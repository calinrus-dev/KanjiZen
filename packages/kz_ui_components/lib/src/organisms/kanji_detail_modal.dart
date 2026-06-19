import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:kz_core/kz_core.dart';
import 'package:kz_domain/kz_domain.dart';
import 'package:kz_ui_components/src/painters/bg_pattern_painter.dart';
import 'package:kz_ui_components/src/painters/kanji_vector_painter.dart';
import 'package:kz_ui_components/src/atoms/tier_badge.dart';

/// ORGANISM: Modal expansivo para mostrar el detalle de un Kanji.
class KanjiDetailModal extends StatefulWidget {
  const KanjiDetailModal({
    super.key,
    required this.kanji,
    required this.enableStrokeAnimation,
  });

  final KanjiModel kanji;
  final bool enableStrokeAnimation;

  static void show({
    required BuildContext context,
    required KanjiModel kanji,
    required bool enableStrokeAnimation,
  }) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Cerrar',
      barrierColor: Colors.black87,
      pageBuilder: (ctx, anim1, anim2) => KanjiDetailModal(
        kanji: kanji,
        enableStrokeAnimation: enableStrokeAnimation,
      ),
      transitionBuilder: (ctx, anim1, anim2, child) {
        return FadeTransition(opacity: anim1, child: child);
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  @override
  State<KanjiDetailModal> createState() => _KanjiDetailModalState();
}

class _KanjiDetailModalState extends State<KanjiDetailModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    if (widget.enableStrokeAnimation) {
      _anim.forward();
    } else {
      _anim.value = 1.0;
    }
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const accent = CyberTheme.defaultAccent;
    final tier = TierCalculator.calculate(
      hitRate: widget.kanji.currentHitRate,
      avgMs: widget.kanji.averageMs,
      isUnlocked: widget.kanji.isUnlocked,
    );

    return Scaffold(
      backgroundColor: CyberTheme.bgObsidian.withValues(alpha: 0.95),
      body: Stack(
        children: [
          // Background Pattern
          Positioned.fill(
            child: CustomPaint(
              painter: BgPatternPainter(
                accentColor: accent.withValues(alpha: 0.05),
              ),
            ),
          ),

          // Main Content
          SafeArea(
            child: Column(
              children: [
                // Top Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white70),
                      onPressed: () => Navigator.pop(context),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.white70),
                      onPressed: () {
                        if (widget.enableStrokeAnimation) {
                          _anim.forward(from: 0.0);
                        }
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Animated Character
                Center(
                  child: AnimatedBuilder(
                    animation: _anim,
                    builder: (ctx, _) {
                      if (widget.kanji.svgPaths.isEmpty) {
                        return Text(
                          widget.kanji.character,
                          style: const TextStyle(
                            fontSize: 160,
                            color: CyberTheme.textNeutral,
                            fontWeight: FontWeight.w100,
                          ),
                        );
                      }
                      return CustomPaint(
                        size: const Size(200, 200),
                        painter: KanjiVectorPainter(
                          svgPaths: widget.kanji.svgPaths,
                          accentColor: accent,
                          progress: _anim.value,
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 32),
                
                // Meanings
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    widget.kanji.meanings.take(3).join(' • ').toUpperCase(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: CyberTheme.textNeutral,
                      letterSpacing: 4,
                    ),
                  ).animate().fadeIn(delay: 500.ms),
                ),

                const SizedBox(height: 24),
                
                // Onyomi & Kunyomi
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              'ONYOMI',
                              style: TextStyle(
                                color: accent.withValues(alpha: 0.5),
                                fontSize: 10,
                                fontFamily: 'Courier',
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.kanji.onyomi.join(', '),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: CyberTheme.textNeutral,
                                fontSize: 14,
                                fontFamily: 'Courier',
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(width: 1, height: 40, color: accent.withValues(alpha: 0.2)),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              'KUNYOMI',
                              style: TextStyle(
                                color: accent.withValues(alpha: 0.5),
                                fontSize: 10,
                                fontFamily: 'Courier',
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.kanji.kunyomi.join(', '),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: CyberTheme.textNeutral,
                                fontSize: 14,
                                fontFamily: 'Courier',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 600.ms),

                const SizedBox(height: 24),
                TierBadge(tier: tier, size: 40).animate().scale(delay: 700.ms),

                const Spacer(),

                // Stats
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 24,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: accent.withValues(alpha: 0.3)),
                    color: accent.withValues(alpha: 0.05),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatColumn(
                        'PRECISIÓN',
                        '${(widget.kanji.currentHitRate * 100).toStringAsFixed(1)}%',
                      ),
                      _StatColumn('VELOCIDAD', '${widget.kanji.averageMs} ms'),
                      _StatColumn(
                        'INTENTOS',
                        '${widget.kanji.historyBlob.length}',
                      ),
                    ],
                  ),
                ).animate().slideY(
                  begin: 1.0,
                  curve: Curves.easeOut,
                  duration: 400.ms,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn(this.label, this.value);
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: CyberTheme.textNeutral.withValues(alpha: 0.5),
            fontSize: 10,
            fontFamily: 'Courier',
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: CyberTheme.textNeutral,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Courier',
          ),
        ),
      ],
    );
  }
}
