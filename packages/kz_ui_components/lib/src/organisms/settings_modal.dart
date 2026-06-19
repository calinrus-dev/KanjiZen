import 'package:flutter/material.dart';
import 'package:kz_core/kz_core.dart';
import 'package:kz_domain/kz_domain.dart'; // Solo para los enums

class SettingsModal extends StatelessWidget {
  const SettingsModal({
    super.key,
    required this.state,
    required this.onSetAccentColor,
    required this.onSetFontSize,
    required this.onSetEngineLanguage,
    required this.onSetAppLayoutMode,
    required this.onToggleRomajiHints,
    required this.onSetProgressiveSystem,
    required this.onToggleFreeModeKey,
    required this.onSetDeathClock,
    required this.onToggleSkipOnError,
    required this.onToggleHardcoreMode,
  });

  final SettingsState state;
  final ValueChanged<CyberAccent> onSetAccentColor;
  final ValueChanged<AppFontSize> onSetFontSize;
  final ValueChanged<EngineLanguage> onSetEngineLanguage;
  final ValueChanged<AppLayoutMode> onSetAppLayoutMode;
  final VoidCallback onToggleRomajiHints;
  final ValueChanged<ProgressiveSystem> onSetProgressiveSystem;
  final ValueChanged<String> onToggleFreeModeKey;
  final ValueChanged<DeathClock> onSetDeathClock;
  final VoidCallback onToggleSkipOnError;
  final VoidCallback onToggleHardcoreMode;

  static void show({
    required BuildContext context,
    required SettingsState state,
    required ValueChanged<CyberAccent> onSetAccentColor,
    required ValueChanged<AppFontSize> onSetFontSize,
    required ValueChanged<EngineLanguage> onSetEngineLanguage,
    required ValueChanged<AppLayoutMode> onSetAppLayoutMode,
    required VoidCallback onToggleRomajiHints,
    required ValueChanged<ProgressiveSystem> onSetProgressiveSystem,
    required ValueChanged<String> onToggleFreeModeKey,
    required ValueChanged<DeathClock> onSetDeathClock,
    required VoidCallback onToggleSkipOnError,
    required VoidCallback onToggleHardcoreMode,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SettingsModal(
        state: state,
        onSetAccentColor: onSetAccentColor,
        onSetFontSize: onSetFontSize,
        onSetEngineLanguage: onSetEngineLanguage,
        onSetAppLayoutMode: onSetAppLayoutMode,
        onToggleRomajiHints: onToggleRomajiHints,
        onSetProgressiveSystem: onSetProgressiveSystem,
        onToggleFreeModeKey: onToggleFreeModeKey,
        onSetDeathClock: onSetDeathClock,
        onToggleSkipOnError: onToggleSkipOnError,
        onToggleHardcoreMode: onToggleHardcoreMode,
      ),
    );
  }

