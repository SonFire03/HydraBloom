import 'package:flutter/material.dart';

class HeatModeCard extends StatelessWidget {
  const HeatModeCard({
    super.key,
    required this.enabled,
    required this.onChanged,
    this.title = 'Mode chaleur ☀️',
    this.subtitle = 'Rappels plus frequents et ton chaleur.',
  });

  final bool enabled;
  final ValueChanged<bool> onChanged;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SwitchListTile(
        value: enabled,
        onChanged: onChanged,
        title: Text(title),
        subtitle: Text(subtitle),
      ),
    );
  }
}
