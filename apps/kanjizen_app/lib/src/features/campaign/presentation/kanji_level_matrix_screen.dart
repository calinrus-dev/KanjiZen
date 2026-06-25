import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kz_core/kz_core.dart';
import 'package:kz_domain/kz_domain.dart';
import 'package:kz_data/kz_data.dart';
import 'package:kz_ui_components/kz_ui_components.dart';
import 'package:kanjizen_app/src/providers/timeline_provider.dart';

// ─── MODELO DE NIVEL KANJI ────────────────────────────────────────────────────

enum KanjiCategory { jlpt, grade, jinmeiyo, advanced }

class KanjiLevelModel {
  const KanjiLevelModel({
    required this.id,
    required this.category,
    required this.subCategory,
    required this.requiredKanjis,
    this.isUnlocked = false,
    this.starsEarned = 0,
  });

  final int id;
  final KanjiCategory category;
  final String subCategory; // 'N5', 'G1', etc.
  final List<String> requiredKanjis;
  final bool isUnlocked;
  final int starsEarned;

  KanjiLevelModel copyWith({bool? isUnlocked, int? starsEarned}) =>
      KanjiLevelModel(
        id: id,
        category: category,
        subCategory: subCategory,
        requiredKanjis: requiredKanjis,
        isUnlocked: isUnlocked ?? this.isUnlocked,
        starsEarned: starsEarned ?? this.starsEarned,
      );
}

// ─── DATOS MOCK (JLPT N5 — Nivel 01) ─────────────────────────────────────────

const _jlptN5Levels = [
  KanjiLevelModel(
    id: 1,
    category: KanjiCategory.jlpt,
    subCategory: 'N5',
    requiredKanjis: ['一', '二', '三', '四', '五'],
    isUnlocked: true,
  ),
  KanjiLevelModel(
    id: 2,
    category: KanjiCategory.jlpt,
    subCategory: 'N5',
    requiredKanjis: ['六', '七', '八', '九', '十'],
    isUnlocked: false,
  ),
  KanjiLevelModel(
    id: 3,
    category: KanjiCategory.jlpt,
    subCategory: 'N5',
    requiredKanjis: ['日', '月', '火', '水', '木'],
    isUnlocked: false,
  ),
  KanjiLevelModel(
    id: 4,
    category: KanjiCategory.jlpt,
    subCategory: 'N5',
    requiredKanjis: ['金', '土', '人', '山', '川'],
    isUnlocked: false,
  ),
  KanjiLevelModel(
    id: 5,
    category: KanjiCategory.jlpt,
    subCategory: 'N5',
    requiredKanjis: ['大', '小', '上', '下', '中'],
    isUnlocked: false,
  ),
];

const _gradeG1Levels = [
  KanjiLevelModel(
    id: 1,
    category: KanjiCategory.grade,
    subCategory: 'G1',
    requiredKanjis: ['一', '二', '三', '四', '五'],
    isUnlocked: true,
  ),
  KanjiLevelModel(
    id: 2,
    category: KanjiCategory.grade,
    subCategory: 'G1',
    requiredKanjis: ['六', '七', '八', '九', '十'],
    isUnlocked: false,
  ),
  KanjiLevelModel(
    id: 3,
    category: KanjiCategory.grade,
    subCategory: 'G1',
    requiredKanjis: ['百', '千', '万', '円', '年'],
    isUnlocked: false,
  ),
];

// ─── PROVIDER DE NIVELES KANJI (in-memory con persistencia futura) ────────────

final kanjiLevelProvider =
    StateNotifierProvider<
      KanjiLevelNotifier,
      Map<KanjiCategory, List<KanjiLevelModel>>
    >((ref) => KanjiLevelNotifier());

