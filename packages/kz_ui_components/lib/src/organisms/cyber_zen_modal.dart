import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:kz_core/kz_core.dart';
import 'package:kz_domain/kz_domain.dart';
import 'package:kz_ui_components/src/painters/bg_pattern_painter.dart';
import 'package:kz_ui_components/src/painters/kanji_vector_painter.dart';
import 'package:kz_ui_components/src/atoms/tier_badge.dart';

/// ORGANISM: Modal expansivo "Cyber-Zen" para mostrar el Kana.
/// Anima el trazo vectorial y proporciona feedback de audio.
class CyberZenModal extends StatefulWidget {
  const CyberZenModal({
    super.key,
    required this.kana,
    required this.enableStrokeAnimation,
    required this.onPlayAudio,
  });

  final KanaModel kana;
  final bool enableStrokeAnimation;
  final VoidCallback onPlayAudio;

  static void show({
    required BuildContext context,
    required KanaModel kana,
    required bool enableStrokeAnimation,
    required VoidCallback onPlayAudio,
  }) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Cerrar',
      barrierColor: Colors.black87,
      pageBuilder: (ctx, anim1, anim2) => CyberZenModal(
        kana: kana,
        enableStrokeAnimation: enableStrokeAnimation,
        onPlayAudio: onPlayAudio,
      ),
      transitionBuilder: (ctx, anim1, anim2, child) {
        return FadeTransition(opacity: anim1, child: child);
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  @override
  State<CyberZenModal> createState() => _CyberZenModalState();
}

class _CyberZenModalState extends State<CyberZenModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    if (widget.enableStrokeAnimation) {
      _anim.forward();
    } else {
      _anim.value = 1.0;
    }
    // Play audio automatically
    widget.onPlayAudio();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent =
        Theme.of(context).extension<CyberThemeExtension>()?.accentColor ??
        CyberTheme.defaultAccent;
    final tier = TierCalculator.calculate(
      hitRate: widget.kana.currentHitRate,
      avgMs: widget.kana.averageMs,
      isUnlocked: widget.kana.isUnlocked,
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
                      icon: const Icon(Icons.volume_up, color: Colors.white70),
                      onPressed: () {
                        if (widget.enableStrokeAnimation) {
                          _anim.forward(from: 0.0);
                        }
                        widget.onPlayAudio();
                      },
                    ),
                  ],
                ),

                const Spacer(),

                // Animated Character
                Center(
                  child: AnimatedBuilder(
                    animation: _anim,
                    builder: (ctx, _) {
                      if (widget.kana.svgPaths.isEmpty) {
                        return Text(
                          widget.kana.character,
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
                          svgPaths: widget.kana.svgPaths,
                          accentColor: accent,
                          progress: _anim.value,
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 32),
                Text(
                  widget.kana.romaji.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: CyberTheme.textNeutral,
                    letterSpacing: 8,
                  ),
                ).animate().fadeIn(delay: 500.ms),

                const SizedBox(height: 16),
                TierBadge(tier: tier, size: 40).animate().scale(delay: 600.ms),

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
                        '${(widget.kana.currentHitRate * 100).toStringAsFixed(1)}%',
                      ),
                      _StatColumn('VELOCIDAD', '${widget.kana.averageMs} ms'),
                      _StatColumn(
                        'INTENTOS',
                        '${widget.kana.historyBlob.length}',
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
