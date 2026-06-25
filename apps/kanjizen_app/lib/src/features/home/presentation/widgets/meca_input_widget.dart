import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kz_core/kz_core.dart';
import 'package:kz_domain/kz_domain.dart';
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
      // Frozen static card view
      final charsStr = node.targetCharacters.map((c) => c.character).join(' ');
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
                  'ENGINE: MECA 1.0',
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 10,
                    fontFamily: 'Courier',
                  ),
                ),
                Text(
                  'COMPLETADO',
                  style: TextStyle(
                    color: accent,
                    fontSize: 10,
                    fontFamily: 'Courier',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'CADENA: $charsStr',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontFamily: 'Courier',
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'TELEMETRÍA: Racha: ${node.streak} | ms: ${node.avgMs}ms | A: ${(node.hitRate * 100).toStringAsFixed(0)}%',
              style: TextStyle(
                color: accent.withValues(alpha: 0.7),
                fontSize: 11,
                fontFamily: 'Courier',
              ),
            ),
          ],
        ),
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
