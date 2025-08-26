import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/task.dart';
import '../../domain/value_objects/task_status.dart';
import '../cubits/task/task_cubit.dart';
import '../cubits/task/task_state.dart' as s;

extension _IterableX<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

class TaskDetailPage extends StatelessWidget {
  const TaskDetailPage({required this.taskId, super.key, this.task});
  final String taskId;
  final Task? task;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Task Details')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: BlocBuilder<TaskCubit, s.TaskState>(
            builder: (context, state) {
              final existing = task ??
                  state.items
                      .where((t) => t.id == taskId)
                      .cast<Task?>()
                      .firstOrNull;
              if (existing == null) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Task not found'),
                      const SizedBox(height: 12),
                      FilledButton(
                          onPressed: () => Navigator.of(context).maybePop(),
                          child: const Text('Back')),
                    ],
                  ),
                );
              }
              return _TaskEditor(task: existing);
            },
          ),
        ),
      ),
    );
  }
}

class _TaskEditor extends StatefulWidget {
  const _TaskEditor({required this.task});
  final Task task;

  @override
  State<_TaskEditor> createState() => _TaskEditorState();
}

class _TaskEditorState extends State<_TaskEditor> {
  late final TextEditingController _title =
      TextEditingController(text: widget.task.title);
  late final TextEditingController _desc =
      TextEditingController(text: widget.task.description);
  late TaskStatus _status = widget.task.status;

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
            controller: _title,
            decoration: const InputDecoration(labelText: 'Title')),
        const SizedBox(height: 12),
        TextField(
            controller: _desc,
            decoration: const InputDecoration(labelText: 'Description')),
        const SizedBox(height: 12),
        DropdownButtonFormField<TaskStatus>(
          value: _status,
          items: TaskStatus.values
              .map((s) => DropdownMenuItem(value: s, child: Text(s.label)))
              .toList(),
          onChanged: (s) => setState(() => _status = s ?? _status),
          decoration: const InputDecoration(labelText: 'Status'),
        ),
        const Spacer(),
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: () {
                context.read<TaskCubit>().delete(widget.task.id);
                Navigator.of(context).maybePop();
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Task deleted')));
              },
              icon: const Icon(Icons.delete),
              label: const Text('Delete'),
            ),
            const SizedBox(width: 12),
            FilledButton.icon(
              onPressed: () {
                final updated = widget.task.copyWith(
                  title: _title.text,
                  description: _desc.text,
                  status: _status,
                );
                context.read<TaskCubit>().update(updated);
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Task updated')));
              },
              icon: const Icon(Icons.save),
              label: const Text('Save'),
            ),
          ],
        ),
      ],
    );
  }
}
