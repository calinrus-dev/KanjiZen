import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kz_core/kz_core.dart';
import 'package:kz_domain/kz_domain.dart';
import 'package:kz_data/kz_data.dart';
import 'package:kz_ui_components/kz_ui_components.dart';
import 'package:kanjizen_app/src/providers/game_provider.dart';
import 'package:kanjizen_app/src/providers/kanji_srs_provider.dart';
import 'package:kanjizen_app/src/providers/kana_campaign_provider.dart';
import 'package:kanjizen_app/src/features/home/presentation/general_drawer.dart';

class EngineSelectorScreen extends ConsumerStatefulWidget {
  const EngineSelectorScreen({super.key});

  @override
  ConsumerState<EngineSelectorScreen> createState() => _EngineSelectorScreenState();
}

class _EngineSelectorScreenState extends ConsumerState<EngineSelectorScreen> {
  final TextEditingController _inputController = TextEditingController();
  final FocusNode _inputFocusNode = FocusNode();

  // KANA Level campaign state
  KanaLevelModel? activeLevel;
  int levelQuestionsAnswered = 0;
  int levelErrors = 0;
  int levelSuccesses = 0;
  int levelMaxResponseMs = 0;
  bool showLevelSummary = false;

  // KANJI state
  bool isPlayingKanji = false;

  @override
  void dispose() {
    _inputController.dispose();
    _inputFocusNode.dispose();
    super.dispose();
  }

