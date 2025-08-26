import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/mock_api.dart';
import '../../core/services/secure_storage_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required MockApi api,
    required SecureStorageService storage,
  })  : _api = api,
        _storage = storage;
  final MockApi _api;
  final SecureStorageService _storage;

  @override
  Future<(String token, AppUser user)> login({
    required String email,
    required String password,
  }) async {
    final resp = await _api.login(email, password);
    await _storage.saveJwt(resp.$1);
    return resp;
  }

  @override
  Future<(String token, AppUser user)> register(
      {required String name,
      required String email,
      required String password}) async {
    final resp = await _api.register(name, email, password);
    await _storage.saveJwt(resp.$1);
    return resp;
  }

  @override
  Future<void> logout() async => _storage.clear();

  @override
  Future<String?> currentToken() => _storage.readJwt();
}
