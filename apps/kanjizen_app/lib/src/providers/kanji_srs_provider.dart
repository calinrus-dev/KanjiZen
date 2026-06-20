import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kz_core/kz_core.dart';
import 'package:kz_data/kz_data.dart';
import 'package:kz_domain/kz_domain.dart';
import 'package:kanjizen_app/src/providers/game_provider.dart';

final kanjiSrsProvider = StateNotifierProvider<KanjiSrsNotifier, KanjiSrsState>(
  (ref) {
    return KanjiSrsNotifier(CharacterRepository.instance);
  },
);

/// Representa la fase actual de un Kanji en el SRS.
enum KanjiSrsPhase {
  /// 0-2/10: Muestra Kanji + Romaji/Hiragana. Usuario teclea la lectura.
  initial,

  /// 3-4/10: Solo Kanji, sin pistas. Usuario teclea. Castigo -0.25 por error.
  withdrawal,

  /// 4-6/10: Muestra Concepto, requiere Kanji. Usuario teclea.
  inversion,

  /// 7-10/10: Discriminatorio. Botones en UI.
  discriminatory,
}

class KanjiSrsState {
  final bool isLoading;
  final List<KanjiModel> activePool;
  final double averagePoolScore;
  final String error;
  final EngineState engineState;
  final int streak;
  final int errors;
  final int totalMs;
  final int totalAttempts;
  final int lastResponseMs;

  const KanjiSrsState({
    this.isLoading = true,
    this.activePool = const [],
    this.averagePoolScore = 0.0,
    this.error = '',
    this.engineState = EngineState.welcome,
    this.streak = 0,
    this.errors = 0,
    this.totalMs = 0,
    this.totalAttempts = 0,
    this.lastResponseMs = 0,
  });

  double get hitRate =>
      totalAttempts > 0 ? (totalAttempts - errors) / totalAttempts : 0.0;
  int get avgMs => totalAttempts > 0 ? totalMs ~/ totalAttempts : 0;

  KanjiSrsState copyWith({
    bool? isLoading,
    List<KanjiModel>? activePool,
    double? averagePoolScore,
    String? error,
    EngineState? engineState,
    int? streak,
    int? errors,
    int? totalMs,
    int? totalAttempts,
    int? lastResponseMs,
  }) {
    return KanjiSrsState(
      isLoading: isLoading ?? this.isLoading,
      activePool: activePool ?? this.activePool,
      averagePoolScore: averagePoolScore ?? this.averagePoolScore,
      error: error ?? this.error,
      engineState: engineState ?? this.engineState,
      streak: streak ?? this.streak,
      errors: errors ?? this.errors,
      totalMs: totalMs ?? this.totalMs,
      totalAttempts: totalAttempts ?? this.totalAttempts,
      lastResponseMs: lastResponseMs ?? this.lastResponseMs,
    );
  }
}

class KanjiSrsNotifier extends StateNotifier<KanjiSrsState> {
  KanjiSrsNotifier(this._repository) : super(const KanjiSrsState()) {
    _initializePool();
  }

  final CharacterRepository _repository;

