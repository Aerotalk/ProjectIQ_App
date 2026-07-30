import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class AppTextField extends StatefulWidget {
  final String? label;
  final String? placeholder;
  final String? helperText;
  final String? errorText;
  final TextEditingController? controller;
  final bool isPassword;
  final TextInputType? keyboardType;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;
  final bool readOnly;
  final VoidCallback? onTap;
  final int maxLines;
  final bool isRequired;
  final Widget? labelTrailing;
  final String? initialValue;
  final FormFieldValidator<String>? validator;

  const AppTextField({
    super.key,
    this.label,
    this.placeholder,
    this.helperText,
    this.errorText,
    this.controller,
    this.isPassword = false,
    this.keyboardType,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.readOnly = false,
    this.onTap,
    this.maxLines = 1,
    this.isRequired = false,
    this.labelTrailing,
    this.initialValue,
    this.validator,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final borderColor = isDark ? AppColors.inputDark : AppColors.borderLight;
    final focusColor = isDark ? AppColors.ringDark : AppColors.ringLight;
    final errorColor = isDark ? AppColors.destructiveDark : AppColors.destructiveLight;
    final textColor = isDark ? AppColors.foregroundDark : AppColors.foregroundLight;
    final placeholderColor = isDark ? AppColors.mutedForegroundDark : AppColors.mutedForegroundLight;
    // For Web ERP, the background of inputs is slightly off-white when unfocused.
    final backgroundColor = isDark ? AppColors.inputDark.withValues(alpha: 0.5) : AppColors.backgroundLight.withValues(alpha: 0.5); 

    // Web ERP uses xl border radius (12-14px) for inputs
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
        if (widget.label != null) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RichText(
                text: TextSpan(
                  text: widget.label!,
                  style: AppTypography.label.copyWith(
                    color: isDark ? AppColors.foregroundDark : AppColors.foregroundLight,
                    fontWeight: FontWeight.w600,
                  ),
                  children: [
                    if (widget.isRequired)
                      TextSpan(
                        text: ' *',
                        style: TextStyle(
                          color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
                        ),
                      ),
                  ],
                ),
              ),
              if (widget.labelTrailing != null) widget.labelTrailing!,
            ],
          ),
          const SizedBox(height: AppSpacing.s8),
        ],
        TextFormField(
          initialValue: widget.initialValue,
          controller: widget.controller,
          obscureText: _obscureText,
          keyboardType: widget.keyboardType,
          onChanged: widget.onChanged,
          readOnly: widget.readOnly,
          onTap: widget.onTap,
          maxLines: widget.maxLines,
          style: AppTypography.body.copyWith(color: textColor),
          cursorColor: focusColor,
          validator: widget.validator,
          decoration: InputDecoration(
            filled: true,
            fillColor: backgroundColor, // Note: dynamically changing on focus is complex in standard InputDecoration, so this uses the unfocused base color
            hintText: widget.placeholder,
            hintStyle: AppTypography.body.copyWith(color: placeholderColor),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s16,
              vertical: AppSpacing.s12,
            ),
            prefixIcon: widget.prefixIcon,
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      _obscureText ? LucideIcons.eyeOff : LucideIcons.eye,
                      color: placeholderColor,
                      size: AppSpacing.s20,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  )
                : widget.suffixIcon,
            border: border,
            enabledBorder: border,
            focusedBorder: focusedBorder,
            errorBorder: errorBorder,
            focusedErrorBorder: focusedErrorBorder,
          ),
        ),
        if (widget.errorText != null || widget.helperText != null) ...[
          const SizedBox(height: AppSpacing.s4),
          Text(
            widget.errorText ?? widget.helperText!,
            style: AppTypography.caption.copyWith(
              color: widget.errorText != null ? errorColor : placeholderColor,
            ),
          ),
        ],
      ],
    );
  }
}
