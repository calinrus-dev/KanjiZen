import 'dart:math';
import 'package:flutter/material.dart';
import 'package:kz_core/kz_core.dart';
import 'package:kz_domain/kz_domain.dart';

/// ATOM: Badge de Tier con estilo Cyber-Zen Industrial.
/// CustomPainter que dibuja un hexágono con el label del tier.
class TierBadge extends StatelessWidget {
  const TierBadge({super.key, required this.tier, this.size = 32});

  final KanaTier tier;
  final double size;

  Color get _color => switch (tier) {
    KanaTier.e => const Color(0xFF546E7A),
    KanaTier.d => const Color(0xFF78909C),
    KanaTier.c => CyberTheme.defaultAccent,
    KanaTier.b => const Color(0xFF29B6F6),
    KanaTier.a => const Color(0xFFFF7043),
    KanaTier.s => const Color(0xFFFFD700),
  };

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _TierHexPainter(color: _color, label: tier.label),
      ),
    );
  }
}

class _TierHexPainter extends CustomPainter {
  const _TierHexPainter({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2 - 1;

    final path = Path();
    for (var i = 0; i < 6; i++) {
      final angle = (i * 60 - 30) * (pi / 180);
      final x = cx + r * cos(angle);
      final y = cy + r * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    canvas.drawPath(
      path,
      Paint()
        ..color = color.withOpacity(0.15)
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    final tp = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: color,
          fontSize: size.width * 0.35,
          fontWeight: FontWeight.w900,
          fontFamily: 'Courier',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(cx - tp.width / 2, cy - tp.height / 2));
  }

  @override
  bool shouldRepaint(_TierHexPainter old) =>
      old.color != color || old.label != label;
}
