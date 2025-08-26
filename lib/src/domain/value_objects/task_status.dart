enum TaskStatus { pending, inProgress, done }

extension TaskStatusX on TaskStatus {
  String get label => switch (this) {
        TaskStatus.pending => 'Pending',
        TaskStatus.inProgress => 'In Progress',
        TaskStatus.done => 'Done',
      };

  static TaskStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'inprogress':
      case 'in_progress':
        return TaskStatus.inProgress;
      case 'done':
      case 'completed':
        return TaskStatus.done;
      default:
        return TaskStatus.pending;
    }
  }
}
