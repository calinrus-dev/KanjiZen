import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kz_core/kz_core.dart';
import 'package:kz_domain/kz_domain.dart';
import 'package:kz_ui_components/kz_ui_components.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:kanjizen_app/src/providers/timeline_provider.dart';
import 'package:kanjizen_app/src/features/home/presentation/widgets/dynamic_terminal_bar.dart';
import 'package:kanjizen_app/src/features/home/presentation/widgets/meca_input_widget.dart';
import 'package:kanjizen_app/src/features/home/presentation/widgets/kanji_production_widget.dart';
import 'package:kanjizen_app/src/features/home/presentation/widgets/kanji_quiz_widget.dart';
import 'package:kanjizen_app/src/features/home/presentation/widgets/arcade_viewport_widget.dart';
import 'package:kanjizen_app/src/features/home/presentation/widgets/stroke_validation_widget.dart';
import 'package:kanjizen_app/src/features/home/presentation/widgets/exercise_report_widget.dart';
import 'package:kanjizen_app/src/features/home/presentation/general_drawer.dart';

class EngineSelectorScreen extends ConsumerStatefulWidget {
  const EngineSelectorScreen({super.key});

  @override
  ConsumerState<EngineSelectorScreen> createState() =>
      _EngineSelectorScreenState();
}

