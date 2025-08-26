import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../core/di/injection.dart';
import '../cubits/auth/auth_cubit.dart';
import '../cubits/auth/auth_state.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';
import '../widgets/loading_overlay.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getIt<AuthCubit>(),
      child: Scaffold(
        body: SafeArea(
          child: BlocConsumer<AuthCubit, AuthState>(
            listener: (context, state) {
              if (state is AuthAuthenticated) {
                context.go('/tasks');
                ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(content: Text('Welcome!')));
              } else if (state is AuthFailure) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(state.message)));
              }
            },
            builder: (context, state) {
              final loading = state is AuthLoading;
              return LoadingOverlay(
                visible: loading,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Tasky',
                                style:
                                    Theme.of(context).textTheme.headlineMedium),
                            const SizedBox(height: 16),
                            AppTextField(
                              controller: _email,
                              autofillHints: const [AutofillHints.email],
                              textInputAction: TextInputAction.next,
                              label: 'Email',
                              keyboardType: TextInputType.emailAddress,
                              validator: (v) => v != null && v.contains('@')
                                  ? null
                                  : 'Provide a valid email',
                            ),
                            const SizedBox(height: 12),
                            AppTextField(
                              controller: _password,
                              label: 'Password',
                              obscure: true,
                              validator: (v) => v != null && v.length >= 6
                                  ? null
                                  : 'Min 6 chars',
                            ),
                            const SizedBox(height: 16),
                            AppButton(
                              label: 'Login',
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  context.read<AuthCubit>().login(
                                      email: _email.text,
                                      password: _password.text);
                                }
                              },
                            ),
                            const SizedBox(height: 8),
                            TextButton(
                                onPressed: () => context.go('/register'),
                                child: const Text('Create account')),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
