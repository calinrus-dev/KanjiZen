import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kz_core/kz_core.dart';
import 'package:kz_domain/kz_domain.dart';
import 'package:kz_ui_components/kz_ui_components.dart';
import 'package:kanjizen_app/src/providers/timeline_provider.dart';

class KanjiProductionWidget extends ConsumerWidget {
  const KanjiProductionWidget({super.key, this.productionNode, this.recallNode})
    : assert(productionNode != null || recallNode != null);

  final KanjiProductionNode? productionNode;
  final ConceptRecallNode? recallNode;

  bool get isRecall => recallNode != null;

  String get id => productionNode?.id ?? recallNode!.id;
  bool get isFrozen => productionNode?.isFrozen ?? recallNode!.isFrozen;
  KanjiModel get kanji => productionNode?.kanji ?? recallNode!.kanji;
  bool get isSuccess => productionNode?.isSuccess ?? recallNode!.isSuccess;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final accent = _getAccentColor(settings.accentColor);
    final timelineState = ref.watch(timelineProvider);
    final useBold = settings.useBoldText;

    if (isFrozen) {
      return CyberHistoryCard(
        title: isRecall
            ? 'ENGINE: KANJI 1.0 (RECALL)'
            : 'ENGINE: KANJI 1.0 (PRODUCTION)',
        statusLabel: 'COMPLETADO',
        statusColor: accent,
        accentColor: accent,
        mainContent: Text(
          'KANJI: ${kanji.character} [${kanji.meanings.first.toUpperCase()}]',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontFamily: 'Courier',
            fontWeight: FontWeight.bold,
          ),
        ),
        stats: {
          'srs score': kanji.srsScore.toStringAsFixed(1),
          'onyomi': kanji.onyomi.take(2).join(', '),
          'kunyomi': kanji.kunyomi.take(2).join(', '),
        },
      );
    }

    // Active interactive view
    final opacity = timelineState.isPaused ? 0.2 : 1.0;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isRecall) ...[
            // Selective erasure: hides Kanji from center, displays concept only
            const Icon(Icons.visibility_off, size: 24, color: Colors.white24),
            const SizedBox(height: 12),
            Text(
              kanji.meanings.first.toUpperCase(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: opacity),
                fontSize: 32,
                fontFamily: 'Courier',
                letterSpacing: 4,
                fontWeight: useBold ? FontWeight.bold : FontWeight.w300,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'EVOCA Y ESCRIBE EL KANJI A CIEGAS',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: accent.withValues(alpha: 0.4),
                fontSize: 10,
                fontFamily: 'Courier',
                letterSpacing: 1.5,
              ),
            ),
          ] else ...[
            // Production: displays Kanji naked (vector or text) + concept
            SizedBox(
              width: 180,
              height: 180,
              child: Opacity(
                opacity: opacity,
                child:
                    settings.enableStrokeAnimation && kanji.svgPaths.isNotEmpty
                    ? CustomPaint(
                        painter: KanjiVectorPainter(
                          svgPaths: kanji.svgPaths,
                          accentColor: accent,
                        ),
                      )
                    : Center(
                        child: Text(
                          kanji.character,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 140,
                            fontFamily: 'Courier',
                            fontWeight: useBold
                                ? FontWeight.w900
                                : FontWeight.w100,
                          ),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              kanji.meanings.first.toUpperCase(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70.withValues(alpha: opacity),
                fontSize: 18,
                fontFamily: 'Courier',
                letterSpacing: 2,
              ),
            ),
            if (productionNode?.showHint == true) ...[
              const SizedBox(height: 8),
              Text(
                'PISTA: ${kanji.onyomi.isNotEmpty ? kanji.onyomi.first : ""} ${kanji.kunyomi.isNotEmpty ? kanji.kunyomi.first : ""}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: accent.withValues(alpha: 0.5),
                  fontSize: 11,
                  fontFamily: 'Courier',
                ),
              ),
            ],
          ],
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
