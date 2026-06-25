import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kz_core/kz_core.dart';
import 'package:kz_domain/kz_domain.dart';
import 'package:kz_ui_components/kz_ui_components.dart';
import 'package:kanjizen_app/src/providers/timeline_provider.dart';
import 'package:kanjizen_app/src/features/home/presentation/widgets/chat_console_input.dart';
import 'package:kanjizen_app/src/features/home/presentation/widgets/virtual_flick_keyboard.dart';

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
  void didUpdateWidget(covariant DynamicTerminalBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    _applyFocusPolicy();
  }

  /// Aplica política de foco fuera de [build]. Se invoca en didUpdateWidget y
  /// después de cambios de estado controlados por el provider.
  void _applyFocusPolicy() {
    final timelineState = ref.read(timelineProvider);
    final lastNode = _lastActiveNode(timelineState);

    if (lastNode is MecaInputNode ||
        lastNode is KanjiProductionNode ||
        lastNode is ConceptRecallNode) {
      if (!timelineState.isPaused &&
          !timelineState.isNeonErrorActive &&
          !_useFlick &&
          !_focusNode.hasFocus) {
        _focusNode.requestFocus();
      }
    } else {
      if (_focusNode.hasFocus) {
        _focusNode.unfocus();
      }
    }
  }

  FeedNode? _lastActiveNode(SessionTimelineState timelineState) {
    final activeNodes = timelineState.activeSession.nodes;
    return activeNodes.isNotEmpty ? activeNodes.last : null;
  }

  void _clearLocalInputBuffers() {
    if (_textController.text.isNotEmpty) {
      _textController.clear();
    }
    if (_flickText.isNotEmpty) {
      setState(() => _flickText = '');
    }
  }

  @override
  Widget build(BuildContext context) {
    final timelineState = ref.watch(timelineProvider);
    final lastNode = _lastActiveNode(timelineState);
    final accent = _getAccentColor(ref.watch(settingsProvider).accentColor);

    if (lastNode == null) return const SizedBox.shrink();

    // Detectar cambio de nodo activo y purgar estado local.
    if (lastNode.id != _lastNodeId) {
      _lastNodeId = lastNode.id;
      _quizLocked = false;
      _useFlick = false;
      // La limpieza síncrona se ejecuta en el próximo frame para no mutar
      // controllers durante el build.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _clearLocalInputBuffers();
        _applyFocusPolicy();
      });
    }

    // Escuchar estado del provider para limpiar el buffer local al instante.
    ref.listen<SessionTimelineState>(
      timelineProvider,
      (previous, next) {
        final prevNode = previous != null ? _lastActiveNode(previous) : null;
        final nextNode = _lastActiveNode(next);
        if (prevNode == null || nextNode == null) return;
        if (prevNode.id != nextNode.id) return;

        InputState prevState = InputState.neutral;
        InputState nextState = InputState.neutral;
        if (prevNode is MecaInputNode) prevState = prevNode.inputState;
        if (nextNode is MecaInputNode) nextState = nextNode.inputState;
        if (prevNode is KanjiProductionNode) prevState = prevNode.inputState;
        if (nextNode is KanjiProductionNode) nextState = nextNode.inputState;
        if (prevNode is ConceptRecallNode) prevState = prevNode.inputState;
        if (nextNode is ConceptRecallNode) nextState = nextNode.inputState;

        final transitioned =
            (prevState != InputState.success && nextState == InputState.success) ||
            (prevState != InputState.error && nextState == InputState.error);

        if (transitioned) {
          _clearLocalInputBuffers();
          _applyFocusPolicy();
        }
      },
    );

    Widget barContent;
    String modeKey;

    if (lastNode is MecaInputNode ||
        lastNode is KanjiProductionNode ||
        lastNode is ConceptRecallNode) {
      modeKey = 'terminal_mode';
      barContent = _buildTerminalMode(lastNode, timelineState, accent);
    } else if (lastNode is ChatNode) {
      modeKey = 'chat_mode';
      barContent = _buildChatMode(accent);
    } else if (lastNode is KanjiQuizNode) {
      modeKey = 'quiz_grid_mode';
      barContent = _buildQuizGridMode(lastNode, accent);
    } else if (lastNode is LaneCollisionViewportNode) {
      modeKey = 'arcade_deck_mode';
      barContent = _buildArcadeDeckMode(lastNode, accent);
    } else {
      modeKey = 'none';
      barContent = const SizedBox.shrink();
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 120),
      child: Container(
        key: ValueKey(modeKey),
        decoration: const BoxDecoration(
          color: Colors.black,
          border: Border(top: BorderSide(color: Colors.white10, width: 0.5)),
        ),
        child: barContent,
      ),
    );
  }

  Widget _buildTerminalMode(
    FeedNode lastNode,
    SessionTimelineState timelineState,
    Color accent,
  ) {
    String hint = 'Escribe en romaji...';
    if (lastNode is ConceptRecallNode) {
      hint = 'Evoca y escribe el carácter...';
    }

    InputState currentState = InputState.neutral;
    if (lastNode is MecaInputNode) currentState = lastNode.inputState;
    if (lastNode is KanjiProductionNode) currentState = lastNode.inputState;
    if (lastNode is ConceptRecallNode) currentState = lastNode.inputState;

    return LayoutBuilder(
      builder: (context, constraints) {
        if (_useFlick) {
          return _buildFlickMode(hint, timelineState, accent);
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: RayitaInput(
                  controller: _textController,
                  focusNode: _focusNode,
                  inputState: currentState,
                  hint: hint,
                  accentColor: accent,
                  readOnly: timelineState.isNeonErrorActive || timelineState.isPaused,
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
                onPressed: timelineState.isPaused || timelineState.isNeonErrorActive
                    ? null
                    : () => setState(() => _useFlick = true),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 32,
                  minHeight: 32,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFlickMode(
    String hint,
    SessionTimelineState timelineState,
    Color accent,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final keyboardHeight = constraints.maxHeight > 0
            ? constraints.maxHeight
            : (MediaQuery.of(context).size.height * 0.35).clamp(180.0, 320.0);

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _flickText.isEmpty ? hint : _flickText,
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
                    onPressed: () => setState(() {
                      _useFlick = false;
                      _flickText = '';
                    }),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: (keyboardHeight - 48).clamp(120.0, keyboardHeight),
              child: VirtualFlickKeyboard(
                enabled: !timelineState.isPaused && !timelineState.isNeonErrorActive,
                onCharacterSelected: (char) {
                  setState(() => _flickText += char);
                  ref
                      .read(timelineProvider.notifier)
                      .onTerminalInputChanged(_flickText);
                },
                onBackspace: () {
                  if (_flickText.isNotEmpty) {
                    setState(() {
                      _flickText = _flickText.substring(0, _flickText.length - 1);
                    });
                    ref
                        .read(timelineProvider.notifier)
                        .onTerminalInputChanged(_flickText);
                  }
                },
                onToggleKana: () {
                  // Stub: toggle kana mode (UI ready, backend pending)
                },
                accentColor: accent,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildChatMode(Color accent) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ChatConsoleInput(
        accentColor: accent,
        onSend: (text) {
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
  }

  Widget _buildQuizGridMode(KanjiQuizNode lastNode, Color accent) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossCount = (constraints.maxWidth / 120).clamp(2, 4).toInt();
        final spacing = (constraints.maxWidth * 0.02).clamp(8.0, 16.0);
        final rows = (lastNode.options.length / crossCount).ceil();
        final cellHeight = (constraints.maxHeight / rows).clamp(48.0, 96.0);
        final gridHeight = (rows * cellHeight + (rows - 1) * spacing)
            .clamp(cellHeight, constraints.maxHeight * 0.9);
        final childAspectRatio =
            (constraints.maxWidth / crossCount) / cellHeight;

        return AbsorbPointer(
          absorbing: _quizLocked,
          child: SizedBox(
            height: gridHeight,
            child: GridView.builder(
              physics: const BouncingScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossCount,
                crossAxisSpacing: spacing,
                mainAxisSpacing: spacing,
                childAspectRatio: childAspectRatio,
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
          ),
        );
      },
    );
  }

  Widget _buildArcadeDeckMode(
    LaneCollisionViewportNode lastNode,
    Color accent,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final deck = lastNode.deck;
        const minCardSize = 48.0;
        const maxCardSize = 72.0;
        final targetSize = (constraints.maxWidth / deck.length) * 0.85;
        final cardSize = targetSize.clamp(minCardSize, maxCardSize);

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: deck.map((k) {
                return Draggable<String>(
                  data: k.character,
                  feedback: Material(
                    color: Colors.transparent,
                    child: _ArcadeDeckCard(
                      character: k.character,
                      size: cardSize,
                      accent: accent,
                      isFeedback: true,
                    ),
                  ),
                  childWhenDragging: _ArcadeDeckCard(
                    character: k.character,
                    size: cardSize,
                    accent: accent,
                    isPlaceholder: true,
                  ),
                  child: _ArcadeDeckCard(
                    character: k.character,
                    size: cardSize,
                    accent: accent,
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
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

class _ArcadeDeckCard extends StatelessWidget {
  const _ArcadeDeckCard({
    required this.character,
    required this.size,
    required this.accent,
    this.isFeedback = false,
    this.isPlaceholder = false,
  });

  final String character;
  final double size;
  final Color accent;
  final bool isFeedback;
  final bool isPlaceholder;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isPlaceholder
            ? Colors.white.withValues(alpha: 0.01)
            : isFeedback
                ? accent.withValues(alpha: 0.25)
                : Colors.transparent,
        border: Border.all(
          color: isFeedback
              ? accent
              : isPlaceholder
                  ? Colors.white10
                  : accent.withValues(alpha: 0.6),
          width: isFeedback ? 2.0 : 1.5,
        ),
        shape: BoxShape.circle,
        boxShadow: isFeedback
            ? [
                BoxShadow(
                  color: accent.withValues(alpha: 0.3),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ]
            : [
                BoxShadow(
                  color: accent.withValues(alpha: 0.15),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
        gradient: isFeedback
            ? null
            : RadialGradient(
                colors: [
                  accent.withValues(alpha: 0.15),
                  Colors.transparent,
                ],
              ),
      ),
      alignment: Alignment.center,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          character,
          style: TextStyle(
            color: isFeedback ? Colors.white : accent,
            fontSize: 22,
            fontFamily: 'Courier',
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
