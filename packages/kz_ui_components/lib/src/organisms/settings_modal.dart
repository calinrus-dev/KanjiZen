import 'package:flutter/material.dart';
import 'package:kz_core/kz_core.dart';

/// Modal simple para ajustes generales.
/// (Se consumirá desde kanjizen_app inyectando el estado de Riverpod)
class SettingsModal extends StatelessWidget {
  const SettingsModal({
    super.key,
    required this.enableStrokeAnimation,
    required this.enableAudio,
    required this.onToggleStrokeAnimation,
    required this.onToggleAudio,
  });

  final bool enableStrokeAnimation;
  final bool enableAudio;
  final VoidCallback onToggleStrokeAnimation;
  final VoidCallback onToggleAudio;

  static void show({
    required BuildContext context,
    required bool enableStrokeAnimation,
    required bool enableAudio,
    required VoidCallback onToggleStrokeAnimation,
    required VoidCallback onToggleAudio,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => SettingsModal(
        enableStrokeAnimation: enableStrokeAnimation,
        enableAudio: enableAudio,
        onToggleStrokeAnimation: onToggleStrokeAnimation,
        onToggleAudio: onToggleAudio,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accent = CyberTheme.defaultAccent;

    return Container(
      decoration: BoxDecoration(
        color: CyberTheme.bgObsidian,
        border: Border(top: BorderSide(color: accent.withValues(alpha: 0.5))),
      ),
      padding: const EdgeInsets.all(24),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AJUSTES DEL SISTEMA',
              style: TextStyle(
                color: accent,
                fontFamily: 'Courier',
                fontSize: 16,
                letterSpacing: 3,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),

            // Toggle Audio
            _buildToggleRow(
              title: 'AUDIO TTS',
              description: 'Pronunciación nativa en japonés al acertar.',
              value: enableAudio,
              onChanged: (_) => onToggleAudio(),
              accent: accent,
            ),
            const SizedBox(height: 16),

            // Toggle Animación
            _buildToggleRow(
              title: 'ANIMACIÓN VECTORIAL',
              description: 'Dibuja el trazo KANJIVG progresivamente.',
              value: enableStrokeAnimation,
              onChanged: (_) => onToggleStrokeAnimation(),
              accent: accent,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleRow({
    required String title,
    required String description,
    required bool value,
    required ValueChanged<bool> onChanged,
    required Color accent,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: CyberTheme.textNeutral,
                  fontFamily: 'Courier',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  color: CyberTheme.textNeutral.withValues(alpha: 0.5),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: accent,
          inactiveThumbColor: CyberTheme.textNeutral.withValues(alpha: 0.3),
          inactiveTrackColor: CyberTheme.textNeutral.withValues(alpha: 0.1),
        ),
      ],
    );
  }
}
