import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kz_core/kz_core.dart';
import 'package:kz_domain/kz_domain.dart';
import 'package:kanjizen_app/src/features/home/presentation/meca_pool_settings.dart';

class MecaContextSettings extends ConsumerWidget {
  const MecaContextSettings({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const MecaContextSettings(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final accent = _getAccentColor(settings.accentColor);

    return Container(
      decoration: BoxDecoration(
        color: CyberTheme.bgObsidian.withValues(alpha: 0.95),
        border: Border(top: BorderSide(color: accent.withValues(alpha: 0.3))),
      ),
      padding: EdgeInsets.only(
        top: 24,
        left: 24, right: 24,
        bottom: MediaQuery.of(context).padding.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'MECA 1.0 / CONFIGURACIÓN CONTEXTUAL',
                style: TextStyle(color: accent, fontFamily: 'Courier', fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Icon(Icons.close, color: accent, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _SettingRow(
            label: 'MODO DE GENERACIÓN DEL POZO',
            value: settings.poolMode == PoolMode.auto ? 'AUTO' : 'CUSTOM',
            accent: accent,
            onTap: () {
              Navigator.pop(context);
              MecaPoolSettings.show(context);
            },
          ),
          const SizedBox(height: 16),
          _SettingRow(
            label: 'LAYOUT VISUAL',
            value: settings.layoutMode.name.toUpperCase(),
            accent: accent,
            onTap: () {
              final next = switch (settings.layoutMode) {
                AppLayoutMode.syllable => AppLayoutMode.word,
                AppLayoutMode.word => AppLayoutMode.text,
                AppLayoutMode.text => AppLayoutMode.syllable,
              };
              ref.read(settingsProvider.notifier).setLayoutMode(next);
            },
          ),
          const SizedBox(height: 16),
          _SettingRow(
            label: 'RELOJ DE LA MUERTE (DEATH CLOCK)',
            value: settings.deathClock == DeathClock.off ? 'OFF' : '${settings.deathClock.name.replaceAll('s', '').replaceAll('_', '.')}s',
            accent: accent,
            onTap: () {
              final next = switch (settings.deathClock) {
                DeathClock.off => DeathClock.s5,
                DeathClock.s5 => DeathClock.s3,
                DeathClock.s3 => DeathClock.s1_5,
                DeathClock.s1_5 => DeathClock.s1,
                DeathClock.s1 => DeathClock.s0_75,
                DeathClock.s0_75 => DeathClock.s0_5,
                DeathClock.s0_5 => DeathClock.off,
              };
              ref.read(settingsProvider.notifier).setDeathClock(next);
            },
          ),
          const SizedBox(height: 16),
          _SettingRow(
            label: 'TIEMPO DE SESIÓN',
            value: '${settings.sessionMinutes} MIN',
            accent: accent,
            onTap: () {
              final next = settings.sessionMinutes >= 5 ? 1 : settings.sessionMinutes + 1;
              ref.read(settingsProvider.notifier).setSessionMinutes(next);
            },
          ),
          const SizedBox(height: 16),
          _SettingRow(
            label: 'ASISTENCIA ROMAJI',
            value: settings.romajiAssist ? 'ON (3 fallos)' : 'OFF',
            accent: accent,
            onTap: () {
              ref.read(settingsProvider.notifier).toggleRomajiAssist();
            },
          ),
          const SizedBox(height: 16),
          _SettingRow(
            label: 'MODO HARDCORE (VIDAS)',
            value: settings.hardcoreMode ? '${settings.hardcoreLives} VIDAS' : 'OFF',
            accent: accent,
            onTap: () {
              if (!settings.hardcoreMode) {
                ref.read(settingsProvider.notifier).toggleHardcoreMode();
                ref.read(settingsProvider.notifier).setHardcoreLives(3);
              } else if (settings.hardcoreLives >= 10) {
                ref.read(settingsProvider.notifier).toggleHardcoreMode();
              } else {
                ref.read(settingsProvider.notifier).setHardcoreLives(settings.hardcoreLives + 1);
              }
            },
          ),
          const SizedBox(height: 16),
          _SettingRow(
            label: 'ANIMACIÓN SÍNCRONA DE TRAZADO',
            value: settings.enableStrokeAnimation ? 'ON' : 'OFF',
            accent: accent,
            onTap: () {
              // We could add toggleStrokeAnimation to settings
            },
          ),
        ],
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

class _SettingRow extends StatelessWidget {
  const _SettingRow({required this.label, required this.value, required this.accent, required this.onTap});
  final String label;
  final String value;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.transparent,
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(color: Colors.white70, fontFamily: 'Courier', fontSize: 11),
              ),
            ),
            Text(
              '[$value]',
              style: TextStyle(color: accent, fontFamily: 'Courier', fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
