import 'package:flutter_test/flutter_test.dart';
import 'package:tasky_clean_cubit/src/data/datasources/mock_api.dart';
import 'package:tasky_clean_cubit/src/domain/entities/task.dart';
import 'package:tasky_clean_cubit/src/domain/value_objects/task_status.dart';

void main() {
  group('MockApi', () {
    test('login returns token and user with derived name', () async {
      final api = MockApi();

      final (token, user) = await api.login('john@x.com', 'pw');

      expect(token.startsWith('mock_jwt_'), isTrue);
      expect(user.email, 'john@x.com');
      expect(user.name, 'john');
      expect(user.id.isNotEmpty, isTrue);
    });

    test('register returns token and user with given name', () async {
      final api = MockApi();

      final (token, user) = await api.register('Alice', 'a@x.com', 'pw');

      expect(token.startsWith('mock_jwt_'), isTrue);
      expect(user.email, 'a@x.com');
      expect(user.name, 'Alice');
      expect(user.id.isNotEmpty, isTrue);
    });

    test('list returns all when no filter', () async {
      final api = MockApi();

      final list = await api.list();

      expect(list.length, 3);
    });

    test('list filters by status', () async {
      final api = MockApi();

      final pending = await api.list(status: TaskStatus.pending);
      final inProgress = await api.list(status: TaskStatus.inProgress);
      final done = await api.list(status: TaskStatus.done);

      expect(pending.every((t) => t.status == TaskStatus.pending), isTrue);
      expect(inProgress.every((t) => t.status == TaskStatus.inProgress), isTrue);
      expect(done.every((t) => t.status == TaskStatus.done), isTrue);

      expect(pending.length, 1);
      expect(inProgress.length, 1);
      expect(done.length, 1);
    });

    test('list filters by date range', () async {
      final api = MockApi();
      final now = DateTime.now();
      final from = now.subtract(const Duration(days: 2, hours: 6));
      final to = now;

      final list = await api.list(from: from, to: to);

      expect(list.length, 2);
      expect(list.every((t) => !t.createdAt.isBefore(from) && !t.createdAt.isAfter(to)), isTrue);
    });

    test('create inserts at beginning and returns created task', () async {
      final api = MockApi();

      final created = await api.create(title: 'New', description: 'Desc');
      final all = await api.list();

      expect(created.id.isNotEmpty, isTrue);
      expect(created.title, 'New');
      expect(created.status, TaskStatus.pending);
      expect(all.first.id, created.id);
      expect(all.length, 4);
    });

    test('update modifies existing task and sets updatedAt', () async {
      final api = MockApi();
      final original = (await api.list()).firstWhere((t) => t.id == '2');

      final updated = await api.update(
        original.copyWith(title: 'Changed', status: TaskStatus.done),
      );

      expect(updated.id, original.id);
      expect(updated.title, 'Changed');
      expect(updated.status, TaskStatus.done);
      expect(updated.updatedAt, isNotNull);

      final by = await api.byId('2');
      expect(by.title, 'Changed');
    });

    test('update throws when task not found', () async {
      final api = MockApi();
      final ghost = Task(
        id: 'nope',
        title: 'X',
        description: 'Y',
        status: TaskStatus.pending,
        createdAt: DateTime.now(),
      );

      await expectLater(api.update(ghost), throwsA(isA<Exception>()));
    });

    test('delete removes task', () async {
      final api = MockApi();

      final before = await api.list();
      await api.delete('3');
      final after = await api.list();

      expect(before.length - 1, after.length);
      expect(after.any((t) => t.id == '3'), isFalse);
    });

    test('toggleComplete toggles pending<->done', () async {
      final api = MockApi();

      final t1 = await api.toggleComplete('3');
      final t2 = await api.toggleComplete('3');

      expect(t1.status, TaskStatus.done);
      expect(t2.status, TaskStatus.pending);
    });

    test('byId returns the task', () async {
      final api = MockApi();

      final t = await api.byId('1');

      expect(t.id, '1');
      expect(t.title.isNotEmpty, isTrue);
    });
  });
}
