import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:kz_core/kz_core.dart';
import 'package:kanjizen_app/src/providers/game_provider.dart';
import 'package:kz_domain/kz_domain.dart';
import 'package:kanjizen_app/src/features/home/presentation/meca_context_settings.dart';

class MecaEngineScreen extends ConsumerStatefulWidget {
  const MecaEngineScreen({super.key});

  @override
  ConsumerState<MecaEngineScreen> createState() => _MecaEngineScreenState();
}

class _MecaEngineScreenState extends ConsumerState<MecaEngineScreen> {
  final TextEditingController input = TextEditingController();
  final FocusNode _inputFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(gameProvider.notifier).initialize(GameMode.hiragana);
    });
  }

  @override
  void dispose() {
    input.dispose();
    _inputFocusNode.dispose();
    super.dispose();
  }

  Color _accentColor(SettingsState s) => switch (s.accentColor) {
    CyberAccent.green => CyberTheme.defaultAccent,
    CyberAccent.red => CyberTheme.errorRed,
    CyberAccent.orange => Colors.orange,
    CyberAccent.blue => Colors.cyanAccent,
    CyberAccent.purple => Colors.purpleAccent,
    CyberAccent.white => Colors.white,
  };

  @override
  Widget build(BuildContext context) {
    ref.listen<String>(gameProvider.select((s) => s.inputText), (_, next) {
      if (next.isEmpty && input.text.isNotEmpty) {
        input.clear();
      }
    });

    final state = ref.watch(gameProvider);
    final notifier = ref.read(gameProvider.notifier);
    final settings = ref.watch(settingsProvider);
    final accent = _accentColor(settings);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (state.engineState == EngineState.paused) {
          notifier.resume();
        } else {
          notifier.pause();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Column(
            children: [
              // ── HEADER ────────────────────────────────────────────────
              _GameHeader(state: state, notifier: notifier, accent: accent),

              // ── LIENZO CENTRAL ────────────────────────────────────────
              Expanded(
                child: Stack(
                  children: [
                    LayoutBuilder(
                      builder: (ctx, constraints) {
                        final h = constraints.maxHeight;
                        final fontSize = (h * 0.52).clamp(56.0, 220.0);

                        if (state.isLoading) {
                          return Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 1.5,
                                color: accent,
                              ),
                            ),
                          );
                        }

                        if (state.currentSequence.isEmpty) {
                          return Center(
                            child: Text(
                              'SIN DATOS',
                              style: TextStyle(
                                color: accent.withValues(alpha: 0.4),
                                fontFamily: 'Courier',
                                fontSize: 12,
                                letterSpacing: 3,
                              ),
                            ),
                          );
                        }

                        return Center(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: state.currentSequence
                                  .asMap()
                                  .entries
                                  .map((e) {
                                    final isActive =
                                        e.key == state.currentSequenceIndex;
                                    final char = e.value.character;
                                    final opacity =
                                        (state.engineState !=
                                            EngineState.playing)
                                        ? 0.2
                                        : (isActive ? 1.0 : 0.25);

                                    Widget charWidget = FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        char,
                                        style: TextStyle(
                                          color: Colors.white.withValues(
                                            alpha: opacity,
                                          ),
                                          fontSize: fontSize,
                                          fontWeight: FontWeight.w200,
                                          height: 1.0,
                                        ),
                                      ),
                                    );

                                    if (isActive &&
                                        state.inputState == InputState.error &&
                                        state.engineState ==
                                            EngineState.playing) {
                                      charWidget = charWidget
                                          .animate(target: 1)
                                          .shakeX(
                                            duration: const Duration(
                                              milliseconds: 180,
                                            ),
                                          );
                                    }

                                    return Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal:
                                            state.currentSequence.length > 1
                                            ? 8.0
                                            : 0.0,
                                      ),
                                      child: charWidget,
                                    );
                                  })
                                  .toList(),
                            ),
                          ),
                        );
                      },
                    ),

                    // ── OVERLAY DE PAUSA / BIENVENIDA ────────────────────────
                    if (state.engineState != EngineState.playing)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.only(bottom: 24),
                          color: Colors.transparent,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _MenuAction(
                                label: state.engineState == EngineState.welcome
                                    ? '[ ENTRAR AL SISTEMA ]'
                                    : '[ REANUDAR ]',
                                accent: accent,
                                onTap: notifier.resume,
                              ),
                              const SizedBox(height: 12),
                              _MenuAction(
                                label: '[ AJUSTES CONTEXTUALES ]',
                                accent: accent,
                                onTap: () => MecaContextSettings.show(context),
                              ),
                              const SizedBox(height: 12),
                              _MenuAction(
                                label: '[ SALIR DEL MOTOR ]',
                                accent: accent,
                                onTap: () => SystemNavigator.pop(),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // ── CAMPO DE ENTRADA ──────────────────────────────────────
              if (state.engineState == EngineState.playing)
                _InputField(
                  controller: input,
                  focusNode: _inputFocusNode,
                  inputState: state.inputState,
                  accent: accent,
                  onChanged: (val) {
                    final res = notifier.onInputChanged(val);
                    if (res == InputState.error || res == InputState.success) {
                      input.clear();
                    }
                  },
                ),

              if (state.engineState == EngineState.playing)
                const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── HEADER COMPACTO ──────────────────────────────────────────────────────────
class _GameHeader extends StatelessWidget {
  const _GameHeader({
    required this.state,
    required this.notifier,
    required this.accent,
  });

  final GameState state;
  final GameNotifier notifier;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Hamburguesa
          Builder(
            builder: (ctx) => GestureDetector(
              onTap: () => MecaContextSettings.show(context),
              child: Icon(Icons.settings_outlined, color: accent, size: 22),
            ),
          ),
          const SizedBox(width: 12),

          // Métricas compactas — Expanded consume el espacio disponible
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _Metric('${state.streak}', Icons.local_fire_department, accent),
                const SizedBox(width: 10),
                _Metric(
                  state.avgMs > 0 ? '${state.avgMs}ms' : '—',
                  Icons.speed,
                  accent,
                ),
                const SizedBox(width: 10),
                _Metric(
                  '${(state.hitRate * 100).toStringAsFixed(0)}%',
                  Icons.track_changes,
                  accent,
                ),
              ],
            ),
          ),

          // Selector de modo — compacto
          _ModeChip(
            label: state.mode.label,
            accent: accent,
            onTap: () => _cycleMode(context, state, notifier),
          ),
        ],
      ),
    );
  }

  void _cycleMode(
    BuildContext context,
    GameState state,
    GameNotifier notifier,
  ) {
    final next = switch (state.mode) {
      GameMode.hiragana => GameMode.katakana,
      GameMode.katakana => GameMode.mixed,
      GameMode.mixed => GameMode.hiragana,
    };
    notifier.initialize(next);
  }
}

