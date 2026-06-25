import 'dart:async';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kz_data/kz_data.dart';
import 'package:kz_domain/kz_domain.dart';
import 'package:kanjizen_app/src/providers/game_provider.dart';
import 'package:kanjizen_app/src/providers/kana_campaign_provider.dart';
import 'package:path_drawing/path_drawing.dart';

// ─── MODELOS DE NODOS (FEEDNODE) ─────────────────────────────────────────────

abstract class FeedNode {
  final String id;
  final DateTime timestamp;
  final bool isFrozen;

  FeedNode({required this.id, required this.timestamp, this.isFrozen = false});

  FeedNode freeze();
}

class MecaInputNode extends FeedNode {
  final List<GameCharacter> targetCharacters;
  final int currentIndex;
  final String inputText;
  final InputState inputState;
  final int errors;
  final int streak;
  final int avgMs;
  final double hitRate;
  final int? sessionTimeRemainingMs;

  MecaInputNode({
    required super.id,
    required super.timestamp,
    super.isFrozen,
    required this.targetCharacters,
    required this.currentIndex,
    required this.inputText,
    required this.inputState,
    required this.errors,
    required this.streak,
    required this.avgMs,
    required this.hitRate,
    this.sessionTimeRemainingMs,
  });

  @override
  MecaInputNode freeze() => MecaInputNode(
    id: id,
    timestamp: timestamp,
    isFrozen: true,
    targetCharacters: targetCharacters,
    currentIndex: currentIndex,
    inputText: inputText,
    inputState: inputState,
    errors: errors,
    streak: streak,
    avgMs: avgMs,
    hitRate: hitRate,
  );
}

class KanjiProductionNode extends FeedNode {
  final KanjiModel kanji;
  final String inputText;
  final InputState inputState;
  final bool showHint;
  final bool isSuccess;

  KanjiProductionNode({
    required super.id,
    required super.timestamp,
    super.isFrozen,
    required this.kanji,
    required this.inputText,
    required this.inputState,
    required this.showHint,
    this.isSuccess = false,
  });

  @override
  KanjiProductionNode freeze() => KanjiProductionNode(
    id: id,
    timestamp: timestamp,
    isFrozen: true,
    kanji: kanji,
    inputText: inputText,
    inputState: inputState,
    showHint: showHint,
    isSuccess: isSuccess,
  );
}

class ConceptRecallNode extends FeedNode {
  final KanjiModel kanji;
  final String inputText;
  final InputState inputState;
  final bool isSuccess;

  ConceptRecallNode({
    required super.id,
    required super.timestamp,
    super.isFrozen,
    required this.kanji,
    required this.inputText,
    required this.inputState,
    this.isSuccess = false,
  });

  @override
  ConceptRecallNode freeze() => ConceptRecallNode(
    id: id,
    timestamp: timestamp,
    isFrozen: true,
    kanji: kanji,
    inputText: inputText,
    inputState: inputState,
    isSuccess: isSuccess,
  );
}

class KanjiQuizNode extends FeedNode {
  final KanjiModel kanji;
  final List<String> options;
  final String? selectedOption;
  final bool isSuccess;

  KanjiQuizNode({
    required super.id,
    required super.timestamp,
    super.isFrozen,
    required this.kanji,
    required this.options,
    this.selectedOption,
    this.isSuccess = false,
  });

  @override
  KanjiQuizNode freeze() => KanjiQuizNode(
    id: id,
    timestamp: timestamp,
    isFrozen: true,
    kanji: kanji,
    options: options,
    selectedOption: selectedOption,
    isSuccess: isSuccess,
  );
}

class FallingAssetEntity {
  final String id;
  final String concept;
  final String correctKanji;
  final int lane;
  final double y;
  final double speed;

  FallingAssetEntity({
    required this.id,
    required this.concept,
    required this.correctKanji,
    required this.lane,
    required this.y,
    required this.speed,
  });

  FallingAssetEntity copyWith({double? y}) => FallingAssetEntity(
    id: id,
    concept: concept,
    correctKanji: correctKanji,
    lane: lane,
    y: y ?? this.y,
    speed: speed,
  );
}

class LaneCollisionViewportNode extends FeedNode {
  final List<KanjiModel> deck;
  final List<FallingAssetEntity> fallingEntities;
  final int score;
  final int lives;
  final bool isGameOver;

  LaneCollisionViewportNode({
    required super.id,
    required super.timestamp,
    super.isFrozen,
    required this.deck,
    required this.fallingEntities,
    required this.score,
    required this.lives,
    required this.isGameOver,
  });

  @override
  LaneCollisionViewportNode freeze() => LaneCollisionViewportNode(
    id: id,
    timestamp: timestamp,
    isFrozen: true,
    deck: deck,
    fallingEntities: fallingEntities,
    score: score,
    lives: lives,
    isGameOver: isGameOver,
  );
}

class StrokeValidationNode extends FeedNode {
  final KanjiModel kanji;
  final List<List<Offset>> userStrokes;
  final int currentStrokeIndex;
  final bool isSuccess;

  StrokeValidationNode({
    required super.id,
    required super.timestamp,
    super.isFrozen,
    required this.kanji,
    required this.userStrokes,
    required this.currentStrokeIndex,
    this.isSuccess = false,
  });

  @override
  StrokeValidationNode freeze() => StrokeValidationNode(
    id: id,
    timestamp: timestamp,
    isFrozen: true,
    kanji: kanji,
    userStrokes: userStrokes,
    currentStrokeIndex: currentStrokeIndex,
    isSuccess: isSuccess,
  );
}

class ExerciseReportNode extends FeedNode {
  final String title;
  final int totalQuestions;
  final int successes;
  final int errors;
  final int avgMs;
  final int maxMs;
  final double hitRate;

  ExerciseReportNode({
    required super.id,
    required super.timestamp,
    required this.title,
    required this.totalQuestions,
    required this.successes,
    required this.errors,
    required this.avgMs,
    required this.maxMs,
    required this.hitRate,
  }) : super(isFrozen: true);

  @override
  ExerciseReportNode freeze() => this;
}

// ─── ESTADO E HISTORIAL DE SESIONES ──────────────────────────────────────────

class SessionHistoryItem {
  final String id;
  final String name;
  final bool isPinned;
  final List<FeedNode> nodes;
  final EngineMode activeMode;
  final DateTime createdAt;

  SessionHistoryItem({
    required this.id,
    required this.name,
    this.isPinned = false,
    required this.nodes,
    required this.activeMode,
    required this.createdAt,
  });

