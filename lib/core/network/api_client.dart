import 'dart:io';
import 'package:capstone/core/error/app_exception.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:shared_preferences/shared_preferences.dart';


// Dio wrapper. Centralizes request config and maps DioException -> AppException.
class ApiClient {
  final Dio _dio;
  final SharedPreferences? _prefs;

  ApiClient({required String baseUrl, Dio? dio, SharedPreferences? prefs})
      : _prefs = prefs,
        _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: baseUrl,
                connectTimeout: const Duration(seconds: 15),
                receiveTimeout: const Duration(seconds: 60),
                headers: {
                  'Content-Type': 'application/json',
                  'Accept': 'application/json',
                  'ngrok-skip-browser-warning': 'true',
                  'Bypass-Tunnel-Reminder': 'true',
                },

              ),
            ) {
    // Bypass SSL certificate verification for dynamic development tunnels like ngrok/localtunnel
    if (_dio.httpClientAdapter is IOHttpClientAdapter) {
      (_dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
        final client = HttpClient();
        client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
        return client;
      };
    }

    if (_prefs != null) {
      _dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = _prefs!.getString('auth_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ));
    }
  }

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final res = await _dio.get<dynamic>(
        path,
        queryParameters: queryParameters,
      );
      return res.data;
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<dynamic> post(String path, {Object? data}) async {
    try {
      final res = await _dio.post<dynamic>(path, data: data);
      return res.data;
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<dynamic> put(String path, {Object? data}) async {
    try {
      final res = await _dio.put<dynamic>(path, data: data);
      return res.data;
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<void> delete(String path) async {
    try {
      await _dio.delete<dynamic>(path);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  // Maps transport/HTTP errors to the domain AppException taxonomy.
  AppException _mapError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionError:
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkException();
      case DioExceptionType.badResponse:
        return _mapStatus(e);
      default:
        return UnknownException('${e.type}: ${e.message}');
    }
  }

  AppException _mapStatus(DioException e) {
    final status = e.response?.statusCode ?? 0;
    if (status == 404) return const NotFoundException();
    if (status == 503) return const ServerUnavailableException();
    if (status >= 500) {
      if (_errorCode(e.response?.data) == 'GENERATION_FAILED') {
        return const GenerationFailedException();
      }
      return const ServerUnavailableException();
    }

    // Ambil detail error spesifik dari backend (misal: "User already registered")
    final dynamic data = e.response?.data;
    if (data is Map && data['detail'] is String) {
      return UnknownException(data['detail'] as String);
    }

    return const UnknownException();
  }

  // Extracts {"error": {"code": ...}} when present.
  String? _errorCode(dynamic data) {
    if (data is Map && data['error'] is Map) {
      return (data['error'] as Map)['code'] as String?;
    }
    return null;
  }
}
