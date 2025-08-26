import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:tasky_clean_cubit/src/presenter/pages/task_dashboard_page.dart';
import 'package:tasky_clean_cubit/src/presenter/widgets/empty_state.dart';
import 'package:tasky_clean_cubit/src/presenter/widgets/status_filter_bar.dart';
import 'package:tasky_clean_cubit/src/presenter/widgets/task_card.dart';
import 'package:tasky_clean_cubit/src/presenter/cubits/task/task_cubit.dart';
import 'package:tasky_clean_cubit/src/presenter/cubits/task/task_state.dart' as s;
import 'package:tasky_clean_cubit/src/domain/entities/task.dart';
import 'package:tasky_clean_cubit/src/domain/repositories/task_repository.dart' as repo;
import 'package:tasky_clean_cubit/src/domain/usecases/create_task.dart';
import 'package:tasky_clean_cubit/src/domain/usecases/delete_task.dart';
import 'package:tasky_clean_cubit/src/domain/usecases/get_tasks.dart';
import 'package:tasky_clean_cubit/src/domain/usecases/toggle_complete.dart';
import 'package:tasky_clean_cubit/src/domain/usecases/update_task.dart';
import 'package:tasky_clean_cubit/src/domain/value_objects/task_status.dart';

class _RepoFake implements repo.TaskRepository {
  List<Task> store = <Task>[
    Task(
      id: '1',
      title: 'A',
      description: 'a',
      status: TaskStatus.pending,
      createdAt: DateTime(2025,),
    ),
    Task(
      id: '2',
      title: 'B',
      description: 'b',
      status: TaskStatus.inProgress,
      createdAt: DateTime(2025, 1, 2),
    ),
  ];

  @override
  Future<Task> byId(String id) async => store.firstWhere((e) => e.id == id);

  @override
  Future<Task> create({required String title, required String description, DateTime? dueDate}) async {
    final t = Task(
      id: 'new',
      title: title,
      description: description,
      status: TaskStatus.pending,
      createdAt: DateTime.now(),
      dueDate: dueDate,
    );
    store = [t, ...store];
    return t;
  }

  @override
  Future<void> delete(String id) async {
    store = store.where((e) => e.id != id).toList();
  }

  @override
  Future<List<Task>> list({repo.TaskFilter? filter}) async {
    Iterable<Task> r = store;
    if (filter?.status != null) {
      r = r.where((t) => t.status == filter!.status);
    }
    if (filter?.from != null) {
      r = r.where((t) => !t.createdAt.isBefore(filter!.from!));
    }
    if (filter?.to != null) {
      r = r.where((t) => !t.createdAt.isAfter(filter!.to!));
    }
    return r.toList();
  }

  @override
  Future<Task> toggleComplete(String id) async {
    final i = store.indexWhere((e) => e.id == id);
    final cur = store[i];
    final next = cur.copyWith(status: cur.status == TaskStatus.done ? TaskStatus.pending : TaskStatus.done);
    store[i] = next;
    return next;
  }

  @override
  Future<Task> update(Task task) async {
    final i = store.indexWhere((e) => e.id == task.id);
    if (i != -1) store[i] = task;
    return task;
  }
}

TaskCubit _buildCubit(_RepoFake repo) => TaskCubit(
      getTasks: GetTasks(repo),
      createTask: CreateTask(repo),
      updateTask: UpdateTask(repo),
      deleteTask: DeleteTask(repo),
      toggleComplete: ToggleComplete(repo),
    );

Widget _withRouter({required TaskCubit cubit}) {
  final router = GoRouter(
    initialLocation: '/tasks',
    routes: [
      GoRoute(
        path: '/tasks',
        builder: (context, _) => BlocProvider<TaskCubit>.value(
          value: cubit,
          child: const TaskDashboardPage(),
        ),
        routes: [
          GoRoute(
            path: ':id',
            builder: (context, state) => Scaffold(
              body: Center(child: Text('Detail ${state.pathParameters['id']}', textDirection: TextDirection.ltr)),
            ),
          ),
        ],
      ),
    ],
  );
  return MaterialApp.router(
    routeInformationProvider: router.routeInformationProvider,
    routeInformationParser: router.routeInformationParser,
    routerDelegate: router.routerDelegate,
  );
}

