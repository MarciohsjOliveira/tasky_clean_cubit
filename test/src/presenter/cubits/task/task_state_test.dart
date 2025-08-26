import 'package:flutter_test/flutter_test.dart';
import 'package:tasky_clean_cubit/src/domain/entities/task.dart';
import 'package:tasky_clean_cubit/src/domain/value_objects/task_status.dart';
import 'package:tasky_clean_cubit/src/presenter/cubits/task/task_state.dart';

void main() {
  group('TaskState', () {
    test('default constructor values', () {
      const s = TaskState();
      expect(s.items, isEmpty);
      expect(s.status, TaskStatusUI.idle);
      expect(s.errorMessage, isNull);
      expect(s.filterStatus, isNull);
      expect(s.from, isNull);
      expect(s.to, isNull);
    });

    test('value equality with same field values (same list reference)', () {
      final t1 = Task(
        id: '1',
        title: 'A',
        description: 'D',
        status: TaskStatus.pending,
        createdAt: DateTime(2025,),
      );
      final t2 = Task(
        id: '2',
        title: 'B',
        description: 'E',
        status: TaskStatus.inProgress,
        createdAt: DateTime(2025, 1, 2),
      );
      final items = [t1, t2];
      final from = DateTime(2025,);
      final to = DateTime(2025, 1, 31);

      final a = TaskState(
        items: items,
        status: TaskStatusUI.loading,
        errorMessage: 'err',
        filterStatus: TaskStatus.done,
        from: from,
        to: to,
      );
      final b = TaskState(
        items: items,
        status: TaskStatusUI.loading,
        errorMessage: 'err',
        filterStatus: TaskStatus.done,
        from: from,
        to: to,
      );

      expect(a, b);
      expect(a.props.length, 6);
      expect(a.props[0], same(items));
      expect(a.props[1], TaskStatusUI.loading);
      expect(a.props[2], 'err');
      expect(a.props[3], TaskStatus.done);
      expect(a.props[4], from);
      expect(a.props[5], to);
    });

    test('copyWith updates provided fields and preserves others', () {
      final base = TaskState(
        filterStatus: TaskStatus.pending,
        from: DateTime(2025),
        to: DateTime(2025, 1, 31),
      );

      final newItems = [
        Task(
          id: 'x',
          title: 'T',
          description: 'D',
          status: TaskStatus.pending,
          createdAt: DateTime(2025, 2),
        ),
      ];

      final updated = base.copyWith(
        items: newItems,
        status: TaskStatusUI.success,
        errorMessage: 'ok',
        filterStatus: TaskStatus.done,
        from: DateTime(2025, 2),
        to: DateTime(2025, 2, 28),
      );

      expect(updated.items, same(newItems));
      expect(updated.status, TaskStatusUI.success);
      expect(updated.errorMessage, 'ok');
      expect(updated.filterStatus, TaskStatus.done);
      expect(updated.from, DateTime(2025, 2));
      expect(updated.to, DateTime(2025, 2, 28));
    });

    test('copyWith keeps old values when arguments are null', () {
      final base = TaskState(
        status: TaskStatusUI.loading,
        errorMessage: 'e',
        filterStatus: TaskStatus.inProgress,
        from: DateTime(2025, 3),
        to: DateTime(2025, 3, 31),
      );

      final kept = base.copyWith();

      expect(kept.items, same(base.items));
      expect(kept.status, base.status);
      expect(kept.errorMessage, base.errorMessage);
      expect(kept.filterStatus, base.filterStatus);
      expect(kept.from, base.from);
      expect(kept.to, base.to);
      expect(kept, base);
    });

    test('copyWith resetFilter overrides provided value to null', () {
      const base = TaskState(filterStatus: TaskStatus.pending);

      final changedButReset = base.copyWith(
        filterStatus: TaskStatus.done,
        resetFilter: true,
      );

      expect(changedButReset.filterStatus, isNull);
    });

    test('copyWith resetFrom overrides provided value to null', () {
      final base = TaskState(from: DateTime(2025));

      final changedButReset = base.copyWith(
        from: DateTime(2025, 2),
        resetFrom: true,
      );

      expect(changedButReset.from, isNull);
    });

    test('copyWith resetTo overrides provided value to null', () {
      final base = TaskState(to: DateTime(2025, 1, 31));

      final changedButReset = base.copyWith(
        to: DateTime(2025, 2, 28),
        resetTo: true,
      );

      expect(changedButReset.to, isNull);
    });

    test('copyWith can nullify fields via reset flags only', () {
      final base = TaskState(
        filterStatus: TaskStatus.done,
        from: DateTime(2025, 4),
        to: DateTime(2025, 4, 30),
      );

      final cleared = base.copyWith(
        resetFilter: true,
        resetFrom: true,
        resetTo: true,
      );

      expect(cleared.filterStatus, isNull);
      expect(cleared.from, isNull);
      expect(cleared.to, isNull);
    });
  });
}
