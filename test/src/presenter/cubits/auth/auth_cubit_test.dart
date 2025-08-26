import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tasky_clean_cubit/src/core/services/secure_storage_service.dart';
import 'package:tasky_clean_cubit/src/domain/entities/user.dart';
import 'package:tasky_clean_cubit/src/domain/repositories/auth_repository.dart';
import 'package:tasky_clean_cubit/src/domain/usecases/login.dart';
import 'package:tasky_clean_cubit/src/domain/usecases/register.dart';
import 'package:tasky_clean_cubit/src/presenter/cubits/auth/auth_cubit.dart';
import 'package:tasky_clean_cubit/src/presenter/cubits/auth/auth_state.dart';

class _AuthRepoFake implements AuthRepository {
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
  Future<(String, AppUser)> login({required String email, required String password}) async {
    if (loginError != null) throw loginError!;
    lastLoginEmail = email;
    lastLoginPassword = password;
    return nextLogin ?? ('t', AppUser(id: '1', email: email, name: 'User'));
  }

  @override
  Future<(String, AppUser)> register({required String name, required String email, required String password}) async {
    if (registerError != null) throw registerError!;
    lastRegisterName = name;
    lastRegisterEmail = email;
    lastRegisterPassword = password;
    return nextRegister ?? ('t2', AppUser(id: '2', email: email, name: name));
  }

  @override
  Future<void> logout() async {}

  @override
  Future<String?> currentToken() async => null;
}

class _StorageFake extends SecureStorageService {
  String? _jwt;
  int clearCalls = 0;

  @override
  Future<void> saveJwt(String token) async {
    _jwt = token;
  }

  @override
  Future<String?> readJwt() async => _jwt;

  @override
  Future<void> clear() async {
    clearCalls += 1;
    _jwt = null;
  }
}

void main() {
  group('AuthCubit', () {
    test('initial state is AuthInitial', () {
      final repoL = _AuthRepoFake();
      final repoR = _AuthRepoFake();
      final storage = _StorageFake();
      final cubit = AuthCubit(
        login: Login(repoL),
        registerUseCase: Register(repoR),
        storage: storage,
      );
      expect(cubit.state, isA<AuthInitial>());
      cubit.close();
    });

    blocTest<AuthCubit, AuthState>(
      'checkSession emits AuthAuthenticated when token exists',
      build: () {
        final repoL = _AuthRepoFake();
        final repoR = _AuthRepoFake();
        final storage = _StorageFake().._jwt = 'token';
        return AuthCubit(login: Login(repoL), registerUseCase: Register(repoR), storage: storage);
      },
      act: (cubit) => cubit.checkSession(),
      expect: () => [isA<AuthAuthenticated>()],
    );

    blocTest<AuthCubit, AuthState>(
      'checkSession emits AuthUnauthenticated when token is null',
      build: () {
        final repoL = _AuthRepoFake();
        final repoR = _AuthRepoFake();
        final storage = _StorageFake().._jwt = null;
        return AuthCubit(login: Login(repoL), registerUseCase: Register(repoR), storage: storage);
      },
      act: (cubit) => cubit.checkSession(),
      expect: () => [isA<AuthUnauthenticated>()],
    );

    blocTest<AuthCubit, AuthState>(
      'login emits loading then authenticated and calls repository',
      build: () {
        final repoL = _AuthRepoFake()
          ..nextLogin = ('tok', const AppUser(id: '10', email: 'a@x.com', name: 'Alice'));
        final repoR = _AuthRepoFake();
        final storage = _StorageFake();
        return AuthCubit(login: Login(repoL), registerUseCase: Register(repoR), storage: storage);
      },
      act: (cubit) => cubit.login(email: 'a@x.com', password: 'pw'),
      expect: () => [
        isA<AuthLoading>(),
        predicate<AuthState>((s) => s is AuthAuthenticated && s.user.id == '10' && s.user.email == 'a@x.com'),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'login emits failure then unauthenticated on error',
      build: () {
        final repoL = _AuthRepoFake()..loginError = StateError('x');
        final repoR = _AuthRepoFake();
        final storage = _StorageFake();
        return AuthCubit(login: Login(repoL), registerUseCase: Register(repoR), storage: storage);
      },
      act: (cubit) => cubit.login(email: 'z@z.com', password: 'pw'),
      expect: () => [
        isA<AuthLoading>(),
        predicate<AuthState>((s) => s is AuthFailure && s.message.startsWith('Login failed:')),
        isA<AuthUnauthenticated>(),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'register emits loading then authenticated and calls repository',
      build: () {
        final repoL = _AuthRepoFake();
        final repoR = _AuthRepoFake()
          ..nextRegister = ('tok2', const AppUser(id: '20', email: 'b@x.com', name: 'Bob'));
        final storage = _StorageFake();
        return AuthCubit(login: Login(repoL), registerUseCase: Register(repoR), storage: storage);
      },
      act: (cubit) => cubit.register(name: 'Bob', email: 'b@x.com', password: 'pw'),
      expect: () => [
        isA<AuthLoading>(),
        predicate<AuthState>((s) => s is AuthAuthenticated && s.user.id == '20' && s.user.name == 'Bob'),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'register emits failure then unauthenticated on error',
      build: () {
        final repoL = _AuthRepoFake();
        final repoR = _AuthRepoFake()..registerError = StateError('y');
        final storage = _StorageFake();
        return AuthCubit(login: Login(repoL), registerUseCase: Register(repoR), storage: storage);
      },
      act: (cubit) => cubit.register(name: 'X', email: 'x@x.com', password: 'pw'),
      expect: () => [
        isA<AuthLoading>(),
        predicate<AuthState>((s) => s is AuthFailure && s.message.startsWith('Register failed:')),
        isA<AuthUnauthenticated>(),
      ],
    );

    late _StorageFake storageRef;

    blocTest<AuthCubit, AuthState>(
      'logout clears storage and emits unauthenticated',
      build: () {
        final repoL = _AuthRepoFake();
        final repoR = _AuthRepoFake();
        storageRef = _StorageFake().._jwt = 't';
        return AuthCubit(login: Login(repoL), registerUseCase: Register(repoR), storage: storageRef);
      },
      act: (cubit) => cubit.logout(),
      expect: () => [isA<AuthUnauthenticated>()],
      verify: (_) async {
        expect(storageRef.clearCalls, 1);
        expect(await storageRef.readJwt(), isNull);
      },
    );
  });
}
