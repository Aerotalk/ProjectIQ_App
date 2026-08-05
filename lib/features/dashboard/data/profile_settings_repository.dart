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
          if (photoId != null) 'profilePhotoId': photoId.isEmpty ? null : photoId,
        },
      );
      // Refresh user session data after updating profile
      _ref.read(authControllerProvider.notifier).refreshUser();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updatePassword(String currentPassword, String newPassword) async {
    try {
      await _dio.put(
        '/auth/password',
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
      );
    } catch (e) {
      if (e is DioException && e.response?.data != null) {
        throw Exception(e.response?.data['message'] ?? e.response?.data ?? 'Failed to update password');
      }
      rethrow;
    }
  }

  Future<String> uploadProfilePhoto(String filePath) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath),
        'module': 'profile_pictures',
      });
      final response = await _dio.post(
        '/admin/files/upload',
        data: formData,
      );
      return response.data['id'];
    } catch (e) {
      if (e is DioException && e.response?.data != null) {
        throw Exception(e.response?.data['message'] ?? 'Failed to upload photo');
      }
      rethrow;
    }
  }

  Future<void> updateNotificationPreferences(Map<String, bool> preferences) async {
    // Note: Backend endpoint for notification preferences is not yet available.
    // Mocking success delay for now.
    await Future.delayed(const Duration(milliseconds: 500));
  }
}
