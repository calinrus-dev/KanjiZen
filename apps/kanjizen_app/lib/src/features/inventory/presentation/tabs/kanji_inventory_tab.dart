import 'package:flutter/material.dart';
import 'package:kz_domain/kz_domain.dart';
import 'package:kz_ui_components/kz_ui_components.dart';
import 'package:kz_core/kz_core.dart';

class KanjiInventoryTab extends StatefulWidget {
  const KanjiInventoryTab({
    super.key,
    required this.kanjis,
    required this.settings,
    required this.accent,
  });

  final List<KanjiModel> kanjis;
  final SettingsState settings;
  final Color accent;

  @override
  State<KanjiInventoryTab> createState() => _KanjiInventoryTabState();
}

class _KanjiInventoryTabState extends State<KanjiInventoryTab> {
  String? _selectedRadical;
  bool? _showUnlockedOnly;

  @override
  Widget build(BuildContext context) {
    // Collect unique radicals
    final radicals = widget.kanjis
        .expand((k) => k.radicals)
        .toSet()
        .toList()
      ..sort();

    final filteredKanjis = widget.kanjis.where((k) {
      if (_selectedRadical != null && !k.radicals.contains(_selectedRadical)) return false;
      if (_showUnlockedOnly != null && k.isUnlocked != _showUnlockedOnly) return false;
      return true;
    }).toList();

    return Column(
      children: [
        // Filtro de Radicales y Estado
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
              const SizedBox(width: 16),
              Text(
                'ESTADO:',
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
                  child: DropdownButton<bool?>(
                    value: _showUnlockedOnly,
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
                    items: const [
                      DropdownMenuItem<bool?>(
                        value: null,
                        child: Text('TODOS'),
                      ),
                      DropdownMenuItem<bool?>(
                        value: true,
                        child: Text('DESBLOQ.'),
                      ),
                      DropdownMenuItem<bool?>(
                        value: false,
                        child: Text('BLOQUEADO'),
                      ),
                    ],
                    onChanged: (val) => setState(() => _showUnlockedOnly = val),
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
                    return KanjiGridCell(
                      kanji: kanji,
                      accentColor: widget.accent,
                      onTap: () {
                        KanjiDetailModal.show(
                          context: context,
                          kanji: kanji,
                          enableStrokeAnimation: widget.settings.enableStrokeAnimation,
                        );
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}
