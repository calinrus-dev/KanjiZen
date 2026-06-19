import 'package:isar/isar.dart';
import 'package:kz_data/src/entities/kana_level_entity.dart';
import 'package:kz_data/src/services/database_initializer_service.dart';

/// Repositorio para la gestión de los Niveles de la Campaña Kana.
class CampaignRepository {
  Future<Isar> get _db => DatabaseInitializerService.openDb();

  /// Obtiene todos los niveles ordenados por ID para construir la hoja de ruta.
  Future<List<KanaLevelEntity>> getAllLevels() async {
    final isar = await _db;
    return await isar.kanaLevelEntitys.where().sortByLevelId().findAll();
  }

  /// Actualiza las estrellas de un nivel tras una partida (solo si son mejores).
  Future<void> updateLevelStars(int levelId, int stars, int redStars) async {
    final isar = await _db;
    final level = await isar.kanaLevelEntitys.where().levelIdEqualTo(levelId).findFirst();
    
    if (level != null) {
      bool changed = false;
      if (stars > level.stars) {
        level.stars = stars;
        changed = true;
      }
      if (redStars > level.redStars) {
        level.redStars = redStars;
        changed = true;
      }

      if (changed) {
        await isar.writeTxn(() async {
          await isar.kanaLevelEntitys.put(level);
          
          // Desbloquear el siguiente nivel si se consiguió al menos 1 estrella.
          if (level.stars >= 1) {
            final nextLevel = await isar.kanaLevelEntitys
                .where()
                .levelIdEqualTo(levelId + 1)
                .findFirst();
                
            if (nextLevel != null && !nextLevel.isUnlocked) {
              nextLevel.isUnlocked = true;
              await isar.kanaLevelEntitys.put(nextLevel);
            }
          }
        });
      }
    }
  }

  /// Realiza un barrido inicial si la tabla de niveles está vacía (Seeding algorítmico).
  Future<void> seedLevelsIfNeeded(List<KanaLevelEntity> levels) async {
    final isar = await _db;
    final count = await isar.kanaLevelEntitys.count();
    if (count == 0) {
      await isar.writeTxn(() async {
        await isar.kanaLevelEntitys.putAll(levels);
      });
    }
  }
}
