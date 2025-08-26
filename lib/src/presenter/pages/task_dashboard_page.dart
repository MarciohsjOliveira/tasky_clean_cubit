import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../cubits/task/task_cubit.dart';
import '../cubits/task/task_state.dart' as s;
import '../widgets/empty_state.dart';
import '../widgets/status_filter_bar.dart';
import '../widgets/task_card.dart';

class TaskDashboardPage extends StatefulWidget {
  const TaskDashboardPage({super.key});
  @override
  State<TaskDashboardPage> createState() => _TaskDashboardPageState();
}

class _TaskDashboardPageState extends State<TaskDashboardPage> {
  DateTimeRange? _range;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Tasks')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BlocBuilder<TaskCubit, s.TaskState>(
                builder: (context, state) {
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final isNarrow = constraints.maxWidth < 420;
                      final chips = StatusFilterBar(
                        value: state.filterStatus,
                        onChanged: (st) {
                          if (st == null) {
                            context.read<TaskCubit>().load(
                                clearStatus: true,
                                from: state.from,
                                to: state.to);
                          } else {
                            context.read<TaskCubit>().load(
                                status: st, from: state.from, to: state.to);
                          }
                        },
                      );

                      final dateControls = Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 260),
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                final now = DateTime.now();
                                final picked = await showDateRangePicker(
                                  context: context,
                                  firstDate: DateTime(now.year - 1),
                                  lastDate: DateTime(now.year + 1),
                                );
                                if (!mounted) return;
                                if (picked != null) {
                                  setState(() => _range = picked);
                                  final from = DateTime(picked.start.year,
                                      picked.start.month, picked.start.day);
                                  final to = DateTime(
                                      picked.end.year,
                                      picked.end.month,
                                      picked.end.day,
                                      23,
                                      59,
                                      59);
                                  await context
                                      .read<TaskCubit>()
                                      .load(from: from, to: to);
                                }
                              },
                              icon: const Icon(Icons.filter_alt_outlined,
                                  size: 18),
                              label: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(_range == null
                                    ? 'Date range'
                                    : '${_range!.start.toString().split(' ').first} → ${_range!.end.toString().split(' ').first}'),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (_range != null)
                            TextButton(
                              onPressed: () {
                                setState(() => _range = null);
                                context
                                    .read<TaskCubit>()
                                    .load(resetFrom: true, resetTo: true);
                              },
                              child: const Text('Clear'),
                            ),
                        ],
                      );

                      if (isNarrow) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            chips,
                            const SizedBox(height: 8),
                            dateControls,
                          ],
                        );
                      } else {
                        return Row(
                          children: [
                            Expanded(
                                child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: chips)),
                            const SizedBox(width: 12),
                            Align(
                                alignment: Alignment.centerRight,
                                child: dateControls),
                          ],
                        );
                      }
                    },
                  );
                },
              ),
              const SizedBox(height: 16),
              Expanded(
                child: BlocBuilder<TaskCubit, s.TaskState>(
                  builder: (context, state) {
                    if (state.items.isEmpty) {
                      return const EmptyState(
                          message: 'No tasks found for the current filters');
                    }
                    final isWide = MediaQuery.of(context).size.width >= 900;
                    if (!isWide) {
                      return ListView.separated(
                        itemCount: state.items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, i) {
                          final t = state.items[i];
                          return Dismissible(
                            key: ValueKey(t.id),
                            background: Container(
                                color: Colors.redAccent.withValues(alpha: 0.2)),
                            onDismissed: (_) async {
                              final cubit = context.read<TaskCubit>();
                              await cubit.delete(t.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('Task deleted'),
                                  action: SnackBarAction(
                                    label: 'UNDO',
                                    onPressed: () {
                                      cubit.create(
                                          title: t.title,
                                          description: t.description,
                                          dueDate: t.dueDate);
                                    },
                                  ),
                                ),
                              );
                            },
                            child: TaskCard(
                              task: t,
                              onTap: () =>
                                  context.go('/tasks/${t.id}', extra: t),
                              onToggle: () =>
                                  context.read<TaskCubit>().toggle(t.id),
                            ),
                          );
                        },
                      );
                    } else {
                      return GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount:
                              (MediaQuery.of(context).size.width >= 1200)
                                  ? 4
                                  : (MediaQuery.of(context).size.width >= 900
                                      ? 3
                                      : 2),
                          mainAxisExtent: 120,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: state.items.length,
                        itemBuilder: (context, i) {
                          final t = state.items[i];
                          return Dismissible(
                            key: ValueKey('g_${t.id}'),
                            direction: DismissDirection.up,
                            background: Container(
                                color: Colors.redAccent.withValues(alpha: 0.2)),
                            onDismissed: (_) async {
                              final cubit = context.read<TaskCubit>();
                              await cubit.delete(t.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('Task deleted'),
                                  action: SnackBarAction(
                                    label: 'UNDO',
                                    onPressed: () {
                                      cubit.create(
                                          title: t.title,
                                          description: t.description,
                                          dueDate: t.dueDate);
                                    },
                                  ),
                                ),
                              );
                            },
                            child: TaskCard(
                              task: t,
                              onTap: () =>
                                  context.go('/tasks/${t.id}', extra: t),
                              onToggle: () =>
                                  context.read<TaskCubit>().toggle(t.id),
                            ),
                          );
                        },
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            FloatingActionButton.extended(
              heroTag: 'reloadFab',
              onPressed: () => context.read<TaskCubit>().reload(),
              icon: const Icon(Icons.refresh),
              label: const Text('Reload'),
            ),
            FloatingActionButton.extended(
              heroTag: 'addFab',
              onPressed: () => _openCreateDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Add Task'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openCreateDialog(BuildContext context) async {
    final title = TextEditingController();
    final desc = TextEditingController();
    DateTime? due;

    final rootCtx = context;

    await showDialog<void>(
      context: rootCtx,
      builder: (dialogCtx) {
        return AlertDialog(
          title: const Text('New Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: title,
                  decoration: const InputDecoration(labelText: 'Title')),
              const SizedBox(height: 8),
              TextField(
                  controller: desc,
                  decoration: const InputDecoration(labelText: 'Description')),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () async {
                  final now = DateTime.now();
                  final picked = await showDatePicker(
                    context: dialogCtx,
                    firstDate: DateTime(now.year - 1),
                    lastDate: DateTime(now.year + 2),
                    initialDate: now,
                  );
                  if (picked != null) due = picked;
                },
                icon: const Icon(Icons.event),
                label: Text(due == null
                    ? 'Due date'
                    : due!.toString().split(' ').first),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(dialogCtx),
                child: const Text('Cancel')),
            FilledButton(
              onPressed: () async {
                final created = await rootCtx.read<TaskCubit>().create(
                      title: title.text,
                      description: desc.text,
                      dueDate: due,
                    );

                Navigator.pop(dialogCtx);

                if (created != null) {
                  await rootCtx.push('/tasks/${created.id}', extra: {
                    'task': created,
                    'justCreated': true,
                  });
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }
}
