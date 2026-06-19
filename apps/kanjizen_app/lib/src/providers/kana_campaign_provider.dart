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
    final vA = ['あ','い','う','え','お'];
    final vK = ['か','き','く','け','こ'];
    final vS = ['さ','し','す','せ','そ'];
    final vG = ['が','ぎ','ぐ','げ','ご'];
    final vZ = ['ざ','じ','ず','ぜ','ぞ'];

    final seed = [
      KanaLevelEntity()..levelId = 1..mode = 'hiragana'..targetCharacters = vA..isUnlocked = true, // Nivel 1
      KanaLevelEntity()..levelId = 2..mode = 'hiragana'..targetCharacters = vK..isUnlocked = false, // Nivel 2
      KanaLevelEntity()..levelId = 3..mode = 'hiragana'..targetCharacters = [...vA, ...vK]..isBoss = true..isUnlocked = false, // Nivel 3
      KanaLevelEntity()..levelId = 4..mode = 'hiragana'..targetCharacters = vS..isUnlocked = false, // Nivel 4
      KanaLevelEntity()..levelId = 5..mode = 'hiragana'..targetCharacters = [...vS, ...vA]..isUnlocked = false, // Nivel 5
      KanaLevelEntity()..levelId = 6..mode = 'hiragana'..targetCharacters = [...vS, ...vA, ...vK]..isBoss = true..isUnlocked = false, // Nivel 6
      KanaLevelEntity()..levelId = 7..mode = 'hiragana'..targetCharacters = vG..isUnlocked = false, // Nivel 7
      KanaLevelEntity()..levelId = 8..mode = 'hiragana'..targetCharacters = [...vG, ...vA]..isUnlocked = false, // Nivel 8
      KanaLevelEntity()..levelId = 9..mode = 'hiragana'..targetCharacters = [...vG, ...vA, ...vK]..isUnlocked = false, // Nivel 9
      KanaLevelEntity()..levelId = 10..mode = 'hiragana'..targetCharacters = [...vG, ...vA, ...vK, ...vS]..isUnlocked = false, // Nivel 10
      KanaLevelEntity()..levelId = 11..mode = 'hiragana'..targetCharacters = vZ..isUnlocked = false, // Nivel 11
    ];
    await _repository.seedLevelsIfNeeded(seed);
  }

  /// Evalúa el resultado de una partida y asigna estrellas según los requisitos de tiempo y acierto.
  Future<void> evaluateSession({
    required int levelId,
    required double hitRate,
    required int maxTimePerCharMs,
    required bool isHardcore,
  }) async {
    int stars = 0;
    int redStars = 0;

    if (hitRate >= 0.8) {
      if (isHardcore) {
        if (maxTimePerCharMs <= 1000 && maxTimePerCharMs > 0) redStars = 3;
        else if (maxTimePerCharMs <= 2000 && maxTimePerCharMs > 0) redStars = 2;
        else redStars = 1;
        stars = 3; // Hardcore implica 3 estrellas base
      } else {
        if (maxTimePerCharMs <= 2000 && maxTimePerCharMs > 0) stars = 3;
        else if (maxTimePerCharMs <= 3000 && maxTimePerCharMs > 0) stars = 2;
        else stars = 1;
      }

      await updateLevelProgress(levelId, stars, redStars);
    }
  }
}
