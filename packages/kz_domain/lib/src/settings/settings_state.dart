import 'package:freezed_annotation/freezed_annotation.dart';

part 'settings_state.freezed.dart';

/// Estado inmutable de los ajustes generales del sistema.
enum CyberAccent { green, red, orange, blue, purple, white }

enum AppFontSize { auto, s, m, l }

enum EngineLanguage { es, en, jp }

enum AppLayoutMode { syllable, word, text }

enum ProgressiveSystem { hira, kata, both }

enum DeathClock { off, s5, s3, s1_5, s1, s0_75, s0_5 }

enum EngineMode { meca, kanji, quiz, arcade, write }

enum PoolMode { auto, custom }

enum GridScale { sl, l, xl, auto }

enum SrsProportion { ratio80_20, ratio60_40, reviewOnly }

enum KanjiFilterTopic { grade, jlpt }

enum QuizDensity { matrix2x2, matrix3x2 }

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
    @Default(15) int campaignSessionVolume,
    @Default(0) int campaignSessionDuration,

    // V3.0 New settings
    @Default(GridScale.auto) GridScale gridScale,
    @Default(5) int kanjiBatchSize, // Lote 3, 5, 10
    @Default(SrsProportion.ratio80_20) SrsProportion srsProportion,
    @Default(KanjiFilterTopic.grade) KanjiFilterTopic kanjiFilterTopic,
    @Default(QuizDensity.matrix2x2) QuizDensity quizDensity,
    @Default(false) bool quizMatchRadicals,
    @Default(4) int arcadeLanes, // 3 or 4
    @Default(false) bool arcadeAcceleration,
    @Default(25.0) double writeTolerance, // 15.0, 25.0, 35.0
    @Default(false) bool writeGuideTemplate,
    // V4.0 Visual / Audio settings
    @Default(2.0)
    double strokeWidth, // grosor trazo SVG (1.0 fino → 4.0 grueso)
    @Default(1.5)
    double strokeAnimationSpeed, // segundos por animación SVG (0.5–3.0)
  }) = _SettingsState;
}
