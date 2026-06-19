import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kz_core/kz_core.dart';
import 'package:kz_domain/kz_domain.dart';
import 'package:kz_ui_components/kz_ui_components.dart';
import 'package:kanjizen_app/src/providers/kanji_srs_provider.dart';

class KanjiSrsScreen extends ConsumerStatefulWidget {
  const KanjiSrsScreen({super.key});

  @override
  ConsumerState<KanjiSrsScreen> createState() => _KanjiSrsScreenState();
}

class _KanjiSrsScreenState extends ConsumerState<KanjiSrsScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  InputState _inputState = InputState.neutral;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onInputChanged(String input, KanjiModel kanji, KanjiSrsPhase phase) {
    // Evaluación mock
    String target = '';
    if (phase == KanjiSrsPhase.initial || phase == KanjiSrsPhase.withdrawal) {
      target = kanji.meanings.isNotEmpty ? kanji.meanings.first.toLowerCase() : '';
      // En una implementación real se evaluaría el Romaji/Kunyomi
    } else if (phase == KanjiSrsPhase.inversion) {
      target = kanji.character;
    }

    if (input.trim() == target) {
      setState(() => _inputState = InputState.success);
      _controller.clear();
      ref.read(kanjiSrsProvider.notifier).recordSuccess(kanji);
      setState(() => _inputState = InputState.neutral);
    } else if (!target.startsWith(input.trim())) {
      setState(() => _inputState = InputState.error);
      _controller.clear();
      ref.read(kanjiSrsProvider.notifier).recordError(kanji);
      Future.delayed(const Duration(milliseconds: 150), () {
        if (mounted) setState(() => _inputState = InputState.neutral);
      });
    } else {
      setState(() => _inputState = InputState.progress);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(kanjiSrsProvider);

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
          'MODO KANJI (SRS)',
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
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator(color: CyberTheme.defaultAccent))
          : state.activePool.isEmpty
              ? const Center(child: Text('No hay Kanjis en el pool.', style: TextStyle(color: CyberTheme.textNeutral)))
              : _buildGameArea(state.activePool.first),
    );
  }

  Widget _buildGameArea(KanjiModel kanji) {
    final phase = ref.read(kanjiSrsProvider.notifier).getPhaseFor(kanji.srsScore);
    
    // Tiembla y parpadea en rojo si hay error
    return LayoutBuilder(
      builder: (context, constraints) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Fase: ${phase.name.toUpperCase()} (Score: ${kanji.srsScore.toStringAsFixed(1)})',
                style: const TextStyle(color: CyberTheme.textNeutral, fontSize: 10, fontFamily: 'Courier'),
              ),
              const SizedBox(height: 32),
              
              if (phase == KanjiSrsPhase.initial || phase == KanjiSrsPhase.withdrawal)
                Text(
                  kanji.character,
                  style: const TextStyle(color: CyberTheme.defaultAccent, fontSize: 80, fontWeight: FontWeight.w300),
                )
              else if (phase == KanjiSrsPhase.inversion || phase == KanjiSrsPhase.discriminatory)
                Text(
                  kanji.meanings.isNotEmpty ? kanji.meanings.first.toUpperCase() : '???',
                  style: const TextStyle(color: CyberTheme.defaultAccent, fontSize: 32, fontFamily: 'Courier', letterSpacing: 4),
                  textAlign: TextAlign.center,
                ),

              const SizedBox(height: 16),
              
              if (phase == KanjiSrsPhase.initial)
                Text(
                  kanji.meanings.join(', '),
                  style: TextStyle(color: CyberTheme.textNeutral.withValues(alpha: 0.5), fontSize: 14, fontFamily: 'Courier'),
                ),

              const Spacer(),

              if (phase != KanjiSrsPhase.discriminatory)
                Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: RayitaInput(
                    controller: _controller,
                    focusNode: _focusNode,
                    inputState: _inputState,
                    hint: phase == KanjiSrsPhase.inversion ? 'Dibuja el Kanji...' : 'Escribe lectura...',
                    onChanged: (val) => _onInputChanged(val, kanji, phase),
                  ),
                )
              else
                _buildMultipleChoicePanel(kanji),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMultipleChoicePanel(KanjiModel kanji) {
    // TODO: Generar pool real con gemelos radicales.
    final options = [kanji.character, '日', '目', '白'];
    options.shuffle();

    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Wrap(
        spacing: 16,
        runSpacing: 16,
        alignment: WrapAlignment.center,
        children: options.map((opt) {
          return InkWell(
            onTap: () {
              if (opt == kanji.character) {
                ref.read(kanjiSrsProvider.notifier).recordSuccess(kanji);
              } else {
                ref.read(kanjiSrsProvider.notifier).recordError(kanji);
              }
            },
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                border: Border.all(color: CyberTheme.defaultAccent.withValues(alpha: 0.3)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  opt,
                  style: const TextStyle(color: CyberTheme.textNeutral, fontSize: 32),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
