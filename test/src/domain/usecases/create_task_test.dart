import 'package:flutter_test/flutter_test.dart';
import 'package:tasky_clean_cubit/src/domain/entities/task.dart';
import 'package:tasky_clean_cubit/src/domain/repositories/task_repository.dart';
import 'package:tasky_clean_cubit/src/domain/usecases/create_task.dart';
import 'package:tasky_clean_cubit/src/domain/value_objects/task_status.dart';

class _RepoFake implements TaskRepository {
  String? lastTitle;
  String? lastDescription;
  DateTime? lastDueDate;
  Task? nextResult;
  Object? toThrow;

  @override
  Future<Task> create(
      {required String title,
      required String description,
      DateTime? dueDate}) async {
    if (toThrow != null) throw toThrow!;
    lastTitle = title;
    lastDescription = description;
    lastDueDate = dueDate;
    return nextResult ??
        Task(
          id: 'gen-1',
          title: title,
          description: description,
          status: TaskStatus.pending,
          createdAt: DateTime(2025, 1, 1, 12),
          dueDate: dueDate,
        );
  }

  @override
  Future<Task> byId(String id) => throw UnimplementedError();

  @override
  Future<void> delete(String id) => throw UnimplementedError();

  @override
  Future<List<Task>> list({TaskFilter? filter}) => throw UnimplementedError();

  @override
  Future<Task> toggleComplete(String id) => throw UnimplementedError();

  @override
  Future<Task> update(Task task) => throw UnimplementedError();
}

void main() {
  group('CreateTask', () {
    test('calls repository and returns created task', () async {
      final repo = _RepoFake();
      final usecase = CreateTask(repo);

      final result = await usecase(
        title: 'T',
        description: 'D',
        dueDate: DateTime(2025, 2),
      );

      expect(repo.lastTitle, 'T');
      expect(repo.lastDescription, 'D');
      expect(repo.lastDueDate, DateTime(2025, 2));
      expect(result.title, 'T');
      expect(result.description, 'D');
      expect(result.dueDate, DateTime(2025, 2));
      expect(result.status, TaskStatus.pending);
    });

    test('passes null dueDate through', () async {
      final repo = _RepoFake();
      final usecase = CreateTask(repo);

      final result = await usecase(title: 'NoDue', description: 'X');

      expect(repo.lastDueDate, isNull);
      expect(result.dueDate, isNull);
    });

    test('rethrows repository errors', () async {
      final repo = _RepoFake()..toThrow = StateError('fail');
      final usecase = CreateTask(repo);

      expect(
        () => usecase(title: 'A', description: 'B'),
        throwsA(isA<StateError>()),
      );
    });
  });
}
