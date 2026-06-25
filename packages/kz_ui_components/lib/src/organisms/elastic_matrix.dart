import 'package:flutter/material.dart';
import 'package:kz_core/kz_core.dart';

/// ORGANISM: Matriz Central Adaptativa.
/// Escala dinámicamente la fuente del carácter basándose en el espacio restante de la pantalla,
/// comprimiéndose de forma fluida cuando aparece el Gboard/Flick (resizeToAvoidBottomInset).
class ElasticMatrix extends StatelessWidget {
  const ElasticMatrix({
    super.key,
    required this.mainCharacter,
    this.romajiHint,
    this.accentColor,
    this.matrixSize = 1,
  });

  final String mainCharacter;
  final String? romajiHint;
  final Color? accentColor;
  final int matrixSize; // 1 para único, >1 para listados

  @override
  Widget build(BuildContext context) {
    final accent = accentColor ?? CyberTheme.defaultAccent;

    return LayoutBuilder(
      builder: (context, constraints) {
        // La fuente se calcula como el 30% del alto disponible, limitada entre 60 y 240
        final dynamicFontSize = (constraints.maxHeight * 0.3).clamp(
          60.0,
          240.0,
        );

        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                mainCharacter,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: accent,
                  fontSize: dynamicFontSize,
                  fontWeight: FontWeight.w200,
                  height: 1.0,
                ),
              ),
              if (romajiHint != null) ...[
                const SizedBox(height: 16),
                Text(
                  romajiHint!,
                  style: TextStyle(
                    color: CyberTheme.textNeutral.withValues(alpha: 0.5),
                    fontFamily: 'Courier',
                    fontSize: (dynamicFontSize * 0.15).clamp(14.0, 24.0),
                    letterSpacing: 8,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
