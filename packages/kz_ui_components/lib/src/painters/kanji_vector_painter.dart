import 'package:flutter/material.dart';
import 'package:path_drawing/path_drawing.dart';
import 'package:kz_core/kz_core.dart';

/// CustomPainter para dibujar vectores de KanjiVG sin cuellos de botella.
/// Soporta modo estático (progress = 1.0) y animado progresivo trazo a trazo.
class KanjiVectorPainter extends CustomPainter {
  KanjiVectorPainter({
    required this.svgPaths,
    required this.accentColor,
    this.progress = 1.0,
  });

  final List<String> svgPaths;
  final Color accentColor;
  final double progress;

  // Caché estático global para evitar re-parsear cadenas SVG en cada frame de pintado
  static final Map<String, Path> _pathCache = {};

  @override
  void paint(Canvas canvas, Size size) {
    if (svgPaths.isEmpty) return;

    final paint = Paint()
      ..color = CyberTheme.textNeutral
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final glowPaint = Paint()
      ..color = accentColor.withValues(alpha: 0.4)
      ..strokeWidth = 6
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10)
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // KanjiVG usa un viewport interno de 109x109
    final scale = size.width / 109.0;
    canvas.save();
    canvas.scale(scale, scale);

    final totalPaths = svgPaths.length;
    // Progreso escalado al número total de trazos
    final scaledProgress = progress * totalPaths;
    final targetPathIndex = scaledProgress.floor();
    final partialPathProgress = scaledProgress - targetPathIndex;

    for (var i = 0; i < totalPaths; i++) {
      if (i > targetPathIndex) break;

      final pathString = svgPaths[i];
      final path = _pathCache.putIfAbsent(
        pathString,
        () => parseSvgPathData(pathString),
      );

      if (i == targetPathIndex) {
        // Dibuja el trazo activo parcialmente (animación)
        if (partialPathProgress > 0) {
          final metrics = path.computeMetrics();
          final partialPath = Path();
          for (final metric in metrics) {
            partialPath.addPath(
              metric.extractPath(0, metric.length * partialPathProgress),
              Offset.zero,
            );
          }
          canvas.drawPath(partialPath, glowPaint);
          canvas.drawPath(partialPath, paint);
        }
      } else {
        // Dibuja trazos ya completados al 100%
        canvas.drawPath(path, glowPaint);
        canvas.drawPath(path, paint);
      }
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(KanjiVectorPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.svgPaths != svgPaths ||
        oldDelegate.accentColor != accentColor;
  }
}
