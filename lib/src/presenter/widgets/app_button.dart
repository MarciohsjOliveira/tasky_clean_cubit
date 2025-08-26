import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  const AppButton({required this.onPressed, required this.label, super.key});
  final VoidCallback onPressed;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(onPressed: onPressed, child: Text(label)),
    );
  }
}
