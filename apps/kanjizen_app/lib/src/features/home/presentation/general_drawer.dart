import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kz_core/kz_core.dart';
import 'package:kz_domain/kz_domain.dart';
import 'package:kanjizen_app/src/providers/game_provider.dart';
import 'package:kanjizen_app/src/features/inventory/presentation/inventory_screen.dart';

/// Drawer lateral izquierdo general.
/// Jerarquía: Perfil → Inventario & Diagnóstico → Ajustes → Footer.
class GeneralDrawer extends ConsumerStatefulWidget {
  const GeneralDrawer({super.key, required this.accent});
  final Color accent;

  @override
  ConsumerState<GeneralDrawer> createState() => _GeneralDrawerState();
}

class _GeneralDrawerState extends ConsumerState<GeneralDrawer> {
  bool _showEngineSettings = false;
  bool _showAppearanceSettings = false;

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameProvider);
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final accent = widget.accent;

    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [

                // ── INVENTARIO & DIAGNÓSTICO ─────────────────────────────
                InkWell(
                  onTap: () {
                    Navigator.pop(context); // Close Drawer
                    Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const InventoryScreen()));
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'INVENTARIO & DIAGNÓSTICO',
                            style: TextStyle(
                              color: accent,
                              fontFamily: 'Courier',
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios, color: accent.withValues(alpha: 0.5), size: 14),
                      ],
                    ),
                  ),
                ),

                _Divider(accent),

                // ── AJUSTES: MOTOR ───────────────────────────────────────
                _ExpandableTile(
                  label: 'MOTOR',
                  accent: accent,
                  isOpen: _showEngineSettings,
                  onTap: () => setState(
                      () => _showEngineSettings = !_showEngineSettings),
                  child: Column(
                    children: [
                      _ToggleRow(
                        label: 'SALTAR AL FALLAR',
                        value: settings.skipOnError,
                        accent: accent,
                        onChanged: (_) => notifier.toggleSkipOnError(),
                      ),
                      _ToggleRow(
                        label: 'MODO HARDCORE',
                        value: settings.hardcoreMode,
                        accent: CyberTheme.errorRed,
                        onChanged: (_) => notifier.toggleHardcoreMode(),
                      ),
                      _ToggleRow(
                        label: 'PISTAS ROMAJI',
                        value: settings.showRomajiHints,
                        accent: accent,
                        onChanged: (_) => notifier.toggleRomajiHints(),
                      ),
                      const SizedBox(height: 8),
                      _LabelRow('DEATH CLOCK', accent),
                      const SizedBox(height: 4),
                      _TabSelector<DeathClock>(
                        values: DeathClock.values,
                        labels: const ['OFF', '5s', '3s', '1.5s'],
                        current: settings.deathClock,
                        accent: accent,
                        onChanged: notifier.setDeathClock,
                      ),
                      const SizedBox(height: 8),
                      _LabelRow('SISTEMA PROGRESIVO', accent),
                      const SizedBox(height: 4),
                      _TabSelector<ProgressiveSystem>(
                        values: ProgressiveSystem.values,
                        labels: const ['HIRA', 'KATA', 'AMBOS'],
                        current: settings.progressiveSystem,
                        accent: accent,
                        onChanged: notifier.setProgressiveSystem,
                      ),
                    ],
                  ),
                ),

                _Divider(accent),

                // ── AJUSTES: ASPECTO ─────────────────────────────────────
                _ExpandableTile(
                  label: 'ASPECTO',
                  accent: accent,
                  isOpen: _showAppearanceSettings,
                  onTap: () => setState(() =>
                      _showAppearanceSettings = !_showAppearanceSettings),
                  child: Column(
                    children: [
                      // Acento
                      _LabelRow('COLOR DE ACENTO', accent),
                      const SizedBox(height: 6),
                      Row(
                        children: CyberAccent.values.map((c) {
                          final col = _resolveAccent(c);
                          final selected = settings.accentColor == c;
                          return GestureDetector(
                            onTap: () => notifier.setAccentColor(c),
                            child: Container(
                              margin: const EdgeInsets.only(right: 10),
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: col,
                                shape: BoxShape.circle,
                                border: selected
                                    ? Border.all(
                                        color: Colors.white, width: 2)
                                    : null,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 12),

                      // Tamaño de letra
                      _LabelRow('TAMAÑO DE LETRA', accent),
                      const SizedBox(height: 4),
                      _TabSelector<AppFontSize>(
                        values: AppFontSize.values,
                        labels: const ['AUTO', 'S', 'M', 'L'],
                        current: settings.fontSize,
                        accent: accent,
                        onChanged: notifier.setFontSize,
                      ),
                      const SizedBox(height: 12),

                      // Idioma del motor
                      _LabelRow('IDIOMA DEL MOTOR', accent),
                      const SizedBox(height: 4),
                      _TabSelector<EngineLanguage>(
                        values: EngineLanguage.values,
                        labels: const ['ES', 'EN', 'JP'],
                        current: settings.engineLanguage,
                        accent: accent,
                        onChanged: notifier.setEngineLanguage,
                      ),
                      const SizedBox(height: 12),

                      // Negrita
                      _ToggleRow(
                        label: 'TEXTO EN NEGRITA',
                        value: settings.useBoldText,
                        accent: accent,
                        onChanged: (_) => notifier.toggleBoldText(),
                      ),

                      // Opacidad del lienzo
                      const SizedBox(height: 8),
                      _LabelRow('OPACIDAD LIENZO', accent),
                      SliderTheme(
                        data: SliderThemeData(
                          trackHeight: 1,
                          thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 6),
                          activeTrackColor: accent,
                          inactiveTrackColor:
                              accent.withValues(alpha: 0.2),
                          thumbColor: accent,
                          overlayShape: SliderComponentShape.noOverlay,
                        ),
                        child: Slider(
                          value: settings.canvasOpacity,
                          min: 0.3,
                          max: 1.0,
                          onChanged: notifier.setCanvasOpacity,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── FOOTER DEDICADO (PERFIL, ACTIVITY GRAPH & CRÉDITOS) ───────
          _Divider(accent),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'USUARIO_ACTIVO',
                        style: TextStyle(
                          color: accent,
                          fontFamily: 'Courier',
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _Badge('JLPT N5', accent),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _StatPill(
                      label: 'KANAS',
                      value: '${gameState.kanas.where((k) => k.isUnlocked).length}',
                      accent: accent,
                    ),
                    const SizedBox(width: 12),
                    _StatPill(
                      label: 'VEL',
                      value: '${gameState.avgMs}ms',
                      accent: accent,
                    ),
                    const SizedBox(width: 12),
                    _StatPill(
                      label: 'HIT',
                      value: '${(gameState.hitRate * 100).toStringAsFixed(0)}%',
                      accent: accent,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'MATRIZ DE ACTIVIDAD DIARIA',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.35),
                    fontFamily: 'Courier',
                    fontSize: 8,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  height: 48,
                  width: double.infinity,
                  child: CustomPaint(
                    painter: _ActivityGraphPainter(accent: accent),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    'KANJIZEN v3.0 — calinrus-dev',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.18),
                      fontFamily: 'Courier',
                      fontSize: 8,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _resolveAccent(CyberAccent c) => switch (c) {
        CyberAccent.green => CyberTheme.defaultAccent,
        CyberAccent.red => CyberTheme.errorRed,
        CyberAccent.orange => Colors.orange,
        CyberAccent.blue => Colors.cyanAccent,
        CyberAccent.purple => Colors.purpleAccent,
        CyberAccent.white => Colors.white,
      };
}

class _ActivityGraphPainter extends CustomPainter {
  const _ActivityGraphPainter({required this.accent});
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    const cols = 40;
    const rows = 7;
    
    final cellWidth = (size.width - (cols - 1) * 2.0) / cols;
    final cellHeight = (size.height - (rows - 1) * 2.0) / rows;
    
    for (int x = 0; x < cols; x++) {
      for (int y = 0; y < rows; y++) {
        final left = x * (cellWidth + 2.0);
        final top = y * (cellHeight + 2.0);
        
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

// ─── COMPONENTES INTERNOS ─────────────────────────────────────────────────────

class _Divider extends StatelessWidget {
  const _Divider(this.accent);
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Divider(
      color: accent.withValues(alpha: 0.12),
      height: 1,
      indent: 16,
      endIndent: 16,
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge(this.text, this.accent);
  final String text;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: accent.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        text,
        style: TextStyle(
            color: accent,
            fontFamily: 'Courier',
            fontSize: 9,
            fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill(
      {required this.label, required this.value, required this.accent});
  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.35),
                fontFamily: 'Courier',
                fontSize: 9)),
        const SizedBox(height: 2),
        Text(value,
            style: TextStyle(
                color: accent,
                fontFamily: 'Courier',
                fontSize: 13,
                fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _ExpandableTile extends StatelessWidget {
  const _ExpandableTile({
    required this.label,
    required this.accent,
    required this.isOpen,
    required this.onTap,
    required this.child,
  });

  final String label;
  final Color accent;
  final bool isOpen;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: isOpen
                          ? accent
                          : Colors.white.withValues(alpha: 0.55),
                      fontFamily: 'Courier',
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  isOpen
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: isOpen
                      ? accent
                      : Colors.white.withValues(alpha: 0.3),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
        if (isOpen)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: child,
          ),
      ],
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.label,
    required this.value,
    required this.accent,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final Color accent;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontFamily: 'Courier',
              fontSize: 10,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Transform.scale(
          scale: 0.75,
          child: Switch(
            value: value,
            onChanged: onChanged,
            activeColor: accent,
            inactiveThumbColor: Colors.white24,
            inactiveTrackColor: Colors.white10,
          ),
        ),
      ],
    );
  }
}

class _LabelRow extends StatelessWidget {
  const _LabelRow(this.label, this.accent);
  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.4),
          fontFamily: 'Courier',
          fontSize: 9,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}

class _TabSelector<T> extends StatelessWidget {
  const _TabSelector({
    required this.values,
    required this.labels,
    required this.current,
    required this.accent,
    required this.onChanged,
  });

  final List<T> values;
  final List<String> labels;
  final T current;
  final Color accent;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(values.length, (i) {
        final selected = current == values[i];
        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(values[i]),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 7),
              decoration: BoxDecoration(
                color: selected
                    ? accent.withValues(alpha: 0.15)
                    : Colors.transparent,
                border: Border.all(
                  color: selected
                      ? accent.withValues(alpha: 0.7)
                      : Colors.white.withValues(alpha: 0.1),
                  width: 0.8,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                labels[i],
                style: TextStyle(
                  color: selected
                      ? accent
                      : Colors.white.withValues(alpha: 0.35),
                  fontFamily: 'Courier',
                  fontSize: 10,
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
