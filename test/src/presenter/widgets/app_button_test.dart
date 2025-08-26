import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tasky_clean_cubit/src/presenter/widgets/app_button.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  testWidgets('renders label and ElevatedButton', (tester) async {
    await tester.pumpWidget(_wrap(const AppButton(label: 'Tap Me', onPressed: _noop)));
    expect(find.byType(ElevatedButton), findsOneWidget);
    expect(find.text('Tap Me'), findsOneWidget);
  });

  testWidgets('invokes onPressed once when tapped', (tester) async {
    var taps = 0;
    await tester.pumpWidget(_wrap(AppButton(label: 'Go', onPressed: () => taps++)));
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();
    expect(taps, 1);
  });

  testWidgets('expands to max available width', (tester) async {
    const parentWidth = 320.0;
    await tester.pumpWidget(_wrap(
      const Center(
        child: SizedBox(
          width: parentWidth,
          child: AppButton(label: 'Wide', onPressed: _noop),
        ),
      ),
    ));
    final size = tester.getSize(find.byType(ElevatedButton));
    expect(size.width, parentWidth);
  });
}

void _noop() {}
