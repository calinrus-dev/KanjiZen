import 'package:freezed_annotation/freezed_annotation.dart';

part 'settings_state.freezed.dart';

/// Estado inmutable de los ajustes generales del sistema.
@freezed
abstract class SettingsState with _$SettingsState {
  const factory SettingsState({
    @Default(true) bool enableStrokeAnimation,
    @Default(true) bool enableAudio,
  }) = _SettingsState;
}
