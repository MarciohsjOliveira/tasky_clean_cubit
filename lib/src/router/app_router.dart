import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../core/di/injection.dart';
import 'router_refresh.dart';
import '../presenter/cubits/auth/auth_cubit.dart';
import '../presenter/cubits/auth/auth_state.dart';
import '../presenter/cubits/task/task_cubit.dart';
import '../presenter/pages/login_page.dart';
import '../presenter/pages/register_page.dart';
import '../presenter/pages/task_dashboard_page.dart';
import '../presenter/pages/task_detail_page.dart';
import '../domain/entities/task.dart';

GoRouter createRouter() {
  final authCubit = getIt<AuthCubit>();

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: StreamRefreshListenable(authCubit.stream),
    redirect: (context, state) {
      final isLogged = authCubit.state is AuthAuthenticated;
      final loc = state.uri.toString();
      final loggingIn = loc.startsWith('/login') || loc.startsWith('/register');
      if (!isLogged && !loggingIn) return '/login';
      if (isLogged && loggingIn) return '/tasks';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, __) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, __) => const RegisterPage(),
      ),

      // Mantém um único Provider<TaskCubit> para a lista e o detalhe
      ShellRoute(
        builder: (context, state, child) => BlocProvider<TaskCubit>(
          create: (_) => getIt<TaskCubit>()..load(),
          child: child,
        ),
        routes: [
          GoRoute(
            path: '/tasks',
            builder: (context, __) => const TaskDashboardPage(),
            routes: [
              GoRoute(
                path: ':id',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  final extra = state.extra;
                  final task = extra is Task ? extra : null;
                  return TaskDetailPage(taskId: id, task: task);
                },
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
