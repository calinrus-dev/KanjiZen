import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kz_core/kz_core.dart';
import 'package:kz_domain/kz_domain.dart';
import 'package:kz_ui_components/kz_ui_components.dart';
import 'package:kanjizen_app/src/providers/timeline_provider.dart';
import 'virtual_flick_keyboard.dart';
import 'chat_console_input.dart';

/// Stub para nodo de chat hasta que el backend LLM esté integrado.
/// Permite que el [DynamicTerminalBar] mute al Estado B (Chat UI).
class ChatNode extends FeedNode {
  ChatNode({required super.id, required super.timestamp, super.isFrozen});

  @override
  ChatNode freeze() => ChatNode(id: id, timestamp: timestamp, isFrozen: true);
}

class DynamicTerminalBar extends ConsumerStatefulWidget {
  const DynamicTerminalBar({super.key});

  @override
  ConsumerState<DynamicTerminalBar> createState() => _DynamicTerminalBarState();
}

class _DynamicTerminalBarState extends ConsumerState<DynamicTerminalBar> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  bool _useFlick = false;
  String _flickText = '';
  bool _quizLocked = false;
  String? _lastNodeId;

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

    // Reset local states when the active node changes
    if (lastNode.id != _lastNodeId) {
      _lastNodeId = lastNode.id;
      _quizLocked = false;
      _flickText = '';
      _useFlick = false;
    }

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
        if (next.isEmpty) {
          if (_textController.text.isNotEmpty) {
            _textController.clear();
            _focusNode.requestFocus();
          }
          if (_flickText.isNotEmpty) {
            setState(() => _flickText = '');
          }
        }
      },
    );

    Widget barContent;

    if (lastNode is MecaInputNode ||
        lastNode is KanjiProductionNode ||
        lastNode is ConceptRecallNode) {
      // ─── Estado A: Terminal / Native Input + Flick Toggle ───
      if (!_focusNode.hasFocus && !timelineState.isPaused && !_useFlick) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted &&
              !_focusNode.hasFocus &&
              !ref.read(timelineProvider).isPaused) {
            _focusNode.requestFocus();
          }
        });
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (_useFlick) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _flickText.isEmpty ? '…' : _flickText,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontFamily: 'Courier',
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.keyboard,
                          color: Colors.white54,
                          size: 20,
                        ),
                        tooltip: 'Native input',
                        onPressed: () => setState(() => _useFlick = false),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: constraints.maxHeight.isFinite
                        ? constraints.maxHeight * 0.75
                        : 200,
                    child: VirtualFlickKeyboard(
                      onCharacterSelected: (char) {
                        setState(() => _flickText += char);
                        ref
                            .read(timelineProvider.notifier)
                            .onTerminalInputChanged(_flickText);
                      },
                      onToggleKana: () {
                        // Stub: toggle kana mode (UI ready, backend pending)
                      },
                      accentColor: accent,
                    ),
                  ),
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: RayitaInput(
                    controller: _textController,
                    focusNode: _focusNode,
                    inputState: currentState,
                    hint: hint,
                    accentColor: accent,
                    readOnly: timelineState.isNeonErrorActive,
                    onChanged: (val) {
                      ref
                          .read(timelineProvider.notifier)
                          .onTerminalInputChanged(val);
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.touch_app,
                    color: Colors.white54,
                    size: 20,
                  ),
                  tooltip: 'Flick input',
                  onPressed: () => setState(() => _useFlick = true),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
              ],
            );
          },
        ),
      );
    } else if (lastNode is ChatNode) {
      // ─── Estado B: Chat Console ───
      _focusNode.unfocus();

      barContent = Container(
        key: const ValueKey('chat_mode'),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: const BoxDecoration(
          color: Colors.black,
          border: Border(top: BorderSide(color: Colors.white10, width: 0.5)),
        ),
        child: ChatConsoleInput(
          accentColor: accent,
          onSend: (text) {
            // Stub: conectar a timelineProvider cuando ChatMessageNode esté listo
            debugPrint('Chat send: $text');
          },
          onTtsRequested: () {
            debugPrint('TTS requested');
          },
          onAttachmentRequested: () {
            debugPrint('Attachment requested');
          },
        ),
      );
    } else if (lastNode is KanjiQuizNode) {
      // ─── Estado C: Quiz Grid ───
      _focusNode.unfocus();

      barContent = Container(
        key: const ValueKey('quiz_grid_mode'),
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.black,
          border: Border(top: BorderSide(color: Colors.white10, width: 0.5)),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final crossCount =
                (constraints.maxWidth / 140).clamp(2, 4).toInt();
            final aspect = (constraints.maxWidth / crossCount) / 60;

            return AbsorbPointer(
              absorbing: _quizLocked,
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossCount,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: aspect.clamp(1.0, 4.0),
                ),
                itemCount: lastNode.options.length,
                itemBuilder: (context, i) {
                  final opt = lastNode.options[i];
                  return InkWell(
                    onTap: () {
                      setState(() => _quizLocked = true);
                      ref
                          .read(timelineProvider.notifier)
                          .onQuizOptionSelected(opt);
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
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
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
                    ),
                  );
                },
              ),
            );
          },
        ),
      );
    } else if (lastNode is LaneCollisionViewportNode) {
      // ─── Estado D: Arcade Deck ───
      _focusNode.unfocus();

      barContent = Container(
        key: const ValueKey('arcade_deck_mode'),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: const BoxDecoration(
          color: Colors.black,
          border: Border(top: BorderSide(color: Colors.white10, width: 0.5)),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final deck = lastNode.deck;
            final availableWidth = constraints.maxWidth - 32;
            final cardSize = (availableWidth / deck.length) * 0.9;

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: deck.map((k) {
                return Draggable<String>(
                  data: k.character,
                  feedback: Material(
                    color: Colors.transparent,
                    child: Container(
                      width: cardSize,
                      height: cardSize,
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
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
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
                  ),
                  childWhenDragging: Container(
                    width: cardSize,
                    height: cardSize,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white10, width: 1.0),
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.01),
                    ),
                  ),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: cardSize,
                    height: cardSize,
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
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
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
                  ),
                );
              }).toList(),
            );
          },
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
