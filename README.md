# KanjiZen ⛩️

> **Zero BS. Latencia Cero. Fluidez Nativa.**
> Mecanización total del japonés escrito — de kana a kanji, trazo a trazo.

[![Flutter](https://img.shields.io/badge/Flutter-3.32.5+-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.8.1+-0175C2?logo=dart)](https://dart.dev)
[![Melos](https://img.shields.io/badge/Melos-Monorepo-blueviolet)](https://melos.invertase.dev)
[![GitHub](https://img.shields.io/badge/GitHub-calinrus--dev%2FKanjiZen-181717?logo=github)](https://github.com/calinrus-dev/KanjiZen)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20Web-brightgreen)](https://github.com/calinrus-dev/KanjiZen)

---

## 📌 Repositorio

```
https://github.com/calinrus-dev/KanjiZen
```

Rama principal: `main` · Propietario: [`calinrus-dev`](https://github.com/calinrus-dev)

---

## 🎯 La Metodología (MecaNet × Anki × Kahoot)

KanjiZen no te enseña a dibujar; te enseña a **mecanizar**.

| Pilar | Concepto |
|---|---|
| **Memoria Muscular** | Orientación espacial pura con teclado Flick. Aprendes hacia dónde va cada vocal/consonante. En PC/Web: soporte QWERTY + Romaji. |
| **Repetición Espaciada (SRS)** | Motor propio inspirado en Anki. Cada respuesta actualiza el score individual del carácter y reajusta la cola de práctica. |
| **Velocidad y Precisión** | Ritmo de Kahoot + rigor de MecaNet. El tiempo de respuesta se mide en ms. Tier S = < 500 ms. |
| **Interiorización Kanji** | No solo escribes el carácter; relacionas radical, lecturas Onyomi/Kunyomi y significado en español/inglés. |

---

## 🗺️ Pantallas y Rutas

```
/                   → SplashScreen          (seed BD en background Isolate)
/auth               → AuthScreen            (onboarding / nombre usuario)
/home               → EngineSelectorScreen  (panel principal + GeneralDrawer)
/home/inventory     → InventoryDashboardScreen (todos los kana/kanji + filtros)
/home/kanas         → KanaLevelMatrixScreen (campaña kana por niveles)
/home/kanjis        → KanjiLevelMatrixScreen (adquisición kanji 2 fases)
```

### Pantallas Principales

| Pantalla | Descripción |
|---|---|
| **EngineSelectorScreen** | Hub central. Acceso rápido a MECA, Kanji, Quiz. GeneralDrawer lateral con historial de sesión, botón `[KANJIS]` y acceso a Perfil. |
| **MecaEngineScreen** | Motor MECA **infinito** — nunca muestra "completado", cicla sin parar. Métricas en vivo: racha, t_eff, tier. `RayitaInput` con shakeX en error. |
| **KanaEngineScreen** | Sesión de práctica de kana (hiragana/katakana) con pool dinámico. |
| **KanjiEngineScreen** | Motor SRS de producción kanji. Input + validación multimodal. |
| **KanaLevelMatrixScreen** | Mapa de niveles kana con sistema portero. Grid de niveles desbloqueables. |
| **KanjiLevelMatrixScreen** | **NUEVA.** Adquisición kanji en 2 fases: Fase I (exposición pasiva con KanjiVG animado + TTS) → Fase II (producción activa con input romaji/hiragana). |
| **InventoryDashboardScreen** | Dashboard de todos los caracteres. Filtros JLPT/Grado, sección kanji auto-expandible, `CharacterDetailSheet` con KanjiVG animado + TTS. Acento dinámico. |
| **ProfileDrawer** | Panel lateral: estadísticas, Activity Graph 365 días, analytics por tier, acceso a `_SettingsSheetContent`. |

---

## ⚙️ Arquitectura Técnica

### Monorepo Melos — Capas DDD

```
kz_core
  └── Constantes, temas CyberZen, interfaces abstractas (ICharacterRepository)
      Sin dependencias externas complejas.

kz_data
  └── Entidades Isar (@collection): KanaEntity, KanjiEntity, KanaLevelEntity
      Repositorios locales, DatabaseInitializerService (Isolate).
      Scripts de parseo de datos crudos KanjiVG / KANJIDIC2.

kz_domain
  └── Lógica de negocio pura (sin Flutter).
      SrsEngine, TierCalculator, MecaEvaluator, InputValidator.
      SettingsState (Freezed + Riverpod). Modelos inmutables.

kz_ui_components
  └── Sistema Atómico: Atoms → Molecules → Organisms.
      KanjiVgPainter, KanjiVectorPainter (SVG paths → canvas Dart).
      RayitaInput, CyberZenModal, KanaGridCell.

kanjizen_app
  └── Orquestador. GoRouter, ProviderScope, Screens, Providers.
      TimelineProvider (motor de nodos Feed), GameNotifier, KanjiSrsNotifier.
```

### Stack Técnico

| Capa | Tecnología | Versión |
|---|---|---|
| Framework | Flutter | ≥ 3.32.5 |
| Lenguaje | Dart | ≥ 3.8.1 |
| Estado | Riverpod + riverpod_annotation | 2.6.1 |
| Modelos | Freezed v3+ | 3.0.0 |
| Base de Datos | Isar | 3.1.0+1 |
| Navegación | GoRouter | 14.8.1 |
| Animaciones | flutter_animate | 4.5.2 |
| SVG Kanji | path_drawing | 1.0.1 |
| TTS | flutter_tts | 4.2.3 |
| Monorepo | Melos | — |
| Rendering | Impeller / Vulkan (Android) | — |

---

## 🎮 Motores de Juego

### MECA (infinito)
Motor principal de mecanización. El `TimelineProvider` gestiona nodos `FeedNode` en secuencia infinita. **No existe pantalla de "completado"** — genera el siguiente nodo inmediatamente. Solo muestra reporte en niveles de campaña y modo hardcore (game over).

### Motor SRS Kanji
- Tiers: `E → D → C → B → A → S`
- `TierCalculator`: basado en `hitRate` + `avgMs`. `avgMs=0` → no suma puntos (sin práctica aún).
- `KanjiSrsNotifier`: penalizaciones `initial=0.1 / withdrawal=0.25 / inversion=0.5 / discriminatory=0.1`.
- Pool actualizado en memoria tras cada intento (`_updatePoolAfterAttempt`). `_initializePool` solo cuando `avgScore ≥ 7.0`.

### InputValidator / MecaEvaluator
Soporte completo de alternativas romaji: `si→shi`, `ti→chi`, `tu→tsu`, `hu→fu`, `zi→ji`, `sya→sha`, `tya→cha`, etc. **Las alternativas completas se evalúan antes que los prefijos** (orden crítico).

---

## 🎨 Sistema de Diseño — Cyber-Zen Industrial

| Token | Valor | Uso |
|---|---|---|
| `bgObsidian` | `#000000` | Fondo OLED absoluto |
| `textNeutral` | `#FFFFFF` | Texto principal |
| `errorRed` | `#E53935` | Feedback de error |
| `defaultAccent` | `#00E676` | Acento éxito (verde) |
| Acentos dinámicos | verde/rojo/naranja/azul/morado/blanco | Seleccionables en ajustes |

**Reglas de diseño:**
- Sin degradados. Sin sombras suaves. Contraste radical.
- Animaciones: `flutter_animate` únicamente — prohibido `AnimationController` manual para micro-UI.
- `KanjiVgPainter`: único componente que usa `AnimationController` (animación de trazos SVG).
- Layout reactivo al teclado: `LayoutBuilder` + `viewInsets.bottom` para elevar input sobre teclado nativo.

---

## ⚙️ Ajustes Disponibles

| Ajuste | Opciones |
|---|---|
| Color de acento | Verde / Rojo / Naranja / Azul / Morado / Blanco |
| Grosor de trazo SVG | 1.0 — 4.0 |
| Velocidad animación SVG | 0.5s — 3.0s |
| Escala de cuadrícula | S/L/XL/Auto |
| Reloj de muerte | Off / 5s / 3s / 1.5s / 1s / 0.75s / 0.5s |
| Modo hardcore | On/Off + vidas |
| Asistencia romaji | On/Off + umbral de errores |
| Audio TTS | On/Off |
| Animación de trazos | On/Off |
| Idioma del motor | ES / EN / JP |
| Sistema progresivo | Hiragana / Katakana / Ambos |

---

## 💾 Persistencia de Datos

- **Isar 3** local en dispositivo — sin servidor, sin nube.
- Semilla inicial: 138+ caracteres kana + kanji desde `assets/data/kanji_seed.json`.
- Historial en `historyBlob` (lista de enteros): `bit15=isCorrect`, `bit14=isDoubleStroke`, `bits0-13=responseMs` — sin tablas relacionales pesadas.
- Escrituras asíncronas en background. Lecturas cacheadas en memoria durante gameplay.

---

## 🚀 Instalación y Desarrollo

### Requisitos
- Flutter ≥ 3.32.5
- Dart ≥ 3.8.1
- [Melos](https://melos.invertase.dev) instalado globalmente

### Setup

```bash
# Clonar
git clone https://github.com/calinrus-dev/KanjiZen.git
cd KanjiZen

# Instalar dependencias del monorepo
melos bootstrap

# Compilar código generado (Freezed + Riverpod)
cd packages/kz_domain
dart run build_runner build --delete-conflicting-outputs

# Ejecutar en dispositivo Android
cd apps/kanjizen_app
flutter run -d <device_id>

# Verificar análisis estático
dart analyze
```

### Estructura de Directorios

```
KanjiZen/
├── apps/
│   └── kanjizen_app/          # Aplicación Flutter principal
│       ├── lib/src/
│       │   ├── features/      # Screens por feature (home, campaign, inventory, profile…)
│       │   ├── providers/     # GameNotifier, TimelineProvider, KanjiSrsNotifier
│       │   └── router/        # GoRouter (app_router.dart)
│       └── assets/data/       # kanji_seed.json
├── packages/
│   ├── kz_core/               # Temas, constantes, interfaces
│   ├── kz_data/               # Isar entities, repositories, DB initializer
│   ├── kz_domain/             # SRS engine, settings, validators
│   └── kz_ui_components/      # Sistema atómico de UI + painters
└── tools/
    └── mason/                 # Bricks para generación de código
```

---

## 📊 Estado del Proyecto

| Check | Estado |
|---|---|
| `dart analyze` | ✅ No issues found |
| Build Android (debug) | ✅ app-debug.apk |
| Probado en dispositivo | ✅ Realme RMX5010 — Android 16 (API 36) — Impeller/Vulkan |
| MECA infinito | ✅ |
| KanjiLevelMatrix | ✅ |
| CharacterDetailSheet KanjiVG + TTS | ✅ |
| GeneralDrawer + Perfil + Ajustes | ✅ |
| Inventario con acento dinámico | ✅ |

---

## 🔌 Créditos y Datos Abiertos

| Fuente | Uso |
|---|---|
| **KanjiVG** (Ulrich Apel) | Vectores SVG de trazos de kanji — parseados a comandos Dart en local |
| **KANJIDIC2** (EDRDG) | Lecturas Onyomi/Kunyomi y significados — filtrado a JSON de seed |
| **flutter_animate** | Micro-animaciones UI (shakeX en error, fadeIn, scale, slideY) |
| **Isar** | Base de datos NoSQL embebida de alto rendimiento |
| **Riverpod** | Gestión de estado reactiva e inmutable |
| **GoRouter** | Navegación declarativa |

---

*Zero BS. Latencia cero. Fluidez nativa.*
