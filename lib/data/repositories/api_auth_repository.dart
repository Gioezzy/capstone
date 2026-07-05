import 'package:capstone/core/network/api_client.dart';
import 'package:capstone/core/network/api_endpoints.dart';
import 'package:capstone/domain/models/models.dart';
import 'package:capstone/domain/repositories/auth_repository.dart';
import 'package:dio/dio.dart';

class ApiAuthRepository implements AuthRepository {
  final ApiClient _client;

  ApiAuthRepository(this._client);

  @override
  Future<Token> login(String username, String password) async {
    // backend expects form-data (OAuth2PasswordRequestForm)
    final formData = FormData.fromMap({
      'username': username,
      'password': password,
    });
    
    final data = await _client.post(
      ApiEndpoints.login,
      data: formData,
    );
    
    return Token.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<User> register(String username, String email, String password) async {
    final data = await _client.post(
      ApiEndpoints.register,
      data: {
        'username': username,
        'email': email,
        'password': password,
      },
    );
    return User.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<void> updatePassword(String oldPassword, String newPassword) async {
    await _client.put(
      ApiEndpoints.updatePassword,
      data: {
        'old_password': oldPassword,
        'new_password': newPassword,
      },
    );
  }
}
