import 'dart:math';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:kz_core/kz_core.dart';
import 'package:kz_domain/src/models/kana_model.dart';
import 'package:kz_domain/src/engine/tier_calculator.dart';

part 'srs_engine.g.dart';

/// Representa el estado SM2 de un carácter en la sesión o base de datos.
class Sm2State {
  final int repetitions;
  final double easeFactor;
  final int interval;

  const Sm2State({
    this.repetitions = 0,
    this.easeFactor = 2.5,
    this.interval = 1,
  });

  Sm2State copyWith({
    int? repetitions,
    double? easeFactor,
    int? interval,
  }) => Sm2State(
    repetitions: repetitions ?? this.repetitions,
    easeFactor: easeFactor ?? this.easeFactor,
    interval: interval ?? this.interval,
  );
}

/// Estado inmutable del motor SRS.
class SrsState {
  const SrsState({
    required this.pool,
    required this.currentIndex,
    required this.streak,
    required this.totalErrors,
    required this.sessionStartMs,
  });

  final List<KanaModel> pool;
  final int currentIndex;
  final int streak;
  final int totalErrors;
  final int sessionStartMs;

  KanaModel? get current =>
      pool.isNotEmpty ? pool[currentIndex % pool.length] : null;

  SrsState copyWith({
    List<KanaModel>? pool,
    int? currentIndex,
    int? streak,
    int? totalErrors,
  }) => SrsState(
    pool: pool ?? this.pool,
    currentIndex: currentIndex ?? this.currentIndex,
    streak: streak ?? this.streak,
    totalErrors: totalErrors ?? this.totalErrors,
    sessionStartMs: sessionStartMs,
  );
}

/// Motor SRS — determina el siguiente carácter con probabilidad inversa.
@riverpod
class SrsEngine extends _$SrsEngine {
  final _random = Random();

  @override
  SrsState build() => const SrsState(
    pool: [],
    currentIndex: 0,
    streak: 0,
    totalErrors: 0,
    sessionStartMs: 0,
  );

  /// Inicializa el motor con la lista de kanas desbloqueados.
  void initialize(List<KanaModel> kanas) {
    if (kanas.isEmpty) return;
    final shuffled = _weightedShuffle(kanas);
    state = SrsState(
      pool: shuffled,
      currentIndex: 0,
      streak: 0,
      totalErrors: 0,
      sessionStartMs: DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// Avanza al siguiente carácter con selección ponderada.
  void advance() {
    if (state.pool.isEmpty) return;
    int nextIdx = state.currentIndex + 1;
    List<KanaModel> currentPool = state.pool;
    if (nextIdx >= currentPool.length) {
      currentPool = _weightedShuffle(currentPool);
      nextIdx = 0;
    }
    state = state.copyWith(pool: currentPool, currentIndex: nextIdx);
  }

  /// Registra un acierto y actualiza el modelo del carácter en el pool.
  void recordSuccess({required KanaModel kana, required int responseMs}) {
    final updatedPool = _updateKanaInPool(
      kana: kana,
      isCorrect: true,
      responseMs: responseMs,
    );
    state = state.copyWith(pool: updatedPool, streak: state.streak + 1);
    advance();
  }

  /// Registra un fallo.
  void recordFailure({required KanaModel kana, required int responseMs}) {
    final updatedPool = _updateKanaInPool(
      kana: kana,
      isCorrect: false,
      responseMs: responseMs,
    );
    state = state.copyWith(
      pool: updatedPool,
      streak: 0,
      totalErrors: state.totalErrors + 1,
    );
  }

  // ─── Private ──────────────────────────────────────────────────────────────

  List<KanaModel> _updateKanaInPool({
    required KanaModel kana,
    required bool isCorrect,
    required int responseMs,
  }) {
    final encoded = TierCalculator.encodeAttempt(
      isCorrect: isCorrect,
      isDoubleStroke: false,
      responseMs: responseMs,
    );
    var blob = [...kana.historyBlob, encoded];
    if (blob.length > KzConstants.maxHistoryBlob) {
      blob = blob.sublist(blob.length - KzConstants.maxHistoryBlob);
    }
    final stats = TierCalculator.calculateStats(blob);
    final updated = kana.copyWith(
      historyBlob: blob,
      currentHitRate: stats.hitRate,
      averageMs: stats.avgMs,
    );
    return state.pool
        .map((k) => k.character == kana.character ? updated : k)
        .toList();
  }

  /// Baraja con peso inverso al hitRate — más débil aparece más frecuente.
  List<KanaModel> _weightedShuffle(List<KanaModel> kanas) {
    final weighted = <KanaModel>[];
    for (final k in kanas) {
      final weight = ((1.0 - k.currentHitRate) * 10).ceil().clamp(1, 10);
      for (var i = 0; i < weight; i++) {
        weighted.add(k);
      }
    }
    weighted.shuffle(_random);
    final seen = <String>{};
    return weighted.where((k) => seen.add(k.character)).toList();
  }
}

/// Implementación del algoritmo SuperMemo-2 (SM2) y planificación de Decks
class SrsEngineHelper {
  /// Calcula la nueva racha, intervalo y factor de facilidad basándose en SM2.
  static Sm2State calculateSm2({
    required Sm2State oldState,
    required bool isCorrect,
    required int responseMs,
  }) {
    int q = 0;
    if (!isCorrect) {
      q = 0; // Blackout total
    } else {
      if (responseMs < 800) {
        q = 5; // Perfecto, sin vacilaciones
      } else if (responseMs < 1800) {
        q = 4; // Respuesta correcta tras dudar
      } else {
        q = 3; // Respuesta correcta evocada con seria dificultad
      }
    }

    int reps;
    int interval;
    double ef;

    if (q >= 3) {
      if (oldState.repetitions == 0) {
        reps = 1;
        interval = 1;
      } else if (oldState.repetitions == 1) {
        reps = 2;
        interval = 6;
      } else {
        reps = oldState.repetitions + 1;
        interval = (oldState.interval * oldState.easeFactor).round();
      }
      ef = oldState.easeFactor + (0.1 - (5 - q) * (0.08 + (5 - q) * 0.02));
    } else {
      reps = 0;
      interval = 1;
      ef = oldState.easeFactor;
    }

    return Sm2State(
      repetitions: reps,
      easeFactor: ef.clamp(1.3, 3.0),
      interval: interval.clamp(1, 999),
    );
  }

  /// Selecciona el siguiente carácter basándose en prioridad SM2 (menores reps e intervalo primero).
  static String pickNextCharacter(
    List<String> characters,
    Map<String, Sm2State> sm2States,
    String lastCharacter,
  ) {
    if (characters.isEmpty) return '';
    if (characters.length == 1) return characters.first;

    final candidates = characters.where((c) => c != lastCharacter).toList();
    final list = candidates.isNotEmpty ? candidates : characters;

    // Ordenar de forma estable: menor repetitions, luego menor interval
    final List<String> sorted = List.from(list);
    sorted.sort((a, b) {
      final stateA = sm2States[a] ?? const Sm2State();
      final stateB = sm2States[b] ?? const Sm2State();

      final cmp = stateA.repetitions.compareTo(stateB.repetitions);
      if (cmp != 0) return cmp;

      return stateA.interval.compareTo(stateB.interval);
    });

    // Seleccionar aleatoriamente entre los 2 mejores para evitar monotonía
    final poolSize = min(sorted.length, 2);
    return sorted[Random().nextInt(poolSize)];
  }
}
