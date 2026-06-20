# kanjizen_app

Capa de orquestación de **KanjiZen** — la aplicación Flutter principal que integra todos los paquetes del monorepo.

> Repositorio: [github.com/calinrus-dev/KanjiZen](https://github.com/calinrus-dev/KanjiZen)

---

## Responsabilidad

Esta capa **no contiene lógica de negocio**. Orquesta:
- Inyección de dependencias (`ProviderScope` de Riverpod)
- Navegación declarativa (`GoRouter`)
- Pantallas (Screens) y widgets de presentación
- Providers de estado de sesión (`GameNotifier`, `TimelineProvider`, `KanjiSrsNotifier`)

---

## Estructura de Directorios

```
lib/
├── main.dart
└── src/
    ├── features/
    │   ├── auth/               # Pantalla de onboarding / nombre usuario
    │   ├── campaign/
    │   │   ├── kana_campaign_screen.dart
    │   │   ├── kana_level_matrix_screen.dart   # Mapa de niveles kana
    │   │   └── kanji_level_matrix_screen.dart  # Adquisición kanji 2 fases (NUEVO)
    │   ├── home/
    │   │   ├── engine_selector_screen.dart     # Hub principal
    │   │   ├── general_drawer.dart             # Drawer lateral + [KANJIS] + Perfil
    │   │   ├── meca_engine_screen.dart         # Motor MECA infinito
    │   │   ├── kana_engine_screen.dart
    │   │   ├── kanji_engine_screen.dart
    │   │   └── widgets/
    │   │       ├── arcade_viewport_widget.dart
    │   │       ├── dynamic_matrix_grid.dart    # Grid de caracteres (overflow fixed)
    │   │       ├── dynamic_terminal_bar.dart
    │   │       ├── exercise_report_widget.dart
    │   │       ├── kanji_production_widget.dart
    │   │       ├── kanji_quiz_widget.dart
    │   │       ├── meca_input_widget.dart
    │   │       └── stroke_validation_widget.dart
    │   ├── inventory/
    │   │   ├── inventory_dashboard_screen.dart # Dashboard kana+kanji con filtros
    │   │   └── widgets/
    │   │       └── character_detail_sheet.dart # KanjiVG animado + TTS
    │   ├── profile/
    │   │   └── profile_drawer.dart             # Stats, ActivityGraph, Settings sheet
    │   └── splash/
    │       └── splash_screen.dart              # Seed BD en Isolate
    ├── providers/
    │   ├── game_provider.dart          # GameNotifier — pool, SRS, tiers, avgMs
    │   ├── timeline_provider.dart      # TimelineProvider — nodos Feed, MECA infinito
    │   └── kanji_srs_provider.dart     # KanjiSrsNotifier — SRS kanji
    └── router/
        └── app_router.dart             # GoRouter con todas las rutas
```

---

## Rutas (GoRouter)

| Path | Screen |
|---|---|
| `/` | `SplashScreen` |
| `/auth` | `AuthScreen` |
| `/home` | `EngineSelectorScreen` |
| `/home/inventory` | `InventoryDashboardScreen` |
| `/home/kanas` | `KanaLevelMatrixScreen` |
| `/home/kanjis` | `KanjiLevelMatrixScreen` |

---

## Providers Principales

| Provider | Tipo | Responsabilidad |
|---|---|---|
| `gameProvider` | `StateNotifier<GameState>` | Pool de kana, selección ponderada, avgMs móvil, racha |
| `timelineProvider` | `StateNotifier<TimelineState>` | Nodos Feed, MECA infinito, campaign logic |
| `kanjiSrsProvider` | `StateNotifier<KanjiSrsState>` | SRS kanji, penalizaciones, update pool en memoria |
| `settingsProvider` | `@riverpod` Notifier | SettingsState inmutable, todos los ajustes |
| `kanaLevelProvider` | `StateNotifier` | Estado niveles kana, desbloqueos |

---

## Compilar y Ejecutar

```bash
# Desde la raíz del monorepo
cd apps/kanjizen_app

# Debug en dispositivo
flutter run -d <device_id>

# Build APK release
flutter build apk --release

# Build web
flutter build web
```

## Assets

- `assets/data/kanji_seed.json` — Seed de 138+ caracteres kanji con lecturas, significados y rutas SVG KanjiVG
- `assets/lotties/` — Animaciones Lottie para splash/feedback

## Dependencias Externas Clave

```yaml
flutter_riverpod: ^2.6.1   # Estado
go_router: ^14.8.1          # Navegación
flutter_animate: ^4.5.2    # Animaciones UI
flutter_tts: ^4.2.3         # Text-to-Speech
isar: ^3.1.0+1              # Base de datos local
path_drawing: ^1.0.1        # Parseo SVG KanjiVG
lottie: ^3.3.1              # Animaciones Lottie
```
