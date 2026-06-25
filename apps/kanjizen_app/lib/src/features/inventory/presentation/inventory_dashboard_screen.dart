import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kz_core/kz_core.dart';
import 'package:kz_domain/kz_domain.dart';
import 'package:kz_data/kz_data.dart';
import 'package:kz_ui_components/kz_ui_components.dart';
import 'package:kanjizen_app/src/features/inventory/presentation/widgets/character_detail_sheet.dart';
import 'package:kanjizen_app/src/features/home/presentation/general_drawer.dart';

enum KanjiOrganization { grade, jlpt }

// The 214 traditional Kangxi radicals
const List<String> traditionalRadicals = [
  '一',
  '丨',
  '丶',
  '丿',
  '乙',
  '亅',
  '二',
  '亠',
  '人',
  '儿',
  '入',
  '八',
  '冂',
  '冖',
  '冫',
  '几',
  '凵',
  '刀',
  '力',
  '勹',
  '匕',
  '匚',
  '匸',
  '十',
  '卜',
  '卩',
  '厂',
  '厶',
  '又',
  '口',
  '囗',
  '土',
  '士',
  '夂',
  '夊',
  '夕',
  '大',
  '女',
  '子',
  '宀',
  '寸',
  '小',
  '尢',
  '尸',
  '屮',
  '山',
  '巛',
  '工',
  '己',
  '巾',
  '干',
  '幺',
  '广',
  '廴',
  '廾',
  '弋',
  '弓',
  '彐',
  '彡',
  '彳',
  '心',
  '戈',
  '戶',
  '手',
  '支',
  '攴',
  '文',
  '斗',
  '斤',
  '方',
  '无',
  '日',
  '曰',
  '月',
  '木',
  '欠',
  '止',
  '歹',
  '殳',
  '毋',
  '比',
  '毛',
  '氏',
  '气',
  '水',
  '火',
  '爪',
  '父',
  '爻',
  '爿',
  '片',
  '牙',
  '牛',
  '犬',
  '玄',
  '玉',
  '瓜',
  '瓦',
  '甘',
  '生',
  '用',
  '田',
  '疋',
  '疒',
  '癶',
  '白',
  '皮',
  '皿',
  '目',
  '矛',
  '矢',
  '石',
  '示',
  '禸',
  '禾',
  '穴',
  '立',
  '竹',
  '米',
  '糸',
  '缶',
  '羊',
  '羽',
  '老',
  '而',
  '耒',
  '耳',
  '聿',
  '肉',
  '臣',
  '自',
  '至',
  '臼',
  '舌',
  '舛',
  '舟',
  '艮',
  '色',
  '艸',
  '虍',
  '虫',
  '血',
  '行',
  '衣',
  '襾',
  '見',
  '角',
  '言',
  '谷',
  '豆',
  '豕',
  '豸',
  '貝',
  '赤',
  '走',
  '足',
  '身',
  '車',
  '辛',
  '辰',
  '辵',
  '邑',
  '酉',
  '采',
  '里',
  '金',
  '長',
  '門',
  '阜',
  '隶',
  '隹',
  '雨',
  '青',
  '非',
  '面',
  '革',
  '韋',
  '韭',
  '音',
  '頁',
  '風',
  '飛',
  '食',
  '首',
  '香',
  '馬',
  '骨',
  '高',
  '髟',
  '鬥',
  '鬯',
  '鬲',
  '鬼',
  '魚',
  '鳥',
  '鹵',
  '鹿',
  '麥',
  '麻',
  '黄',
  '黍',
  '黒',
  '黹',
  '黽',
  '鼎',
  '鼓',
  '鼠',
  '鼻',
  '齊',
  '齒',
  '龍',
  '龜',
  '龠',
];

const List<String> kanaColumnsOrder = [
  'A-column',
  'K-column',
  'S-column',
  'T-column',
  'N-column',
  'H-column',
  'M-column',
  'Y-column',
  'R-column',
  'W-column',
  'N-column',
  'G-column',
  'Z-column',
  'D-column',
  'B-column',
  'P-column',
];

class InventoryDashboardScreen extends ConsumerStatefulWidget {
  const InventoryDashboardScreen({super.key});

  @override
  ConsumerState<InventoryDashboardScreen> createState() =>
      _InventoryDashboardScreenState();
}