  SessionHistoryItem copyWith({
    String? name,
    bool? isPinned,
    List<FeedNode>? nodes,
    EngineMode? activeMode,
  }) => SessionHistoryItem(
    id: id,
    name: name ?? this.name,
    isPinned: isPinned ?? this.isPinned,
    nodes: nodes ?? this.nodes,
    activeMode: activeMode ?? this.activeMode,
    createdAt: createdAt,
  );
}

class SessionTimelineState {
  final String activeSessionId;
  final List<SessionHistoryItem> history;
  final bool isPaused;
  final int streak;
  final int avgMs;
  final double hitRate;
  final int lives;
  final bool isNeonErrorActive;

  SessionTimelineState({
    required this.activeSessionId,
    required this.history,
    required this.isPaused,
    required this.streak,
    required this.avgMs,
    required this.hitRate,
    required this.lives,
    this.isNeonErrorActive = false,
  });

  SessionHistoryItem get activeSession =>
      history.firstWhere((s) => s.id == activeSessionId);

  List<FeedNode> get activeNodes => activeSession.nodes;

  SessionTimelineState copyWith({
    String? activeSessionId,
    List<SessionHistoryItem>? history,
    bool? isPaused,
    int? streak,
    int? avgMs,
    double? hitRate,
    int? lives,
    bool? isNeonErrorActive,
  }) => SessionTimelineState(
    activeSessionId: activeSessionId ?? this.activeSessionId,
    history: history ?? this.history,
    isPaused: isPaused ?? this.isPaused,
    streak: streak ?? this.streak,
    avgMs: avgMs ?? this.avgMs,
    hitRate: hitRate ?? this.hitRate,
    lives: lives ?? this.lives,
    isNeonErrorActive: isNeonErrorActive ?? this.isNeonErrorActive,
  );
}

// ─── STATE NOTIFIER (TIMELINE PROVIDER) ──────────────────────────────────────

class TimelineNotifier extends StateNotifier<SessionTimelineState> {
  TimelineNotifier(this.ref)
    : super(
        SessionTimelineState(
          activeSessionId: 'session_01',
          history: [
            SessionHistoryItem(
              id: 'session_01',
              name: 'SESIÓN 01',
              nodes: [],
              activeMode: EngineMode.meca,
              createdAt: DateTime.now(),
            ),
          ],
          isPaused: false,
          streak: 0,
          avgMs: 0,
          hitRate: 0.0,
          lives: 5,
        ),
      ) {
    _initTimeline();
  }

  final Ref ref;
  final _repo = CharacterRepository.instance;

  Timer? _deathClockTimer;
  Timer? _arcadeGameTimer;
  int? _questionStartMs;
  int _arcadeTicks = 0;

  @override
  void dispose() {
    _deathClockTimer?.cancel();
    _arcadeGameTimer?.cancel();
    super.dispose();
  }

  Future<void> _initTimeline() async {
    await DatabaseInitializerService.seedInBackground();
    await generateNextNode(forceNew: true);
  }

  // Cambiar modo de motor
  void setEngineMode(EngineMode mode) {
    ref.read(settingsProvider.notifier).setEngineMode(mode);
    _deathClockTimer?.cancel();
    _arcadeGameTimer?.cancel();

    // Actualizar el modo de la sesión activa
    state = state.copyWith(
      history: state.history.map((s) {
        if (s.id == state.activeSessionId) {
          return s.copyWith(activeMode: mode);
        }
        return s;
      }).toList(),
    );

    generateNextNode(forceNew: true);
  }

  // Pausar y reanudar
  void pauseGame() {
    _deathClockTimer?.cancel();
    _arcadeGameTimer?.cancel();
    state = state.copyWith(isPaused: true);
  }

  void resumeGame() {
    state = state.copyWith(isPaused: false);
    _questionStartMs = DateTime.now().millisecondsSinceEpoch;
    _startDeathClock();
    _startArcadeLoopIfNeeded();
  }

