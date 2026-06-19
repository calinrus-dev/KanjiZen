import 'package:flutter/material.dart';
import 'package:kz_core/kz_core.dart';
import '../painters/activity_graph_painter.dart';

/// ORGANISM: Activity Graph completo — 7×52 heatmap con título y leyenda.
class ActivityGraph extends StatelessWidget {
  const ActivityGraph({
    super.key,
    required this.dailyActivity,
    this.accentColor,
  });

  final List<double> dailyActivity;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final accent = accentColor ?? CyberTheme.defaultAccent;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ─── Título ────────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Text(
                'ACTIVIDAD',
                style: TextStyle(
                  color: accent,
                  fontFamily: 'Courier',
                  fontSize: 11,
                  letterSpacing: 2,
                ),
              ),
              const Spacer(),
              Text(
                '365 días',
                style: TextStyle(
                  color: CyberTheme.textNeutral.withOpacity(0.3),
                  fontFamily: 'Courier',
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),

        // ─── Heatmap ────────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: AspectRatio(
            aspectRatio: 52 / 7,
            child: CustomPaint(
              painter: ActivityGraphPainter(
                dailyActivity: _padActivity(),
                accentColor: accent,
              ),
            ),
          ),
        ),

        // ─── Leyenda ────────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Menos',
                style: TextStyle(
                  color: CyberTheme.textNeutral.withOpacity(0.3),
                  fontSize: 9,
                  fontFamily: 'Courier',
                ),
              ),
              const SizedBox(width: 4),
              ...List.generate(
                5,
                (i) => Container(
                  width: 10,
                  height: 10,
                  margin: const EdgeInsets.symmetric(horizontal: 1),
                  decoration: BoxDecoration(
                    color: i == 0
                        ? const Color(0xFF1A1D26)
                        : accent.withOpacity(0.15 + i * 0.21),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'Más',
                style: TextStyle(
                  color: CyberTheme.textNeutral.withOpacity(0.3),
                  fontSize: 9,
                  fontFamily: 'Courier',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<double> _padActivity() {
    const total = 52 * 7;
    if (dailyActivity.length >= total) return dailyActivity.sublist(0, total);
    return [
      ...List.filled(total - dailyActivity.length, 0.0),
      ...dailyActivity,
    ];
  }
}
