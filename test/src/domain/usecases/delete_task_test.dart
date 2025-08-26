import 'package:flutter_test/flutter_test.dart';
import 'package:tasky_clean_cubit/src/domain/repositories/task_repository.dart';
import 'package:tasky_clean_cubit/src/domain/usecases/delete_task.dart';
import 'package:tasky_clean_cubit/src/domain/entities/task.dart';

class _RepoFake implements TaskRepository {
  String? deletedId;
  Object? toThrow;

  @override
  Future<void> delete(String id) async {
    if (toThrow != null) throw toThrow!;
    deletedId = id;
  }

  @override
  Future<List<Task>> list({TaskFilter? filter}) => throw UnimplementedError();

  @override
  Future<Task> create({required String title, required String description, DateTime? dueDate}) =>
      throw UnimplementedError();

  @override
  Future<Task> update(Task task) => throw UnimplementedError();

  @override
  Future<Task> toggleComplete(String id) => throw UnimplementedError();

  @override
  Future<Task> byId(String id) => throw UnimplementedError();
}

void main() {
  group('DeleteTask', () {
    test('calls repository with correct id', () async {
      final repo = _RepoFake();
      final usecase = DeleteTask(repo);

      await usecase('abc123');

      expect(repo.deletedId, 'abc123');
    });

    test('rethrows repository errors', () async {
      final repo = _RepoFake()..toThrow = StateError('fail');
      final usecase = DeleteTask(repo);

      expect(() => usecase('x'), throwsA(isA<StateError>()));
    });
  });
}
