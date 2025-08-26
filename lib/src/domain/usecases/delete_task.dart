import '../repositories/task_repository.dart';

class DeleteTask {
  const DeleteTask(this._repo);
  final TaskRepository _repo;
  Future<void> call(String id) => _repo.delete(id);
}
