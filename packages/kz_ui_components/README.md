# kz_ui_components

Sistema atómico de componentes UI del monorepo **KanjiZen**. Diseño Cyber-Zen Industrial — contraste radical, cero degradados, animaciones de latencia cero.

---

## Responsabilidad

- Proveer componentes reutilizables organizados por complejidad (Atoms → Molecules → Organisms)
- Painters de alto rendimiento para vectores kanji (KanjiVG SVG → canvas Dart)
- Fondo generativo (`BgPatternPainter`)
- Activity Graph anual estilo GitHub

## Estructura

```
lib/src/
├── atoms/
│   ├── cyber_button.dart       # Botón estilo terminal con borde y acento dinámico
│   ├── kanji_vg_painter.dart   # Painter animado de trazos SVG (AnimationController)
│   └── tier_badge.dart         # Badge de tier E/D/C/B/A/S con color por nivel
├── molecules/
│   ├── grid_cell.dart          # Celda de cuadrícula kana
│   ├── kana_display.dart       # Display de carácter kana con romaji
│   ├── kanji_grid_cell.dart    # Celda de cuadrícula kanji con tier indicator
│   ├── metric_chip.dart        # Chip de métrica (racha, avgMs, hitRate)
│   └── rayita_input.dart       # TextField minimal — solo borde inferior, shakeX en error
├── organisms/
│   ├── activity_graph.dart     # Wrapper del ActivityGraphPainter (365 días)
│   ├── cyber_zen_modal.dart    # Modal base con acento desde ThemeExtension
│   ├── elastic_matrix.dart     # Grid elástico de caracteres
│   ├── game_header.dart        # Header de sesión con métricas en vivo
│   ├── inventory_section.dart  # Sección expandible del inventario
│   ├── kanji_detail_modal.dart # Modal de detalle de kanji
│   └── settings_modal.dart     # Modal de ajustes
├── painters/
│   ├── activity_graph_painter.dart  # Painter del Activity Graph (365 días)
│   ├── bg_pattern_painter.dart      # Patrón de fondo generativo
│   └── kanji_vector_painter.dart    # Painter estático/animado KanjiVG (progress 0→1)
├── bg_pattern/                 # Assets del patrón de fondo
└── widgets/                    # Widgets de utilidad general
```

## Painters Kanji

### KanjiVgPainter (atoms/)
Acepta `Animation<double>` directamente. Usa cuando se necesita integración con `AnimationController` (ej: `CharacterDetailSheet`).

```dart
KanjiVgPainter(
  paths: kanjiEntity.svgPaths,
  progress: _animationController, // Animation<double>
  color: accentColor,
  strokeWidth: settings.strokeWidth,
)
```

**Obligatorio:** siempre envolver en `canvas.save()` / `canvas.restore()`.

### KanjiVectorPainter (painters/)
Painter de producción para modo estático o animado por progreso (`0.0 → 1.0`). Incluye efecto glow con `MaskFilter`.

```dart
CustomPaint(
  painter: KanjiVectorPainter(
    paths: svgPaths,
    progress: 1.0, // estático
    color: accentColor,
  ),
)
```

## RayitaInput

TextField sin bordes decorativos — solo `Border(bottom)`.

```dart
RayitaInput(
  controller: _controller,
  onChanged: _onChanged,
  inputState: InputState.error, // → shakeX inmediato con flutter_animate
)
```

- En `InputState.error`: aplica `shakeX` via `flutter_animate`. Usa `target: 1/0`, **nunca** `AnimationController` manual.

## Reglas de Diseño

1. **flutter_animate** para toda micro-animación UI (fadeIn, scale, slideY, shakeX).
2. **No** `AnimationController` manual excepto en `KanjiVgPainter` para animación de trazos SVG.
3. El acento se lee SIEMPRE de `Theme.of(context).extension<CyberThemeExtension>()` — nunca hardcodeado.
4. Layout reactivo al teclado: usar `LayoutBuilder` + `MediaQuery.of(context).viewInsets.bottom`.

## Dependencias

```yaml
flutter_animate: ^4.5.2
path_drawing: ^1.0.1    # Parseo de rutas SVG KanjiVG
kz_core:                # Tokens de color y temas
```
