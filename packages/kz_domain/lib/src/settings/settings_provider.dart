import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'settings_state.dart';

part 'settings_provider.g.dart';

@riverpod
class Settings extends _$Settings {
  @override
  SettingsState build() {
    // Aquí a futuro se podría leer de SharedPreferences para persistencia
    return const SettingsState();
  }

  void toggleStrokeAnimation() {
    state = state.copyWith(enableStrokeAnimation: !state.enableStrokeAnimation);
  }

  void toggleAudio() {
    state = state.copyWith(enableAudio: !state.enableAudio);
  }
}
