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
  void setLayoutMode(AppLayoutMode mode) => state = state.copyWith(layoutMode: mode);
  void toggleRomajiHints() => state = state.copyWith(showRomajiHints: !state.showRomajiHints);
  void setProgressiveSystem(ProgressiveSystem sys) => state = state.copyWith(progressiveSystem: sys);
  
  void toggleFreeModeKey(String key) {
    final keys = List<String>.from(state.freeModeKeys);
    if (keys.contains(key)) {
      keys.remove(key);
    } else {
      keys.add(key);
    }
    state = state.copyWith(freeModeKeys: keys);
  }

  void setDeathClock(DeathClock clock) => state = state.copyWith(deathClock: clock);
  void toggleSkipOnError() => state = state.copyWith(skipOnError: !state.skipOnError);
  void toggleHardcoreMode() => state = state.copyWith(hardcoreMode: !state.hardcoreMode);
  void setHardcoreLives(int lives) => state = state.copyWith(hardcoreLives: lives);
  void setCanvasOpacity(double opacity) => state = state.copyWith(canvasOpacity: opacity.clamp(0.3, 1.0));
  void toggleBoldText() => state = state.copyWith(useBoldText: !state.useBoldText);
  
  void setEngineMode(EngineMode mode) => state = state.copyWith(engineMode: mode);
  void setPoolMode(PoolMode mode) => state = state.copyWith(poolMode: mode);
  void setSessionMinutes(int min) => state = state.copyWith(sessionMinutes: min);
  void toggleRomajiAssist() => state = state.copyWith(romajiAssist: !state.romajiAssist);
  void setRomajiThreshold(int val) => state = state.copyWith(romajiThreshold: val);
  void toggleStrokeAnimation() => state = state.copyWith(enableStrokeAnimation: !state.enableStrokeAnimation);
}
