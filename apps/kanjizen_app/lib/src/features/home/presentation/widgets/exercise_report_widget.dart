import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kz_core/kz_core.dart';
import 'package:kz_domain/kz_domain.dart';
import 'package:kanjizen_app/src/providers/timeline_provider.dart';

class ExerciseReportWidget extends ConsumerWidget {
  const ExerciseReportWidget({super.key, required this.node});
  final ExerciseReportNode node;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final accent = _getAccentColor(settings.accentColor);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.02),
        border: Border.all(color: accent.withValues(alpha: 0.2)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                node.title,
                style: TextStyle(
                  color: accent,
                  fontFamily: 'Courier',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const Icon(
                Icons.analytics_outlined,
                color: Colors.white24,
                size: 16,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Grid of performance statistics
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatColumn(
                'ACIERTO',
                '${(node.hitRate * 100).toStringAsFixed(0)}%',
                accent,
              ),
              _buildStatColumn(
                'CORRECTAS',
                '${node.successes}/${node.totalQuestions}',
                Colors.white70,
              ),
              _buildStatColumn(
                'ERRORES',
                '${node.errors}',
                CyberTheme.errorRed,
              ),
              _buildStatColumn('LATENCIA', '${node.avgMs}ms', accent),
            ],
          ),
          const SizedBox(height: 20),

          // Siguiente Ejercicio Button (only if this is the last node in the entire feed history!)
          Consumer(
            builder: (ctx, refWatch, _) {
              final activeNodes = refWatch.watch(timelineProvider).activeNodes;
              final isLast =
                  activeNodes.isNotEmpty && activeNodes.last.id == node.id;

              if (!isLast) return const SizedBox.shrink();

              return Center(
                child: InkWell(
                  onTap: () {
                    ref.read(timelineProvider.notifier).generateNextNode();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: accent),
                      borderRadius: BorderRadius.circular(2),
                      color: accent.withValues(alpha: 0.05),
                    ),
                    child: Text(
                      '[ SIGUIENTE EJERCICIO ]',
                      style: TextStyle(
                        color: accent,
                        fontFamily: 'Courier',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white24,
            fontFamily: 'Courier',
            fontSize: 8,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontFamily: 'Courier',
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
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
