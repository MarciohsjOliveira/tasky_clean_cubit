import '../entities/task.dart';
import '../repositories/task_repository.dart';

class CreateTask {
  const CreateTask(this._repo);
  final TaskRepository _repo;
  Future<Task> call({
    required String title,
    required String description,
    DateTime? dueDate,
  }) {
    return _repo.create(
      title: title,
      description: description,
      dueDate: dueDate,
    );
  }
}
