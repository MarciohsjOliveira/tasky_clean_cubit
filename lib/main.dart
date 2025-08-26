import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'src/core/di/injection.dart';
import 'src/router/app_router.dart';
import 'src/presenter/cubits/auth/auth_cubit.dart';
import 'src/presenter/cubits/task/task_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Injection.init();
  runApp(const TaskyApp());
}

class TaskyApp extends StatelessWidget {
  const TaskyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = createRouter();
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<AuthCubit>()..checkSession()),
        BlocProvider(create: (_) => getIt<TaskCubit>()..load()),
      ],
      child: MaterialApp.router(
        title: 'Tasky Clean Cubit',
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: Colors.indigo,
          snackBarTheme:
              const SnackBarThemeData(behavior: SnackBarBehavior.floating),
        ),
        routerConfig: router,
      ),
    );
  }
}
