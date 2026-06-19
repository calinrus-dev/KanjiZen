import 'package:flutter/material.dart';
import 'package:kz_core/kz_core.dart';
import 'package:kz_domain/kz_domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kanjizen_app/src/providers/game_provider.dart';
import 'package:kanjizen_app/src/features/inventory/presentation/kanji_detail_modal.dart';

class InventoryScreen extends ConsumerWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameProvider);
    final settings = ref.watch(settingsProvider);
    final accent = _getAccentColor(settings.accentColor);

    return Scaffold(
      backgroundColor: CyberTheme.bgObsidian,
      body: SafeArea(
        child: DefaultTabController(
          length: 2,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.only(top: 12, left: 16, right: 16),
                decoration: BoxDecoration(border: Border(bottom: BorderSide(color: accent.withValues(alpha: 0.2)))),
                child: Column(
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Icon(Icons.arrow_back_ios, color: accent.withValues(alpha: 0.6), size: 20),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'PERFIL Y DIAGNÓSTICO',
                          style: TextStyle(color: accent, fontFamily: 'Courier', fontSize: 14, letterSpacing: 2, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TabBar(
                      indicatorColor: accent,
                      labelColor: accent,
                      unselectedLabelColor: accent.withValues(alpha: 0.4),
                      labelStyle: const TextStyle(fontFamily: 'Courier', fontWeight: FontWeight.bold, letterSpacing: 2),
                      tabs: const [Tab(text: 'INVENTARIO'), Tab(text: 'MÉTRICAS')],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _InventoryTab(kanas: state.kanas, kanjis: state.kanjis, accent: accent),
                    _MetricsTab(state: state, accent: accent),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getAccentColor(CyberAccent c) {
    switch (c) {
      case CyberAccent.green: return CyberTheme.defaultAccent;
      case CyberAccent.red: return CyberTheme.errorRed;
      case CyberAccent.orange: return Colors.orange;
      case CyberAccent.blue: return Colors.cyanAccent;
      case CyberAccent.purple: return Colors.purpleAccent;
      case CyberAccent.white: return Colors.white;
    }
  }
}

class _InventoryTab extends StatelessWidget {
  const _InventoryTab({required this.kanas, required this.kanjis, required this.accent});
  final List<KanaModel> kanas;
  final List<KanjiModel> kanjis;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final hiragana = kanas.where((k) => !k.isKatakana).toList();
    final katakana = kanas.where((k) => k.isKatakana).toList();

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _SectionHeader('HIRAGANA', accent)),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5, crossAxisSpacing: 8, mainAxisSpacing: 8),
            delegate: SliverChildBuilderDelegate(
              (ctx, i) => _Cell(character: hiragana[i].character, tier: hiragana[i].tier.name.toUpperCase(), isUnlocked: hiragana[i].isUnlocked, accent: accent),
              childCount: hiragana.length,
            ),
          ),
        ),
        SliverToBoxAdapter(child: _SectionHeader('KATAKANA', accent)),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5, crossAxisSpacing: 8, mainAxisSpacing: 8),
            delegate: SliverChildBuilderDelegate(
              (ctx, i) => _Cell(character: katakana[i].character, tier: katakana[i].tier.name.toUpperCase(), isUnlocked: katakana[i].isUnlocked, accent: accent),
              childCount: katakana.length,
            ),
          ),
        ),
        SliverToBoxAdapter(child: _SectionHeader('KANJIS (${kanjis.length})', accent)),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5, crossAxisSpacing: 8, mainAxisSpacing: 8),
            delegate: SliverChildBuilderDelegate(
              (ctx, i) => _Cell(
                character: kanjis[i].character,
                tier: kanjis[i].tier.name.toUpperCase(),
                isUnlocked: kanjis[i].isUnlocked,
                accent: accent,
                onTap: () {
                  KanjiDetailModal.show(
                    context: ctx,
                    kanji: kanjis[i],
                    accent: accent,
                    onForceUnlock: () {},
                    onReset: () {},
                    onLock: () {},
                  );
                },
              ),
              childCount: kanjis.length,
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 40)),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title, this.accent);
  final String title;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: TextStyle(color: accent, fontFamily: 'Courier', fontWeight: FontWeight.bold, letterSpacing: 2),
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell({required this.character, required this.tier, required this.isUnlocked, required this.accent, this.onTap});
  final String character;
  final String tier;
  final bool isUnlocked;
  final Color accent;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    Widget content;
    if (!isUnlocked) {
      content = Container(
        decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(4)),
        alignment: Alignment.center,
        child: const Icon(Icons.lock, color: Colors.grey, size: 16),
      );
    } else {
      content = Container(
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.1),
          border: Border.all(color: accent.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Stack(
          children: [
            Center(child: Text(character, style: TextStyle(color: accent, fontSize: 24))),
            Positioned(
              top: 2, right: 2,
              child: Text(tier, style: TextStyle(color: accent, fontSize: 10, fontFamily: 'Courier', fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: content,
    );
  }
}

class _MetricsTab extends StatelessWidget {
  const _MetricsTab({required this.state, required this.accent});
  final GameState state;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPanel('PRECISIÓN GLOBAL', '${(state.hitRate * 100).toStringAsFixed(1)}%'),
          const SizedBox(height: 16),
          _buildPanel('TIEMPO MEDIO REACCIÓN', '${state.avgMs} ms'),
          const SizedBox(height: 16),
          _buildPanel('RACHA ACTUAL', '${state.streak}'),
          const SizedBox(height: 32),
          const Text('ANÁLISIS DE FALLOS CRÍTICOS', style: TextStyle(color: CyberTheme.textNeutral, fontFamily: 'Courier', fontSize: 12)),
          const SizedBox(height: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(border: Border.all(color: CyberTheme.errorRed.withValues(alpha: 0.3)), borderRadius: BorderRadius.circular(8)),
              child: const Center(
                child: Text('Sin datos suficientes', style: TextStyle(color: CyberTheme.textNeutral)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPanel(String label, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: accent.withValues(alpha: 0.1), border: Border.all(color: accent.withValues(alpha: 0.3)), borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: CyberTheme.textNeutral, fontFamily: 'Courier', fontSize: 12)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(color: accent, fontFamily: 'Courier', fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
