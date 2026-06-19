import 'package:flutter/material.dart';
import 'package:kz_core/kz_core.dart';
import 'package:kz_data/kz_data.dart';
import 'package:kz_domain/kz_domain.dart';
import 'package:kz_ui_components/kz_ui_components.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// InventoryScreen — listas colapsables Hiragana + Katakana.
/// Puede usarse como Screen completa o como contenido de Drawer
class InventoryScreen extends ConsumerWidget {
  const InventoryScreen({super.key, this.kanas, this.kanjis = const []});

  final List<KanaModel>? kanas;
  final List<KanjiModel> kanjis; // Próximamente se poblará desde el Provider

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final accent = CyberTheme.defaultAccent;

    return DefaultTabController(
      length: 2,
      child: Container(
        color: CyberTheme.bgObsidian,
        child: Column(
          children: [
            // ─── Header con TabBar ──────────────────────────────────────────
            Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 12,
                left: 16,
                right: 16,
              ),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: accent.withValues(alpha: 0.2)),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      if (Navigator.canPop(context))
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Icon(
                            Icons.close,
                            color: accent.withValues(alpha: 0.6),
                            size: 20,
                          ),
                        ),
                      const SizedBox(width: 12),
                      Text(
                        'INVENTARIO',
                        style: TextStyle(
                          color: accent,
                          fontFamily: 'Courier',
                          fontSize: 14,
                          letterSpacing: 3,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TabBar(
                    indicatorColor: accent,
                    labelColor: accent,
                    unselectedLabelColor: accent.withValues(alpha: 0.4),
                    labelStyle: const TextStyle(
                      fontFamily: 'Courier',
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                    tabs: const [
                      Tab(text: 'KANA'),
                      Tab(text: 'KANJI'),
                    ],
                  ),
                ],
              ),
            ),

            // ─── Tab Bar Views ──────────────────────────────────────────────
            Expanded(
              child: TabBarView(
                children: [
                  _KanaTab(kanas: kanas, settings: settings, accent: accent),
                  _KanjiTab(kanjis: kanjis, settings: settings, accent: accent),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _KanaTab extends StatelessWidget {
  const _KanaTab({
    required this.kanas,
    required this.settings,
    required this.accent,
  });

  final List<KanaModel>? kanas;
  final SettingsState settings;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final allKanas = kanas ?? [];
    final hiragana = allKanas.where((k) => !k.isKatakana).toList();
    final katakana = allKanas.where((k) => k.isKatakana).toList();

    return SingleChildScrollView(
      child: Column(
        children: [
          if (hiragana.isNotEmpty)
            InventorySection(
              title: 'HIRAGANA',
              kanas: hiragana,
              accentColor: accent,
              onKanaTap: (kana) {
                CyberZenModal.show(
                  context: context,
                  kana: kana,
                  enableStrokeAnimation: settings.enableStrokeAnimation,
                  onPlayAudio: () {
                    if (settings.enableAudio) {
                      AudioFeedbackService.instance.playReading(kana.character);
                    }
                  },
                );
              },
            ),
          if (katakana.isNotEmpty)
            InventorySection(
              title: 'KATAKANA',
              kanas: katakana,
              accentColor: accent,
              initiallyExpanded: false,
              onKanaTap: (kana) {
                CyberZenModal.show(
                  context: context,
                  kana: kana,
                  enableStrokeAnimation: settings.enableStrokeAnimation,
                  onPlayAudio: () {
                    if (settings.enableAudio) {
                      AudioFeedbackService.instance.playReading(kana.character);
                    }
                  },
                );
              },
            ),
          if (allKanas.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Text(
                'Cargando kana...',
                style: TextStyle(
                  color: accent.withValues(alpha: 0.3),
                  fontFamily: 'Courier',
                  fontSize: 12,
                ),
              ),
            ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _KanjiTab extends StatefulWidget {
  const _KanjiTab({
    required this.kanjis,
    required this.settings,
    required this.accent,
  });

  final List<KanjiModel> kanjis;
  final SettingsState settings;
  final Color accent;

  @override
  State<_KanjiTab> createState() => _KanjiTabState();
}

class _KanjiTabState extends State<_KanjiTab> {
  String? _selectedRadical;

  @override
  Widget build(BuildContext context) {
    // Collect unique radicals
    final radicals = widget.kanjis
        .expand((k) => k.radicals)
        .toSet()
        .toList()
      ..sort();

    final filteredKanjis = _selectedRadical == null
        ? widget.kanjis
        : widget.kanjis.where((k) => k.radicals.contains(_selectedRadical)).toList();

    return Column(
      children: [
        // Filtro de Radicales
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Text(
                'RADICAL:',
                style: TextStyle(
                  color: widget.accent.withValues(alpha: 0.6),
                  fontFamily: 'Courier',
                  fontSize: 12,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String?>(
                    value: _selectedRadical,
                    isExpanded: true,
                    dropdownColor: CyberTheme.bgObsidian,
                    icon: Icon(Icons.arrow_drop_down, color: widget.accent),
                    hint: Text(
                      'TODOS',
                      style: TextStyle(
                        color: widget.accent,
                        fontFamily: 'Courier',
                        fontSize: 14,
                      ),
                    ),
                    style: TextStyle(
                      color: widget.accent,
                      fontFamily: 'Courier',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('TODOS'),
                      ),
                      ...radicals.map(
                        (r) => DropdownMenuItem(
                          value: r,
                          child: Text(r),
                        ),
                      ),
                    ],
                    onChanged: (val) => setState(() => _selectedRadical = val),
                  ),
                ),
              ),
            ],
          ),
        ),
        Divider(color: widget.accent.withValues(alpha: 0.1), height: 1),

        // Grid de Kanjis
        Expanded(
          child: filteredKanjis.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inventory_2_outlined, color: widget.accent.withValues(alpha: 0.2), size: 48),
                      const SizedBox(height: 16),
                      Text(
                        'BASE DE DATOS KANJI VACÍA',
                        style: TextStyle(
                          color: widget.accent.withValues(alpha: 0.4),
                          fontFamily: 'Courier',
                          fontSize: 12,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 6,
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 4,
                  ),
                  itemCount: filteredKanjis.length,
                  itemBuilder: (context, i) {
                    final kanji = filteredKanjis[i];
                    return Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: widget.accent.withValues(alpha: 0.3)),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        kanji.character,
                        style: const TextStyle(
                          color: CyberTheme.textNeutral,
                          fontSize: 24,
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
