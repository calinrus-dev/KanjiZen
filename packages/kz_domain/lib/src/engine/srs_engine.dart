import 'dart:math';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:kz_core/kz_core.dart';
import 'package:kz_domain/src/models/kana_model.dart';
import 'package:kz_domain/src/engine/tier_calculator.dart';

part 'srs_engine.g.dart';

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
/// Probabilidad ∝ (1.0 - currentHitRate): los más débiles aparecen más.
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
    state = state.copyWith(
      pool: currentPool,
      currentIndex: nextIdx,
    );
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
    // Deduplicar manteniendo orden
    final seen = <String>{};
    return weighted.where((k) => seen.add(k.character)).toList();
  }
}
