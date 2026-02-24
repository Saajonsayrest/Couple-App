import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_service.dart';
import 'auth_service.dart';
import '../core/api_constants.dart';

final uploadServiceProvider = Provider((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return UploadService(apiService);
});

class UploadService {
  final ApiService _apiService;

  UploadService(this._apiService);

  Future<String> uploadImage(File file, {String type = 'avatar'}) async {
    final response = await _apiService.multipartPost(
      ApiConstants.upload,
      file,
      type: type,
    );
    final data = response.data;

    if (response.statusCode == 200 || response.statusCode == 201) {
      return data['url'];
    } else {
      throw Exception(data['error'] ?? 'Upload failed');
    }
  }
}
