import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:projectiq_app/features/attendance/data/repositories/attendance_repository.dart';

class MockDio extends Mock implements Dio {}
class MockResponse<T> extends Mock implements Response<T> {}

void main() {
  late AttendanceRepository attendanceRepository;
  late MockDio mockDio;

  setUp(() {
    mockDio = MockDio();
    attendanceRepository = AttendanceRepository(mockDio);
  });

  group('AttendanceRepository Unit Tests', () {
    test('getCheckInStatus returns status when API succeeds', () async {
      // Arrange
      final mockResponse = MockResponse<Map<String, dynamic>>();
      when(() => mockResponse.data).thenReturn({
        'currentlyCheckedIn': true,
        'checkInTime': '2023-10-27T09:00:00Z',
      });
      when(() => mockDio.get(
            '/hrms/attendance/records/check-in/status',
            queryParameters: {'employeeId': 'emp-123'},
          )).thenAnswer((_) async => mockResponse);

      // Act
      final status = await attendanceRepository.getCheckInStatus('emp-123');

      // Assert
      expect(status['currentlyCheckedIn'], true);
      expect(status['checkInTime'], '2023-10-27T09:00:00Z');
      verify(() => mockDio.get(
            '/hrms/attendance/records/check-in/status',
            queryParameters: {'employeeId': 'emp-123'},
          )).called(1);
    });

    test('getCheckInStatus returns false status when API fails', () async {
      // Arrange
      when(() => mockDio.get(
            '/hrms/attendance/records/check-in/status',
            queryParameters: {'employeeId': 'emp-123'},
          )).thenThrow(DioException(requestOptions: RequestOptions(path: '')));

      // Act
      final status = await attendanceRepository.getCheckInStatus('emp-123');

      // Assert
      expect(status['currentlyCheckedIn'], false);
    });

    test('checkIn calls correct endpoint', () async {
      // Arrange
      when(() => mockDio.post(
            '/hrms/attendance/records/check-in',
            data: any(named: 'data'),
          )).thenAnswer((_) async => MockResponse());

      // Act
      await attendanceRepository.checkIn(
        'emp-123',
        lat: 1.0,
        lng: 2.0,
        locationLabel: 'Test Address',
      );

      // Assert
      verify(() => mockDio.post(
            '/hrms/attendance/records/check-in',
            data: any(named: 'data'),
          )).called(1);
    });
  });
}
