import 'package:flutter/material.dart';

/// Custom icon button widget
class AppIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? color;
  final Color? backgroundColor;
  final double size;
  final double iconSize;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final IconButtonVariant variant;
  final String? tooltip;
  final bool isLoading;

  const AppIconButton({
    Key? key,
    required this.icon,
    this.onPressed,
    this.color,
    this.backgroundColor,
    this.size = 48.0,
    this.iconSize = 24.0,
    this.padding = const EdgeInsets.all(12.0),
    this.borderRadius = 8.0,
    this.variant = IconButtonVariant.filled,
    this.tooltip,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color buttonColor = backgroundColor ?? theme.cardColor;
    Color iconColor = color ?? theme.primaryColor;

    Widget buttonContent = isLoading
        ? SizedBox(
            width: iconSize,
            height: iconSize,
            child: CircularProgressIndicator(
              strokeWidth: 2.0,
              valueColor: AlwaysStoppedAnimation<Color>(iconColor),
            ),
          )
        : Icon(
            icon,
            size: iconSize,
            color: iconColor,
          );

    Widget button = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: variant == IconButtonVariant.filled
            ? buttonColor
            : Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius),
        border: variant == IconButtonVariant.outlined
            ? Border.all(color: buttonColor, width: 2.0)
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Container(
            padding: padding,
            child: Center(child: buttonContent),
          ),
        ),
      ),
    );

    if (tooltip != null) {
      return Tooltip(
        message: tooltip,
        child: button,
      );
    }

    return button;
  }
}

/// Specialized icon button for favorites
class FavoriteButton extends StatefulWidget {
  final bool isFavorite;
  final VoidCallback? onToggle;
  final double size;
  final Color activeColor;
  final Color inactiveColor;

  const FavoriteButton({
    Key? key,
    this.isFavorite = false,
    this.onToggle,
    this.size = 24.0,
    this.activeColor = Colors.red,
    this.inactiveColor = Colors.grey,
  }) : super(key: key);

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton> {
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.isFavorite;
  }

  @override
  Widget build(BuildContext context) {
    return AppIconButton(
      icon: _isFavorite ? Icons.favorite : Icons.favorite_border,
      onPressed: () {
        setState(() {
          _isFavorite = !_isFavorite;
        });
        widget.onToggle?.call();
      },
      color: _isFavorite ? widget.activeColor : widget.inactiveColor,
      size: widget.size + 24.0,
      iconSize: widget.size,
      tooltip: _isFavorite ? 'Удалить из избранного' : 'Добавить в избранное',
    );
  }
}

enum IconButtonVariant { filled, outlined }
