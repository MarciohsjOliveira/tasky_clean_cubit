import 'package:flutter/material.dart';
import '../../domain/entities/task.dart';
import '../../domain/value_objects/task_status.dart';

class TaskCard extends StatelessWidget {
  const TaskCard(
      {required this.task,
      required this.onTap,
      required this.onToggle,
      super.key});

  final Task task;
  final VoidCallback onTap;
  final VoidCallback onToggle;

  Color _bg(TaskStatus s) {
    switch (s) {
      case TaskStatus.pending:
        return Colors.amberAccent.withValues(alpha: 0.08);
      case TaskStatus.inProgress:
        return Colors.lightBlueAccent.withValues(alpha: 0.08);
      case TaskStatus.done:
        return Colors.lightGreen.withValues(alpha: 0.12);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: _bg(task.status),
      child: ListTile(
        title: Text(task.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(task.description,
            maxLines: 2, overflow: TextOverflow.ellipsis),
        trailing: IconButton(
          tooltip: task.status == TaskStatus.done
              ? 'Mark as Pending'
              : 'Mark as Done',
          onPressed: onToggle,
          icon: Icon(task.status == TaskStatus.done
              ? Icons.check_box
              : Icons.check_box_outline_blank),
        ),
        onTap: onTap,
      ),
    );
  }
}
