import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class AppSelect<T> extends StatelessWidget {
  final String? label;
  final String? placeholder;
  final String? helperText;
  final String? errorText;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final bool isRequired;
  final Widget? prefixIcon;

  const AppSelect({
    super.key,
    this.label,
    this.placeholder,
    this.helperText,
    this.errorText,
    required this.items,
    this.value,
    this.onChanged,
    this.isRequired = false,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final borderColor = isDark ? AppColors.inputDark : AppColors.borderLight;
    final focusColor = isDark ? AppColors.ringDark : AppColors.ringLight;
    final errorColor = isDark ? AppColors.destructiveDark : AppColors.destructiveLight;
    final textColor = isDark ? AppColors.foregroundDark : AppColors.foregroundLight;
    final placeholderColor = isDark ? AppColors.mutedForegroundDark : AppColors.mutedForegroundLight;
    final backgroundColor = isDark ? AppColors.inputDark.withValues(alpha: 0.5) : AppColors.backgroundLight.withValues(alpha: 0.5); 

    final borderRadius = BorderRadius.circular(AppRadius.xl);

    final border = OutlineInputBorder(
      borderRadius: borderRadius,
      borderSide: BorderSide(color: borderColor, width: 1),
    );

    final focusedBorder = OutlineInputBorder(
      borderRadius: borderRadius,
      borderSide: BorderSide(color: focusColor.withValues(alpha: 0.5), width: 2),
    );

    final errorBorder = OutlineInputBorder(
      borderRadius: borderRadius,
      borderSide: BorderSide(color: errorColor, width: 1),
    );

    final focusedErrorBorder = OutlineInputBorder(
      borderRadius: borderRadius,
      borderSide: BorderSide(color: errorColor, width: 2),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          RichText(
            text: TextSpan(
              text: label!,
              style: AppTypography.label.copyWith(
                color: isDark ? AppColors.foregroundDark : AppColors.foregroundLight,
                fontWeight: FontWeight.w600,
              ),
              children: [
                if (isRequired)
                  TextSpan(
                    text: ' *',
                    style: TextStyle(
                      color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.s8),
        ],
        LayoutBuilder(
          builder: (context, constraints) {
            return DropdownMenu<T>(
              key: ValueKey(value),
              initialSelection: items.any((item) => item.value == value) ? value : null,
              width: constraints.maxWidth,
              hintText: placeholder,
              onSelected: onChanged,
              textStyle: AppTypography.body.copyWith(color: textColor),
              trailingIcon: Icon(LucideIcons.chevronDown, color: placeholderColor, size: AppSpacing.s20),
              selectedTrailingIcon: Icon(LucideIcons.chevronUp, color: placeholderColor, size: AppSpacing.s20),
              leadingIcon: prefixIcon,
              menuStyle: MenuStyle(
                backgroundColor: WidgetStatePropertyAll(isDark ? AppColors.backgroundDark : AppColors.backgroundLight),
                elevation: const WidgetStatePropertyAll(8),
                shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: borderRadius)),
              ),
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: backgroundColor,
                hintStyle: AppTypography.body.copyWith(color: placeholderColor),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.s16,
                  vertical: AppSpacing.s12,
                ),
                border: border,
                enabledBorder: border,
                focusedBorder: focusedBorder,
                errorBorder: errorBorder,
                focusedErrorBorder: focusedErrorBorder,
              ),
              dropdownMenuEntries: items.map((item) {
                String itemLabel = item.value.toString();
                if (item.child is Text) {
                  itemLabel = (item.child as Text).data ?? itemLabel;
                }
                return DropdownMenuEntry<T>(
                  value: item.value as T,
                  label: itemLabel,
                  style: MenuItemButton.styleFrom(
                    foregroundColor: textColor,
                    textStyle: AppTypography.body,
                  ),
                );
              }).toList(),
            );
          },
        ),
        if (errorText != null || helperText != null) ...[
          const SizedBox(height: AppSpacing.s4),
          Text(
            errorText ?? helperText!,
            style: AppTypography.caption.copyWith(
              color: errorText != null ? errorColor : placeholderColor,
            ),
          ),
        ],
      ],
    );
  }
}
