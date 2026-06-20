import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kz_core/kz_core.dart';
import 'package:kz_domain/kz_domain.dart';
import 'package:kanjizen_app/src/providers/game_provider.dart';

Color _resolveAccent(CyberAccent c) => switch (c) {
  CyberAccent.green => CyberTheme.defaultAccent,
  CyberAccent.red => CyberTheme.errorRed,
  CyberAccent.orange => Colors.orange,
  CyberAccent.blue => Colors.cyanAccent,
  CyberAccent.purple => Colors.purpleAccent,
  CyberAccent.white => Colors.white,
};

class ProfileDrawer extends ConsumerWidget {
  const ProfileDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameProvider);
    final settings = ref.watch(settingsProvider);
    final accent = _resolveAccent(settings.accentColor);

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
                      Text(
                        'USUARIO_ACTIVO',
                        style: TextStyle(
                          color: accent,
                          fontFamily: 'Courier',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: accent),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'JLPT N5',
                          style: TextStyle(
                            color: accent,
                            fontFamily: 'Courier',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _StatColumn(
                        'KANJIS',
                        '${state.kanjis.where((k) => k.isUnlocked).length}',
                        accent,
                      ),
                      const SizedBox(width: 24),
                      _StatColumn('VELOCIDAD', '${state.avgMs}ms', accent),
                      const SizedBox(width: 24),
                      _StatColumn(
                        'ACIERTO',
                        '${(state.hitRate * 100).toStringAsFixed(1)}%',
                        accent,
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'ACTIVITY GRAPH',
                    style: TextStyle(
                      color: CyberTheme.textNeutral,
                      fontFamily: 'Courier',
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Contenedor estático del graph por ahora
                  const SizedBox(
                    height: 80,
                    width: double.infinity,
                    child: CustomPaint(
                      painter: ActivityGraphPainter(
                        accent: CyberTheme.defaultAccent,
                      ),
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
                      labelStyle: const TextStyle(
                        fontFamily: 'Courier',
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      tabs: const [
                        Tab(text: 'KANA'),
                        Tab(text: 'KANJI'),
                        Tab(text: 'MECA'),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          _AnalyticsTab(
                            mode: 'KANA',
                            accent: accent,
                            kanas: state.kanas,
                            kanjis: state.kanjis,
                          ),
                          _AnalyticsTab(
                            mode: 'KANJI',
                            accent: accent,
                            kanas: state.kanas,
                            kanjis: state.kanjis,
                          ),
                          _AnalyticsTab(
                            mode: 'MECA',
                            accent: accent,
                            kanas: state.kanas,
                            kanjis: state.kanjis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Botones de acción inferiores
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        // Abre ajustes como overlay desde el EngineSelectorScreen
                        showModalBottomSheet<void>(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: const Color(0xFF0D0E15),
                          shape: Border(
                            top: BorderSide(color: accent, width: 1.5),
                          ),
                          builder: (_) => _SettingsSheetContent(accent: accent),
                        );
                      },
                      icon: const Icon(
                        Icons.settings_outlined,
                        color: CyberTheme.bgObsidian,
                        size: 16,
                      ),
                      label: const Text(
                        'AJUSTES',
                        style: TextStyle(
                          color: CyberTheme.bgObsidian,
                          fontFamily: 'Courier',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: Icon(Icons.share, color: accent, size: 16),
                      label: Text(
                        'COMPARTIR INFORME',
                        style: TextStyle(
                          color: accent,
                          fontFamily: 'Courier',
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: accent.withValues(alpha: 0.4)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                ],
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
        Text(
          label,
          style: const TextStyle(
            color: CyberTheme.textNeutral,
            fontFamily: 'Courier',
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontFamily: 'Courier',
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _AnalyticsTab extends StatelessWidget {
  const _AnalyticsTab({
    required this.mode,
    required this.accent,
    required this.kanas,
    required this.kanjis,
  });

  final String mode;
  final Color accent;
  final List<KanaModel> kanas;
  final List<KanjiModel> kanjis;

  @override
  Widget build(BuildContext context) {
    // Calcular dinámicamente dominantes y críticos
    final List<String> dominantItems = [];
    final List<String> criticalItems = [];

    if (mode == 'KANA') {
      final candidates = kanas
          .where((KanaModel k) => k.isUnlocked && k.historyBlob.isNotEmpty)
          .toList();
      final sortedDom = List<KanaModel>.from(candidates)
        ..sort((KanaModel a, KanaModel b) {
          final cmp = b.currentHitRate.compareTo(a.currentHitRate);
          if (cmp != 0) return cmp;
          return a.averageMs.compareTo(b.averageMs);
        });
      final sortedCrit = List<KanaModel>.from(candidates)
        ..sort((KanaModel a, KanaModel b) {
          final cmp = a.currentHitRate.compareTo(b.currentHitRate);
          if (cmp != 0) return cmp;
          return b.averageMs.compareTo(a.averageMs);
        });
      dominantItems.addAll(
        sortedDom
            .take(5)
            .map(
              (KanaModel k) =>
                  '${k.character} (${(k.averageMs / 1000.0).toStringAsFixed(1)}s)',
            ),
      );
      criticalItems.addAll(
        sortedCrit
            .take(5)
            .map(
              (KanaModel k) =>
                  '${k.character} (${(k.averageMs / 1000.0).toStringAsFixed(1)}s)',
            ),
      );
    } else if (mode == 'KANJI') {
      final candidates = kanjis
          .where((KanjiModel k) => k.isUnlocked && k.historyBlob.isNotEmpty)
          .toList();
      final sortedDom = List<KanjiModel>.from(candidates)
        ..sort((KanjiModel a, KanjiModel b) {
          final cmp = b.currentHitRate.compareTo(a.currentHitRate);
          if (cmp != 0) return cmp;
          return a.averageMs.compareTo(b.averageMs);
        });
      final sortedCrit = List<KanjiModel>.from(candidates)
        ..sort((KanjiModel a, KanjiModel b) {
          final cmp = a.currentHitRate.compareTo(b.currentHitRate);
          if (cmp != 0) return cmp;
          return b.averageMs.compareTo(a.averageMs);
        });
      dominantItems.addAll(
        sortedDom
            .take(5)
            .map(
              (KanjiModel k) =>
                  '${k.character} (${(k.averageMs / 1000.0).toStringAsFixed(1)}s)',
            ),
      );
      criticalItems.addAll(
        sortedCrit
            .take(5)
            .map(
              (KanjiModel k) =>
                  '${k.character} (${(k.averageMs / 1000.0).toStringAsFixed(1)}s)',
            ),
      );
    } else {
      // MECA (mismo peso para kanas y kanjis)
      final List<({String character, int averageMs})> candKana = kanas
          .where((KanaModel k) => k.isUnlocked && k.historyBlob.isNotEmpty)
          .map(
            (KanaModel k) => (character: k.character, averageMs: k.averageMs),
          )
          .toList();
      final List<({String character, int averageMs})> candKanji = kanjis
          .where((KanjiModel k) => k.isUnlocked && k.historyBlob.isNotEmpty)
          .map(
            (KanjiModel k) => (character: k.character, averageMs: k.averageMs),
          )
          .toList();
      final List<({String character, int averageMs})> candidates = [
        ...candKana,
        ...candKanji,
      ];
      final sortedDom = List<({String character, int averageMs})>.from(
        candidates,
      )..sort((a, b) => a.averageMs.compareTo(b.averageMs));
      final sortedCrit = List<({String character, int averageMs})>.from(
        candidates,
      )..sort((a, b) => b.averageMs.compareTo(a.averageMs));
      dominantItems.addAll(
        sortedDom
            .take(5)
            .map(
              (k) =>
                  '${k.character} (${(k.averageMs / 1000.0).toStringAsFixed(1)}s)',
            ),
      );
      criticalItems.addAll(
        sortedCrit
            .take(5)
            .map(
              (k) =>
                  '${k.character} (${(k.averageMs / 1000.0).toStringAsFixed(1)}s)',
            ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'TIEMPOS DE REACCIÓN',
          style: TextStyle(
            color: CyberTheme.textNeutral,
            fontFamily: 'Courier',
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 100,
          decoration: BoxDecoration(
            border: Border.all(color: accent.withValues(alpha: 0.2)),
            borderRadius: BorderRadius.circular(4),
          ),
          alignment: Alignment.center,
          child: Text(
            'GRÁFICA: $mode',
            style: TextStyle(color: accent.withValues(alpha: 0.5)),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '5 DOMINANTES',
                    style: TextStyle(
                      color: accent,
                      fontFamily: 'Courier',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (dominantItems.isEmpty)
                    const Text(
                      'Sin datos',
                      style: TextStyle(
                        color: Colors.white24,
                        fontFamily: 'Courier',
                        fontSize: 12,
                      ),
                    )
                  else
                    ...dominantItems.asMap().entries.map(
                      (e) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          '${e.key + 1}. ${e.value}',
                          style: const TextStyle(
                            color: CyberTheme.textNeutral,
                            fontFamily: 'Courier',
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '5 CRÍTICOS',
                    style: TextStyle(
                      color: CyberTheme.errorRed,
                      fontFamily: 'Courier',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (criticalItems.isEmpty)
                    const Text(
                      'Sin datos',
                      style: TextStyle(
                        color: Colors.white24,
                        fontFamily: 'Courier',
                        fontSize: 12,
                      ),
                    )
                  else
                    ...criticalItems.asMap().entries.map(
                      (e) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          '${e.key + 1}. ${e.value}',
                          style: const TextStyle(
                            color: CyberTheme.textNeutral,
                            fontFamily: 'Courier',
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
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
    const cols = 52;
    const rows = 7;

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

// ─── SETTINGS SHEET ───────────────────────────────────────────────────────────
class _SettingsSheetContent extends ConsumerWidget {
  const _SettingsSheetContent({required this.accent});
  final Color accent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);
    final n = ref.read(settingsProvider.notifier);

    return SingleChildScrollView(
      padding: EdgeInsets.only(
        top: 24,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '// CONFIGURACIÓN GLOBAL',
                style: TextStyle(
                  color: accent,
                  fontFamily: 'Courier',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Icon(Icons.close, color: accent, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _label('COLOR DE ACENTO'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: CyberAccent.values.map((c) {
              final color = _resolveAccent(c);
              final sel = s.accentColor == c;
              return GestureDetector(
                onTap: () => n.setAccentColor(c),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    border: Border.all(
                      color: sel ? color : Colors.white12,
                      width: sel ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: sel ? Icon(Icons.check, color: color, size: 16) : null,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          _label('GROSOR DE TRAZO SVG'),
          Slider(
            value: s.strokeWidth,
            min: 1.0,
            max: 4.0,
            divisions: 6,
            activeColor: accent,
            inactiveColor: Colors.white12,
            label: '${s.strokeWidth.toStringAsFixed(1)}px',
            onChanged: (v) => n.setStrokeWidth(v),
          ),
          const SizedBox(height: 8),
          _label('VELOCIDAD DE ANIMACIÓN SVG'),
          Slider(
            value: s.strokeAnimationSpeed,
            min: 0.5,
            max: 3.0,
            divisions: 5,
            activeColor: accent,
            inactiveColor: Colors.white12,
            label: '${s.strokeAnimationSpeed.toStringAsFixed(1)}s',
            onChanged: (v) => n.setStrokeAnimationSpeed(v),
          ),
          const SizedBox(height: 8),
          _settingRow(
            'ANIMACIONES DE TRAZO',
            Switch(
              value: s.enableStrokeAnimation,
              onChanged: (_) => n.toggleStrokeAnimation(),
              activeColor: accent,
            ),
          ),
          _settingRow(
            'AUDIO TTS',
            Switch(
              value: s.enableAudio,
              onChanged: (_) => n.toggleEnableAudio(),
              activeColor: accent,
            ),
          ),
          const SizedBox(height: 8),
          _label('TAMAÑO DE REJILLA'),
          Wrap(
            spacing: 8,
            children:
                {
                  GridScale.sl: 'SL',
                  GridScale.l: 'L',
                  GridScale.xl: 'XL',
                  GridScale.auto: 'AUTO',
                }.entries.map((e) {
                  final sel = s.gridScale == e.key;
                  return GestureDetector(
                    onTap: () => n.setGridScale(e.key),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: sel ? accent : Colors.white12,
                        ),
                        color: sel
                            ? accent.withValues(alpha: 0.1)
                            : Colors.transparent,
                      ),
                      child: Text(
                        e.value,
                        style: TextStyle(
                          color: sel ? accent : Colors.white54,
                          fontFamily: 'Courier',
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }).toList(),
          ),
          const SizedBox(height: 16),
          _label('RELOJ DE LA MUERTE'),
          Wrap(
            spacing: 8,
            children:
                {
                  DeathClock.off: 'OFF',
                  DeathClock.s5: '5s',
                  DeathClock.s3: '3s',
                  DeathClock.s1: '1s',
                  DeathClock.s0_5: '0.5s',
                }.entries.map((e) {
                  final sel = s.deathClock == e.key;
                  return GestureDetector(
                    onTap: () => n.setDeathClock(e.key),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: sel ? CyberTheme.errorRed : Colors.white12,
                        ),
                        color: sel
                            ? CyberTheme.errorRed.withValues(alpha: 0.1)
                            : Colors.transparent,
                      ),
                      child: Text(
                        e.value,
                        style: TextStyle(
                          color: sel ? CyberTheme.errorRed : Colors.white54,
                          fontFamily: 'Courier',
                          fontSize: 11,
                        ),
                      ),
                    ),
                  );
                }).toList(),
          ),
          const SizedBox(height: 16),
          _settingRow(
            'MODO HARDCORE',
            Switch(
              value: s.hardcoreMode,
              onChanged: (_) => n.toggleHardcoreMode(),
              activeColor: CyberTheme.errorRed,
            ),
          ),
          _settingRow(
            'ASISTENCIA ROMAJI',
            Switch(
              value: s.romajiAssist,
              onChanged: (_) => n.toggleRomajiAssist(),
              activeColor: accent,
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: const TextStyle(
        color: Colors.white54,
        fontFamily: 'Courier',
        fontSize: 10,
        letterSpacing: 1,
      ),
    ),
  );

  Widget _settingRow(String label, Widget control) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontFamily: 'Courier',
              fontSize: 11,
            ),
          ),
        ),
        control,
      ],
    ),
  );
}
