import 'package:equatable/equatable.dart';
import '../../../domain/entities/task.dart';
import '../../../domain/value_objects/task_status.dart';

enum TaskStatusUI { idle, loading, success, failure }

class TaskState extends Equatable {
  const TaskState({
    this.items = const <Task>[],
    this.status = TaskStatusUI.idle,
    this.errorMessage,
    this.filterStatus,
    this.from,
    this.to,
  });

  final List<Task> items;
  final TaskStatusUI status;
  final String? errorMessage;
  final TaskStatus? filterStatus;
  final DateTime? from;
  final DateTime? to;

  TaskState copyWith({
    List<Task>? items,
    TaskStatusUI? status,
    String? errorMessage,
    TaskStatus? filterStatus,
    DateTime? from,
    DateTime? to,
    bool resetFilter = false,
    bool resetFrom = false,
    bool resetTo = false,
  }) {
    return TaskState(
      items: items ?? this.items,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      filterStatus: resetFilter ? null : (filterStatus ?? this.filterStatus),
      from: resetFrom ? null : (from ?? this.from),
      to: resetTo ? null : (to ?? this.to),
    );
  }

  @override
  List<Object?> get props =>
      [items, status, errorMessage, filterStatus, from, to];
}
