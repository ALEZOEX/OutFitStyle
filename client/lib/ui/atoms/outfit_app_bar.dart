import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../theme/theme_controller.dart';

class OutfitAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showThemeToggle;

  const OutfitAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showThemeToggle = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final themeNotifier = ref.read(themeModeProvider.notifier);

    IconData themeIcon;
    switch (themeMode) {
      case ThemeMode.dark:
        themeIcon = Icons.dark_mode_rounded;
        break;
      case ThemeMode.light:
        themeIcon = Icons.light_mode_rounded;
        break;
      case ThemeMode.system:
        themeIcon = Icons.auto_mode_rounded;
        break;
    }

    return AppBar(
      leading: showThemeToggle
          ? IconButton(
              tooltip: 'Тема',
              onPressed: () {
                // цикл: system -> dark -> light -> system
                final next = themeMode == ThemeMode.system
                    ? ThemeMode.dark
                    : (themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.system);
                themeNotifier.setMode(next);
              },
              icon: Icon(themeIcon),
            )
          : null,
      titleSpacing: 0,
      title: Row(
        children: [
          const BrandBadge(),
          const SizedBox(width: 10),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
        ],
      ),
      actions: actions,
    );
  }
}

class BrandBadge extends StatelessWidget {
  const BrandBadge({super.key});

  @override
  Widget build(BuildContext context) {
    const purple = Color(0xFF7C3AED);

    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: purple,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            blurRadius: 14,
            offset: const Offset(0, 8),
            color: purple.withOpacity(0.25),
          ),
        ],
      ),
      child: const Center(
        child: Icon(Icons.checkroom_rounded, color: Colors.white, size: 18),
      ),
    );
  }
}