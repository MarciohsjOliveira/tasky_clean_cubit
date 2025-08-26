import '../entities/task.dart';
import '../repositories/task_repository.dart';

class UpdateTask {
  const UpdateTask(this._repo);
  final TaskRepository _repo;
  Future<Task> call(Task task) => _repo.update(task);
}
