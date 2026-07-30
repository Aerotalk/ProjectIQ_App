import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/avatars/profile_avatar.dart';
import '../../../shared/widgets/badges/app_badge.dart';
import '../../authentication/presentation/auth_controller.dart';
import 'providers/employee_providers.dart';

class EmployeeProfileScreen extends ConsumerWidget {
  final String employeeId;

  const EmployeeProfileScreen({super.key, required this.employeeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final employeeAsync = ref.watch(employeeDetailProvider(employeeId));
    final user = ref.watch(authControllerProvider).user;
    final canEdit = user?.hasPermission('employee.edit') ?? false;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Employee Profile', style: AppTypography.title.copyWith(fontWeight: FontWeight.w700)),
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        elevation: 0,
        actions: [
          if (canEdit)
            IconButton(
              icon: const Icon(LucideIcons.pencil),
              onPressed: () {
                // TODO: Implement Edit
              },
            ),
        ],
      ),
      body: employeeAsync.when(
        data: (employee) {
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.s16),
            children: [
              // Header Card
              Container(
                padding: const EdgeInsets.all(AppSpacing.s24),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : AppColors.cardLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  ),
                ),
                child: Column(
                  children: [
                    ProfileAvatar(
                      name: employee.fullName,
                      photoId: employee.profilePhotoId,
                      size: 96,
                    ),
                    const SizedBox(height: AppSpacing.s16),
                    Text(
                      employee.fullName,
                      style: AppTypography.headline,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.s8),
                    AppBadge(
                      text: employee.employmentStatus,
                      variant: _getStatusType(employee.employmentStatus),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: AppSpacing.s24),
              
              // Actions Bar (if permitted)
              if (canEdit) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildActionButton(context, LucideIcons.powerOff, 'Deactivate', Colors.orange),
                    _buildActionButton(context, LucideIcons.arrowRightLeft, 'Transfer', AppColors.primaryLight),
                    _buildActionButton(context, LucideIcons.trash2, 'Delete', AppColors.destructiveLight),
                  ],
                ),
                const SizedBox(height: AppSpacing.s24),
              ],

              // Employment Info
              Text(
                'Employment Information',
                style: AppTypography.subtitle.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: AppSpacing.s8),
              Container(
                padding: const EdgeInsets.all(AppSpacing.s16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : AppColors.cardLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  ),
                ),
                child: Column(
                  children: [
                    _buildDetailRow(context, 'Employee Code', employee.employeeCode.isNotEmpty ? employee.employeeCode : 'N/A'),
                    const Divider(height: AppSpacing.s24),
                    _buildDetailRow(context, 'Department', employee.departmentName ?? 'N/A'),
                    const Divider(height: AppSpacing.s24),
                    _buildDetailRow(context, 'Designation', employee.designationName ?? 'N/A'),
                    const Divider(height: AppSpacing.s24),
                    _buildDetailRow(context, 'Joining Date', employee.joiningDate ?? 'N/A'),
                    const Divider(height: AppSpacing.s24),
                    _buildDetailRow(context, 'Reporting Manager', employee.reportingManagerName ?? 'N/A'),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.s24),
              
              // Personal Info
              Text(
                'Personal Information',
                style: AppTypography.subtitle.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: AppSpacing.s8),
              Container(
                padding: const EdgeInsets.all(AppSpacing.s16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : AppColors.cardLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  ),
                ),
                child: Column(
                  children: [
                    _buildDetailRow(context, 'Gender', employee.gender ?? 'N/A'),
                    const Divider(height: AppSpacing.s24),
                    _buildDetailRow(context, 'Date of Birth', employee.dateOfBirth ?? 'N/A'),
                    const Divider(height: AppSpacing.s24),
                    _buildDetailRow(context, 'Email Address', employee.email ?? 'N/A'),
                  ],
                ),
              ),
              
              const SizedBox(height: AppSpacing.s32),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Failed to load profile: $err')),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: AppTypography.label.copyWith(
              color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForegroundLight,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: AppTypography.body.copyWith(fontWeight: FontWeight.w500),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context, IconData icon, String label, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s12, vertical: AppSpacing.s8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.s12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: AppSpacing.s8),
            Text(
              label,
              style: AppTypography.label.copyWith(
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.foregroundDark : AppColors.foregroundLight,
              ),
            ),
          ],
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
