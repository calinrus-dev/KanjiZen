import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:kz_core/kz_core.dart';
import 'package:kz_domain/kz_domain.dart';
import '../atoms/tier_badge.dart';
import '../painters/kanji_vector_painter.dart';

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

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ─── Carácter principal ───────────────────────────────────────────
        Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: accent.withOpacity(0.3), width: 1),
                color: accent.withOpacity(0.04),
              ),
              child: Stack(
                children: [
                  // Corner brackets SVG-style
                  Positioned(
                    top: 6,
                    left: 6,
                    child: _Bracket(color: accent, flip: false),
                  ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: _Bracket(color: accent, flip: true),
                  ),
                  Positioned(
                    bottom: 6,
                    left: 6,
                    child: _Bracket(color: accent, flip: false, bottom: true),
                  ),
                  Positioned(
                    bottom: 6,
                    right: 6,
                    child: _Bracket(color: accent, flip: true, bottom: true),
                  ),
                  // Carácter (Text fallback o VectorPainter)
                  Center(
                    child: (svgPaths != null && svgPaths!.isNotEmpty)
                        ? CustomPaint(
                            size: const Size(120, 120),
                            painter: KanjiVectorPainter(
                              svgPaths: svgPaths!,
                              accentColor: accent,
                              progress: 1.0, // Modo estático
                            ),
                          )
                        : Text(
                            character,
                            style: TextStyle(
                              fontSize: 120,
                              color: CyberTheme.textNeutral,
                              fontWeight: FontWeight.w100,
                              shadows: [
                                Shadow(color: accent.withValues(alpha: 0.4), blurRadius: 20),
                                Shadow(color: accent.withValues(alpha: 0.2), blurRadius: 40),
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
          const SizedBox(height: 12),
          TierBadge(tier: tier, size: 28),
        ],
      ],
    );
  }
}

class _Bracket extends StatelessWidget {
  const _Bracket({
    required this.color,
    required this.flip,
    this.bottom = false,
  });
  final Color color;
  final bool flip;
  final bool bottom;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(10, 10),
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
      ..color = color.withOpacity(0.6)
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
