import 'package:flutter/material.dart';
import 'package:kz_core/kz_core.dart';
import 'package:kz_domain/kz_domain.dart';
import 'package:kz_ui_components/kz_ui_components.dart';

class KanjiDetailModal extends StatefulWidget {
  const KanjiDetailModal({
    super.key,
    required this.kanji,
    required this.accent,
    required this.onForceUnlock,
    required this.onReset,
    required this.onLock,
  });

  final KanjiModel kanji;
  final Color accent;
  final VoidCallback onForceUnlock;
  final VoidCallback onReset;
  final VoidCallback onLock;

  static void show({
    required BuildContext context,
    required KanjiModel kanji,
    required Color accent,
    required VoidCallback onForceUnlock,
    required VoidCallback onReset,
    required VoidCallback onLock,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => KanjiDetailModal(
        kanji: kanji,
        accent: accent,
        onForceUnlock: onForceUnlock,
        onReset: onReset,
        onLock: onLock,
      ),
    );
  }

  @override
  State<KanjiDetailModal> createState() => _KanjiDetailModalState();
}

class _KanjiDetailModalState extends State<KanjiDetailModal> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final k = widget.kanji;
    final isLocked = !k.isUnlocked;

    int hits = 0;
    int errors = 0;
    for (final b in k.historyBlob) {
      if ((b & 0x8000) != 0) {
        hits++;
      } else {
        errors++;
      }
    }
    final double speedSec = k.averageMs / 1000.0;
    final String tierName = k.tier.name.toUpperCase();

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: CyberTheme.bgObsidian,
        border: Border(top: BorderSide(color: widget.accent.withValues(alpha: 0.5))),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(isLocked ? 'ESTADO: BLOQUEADO' : 'ESTADO: ACTIVO [TIER $tierName]', style: TextStyle(color: isLocked ? CyberTheme.textNeutral : widget.accent, fontFamily: 'Courier', fontSize: 12, fontWeight: FontWeight.bold)),
                IconButton(icon: Icon(Icons.close, color: widget.accent.withValues(alpha: 0.6)), onPressed: () => Navigator.pop(context)),
              ],
            ),
          ),
          
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              children: [
                // Top area: Animation + Concept
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Animator SVG
                    Container(
                      width: 120, height: 120,
                      decoration: BoxDecoration(
                        border: Border.all(color: widget.accent.withValues(alpha: 0.3)),
                        borderRadius: BorderRadius.circular(8),
                        color: widget.accent.withValues(alpha: 0.05),
                      ),
                      child: CustomPaint(
                        painter: KanjiVgPainter(
                          svgPaths: k.svgPaths,
                          progress: _controller,
                          strokeColor: widget.accent,
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    // Concept info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(k.meanings.isNotEmpty ? k.meanings.first.toUpperCase() : 'DESCONOCIDO', style: TextStyle(color: widget.accent, fontFamily: 'Courier', fontSize: 24, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          if (k.onyomi.isNotEmpty) ...[
                            const Text('ONYOMI (CHINO)', style: TextStyle(color: CyberTheme.textNeutral, fontFamily: 'Courier', fontSize: 10)),
                            Text(k.onyomi.join(', '), style: const TextStyle(color: Colors.white, fontFamily: 'Courier', fontSize: 14)),
                            const SizedBox(height: 8),
                          ],
                          if (k.kunyomi.isNotEmpty) ...[
                            const Text('KUNYOMI (JAPONÉS)', style: TextStyle(color: CyberTheme.textNeutral, fontFamily: 'Courier', fontSize: 10)),
                            Text(k.kunyomi.join(', '), style: const TextStyle(color: Colors.white, fontFamily: 'Courier', fontSize: 14)),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                
                // Extra metadata
                Wrap(
                  spacing: 16, runSpacing: 16,
                  children: [
                    _MetaChip('JLPT', 'N${k.jlpt > 0 ? k.jlpt : '?'}', widget.accent),
                    _MetaChip('JOYO', '${k.joyo > 0 ? k.joyo : '?'}', widget.accent),
                    _MetaChip('RADICAL', k.radical.isNotEmpty ? k.radical : '?', widget.accent),
                  ],
                ),
                const SizedBox(height: 32),

                // Actions
                if (isLocked) ...[
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      widget.onForceUnlock();
                    },
                    icon: const Icon(Icons.lock_open, color: CyberTheme.bgObsidian),
                    label: const Text('FORZAR DESBLOQUEO (ONE-SHOT)', style: TextStyle(color: CyberTheme.bgObsidian, fontFamily: 'Courier', fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(backgroundColor: widget.accent, padding: const EdgeInsets.all(16)),
                  ),
                ] else ...[
                  // Metrics
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(border: Border.all(color: widget.accent.withValues(alpha: 0.2)), borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _Stat('ACIERTOS', '$hits', widget.accent),
                        _Stat('ERRORES', '$errors', CyberTheme.errorRed),
                        _Stat('VELOCIDAD', '${speedSec.toStringAsFixed(1)}s', widget.accent),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            widget.onReset();
                          },
                          style: OutlinedButton.styleFrom(foregroundColor: widget.accent, side: BorderSide(color: widget.accent)),
                          child: const Text('RESETEAR MÉTRICAS', style: TextStyle(fontFamily: 'Courier', fontSize: 12)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            widget.onLock();
                          },
                          style: OutlinedButton.styleFrom(foregroundColor: CyberTheme.errorRed, side: const BorderSide(color: CyberTheme.errorRed)),
                          child: const Text('BLOQUEAR', style: TextStyle(fontFamily: 'Courier', fontSize: 12)),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip(this.label, this.value, this.accent);
  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(border: Border.all(color: accent.withValues(alpha: 0.3)), borderRadius: BorderRadius.circular(4)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$label:', style: const TextStyle(color: CyberTheme.textNeutral, fontFamily: 'Courier', fontSize: 10)),
          const SizedBox(width: 4),
          Text(value, style: TextStyle(color: accent, fontFamily: 'Courier', fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.label, this.value, this.color);
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: CyberTheme.textNeutral, fontFamily: 'Courier', fontSize: 10)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: color, fontFamily: 'Courier', fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
