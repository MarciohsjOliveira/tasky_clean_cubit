import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tasky_clean_cubit/src/presenter/widgets/loading_overlay.dart';

Widget _wrap(Widget child) =>
    MaterialApp(home: Scaffold(body: child));

void main() {
  testWidgets('renders child when not visible', (tester) async {
    await tester.pumpWidget(_wrap(
      const LoadingOverlay(
        visible: false,
        child: Text('content'),
      ),
    ));
    expect(find.text('content'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.byType(ColoredBox), findsNothing);
  });

  testWidgets('shows spinner and dimmed overlay when visible', (tester) async {
    await tester.pumpWidget(_wrap(
     const LoadingOverlay(
        visible: true,
        child: Text('content'),
      ),
    ));
    expect(find.text('content'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byType(ColoredBox), findsOneWidget);
  });

  testWidgets('toggles overlay on visibility change', (tester) async {
    final widget = StatefulBuilder(
      builder: (context, setState) {
        return _ToggleHost(setState: setState);
      },
    );
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));

    expect(find.byType(CircularProgressIndicator), findsNothing);

    await tester.tap(find.text('toggle'));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.tap(find.text('toggle'));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsNothing);
  });
}

class _ToggleHost extends StatefulWidget {
  const _ToggleHost({required this.setState});
  final void Function(VoidCallback) setState;

  @override
  State<_ToggleHost> createState() => _ToggleHostState();
}

class _ToggleHostState extends State<_ToggleHost> {
  bool _visible = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LoadingOverlay(
          visible: _visible,
          child: const Text('content'),
        ),
        TextButton(
          onPressed: () => setState(() => _visible = !_visible),
          child: const Text('toggle'),
        ),
      ],
    );
  }
}
