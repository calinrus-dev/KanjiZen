import 'package:freezed_annotation/freezed_annotation.dart';

part 'settings_state.freezed.dart';

/// Estado inmutable de los ajustes generales del sistema.
enum CyberAccent { green, red, orange, blue, purple, white }
enum AppFontSize { auto, s, m, l }
enum EngineLanguage { es, en, jp }
enum TrainingMode { syllable, words }
enum ProgressiveSystem { hira, kata, both }
enum DeathClock { off, s5, s3, s1_5 }

@freezed
abstract class SettingsState with _$SettingsState {
  const factory SettingsState({
    @Default(CyberAccent.green) CyberAccent accentColor,
    @Default(AppFontSize.auto) AppFontSize fontSize,
    @Default(EngineLanguage.es) EngineLanguage engineLanguage,
    @Default(TrainingMode.syllable) TrainingMode trainingMode,
    @Default(false) bool showRomajiHints,
    @Default(ProgressiveSystem.both) ProgressiveSystem progressiveSystem,
    @Default([]) List<String> freeModeKeys,
    @Default(DeathClock.off) DeathClock deathClock,
    @Default(false) bool skipOnError,
    @Default(false) bool hardcoreMode,
    @Default(true) bool enableStrokeAnimation,
    @Default(true) bool enableAudio,
  }) = _SettingsState;
}
