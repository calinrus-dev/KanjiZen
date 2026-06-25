import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kz_core/kz_core.dart';
import 'package:kz_domain/kz_domain.dart';
import 'package:kanjizen_app/src/providers/timeline_provider.dart';

class KanjiQuizWidget extends ConsumerWidget {
  const KanjiQuizWidget({super.key, required this.node});
  final KanjiQuizNode node;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accent = _getAccentColor(ref.watch(settingsProvider).accentColor);
    final timelineState = ref.watch(timelineProvider);
    final useBold = ref.watch(settingsProvider).useBoldText;

    if (node.isFrozen) {
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
                  'ENGINE: QUIZ 1.0',
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 10,
                    fontFamily: 'Courier',
                  ),
                ),
                Text(
                  node.isSuccess ? 'ACERTADO' : 'ERRÓNEO',
                  style: TextStyle(
                    color: node.isSuccess ? accent : CyberTheme.errorRed,
                    fontSize: 10,
                    fontFamily: 'Courier',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'CONCEPTO: ${node.kanji.meanings.first.toUpperCase()}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontFamily: 'Courier',
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'RESPUESTA CORRECTA: ${node.kanji.character} | SELECCIONADO: ${node.selectedOption ?? "NINGUNO"}',
              style: TextStyle(
                color: node.isSuccess
                    ? accent.withValues(alpha: 0.7)
                    : CyberTheme.errorRed.withValues(alpha: 0.7),
                fontSize: 11,
                fontFamily: 'Courier',
              ),
            ),
          ],
        ),
      );
    }

    // Active interactive view
    final opacity = timelineState.isPaused ? 0.2 : 1.0;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.help_outline, size: 36, color: Colors.white30),
          const SizedBox(height: 16),
          Text(
            node.kanji.meanings.first.toUpperCase(),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: opacity),
              fontSize: 36,
              fontFamily: 'Courier',
              letterSpacing: 4,
              fontWeight: useBold ? FontWeight.bold : FontWeight.w300,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'SELECCIONA EL RADICAL CORRECTO ABAJO',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: accent.withValues(alpha: 0.5),
              fontSize: 11,
              fontFamily: 'Courier',
              letterSpacing: 1.5,
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
