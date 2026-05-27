import 'package:flutter/material.dart';

class HeatModeCard extends StatelessWidget {
  const HeatModeCard({
    super.key,
    required this.enabled,
    required this.onChanged,
  });

  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SwitchListTile(
        value: enabled,
        onChanged: onChanged,
        title: const Text('Mode chaleur ☀️'),
        subtitle: const Text('Rappels plus frequents et ton chaleur.'),
      ),
    );
  }
}
