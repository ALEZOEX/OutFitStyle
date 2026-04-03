import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

/// Premium кнопка с мягким градиентом и цветной тенью
class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Widget? leading;
  final ButtonVariant variant;
  final double? width;
  final double height;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.leading,
    this.variant = ButtonVariant.primary,
    this.width,
    this.height = AppSpacing.buttonHeight,
  });

  const AppButton.small({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.leading,
    this.variant = ButtonVariant.primary,
    this.width,
    this.height = 40,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: switch (variant) {
        ButtonVariant.primary => _buildGradientButton(context),
        ButtonVariant.secondary => _buildSecondaryButton(context),
        ButtonVariant.outlined => _buildOutlinedButton(context),
        ButtonVariant.text => _buildTextButton(context),
        ButtonVariant.danger => _buildDangerButton(context),
      },
    );
  }

  /// Премиальная кнопка — мягкий градиент + цветная тень + border
  Widget _buildGradientButton(BuildContext context) {
    final theme = Theme.of(context);
    final isDisabled = onPressed == null || isLoading;
    final isDark = theme.brightness == Brightness.dark;

    // Градиент из theme colors
    final colors = isDark
        ? [
            theme.colorScheme.primary.withValues(alpha: 0.8),
            theme.colorScheme.secondary.withValues(alpha: 0.7),
          ]
        : [theme.colorScheme.primary, theme.colorScheme.secondary];

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: isDisabled
            ? null
            : LinearGradient(
                colors: colors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        color: isDisabled
            ? Theme.of(context).colorScheme.surfaceContainerHighest
            : null,
        borderRadius: AppRadius.radiusPill,
        border: isDisabled
            ? null
            : Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1),
        boxShadow: isDisabled
            ? null
            : [
                // Мягкая цветная тень
                BoxShadow(
                  color: colors.first.withValues(alpha: 0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
                // Лёгкое свечение
                BoxShadow(
                  color: colors.first.withValues(alpha: 0.1),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: AppRadius.radiusPill,
          child: Center(child: _buildContent(context, isPrimary: true)),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusPill),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
      ),
      child: _buildContent(context, isPrimary: false),
    );
  }

  Widget _buildOutlinedButton(BuildContext context) {
    return OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        elevation: 0,
        side: BorderSide(color: Theme.of(context).colorScheme.outline),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusPill),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
      ),
      child: _buildContent(context, isPrimary: false),
    );
  }

  Widget _buildTextButton(BuildContext context) {
    return TextButton(
      onPressed: isLoading ? null : onPressed,
      style: TextButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusMd),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      ),
      child: _buildContent(context, isPrimary: false),
    );
  }

  Widget _buildDangerButton(BuildContext context) {
    final theme = Theme.of(context);
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.colorScheme.error,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusPill),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
      ),
      child: _buildContent(context, isPrimary: true),
    );
  }

  Widget _buildContent(BuildContext context, {required bool isPrimary}) {
    if (isLoading) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: isPrimary
                  ? Colors.white
                  : Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            'Загрузка...',
            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (leading != null) ...[
          leading!,
          const SizedBox(width: AppSpacing.sm),
        ],
        Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isPrimary ? Colors.white : null,
          ),
        ),
      ],
    );
  }
}

enum ButtonVariant { primary, secondary, outlined, text, danger }
