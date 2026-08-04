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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final isCheckedIn = clockState.status == ClockStatus.checkedIn;
    final isCheckedOut = clockState.status == ClockStatus.checkedOut;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.s24),
      color: isDark ? AppColors.cardDark : AppColors.cardLight,
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
                          ? 'Checked In' 
                          : (isCheckedOut ? 'Checked Out' : 'Not Checked In'),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isCheckedIn 
                            ? Colors.green 
                            : (isCheckedOut ? Colors.orange : AppColors.primaryLight),
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
          
          if (!isCheckedOut)
            SlideAction(
              text: isCheckedIn ? 'Slide to Check Out' : 'Slide to Check In',
              submittingText: 'Recording...',
              completedText: 'Success',
              outerColor: isCheckedIn ? Colors.orange : AppColors.primaryLight,
              isCompleted: clockState.isLoading,
              onSubmit: () async {
                if (isCheckedIn) {
                  await ref.read(attendanceClockProvider.notifier).checkOut();
                } else {
                  await ref.read(attendanceClockProvider.notifier).checkIn();
                }
              },
            ),
        ],
      ),
    );
  }
}