class _Metric extends StatelessWidget {
  const _Metric(this.value, this.icon, this.color);
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color.withValues(alpha: 0.6), size: 13),
        const SizedBox(width: 3),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontFamily: 'Courier',
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _ModeChip extends StatelessWidget {
  const _ModeChip({
    required this.label,
    required this.accent,
    required this.onTap,
  });
  final String label;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          border: Border.all(color: accent.withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(3),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: accent,
            fontFamily: 'Courier',
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }
}

// ─── CAMPO DE ENTRADA MINIMALISTA ─────────────────────────────────────────────
class _InputField extends StatelessWidget {
  const _InputField({
    required this.controller,
    required this.focusNode,
    required this.inputState,
    required this.accent,
    required this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final InputState inputState;
  final Color accent;
  final ValueChanged<String> onChanged;

  Color get _lineColor => switch (inputState) {
    InputState.neutral => Colors.white.withValues(alpha: 0.15),
    InputState.progress => accent.withValues(alpha: 0.6),
    InputState.error => CyberTheme.errorRed,
    InputState.success => accent,
  };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 4),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        onChanged: onChanged,
        autofocus: true,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.85),
          fontSize: 16,
          fontFamily: 'Courier',
          fontWeight: FontWeight.w300,
          letterSpacing: 3,
        ),
        cursorColor: accent,
        cursorHeight: 16,
        decoration: InputDecoration(
          hintText: 'romaji',
          hintStyle: TextStyle(
            color: Colors.white.withValues(alpha: 0.12),
            fontSize: 12,
            fontFamily: 'Courier',
            letterSpacing: 2,
          ),
          border: InputBorder.none,
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: _lineColor, width: 1),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: _lineColor, width: 1.5),
          ),
          isDense: true,
          contentPadding: const EdgeInsets.only(bottom: 6),
        ),
      ),
    );
  }
}

class _MenuAction extends StatelessWidget {
  const _MenuAction({
    required this.label,
    required this.accent,
    required this.onTap,
  });
  final String label;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.transparent, // expanded hit area
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text(
          label,
          style: TextStyle(
            color: accent,
            fontFamily: 'Courier',
            fontSize: 14,
            letterSpacing: 2,
            fontWeight: FontWeight.w300,
          ),
        ),
      ),
    );
  }
}
