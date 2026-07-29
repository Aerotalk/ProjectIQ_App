import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_animation.dart';

enum AppButtonVariant { primary, secondary, outline, ghost, danger }

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final bool isDisabled;
  final IconData? icon;
  final bool isFullWidth;

  const AppButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.isDisabled = false,
    this.icon,
    this.isFullWidth = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color backgroundColor;
    Color foregroundColor;
    Color? borderColor;

    switch (variant) {
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

    final bool effectiveDisabled = isDisabled || isLoading;
    if (effectiveDisabled) {
      if (variant != AppButtonVariant.outline && variant != AppButtonVariant.ghost) {
        backgroundColor = backgroundColor.withValues(alpha: 0.5);
      }
      foregroundColor = foregroundColor.withValues(alpha: 0.5);
    }

    Widget content = Row(
      mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: AppSpacing.s16,
            height: AppSpacing.s16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
            ),
          ),
          const SizedBox(width: AppSpacing.s8),
        ] else if (icon != null) ...[
          Icon(icon, size: AppSpacing.s16, color: foregroundColor),
          const SizedBox(width: AppSpacing.s8),
        ],
        Text(
          text,
          style: AppTypography.button.copyWith(color: foregroundColor),
        ),
      ],
    );

    return AnimatedContainer(
      duration: AppAnimation.fast,
      curve: AppAnimation.defaultCurve,
      width: isFullWidth ? double.infinity : null,
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
          onTap: effectiveDisabled ? null : onPressed,
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
  }
}
