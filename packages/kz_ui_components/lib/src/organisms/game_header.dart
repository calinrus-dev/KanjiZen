import 'package:flutter/material.dart';
import 'package:kz_core/kz_core.dart';
import 'package:kz_ui_components/src/molecules/metric_chip.dart';

/// ORGANISM: Header monospace estricto.
class GameHeader extends StatelessWidget {
  const GameHeader({
    super.key,
    required this.streak,
    required this.avgMs,
    required this.hitRate,
    required this.errors,
    required this.accentColor,
    this.onMenuTap,
    this.onSettingsTap,
    this.onPauseTap,
    this.onInventoryTap,
  });

  final int streak;
  final int avgMs;
  final double hitRate;
  final int errors;
  final Color accentColor;
  final VoidCallback? onMenuTap;
  final VoidCallback? onSettingsTap;
  final VoidCallback? onPauseTap;
  final VoidCallback? onInventoryTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: CyberTheme.bgObsidian,
        // Sin bordes inferiores según las especificaciones minimalistas absolutas.
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Menú izquierdo (3 barras)
          if (onMenuTap != null)
            IconButton(
              icon: Icon(Icons.menu, color: accentColor, size: 24),
              onPressed: onMenuTap,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          const SizedBox(width: 16),

          // Métricas CRUDAS alineadas
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _RawMetric(label: 'Racha', value: '$streak', color: accentColor),
                const SizedBox(width: 12),
                _RawMetric(label: 'ms', value: avgMs > 0 ? '$avgMs' : '---', color: accentColor),
                const SizedBox(width: 12),
                _RawMetric(label: 'A', value: '${(hitRate * 100).toStringAsFixed(0)}%', color: accentColor),
                const SizedBox(width: 12),
                _RawMetric(label: 'E', value: '$errors', color: CyberTheme.errorRed),
              ],
            ),
          ),

          // Inventario, Pausa y Ajustes
          if (onInventoryTap != null)
            IconButton(
              icon: Icon(Icons.inventory_2_outlined, color: accentColor, size: 24),
              onPressed: onInventoryTap,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          const SizedBox(width: 16),
          if (onPauseTap != null)
            IconButton(
              icon: Icon(Icons.pause, color: accentColor, size: 24),
              onPressed: onPauseTap,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          const SizedBox(width: 16),
          if (onSettingsTap != null)
            IconButton(
              icon: Icon(Icons.settings, color: accentColor, size: 24),
              onPressed: onSettingsTap,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }
}

class _RawMetric extends StatelessWidget {
  const _RawMetric({required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('[$label:', style: TextStyle(color: color.withValues(alpha: 0.5), fontFamily: 'Courier', fontSize: 12)),
        const SizedBox(width: 4),
        Text('$value]', style: TextStyle(color: color, fontFamily: 'Courier', fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