Future<void> _setSize(WidgetTester tester, Size size) async {
  tester.binding.window.physicalSizeTestValue = Size(size.width * 2, size.height * 2);
  tester.binding.window.devicePixelRatioTestValue = 2.0;
  addTearDown(() {
    tester.binding.window.clearPhysicalSizeTestValue();
    tester.binding.window.clearDevicePixelRatioTestValue();
  });
}

void main() {
  setUp(() async {
    await GetIt.instance.reset();
  });

  testWidgets('shows empty state when there are no items', (tester) async {
    final repo = _RepoFake()..store = <Task>[];
    final cubit = _buildCubit(repo);
    await tester.pumpWidget(_withRouter(cubit: cubit));
    await tester.pumpAndSettle();
    expect(find.byType(EmptyState), findsOneWidget);
  });

  testWidgets('renders list on narrow screens and allows swipe to delete', (tester) async {
    await _setSize(tester, const Size(400, 800));
    final repo = _RepoFake();
    final cubit = _buildCubit(repo);
    cubit.emit(const s.TaskState(status: s.TaskStatusUI.success));
    await tester.pumpWidget(_withRouter(cubit: cubit));
    cubit.emit(s.TaskState(items: repo.store, status: s.TaskStatusUI.success));
    await tester.pump();

    expect(find.byType(ListView), findsOneWidget);
    expect(find.byType(TaskCard), findsNWidgets(2));

    await tester.drag(find.byType(TaskCard).first, const Offset(-600, 0));
    await tester.pumpAndSettle();

    expect(repo.store.length, 1);
  });

  testWidgets('renders grid on wide screens', (tester) async {
    await _setSize(tester, const Size(1200, 900));
    final repo = _RepoFake();
    final cubit = _buildCubit(repo);
    cubit.emit(s.TaskState(items: repo.store, status: s.TaskStatusUI.success));
    await tester.pumpWidget(_withRouter(cubit: cubit));
    await tester.pump();
    expect(find.byType(GridView), findsOneWidget);
    expect(find.byType(TaskCard), findsNWidgets(2));
  });

  testWidgets('All filter resets status and reloads', (tester) async {
    final repo = _RepoFake();
    final cubit = _buildCubit(repo);
    cubit.emit(s.TaskState(items: repo.store, status: s.TaskStatusUI.success, filterStatus: TaskStatus.done));
    await tester.pumpWidget(_withRouter(cubit: cubit));
    await tester.pump();

    final bar = tester.widget<StatusFilterBar>(find.byType(StatusFilterBar));
    bar.onChanged(null);
    await tester.pump();

    expect(cubit.state.filterStatus, isNull);
  });

  testWidgets('Reload FAB triggers reload flow', (tester) async {
    final repo = _RepoFake();
    final cubit = _buildCubit(repo);
    cubit.emit(s.TaskState(items: repo.store, status: s.TaskStatusUI.success));
    await tester.pumpWidget(_withRouter(cubit: cubit));
    await tester.pump();

    await tester.tap(find.text('Reload'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.byType(TaskCard), findsWidgets);
  });

  testWidgets('Add Task opens dialog, creates and navigates to detail', (tester) async {
    final repo = _RepoFake();
    final cubit = _buildCubit(repo);
    cubit.emit(s.TaskState(items: repo.store, status: s.TaskStatusUI.success));
    await tester.pumpWidget(_withRouter(cubit: cubit));
    await tester.pump();

    await tester.tap(find.text('Add Task'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), 'New title');
    await tester.enterText(find.byType(TextField).at(1), 'New desc');
    await tester.tap(find.text('Create'));
    await tester.pumpAndSettle();

    expect(find.text('Detail new'), findsOneWidget);
  });
}
