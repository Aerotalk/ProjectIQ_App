import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

enum AppBadgeVariant { defaultVariant, secondary, outline, destructive, success, warning }

class AppBadge extends StatelessWidget {
  final String text;
  final AppBadgeVariant variant;

  const AppBadge({
    super.key,
    required this.text,
    this.variant = AppBadgeVariant.defaultVariant,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color backgroundColor;
    Color foregroundColor;
    Color? borderColor;

    switch (variant) {
      case AppBadgeVariant.defaultVariant:
        backgroundColor = isDark ? AppColors.primaryDark : AppColors.primaryLight;
        foregroundColor = isDark ? AppColors.primaryForegroundDark : AppColors.primaryForegroundLight;
        break;
      case AppBadgeVariant.secondary:
        backgroundColor = isDark ? AppColors.secondaryDark : AppColors.secondaryLight;
        foregroundColor = isDark ? AppColors.secondaryForegroundDark : AppColors.secondaryForegroundLight;
        break;
      case AppBadgeVariant.outline:
        backgroundColor = Colors.transparent;
        foregroundColor = isDark ? AppColors.foregroundDark : AppColors.foregroundLight;
        borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
        break;
      case AppBadgeVariant.destructive:
        backgroundColor = isDark ? AppColors.destructiveDark : AppColors.destructiveLight;
        foregroundColor = isDark ? AppColors.destructiveForegroundDark : AppColors.destructiveForegroundLight;
        break;
      case AppBadgeVariant.success:
        backgroundColor = AppColors.success.withValues(alpha: 0.2);
        foregroundColor = AppColors.success;
        break;
      case AppBadgeVariant.warning:
        backgroundColor = AppColors.warning.withValues(alpha: 0.2);
        foregroundColor = AppColors.warning;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s10,
        vertical: AppSpacing.s2,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppRadius.xxl), // pills
        border: borderColor != null
            ? Border.all(color: borderColor, width: 1.0)
            : null,
      ),
      child: Text(
        text,
        style: AppTypography.caption.copyWith(
          color: foregroundColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
