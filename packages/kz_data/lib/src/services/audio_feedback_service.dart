import 'package:flutter_tts/flutter_tts.dart';

/// Servicio TTS para pronunciar Kana y significados.
/// Idioma base: ja-JP. Para significados en es-ES se restaura inmediatamente.
class AudioFeedbackService {
  AudioFeedbackService._();
  static final AudioFeedbackService instance = AudioFeedbackService._();

  final FlutterTts _tts = FlutterTts();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    await _tts.setLanguage('ja-JP');
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
    _initialized = true;
  }

  Future<void> playReading(String text) async {
    await init();
    await _tts.speak(text);
  }

  Future<void> playMeaning(String text) async {
    await init();
    await _tts.setLanguage('es-ES');
    await _tts.speak(text);
    await _tts.setLanguage('ja-JP'); // Restaurar inmediatamente
  }

  Future<void> stop() async => _tts.stop();
}
