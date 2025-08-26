import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:tasky_clean_cubit/src/core/di/injection.dart';
import 'package:tasky_clean_cubit/src/core/services/secure_storage_service.dart';
import 'package:tasky_clean_cubit/src/data/datasources/mock_api.dart';
import 'package:tasky_clean_cubit/src/data/repositories/auth_repository_impl.dart';
import 'package:tasky_clean_cubit/src/data/repositories/task_repository_impl.dart';
import 'package:tasky_clean_cubit/src/domain/repositories/auth_repository.dart';
import 'package:tasky_clean_cubit/src/domain/repositories/task_repository.dart';
import 'package:tasky_clean_cubit/src/domain/usecases/create_task.dart';
import 'package:tasky_clean_cubit/src/domain/usecases/delete_task.dart';
import 'package:tasky_clean_cubit/src/domain/usecases/get_tasks.dart';
import 'package:tasky_clean_cubit/src/domain/usecases/login.dart';
import 'package:tasky_clean_cubit/src/domain/usecases/register.dart';
import 'package:tasky_clean_cubit/src/domain/usecases/toggle_complete.dart';
import 'package:tasky_clean_cubit/src/domain/usecases/update_task.dart';
import 'package:tasky_clean_cubit/src/presenter/cubits/auth/auth_cubit.dart';
import 'package:tasky_clean_cubit/src/presenter/cubits/task/task_cubit.dart';

void main() {
  final di = GetIt.instance;

  setUp(() async {
    await di.reset();
    await Injection.init();
  });

  tearDown(() async {
    await di.reset();
  });

  test('registers core singletons', () {
    expect(di.isRegistered<SecureStorageService>(), isTrue);
    expect(di.isRegistered<MockApi>(), isTrue);

    final s1 = di<SecureStorageService>();
    final s2 = di<SecureStorageService>();
    expect(identical(s1, s2), isTrue);

    final a1 = di<MockApi>();
    final a2 = di<MockApi>();
    expect(identical(a1, a2), isTrue);
  });

  test('registers repositories with correct types and lifetimes', () {
    expect(di.isRegistered<AuthRepository>(), isTrue);
    expect(di.isRegistered<TaskRepository>(), isTrue);

    final authRepo = di<AuthRepository>();
    final taskRepo = di<TaskRepository>();
    expect(authRepo, isA<AuthRepositoryImpl>());
    expect(taskRepo, isA<TaskRepositoryImpl>());

    final authRepo2 = di<AuthRepository>();
    final taskRepo2 = di<TaskRepository>();
    expect(identical(authRepo, authRepo2), isTrue);
    expect(identical(taskRepo, taskRepo2), isTrue);
  });

  test('registers use cases as factories', () {
    expect(di.isRegistered<Login>(), isTrue);
    expect(di.isRegistered<Register>(), isTrue);
    expect(di.isRegistered<GetTasks>(), isTrue);
    expect(di.isRegistered<CreateTask>(), isTrue);
    expect(di.isRegistered<UpdateTask>(), isTrue);
    expect(di.isRegistered<DeleteTask>(), isTrue);
    expect(di.isRegistered<ToggleComplete>(), isTrue);

    final u1a = di<Login>();
    final u1b = di<Login>();
    expect(identical(u1a, u1b), isFalse);

    final u2a = di<GetTasks>();
    final u2b = di<GetTasks>();
    expect(identical(u2a, u2b), isFalse);
  });

  test('registers cubits with expected lifetimes', () {
    expect(di.isRegistered<AuthCubit>(), isTrue);
    expect(di.isRegistered<TaskCubit>(), isTrue);

    final authA = di<AuthCubit>();
    final authB = di<AuthCubit>();
    expect(identical(authA, authB), isTrue);

    final taskA = di<TaskCubit>();
    final taskB = di<TaskCubit>();
    expect(identical(taskA, taskB), isFalse);
  });
}
