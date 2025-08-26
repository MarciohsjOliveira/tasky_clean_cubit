import 'package:flutter_test/flutter_test.dart';
import 'package:tasky_clean_cubit/src/domain/entities/user.dart';

void main() {
  group('AppUser', () {
    const u1 = AppUser(id: '1', email: 'a@x.com', name: 'Alice');
    const u2 = AppUser(id: '1', email: 'a@x.com', name: 'Alice');
    const u3 = AppUser(id: '2', email: 'b@x.com', name: 'Bob');

    test('supports value equality', () {
      expect(u1, equals(u2));
      expect(u1 == u3, isFalse);
    });

    test('props contains all fields in order', () {
      expect(u1.props, ['1', 'a@x.com', 'Alice']);
    });
  });
}