class _InventoryDashboardScreenState
    extends ConsumerState<InventoryDashboardScreen> {
  // Database cache
  List<KanaModel> _allKanas = [];
  List<KanjiModel> _allKanjis = [];
  bool _isLoading = true;

  // Collapsable Tree State
  bool _hiraExpanded = true;
  bool _kataExpanded = false;
  bool _kanjiExpanded = false;

  final Set<String> _expandedHiraColumns = {};
  final Set<String> _expandedKataColumns = {};
  final Set<String> _expandedKanjiGroups = {};

  // Filtering System State
  String _searchQuery = '';
  final Set<int> _selectedGrades = {}; // 1..6, 8 (Jōyō)
  final Set<int> _selectedJLPTs = {}; // 1..5 for N1..N5
  String? _selectedRadical;
  bool _showRadicalGrid = false;
  KanjiOrganization _kanjiOrg = KanjiOrganization.grade;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final repo = CharacterRepository.instance;
    final kEntities = await repo.getAllKanas();
    final kjEntities = await repo.getAllKanjis();

    setState(() {
      _allKanas = kEntities
          .map(
            (e) => KanaModel(
              character: e.character,
              romaji: e.romaji,
              isKatakana: e.isKatakana,
              linkedKanaCharacter: e.linkedKanaCharacter,
              isDakutenOrHandakuten: e.isDakutenOrHandakuten,
              isUnlocked: e.isUnlocked,
              historyBlob: List<int>.from(e.historyBlob),
              currentHitRate: e.currentHitRate,
              averageMs: e.averageMs,
            ),
          )
          .toList();

      _allKanjis = kjEntities
          .map(
            (e) => KanjiModel(
              character: e.character,
              onyomi: e.onyomi,
              kunyomi: e.kunyomi,
              meanings: e.meanings,
              radicals: e.radicals,
              radical: e.radical,
              jlpt: e.jlpt,
              joyo: e.joyo,
              isUnlocked: e.isUnlocked,
              historyBlob: List<int>.from(e.historyBlob),
              currentHitRate: e.currentHitRate,
              averageMs: e.averageMs,
              srsScore: e.srsScore,
              consecutiveFails: e.consecutiveFails,
              kanjidicTranslations: List<String>.from(e.kanjidicTranslations),
            ),
          )
          .toList();

      _isLoading = false;
    });
  }

  String _getKanaColumn(String romaji) {
    final r = romaji.toLowerCase().trim();
    if (r == 'n') return 'N-column';
    if (r.startsWith('k')) return 'K-column';
    if (r.startsWith('s') || r.startsWith('sh')) return 'S-column';
    if (r.startsWith('t') || r.startsWith('ch') || r.startsWith('ts')) {
      return 'T-column';
    }
    if (r.startsWith('n')) return 'N-column';
    if (r.startsWith('h') || r.startsWith('f')) return 'H-column';
    if (r.startsWith('m')) return 'M-column';
    if (r.startsWith('y')) return 'Y-column';
    if (r.startsWith('r')) return 'R-column';
    if (r.startsWith('w')) return 'W-column';
    if (r.startsWith('g')) return 'G-column';
    if (r.startsWith('z') || r.startsWith('j')) return 'Z-column';
    if (r.startsWith('d')) return 'D-column';
    if (r.startsWith('b')) return 'B-column';
    if (r.startsWith('p')) return 'P-column';
    return 'A-column';
  }

  List<KanjiModel> get _filteredKanjis {
    return _allKanjis.where((k) {
      // 1. Text Search query
      if (_searchQuery.isNotEmpty) {
        final sq = _searchQuery.toLowerCase();
        final matchesChar = k.character.contains(sq);
        final matchesMeanings = k.meanings.any(
          (m) => m.toLowerCase().contains(sq),
        );
        final matchesKanjidic = k.kanjidicTranslations.any(
          (t) => t.toLowerCase().contains(sq),
        );
        final matchesOnyomi = k.onyomi.any((o) => o.toLowerCase().contains(sq));
        final matchesKunyomi = k.kunyomi.any(
          (ku) => ku.toLowerCase().contains(sq),
        );
        if (!matchesChar &&
            !matchesMeanings &&
            !matchesKanjidic &&
            !matchesOnyomi &&
            !matchesKunyomi) {
          return false;
        }
      }

      // 2. School Grade Filter (Multi-select OR, AND with others)
      if (_selectedGrades.isNotEmpty) {
        if (!_selectedGrades.contains(k.joyo)) return false;
      }

      // 3. JLPT Filter (Multi-select OR, AND with others)
      if (_selectedJLPTs.isNotEmpty) {
        if (!_selectedJLPTs.contains(k.jlpt)) return false;
      }

      // 4. Radical Filter (AND with others)
      if (_selectedRadical != null) {
        if (k.radical != _selectedRadical &&
            !k.radicals.contains(_selectedRadical)) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  void _showFilterOverlay(Color accent) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF0D0E15),
      shape: Border(top: BorderSide(color: accent, width: 1.5)),
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (ctx, setOverlayState) {
            return Container(
              padding: EdgeInsets.only(
                top: 24,
                left: 24,
                right: 24,
                bottom: MediaQuery.of(ctx).viewInsets.bottom +
                    MediaQuery.of(ctx).padding.bottom +
                    24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                  Text(
                    '// FILTROS AVANZADOS (MULTI-AND)',
                    style: TextStyle(
                      color: accent,
                      fontFamily: 'Courier',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Grade Multi Selector
                  const Text(
                    'GRADO ESCOLAR:',
                    style: TextStyle(
                      color: Colors.white54,
                      fontFamily: 'Courier',
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    children: [1, 2, 3, 4, 5, 6, 8].map((g) {
                      final label = g == 8 ? 'Jōyō' : 'G$g';
                      final isSelected = _selectedGrades.contains(g);
                      return ChoiceChip(
                        label: Text(
                          label,
                          style: TextStyle(
                            color: isSelected ? Colors.black : Colors.white,
                            fontFamily: 'Courier',
                            fontSize: 10,
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: accent,
                        backgroundColor: Colors.white10,
                        showCheckmark: false,
                        onSelected: (val) {
                          setState(() {
                            if (val) {
                              _selectedGrades.add(g);
                            } else {
                              _selectedGrades.remove(g);
                            }
                          });
                          setOverlayState(() {});
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // JLPT Multi Selector
                  const Text(
                    'JLPT LEVEL:',
                    style: TextStyle(
                      color: Colors.white54,
                      fontFamily: 'Courier',
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    children: [5, 4, 3, 2, 1].map((n) {
                      final label = 'N$n';
                      final isSelected = _selectedJLPTs.contains(n);
                      return ChoiceChip(
                        label: Text(
                          label,
                          style: TextStyle(
                            color: isSelected ? Colors.black : Colors.white,
                            fontFamily: 'Courier',
                            fontSize: 10,
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: accent,
                        backgroundColor: Colors.white10,
                        showCheckmark: false,
                        onSelected: (val) {
                          setState(() {
                            if (val) {
                              _selectedJLPTs.add(n);
                            } else {
                              _selectedJLPTs.remove(n);
                            }
                          });
                          setOverlayState(() {});
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _selectedGrades.clear();
                            _selectedJLPTs.clear();
                            _selectedRadical = null;
                            _searchQuery = '';
                          });
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'LIMPIAR FILTROS',
                          style: TextStyle(
                            color: CyberTheme.errorRed,
                            fontFamily: 'Courier',
                            fontSize: 11,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accent,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'APLICAR',
                          style: TextStyle(
                            fontFamily: 'Courier',
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final accent = switch (settings.accentColor) {
      CyberAccent.green => CyberTheme.defaultAccent,
      CyberAccent.red => CyberTheme.errorRed,
      CyberAccent.orange => Colors.orange,
      CyberAccent.blue => Colors.cyanAccent,
      CyberAccent.purple => Colors.purpleAccent,
      CyberAccent.white => Colors.white,
    };

    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFF0D0E15),
        body: Center(
          child: Text(
            'CARGANDO TELEMETRÍA DE INVENTARIO...',
            style: TextStyle(
              color: accent,
              fontFamily: 'Courier',
              fontSize: 12,
            ),
          ),
        ),
      );
    }


    // Auto-expandir sección kanji cuando hay filtros activos
    final hasKanjiFilters =
        _selectedGrades.isNotEmpty ||
        _selectedJLPTs.isNotEmpty ||
        _selectedRadical != null ||
        _searchQuery.isNotEmpty;
    if (hasKanjiFilters && !_kanjiExpanded) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _kanjiExpanded = true);
      });
    }

    // Build list of active filters for text display
    final List<String> activeFilterTags = [];
    if (_searchQuery.isNotEmpty) activeFilterTags.add('"$_searchQuery"');
    if (_selectedGrades.isNotEmpty) {
      activeFilterTags.add(
        'Grados: ${_selectedGrades.map((g) => g == 8 ? "Jōyō" : "G$g").join(", ")}',
      );
    }
    if (_selectedJLPTs.isNotEmpty) {
      activeFilterTags.add(
        'JLPT: ${_selectedJLPTs.map((n) => "N$n").join(", ")}',
      );
    }
    if (_selectedRadical != null) {
      activeFilterTags.add('Rad: $_selectedRadical');
    }

    final filterText = activeFilterTags.isEmpty
        ? 'Ninguno (Tocar para filtrar)'
        : activeFilterTags.join(' | ');

    return Scaffold(
      backgroundColor: const Color(0xFF0D0E15),
      drawer: GeneralDrawer(accent: accent),
      body: SafeArea(
        child: Column(
          children: [
            // ── GLOBAL HEADER ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Builder(
                    builder: (ctx) => GestureDetector(
                      onTap: () => Scaffold.of(ctx).openDrawer(),
                      child: const Icon(
                        Icons.menu,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'INVENTARIO DENSE',
                    style: TextStyle(
                      color: accent,
                      fontFamily: 'Courier',
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 20),
                ],
              ),
            ),
            const Divider(color: Colors.white10, height: 1),

            // ── PERSISTENT FILTER BAR ───────────────────────────────────
            GestureDetector(
              onTap: () => _showFilterOverlay(accent),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                color: Colors.white.withValues(alpha: 0.01),
                child: Row(
                  children: [
                    Icon(Icons.filter_list, color: accent, size: 14),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '[ $filterText ]',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontFamily: 'Courier',
                          fontSize: 10,
                        ),
                      ),
                    ),
                    if (activeFilterTags.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedGrades.clear();
                            _selectedJLPTs.clear();
                            _selectedRadical = null;
                            _searchQuery = '';
                          });
                        },
                        child: const Icon(
                          Icons.clear,
                          color: CyberTheme.errorRed,
                          size: 14,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const Divider(color: Colors.white10, height: 1),

            // ── SEARCH BAR & RADICAL OVERLAY BUTTONS ────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 36,
                      child: TextField(
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'Courier',
                          fontSize: 12,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Buscar...',
                          hintStyle: const TextStyle(
                            color: Colors.white24,
                            fontFamily: 'Courier',
                          ),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.04),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 0,
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(2),
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: accent,
                            size: 14,
                          ),
                        ),
                        onChanged: (val) => setState(() => _searchQuery = val),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () =>
                        setState(() => _showRadicalGrid = !_showRadicalGrid),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _showRadicalGrid ? accent : Colors.white10,
                        ),
                        color: _showRadicalGrid
                            ? accent.withValues(alpha: 0.1)
                            : Colors.transparent,
                      ),
                      child: Text(
                        _showRadicalGrid ? '[X] RADICALES' : '[ ] RADICALES',
                        style: TextStyle(
                          color: _showRadicalGrid ? accent : Colors.white54,
                          fontFamily: 'Courier',
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white10, height: 1),

            // ── MAIN CONTENT VIEW (RADICAL GRID OR CLASSIFICATION TREE) ─
            Expanded(
              child: CustomScrollView(
                slivers: _buildSlivers(accent),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildSlivers(Color accent) {
    final List<Widget> slivers = [];

    if (_showRadicalGrid) {
      slivers.add(
        SliverPadding(
          padding: const EdgeInsets.all(8),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 12,
              crossAxisSpacing: 2,
              mainAxisSpacing: 2,
              childAspectRatio: 1.0,
            ),
            delegate: SliverChildBuilderDelegate(
              (ctx, i) {
                if (i >= traditionalRadicals.length) {
                  return Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.cyan.withValues(alpha: 0.05)),
                    ),
                  );
                }
                final rad = traditionalRadicals[i];
                final isSelected = _selectedRadical == rad;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedRadical = rad;
                      _showRadicalGrid = false;
                      _kanjiExpanded = true;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.cyan.withValues(alpha: 0.2)
                          : Colors.transparent,
                      border: Border.all(
                        color: isSelected
                            ? Colors.cyanAccent
                            : Colors.cyan.withValues(alpha: 0.2),
                        width: isSelected ? 1.5 : 0.8,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      rad,
                      style: TextStyle(
                        color: isSelected ? Colors.cyanAccent : Colors.white70,
                        fontFamily: 'Courier',
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
              childCount: 216,
            ),
          ),
        ),
      );
      return slivers;
    }

    final hira = _allKanas.where((k) => !k.isKatakana).toList();
    final kata = _allKanas.where((k) => k.isKatakana).toList();
    final kanjis = _filteredKanjis;

    // SECTION 1: HIRAGANA
    slivers.add(
      SliverToBoxAdapter(
        child: _buildHiraganaHeader(hira, accent),
      ),
    );

    if (_hiraExpanded) {
      final Map<String, List<KanaModel>> groups = {};
      for (final col in kanaColumnsOrder) {
        groups[col] = [];
      }
      for (final k in hira) {
        final col = _getKanaColumn(k.romaji);
        groups.putIfAbsent(col, () => []).add(k);
      }

      for (final col in kanaColumnsOrder) {
        final list = groups[col] ?? [];
        if (list.isEmpty) continue;
        final isColExpanded = _expandedHiraColumns.contains(col);

        slivers.add(
          SliverToBoxAdapter(
            child: _buildHiraganaSubHeader(col, list, isColExpanded),
          ),
        );

        if (isColExpanded) {
          slivers.add(
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 4.0),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  crossAxisSpacing: 6,
                  mainAxisSpacing: 6,
                  childAspectRatio: 1.2,
                ),
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) => _buildKanaCell(list[i], accent),
                  childCount: list.length,
                ),
              ),
            ),
          );
        }
      }
    }

    // Divider between sections
    slivers.add(const SliverToBoxAdapter(child: SizedBox(height: 12)));

    // SECTION 2: KATAKANA
    slivers.add(
      SliverToBoxAdapter(
        child: _buildKatakanaHeader(kata, accent),
      ),
    );

    if (_kataExpanded) {
      final Map<String, List<KanaModel>> groups = {};
      for (final col in kanaColumnsOrder) {
        groups[col] = [];
      }
      for (final k in kata) {
        final col = _getKanaColumn(k.romaji);
        groups.putIfAbsent(col, () => []).add(k);
      }

      for (final col in kanaColumnsOrder) {
        final list = groups[col] ?? [];
        if (list.isEmpty) continue;
        final isColExpanded = _expandedKataColumns.contains(col);

        slivers.add(
          SliverToBoxAdapter(
            child: _buildKatakanaSubHeader(col, list, isColExpanded),
          ),
        );

        if (isColExpanded) {
          slivers.add(
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 4.0),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  crossAxisSpacing: 6,
                  mainAxisSpacing: 6,
                  childAspectRatio: 1.2,
                ),
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) => _buildKanaCell(list[i], accent),
                  childCount: list.length,
                ),
              ),
            ),
          );
        }
      }
    }

    // Divider between sections
    slivers.add(const SliverToBoxAdapter(child: SizedBox(height: 12)));

    // SECTION 3: KANJI
    slivers.add(
      SliverToBoxAdapter(
        child: _buildKanjiHeader(kanjis, accent),
      ),
    );

    if (_kanjiExpanded) {
      slivers.add(
        SliverToBoxAdapter(
          child: _buildKanjiOrgToggles(accent),
        ),
      );

      final Map<String, List<KanjiModel>> groups = {};
      if (_kanjiOrg == KanjiOrganization.grade) {
        for (final g in [1, 2, 3, 4, 5, 6, 8]) {
          final label = g == 8 ? 'Jōyō' : 'Grado $g';
          groups[label] = [];
        }
        for (final k in kanjis) {
          final label =
              k.joyo == 8 ||
                  (k.joyo != 1 &&
                      k.joyo != 2 &&
                      k.joyo != 3 &&
                      k.joyo != 4 &&
                      k.joyo != 5 &&
                      k.joyo != 6)
              ? 'Jōyō'
              : 'Grado ${k.joyo}';
          groups.putIfAbsent(label, () => []).add(k);
        }
      } else {
        for (final jl in [5, 4, 3, 2, 1]) {
          groups['N$jl'] = [];
        }
        for (final k in kanjis) {
          final label = 'N${k.jlpt}';
          groups.putIfAbsent(label, () => []).add(k);
        }
      }

      final groupKeys = groups.keys.where((k) => groups[k]!.isNotEmpty).toList();

      for (final group in groupKeys) {
        final list = groups[group]!;
        final isGroupExpanded = _expandedKanjiGroups.contains(group);

        slivers.add(
          SliverToBoxAdapter(
            child: _buildKanjiGroupHeader(group, list, isGroupExpanded),
          ),
        );

        if (isGroupExpanded) {
          slivers.add(
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 4.0),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  crossAxisSpacing: 6,
                  mainAxisSpacing: 6,
                  childAspectRatio: 1.0,
                ),
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) => _buildKanjiCell(list[i], accent),
                  childCount: list.length,
                ),
              ),
            ),
          );
        }
      }
    }

    return slivers;
  }

  Widget _buildHiraganaHeader(List<KanaModel> items, Color accent) {
    return GestureDetector(
      onTap: () => setState(() => _hiraExpanded = !_hiraExpanded),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white10),
          color: Colors.white.withValues(alpha: 0.02),
        ),
        child: Row(
          children: [
            Text(
              _hiraExpanded ? '[-] HIRAGANA' : '[+] HIRAGANA',
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
              '${items.where((k) => k.isUnlocked).length} DESBLOQUEADOS',
              style: const TextStyle(
                color: Colors.white30,
                fontFamily: 'Courier',
                fontSize: 9,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHiraganaSubHeader(String col, List<KanaModel> list, bool isColExpanded) {
    return GestureDetector(
      onTap: () => setState(() {
        if (isColExpanded) {
          _expandedHiraColumns.remove(col);
        } else {
          _expandedHiraColumns.add(col);
        }
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        margin: const EdgeInsets.only(left: 12),
        child: Row(
          children: [
            Text(
              isColExpanded ? '  ▼ $col' : '  ▶ $col',
              style: const TextStyle(
                color: Colors.white70,
                fontFamily: 'Courier',
                fontSize: 10,
              ),
            ),
            const Spacer(),
            Text(
              '${list.length} ítems',
              style: const TextStyle(
                color: Colors.white24,
                fontFamily: 'Courier',
                fontSize: 9,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKatakanaHeader(List<KanaModel> items, Color accent) {
    return GestureDetector(
      onTap: () => setState(() => _kataExpanded = !_kataExpanded),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white10),
          color: Colors.white.withValues(alpha: 0.02),
        ),
        child: Row(
          children: [
            Text(
              _kataExpanded ? '[-] KATAKANA' : '[+] KATAKANA',
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
              '${items.where((k) => k.isUnlocked).length} DESBLOQUEADOS',
              style: const TextStyle(
                color: Colors.white30,
                fontFamily: 'Courier',
                fontSize: 9,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKatakanaSubHeader(String col, List<KanaModel> list, bool isColExpanded) {
    return GestureDetector(
      onTap: () => setState(() {
        if (isColExpanded) {
          _expandedKataColumns.remove(col);
        } else {
          _expandedKataColumns.add(col);
        }
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        margin: const EdgeInsets.only(left: 12),
        child: Row(
          children: [
            Text(
              isColExpanded ? '  ▼ $col' : '  ▶ $col',
              style: const TextStyle(
                color: Colors.white70,
                fontFamily: 'Courier',
                fontSize: 10,
              ),
            ),
            const Spacer(),
            Text(
              '${list.length} ítems',
              style: const TextStyle(
                color: Colors.white24,
                fontFamily: 'Courier',
                fontSize: 9,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKanjiHeader(List<KanjiModel> items, Color accent) {
    return GestureDetector(
      onTap: () => setState(() => _kanjiExpanded = !_kanjiExpanded),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white10),
          color: Colors.white.withValues(alpha: 0.02),
        ),
        child: Row(
          children: [
            Text(
              _kanjiExpanded ? '[-] KANJI' : '[+] KANJI',
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
              '${items.length} FILTRADOS',
              style: const TextStyle(
                color: Colors.white30,
                fontFamily: 'Courier',
                fontSize: 9,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKanjiOrgToggles(Color accent) {
    return Padding(
      padding: const EdgeInsets.only(left: 12.0, top: 8.0, bottom: 4.0),
      child: Row(
        children: [
          const Text(
            'ESTRUCTURA:',
            style: TextStyle(
              color: Colors.white38,
              fontFamily: 'Courier',
              fontSize: 9,
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => setState(() => _kanjiOrg = KanjiOrganization.grade),
            child: Text(
              '[ GRADO ESCOLAR ]',
              style: TextStyle(
                color: _kanjiOrg == KanjiOrganization.grade ? accent : Colors.white24,
                fontFamily: 'Courier',
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => setState(() => _kanjiOrg = KanjiOrganization.jlpt),
            child: Text(
              '[ JLPT ]',
              style: TextStyle(
                color: _kanjiOrg == KanjiOrganization.jlpt ? accent : Colors.white24,
                fontFamily: 'Courier',
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKanjiGroupHeader(String group, List<KanjiModel> list, bool isGroupExpanded) {
    return GestureDetector(
      onTap: () => setState(() {
        if (isGroupExpanded) {
          _expandedKanjiGroups.remove(group);
        } else {
          _expandedKanjiGroups.add(group);
        }
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        margin: const EdgeInsets.only(left: 12),
        child: Row(
          children: [
            Text(
              isGroupExpanded ? '  ▼ $group' : '  ▶ $group',
              style: const TextStyle(
                color: Colors.white70,
                fontFamily: 'Courier',
                fontSize: 10,
              ),
            ),
            const Spacer(),
            Text(
              '${list.length} ítems',
              style: const TextStyle(
                color: Colors.white24,
                fontFamily: 'Courier',
                fontSize: 9,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKanaCell(KanaModel k, Color accent) {
    return GestureDetector(
      onTap: k.isUnlocked ? () => _showCharDetail(k, accent) : null,
      child: Container(
        decoration: BoxDecoration(
          color: k.isUnlocked
              ? accent.withValues(alpha: 0.03)
              : Colors.transparent,
          border: Border.all(
            color: k.isUnlocked
                ? accent.withValues(alpha: 0.3)
                : Colors.white.withValues(alpha: 0.05),
          ),
          borderRadius: BorderRadius.circular(2),
        ),
        alignment: Alignment.center,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              k.character,
              style: TextStyle(
                color: k.isUnlocked ? Colors.white : Colors.white10,
                fontSize: 18,
                fontWeight: k.isUnlocked ? FontWeight.normal : FontWeight.w100,
              ),
            ),
            if (!k.isUnlocked)
              const Positioned(
                top: 2,
                right: 2,
                child: Icon(
                  Icons.lock_outline,
                  size: 8,
                  color: Colors.white12,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildKanjiCell(KanjiModel k, Color accent) {
    return GestureDetector(
      onTap: () => _showCharDetail(k, accent),
      child: Container(
        decoration: BoxDecoration(
          color: k.isUnlocked
              ? accent.withValues(alpha: 0.05)
              : Colors.red.withValues(alpha: 0.02),
          border: Border.all(
            color: k.isUnlocked
                ? accent.withValues(alpha: 0.4)
                : Colors.red.withValues(alpha: 0.15),
            width: k.isUnlocked ? 1.0 : 0.8,
          ),
          borderRadius: BorderRadius.circular(2),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Kanji vector shape
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: k.svgPaths.isNotEmpty
                    ? CustomPaint(
                        painter: KanjiVectorPainter(
                          svgPaths: k.svgPaths,
                          accentColor: k.isUnlocked ? accent : Colors.red,
                          progress: 1.0,
                        ),
                      )
                    : Center(
                        child: Text(
                          k.character,
                          style: TextStyle(
                            color: k.isUnlocked
                                ? Colors.white
                                : Colors.white10,
                            fontFamily: 'Courier',
                            fontSize: 22,
                          ),
                        ),
                      ),
              ),
            ),
            // Locked / Unlocked badge or indicators
            if (!k.isUnlocked)
              Positioned(
                top: 2,
                right: 2,
                child: Icon(
                  Icons.lock,
                  size: 8,
                  color: Colors.red.withValues(alpha: 0.3),
                ),
              )
            else ...[
              // Unlocked info: e.g. SRS score or level
              Positioned(
                bottom: 2,
                right: 3,
                child: Text(
                  k.srsScore.toStringAsFixed(1),
                  style: TextStyle(
                    color: accent.withValues(alpha: 0.6),
                    fontFamily: 'Courier',
                    fontSize: 7,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (k.jlpt > 0)
                Positioned(
                  top: 2,
                  left: 3,
                  child: Text(
                    'N${k.jlpt}',
                    style: const TextStyle(
                      color: Colors.white30,
                      fontFamily: 'Courier',
                      fontSize: 6,
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  void _showCharDetail(Object model, Color accent) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CharacterDetailSheet(model: model, accent: accent),
    );
  }
}
