/// Constantes globales del dominio KanjiZen.
abstract final class KzConstants {
  // ─── SRS ──────────────────────────────────────────────────────────────────
  /// Máximo de intentos almacenados en historyBlob.
  static const int maxHistoryBlob = 50;

  /// Score de kanji para introducir uno nuevo en el pool.
  static const double kanjiPoolThreshold = 7.0;

  // ─── Tiers ────────────────────────────────────────────────────────────────
  static const double tierDHitRate = 0.60;
  static const double tierCHitRate = 0.75;
  static const double tierBHitRate = 0.85;
  static const double tierAHitRate = 0.92;
  static const double tierSHitRate = 0.98;

  static const int tierDMaxMs = 2500;
  static const int tierCMaxMs = 1800;
  static const int tierBMaxMs = 1200;
  static const int tierAMaxMs = 800;
  static const int tierSMaxMs = 500;

  // ─── Unlock conditions ───────────────────────────────────────────────────
  static const int tierCUnlockKanas = 23;
  static const int tierBUnlockKanas = 46;

  // ─── Inventory ────────────────────────────────────────────────────────────
  /// Número de distractores en Fase 3 Kanji.
  static const int distractorCount =
      6; // 1 correcto + 2 gemelos + 2 similares + 1 trampa

  // ─── Seeding ─────────────────────────────────────────────────────────────
  /// Tamaño de bloque para Isar.putAllSync() durante el seeding.
  static const int seedBatchSize = 1000;

  // ─── ActivityGraph ────────────────────────────────────────────────────────
  static const int activityGraphRows = 7;
  static const int activityGraphCols = 52;
  static const int activityGraphDays = 365;
}
