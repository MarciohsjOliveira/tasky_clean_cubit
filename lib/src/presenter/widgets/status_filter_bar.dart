import 'package:flutter/material.dart';
import '../../domain/value_objects/task_status.dart';

class StatusFilterBar extends StatelessWidget {
  const StatusFilterBar({required this.onChanged, super.key, this.value});
  final TaskStatus? value;
  final void Function(TaskStatus?) onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        ChoiceChip(
            label: const Text('All'),
            selected: value == null,
            onSelected: (_) => onChanged(null)),
        for (final s in TaskStatus.values)
          ChoiceChip(
              label: Text(s.label),
              selected: value == s,
              onSelected: (_) => onChanged(s)),
      ],
    );
  }
}
