import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kz_core/kz_core.dart';
import 'package:kz_domain/kz_domain.dart';
import 'package:kz_ui_components/kz_ui_components.dart';
import '../../../providers/game_provider.dart';
import '../../inventory/presentation/inventory_screen.dart';

/// HomeScreen — Modo Meca / Motor Universal.
/// Layout: Header ↕ KanaDisplay ↕ RayitaInput (footer fijo sobre teclado).
/// Envuelto en LayoutBuilder reactivo al viewInsets.bottom (Gboard).
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _controller = TextEditingController();
  final _focus = FocusNode();
  GameMode _mode = GameMode.hiragana;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(gameProvider.notifier).initialize(_mode);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _onInputChanged(String value) {
    ref.read(gameProvider.notifier).onInputChanged(value);
    final state = ref.read(gameProvider);
    if (state.inputState == InputState.success) {
      _controller.clear();
    }
  }

  void _switchMode(GameMode mode) {
    setState(() => _mode = mode);
    ref.read(gameProvider.notifier).initialize(mode);
    _controller.clear();
    _focus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(gameProvider);
    final settings = ref.watch(settingsProvider);
    final accent = CyberTheme.defaultAccent;

    return Scaffold(
      backgroundColor: CyberTheme.bgObsidian,
      // ─── Left Drawer — Perfil ──────────────────────────────────────────
      drawer: _ProfileDrawer(accent: accent, kanas: game.kanas),
      // ─── Right Drawer — Inventario ────────────────────────────────────
      endDrawer: _buildInventoryDrawer(game),
      body: LayoutBuilder(
        builder: (context, _) {
          final bottom = MediaQuery.of(context).viewInsets.bottom;
          return BgPattern(
            child: Column(
              children: [
                // ─── Safe area top ──────────────────────────────────────
                SizedBox(height: MediaQuery.of(context).padding.top),

                // ─── Header ─────────────────────────────────────────────
                Builder(
                  builder: (ctx) => GameHeader(
                    streak: game.streak,
                    avgMs: game.avgMs,
                    hitRate: game.hitRate,
                    errors: game.errors,
                    accentColor: accent,
                    onMenuTap: () => Scaffold.of(ctx).openDrawer(),
                    onInventoryTap: () => Scaffold.of(ctx).openEndDrawer(),
                    onSettingsTap: () {
                      SettingsModal.show(
                        context: context,
                        enableStrokeAnimation: settings.enableStrokeAnimation,
                        enableAudio: settings.enableAudio,
                        onToggleStrokeAnimation: () => ref.read(settingsProvider.notifier).toggleStrokeAnimation(),
                        onToggleAudio: () => ref.read(settingsProvider.notifier).toggleAudio(),
                      );
                    },
                  ),
                ),

                // ─── Área central de matriz ──────────────────────────────
                Expanded(
                  child: Center(
                    child: game.isLoading
                        ? CircularProgressIndicator(
                            color: accent,
                            strokeWidth: 1.5,
                          )
                        : game.currentKana == null
                        ? _emptyState(accent)
                        : _buildGameArea(game, accent),
                  ),
                ),

                // ─── Modo selector ────────────────────────────────────────
                _ModeSelector(
                  current: _mode,
                  onChanged: _switchMode,
                  accent: accent,
                ),

                // ─── Footer RayitaInput (reactivo al teclado) ────────────
                AnimatedPadding(
                  padding: EdgeInsets.only(
                    left: 32,
                    right: 32,
                    bottom: bottom > 0 ? bottom + 12 : 32,
                    top: 12,
                  ),
                  duration: const Duration(milliseconds: 150),
                  curve: Curves.easeOut,
                  child: game.currentKana != null
                      ? RayitaInput(
                          controller: _controller,
                          focusNode: _focus,
                          onChanged: _onInputChanged,
                          inputState: game.inputState,
                          hint:
                              game.currentKana?.romaji.split('').join('·') ??
                              '---',
                          accentColor: accent,
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildGameArea(GameState game, Color accent) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        KanaDisplay(
          character: game.currentKana!.character,
          tier: game.currentKana!.tier,
          accentColor: accent,
        ),
        const SizedBox(height: 16),
        // Hint de romaji oculto hasta 2 errores
        if (game.errors > 2 && game.currentKana != null)
          Text(
            game.currentKana!.romaji,
            style: TextStyle(
              color: accent.withOpacity(0.4),
              fontFamily: 'Courier',
              fontSize: 12,
              letterSpacing: 4,
            ),
          ),
      ],
    );
  }

  Widget _emptyState(Color accent) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.lock_outline, color: accent.withOpacity(0.3), size: 48),
        const SizedBox(height: 16),
        Text(
          'SIN KANAS DESBLOQUEADOS',
          style: TextStyle(
            color: accent.withOpacity(0.4),
            fontFamily: 'Courier',
            fontSize: 12,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildInventoryDrawer(GameState game) {
    return Drawer(
      backgroundColor: CyberTheme.bgObsidian,
      child: InventoryScreen(
        kanas: game.kanas,
        kanjis: game.kanjis,
      ),
    );
  }
}

/// Selector de modo de juego.
class _ModeSelector extends StatelessWidget {
  const _ModeSelector({
    required this.current,
    required this.onChanged,
    required this.accent,
  });
  final GameMode current;
  final ValueChanged<GameMode> onChanged;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: GameMode.values.map((m) {
          final selected = m == current;
          return GestureDetector(
            onTap: () => onChanged(m),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: selected ? accent.withOpacity(0.12) : Colors.transparent,
                border: Border.all(
                  color: selected ? accent : accent.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Text(
                m.label,
                style: TextStyle(
                  color: selected ? accent : accent.withOpacity(0.4),
                  fontFamily: 'Courier',
                  fontSize: 10,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                  letterSpacing: 1,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Drawer izquierdo — Perfil y estadísticas.
class _ProfileDrawer extends StatelessWidget {
  const _ProfileDrawer({required this.accent, required this.kanas});
  final Color accent;
  final List<KanaModel> kanas;

  List<double> get _dailyActivity {
    // Genera actividad de los últimos 365 días desde el historyBlob global
    final activity = List<double>.filled(365, 0.0);
    // Datos de sesión actual como proxy
    if (kanas.isNotEmpty) {
      for (var i = 0; i < kanas.length && i < 10; i++) {
        activity[364 - i] = kanas[i].currentHitRate;
      }
    }
    return activity;
  }

  @override
  Widget build(BuildContext context) {
    final unlocked = kanas.where((k) => k.isUnlocked).length;
    final total = kanas.length;
    final avgHitRate = kanas.isEmpty
        ? 0.0
        : kanas.fold(0.0, (s, k) => s + k.currentHitRate) / kanas.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: MediaQuery.of(context).padding.top + 16),

        // ─── Usuario ────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  border: Border.all(color: accent, width: 1),
                  shape: BoxShape.circle,
                  color: accent.withOpacity(0.1),
                ),
                child: Icon(Icons.person, color: accent, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'USUARIO',
                    style: TextStyle(
                      color: CyberTheme.textNeutral,
                      fontFamily: 'Courier',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                    ),
                  ),
                  Text(
                    'JLPT N5 — Principiante',
                    style: TextStyle(
                      color: accent.withOpacity(0.5),
                      fontFamily: 'Courier',
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // ─── Métricas globales ───────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatBox(
                label: 'Kanas',
                value: '$unlocked/$total',
                accent: accent,
              ),
              _StatBox(
                label: 'Precisión',
                value: '${(avgHitRate * 100).toStringAsFixed(0)}%',
                accent: accent,
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),
        Divider(color: accent.withOpacity(0.15), height: 1),
        const SizedBox(height: 16),

        // ─── Activity Graph ──────────────────────────────────────────────
        ActivityGraph(dailyActivity: _dailyActivity, accentColor: accent),

        const SizedBox(height: 16),
        Divider(color: accent.withOpacity(0.15), height: 1),
        const SizedBox(height: 16),

        // ─── Top 5 dominantes ────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'TOP 5 DOMINANTES',
            style: TextStyle(
              color: accent,
              fontFamily: 'Courier',
              fontSize: 10,
              letterSpacing: 2,
            ),
          ),
        ),
        const SizedBox(height: 8),
        ..._topKanas(true).map((k) => _KanaStatRow(kana: k, accent: accent)),

        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            '5 CRÍTICOS',
            style: TextStyle(
              color: CyberTheme.errorRed,
              fontFamily: 'Courier',
              fontSize: 10,
              letterSpacing: 2,
            ),
          ),
        ),
        const SizedBox(height: 8),
        ..._topKanas(
          false,
        ).map((k) => _KanaStatRow(kana: k, accent: CyberTheme.errorRed)),
      ],
    );
  }

  List<KanaModel> _topKanas(bool dominant) {
    final sorted = [...kanas.where((k) => k.historyBlob.isNotEmpty)]
      ..sort(
        (a, b) => dominant
            ? b.currentHitRate.compareTo(a.currentHitRate)
            : a.currentHitRate.compareTo(b.currentHitRate),
      );
    return sorted.take(5).toList();
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({
    required this.label,
    required this.value,
    required this.accent,
  });
  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: accent.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: accent,
              fontFamily: 'Courier',
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: CyberTheme.textNeutral.withOpacity(0.4),
              fontFamily: 'Courier',
              fontSize: 9,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _KanaStatRow extends StatelessWidget {
  const _KanaStatRow({required this.kana, required this.accent});
  final KanaModel kana;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Text(
              kana.character,
              style: const TextStyle(
                color: CyberTheme.textNeutral,
                fontSize: 18,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            kana.romaji,
            style: TextStyle(
              color: accent.withOpacity(0.6),
              fontFamily: 'Courier',
              fontSize: 11,
            ),
          ),
          const Spacer(),
          Text(
            '${(kana.currentHitRate * 100).toStringAsFixed(0)}%',
            style: TextStyle(
              color: accent,
              fontFamily: 'Courier',
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${kana.averageMs}ms',
            style: TextStyle(
              color: CyberTheme.textNeutral.withOpacity(0.4),
              fontFamily: 'Courier',
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
