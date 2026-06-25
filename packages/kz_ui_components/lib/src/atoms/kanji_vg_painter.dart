import 'package:flutter/material.dart';
import 'package:kz_core/kz_core.dart';
import 'package:path_drawing/path_drawing.dart';

class KanjiVgPainter extends CustomPainter {
  KanjiVgPainter({
    required this.svgPaths,
    required this.progress,
    this.strokeColor = CyberTheme.defaultAccent,
  }) : super(repaint: progress);

  final List<String> svgPaths;
  final Animation<double> progress;
  final Color strokeColor;

  // Caché estático global para evitar re-parsear cadenas SVG en cada frame
  static final Map<String, Path> _pathCache = {};

  @override
  void paint(Canvas canvas, Size size) {
    if (svgPaths.isEmpty) return;

    final paint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final scale = size.width / 109.0; // KanjiVG typically uses a 109x109 grid
    canvas.save();
    canvas.scale(scale, scale);

    final totalPaths = svgPaths.length;
    final currentProgress = progress.value * totalPaths;

    for (int i = 0; i < totalPaths; i++) {
      final pathString = svgPaths[i];
      final path = _pathCache.putIfAbsent(
        pathString,
        () => parseSvgPathData(pathString),
      );

      if (i < currentProgress.floor()) {
        // Trazo completamente dibujado
        canvas.drawPath(path, paint);
      } else if (i == currentProgress.floor()) {
        // Trazo en progreso de dibujo
        final metrics = path.computeMetrics().toList();
        if (metrics.isEmpty) continue;

        final localProgress = currentProgress - currentProgress.floor();
        final metric = metrics.first;
        final extractPath = metric.extractPath(
          0,
          metric.length * localProgress,
        );
        canvas.drawPath(extractPath, paint);
      }
      // Los trazos posteriores no se dibujan
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant KanjiVgPainter oldDelegate) {
    return oldDelegate.progress.value != progress.value ||
        oldDelegate.strokeColor != strokeColor ||
        oldDelegate.svgPaths != svgPaths;
  }
}
