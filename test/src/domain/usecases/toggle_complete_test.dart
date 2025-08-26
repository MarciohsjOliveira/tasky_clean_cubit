import 'package:flutter_test/flutter_test.dart';
import 'package:tasky_clean_cubit/src/domain/entities/task.dart';
import 'package:tasky_clean_cubit/src/domain/repositories/task_repository.dart';
import 'package:tasky_clean_cubit/src/domain/usecases/toggle_complete.dart';
import 'package:tasky_clean_cubit/src/domain/value_objects/task_status.dart';

class _RepoFake implements TaskRepository {
  String? lastToggledId;
  Task? nextTask;
  Object? toThrow;

  @override
  Future<Task> toggleComplete(String id) async {
    if (toThrow != null) throw toThrow!;
    lastToggledId = id;
    return nextTask ??
        Task(
          id: id,
          title: 'T',
          description: 'D',
          status: TaskStatus.done,
          createdAt: DateTime(2025, 1, 1, 12),
        );
  }

  @override
  Future<List<Task>> list({TaskFilter? filter}) => throw UnimplementedError();

  @override
  Future<Task> create({required String title, required String description, DateTime? dueDate}) =>
      throw UnimplementedError();

  @override
  Future<Task> update(Task task) => throw UnimplementedError();

  @override
  Future<void> delete(String id) => throw UnimplementedError();

  @override
  Future<Task> byId(String id) => throw UnimplementedError();
}

void main() {
  group('ToggleComplete', () {
    test('calls repository with id and returns task', () async {
      final repo = _RepoFake();
      final usecase = ToggleComplete(repo);

      final result = await usecase('id-1');

      expect(repo.lastToggledId, 'id-1');
      expect(result.id, 'id-1');
      expect(result.status, TaskStatus.done);
    });

    test('returns provided repository result', () async {
      final repo = _RepoFake()
        ..nextTask = Task(
          id: 'x',
          title: 'A',
          description: 'B',
          status: TaskStatus.inProgress,
          createdAt: DateTime(2025, 1, 2),
        );
      final usecase = ToggleComplete(repo);

      final result = await usecase('x');

      expect(result, same(repo.nextTask));
    });

    test('rethrows repository errors', () async {
      final repo = _RepoFake()..toThrow = StateError('fail');
      final usecase = ToggleComplete(repo);

      await expectLater(usecase('y'), throwsA(isA<StateError>()));
    });
  });
}
