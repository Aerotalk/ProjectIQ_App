import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/attendance_calendar_model.dart';
import '../../data/repositories/attendance_repository.dart';
import '../../../authentication/presentation/auth_controller.dart';

final attendanceCalendarProvider = FutureProvider.family<List<AttendanceDayModel>, DateTime>((ref, arg) async {
  final user = ref.watch(authControllerProvider).user;
  return ref.read(attendanceRepositoryProvider).getAttendanceCalendar(
    arg.year, 
    arg.month,
    employeeId: user?.employeeId,
  );
});
