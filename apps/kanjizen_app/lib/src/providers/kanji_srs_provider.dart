import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kz_data/kz_data.dart';
import 'package:kz_domain/kz_domain.dart';

final kanjiSrsProvider = StateNotifierProvider<KanjiSrsNotifier, KanjiSrsState>((ref) {
  return KanjiSrsNotifier(CharacterRepository.instance);
});

/// Representa la fase actual de un Kanji en el SRS.
enum KanjiSrsPhase {
  /// 0-2/10: Muestra Kanji + Romaji/Hiragana. Usuario teclea la lectura.
  initial,
  /// 3-4/10: Solo Kanji, sin pistas. Usuario teclea. Castigo -0.25 por error.
  withdrawal,
  /// 4-6/10: Muestra Concepto, requiere Kanji. Usuario teclea.
  inversion,
  /// 7-10/10: Discriminatorio. Botones en UI.
  discriminatory,
}

class KanjiSrsState {
  final bool isLoading;
  final List<KanjiModel> activePool;
  final double averagePoolScore;
  final String error;

  const KanjiSrsState({
    this.isLoading = true,
    this.activePool = const [],
    this.averagePoolScore = 0.0,
    this.error = '',
  });

  KanjiSrsState copyWith({
    bool? isLoading,
    List<KanjiModel>? activePool,
    double? averagePoolScore,
    String? error,
  }) {
    return KanjiSrsState(
      isLoading: isLoading ?? this.isLoading,
      activePool: activePool ?? this.activePool,
      averagePoolScore: averagePoolScore ?? this.averagePoolScore,
      error: error ?? this.error,
    );
  }
}

class KanjiSrsNotifier extends StateNotifier<KanjiSrsState> {
  KanjiSrsNotifier(this._repository) : super(const KanjiSrsState()) {
    _initializePool();
  }

  final CharacterRepository _repository;

  Future<void> _initializePool() async {
    state = state.copyWith(isLoading: true);
    try {
      final kanjis = await _repository.getAllKanjis();
      
      final activeKanjis = kanjis.where((k) => k.isUnlocked).toList();
      
      double avgScore = 0.0;
      if (activeKanjis.isNotEmpty) {
        avgScore = activeKanjis.fold(0.0, (s, k) => s + k.srsScore) / activeKanjis.length;
      }

      // Regla de Homogeneidad: Si promedio >= 7.0, desbloquear nuevos (hasta 5 a la vez).
      if (avgScore >= 7.0 || activeKanjis.isEmpty) {
        final locked = kanjis.where((k) => !k.isUnlocked).take(5).toList();
        for (var l in locked) {
          await _repository.unlockKanji(l.character);
        }
      }

      state = state.copyWith(
        isLoading: false,
        activePool: activeKanjis.map((e) => KanjiModel(
          character: e.character,
          isUnlocked: e.isUnlocked,
          srsScore: e.srsScore,
          consecutiveFails: e.consecutiveFails,
          meanings: e.meanings,
          radicals: e.radicals,
        )).toList(),
        averagePoolScore: avgScore,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Determina la fase SRS actual basándose en la puntuación del Kanji.
  KanjiSrsPhase getPhaseFor(double score) {
    if (score < 3.0) return KanjiSrsPhase.initial;
    if (score < 5.0) return KanjiSrsPhase.withdrawal;
    if (score < 7.0) return KanjiSrsPhase.inversion;
    return KanjiSrsPhase.discriminatory;
  }

  /// Aplica las penalizaciones específicas según la fase.
  Future<void> recordError(KanjiModel kanji) async {
    final currentScore = kanji.srsScore;
    final phase = getPhaseFor(currentScore);
    
    double penalty = 0.0;
    int fails = kanji.consecutiveFails + 1;

    if (phase == KanjiSrsPhase.withdrawal) {
      penalty = 0.25;
    } else if (phase == KanjiSrsPhase.inversion) {
      penalty = 0.5; // Degradación
    } else if (phase == KanjiSrsPhase.discriminatory) {
      penalty = 0.1;
    }

    final newScore = (currentScore - penalty).clamp(0.0, 10.0);

    await _repository.updateKanjiSrs(kanji.character, newScore, fails);
    
    await _initializePool();
  }

  Future<void> recordSuccess(KanjiModel kanji) async {
    final newScore = (kanji.srsScore + 0.5).clamp(0.0, 10.0);
    await _repository.updateKanjiSrs(kanji.character, newScore, 0);
    await _initializePool();
  }

  /// Genera opciones trampa (Gemelos Radicales) para la Fase Discriminatoria (7-10).
  List<String> generateDiscriminatoryOptions(KanjiModel targetKanji) {
    final pool = state.activePool;
    final options = <String>{targetKanji.character};

    // 1. Gemelos Radicales (mismo radical)
    final sameRadical = pool.where((k) => k.radical == targetKanji.radical && k.character != targetKanji.character).toList();
    sameRadical.shuffle();
    options.addAll(sameRadical.take(2).map((k) => k.character));

    // 2. Nivel de dominio similar (Mismo SRS Phase)
    final similarScore = pool.where((k) => getPhaseFor(k.srsScore) == KanjiSrsPhase.discriminatory && k.character != targetKanji.character).toList();
    similarScore.shuffle();
    options.addAll(similarScore.take(2).map((k) => k.character));

    // 3. Relleno aleatorio / Troll si faltan
    final random = pool.where((k) => k.character != targetKanji.character).toList();
    random.shuffle();
    while (options.length < 6 && random.isNotEmpty) {
      options.add(random.removeLast().character);
    }

    final result = options.toList();
    result.shuffle(); // Barajar la respuesta correcta
    return result;
  }
}
