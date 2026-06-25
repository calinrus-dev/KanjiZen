import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kz_core/kz_core.dart';
import 'package:kz_domain/kz_domain.dart';
import 'package:kz_ui_components/kz_ui_components.dart';
import 'package:kanjizen_app/src/providers/timeline_provider.dart';
import 'package:kanjizen_app/src/features/home/presentation/widgets/dynamic_matrix_grid.dart';

class MecaInputWidget extends ConsumerWidget {
  const MecaInputWidget({super.key, required this.node});
  final MecaInputNode node;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accent = _getAccentColor(ref.watch(settingsProvider).accentColor);
    final timelineState = ref.watch(timelineProvider);
    final useBold = ref.watch(settingsProvider).useBoldText;

    if (node.isFrozen) {
      final charsStr = node.targetCharacters.map((c) => c.character).join(' ');
      return CyberHistoryCard(
        title: 'ENGINE: MECA 1.0',
        statusLabel: 'COMPLETADO',
        statusColor: accent,
        accentColor: accent,
        mainContent: Text(
          'CADENA: $charsStr',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontFamily: 'Courier',
            fontWeight: FontWeight.bold,
          ),
        ),
        stats: {
          'racha': '${node.streak}',
          'latencia': '${node.avgMs}ms',
          'acierto': '${(node.hitRate * 100).toStringAsFixed(0)}%',
        },
      );
    }

    // Active interactive view
    return DynamicMatrixGrid(
      targetCharacters: node.targetCharacters,
      currentIndex: node.currentIndex,
      isPaused: timelineState.isPaused,
      layoutMode: ref.watch(settingsProvider).layoutMode,
      useBold: useBold,
      isNeonError: timelineState
          .isNeonErrorActive, // Asumiendo que añadiremos esto al timelineProvider
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
