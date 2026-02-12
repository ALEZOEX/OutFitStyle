import 'package:flutter/material.dart';

/// Custom input field widget with validation and different styles
class AppInput extends StatefulWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onFieldSubmitted;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool enabled;
  final int maxLines;
  final int? maxLength;
  final String? initialValue;
  final InputVariant variant;

  const AppInput({
    Key? key,
    required this.label,
    this.hint,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
    this.maxLines = 1,
    this.maxLength,
    this.initialValue,
    this.variant = InputVariant.filled,
  }) : super(key: key);

  @override
  State<AppInput> createState() => _AppInputState();
}

class _AppInputState extends State<AppInput> {
  late final TextEditingController _controller;
  bool _obscureText = false;

  @override
  void initState() {
    super.initState();
    _controller =
        widget.controller ?? TextEditingController(text: widget.initialValue);
    _obscureText = widget.obscureText;
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    InputDecoration inputDecoration = InputDecoration(
      labelText: widget.label,
      hintText: widget.hint,
      prefixIcon: widget.prefixIcon,
      suffixIcon: _buildSuffixIcon(theme),
      border: _getBorder(theme),
      enabledBorder: _getBorder(theme),
      focusedBorder: _getFocusedBorder(theme),
      errorBorder: _getErrorBorder(theme),
      focusedErrorBorder: _getErrorBorder(theme),
      filled: widget.variant == InputVariant.filled ||
          widget.variant == InputVariant.outlined,
      fillColor: widget.variant == InputVariant.filled
          ? theme.inputDecorationTheme.fillColor
          : null,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
    );

    return TextFormField(
      controller: _controller,
      keyboardType: widget.keyboardType,
      obscureText: _obscureText,
      validator: widget.validator,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onFieldSubmitted,
      enabled: widget.enabled,
      maxLines: widget.maxLines,
      maxLength: widget.maxLength,
      decoration: inputDecoration,
    );
  }

  Widget? _buildSuffixIcon(ThemeData theme) {
    if (widget.obscureText) {
      return IconButton(
        icon: Icon(
          _obscureText
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
          color: theme.hintColor,
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      );
    }
    return widget.suffixIcon;
  }

  InputBorder _getBorder(ThemeData theme) {
    switch (widget.variant) {
      case InputVariant.outlined:
        return OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(
            color: theme.dividerColor,
          ),
        );
      case InputVariant.filled:
        return OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide.none,
        );
      case InputVariant.underline:
        return const UnderlineInputBorder();
    }
  }

  InputBorder _getFocusedBorder(ThemeData theme) {
    switch (widget.variant) {
      case InputVariant.outlined:
        return OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(
            color: theme.primaryColor,
            width: 2.0,
          ),
        );
      case InputVariant.filled:
        return OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(
            color: theme.primaryColor,
            width: 2.0,
          ),
        );
      case InputVariant.underline:
        return UnderlineInputBorder(
          borderSide: BorderSide(
            color: theme.primaryColor,
            width: 2.0,
          ),
        );
    }
  }

  InputBorder _getErrorBorder(ThemeData theme) {
    return const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(8.0)),
      borderSide: BorderSide(
        color: Colors.red, // Using red for error as per Material Design
        width: 2.0,
      ),
    );
  }
}

enum InputVariant { outlined, filled, underline }
