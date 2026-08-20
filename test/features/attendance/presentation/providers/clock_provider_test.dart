import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:projectiq_app/features/attendance/presentation/providers/clock_provider.dart';
import 'package:projectiq_app/features/authentication/presentation/auth_controller.dart';
import 'package:projectiq_app/features/attendance/data/repositories/attendance_repository.dart';
import 'package:projectiq_app/features/authentication/domain/user.dart';

class MockAttendanceRepository extends Mock implements AttendanceRepository {}

class MockAuthController extends AuthController {
  final AuthState mockState;
  MockAuthController(this.mockState);

  @override
  AuthState build() => mockState;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late MockAttendanceRepository mockAttendanceRepository;

  setUp(() {
    mockAttendanceRepository = MockAttendanceRepository();
    SharedPreferences.setMockInitialValues({});
  });

  ProviderContainer makeProviderContainer({User? user}) {
    return ProviderContainer(
      overrides: [
        attendanceRepositoryProvider.overrideWithValue(mockAttendanceRepository),
        authControllerProvider.overrideWith(
          () => MockAuthController(AuthState(
            isLoading: false, 
            user: user,
            error: null
          )),
        ),
      ],
    );
  }

  group('AttendanceClockNotifier Unit Tests', () {
    test('initial state when user has no employeeId', () async {
      final container = makeProviderContainer(user: const User(id: '1', username: 'test', email: 'test@example.com', roles: [], effectivePermissions: []));
      
      final state = container.read(attendanceClockProvider);
      expect(state.isLoading, isTrue); // Initial sync

      await Future.delayed(Duration.zero);
      
      final resolvedState = container.read(attendanceClockProvider);
      expect(resolvedState.isLoading, isFalse);
      expect(resolvedState.status, ClockStatus.notCheckedIn);
    });

    test('restores checked in state from API', () async {
      final container = makeProviderContainer(user: const User(id: '1', username: 'test', email: 't@t.com', roles: [], effectivePermissions: [], employeeId: 'emp-123'));
      
      when(() => mockAttendanceRepository.getCheckInStatus('emp-123')).thenAnswer((_) async => {
        'currentlyCheckedIn': true,
        'workingHours': '2.5'
      });

      final state = container.read(attendanceClockProvider);
      expect(state.isLoading, isTrue);

      await Future.delayed(Duration.zero);
      
      final resolvedState = container.read(attendanceClockProvider);
      expect(resolvedState.isLoading, isFalse);
      expect(resolvedState.status, ClockStatus.checkedIn);
      expect(resolvedState.accumulatedElapsed.inSeconds, equals((2.5 * 3600).toInt()));
    });
  });
}
