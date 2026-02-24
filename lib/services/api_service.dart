import 'dart:io';
import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/api_constants.dart';

class ApiService {
  late final Dio _dio;
  static const String _tokenKey = 'auth_token';

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 13),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add logging
    _dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
        maxWidth: 90,
      ),
    );

    // Add token interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  Future<Response> get(String endpoint) async {
    try {
      return await _dio.get(endpoint);
    } on DioException catch (e) {
      // Return the response even if it's an error so services can handle it
      if (e.response != null) return e.response!;
      throw Exception('Network error: ${e.message}');
    }
  }

  Future<Response> post(String endpoint, dynamic body) async {
    try {
      return await _dio.post(endpoint, data: body);
    } on DioException catch (e) {
      if (e.response != null) return e.response!;
      throw Exception('Network error: ${e.message}');
    }
  }

  Future<Response> put(String endpoint, dynamic body) async {
    try {
      return await _dio.put(endpoint, data: body);
    } on DioException catch (e) {
      if (e.response != null) return e.response!;
      throw Exception('Network error: ${e.message}');
    }
  }

  Future<Response> delete(String endpoint) async {
    try {
      return await _dio.delete(endpoint);
    } on DioException catch (e) {
      if (e.response != null) return e.response!;
      throw Exception('Network error: ${e.message}');
    }
  }

  Future<Response> multipartPost(
    String endpoint,
    File file, {
    String type = 'avatar',
  }) async {
    try {
      final formData = FormData.fromMap({
        'type': type,
        'image': await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        ),
      });

      return await _dio.post(endpoint, data: formData);
    } on DioException catch (e) {
      if (e.response != null) return e.response!;
      throw Exception('Network error: ${e.message}');
    }
  }
}