  void triggerNeonError() {
    state = state.copyWith(isNeonErrorActive: true);
    HapticFeedback.vibrate();
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) state = state.copyWith(isNeonErrorActive: false);
    });
  }

  void _handleHardcoreFailure() {
    if (ref.read(settingsProvider).hardcoreMode) {
      final nextLives = state.lives - 1;
      state = state.copyWith(lives: nextLives.clamp(0, 99));
      if (nextLives <= 0) {
        pauseGame();
        _triggerReportNode('GAME OVER (SIN VIDAS)', 0, 0);
      }
    }
  }

  // Acciones Rápidas Drawer
  void createNewSession() {
    final nextNum = state.history.length + 1;
    final id = 'session_${nextNum.toString().padLeft(2, '0')}';
    final name = 'SESIÓN ${nextNum.toString().padLeft(2, '0')}';
    final activeMode = ref.read(settingsProvider).engineMode;

    final newSession = SessionHistoryItem(
      id: id,
      name: name,
      nodes: [],
      activeMode: activeMode,
      createdAt: DateTime.now(),
    );

    state = state.copyWith(
      activeSessionId: id,
      history: [...state.history, newSession],
      streak: 0,
      avgMs: 0,
      hitRate: 0.0,
      lives: ref.read(settingsProvider).hardcoreLives,
    );

    generateNextNode(forceNew: true);
  }

  void pinSession(String id) {
    state = state.copyWith(
      history: state.history.map((s) {
        if (s.id == id) {
          return s.copyWith(isPinned: !s.isPinned);
        }
        return s;
      }).toList(),
    );
  }

  void renameSession(String id, String newName) {
    state = state.copyWith(
      history: state.history.map((s) {
        if (s.id == id) {
          return s.copyWith(name: newName);
        }
        return s;
      }).toList(),
    );
  }

  void deleteSession(String id) {
    if (state.history.length <= 1) return; // Keep at least one
    final activeId = state.activeSessionId == id
        ? state.history.firstWhere((s) => s.id != id).id
        : state.activeSessionId;

    state = state.copyWith(
      activeSessionId: activeId,
      history: state.history.where((s) => s.id != id).toList(),
    );

    if (state.activeSessionId == activeId && id == state.activeSessionId) {
      generateNextNode(forceNew: true);
    }
  }

  void selectSession(String id) {
    _deathClockTimer?.cancel();
    _arcadeGameTimer?.cancel();
    state = state.copyWith(activeSessionId: id);
    generateNextNode(forceNew: true);
  }

  // Inicia un nivel de campaña inyectando un nodo especial en el feed
  void startCampaignLevel(KanaLevelModel level) {
    ref.read(settingsProvider.notifier).setEngineMode(EngineMode.meca);
    _deathClockTimer?.cancel();
    _arcadeGameTimer?.cancel();

    final timestamp = DateTime.now();
    final id =
        'campaign_level_${level.levelId}_${timestamp.millisecondsSinceEpoch}';

    // Congelar nodos previos
    final updatedNodes = List<FeedNode>.from(state.activeSession.nodes);
    if (updatedNodes.isNotEmpty) {
      final lastNode = updatedNodes.last;
      updatedNodes[updatedNodes.length - 1] = lastNode.freeze();
    }

    final targetChars = level.targetCharacters.map((char) {
      final isKata = level.mode == 'katakana';
      final seed = KanaSeedData.all
          .where((s) => s.character == char)
          .firstOrNull;
      return GameCharacter(
        kana: KanaModel(
          character: char,
          romaji: seed?.romaji ?? 'a',
          isKatakana: isKata,
          linkedKanaCharacter: '',
          isDakutenOrHandakuten: false,
          isUnlocked: true,
        ),
      );
    }).toList();
    targetChars.shuffle();

    final nextNode = MecaInputNode(
      id: id,
      timestamp: timestamp,
      targetCharacters: targetChars,
      currentIndex: 0,
      inputText: '',
      inputState: InputState.neutral,
      errors: 0,
      streak: 0,
      avgMs: 0,
      hitRate: 1.0,
    );

    updatedNodes.add(nextNode);

    state = state.copyWith(
      history: state.history.map((s) {
        if (s.id == state.activeSessionId) {
          return s.copyWith(nodes: updatedNodes, activeMode: EngineMode.meca);
        }
        return s;
      }).toList(),
      isPaused: false,
    );

    _questionStartMs = DateTime.now().millisecondsSinceEpoch;
    _startDeathClock();
  }

  // Generador de Nodos
  Future<void> generateNextNode({bool forceNew = false}) async {
    _deathClockTimer?.cancel();
    _arcadeGameTimer?.cancel();

    final activeSession = state.activeSession;
    final mode = activeSession.activeMode;
    final timestamp = DateTime.now();
    final id = 'node_${timestamp.millisecondsSinceEpoch}';

    // Congelar nodos previos
    final updatedNodes = List<FeedNode>.from(activeSession.nodes);
    if (updatedNodes.isNotEmpty) {
      final lastNode = updatedNodes.last;
      updatedNodes[updatedNodes.length - 1] = lastNode.freeze();
    }

    FeedNode nextNode;

    switch (mode) {
      case EngineMode.meca:
        final kanas = await _repo.getUnlockedKanas();
        final kanjis = await _repo.getAllKanjis();
        final unlockedKanjis = kanjis.where((k) => k.isUnlocked).toList();

        // 60% Kanas / 40% Kanjis weighted srs selection
        final targetChars = <GameCharacter>[];
        final size = ref.read(settingsProvider).layoutMode == AppLayoutMode.word
            ? 4
            : (ref.read(settingsProvider).layoutMode == AppLayoutMode.text
                  ? 10
                  : 1);

        for (int i = 0; i < size; i++) {
          final rand = Random().nextInt(100);
          if (rand < 40 && unlockedKanjis.isNotEmpty) {
            final k = unlockedKanjis[Random().nextInt(unlockedKanjis.length)];
            targetChars.add(GameCharacter(kanji: _toKanjiModel(k)));
          } else if (kanas.isNotEmpty) {
            final k = kanas[Random().nextInt(kanas.length)];
            targetChars.add(GameCharacter(kana: _toKanaModel(k)));
          } else {
            // Default fallback
            targetChars.add(
              const GameCharacter(
                kana: KanaModel(
                  character: 'あ',
                  romaji: 'a',
                  isKatakana: false,
                  linkedKanaCharacter: '',
                  isDakutenOrHandakuten: false,
                  isUnlocked: true,
                ),
              ),
            );
          }
        }

        nextNode = MecaInputNode(
          id: id,
          timestamp: timestamp,
          targetCharacters: targetChars,
          currentIndex: 0,
          inputText: '',
          inputState: InputState.neutral,
          errors: 0,
          streak: 0,
          avgMs: 0,
          hitRate: 1.0,
        );
        break;

      case EngineMode.kanji:
        final settings = ref.read(settingsProvider);
        var kanjis = await _repo.getAllKanjis();

        // Apply thematic filter
        if (settings.kanjiFilterTopic == KanjiFilterTopic.grade) {
          kanjis = kanjis.where((k) => k.joyo > 0).toList();
        } else if (settings.kanjiFilterTopic == KanjiFilterTopic.jlpt) {
          kanjis = kanjis.where((k) => k.jlpt > 0).toList();
        }

        var activeKanjis = kanjis.where((k) => k.isUnlocked).toList();

        // Ensure we respect batch size
        if (activeKanjis.length < settings.kanjiBatchSize) {
          final needed = settings.kanjiBatchSize - activeKanjis.length;
          final locked = kanjis
              .where((k) => !k.isUnlocked)
              .take(needed)
              .toList();
          for (var l in locked) {
            await _repo.unlockKanji(l.character);
          }
          // Reload database state
          final updatedKanjis = await _repo.getAllKanjis();
          var reFiltered = updatedKanjis;
          if (settings.kanjiFilterTopic == KanjiFilterTopic.grade) {
            reFiltered = reFiltered.where((k) => k.joyo > 0).toList();
          } else if (settings.kanjiFilterTopic == KanjiFilterTopic.jlpt) {
            reFiltered = reFiltered.where((k) => k.jlpt > 0).toList();
          }
          activeKanjis = reFiltered.where((k) => k.isUnlocked).toList();
        }

        // Limit active rotation pool to settings.kanjiBatchSize
        final rotationPool = activeKanjis
            .take(settings.kanjiBatchSize)
            .toList();

        // Choose target based on srsProportion
        KanjiEntity targetKanji;
        final rand = Random().nextInt(100);
        bool pickNew = false;
        if (settings.srsProportion == SrsProportion.ratio80_20) {
          pickNew = (rand < 20);
        } else if (settings.srsProportion == SrsProportion.ratio60_40) {
          pickNew = (rand < 40);
        }

        if (pickNew) {
          final lockedKanjis = kanjis.where((k) => !k.isUnlocked).toList();
          if (lockedKanjis.isNotEmpty) {
            final newK = lockedKanjis[Random().nextInt(lockedKanjis.length)];
            await _repo.unlockKanji(newK.character);
            targetKanji = newK;
          } else {
            targetKanji = rotationPool[Random().nextInt(rotationPool.length)];
          }
        } else {
          targetKanji = rotationPool[Random().nextInt(rotationPool.length)];
        }

        final model = _toKanjiModel(targetKanji);

        if (model.srsScore < 5.0) {
          nextNode = KanjiProductionNode(
            id: id,
            timestamp: timestamp,
            kanji: model,
            inputText: '',
            inputState: InputState.neutral,
            showHint: model.currentHitRate < 0.7,
          );
        } else {
          nextNode = ConceptRecallNode(
            id: id,
            timestamp: timestamp,
            kanji: model,
            inputText: '',
            inputState: InputState.neutral,
          );
        }
        break;

      case EngineMode.quiz:
        final settings = ref.read(settingsProvider);
        var kanjis = await _repo.getAllKanjis();

        // Apply thematic filter if applicable
        if (settings.kanjiFilterTopic == KanjiFilterTopic.grade) {
          kanjis = kanjis.where((k) => k.joyo > 0).toList();
        } else if (settings.kanjiFilterTopic == KanjiFilterTopic.jlpt) {
          kanjis = kanjis.where((k) => k.jlpt > 0).toList();
        }

        var activeKanjis = kanjis.where((k) => k.isUnlocked).toList();
        if (activeKanjis.isEmpty) {
          final locked = kanjis.where((k) => !k.isUnlocked).take(5).toList();
          for (var l in locked) {
            await _repo.unlockKanji(l.character);
          }
          final updatedKanjis = await _repo.getAllKanjis();
          var reFiltered = updatedKanjis;
          if (settings.kanjiFilterTopic == KanjiFilterTopic.grade) {
            reFiltered = reFiltered.where((k) => k.joyo > 0).toList();
          } else if (settings.kanjiFilterTopic == KanjiFilterTopic.jlpt) {
            reFiltered = reFiltered.where((k) => k.jlpt > 0).toList();
          }
          activeKanjis = reFiltered.where((k) => k.isUnlocked).toList();
        }

        final target = activeKanjis[Random().nextInt(activeKanjis.length)];
        final model = _toKanjiModel(target);

        final totalOptionsCount = settings.quizDensity == QuizDensity.matrix2x2
            ? 4
            : 6;
        final optionsSet = <String>{model.character};

        // If quizMatchRadicals is enabled, preferentially find distractors with the same radical
        if (settings.quizMatchRadicals) {
          final sameRad = activeKanjis
              .where(
                (k) =>
                    k.radical == target.radical &&
                    k.character != target.character,
              )
              .toList();
          sameRad.shuffle();
          for (var k in sameRad) {
            if (optionsSet.length >= totalOptionsCount) break;
            optionsSet.add(k.character);
          }
        }

        // Fill remaining options with random unlocked Kanjis
        final remainingPool = activeKanjis
            .where((k) => k.character != target.character)
            .toList();
        remainingPool.shuffle();
        for (var k in remainingPool) {
          if (optionsSet.length >= totalOptionsCount) break;
          optionsSet.add(k.character);
        }

        // Fill with extra fillers if optionsSet length is still less than totalOptionsCount
        final extraFills = ['☠', '☯', '無', '心', '禅', '空'];
        for (var f in extraFills) {
          if (optionsSet.length >= totalOptionsCount) break;
          optionsSet.add(f);
        }

        final options = optionsSet.toList();
        options.shuffle();

        nextNode = KanjiQuizNode(
          id: id,
          timestamp: timestamp,
          kanji: model,
          options: options,
        );
        break;

      case EngineMode.arcade:
        final settings = ref.read(settingsProvider);
        final kanjis = await _repo.getAllKanjis();
        var activeKanjis = kanjis.where((k) => k.isUnlocked).toList();
        if (activeKanjis.isEmpty) {
          final locked = kanjis.where((k) => !k.isUnlocked).take(5).toList();
          for (var l in locked) {
            await _repo.unlockKanji(l.character);
          }
          activeKanjis = (await _repo.getAllKanjis())
              .where((k) => k.isUnlocked)
              .toList();
        }

        activeKanjis.shuffle();
        final deck = activeKanjis
            .take(settings.arcadeLanes)
            .map(_toKanjiModel)
            .toList();

        nextNode = LaneCollisionViewportNode(
          id: id,
          timestamp: timestamp,
          deck: deck,
          fallingEntities: [],
          score: 0,
          lives: 5,
          isGameOver: false,
        );
        break;

      case EngineMode.write:
        final kanjis = await _repo.getAllKanjis();
        final activeKanjis = kanjis.where((k) => k.isUnlocked).toList();
        if (activeKanjis.isEmpty) {
          final locked = kanjis.where((k) => !k.isUnlocked).take(5).toList();
          for (var l in locked) {
            await _repo.unlockKanji(l.character);
          }
          activeKanjis.addAll(locked);
        }

        final target = activeKanjis[Random().nextInt(activeKanjis.length)];
        nextNode = StrokeValidationNode(
          id: id,
          timestamp: timestamp,
          kanji: _toKanjiModel(target),
          userStrokes: [],
          currentStrokeIndex: 0,
        );
        break;
    }

    updatedNodes.add(nextNode);

    state = state.copyWith(
      history: state.history.map((s) {
        if (s.id == state.activeSessionId) {
          return s.copyWith(nodes: updatedNodes);
        }
        return s;
      }).toList(),
      isPaused: false,
    );

    _questionStartMs = DateTime.now().millisecondsSinceEpoch;
    _startDeathClock();
    _startArcadeLoopIfNeeded();
  }

  // Reloj de la Muerte
  void _startDeathClock() {
    _deathClockTimer?.cancel();
    final clockSetting = ref.read(settingsProvider).deathClock;
    if (clockSetting == DeathClock.off) return;

    final double seconds = switch (clockSetting) {
      DeathClock.off => 0,
      DeathClock.s5 => 5,
      DeathClock.s3 => 3,
      DeathClock.s1_5 => 1.5,
      DeathClock.s1 => 1,
      DeathClock.s0_75 => 0.75,
      DeathClock.s0_5 => 0.5,
    };

    if (seconds <= 0) return;

    _deathClockTimer = Timer(
      Duration(milliseconds: (seconds * 1000).toInt()),
      () {
        _handleTimeExpired();
      },
    );
  }

  Future<void> _handleTimeExpired() async {
    final activeSession = state.activeSession;
    if (activeSession.nodes.isEmpty) return;
    final lastNode = activeSession.nodes.last;

    if (lastNode is MecaInputNode && !lastNode.isFrozen) {
      // Penalty and advance
      final char = lastNode.targetCharacters[lastNode.currentIndex];
      await _penalizeCharacter(char.character, !char.isKana);
      await _advanceMecaError(lastNode);
    } else if ((lastNode is KanjiProductionNode ||
            lastNode is ConceptRecallNode) &&
        !lastNode.isFrozen) {
      final character = lastNode is KanjiProductionNode
          ? lastNode.kanji.character
          : (lastNode as ConceptRecallNode).kanji.character;
      await _penalizeCharacter(character, true);
      _recordTelemetry(false, 3000);
      await generateNextNode();
    } else if (lastNode is KanjiQuizNode && !lastNode.isFrozen) {
      await _penalizeCharacter(lastNode.kanji.character, true);
      _recordTelemetry(false, 3000);
      await generateNextNode();
    }
  }

  // Sincronizar input de TerminalMode
  Future<void> onTerminalInputChanged(String text) async {
    if (state.isPaused || state.isNeonErrorActive) {
      return; // Prevent input if frozen
    }
    final activeSession = state.activeSession;
    if (activeSession.nodes.isEmpty) return;
    final lastNode = activeSession.nodes.last;

    final cleanInput = text.toLowerCase().trim();

    if (lastNode is MecaInputNode && !lastNode.isFrozen) {
      final targetChar = lastNode.targetCharacters[lastNode.currentIndex];
      final targetRomaji = targetChar.romaji.toLowerCase().trim();
      final targetJapanese = targetChar.character.toLowerCase().trim();

      if (cleanInput.isEmpty) return;

      // Acerto absoluto
      if (cleanInput == targetRomaji || cleanInput == targetJapanese) {
        await _handleMecaStepSuccess(lastNode, targetChar);
        return;
      }

      // Composer Mode: is it a valid prefix?
      if (targetRomaji.startsWith(cleanInput) ||
          targetJapanese.startsWith(cleanInput)) {
        // Update input state in current node
        _updateMecaInput(lastNode, text, InputState.progress);
        return;
      }

      // Fallo absoluto: clear buffer, execute haptic error, penalize domain
      triggerNeonError();
      _handleHardcoreFailure();
      _updateMecaInput(lastNode, '', InputState.error);
      await _penalizeCharacter(targetChar.character, !targetChar.isKana);
      _recordTelemetry(
        false,
        DateTime.now().millisecondsSinceEpoch - _questionStartMs!,
      );

      // Clean error status after 150ms
      Future.delayed(const Duration(milliseconds: 150), () async {
        if (!mounted) return;
        _updateMecaInput(lastNode, '', InputState.neutral);
      });
    } else if (lastNode is KanjiProductionNode && !lastNode.isFrozen) {
      final k = lastNode.kanji;
      if (cleanInput.isEmpty) return;

      // Check Onyomi, Kunyomi or Meanings
      final isMatch = _checkKanjiMatch(k, cleanInput);
      final isPrefix = _checkKanjiPrefix(k, cleanInput);

      if (isMatch) {
        _updateKanjiProductionInput(lastNode, '', InputState.success);
        await _handleKanjiSuccess(k);
        return;
      }
      if (isPrefix) {
        _updateKanjiProductionInput(lastNode, text, InputState.progress);
        return;
      }

      // Fallo
      triggerNeonError();
      _handleHardcoreFailure();
      _updateKanjiProductionInput(lastNode, '', InputState.error);
      await _repo.updateKanjiSrs(
        k.character,
        (k.srsScore - 0.25).clamp(0.0, 10.0),
        k.consecutiveFails + 1,
      );
      _recordTelemetry(false, 1000);

      Future.delayed(const Duration(milliseconds: 150), () async {
        if (!mounted) return;
        _updateKanjiProductionInput(lastNode, '', InputState.neutral);
        await generateNextNode();
      });
    } else if (lastNode is ConceptRecallNode && !lastNode.isFrozen) {
      final k = lastNode.kanji;
      if (cleanInput.isEmpty) return;

      // Blind recall: user writes Kanji character itself or its primary romaji reading
      final isMatch =
          cleanInput == k.character || _checkKanjiMatch(k, cleanInput);
      final isPrefix =
          k.character.startsWith(cleanInput) ||
          _checkKanjiPrefix(k, cleanInput);

      if (isMatch) {
        _updateConceptRecallInput(lastNode, '', InputState.success);
        await _handleKanjiSuccess(k);
        return;
      }
      if (isPrefix) {
        _updateConceptRecallInput(lastNode, text, InputState.progress);
        return;
      }

      // Fallo
      triggerNeonError();
      _handleHardcoreFailure();
      _updateConceptRecallInput(lastNode, '', InputState.error);
      await _repo.updateKanjiSrs(
        k.character,
        (k.srsScore - 0.5).clamp(0.0, 10.0),
        k.consecutiveFails + 1,
      );
      _recordTelemetry(false, 1000);

      Future.delayed(const Duration(milliseconds: 150), () async {
        if (!mounted) return;
        _updateConceptRecallInput(lastNode, '', InputState.neutral);
        await generateNextNode();
      });
    }
  }

  bool _checkKanjiMatch(KanjiModel k, String input) {
    final meanings = k.meanings.map((m) => m.toLowerCase().trim());
    if (meanings.contains(input)) return true;

    // Kunyomi & Onyomi
    for (final ony in k.onyomi) {
      if (ony.replaceAll('.', '').replaceAll('-', '').toLowerCase().trim() ==
          input) {
        return true;
      }
    }
    for (final kun in k.kunyomi) {
      if (kun.replaceAll('.', '').replaceAll('-', '').toLowerCase().trim() ==
          input) {
        return true;
      }
    }
    return false;
  }

  bool _checkKanjiPrefix(KanjiModel k, String input) {
    final meanings = k.meanings.map((m) => m.toLowerCase().trim());
    if (meanings.any((m) => m.startsWith(input))) return true;

    for (final ony in k.onyomi) {
      if (ony
          .replaceAll('.', '')
          .replaceAll('-', '')
          .toLowerCase()
          .trim()
          .startsWith(input)) {
        return true;
      }
    }
    for (final kun in k.kunyomi) {
      if (kun
          .replaceAll('.', '')
          .replaceAll('-', '')
          .toLowerCase()
          .trim()
          .startsWith(input)) {
        return true;
      }
    }
    return false;
  }

  Future<void> _handleMecaStepSuccess(
    MecaInputNode node,
    GameCharacter targetChar,
  ) async {
    if (ref.read(settingsProvider).enableAudio) {
      AudioFeedbackService.instance.playReading(targetChar.character);
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    final responseMs = _questionStartMs != null ? now - _questionStartMs! : 500;

    // Update character stats
    await _updateCharacterProgress(targetChar, true, responseMs);
    _recordTelemetry(true, responseMs);

    final nextIndex = node.currentIndex + 1;
    if (nextIndex >= node.targetCharacters.length) {
      // Completed block/report
      final isCampaign = node.id.startsWith('campaign_level_');
      if (isCampaign) {
        final parts = node.id.split('_');
        final levelId = int.tryParse(parts[2]) ?? 1;
        final hitRate =
            (node.targetCharacters.length - node.errors) /
            node.targetCharacters.length;
        ref
            .read(kanaCampaignProvider.notifier)
            .evaluateSession(
              levelId: levelId,
              hitRate: hitRate,
              maxTimePerCharMs: state.avgMs,
              isHardcore: ref.read(settingsProvider).hardcoreMode,
            );
        _triggerReportNode(
          'NIVEL $levelId COMPLETADO',
          node.targetCharacters.length,
          node.errors,
        );
      } else {
        // MECA es infinito — continúa sin mostrar pantalla de completado.
        await generateNextNode();
      }
    } else {
      // Move to next char in current node
      final updatedNode = MecaInputNode(
        id: node.id,
        timestamp: node.timestamp,
        targetCharacters: node.targetCharacters,
        currentIndex: nextIndex,
        inputText: '',
        inputState: InputState.success,
        errors: node.errors,
        streak: node.streak + 1,
        avgMs: responseMs,
        hitRate: node.hitRate,
      );

      _updateNodeInTimeline(updatedNode);
      _questionStartMs = DateTime.now().millisecondsSinceEpoch;
      _startDeathClock();
    }
  }

  Future<void> _advanceMecaError(MecaInputNode node) async {
    final nextIndex = node.currentIndex + 1;

    final updatedNode = MecaInputNode(
      id: node.id,
      timestamp: node.timestamp,
      targetCharacters: node.targetCharacters,
      currentIndex: nextIndex >= node.targetCharacters.length
          ? node.currentIndex
          : nextIndex,
      inputText: '',
      inputState: InputState.neutral,
      errors: node.errors + 1,
      streak: 0,
      avgMs: node.avgMs,
      hitRate: node.hitRate,
    );

    if (nextIndex >= node.targetCharacters.length) {
      final isCampaign = node.id.startsWith('campaign_level_');
      if (isCampaign) {
        final parts = node.id.split('_');
        final levelId = int.tryParse(parts[2]) ?? 1;
        final hitRate =
            (node.targetCharacters.length - updatedNode.errors) /
            node.targetCharacters.length;
        ref
            .read(kanaCampaignProvider.notifier)
            .evaluateSession(
              levelId: levelId,
              hitRate: hitRate,
              maxTimePerCharMs: state.avgMs,
              isHardcore: ref.read(settingsProvider).hardcoreMode,
            );
        _triggerReportNode(
          'NIVEL $levelId COMPLETADO',
          node.targetCharacters.length,
          updatedNode.errors,
        );
      } else {
        // MECA es infinito — continúa sin mostrar pantalla de completado.
        await generateNextNode();
      }
    } else {
      _updateNodeInTimeline(updatedNode);
      _questionStartMs = DateTime.now().millisecondsSinceEpoch;
      _startDeathClock();
    }
  }

  void _updateMecaInput(MecaInputNode node, String text, InputState stateVal) {
    final updated = MecaInputNode(
      id: node.id,
      timestamp: node.timestamp,
      targetCharacters: node.targetCharacters,
      currentIndex: node.currentIndex,
      inputText: text,
      inputState: stateVal,
      errors: node.errors,
      streak: node.streak,
      avgMs: node.avgMs,
      hitRate: node.hitRate,
    );
    _updateNodeInTimeline(updated);
  }

  void _updateKanjiProductionInput(
    KanjiProductionNode node,
    String text,
    InputState stateVal,
  ) {
    final updated = KanjiProductionNode(
      id: node.id,
      timestamp: node.timestamp,
      kanji: node.kanji,
      inputText: text,
      inputState: stateVal,
      showHint: node.showHint,
      isSuccess: stateVal == InputState.success,
    );
    _updateNodeInTimeline(updated);
  }

  void _updateConceptRecallInput(
    ConceptRecallNode node,
    String text,
    InputState stateVal,
  ) {
    final updated = ConceptRecallNode(
      id: node.id,
      timestamp: node.timestamp,
      kanji: node.kanji,
      inputText: text,
      inputState: stateVal,
      isSuccess: stateVal == InputState.success,
    );
    _updateNodeInTimeline(updated);
  }

  Future<void> _handleKanjiSuccess(KanjiModel k) async {
    if (ref.read(settingsProvider).enableAudio) {
      AudioFeedbackService.instance.playReading(k.character);
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    final responseMs = _questionStartMs != null
        ? now - _questionStartMs!
        : 1000;

    await _repo.updateKanjiSrs(
      k.character,
      (k.srsScore + 0.5).clamp(0.0, 10.0),
      0,
    );
    await _updateCharacterProgress(GameCharacter(kanji: k), true, responseMs);
    _recordTelemetry(true, responseMs);

    await generateNextNode();
  }

  // Quiz Option Selected
  Future<void> onQuizOptionSelected(String opt) async {
    if (state.isPaused) return;
    final activeSession = state.activeSession;
    if (activeSession.nodes.isEmpty) return;
    final lastNode = activeSession.nodes.last;

    if (lastNode is KanjiQuizNode && !lastNode.isFrozen) {
      final success = opt == lastNode.kanji.character;
      final now = DateTime.now().millisecondsSinceEpoch;
      final responseMs = _questionStartMs != null
          ? now - _questionStartMs!
          : 1000;

      if (success) {
        if (ref.read(settingsProvider).enableAudio) {
          AudioFeedbackService.instance.playReading(lastNode.kanji.character);
        }
        await _repo.updateKanjiSrs(
          lastNode.kanji.character,
          (lastNode.kanji.srsScore + 0.5).clamp(0.0, 10.0),
          0,
        );
        await _updateCharacterProgress(
          GameCharacter(kanji: lastNode.kanji),
          true,
          responseMs,
        );
        _recordTelemetry(true, responseMs);
      } else {
        triggerNeonError();
        _handleHardcoreFailure();
        await _repo.updateKanjiSrs(
          lastNode.kanji.character,
          (lastNode.kanji.srsScore - 0.25).clamp(0.0, 10.0),
          lastNode.kanji.consecutiveFails + 1,
        );
        await _updateCharacterProgress(
          GameCharacter(kanji: lastNode.kanji),
          false,
          responseMs,
        );
        _recordTelemetry(false, responseMs);
      }

      await generateNextNode();
    }
  }

  // Arcade Mode Tick Loop
  void _startArcadeLoopIfNeeded() {
    _arcadeGameTimer?.cancel();
    final activeSession = state.activeSession;
    if (activeSession.nodes.isEmpty) return;
    final lastNode = activeSession.nodes.last;

    if (lastNode is LaneCollisionViewportNode &&
        !lastNode.isFrozen &&
        !lastNode.isGameOver) {
      _arcadeTicks = 0;
      _arcadeGameTimer = Timer.periodic(const Duration(milliseconds: 100), (
        timer,
      ) {
        if (state.isPaused) return;
        _tickArcade();
      });
    }
  }

  void _tickArcade() {
    final activeSession = state.activeSession;
    if (activeSession.nodes.isEmpty) return;
    final lastNode = activeSession.nodes.last as LaneCollisionViewportNode;

    _arcadeTicks++;

    final settings = ref.read(settingsProvider);
    final speedFactor = settings.arcadeAcceleration
        ? (1.0 + state.streak * 0.05)
        : 1.0;

    // Mover entities hacia abajo
    final updatedFalling = lastNode.fallingEntities.map((e) {
      return e.copyWith(y: e.y + e.speed * speedFactor);
    }).toList();

    // Comprobar si cruzan la deadline inferior (y >= 1.0)
    int lostLives = 0;
    final List<FallingAssetEntity> surviving = [];
    for (final entity in updatedFalling) {
      if (entity.y >= 1.0) {
        lostLives++;
        HapticFeedback.vibrate();
      } else {
        surviving.add(entity);
      }
    }

    // Inyectar nuevos enemigos
    if (_arcadeTicks % 25 == 0 && surviving.length < 5) {
      final randomDeckKanji =
          lastNode.deck[Random().nextInt(lastNode.deck.length)];
      final lane = Random().nextInt(lastNode.deck.length);
      surviving.add(
        FallingAssetEntity(
          id: 'asset_${DateTime.now().millisecondsSinceEpoch}',
          concept: randomDeckKanji.meanings.first.toUpperCase(),
          correctKanji: randomDeckKanji.character,
          lane: lane,
          y: 0.0,
          speed: 0.02 + Random().nextDouble() * 0.015,
        ),
      );
    }

    final newLives = max(0, lastNode.lives - lostLives);
    final gameOver = newLives <= 0;

    final updatedNode = LaneCollisionViewportNode(
      id: lastNode.id,
      timestamp: lastNode.timestamp,
      deck: lastNode.deck,
      fallingEntities: surviving,
      score: lastNode.score,
      lives: newLives,
      isGameOver: gameOver,
    );

    _updateNodeInTimeline(updatedNode);

    if (gameOver) {
      _arcadeGameTimer?.cancel();
      _triggerReportNode('ARCADE COMPLETADO', lastNode.score, 5 - newLives);
    }
  }

  // Colisión Arcade Flick/Drag
  void onArcadeFlick(String kanjiChar, int lane) {
    if (state.isPaused) return;
    final activeSession = state.activeSession;
    if (activeSession.nodes.isEmpty) return;
    final lastNode = activeSession.nodes.last;

    if (lastNode is LaneCollisionViewportNode &&
        !lastNode.isFrozen &&
        !lastNode.isGameOver) {
      // Find matching falling asset in that lane
      final matches = lastNode.fallingEntities
          .where((e) => e.lane == lane)
          .toList();
      if (matches.isEmpty) return;

      // Closest one to bottom (highest y)
      matches.sort((a, b) => b.y.compareTo(a.y));
      final target = matches.first;

      if (target.correctKanji == kanjiChar) {
        // Destroy and reward
        if (ref.read(settingsProvider).enableAudio) {
          AudioFeedbackService.instance.playReading(kanjiChar);
        }
        final updatedList = lastNode.fallingEntities
            .where((e) => e.id != target.id)
            .toList();
        final updatedNode = LaneCollisionViewportNode(
          id: lastNode.id,
          timestamp: lastNode.timestamp,
          deck: lastNode.deck,
          fallingEntities: updatedList,
          score: lastNode.score + 100,
          lives: lastNode.lives,
          isGameOver: false,
        );
        _updateNodeInTimeline(updatedNode);
        _recordTelemetry(true, 500);
      } else {
        // Fallo: rest life
        HapticFeedback.vibrate();
        final newLives = max(0, lastNode.lives - 1);
        final gameOver = newLives <= 0;

        final updatedNode = LaneCollisionViewportNode(
          id: lastNode.id,
          timestamp: lastNode.timestamp,
          deck: lastNode.deck,
          fallingEntities: lastNode.fallingEntities,
          score: lastNode.score,
          lives: newLives,
          isGameOver: gameOver,
        );
        _updateNodeInTimeline(updatedNode);
        _recordTelemetry(false, 500);

        if (gameOver) {
          _arcadeGameTimer?.cancel();
          _triggerReportNode('ARCADE COMPLETADO', lastNode.score, 5 - newLives);
        }
      }
    }
  }

  // Write Canvas Drawing Stroke logic
  Future<void> onStrokeCompleted(List<Offset> points) async {
    if (state.isPaused) return;
    final activeSession = state.activeSession;
    if (activeSession.nodes.isEmpty) return;
    final lastNode = activeSession.nodes.last;

    if (lastNode is StrokeValidationNode && !lastNode.isFrozen) {
      final k = lastNode.kanji;
      final currentIdx = lastNode.currentStrokeIndex;
      if (k.svgPaths.isEmpty || currentIdx >= k.svgPaths.length) return;

      final pathString = k.svgPaths[currentIdx];

      // Sincronizar normalización y cálculo de vectores usando path_drawing
      final path = parseSvgPathData(pathString);
      final metrics = path.computeMetrics().toList();
      if (metrics.isEmpty || points.length < 2) return;

      final metric = metrics.first;
      final startTangent = metric.getTangentForOffset(0);
      final endTangent = metric.getTangentForOffset(metric.length);

      if (startTangent != null && endTangent != null) {
        final svgStart = startTangent.position;
        final svgEnd = endTangent.position;
        final svgVector = svgEnd - svgStart;

        final userStart = points.first;
        final userEnd = points.last;
        final userVector = userEnd - userStart;

        final angleSvg = svgVector.direction;
        final angleUser = userVector.direction;

        double diff = (angleUser - angleSvg).abs();
        if (diff > pi) {
          diff = 2 * pi - diff;
        }

        final diffDegrees = diff * 180 / pi;
        final tolerance = ref.read(settingsProvider).writeTolerance;

        if (diffDegrees <= tolerance) {
          // Snap exitoso trazo
          final newStrokes = List<List<Offset>>.from(lastNode.userStrokes)
            ..add(points);
          final nextIdx = currentIdx + 1;

          if (nextIdx >= k.svgPaths.length) {
            // Kanji caligrafiado al 100%
            if (ref.read(settingsProvider).enableAudio) {
              AudioFeedbackService.instance.playReading(k.character);
            }
            await _repo.updateKanjiSrs(
              k.character,
              (k.srsScore + 0.5).clamp(0.0, 10.0),
              0,
            );
            await _updateCharacterProgress(GameCharacter(kanji: k), true, 1000);
            _recordTelemetry(true, 1000);

            _triggerReportNode('CALIGRAFÍA EXITOSA', k.svgPaths.length, 0);
          } else {
            // Siguiente trazo
            final updatedNode = StrokeValidationNode(
              id: lastNode.id,
              timestamp: lastNode.timestamp,
              kanji: k,
              userStrokes: newStrokes,
              currentStrokeIndex: nextIdx,
            );
            _updateNodeInTimeline(updatedNode);
          }
        } else {
          // Error de ángulo de trazo
          triggerNeonError();
          _handleHardcoreFailure();
          _recordTelemetry(false, 500);

          // Force repaint with flash error (simply empty points to redraw)
          final updatedNode = StrokeValidationNode(
            id: lastNode.id,
            timestamp: lastNode.timestamp,
            kanji: k,
            userStrokes: lastNode.userStrokes,
            currentStrokeIndex: currentIdx,
          );
          _updateNodeInTimeline(updatedNode);
        }
      }
    }
  }

  void _triggerReportNode(String title, int total, int errors) {
    _deathClockTimer?.cancel();
    _arcadeGameTimer?.cancel();

    final activeSession = state.activeSession;
    final now = DateTime.now();

    final reportNode = ExerciseReportNode(
      id: 'report_${now.millisecondsSinceEpoch}',
      timestamp: now,
      title: title,
      totalQuestions: total,
      successes: total - errors,
      errors: errors,
      avgMs: state.avgMs,
      maxMs: 3000,
      hitRate: total > 0 ? (total - errors) / total : 0.0,
    );

    // Reemplaza o añade el nodo de reporte y congela
    final updatedNodes = List<FeedNode>.from(activeSession.nodes);
    if (updatedNodes.isNotEmpty) {
      final lastIdx = updatedNodes.length - 1;
      updatedNodes[lastIdx] = updatedNodes[lastIdx].freeze();
    }
    updatedNodes.add(reportNode);

    state = state.copyWith(
      history: state.history.map((s) {
        if (s.id == state.activeSessionId) {
          return s.copyWith(nodes: updatedNodes);
        }
        return s;
      }).toList(),
    );
  }

  // Utilidades internas
  void _updateNodeInTimeline(FeedNode node) {
    state = state.copyWith(
      history: state.history.map((s) {
        if (s.id == state.activeSessionId) {
          final idx = s.nodes.indexWhere((n) => n.id == node.id);
          if (idx != -1) {
            final updatedList = List<FeedNode>.from(s.nodes);
            updatedList[idx] = node;
            return s.copyWith(nodes: updatedList);
          }
        }
        return s;
      }).toList(),
    );
  }

  Future<void> _penalizeCharacter(String character, bool isKanji) async {
    HapticFeedback.vibrate();
    if (isKanji) {
      // We read from repository
      final kanjis = await _repo.getAllKanjis();
      final target = kanjis.where((k) => k.character == character).firstOrNull;
      if (target != null) {
        final score = (target.srsScore - 0.25).clamp(0.0, 10.0);
        await _repo.updateKanjiSrs(
          character,
          score,
          target.consecutiveFails + 1,
        );
      }
    } else {
      final kana = await _repo.getKanaByCharacter(character);
      if (kana != null) {
        final blob = [...kana.historyBlob, 0]; // 0 representing fail
        final stats = TierCalculator.calculateStats(blob);
        await _repo.updateKanaProgress(
          character: character,
          historyBlob: blob,
          hitRate: stats.hitRate,
          averageMs: stats.avgMs,
        );
      }
    }
  }

  Future<void> _updateCharacterProgress(
    GameCharacter char,
    bool success,
    int responseMs,
  ) async {
    final encoded = TierCalculator.encodeAttempt(
      isCorrect: success,
      isDoubleStroke: false,
      responseMs: responseMs,
    );
    var blob = [...char.historyBlob, encoded];
    if (blob.length > 50) blob = blob.sublist(blob.length - 50);
    final stats = TierCalculator.calculateStats(blob);

    if (char.isKana) {
      await _repo.updateKanaProgress(
        character: char.character,
        historyBlob: blob,
        hitRate: stats.hitRate,
        averageMs: stats.avgMs,
      );
    } else {
      await _repo.updateKanjiProgress(
        character: char.character,
        historyBlob: blob,
        hitRate: stats.hitRate,
        averageMs: stats.avgMs,
      );
    }
  }

  void _recordTelemetry(bool success, int ms) {
    final newStreak = success ? state.streak + 1 : 0;
    final hit = success ? 1.0 : 0.0;

    state = state.copyWith(
      streak: newStreak,
      avgMs: state.avgMs == 0 ? ms : (state.avgMs * 0.8 + ms * 0.2).toInt(),
      hitRate: state.hitRate == 0.0 ? hit : (state.hitRate * 0.9 + hit * 0.1),
    );
  }

  // Seeding parsers
  KanaModel _toKanaModel(KanaEntity e) => KanaModel(
    character: e.character,
    romaji: e.romaji,
    isKatakana: e.isKatakana,
    linkedKanaCharacter: e.linkedKanaCharacter,
    isDakutenOrHandakuten: e.isDakutenOrHandakuten,
    isUnlocked: e.isUnlocked,
    historyBlob: List<int>.from(e.historyBlob),
    svgPaths: List<String>.from(e.svgPaths),
    currentHitRate: e.currentHitRate,
    averageMs: e.averageMs,
  );

  KanjiModel _toKanjiModel(KanjiEntity e) => KanjiModel(
    character: e.character,
    onyomi: e.onyomi,
    kunyomi: e.kunyomi,
    meanings: e.meanings,
    radicals: e.radicals,
    radical: e.radical,
    isUnlocked: e.isUnlocked,
    historyBlob: List<int>.from(e.historyBlob),
    svgPaths: List<String>.from(e.svgPaths),
    currentHitRate: e.currentHitRate,
    averageMs: e.averageMs,
    srsScore: e.srsScore,
    consecutiveFails: e.consecutiveFails,
    jlpt: e.jlpt,
    joyo: e.joyo,
    isJinmeiyo: e.isJinmeiyo,
    kanjidicTranslations: List<String>.from(e.kanjidicTranslations),
  );
}

final timelineProvider =
    StateNotifierProvider<TimelineNotifier, SessionTimelineState>(
      (ref) => TimelineNotifier(ref),
    );
