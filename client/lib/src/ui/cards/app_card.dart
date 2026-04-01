import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

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
    final effectivePadding = padding ?? const EdgeInsets.all(AppSpacing.lg);
    final effectiveMargin = margin ?? EdgeInsets.zero;

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
      margin: effectiveMargin,
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

  /// Glassmorphism (Landing glass-card)
  Widget _buildGlass(BuildContext context, bool isDark) {
    return ClipRRect(
      borderRadius: AppRadius.radiusLg,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.white.withValues(alpha: 0.6),
            borderRadius: AppRadius.radiusLg,
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.white.withValues(alpha: 0.4),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
          child: child,
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

/// Обёртка для glassmorphism-эффекта на модалках
class GlassContainer extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;

  const GlassContainer({
    super.key,
    required this.child,
    this.blur = 20,
    this.opacity = 0.08,
    this.padding,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final radius = borderRadius ?? AppRadius.radiusXxl;

    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: opacity * 0.5)
                : Colors.white.withValues(alpha: opacity + 0.5),
            borderRadius: radius,
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.white.withValues(alpha: 0.3),
            ),
          ),
          padding: padding ?? const EdgeInsets.all(AppSpacing.xxl),
          child: child,
        ),
      ),
    );
  }
}
