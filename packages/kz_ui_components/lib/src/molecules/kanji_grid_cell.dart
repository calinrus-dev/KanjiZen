import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:kz_core/kz_core.dart';
import 'package:kz_domain/kz_domain.dart';
import 'package:kz_ui_components/src/atoms/tier_badge.dart';

/// MOLECULE: Celda de inventario para un Kanji.
/// Estado bloqueado: opaco gris. Estado desbloqueado: acento activo.
class KanjiGridCell extends StatelessWidget {
  const KanjiGridCell({
    super.key,
    required this.kanji,
    this.onTap,
    this.accentColor,
    this.isExpanded = false,
  });

  final KanjiModel kanji;
  final VoidCallback? onTap;
  final Color? accentColor;
  final bool isExpanded;

  @override
  Widget build(BuildContext context) {
    final accent = accentColor ?? CyberTheme.defaultAccent;
    final isLocked = !kanji.isUnlocked;
    final tier = TierCalculator.calculate(
      hitRate: kanji.currentHitRate,
      avgMs: kanji.averageMs,
      isUnlocked: kanji.isUnlocked,
    );

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: 200.ms,
        decoration: BoxDecoration(
          color: isLocked
              ? const Color(0xFF1A1D26)
              : accent.withValues(alpha: 0.07),
          border: Border.all(
            color: isLocked
                ? const Color(0xFF2A2D36)
                : accent.withValues(alpha: isExpanded ? 0.8 : 0.3),
            width: isExpanded ? 1.5 : 1,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Text(
                kanji.character,
                style: TextStyle(
                  fontSize: 24,
                  color: isLocked
                      ? CyberTheme.textNeutral.withValues(alpha: 0.2)
                      : CyberTheme.textNeutral,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
            if (!isLocked)
              Positioned(
                bottom: 3,
                right: 3,
                child: TierBadge(tier: tier, size: 14),
              ),
          ],
        ),
      ),
    );
  }
}
