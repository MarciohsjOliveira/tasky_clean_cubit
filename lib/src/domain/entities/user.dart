import 'package:equatable/equatable.dart';

class AppUser extends Equatable {
  const AppUser({
    required this.id,
    required this.email,
    required this.name,
  });
  final String id;
  final String email;
  final String name;
  @override
  List<Object?> get props => [
        id,
        email,
        name,
      ];
}
