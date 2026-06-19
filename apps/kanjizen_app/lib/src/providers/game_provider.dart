import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kz_data/kz_data.dart';
import 'package:kz_domain/kz_domain.dart';

/// Envoltorio para unificar Kanas y Kanjis en la secuencia.
class GameCharacter {
  const GameCharacter({this.kana, this.kanji});
  final KanaModel? kana;
  final KanjiModel? kanji;

  bool get isKana => kana != null;
  String get character => kana?.character ?? kanji!.character;
  String get romaji => kana?.romaji ?? (kanji!.kunyomi.isNotEmpty ? kanji!.kunyomi.first : (kanji!.onyomi.isNotEmpty ? kanji!.onyomi.first : ''));
  List<int> get historyBlob => kana?.historyBlob ?? kanji!.historyBlob;
  double get currentHitRate => kana?.currentHitRate ?? kanji!.currentHitRate;
  int get averageMs => kana?.averageMs ?? kanji!.averageMs;

  GameCharacter copyWithStats(List<int> blob, double hitRate, int avgMs) {
    if (isKana) {
      return GameCharacter(kana: kana!.copyWith(historyBlob: blob, currentHitRate: hitRate, averageMs: avgMs));
    } else {
      return GameCharacter(kanji: kanji!.copyWith(historyBlob: blob, currentHitRate: hitRate, averageMs: avgMs));
    }
  }
}

/// Estado global del juego en sesión.
class GameState {
  const GameState({
    this.kanas = const [],
    this.kanjis = const [],
    this.currentSequence = const [],
    this.currentSequenceIndex = 0,
    this.inputText = '',
    this.inputState = InputState.neutral,
    this.streak = 0,
    this.errors = 0,
    this.avgMs = 0,
    this.hitRate = 0.0,
    this.lastResponseMs = 0,
    this.isLoading = true,
    this.mode = GameMode.hiragana,
    this.timeAttackRemainingMs,
  });

  final List<KanaModel> kanas;
  final List<KanjiModel> kanjis;
  final List<GameCharacter> currentSequence;
  final int currentSequenceIndex;
  final String inputText;
  final InputState inputState;
  final int streak;
  final int errors;
  final int avgMs;
  final double hitRate;
  final int lastResponseMs;
  final bool isLoading;
  final GameMode mode;
  final int? timeAttackRemainingMs;

  GameState copyWith({
    List<KanaModel>? kanas,
    List<KanjiModel>? kanjis,
    List<GameCharacter>? currentSequence,
    int? currentSequenceIndex,
    String? inputText,
    InputState? inputState,
    int? streak,
    int? errors,
    int? avgMs,
    double? hitRate,
    int? lastResponseMs,
    bool? isLoading,
    GameMode? mode,
    int? timeAttackRemainingMs,
  }) => GameState(
    kanas: kanas ?? this.kanas,
    kanjis: kanjis ?? this.kanjis,
    currentSequence: currentSequence ?? this.currentSequence,
    currentSequenceIndex: currentSequenceIndex ?? this.currentSequenceIndex,
    inputText: inputText ?? this.inputText,
    inputState: inputState ?? this.inputState,
    streak: streak ?? this.streak,
    errors: errors ?? this.errors,
    avgMs: avgMs ?? this.avgMs,
    hitRate: hitRate ?? this.hitRate,
    lastResponseMs: lastResponseMs ?? this.lastResponseMs,
    isLoading: isLoading ?? this.isLoading,
    mode: mode ?? this.mode,
    timeAttackRemainingMs: timeAttackRemainingMs ?? this.timeAttackRemainingMs,
  );
}

enum GameMode { hiragana, katakana, mixed }

extension GameModeLabel on GameMode {
  String get label => switch (this) {
    GameMode.hiragana => 'HIRAGANA',
    GameMode.katakana => 'KATAKANA',
    GameMode.mixed => 'MIXTO',
  };
}

/// Provider central del juego — orquesta SRS, validación y persistencia.
class GameNotifier extends StateNotifier<GameState> {
  GameNotifier(this.ref) : super(const GameState());

  final Ref ref;

  final _validator = InputValidator();
  final _repo = CharacterRepository.instance;
  int? _questionStartMs;
  Timer? _timer;

  Timer? _timeAttackTimer;

