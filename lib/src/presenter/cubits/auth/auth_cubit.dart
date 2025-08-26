import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/services/secure_storage_service.dart';
import '../../../domain/usecases/login.dart';
import '../../../domain/usecases/register.dart';
import '../../../domain/entities/user.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(
      {required Login login,
      required Register registerUseCase,
      required SecureStorageService storage})
      : _login = login,
        _register = registerUseCase,
        _storage = storage,
        super(AuthInitial());

  final Login _login;
  final Register _register;
  final SecureStorageService _storage;

  Future<void> checkSession() async {
    final token = await _storage.readJwt();
    if (token != null) {
      emit(
        const AuthAuthenticated(
          AppUser(id: 'me', email: 'me@mock.dev', name: 'Mock User'),
        ),
      );
    } else {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    emit(AuthLoading());
    try {
      final resp = await _login(email: email, password: password);
      emit(AuthAuthenticated(resp.$2));
    } catch (e) {
      emit(AuthFailure('Login failed: $e'));
      emit(AuthUnauthenticated());
    }
  }

  Future<void> register(
      {required String name,
      required String email,
      required String password}) async {
    emit(AuthLoading());
    try {
      final resp = await _register(
        name: name,
        email: email,
        password: password,
      );
      emit(AuthAuthenticated(resp.$2));
    } catch (e) {
      emit(AuthFailure('Register failed: $e'));
      emit(AuthUnauthenticated());
    }
  }

  Future<void> logout() async {
    await _storage.clear();
    emit(AuthUnauthenticated());
  }
}
