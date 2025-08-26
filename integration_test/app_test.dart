import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:get_it/get_it.dart';

import 'package:tasky_clean_cubit/src/core/di/injection.dart';
import 'package:tasky_clean_cubit/src/core/services/secure_storage_service.dart';
import 'package:tasky_clean_cubit/src/router/app_router.dart';

class _FakeStorage extends SecureStorageService {
  String? _token;
  @override
  Future<void> saveJwt(String token) async => _token = token;

  @override
  Future<String?> readJwt() async => _token;

  @override
  Future<void> clear() async => _token = null;
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
      'email validation + basic navigation (login -> list -> add -> back)',
      (tester) async {
   
    await Injection.init();
    final getIt = GetIt.instance;
    if (getIt.isRegistered<SecureStorageService>()) {
      getIt.unregister<SecureStorageService>();
    }
    getIt.registerLazySingleton<SecureStorageService>(_FakeStorage.new);

    final router = createRouter();
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'john');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'), '123456');
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    expect(find.text('Your Tasks'), findsNothing);
    expect(find.text('Login'), findsOneWidget);

    await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'), 'john@dev.com');
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    expect(find.text('Your Tasks'), findsOneWidget);

    final addTaskBtn = find.text('Add Task');
    expect(addTaskBtn, findsOneWidget);
    await tester.tap(addTaskBtn);
    await tester.pumpAndSettle();

    expect(find.widgetWithText(FilledButton, 'Create'), findsOneWidget);

    final scaffold = find.byType(Scaffold).first;
    final ctx = tester.element(scaffold);
    await Navigator.of(ctx).maybePop();
    await tester.pumpAndSettle();

    expect(find.text('Your Tasks'), findsOneWidget);
  });
}
