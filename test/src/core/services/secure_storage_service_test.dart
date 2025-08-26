import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tasky_clean_cubit/src/core/constants.dart';
import 'package:tasky_clean_cubit/src/core/services/secure_storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
  final store = <String, String?>{};

  setUp(() {
    store.clear();
    channel.setMockMethodCallHandler((MethodCall call) async {
      final args = (call.arguments as Map?)?.cast<String, dynamic>() ?? {};
      switch (call.method) {
        case 'write':
          store[args['key'] as String] = args['value'] as String?;
          return null;
        case 'read':
          return store[args['key'] as String];
        case 'delete':
          store.remove(args['key'] as String);
          return null;
        case 'containsKey':
          return store.containsKey(args['key'] as String);
        case 'readAll':
          return Map<String, String?>.from(store);
        case 'deleteAll':
          store.clear();
          return null;
        default:
          return null;
      }
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  group('SecureStorageService', () {
    test('saveJwt then readJwt returns same value', () async {
      final svc = SecureStorageService();

      await svc.saveJwt('token-123');
      final read = await svc.readJwt();

      expect(read, 'token-123');
      expect(store.containsKey(AppKeys.jwt), isTrue);
    });

    test('clear removes the stored token', () async {
      final svc = SecureStorageService();

      await svc.saveJwt('x');
      await svc.clear();
      final read = await svc.readJwt();

      expect(read, isNull);
      expect(store.containsKey(AppKeys.jwt), isFalse);
    });

    test('readJwt returns null when nothing stored', () async {
      final svc = SecureStorageService();

      final read = await svc.readJwt();

      expect(read, isNull);
    });
  });
}
