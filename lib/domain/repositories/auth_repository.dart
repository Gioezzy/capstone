import 'package:capstone/domain/models/models.dart';

abstract class AuthRepository {
  Future<Token> login(String username, String password);
  Future<User> register(String username, String email, String password);
  Future<void> updatePassword(String oldPassword, String newPassword);
}
