import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasky_clean_cubit/src/presenter/pages/register_page.dart';
import 'package:tasky_clean_cubit/src/presenter/cubits/auth/auth_cubit.dart';
import 'package:tasky_clean_cubit/src/presenter/cubits/auth/auth_state.dart';
import 'package:tasky_clean_cubit/src/domain/entities/user.dart';
import 'package:tasky_clean_cubit/src/presenter/widgets/loading_overlay.dart';

final getIt = GetIt.instance;

class _AuthCubitFake extends Cubit<AuthState> implements AuthCubit {
  _AuthCubitFake(super.initial);

  String? lastName;
  String? lastEmail;
  String? lastPassword;

  @override
  Future<void> checkSession() async {}

  @override
  Future<void> login({required String email, required String password}) async {}

  @override
  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    lastName = name;
    lastEmail = email;
    lastPassword = password;
  }

  @override
  Future<void> logout() async {}
}

class _DummyPage extends StatelessWidget {
  const _DummyPage(this.label);
  final String label;
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text(label, textDirection: TextDirection.ltr)));
  }
}

GoRouter _router() {
  return GoRouter(
    initialLocation: '/register',
    routes: [
      GoRoute(path: '/register', builder: (_, __) => const RegisterPage()),
      GoRoute(path: '/tasks', builder: (_, __) => const _DummyPage('Tasks')),
      GoRoute(path: '/login', builder: (_, __) => const _DummyPage('Login')),
    ],
  );
}

Widget _app(GoRouter router, _AuthCubitFake auth) {
  return BlocProvider<AuthCubit>.value(
    value: auth,
    child: MaterialApp.router(
      routeInformationProvider: router.routeInformationProvider,
      routeInformationParser: router.routeInformationParser,
      routerDelegate: router.routerDelegate,
    ),
  );
}

void main() {
  setUp(() async {
    await getIt.reset();
    getIt.registerSingleton<AuthCubit>(_AuthCubitFake(AuthUnauthenticated()));
  });

  testWidgets('renders UI elements', (tester) async {
    final auth = getIt<AuthCubit>() as _AuthCubitFake;
    final router = _router();
    await tester.pumpWidget(_app(router, auth));
    await tester.pumpAndSettle();

    expect(find.text('Register'), findsOneWidget);
    expect(find.text('Name'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Create account'), findsOneWidget);
  });

  testWidgets('validation shows errors for invalid fields', (tester) async {
    final auth = getIt<AuthCubit>() as _AuthCubitFake;
    final router = _router();
    await tester.pumpWidget(_app(router, auth));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Create account'));
    await tester.pump();

    expect(find.text('Required'), findsOneWidget);
    expect(find.text('Provide a valid email'), findsOneWidget);
    expect(find.text('Min 6 chars'), findsOneWidget);
    expect(auth.lastEmail, isNull);
    expect(auth.lastPassword, isNull);
  });

  testWidgets('calls register with valid data', (tester) async {
    final auth = getIt<AuthCubit>() as _AuthCubitFake;
    final router = _router();
    await tester.pumpWidget(_app(router, auth));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'John');
    await tester.enterText(find.byType(TextFormField).at(1), 'john@dev.io');
    await tester.enterText(find.byType(TextFormField).at(2), '123456');
    await tester.tap(find.text('Create account'));
    await tester.pump();

    expect(auth.lastName, 'John');
    expect(auth.lastEmail, 'john@dev.io');
    expect(auth.lastPassword, '123456');
  });

  testWidgets('shows loading overlay when AuthLoading', (tester) async {
    final auth = getIt<AuthCubit>() as _AuthCubitFake;
    final router = _router();
    await tester.pumpWidget(_app(router, auth));
    await tester.pumpAndSettle();

    auth.emit(AuthLoading());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    final overlays = tester.widgetList<LoadingOverlay>(find.byType(LoadingOverlay)).toList();
    expect(overlays, isNotEmpty);
    expect(overlays.last.visible, isTrue);
  });

  testWidgets('shows SnackBar on AuthFailure', (tester) async {
    final auth = getIt<AuthCubit>() as _AuthCubitFake;
    final router = _router();
    await tester.pumpWidget(_app(router, auth));
    await tester.pumpAndSettle();

    auth.emit(const AuthFailure('Register failed: boom'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Register failed: boom'), findsOneWidget);
  });

  testWidgets('navigates to /tasks and shows welcome SnackBar on AuthAuthenticated', (tester) async {
    final auth = getIt<AuthCubit>() as _AuthCubitFake;
    final router = _router();
    await tester.pumpWidget(_app(router, auth));
    await tester.pumpAndSettle();

    auth.emit(const AuthAuthenticated(AppUser(id: '1', email: 'a@b.c', name: 'A')));
    await tester.pumpAndSettle();

    expect(find.text('Tasks'), findsOneWidget);
    expect(find.text('Welcome!'), findsOneWidget);
  });
}
