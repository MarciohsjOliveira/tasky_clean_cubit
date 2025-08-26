import 'package:flutter_test/flutter_test.dart';
import 'package:tasky_clean_cubit/src/domain/entities/task.dart';
import 'package:tasky_clean_cubit/src/domain/value_objects/task_status.dart';

void main() {
  group('Task', () {
    final created = DateTime(2025, 1, 2, 3, 4, 5);
    final due = DateTime(2025, 1, 10);
    final updated = DateTime(2025, 1, 3);

    final base = Task(
      id: 't1',
      title: 'Title',
      description: 'Desc',
      status: TaskStatus.pending,
      createdAt: created,
      dueDate: due,
      updatedAt: updated,
    );

    test('supports value equality', () {
      final same = Task(
        id: 't1',
        title: 'Title',
        description: 'Desc',
        status: TaskStatus.pending,
        createdAt: created,
        dueDate: due,
        updatedAt: updated,
      );

      expect(base, equals(same));
      final copy = base.copyWith();
      expect(copy, equals(base));
      expect(identical(copy, base), isFalse);
    });

    test('props contains all fields in order', () {
      expect(
        base.props,
        [
          't1',
          'Title',
          'Desc',
          TaskStatus.pending,
          created,
          due,
          updated,
        ],
      );
    });

    test('copyWith updates only provided fields', () {
      final changed = base.copyWith(
        id: 't2',
        title: 'New',
        description: 'NewDesc',
        status: TaskStatus.inProgress,
        createdAt: DateTime(2025),
        dueDate: DateTime(2025, 2),
        updatedAt: DateTime(2025, 1, 5),
      );

      expect(changed.id, 't2');
      expect(changed.title, 'New');
      expect(changed.description, 'NewDesc');
      expect(changed.status, TaskStatus.inProgress);
      expect(changed.createdAt, DateTime(2025));
      expect(changed.dueDate, DateTime(2025, 2));
      expect(changed.updatedAt, DateTime(2025, 1, 5));
    });

    test('copyWith keeps current values when passing null to optionals', () {
      final keep = base.copyWith();
      expect(keep.dueDate, base.dueDate);
      expect(keep.updatedAt, base.updatedAt);
    });
  });
}
