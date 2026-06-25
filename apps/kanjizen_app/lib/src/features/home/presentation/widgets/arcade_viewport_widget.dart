import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kz_core/kz_core.dart';
import 'package:kz_domain/kz_domain.dart';
import 'package:kanjizen_app/src/providers/timeline_provider.dart';

class ArcadeViewportWidget extends ConsumerWidget {
  const ArcadeViewportWidget({super.key, required this.node});
  final LaneCollisionViewportNode node;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final accent = _getAccentColor(settings.accentColor);

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
                  'ENGINE: ARCADE 1.0',
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
              'PUNTUACIÓN OBTENIDA: ${node.score} PTS',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontFamily: 'Courier',
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'VIDAS RESTANTES: ${node.lives} | DECK DE KANJIS: ${node.deck.map((k) => k.character).join(", ")}',
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
    return Column(
      children: [
        // Status indicator
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'SCORE: ${node.score}',
                style: TextStyle(
                  color: accent,
                  fontFamily: 'Courier',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: List.generate(5, (i) {
                  return Icon(
                    Icons.favorite,
                    color: i < node.lives
                        ? CyberTheme.errorRed
                        : Colors.white10,
                    size: 14,
                  );
                }),
              ),
            ],
          ),
        ),

        // Lanes container
        Expanded(
          child: Container(
            color: Colors.black,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final height = constraints.maxHeight;
                final width = constraints.maxWidth;
                final lanesCount = settings.arcadeLanes;
                final laneWidth = width / lanesCount;

                return Stack(
                  children: [
                    // Lane dividing lines
                    Row(
                      children: List.generate(lanesCount, (i) {
                        return Container(
                          width: laneWidth,
                          height: height,
                          decoration: BoxDecoration(
                            border: Border(
                              right: BorderSide(
                                color: Colors.white.withValues(alpha: 0.05),
                                width: 0.5,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),

                    // Falling items
                    ...node.fallingEntities.map((entity) {
                      final left = entity.lane * laneWidth;
                      final top = entity.y * (height - 60);

                      return Positioned(
                        left: left,
                        top: top,
                        child: Container(
                          width: laneWidth,
                          height: 50,
                          alignment: Alignment.center,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: CyberTheme.bgObsidian,
                              border: Border.all(
                                color: accent.withValues(alpha: 0.2),
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              entity.concept,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 9,
                                fontFamily: 'Courier',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),

                    // DragTarget Overlays on Lanes
                    Row(
                      children: List.generate(lanesCount, (laneIdx) {
                        return DragTarget<String>(
                          onWillAcceptWithDetails: (details) => true,
                          onAcceptWithDetails: (details) {
                            ref
                                .read(timelineProvider.notifier)
                                .onArcadeFlick(details.data, laneIdx);
                          },
                          builder: (context, candidateData, rejectedData) {
                            final isHovered = candidateData.isNotEmpty;
                            return Container(
                              width: laneWidth,
                              height: height,
                              color: isHovered
                                  ? accent.withValues(alpha: 0.05)
                                  : Colors.transparent,
                            );
                          },
                        );
                      }),
                    ),

                    // Deadline Warning Line
                    Positioned(
                      bottom: 20,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 1,
                        color: CyberTheme.errorRed.withValues(alpha: 0.4),
                      ),
                    ),
                  ],
                );
              },
            ),
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
