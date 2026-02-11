import 'package:flutter/material.dart';

/// Custom loading indicator widget
class AppLoading extends StatelessWidget {
  final String? message;
  final bool showProgress;
  final double progress;
  final LoadingVariant variant;
  final Color? color;

  const AppLoading({
    Key? key,
    this.message,
    this.showProgress = false,
    this.progress = 0.0,
    this.variant = LoadingVariant.indicator,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loadingColor = color ?? theme.primaryColor;

    Widget loader;
    switch (variant) {
      case LoadingVariant.indicator:
        loader = _buildCircularIndicator(loadingColor);
        break;
      case LoadingVariant.bar:
        loader = _buildProgressBar(loadingColor);
        break;
      case LoadingVariant.dots:
        loader = _buildDotsIndicator(loadingColor);
        break;
      case LoadingVariant.pulse:
        loader = _buildPulseIndicator(loadingColor);
        break;
      case LoadingVariant.fullscreen:
        // This case is handled separately in the build method
        loader = _buildCircularIndicator(loadingColor);
        break;
    }

    Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        loader,
        if (message != null) ...[
          const SizedBox(height: 16.0),
          Text(
            message!,
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ],
    );

    if (variant == LoadingVariant.fullscreen) {
      return Scaffold(
        body: Center(child: content),
      );
    }

    return Center(child: content);
  }

  Widget _buildCircularIndicator(Color color) {
    return SizedBox(
      width: 40.0,
      height: 40.0,
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(color),
        strokeWidth: 3.0,
      ),
    );
  }

  Widget _buildProgressBar(Color color) {
    return Container(
      width: 200.0,
      height: 8.0,
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: showProgress
          ? AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 200.0 * progress,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4.0),
              ),
            )
          : LinearProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(color),
              backgroundColor: color.withOpacity(0.2),
            ),
    );
  }

  Widget _buildDotsIndicator(Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        3,
        (index) => Padding(
          padding: EdgeInsets.symmetric(horizontal: index == 0 ? 0 : 4.0),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 600),
            width: 12.0,
            height: 12.0,
            decoration: BoxDecoration(
              color: index <= DateTime.now().millisecond ~/ 600 % 3
                  ? color
                  : color.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPulseIndicator(Color color) {
    return Container(
      width: 60.0,
      height: 60.0,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: SizedBox(
          width: 30.0,
          height: 30.0,
          child: CircularProgressIndicator(
            strokeWidth: 3.0,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      ),
    );
  }
}

enum LoadingVariant { indicator, bar, dots, pulse, fullscreen }

/// Loading overlay that can be shown over the entire screen
class AppLoadingOverlay extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final String? message;

  const AppLoadingOverlay({
    Key? key,
    required this.child,
    this.isLoading = false,
    this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: Center(
              child: AppLoading(message: message),
            ),
          ),
      ],
    );
  }
}
