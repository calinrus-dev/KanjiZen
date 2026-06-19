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
            ),
          ),
        ],
      ),
    );
  }
}
