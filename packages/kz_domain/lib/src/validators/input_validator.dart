/// Estado del input del usuario en tiempo real.
enum InputState {
  neutral, // Sin input
  progress, // Input parcialmente correcto (dakuten root)
  error, // Input incorrecto — dispara shakeX
  success, // Input completo correcto
}

/// Validador de input dinámico — evalúa progreso de escritura en Flick/QWERTY.
/// Cero dependencias de Flutter.
class InputValidator {
  InputValidator();

  // (Dakuten roots will be implemented when Flick direct Kana input is fully supported)

  /// Mapa de romaji parcial → válido para multi-carácter (shi, chi, tsu...)
  static const Map<String, List<String>> _multiCharRomaji = {
    'shi': ['s', 'sh'],
    'chi': ['c', 'ch'],
    'tsu': ['t', 'ts'],
  };

  /// Evalúa el paso actual del input contra el target romaji.
  InputState evaluateStep(String input, String targetRomaji) {
    if (input.isEmpty) return InputState.neutral;
    if (input == targetRomaji) return InputState.success;

    // Verifica si el input es prefijo válido del romaji objetivo
    if (targetRomaji.startsWith(input)) return InputState.progress;

    // Verifica prefijos multi-carácter (shi→s,sh / chi→c,ch / tsu→t,ts)
    for (final entry in _multiCharRomaji.entries) {
      if (targetRomaji == entry.key && entry.value.contains(input)) {
        return InputState.progress;
      }
    }

    return InputState.error;
  }

  /// Número de pulsaciones reales requeridas para el romaji dado.
  /// Usado en la fórmula t_eff del spec.
  int realKeystrokesFor(String romaji) => romaji.length;
}
