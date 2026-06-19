import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kz_domain/src/engine/tier_calculator.dart';
import 'package:kz_domain/src/models/kana_model.dart';

part 'kanji_model.freezed.dart';

/// Modelo inmutable de Kanji para la capa de dominio.
@freezed
abstract class KanjiModel with _$KanjiModel {
  const factory KanjiModel({
    required String character,
    @Default([]) List<String> onyomi,
    @Default([]) List<String> kunyomi,
    required List<String> meanings,
    required List<String> radicals,
    @Default('') String radical,
    @Default(0) int jlpt,
    @Default(0) int joyo,
    @Default(false) bool isJinmeiyo,
    @Default([]) List<String> kanjidicTranslations,
    @Default([]) List<String> svgPaths,
    required bool isUnlocked,
    @Default([]) List<int> historyBlob,
    @Default(0.0) double currentHitRate,
    @Default(0) int averageMs,
    @Default(0.0) double srsScore,
    @Default(0) int consecutiveFails,
  }) = _KanjiModel;

  const KanjiModel._();

  /// Tier actual calculado en función de hitRate y averageMs.
  KanaTier get tier => TierCalculator.calculate(
    hitRate: currentHitRate,
    avgMs: averageMs,
    isUnlocked: isUnlocked,
  );
}
