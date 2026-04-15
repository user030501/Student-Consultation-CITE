import 'package:flutter_test/flutter_test.dart';
import 'package:namer_app/models/user.dart';

void main() {
  group('User', () {
    test('serializes to JSON', () {
      final user = User(
        username: 'stephen',
        role: 'Admin',
        passwordHash: 'hashed-password',
      );

      expect(user.toJson(), {
        'username': 'stephen',
        'role': 'Admin',
        'passwordHash': 'hashed-password',
      });
    });

    test('deserializes from JSON', () {
      final user = User.fromJson({
        'username': 'stephen',
        'role': 'Adviser',
        'passwordHash': 'secret-hash',
      });

      expect(user.username, 'stephen');
      expect(user.role, 'Adviser');
      expect(user.passwordHash, 'secret-hash');
    });
  });
}
