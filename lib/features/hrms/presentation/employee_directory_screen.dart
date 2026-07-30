import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/inputs/app_text_field.dart';
import '../../../shared/widgets/loaders/skeleton.dart';
import '../../authentication/presentation/auth_controller.dart';
import 'providers/employee_providers.dart';
import 'widgets/employee_card.dart';
import 'package:flutter_animate/flutter_animate.dart';

class EmployeeDirectoryScreen extends ConsumerWidget {
  const EmployeeDirectoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final employeesAsync = ref.watch(employeeListProvider);
    final user = ref.watch(authControllerProvider).user;
    final hasCreatePermission = user?.hasPermission('employee.create') ?? false;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Employee Directory',
          style: AppTypography.title.copyWith(fontWeight: FontWeight.w700),
        ),
        backgroundColor: isDark
            ? AppColors.backgroundDark
            : AppColors.backgroundLight,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.s16,
              0,
              AppSpacing.s16,
              AppSpacing.s12,
            ),
            child: Row(
              children: [
                Expanded(
                  child: AppTextField(
                    placeholder: 'Search by name, ID, department...',
                    prefixIcon: Icon(
                      LucideIcons.search,
                      size: 20,
                      color: isDark
                          ? AppColors.mutedForegroundDark
                          : AppColors.mutedForegroundLight,
                    ),
                    onChanged: (value) {
                      ref
                          .read(employeeSearchQueryProvider.notifier)
                          .updateState(value);
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.s12),
                Container(
                  decoration: BoxDecoration(
                    color:
                        (isDark
                                ? AppColors.primaryDark
                                : AppColors.primaryLight)
                            .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    icon: Icon(
                      LucideIcons.filter,
                      color: isDark
                          ? AppColors.primaryDark
                          : AppColors.primaryLight,
                    ),
                    onPressed: () {
                      // TODO: Implement Bottom Sheet Filters
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: employeesAsync.when(
        data: (employees) {
          if (employees.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    LucideIcons.users,
                    size: 64,
                    color: isDark
                        ? AppColors.mutedForegroundDark.withValues(alpha: 0.5)
                        : AppColors.mutedForegroundLight.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: AppSpacing.s16),
                  Text('No employees found', style: AppTypography.subtitle),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              return ref.refresh(employeeListProvider.future);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.s16),
              itemCount: employees.length,
              itemBuilder: (context, index) {
                final employee = employees[index];
                return EmployeeCard(
                      employee: employee,
                      onTap: () {
                        context.push('/hrms/employees/${employee.id}');
                      },
                    )
                    .animate()
                    .fade(duration: 400.ms, delay: (index * 50).ms)
                    .slideY(begin: 0.1, curve: Curves.easeOutQuad);
              },
            ),
          );
        },
        loading: () => ListView.builder(
          padding: const EdgeInsets.all(AppSpacing.s16),
          itemCount: 5,
          itemBuilder: (context, index) => _buildSkeletonCard(),
        ),
        error: (err, stack) =>
            Center(child: Text('Error loading employees: $err')),
      ),
      floatingActionButton: hasCreatePermission
          ? FloatingActionButton(
              onPressed: () {
                context.push('/hrms/employees/new');
              },
              backgroundColor: isDark
                  ? AppColors.primaryDark
                  : AppColors.primaryLight,
              child: const Icon(LucideIcons.plus, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildSkeletonCard() {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: AppSpacing.s12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s16),
        child: Row(
          children: [
            const Skeleton(width: 56, height: 56, borderRadius: 28),
            const SizedBox(width: AppSpacing.s16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Skeleton(width: 150, height: 16),
                  const SizedBox(height: AppSpacing.s8),
                  const Skeleton(width: 100, height: 14),
                  const SizedBox(height: AppSpacing.s12),
                  Row(
                    children: const [
                      Skeleton(width: 80, height: 12),
                      SizedBox(width: 16),
                      Skeleton(width: 60, height: 12),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
