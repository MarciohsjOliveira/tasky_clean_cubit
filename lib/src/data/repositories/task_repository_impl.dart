import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/mock_api.dart';

class TaskRepositoryImpl implements TaskRepository {
  TaskRepositoryImpl({required MockApi api}) : _api = api;
  final MockApi _api;

  @override
  Future<Task> byId(String id) => _api.byId(id);

  @override
  Future<Task> create({
    required String title,
    required String description,
    DateTime? dueDate,
  }) {
    return _api.create(
      title: title,
      description: description,
      dueDate: dueDate,
    );
  }

  @override
  Future<void> delete(String id) => _api.delete(id);

  @override
  Future<List<Task>> list({
    TaskFilter? filter,
  }) {
    return _api.list(
      status: filter?.status,
      from: filter?.from,
      to: filter?.to,
    );
  }

  @override
  Future<Task> toggleComplete(String id) => _api.toggleComplete(id);

  @override
  Future<Task> update(Task task) => _api.update(task);
}
