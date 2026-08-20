import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/cards/app_card.dart';
import '../../../../shared/widgets/buttons/slide_action.dart';
import '../../../attendance/presentation/providers/clock_provider.dart';
import 'package:intl/intl.dart';

class AttendanceClockCard extends ConsumerWidget {
  const AttendanceClockCard({super.key});

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clockState = ref.watch(attendanceClockProvider);

    final isCheckedIn = clockState.status == ClockStatus.checkedIn;
    final isCheckedOut = clockState.status == ClockStatus.checkedOut;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.s24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Time Clock',
                    style: AppTypography.subtitle.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s4),
                  Text(
                    DateFormat('EEEE, MMM d').format(DateTime.now()),
                    style: AppTypography.caption,
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isCheckedIn 
                      ? Colors.green.withValues(alpha: 0.1)
                      : (isCheckedOut ? Colors.orange.withValues(alpha: 0.1) : AppColors.primaryLight.withValues(alpha: 0.1)),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(
                      isCheckedIn 
                          ? LucideIcons.checkCircle2 
                          : (isCheckedOut ? LucideIcons.logOut : LucideIcons.clock),
                      size: 14,
                      color: isCheckedIn 
                          ? Colors.green 
                          : (isCheckedOut ? Colors.orange : AppColors.primaryLight),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isCheckedIn 
                          ? 'Clocked In'
                          : (isCheckedOut 
                              ? 'Clocked Out'
                              : 'Not Clocked In'),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: clockState.isSyncPending ? Colors.orange : (isCheckedIn 
                            ? Colors.green 
                            : (isCheckedOut ? Colors.orange : AppColors.primaryLight)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s24),
          if (isCheckedIn)
            Center(
              child: Column(
                children: [
                  Text(
                    _formatDuration(clockState.elapsed),
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s8),
                  Text(
                    'Since ${DateFormat('hh:mm a').format(clockState.checkInTime!)}',
                    style: AppTypography.caption,
                  ),
                ],
              ),
            )
          else if (isCheckedOut)
             Center(
              child: Column(
                children: [
                  Text(
                    _formatDuration(clockState.elapsed),
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s8),
                  Text(
                    'Total Time Logged',
                    style: AppTypography.caption,
                  ),
                ],
              ),
            )
          else
            const Center(
              child: Text(
                '00:00:00',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                  color: Colors.grey,
                ),
              ),
            ),
          const SizedBox(height: AppSpacing.s32),
          
          SlideAction(
            key: ValueKey(clockState.status),
            text: isCheckedIn ? 'Slide to Clock Out' : 'Slide to Clock In',
            submittingText: 'Recording...',
            completedText: 'Success',
            outerColor: isCheckedIn ? Colors.orange : AppColors.primaryLight,
            onSubmit: () async {
              if (isCheckedIn) {
                await ref.read(attendanceClockProvider.notifier).checkOut();
              } else {
                await ref.read(attendanceClockProvider.notifier).checkIn();
              }
              
              if (!context.mounted) return;
              
              final newState = ref.read(attendanceClockProvider);
              if (newState.error != null) {
                 ScaffoldMessenger.of(context).showSnackBar(
                   SnackBar(
                     content: Row(children: [const Icon(LucideIcons.alertCircle, color: Colors.white, size: 18), const SizedBox(width: 8), Expanded(child: Text(newState.error!))]),
                     backgroundColor: Colors.red.shade700,
                     behavior: SnackBarBehavior.floating,
                   )
                 );
              } else if (newState.isSyncPending) {
                 ScaffoldMessenger.of(context).showSnackBar(
                   SnackBar(
                     content: Row(children: [const Icon(LucideIcons.wifiOff, color: Colors.white, size: 18), const SizedBox(width: 8), const Expanded(child: Text('Network unavailable. Punch saved offline and will sync automatically.'))]),
                     backgroundColor: Colors.orange.shade800,
                     behavior: SnackBarBehavior.floating,
                     duration: const Duration(seconds: 4),
                   )
                 );
              } else {
                 final actionStr = isCheckedIn ? 'clocked out' : 'clocked in';
                 ScaffoldMessenger.of(context).showSnackBar(
                   SnackBar(
                     content: Row(children: [const Icon(LucideIcons.checkCircle2, color: Colors.white, size: 18), const SizedBox(width: 8), Text('Successfully $actionStr!')]),
                     backgroundColor: Colors.green.shade700,
                     behavior: SnackBarBehavior.floating,
                     duration: const Duration(seconds: 2),
                   )
                 );
              }
            },
          ),
          if (clockState.error != null)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.s12),
              child: Text(
                clockState.error!,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}