  // COMPOSER MODE input validation
  void _handleInputChanged(
    String text,
    EngineMode currentMode,
    GameState mecaState,
    GameNotifier mecaNotifier,
    KanjiSrsState kanjiState,
    KanjiSrsNotifier kanjiNotifier,
  ) {
    final cleanInput = text.toLowerCase().trim();

    if (currentMode == EngineMode.meca || activeLevel != null) {
      if (mecaState.currentSequence.isEmpty) return;
      final current = mecaState.currentSequence[mecaState.currentSequenceIndex];
      final targetRomaji = current.romaji.toLowerCase().trim();
      final targetJapanese = current.character.toLowerCase().trim();

      if (cleanInput.isEmpty) {
        mecaNotifier.clearInput();
        return;
      }

      // ACERTO ABSOLUTO
      if (cleanInput == targetRomaji || cleanInput == targetJapanese) {
        _inputController.clear();
        mecaNotifier.onInputChanged(targetRomaji);

        if (activeLevel != null) {
          setState(() {
            levelQuestionsAnswered++;
            levelSuccesses++;
            final responseMs = mecaState.lastResponseMs;
            if (responseMs > levelMaxResponseMs) {
              levelMaxResponseMs = responseMs;
            }
          });

          // Verificar fin de nivel
          if (levelQuestionsAnswered >= activeLevel!.targetCharacters.length) {
            final hitRate = levelSuccesses / levelQuestionsAnswered;
            ref.read(kanaCampaignProvider.notifier).evaluateSession(
              levelId: activeLevel!.levelId,
              hitRate: hitRate,
              maxTimePerCharMs: levelMaxResponseMs,
              isHardcore: ref.read(settingsProvider).hardcoreMode,
            );
            mecaNotifier.pause();
            setState(() {
              showLevelSummary = true;
            });
          }
        }
        return;
      }

      // COMPOSER MODE
      if (targetRomaji.startsWith(cleanInput) || targetJapanese.startsWith(cleanInput)) {
        mecaNotifier.onInputChanged(text);
        return;
      }

      // FALLO ABSOLUTO
      _inputController.clear();
      mecaNotifier.onInputChanged('__wrong_input__');

      if (activeLevel != null) {
        setState(() {
          levelQuestionsAnswered++;
          levelErrors++;
          final responseMs = mecaState.lastResponseMs;
          if (responseMs > levelMaxResponseMs) {
            levelMaxResponseMs = responseMs;
          }
        });

        // Verificar fin de nivel
        if (levelQuestionsAnswered >= activeLevel!.targetCharacters.length) {
          final hitRate = levelSuccesses / levelQuestionsAnswered;
          ref.read(kanaCampaignProvider.notifier).evaluateSession(
            levelId: activeLevel!.levelId,
            hitRate: hitRate,
            maxTimePerCharMs: levelMaxResponseMs,
            isHardcore: ref.read(settingsProvider).hardcoreMode,
          );
          mecaNotifier.pause();
          setState(() {
            showLevelSummary = true;
          });
        }
      }
    } else if (currentMode == EngineMode.kanji) {
      if (kanjiState.activePool.isEmpty) return;
      final kanji = kanjiState.activePool.first;
      final phase = kanjiNotifier.getPhaseFor(kanji.srsScore);

      if (cleanInput.isEmpty) return;

      if (phase == KanjiSrsPhase.inversion) {
        final target = kanji.character.toLowerCase().trim();
        if (cleanInput == target) {
          _inputController.clear();
          kanjiNotifier.recordSuccess(kanji);
          return;
        }
        if (target.startsWith(cleanInput)) {
          return;
        }
        _inputController.clear();
        kanjiNotifier.recordError(kanji);
      } else {
        bool matchesAny(String input, bool isExact) {
          final clean = input.trim().toLowerCase();

          String toRomaji(String kanaStr) {
            final sb = StringBuffer();
            for (var i = 0; i < kanaStr.length; i++) {
              final char = kanaStr[i];
              if (char == '.' || char == '-' || char == ' ') continue;
              final seed = KanaSeedData.all.where((KanaSeed s) => s.character == char).firstOrNull;
              if (seed != null) {
                sb.write(seed.romaji);
              } else {
                sb.write(char);
              }
            }
            return sb.toString().toLowerCase();
          }

          // Onyomi
          for (final onyomi in kanji.onyomi) {
            final cleanOnyomi = onyomi.replaceAll('.', '').replaceAll('-', '').trim().toLowerCase();
            final romajiOnyomi = toRomaji(onyomi);
            if (isExact) {
              if (cleanOnyomi == clean || romajiOnyomi == clean) return true;
            } else {
              if (cleanOnyomi.startsWith(clean) || romajiOnyomi.startsWith(clean)) return true;
            }
          }
          // Kunyomi
          for (final kunyomi in kanji.kunyomi) {
            final cleanKunyomi = kunyomi.replaceAll('.', '').replaceAll('-', '').trim().toLowerCase();
            final romajiKunyomi = toRomaji(kunyomi);
            if (isExact) {
              if (cleanKunyomi == clean || romajiKunyomi == clean) return true;
            } else {
              if (cleanKunyomi.startsWith(clean) || romajiKunyomi.startsWith(clean)) return true;
            }
          }
          // Meanings
          for (final meaning in kanji.meanings) {
            final cleanMeaning = meaning.trim().toLowerCase();
            if (isExact) {
              if (cleanMeaning == clean) return true;
            } else {
              if (cleanMeaning.startsWith(clean)) return true;
            }
          }
          return false;
        }

        if (matchesAny(cleanInput, true)) {
          _inputController.clear();
          kanjiNotifier.recordSuccess(kanji);
          return;
        }

        if (matchesAny(cleanInput, false)) {
          return;
        }

        _inputController.clear();
        kanjiNotifier.recordError(kanji);
      }
    }
  }

