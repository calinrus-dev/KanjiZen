import 'package:flutter/material.dart';
import 'package:kz_core/kz_core.dart';
import 'package:kz_data/kz_data.dart';
import 'package:kz_domain/kz_domain.dart';
import 'package:kz_ui_components/kz_ui_components.dart';

/// InventoryScreen — listas colapsables Hiragana + Katakana.
/// Puede usarse como Screen completa o como contenido de Drawer.
class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key, this.kanas});

  final List<KanaModel>? kanas;

  @override
  Widget build(BuildContext context) {
    final accent = CyberTheme.defaultAccent;
    final allKanas = kanas ?? [];
    final hiragana = allKanas.where((k) => !k.isKatakana).toList();
    final katakana = allKanas.where((k) => k.isKatakana).toList();

    return Container(
      color: CyberTheme.bgObsidian,
      child: Column(
        children: [
          // ─── Header ─────────────────────────────────────────────────────
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 12,
              left: 16,
              right: 16,
              bottom: 12,
            ),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: accent.withOpacity(0.2)),
              ),
            ),
            child: Row(
              children: [
                if (Navigator.canPop(context))
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(
                      Icons.close,
                      color: accent.withOpacity(0.6),
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
          ),

          // ─── Listas ──────────────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  if (hiragana.isNotEmpty)
                    InventorySection(
                      title: 'HIRAGANA',
                      kanas: hiragana,
                      accentColor: accent,
                      onKanaTap: (kana) {
                        CyberZenModal.show(
                          context,
                          kana,
                          () => AudioFeedbackService.instance.playReading(
                            kana.character,
                          ),
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
                          context,
                          kana,
                          () => AudioFeedbackService.instance.playReading(
                            kana.character,
                          ),
                        );
                      },
                    ),
                  if (allKanas.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(
                        'Cargando inventario...',
                        style: TextStyle(
                          color: accent.withOpacity(0.3),
                          fontFamily: 'Courier',
                          fontSize: 12,
                        ),
                      ),
                    ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
