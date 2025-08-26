import '../entities/task.dart';
import '../repositories/task_repository.dart';

class GetTasks {
  const GetTasks(this._repo);
  final TaskRepository _repo;
  Future<List<Task>> call({TaskFilter? filter}) => _repo.list(filter: filter);
}
