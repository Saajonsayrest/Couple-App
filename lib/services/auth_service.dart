import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_service.dart';
import '../core/api_constants.dart';

final apiServiceProvider = Provider((ref) => ApiService());

final authServiceProvider = Provider((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return AuthService(apiService);
});

class AuthService {
  final ApiService _apiService;

  AuthService(this._apiService);

  Future<Map<String, dynamic>> register(
    String username,
    String password,
  ) async {
    final response = await _apiService.post(ApiConstants.register, {
      'username': username,
      'password': password,
    });

    final data = response.data;
    if (response.statusCode == 201) {
      if (data['token'] != null) {
        await _apiService.saveToken(data['token']);
      }
      return data;
    } else {
      throw Exception(data['error'] ?? 'Registration failed');
    }
  }

  Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await _apiService.post(ApiConstants.login, {
      'username': username,
      'password': password,
    });

    final data = response.data;
    if (response.statusCode == 200) {
      if (data['token'] != null) {
        await _apiService.saveToken(data['token']);
      }
      return data;
    } else {
      throw Exception(data['error'] ?? 'Login failed');
    }
  }

  Future<Map<String, dynamic>> getCurrentUser() async {
    final response = await _apiService.get(ApiConstants.me);
    final data = response.data;
    if (response.statusCode == 200) {
      return data['user'];
    } else {
      throw Exception(data['error'] ?? 'Failed to get profile');
    }
  }

  Future<void> logout() async {
    await _apiService.clearToken();
  }

  Future<bool> isLoggedIn() async {
    final token = await _apiService.getToken();
    return token != null;
  }
}
