import 'package:kz_domain/kz_domain.dart';

class TierCalculator {
  static KanaTier calculate({
    required double hitRate,
    required int avgMs,
    required bool isUnlocked,
  }) {
    if (!isUnlocked) return KanaTier.e;
    // Sin datos de práctica → E (evita inflar tier por avgMs=0)
    if (avgMs == 0 && hitRate == 0.0) return KanaTier.e;

    double score = 0;
    if (hitRate >= 0.95) {
      score += 50;
    } else if (hitRate >= 0.85) {
      score += 30;
    } else if (hitRate >= 0.70) {
      score += 10;
    }

    // avgMs == 0 significa sin intentos — no cuenta como "rápido"
    if (avgMs > 0 && avgMs < 800) {
      score += 50;
    } else if (avgMs > 0 && avgMs < 1200) {
      score += 30;
    } else if (avgMs > 0 && avgMs < 2000) {
      score += 10;
    }

    if (score >= 90) return KanaTier.s;
    if (score >= 70) return KanaTier.a;
    if (score >= 50) return KanaTier.b;
    if (score >= 30) return KanaTier.c;
    if (score >= 10) return KanaTier.d;
    return KanaTier.e;
  }

  static int encodeAttempt({
    required bool isCorrect,
    required bool isDoubleStroke,
    required int responseMs,
  }) {
    // 1 bit correcto (0x8000), 1 bit doubleStroke (0x4000), 14 bits ms
    int flag = isCorrect ? 0x8000 : 0;
    if (isDoubleStroke) flag |= 0x4000;
    final clampedMs = responseMs.clamp(0, 0x3FFF);
    return flag | clampedMs;
  }

  static ({double hitRate, int avgMs}) calculateStats(List<int> blob) {
    if (blob.isEmpty) return (hitRate: 0.0, avgMs: 0);
    int hits = 0;
    int totalMs = 0;
    for (var b in blob) {
      if ((b & 0x8000) != 0) hits++;
      totalMs += (b & 0x3FFF);
    }
    return (hitRate: hits / blob.length, avgMs: totalMs ~/ blob.length);
  }

  /// Calcula el nivel de dominio de E a S (Legacy).
  static String calculateTier({
    required int totalKanaUnlocked,
    required double hitRate,
    required double avgMs,
    required int historyBlobLength,
  }) {
    // Si no hay datos, E
    if (historyBlobLength == 0) return 'E';

    // Fórmulas base (simplificadas para el PRD)
    double score = 0;
    if (hitRate >= 0.95) {
      score += 50;
    } else if (hitRate >= 0.85) {
      score += 30;
    } else if (hitRate >= 0.70) {
      score += 10;
    }

    if (avgMs < 800) {
      score += 50;
    } else if (avgMs < 1200) {
      score += 30;
    } else if (avgMs < 2000) {
      score += 10;
    }

    String candidateTier = 'E';
    if (score >= 90) {
      candidateTier = 'S';
    } else if (score >= 70) {
      candidateTier = 'A';
    } else if (score >= 50) {
      candidateTier = 'B';
    } else if (score >= 30) {
      candidateTier = 'C';
    } else if (score >= 10) {
      candidateTier = 'D';
    }

    // FÓRMULAS DE BLOQUEO ANTI-CONFIANZA
    const totalAllKanas = 104; // Hiragana + Katakana + variantes

    // El Rango S está bloqueado hasta que el 100% de las Kanas base (incluyendo variantes) estén desbloqueadas.
    if (candidateTier == 'S' && totalKanaUnlocked < totalAllKanas) {
      candidateTier = 'A';
    }

    // El Rango A está bloqueado hasta cumplir el volumen requerido del inventario.
    // (Ejemplo: 80% de las Kanas)
    if (candidateTier == 'A' && totalKanaUnlocked < (totalAllKanas * 0.8)) {
      candidateTier = 'B';
    }

    // El Rango C exige tener desbloqueadas al menos la mitad del silabario base (23 de 46 Kanas).
    if ((candidateTier == 'C' || candidateTier == 'B') &&
        totalKanaUnlocked < 23) {
      candidateTier = 'D';
    }

    return candidateTier;
  }

  /// Calcula el tiempo efectivo descontando tiempos muertos (Compensación Cognitiva).
  static double calculateEffectiveMs({
    required double rawMs,
    required String character,
    required bool isKanji,
  }) {
    double effective = rawMs;

    // Descuenta el tiempo invertido en ejecutar la segunda pulsación obligatoria (Dakuten / Handakuten)
    final hasDakuten =
        character.contains('゛') ||
        character.contains('゜') ||
        _dakutenChars.contains(character);
    if (hasDakuten) {
      effective -= 150.0; // Restar 150ms de tiempo mecánico
    }

    // En Kanjis, descuenta los milisegundos consumidos en pulsar el botón de conversión predictiva
    if (isKanji) {
      effective -= 300.0; // Restar 300ms de scroll/búsqueda mental en Flick
    }

    return effective > 0 ? effective : 0;
  }

  static const _dakutenChars = [
    'が',
    'ぎ',
    'ぐ',
    'げ',
    'ご',
    'ざ',
    'じ',
    'ず',
    'ぜ',
    'ぞ',
    'だ',
    'ぢ',
    'づ',
    'で',
    'ど',
    'ば',
    'び',
    'ぶ',
    'べ',
    'ぼ',
    'ぱ',
    'ぴ',
    'ぷ',
    'ぺ',
    'ぽ',
    'ガ',
    'ギ',
    'グ',
    'ゲ',
    'ゴ',
    'ザ',
    'ジ',
    'ズ',
    'ゼ',
    'ゾ',
    'ダ',
    'ヂ',
    'ヅ',
    'デ',
    'ド',
    'バ',
    'ビ',
    'ブ',
    'ベ',
    'ボ',
    'パ',
    'ピ',
    'プ',
    'ペ',
    'ポ',
  ];
}
