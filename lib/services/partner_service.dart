import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_service.dart';
import 'auth_service.dart';
import '../core/api_constants.dart';
import '../data/models/user_profile.dart';

final partnerServiceProvider = Provider((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return PartnerService(apiService);
});

class PartnerService {
  final ApiService _apiService;

  PartnerService(this._apiService);

  Future<List<Map<String, dynamic>>> getPartners() async {
    final response = await _apiService.get(ApiConstants.partners);
    final data = response.data;
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(data['partners']);
    } else {
      throw Exception(data['error'] ?? 'Failed to get partners');
    }
  }

  Future<Map<String, dynamic>> createPartner(UserProfile profile) async {
    final response = await _apiService.post(ApiConstants.partners, {
      'full_name': profile.name,
      'nickname': profile.nickname,
      'gender': profile.gender,
      'date_of_birth': profile.birthday.toIso8601String().split('T')[0],
      'first_met_on': profile.relationshipStartDate?.toIso8601String().split(
        'T',
      )[0],
      'profile_image': profile.avatarPath, // This will be the URL after upload
      'is_partner': profile.isPartner,
    });

    final data = response.data;
    if (response.statusCode == 201) {
      return data['partner'];
    } else {
      throw Exception(data['error'] ?? 'Failed to create partner');
    }
  }

  Future<Map<String, dynamic>> updatePartner(
    int id,
    UserProfile profile,
  ) async {
    final response = await _apiService.put('${ApiConstants.partners}/$id', {
      'full_name': profile.name,
      'nickname': profile.nickname,
      'gender': profile.gender,
      'date_of_birth': profile.birthday.toIso8601String().split('T')[0],
      'first_met_on': profile.relationshipStartDate?.toIso8601String().split(
        'T',
      )[0],
      'profile_image': profile.avatarPath,
    });

    final data = response.data;
    if (response.statusCode == 200) {
      return data['partner'];
    } else {
      throw Exception(data['error'] ?? 'Failed to update partner');
    }
  }

  Future<void> deletePartner(int id) async {
    final response = await _apiService.delete('${ApiConstants.partners}/$id');
    if (response.statusCode != 200) {
      final data = response.data;
      throw Exception(data['error'] ?? 'Failed to delete partner');
    }
  }
}
