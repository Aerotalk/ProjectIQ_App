import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/inputs/app_text_field.dart';
import '../../../../shared/widgets/loaders/skeleton.dart';
import '../providers/department_providers.dart';
import '../widgets/department_card.dart';

class DepartmentListScreen extends ConsumerStatefulWidget {
  const DepartmentListScreen({super.key});

  @override
  ConsumerState<DepartmentListScreen> createState() => _DepartmentListScreenState();
}

class _DepartmentListScreenState extends ConsumerState<DepartmentListScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(departmentListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Departments'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.plus),
            onPressed: () => context.push('/departments/new'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(departmentListProvider.notifier).refresh(),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.s16),
                child: AppTextField(
                  placeholder: 'Search by code or name...',
                  prefixIcon: const Icon(LucideIcons.search, size: 20),
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
              ),
            ),
            state.when(
              data: (departments) {
                final filtered = departments.where((d) {
                  final query = _searchQuery.toLowerCase();
                  return d.departmentName.toLowerCase().contains(query) ||
                      d.departmentCode.toLowerCase().contains(query);
                }).toList();

                if (filtered.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(LucideIcons.building2, size: 48, color: Theme.of(context).disabledColor),
                          const SizedBox(height: AppSpacing.s16),
                          Text(
                            _searchQuery.isEmpty ? 'No departments found' : 'No results match "$_searchQuery"',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Theme.of(context).disabledColor,
                                ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final dept = filtered[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.s12),
                          child: DepartmentCard(
                            department: dept,
                            onTap: () => context.push('/departments/${dept.id}'),
                            onEdit: () => context.push('/departments/${dept.id}/edit', extra: dept),
                            onDelete: () => _confirmDelete(context, dept.id),
                          ),
                        );
                      },
                      childCount: filtered.length,
                    ),
                  ),
                );
              },
              loading: () => SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => const Padding(
                      padding: EdgeInsets.only(bottom: AppSpacing.s12),
                      child: Skeleton(height: 100, width: double.infinity),
                    ),
                    childCount: 5,
                  ),
                ),
              ),
              error: (error, stack) => SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(LucideIcons.alertCircle, size: 48, color: AppColors.destructiveLight),
                      const SizedBox(height: AppSpacing.s16),
                      Text('Error loading departments', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: AppSpacing.s8),
                      ElevatedButton(
                        onPressed: () => ref.read(departmentListProvider.notifier).refresh(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Department'),
        content: const Text('Are you sure you want to delete this department?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.destructiveLight, foregroundColor: Colors.white),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      ref.read(departmentActionProvider.notifier).deleteDepartment(id);
    }
  }
}
