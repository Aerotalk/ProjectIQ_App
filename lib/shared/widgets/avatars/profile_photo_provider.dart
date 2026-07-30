import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';

final profilePhotoProvider = FutureProvider.family<Uint8List?, String>((ref, photoId) async {
  final dio = ref.watch(dioProvider);
  try {
    final response = await dio.get<List<int>>(
      '/admin/files/$photoId',
      options: Options(responseType: ResponseType.bytes),
    );
    if (response.data != null) {
      return Uint8List.fromList(response.data!);
    }
    return null;
  } catch (e) {
    // If the file cannot be fetched (e.g. 404, 401), we return null to fallback to initials.
    return null;
  }
});
