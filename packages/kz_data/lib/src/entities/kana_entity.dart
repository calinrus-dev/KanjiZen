// GENERATED CODE — DO NOT EDIT MANUALLY
// Run: melos run build_runner
import 'package:isar/isar.dart';

part 'kana_entity.g.dart';

/// Entidad Isar para Kana (Hiragana + Katakana).
/// Las escrituras son asíncronas; las lecturas sincrónicas vía caché Riverpod.
@collection
class KanaEntity {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String character;

  late bool isKatakana;
  late String romaji;

  /// Carácter equivalente en la otra sílaba (ひ↔ヒ).
  late String linkedKanaCharacter;

  late bool isDakutenOrHandakuten;

  /// Paths crudos SVG extraídos de KanjiVG para dibujar el carácter.
  List<String> svgPaths = [];

  // ─── Progreso ─────────────────────────────────────────────────────────────
  @Index()
  late bool isUnlocked;

  /// Últimos 50 intentos comprimidos en 32 bits por entrada:
  /// Bit 0 = acierto(1)/fallo(0) · Bit 1 = doble pulsación · Bits 2-31 = ms
  late List<int> historyBlob;

  late double currentHitRate;
  late int averageMs;
}
