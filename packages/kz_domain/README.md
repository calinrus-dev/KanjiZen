# kz_domain

Capa de lógica de negocio pura del monorepo **KanjiZen**. Sin dependencias de Flutter. Contiene el motor SRS, evaluadores de input, calculador de tiers y el estado de ajustes inmutable.

---

## Responsabilidad

- Motor de Repetición Espaciada (SRS) para kana y kanji
- Evaluación on-change de input del usuario (`MecaEvaluator`, `InputValidator`)
- Cálculo de tiers de rendimiento (`TierCalculator`)
- Modelo de ajustes de usuario (`SettingsState` — Freezed + Riverpod)
- Modelos de dominio inmutables (Freezed v3)

## Estructura

```
lib/src/
├── engine/
│   ├── meca_evaluator.dart     # Evaluación MECA on-change con alternativas romaji
│   ├── tier_calculator.dart    # hitRate + avgMs → KanaTier (E→S)
│   └── srs_engine.dart         # @riverpod SrsEngine — score updates
├── models/                     # Modelos Freezed inmutables del dominio
├── settings/
│   ├── settings_state.dart     # SettingsState (@freezed) — todos los ajustes
│   └── settings_provider.dart  # Notifier de settings con setters
└── validators/
    └── input_validator.dart    # Validación keystroke a keystroke con romaji alternativas
```

## Motor SRS — TierCalculator

```
E → sin práctica (avgMs=0 y hitRate=0) o no desbloqueado
D → hitRate < 50%
C → hitRate 50-69%
B → hitRate 70-84% o avgMs > 1500ms
A → hitRate 85-94%
S → hitRate ≥ 95% y avgMs < 500ms
```

**Regla crítica:** `avgMs=0` NO se trata como "rápido" — devuelve `KanaTier.e` para evitar inflar el tier en caracteres sin práctica.

## InputValidator / MecaEvaluator — Alternativas Romaji

Ambos evaluadores soportan alternativas completas **antes** de evaluar prefijos:

| Romaji alternativo | Romaji canónico |
|---|---|
| `si` | `shi` |
| `ti` | `chi` |
| `tu` | `tsu` |
| `hu` | `fu` |
| `zi` | `ji` |
| `sya` | `sha` |
| `tya` | `cha` |
| `tsu` | `tsu` |

> **CRÍTICO:** El orden de evaluación importa — alternativas completas → prefijo canónico → prefijos de alternativas → error.

## SettingsState

Estado inmutable gestionado por Riverpod. Campos principales:

| Campo | Tipo | Default |
|---|---|---|
| `accentColor` | `CyberAccent` | `.green` |
| `strokeWidth` | `double` | `2.0` |
| `strokeAnimationSpeed` | `double` | `1.5` |
| `enableAudio` | `bool` | `true` |
| `enableStrokeAnimation` | `bool` | `true` |
| `hardcoreMode` | `bool` | `false` |
| `romajiAssist` | `bool` | `false` |
| `deathClock` | `DeathClock` | `.off` |
| `gridScale` | `GridScale` | `.auto` |
| `engineMode` | `EngineMode` | `.meca` |
| `engineLanguage` | `EngineLanguage` | `.es` |

Ver `settings_state.dart` para la lista completa de enums y campos.

## Código Generado

Tras cambios en modelos Freezed o providers `@riverpod`:
```bash
dart run build_runner build --delete-conflicting-outputs
```

Freezed v3+ requiere: `abstract class Modelo with _$Modelo { ... }`
