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

  /// Mapa de romaji parcial y alternativo válido
  static const Map<String, List<String>> _multiCharRomaji = {
    'shi': ['s', 'sh', 'si'],
    'chi': ['c', 'ch', 't', 'ti'],
    'tsu': ['t', 'ts', 'tu'],
    'fu': ['f', 'h', 'hu'],
    'ji': ['j', 'z', 'zi'],
    'sha': ['sh', 's', 'sy', 'sya'],
    'shu': ['sh', 's', 'sy', 'syu'],
    'sho': ['sh', 's', 'sy', 'syo'],
    'cha': ['ch', 'c', 'ty', 'tya'],
    'chu': ['ch', 'c', 'ty', 'tyu'],
    'cho': ['ch', 'c', 'ty', 'tyo'],
    'ja': ['j', 'z', 'zy', 'zya'],
    'ju': ['j', 'z', 'zy', 'zyu'],
    'jo': ['j', 'z', 'zy', 'zyo'],
  };

  /// Evalúa el paso actual del input contra el target romaji.
  InputState evaluateStep(String input, String targetRomaji) {
    if (input.isEmpty) return InputState.neutral;
    if (input == targetRomaji) return InputState.success;

    // Verifica alternativas COMPLETAS primero (ej. 'si' == 'shi')
    // IMPORTANTE: debe estar antes que la comprobación de prefijos para no
    // devolver `progress` cuando el input ya es una alternativa completa válida.
    if (_multiCharRomaji.containsKey(targetRomaji)) {
      if (input == 'si' && targetRomaji == 'shi') return InputState.success;
      if (input == 'ti' && targetRomaji == 'chi') return InputState.success;
      if (input == 'tu' && targetRomaji == 'tsu') return InputState.success;
      if (input == 'hu' && targetRomaji == 'fu') return InputState.success;
      if (input == 'zi' && targetRomaji == 'ji') return InputState.success;
      if (input == 'sya' && targetRomaji == 'sha') return InputState.success;
      if (input == 'syu' && targetRomaji == 'shu') return InputState.success;
      if (input == 'syo' && targetRomaji == 'sho') return InputState.success;
      if (input == 'tya' && targetRomaji == 'cha') return InputState.success;
      if (input == 'tyu' && targetRomaji == 'chu') return InputState.success;
      if (input == 'tyo' && targetRomaji == 'cho') return InputState.success;
      if (input == 'zya' && targetRomaji == 'ja') return InputState.success;
      if (input == 'zyu' && targetRomaji == 'ju') return InputState.success;
      if (input == 'zyo' && targetRomaji == 'jo') return InputState.success;
    }

    // Verifica si el input es prefijo válido del romaji objetivo
    if (targetRomaji.startsWith(input)) return InputState.progress;

    // Verifica prefijos de alternativas multi-carácter
    if (_multiCharRomaji.containsKey(targetRomaji)) {
      final validInputs = _multiCharRomaji[targetRomaji]!;
      if (validInputs.contains(input)) return InputState.progress;
    }

    return InputState.error;
  }

  /// Número de pulsaciones reales requeridas para el romaji dado.
  /// Usado en la fórmula t_eff del spec.
  int realKeystrokesFor(String romaji) => romaji.length;
}
