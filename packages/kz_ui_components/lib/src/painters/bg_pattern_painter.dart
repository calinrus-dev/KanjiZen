import 'package:flutter/material.dart';
import 'package:kz_core/kz_core.dart';

/// PAINTER: Fondo Cyber-Zen Industrial — rejilla de puntos con líneas de acento.
/// Alta eficiencia: repinta solo en cambio de acento (shouldRepaint falso en scroll).
class BgPatternPainter extends CustomPainter {
  const BgPatternPainter({this.accentColor = CyberTheme.defaultAccent});
  final Color accentColor;

  @override
  void paint(Canvas canvas, Size size) {
    // ─── Fondo base obsidian ─────────────────────────────────────────────────
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = CyberTheme.bgObsidian,
    );

    // ─── Dot grid ────────────────────────────────────────────────────────────
    final dotPaint = Paint()..color = accentColor.withValues(alpha: 0.06);
    const spacing = 28.0;
    const dotR = 1.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), dotR, dotPaint);
      }
    }

    // ─── Líneas diagonales tenues (estética circuit-board) ───────────────────
    final linePaint = Paint()
      ..color = accentColor.withValues(alpha: 0.04)
      ..strokeWidth = 0.5;

    // Líneas horizontales cada 84px
    for (double y = 0; y < size.height; y += 84) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }

    // ─── Corner brackets en las 4 esquinas (SVG-style) ───────────────────────
    _drawCornerBracket(canvas, size, accentColor);
  }

  void _drawCornerBracket(Canvas canvas, Size size, Color color) {
    final p = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    const len = 20.0;
    const margin = 12.0;

    // Top-left
    canvas.drawPath(
      Path()
        ..moveTo(margin, margin + len)
        ..lineTo(margin, margin)
        ..lineTo(margin + len, margin),
      p,
    );
    // Top-right
    canvas.drawPath(
      Path()
        ..moveTo(size.width - margin - len, margin)
        ..lineTo(size.width - margin, margin)
        ..lineTo(size.width - margin, margin + len),
      p,
    );
    // Bottom-left
    canvas.drawPath(
      Path()
        ..moveTo(margin, size.height - margin - len)
        ..lineTo(margin, size.height - margin)
        ..lineTo(margin + len, size.height - margin),
      p,
    );
    // Bottom-right
    canvas.drawPath(
      Path()
        ..moveTo(size.width - margin - len, size.height - margin)
        ..lineTo(size.width - margin, size.height - margin)
        ..lineTo(size.width - margin, size.height - margin - len),
      p,
    );
  }

  @override
  bool shouldRepaint(BgPatternPainter old) => old.accentColor != accentColor;
}

/// Widget wrapper para BgPatternPainter.
class BgPattern extends StatelessWidget {
  const BgPattern({super.key, this.accentColor, this.child});
  final Color? accentColor;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: BgPatternPainter(
        accentColor: accentColor ?? CyberTheme.defaultAccent,
      ),
      child: child,
    );
  }
}
