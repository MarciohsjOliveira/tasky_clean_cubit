import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tasky_clean_cubit/src/presenter/widgets/app_text_field.dart';

Widget _wrap(Widget child) =>
    MaterialApp(home: Scaffold(body: Padding(padding: const EdgeInsets.all(16), child: child)));

Widget _wrapInForm(GlobalKey<FormState> key, Widget field) =>
    _wrap(Form(key: key, child: field));

void main() {
  testWidgets('renders TextFormField with label text', (tester) async {
    final c = TextEditingController();
    await tester.pumpWidget(_wrap(AppTextField(controller: c, label: 'Email')));
    expect(find.byType(TextFormField), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
  });

  testWidgets('obscureText false by default, true when requested', (tester) async {
    final c1 = TextEditingController();
    await tester.pumpWidget(_wrap(AppTextField(controller: c1, label: 'Pwd')));
    EditableText e = tester.widget(find.byType(EditableText));
    expect(e.obscureText, isFalse);

    final c2 = TextEditingController();
    await tester.pumpWidget(_wrap(AppTextField(controller: c2, label: 'Pwd', obscure: true)));
    e = tester.widget(find.byType(EditableText));
    expect(e.obscureText, isTrue);
  });

  testWidgets('validator shows error message', (tester) async {
    final key = GlobalKey<FormState>();
    final c = TextEditingController();
    await tester.pumpWidget(_wrapInForm(
      key,
      AppTextField(
        controller: c,
        label: 'Name',
        validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
      ),
    ));
    key.currentState!.validate();
    await tester.pump();
    expect(find.text('Required'), findsOneWidget);
  });

  testWidgets('updates controller when user types', (tester) async {
    final c = TextEditingController();
    await tester.pumpWidget(_wrap(AppTextField(controller: c, label: 'Title')));
    await tester.enterText(find.byType(TextFormField), 'hello');
    expect(c.text, 'hello');
  });

  testWidgets('shows initial controller text', (tester) async {
    final c = TextEditingController(text: 'prefill');
    await tester.pumpWidget(_wrap(AppTextField(controller: c, label: 'X')));
    expect(find.text('prefill'), findsOneWidget);
  });
}
