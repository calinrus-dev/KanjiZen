import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kz_core/kz_core.dart';
import 'package:kanjizen_app/src/providers/game_provider.dart';

class ProfileDrawer extends ConsumerWidget {
  const ProfileDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameProvider);
    const accent = CyberTheme.defaultAccent; // Se puede leer del settingsProvider

    return Container(
      color: CyberTheme.bgObsidian,
      child: SafeArea(
        child: Column(
          children: [
            // Panel Superior
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('USUARIO_ACTIVO', style: TextStyle(color: accent, fontFamily: 'Courier', fontSize: 18, fontWeight: FontWeight.bold)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(border: Border.all(color: accent), borderRadius: BorderRadius.circular(4)),
                        child: const Text('JLPT N5', style: TextStyle(color: accent, fontFamily: 'Courier', fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _StatColumn('KANJIS', '${state.kanjis.where((k) => k.isUnlocked).length}', accent),
                      const SizedBox(width: 24),
                      _StatColumn('VELOCIDAD', '${state.avgMs}ms', accent),
                      const SizedBox(width: 24),
                      _StatColumn('ACIERTO', '${(state.hitRate * 100).toStringAsFixed(1)}%', accent),
                    ],
                  ),
                  const SizedBox(height: 32),
                  const Text('ACTIVITY GRAPH', style: TextStyle(color: CyberTheme.textNeutral, fontFamily: 'Courier', fontSize: 12)),
                  const SizedBox(height: 12),
                  // Contenedor estático del graph por ahora
                  SizedBox(
                    height: 80,
                    width: double.infinity,
                    child: CustomPaint(
                      painter: ActivityGraphPainter(accent: accent),
                    ),
                  ),
                ],
              ),
            ),
            Divider(color: accent.withValues(alpha: 0.2), height: 1),
            
            // Desglose Estadístico Inferior
            Expanded(
              child: DefaultTabController(
                length: 3,
                child: Column(
                  children: [
                    TabBar(
                      indicatorColor: accent,
                      labelColor: accent,
                      unselectedLabelColor: CyberTheme.textNeutral,
                      labelStyle: const TextStyle(fontFamily: 'Courier', fontSize: 10, fontWeight: FontWeight.bold),
                      tabs: const [Tab(text: 'KANA'), Tab(text: 'KANJI'), Tab(text: 'MECA')],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          _AnalyticsTab(mode: 'KANA', accent: accent),
                          _AnalyticsTab(mode: 'KANJI', accent: accent),
                          _AnalyticsTab(mode: 'MECA', accent: accent),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Botón Compartir
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.share, color: CyberTheme.bgObsidian, size: 16),
                  label: const Text('COMPARTIR INFORME', style: TextStyle(color: CyberTheme.bgObsidian, fontFamily: 'Courier', fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn(this.label, this.value, this.color);
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: CyberTheme.textNeutral, fontFamily: 'Courier', fontSize: 10)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: color, fontFamily: 'Courier', fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _AnalyticsTab extends StatelessWidget {
  const _AnalyticsTab({required this.mode, required this.accent});
  final String mode;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('TIEMPOS DE REACCIÓN', style: TextStyle(color: CyberTheme.textNeutral, fontFamily: 'Courier', fontSize: 12)),
        const SizedBox(height: 8),
        Container(
          height: 100,
          decoration: BoxDecoration(
            border: Border.all(color: accent.withValues(alpha: 0.2)),
            borderRadius: BorderRadius.circular(4),
          ),
          alignment: Alignment.center,
          child: Text('GRÁFICA: $mode', style: TextStyle(color: accent.withValues(alpha: 0.5))),
        ),
        const SizedBox(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('5 DOMINANTES', style: TextStyle(color: accent, fontFamily: 'Courier', fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...List.generate(5, (i) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text('${i+1}. あ (0.9s)', style: const TextStyle(color: CyberTheme.textNeutral, fontFamily: 'Courier', fontSize: 14)),
                  )),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('5 CRÍTICOS', style: TextStyle(color: CyberTheme.errorRed, fontFamily: 'Courier', fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...List.generate(5, (i) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text('${i+1}. ぬ (3.2s)', style: const TextStyle(color: CyberTheme.textNeutral, fontFamily: 'Courier', fontSize: 14)),
                  )),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class ActivityGraphPainter extends CustomPainter {
  const ActivityGraphPainter({required this.accent});
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final cols = 52;
    final rows = 7;
    
    final cellWidth = (size.width - (cols - 1) * 2) / cols;
    final cellHeight = (size.height - (rows - 1) * 2) / rows;
    
    for (int x = 0; x < cols; x++) {
      for (int y = 0; y < rows; y++) {
        final left = x * (cellWidth + 2);
        final top = y * (cellHeight + 2);
        
        // Mock data: randomly light up cells
        final rand = (x * 7 + y) % 10;
        if (rand > 7) {
          paint.color = accent;
        } else if (rand > 4) {
          paint.color = accent.withValues(alpha: 0.5);
        } else {
          paint.color = accent.withValues(alpha: 0.1);
        }
        
        canvas.drawRect(Rect.fromLTWH(left, top, cellWidth, cellHeight), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