  void _showContextSettings(BuildContext context, EngineMode mode) {
    final settings = ref.watch(settingsProvider);
    final accent = _getAccentColor(settings.accentColor);

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF05060A),
      shape: Border(top: BorderSide(color: accent.withValues(alpha: 0.3))),
      builder: (_) {
        return Consumer(
          builder: (ctx, refWatch, _) {
            final s = refWatch.watch(settingsProvider);
            final n = refWatch.read(settingsProvider.notifier);

            return Container(
              padding: EdgeInsets.only(
                top: 24,
                left: 24,
                right: 24,
                bottom: MediaQuery.of(ctx).padding.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        mode == EngineMode.kanji ? 'KANJI 1.0 — CONFIGURACIÓN' : 'CONFIGURACIÓN CONTEXTUAL',
                        style: TextStyle(
                          color: accent,
                          fontFamily: 'Courier',
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(ctx),
                        child: Icon(Icons.close, color: accent, size: 20),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  if (mode == EngineMode.meca || mode == EngineMode.kana) ...[
                    _buildSettingsRow(
                      label: 'TIPO DE GENERADOR DE POZO',
                      value: s.poolMode == PoolMode.auto ? 'AUTO' : 'CUSTOM',
                      accent: accent,
                      onTap: () {
                        n.setPoolMode(s.poolMode == PoolMode.auto ? PoolMode.custom : PoolMode.auto);
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildSettingsRow(
                      label: 'TAMAÑO DE RECILLA (LAYOUT)',
                      value: s.layoutMode.name.toUpperCase(),
                      accent: accent,
                      onTap: () {
                        final next = switch (s.layoutMode) {
                          AppLayoutMode.syllable => AppLayoutMode.word,
                          AppLayoutMode.word => AppLayoutMode.text,
                          AppLayoutMode.text => AppLayoutMode.syllable,
                        };
                        n.setLayoutMode(next);
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildSettingsRow(
                      label: 'RELOJ DE LA MUERTE (DEATH CLOCK)',
                      value: s.deathClock == DeathClock.off ? 'OFF' : '${s.deathClock.name.replaceAll('s', '').replaceAll('_', '.')}s',
                      accent: accent,
                      onTap: () {
                        final next = switch (s.deathClock) {
                          DeathClock.off => DeathClock.s5,
                          DeathClock.s5 => DeathClock.s3,
                          DeathClock.s3 => DeathClock.s1_5,
                          DeathClock.s1_5 => DeathClock.s1,
                          DeathClock.s1 => DeathClock.s0_75,
                          DeathClock.s0_75 => DeathClock.s0_5,
                          DeathClock.s0_5 => DeathClock.off,
                        };
                        n.setDeathClock(next);
                      },
                    ),
                  ],

                  if (mode == EngineMode.kanji) ...[
                    _buildSettingsRow(
                      label: 'DIBUJO VECTORIAL KANJIVG',
                      value: s.enableStrokeAnimation ? 'ON' : 'OFF',
                      accent: accent,
                      onTap: () => n.toggleStrokeAnimation(),
                    ),
                  ],

                  const SizedBox(height: 16),
                  _buildSettingsRow(
                    label: 'ASISTENCIA ROMAJI',
                    value: s.romajiAssist ? 'ON (${s.romajiThreshold} FALLOS)' : 'OFF',
                    accent: accent,
                    onTap: () => n.toggleRomajiAssist(),
                  ),
                  if (s.romajiAssist) ...[
                    const SizedBox(height: 8),
                    SliderTheme(
                      data: SliderThemeData(
                        trackHeight: 1,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                        activeTrackColor: accent,
                        inactiveTrackColor: accent.withValues(alpha: 0.2),
                        thumbColor: accent,
                      ),
                      child: Slider(
                        value: s.romajiThreshold.toDouble(),
                        min: 1,
                        max: 5,
                        divisions: 4,
                        onChanged: (val) => n.setRomajiThreshold(val.toInt()),
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),
                  _buildSettingsRow(
                    label: 'MODO HARDCORE (SÚBITO)',
                    value: s.hardcoreMode ? 'ON (${s.hardcoreLives} VIDAS)' : 'OFF',
                    accent: accent,
                    onTap: () {
                      if (!s.hardcoreMode) {
                        n.toggleHardcoreMode();
                        n.setHardcoreLives(3);
                      } else if (s.hardcoreLives >= 10) {
                        n.toggleHardcoreMode();
                      } else {
                        n.setHardcoreLives(s.hardcoreLives + 1);
                      }
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSettingsRow({
    required String label,
    required String value,
    required Color accent,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.transparent,
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(color: Colors.white70, fontFamily: 'Courier', fontSize: 11),
              ),
            ),
            Text(
              '[$value]',
              style: TextStyle(color: accent, fontFamily: 'Courier', fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final accent = _getAccentColor(settings.accentColor);
    final currentMode = settings.engineMode;

    final mecaState = ref.watch(gameProvider);
    final mecaNotifier = ref.read(gameProvider.notifier);

    final kanjiState = ref.watch(kanjiSrsProvider);
    final kanjiNotifier = ref.read(kanjiSrsProvider.notifier);

    final campaignState = ref.watch(kanaCampaignProvider);

    // Determinar la telemetría dinámica
    String telemetryText = '[Racha: 0 | ms: — | A: 0%]';
    EngineState currentEngineState = EngineState.welcome;

    if (currentMode == EngineMode.meca || activeLevel != null) {
      currentEngineState = mecaState.engineState;
      final acc = (mecaState.hitRate * 100).toStringAsFixed(0);
      telemetryText = '[Racha: ${mecaState.streak} | ms: ${mecaState.avgMs > 0 ? mecaState.avgMs : '—'} | A: $acc%]';
    } else if (currentMode == EngineMode.kanji) {
      currentEngineState = kanjiState.engineState;
      final acc = (kanjiState.hitRate * 100).toStringAsFixed(0);
      telemetryText = '[Racha: ${kanjiState.streak} | ms: ${kanjiState.avgMs > 0 ? kanjiState.avgMs : '—'} | A: $acc%]';
    }

    // Altura del Viewport
    final mediaQuery = MediaQuery.of(context);
    final keyboardHeight = mediaQuery.viewInsets.bottom;
    final viewHeight = (mediaQuery.size.height - keyboardHeight - 140.0).clamp(150.0, 520.0);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (currentEngineState == EngineState.playing) {
          if (currentMode == EngineMode.meca || activeLevel != null) {
            mecaNotifier.pause();
          } else {
            kanjiNotifier.pause();
          }
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black, // OLED absoluto
        drawer: GeneralDrawer(accent: accent),
        body: SafeArea(
          child: Column(
            children: [
              // ── CABECERA COMPACTA ──────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    // Hamburguesa
                    Builder(
                      builder: (ctx) => GestureDetector(
                        onTap: () => Scaffold.of(ctx).openDrawer(),
                        child: const Icon(Icons.menu, color: Colors.white, size: 20),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Telemetría
                    Expanded(
                      child: Text(
                        telemetryText,
                        style: TextStyle(
                          color: accent.withValues(alpha: 0.5),
                          fontFamily: 'Courier',
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Selector de Modo (Horizontal Scrollable)
                    Flexible(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _ModeTab('[KANA]', currentMode == EngineMode.kana, accent, () {
                              setState(() {
                                activeLevel = null;
                                isPlayingKanji = false;
                              });
                              mecaNotifier.welcome();
                              kanjiNotifier.welcome();
                              ref.read(settingsProvider.notifier).setEngineMode(EngineMode.kana);
                            }),
                            const SizedBox(width: 8),
                            _ModeTab('[MECA]', currentMode == EngineMode.meca, accent, () {
                              setState(() {
                                activeLevel = null;
                                isPlayingKanji = false;
                              });
                              mecaNotifier.welcome();
                              kanjiNotifier.welcome();
                              ref.read(settingsProvider.notifier).setEngineMode(EngineMode.meca);
                            }),
                            const SizedBox(width: 8),
                            _ModeTab('[KANJI]', currentMode == EngineMode.kanji, accent, () {
                              setState(() {
                                activeLevel = null;
                                isPlayingKanji = false;
                              });
                              mecaNotifier.welcome();
                              kanjiNotifier.welcome();
                              ref.read(settingsProvider.notifier).setEngineMode(EngineMode.kanji);
                            }),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Ruedecita de Ajustes
                    GestureDetector(
                      onTap: () => _showContextSettings(context, currentMode),
                      child: Icon(Icons.settings_outlined, color: accent, size: 18),
                    ),
                  ],
                ),
              ),

              const Divider(color: Colors.white12, height: 1),

              // ── CUERPO / VIEWPORT CENTRAL ─────────────────────────────────
              Expanded(
                child: Center(
                  child: AnimatedSize(
                    duration: const Duration(milliseconds: 150),
                    child: SizedBox(
                      height: viewHeight,
                      width: double.infinity,
                      child: LayoutBuilder(
                        builder: (ctx, constraints) {
                          // Determinar qué widget de modo pintar
                          if (currentMode == EngineMode.kana && activeLevel == null) {
                            // Mostrar GRID de Campaña KANA
                            return campaignState.when(
                              loading: () => Center(child: CircularProgressIndicator(color: accent)),
                              error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: Colors.red))),
                              data: (levels) => _buildKanaGrid(levels, settings.progressiveSystem, accent),
                            );
                          }

                          if (currentMode == EngineMode.kanji && !isPlayingKanji) {
                            // Mostrar Landing de KANJI SRS
                            return _buildKanjiLanding(kanjiState, accent, kanjiNotifier);
                          }

                          // MODO DE JUEGO ACTIVO
                          if (currentEngineState != EngineState.playing) {
                            // Mostrar IDLE OVERLAY
                            return _buildIdleOverlay(currentMode, accent, mecaNotifier, kanjiNotifier);
                          }

                          if (showLevelSummary) {
                            // Mostrar Resumen de Fin de Nivel KANA
                            return _buildLevelSummary(accent);
                          }

                          // RENDERIZAR CARÁCTER FLOTANTE DESNUDO EN ESPACIO NEGATIVO
                          return Stack(
                            children: [
                              Center(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Opacity(
                                    opacity: settings.canvasOpacity,
                                    child: _buildNakedCharacter(currentMode, mecaState, kanjiState, settings, accent),
                                  ),
                                ),
                              ),

                              // Controles o Fase en Kanji
                              if (currentMode == EngineMode.kanji && kanjiState.activePool.isNotEmpty) ...[
                                Positioned(
                                  top: 16,
                                  left: 0,
                                  right: 0,
                                  child: Center(
                                    child: Text(
                                      'FASE: ${kanjiNotifier.getPhaseFor(kanjiState.activePool.first.srsScore).name.toUpperCase()}',
                                      style: TextStyle(
                                        color: accent.withValues(alpha: 0.3),
                                        fontFamily: 'Courier',
                                        fontSize: 9,
                                        letterSpacing: 2,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),

              // ── BARRA DE ENTRADA CHATBOT (ABAJO DEL TODO) ──────────────────
              if (currentEngineState == EngineState.playing && !showLevelSummary && !_isPhase4MultipleChoice(currentMode, kanjiState, kanjiNotifier))
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    border: Border(top: BorderSide(color: Colors.white10, width: 0.5)),
                  ),
                  child: TextField(
                    controller: _inputController,
                    focusNode: _inputFocusNode,
                    onChanged: (val) => _handleInputChanged(val, currentMode, mecaState, mecaNotifier, kanjiState, kanjiNotifier),
                    autofocus: true,
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Courier',
                      fontSize: 13,
                      fontWeight: settings.useBoldText ? FontWeight.bold : FontWeight.normal,
                      letterSpacing: 2,
                    ),
                    cursorColor: accent,
                    cursorHeight: 14,
                    decoration: InputDecoration(
                      hintText: currentMode == EngineMode.kanji &&
                              kanjiState.activePool.isNotEmpty &&
                              kanjiNotifier.getPhaseFor(kanjiState.activePool.first.srsScore) == KanjiSrsPhase.inversion
                          ? 'Dibuja o escribe el Kanji...'
                          : 'Escribe en romaji...',
                      hintStyle: const TextStyle(
                        color: Colors.white24,
                        fontFamily: 'Courier',
                        fontSize: 11,
                        letterSpacing: 1.5,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),

              if (currentEngineState == EngineState.playing && !showLevelSummary && _isPhase4MultipleChoice(currentMode, kanjiState, kanjiNotifier))
                _buildMultipleChoiceGrid(kanjiState.activePool.first, accent, kanjiNotifier),
            ],
          ),
        ),
      ),
    );
  }

  // Comprueba si estamos en la fase 4 discriminatoria de Kanji
  bool _isPhase4MultipleChoice(EngineMode mode, KanjiSrsState srsState, KanjiSrsNotifier notifier) {
    if (mode != EngineMode.kanji || srsState.activePool.isEmpty) return false;
    final kanji = srsState.activePool.first;
    return notifier.getPhaseFor(kanji.srsScore) == KanjiSrsPhase.discriminatory;
  }

  // ── RENDERIZAR CARÁCTER DESNUDO SIN RECUARES ──────────────────────────────
  Widget _buildNakedCharacter(
    EngineMode mode,
    GameState mecaState,
    KanjiSrsState kanjiState,
    SettingsState settings,
    Color accent,
  ) {
    if (mode == EngineMode.meca || activeLevel != null) {
      if (mecaState.currentSequence.isEmpty) {
        return const Text('SIN DATOS', style: TextStyle(color: Colors.white24, fontFamily: 'Courier', fontSize: 14));
      }
      final current = mecaState.currentSequence[mecaState.currentSequenceIndex];
      return Text(
        current.character,
        style: TextStyle(
          color: Colors.white,
          fontSize: 160,
          fontWeight: settings.useBoldText ? FontWeight.w900 : FontWeight.w100,
          fontFamily: 'Courier',
        ),
      );
    } else {
      // MODO KANJI SRS
      if (kanjiState.activePool.isEmpty) {
        return const Text('POOL VACÍO', style: TextStyle(color: Colors.white24, fontFamily: 'Courier', fontSize: 14));
      }
      final kanji = kanjiState.activePool.first;
      final phase = ref.read(kanjiSrsProvider.notifier).getPhaseFor(kanji.srsScore);

      if (phase == KanjiSrsPhase.initial || phase == KanjiSrsPhase.withdrawal) {
        // Fase 1 y 2: Mostrar el Kanji directamente (o vectorial)
        if (settings.enableStrokeAnimation && kanji.svgPaths.isNotEmpty) {
          return SizedBox(
            width: 180,
            height: 180,
            child: CustomPaint(
              painter: KanjiVectorPainter(
                svgPaths: kanji.svgPaths,
                accentColor: accent,
              ),
            ),
          );
        }
        return Text(
          kanji.character,
          style: TextStyle(
            color: Colors.white,
            fontSize: 160,
            fontWeight: settings.useBoldText ? FontWeight.w900 : FontWeight.w100,
          ),
        );
      } else {
        // Fase 3 y 4: Mostrar Concepto/Significado
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              kanji.meanings.first.toUpperCase(),
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontFamily: 'Courier',
                letterSpacing: 4,
                fontWeight: settings.useBoldText ? FontWeight.bold : FontWeight.w300,
              ),
              textAlign: TextAlign.center,
            ),
            if (phase == KanjiSrsPhase.initial) ...[
              const SizedBox(height: 12),
              Text(
                kanji.meanings.join(', '),
                style: const TextStyle(color: Colors.white38, fontFamily: 'Courier', fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        );
      }
    }
  }

  // ── RENDERIZAR MENÚ DE PAUSA / IDLE OVERLAY ────────────────────────────────
  Widget _buildIdleOverlay(EngineMode mode, Color accent, GameNotifier mecaNotifier, KanjiSrsNotifier kanjiNotifier) {
    final title = mode == EngineMode.kana ? 'KANA 1.0' : (mode == EngineMode.meca ? 'MECA 1.0' : 'KANJI 1.0');

    return Stack(
      children: [
        // Fondo semi-oscuro para opacidad del 20%
        Container(
          color: Colors.black.withValues(alpha: 0.8),
        ),

        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: accent,
                  fontFamily: 'Courier',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 32),
              _buildMenuAction(
                label: '[ ENTRAR AL SISTEMA ]',
                accent: accent,
                onTap: () {
                  if (mode == EngineMode.meca || activeLevel != null) {
                    mecaNotifier.resume();
                  } else if (mode == EngineMode.kanji) {
                    setState(() {
                      isPlayingKanji = true;
                    });
                    kanjiNotifier.resume();
                  }
                },
              ),
              const SizedBox(height: 16),
              _buildMenuAction(
                label: '[ AJUSTES CONTEXTUALES ]',
                accent: accent,
                onTap: () => _showContextSettings(context, mode),
              ),
              const SizedBox(height: 16),
              _buildMenuAction(
                label: '[ SALIR DEL MOTOR ]',
                accent: accent,
                onTap: () => SystemNavigator.pop(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMenuAction({required String label, required Color accent, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
        child: Text(
          label,
          style: TextStyle(
            color: accent,
            fontFamily: 'Courier',
            fontSize: 13,
            letterSpacing: 2,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }

  // ── RENDERIZAR GRID KANA 20x5 ──────────────────────────────────────────────
  Widget _buildKanaGrid(List<KanaLevelModel> levels, ProgressiveSystem system, Color accent) {
    // Filtrar niveles por modo
    final filtered = levels.where((l) {
      if (system == ProgressiveSystem.hira) return l.levelId <= 50;
      if (system == ProgressiveSystem.kata) return l.levelId > 50;
      return true;
    }).toList();

    return Column(
      children: [
        // Secondary Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _ToggleBtn('HIRAGANA', system == ProgressiveSystem.hira, accent, () {
                ref.read(settingsProvider.notifier).setProgressiveSystem(ProgressiveSystem.hira);
              }),
              _ToggleBtn('MIXTO', system == ProgressiveSystem.both, accent, () {
                ref.read(settingsProvider.notifier).setProgressiveSystem(ProgressiveSystem.both);
              }),
              _ToggleBtn('KATAKANA', system == ProgressiveSystem.kata, accent, () {
                ref.read(settingsProvider.notifier).setProgressiveSystem(ProgressiveSystem.kata);
              }),
            ],
          ),
        ),

        // Grid 20x5
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 0.9,
            ),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final level = filtered[index];
              final isUnlocked = level.isUnlocked;

              Widget content;
              if (!isUnlocked) {
                content = Container(
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    border: Border.all(color: Colors.white10),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(Icons.lock_outline, size: 14, color: Colors.white24),
                );
              } else {
                final isHardcore = ref.read(settingsProvider).hardcoreMode;
                final displayStars = isHardcore ? level.redStars : level.stars;
                final starColor = isHardcore ? CyberTheme.errorRed : accent;

                content = Container(
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.05),
                    border: Border.all(color: accent.withValues(alpha: 0.3)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'L${level.levelId}',
                        style: TextStyle(
                          color: accent,
                          fontFamily: 'Courier',
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(3, (starIdx) {
                          return Icon(
                            starIdx < displayStars ? Icons.star : Icons.star_border,
                            color: starIdx < displayStars ? starColor : starColor.withValues(alpha: 0.2),
                            size: 10,
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
                  setState(() {
                    activeLevel = level;
                    levelQuestionsAnswered = 0;
                    levelErrors = 0;
                    levelSuccesses = 0;
                    levelMaxResponseMs = 0;
                    showLevelSummary = false;
                  });
                  ref.read(gameProvider.notifier).initializeCampaign(level);
                  ref.read(gameProvider.notifier).resume();
                },
                child: content,
              );
            },
          ),
        ),
      ],
    );
  }

  // ── RENDERIZAR SUMMARY FIN DE NIVEL KANA ───────────────────────────────────
  Widget _buildLevelSummary(Color accent) {
    final hitRate = levelSuccesses / levelQuestionsAnswered;
    final success = hitRate >= 0.8;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            success ? Icons.verified_user_outlined : Icons.report_problem_outlined,
            color: success ? accent : CyberTheme.errorRed,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            success ? 'NIVEL COMPLETADO' : 'NIVEL FALLIDO',
            style: TextStyle(
              color: success ? accent : CyberTheme.errorRed,
              fontFamily: 'Courier',
              fontSize: 15,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'ACIERTO: ${(hitRate * 100).toStringAsFixed(0)}% ($levelSuccesses/$levelQuestionsAnswered)\n'
            'VELOCIDAD MÁX: ${levelMaxResponseMs}ms',
            style: const TextStyle(color: Colors.white70, fontFamily: 'Courier', fontSize: 11, height: 1.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          CyberButton(
            label: 'VOLVER AL MAPA',
            accent: accent,
            onTap: () {
              setState(() {
                activeLevel = null;
                showLevelSummary = false;
              });
              ref.read(gameProvider.notifier).welcome();
            },
          ),
        ],
      ),
    );
  }

  // ── RENDERIZAR LANDING KANJI SRS ───────────────────────────────────────────
  Widget _buildKanjiLanding(KanjiSrsState srsState, Color accent, KanjiSrsNotifier notifier) {
    return Center(
      child: srsState.isLoading
          ? CircularProgressIndicator(color: accent)
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.psychology_outlined, size: 40, color: accent.withValues(alpha: 0.5)),
                const SizedBox(height: 16),
                Text(
                  'MOTOR RELACIONAL KANJI',
                  style: TextStyle(
                    color: accent,
                    fontFamily: 'Courier',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Ventana de Kanjis basada en historial de clics.\n'
                  'Progreso estocástico y penalización cognitiva.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontFamily: 'Courier',
                    fontSize: 10,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  margin: const EdgeInsets.symmetric(horizontal: 48),
                  decoration: BoxDecoration(
                    border: Border.all(color: accent.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildLandingStat('KANJIS ACTIVOS', srsState.activePool.length.toString(), accent),
                      _buildLandingStat('DOMINIO MEDIO', srsState.averagePoolScore.toStringAsFixed(1), accent),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                CyberButton(
                  label: 'INICIAR SISTEMA SRS',
                  icon: Icons.flash_on,
                  accent: accent,
                  onTap: () {
                    setState(() {
                      isPlayingKanji = true;
                    });
                    notifier.resume();
                  },
                ),
              ],
            ),
    );
  }

  Widget _buildLandingStat(String label, String value, Color accent) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white24, fontFamily: 'Courier', fontSize: 8, letterSpacing: 1),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(color: accent, fontFamily: 'Courier', fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  // ── PANEL DE SELECCIÓN MÚLTIPLE DE RADICALES (KANJI FASE 4) ────────────────
  Widget _buildMultipleChoiceGrid(KanjiModel kanji, Color accent, KanjiSrsNotifier notifier) {
    final options = notifier.generateDiscriminatoryOptions(kanji);

    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.black,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.5,
        ),
        itemCount: options.length,
        itemBuilder: (context, i) {
          final opt = options[i];
          return InkWell(
            onTap: () {
              if (opt == kanji.character) {
                notifier.recordSuccess(kanji);
              } else {
                notifier.recordError(kanji);
              }
            },
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: accent.withValues(alpha: 0.3)),
                borderRadius: BorderRadius.circular(4),
              ),
              alignment: Alignment.center,
              child: Text(
                opt,
                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w300),
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getAccentColor(CyberAccent c) {
    switch (c) {
      case CyberAccent.green: return CyberTheme.defaultAccent;
      case CyberAccent.red: return CyberTheme.errorRed;
      case CyberAccent.orange: return Colors.orange;
      case CyberAccent.blue: return Colors.cyanAccent;
      case CyberAccent.purple: return Colors.purpleAccent;
      case CyberAccent.white: return Colors.white;
    }
  }
}

class _ModeTab extends StatelessWidget {
  const _ModeTab(this.label, this.isActive, this.accent, this.onTap);
  final String label;
  final bool isActive;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? accent : Colors.white24,
            fontFamily: 'Courier',
            fontSize: 11,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w300,
            letterSpacing: 1,
          ),
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
          borderRadius: BorderRadius.circular(3),
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
