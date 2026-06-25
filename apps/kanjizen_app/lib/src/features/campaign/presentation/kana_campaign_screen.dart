import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kz_core/kz_core.dart';
import 'package:kz_domain/kz_domain.dart';
import 'package:kanjizen_app/src/providers/kana_campaign_provider.dart';

/// Pantalla de la Hoja de Ruta Pedagógica (Fase 3).
class KanaCampaignScreen extends ConsumerWidget {
  const KanaCampaignScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final campaignState = ref.watch(kanaCampaignProvider);

    return Scaffold(
      backgroundColor: CyberTheme.bgObsidian,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: CyberTheme.textNeutral),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'RUTA PEDAGÓGICA KANA',
          style: TextStyle(
            color: CyberTheme.defaultAccent,
            fontFamily: 'Courier',
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
            fontSize: 14,
          ),
        ),
        centerTitle: true,
      ),
      body: campaignState.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: CyberTheme.defaultAccent),
        ),
        error: (err, st) => Center(
          child: Text(
            'Error: $err',
            style: const TextStyle(color: CyberTheme.errorRed),
          ),
        ),
        data: (levels) {
          if (levels.isEmpty) {
            return const Center(
              child: Text(
                'Sin niveles',
                style: TextStyle(color: CyberTheme.textNeutral),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: levels.length,
            itemBuilder: (context, index) {
              final level = levels[index];
              return _LevelNode(level: level);
            },
          );
        },
      ),
    );
  }
}

class _LevelNode extends ConsumerWidget {
  const _LevelNode({required this.level});
  final KanaLevelModel level;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isHardcore = level.redStars > 0;
    final Color mainColor = isHardcore
        ? CyberTheme.errorRed
        : CyberTheme.defaultAccent;
    final double opacity = level.isUnlocked ? 1.0 : 0.3;

    return GestureDetector(
      onTap: () {
        if (!level.isUnlocked) return;
        // TODO: Navegar a la pantalla de juego inyectando el nivel.
        // ref.read(gameProvider.notifier).initializeCampaign(level);
        // Navigator.push(...)
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 24),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: level.isUnlocked
              ? mainColor.withValues(alpha: 0.1)
              : Colors.transparent,
          border: Border.all(
            color: level.isUnlocked
                ? mainColor
                : CyberTheme.textNeutral.withValues(alpha: 0.2),
            width: level.isUnlocked ? 1.5 : 1.0,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Opacity(
          opacity: opacity,
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: mainColor.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${level.levelId}',
                    style: TextStyle(
                      color: mainColor,
                      fontFamily: 'Courier',
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (level.isBoss) ...[
                          Icon(
                            Icons.warning_amber_rounded,
                            color: mainColor,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                        ],
                        Text(
                          level.isBoss ? 'BOSS LEVEL' : 'ADQUISICIÓN',
                          style: TextStyle(
                            color: mainColor,
                            fontFamily: 'Courier',
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      level.targetCharacters.join(' · '),
                      style: const TextStyle(
                        color: CyberTheme.textNeutral,
                        fontSize: 14,
                        letterSpacing: 2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _StarsDisplay(count: level.stars, isRed: false),
                  if (level.redStars > 0) ...[
                    const SizedBox(height: 4),
                    _StarsDisplay(count: level.redStars, isRed: true),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StarsDisplay extends StatelessWidget {
  const _StarsDisplay({required this.count, required this.isRed});
  final int count;
  final bool isRed;

  @override
  Widget build(BuildContext context) {
    final color = isRed ? CyberTheme.errorRed : CyberTheme.defaultAccent;
    return Row(
      children: List.generate(3, (index) {
        return Icon(
          index < count ? Icons.star : Icons.star_border,
          color: index < count ? color : color.withValues(alpha: 0.3),
          size: 14,
        );
      }),
    );
  }
}
