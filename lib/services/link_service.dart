import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_service.dart';
import 'auth_service.dart';
import '../core/api_constants.dart';

final linkServiceProvider = Provider((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return LinkService(apiService);
});

class LinkService {
  final ApiService _apiService;

  LinkService(this._apiService);

  Future<Map<String, dynamic>> linkPartner(String inviteCode) async {
    final response = await _apiService.post(ApiConstants.link, {
      'invite_code': inviteCode,
    });

    final data = response.data;
    if (response.statusCode == 200) {
      return data;
    } else {
      throw Exception(data['error'] ?? 'Linking failed');
    }
  }

  Future<Map<String, dynamic>> getLinkStatus() async {
    final response = await _apiService.get(ApiConstants.link);
    final data = response.data;
    if (response.statusCode == 200) {
      return data;
    } else {
      throw Exception(data['error'] ?? 'Failed to get status');
    }
  }

  Future<void> unlinkPartner() async {
    final response = await _apiService.delete(ApiConstants.link);
    if (response.statusCode != 200) {
      final data = response.data;
      throw Exception(data['error'] ?? 'Failed to unlink');
    }
  }
}
