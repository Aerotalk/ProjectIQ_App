import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/avatars/profile_avatar.dart';
import '../../../../shared/widgets/badges/app_badge.dart';
import '../../domain/employee.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class EmployeeCard extends StatelessWidget {
  final Employee employee;
  final VoidCallback onTap;

  const EmployeeCard({super.key, required this.employee, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: AppSpacing.s12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      color: isDark ? AppColors.cardDark : AppColors.cardLight,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.s16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProfileAvatar(
                name: employee.fullName,
                photoId: employee.profilePhotoId,
                size: 56,
              ),
              const SizedBox(width: AppSpacing.s16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            employee.fullName,
                            style: AppTypography.subtitle.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        AppBadge(
                          text: employee.employmentStatus,
                          variant: _getStatusType(employee.employmentStatus),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.s4),
                    Text(
                      employee.designationName ?? 'No Designation',
                      style: AppTypography.body.copyWith(
                        color: isDark
                            ? AppColors.mutedForegroundDark
                            : AppColors.mutedForegroundLight,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s8),
                    Row(
                      children: [
                        Icon(
                          LucideIcons.briefcase,
                          size: 14,
                          color: isDark
                              ? AppColors.mutedForegroundDark
                              : AppColors.mutedForegroundLight,
                        ),
                        const SizedBox(width: AppSpacing.s4),
                        Text(
                          employee.departmentName ?? 'No Department',
                          style: AppTypography.label.copyWith(
                            color: isDark
                                ? AppColors.mutedForegroundDark
                                : AppColors.mutedForegroundLight,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.s16),
                        Icon(
                          LucideIcons.hash,
                          size: 14,
                          color: isDark
                              ? AppColors.mutedForegroundDark
                              : AppColors.mutedForegroundLight,
                        ),
                        const SizedBox(width: AppSpacing.s4),
                        Text(
                          employee.employeeCode.isNotEmpty
                              ? employee.employeeCode
                              : 'No ID',
                          style: AppTypography.label.copyWith(
                            color: isDark
                                ? AppColors.mutedForegroundDark
                                : AppColors.mutedForegroundLight,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  AppBadgeVariant _getStatusType(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return AppBadgeVariant.success;
      case 'inactive':
      case 'terminated':
      case 'resigned':
        return AppBadgeVariant.destructive;
      case 'on leave':
      case 'suspended':
        return AppBadgeVariant.warning;
      default:
        return AppBadgeVariant.defaultVariant;
    }
  }
}
