import 'package:flutter/material.dart';

/// Custom button widget with different styles
class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonStyle? style;
  final TextStyle? textStyle;
  final bool isLoading;
  final Widget? leading;
  final EdgeInsetsGeometry padding;
  final ButtonVariant variant;

  const AppButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.style,
    this.textStyle,
    this.isLoading = false,
    this.leading,
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
    this.variant = ButtonVariant.primary,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    ButtonStyle defaultStyle;
    switch (variant) {
      case ButtonVariant.primary:
        defaultStyle = ElevatedButton.styleFrom(
          backgroundColor: isLoading ? Colors.grey : theme.primaryColor,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey.shade300,
          disabledForegroundColor: Colors.grey.shade500,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        );
        break;
      case ButtonVariant.secondary:
        defaultStyle = ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: theme.primaryColor,
          side: BorderSide(color: theme.primaryColor),
          disabledBackgroundColor: Colors.transparent,
          disabledForegroundColor: Colors.grey.shade400,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
            side: BorderSide(color: theme.disabledColor),
          ),
        );
        break;
      case ButtonVariant.outlined:
        defaultStyle = OutlinedButton.styleFrom(
          side: BorderSide(color: theme.primaryColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        );
        break;
      case ButtonVariant.text:
        defaultStyle = TextButton.styleFrom(
          foregroundColor: theme.primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        );
        break;
    }

    Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (leading != null) ...[
          leading!,
          const SizedBox(width: 8.0),
        ],
        if (isLoading)
          Container(
            width: 16,
            height: 16,
            margin: const EdgeInsets.only(right: 8.0),
            child: const CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
        else
          const SizedBox(width: 24), // To maintain consistent spacing
        Text(
          text,
          style: textStyle ??
              theme.textTheme.labelLarge?.copyWith(
                color: variant == ButtonVariant.text ||
                        variant == ButtonVariant.outlined
                    ? theme.primaryColor
                    : Colors.white,
              ),
        ),
      ],
    );

    return Padding(
      padding: padding,
      child: SizedBox(
        width: double.infinity,
        child: !isLoading
            ? _buildButton(defaultStyle, content)
            : _buildDisabledButton(defaultStyle, content),
      ),
    );
  }

  Widget _buildButton(ButtonStyle style, Widget content) {
    switch (variant) {
      case ButtonVariant.primary:
        return ElevatedButton(
          onPressed: onPressed,
          style: this.style ?? style,
          child: content,
        );
      case ButtonVariant.secondary:
        return ElevatedButton(
          onPressed: onPressed,
          style: this.style ?? style,
          child: content,
        );
      case ButtonVariant.outlined:
        return OutlinedButton(
          onPressed: onPressed,
          style: this.style ?? style,
          child: content,
        );
      case ButtonVariant.text:
        return TextButton(
          onPressed: onPressed,
          style: this.style ?? style,
          child: content,
        );
    }
  }

  Widget _buildDisabledButton(ButtonStyle style, Widget content) {
    return ElevatedButton(
      onPressed: null,
      style: style.copyWith(
        backgroundColor: MaterialStateProperty.all(Colors.grey.shade400),
      ),
      child: content,
    );
  }
}

enum ButtonVariant { primary, secondary, outlined, text }
