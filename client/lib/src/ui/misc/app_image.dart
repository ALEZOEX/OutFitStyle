import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Custom image widget with loading and error handling
class AppImage extends StatelessWidget {
  final String imageUrl;
  final String? placeholderAsset;
  final String? errorAsset;
  final BoxFit fit;
  final double? width;
  final double? height;
  final bool useCache;
  final ImageVariant variant;
  final double borderRadius;
  final Color? backgroundColor;

  const AppImage({
    Key? key,
    required this.imageUrl,
    this.placeholderAsset,
    this.errorAsset,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.useCache = true,
    this.variant = ImageVariant.rectangle,
    this.borderRadius = 0.0,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget imageWidget = useCache
        ? CachedNetworkImage(
            imageUrl: imageUrl,
            placeholder: (context, url) => _buildPlaceholder(theme),
            errorWidget: (context, url, error) => _buildError(theme),
            fit: fit,
            width: width,
            height: height,
          )
        : Image.network(
            imageUrl,
            fit: fit,
            width: width,
            height: height,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return _buildPlaceholder(theme);
            },
            errorBuilder: (context, error, stackTrace) => _buildError(theme),
          );

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: variant == ImageVariant.circle
            ? BorderRadius.circular((width ?? height ?? 100.0) / 2)
            : BorderRadius.circular(borderRadius),
      ),
      child: ClipRRect(
        borderRadius: variant == ImageVariant.circle
            ? BorderRadius.circular((width ?? height ?? 100.0) / 2)
            : BorderRadius.circular(borderRadius),
        child: imageWidget,
      ),
    );
  }

  Widget _buildPlaceholder(ThemeData theme) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: variant == ImageVariant.circle
            ? BorderRadius.circular((width ?? height ?? 100.0) / 2)
            : BorderRadius.circular(borderRadius),
      ),
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
        ),
      ),
    );
  }

  Widget _buildError(ThemeData theme) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: variant == ImageVariant.circle
            ? BorderRadius.circular((width ?? height ?? 100.0) / 2)
            : BorderRadius.circular(borderRadius),
      ),
      child: Center(
        child: Icon(
          Icons.broken_image_outlined,
          color: theme.disabledColor,
          size: width != null
              ? width! * 0.3
              : height != null
                  ? height! * 0.3
                  : 40.0,
        ),
      ),
    );
  }
}

/// Specialized image for outfit recommendations
class OutfitImage extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  const OutfitImage({
    Key? key,
    required this.imageUrl,
    required this.title,
    this.subtitle,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8.0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.0),
          child: Stack(
            children: [
              AppImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                height: 200.0,
                variant: ImageVariant.rectangle,
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4.0),
                        Text(
                          subtitle!,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12.0,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum ImageVariant { rectangle, circle }
