import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/daily_attendance_model.dart';
import '../../data/repositories/attendance_repository.dart';

final dailyAttendanceListProvider = AsyncNotifierProvider<DailyAttendanceListNotifier, List<DailyAttendanceModel>>(() {
  return DailyAttendanceListNotifier();
});

class DailyAttendanceListNotifier extends AsyncNotifier<List<DailyAttendanceModel>> {
  @override
  Future<List<DailyAttendanceModel>> build() async {
    return ref.read(attendanceRepositoryProvider).getDailyAttendanceLogs();
  }
}
