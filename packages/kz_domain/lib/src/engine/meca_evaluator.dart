enum MecaEvaluationResult { hit, prefix, error }

/// Mapeo de alternativas romaji válidas (ej. si→shi, ti→chi).
/// Clave: romaji canónico. Valor: lista de alternativas aceptadas.
const _romajiAlternatives = <String, List<String>>{
  'shi': ['si', 'sy'],
  'chi': ['ti', 'ty'],
  'tsu': ['tu'],
  'fu': ['hu'],
  'ji': ['zi'],
  'sha': ['sya'],
  'shu': ['syu'],
  'sho': ['syo'],
  'cha': ['tya'],
  'chu': ['tyu'],
  'cho': ['tyo'],
  'ja': ['zya'],
  'ju': ['zyu'],
  'jo': ['zyo'],
};

class MecaEvaluator {
  /// Evalúa el input en tiempo real (onChange).
  /// [input]: Lo que el usuario ha tecleado hasta el momento.
  /// [targetRomaji]: La respuesta correcta esperada en Romaji (ej: 'ka').
  /// [targetKana]: La respuesta correcta esperada en Kana/Kanji (ej: 'か').
  static MecaEvaluationResult evaluate(
    String input,
    String targetRomaji,
    String targetKana,
  ) {
    if (input.isEmpty) return MecaEvaluationResult.prefix;

    final normalizedInput = input.trim().toLowerCase();
    final normalizedRomaji = targetRomaji.trim().toLowerCase();

    // Acierto directo (escribió el romaji canónico o el kana directo)
    if (normalizedInput == normalizedRomaji || input.trim() == targetKana) {
      return MecaEvaluationResult.hit;
    }

    // Prefijo válido del kana directo (ej. 'か' para 'かん')
    if (targetKana.startsWith(input.trim())) {
      return MecaEvaluationResult.prefix;
    }

    // Verificar alternativas completas (ej. 'si' == 'shi')
    final alternatives = _romajiAlternatives[normalizedRomaji];
    if (alternatives != null && alternatives.contains(normalizedInput)) {
      return MecaEvaluationResult.hit;
    }

    // Prefijo válido del romaji canónico (ej. 'k' para 'ka')
    if (normalizedRomaji.startsWith(normalizedInput)) {
      return MecaEvaluationResult.prefix;
    }

    // Prefijo válido de alternativas (ej. 's' para 'si' cuando target es 'shi')
    if (alternatives != null) {
      for (final alt in alternatives) {
        if (alt.startsWith(normalizedInput)) return MecaEvaluationResult.prefix;
      }
    }

    return MecaEvaluationResult.error;
  }
}
