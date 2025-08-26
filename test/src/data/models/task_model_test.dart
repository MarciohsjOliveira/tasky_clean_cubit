import 'package:flutter_test/flutter_test.dart';
import 'package:tasky_clean_cubit/src/data/models/task_model.dart';
import 'package:tasky_clean_cubit/src/domain/value_objects/task_status.dart';

void main() {
  group('TaskModel', () {
    test('fromJson parses all fields', () {
      final created = DateTime(2025, 1, 1, 12);
      final due = DateTime(2025, 1, 10);
      final updated = DateTime(2025, 1, 2, 9);

      final json = {
        'id': '1',
        'title': 'T',
        'description': 'D',
        'status': 'in_progress',
        'createdAt': created.toIso8601String(),
        'dueDate': due.toIso8601String(),
        'updatedAt': updated.toIso8601String(),
      };

      final model = TaskModel.fromJson(json);

      expect(model.id, '1');
      expect(model.title, 'T');
      expect(model.description, 'D');
      expect(model.status, TaskStatus.inProgress);
      expect(model.createdAt, created);
      expect(model.dueDate, due);
      expect(model.updatedAt, updated);
    });

    test('fromJson handles null optional fields', () {
      final created = DateTime(2025, 1, 1, 12);

      final json = {
        'id': '2',
        'title': 'A',
        'description': 'B',
        'status': 'done',
        'createdAt': created.toIso8601String(),
        'dueDate': null,
        'updatedAt': null,
      };

      final model = TaskModel.fromJson(json);

      expect(model.id, '2');
      expect(model.status, TaskStatus.done);
      expect(model.createdAt, created);
      expect(model.dueDate, isNull);
      expect(model.updatedAt, isNull);
    });

    test('toJson serializes with status.name and ISO dates', () {
      final model = TaskModel(
        id: '3',
        title: 'X',
        description: 'Y',
        status: TaskStatus.inProgress,
        createdAt: DateTime(2025, 1, 3, 8),
        dueDate: DateTime(2025, 1, 20),
        updatedAt: DateTime(2025, 1, 5),
      );

      final json = model.toJson();

      expect(json['id'], '3');
      expect(json['title'], 'X');
      expect(json['description'], 'Y');
      expect(json['status'], 'inProgress');
      expect(json['createdAt'], model.createdAt.toIso8601String());
      expect(json['dueDate'], model.dueDate!.toIso8601String());
      expect(json['updatedAt'], model.updatedAt!.toIso8601String());
    });

    test('roundtrip toJson -> fromJson preserves value equality', () {
      final model = TaskModel(
        id: '4',
        title: 'Round',
        description: 'Trip',
        status: TaskStatus.pending,
        createdAt: DateTime(2025, 1, 4, 10),
        dueDate: DateTime(2025, 1, 25),
        updatedAt: DateTime(2025, 1, 6),
      );

      final parsed = TaskModel.fromJson(model.toJson());
      expect(parsed, equals(model));
    });
  });
}
