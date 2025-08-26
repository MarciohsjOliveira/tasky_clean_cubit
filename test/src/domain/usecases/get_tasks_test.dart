import 'package:flutter_test/flutter_test.dart';
import 'package:tasky_clean_cubit/src/domain/entities/task.dart';
import 'package:tasky_clean_cubit/src/domain/repositories/task_repository.dart';
import 'package:tasky_clean_cubit/src/domain/usecases/get_tasks.dart';
import 'package:tasky_clean_cubit/src/domain/value_objects/task_status.dart';

class _RepoFake implements TaskRepository {
  TaskFilter? lastFilter;
  List<Task>? nextList;
  Object? toThrow;

  @override
  Future<List<Task>> list({TaskFilter? filter}) async {
    if (toThrow != null) throw toThrow!;
    lastFilter = filter;
    return nextList ?? <Task>[];
  }

  @override
  Future<Task> create(
          {required String title,
          required String description,
          DateTime? dueDate}) =>
      throw UnimplementedError();

  @override
  Future<Task> update(Task task) => throw UnimplementedError();

  @override
  Future<Task> toggleComplete(String id) => throw UnimplementedError();

  @override
  Future<void> delete(String id) => throw UnimplementedError();

  @override
  Future<Task> byId(String id) => throw UnimplementedError();
}

void main() {
  group('GetTasks', () {
    test('calls repository with filter and returns list', () async {
      final repo = _RepoFake();
      final usecase = GetTasks(repo);

      final tasks = [
        Task(
          id: '1',
          title: 'A',
          description: 'a',
          status: TaskStatus.pending,
          createdAt: DateTime(2025, 1, 1, 10),
        ),
        Task(
          id: '2',
          title: 'B',
          description: 'b',
          status: TaskStatus.inProgress,
          createdAt: DateTime(2025, 1, 2, 11),
        ),
      ];
      repo.nextList = tasks;

      final filter = TaskFilter(
        status: TaskStatus.pending,
        from: DateTime(
          2025,
        ),
        to: DateTime(2025, 1, 31),
      );

      final result = await usecase(filter: filter);

      expect(result, tasks);
      expect(repo.lastFilter, same(filter));
    });

    test('passes null filter and returns empty list', () async {
      final repo = _RepoFake()..nextList = <Task>[];
      final usecase = GetTasks(repo);

      final result = await usecase();

      expect(result, isEmpty);
      expect(repo.lastFilter, isNull);
    });

    test('rethrows repository errors', () async {
      final repo = _RepoFake()..toThrow = StateError('fail');
      final usecase = GetTasks(repo);

      await expectLater(usecase(), throwsA(isA<StateError>()));
    });
  });
}
