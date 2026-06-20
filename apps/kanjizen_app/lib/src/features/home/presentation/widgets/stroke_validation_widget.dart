import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kz_core/kz_core.dart';
import 'package:kz_domain/kz_domain.dart';
import 'package:kz_ui_components/kz_ui_components.dart';
import 'package:kanjizen_app/src/providers/timeline_provider.dart';

class StrokeValidationWidget extends ConsumerStatefulWidget {
  const StrokeValidationWidget({super.key, required this.node});
  final StrokeValidationNode node;

  @override
  ConsumerState<StrokeValidationWidget> createState() => _StrokeValidationWidgetState();
}

class _StrokeValidationWidgetState extends ConsumerState<StrokeValidationWidget> {
  final List<Offset> _currentStrokePoints = [];

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final accent = _getAccentColor(settings.accentColor);
    final timelineState = ref.watch(timelineProvider);
    final k = widget.node.kanji;

    if (widget.node.isFrozen) {
      // Frozen static view
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.02),
          border: Border.all(color: Colors.white10),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'ENGINE: WRITE 1.0',
                  style: TextStyle(color: Colors.white38, fontSize: 10, fontFamily: 'Courier'),
                ),
                Text(
                  'COMPLETADO',
                  style: TextStyle(color: accent, fontSize: 10, fontFamily: 'Courier', fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'KANJI CALIGRAFIADO: ${k.character} [${k.meanings.first.toUpperCase()}]',
              style: const TextStyle(color: Colors.white, fontSize: 14, fontFamily: 'Courier', fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              'TRAZOS REALIZADOS CORRECTAMENTE: ${k.svgPaths.length}',
              style: TextStyle(color: accent.withValues(alpha: 0.7), fontSize: 11, fontFamily: 'Courier'),
            ),
          ],
        ),
      );
    }

    final opacity = timelineState.isPaused ? 0.2 : 1.0;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            k.meanings.first.toUpperCase(),
            style: TextStyle(
              color: Colors.white38.withValues(alpha: opacity),
              fontSize: 14,
              fontFamily: 'Courier',
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'DIBUJA EL TRAZO ${widget.node.currentStrokeIndex + 1} DE ${k.svgPaths.length}',
            style: TextStyle(
              color: accent.withValues(alpha: 0.5),
              fontSize: 10,
              fontFamily: 'Courier',
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 20),

          // Drawing Area
          SizedBox(
            width: 200,
            height: 200,
            child: GestureDetector(
              onPanStart: (details) {
                if (timelineState.isPaused) return;
                setState(() {
                  _currentStrokePoints.clear();
                  _currentStrokePoints.add(details.localPosition);
                });
              },
              onPanUpdate: (details) {
                if (timelineState.isPaused) return;
                setState(() {
                  _currentStrokePoints.add(details.localPosition);
                });
              },
              onPanEnd: (details) {
                if (timelineState.isPaused) return;
                if (_currentStrokePoints.length >= 2) {
                  ref.read(timelineProvider.notifier).onStrokeCompleted(List.from(_currentStrokePoints));
                }
                setState(() {
                  _currentStrokePoints.clear();
                });
              },
              child: Stack(
                children: [
                  // Dimmed Template Guide (15% opacity)
                  if (settings.writeGuideTemplate)
                    Positioned.fill(
                      child: Opacity(
                        opacity: 0.15 * opacity,
                        child: CustomPaint(
                          painter: KanjiVectorPainter(
                            svgPaths: k.svgPaths,
                            accentColor: accent,
                            progress: 1.0,
                          ),
                        ),
                      ),
                    ),

                  // Snapped strokes so far (neon green/accent)
                  Positioned.fill(
                    child: Opacity(
                      opacity: opacity,
                      child: CustomPaint(
                        painter: KanjiVectorPainter(
                          svgPaths: k.svgPaths,
                          accentColor: accent,
                          progress: widget.node.currentStrokeIndex / k.svgPaths.length,
                        ),
                      ),
                    ),
                  ),

                  // Active user drawing stroke lines
                  Positioned.fill(
                    child: Opacity(
                      opacity: opacity,
                      child: CustomPaint(
                        painter: _UserStrokePainter(
                          points: _currentStrokePoints,
                          accentColor: accent,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getAccentColor(CyberAccent c) {
    switch (c) {
      case CyberAccent.green:
        return CyberTheme.defaultAccent;
      case CyberAccent.red:
        return CyberTheme.errorRed;
      case CyberAccent.orange:
        return Colors.orange;
      case CyberAccent.blue:
        return Colors.cyanAccent;
      case CyberAccent.purple:
        return Colors.purpleAccent;
      case CyberAccent.white:
        return Colors.white;
    }
  }
}

class _UserStrokePainter extends CustomPainter {
  final List<Offset> points;
  final Color accentColor;

  _UserStrokePainter({required this.points, required this.accentColor});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
