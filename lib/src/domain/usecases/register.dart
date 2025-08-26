import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class Register {
  const Register(this._repo);
  final AuthRepository _repo;
  Future<(String token, AppUser user)> call({
    required String name,
    required String email,
    required String password,
  }) {
    return _repo.register(
      name: name,
      email: email,
      password: password,
    );
  }
}
