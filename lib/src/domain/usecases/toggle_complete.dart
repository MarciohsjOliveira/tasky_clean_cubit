import '../entities/task.dart';
import '../repositories/task_repository.dart';

class ToggleComplete {
  const ToggleComplete(this._repo);
  final TaskRepository _repo;
  Future<Task> call(String id) => _repo.toggleComplete(id);
}