  Color _getColor(CyberAccent accent) {
    switch (accent) {
      case CyberAccent.green: return CyberTheme.defaultAccent;
      case CyberAccent.red: return CyberTheme.errorRed;
      case CyberAccent.orange: return Colors.orange;
      case CyberAccent.blue: return Colors.cyanAccent;
      case CyberAccent.purple: return Colors.purpleAccent;
      case CyberAccent.white: return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = _getColor(state.accentColor);

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: CyberTheme.bgObsidian,
        border: Border(top: BorderSide(color: accent.withValues(alpha: 0.5))),
      ),
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('HERRAMIENTAS Y AJUSTES', style: TextStyle(color: accent, fontFamily: 'Courier', fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 2)),
            const SizedBox(height: 32),

            // Color de Acento
            const Text('COLOR DE ACENTO', style: TextStyle(color: CyberTheme.textNeutral, fontFamily: 'Courier', fontSize: 12)),
            const SizedBox(height: 8),
            Row(
              children: CyberAccent.values.map((c) {
                final color = _getColor(c);
                final isSelected = state.accentColor == c;
                return GestureDetector(
                  onTap: () => onSetAccentColor(c),
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: isSelected ? Border.all(color: Colors.white, width: 2) : null,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Tamaño de Letra
            _buildTabSelector<AppFontSize>(
              title: 'TAMAÑO DE LETRA',
              values: AppFontSize.values,
              labels: const ['AUTO', 'S', 'M', 'L'],
              current: state.fontSize,
              onChanged: onSetFontSize,
              accent: accent,
            ),
            const SizedBox(height: 24),

            // Idioma del Motor
            _buildTabSelector<EngineLanguage>(
              title: 'IDIOMA DEL MOTOR',
              values: EngineLanguage.values,
              labels: const ['ESPAÑOL', 'ENGLISH', '日本語'],
              current: state.engineLanguage,
              onChanged: onSetEngineLanguage,
              accent: accent,
            ),
            const SizedBox(height: 24),

            // Modo de Entrenamiento
            _buildTabSelector<AppLayoutMode>(
              title: 'LAYOUT VISUAL',
              values: AppLayoutMode.values,
              labels: const ['SÍLABA', 'PALABRA', 'TEXTO'],
              current: state.layoutMode,
              onChanged: onSetAppLayoutMode,
              accent: accent,
            ),
            const SizedBox(height: 24),

            // Ayuda Visual
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('MOSTRAR ROMAJI / PISTAS', style: TextStyle(color: CyberTheme.textNeutral, fontFamily: 'Courier', fontSize: 12)),
                Switch(
                  value: state.showRomajiHints,
                  onChanged: (_) => onToggleRomajiHints(),
                  activeColor: accent,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Sistema Progresivo
            _buildTabSelector<ProgressiveSystem>(
              title: 'SISTEMA PROGRESIVO',
              values: ProgressiveSystem.values,
              labels: const ['HIRA', 'KATA', 'AMBOS'],
              current: state.progressiveSystem,
              onChanged: onSetProgressiveSystem,
              accent: accent,
            ),
            const SizedBox(height: 24),

            // Teclas Modo Libre (Mocked grid para no hacer el código inmenso)
            const Text('TECLAS MODO LIBRE', style: TextStyle(color: CyberTheme.textNeutral, fontFamily: 'Courier', fontSize: 12)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: ['A1','B1','C1','D1','E1'].map((k) {
                final active = state.freeModeKeys.contains(k);
                return GestureDetector(
                  onTap: () => onToggleFreeModeKey(k),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: active ? accent.withValues(alpha: 0.2) : Colors.transparent,
                      border: Border.all(color: active ? accent : CyberTheme.textNeutral.withValues(alpha: 0.3)),
                    ),
                    child: Text(k, style: TextStyle(color: active ? accent : CyberTheme.textNeutral, fontFamily: 'Courier')),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Reloj de la Muerte
            _buildTabSelector<DeathClock>(
              title: 'RELOJ DE LA MUERTE (DEATH CLOCK)',
              values: DeathClock.values,
              labels: const ['OFF', '5.0s', '3.0s', '1.5s', '1.0s', '0.75s', '0.5s'],
              current: state.deathClock,
              onChanged: onSetDeathClock,
              accent: CyberTheme.errorRed,
            ),
            const SizedBox(height: 24),

            // Control del Generador
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('SALTAR AL FALLAR', style: TextStyle(color: CyberTheme.textNeutral, fontFamily: 'Courier', fontSize: 12)),
                Switch(
                  value: state.skipOnError,
                  onChanged: (_) => onToggleSkipOnError(),
                  activeColor: accent,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Modo Hardcore
            GestureDetector(
              onTap: () => onToggleHardcoreMode(),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: state.hardcoreMode ? CyberTheme.errorRed.withValues(alpha: 0.2) : Colors.transparent,
                  border: Border.all(color: CyberTheme.errorRed, width: state.hardcoreMode ? 2 : 1),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.warning_amber_rounded, color: state.hardcoreMode ? CyberTheme.errorRed : CyberTheme.textNeutral),
                    const SizedBox(width: 8),
                    Text(
                      'MUERTE SÚBITA — UN FALLO = FIN',
                      style: TextStyle(
                        color: state.hardcoreMode ? CyberTheme.errorRed : CyberTheme.textNeutral,
                        fontFamily: 'Courier',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildTabSelector<T>({
    required String title,
    required List<T> values,
    required List<String> labels,
    required T current,
    required ValueChanged<T> onChanged,
    required Color accent,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: CyberTheme.textNeutral, fontFamily: 'Courier', fontSize: 12)),
        const SizedBox(height: 8),
        Row(
          children: List.generate(values.length, (index) {
            final isSelected = current == values[index];
            return Expanded(
              child: GestureDetector(
                onTap: () => onChanged(values[index]),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? accent.withValues(alpha: 0.2) : Colors.transparent,
                    border: Border.all(color: isSelected ? accent : CyberTheme.textNeutral.withValues(alpha: 0.2)),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    labels[index],
                    style: TextStyle(
                      color: isSelected ? accent : CyberTheme.textNeutral,
                      fontFamily: 'Courier',
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
