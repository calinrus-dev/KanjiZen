enum MecaEvaluationResult {
  hit,
  prefix,
  error,
}

class MecaEvaluator {
  /// Evalúa el input en tiempo real (onChange).
  /// [input]: Lo que el usuario ha tecleado hasta el momento.
  /// [targetRomaji]: La respuesta correcta esperada en Romaji (ej: 'ka').
  /// [targetKana]: La respuesta correcta esperada en Kana/Kanji (ej: 'か').
  static MecaEvaluationResult evaluate(String input, String targetRomaji, String targetKana) {
    if (input.isEmpty) return MecaEvaluationResult.prefix;

    final normalizedInput = input.trim().toLowerCase();
    final normalizedRomaji = targetRomaji.trim().toLowerCase();

    // Acierto directo (escribió el romaji completo o el kana/kanji directo usando teclado japonés)
    if (normalizedInput == normalizedRomaji || input.trim() == targetKana) {
      return MecaEvaluationResult.hit;
    }

    // Prefijo válido (ej: escribió 'k' para 'ka')
    if (normalizedRomaji.startsWith(normalizedInput)) {
      return MecaEvaluationResult.prefix;
    }

    // Si no es acierto ni prefijo válido, es un error de secuencia
    return MecaEvaluationResult.error;
  }
}
