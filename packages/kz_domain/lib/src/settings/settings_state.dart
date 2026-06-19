import 'package:freezed_annotation/freezed_annotation.dart';

part 'settings_state.freezed.dart';

/// Estado inmutable de los ajustes generales del sistema.
enum CyberAccent { green, red, orange, blue, purple, white }
enum AppFontSize { auto, s, m, l }
enum EngineLanguage { es, en, jp }
enum AppLayoutMode { syllable, word, text }
enum ProgressiveSystem { hira, kata, both }
enum DeathClock { off, s5, s3, s1_5, s1, s0_75, s0_5 }
enum EngineMode { kana, meca, kanji }
enum PoolMode { auto, custom }

@freezed
abstract class SettingsState with _$SettingsState {
  const factory SettingsState({
    @Default(CyberAccent.green) CyberAccent accentColor,
    @Default(AppFontSize.auto) AppFontSize fontSize,
    @Default(EngineLanguage.es) EngineLanguage engineLanguage,
    @Default(AppLayoutMode.syllable) AppLayoutMode layoutMode,
    @Default(false) bool showRomajiHints,
    @Default(ProgressiveSystem.both) ProgressiveSystem progressiveSystem,
    @Default([]) List<String> freeModeKeys,
    @Default(DeathClock.off) DeathClock deathClock,
    @Default(false) bool skipOnError,
    @Default(false) bool hardcoreMode,
    @Default(1) int hardcoreLives,
    @Default(EngineMode.meca) EngineMode engineMode,
    @Default(PoolMode.auto) PoolMode poolMode,
    @Default(1) int sessionMinutes,
    @Default(false) bool romajiAssist,
    @Default(3) int romajiThreshold,
    @Default(true) bool enableStrokeAnimation,
    @Default(true) bool enableAudio,
    @Default(1.0) double canvasOpacity,
    @Default(false) bool useBoldText,
  }) = _SettingsState;
}
