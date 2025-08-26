import 'package:get_it/get_it.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/task_repository_impl.dart';
import '../../data/datasources/mock_api.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/task_repository.dart';
import '../../domain/usecases/login.dart';
import '../../domain/usecases/register.dart';
import '../../domain/usecases/get_tasks.dart';
import '../../domain/usecases/create_task.dart';
import '../../domain/usecases/update_task.dart';
import '../../domain/usecases/delete_task.dart';
import '../../domain/usecases/toggle_complete.dart';
import '../../presenter/cubits/auth/auth_cubit.dart';
import '../../presenter/cubits/task/task_cubit.dart';
import '../services/secure_storage_service.dart';

final getIt = GetIt.instance;

class Injection {
  static Future<void> init() async {
    getIt.registerLazySingleton<SecureStorageService>(SecureStorageService.new);
    getIt.registerLazySingleton<MockApi>(MockApi.new);

    getIt
      ..registerLazySingleton<AuthRepository>(
          () => AuthRepositoryImpl(api: getIt(), storage: getIt()))
      ..registerLazySingleton<TaskRepository>(
          () => TaskRepositoryImpl(api: getIt()))
      ..registerFactory(() => Login(getIt()))
      ..registerFactory(() => Register(getIt()))
      ..registerFactory(() => GetTasks(getIt()))
      ..registerFactory(() => CreateTask(getIt()))
      ..registerFactory(() => UpdateTask(getIt()))
      ..registerFactory(() => DeleteTask(getIt()))
      ..registerFactory(() => ToggleComplete(getIt()))
      ..registerLazySingleton<AuthCubit>(() =>
          AuthCubit(login: getIt(), registerUseCase: getIt(), storage: getIt()))
      ..registerFactory(() => TaskCubit(
            getTasks: getIt(),
            createTask: getIt(),
            updateTask: getIt(),
            deleteTask: getIt(),
            toggleComplete: getIt(),
          ));
  }
}
