import 'package:freezed_annotation/freezed_annotation.dart';

part 'kana_level_model.freezed.dart';

/// Modelo inmutable para los Niveles de la Campaña Pedagógica Kana.
@freezed
abstract class KanaLevelModel with _$KanaLevelModel {
  const factory KanaLevelModel({
    required int levelId,
    required String mode, // hiragana, katakana, mixed
    @Default(false) bool isBoss,
    @Default([]) List<String> targetCharacters,
    @Default(0) int stars,
    @Default(0) int redStars,
    @Default(false) bool isUnlocked,
  }) = _KanaLevelModel;

  const KanaLevelModel._();
}
