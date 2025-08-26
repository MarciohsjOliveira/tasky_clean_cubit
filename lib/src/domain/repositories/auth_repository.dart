import '../entities/user.dart';

abstract class AuthRepository {
  Future<(String token, AppUser user)> login(
      {required String email, required String password});
  Future<(String token, AppUser user)> register(
      {required String name, required String email, required String password});
  Future<void> logout();
  Future<String?> currentToken();
}
