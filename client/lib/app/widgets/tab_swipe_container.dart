import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../ui/atoms/haptics.dart';

class TabSwipeContainer extends StatefulWidget {
  final StatefulNavigationShell navigationShell;
  final List<Widget> children;

  /// Ключи навигаторов веток — чтобы понимать, можно ли pop (и не перехватывать back жесты).
  final List<GlobalKey<NavigatorState>> branchNavigatorKeys;

  /// Ширина “активной зоны” свайпа по краям (dp)
  final double edgeWidth;

  const TabSwipeContainer({
    super.key,
    required this.navigationShell,
    required this.children,
    required this.branchNavigatorKeys,
    this.edgeWidth = 18,
  });

  @override
  State<TabSwipeContainer> createState() => _TabSwipeContainerState();
}

class _TabSwipeContainerState extends State<TabSwipeContainer> {
  late final PageController _pc;
  int _syncedIndex = 0;

  double _dragDx = 0;

  static const double _minDelta = 55;     // минимальный “протяг” в dp
  static const double _minVelocity = 650; // px/s

  @override
  void initState() {
    super.initState();
    _syncedIndex = widget.navigationShell.currentIndex;
    _pc = PageController(initialPage: _syncedIndex);
  }

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  bool _currentBranchCanPop() {
    final idx = widget.navigationShell.currentIndex;
    if (idx < 0 || idx >= widget.branchNavigatorKeys.length) return false;
    return widget.branchNavigatorKeys[idx].currentState?.canPop() ?? false;
  }

  void _goTo(int index) {
    if (index < 0 || index >= widget.children.length) return;
    if (index == widget.navigationShell.currentIndex) return;

    Haptics.selection();
    widget.navigationShell.goBranch(index);
  }

  void _syncToShellIndex() {
    final idx = widget.navigationShell.currentIndex;
    if (!_pc.hasClients) return;

    if (idx != _syncedIndex) {
      _syncedIndex = idx;
      _pc.animateToPage(
        idx,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Поддержка: тап по bottom nav / deep link — анимируем PageView к нужной вкладке
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _syncToShellIndex();
    });

    final idx = widget.navigationShell.currentIndex;

    return Stack(
      children: [
        PageView(
          controller: _pc,
          physics: const NeverScrollableScrollPhysics(), // важно: PageView не ворует жесты у контента
          children: widget.children,
        ),

        // Левый край: перейти на предыдущую вкладку (свайп вправо)
        Positioned(
          left: 0,
          top: 0,
          bottom: 0,
          width: widget.edgeWidth,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onHorizontalDragStart: (_) => _dragDx = 0,
            onHorizontalDragUpdate: (d) => _dragDx += d.delta.dx,
            onHorizontalDragEnd: (d) {
              // Если текущая ветка может pop — не мешаем навигации назад
              if (_currentBranchCanPop()) return;

              final v = d.primaryVelocity ?? 0;
              final should = _dragDx > _minDelta || v > _minVelocity;

              if (should) _goTo(idx - 1);
            },
          ),
        ),

        // Правый край: перейти на следующую вкладку (свайп влево)
        Positioned(
          right: 0,
          top: 0,
          bottom: 0,
          width: widget.edgeWidth,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onHorizontalDragStart: (_) => _dragDx = 0,
            onHorizontalDragUpdate: (d) => _dragDx += d.delta.dx,
            onHorizontalDragEnd: (d) {
              if (_currentBranchCanPop()) return;

              final v = d.primaryVelocity ?? 0;
              final should = _dragDx < -_minDelta || v < -_minVelocity;

              if (should) _goTo(idx + 1);
            },
          ),
        ),
      ],
    );
  }
}