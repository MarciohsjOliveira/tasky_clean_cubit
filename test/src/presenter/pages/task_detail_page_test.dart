import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasky_clean_cubit/src/presenter/pages/task_detail_page.dart';
import 'package:tasky_clean_cubit/src/presenter/cubits/task/task_cubit.dart';
import 'package:tasky_clean_cubit/src/presenter/cubits/task/task_state.dart'
    as s;
import 'package:tasky_clean_cubit/src/domain/entities/task.dart';
import 'package:tasky_clean_cubit/src/domain/value_objects/task_status.dart';
import 'package:tasky_clean_cubit/src/domain/repositories/task_repository.dart'
    as repo;
import 'package:tasky_clean_cubit/src/domain/usecases/create_task.dart';
import 'package:tasky_clean_cubit/src/domain/usecases/delete_task.dart';
import 'package:tasky_clean_cubit/src/domain/usecases/get_tasks.dart';
import 'package:tasky_clean_cubit/src/domain/usecases/toggle_complete.dart';
import 'package:tasky_clean_cubit/src/domain/usecases/update_task.dart';

class _RepoFake implements repo.TaskRepository {
  List<Task> store = <Task>[
    Task(
      id: 't1',
      title: 'Title 1',
      description: 'Desc 1',
      status: TaskStatus.pending,
      createdAt: DateTime(
        2025,
      ),
    ),
    Task(
      id: 't2',
      title: 'Title 2',
      description: 'Desc 2',
      status: TaskStatus.inProgress,
      createdAt: DateTime(2025, 1, 2),
    ),
  ];

  @override
  Future<Task> byId(String id) async => store.firstWhere((e) => e.id == id);

  @override
  Future<Task> create(
      {required String title,
      required String description,
      DateTime? dueDate}) async {
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
    final next = cur.copyWith(
        status: cur.status == TaskStatus.done
            ? TaskStatus.pending
            : TaskStatus.done);
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

Widget _wrapDirect(TaskCubit cubit, Widget child) {
  return MaterialApp(
    home: Scaffold(
      body: BlocProvider<TaskCubit>.value(
        value: cubit,
        child: child,
      ),
    ),
  );
}

Widget _wrapWithPush(TaskCubit cubit, Widget page) {
  return MaterialApp(
    home: Scaffold(
      body: Builder(
        builder: (ctx) => Center(
          child: ElevatedButton(
            onPressed: () => Navigator.of(ctx).push(
              MaterialPageRoute(
                builder: (_) => BlocProvider<TaskCubit>.value(
                  value: cubit,
                  child: page,
                ),
              ),
            ),
            child: const Text('go'),
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('shows not found and back button pops', (tester) async {
    final repo = _RepoFake()..store = <Task>[];
    final cubit = _buildCubit(repo);
    await tester.pumpWidget(_wrapWithPush(
        cubit,
        const TaskDetailPage(
          taskId: 'absent',
        )));
    await tester.tap(find.text('go'));
    await tester.pumpAndSettle();
    expect(find.text('Task not found'), findsOneWidget);
    await tester.tap(find.text('Back'));
    await tester.pumpAndSettle();
    expect(find.text('Task not found'), findsNothing);
  });

  testWidgets('prefills fields and saves with updated values and status',
      (tester) async {
    final repo = _RepoFake();
    final cubit = _buildCubit(repo);
    cubit.emit(s.TaskState(items: repo.store, status: s.TaskStatusUI.success));
    await tester.pumpWidget(_wrapDirect(
        cubit,
        const TaskDetailPage(
          taskId: 't1',
        )));
    await tester.pump();

    final titleField = find.byType(TextField).at(0);
    final descField = find.byType(TextField).at(1);
    final dd = find.byType(DropdownButtonFormField<TaskStatus>);

    expect(
        tester.widget<TextField>(titleField).controller?.text ?? '', 'Title 1');
    expect(
        tester.widget<TextField>(descField).controller?.text ?? '', 'Desc 1');

    await tester.enterText(titleField, 'Edited Title');
    await tester.enterText(descField, 'Edited Desc');
    await tester.tap(dd);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Done').last);
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Save'));
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    final updated = repo.store.firstWhere((e) => e.id == 't1');
    expect(updated.title, 'Edited Title');
    expect(updated.description, 'Edited Desc');
    expect(updated.status, TaskStatus.done);
    expect(find.text('Task updated'), findsOneWidget);
  });

  testWidgets('deletes and pops, shows SnackBar on previous route',
      (tester) async {
    final repo = _RepoFake();
    final cubit = _buildCubit(repo);
    cubit.emit(s.TaskState(items: repo.store, status: s.TaskStatusUI.success));
    await tester.pumpWidget(_wrapWithPush(
        cubit,
        const TaskDetailPage(
          taskId: 't2',
        )));
    await tester.tap(find.text('go'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Delete'));
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(repo.store.any((e) => e.id == 't2'), isFalse);
    expect(find.text('Task deleted'), findsOneWidget);
    expect(find.byType(TaskDetailPage), findsNothing);
  });

  testWidgets('uses provided extra task even if state does not contain it',
      (tester) async {
    final repo = _RepoFake()..store = <Task>[];
    final cubit = _buildCubit(repo);
    cubit.emit(const s.TaskState(status: s.TaskStatusUI.success));
    final extra = Task(
      id: 'x1',
      title: 'External',
      description: 'From extra',
      status: TaskStatus.pending,
      createdAt: DateTime(2025, 2),
    );
    await tester.pumpWidget(_wrapDirect(
        cubit,
        TaskDetailPage(
          taskId: 'x1',
          task: extra,
        )));
    await tester.pump();

    final titleField = find.byType(TextField).first;
    expect(tester.widget<TextField>(titleField).controller?.text ?? '',
        'External');
  });
}
