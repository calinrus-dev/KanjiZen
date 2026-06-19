import 'package:flutter/material.dart';
import 'package:kz_domain/kz_domain.dart';
import 'package:kz_ui_components/kz_ui_components.dart';
import 'package:kz_data/kz_data.dart';

class KanaInventoryTab extends StatelessWidget {
  const KanaInventoryTab({
    super.key,
    required this.kanas,
    required this.settings,
    required this.accent,
  });

  final List<KanaModel>? kanas;
  final SettingsState settings;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final allKanas = kanas ?? [];
    final hiragana = allKanas.where((k) => !k.isKatakana).toList();
    final katakana = allKanas.where((k) => k.isKatakana).toList();

    return SingleChildScrollView(
      child: Column(
        children: [
          if (hiragana.isNotEmpty)
            InventorySection(
              title: 'HIRAGANA',
              kanas: hiragana,
              accentColor: accent,
              onKanaTap: (kana) {
                CyberZenModal.show(
                  context: context,
                  kana: kana,
                  enableStrokeAnimation: settings.enableStrokeAnimation,
                  onPlayAudio: () {
                    if (settings.enableAudio) {
                      AudioFeedbackService.instance.playReading(kana.character);
                    }
                  },
                );
              },
            ),
          if (katakana.isNotEmpty)
            InventorySection(
              title: 'KATAKANA',
              kanas: katakana,
              accentColor: accent,
              initiallyExpanded: false,
              onKanaTap: (kana) {
                CyberZenModal.show(
                  context: context,
                  kana: kana,
                  enableStrokeAnimation: settings.enableStrokeAnimation,
                  onPlayAudio: () {
                    if (settings.enableAudio) {
                      AudioFeedbackService.instance.playReading(kana.character);
                    }
                  },
                );
              },
            ),
          if (allKanas.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Text(
                'Cargando kana...',
                style: TextStyle(
                  color: accent.withValues(alpha: 0.3),
                  fontFamily: 'Courier',
                  fontSize: 12,
                ),
              ),
            ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
