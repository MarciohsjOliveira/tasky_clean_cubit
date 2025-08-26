import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/task.dart';
import '../../../domain/repositories/task_repository.dart' as repo;
import '../../../domain/usecases/create_task.dart';
import '../../../domain/usecases/delete_task.dart';
import '../../../domain/usecases/get_tasks.dart';
import '../../../domain/usecases/toggle_complete.dart';
import '../../../domain/usecases/update_task.dart';
import '../../../domain/value_objects/task_status.dart';
import 'task_state.dart' as s;

class TaskCubit extends Cubit<s.TaskState> {
  TaskCubit({
    required GetTasks getTasks,
    required CreateTask createTask,
    required UpdateTask updateTask,
    required DeleteTask deleteTask,
    required ToggleComplete toggleComplete,
  })  : _get = getTasks,
        _create = createTask,
        _update = updateTask,
        _delete = deleteTask,
        _toggle = toggleComplete,
        super(const s.TaskState());

  final GetTasks _get;
  final CreateTask _create;
  final UpdateTask _update;
  final DeleteTask _delete;
  final ToggleComplete _toggle;

  Future<void> load(
      {TaskStatus? status,
      DateTime? from,
      DateTime? to,
      bool clearStatus = false,
      bool resetFrom = false,
      bool resetTo = false}) async {
    final statusFinal = clearStatus ? null : (status ?? state.filterStatus);
    final fromFinal = resetFrom ? null : (from ?? state.from);
    final toFinal = resetTo ? null : (to ?? state.to);
    final filter =
        repo.TaskFilter(status: statusFinal, from: fromFinal, to: toFinal);

    emit(state.copyWith(
        status: s.TaskStatusUI.loading,
        filterStatus: filter.status,
        from: filter.from,
        to: filter.to,
        resetFilter: filter.status == null,
        resetFrom: filter.from == null,
        resetTo: filter.to == null));
    try {
      final items = await _get(filter: filter);
      emit(state.copyWith(items: items, status: s.TaskStatusUI.success));
    } catch (e) {
      emit(state.copyWith(status: s.TaskStatusUI.failure, errorMessage: '$e'));
    }
  }

  Future<void> reload() =>
      load(status: state.filterStatus, from: state.from, to: state.to);

  Future<Task?> create(
      {required String title,
      required String description,
      DateTime? dueDate}) async {
    try {
      final created = await _create(
          title: title, description: description, dueDate: dueDate);
      emit(state.copyWith(items: [created, ...state.items]));
      await reload();
      return created;
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Create failed: $e'));
      return null;
    }
  }

  Future<void> delete(String id) async {
    try {
      await _delete(id);
      emit(
          state.copyWith(items: state.items.where((e) => e.id != id).toList()));
      await reload();
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Delete failed: $e'));
    }
  }

  Future<void> update(Task task) async {
    try {
      final updated = await _update(task);
      emit(state.copyWith(
          items:
              state.items.map((t) => t.id == task.id ? updated : t).toList()));
      await reload();
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Update failed: $e'));
    }
  }

  Future<void> toggle(String id) async {
    try {
      final updated = await _toggle(id);
      emit(state.copyWith(
          items: state.items.map((e) => e.id == id ? updated : e).toList()));
      await reload();
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Toggle failed: $e'));
    }
  }
}