class KanjiLevelNotifier
    extends StateNotifier<Map<KanjiCategory, List<KanjiLevelModel>>> {
  KanjiLevelNotifier()
    : super({
        KanjiCategory.jlpt: _jlptN5Levels,
        KanjiCategory.grade: _gradeG1Levels,
        KanjiCategory.jinmeiyo: [],
        KanjiCategory.advanced: [],
      });

  void completeLevel(KanjiCategory cat, int levelId, int stars) {
    final levels = List<KanjiLevelModel>.from(state[cat] ?? []);
    final idx = levels.indexWhere((l) => l.id == levelId);
    if (idx < 0) return;
    levels[idx] = levels[idx].copyWith(starsEarned: stars);
    // Desbloquear el siguiente nivel si es el primero en superar
    if (idx + 1 < levels.length && !levels[idx + 1].isUnlocked) {
      levels[idx + 1] = levels[idx + 1].copyWith(isUnlocked: true);
    }
    state = {...state, cat: levels};
  }

  // Desbloquea los kanjis en la BD
  Future<void> unlockKanjisInDb(List<String> characters) async {
    final repo = CharacterRepository.instance;
    for (final char in characters) {
      await repo.unlockKanji(char);
    }
  }
}

// ─── PANTALLA PRINCIPAL ───────────────────────────────────────────────────────

class KanjiLevelMatrixScreen extends ConsumerStatefulWidget {
  const KanjiLevelMatrixScreen({super.key});

  @override
  ConsumerState<KanjiLevelMatrixScreen> createState() =>
      _KanjiLevelMatrixScreenState();
}

