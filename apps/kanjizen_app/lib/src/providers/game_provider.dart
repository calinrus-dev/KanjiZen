import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kz_data/kz_data.dart';
import 'package:kz_domain/kz_domain.dart';

/// Estado global del juego en sesión.
class GameState {
  const GameState({
    this.kanas = const [],
    this.currentKana,
    this.inputText = '',
    this.inputState = InputState.neutral,
    this.streak = 0,
    this.errors = 0,
    this.avgMs = 0,
    this.hitRate = 0.0,
    this.lastResponseMs = 0,
    this.isLoading = true,
    this.mode = GameMode.hiragana,
  });

  final List<KanaModel> kanas;
  final KanaModel? currentKana;
  final String inputText;
  final InputState inputState;
  final int streak;
  final int errors;
  final int avgMs;
  final double hitRate;
  final int lastResponseMs;
  final bool isLoading;
  final GameMode mode;

  GameState copyWith({
    List<KanaModel>? kanas,
    KanaModel? currentKana,
    String? inputText,
    InputState? inputState,
    int? streak,
    int? errors,
    int? avgMs,
    double? hitRate,
    int? lastResponseMs,
    bool? isLoading,
    GameMode? mode,
  }) => GameState(
    kanas: kanas ?? this.kanas,
    currentKana: currentKana ?? this.currentKana,
    inputText: inputText ?? this.inputText,
    inputState: inputState ?? this.inputState,
    streak: streak ?? this.streak,
    errors: errors ?? this.errors,
    avgMs: avgMs ?? this.avgMs,
    hitRate: hitRate ?? this.hitRate,
    lastResponseMs: lastResponseMs ?? this.lastResponseMs,
    isLoading: isLoading ?? this.isLoading,
    mode: mode ?? this.mode,
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
  GameNotifier() : super(const GameState());

  final _validator = InputValidator();
  final _repo = CharacterRepository.instance;
  int? _questionStartMs;

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

    if (kanas.isEmpty) {
      state = state.copyWith(isLoading: false);
      return;
    }

    kanas.shuffle();
    _questionStartMs = DateTime.now().millisecondsSinceEpoch;
    state = state.copyWith(
      kanas: kanas,
      currentKana: kanas.first,
      isLoading: false,
      inputText: '',
      inputState: InputState.neutral,
    );
  }

  void onInputChanged(String input) {
    final current = state.currentKana;
    if (current == null) return;

    final lower = input.toLowerCase().trim();
    final result = _validator.evaluateStep(lower, current.romaji);

    if (result == InputState.success) {
      _handleSuccess(current);
    } else {
      state = state.copyWith(inputText: lower, inputState: result);
    }
  }

  void _handleSuccess(KanaModel kana) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final responseMs = _questionStartMs != null ? now - _questionStartMs! : 500;

    final encoded = TierCalculator.encodeAttempt(
      isCorrect: true,
      isDoubleStroke: false,
      responseMs: responseMs,
    );
    var blob = [...kana.historyBlob, encoded];
    if (blob.length > 50) blob = blob.sublist(blob.length - 50);

    final stats = TierCalculator.calculateStats(blob);
    final updated = kana.copyWith(
      historyBlob: blob,
      currentHitRate: stats.hitRate,
      averageMs: stats.avgMs,
    );

    // Persistir en background
    _repo.updateKanaProgress(
      character: kana.character,
      historyBlob: blob,
      hitRate: stats.hitRate,
      averageMs: stats.avgMs,
    );

    final updatedKanas = state.kanas
        .map((k) => k.character == kana.character ? updated : k)
        .toList();
    final next = _pickNext(updatedKanas, kana.character);

    _questionStartMs = DateTime.now().millisecondsSinceEpoch;

    // Calcular hitRate global de sesión
    final totalHits = state.streak + 1;
    final totalAttempts = totalHits + state.errors;
    final sessionHitRate = totalAttempts > 0 ? totalHits / totalAttempts : 0.0;

    state = state.copyWith(
      kanas: updatedKanas,
      currentKana: next,
      inputText: '',
      inputState: InputState.neutral,
      streak: state.streak + 1,
      avgMs: responseMs,
      hitRate: sessionHitRate,
      lastResponseMs: responseMs,
    );
  }

  void recordError(KanaModel kana, int responseMs) {
    final encoded = TierCalculator.encodeAttempt(
      isCorrect: false,
      isDoubleStroke: false,
      responseMs: responseMs,
    );
    var blob = [...kana.historyBlob, encoded];
    if (blob.length > 50) blob = blob.sublist(blob.length - 50);
    final stats = TierCalculator.calculateStats(blob);
    final updated = kana.copyWith(
      historyBlob: blob,
      currentHitRate: stats.hitRate,
      averageMs: stats.avgMs,
    );
    final updatedKanas = state.kanas
        .map((k) => k.character == kana.character ? updated : k)
        .toList();

    final totalAttempts = state.streak + state.errors + 1;
    final sessionHitRate = totalAttempts > 0
        ? state.streak / totalAttempts
        : 0.0;

    state = state.copyWith(
      kanas: updatedKanas,
      inputState: InputState.error,
      streak: 0,
      errors: state.errors + 1,
      hitRate: sessionHitRate,
    );
  }

  void clearInput() {
    state = state.copyWith(inputText: '', inputState: InputState.neutral);
  }

  // ─── SRS: selección ponderada ─────────────────────────────────────────────
  KanaModel _pickNext(List<KanaModel> pool, String excludeChar) {
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
}

final gameProvider = StateNotifierProvider<GameNotifier, GameState>(
  (_) => GameNotifier(),
);
