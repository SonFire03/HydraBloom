import 'package:flutter/material.dart';

class CuteActionButton extends StatelessWidget {
  const CuteActionButton({super.key, required this.onPressed, required this.label});

  final VoidCallback onPressed;
  final String label;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.water_drop_rounded),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
      style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(54)),
    );
  }
}
