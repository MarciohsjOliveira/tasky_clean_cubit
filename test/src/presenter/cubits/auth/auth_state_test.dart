import 'package:flutter_test/flutter_test.dart';
import 'package:tasky_clean_cubit/src/domain/entities/user.dart';
import 'package:tasky_clean_cubit/src/presenter/cubits/auth/auth_state.dart';

void main() {
  group('AuthState', () {
    test('AuthInitial value equality and empty props', () {
      final a = AuthInitial();
      final b = AuthInitial();

      expect(a, b);
      expect(a.props, isEmpty);
    });

    test('AuthLoading value equality and empty props', () {
      final a = AuthLoading();
      final b = AuthLoading();

      expect(a, b);
      expect(a.props, isEmpty);
    });

    test('AuthUnauthenticated value equality and empty props', () {
      final a = AuthUnauthenticated();
      final b = AuthUnauthenticated();

      expect(a, b);
      expect(a.props, isEmpty);
    });

    test('AuthAuthenticated holds user and compares by user', () {
      const u1 = AppUser(id: '1', email: 'a@x.com', name: 'Alice');
      const u2 = AppUser(id: '1', email: 'a@x.com', name: 'Alice');
      const u3 = AppUser(id: '2', email: 'b@x.com', name: 'Bob');

      const s1 = AuthAuthenticated(u1);
      const s2 = AuthAuthenticated(u2);
      const s3 = AuthAuthenticated(u3);

      expect(s1, s2);
      expect(s1 == s3, isFalse);
      expect(s1.props.length, 1);
      expect(s1.props.first, u1);
    });

    test('AuthFailure holds message and compares by message', () {
      const s1 = AuthFailure('oops');
      const s2 = AuthFailure('oops');
      const s3 = AuthFailure('different');

      expect(s1, s2);
      expect(s1 == s3, isFalse);
      expect(s1.props.length, 1);
      expect(s1.props.first, 'oops');
    });
  });
}
