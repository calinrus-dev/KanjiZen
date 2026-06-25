import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kz_core/kz_core.dart';
import 'package:kz_domain/kz_domain.dart';
import 'package:kz_ui_components/kz_ui_components.dart';
import 'package:kanjizen_app/src/providers/kanji_srs_provider.dart';
import 'package:kanjizen_app/src/features/kanji_srs/presentation/kanji_srs_screen.dart';

class KanjiEngineScreen extends ConsumerWidget {
  const KanjiEngineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final accent = _getAccentColor(settings.accentColor);
    final srsState = ref.watch(kanjiSrsProvider);

    return Center(
      child: srsState.isLoading
          ? CircularProgressIndicator(color: accent)
          : SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.style,
                    size: 48,
                    color: accent.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'SISTEMA DE REPETICIÓN ESPACIADA',
                    style: TextStyle(
                      color: accent,
                      fontFamily: 'Courier',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Fases del dominio cognitivo (0.0 a 10.0):\n'
                    '• 0-2: Inicial | • 3-4: Retirada\n'
                    '• 5-6: Inversión | • 7-10: Discriminatorio',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontFamily: 'Courier',
                      fontSize: 12,
                      height: 1.6,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    margin: const EdgeInsets.symmetric(horizontal: 32),
                    decoration: BoxDecoration(
                      border: Border.all(color: accent.withValues(alpha: 0.2)),
                      color: accent.withValues(alpha: 0.02),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Flexible(
                          child: _StatItem(
                            'KANJIS ACTIVOS',
                            srsState.activePool.length.toString(),
                            accent,
                          ),
                        ),
                        Flexible(
                          child: _StatItem(
                            'DOMINIO MEDIO',
                            srsState.averagePoolScore.toStringAsFixed(1),
                            accent,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  CyberButton(
                    label: 'Iniciar Entrenamiento',
                    icon: Icons.play_arrow,
                    accent: accent,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const KanjiSrsScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }

  Color _getAccentColor(CyberAccent c) {
    switch (c) {
      case CyberAccent.green:
        return CyberTheme.defaultAccent;
      case CyberAccent.red:
        return CyberTheme.errorRed;
      case CyberAccent.orange:
        return Colors.orange;
      case CyberAccent.blue:
        return Colors.cyanAccent;
      case CyberAccent.purple:
        return Colors.purpleAccent;
      case CyberAccent.white:
        return Colors.white;
    }
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem(this.label, this.value, this.accent);
  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.35),
            fontFamily: 'Courier',
            fontSize: 10,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 6),
        FittedBox(
          child: Text(
            value,
            style: TextStyle(
              color: accent,
              fontFamily: 'Courier',
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
