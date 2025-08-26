import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tasky_clean_cubit/src/domain/entities/task.dart';
import 'package:tasky_clean_cubit/src/domain/repositories/task_repository.dart' as repo;
import 'package:tasky_clean_cubit/src/domain/usecases/create_task.dart';
import 'package:tasky_clean_cubit/src/domain/usecases/delete_task.dart';
import 'package:tasky_clean_cubit/src/domain/usecases/get_tasks.dart';
import 'package:tasky_clean_cubit/src/domain/usecases/toggle_complete.dart';
import 'package:tasky_clean_cubit/src/domain/usecases/update_task.dart';
import 'package:tasky_clean_cubit/src/domain/value_objects/task_status.dart';
import 'package:tasky_clean_cubit/src/presenter/cubits/task/task_cubit.dart';
import 'package:tasky_clean_cubit/src/presenter/cubits/task/task_state.dart' as s;

class _RepoFake implements repo.TaskRepository {
  _RepoFake({
    List<Task>? seed,
  }) : _tasks = List<Task>.from(seed ?? <Task>[
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
          Task(
            id: '3',
            title: 'C',
            description: 'c',
            status: TaskStatus.done,
            createdAt: DateTime(2025, 1, 3),
          ),
        ]);

  final List<Task> _tasks;

  bool throwOnList = false;
  bool throwOnCreate = false;
  bool throwOnDelete = false;
  bool throwOnUpdate = false;
  bool throwOnToggle = false;

  int listCalls = 0;
  repo.TaskFilter? lastFilter;

  @override
  Future<Task> byId(String id) async {
    return _tasks.firstWhere((e) => e.id == id);
  }

  @override
  Future<Task> create({
    required String title,
    required String description,
    DateTime? dueDate,
  }) async {
    if (throwOnCreate) throw StateError('create');
    final t = Task(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title,
      description: description,
      status: TaskStatus.pending,
      createdAt: DateTime.now(),
      dueDate: dueDate,
    );
    _tasks.insert(0, t);
    return t;
  }

  @override
  Future<void> delete(String id) async {
    if (throwOnDelete) throw StateError('delete');
    _tasks.removeWhere((e) => e.id == id);
  }

  @override
  Future<List<Task>> list({repo.TaskFilter? filter}) async {
    if (throwOnList) throw StateError('list');
    listCalls += 1;
    lastFilter = filter;
    final status = filter?.status;
    final from = filter?.from;
    final to = filter?.to;
    return _tasks.where((t) {
      final sOk = status == null || t.status == status;
      final fOk = from == null || !t.createdAt.isBefore(from);
      final tOk = to == null || !t.createdAt.isAfter(to);
      return sOk && fOk && tOk;
    }).toList();
  }

  @override
  Future<Task> toggleComplete(String id) async {
    if (throwOnToggle) throw StateError('toggle');
    final idx = _tasks.indexWhere((e) => e.id == id);
    if (idx == -1) throw StateError('not found');
    final cur = _tasks[idx];
    final next = cur.copyWith(
      status: cur.status == TaskStatus.done ? TaskStatus.pending : TaskStatus.done,
      updatedAt: DateTime.now(),
    );
    _tasks[idx] = next;
    return next;
  }

  @override
  Future<Task> update(Task task) async {
    if (throwOnUpdate) throw StateError('update');
    final idx = _tasks.indexWhere((e) => e.id == task.id);
    if (idx == -1) throw StateError('not found');
    final updated = task.copyWith(updatedAt: DateTime.now());
    _tasks[idx] = updated;
    return updated;
  }
}

TaskCubit _buildCubit(_RepoFake repo) {
  return TaskCubit(
    getTasks: GetTasks(repo),
    createTask: CreateTask(repo),
    updateTask: UpdateTask(repo),
    deleteTask: DeleteTask(repo),
    toggleComplete: ToggleComplete(repo),
  );
}

