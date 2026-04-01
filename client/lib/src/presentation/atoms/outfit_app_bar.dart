import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/theme_controller.dart';
import '../../theme/app_theme.dart';
import '../design_system/outfit_style_components.dart';

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
                    : (themeMode == ThemeMode.dark
                          ? ThemeMode.light
                          : ThemeMode.system);
                themeNotifier.setMode(next);
              },
              icon: Icon(themeIcon),
              style: OutfitStyleComponents.iconButtonStyle(),
            )
          : null,
      titleSpacing: 0,
      title: Row(
        children: [
          const BrandBadge(),
          const SizedBox(width: 10),
          Text(
            title,
            style: OutfitStyleComponents.titleLarge(
              context,
            ).copyWith(fontWeight: FontWeight.w900),
          ),
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
    final primary = AppColors.primary;

    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: primary,
        borderRadius: AppRadius.radiusMd,
        boxShadow: [
          BoxShadow(
            blurRadius: 14,
            offset: const Offset(0, 8),
            color: primary.withValues(alpha: 0.25),
          ),
        ],
      ),
      child: const Center(
        child: Icon(Icons.checkroom_rounded, color: Colors.white, size: 18),
      ),
    );
  }
}
