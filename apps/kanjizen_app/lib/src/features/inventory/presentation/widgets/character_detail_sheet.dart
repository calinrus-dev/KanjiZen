import 'package:flutter/material.dart';
import 'package:kz_core/kz_core.dart';
import 'package:kz_domain/kz_domain.dart';
import 'package:kz_data/kz_data.dart';
import 'package:kz_ui_components/kz_ui_components.dart';

// ─── STATEFUL WRAPPER ─────────────────────────────────────────────────────────
class CharacterDetailSheet extends StatefulWidget {
  final Object model;
  final Color accent;

  const CharacterDetailSheet({
    super.key,
    required this.model,
    required this.accent,
  });

  @override
  State<CharacterDetailSheet> createState() => _CharacterDetailSheetState();
}

class _CharacterDetailSheetState extends State<CharacterDetailSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _strokeProgress;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _strokeProgress = CurvedAnimation(
      parent: _animCtrl,
      curve: Curves.easeInOut,
    );
    // Auto-arranca al abrir
    WidgetsBinding.instance.addPostFrameCallback((_) => _animCtrl.forward());
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  void _replayAnimation() {
    _animCtrl.reset();
    _animCtrl.forward();
  }

  void _playTts(String character) {
    AudioFeedbackService.instance.playReading(character);
  }

  @override
  Widget build(BuildContext context) {
    final model = widget.model;
    final accent = widget.accent;

    String character = '';
    String sub = '';
    String meaningEs = '';
    String meaningEn = '';
    String onyomi = '';
    String kunyomi = '';
    String radical = '';
    double hitRate = 0.0;
    int avgMs = 0;
    int jlpt = 0;
    int joyo = 0;
    KanaTier tier = KanaTier.e;
    List<int> history = [];
    List<String> svgPaths = [];

    if (model is KanaModel) {
      final k = model;
      character = k.character;
      sub = k.romaji;
      hitRate = k.currentHitRate;
      avgMs = k.averageMs;
      tier = k.tier;
      history = k.historyBlob;
      svgPaths = k.svgPaths;
    } else if (model is KanjiModel) {
      final k = model;
      character = k.character;
      meaningEs = k.meanings.join(', ');
      meaningEn = k.kanjidicTranslations.join(', ');
      onyomi = k.onyomi.join(', ');
      kunyomi = k.kunyomi.join(', ');
      radical = k.radical;
      hitRate = k.currentHitRate;
      avgMs = k.averageMs;
      jlpt = k.jlpt;
      joyo = k.joyo;
      tier = k.tier;
      history = k.historyBlob;
      svgPaths = k.svgPaths;
    }

    final displayRadical = radical.isNotEmpty
        ? radical
        : (model is KanjiModel ? (model).radicals.firstOrNull ?? '' : '');
    final tierColor = switch (tier) {
      KanaTier.e => CyberTheme.errorRed,
      KanaTier.d => Colors.orange,
      KanaTier.c => Colors.yellow,
      KanaTier.b => accent,
      KanaTier.a => accent,
      KanaTier.s => Colors.white,
    };

    return Container(
      height: MediaQuery.of(context).size.height * 0.90,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
        border: Border(top: BorderSide(color: Colors.white12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '// TELEMETRÍA DE COMPONENTE',
                style: TextStyle(
                  color: accent,
                  fontFamily: 'Courier',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // TTS button
                  GestureDetector(
                    onTap: () => _playTts(character),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: accent.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Icon(
                        Icons.volume_up_outlined,
                        color: accent,
                        size: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white54,
                      size: 18,
                    ),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Core details row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // KanjiVG animated painter (toca para repetir)
              GestureDetector(
                onTap: _replayAnimation,
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    border: Border.all(color: accent.withValues(alpha: 0.5)),
                    color: Colors.white.withValues(alpha: 0.01),
                  ),
                  child: svgPaths.isNotEmpty
                      ? CustomPaint(
                          painter: KanjiVgPainter(
                            svgPaths: svgPaths,
                            progress: _strokeProgress,
                            strokeColor: Colors.white,
                          ),
                        )
                      : Center(
                          child: Text(
                            character,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 68,
                              height: 1.0,
                            ),
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 16),

              // Metadatos monoespaciados densos
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (sub.isNotEmpty)
                      _buildMetaLine('ROMAJI', sub, accent: accent),
                    if (onyomi.isNotEmpty)
                      _buildMetaLine('音読み', onyomi, accent: accent),
                    if (kunyomi.isNotEmpty)
                      _buildMetaLine('訓読み', kunyomi, accent: accent),
                    if (meaningEs.isNotEmpty)
                      _buildMetaLine('ES', meaningEs, accent: accent),
                    if (meaningEn.isNotEmpty)
                      _buildMetaLine('EN', meaningEn, accent: accent),
                    if (jlpt > 0)
                      _buildMetaLine('JLPT', 'N$jlpt', accent: accent),
                    if (joyo > 0)
                      _buildMetaLine('GRADO', 'G$joyo', accent: accent),
                    // Tier badge
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: tierColor.withValues(alpha: 0.6),
                        ),
                        color: tierColor.withValues(alpha: 0.07),
                      ),
                      child: Text(
                        'TIER ${tier.name.toUpperCase()}',
                        style: TextStyle(
                          color: tierColor,
                          fontFamily: 'Courier',
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Tap-to-replay hint
          if (svgPaths.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              '[ TOCAR PARA REPETIR TRAZO ]',
              style: TextStyle(
                color: accent.withValues(alpha: 0.3),
                fontFamily: 'Courier',
                fontSize: 8,
                letterSpacing: 1,
              ),
            ),
          ],
          const SizedBox(height: 12),

          // Render Radical principal visualmente
          if (displayRadical.isNotEmpty) ...[
            const Divider(color: Colors.white10),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text(
                  'RADICAL PRINCIPAL: ',
                  style: TextStyle(
                    color: Colors.white38,
                    fontFamily: 'Courier',
                    fontSize: 10,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    border: Border.all(color: accent.withValues(alpha: 0.4)),
                    color: accent.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    displayRadical,
                    style: TextStyle(
                      color: accent,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      height: 1.0,
                    ),
                  ),
                ),
              ],
            ),
          ],

          const Divider(color: Colors.white10),
          const SizedBox(height: 12),

          // Telemetry details
          Text(
            '// HISTORIAL DE RENDIMIENTO (ÚLTIMAS 50 SESIONES)',
            style: TextStyle(
              color: accent,
              fontFamily: 'Courier',
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildMetric(
                'PRECISIÓN',
                '${(hitRate * 100).toStringAsFixed(1)}%',
              ),
              _buildMetric('VELOCIDAD MEDIA', '${avgMs}ms'),
              _buildMetric('MUESTRAS', '${history.length}/50'),
            ],
          ),
          const SizedBox(height: 16),

          // Telemetry Chart (CustomPaint for high performance)
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white10),
                color: Colors.black,
              ),
              child: ClipRect(
                child: CustomPaint(
                  painter: TelemetryChartPainter(
                    historyBlob: history,
                    accentColor: accent,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaLine(
    String label,
    String value, {
    Color? valueColor,
    Color? accent,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white30,
                fontFamily: 'Courier',
                fontSize: 9,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: valueColor ?? Colors.white,
                fontFamily: 'Courier',
                fontSize: 10,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontFamily: 'Courier',
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white38,
            fontFamily: 'Courier',
            fontSize: 9,
          ),
        ),
      ],
    );
  }
}

