import 'package:flutter_test/flutter_test.dart';
import 'package:tasky_clean_cubit/src/core/services/secure_storage_service.dart';
import 'package:tasky_clean_cubit/src/data/datasources/mock_api.dart';
import 'package:tasky_clean_cubit/src/data/repositories/auth_repository_impl.dart';
import 'package:tasky_clean_cubit/src/domain/entities/user.dart';

class _ApiFake extends MockApi {
  String? lastLoginEmail;
  String? lastLoginPassword;
  String? lastRegisterName;
  String? lastRegisterEmail;
  String? lastRegisterPassword;

  (String, AppUser)? nextLogin;
  (String, AppUser)? nextRegister;

  Object? loginError;
  Object? registerError;

  @override
  Future<(String, AppUser)> login(String email, String password) async {
    if (loginError != null) throw loginError!;
    lastLoginEmail = email;
    lastLoginPassword = password;
    return nextLogin ??
        ('t-login', AppUser(id: '1', email: email, name: 'Tester'));
  }

  @override
  Future<(String, AppUser)> register(
      String name, String email, String password) async {
    if (registerError != null) throw registerError!;
    lastRegisterName = name;
    lastRegisterEmail = email;
    lastRegisterPassword = password;
    return nextRegister ??
        ('t-register', AppUser(id: '2', email: email, name: name));
  }
}

class _StorageFake extends SecureStorageService {
  String? _jwt;

  @override
  Future<void> saveJwt(String token) async {
    _jwt = token;
  }

  @override
  Future<String?> readJwt() async => _jwt;

  @override
  Future<void> clear() async {
    _jwt = null;
  }
}

void main() {
  group('AuthRepositoryImpl', () {
    test('login saves token and returns tuple', () async {
      final api = _ApiFake()
        ..nextLogin = (
          'token-1',
          const AppUser(
            id: '10',
            email: 'a@x.com',
            name: 'Alice',
          )
        );
      final storage = _StorageFake();
      final repo = AuthRepositoryImpl(api: api, storage: storage);

      final (token, user) = await repo.login(
        email: 'a@x.com',
        password: 'pw',
      );

      expect(api.lastLoginEmail, 'a@x.com');
      expect(api.lastLoginPassword, 'pw');
      expect(token, 'token-1');
      expect(user.id, '10');
      expect(await storage.readJwt(), 'token-1');
    });

    test('register saves token and returns tuple', () async {
      final api = _ApiFake()
        ..nextRegister = (
          'token-2',
          const AppUser(
            id: '11',
            email: 'b@x.com',
            name: 'Bob',
          )
        );
      final storage = _StorageFake();
      final repo = AuthRepositoryImpl(api: api, storage: storage);

      final (token, user) = await repo.register(
        name: 'Bob',
        email: 'b@x.com',
        password: 'pw',
      );

      expect(api.lastRegisterName, 'Bob');
      expect(api.lastRegisterEmail, 'b@x.com');
      expect(api.lastRegisterPassword, 'pw');
      expect(token, 'token-2');
      expect(user.id, '11');
      expect(await storage.readJwt(), 'token-2');
    });

    test('currentToken returns value from storage', () async {
      final api = _ApiFake();
      final storage = _StorageFake();
      final repo = AuthRepositoryImpl(
        api: api,
        storage: storage,
      );

      await storage.saveJwt('xyz');
      final tok = await repo.currentToken();

      expect(tok, 'xyz');
    });

    test('logout clears storage', () async {
      final api = _ApiFake();
      final storage = _StorageFake();
      final repo = AuthRepositoryImpl(
        api: api,
        storage: storage,
      );

      await storage.saveJwt('abc');
      await repo.logout();

      expect(await storage.readJwt(), isNull);
    });

    test('login rethrows errors and does not save token', () async {
      final api = _ApiFake()..loginError = StateError('fail');
      final storage = _StorageFake();
      final repo = AuthRepositoryImpl(
        api: api,
        storage: storage,
      );

      await expectLater(
        repo.login(email: 'z@z.com', password: 'pw'),
        throwsA(isA<StateError>()),
      );
      expect(await storage.readJwt(), isNull);
    });

    test('register rethrows errors and does not save token', () async {
      final api = _ApiFake()..registerError = StateError('fail');
      final storage = _StorageFake();
      final repo = AuthRepositoryImpl(
        api: api,
        storage: storage,
      );

      await expectLater(
        repo.register(name: 'X', email: 'x@x.com', password: 'pw'),
        throwsA(isA<StateError>()),
      );
      expect(await storage.readJwt(), isNull);
    });
  });
}
