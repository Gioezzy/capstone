import 'package:capstone/core/error/app_exception.dart';
import 'package:dio/dio.dart';

// Dio wrapper. Centralizes request config and maps DioException -> AppException.
class ApiClient {
  final Dio _dio;

  ApiClient({required String baseUrl, Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: baseUrl,
                connectTimeout: const Duration(seconds: 15),
                receiveTimeout: const Duration(seconds: 60),
                headers: {
                  'Content-Type': 'application/json',
                  'Accept': 'application/json',
                },
              ),
            );

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
        return const UnknownException();
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
