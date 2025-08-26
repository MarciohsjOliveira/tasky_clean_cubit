import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tasky_clean_cubit/src/presenter/widgets/empty_state.dart';

Widget _wrap(Widget child) =>
    MaterialApp(home: Scaffold(body: child));

void main() {
  testWidgets('renders default message', (tester) async {
    await tester.pumpWidget(_wrap(const EmptyState()));
    expect(find.byType(Center), findsOneWidget);
    expect(find.byType(Text), findsOneWidget);
    expect(find.text('Nothing here yet.'), findsOneWidget);
  });

  testWidgets('renders custom message', (tester) async {
    await tester.pumpWidget(_wrap(const EmptyState(message: 'No tasks found')));
    expect(find.text('No tasks found'), findsOneWidget);
  });

  testWidgets('Text uses theme (exists under MaterialApp)', (tester) async {
    await tester.pumpWidget(_wrap(const EmptyState(message: 'Themed')));
    final text = tester.widget<Text>(find.text('Themed'));
    expect(text.style, isNotNull);
  });
}
