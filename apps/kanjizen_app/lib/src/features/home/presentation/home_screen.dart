import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:kz_core/kz_core.dart';
import 'package:kz_ui_components/kz_ui_components.dart';
import 'package:kanjizen_app/src/providers/game_provider.dart';
import 'package:kz_domain/kz_domain.dart';
import 'package:kanjizen_app/src/features/inventory/presentation/inventory_screen.dart';
import 'package:kanjizen_app/src/features/profile/presentation/profile_drawer.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(gameProvider.notifier).initialize(GameMode.hiragana);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Color _getAccentColor(SettingsState settings) {
    switch (settings.accentColor) {
      case CyberAccent.green: return CyberTheme.defaultAccent;
      case CyberAccent.red: return CyberTheme.errorRed;
      case CyberAccent.orange: return Colors.orange;
      case CyberAccent.blue: return Colors.cyanAccent;
      case CyberAccent.purple: return Colors.purpleAccent;
      case CyberAccent.white: return Colors.white;
    }
  }

  void _showSettingsModal() {
    final state = ref.read(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    SettingsModal.show(
      context: context,
      state: state,
      onSetAccentColor: notifier.setAccentColor,
      onSetFontSize: notifier.setFontSize,
      onSetEngineLanguage: notifier.setEngineLanguage,
      onSetTrainingMode: notifier.setTrainingMode,
      onToggleRomajiHints: notifier.toggleRomajiHints,
      onSetProgressiveSystem: notifier.setProgressiveSystem,
      onToggleFreeModeKey: notifier.toggleFreeModeKey,
      onSetDeathClock: notifier.setDeathClock,
      onToggleSkipOnError: notifier.toggleSkipOnError,
      onToggleHardcoreMode: notifier.toggleHardcoreMode,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(gameProvider);
    final notifier = ref.read(gameProvider.notifier);
    final settings = ref.watch(settingsProvider);
    final accentColor = _getAccentColor(settings);

    // Si hay error en la entrada, animamos TODA la pantalla según las reglas "temblor horizontal seco"
    Widget scaffoldBody = Scaffold(
      backgroundColor: CyberTheme.bgObsidian,
      drawer: const Drawer(
        backgroundColor: CyberTheme.bgObsidian,
        child: ProfileDrawer(),
      ),
      endDrawer: const Drawer(
        backgroundColor: CyberTheme.bgObsidian,
        child: InventoryScreen(),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header Estricto
            Builder(
              builder: (ctx) => GameHeader(
                streak: state.streak,
                avgMs: state.avgMs,
                hitRate: state.hitRate,
                errors: state.errors,
                accentColor: accentColor,
                onMenuTap: () => Scaffold.of(ctx).openDrawer(),
                onInventoryTap: () => Scaffold.of(ctx).openEndDrawer(),
                onSettingsTap: _showSettingsModal,
                onPauseTap: () {
                  // TODO: Pausar el juego
                },
              ),
            ),
            
            // Área Central Elástica (LayoutBuilder reacciona al viewInsets.bottom)
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final availableHeight = constraints.maxHeight;
                  // '.clamp()' matemático para encoger, ahora con más espacio libre
                  final boxSize = (availableHeight * 0.6).clamp(100.0, 300.0);
                  final fontSize = (boxSize * 0.5).clamp(50.0, 150.0);

                  return Center(
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 16,
                      runSpacing: 16,
                      children: state.currentSequence.asMap().entries.map((e) {
                        final i = e.key;
                        final k = e.value;
                        final isActive = i == state.currentSequenceIndex;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: boxSize,
                          height: boxSize,
                          decoration: BoxDecoration(
                            color: isActive ? accentColor.withValues(alpha: 0.1) : Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isActive ? accentColor : CyberTheme.textNeutral.withValues(alpha: 0.3),
                              width: isActive ? 2 : 1,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            k.character,
                            style: TextStyle(
                              color: isActive ? accentColor : CyberTheme.textNeutral,
                              fontSize: fontSize,
                              fontWeight: isActive ? FontWeight.w300 : FontWeight.w100,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
            ),



            // Footer Limpio (RayitaInput original ya cumple con esto pero lo reforzamos)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
              child: RayitaInput(
                controller: _controller,
                focusNode: _focusNode,
                inputState: state.inputState,
                hint: '', // Limpio
                onChanged: notifier.onInputChanged,
              ),
            ),
          ],
        ),
      ),
    );

    if (state.inputState == InputState.error) {
      scaffoldBody = scaffoldBody
          .animate(key: const ValueKey('error_shake'))
          .shakeX(hz: 8, amount: 6, duration: 150.ms)
          .tint(color: CyberTheme.errorRed, duration: 150.ms);
    }

    return scaffoldBody;
  }
}

class _ModeSelector extends StatelessWidget {
  const _ModeSelector({
    required this.label,
    required this.mode,
    required this.currentMode,
    required this.color,
    required this.onTap,
  });

  final String label;
  final GameMode mode;
  final GameMode currentMode;
  final Color color;
  final void Function(GameMode) onTap;

  @override
  Widget build(BuildContext context) {
    final isActive = mode == currentMode;
    return GestureDetector(
      onTap: () => onTap(mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? color.withValues(alpha: 0.2) : Colors.transparent,
          border: Border.all(color: isActive ? color : CyberTheme.textNeutral.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(4), // Botones planos rectangulares (con leve border radius)
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? color : CyberTheme.textNeutral,
            fontFamily: 'Courier',
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
