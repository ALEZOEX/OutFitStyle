import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Единое пустое состояние в стиле Landing
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Widget? secondaryAction;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
    this.secondaryAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Gradient circle icon — Landing style
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: isDark
                    ? AppGradients.cardDark
                    : AppGradients.cardLight,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 44, color: theme.colorScheme.primary),
            ),
            const SizedBox(height: AppSpacing.xxl),
            Text(
              title,
              style: AppTypography.headlineSmall(context),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              subtitle,
              style: AppTypography.bodyMedium(context).copyWith(height: 1.5),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.xxl),
              SizedBox(
                width: 200,
                child: InkWell(
                  onTap: onAction,
                  borderRadius: AppRadius.radiusPill,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.md,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: AppRadius.radiusPill,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add,
                          size: 18,
                          color: theme.colorScheme.onPrimary,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          actionLabel!,
                          style: TextStyle(
                            color: theme.colorScheme.onPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
            if (secondaryAction != null) ...[
              const SizedBox(height: AppSpacing.md),
              secondaryAction!,
            ],
          ],
        ),
      ),
    );
  }
}
