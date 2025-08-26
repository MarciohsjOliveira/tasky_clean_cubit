import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tasky_clean_cubit/src/presenter/widgets/task_card.dart';
import 'package:tasky_clean_cubit/src/domain/entities/task.dart';
import 'package:tasky_clean_cubit/src/domain/value_objects/task_status.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

Task _task({
  String id = 't1',
  String title = 'Title',
  String description = 'Desc',
  TaskStatus status = TaskStatus.pending,
}) {
  return Task(
    id: id,
    title: title,
    description: description,
    status: status,
    createdAt: DateTime(2024,),
  );
}

void main() {
  testWidgets('renders title and description', (tester) async {
    final task = _task(title: 'A', description: 'B');
    await tester.pumpWidget(_wrap(TaskCard(
      task: task,
      onTap: () {},
      onToggle: () {},
    )));
    expect(find.text('A'), findsOneWidget);
    expect(find.text('B'), findsOneWidget);
  });

  testWidgets('background color reflects pending status', (tester) async {
    final task = _task();
    await tester.pumpWidget(_wrap(TaskCard(
      task: task,
      onTap: () {},
      onToggle: () {},
    )));
    final card = tester.widget<Card>(find.byType(Card));
    expect(card.color, Colors.amberAccent.withValues(alpha: 0.08));
  });

  testWidgets('background color reflects inProgress status', (tester) async {
    final task = _task(status: TaskStatus.inProgress);
    await tester.pumpWidget(_wrap(TaskCard(
      task: task,
      onTap: () {},
      onToggle: () {},
    )));
    final card = tester.widget<Card>(find.byType(Card));
    expect(card.color, Colors.lightBlueAccent.withValues(alpha: 0.08));
  });

  testWidgets('background color reflects done status', (tester) async {
    final task = _task(status: TaskStatus.done);
    await tester.pumpWidget(_wrap(TaskCard(
      task: task,
      onTap: () {},
      onToggle: () {},
    )));
    final card = tester.widget<Card>(find.byType(Card));
    expect(card.color, Colors.lightGreen.withValues(alpha: 0.12));
  });

  testWidgets('shows outlined checkbox when not done', (tester) async {
    final task = _task(status: TaskStatus.inProgress);
    await tester.pumpWidget(_wrap(TaskCard(
      task: task,
      onTap: () {},
      onToggle: () {},
    )));
    expect(find.byIcon(Icons.check_box_outline_blank), findsOneWidget);
    expect(find.byIcon(Icons.check_box), findsNothing);
    expect(find.byTooltip('Mark as Done'), findsOneWidget);
  });

  testWidgets('shows checked checkbox when done', (tester) async {
    final task = _task(status: TaskStatus.done);
    await tester.pumpWidget(_wrap(TaskCard(
      task: task,
      onTap: () {},
      onToggle: () {},
    )));
    expect(find.byIcon(Icons.check_box), findsOneWidget);
    expect(find.byIcon(Icons.check_box_outline_blank), findsNothing);
    expect(find.byTooltip('Mark as Pending'), findsOneWidget);
  });

  testWidgets('tapping trailing icon triggers onToggle', (tester) async {
    int toggles = 0;
    final task = _task();
    await tester.pumpWidget(_wrap(TaskCard(
      task: task,
      onTap: () {},
      onToggle: () => toggles++,
    )));
    await tester.tap(find.byType(IconButton));
    await tester.pump();
    expect(toggles, 1);
  });

  testWidgets('tapping tile triggers onTap', (tester) async {
    var taps = 0;
    final task = _task();
    await tester.pumpWidget(_wrap(TaskCard(
      task: task,
      onTap: () => taps++,
      onToggle: () {},
    )));
    await tester.tap(find.byType(ListTile));
    await tester.pump();
    expect(taps, 1);
  });
}