void main() {
  group('TaskCubit', () {
    test('initial state', () {
      final cubit = _buildCubit(_RepoFake());
      expect(cubit.state, const s.TaskState());
      cubit.close();
    });

    blocTest<TaskCubit, s.TaskState>(
      'load without filters emits loading then success with all items',
      build: () => _buildCubit(_RepoFake()),
      act: (cubit) => cubit.load(),
      expect: () => [
        predicate<s.TaskState>((st) =>
            st.status == s.TaskStatusUI.loading &&
            st.filterStatus == null &&
            st.from == null &&
            st.to == null),
        predicate<s.TaskState>((st) =>
            st.status == s.TaskStatusUI.success && st.items.length == 3),
      ],
    );

    blocTest<TaskCubit, s.TaskState>(
      'load with status filter emits loading with filter then success filtered',
      build: () => _buildCubit(_RepoFake()),
      act: (cubit) => cubit.load(status: TaskStatus.pending),
      expect: () => [
        predicate<s.TaskState>((st) =>
            st.status == s.TaskStatusUI.loading &&
            st.filterStatus == TaskStatus.pending),
        predicate<s.TaskState>((st) =>
            st.status == s.TaskStatusUI.success &&
            st.items.every((t) => t.status == TaskStatus.pending)),
      ],
    );

    blocTest<TaskCubit, s.TaskState>(
      'load failure emits failure',
      build: () {
        final r = _RepoFake()..throwOnList = true;
        return _buildCubit(r);
      },
      act: (cubit) => cubit.load(),
      expect: () => [
        predicate<s.TaskState>((st) => st.status == s.TaskStatusUI.loading),
        predicate<s.TaskState>((st) => st.status == s.TaskStatusUI.failure && st.errorMessage != null),
      ],
    );

   

    blocTest<TaskCubit, s.TaskState>(
      'create emits local insert then reloads to success',
      build: () => _buildCubit(_RepoFake()),
      act: (cubit) async {
        await cubit.load();
        await cubit.create(title: 'New', description: 'desc');
      },
      expect: () => [
        predicate<s.TaskState>((st) => st.status == s.TaskStatusUI.loading),
        predicate<s.TaskState>((st) => st.status == s.TaskStatusUI.success && st.items.length == 3),
        predicate<s.TaskState>((st) => st.items.length == 4),
        predicate<s.TaskState>((st) => st.status == s.TaskStatusUI.loading),
        predicate<s.TaskState>((st) => st.status == s.TaskStatusUI.success && st.items.length == 4),
      ],
    );

    blocTest<TaskCubit, s.TaskState>(
      'create failure sets errorMessage but does not crash',
      build: () {
        final r = _RepoFake()..throwOnCreate = true;
        return _buildCubit(r);
      },
      act: (cubit) async {
        await cubit.load();
        await cubit.create(title: 'X', description: 'Y');
      },
      expect: () => [
        predicate<s.TaskState>((st) => st.status == s.TaskStatusUI.loading),
        predicate<s.TaskState>((st) => st.status == s.TaskStatusUI.success),
        predicate<s.TaskState>((st) => st.errorMessage?.startsWith('Create failed:') == true),
      ],
    );

    blocTest<TaskCubit, s.TaskState>(
      'delete removes locally then reloads',
      build: () => _buildCubit(_RepoFake()),
      act: (cubit) async {
        await cubit.load();
        await cubit.delete('2');
      },
      expect: () => [
        predicate<s.TaskState>((st) => st.status == s.TaskStatusUI.loading),
        predicate<s.TaskState>((st) => st.status == s.TaskStatusUI.success && st.items.length == 3),
        predicate<s.TaskState>((st) => st.items.every((t) => t.id != '2')),
        predicate<s.TaskState>((st) => st.status == s.TaskStatusUI.loading),
        predicate<s.TaskState>((st) => st.status == s.TaskStatusUI.success && st.items.length == 2),
      ],
    );

    blocTest<TaskCubit, s.TaskState>(
      'delete failure sets errorMessage',
      build: () {
        final r = _RepoFake()..throwOnDelete = true;
        return _buildCubit(r);
      },
      act: (cubit) async {
        await cubit.load();
        await cubit.delete('1');
      },
      expect: () => [
        predicate<s.TaskState>((st) => st.status == s.TaskStatusUI.loading),
        predicate<s.TaskState>((st) => st.status == s.TaskStatusUI.success),
        predicate<s.TaskState>((st) => st.errorMessage?.startsWith('Delete failed:') == true),
      ],
    );

    blocTest<TaskCubit, s.TaskState>(
      'update replaces item then reloads',
      build: () => _buildCubit(_RepoFake()),
      act: (cubit) async {
        await cubit.load();
        final original = cubit.state.items.firstWhere((t) => t.id == '1');
        await cubit.update(original.copyWith(title: 'Changed'));
      },
      expect: () => [
        predicate<s.TaskState>((st) => st.status == s.TaskStatusUI.loading),
        predicate<s.TaskState>((st) => st.status == s.TaskStatusUI.success),
        predicate<s.TaskState>((st) => st.items.firstWhere((t) => t.id == '1').title == 'Changed'),
        predicate<s.TaskState>((st) => st.status == s.TaskStatusUI.loading),
        predicate<s.TaskState>((st) => st.status == s.TaskStatusUI.success),
      ],
    );

    blocTest<TaskCubit, s.TaskState>(
      'update failure sets errorMessage',
      build: () {
        final r = _RepoFake()..throwOnUpdate = true;
        return _buildCubit(r);
      },
      act: (cubit) async {
        await cubit.load();
        final t = cubit.state.items.first.copyWith(title: 'X');
        await cubit.update(t);
      },
      expect: () => [
        predicate<s.TaskState>((st) => st.status == s.TaskStatusUI.loading),
        predicate<s.TaskState>((st) => st.status == s.TaskStatusUI.success),
        predicate<s.TaskState>((st) => st.errorMessage?.startsWith('Update failed:') == true),
      ],
    );

    blocTest<TaskCubit, s.TaskState>(
      'toggle updates item then reloads',
      build: () => _buildCubit(_RepoFake()),
      act: (cubit) async {
        await cubit.load();
        await cubit.toggle('3');
      },
      expect: () => [
        predicate<s.TaskState>((st) => st.status == s.TaskStatusUI.loading),
        predicate<s.TaskState>((st) => st.status == s.TaskStatusUI.success),
        predicate<s.TaskState>((st) {
          final t = st.items.firstWhere((e) => e.id == '3', orElse: () => st.items.last);
          return t.id == '3' && t.status == TaskStatus.pending || t.status == TaskStatus.done;
        }),
        predicate<s.TaskState>((st) => st.status == s.TaskStatusUI.loading),
        predicate<s.TaskState>((st) => st.status == s.TaskStatusUI.success),
      ],
    );

    blocTest<TaskCubit, s.TaskState>(
      'toggle failure sets errorMessage',
      build: () {
        final r = _RepoFake()..throwOnToggle = true;
        return _buildCubit(r);
      },
      act: (cubit) async {
        await cubit.load();
        await cubit.toggle('1');
      },
      expect: () => [
        predicate<s.TaskState>((st) => st.status == s.TaskStatusUI.loading),
        predicate<s.TaskState>((st) => st.status == s.TaskStatusUI.success),
        predicate<s.TaskState>((st) => st.errorMessage?.startsWith('Toggle failed:') == true),
      ],
    );

    blocTest<TaskCubit, s.TaskState>(
      'load with clearStatus/resetFrom/resetTo nullifies stored filters',
      build: () => _buildCubit(_RepoFake()),
      act: (cubit) async {
        await cubit.load(status: TaskStatus.pending, from: DateTime(2025,), to: DateTime(2025, 1, 31));
        await cubit.load(clearStatus: true, resetFrom: true, resetTo: true);
      },
      expect: () => [
        predicate<s.TaskState>((st) => st.status == s.TaskStatusUI.loading),
        predicate<s.TaskState>((st) =>
            st.status == s.TaskStatusUI.success &&
            st.filterStatus == TaskStatus.pending &&
            st.from != null &&
            st.to != null),
        predicate<s.TaskState>((st) =>
            st.status == s.TaskStatusUI.loading &&
            st.filterStatus == null &&
            st.from == null &&
            st.to == null),
        predicate<s.TaskState>((st) => st.status == s.TaskStatusUI.success),
      ],
    );
  });
}
