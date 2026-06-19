import 'package:flutter/material.dart';
import 'package:kz_core/kz_core.dart';
import 'package:kz_domain/kz_domain.dart';
import '../molecules/grid_cell.dart';

/// ORGANISM: Sección colapsable del inventario (Hiragana o Katakana).
class InventorySection extends StatefulWidget {
  const InventorySection({
    super.key,
    required this.title,
    required this.kanas,
    this.accentColor,
    this.onKanaTap,
    this.initiallyExpanded = true,
  });

  final String title;
  final List<KanaModel> kanas;
  final Color? accentColor;
  final ValueChanged<KanaModel>? onKanaTap;
  final bool initiallyExpanded;

  @override
  State<InventorySection> createState() => _InventorySectionState();
}

class _InventorySectionState extends State<InventorySection> {
  late bool _expanded;
  String? _selectedChar;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.accentColor ?? CyberTheme.defaultAccent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ─── Header colapsable ────────────────────────────────────────────
        GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: accent.withOpacity(0.2)),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _expanded
                      ? Icons.keyboard_arrow_down
                      : Icons.keyboard_arrow_right,
                  color: accent,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  widget.title,
                  style: TextStyle(
                    color: accent,
                    fontFamily: 'Courier',
                    fontSize: 13,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Text(
                  '${widget.kanas.where((k) => k.isUnlocked).length}/${widget.kanas.length}',
                  style: TextStyle(
                    color: CyberTheme.textNeutral.withOpacity(0.4),
                    fontFamily: 'Courier',
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ),

        // ─── Grid de celdas ───────────────────────────────────────────────
        if (_expanded)
          Padding(
            padding: const EdgeInsets.all(8),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 8,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
                childAspectRatio: 1,
              ),
              itemCount: widget.kanas.length,
              itemBuilder: (_, i) {
                final kana = widget.kanas[i];
                return GridCell(
                  kana: kana,
                  accentColor: accent,
                  isExpanded: _selectedChar == kana.character,
                  onTap: () {
                    setState(() {
                      _selectedChar = _selectedChar == kana.character
                          ? null
                          : kana.character;
                    });
                    widget.onKanaTap?.call(kana);
                  },
                );
              },
            ),
          ),
      ],
    );
  }
}
