import 'package:flutter/material.dart';
import 'package:kz_core/kz_core.dart';
import '../molecules/metric_chip.dart';

/// ORGANISM: Header monospace del juego.
/// Fila: [Racha: X] [XXX ms] [A: XX%] [E: X]
class GameHeader extends StatelessWidget {
  const GameHeader({
    super.key,
    required this.streak,
    required this.avgMs,
    required this.hitRate,
    required this.errors,
    this.accentColor,
    this.onMenuTap,
    this.onInventoryTap,
    this.onSettingsTap,
  });

  final int streak;
  final int avgMs;
  final double hitRate;
  final int errors;
  final Color? accentColor;
  final VoidCallback? onMenuTap;
  final VoidCallback? onInventoryTap;
  final VoidCallback? onSettingsTap;

  @override
  Widget build(BuildContext context) {
    final accent = accentColor ?? CyberTheme.defaultAccent;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: accent.withOpacity(0.15), width: 1),
        ),
      ),
      child: Row(
        children: [
          // Menú izquierdo
          if (onMenuTap != null)
            GestureDetector(
              onTap: onMenuTap,
              child: Icon(
                Icons.person_outline,
                color: accent.withOpacity(0.6),
                size: 20,
              ),
            ),
          const SizedBox(width: 12),

          // Métricas
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MetricChip(
                  label: 'Racha',
                  value: '$streak',
                  accentColor: accent,
                ),
                const SizedBox(width: 16),
                MetricChip(
                  label: 'ms',
                  value: avgMs > 0 ? '$avgMs' : '---',
                  accentColor: accent,
                ),
                const SizedBox(width: 16),
                MetricChip(
                  label: 'A',
                  value: '${(hitRate * 100).toStringAsFixed(0)}%',
                  accentColor: accent,
                ),
                const SizedBox(width: 16),
                MetricChip(
                  label: 'E',
                  value: '$errors',
                  accentColor: CyberTheme.errorRed,
                ),
              ],
            ),
          ),

          // Ajustes y Menú derecho
          const SizedBox(width: 12),
          if (onInventoryTap != null)
            GestureDetector(
              onTap: onInventoryTap,
              child: Icon(Icons.inventory_2_outlined, color: accent.withValues(alpha: 0.6), size: 20),
            ),
          const SizedBox(width: 8),
          if (onSettingsTap != null)
            GestureDetector(
              onTap: onSettingsTap,
              child: Icon(Icons.tune, color: accent.withValues(alpha: 0.6), size: 20),
            ),
        ],
      ),
    );
  }
}
