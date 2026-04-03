import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../theme/app_theme.dart';

/// Custom loading indicator widget
class AppLoading extends StatelessWidget {
  final String? message;
  final bool showProgress;
  final double progress;
  final LoadingVariant variant;
  final Color? color;

  const AppLoading({
    super.key,
    this.message,
    this.showProgress = false,
    this.progress = 0.0,
    this.variant = LoadingVariant.indicator,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loadingColor = color ?? theme.colorScheme.primary;

    Widget loader;
    switch (variant) {
      case LoadingVariant.indicator:
        loader = _buildCircularIndicator(loadingColor);
      case LoadingVariant.bar:
        loader = _buildProgressBar(loadingColor);
      case LoadingVariant.dots:
        loader = _buildDotsIndicator(loadingColor);
      case LoadingVariant.pulse:
        loader = _buildPulseIndicator(loadingColor);
      case LoadingVariant.fullscreen:
        loader = _buildCircularIndicator(loadingColor);
    }

    Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        loader,
        if (message != null) ...[
          const SizedBox(height: AppSpacing.lg),
          Text(message!, style: theme.textTheme.bodyMedium),
        ],
      ],
    );

    if (variant == LoadingVariant.fullscreen) {
      return Scaffold(body: Center(child: content));
    }

    return Center(child: content);
  }

  Widget _buildCircularIndicator(Color color) {
    return SizedBox(
      width: 40,
      height: 40,
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(color),
        strokeWidth: 3,
      ),
    );
  }

  Widget _buildProgressBar(Color color) {
    return Container(
      width: 200,
      height: 8,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: showProgress
          ? AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 200 * progress,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
            )
          : LinearProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(color),
              backgroundColor: color.withValues(alpha: 0.2),
            ),
    );
  }

  Widget _buildDotsIndicator(Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        3,
        (index) => Padding(
          padding: EdgeInsets.symmetric(horizontal: index == 0 ? 0 : 4),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 600),
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: index <= DateTime.now().millisecond ~/ 600 % 3
                  ? color
                  : color.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPulseIndicator(Color color) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: const Center(
        child: SizedBox(
          width: 30,
          height: 30,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      ),
    );
  }
}

enum LoadingVariant { indicator, bar, dots, pulse, fullscreen }

/// Shimmer-скелетон для загрузки (Landing style)
class AppShimmer extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const AppShimmer({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  /// Прямоугольный shimmer
  const AppShimmer.rectangular({
    super.key,
    required this.width,
    required this.height,
  }) : borderRadius = null;

  /// Круглый shimmer (аватар)
  const AppShimmer.circular({super.key, required double size})
    : width = size,
      height = size,
      borderRadius = null;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDark ? AppColors.surfaceDarkElevated : AppColors.grey100,
      highlightColor: isDark ? AppColors.surfaceDark : AppColors.grey50,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDarkElevated : AppColors.grey100,
          borderRadius: borderRadius ?? AppRadius.radiusMd,
        ),
      ),
    );
  }
}

/// Скелетон карточки рекомендации
class RecommendationCardShimmer extends StatelessWidget {
  const RecommendationCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusLg),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppShimmer(width: double.infinity, height: 160),
            const SizedBox(height: AppSpacing.lg),
            const AppShimmer(width: 200, height: 18),
            const SizedBox(height: AppSpacing.sm),
            const AppShimmer(width: double.infinity, height: 14),
            const SizedBox(height: AppSpacing.sm),
            const AppShimmer(width: 140, height: 14),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: const [
                AppShimmer(
                  width: 80,
                  height: 32,
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
                SizedBox(width: AppSpacing.sm),
                AppShimmer(
                  width: 60,
                  height: 32,
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
                SizedBox(width: AppSpacing.sm),
                AppShimmer(
                  width: 70,
                  height: 32,
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Скелетон карточки гардероба
class WardrobeItemShimmer extends StatelessWidget {
  const WardrobeItemShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AspectRatio(
            aspectRatio: 1,
            child: AppShimmer(width: double.infinity, height: double.infinity),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                AppShimmer(width: 120, height: 14),
                SizedBox(height: AppSpacing.xs),
                AppShimmer(width: 80, height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Loading overlay
class AppLoadingOverlay extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final String? message;

  const AppLoadingOverlay({
    super.key,
    required this.child,
    this.isLoading = false,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black.withValues(alpha: 0.3),
            child: Center(child: AppLoading(message: message)),
          ),
      ],
    );
  }
}
