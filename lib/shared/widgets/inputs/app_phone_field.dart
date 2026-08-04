import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

class AppPhoneField extends StatelessWidget {
  final String label;
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final String placeholder;

  const AppPhoneField({
    super.key,
    required this.label,
    this.initialValue,
    this.onChanged,
    this.placeholder = 'Enter phone number',
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Text(
            label,
            style: AppTypography.caption.copyWith(
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white70 : AppColors.foregroundLight,
            ),
          ),
          const SizedBox(height: AppSpacing.s8),
        ],
        IntlPhoneField(
          initialValue: initialValue,
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: AppTypography.body.copyWith(
              color: isDark ? Colors.white30 : Colors.black38,
            ),
            filled: true,
            fillColor: isDark ? AppColors.inputDark : Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s16,
              vertical: AppSpacing.s12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
                width: 2,
              ),
            ),
          ),
          initialCountryCode: 'IN', // Defaulting to India like frontend 'IN'
          onChanged: (phone) {
            if (onChanged != null) {
              onChanged!(phone.completeNumber);
            }
          },
        ),
      ],
    );
  }
}
