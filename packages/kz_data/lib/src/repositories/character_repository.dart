import 'package:isar/isar.dart';
import '../entities/kana_entity.dart';
import '../services/database_initializer_service.dart';

/// Repositorio de caracteres Kana — implementación Isar.
/// Lecturas síncronas desde caché activa, escrituras asíncronas.
class CharacterRepository {
  CharacterRepository._();
  static final CharacterRepository instance = CharacterRepository._();

  Future<Isar> get _db => DatabaseInitializerService.openDb();

  // ─── Kana reads ───────────────────────────────────────────────────────────

  Future<List<KanaEntity>> getAllKanas() async {
    final isar = await _db;
    return isar.kanaEntitys.where().findAll();
  }

  Future<List<KanaEntity>> getUnlockedKanas() async {
    final isar = await _db;
    return isar.kanaEntitys.filter().isUnlockedEqualTo(true).findAll();
  }

  Future<KanaEntity?> getKanaByCharacter(String character) async {
    final isar = await _db;
    return isar.kanaEntitys.filter().characterEqualTo(character).findFirst();
  }

  // ─── Kana writes ──────────────────────────────────────────────────────────

  Future<void> updateKanaProgress({
    required String character,
    required List<int> historyBlob,
    required double hitRate,
    required int averageMs,
  }) async {
    final isar = await _db;
    final entity = await isar.kanaEntitys
        .filter()
        .characterEqualTo(character)
        .findFirst();
    if (entity == null) return;
    entity
      ..historyBlob = historyBlob
      ..currentHitRate = hitRate
      ..averageMs = averageMs;
    await isar.writeTxn(() async => isar.kanaEntitys.put(entity));
  }

  Future<void> unlockKana(String character) async {
    final isar = await _db;
    final entity = await isar.kanaEntitys
        .filter()
        .characterEqualTo(character)
        .findFirst();
    if (entity == null || entity.isUnlocked) return;
    entity.isUnlocked = true;
    await isar.writeTxn(() async => isar.kanaEntitys.put(entity));
  }

  Future<void> resetKanaProgress(String character) async {
    final isar = await _db;
    final entity = await isar.kanaEntitys
        .filter()
        .characterEqualTo(character)
        .findFirst();
    if (entity == null) return;
    entity
      ..historyBlob = []
      ..currentHitRate = 0.0
      ..averageMs = 0;
    await isar.writeTxn(() async => isar.kanaEntitys.put(entity));
  }
}
