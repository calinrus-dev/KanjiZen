import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kz_core/kz_core.dart';
import 'package:kz_data/kz_data.dart';
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

  bool _isCorrectReading(String input, KanjiModel kanji) {
    final cleanInput = input.trim().toLowerCase();
    if (cleanInput.isEmpty) return false;

    String toRomaji(String kanaStr) {
      final sb = StringBuffer();
      for (var i = 0; i < kanaStr.length; i++) {
        final char = kanaStr[i];
        if (char == '.' || char == '-' || char == ' ') continue;
        final seed = KanaSeedData.all
            .where((s) => s.character == char)
            .firstOrNull;
        if (seed != null) {
          sb.write(seed.romaji);
        } else {
          sb.write(char);
        }
      }
      return sb.toString().toLowerCase();
    }

    for (final onyomi in kanji.onyomi) {
      final cleanOnyomi = onyomi
          .replaceAll('.', '')
          .replaceAll('-', '')
          .trim()
          .toLowerCase();
      if (cleanOnyomi == cleanInput) return true;
      if (toRomaji(onyomi) == cleanInput) return true;
    }

    for (final kunyomi in kanji.kunyomi) {
      final cleanKunyomi = kunyomi
          .replaceAll('.', '')
          .replaceAll('-', '')
          .trim()
          .toLowerCase();
      if (cleanKunyomi == cleanInput) return true;
      if (toRomaji(kunyomi) == cleanInput) return true;
    }

    for (final meaning in kanji.meanings) {
      if (meaning.toLowerCase().trim() == cleanInput) return true;
    }

    return false;
  }

  bool _isReadingPrefix(String cleanInput, KanjiModel kanji) {
    if (cleanInput.isEmpty) return false;

    String toRomaji(String kanaStr) {
      final sb = StringBuffer();
      for (var i = 0; i < kanaStr.length; i++) {
        final char = kanaStr[i];
        if (char == '.' || char == '-' || char == ' ') continue;
        final seed = KanaSeedData.all
            .where((s) => s.character == char)
            .firstOrNull;
        if (seed != null) {
          sb.write(seed.romaji);
        } else {
          sb.write(char);
        }
      }
      return sb.toString().toLowerCase();
    }

    for (final onyomi in kanji.onyomi) {
      final cleanOnyomi = onyomi
          .replaceAll('.', '')
          .replaceAll('-', '')
          .trim()
          .toLowerCase();
      if (cleanOnyomi.startsWith(cleanInput)) return true;
      if (toRomaji(onyomi).startsWith(cleanInput)) return true;
    }

    for (final kunyomi in kanji.kunyomi) {
      final cleanKunyomi = kunyomi
          .replaceAll('.', '')
          .replaceAll('-', '')
          .trim()
          .toLowerCase();
      if (cleanKunyomi.startsWith(cleanInput)) return true;
      if (toRomaji(kunyomi).startsWith(cleanInput)) return true;
    }

    for (final meaning in kanji.meanings) {
      if (meaning.toLowerCase().trim().startsWith(cleanInput)) return true;
    }

    return false;
  }

  void _onInputChanged(String input, KanjiModel kanji, KanjiSrsPhase phase) {
    final cleanInput = input.trim().toLowerCase();
    if (cleanInput.isEmpty) {
      setState(() => _inputState = InputState.neutral);
      return;
    }

    bool isSuccess = false;
    bool isPrefix = false;

    if (phase == KanjiSrsPhase.inversion) {
      final target = kanji.character;
      isSuccess = (cleanInput == target);
      isPrefix = target.startsWith(cleanInput);
    } else {
      isSuccess = _isCorrectReading(cleanInput, kanji);
      isPrefix = _isReadingPrefix(cleanInput, kanji);
    }

    if (isSuccess) {
      setState(() => _inputState = InputState.success);
      _controller.clear();
      ref.read(kanjiSrsProvider.notifier).recordSuccess(kanji);
      setState(() => _inputState = InputState.neutral);
    } else if (!isPrefix) {
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
      resizeToAvoidBottomInset: true,
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
          ? const Center(
              child: CircularProgressIndicator(color: CyberTheme.defaultAccent),
            )
          : state.activePool.isEmpty
          ? const Center(
              child: Text(
                'No hay Kanjis en el pool.',
                style: TextStyle(color: CyberTheme.textNeutral),
              ),
            )
          : _buildGameArea(state.activePool.first),
    );
  }

  Widget _buildGameArea(KanjiModel kanji) {
    final phase = ref
        .read(kanjiSrsProvider.notifier)
        .getPhaseFor(kanji.srsScore);

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 16),
                    Text(
                      'Fase: ${phase.name.toUpperCase()} (Score: ${kanji.srsScore.toStringAsFixed(1)})',
                      style: const TextStyle(
                        color: CyberTheme.textNeutral,
                        fontSize: 10,
                        fontFamily: 'Courier',
                      ),
                    ),
                    const SizedBox(height: 24),
                    Flexible(
                      child: _buildPrompt(kanji, phase, constraints),
                    ),
                    const SizedBox(height: 16),
                    if (phase == KanjiSrsPhase.initial)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          kanji.meanings.join(', '),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: CyberTheme.textNeutral.withValues(alpha: 0.5),
                            fontSize: (constraints.maxWidth * 0.035).clamp(12.0, 16.0),
                            fontFamily: 'Courier',
                          ),
                        ),
                      ),
                    const SizedBox(height: 24),
                    if (phase != KanjiSrsPhase.discriminatory)
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: RayitaInput(
                          controller: _controller,
                          focusNode: _focusNode,
                          inputState: _inputState,
                          hint: phase == KanjiSrsPhase.inversion
                              ? 'Dibuja el Kanji...'
                              : 'Escribe lectura...',
                          onChanged: (val) => _onInputChanged(val, kanji, phase),
                        ),
                      )
                    else
                      _buildMultipleChoicePanel(kanji, constraints),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPrompt(
    KanjiModel kanji,
    KanjiSrsPhase phase,
    BoxConstraints constraints,
  ) {
    if (phase == KanjiSrsPhase.initial || phase == KanjiSrsPhase.withdrawal) {
      final fontSize = (constraints.maxWidth * 0.25).clamp(48.0, 120.0);
      return FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          kanji.character,
          style: TextStyle(
            color: CyberTheme.defaultAccent,
            fontSize: fontSize,
            fontWeight: FontWeight.w300,
          ),
        ),
      );
    }

    // inversion / discriminatory
    final fontSize = (constraints.maxWidth * 0.08).clamp(18.0, 36.0);
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        kanji.meanings.isNotEmpty
            ? kanji.meanings.first.toUpperCase()
            : '???',
        style: TextStyle(
          color: CyberTheme.defaultAccent,
          fontSize: fontSize,
          fontFamily: 'Courier',
          letterSpacing: 4,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildMultipleChoicePanel(KanjiModel kanji, BoxConstraints constraints) {
    final options = ref
        .read(kanjiSrsProvider.notifier)
        .generateDiscriminatoryOptions(kanji);

    final cardSize = (constraints.maxWidth / 4).clamp(56.0, 96.0);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
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
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: cardSize,
              height: cardSize,
              decoration: BoxDecoration(
                border: Border.all(
                  color: CyberTheme.defaultAccent.withValues(alpha: 0.3),
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  opt,
                  style: const TextStyle(
                    color: CyberTheme.textNeutral,
                    fontSize: 32,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
