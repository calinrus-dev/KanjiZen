import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kz_core/kz_core.dart';
import 'package:kz_domain/kz_domain.dart';
import 'package:kz_ui_components/kz_ui_components.dart';
import 'package:kanjizen_app/src/providers/timeline_provider.dart';

class DynamicTerminalBar extends ConsumerStatefulWidget {
  const DynamicTerminalBar({super.key});

  @override
  ConsumerState<DynamicTerminalBar> createState() => _DynamicTerminalBarState();
}

class _DynamicTerminalBarState extends ConsumerState<DynamicTerminalBar> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timelineState = ref.watch(timelineProvider);
    final activeSession = timelineState.activeSession;
    final activeNodes = activeSession.nodes;
    final lastNode = activeNodes.isNotEmpty ? activeNodes.last : null;
    final accent = _getAccentColor(ref.watch(settingsProvider).accentColor);

    if (lastNode == null) return const SizedBox.shrink();

    // Listen to clear event from provider
    ref.listen<String>(
      timelineProvider.select((s) {
        final node = s.activeNodes.isNotEmpty ? s.activeNodes.last : null;
        if (node is MecaInputNode) return node.inputText;
        if (node is KanjiProductionNode) return node.inputText;
        if (node is ConceptRecallNode) return node.inputText;
        return '';
      }),
      (_, next) {
        if (next.isEmpty && _textController.text.isNotEmpty) {
          _textController.clear();
        }
      },
    );

    Widget barContent;

    if (lastNode is MecaInputNode ||
        lastNode is KanjiProductionNode ||
        lastNode is ConceptRecallNode) {
      // TerminalMode - keyboard typing
      if (!_focusNode.hasFocus && !timelineState.isPaused) {
        _focusNode.requestFocus();
      }

      String hint = 'Escribe en romaji...';
      if (lastNode is ConceptRecallNode) {
        hint = 'Evoca y escribe el carácter...';
      }

      InputState currentState = InputState.neutral;
      if (lastNode is MecaInputNode) currentState = lastNode.inputState;
      if (lastNode is KanjiProductionNode) currentState = lastNode.inputState;
      if (lastNode is ConceptRecallNode) currentState = lastNode.inputState;

      barContent = Container(
        key: const ValueKey('terminal_mode'),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 1.0),
        decoration: const BoxDecoration(
          color: Colors.black,
          border: Border(top: BorderSide(color: Colors.white10, width: 0.5)),
        ),
        child: RayitaInput(
          controller: _textController,
          focusNode: _focusNode,
          inputState: currentState,
          hint: hint,
          accentColor: accent,
          readOnly: timelineState.isNeonErrorActive,
          onChanged: (val) {
            ref.read(timelineProvider.notifier).onTerminalInputChanged(val);
          },
        ),
      );
    } else if (lastNode is KanjiQuizNode) {
      // GridMode - Quiz buttons (unfocus keyboard)
      _focusNode.unfocus();

      final settings = ref.watch(settingsProvider);
      final is2x2 = settings.quizDensity == QuizDensity.matrix2x2;
      final crossCount = is2x2 ? 2 : 3;
      final aspect = is2x2 ? 2.0 : 1.5;

      barContent = Container(
        key: const ValueKey('quiz_grid_mode'),
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.black,
          border: Border(top: BorderSide(color: Colors.white10, width: 0.5)),
        ),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: aspect,
          ),
          itemCount: lastNode.options.length,
          itemBuilder: (context, i) {
            final opt = lastNode.options[i];
            return InkWell(
              onTap: () {
                ref.read(timelineProvider.notifier).onQuizOptionSelected(opt);
              },
              borderRadius: BorderRadius.circular(6),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: accent.withValues(alpha: 0.4),
                    width: 1.2,
                  ),
                  borderRadius: BorderRadius.circular(6),
                  color: accent.withValues(alpha: 0.04),
                  boxShadow: [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.08),
                      blurRadius: 6,
                      spreadRadius: 0.5,
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  opt,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontFamily: 'Courier',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            );
          },
        ),
      );
    } else if (lastNode is LaneCollisionViewportNode) {
      // KanjiDeckHand - Arcade mode deck
      _focusNode.unfocus();

      barContent = Container(
        key: const ValueKey('arcade_deck_mode'),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: const BoxDecoration(
          color: Colors.black,
          border: Border(top: BorderSide(color: Colors.white10, width: 0.5)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: lastNode.deck.map((k) {
            return Draggable<String>(
              data: k.character,
              feedback: Material(
                color: Colors.transparent,
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.25),
                    border: Border.all(color: accent, width: 2.0),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: accent.withValues(alpha: 0.3),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    k.character,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontFamily: 'Courier',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              childWhenDragging: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white10, width: 1.0),
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.01),
                ),
              ),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      accent.withValues(alpha: 0.15),
                      Colors.transparent,
                    ],
                  ),
                  border: Border.all(
                    color: accent.withValues(alpha: 0.6),
                    width: 1.5,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.15),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  k.character,
                  style: TextStyle(
                    color: accent,
                    fontSize: 22,
                    fontFamily: 'Courier',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      );
    } else {
      // Stroke drawing or static nodes - hide keyboard
      _focusNode.unfocus();
      barContent = const SizedBox.shrink(key: ValueKey('none'));
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: barContent,
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
