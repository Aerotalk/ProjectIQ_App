import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../providers/attendance_exception_providers.dart';

class AttendanceExceptionListScreen extends ConsumerWidget {
  const AttendanceExceptionListScreen({super.key});

  Widget _buildStatusBadge(bool resolved) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: resolved ? Colors.green.shade100 : Colors.orange.shade100,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        resolved ? 'Resolved' : 'Pending',
        style: TextStyle(
          color: resolved ? Colors.green.shade700 : Colors.orange.shade700,
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listState = ref.watch(attendanceExceptionListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exceptions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
      ),
      body: listState.when(
        data: (exceptions) {
          if (exceptions.isEmpty) {
            return const Center(child: Text('No exceptions found.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.s16),
            itemCount: exceptions.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.s12),
            itemBuilder: (context, index) {
              final exception = exceptions[index];
              final isHighSeverity = exception.severity == 'High';

              return Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isHighSeverity ? Colors.red.shade100 : Colors.grey.shade300,
                    width: 1.0,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.s16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(AppSpacing.s8),
                                decoration: BoxDecoration(
                                  color: isHighSeverity ? Colors.red.shade50 : Colors.orange.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  LucideIcons.alertCircle,
                                  color: isHighSeverity ? Colors.red : Colors.orange,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.s12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    exception.employeeName,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${exception.employeeCode} • ${exception.date}',
                                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          _buildStatusBadge(exception.resolved),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.s16),
                      const Divider(height: 1),
                      const SizedBox(height: AppSpacing.s16),
                      Text(
                        exception.exceptionType,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        exception.description,
                        style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                      ),
                      if (!exception.resolved) ...[
                        const SizedBox(height: AppSpacing.s16),
                        SizedBox(
                          width: double.infinity,
                          child: TextButton.icon(
                            onPressed: () {
                              // ScaffoldMessenger.showSnackBar(const SnackBar(content: Text('Open in Approval Center')));
                            },
                            icon: const Icon(LucideIcons.externalLink, size: 16),
                            label: const Text('View in Approval Center'),
                            style: TextButton.styleFrom(
                              foregroundColor: Theme.of(context).primaryColor,
                              backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
