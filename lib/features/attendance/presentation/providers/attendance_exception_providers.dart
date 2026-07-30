import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/attendance_exception_model.dart';
import '../../data/repositories/attendance_repository.dart';

final attendanceExceptionListProvider = AsyncNotifierProvider<AttendanceExceptionListNotifier, List<AttendanceExceptionModel>>(() {
  return AttendanceExceptionListNotifier();
});

class AttendanceExceptionListNotifier extends AsyncNotifier<List<AttendanceExceptionModel>> {
  @override
  Future<List<AttendanceExceptionModel>> build() async {
    return ref.read(attendanceRepositoryProvider).getAttendanceExceptions();
  }
}
