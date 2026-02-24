import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_service.dart';
import 'auth_service.dart';
import '../core/api_constants.dart';
import '../data/models/timeline_event.dart';

final journeyServiceProvider = Provider((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return JourneyService(apiService);
});

class JourneyService {
  final ApiService _apiService;

  JourneyService(this._apiService);

  Future<List<Map<String, dynamic>>> getJourneys() async {
    final response = await _apiService.get(ApiConstants.journeys);
    final data = response.data;
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(data['journeys']);
    } else {
      throw Exception(data['error'] ?? 'Failed to get journeys');
    }
  }

  Future<Map<String, dynamic>> createJourney(TimelineEvent event) async {
    final response = await _apiService.post(ApiConstants.journeys, {
      'title': event.title,
      'body': event.body,
      'date': event.date.toIso8601String().split('T')[0],
    });

    final data = response.data;
    if (response.statusCode == 201) {
      return data['journey'];
    } else {
      throw Exception(data['error'] ?? 'Failed to create journey');
    }
  }

  Future<Map<String, dynamic>> updateJourney(
    int id,
    TimelineEvent event,
  ) async {
    final response = await _apiService.put('${ApiConstants.journeys}/$id', {
      'title': event.title,
      'body': event.body,
      'date': event.date.toIso8601String().split('T')[0],
    });

    final data = response.data;
    if (response.statusCode == 200) {
      return data['journey'];
    } else {
      throw Exception(data['error'] ?? 'Failed to update journey');
    }
  }

  Future<void> deleteJourney(int id) async {
    final response = await _apiService.delete('${ApiConstants.journeys}/$id');
    if (response.statusCode != 200) {
      final data = response.data;
      throw Exception(data['error'] ?? 'Failed to delete journey');
    }
  }
}
