import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Виджет-обёртка для ограничения ширины контента
///
/// Используется для центрирования контента на больших экранах
/// и обеспечения комфортной ширины для чтения/восприятия.
///
/// Параметры:
/// - [child] — дочерний виджет
/// - [maxWidth] — максимальная ширина (по умолчанию 1200px)
/// - [padding] — внутренние отступы (по умолчанию 16px по горизонтали)
/// - [center] — центрировать контент (по умолчанию true)
class MaxWidthContainer extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;
  final bool center;

  const MaxWidthContainer({
    super.key,
    required this.child,
    this.maxWidth = 1200,
    this.padding,
    this.center = true,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 16),
          child: child,
        ),
      ),
    );
  }
}

/// Виджет-обёртка для ограничения ширины с адаптивными отступами
///
/// На мобильных устройствах (ширина < 600px) использует полную ширину
/// с минимальными отступами. На планшетах и десктопах ограничивает
/// ширину и центрирует контент.
class ResponsiveMaxWidthContainer extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? mobilePadding;
  final EdgeInsetsGeometry? desktopPadding;

  const ResponsiveMaxWidthContainer({
    super.key,
    required this.child,
    this.maxWidth = 1200,
    this.mobilePadding = const EdgeInsets.symmetric(horizontal: 16),
    this.desktopPadding = const EdgeInsets.symmetric(horizontal: 24),
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        final isTablet =
            constraints.maxWidth >= 600 && constraints.maxWidth < 1024;

        // Адаптивная максимальная ширина
        final effectiveMaxWidth =
            isMobile
                ? double.infinity
                : isTablet
                ? math.min(maxWidth * 0.9, constraints.maxWidth)
                : maxWidth;

        final effectivePadding = isMobile ? mobilePadding : desktopPadding;

        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: effectiveMaxWidth),
            child: Padding(padding: effectivePadding, child: child),
          ),
        );
      },
    );
  }
}
