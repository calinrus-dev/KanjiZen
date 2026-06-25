import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kz_core/kz_core.dart';
import 'package:kz_domain/kz_domain.dart';
import 'package:kanjizen_app/src/features/home/presentation/meca_context_settings.dart';

class MecaPoolSettings extends ConsumerWidget {
  const MecaPoolSettings({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const MecaPoolSettings(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final accent = _getAccentColor(settings.accentColor);
    final isAuto = settings.poolMode == PoolMode.auto;

    return Container(
      decoration: BoxDecoration(
        color: CyberTheme.bgObsidian.withValues(alpha: 0.98),
        border: Border(top: BorderSide(color: accent.withValues(alpha: 0.3))),
      ),
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
                'MODO DE GENERACIÓN DEL POZO',
                style: TextStyle(
                  color: accent,
                  fontFamily: 'Courier',
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      MecaContextSettings.show(context);
                    },
                    child: Icon(Icons.arrow_back_ios, color: accent, size: 16),
                  ),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.close, color: accent, size: 20),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Toggle AUTO / CUSTOM
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => ref
                      .read(settingsProvider.notifier)
                      .setPoolMode(PoolMode.auto),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isAuto
                          ? accent.withValues(alpha: 0.2)
                          : Colors.transparent,
                      border: Border.all(
                        color: isAuto ? accent : Colors.white12,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'AUTO',
                        style: TextStyle(
                          color: isAuto ? accent : Colors.white54,
                          fontFamily: 'Courier',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () => ref
                      .read(settingsProvider.notifier)
                      .setPoolMode(PoolMode.custom),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: !isAuto
                          ? accent.withValues(alpha: 0.2)
                          : Colors.transparent,
                      border: Border.all(
                        color: !isAuto ? accent : Colors.white12,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'CUSTOM',
                        style: TextStyle(
                          color: !isAuto ? accent : Colors.white54,
                          fontFamily: 'Courier',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Text(
            isAuto
                ? 'El motor SRS solo escupe caracteres desbloqueados legítimamente desde KANA 1.0.'
                : 'Despliega la rejilla Flick nativa (A1-B4) para forzar caracteres.',
            style: const TextStyle(
              color: Colors.white70,
              fontFamily: 'Courier',
              fontSize: 11,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 24),

          // Custom Grid Mockup
          if (!isAuto)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 2.0,
              ),
              itemCount: 12,
              itemBuilder: (context, index) {
                final labels = [
                  'あ',
                  'か',
                  'さ',
                  'た',
                  'な',
                  'は',
                  'ま',
                  'や',
                  'ら',
                  'わ',
                  '、',
                  'ん',
                ];
                return Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: accent.withValues(alpha: 0.3)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Center(
                    child: Text(
                      labels[index],
                      style: TextStyle(color: accent, fontSize: 18),
                    ),
                  ),
                );
              },
            ),
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
