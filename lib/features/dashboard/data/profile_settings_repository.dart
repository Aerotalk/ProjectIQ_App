import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../authentication/presentation/auth_controller.dart';

final profileSettingsRepositoryProvider = Provider<ProfileSettingsRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return ProfileSettingsRepository(dio, ref);
});

class ProfileSettingsRepository {
  final Dio _dio;
  final Ref _ref;

  ProfileSettingsRepository(this._dio, this._ref);

  Future<void> updatePersonalInformation(String username, String? photoId) async {
    try {
      await _dio.put(
        '/auth/profile',
        data: {
          'username': username,
          if (photoId != null) 'profilePhotoId': photoId,
        },
      );
      // Refresh user session data after updating profile
      _ref.read(authControllerProvider.notifier).refreshUser();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updatePassword(String currentPassword, String newPassword) async {
    // Note: Backend endpoint for updating logged-in user's password is not yet available.
    // Mocking success delay for now.
    await Future.delayed(const Duration(seconds: 1));
    // throw Exception('Not implemented in backend');
  }

  Future<void> updateNotificationPreferences(Map<String, bool> preferences) async {
    // Note: Backend endpoint for notification preferences is not yet available.
    // Mocking success delay for now.
    await Future.delayed(const Duration(milliseconds: 500));
  }
}
