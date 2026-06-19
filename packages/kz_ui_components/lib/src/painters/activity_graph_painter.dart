import 'package:flutter/material.dart';
import 'package:kz_core/kz_core.dart';

/// PAINTER: Activity Graph — rejilla 7×52 (365 días) estilo GitHub heatmap.
/// Decodifica historyBlob para mapear saturación de color por día.
class ActivityGraphPainter extends CustomPainter {
  const ActivityGraphPainter({
    required this.dailyActivity,
    this.accentColor = CyberTheme.defaultAccent,
  });

  /// Lista de 365 entradas (0.0–1.0) de actividad por día, más reciente al final.
  final List<double> dailyActivity;
  final Color accentColor;

  @override
  void paint(Canvas canvas, Size size) {
    const cols = 52;
    const rows = 7;
    final cellW = size.width / cols;
    final cellH = size.height / rows;
    const gap = 2.0;

    for (var col = 0; col < cols; col++) {
      for (var row = 0; row < rows; row++) {
        final dayIdx = col * rows + row;
        final activity = dayIdx < dailyActivity.length
            ? dailyActivity[dayIdx]
            : 0.0;

        final rect = RRect.fromRectAndRadius(
          Rect.fromLTWH(
            col * cellW + gap / 2,
            row * cellH + gap / 2,
            cellW - gap,
            cellH - gap,
          ),
          const Radius.circular(2),
        );

        canvas.drawRRect(
          rect,
          Paint()
            ..color = activity > 0
                ? accentColor.withOpacity(0.15 + activity * 0.85)
                : const Color(0xFF1A1D26),
        );
      }
    }
  }

  @override
  bool shouldRepaint(ActivityGraphPainter old) =>
      old.dailyActivity != dailyActivity || old.accentColor != accentColor;
}