class _KanjiLevelMatrixScreenState
    extends ConsumerState<KanjiLevelMatrixScreen> {
  KanjiCategory _selectedCategory = KanjiCategory.jlpt;

  Color _accent(CyberAccent c) => switch (c) {
    CyberAccent.green => CyberTheme.defaultAccent,
    CyberAccent.red => CyberTheme.errorRed,
    CyberAccent.orange => Colors.orange,
    CyberAccent.blue => Colors.cyanAccent,
    CyberAccent.purple => Colors.purpleAccent,
    CyberAccent.white => Colors.white,
  };

  String _categoryLabel(KanjiCategory c) => switch (c) {
    KanjiCategory.jlpt => 'JLPT',
    KanjiCategory.grade => 'GRADO ESCOLAR',
    KanjiCategory.jinmeiyo => 'NOMBRES',
    KanjiCategory.advanced => 'AVANZADO',
  };

  void _showLevelPreview(
    BuildContext context,
    KanjiLevelModel level,
    Color accent,
  ) {
    final settings = ref.read(settingsProvider);
    int selectedVolume = settings.campaignSessionVolume;
    int selectedDuration = settings.campaignSessionDuration;

    showDialog<void>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF05060A),
              shape: Border.all(color: accent.withValues(alpha: 0.3)),
              title: Text(
                'NIVEL ${level.id} — ${level.subCategory}',
                style: TextStyle(
                  color: accent,
                  fontFamily: 'Courier',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'KANJIS OBJETIVOS:',
                    style: TextStyle(
                      color: Colors.white38,
                      fontFamily: 'Courier',
                      fontSize: 9,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    level.requiredKanjis.join('  '),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontFamily: 'Courier',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'VOLUMEN DE DECK:',
                    style: TextStyle(
                      color: Colors.white38,
                      fontFamily: 'Courier',
                      fontSize: 9,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [15, 30, 50].map((v) {
                      final active = selectedVolume == v;
                      return GestureDetector(
                        onTap: () => setState(() => selectedVolume = v),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            border: Border.all(color: active ? accent : Colors.white10),
                            color: active ? accent.withValues(alpha: 0.1) : Colors.transparent,
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: Text(
                            '$v ÍTEMS',
                            style: TextStyle(
                              color: active ? accent : Colors.white30,
                              fontFamily: 'Courier',
                              fontSize: 9,
                              fontWeight: active ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'LÍMITE DE TIEMPO:',
                    style: TextStyle(
                      color: Colors.white38,
                      fontFamily: 'Courier',
                      fontSize: 9,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      (0, 'SIN LÍMITE'),
                      (60, '1 MIN'),
                      (180, '3 MIN'),
                      (300, '5 MIN'),
                    ].map((pair) {
                      final active = selectedDuration == pair.$1;
                      return GestureDetector(
                        onTap: () => setState(() => selectedDuration = pair.$1),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            border: Border.all(color: active ? accent : Colors.white10),
                            color: active && pair.$1 > 0 ? accent.withValues(alpha: 0.1) : Colors.transparent,
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: Text(
                            pair.$2,
                            style: TextStyle(
                              color: active ? accent : Colors.white30,
                              fontFamily: 'Courier',
                              fontSize: 9,
                              fontWeight: active ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  if (level.starsEarned > 0) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: List.generate(
                        3,
                        (i) => Icon(
                          i < level.starsEarned ? Icons.star : Icons.star_border,
                          color: accent,
                          size: 14,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text(
                    'VOLVER',
                    style: TextStyle(
                      color: Colors.white30,
                      fontFamily: 'Courier',
                      fontSize: 11,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    ref.read(settingsProvider.notifier).setCampaignSessionVolume(selectedVolume);
                    ref.read(settingsProvider.notifier).setCampaignSessionDuration(selectedDuration);
                    ref.read(timelineProvider.notifier).startKanjiCampaignLevel(level);
                    context.pop();
                  },
                  child: Text(
                    'START LEVEL ENGINE',
                    style: TextStyle(
                      color: accent,
                      fontFamily: 'Courier',
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          }
        );
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final accent = _accent(settings.accentColor);
    final levels = ref.watch(kanjiLevelProvider)[_selectedCategory] ?? [];

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Icon(Icons.arrow_back_ios, color: accent, size: 20),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'MAPA DE NIVELES KANJI',
                    style: TextStyle(
                      color: accent,
                      fontFamily: 'Courier',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white10, height: 1),

            // Category selector
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: KanjiCategory.values.map((cat) {
                  final sel = _selectedCategory == cat;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategory = cat),
                    child: Container(
                      margin: const EdgeInsets.only(
                        right: 8,
                        top: 6,
                        bottom: 6,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: sel ? accent : Colors.white12,
                        ),
                        color: sel
                            ? accent.withValues(alpha: 0.1)
                            : Colors.transparent,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _categoryLabel(cat),
                        style: TextStyle(
                          color: sel ? accent : Colors.white38,
                          fontFamily: 'Courier',
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const Divider(color: Colors.white10, height: 1),

            // Level grid
            Expanded(
              child: levels.isEmpty
                  ? Center(
                      child: Text(
                        'PRÓXIMAMENTE',
                        style: TextStyle(
                          color: accent.withValues(alpha: 0.3),
                          fontFamily: 'Courier',
                          fontSize: 12,
                          letterSpacing: 3,
                        ),
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(20),
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 72,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            childAspectRatio: 0.9,
                          ),
                      itemCount: levels.length,
                      itemBuilder: (ctx, i) {
                        final level = levels[i];
                        return GestureDetector(
                          onTap: level.isUnlocked
                              ? () => _showLevelPreview(context, level, accent)
                              : null,
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: level.isUnlocked
                                    ? accent.withValues(alpha: 0.3)
                                    : Colors.white.withValues(alpha: 0.05),
                              ),
                              color: level.isUnlocked
                                  ? accent.withValues(alpha: 0.03)
                                  : Colors.transparent,
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Opacity(
                                  opacity: level.isUnlocked ? 1.0 : 0.15,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'L${level.id}',
                                        style: TextStyle(
                                          color: accent,
                                          fontFamily: 'Courier',
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: List.generate(
                                          3,
                                          (si) => Icon(
                                            si < level.starsEarned
                                                ? Icons.star
                                                : Icons.star_border,
                                            color: si < level.starsEarned
                                                ? accent
                                                : accent.withValues(alpha: 0.2),
                                            size: 10,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        level.subCategory,
                                        style: TextStyle(
                                          color: accent.withValues(alpha: 0.5),
                                          fontFamily: 'Courier',
                                          fontSize: 9,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (!level.isUnlocked)
                                  const Positioned(
                                    top: 4,
                                    right: 4,
                                    child: SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: Icon(
                                        Icons.lock_outline,
                                        size: 10,
                                        color: Colors.white24,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── MOTOR DE ADQUISICIÓN (EXPOSICIÓN + PRODUCCIÓN) ───────────────────────────

enum _Phase { passiveExposure, activeProduction }

class _AcquisitionEngine extends ConsumerStatefulWidget {
  const _AcquisitionEngine({
    required this.level,
    required this.accent,
    required this.onCompleted,
  });

  final KanjiLevelModel level;
  final Color accent;
  final void Function(int stars) onCompleted;

  @override
  ConsumerState<_AcquisitionEngine> createState() => _AcquisitionEngineState();
}

class _AcquisitionEngineState extends ConsumerState<_AcquisitionEngine>
    with SingleTickerProviderStateMixin {
  _Phase _phase = _Phase.passiveExposure;
  int _currentIdx = 0;
  int _hits = 0;
  bool _showError = false;

  final TextEditingController _ctrl = TextEditingController();
  final FocusNode _focus = FocusNode();
  late AnimationController _strokeAnim;
  late Animation<double> _strokeProgress;

  List<KanjiModel> _models = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _strokeAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _strokeProgress = CurvedAnimation(
      parent: _strokeAnim,
      curve: Curves.easeInOut,
    );
    _loadModels();
  }

  Future<void> _loadModels() async {
    final repo = CharacterRepository.instance;
    final all = await repo.getAllKanjis();
    final models = <KanjiModel>[];
    for (final char in widget.level.requiredKanjis) {
      final entity = all.where((e) => e.character == char).firstOrNull;
      if (entity != null) {
        models.add(
          KanjiModel(
            character: entity.character,
            onyomi: entity.onyomi,
            kunyomi: entity.kunyomi,
            meanings: entity.meanings,
            radicals: entity.radicals,
            radical: entity.radical,
            jlpt: entity.jlpt,
            joyo: entity.joyo,
            svgPaths: entity.svgPaths,
            kanjidicTranslations: entity.kanjidicTranslations,
            isUnlocked: true,
          ),
        );
      } else {
        // Fallback si no hay datos en la BD aún
        models.add(
          KanjiModel(
            character: char,
            meanings: [char],
            radicals: [],
            isUnlocked: true,
          ),
        );
      }
    }
    if (!mounted) return;
    setState(() {
      _models = models;
      _isLoading = false;
    });
    _playStrokeAnimation();
    _playTts();
  }

  @override
  void dispose() {
    _strokeAnim.dispose();
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  KanjiModel get _current => _models[_currentIdx];

  void _playStrokeAnimation() {
    _strokeAnim.reset();
    _strokeAnim.forward();
  }

  void _playTts() {
    final settings = ref.read(settingsProvider);
    if (settings.enableAudio) {
      AudioFeedbackService.instance.playReading(_current.character);
    }
  }

  void _advanceExposure() {
    if (_currentIdx + 1 < _models.length) {
      setState(() {
        _currentIdx++;
      });
      _playStrokeAnimation();
      _playTts();
    } else {
      // Pasar a fase de producción activa
      setState(() {
        _phase = _Phase.activeProduction;
        _currentIdx = 0;
      });
      _playStrokeAnimation();
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) _focus.requestFocus();
      });
    }
  }

  void _onInputChanged(String val) {
    final target = _current;
    final readings = [
      ...target.kunyomi.map(
        (k) => k.replaceAll('.', '').replaceAll('-', '').toLowerCase(),
      ),
      ...target.onyomi.map((o) => o.toLowerCase()),
    ];

    final lower = val.toLowerCase().trim();

    // Acierto
    if (readings.any((r) => r == lower)) {
      _ctrl.clear();
      if (settings.enableAudio) {
        AudioFeedbackService.instance.playReading(target.character);
      }
      setState(() {
        _hits++;
      });
      _advanceProduction();
      return;
    }

    // Prefijo válido → continue
    if (readings.any((r) => r.startsWith(lower))) return;

    // Error absoluto
    _ctrl.clear();
    HapticFeedback.vibrate();
    setState(() {
      _showError = true;
    });
    Future.delayed(const Duration(milliseconds: 180), () {
      if (mounted) setState(() => _showError = false);
    });
  }

  SettingsState get settings => ref.read(settingsProvider);

  void _advanceProduction() {
    if (_currentIdx + 1 < _models.length) {
      setState(() {
        _currentIdx++;
      });
      _playStrokeAnimation();
    } else {
      _completeLevel();
    }
  }

  void _completeLevel() {
    final total = _models.length;
    final hitRate = _hits / total;
    final stars = hitRate >= 0.9 ? 3 : (hitRate >= 0.7 ? 2 : 1);
    widget.onCompleted(stars);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _models.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(
            color: widget.accent,
            strokeWidth: 1.5,
          ),
        ),
      );
    }

    final accent = widget.accent;
    final kanji = _current;
    final isExposure = _phase == _Phase.passiveExposure;

    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            // Header con progreso
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white38,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    isExposure ? 'FASE I — EXPOSICIÓN' : 'FASE II — PRODUCCIÓN',
                    style: TextStyle(
                      color: accent,
                      fontFamily: 'Courier',
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${_currentIdx + 1}/${_models.length}',
                    style: TextStyle(
                      color: accent.withValues(alpha: 0.5),
                      fontFamily: 'Courier',
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),

            // Barra de progreso
            LinearProgressIndicator(
              value: (_currentIdx + 1) / _models.length,
              backgroundColor: Colors.white10,
              valueColor: AlwaysStoppedAnimation<Color>(accent),
              minHeight: 2,
            ),

            // Lienzo central
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: GestureDetector(
                        onTap: isExposure ? _advanceExposure : null,
                        behavior: HitTestBehavior.opaque,
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                        // Kanji SVG animado
                        GestureDetector(
                          onTap: () {
                            _playStrokeAnimation();
                            _playTts();
                          },
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: constraints.maxWidth * 0.55,
                              maxHeight: constraints.maxHeight * 0.45,
                            ),
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: _showError
                                        ? CyberTheme.errorRed
                                        : accent.withValues(alpha: 0.4),
                                    width: _showError ? 2 : 1,
                                  ),
                                  color: _showError
                                      ? CyberTheme.errorRed.withValues(alpha: 0.05)
                                      : Colors.white.withValues(alpha: 0.01),
                                ),
                                child: kanji.svgPaths.isNotEmpty
                                    ? CustomPaint(
                                        painter: KanjiVgPainter(
                                          svgPaths: kanji.svgPaths,
                                          progress: _strokeProgress,
                                          strokeColor: Colors.white,
                                        ),
                                      )
                                    : FittedBox(
                                        fit: BoxFit.contain,
                                        child: Text(
                                          kanji.character,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 100,
                                            height: 1.0,
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Fase exposición: muestra significado y lectura
                        if (isExposure) ...[
                          if (kanji.meanings.isNotEmpty)
                            Text(
                              kanji.meanings.take(2).join(' / ').toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontFamily: 'Courier',
                                fontSize: 16,
                                fontWeight: FontWeight.w300,
                                letterSpacing: 2,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          const SizedBox(height: 8),
                          if (kanji.kunyomi.isNotEmpty ||
                              kanji.onyomi.isNotEmpty)
                            Text(
                              [
                                if (kanji.kunyomi.isNotEmpty)
                                  kanji.kunyomi.first.replaceAll('.', ''),
                                if (kanji.onyomi.isNotEmpty) kanji.onyomi.first,
                              ].join('  /  '),
                              style: TextStyle(
                                color: accent,
                                fontFamily: 'Courier',
                                fontSize: 14,
                              ),
                            ),
                          const SizedBox(height: 40),
                          Text(
                            '[ TOCAR PARA CONTINUAR ]',
                            style: TextStyle(
                              color: accent.withValues(alpha: 0.4),
                              fontFamily: 'Courier',
                              fontSize: 10,
                              letterSpacing: 2,
                            ),
                          ),
                        ],

                        // Fase producción: oculta pistas
                        if (!isExposure) ...[
                          if (_showError)
                            const Text(
                              'ERROR — REINTENTAR',
                              style: TextStyle(
                                color: CyberTheme.errorRed,
                                fontFamily: 'Courier',
                                fontSize: 11,
                                letterSpacing: 2,
                              ),
                            )
                          else
                            Text(
                              '¿CÓMO SE LEE?',
                              style: TextStyle(
                                color: accent.withValues(alpha: 0.5),
                                fontFamily: 'Courier',
                                fontSize: 11,
                                letterSpacing: 2,
                              ),
                            ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),

            // Input de producción
            if (!isExposure)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: _showError
                            ? CyberTheme.errorRed
                            : accent.withValues(alpha: 0.5),
                        width: 1.5,
                      ),
                    ),
                  ),
                  child: TextField(
                    controller: _ctrl,
                    focusNode: _focus,
                    autofocus: true,
                    style: TextStyle(
                      color: accent,
                      fontFamily: 'Courier',
                      fontSize: 16,
                    ),
                    cursorColor: accent,
                    decoration: InputDecoration(
                      hintText: 'romaji / hiragana...',
                      hintStyle: TextStyle(
                        color: accent.withValues(alpha: 0.2),
                        fontFamily: 'Courier',
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                    ),
                    onChanged: _onInputChanged,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
