import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kz_core/kz_core.dart';
import 'package:kz_domain/kz_domain.dart';

class KanaEngineScreen extends ConsumerWidget {
  const KanaEngineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final accent = _getAccentColor(settings.accentColor);

    return Column(
      children: [
        // Toggle Hiragana / Katakana / Mix
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _ToggleBtn(
                'HIRAGANA',
                settings.progressiveSystem == ProgressiveSystem.hira,
                accent,
                () {
                  ref
                      .read(settingsProvider.notifier)
                      .setProgressiveSystem(ProgressiveSystem.hira);
                },
              ),
              _ToggleBtn(
                'MIX',
                settings.progressiveSystem == ProgressiveSystem.both,
                accent,
                () {
                  ref
                      .read(settingsProvider.notifier)
                      .setProgressiveSystem(ProgressiveSystem.both);
                },
              ),
              _ToggleBtn(
                'KATAKANA',
                settings.progressiveSystem == ProgressiveSystem.kata,
                accent,
                () {
                  ref
                      .read(settingsProvider.notifier)
                      .setProgressiveSystem(ProgressiveSystem.kata);
                },
              ),
            ],
          ),
        ),
        // Grid 20x5
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(24),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: 100, // 20x5
            itemBuilder: (context, index) {
              final level = index + 1;
              final isUnlocked = level <= 3; // Placeholder progression
              return Container(
                decoration: BoxDecoration(
                  color: isUnlocked
                      ? accent.withValues(alpha: 0.1)
                      : Colors.transparent,
                  border: Border.all(
                    color: isUnlocked
                        ? accent.withValues(alpha: 0.5)
                        : Colors.white.withValues(alpha: 0.1),
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                  child: isUnlocked
                      ? Text(
                          '$level',
                          style: TextStyle(
                            color: accent,
                            fontFamily: 'Courier',
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : Icon(
                          Icons.lock,
                          size: 16,
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                ),
              );
            },
          ),
        ),
      ],
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

class _ToggleBtn extends StatelessWidget {
  const _ToggleBtn(this.label, this.isActive, this.accent, this.onTap);
  final String label;
  final bool isActive;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? accent.withValues(alpha: 0.15) : Colors.transparent,
          border: Border.all(
            color: isActive ? accent : Colors.white.withValues(alpha: 0.2),
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? accent : Colors.white.withValues(alpha: 0.4),
            fontFamily: 'Courier',
            fontSize: 12,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w300,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }
}
