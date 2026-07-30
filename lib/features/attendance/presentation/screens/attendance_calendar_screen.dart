import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/loaders/skeleton.dart';
import '../providers/attendance_calendar_providers.dart';

class AttendanceCalendarScreen extends ConsumerStatefulWidget {
  const AttendanceCalendarScreen({super.key});

  @override
  ConsumerState<AttendanceCalendarScreen> createState() => _AttendanceCalendarScreenState();
}

class _AttendanceCalendarScreenState extends ConsumerState<AttendanceCalendarScreen> {
  DateTime _currentMonth = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(attendanceCalendarProvider(_currentMonth));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Calendar'),
      ),
      body: Column(
        children: [
          _buildMonthHeader(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.s16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text('S'), Text('M'), Text('T'), Text('W'), Text('T'), Text('F'), Text('S'),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: state.when(
              data: (days) => _buildCalendarGrid(days),
              loading: () => const Padding(
                padding: EdgeInsets.all(AppSpacing.s16),
                child: Skeleton(width: double.infinity, height: 300),
              ),
              error: (err, _) => Center(child: Text('Error: $err')),
            ),
          ),
          _buildLegend(),
        ],
      ),
    );
  }

  Widget _buildMonthHeader() {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.s16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(LucideIcons.chevronLeft),
            onPressed: () {
              setState(() {
                _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
              });
            },
          ),
          Text(
            '${months[_currentMonth.month - 1]} ${_currentMonth.year}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(LucideIcons.chevronRight),
            onPressed: () {
              setState(() {
                _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid(List<dynamic> days) {
    // Determine the offset for the first day of the month
    final firstDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final emptyBoxesCount = firstDayOfMonth.weekday == 7 ? 0 : firstDayOfMonth.weekday;
    final totalItems = emptyBoxesCount + days.length;

    return GridView.builder(
      padding: const EdgeInsets.all(AppSpacing.s16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1.0,
      ),
      itemCount: totalItems,
      itemBuilder: (context, index) {
        if (index < emptyBoxesCount) {
          return const SizedBox.shrink();
        }
        final dayIndex = index - emptyBoxesCount;
        final day = days[dayIndex];
        return _buildDayCell(day);
      },
    );
  }

  Widget _buildDayCell(dynamic day) {
    Color bgColor;
    switch (day.status) {
      case 'Present': bgColor = Colors.green.withValues(alpha: 0.2); break;
      case 'Absent': bgColor = Colors.red.withValues(alpha: 0.2); break;
      case 'Leave': bgColor = Colors.blue.withValues(alpha: 0.2); break;
      case 'Weekend': bgColor = Colors.grey.withValues(alpha: 0.2); break;
      default: bgColor = Colors.transparent;
    }

    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: Text(
          '${day.date.day}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.s16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _legendItem(Colors.green, 'Present'),
          _legendItem(Colors.red, 'Absent'),
          _legendItem(Colors.blue, 'Leave'),
          _legendItem(Colors.grey, 'Weekend'),
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      children: [
        Container(width: 12, height: 12, color: color),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
