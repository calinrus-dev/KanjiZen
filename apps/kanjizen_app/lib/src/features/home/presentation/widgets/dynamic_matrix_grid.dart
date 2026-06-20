import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kz_domain/kz_domain.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:kanjizen_app/src/providers/game_provider.dart';

class DynamicMatrixGrid extends ConsumerWidget {
  const DynamicMatrixGrid({
    super.key,
    required this.targetCharacters,
    required this.currentIndex,
    required this.isPaused,
    required this.layoutMode,
    required this.useBold,
    required this.isNeonError,
  });

  final List<GameCharacter> targetCharacters;
  final int currentIndex;
  final bool isPaused;
  final AppLayoutMode layoutMode;
  final bool useBold;
  final bool isNeonError;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaQuery = MediaQuery.of(context);
    final totalHeight = mediaQuery.size.height;
    final keyboardHeight = mediaQuery.viewInsets.bottom;

    // Viewport calculations
    const headerHeight = 64.0;
    const terminalHeight = 52.0;
    final availableHeight =
        (totalHeight - keyboardHeight - headerHeight - terminalHeight).clamp(
          120.0,
          totalHeight,
        );

    final settings = ref.watch(settingsProvider);
    final scale = settings.gridScale;

    double cellSize = 80.0;
    if (scale == GridScale.sl) {
      cellSize = availableHeight * 0.35;
    } else if (scale == GridScale.l) {
      cellSize = availableHeight * 0.50;
    } else if (scale == GridScale.xl) {
      cellSize = availableHeight * 0.65;
    } else {
      // AUTO mode
      double hypoSize = availableHeight * 0.40;
      final maxAvailableWidth = mediaQuery.size.width - 32.0;
      if (hypoSize * targetCharacters.length > maxAvailableWidth * 0.90) {
        hypoSize = (maxAvailableWidth * 0.90) / targetCharacters.length;
      }
      cellSize = hypoSize;
    }

    // Final safety constraints
    final maxAvailableWidth = mediaQuery.size.width - 32.0;
    if (cellSize * targetCharacters.length > maxAvailableWidth) {
      cellSize = maxAvailableWidth / targetCharacters.length;
    }
    // Clamp mínimo para legibilidad — pero si el clamp sube el tamaño y produce
    // overflow de nuevo, lo corregimos después.
    cellSize = cellSize.clamp(40.0, 220.0);
    // Re-verificar ancho tras el clamp (clamp puede haber aumentado cellSize)
    if (cellSize * targetCharacters.length > maxAvailableWidth) {
      cellSize = maxAvailableWidth / targetCharacters.length;
    }

    final gridWidth = targetCharacters.length * cellSize;
    final gridHeight = cellSize;

    Widget gridWidget = SizedBox(
      width: gridWidth,
      height: gridHeight,
      child: CustomPaint(
        painter: TechnicalGridPainter(
          color: const Color(
            0xFF00FFFF,
          ).withValues(alpha: isPaused ? 0.2 : 0.8),
          columns: targetCharacters.length,
          cellSize: cellSize,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(targetCharacters.length, (idx) {
            final char = targetCharacters[idx];
            final isActive = idx == currentIndex;
            double opacity = 0.25;
            if (isActive) opacity = isPaused ? 0.2 : 1.0;

            return SizedBox(
              width: cellSize,
              height: cellSize,
              child: Center(
                child: FractionallySizedBox(
                  widthFactor: 0.95,
                  heightFactor: 0.95,
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: Text(
                      char.character,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: opacity),
                        fontFamily: 'Courier',
                        fontWeight: useBold ? FontWeight.bold : FontWeight.w100,
                        height: 1.0,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );

    // Neon Error Animation: Blinks 3 times in 150ms between Cyan and Violento Red (#ff0000)
    if (isNeonError) {
      gridWidget = gridWidget
          .animate(onPlay: (controller) => controller.repeat(max: 3))
          .tint(color: const Color(0xFFFF0000), end: 1.0, duration: 25.ms)
          .then()
          .tint(color: const Color(0xFF00FFFF), end: 0.0, duration: 25.ms);
    }

    // Dynamic center container — clipBehavior previene overflow durante la
    // transición de tamaño entre secuencias de diferente longitud.
    return Center(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        clipBehavior: Clip.hardEdge,
        decoration: const BoxDecoration(),
        width: gridWidth,
        height: gridHeight,
        child: gridWidget,
      ),
    );
  }
}

class TechnicalGridPainter extends CustomPainter {
  final Color color;
  final int columns;
  final double cellSize;

  TechnicalGridPainter({
    required this.color,
    required this.columns,
    required this.cellSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Outer border
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Vertical divider lines
    for (int i = 1; i < columns; i++) {
      final x = i * cellSize;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Micro crosshairs at the 4 outer corners of the entire grid
    final len = min(cellSize * 0.15, 12.0);
    final p = Paint()
      ..color = color.withValues(alpha: 1.0)
      ..strokeWidth = 1.5;

    // Top-Left corner
    canvas.drawLine(const Offset(0, 0), Offset(len, 0), p);
    canvas.drawLine(const Offset(0, 0), Offset(0, len), p);

    // Top-Right corner
    canvas.drawLine(Offset(size.width, 0), Offset(size.width - len, 0), p);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, len), p);

    // Bottom-Left corner
    canvas.drawLine(Offset(0, size.height), Offset(len, size.height), p);
    canvas.drawLine(Offset(0, size.height), Offset(0, size.height - len), p);

    // Bottom-Right corner
    canvas.drawLine(
      Offset(size.width, size.height),
      Offset(size.width - len, size.height),
      p,
    );
    canvas.drawLine(
      Offset(size.width, size.height),
      Offset(size.width, size.height - len),
      p,
    );
  }

  @override
  bool shouldRepaint(covariant TechnicalGridPainter oldDelegate) =>
      color != oldDelegate.color ||
      columns != oldDelegate.columns ||
      cellSize != oldDelegate.cellSize;
}
