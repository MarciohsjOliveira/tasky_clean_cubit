import 'package:flutter_test/flutter_test.dart';
import 'package:tasky_clean_cubit/src/domain/entities/task.dart';
import 'package:tasky_clean_cubit/src/domain/repositories/task_repository.dart';
import 'package:tasky_clean_cubit/src/domain/usecases/update_task.dart';
import 'package:tasky_clean_cubit/src/domain/value_objects/task_status.dart';

class _RepoFake implements TaskRepository {
  Task? lastUpdated;
  Task? nextTask;
  Object? toThrow;

  @override
  Future<Task> update(Task task) async {
    if (toThrow != null) throw toThrow!;
    lastUpdated = task;
    return nextTask ?? task;
  }

  @override
  Future<List<Task>> list({TaskFilter? filter}) => throw UnimplementedError();

  @override
  Future<Task> create({required String title, required String description, DateTime? dueDate}) =>
      throw UnimplementedError();

  @override
  Future<Task> toggleComplete(String id) => throw UnimplementedError();

  @override
  Future<void> delete(String id) => throw UnimplementedError();

  @override
  Future<Task> byId(String id) => throw UnimplementedError();
}

void main() {
  group('UpdateTask', () {
    final base = Task(
      id: '1',
      title: 'A',
      description: 'B',
      status: TaskStatus.pending,
      createdAt: DateTime(2025,),
    );

    test('calls repository with task and returns result', () async {
      final repo = _RepoFake()
        ..nextTask = base.copyWith(title: 'A2', status: TaskStatus.inProgress);
      final usecase = UpdateTask(repo);

      final result = await usecase(base);

      expect(repo.lastUpdated, same(base));
      expect(result.title, 'A2');
      expect(result.status, TaskStatus.inProgress);
    });

    test('returns input task when repo returns same instance', () async {
      final repo = _RepoFake();
      final usecase = UpdateTask(repo);

      final result = await usecase(base);

      expect(result, same(base));
    });

    test('rethrows repository errors', () async {
      final repo = _RepoFake()..toThrow = StateError('fail');
      final usecase = UpdateTask(repo);

      await expectLater(usecase(base), throwsA(isA<StateError>()));
    });
  });
}
