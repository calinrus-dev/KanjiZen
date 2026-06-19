import 'package:flutter/material.dart';
import 'package:kz_core/kz_core.dart';

/// MOLECULE: Chip de métrica monospace para el header de juego.
/// Formato: [label: value]
class MetricChip extends StatelessWidget {
  const MetricChip({
    super.key,
    required this.label,
    required this.value,
    this.accentColor,
  });

  final String label;
  final String value;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final accent = accentColor ?? CyberTheme.defaultAccent;
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontFamily: 'Courier', fontSize: 12),
        children: [
          TextSpan(
            text: '$label:',
            style: TextStyle(color: CyberTheme.textNeutral.withOpacity(0.5)),
          ),
          const TextSpan(text: ' '),
          TextSpan(
            text: value,
            style: TextStyle(color: accent, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
