import 'package:flutter_test/flutter_test.dart';
import 'package:tasky_clean_cubit/src/domain/entities/user.dart';
import 'package:tasky_clean_cubit/src/domain/repositories/auth_repository.dart';
import 'package:tasky_clean_cubit/src/domain/usecases/register.dart';

class _AuthRepoFake implements AuthRepository {
  String? lastName;
  String? lastEmail;
  String? lastPassword;
  (String, AppUser)? nextRegister;
  Object? toThrow;

  @override
  Future<(String, AppUser)> register({
    required String name,
    required String email,
    required String password,
  }) async {
    if (toThrow != null) throw toThrow!;
    lastName = name;
    lastEmail = email;
    lastPassword = password;
    return nextRegister ?? ('token-1', AppUser(id: '1', email: email, name: name));
  }

  @override
  Future<(String, AppUser)> login({required String email, required String password}) =>
      throw UnimplementedError();

  @override
  Future<void> logout() => throw UnimplementedError();

  @override
  Future<String?> currentToken() => throw UnimplementedError();
}

void main() {
  group('Register', () {
    test('calls repository with name, email, password and returns token+user', () async {
      final repo = _AuthRepoFake();
      final usecase = Register(repo);

      final (token, user) = await usecase(name: 'Alice', email: 'a@x.com', password: 'secret');

      expect(repo.lastName, 'Alice');
      expect(repo.lastEmail, 'a@x.com');
      expect(repo.lastPassword, 'secret');
      expect(token, 'token-1');
      expect(user.email, 'a@x.com');
      expect(user.name, 'Alice');
    });

    test('returns provided repository result', () async {
      final repo = _AuthRepoFake()
        ..nextRegister = ('t-abc', const AppUser(id: '42', email: 'b@x.com', name: 'Bob'));
      final usecase = Register(repo);

      final (token, user) = await usecase(name: 'Bob', email: 'b@x.com', password: 'pw');

      expect(token, 't-abc');
      expect(user.id, '42');
      expect(user.name, 'Bob');
    });

    test('rethrows repository errors', () async {
      final repo = _AuthRepoFake()..toThrow = StateError('fail');
      final usecase = Register(repo);

      await expectLater(
        usecase(name: 'X', email: 'x@x.com', password: 'pw'),
        throwsA(isA<StateError>()),
      );
    });
  });
}
