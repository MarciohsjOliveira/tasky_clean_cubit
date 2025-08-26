import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tasky_clean_cubit/src/presenter/widgets/status_filter_bar.dart';
import 'package:tasky_clean_cubit/src/domain/value_objects/task_status.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  testWidgets('renders All and one chip per TaskStatus', (tester) async {
    await tester.pumpWidget(_wrap(const StatusFilterBar(onChanged: _noop)));
    expect(
        find.byType(ChoiceChip), findsNWidgets(1 + TaskStatus.values.length));
    expect(find.text('All'), findsOneWidget);
    expect(find.text(TaskStatus.pending.label), findsOneWidget);
    expect(find.text(TaskStatus.inProgress.label), findsOneWidget);
    expect(find.text(TaskStatus.done.label), findsOneWidget);
  });

  testWidgets('All is selected when value is null', (tester) async {
    await tester.pumpWidget(_wrap(const StatusFilterBar(onChanged: _noop)));
    final allChip =
        tester.widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'All'));
    expect(allChip.selected, isTrue);
  });

  testWidgets('selecting a status calls onChanged with that status',
      (tester) async {
    TaskStatus? received;
    await tester.pumpWidget(_wrap(StatusFilterBar(
      onChanged: (v) => received = v,
    )));
    await tester.tap(find.text(TaskStatus.pending.label));
    await tester.pump();
    expect(received, TaskStatus.pending);
  });

  testWidgets('tapping All calls onChanged with null', (tester) async {
    TaskStatus? received = TaskStatus.done;
    await tester.pumpWidget(_wrap(StatusFilterBar(
      value: TaskStatus.done,
      onChanged: (v) => received = v,
    )));
    await tester.tap(find.text('All'));
    await tester.pump();
    expect(received, isNull);
  });

  testWidgets('selection reflects value prop', (tester) async {
    await tester.pumpWidget(_wrap(const StatusFilterBar(
      value: TaskStatus.inProgress,
      onChanged: _noop,
    )));
    final chipInProgress = tester.widget<ChoiceChip>(
        find.widgetWithText(ChoiceChip, TaskStatus.inProgress.label));
    final chipPending = tester.widget<ChoiceChip>(
        find.widgetWithText(ChoiceChip, TaskStatus.pending.label));
    final chipDone = tester.widget<ChoiceChip>(
        find.widgetWithText(ChoiceChip, TaskStatus.done.label));
    final chipAll =
        tester.widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'All'));
    expect(chipInProgress.selected, isTrue);
    expect(chipPending.selected, isFalse);
    expect(chipDone.selected, isFalse);
    expect(chipAll.selected, isFalse);
  });

  testWidgets('layout uses Wrap with expected spacing', (tester) async {
    await tester.pumpWidget(_wrap(const StatusFilterBar(onChanged: _noop)));
    final wrap = tester.widget<Wrap>(find.byType(Wrap));
    expect(wrap.spacing, 8);
    expect(wrap.runSpacing, 8);
    expect(wrap.crossAxisAlignment, WrapCrossAlignment.center);
  });

  testWidgets('integrated state change via ValueListenable', (tester) async {
    final notifier = ValueNotifier<TaskStatus?>(null);
    await tester.pumpWidget(_wrap(ValueListenableBuilder<TaskStatus?>(
      valueListenable: notifier,
      builder: (context, value, _) {
        return StatusFilterBar(
          value: value,
          onChanged: (v) => notifier.value = v,
        );
      },
    )));
    expect(
      tester
          .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'All'))
          .selected,
      isTrue,
    );
    await tester.tap(find.text(TaskStatus.done.label));
    await tester.pump();
    expect(notifier.value, TaskStatus.done);
    expect(
      tester
          .widget<ChoiceChip>(
              find.widgetWithText(ChoiceChip, TaskStatus.done.label))
          .selected,
      isTrue,
    );
    await tester.tap(find.text('All'));
    await tester.pump();
    expect(notifier.value, isNull);
    expect(
      tester
          .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'All'))
          .selected,
      isTrue,
    );
  });
}

void _noop(TaskStatus? _) {}
