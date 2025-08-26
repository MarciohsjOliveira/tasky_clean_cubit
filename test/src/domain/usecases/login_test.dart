import 'package:flutter_test/flutter_test.dart';
import 'package:tasky_clean_cubit/src/domain/entities/user.dart';
import 'package:tasky_clean_cubit/src/domain/repositories/auth_repository.dart';
import 'package:tasky_clean_cubit/src/domain/usecases/login.dart';

class _AuthRepoFake implements AuthRepository {
  String? lastEmail;
  String? lastPassword;
  (String, AppUser)? nextLogin;
  Object? toThrow;

  @override
  Future<(String, AppUser)> login({required String email, required String password}) async {
    if (toThrow != null) throw toThrow!;
    lastEmail = email;
    lastPassword = password;
    return nextLogin ?? ('token-1', AppUser(id: '1', email: email, name: 'Tester'));
  }

  @override
  Future<(String, AppUser)> register({required String name, required String email, required String password}) =>
      throw UnimplementedError();

  @override
  Future<void> logout() => throw UnimplementedError();

  @override
  Future<String?> currentToken() => throw UnimplementedError();
}

void main() {
  group('Login', () {
    test('calls repository with email and password and returns token+user', () async {
      final repo = _AuthRepoFake();
      final usecase = Login(repo);

      final (token, user) = await usecase(email: 'a@x.com', password: 'secret');

      expect(repo.lastEmail, 'a@x.com');
      expect(repo.lastPassword, 'secret');
      expect(token, 'token-1');
      expect(user.email, 'a@x.com');
      expect(user.name, 'Tester');
    });

    test('returns provided repository result', () async {
      final repo = _AuthRepoFake()
        ..nextLogin = ('t-abc', const AppUser(id: '42', email: 'b@x.com', name: 'Bob'));
      final usecase = Login(repo);

      final (token, user) = await usecase(email: 'b@x.com', password: 'pw');

      expect(token, 't-abc');
      expect(user.id, '42');
      expect(user.name, 'Bob');
    });

    test('rethrows repository errors', () async {
      final repo = _AuthRepoFake()..toThrow = StateError('fail');
      final usecase = Login(repo);

      await expectLater(usecase(email: 'z@z.com', password: 'pw'), throwsA(isA<StateError>()));
    });
  });
}
