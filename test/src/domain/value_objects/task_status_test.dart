import 'package:flutter_test/flutter_test.dart';
import 'package:tasky_clean_cubit/src/domain/value_objects/task_status.dart';

void main() {
  group('TaskStatus.label', () {
    test('returns correct labels', () {
      expect(TaskStatus.pending.label, 'Pending');
      expect(TaskStatus.inProgress.label, 'In Progress');
      expect(TaskStatus.done.label, 'Done');
    });
  });

  group('TaskStatusX.fromString', () {
    test('parses canonical values', () {
      expect(TaskStatusX.fromString('pending'), TaskStatus.pending);
      expect(TaskStatusX.fromString('inProgress'), TaskStatus.inProgress);
      expect(TaskStatusX.fromString('done'), TaskStatus.done);
    });

    test('parses snake/compact variants', () {
      expect(TaskStatusX.fromString('in_progress'), TaskStatus.inProgress);
      expect(TaskStatusX.fromString('inprogress'), TaskStatus.inProgress);
      expect(TaskStatusX.fromString('completed'), TaskStatus.done);
    });

    test('is case-insensitive', () {
      expect(TaskStatusX.fromString('INPROGRESS'), TaskStatus.inProgress);
      expect(TaskStatusX.fromString('Completed'), TaskStatus.done);
      expect(TaskStatusX.fromString('PENDING'), TaskStatus.pending);
    });

    test('falls back to pending for unknown', () {
      expect(TaskStatusX.fromString('unknown'), TaskStatus.pending);
      expect(TaskStatusX.fromString(''), TaskStatus.pending);
    });
  });
}
