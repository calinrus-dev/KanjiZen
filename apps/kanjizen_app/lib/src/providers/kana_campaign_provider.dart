import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kz_data/kz_data.dart';
import 'package:kz_domain/kz_domain.dart';

final campaignRepositoryProvider = Provider((ref) => CampaignRepository());

final kanaCampaignProvider = StateNotifierProvider<KanaCampaignNotifier, AsyncValue<List<KanaLevelModel>>>((ref) {
  return KanaCampaignNotifier(ref.watch(campaignRepositoryProvider));
});

class KanaCampaignNotifier extends StateNotifier<AsyncValue<List<KanaLevelModel>>> {
  KanaCampaignNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadLevels();
  }

  final CampaignRepository _repository;

  Future<void> loadLevels() async {
    state = const AsyncValue.loading();
    try {
      final entities = await _repository.getAllLevels();
      
      // Si está vacío, hacemos un seeding inicial (mock de 10 niveles)
      if (entities.isEmpty) {
        await _seedLevels();
        return loadLevels();
      }

      final models = entities.map((e) => KanaLevelModel(
        levelId: e.levelId,
        mode: e.mode,
        isBoss: e.isBoss,
        targetCharacters: e.targetCharacters,
        stars: e.stars,
        redStars: e.redStars,
        isUnlocked: e.isUnlocked,
      )).toList();
      
      state = AsyncValue.data(models);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateLevelProgress(int levelId, int stars, int redStars) async {
    await _repository.updateLevelStars(levelId, stars, redStars);
    await loadLevels();
  }

  Future<void> _seedLevels() async {
    final seed = <KanaLevelEntity>[];
    const allKanas = KanaSeedData.all;
    
    // Separar en Hiragana y Katakana
    final hiras = allKanas.where((k) => !k.isKatakana).toList();
    final katas = allKanas.where((k) => k.isKatakana).toList();
    
    for (int lvl = 1; lvl <= 100; lvl++) {
      final List<String> targets = [];
      final String mode;
      final bool isBoss = lvl % 5 == 0;
      
      if (lvl <= 50) {
        mode = 'hiragana';
        if (isBoss) {
          final startIdx = ((lvl ~/ 5 - 1) * 10).clamp(0, hiras.length - 1);
          final endIdx = (startIdx + 15).clamp(0, hiras.length);
          targets.addAll(hiras.sublist(startIdx, endIdx).map((k) => k.character));
        } else {
          final startIdx = ((lvl - 1 - (lvl ~/ 5)) * 4).clamp(0, hiras.length - 1);
          final endIdx = (startIdx + 4).clamp(0, hiras.length);
          targets.addAll(hiras.sublist(startIdx, endIdx).map((k) => k.character));
        }
      } else {
        mode = 'katakana';
        final relLvl = lvl - 50;
        if (isBoss) {
          final startIdx = ((relLvl ~/ 5 - 1) * 10).clamp(0, katas.length - 1);
          final endIdx = (startIdx + 15).clamp(0, katas.length);
          targets.addAll(katas.sublist(startIdx, endIdx).map((k) => k.character));
        } else {
          final startIdx = ((relLvl - 1 - (relLvl ~/ 5)) * 4).clamp(0, katas.length - 1);
          final endIdx = (startIdx + 4).clamp(0, katas.length);
          targets.addAll(katas.sublist(startIdx, endIdx).map((k) => k.character));
        }
      }

      if (targets.isEmpty) {
        targets.addAll(lvl <= 50 
          ? ['あ', 'い', 'う', 'え', 'お'] 
          : ['ア', 'イ', 'ウ', 'エ', 'オ']);
      }

      seed.add(
        KanaLevelEntity()
          ..levelId = lvl
          ..mode = mode
          ..targetCharacters = targets
          ..isBoss = isBoss
          ..stars = 0
          ..redStars = 0
          ..isUnlocked = (lvl == 1),
      );
    }
    
    await _repository.seedLevelsIfNeeded(seed);
  }


  Future<void> evaluateSession({
    required int levelId,
    required double hitRate,
    required int maxTimePerCharMs,
    required bool isHardcore,
  }) async {
    int stars = 0;
    int redStars = 0;

    if (hitRate >= 0.8) {
      final levels = state.value ?? [];
      final level = levels.where((l) => l.levelId == levelId).firstOrNull;
      if (level != null) {
        final repo = CharacterRepository.instance;
        for (final char in level.targetCharacters) {
          await repo.unlockKana(char);
        }
      }

      if (isHardcore) {
        if (maxTimePerCharMs <= 1000 && maxTimePerCharMs > 0) {
          redStars = 3;
        } else if (maxTimePerCharMs <= 2000 && maxTimePerCharMs > 0) {
          redStars = 2;
        } else {
          redStars = 1;
        }
        stars = 3;
      } else {
        if (maxTimePerCharMs <= 2000 && maxTimePerCharMs > 0) {
          stars = 3;
        } else if (maxTimePerCharMs <= 3000 && maxTimePerCharMs > 0) {
          stars = 2;
        } else {
          stars = 1;
        }
      }

      await updateLevelProgress(levelId, stars, redStars);
    }
  }
}
