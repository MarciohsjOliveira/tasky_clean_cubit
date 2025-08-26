import 'package:flutter_test/flutter_test.dart';
import 'package:tasky_clean_cubit/src/data/datasources/mock_api.dart';
import 'package:tasky_clean_cubit/src/data/repositories/task_repository_impl.dart';
import 'package:tasky_clean_cubit/src/domain/entities/task.dart';
import 'package:tasky_clean_cubit/src/domain/repositories/task_repository.dart';
import 'package:tasky_clean_cubit/src/domain/value_objects/task_status.dart';

class _ApiFake extends MockApi {
  String? byIdArg;
  String? toggleArg;
  String? deleteArg;
  Task? updateArg;
  String? createTitle;
  String? createDescription;
  DateTime? createDue;

  Task? nextTask;
  List<Task>? nextList;

  Object? byIdError;
  Object? listError;
  Object? createError;
  Object? updateError;
  Object? toggleError;
  Object? deleteError;

  @override
  Future<Task> byId(String id) async {
    if (byIdError != null) throw byIdError!;
    byIdArg = id;
    return nextTask ??
        Task(
          id: id,
          title: 'T',
          description: 'D',
          status: TaskStatus.pending,
          createdAt: DateTime(2025, 1, 1, 10),
        );
  }

  @override
  Future<List<Task>> list(
      {TaskStatus? status, DateTime? from, DateTime? to}) async {
    if (listError != null) throw listError!;
    return nextList ?? <Task>[];
  }

  @override
  Future<Task> create(
      {required String title,
      required String description,
      DateTime? dueDate}) async {
    if (createError != null) throw createError!;
    createTitle = title;
    createDescription = description;
    createDue = dueDate;
    return nextTask ??
        Task(
          id: 'new',
          title: title,
          description: description,
          status: TaskStatus.pending,
          createdAt: DateTime(2025, 1, 1, 12),
          dueDate: dueDate,
        );
  }

  @override
  Future<Task> update(Task task) async {
    if (updateError != null) throw updateError!;
    updateArg = task;
    return nextTask ?? task;
  }

  @override
  Future<Task> toggleComplete(String id) async {
    if (toggleError != null) throw toggleError!;
    toggleArg = id;
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
  Future<void> delete(String id) async {
    if (deleteError != null) throw deleteError!;
    deleteArg = id;
  }
}

void main() {
  group('TaskRepositoryImpl', () {
    test('byId forwards id and returns task', () async {
      final api = _ApiFake()
        ..nextTask = Task(
            id: '1',
            title: 'A',
            description: 'B',
            status: TaskStatus.pending,
            createdAt: DateTime(
              2025,
            ));
      final repo = TaskRepositoryImpl(api: api);

      final t = await repo.byId('1');

      expect(api.byIdArg, '1');
      expect(t.id, '1');
      expect(t.title, 'A');
    });

    test('list forwards filter fields', () async {
      final api = _ApiFake()
        ..nextList = [
          Task(
              id: '1',
              title: 'A',
              description: 'B',
              status: TaskStatus.pending,
              createdAt: DateTime(
                2025,
              )),
        ];
      final repo = TaskRepositoryImpl(api: api);

      final filter = TaskFilter(
        status: TaskStatus.pending,
        from: DateTime(
          2025,
        ),
        to: DateTime(2025, 1, 31),
      );

      final list = await repo.list(filter: filter);

      expect(list.length, 1);
      expect(list.first.id, '1');
    });

    test('list with null filter returns next list', () async {
      final api = _ApiFake()..nextList = [];
      final repo = TaskRepositoryImpl(api: api);

      final list = await repo.list();

      expect(list, isEmpty);
    });

    test('create forwards params and returns task', () async {
      final api = _ApiFake();
      final repo = TaskRepositoryImpl(api: api);

      final due = DateTime(
        2025,
        2,
      );
      final t = await repo.create(title: 'T', description: 'D', dueDate: due);

      expect(api.createTitle, 'T');
      expect(api.createDescription, 'D');
      expect(api.createDue, due);
      expect(t.title, 'T');
      expect(t.description, 'D');
      expect(t.dueDate, due);
    });

    test('create with null dueDate passes null', () async {
      final api = _ApiFake();
      final repo = TaskRepositoryImpl(api: api);

      final t = await repo.create(title: 'X', description: 'Y');

      expect(api.createDue, isNull);
      expect(t.dueDate, isNull);
    });

    test('update forwards task and returns updated', () async {
      final api = _ApiFake();
      final repo = TaskRepositoryImpl(api: api);

      final input = Task(
        id: '9',
        title: 'Old',
        description: 'Desc',
        status: TaskStatus.inProgress,
        createdAt: DateTime(2025, 1, 5),
      );
      api.nextTask = input.copyWith(title: 'New');

      final out = await repo.update(input);

      expect(api.updateArg, same(input));
      expect(out.title, 'New');
    });

    test('toggleComplete forwards id and returns task', () async {
      final api = _ApiFake();
      final repo = TaskRepositoryImpl(api: api);

      final t = await repo.toggleComplete('k1');

      expect(api.toggleArg, 'k1');
      expect(t.id, 'k1');
    });

    test('delete forwards id', () async {
      final api = _ApiFake();
      final repo = TaskRepositoryImpl(api: api);

      await repo.delete('del-1');

      expect(api.deleteArg, 'del-1');
    });

    test('byId rethrows errors', () async {
      final api = _ApiFake()..byIdError = StateError('x');
      final repo = TaskRepositoryImpl(api: api);

      await expectLater(repo.byId('1'), throwsA(isA<StateError>()));
    });

    test('list rethrows errors', () async {
      final api = _ApiFake()..listError = StateError('x');
      final repo = TaskRepositoryImpl(api: api);

      await expectLater(repo.list(), throwsA(isA<StateError>()));
    });

    test('create rethrows errors', () async {
      final api = _ApiFake()..createError = StateError('x');
      final repo = TaskRepositoryImpl(api: api);

      await expectLater(
        repo.create(title: 'T', description: 'D'),
        throwsA(isA<StateError>()),
      );
    });

    test('update rethrows errors', () async {
      final api = _ApiFake()..updateError = StateError('x');
      final repo = TaskRepositoryImpl(api: api);

      final task = Task(
        id: '1',
        title: 't',
        description: 'd',
        status: TaskStatus.pending,
        createdAt: DateTime(
          2025,
        ),
      );

      await expectLater(repo.update(task), throwsA(isA<StateError>()));
    });

    test('toggleComplete rethrows errors', () async {
      final api = _ApiFake()..toggleError = StateError('x');
      final repo = TaskRepositoryImpl(api: api);

      await expectLater(repo.toggleComplete('i'), throwsA(isA<StateError>()));
    });

    test('delete rethrows errors', () async {
      final api = _ApiFake()..deleteError = StateError('x');
      final repo = TaskRepositoryImpl(api: api);

      await expectLater(repo.delete('i'), throwsA(isA<StateError>()));
    });
  });
}
