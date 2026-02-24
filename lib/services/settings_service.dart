import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_service.dart';
import 'auth_service.dart';
import '../core/api_constants.dart';

final settingsServiceProvider = Provider((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return SettingsService(apiService);
});

class SettingsService {
  final ApiService _apiService;

  SettingsService(this._apiService);

  Future<Map<String, dynamic>> getSettings() async {
    final response = await _apiService.get(ApiConstants.settings);
    final data = response.data;
    if (response.statusCode == 200) {
      return data['settings'];
    } else {
      throw Exception(data['error'] ?? 'Failed to get settings');
    }
  }

  Future<Map<String, dynamic>> updateSettings(
    Map<String, dynamic> settings,
  ) async {
    final response = await _apiService.put(ApiConstants.settings, settings);
    final data = response.data;
    if (response.statusCode == 200) {
      return data['settings'];
    } else {
      throw Exception(data['error'] ?? 'Failed to update settings');
    }
  }
}
