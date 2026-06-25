enum KanjiPhase {
  /// 0-2.99: Muestra Kanji + Romaji/Hiragana. Usuario teclea la lectura.
  initial,

  /// 3-4.99: Solo Kanji, sin pistas. Usuario teclea.
  withdrawal,

  /// 5-6.99: Muestra Concepto, requiere Kanji de memoria. Usuario teclea.
  inversion,

  /// 7-10: Discriminatorio relacional. Botones de opciones.
  discriminatory,
}

class KanjiPhaseCalculator {
  /// Devuelve la fase actual del Kanji basado en su puntuación SRS (0.0 a 10.0).
  static KanjiPhase getPhase(double srsScore) {
    if (srsScore < 3.0) return KanjiPhase.initial;
    if (srsScore < 5.0) return KanjiPhase.withdrawal;
    if (srsScore < 7.0) return KanjiPhase.inversion;
    return KanjiPhase.discriminatory;
  }

  /// Calcula la penalización según la fase actual.
  static double getPenaltyForPhase(KanjiPhase phase) {
    switch (phase) {
      case KanjiPhase.initial:
        return 0.1; // Penalización leve en etapa inicial
      case KanjiPhase.withdrawal:
        return 0.25; // Retirada de pistas, -0.25 por error
      case KanjiPhase.inversion:
        return 0.5; // Degradación más fuerte en inversión
      case KanjiPhase.discriminatory:
        return 0.1; // Error discriminatorio
    }
  }

  /// Aplica el castigo o premio al score.
  static double applyScore(double currentScore, bool isSuccess) {
    if (isSuccess) {
      return (currentScore + 0.5).clamp(0.0, 10.0);
    } else {
      final phase = getPhase(currentScore);
      final penalty = getPenaltyForPhase(phase);
      return (currentScore - penalty).clamp(0.0, 10.0);
    }
  }
}
