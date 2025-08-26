import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class Login {
  const Login(this._repo);
  final AuthRepository _repo;
  Future<(String token, AppUser user)> call({
    required String email,
    required String password,
  }) {
    return _repo.login(
      email: email,
      password: password,
    );
  }
}
