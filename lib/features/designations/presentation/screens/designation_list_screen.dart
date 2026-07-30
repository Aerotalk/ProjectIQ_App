import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/inputs/app_text_field.dart';
import '../../../../shared/widgets/loaders/skeleton.dart';
import '../providers/designation_providers.dart';
import '../widgets/designation_card.dart';

class DesignationListScreen extends ConsumerStatefulWidget {
  const DesignationListScreen({super.key});

  @override
  ConsumerState<DesignationListScreen> createState() => _DesignationListScreenState();
}

class _DesignationListScreenState extends ConsumerState<DesignationListScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(designationListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Designations'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.plus),
            onPressed: () => context.push('/designations/new'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(designationListProvider.notifier).refresh(),
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
              data: (designations) {
                final filtered = designations.where((d) {
                  final query = _searchQuery.toLowerCase();
                  return d.designationName.toLowerCase().contains(query) ||
                      d.designationCode.toLowerCase().contains(query);
                }).toList();

                if (filtered.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(LucideIcons.award, size: 48, color: Theme.of(context).disabledColor),
                          const SizedBox(height: AppSpacing.s16),
                          Text(
                            _searchQuery.isEmpty ? 'No designations found' : 'No results match "$_searchQuery"',
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
                        final desig = filtered[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.s12),
                          child: DesignationCard(
                            designation: desig,
                            onTap: () => context.push('/designations/${desig.id}'),
                            onEdit: () => context.push('/designations/${desig.id}/edit', extra: desig),
                            onDelete: () => _confirmDelete(context, desig.id),
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
                      child: Skeleton(height: 120, width: double.infinity),
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
                      Text('Error loading designations', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: AppSpacing.s8),
                      ElevatedButton(
                        onPressed: () => ref.read(designationListProvider.notifier).refresh(),
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
        title: const Text('Delete Designation'),
        content: const Text('Are you sure you want to delete this designation?'),
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
      ref.read(designationActionProvider.notifier).deleteDesignation(id);
    }
  }
}
