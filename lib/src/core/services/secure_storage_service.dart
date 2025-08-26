import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants.dart';

class SecureStorageService {
  final _storage = const FlutterSecureStorage();
  Future<void> saveJwt(String token) =>
      _storage.write(key: AppKeys.jwt, value: token);
  Future<String?> readJwt() => _storage.read(key: AppKeys.jwt);
  Future<void> clear() => _storage.delete(key: AppKeys.jwt);
}
