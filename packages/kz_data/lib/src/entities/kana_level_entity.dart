import 'package:isar/isar.dart';

part 'kana_level_entity.g.dart';

/// Entidad Isar para los Niveles de la Campaña Pedagógica Kana.
@collection
class KanaLevelEntity {
  Id id = Isar.autoIncrement;

  /// El número oficial del nivel (1 a 100+).
  @Index(unique: true)
  late int levelId;

  /// El modo al que pertenece: 'hiragana', 'katakana' o 'mixed'.
  @Index()
  late String mode;

  /// Si es un nivel de integración complejo (Boss).
  bool isBoss = false;

  /// Lista de caracteres inyectados en este nivel.
  List<String> targetCharacters = [];

  /// Estrellas normales (0 a 3).
  int stars = 0;

  /// Estrellas rojas / Hardcore (0 a 3).
  int redStars = 0;

  /// Indica si el usuario ya puede jugar este nivel.
  bool isUnlocked = false;
}
