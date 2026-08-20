import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:projectiq_app/features/authentication/data/auth_repository.dart';

class MockDio extends Mock implements Dio {}
class MockResponse<T> extends Mock implements Response<T> {}

void main() {
  late AuthRepository authRepository;
  late MockDio mockDio;

  setUp(() {
    mockDio = MockDio();
    authRepository = AuthRepository(mockDio);
  });

  group('AuthRepository Unit Tests', () {
    test('login() returns User on success', () async {
      // Arrange
      final mockResponse = MockResponse<Map<String, dynamic>>();
      when(() => mockResponse.data).thenReturn({
        'id': '1',
        'email': 'test@example.com',
        'username': 'Test User',
      });
      when(() => mockDio.post(any(), data: any(named: 'data')))
          .thenAnswer((_) async => mockResponse);

      // Act
      final user = await authRepository.login('test@example.com', 'password');

      // Assert
      expect(user.id, '1');
      expect(user.email, 'test@example.com');
      expect(user.username, 'Test User');
      verify(() => mockDio.post('/auth/login', data: {'email': 'test@example.com', 'password': 'password'})).called(1);
    });

    test('me() returns User with employeeId if /admin/employees/me succeeds', () async {
      // Arrange
      final authResponse = MockResponse<Map<String, dynamic>>();
      when(() => authResponse.data).thenReturn({
        'id': '1',
        'email': 'test@example.com',
        'username': 'Test User',
      });
      
      final empResponse = MockResponse<Map<String, dynamic>>();
      when(() => empResponse.data).thenReturn({'id': '100'});

      when(() => mockDio.get('/auth/me')).thenAnswer((_) async => authResponse);
      when(() => mockDio.get('/admin/employees/me')).thenAnswer((_) async => empResponse);

      // Act
      final user = await authRepository.me();

      // Assert
      expect(user.id, '1');
      expect(user.employeeId, '100');
    });

    test('me() returns User WITHOUT employeeId if /admin/employees/me fails', () async {
      // Arrange
      final authResponse = MockResponse<Map<String, dynamic>>();
      when(() => authResponse.data).thenReturn({
        'id': '1',
        'email': 'test@example.com',
        'username': 'Test User',
      });

      when(() => mockDio.get('/auth/me')).thenAnswer((_) async => authResponse);
      when(() => mockDio.get('/admin/employees/me')).thenThrow(DioException(requestOptions: RequestOptions(path: '')));

      // Act
      final user = await authRepository.me();

      // Assert
      expect(user.id, '1');
      expect(user.employeeId, null);
    });

    test('logout() calls /auth/logout endpoint', () async {
      when(() => mockDio.post('/auth/logout')).thenAnswer((_) async => MockResponse());
      await authRepository.logout();
      verify(() => mockDio.post('/auth/logout')).called(1);
    });
  });
}
