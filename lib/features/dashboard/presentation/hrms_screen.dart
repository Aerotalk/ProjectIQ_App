import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/router/module_registry.dart';
import 'widgets/module_card.dart';

class HRMSScreen extends ConsumerWidget {
  const HRMSScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final moduleRegistry = ref.watch(moduleRegistryProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final modules = moduleRegistry.hrmsGridModules;

    return Scaffold(
      appBar: AppBar(
        title: Text('HRMS', style: AppTypography.title.copyWith(fontWeight: FontWeight.w700)),
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        elevation: 0,
        scrolledUnderElevation: 4,
      ),
      body: modules.isEmpty
          ? const Center(child: Text('No HRMS modules available.'))
          : GridView.builder(
              padding: const EdgeInsets.all(AppSpacing.s16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: AppSpacing.s16,
                mainAxisSpacing: AppSpacing.s16,
                childAspectRatio: 1.0,
              ),
              itemCount: modules.length,
              itemBuilder: (context, index) {
                return ModuleCard(module: modules[index]);
              },
            ),
    );
  }
}
