import 'package:kz_core/kz_core.dart';
import 'package:kz_domain/src/models/kana_model.dart';

/// Calculador de Tiers según las métricas de dominio.
abstract final class TierCalculator {
  static KanaTier calculate({
    required double hitRate,
    required int avgMs,
    required bool isUnlocked,
  }) {
    if (!isUnlocked) return KanaTier.e;
    if (hitRate >= KzConstants.tierSHitRate &&
        avgMs > 0 &&
        avgMs < KzConstants.tierSMaxMs)
      return KanaTier.s;
    if (hitRate >= KzConstants.tierAHitRate &&
        avgMs > 0 &&
        avgMs < KzConstants.tierAMaxMs)
      return KanaTier.a;
    if (hitRate >= KzConstants.tierBHitRate &&
        avgMs > 0 &&
        avgMs < KzConstants.tierBMaxMs)
      return KanaTier.b;
    if (hitRate >= KzConstants.tierCHitRate &&
        avgMs > 0 &&
        avgMs < KzConstants.tierCMaxMs)
      return KanaTier.c;
    if (hitRate >= KzConstants.tierDHitRate &&
        avgMs > 0 &&
        avgMs < KzConstants.tierDMaxMs)
      return KanaTier.d;
    return KanaTier.e;
  }

  static int effectiveTime({
    required int totalMs,
    required int realKeystrokes,
  }) {
    if (realKeystrokes <= 0) return totalMs;
    return (totalMs / realKeystrokes).round();
  }

  static int encodeAttempt({
    required bool isCorrect,
    required bool isDoubleStroke,
    required int responseMs,
  }) {
    int value = responseMs.clamp(0, (1 << 30) - 1) << 2;
    if (isDoubleStroke) value |= 0x02;
    if (isCorrect) value |= 0x01;
    return value;
  }

  static ({bool isCorrect, bool isDoubleStroke, int responseMs}) decodeAttempt(
    int encoded,
  ) {
    return (
      isCorrect: (encoded & 0x01) == 1,
      isDoubleStroke: (encoded & 0x02) == 2,
      responseMs: encoded >> 2,
    );
  }

  static ({double hitRate, int avgMs}) calculateStats(List<int> historyBlob) {
    if (historyBlob.isEmpty) return (hitRate: 0.0, avgMs: 0);
    int hits = 0;
    int totalMs = 0;
    for (final e in historyBlob) {
      final d = decodeAttempt(e);
      if (d.isCorrect) hits++;
      totalMs += d.responseMs;
    }
    return (
      hitRate: hits / historyBlob.length,
      avgMs: (totalMs / historyBlob.length).round(),
    );
  }
}
