import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../authentication/presentation/auth_controller.dart';
import '../../../../shared/widgets/avatars/profile_avatar.dart';
import '../../../../shared/widgets/loaders/skeleton.dart';
import '../data/employee_profile_provider.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final user = authState.user;
    final employeeProfileAsync = ref.watch(employeeProfileProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile', style: AppTypography.title.copyWith(fontWeight: FontWeight.w700)),
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.settings),
            onPressed: () {
              context.push('/profile-settings');
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.s16),
        children: [
          // Profile Card
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
                  name: user?.username ?? 'User',
                  photoId: user?.profilePhotoId,
                  size: 80,
                ),
                const SizedBox(height: AppSpacing.s16),
                Text(
                  user?.username ?? 'User Name',
                  style: AppTypography.title.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: AppSpacing.s4),
                Text(
                  user?.email ?? 'email@example.com',
                  style: AppTypography.body.copyWith(
                    color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForegroundLight,
                  ),
                ),
                const SizedBox(height: AppSpacing.s16),
                const Divider(),
                const SizedBox(height: AppSpacing.s8),
                employeeProfileAsync.when(
                  data: (profile) {
                    if (profile == null) {
                      return const Center(child: Text('Employee profile not found'));
                    }
                    return Column(
                      children: [
                        _buildProfileDetailRow(context, 'Employee ID', profile.employeeCode.isNotEmpty ? profile.employeeCode : 'Not Assigned'),
                        _buildProfileDetailRow(context, 'Department', profile.departmentName ?? 'Not Assigned'),
                        _buildProfileDetailRow(context, 'Designation', profile.designationName ?? 'Not Assigned'),
                        _buildProfileDetailRow(context, 'Status', profile.employmentStatus),
                      ],
                    );
                  },
                  loading: () => Column(
                    children: [
                      _buildProfileDetailRowSkeleton(context),
                      _buildProfileDetailRowSkeleton(context),
                      _buildProfileDetailRowSkeleton(context),
                    ],
                  ),
                  error: (err, stack) => Center(child: Text('Error loading profile: $err')),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: AppSpacing.s32),
          Text(
            'Preferences',
            style: AppTypography.subtitle.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSpacing.s8),
          
          _buildSettingsTile(
            context: context,
            icon: LucideIcons.moon,
            title: 'Dark Mode',
            trailing: Switch(
              value: isDark,
              onChanged: (val) {
                ref.read(themeProvider.notifier).toggleTheme();
              },
            ),
          ),
          _buildSettingsTile(
            context: context,
            icon: LucideIcons.bell,
            title: 'Push Notifications',
            trailing: const Icon(LucideIcons.chevronRight, size: 20),
          ),
          
          const SizedBox(height: AppSpacing.s32),
          Text(
            'Account',
            style: AppTypography.subtitle.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSpacing.s8),
          
          _buildSettingsTile(
            context: context,
            icon: LucideIcons.lock,
            title: 'Change Password',
            trailing: const Icon(LucideIcons.chevronRight, size: 20),
          ),
          _buildSettingsTile(
            context: context,
            icon: LucideIcons.logOut,
            title: 'Log Out',
            textColor: AppColors.destructiveLight,
            onTap: () {
              ref.read(authControllerProvider.notifier).logout();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProfileDetailRow(BuildContext context, String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.label.copyWith(
              color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForegroundLight,
            ),
          ),
          Text(
            value,
            style: AppTypography.body.copyWith(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileDetailRowSkeleton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Skeleton(width: 80, height: 16),
          const Skeleton(width: 120, height: 16),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    Widget? trailing,
    Color? textColor,
    VoidCallback? onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(AppSpacing.s8),
        decoration: BoxDecoration(
          color: (textColor ?? (isDark ? AppColors.primaryDark : AppColors.primaryLight)).withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: textColor ?? (isDark ? AppColors.primaryDark : AppColors.primaryLight), size: 20),
      ),
      title: Text(
        title,
        style: AppTypography.body.copyWith(
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: trailing,
      onTap: onTap,
    );
  }
}
