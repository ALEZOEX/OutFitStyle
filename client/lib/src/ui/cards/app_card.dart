import 'dart:ui';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Унифицированная карточка в стиле Landing
/// Поддерживает: обычный, glass, gradient варианты
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final CardVariant variant;
  final Gradient? gradient;
  final double? width;
  final double? height;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.variant = CardVariant.outlined,
    this.gradient,
    this.width,
    this.height,
  });

  /// Glassmorphism карточка (Landing glass-card)
  const AppCard.glass({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.gradient,
    this.width,
    this.height,
  }) : variant = CardVariant.glass;

  /// Градиентная карточка
  const AppCard.gradient({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.gradient,
    this.width,
    this.height,
  }) : variant = CardVariant.gradient;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget card = switch (variant) {
      CardVariant.outlined => _buildOutlined(context, isDark),
      CardVariant.glass => _buildGlass(context, isDark),
      CardVariant.gradient => _buildGradient(context, isDark),
      CardVariant.elevated => _buildElevated(context, isDark),
      CardVariant.flat => _buildFlat(context, isDark),
    };

    card = Container(
      width: width,
      height: height,
      margin: margin ?? EdgeInsets.zero,
      child: card,
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: AppRadius.radiusLg,
        child: card,
      );
    }

    return card;
  }

  /// Обычная карточка с тонкой рамкой (Landing default)
  Widget _buildOutlined(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDarkElevated : Colors.white,
        borderRadius: AppRadius.radiusLg,
        border: Border.all(
          color: isDark
              ? const Color(0xFF374151).withValues(alpha: 0.5)
              : AppColors.grey200,
        ),
      ),
      padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
      child: child,
    );
  }

  /// iOS-style Glassmorphism
  Widget _buildGlass(BuildContext context, bool isDark) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: AppRadius.radiusXxl,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(
              alpha: isDark ? 0.2 : 0.1,
            ),
            blurRadius: 24,
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
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        Colors.white.withValues(alpha: 0.12),
                        Colors.white.withValues(alpha: 0.04),
                      ]
                    : [
                        Colors.white.withValues(alpha: 0.7),
                        Colors.white.withValues(alpha: 0.4),
                      ],
              ),
              borderRadius: AppRadius.radiusXxl,
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.2)
                    : Colors.black.withValues(alpha: 0.08),
                width: 1,
              ),
            ),
            child: Stack(
              children: [
                // Верхний блик (iOS highlight)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 40,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withValues(alpha: isDark ? 0.1 : 0.2),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 1.0],
                      ),
                      borderRadius: BorderRadius.vertical(
                        top: AppRadius.radiusXxl.topLeft,
                      ),
                    ),
                  ),
                ),
                // Контент
                Padding(
                  padding: padding ?? const EdgeInsets.all(AppSpacing.xxl),
                  child: child,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Градиентная карточка
  Widget _buildGradient(BuildContext context, bool isDark) {
    final effectiveGradient =
        gradient ?? (isDark ? AppGradients.cardDark : AppGradients.cardLight);

    return Container(
      decoration: BoxDecoration(
        gradient: effectiveGradient,
        borderRadius: AppRadius.radiusLg,
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
      ),
      padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
      child: child,
    );
  }

  /// Карточка с тенью
  Widget _buildElevated(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDarkElevated : Colors.white,
        borderRadius: AppRadius.radiusLg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
      child: child,
    );
  }

  /// Плоская карточка без рамки/тени
  Widget _buildFlat(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.surfaceDarkElevated.withValues(alpha: 0.5)
            : AppColors.grey50,
        borderRadius: AppRadius.radiusLg,
      ),
      padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
      child: child,
    );
  }
}

enum CardVariant { outlined, glass, gradient, elevated, flat }

// ══════════════════════════════════════════════════════════════
// Glassmorphism helper для модальных bottom sheets
// ══════════════════════════════════════════════════════════════

/// iOS-style Glassmorphism контейнер для модалок и bottom sheets
class GlassContainer extends StatelessWidget {
  final Widget child;
  final double blur;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;

  const GlassContainer({
    super.key,
    required this.child,
    this.blur = 20,
    this.padding,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    final radius = borderRadius ?? AppRadius.radiusXxl;

    return Container(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(
              alpha: isDark ? 0.25 : 0.12,
            ),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        const Color(0xFF1F2937).withValues(alpha: 0.6),
                        const Color(0xFF111827).withValues(alpha: 0.4),
                      ]
                    : [
                        Colors.white.withValues(alpha: 0.75),
                        Colors.white.withValues(alpha: 0.5),
                      ],
              ),
              borderRadius: radius,
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.15)
                    : Colors.black.withValues(alpha: 0.06),
                width: 1,
              ),
            ),
            child: Stack(
              children: [
                // Верхний блик
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 50,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withValues(alpha: isDark ? 0.08 : 0.18),
                          Colors.transparent,
                        ],
                      ),
                      borderRadius: BorderRadius.vertical(top: radius.topLeft),
                    ),
                  ),
                ),
                // Контент
                Padding(
                  padding: padding ?? const EdgeInsets.all(AppSpacing.xxl),
                  child: child,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