// Telemetry Graph Painter
class TelemetryChartPainter extends CustomPainter {
  final List<int> historyBlob;
  final Color accentColor;

  TelemetryChartPainter({required this.historyBlob, required this.accentColor});

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw Grid lines
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..strokeWidth = 0.5;

    final double stepY = size.height / 5;
    for (int i = 0; i <= 5; i++) {
      final y = i * stepY;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final double stepX = size.width / 10;
    for (int i = 0; i <= 10; i++) {
      final x = i * stepX;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }

    if (historyBlob.isEmpty) {
      // Empty text
      final textPainter = TextPainter(
        text: const TextSpan(
          text: '[ SIN REGISTRO DE DATOS ]',
          style: TextStyle(
            color: Colors.white24,
            fontFamily: 'Courier',
            fontSize: 10,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(
        canvas,
        Offset(
          (size.width - textPainter.width) / 2,
          (size.height - textPainter.height) / 2,
        ),
      );
      return;
    }

    // 2. Decode last 50 attempts
    final last50 = historyBlob.length > 50
        ? historyBlob.sublist(historyBlob.length - 50)
        : historyBlob;
    final int count = last50.length;

    // Draw bars
    final double barWidth = (size.width / 50) * 0.7;
    final double spacing = (size.width / 50) * 0.3;

    for (int i = 0; i < count; i++) {
      final val = last50[i];
      final isCorrect = (val & 0x8000) != 0;
      final int responseMs = val & 0x3FFF;

      // Speed factor: faster is higher (responseMs ranges from 0 to 3000ms+)
      final speedFactor = (1.0 - (responseMs / 3000.0)).clamp(0.08, 1.0);
      final height = size.height * speedFactor;

      final x = i * (barWidth + spacing) + spacing;
      final y = size.height - height;

      final paint = Paint()
        ..color = isCorrect ? accentColor : CyberTheme.errorRed
        ..style = PaintingStyle.fill;

      canvas.drawRect(Rect.fromLTWH(x, y, barWidth, height), paint);

      // Add a thin cyan/red glow outline on top of the bar
      final glowPaint = Paint()
        ..color = (isCorrect ? accentColor : CyberTheme.errorRed).withValues(
          alpha: 0.5,
        )
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
      canvas.drawRect(Rect.fromLTWH(x, y, barWidth, height), glowPaint);
    }

    // Draw Y axis helper labels
    _drawAxisLabel(canvas, size, '0ms', size.height - 12);
    _drawAxisLabel(
      canvas,
      size,
      '1000ms',
      size.height - (size.height * (1.0 - 1000 / 3000)) - 6,
    );
    _drawAxisLabel(
      canvas,
      size,
      '2000ms',
      size.height - (size.height * (1.0 - 2000 / 3000)) - 6,
    );
    _drawAxisLabel(canvas, size, '3000ms+', 4);
  }

  void _drawAxisLabel(Canvas canvas, Size size, String text, double yOffset) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Colors.white30,
          fontFamily: 'Courier',
          fontSize: 8,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      Offset(size.width - textPainter.width - 6, yOffset),
    );
  }

  @override
  bool shouldRepaint(covariant TelemetryChartPainter oldDelegate) =>
      historyBlob != oldDelegate.historyBlob ||
      accentColor != oldDelegate.accentColor;
}
