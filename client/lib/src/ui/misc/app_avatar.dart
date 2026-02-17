import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

/// Custom avatar widget
class AppAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? name;
  final double radius;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final String? placeholderText;
  final Widget? placeholderWidget;
  final VoidCallback? onTap;
  final AvatarVariant variant;
  final double borderWidth;
  final Color borderColor;

  const AppAvatar({
    Key? key,
    this.imageUrl,
    this.name,
    this.radius = 24.0,
    this.backgroundColor,
    this.foregroundColor,
    this.placeholderText,
    this.placeholderWidget,
    this.onTap,
    this.variant = AvatarVariant.circle,
    this.borderWidth = 0.0,
    this.borderColor = Colors.transparent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color bgColor = backgroundColor ?? theme.primaryColor;
    Color fgColor = foregroundColor ?? Colors.white;

    Widget avatarContent = _buildAvatarContent(bgColor, fgColor, theme);

    if (borderWidth > 0) {
      avatarContent = Container(
        decoration: BoxDecoration(
          shape: variant == AvatarVariant.circle
              ? BoxShape.circle
              : BoxShape.rectangle,
          border: Border.all(
            color: borderColor,
            width: borderWidth,
          ),
          borderRadius: variant == AvatarVariant.circle
              ? null
              : BorderRadius.circular(radius),
        ),
        child: Padding(
          padding: EdgeInsets.all(borderWidth),
          child: avatarContent,
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: ClipOval(
        clipBehavior: Clip.hardEdge,
        child: Container(
          width: radius * 2,
          height: radius * 2,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: bgColor,
          ),
          child: avatarContent,
        ),
      ),
    );
  }

  Widget _buildAvatarContent(Color bgColor, Color fgColor, ThemeData theme) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return Image.network(
        imageUrl!,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            return child;
          }
          return _buildPlaceholder(bgColor, fgColor, theme);
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholder(bgColor, fgColor, theme);
        },
      );
    } else {
      return _buildPlaceholder(bgColor, fgColor, theme);
    }
  }

  Widget _buildPlaceholder(Color bgColor, Color fgColor, ThemeData theme) {
    if (placeholderWidget != null) {
      return placeholderWidget!;
    }

    // Используем SVG placeholder вместо текста
    return SvgPicture.asset(
      'assets/icons/avatar_placeholder.svg',
      width: radius * 2,
      height: radius * 2,
      fit: BoxFit.cover,
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';

    List<String> parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}';
    } else {
      return parts.first.isNotEmpty ? parts.first.substring(0, 1) : '?';
    }
  }
}

enum AvatarVariant { circle, square }

/// Specialized avatar for user profiles
class UserProfileAvatar extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final double radius;
  final bool isOnline;

  const UserProfileAvatar({
    Key? key,
    this.imageUrl,
    required this.name,
    this.radius = 32.0,
    this.isOnline = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        AppAvatar(
          imageUrl: imageUrl,
          name: name,
          radius: radius,
        ),
        if (isOnline)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: radius * 0.4,
              height: radius * 0.4,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 2.0,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