  Future<void> _initializePool() async {
    state = state.copyWith(isLoading: true);
    try {
      final kanjis = await _repository.getAllKanjis();

      var activeKanjis = kanjis.where((k) => k.isUnlocked).toList();

      double avgScore = 0.0;
      if (activeKanjis.isNotEmpty) {
        avgScore =
            activeKanjis.fold(0.0, (s, k) => s + k.srsScore) /
            activeKanjis.length;
      }

      // Regla de Homogeneidad: Si promedio >= 7.0 o el pool activo está vacío, desbloquear nuevos (hasta 5 a la vez).
      if (avgScore >= 7.0 || activeKanjis.isEmpty) {
        final locked = kanjis.where((k) => !k.isUnlocked).take(5).toList();
        for (var l in locked) {
          await _repository.unlockKanji(l.character);
          l.isUnlocked = true; // Update local memory object
        }
        // Recalculate active pool and average score from updated list
        activeKanjis = kanjis.where((k) => k.isUnlocked).toList();
        if (activeKanjis.isNotEmpty) {
          avgScore =
              activeKanjis.fold(0.0, (s, k) => s + k.srsScore) /
              activeKanjis.length;
        }
      }

      state = state.copyWith(
        isLoading: false,
        activePool: activeKanjis
            .map(
              (e) => KanjiModel(
                character: e.character,
                isUnlocked: e.isUnlocked,
                srsScore: e.srsScore,
                consecutiveFails: e.consecutiveFails,
                meanings: e.meanings,
                radicals: e.radicals,
                radical: e.radical,
                onyomi: e.onyomi,
                kunyomi: e.kunyomi,
                jlpt: e.jlpt,
                joyo: e.joyo,
                isJinmeiyo: e.isJinmeiyo,
                svgPaths: e.svgPaths,
                historyBlob: e.historyBlob,
                currentHitRate: e.currentHitRate,
                averageMs: e.averageMs,
              ),
            )
            .toList(),
        averagePoolScore: avgScore,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Determina la fase SRS actual basándose en la puntuación del Kanji.
  KanjiSrsPhase getPhaseFor(double score) {
    if (score < 3.0) return KanjiSrsPhase.initial;
    if (score < 5.0) return KanjiSrsPhase.withdrawal;
    if (score < 7.0) return KanjiSrsPhase.inversion;
    return KanjiSrsPhase.discriminatory;
  }

  /// Aplica las penalizaciones específicas según la fase.
  int? _questionStartMs;

  void pause() => state = state.copyWith(engineState: EngineState.paused);

  void resume() {
    state = state.copyWith(engineState: EngineState.playing);
    _questionStartMs = DateTime.now().millisecondsSinceEpoch;
  }

  void welcome() => state = state.copyWith(engineState: EngineState.welcome);

  /// Aplica las penalizaciones específicas según la fase.
  Future<void> recordError(KanjiModel kanji) async {
    final currentScore = kanji.srsScore;
    final phase = getPhaseFor(currentScore);

    final double penalty;
    final int fails = kanji.consecutiveFails + 1;
    if (phase == KanjiSrsPhase.withdrawal) {
      penalty = 0.25;
    } else if (phase == KanjiSrsPhase.inversion) {
      penalty = 0.5;
    } else if (phase == KanjiSrsPhase.discriminatory) {
      penalty = 0.1;
    } else {
      penalty = 0.1; // Fase inicial: penalización leve
    }

    final newScore = (currentScore - penalty).clamp(0.0, 10.0);

    final now = DateTime.now().millisecondsSinceEpoch;
    final responseMs = _questionStartMs != null
        ? now - _questionStartMs!
        : 1000;
    _questionStartMs = now;

    // Actualizar historial local
    final encoded = TierCalculator.encodeAttempt(
      isCorrect: false,
      isDoubleStroke: false,
      responseMs: responseMs,
    );
    var blob = [...kanji.historyBlob, encoded];
    if (blob.length > 50) blob = blob.sublist(blob.length - 50);
    final stats = TierCalculator.calculateStats(blob);

    await _repository.updateKanjiProgress(
      character: kanji.character,
      historyBlob: blob,
      hitRate: stats.hitRate,
      averageMs: stats.avgMs,
    );
    await _repository.updateKanjiSrs(kanji.character, newScore, fails);

    final updatedKanji =
        (state.activePool
                    .where((k) => k.character == kanji.character)
                    .firstOrNull ??
                kanji)
            .copyWith(
              srsScore: newScore,
              consecutiveFails: fails,
              historyBlob: blob,
              currentHitRate: stats.hitRate,
              averageMs: stats.avgMs,
            );

    state = state.copyWith(
      errors: state.errors + 1,
      totalAttempts: state.totalAttempts + 1,
      streak: 0,
      totalMs: state.totalMs + responseMs,
      lastResponseMs: responseMs,
    );
    await _updatePoolAfterAttempt(updatedKanji);
  }

  Future<void> recordSuccess(KanjiModel kanji) async {
    final newScore = (kanji.srsScore + 0.5).clamp(0.0, 10.0);

    final now = DateTime.now().millisecondsSinceEpoch;
    final responseMs = _questionStartMs != null
        ? now - _questionStartMs!
        : 1000;
    _questionStartMs = now;

    // Actualizar historial local
    final encoded = TierCalculator.encodeAttempt(
      isCorrect: true,
      isDoubleStroke: false,
      responseMs: responseMs,
    );
    var blob = [...kanji.historyBlob, encoded];
    if (blob.length > 50) blob = blob.sublist(blob.length - 50);
    final stats = TierCalculator.calculateStats(blob);

    await _repository.updateKanjiProgress(
      character: kanji.character,
      historyBlob: blob,
      hitRate: stats.hitRate,
      averageMs: stats.avgMs,
    );
    await _repository.updateKanjiSrs(kanji.character, newScore, 0);

    final updatedKanji =
        (state.activePool
                    .where((k) => k.character == kanji.character)
                    .firstOrNull ??
                kanji)
            .copyWith(
              srsScore: newScore,
              consecutiveFails: 0,
              historyBlob: blob,
              currentHitRate: stats.hitRate,
              averageMs: stats.avgMs,
            );

    state = state.copyWith(
      totalAttempts: state.totalAttempts + 1,
      streak: state.streak + 1,
      totalMs: state.totalMs + responseMs,
      lastResponseMs: responseMs,
    );
    await _updatePoolAfterAttempt(updatedKanji);
  }

  /// Actualiza el pool en memoria y solo recarga desde BD si se activa
  /// la regla de homogeneidad (promedio >= 7.0).
  Future<void> _updatePoolAfterAttempt(KanjiModel updatedKanji) async {
    final updatedPool = state.activePool
        .map((k) => k.character == updatedKanji.character ? updatedKanji : k)
        .toList();
    final avgScore = updatedPool.isEmpty
        ? 0.0
        : updatedPool.fold(0.0, (s, k) => s + k.srsScore) / updatedPool.length;

    state = state.copyWith(activePool: updatedPool, averagePoolScore: avgScore);

    // Solo recarga completa si se alcanza umbral (puede haber nuevos kanjis)
    if (avgScore >= KzConstants.kanjiPoolThreshold) {
      await _initializePool();
    }
  }

  /// Genera opciones trampa (Gemelos Radicales) para la Fase Discriminatoria (7-10).
  List<String> generateDiscriminatoryOptions(KanjiModel targetKanji) {
    final pool = state.activePool;
    final options = <String>{targetKanji.character};

    // 1. Gemelos Radicales (mismo radical)
    final sameRadical = pool
        .where(
          (k) =>
              k.radical == targetKanji.radical &&
              k.character != targetKanji.character,
        )
        .toList();
    sameRadical.shuffle();
    options.addAll(sameRadical.take(2).map((k) => k.character));

    // 2. Nivel de dominio similar (Mismo SRS Phase)
    final similarScore = pool
        .where(
          (k) =>
              getPhaseFor(k.srsScore) == KanjiSrsPhase.discriminatory &&
              k.character != targetKanji.character,
        )
        .toList();
    similarScore.shuffle();
    options.addAll(similarScore.take(2).map((k) => k.character));

    // 3. Relleno aleatorio / Troll si faltan
    final random = pool
        .where((k) => k.character != targetKanji.character)
        .toList();
    random.shuffle();
    while (options.length < 6 && random.isNotEmpty) {
      options.add(random.removeLast().character);
    }

    final result = options.toList();
    result.shuffle(); // Barajar la respuesta correcta
    return result;
  }
}
