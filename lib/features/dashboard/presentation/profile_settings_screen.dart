import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/inputs/app_text_field.dart';
import '../../../../shared/widgets/avatars/profile_avatar.dart';
import '../../authentication/presentation/auth_controller.dart';
import '../data/profile_settings_repository.dart';
import 'package:go_router/go_router.dart';

class ProfileSettingsScreen extends ConsumerStatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  ConsumerState<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends ConsumerState<ProfileSettingsScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _emailAlerts = true;
  bool _pushNotifications = false;
  bool _securityAlerts = true;

  bool _isLoadingPersonal = false;
  bool _isLoadingPassword = false;

  @override
  void initState() {
    super.initState();
    // Initialize with current user data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(authControllerProvider).user;
      if (user != null) {
        _usernameController.text = user.username;
        _emailController.text = user.email;
      }
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = ref.watch(authControllerProvider).user;

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Settings', style: AppTypography.title.copyWith(fontWeight: FontWeight.w700)),
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.s16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Admin Profile', style: AppTypography.display.copyWith(fontSize: 24)),
            const SizedBox(height: AppSpacing.s4),
            Text(
              'Manage your personal information and security preferences.',
              style: AppTypography.body.copyWith(
                color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForegroundLight,
              ),
            ),
            const SizedBox(height: AppSpacing.s24),
            
            // Personal Information Card
            _buildCard(
              context: context,
              icon: LucideIcons.user,
              iconColor: Colors.purple,
              title: 'Personal Information',
              subtitle: 'Update your basic profile details and public avatar.',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ProfileAvatar(
                        name: user?.username ?? 'User',
                        photoId: user?.profilePhotoId,
                        size: 80,
                      ),
                      const SizedBox(width: AppSpacing.s16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Profile Photo', style: AppTypography.body.copyWith(fontWeight: FontWeight.w600)),
                            const SizedBox(height: AppSpacing.s4),
                            Text(
                              'Recommended size is 256x256px. Max file size 2MB.',
                              style: AppTypography.caption.copyWith(color: Colors.grey),
                            ),
                            const SizedBox(height: AppSpacing.s12),
                            Row(
                              children: [
                                ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
                                    foregroundColor: isDark ? Colors.white : Colors.black,
                                    elevation: 0,
                                  ),
                                  child: const Text('Change Photo'),
                                ),
                                const SizedBox(width: AppSpacing.s16),
                                TextButton(
                                  onPressed: () {},
                                  style: TextButton.styleFrom(
                                    foregroundColor: AppColors.destructiveLight,
                                  ),
                                  child: const Text('Remove'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.s24),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('USERNAME', style: AppTypography.caption.copyWith(fontWeight: FontWeight.w600)),
                            const SizedBox(height: AppSpacing.s8),
                            AppTextField(
                              controller: _usernameController,
                              prefixIcon: const Icon(LucideIcons.user),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.s16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('EMAIL ADDRESS', style: AppTypography.caption.copyWith(fontWeight: FontWeight.w600)),
                            const SizedBox(height: AppSpacing.s8),
                            AppTextField(
                              controller: _emailController,
                              prefixIcon: const Icon(LucideIcons.mail),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.s24),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: _isLoadingPersonal ? null : () async {
                        setState(() => _isLoadingPersonal = true);
                        try {
                          await ref.read(profileSettingsRepositoryProvider).updatePersonalInformation(
                                _usernameController.text,
                                null, // Pass photoId if changed
                              );
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated successfully')));
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update profile: $e')));
                          }
                        } finally {
                          if (mounted) setState(() => _isLoadingPersonal = false);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: _isLoadingPersonal 
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Save Changes'),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: AppSpacing.s24),
            
            // Security Card
            _buildCard(
              context: context,
              icon: LucideIcons.key,
              iconColor: Colors.purple,
              title: 'Security',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('CURRENT PASSWORD', style: AppTypography.caption.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: AppSpacing.s8),
                  AppTextField(
                    controller: _currentPasswordController,
                    isPassword: true,
                  ),
                  const SizedBox(height: AppSpacing.s16),
                  Text('NEW PASSWORD', style: AppTypography.caption.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: AppSpacing.s8),
                  AppTextField(
                    controller: _newPasswordController,
                    isPassword: true,
                  ),
                  const SizedBox(height: AppSpacing.s16),
                  Text('CONFIRM NEW PASSWORD', style: AppTypography.caption.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: AppSpacing.s8),
                  AppTextField(
                    controller: _confirmPasswordController,
                    isPassword: true,
                  ),
                  const SizedBox(height: AppSpacing.s24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoadingPassword ? null : () async {
                        if (_newPasswordController.text != _confirmPasswordController.text) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Passwords do not match')));
                          return;
                        }
                        setState(() => _isLoadingPassword = true);
                        try {
                          await ref.read(profileSettingsRepositoryProvider).updatePassword(
                                _currentPasswordController.text,
                                _newPasswordController.text,
                              );
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password updated successfully')));
                            _currentPasswordController.clear();
                            _newPasswordController.clear();
                            _confirmPasswordController.clear();
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update password: $e')));
                          }
                        } finally {
                          if (mounted) setState(() => _isLoadingPassword = false);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? AppColors.primaryDark : const Color(0xFF1F2937), // Dark navy
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isLoadingPassword
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Update Password'),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: AppSpacing.s24),
            
            // Notifications Card
            _buildCard(
              context: context,
              icon: LucideIcons.bell,
              iconColor: Colors.purple,
              title: 'Notifications',
              child: Column(
                children: [
                  _buildToggleRow(
                    title: 'Email Alerts',
                    subtitle: 'Receive daily summary emails.',
                    value: _emailAlerts,
                    onChanged: (val) {
                      setState(() => _emailAlerts = val);
                      _saveNotificationPrefs();
                    },
                  ),
                  const Divider(),
                  _buildToggleRow(
                    title: 'Push Notifications',
                    subtitle: 'Real-time alerts for active sessions.',
                    value: _pushNotifications,
                    onChanged: (val) {
                      setState(() => _pushNotifications = val);
                      _saveNotificationPrefs();
                    },
                  ),
                  const Divider(),
                  _buildToggleRow(
                    title: 'Security Alerts',
                    subtitle: 'New logins from unknown devices.',
                    value: _securityAlerts,
                    onChanged: (val) {
                      setState(() => _securityAlerts = val);
                      _saveNotificationPrefs();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    required Widget child,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
        boxShadow: const [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: AppSpacing.s8),
              Text(title, style: AppTypography.title.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: AppSpacing.s4),
            Text(
              subtitle,
              style: AppTypography.caption.copyWith(
                color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForegroundLight,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.s24),
          const Divider(),
          const SizedBox(height: AppSpacing.s24),
          child,
        ],
      ),
    );
  }

  Widget _buildToggleRow({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.body.copyWith(fontWeight: FontWeight.w500)),
                Text(
                  subtitle,
                  style: AppTypography.caption.copyWith(
                    color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForegroundLight,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.purple,
          ),
        ],
      ),
    );
  }

  Future<void> _saveNotificationPrefs() async {
    try {
      await ref.read(profileSettingsRepositoryProvider).updateNotificationPreferences({
        'emailAlerts': _emailAlerts,
        'pushNotifications': _pushNotifications,
        'securityAlerts': _securityAlerts,
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update preferences: $e')));
      }
    }
  }
}
