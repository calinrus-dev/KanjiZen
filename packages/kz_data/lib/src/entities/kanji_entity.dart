import 'package:isar/isar.dart';

part 'kanji_entity.g.dart';

/// Entidad Isar para los Kanjis base.
@collection
class KanjiEntity {
  Id id = Isar.autoIncrement;

  /// El carácter Kanji en sí.
  @Index(unique: true)
  late String character;

  @Index()
  String radical = '';

  @Index()
  int jlpt = 0; // 5 a 1

  @Index()
  int joyo = 0; // Grado 1 a 6, o 8 para secundaria superior

  @Index()
  bool isJinmeiyo = false; // Para nombres

  List<String> kanjidicTranslations =
      []; // Traducciones de diccionario oficiales

  /// Lista de Onyomis (Lecturas chinas) en Katakana.
  List<String> onyomi = [];

  /// Lista de Kunyomis (Lecturas japonesas) en Hiragana.
  List<String> kunyomi = [];

  /// Significados del Kanji en español.
  List<String> meanings = [];

  /// Radicales principales que lo componen (para filtros visuales).
  List<String> radicals = [];

  /// Trazos vectoriales SVG extraídos de KanjiVG.
  List<String> svgPaths = [];

  /// Desbloqueo lógico del sistema SRS.
  bool isUnlocked = false;

  /// Progreso de aciertos/errores cifrados.
  List<int> historyBlob = [];

  /// Estadísticas derivadas para consultas rápidas.
  double currentHitRate = 0.0;
  int averageMs = 0;

  /// Nivel de Dominio SRS (0.0 a 10.0).
  double srsScore = 0.0;

  /// Fallos consecutivos para activar asistencia.
  int consecutiveFails = 0;
}
