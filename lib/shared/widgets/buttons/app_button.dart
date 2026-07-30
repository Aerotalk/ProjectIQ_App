import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_animation.dart';
import 'package:flutter_animate/flutter_animate.dart';

enum AppButtonVariant { primary, secondary, outline, ghost, danger }

class AppButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final bool isDisabled;
  final IconData? icon;
  final bool isFullWidth;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.isDisabled = false,
    this.icon,
    this.isFullWidth = false,
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color backgroundColor;
    Color foregroundColor;
    Color? borderColor;

    switch (widget.variant) {
      case AppButtonVariant.primary:
        backgroundColor = isDark ? AppColors.primaryDark : AppColors.primaryLight;
        foregroundColor = isDark ? AppColors.primaryForegroundDark : AppColors.primaryForegroundLight;
        break;
      case AppButtonVariant.secondary:
        backgroundColor = isDark ? AppColors.secondaryDark : AppColors.secondaryLight;
        foregroundColor = isDark ? AppColors.secondaryForegroundDark : AppColors.secondaryForegroundLight;
        break;
      case AppButtonVariant.outline:
        backgroundColor = Colors.transparent;
        foregroundColor = isDark ? AppColors.foregroundDark : AppColors.foregroundLight;
        borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
        break;
      case AppButtonVariant.ghost:
        backgroundColor = Colors.transparent;
        foregroundColor = isDark ? AppColors.foregroundDark : AppColors.foregroundLight;
        break;
      case AppButtonVariant.danger:
        backgroundColor = isDark ? AppColors.destructiveDark : AppColors.destructiveLight;
        foregroundColor = isDark ? AppColors.destructiveForegroundDark : AppColors.destructiveForegroundLight;
        break;
    }

    final bool effectiveDisabled = widget.isDisabled || widget.isLoading;
    if (effectiveDisabled) {
      if (widget.variant != AppButtonVariant.outline && widget.variant != AppButtonVariant.ghost) {
        backgroundColor = backgroundColor.withValues(alpha: 0.5);
      }
      foregroundColor = foregroundColor.withValues(alpha: 0.5);
    }

    Widget content = Row(
      mainAxisSize: widget.isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.isLoading) ...[
          SizedBox(
            width: AppSpacing.s16,
            height: AppSpacing.s16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
            ),
          ),
          const SizedBox(width: AppSpacing.s8),
        ] else if (widget.icon != null) ...[
          Icon(widget.icon, size: AppSpacing.s16, color: foregroundColor),
          const SizedBox(width: AppSpacing.s8),
        ],
        Text(
          widget.text,
          style: AppTypography.button.copyWith(color: foregroundColor),
        ),
      ],
    );

    final buttonCore = AnimatedContainer(
      duration: AppAnimation.fast,
      curve: AppAnimation.defaultCurve,
      width: widget.isFullWidth ? double.infinity : null,
      height: 40.0, // standard Tailwind button h-10 (40px)
      child: Material(
        color: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          side: borderColor != null
              ? BorderSide(color: borderColor, width: 1.0)
              : BorderSide.none,
        ),
        child: InkWell(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          onTap: effectiveDisabled ? null : widget.onPressed,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          splashColor: foregroundColor.withValues(alpha: 0.1),
          highlightColor: foregroundColor.withValues(alpha: 0.05),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
            child: Center(child: content),
          ),
        ),
      ),
    );

    return buttonCore.animate(target: _isPressed ? 1 : 0).scaleXY(end: 0.96, duration: 100.ms, curve: Curves.easeOut);
  }
}
