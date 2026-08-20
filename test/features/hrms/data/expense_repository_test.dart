import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:projectiq_app/features/hrms/data/expense_repository.dart';

class MockDio extends Mock implements Dio {}
class MockResponse<T> extends Mock implements Response<T> {}

void main() {
  late ExpenseRepository expenseRepository;
  late MockDio mockDio;

  setUp(() {
    mockDio = MockDio();
    expenseRepository = ExpenseRepository(mockDio);
  });

  group('ExpenseRepository Unit Tests', () {
    test('getClaims parses list correctly', () async {
      // Arrange
      final mockResponse = MockResponse<List<dynamic>>();
      when(() => mockResponse.data).thenReturn([
        {
          'id': 'claim-1',
          'claimNo': 'CLM-001',
          'title': 'Business Trip',
          'totalClaimed': 1500.5,
          'status': 'Approved',
          'submittedOn': '2023-11-01'
        }
      ]);
      when(() => mockDio.get('/hrms/expense-claims/claims'))
          .thenAnswer((_) async => mockResponse);

      // Act
      final claims = await expenseRepository.getClaims();

      // Assert
      expect(claims.length, 1);
      expect(claims.first['id'], 'claim-1');
      expect(claims.first['claimNo'], 'CLM-001');
      expect(claims.first['totalClaimed'], 1500.5);
      verify(() => mockDio.get('/hrms/expense-claims/claims')).called(1);
    });

    test('createClaim sends payload to correct endpoint', () async {
      // Arrange
      final mockResponse = MockResponse<Map<String, dynamic>>();
      when(() => mockResponse.data).thenReturn({'success': true});
      when(() => mockDio.post('/hrms/expense-claims/claims', data: any(named: 'data')))
          .thenAnswer((_) async => mockResponse);

      final payload = {'title': 'New Claim'};
      
      // Act
      final result = await expenseRepository.createClaim(payload);

      // Assert
      expect(result['success'], true);
      verify(() => mockDio.post('/hrms/expense-claims/claims', data: payload)).called(1);
    });
  });
}
