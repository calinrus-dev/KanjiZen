import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:kz_domain/src/settings/settings_state.dart';

part 'settings_provider.g.dart';

@riverpod
class Settings extends _$Settings {
  @override
  SettingsState build() {
    // Aquí a futuro se podría leer de SharedPreferences para persistencia
    return const SettingsState();
  }

  void setAccentColor(CyberAccent color) => state = state.copyWith(accentColor: color);
  void setFontSize(AppFontSize size) => state = state.copyWith(fontSize: size);
  void setEngineLanguage(EngineLanguage lang) => state = state.copyWith(engineLanguage: lang);
  void setTrainingMode(TrainingMode mode) => state = state.copyWith(trainingMode: mode);
  void toggleRomajiHints() => state = state.copyWith(showRomajiHints: !state.showRomajiHints);
  void setProgressiveSystem(ProgressiveSystem sys) => state = state.copyWith(progressiveSystem: sys);
  
  void toggleFreeModeKey(String key) {
    final keys = List<String>.from(state.freeModeKeys);
    if (keys.contains(key)) keys.remove(key);
    else keys.add(key);
    state = state.copyWith(freeModeKeys: keys);
  }

  void setDeathClock(DeathClock clock) => state = state.copyWith(deathClock: clock);
  void toggleSkipOnError() => state = state.copyWith(skipOnError: !state.skipOnError);
  void toggleHardcoreMode() => state = state.copyWith(hardcoreMode: !state.hardcoreMode);
}