  @override
  void dispose() {
    _timer?.cancel();
    _timeAttackTimer?.cancel();
    super.dispose();
  }

  void startTimeAttack(int minutes) {
    _timeAttackTimer?.cancel();
    state = state.copyWith(timeAttackRemainingMs: minutes * 60 * 1000);
    _timeAttackTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      final current = state.timeAttackRemainingMs ?? 0;
      if (current <= 0) {
        t.cancel();
        state = state.copyWith(timeAttackRemainingMs: 0, inputState: InputState.neutral);
        // La UI debería reaccionar a timeAttackRemainingMs == 0 para bloquear y mostrar el Modal de CPM
      } else {
        state = state.copyWith(timeAttackRemainingMs: current - 1000);
      }
    });
  }

  void _startTimer() {
    _timer?.cancel();
    final settings = ref.read(settingsProvider);
    double limit = 0.0;
    switch (settings.deathClock) {
      case DeathClock.off: limit = 0.0; break;
      case DeathClock.s5: limit = 5.0; break;
      case DeathClock.s3: limit = 3.0; break;
      case DeathClock.s1_5: limit = 1.5; break;
    }
    
    if (limit > 0) {
      _timer = Timer(Duration(milliseconds: (limit * 1000).toInt()), () {
        if (!mounted || state.currentSequence.isEmpty) return;
        final current = state.currentSequence[state.currentSequenceIndex];
        recordError(current, (limit * 1000).toInt());
        _startTimer(); // Reiniciar para el siguiente intento
      });
    }
  }

  Future<void> initialize(GameMode mode) async {
    state = state.copyWith(isLoading: true, mode: mode);

    // Asegurar que la BD esté sembrada
    await DatabaseInitializerService.seedInBackground();

    final entities = await _repo.getAllKanas();
    final kanas = entities
        .where((e) => e.isUnlocked)
        .where(
          (e) => switch (mode) {
            GameMode.hiragana => !e.isKatakana,
            GameMode.katakana => e.isKatakana,
            GameMode.mixed => true,
          },
        )
        .map(_toModel)
        .toList();

    final kanjiEntities = await _repo.getAllKanjis();
    final kanjis = kanjiEntities.map<KanjiModel>(_toKanjiModel).toList();

    if (kanas.isEmpty) {
      state = state.copyWith(isLoading: false, kanjis: kanjis);
      return;
    }

    _questionStartMs = DateTime.now().millisecondsSinceEpoch;
    state = state.copyWith(
      kanas: kanas,
      kanjis: kanjis,
      currentSequence: _generateNextSequence(kanas, kanjis, null),
      currentSequenceIndex: 0,
      isLoading: false,
      inputText: '',
      inputState: InputState.neutral,
    );
    _startTimer();
  }

  /// Inicializa una partida restringida a los parámetros de un Nivel de Campaña.
  Future<void> initializeCampaign(KanaLevelModel level, {int? timeLimit}) async {
    state = state.copyWith(isLoading: true, mode: GameMode.mixed); // El modo visual dependerá de las Kanas

    final entities = await _repo.getAllKanas();
    final kanas = entities
        .where((e) => level.targetCharacters.contains(e.character))
        .map(_toModel)
        .toList();

    if (kanas.isEmpty) {
      state = state.copyWith(isLoading: false);
      return;
    }

    kanas.shuffle();
    _questionStartMs = DateTime.now().millisecondsSinceEpoch;
    state = state.copyWith(
      kanas: kanas,
      kanjis: [], // En modo campaña Kana no hay Kanjis
      currentSequence: _generateNextSequence(kanas, [], null),
      currentSequenceIndex: 0,
      isLoading: false,
      inputText: '',
      inputState: InputState.neutral,
    );
    
    // Configurar el reloj de la muerte si aplica
    if (timeLimit != null && timeLimit > 0) {
      _timer?.cancel();
      _timer = Timer(Duration(seconds: timeLimit), () {
        if (!mounted || state.currentSequence.isEmpty) return;
        final current = state.currentSequence[state.currentSequenceIndex];
        recordError(current, timeLimit * 1000);
        _startTimer();
      });
    } else {
      _startTimer(); // Fallback normal
    }
  }

  void onInputChanged(String input) {
    if (state.currentSequence.isEmpty) return;
    final current = state.currentSequence[state.currentSequenceIndex];

    final lower = input.toLowerCase().trim();
    final result = _validator.evaluateStep(lower, current.romaji);

    if (result == InputState.success) {
      _handleSuccess(current);
    } else if (result == InputState.error) {
      final now = DateTime.now().millisecondsSinceEpoch;
      final responseMs = _questionStartMs != null ? now - _questionStartMs! : 500;
      recordError(current, responseMs);
    } else {
      state = state.copyWith(inputText: lower, inputState: result);
    }
  }

  void _handleSuccess(GameCharacter char) {
    // 🔊 Audio Feedback Inmediato respetando ajustes
    if (ref.read(settingsProvider).enableAudio) {
      AudioFeedbackService.instance.playReading(char.character);
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    final rawMs = _questionStartMs != null ? now - _questionStartMs! : 500;
    
    // Compensación Cognitiva
    final responseMs = TierCalculator.calculateEffectiveMs(
      rawMs: rawMs.toDouble(),
      character: char.character,
      isKanji: !char.isKana,
    ).toInt();

    final encoded = TierCalculator.encodeAttempt(
      isCorrect: true,
      isDoubleStroke: false,
      responseMs: responseMs,
    );
    var blob = [...char.historyBlob, encoded];
    if (blob.length > 50) blob = blob.sublist(blob.length - 50);

    final stats = TierCalculator.calculateStats(blob);
    final updatedChar = char.copyWithStats(blob, stats.hitRate, stats.avgMs);

    // Persistir en background
    if (char.isKana) {
      _repo.updateKanaProgress(
        character: char.character,
        historyBlob: blob,
        hitRate: stats.hitRate,
        averageMs: stats.avgMs,
      );
    } else {
      _repo.updateKanjiProgress(
        character: char.character,
        historyBlob: blob,
        hitRate: stats.hitRate,
        averageMs: stats.avgMs,
      );
    }

    List<GameCharacter> nextSeq = List.from(state.currentSequence);
    nextSeq[state.currentSequenceIndex] = updatedChar;
    int nextIdx = state.currentSequenceIndex + 1;

    if (nextIdx >= state.currentSequence.length) {
      nextSeq = _generateNextSequence(state.kanas, state.kanjis, updatedChar);
      nextIdx = 0;
    }

    _questionStartMs = DateTime.now().millisecondsSinceEpoch;

    // Calcular hitRate global de sesión
    final totalHits = state.streak + 1;
    final totalAttempts = totalHits + state.errors;
    final sessionHitRate = totalAttempts > 0 ? totalHits / totalAttempts : 0.0;

    state = state.copyWith(
      currentSequence: nextSeq,
      currentSequenceIndex: nextIdx,
      inputText: '',
      inputState: InputState.neutral,
      streak: state.streak + 1,
      avgMs: responseMs,
      hitRate: sessionHitRate,
      lastResponseMs: responseMs,
    );
    _startTimer();
  }

  void recordError(GameCharacter char, int responseMs) {
    final encoded = TierCalculator.encodeAttempt(
      isCorrect: false,
      isDoubleStroke: false,
      responseMs: responseMs,
    );
    var blob = [...char.historyBlob, encoded];
    if (blob.length > 50) blob = blob.sublist(blob.length - 50);
    final stats = TierCalculator.calculateStats(blob);
    final updatedChar = char.copyWithStats(blob, stats.hitRate, stats.avgMs);

    final totalAttempts = state.streak + state.errors + 1;
    final sessionHitRate = totalAttempts > 0
        ? state.streak / totalAttempts
        : 0.0;

    List<GameCharacter> nextSeq = List.from(state.currentSequence);
    nextSeq[state.currentSequenceIndex] = updatedChar;

    state = state.copyWith(
      currentSequence: nextSeq,
      inputState: InputState.error,
      inputText: '', // Limpiamos el texto al instante
      errors: state.errors + 1,
      streak: 0,
      hitRate: sessionHitRate,
      lastResponseMs: responseMs,
    );

    // Retraso exacto de 150ms para regresar a neutral y permitir fluidez
    Future.delayed(const Duration(milliseconds: 150), () {
      if (!mounted) return;
      if (state.inputState == InputState.error) {
        state = state.copyWith(inputState: InputState.neutral, inputText: '');
      }
    });

    // Si la destrucción está activada, saltamos al siguiente carácter automáticamente tras el error.
    if (ref.read(settingsProvider).skipOnError) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (!mounted) return;
        _advanceSequence(responseMs);
      });
    }
  }

  void _advanceSequence(int responseMs) {
    List<GameCharacter> nextSeq = List.from(state.currentSequence);
    int nextIdx = state.currentSequenceIndex + 1;

    if (nextIdx >= state.currentSequence.length) {
      nextSeq = _generateNextSequence(state.kanas, state.kanjis, null);
      nextIdx = 0;
    }

    _questionStartMs = DateTime.now().millisecondsSinceEpoch;

    state = state.copyWith(
      currentSequence: nextSeq,
      currentSequenceIndex: nextIdx,
      inputText: '',
      inputState: InputState.neutral,
    );
    _startTimer();
  }

  void clearInput() {
    state = state.copyWith(inputText: '', inputState: InputState.neutral);
  }

  // ─── SRS: selección ponderada 60% Kanas / 40% Kanjis ─────────────────────────
  List<GameCharacter> _generateNextSequence(List<KanaModel> kanas, List<KanjiModel> kanjis, GameCharacter? lastChar) {
    final settings = ref.read(settingsProvider);
    final sequenceLength = settings.trainingMode == TrainingMode.words ? 4 : 1;
    List<GameCharacter> seq = [];
    
    final validKanjis = kanjis.where((k) => k.isUnlocked && k.srsScore >= 3.0).toList();
    
    for (int i = 0; i < sequenceLength; i++) {
      // 60/40 logic: decide if we inject kana or kanji
      final rand = DateTime.now().microsecondsSinceEpoch % 100;
      final pickKanji = validKanjis.isNotEmpty && rand < 40;
      
      if (pickKanji) {
        final k = _pickNextKanji(validKanjis, lastChar?.character ?? '');
        seq.add(GameCharacter(kanji: k));
      } else {
        final k = _pickNextKana(kanas, lastChar?.character ?? '');
        seq.add(GameCharacter(kana: k));
      }
    }
    
    return seq.isNotEmpty ? seq : [GameCharacter(kana: kanas.first)]; // Fallback
  }

  KanaModel _pickNextKana(List<KanaModel> pool, String excludeChar) {
    final candidates = pool.where((k) => k.character != excludeChar).toList();
    if (candidates.isEmpty) return pool.first;

    final totalWeight = candidates.fold<double>(
      0,
      (sum, k) => sum + (1.0 - k.currentHitRate).clamp(0.1, 1.0),
    );
    var rand =
        (totalWeight * DateTime.now().microsecondsSinceEpoch % 1000) /
        1000 *
        totalWeight;

    for (final k in candidates) {
      rand -= (1.0 - k.currentHitRate).clamp(0.1, 1.0);
      if (rand <= 0) return k;
    }
    return candidates.last;
  }

  KanjiModel _pickNextKanji(List<KanjiModel> pool, String excludeChar) {
    final candidates = pool.where((k) => k.character != excludeChar).toList();
    if (candidates.isEmpty) return pool.first;

    final totalWeight = candidates.fold<double>(
      0,
      (sum, k) => sum + (1.0 - k.currentHitRate).clamp(0.1, 1.0),
    );
    var rand = (totalWeight * DateTime.now().microsecondsSinceEpoch % 1000) / 1000 * totalWeight;

    for (final k in candidates) {
      rand -= (1.0 - k.currentHitRate).clamp(0.1, 1.0);
      if (rand <= 0) return k;
    }
    return candidates.last;
  }

  KanaModel _toModel(KanaEntity e) {
    return KanaModel(
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
  }

  KanjiModel _toKanjiModel(KanjiEntity e) {
    return KanjiModel(
      character: e.character,
      onyomi: e.onyomi,
      kunyomi: e.kunyomi,
      meanings: e.meanings,
      radicals: e.radicals,
      isUnlocked: e.isUnlocked,
      historyBlob: List<int>.from(e.historyBlob),
      svgPaths: List<String>.from(e.svgPaths),
      currentHitRate: e.currentHitRate,
      averageMs: e.averageMs,
    );
  }
}

final gameProvider = StateNotifierProvider<GameNotifier, GameState>(
  (ref) => GameNotifier(ref),
);
