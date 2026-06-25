import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:kz_core/kz_core.dart';
import 'package:kz_domain/kz_domain.dart';
import 'package:kz_ui_components/src/atoms/tier_badge.dart';
import 'package:kz_ui_components/src/painters/kanji_vector_painter.dart';

/// MOLECULE: Display central del carácter Kana activo.
/// Muestra el carácter grande con glow de acento y tier badge.
class KanaDisplay extends StatelessWidget {
  const KanaDisplay({
    super.key,
    required this.character,
    required this.tier,
    this.accentColor,
    this.showTier = true,
    this.svgPaths,
  });

  final String character;
  final KanaTier tier;
  final Color? accentColor;
  final bool showTier;
  final List<String>? svgPaths;

  @override
  Widget build(BuildContext context) {
    final accent = accentColor ?? CyberTheme.defaultAccent;

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxW = constraints.maxWidth.isFinite ? constraints.maxWidth : 200.0;
        final maxH =
            constraints.maxHeight.isFinite ? constraints.maxHeight : 200.0;
        final boxSize = math.min(maxW, maxH).clamp(80.0, 240.0);
        final charSize = boxSize * 0.6;
        final bracketSize = boxSize * 0.05;
        final inset = boxSize * 0.03;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ─── Carácter principal ───────────────────────────────────────────
            Container(
                  width: boxSize,
                  height: boxSize,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: accent.withValues(alpha: 0.3),
                      width: 1,
                    ),
                    color: accent.withValues(alpha: 0.04),
                  ),
                  child: Stack(
                    children: [
                      // Corner brackets SVG-style
                      Positioned(
                        top: inset,
                        left: inset,
                        child: _Bracket(
                          color: accent,
                          flip: false,
                          size: bracketSize,
                        ),
                      ),
                      Positioned(
                        top: inset,
                        right: inset,
                        child: _Bracket(
                          color: accent,
                          flip: true,
                          size: bracketSize,
                        ),
                      ),
                      Positioned(
                        bottom: inset,
                        left: inset,
                        child: _Bracket(
                          color: accent,
                          flip: false,
                          bottom: true,
                          size: bracketSize,
                        ),
                      ),
                      Positioned(
                        bottom: inset,
                        right: inset,
                        child: _Bracket(
                          color: accent,
                          flip: true,
                          bottom: true,
                          size: bracketSize,
                        ),
                      ),
                      // Carácter (Text fallback o VectorPainter)
                      Center(
                        child: (svgPaths != null && svgPaths!.isNotEmpty)
                            ? CustomPaint(
                                size: Size(charSize, charSize),
                                painter: KanjiVectorPainter(
                                  svgPaths: svgPaths!,
                                  accentColor: accent,
                                  progress: 1.0, // Modo estático
                                ),
                              )
                            : Text(
                                character,
                                style: TextStyle(
                                  fontSize: charSize,
                                  color: CyberTheme.textNeutral,
                                  fontWeight: FontWeight.w100,
                                  shadows: [
                                    Shadow(
                                      color: accent.withValues(alpha: 0.4),
                                      blurRadius: boxSize * 0.1,
                                    ),
                                    Shadow(
                                      color: accent.withValues(alpha: 0.2),
                                      blurRadius: boxSize * 0.2,
                                    ),
                                  ],
                                ),
                              ),
                      ),
                    ],
                  ),
                )
                .animate()
                .fadeIn(duration: 200.ms)
                .scale(
                  begin: const Offset(0.92, 0.92),
                  duration: 200.ms,
                  curve: Curves.easeOut,
                ),

            // ─── Tier badge ───────────────────────────────────────────────────
            if (showTier) ...[
              SizedBox(height: boxSize * 0.06),
              TierBadge(tier: tier, size: boxSize * 0.14),
            ],
          ],
        );
      },
    );
  }
}

class _Bracket extends StatelessWidget {
  const _Bracket({
    required this.color,
    required this.flip,
    this.bottom = false,
    required this.size,
  });
  final Color color;
  final bool flip;
  final bool bottom;
  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _BracketPainter(color: color, flipH: flip, flipV: bottom),
    );
  }
}

class _BracketPainter extends CustomPainter {
  const _BracketPainter({
    required this.color,
    required this.flipH,
    required this.flipV,
  });
  final Color color;
  final bool flipH;
  final bool flipV;

  @override
  void paint(Canvas canvas, Size s) {
    final p = Paint()
      ..color = color.withValues(alpha: 0.6)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    final x = flipH ? s.width : 0.0;
    final y = flipV ? s.height : 0.0;
    final dx = flipH ? -s.width : s.width;
    final dy = flipV ? -s.height : s.height;
    canvas.drawPath(
      Path()
        ..moveTo(x + dx, y)
        ..lineTo(x, y)
        ..lineTo(x, y + dy),
      p,
    );
  }

  @override
  bool shouldRepaint(_BracketPainter o) => o.color != color;
}
