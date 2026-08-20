import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:projectiq_app/features/hrms/data/performance_repository.dart';

class MockDio extends Mock implements Dio {}
class MockResponse<T> extends Mock implements Response<T> {}

void main() {
  late PerformanceRepository performanceRepository;
  late MockDio mockDio;

  setUp(() {
    mockDio = MockDio();
    performanceRepository = PerformanceRepository(mockDio);
  });

  group('PerformanceRepository Unit Tests', () {
    test('getActiveCycles parses correctly when API returns data list', () async {
      // Arrange
      final mockResponse = MockResponse<Map<String, dynamic>>();
      when(() => mockResponse.data).thenReturn({
        'data': [
          {
            'id': 'cycle-1',
            'name': '2023 Annual',
            'type': 'Annual',
            'period': '2023',
            'startDate': '2023-01-01T00:00:00.000Z',
            'endDate': '2023-12-31T00:00:00.000Z',
            'selfReviewDeadline': '2023-11-30T00:00:00.000Z',
            'managerReviewDeadline': '2023-12-15T00:00:00.000Z',
            'hrReviewDeadline': '2023-12-31T00:00:00.000Z',
            'eligibleCount': 100,
            'completionPercentage': 50,
            'status': 'Active',
            'description': 'Annual appraisal'
          }
        ]
      });
      when(() => mockDio.get('/hrms/performance/cycles'))
          .thenAnswer((_) async => mockResponse);

      // Act
      final cycles = await performanceRepository.getActiveCycles();

      // Assert
      expect(cycles.length, 1);
      expect(cycles.first.id, 'cycle-1');
      expect(cycles.first.name, '2023 Annual');
      verify(() => mockDio.get('/hrms/performance/cycles')).called(1);
    });

    test('getGoals parses correctly when API returns array', () async {
      // Arrange
      final mockResponse = MockResponse<List<dynamic>>();
      when(() => mockResponse.data).thenReturn([
        {
          'id': 'goal-1',
          'title': 'Test Goal',
          'employee': {
            'id': 'emp-1',
            'firstName': 'John',
            'lastName': 'Doe',
            'designation': {'designationName': 'Dev'},
            'department': {'departmentName': 'Engineering'}
          },
          'cycleId': 'cycle-1',
          'targetValue': 100,
          'currentValue': 50,
          'status': 'In Progress'
        }
      ]);
      when(() => mockDio.get('/hrms/performance/goals'))
          .thenAnswer((_) async => mockResponse);

      // Act
      final goals = await performanceRepository.getGoals();

      // Assert
      expect(goals.length, 1);
      expect(goals.first.id, 'goal-1');
      expect(goals.first.title, 'Test Goal');
      expect(goals.first.employee.name, 'John Doe');
      expect(goals.first.targetValue, 100.0);
      expect(goals.first.currentValue, 50.0);
      verify(() => mockDio.get('/hrms/performance/goals')).called(1);
    });

    test('createGoal calls POST correctly', () async {
      // Arrange
      final mockResponse = MockResponse<Map<String, dynamic>>();
      when(() => mockResponse.data).thenReturn({'success': true});
      when(() => mockDio.post('/hrms/performance/goals', data: any(named: 'data')))
          .thenAnswer((_) async => mockResponse);

      // Act
      final payload = {'title': 'New Goal'};
      final response = await performanceRepository.createGoal(payload);

      // Assert
      expect(response['success'], true);
      verify(() => mockDio.post('/hrms/performance/goals', data: payload)).called(1);
    });
  });
}
