import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kz_core/kz_core.dart';
import 'package:kz_domain/kz_domain.dart';
import 'package:kz_ui_components/kz_ui_components.dart';
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
      final statusColor = node.isSuccess ? accent : CyberTheme.errorRed;
      return CyberHistoryCard(
        title: 'ENGINE: QUIZ 1.0',
        statusLabel: node.isSuccess ? 'ACERTADO' : 'ERRÓNEO',
        statusColor: statusColor,
        accentColor: accent,
        mainContent: Text(
          'CONCEPTO: ${node.kanji.meanings.first.toUpperCase()}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontFamily: 'Courier',
            fontWeight: FontWeight.bold,
          ),
        ),
        stats: {
          'respuesta': node.kanji.character,
          'seleccion': node.selectedOption ?? 'NINGUNO',
        },
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
