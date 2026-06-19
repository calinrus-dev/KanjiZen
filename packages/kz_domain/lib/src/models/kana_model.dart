import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kz_domain/src/engine/tier_calculator.dart';

part 'kana_model.freezed.dart';

/// Modelo inmutable de Kana para la capa de dominio.
/// Sombra inmutable de KanaEntity — nunca expone Isar directamente.
@freezed
abstract class KanaModel with _$KanaModel {
  const factory KanaModel({
    required String character,
    required String romaji,
    required bool isKatakana,
    required String linkedKanaCharacter,
    required bool isDakutenOrHandakuten,
    required bool isUnlocked,
    @Default([]) List<int> historyBlob,
    @Default([]) List<String> svgPaths,
    @Default(0.0) double currentHitRate,
    @Default(0) int averageMs,
  }) = _KanaModel;

  const KanaModel._();

  /// Tier actual calculado en función de hitRate y averageMs.
  KanaTier get tier => TierCalculator.calculate(
    hitRate: currentHitRate,
    avgMs: averageMs,
    isUnlocked: isUnlocked,
  );
}

/// Niveles de dominio del sistema Cyber-Zen.
enum KanaTier { e, d, c, b, a, s }

extension KanaTierLabel on KanaTier {
  String get label => name.toUpperCase();

  String get description => switch (this) {
    KanaTier.e => 'Iniciado',
    KanaTier.d => 'Aprendiz',
    KanaTier.c => 'Competente',
    KanaTier.b => 'Avanzado',
    KanaTier.a => 'Experto',
    KanaTier.s => 'Maestro',
  };
}
