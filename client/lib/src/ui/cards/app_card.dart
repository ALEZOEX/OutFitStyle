import 'package:flutter/material.dart';

/// Custom card widget with different styles
class AppCard extends StatelessWidget {
  final Widget child;
  final Color? color;
  final double? elevation;
  final ShapeBorder? shape;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final Gradient? gradient;
  final Widget? header;
  final Widget? footer;
  final bool showShadow;

  const AppCard({
    Key? key,
    required this.child,
    this.color,
    this.elevation,
    this.shape,
    this.margin,
    this.padding = const EdgeInsets.all(16.0),
    this.gradient,
    this.header,
    this.footer,
    this.showShadow = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (header != null) ...[header!, const SizedBox(height: 8.0)],
        Expanded(child: child),
        if (footer != null) ...[const SizedBox(height: 8.0), footer!],
      ],
    );

    BoxDecoration? decoration;
    if (gradient != null) {
      decoration = BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(12.0),
      );
    }

    return Card(
      color: color,
      elevation: showShadow ? elevation ?? 2.0 : 0.0,
      shape:
          shape ??
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
            side: BorderSide(color: theme.dividerColor, width: 0.5),
          ),
      margin: margin ?? const EdgeInsets.all(8.0),
      child: Container(
        padding: padding,
        decoration: decoration,
        child: content,
      ),
    );
  }
}

/// Specialized card for outfit recommendations
class OutfitRecommendationCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? image;
  final VoidCallback? onTap;
  final List<String>? tags;

  const OutfitRecommendationCard({
    Key? key,
    required this.title,
    required this.subtitle,
    this.image,
    this.onTap,
    this.tags,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (image != null) ...[
            ClipRRect(borderRadius: BorderRadius.circular(8.0), child: image),
            const SizedBox(height: 12.0),
          ],
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4.0),
          Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
          if (tags != null && tags!.isNotEmpty) ...[
            const SizedBox(height: 8.0),
            Wrap(
              spacing: 4.0,
              runSpacing: 4.0,
              children: tags!.map((tag) => _buildTag(tag, context)).toList(),
            ),
          ],
        ],
      ),
      showShadow: true,
    );
  }

  Widget _buildTag(String tag, BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Text(
        tag,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).primaryColor,
          fontSize: 12.0,
        ),
      ),
    );
  }
}
