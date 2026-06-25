import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kz_core/kz_core.dart';
import 'package:kz_domain/kz_domain.dart';
import 'package:kanjizen_app/src/providers/kana_campaign_provider.dart';
import 'package:kanjizen_app/src/providers/timeline_provider.dart';

class KanaLevelMatrixScreen extends ConsumerStatefulWidget {
  const KanaLevelMatrixScreen({super.key});

  @override
  ConsumerState<KanaLevelMatrixScreen> createState() =>
      _KanaLevelMatrixScreenState();
}

class _KanaLevelMatrixScreenState extends ConsumerState<KanaLevelMatrixScreen> {
  ProgressiveSystem _filterSystem = ProgressiveSystem.both;

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

  void _showLevelPreview(
    BuildContext context,
    KanaLevelModel level,
    Color accent,
  ) {
    final settings = ref.read(settingsProvider);
    final isHardcore = settings.hardcoreMode;
    final displayStars = isHardcore ? level.redStars : level.stars;
    final starColor = isHardcore ? CyberTheme.errorRed : accent;

    int selectedVolume = settings.campaignSessionVolume;
    int selectedDuration = settings.campaignSessionDuration;

    showDialog<void>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF05060A),
              shape: Border.all(color: accent.withValues(alpha: 0.3)),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    level.isBoss
                        ? 'ALERTA: ENFRENTAMIENTO JEFE'
                        : 'NIVEL ${level.levelId}',
                    style: TextStyle(
                      color: level.isBoss ? CyberTheme.errorRed : accent,
                      fontFamily: 'Courier',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  if (level.isBoss)
                    const Icon(Icons.gavel, color: CyberTheme.errorRed, size: 16),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'MÉTODO: ${level.mode.toUpperCase()}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontFamily: 'Courier',
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'CARACTERES OBJETIVOS A EVALUAR:',
                    style: TextStyle(
                      color: Colors.white38,
                      fontFamily: 'Courier',
                      fontSize: 9,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    level.targetCharacters.join('   '),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontFamily: 'Courier',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'VOLUMEN DE DECK:',
                    style: TextStyle(
                      color: Colors.white38,
                      fontFamily: 'Courier',
                      fontSize: 9,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [15, 30, 50].map((v) {
                      final active = selectedVolume == v;
                      return GestureDetector(
                        onTap: () => setState(() => selectedVolume = v),
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            border: Border.all(color: active ? accent : Colors.white10),
                            color: active ? accent.withValues(alpha: 0.1) : Colors.transparent,
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: Text(
                            '$v ÍTEMS',
                            style: TextStyle(
                              color: active ? accent : Colors.white30,
                              fontFamily: 'Courier',
                              fontSize: 9,
                              fontWeight: active ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'LÍMITE DE TIEMPO:',
                    style: TextStyle(
                      color: Colors.white38,
                      fontFamily: 'Courier',
                      fontSize: 9,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      (0, 'SIN LÍMITE'),
                      (60, '1 MIN'),
                      (180, '3 MIN'),
                      (300, '5 MIN'),
                    ].map((pair) {
                      final active = selectedDuration == pair.$1;
                      return GestureDetector(
                        onTap: () => setState(() => selectedDuration = pair.$1),
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            border: Border.all(color: active ? accent : Colors.white10),
                            color: active && pair.$1 > 0 ? accent.withValues(alpha: 0.1) : Colors.transparent,
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: Text(
                            pair.$2,
                            style: TextStyle(
                              color: active ? accent : Colors.white30,
                              fontFamily: 'Courier',
                              fontSize: 9,
                              fontWeight: active ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Text(
                        'PUNTUACIÓN MÁXIMA: ',
                        style: TextStyle(
                          color: Colors.white38,
                          fontFamily: 'Courier',
                          fontSize: 9,
                        ),
                      ),
                      Row(
                        children: List.generate(3, (starIdx) {
                          return Icon(
                            starIdx < displayStars ? Icons.star : Icons.star_border,
                            color: starIdx < displayStars
                                ? starColor
                                : starColor.withValues(alpha: 0.2),
                            size: 12,
                          );
                        }),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text(
                    'VOLVER',
                    style: TextStyle(
                      color: Colors.white30,
                      fontFamily: 'Courier',
                      fontSize: 11,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(ctx); // Close dialog
                    ref.read(settingsProvider.notifier).setCampaignSessionVolume(selectedVolume);
                    ref.read(settingsProvider.notifier).setCampaignSessionDuration(selectedDuration);
                    ref.read(timelineProvider.notifier).startCampaignLevel(level);
                    context.pop();
                  },
                  child: Text(
                    'START LEVEL ENGINE',
                    style: TextStyle(
                      color: level.isBoss ? CyberTheme.errorRed : accent,
                      fontFamily: 'Courier',
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final accent = _getAccentColor(settings.accentColor);
    final campaignState = ref.watch(kanaCampaignProvider);

    return Scaffold(
      backgroundColor: Colors.black, // PURE OLED BLACK
      body: SafeArea(
        child: Column(
          children: [
            // Header bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      context.pop();
                    },
                    child: Icon(Icons.arrow_back_ios, color: accent, size: 20),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'MAPA DE NIVELES KANA',
                    style: TextStyle(
                      color: accent,
                      fontFamily: 'Courier',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),

            const Divider(color: Colors.white10, height: 1),

            // Tab toggles (HIRAGANA / MIXTO / KATAKANA)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ToggleBtn(
                    'HIRAGANA',
                    _filterSystem == ProgressiveSystem.hira,
                    accent,
                    () {
                      setState(() => _filterSystem = ProgressiveSystem.hira);
                    },
                  ),
                  _ToggleBtn(
                    'MIXTO',
                    _filterSystem == ProgressiveSystem.both,
                    accent,
                    () {
                      setState(() => _filterSystem = ProgressiveSystem.both);
                    },
                  ),
                  _ToggleBtn(
                    'KATAKANA',
                    _filterSystem == ProgressiveSystem.kata,
                    accent,
                    () {
                      setState(() => _filterSystem = ProgressiveSystem.kata);
                    },
                  ),
                ],
              ),
            ),

            // Grid sequential body
            Expanded(
              child: campaignState.when(
                loading: () =>
                    Center(child: CircularProgressIndicator(color: accent)),
                error: (err, _) => Center(
                  child: Text(
                    'Error: $err',
                    style: const TextStyle(color: CyberTheme.errorRed),
                  ),
                ),
                data: (levels) {
                  // Filter levels by script selected tab
                  final filtered = levels.where((l) {
                    if (_filterSystem == ProgressiveSystem.hira) {
                      return l.levelId <= 50;
                    }
                    if (_filterSystem == ProgressiveSystem.kata) {
                      return l.levelId > 50;
                    }
                    return true;
                  }).toList();

                  return GridView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 5,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 0.9,
                        ),
                    itemCount: filtered.length,
                    itemBuilder: (ctx, index) {
                      final level = filtered[index];
                      final isUnlocked = level.isUnlocked;
                      final isBoss = level.isBoss;

                      Widget content;
                      if (!isUnlocked) {
                        content = Container(
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.05),
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.lock_outline,
                            size: 14,
                            color: Colors.white24,
                          ),
                        );
                      } else {
                        final isHardcore = settings.hardcoreMode;
                        final displayStars = isHardcore
                            ? level.redStars
                            : level.stars;
                        final starColor = isHardcore
                            ? CyberTheme.errorRed
                            : accent;

                        content = Container(
                          decoration: BoxDecoration(
                            color: isBoss
                                ? CyberTheme.errorRed.withValues(alpha: 0.05)
                                : accent.withValues(alpha: 0.03),
                            border: Border.all(
                              color: isBoss
                                  ? CyberTheme.errorRed.withValues(alpha: 0.5)
                                  : accent.withValues(alpha: 0.2),
                              width: isBoss ? 1.5 : 1.0,
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                isBoss ? 'BOSS' : 'L${level.levelId}',
                                style: TextStyle(
                                  color: isBoss ? CyberTheme.errorRed : accent,
                                  fontFamily: 'Courier',
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(3, (starIdx) {
                                  return Icon(
                                    starIdx < displayStars
                                        ? Icons.star
                                        : Icons.star_border,
                                    color: starIdx < displayStars
                                        ? starColor
                                        : starColor.withValues(alpha: 0.15),
                                    size: 9,
                                  );
                                }),
                              ),
                            ],
                          ),
                        );
                      }

                      return GestureDetector(
                        onTap: () {
                          if (!isUnlocked) return;
                          _showLevelPreview(context, level, accent);
                        },
                        child: content,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToggleBtn extends StatelessWidget {
  const _ToggleBtn(this.label, this.isActive, this.accent, this.onTap);
  final String label;
  final bool isActive;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? accent.withValues(alpha: 0.1) : Colors.transparent,
          border: Border.all(color: isActive ? accent : Colors.white10),
          borderRadius: BorderRadius.circular(2),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? accent : Colors.white30,
            fontFamily: 'Courier',
            fontSize: 10,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }
}