class _EngineSelectorScreenState extends ConsumerState<EngineSelectorScreen>
    with WidgetsBindingObserver {
  final ScrollController _scrollController = ScrollController();
  bool _showSnapToBottom = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    // Scroll atómico tras el cambio de ViewInsets
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _scrollToBottom();
    });
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    // Show snap to bottom if scrolled up by more than 100 pixels
    final scrolledUp = (maxScroll - currentScroll) > 100;
    if (scrolledUp != _showSnapToBottom) {
      setState(() {
        _showSnapToBottom = scrolledUp;
      });
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 50), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  void _showModeSelectorOverlay(
    BuildContext context,
    Color accent,
    EngineMode activeMode,
  ) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Cerrar selector de modo',
      barrierColor: Colors.black87,
      transitionDuration: const Duration(milliseconds: 150),
      pageBuilder: (ctx, anim1, anim2) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              margin: const EdgeInsets.symmetric(horizontal: 32),
              decoration: BoxDecoration(
                color: CyberTheme.bgObsidian.withValues(alpha: 0.9),
                border: Border.all(
                  color: accent.withValues(alpha: 0.3),
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.1),
                    blurRadius: 30,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'SELECCIONAR MOTOR DE APRENDIZAJE',
                    style: TextStyle(
                      color: accent,
                      fontSize: 11,
                      fontFamily: 'Courier',
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildOverlayModeBtn(
                    ctx,
                    'MECA 1.0',
                    EngineMode.meca,
                    accent,
                    activeMode == EngineMode.meca,
                  ),
                  const SizedBox(height: 12),
                  _buildOverlayModeBtn(
                    ctx,
                    'KANJI 1.0',
                    EngineMode.kanji,
                    accent,
                    activeMode == EngineMode.kanji,
                  ),
                  const SizedBox(height: 12),
                  _buildOverlayModeBtn(
                    ctx,
                    'QUIZ 1.0',
                    EngineMode.quiz,
                    accent,
                    activeMode == EngineMode.quiz,
                  ),
                  const SizedBox(height: 12),
                  _buildOverlayModeBtn(
                    ctx,
                    'ARCADE 1.0',
                    EngineMode.arcade,
                    accent,
                    activeMode == EngineMode.arcade,
                  ),
                  const SizedBox(height: 12),
                  _buildOverlayModeBtn(
                    ctx,
                    'WRITE 1.0',
                    EngineMode.write,
                    accent,
                    activeMode == EngineMode.write,
                  ),
                  const SizedBox(height: 12),
                  _buildLockedOverlayModeBtn('AI_MODE (BLOQUEADO)'),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOverlayModeBtn(
    BuildContext ctx,
    String label,
    EngineMode mode,
    Color accent,
    bool isActive,
  ) {
    return GestureDetector(
      onTap: () {
        ref.read(timelineProvider.notifier).setEngineMode(mode);
        Navigator.pop(ctx);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(
            color: isActive ? accent : Colors.white10,
            width: isActive ? 1.5 : 1.0,
          ),
          borderRadius: BorderRadius.circular(4),
          color: isActive
              ? accent.withValues(alpha: 0.1)
              : Colors.white.withValues(alpha: 0.01),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.15),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isActive) ...[
              Icon(Icons.circle, color: accent, size: 8),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : accent.withValues(alpha: 0.7),
                fontFamily: 'Courier',
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLockedOverlayModeBtn(String label) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        borderRadius: BorderRadius.circular(4),
        color: Colors.transparent,
      ),
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.lock_outline, color: Colors.white24, size: 14),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white24,
              fontFamily: 'Courier',
              fontSize: 13,
              letterSpacing: 2,
              decoration: TextDecoration.none,
            ),
          ),
        ],
      ),
    );
  }

  void _showContextSettings(
    BuildContext context,
    EngineMode mode,
    Color accent,
  ) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF000000), // Pure OLED Black
      shape: Border(
        top: BorderSide(color: accent.withValues(alpha: 0.3), width: 1.5),
      ),
      isScrollControlled: true,
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
                        '${mode.name.toUpperCase()} 1.0 — CONFIGURACIÓN',
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
                  if (mode == EngineMode.meca) ...[
                    _buildSettingsRow(
                      label: 'TAMAÑO DE REJILLA / LAYOUT',
                      control: CyberSegmentedControl<GridScale>(
                        groupValue: s.gridScale,
                        children: const {
                          GridScale.sl: 'SL',
                          GridScale.l: 'L',
                          GridScale.xl: 'XL',
                          GridScale.auto: 'AUTO',
                        },
                        onValueChanged: (val) => n.setGridScale(val),
                        accentColor: accent,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildSettingsRow(
                      label: 'RELOJ DE LA MUERTE',
                      control: CyberSegmentedControl<DeathClock>(
                        groupValue: s.deathClock,
                        children: const {
                          DeathClock.off: 'OFF',
                          DeathClock.s1: '1s',
                          DeathClock.s3: '3s',
                          DeathClock.s5: '5s',
                        },
                        onValueChanged: (val) => n.setDeathClock(val),
                        accentColor: accent,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildSettingsRow(
                      label: 'ASISTENCIA ROMAJI',
                      control: OledToggleSwitch(
                        value: s.romajiAssist,
                        onChanged: (_) => n.toggleRomajiAssist(),
                        activeColor: accent,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildSettingsRow(
                      label: 'MODO HARDCORE (VIDAS)',
                      control: OledToggleSwitch(
                        value: s.hardcoreMode,
                        onChanged: (_) => n.toggleHardcoreMode(),
                        activeColor: accent,
                      ),
                    ),
                  ] else if (mode == EngineMode.kanji) ...[
                    _buildSettingsRow(
                      label: 'VENTANA DE TRABAJO ACTIVA',
                      control: CyberSegmentedControl<int>(
                        groupValue: s.kanjiBatchSize,
                        children: const {
                          3: 'LOTE 3',
                          5: 'LOTE 5',
                          10: 'LOTE 10',
                        },
                        onValueChanged: (val) => n.setKanjiBatchSize(val),
                        accentColor: accent,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildSettingsRow(
                      label: 'PROPORCIÓN SRS INYECCIÓN',
                      control: CyberSegmentedControl<SrsProportion>(
                        groupValue: s.srsProportion,
                        children: const {
                          SrsProportion.ratio80_20: '80/20',
                          SrsProportion.ratio60_40: '60/40',
                          SrsProportion.reviewOnly: 'REPASO',
                        },
                        onValueChanged: (val) => n.setSrsProportion(val),
                        accentColor: accent,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildSettingsRow(
                      label: 'FILTRO TEMÁTICO SESIÓN',
                      control: CyberSegmentedControl<KanjiFilterTopic>(
                        groupValue: s.kanjiFilterTopic,
                        children: const {
                          KanjiFilterTopic.grade: 'GRADO',
                          KanjiFilterTopic.jlpt: 'JLPT',
                        },
                        onValueChanged: (val) => n.setKanjiFilterTopic(val),
                        accentColor: accent,
                      ),
                    ),
                  ] else if (mode == EngineMode.quiz) ...[
                    _buildSettingsRow(
                      label: 'DENSIDAD DE MATRIZ INFERIOR',
                      control: CyberSegmentedControl<QuizDensity>(
                        groupValue: s.quizDensity,
                        children: const {
                          QuizDensity.matrix2x2: '2x2',
                          QuizDensity.matrix3x2: '3x2',
                        },
                        onValueChanged: (val) => n.setQuizDensity(val),
                        accentColor: accent,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildSettingsRow(
                      label: 'FILTRO RADICALES COINCIDENTES',
                      control: OledToggleSwitch(
                        value: s.quizMatchRadicals,
                        onChanged: (_) => n.toggleQuizMatchRadicals(),
                        activeColor: accent,
                      ),
                    ),
                  ] else if (mode == EngineMode.arcade) ...[
                    _buildSettingsRow(
                      label: 'NÚMERO DE CARRILES ACTIVOS',
                      control: CyberSegmentedControl<int>(
                        groupValue: s.arcadeLanes,
                        children: const {3: '3 CARR.', 4: '4 CARR.'},
                        onValueChanged: (val) => n.setArcadeLanes(val),
                        accentColor: accent,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildSettingsRow(
                      label: 'ACELERACIÓN BALÍSTICA PROGRESIVA',
                      control: OledToggleSwitch(
                        value: s.arcadeAcceleration,
                        onChanged: (_) => n.toggleArcadeAcceleration(),
                        activeColor: accent,
                      ),
                    ),
                  ] else if (mode == EngineMode.write) ...[
                    _buildSettingsRow(
                      label: 'TOLERANCIA ANGULAR TRAZO',
                      control: CyberSegmentedControl<double>(
                        groupValue: s.writeTolerance,
                        children: {15.0: '15°', 25.0: '25°', 35.0: '35°'},
                        onValueChanged: (val) => n.setWriteTolerance(val),
                        accentColor: accent,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildSettingsRow(
                      label: 'GUÍA DE PLANTILLA PASIVA',
                      control: OledToggleSwitch(
                        value: s.writeGuideTemplate,
                        onChanged: (_) => n.toggleWriteGuideTemplate(),
                        activeColor: accent,
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSettingsRow({required String label, required Widget control}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontFamily: 'Courier',
                fontSize: 10,
                letterSpacing: 1.0,
              ),
            ),
          ),
          const SizedBox(width: 16),
          control,
        ],
      ),
    );
  }

  Widget _buildActiveNodeWidget(FeedNode node, double localCanvasHeight) {
    if (node is MecaInputNode) {
      return MecaInputWidget(node: node);
    } else if (node is KanjiProductionNode) {
      return KanjiProductionWidget(productionNode: node);
    } else if (node is ConceptRecallNode) {
      return KanjiProductionWidget(recallNode: node);
    } else if (node is KanjiQuizNode) {
      return KanjiQuizWidget(node: node);
    } else if (node is LaneCollisionViewportNode) {
      return SizedBox(
        height: (localCanvasHeight * 0.55).clamp(280.0, 400.0),
        child: ArcadeViewportWidget(node: node),
      );
    } else if (node is StrokeValidationNode) {
      return SizedBox(
        height: (localCanvasHeight * 0.5).clamp(240.0, 320.0),
        child: StrokeValidationWidget(node: node),
      );
    } else if (node is ExerciseReportNode) {
      return ExerciseReportWidget(node: node);
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final accent = _getAccentColor(settings.accentColor);
    final timelineState = ref.watch(timelineProvider);
    final activeSession = timelineState.activeSession;
    final nodes = activeSession.nodes;

    final frozenNodes = nodes.where((n) => n.isFrozen).toList();
    final activeNode = nodes.where((n) => !n.isFrozen).firstOrNull;

    // Listen for new frozen timeline events to auto-scroll the history list
    ref.listen<int>(
      timelineProvider.select(
        (s) => s.activeSession.nodes.where((n) => n.isFrozen).length,
      ),
      (_, next) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
      },
    );

    // Dynamic Telemetry String
    final streak = timelineState.streak;
    final avgMs = timelineState.avgMs;
    final hitRateAcc = (timelineState.hitRate * 100).toStringAsFixed(0);
    final telemetryStr =
        '[Streak: $streak | ms: ${avgMs > 0 ? avgMs : "—"} | Acc: $hitRateAcc%]';

    // UI elements setup

    Widget bodyColumn = Column(
      children: [
        // ── GLOBAL HEADER BAR (UI Elástica Superior) ──────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              // Hamburguesa Sidebar Trigger
              Builder(
                builder: (ctx) => GestureDetector(
                  onTap: () => Scaffold.of(ctx).openDrawer(),
                  child: const Icon(Icons.menu, color: Colors.white, size: 20),
                ),
              ),
              const Spacer(),

              // Center Mode selector click overlay dropdown
              GestureDetector(
                onTap: () => _showModeSelectorOverlay(
                  context,
                  accent,
                  activeSession.activeMode,
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.05),
                    border: Border.all(color: accent.withValues(alpha: 0.3)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${activeSession.activeMode.name.toUpperCase()} ▼',
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
              const Spacer(),

              // ContextConfigTrigger config bottom sheet
              GestureDetector(
                onTap: () => _showContextSettings(
                  context,
                  activeSession.activeMode,
                  accent,
                ),
                child: Icon(Icons.more_vert, color: accent, size: 18),
              ),
            ],
          ),
        ),

        const Divider(color: Colors.white10, height: 1),

        // ── UNIVERSAL CANVAS & SESSION TIMELINE ────────────────────────
        Expanded(
          child: Center(
            child: SizedBox(
              width: double.infinity,
              child: LayoutBuilder(
                builder: (ctx, constraints) {
                  final localCanvasHeight = constraints.maxHeight;

                  if (nodes.isEmpty) {
                    return Center(
                      child: Text(
                        'WAITING FOR SESSION INPUT...',
                        style: TextStyle(
                          color: accent.withValues(alpha: 0.3),
                          fontSize: 11,
                          fontFamily: 'Courier',
                        ),
                      ),
                    );
                  }

                  return Stack(
                    children: [
                      Column(
                        children: [
                          // Telemetry Overlay
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              telemetryStr,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: accent.withValues(alpha: 0.3),
                                fontFamily: 'Courier',
                                fontSize: 10,
                              ),
                            ),
                          ),

                          // Feed scrolling list builder (History Feed)
                          Expanded(
                            child: ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.only(
                                top: 12,
                                bottom: 24,
                              ),
                              itemCount: frozenNodes.length,
                              itemBuilder: (ctx, i) {
                                final node = frozenNodes[i];
                                // Render appropriate node based on its type
                                if (node is MecaInputNode) {
                                  return MecaInputWidget(node: node);
                                } else if (node is KanjiProductionNode) {
                                  return KanjiProductionWidget(
                                    productionNode: node,
                                  );
                                } else if (node is ConceptRecallNode) {
                                  return KanjiProductionWidget(
                                    recallNode: node,
                                  );
                                } else if (node is KanjiQuizNode) {
                                  return KanjiQuizWidget(node: node);
                                } else if (node is LaneCollisionViewportNode) {
                                  return ArcadeViewportWidget(node: node);
                                } else if (node is StrokeValidationNode) {
                                  return StrokeValidationWidget(node: node);
                                } else if (node is ExerciseReportNode) {
                                  return ExerciseReportWidget(node: node);
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                          ),

                          // Active Workspace Area
                          if (activeNode != null) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 1,
                                    color: accent.withValues(alpha: 0.3),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'ACTIVE WORKSPACE',
                                    style: TextStyle(
                                      color: accent.withValues(alpha: 0.4),
                                      fontFamily: 'Courier',
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Divider(
                                      color: accent.withValues(alpha: 0.15),
                                      height: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _buildActiveNodeWidget(
                                activeNode,
                                localCanvasHeight,
                              ),
                            ),
                          ],
                        ],
                      ),

                      // Central pause overlay actions when paused (Oculto al inspeccionar historial)
                      if (timelineState.isPaused && !_showSnapToBottom)
                        Positioned.fill(
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                            child: Container(
                              color: Colors.black.withValues(alpha: 0.6),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // Glow effect behind text
                                    Container(
                                      decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                            color: CyberTheme.errorRed
                                                .withValues(alpha: 0.2),
                                            blurRadius: 40,
                                            spreadRadius: 10,
                                          ),
                                        ],
                                      ),
                                      child: const Text(
                                        'SYSTEM PAUSED',
                                        style: TextStyle(
                                          color: CyberTheme.errorRed,
                                          fontFamily: 'Courier',
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 8,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 60),
                                    SizedBox(
                                      width: 240,
                                      child: CyberButton(
                                        label: 'RESUME',
                                        onTap: () {
                                          ref
                                              .read(timelineProvider.notifier)
                                              .resumeGame();
                                        },
                                        accent: accent,
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    SizedBox(
                                      width: 240,
                                      child: CyberButton(
                                        label: 'SETTINGS',
                                        onTap: () {
                                          _showContextSettings(
                                            context,
                                            activeSession.activeMode,
                                            accent,
                                          );
                                        },
                                        accent: accent,
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    SizedBox(
                                      width: 240,
                                      child: CyberButton(
                                        label: 'DISCONNECT',
                                        onTap: () {
                                          SystemNavigator.pop();
                                        },
                                        accent: CyberTheme.errorRed,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                      // SnapToBottomButton (Visible durante inspección de historial, pausado o no)
                      if (_showSnapToBottom)
                        Positioned(
                          bottom: 16,
                          right: 16,
                          child: GestureDetector(
                            onTap: () {
                              _scrollToBottom();
                              ref.read(timelineProvider.notifier).resumeGame();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: accent,
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: const Text(
                                'SNAP TO LIVE V',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontFamily: 'Courier',
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),

        // ── DYNAMIC TERMINAL BAR (MUTANTE) ───────────────────────────
        if (!timelineState.isPaused) const DynamicTerminalBar(),
      ],
    );

    // Apply violent screen shake during neon error
    if (timelineState.isNeonErrorActive) {
      bodyColumn = bodyColumn.animate().shake(
        duration: 150.ms,
        hz: 15,
        offset: const Offset(10.0, 10.0),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (!timelineState.isPaused) {
          ref.read(timelineProvider.notifier).pauseGame();
        } else {
          ref.read(timelineProvider.notifier).resumeGame();
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.black, // Pure OLED black
        drawer: GeneralDrawer(accent: accent),
        body: SafeArea(child: bodyColumn),
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

class OledToggleSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color activeColor;

  const OledToggleSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.activeColor = const Color(0xFF00FF66),
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 40,
        height: 20,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: value
              ? activeColor.withValues(alpha: 0.2)
              : const Color(0xFF222222),
          border: Border.all(
            color: value ? activeColor : const Color(0xFF333333),
            width: 1.5,
          ),
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeInOut,
              left: value ? 22 : 2,
              top: 1.5,
              child: Container(
                width: 13,
                height: 13,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: value ? activeColor : const Color(0xFF666666),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CyberSegmentedControl<T> extends StatelessWidget {
  final T groupValue;
  final Map<T, String> children;
  final ValueChanged<T> onValueChanged;
  final Color accentColor;

  const CyberSegmentedControl({
    super.key,
    required this.groupValue,
    required this.children,
    required this.onValueChanged,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 210),
      height: 28,
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.white10),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(3),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: children.entries.map((entry) {
            final isSelected = entry.key == groupValue;
            final itemWidth = 208.0 / children.length;
            return SizedBox(
              width: itemWidth,
              height: double.infinity,
              child: GestureDetector(
                onTap: () => onValueChanged(entry.key),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  alignment: Alignment.center,
                  color: isSelected
                      ? accentColor.withValues(alpha: 0.15)
                      : Colors.transparent,
                  child: Text(
                    entry.value,
                    style: TextStyle(
                      color: isSelected ? accentColor : Colors.white60,
                      fontFamily: 'Courier',
                      fontSize: 8.5,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
