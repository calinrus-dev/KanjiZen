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
      backgroundColor: const Color(0xFF000000), // OLED black
      shape: const Border(
        top: BorderSide(color: Color(0xFF00FFFF), width: 1.5),
      ),
      isScrollControlled: true,
      builder: (_) => const MecaContextSettings(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final accent = _getAccentColor(settings.accentColor);

    return Container(
      padding: EdgeInsets.only(
        top: 24,
        left: 24,
        right: 24,
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
                'MECA 1.0 — CONFIGURACIÓN',
                style: TextStyle(
                  color: accent,
                  fontFamily: 'Courier',
                  fontSize: 11,
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
          const SizedBox(height: 24),
          _buildSettingsRow(
            label: 'POZO DE GENERACIÓN',
            control: GestureDetector(
              onTap: () {
                Navigator.pop(context);
                MecaPoolSettings.show(context);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white24),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  settings.poolMode == PoolMode.auto ? 'AUTO' : 'CUSTOM',
                  style: TextStyle(
                    color: accent,
                    fontFamily: 'Courier',
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _buildSettingsRow(
            label: 'TAMAÑO DE REJILLA / LAYOUT',
            control: _CyberSegmentedControl<GridScale>(
              groupValue: settings.gridScale,
              children: const {
                GridScale.sl: 'SL',
                GridScale.l: 'L',
                GridScale.xl: 'XL',
                GridScale.auto: 'AUTO',
              },
              onValueChanged: (val) {
                ref.read(settingsProvider.notifier).setGridScale(val);
              },
              accentColor: accent,
            ),
          ),
          const SizedBox(height: 12),
          _buildSettingsRow(
            label: 'RELOJ DE LA MUERTE',
            control: _CyberSegmentedControl<DeathClock>(
              groupValue: settings.deathClock,
              children: const {
                DeathClock.off: 'OFF',
                DeathClock.s1: '1s',
                DeathClock.s3: '3s',
                DeathClock.s5: '5s',
              },
              onValueChanged: (val) {
                ref.read(settingsProvider.notifier).setDeathClock(val);
              },
              accentColor: accent,
            ),
          ),
          const SizedBox(height: 12),
          _buildSettingsRow(
            label: 'ASISTENCIA ROMAJI',
            control: _OledToggleSwitch(
              value: settings.romajiAssist,
              onChanged: (_) {
                ref.read(settingsProvider.notifier).toggleRomajiAssist();
              },
              activeColor: accent,
            ),
          ),
          const SizedBox(height: 12),
          _buildSettingsRow(
            label: 'MODO HARDCORE',
            control: _OledToggleSwitch(
              value: settings.hardcoreMode,
              onChanged: (_) {
                ref.read(settingsProvider.notifier).toggleHardcoreMode();
              },
              activeColor: accent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsRow({required String label, required Widget control}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontFamily: 'Courier',
                fontSize: 10,
                letterSpacing: 1.0,
              ),
            ),
          ),
          const SizedBox(width: 16),
          control,
        ],
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

class _OledToggleSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color activeColor;

  const _OledToggleSwitch({
    required this.value,
    required this.onChanged,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 40,
        height: 20,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: value
              ? activeColor.withValues(alpha: 0.2)
              : const Color(0xFF222222),
          border: Border.all(
            color: value ? activeColor : const Color(0xFF333333),
            width: 1.5,
          ),
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeInOut,
              left: value ? 22 : 2,
              top: 1.5,
              child: Container(
                width: 13,
                height: 13,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: value ? activeColor : const Color(0xFF666666),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CyberSegmentedControl<T> extends StatelessWidget {
  final T groupValue;
  final Map<T, String> children;
  final ValueChanged<T> onValueChanged;
  final Color accentColor;

  const _CyberSegmentedControl({
    required this.groupValue,
    required this.children,
    required this.onValueChanged,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 210),
      height: 28,
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.white10),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(3),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: children.entries.map((entry) {
            final isSelected = entry.key == groupValue;
            final itemWidth = 208.0 / children.length;
            return SizedBox(
              width: itemWidth,
              height: double.infinity,
              child: GestureDetector(
                onTap: () => onValueChanged(entry.key),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  alignment: Alignment.center,
                  color: isSelected
                      ? accentColor.withValues(alpha: 0.15)
                      : Colors.transparent,
                  child: Text(
                    entry.value,
                    style: TextStyle(
                      color: isSelected ? accentColor : Colors.white60,
                      fontFamily: 'Courier',
                      fontSize: 8.5,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
