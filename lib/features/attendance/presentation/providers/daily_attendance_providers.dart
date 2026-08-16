import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/daily_attendance_model.dart';
import '../../data/repositories/attendance_repository.dart';

import '../../../authentication/presentation/auth_controller.dart';

final dailyAttendanceListProvider = AsyncNotifierProvider<DailyAttendanceListNotifier, List<DailyAttendanceModel>>(() {
  return DailyAttendanceListNotifier();
});

class DailyAttendanceListNotifier extends AsyncNotifier<List<DailyAttendanceModel>> {
  @override
  Future<List<DailyAttendanceModel>> build() async {
    final authState = ref.watch(authControllerProvider);
    final user = authState.user;
    
    final isManagerOrHR = user?.hasRole('ROLE_SUPER_ADMIN') == true || 
                          user?.hasRole('ROLE_HR') == true || 
                          user?.hasRole('ROLE_COMPANY_ADMIN') == true || 
                          user?.hasRole('ROLE_MANAGER') == true;

    final employeeId = !isManagerOrHR && user != null ? user.employeeId : null;
    return ref.read(attendanceRepositoryProvider).getDailyAttendanceLogs(employeeId: employeeId);
  }
}
