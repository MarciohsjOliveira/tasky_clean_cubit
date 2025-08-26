import '../entities/task.dart';
import '../value_objects/task_status.dart';

class TaskFilter {
  const TaskFilter({this.status, this.from, this.to});
  final TaskStatus? status;
  final DateTime? from;
  final DateTime? to;
}

abstract class TaskRepository {
  Future<List<Task>> list({TaskFilter? filter});
  Future<Task> create(
      {required String title, required String description, DateTime? dueDate});
  Future<Task> update(Task task);
  Future<void> delete(String id);
  Future<Task> toggleComplete(String id);
  Future<Task> byId(String id);
}
