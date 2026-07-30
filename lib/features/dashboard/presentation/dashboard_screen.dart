import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../authentication/presentation/auth_controller.dart';
import '../../../../core/router/module_registry.dart';
import '../../../../core/permissions/permission_service.dart';
import '../../../shared/widgets/avatars/profile_avatar.dart';
import 'widgets/dashboard_section.dart';
import 'widgets/module_card.dart';
import '../../../../shared/widgets/loaders/skeleton.dart';
import '../../../../shared/widgets/search/global_search_delegate.dart';
import '../../../../core/theme/theme_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class QuickActionItem {
  final String label;
  final IconData icon;
  final String? permission;
  final VoidCallback onTap;

  QuickActionItem({
    required this.label,
    required this.icon,
    this.permission,
    required this.onTap,
  });
}

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final moduleRegistry = ref.watch(moduleRegistryProvider);
    final permissionService = ref.watch(permissionServiceProvider);
    
    final user = authState.user;
    final isLoading = authState.isLoading || user == null;
    
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context, user, isLoading),
          SliverToBoxAdapter(
            child: _buildWelcomeHeader(context, user, isLoading),
          ),
          SliverPadding(
            padding: const EdgeInsets.only(top: AppSpacing.s24),
            sliver: SliverToBoxAdapter(
              child: DashboardSection(
                title: 'Today\'s Summary',
                child: _buildSummaryCards(context, isLoading),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.only(top: AppSpacing.s24),
            sliver: SliverToBoxAdapter(
              child: DashboardSection(
                title: 'Pending Approvals',
                child: _buildPendingApprovals(context, permissionService, isLoading),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.only(top: AppSpacing.s24, bottom: AppSpacing.s40),
            sliver: SliverToBoxAdapter(
              child: DashboardSection(
                title: 'Recent Activity',
                child: _buildRecentActivity(context, isLoading),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, dynamic user, bool isLoading) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final orgName = user?.companyName ?? user?.organizationName ?? 'BumbleERP';

    return SliverAppBar(
      pinned: true,
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      elevation: 0,
      scrolledUnderElevation: 4,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      title: Row(
        children: [
          Icon(
            LucideIcons.layers,
            color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
          ),
          const SizedBox(width: AppSpacing.s8),
          Expanded(
            child: isLoading
                ? const Skeleton(height: 24, width: 120)
                : Text(
                    orgName,
                    style: AppTypography.title.copyWith(fontWeight: FontWeight.w700, fontSize: 18),
                    overflow: TextOverflow.ellipsis,
                  ),
          ),
        ],
      ),
      actions: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              user?.hasRole('ROLE_SUPER_ADMIN') == true ? 'HR' : 'EMP',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
              ),
            ),
            Transform.scale(
              scale: 0.6,
              child: Switch(
                value: user?.hasRole('ROLE_SUPER_ADMIN') == true,
                onChanged: (_) {
                  ref.read(authControllerProvider.notifier).toggleDeveloperRole();
                },
              ),
            ),
          ],
        ),
        IconButton(
          icon: Icon(isDark ? LucideIcons.sun : LucideIcons.moon, size: 20),
          onPressed: () {
            ref.read(themeProvider.notifier).toggleTheme();
          },
        ),
        IconButton(
          icon: const Badge(
            child: Icon(LucideIcons.bell, size: 20),
          ),
          onPressed: () {
            context.go('/notifications');
          },
        ),
        Padding(
          padding: const EdgeInsets.only(right: 16.0, left: 8.0),
          child: ProfileAvatar(
            name: user?.username ?? 'User',
            photoId: user?.profilePhotoId,
            onTap: () {},
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeHeader(BuildContext context, dynamic user, bool isLoading) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final greeting = _getGreeting();
    final dateStr = DateFormat('EEEE, MMMM d').format(DateTime.now());
    
    return Container(
      padding: const EdgeInsets.only(
        top: AppSpacing.s16,
        left: AppSpacing.s16,
        right: AppSpacing.s16,
        bottom: AppSpacing.s24,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            dateStr,
            style: AppTypography.caption.copyWith(
              color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.s8),
          Text(
            greeting,
            style: AppTypography.subtitle.copyWith(
              color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForegroundLight,
            ),
          ),
          const SizedBox(height: AppSpacing.s4),
          if (isLoading)
            const Skeleton(height: 36, width: 200)
          else
            Text(
              user?.username ?? 'Employee',
              style: AppTypography.display.copyWith(fontSize: 28),
            ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(BuildContext context, bool isLoading) {
    if (isLoading) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
        child: Row(
          children: const [
            Expanded(child: Skeleton(height: 100, borderRadius: 12)),
            SizedBox(width: AppSpacing.s16),
            Expanded(child: Skeleton(height: 100, borderRadius: 12)),
          ],
        ),
      );
    }
    
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryCard(context, 'Hours Logged', '8h 30m', LucideIcons.clock, isDark),
          ),
          const SizedBox(width: AppSpacing.s16),
          Expanded(
            child: _buildSummaryCard(context, 'Attendance', 'Present', LucideIcons.checkCircle, isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, String title, String value, IconData icon, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: isDark ? AppColors.primaryDark : AppColors.primaryLight),
              const SizedBox(width: AppSpacing.s8),
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.label.copyWith(color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForegroundLight),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s12),
          Text(
            value,
            style: AppTypography.title.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingApprovals(BuildContext context, PermissionService permissions, bool isLoading) {
    if (!permissions.can('approvals.view')) {
      return const SizedBox.shrink(); // Hide if they aren't a manager
    }
    
    if (isLoading) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
        child: const Skeleton(height: 80, borderRadius: 12),
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.s16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (isDark ? AppColors.primaryDark : AppColors.primaryLight).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(LucideIcons.fileSignature, color: isDark ? AppColors.primaryDark : AppColors.primaryLight),
            ),
            const SizedBox(width: AppSpacing.s16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Leave Request', style: AppTypography.body.copyWith(fontWeight: FontWeight.w600)),
                  Text('John Doe - Sick Leave', style: AppTypography.caption),
                ],
              ),
            ),
            const Icon(LucideIcons.chevronRight, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity(BuildContext context, bool isLoading) {
    if (isLoading) {
      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
        itemCount: 3,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.s12),
        itemBuilder: (_, __) => const Skeleton(height: 70, borderRadius: 12),
      );
    }
    
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
      itemCount: 3,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.s12),
      itemBuilder: (context, index) {
        return Container(
          padding: const EdgeInsets.all(AppSpacing.s16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : AppColors.cardLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
          ),
          child: Row(
            children: [
              Icon(LucideIcons.checkCircle, color: Colors.green, size: 20),
              const SizedBox(width: AppSpacing.s16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Checked In', style: AppTypography.body.copyWith(fontWeight: FontWeight.w500)),
                    Text('09:00 AM - HQ Office', style: AppTypography.caption),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning,';
    if (hour < 17) return 'Good Afternoon,';
    return 'Good Evening,';
  }
}
