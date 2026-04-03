import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:outfitstyle_client/src/theme/app_theme.dart';

/// Glass-style snackbar for success/error notifications
class GlassSnackBar {
  static void show(
    BuildContext context, {
    required String message,
    GlassSnackBarVariant variant = GlassSnackBarVariant.success,
    IconData? icon,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 3),
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color iconColor;
    IconData displayIcon;
    Gradient gradient;

    switch (variant) {
      case GlassSnackBarVariant.success:
        iconColor = Colors.white;
        displayIcon = icon ?? Icons.check_circle_outline;
        gradient = LinearGradient(
          colors: [
            theme.colorScheme.primary.withValues(alpha: isDark ? 0.6 : 0.5),
            theme.colorScheme.primary.withValues(alpha: isDark ? 0.4 : 0.3),
          ],
        );
        break;
      case GlassSnackBarVariant.error:
        iconColor = Colors.white;
        displayIcon = icon ?? Icons.error_outline;
        gradient = LinearGradient(
          colors: [
            theme.colorScheme.error.withValues(alpha: isDark ? 0.6 : 0.5),
            theme.colorScheme.error.withValues(alpha: isDark ? 0.4 : 0.3),
          ],
        );
        break;
      case GlassSnackBarVariant.warning:
        iconColor = Colors.white;
        displayIcon = icon ?? Icons.warning_amber_outlined;
        gradient = LinearGradient(
          colors: [
            Colors.orange.withValues(alpha: isDark ? 0.6 : 0.5),
            Colors.orange.withValues(alpha: isDark ? 0.4 : 0.3),
          ],
        );
        break;
    }

    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Material(
              color: Colors.transparent,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 480),
                decoration: BoxDecoration(
                  borderRadius: AppRadius.radiusXxl,
                  boxShadow: [
                    BoxShadow(
                      color: variant == GlassSnackBarVariant.success
                          ? theme.colorScheme.primary.withValues(alpha: 0.3)
                          : variant == GlassSnackBarVariant.error
                          ? theme.colorScheme.error.withValues(alpha: 0.3)
                          : Colors.orange.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: AppRadius.radiusXxl,
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: gradient,
                        borderRadius: AppRadius.radiusXxl,
                        border: Border.all(
                          color: Colors.white.withValues(
                            alpha: isDark ? 0.15 : 0.2,
                          ),
                          width: 1,
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              Icon(displayIcon, color: iconColor, size: 24),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  message,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              if (actionLabel != null && onAction != null)
                                TextButton(
                                  onPressed: () {
                                    onAction();
                                    overlayEntry.remove();
                                  },
                                  child: Text(
                                    actionLabel,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(duration, () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }

  static void showSuccess(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    show(context, message: message, variant: GlassSnackBarVariant.success, duration: duration);
  }

  static void showError(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 4),
  }) {
    show(context, message: message, variant: GlassSnackBarVariant.error, duration: duration);
  }

  static void showWarning(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    show(context, message: message, variant: GlassSnackBarVariant.warning, duration: duration);
  }
}

enum GlassSnackBarVariant { success, error, warning }
