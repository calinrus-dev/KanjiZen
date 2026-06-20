# kz_data

Capa de persistencia del monorepo **KanjiZen**. Gestiona todas las entidades de base de datos Isar, los repositorios locales y la inicialización de datos en background.

---

## Responsabilidad

- Definir entidades `@collection` para Isar 3
- Implementar repositorios concretos que cumplen `ICharacterRepository`
- Orquestar la siembra inicial de datos desde assets (Isolate background)
- Scripts de parseo de datos crudos (KanjiVG, KANJIDIC2)

## Estructura

```
lib/src/
├── entities/
│   ├── kana_entity.dart        # KanaEntity @collection — kana + historyBlob + tier
│   ├── kanji_entity.dart       # KanjiEntity @collection — kanji + svgPaths + readings
│   └── kana_level_entity.dart  # KanaLevelEntity @collection — estado de niveles
├── repositories/               # Implementaciones concretas de ICharacterRepository
└── services/
    └── database_initializer_service.dart  # Seed en Isolate desde kanji_seed.json

scripts/
└── kanji_parser_script.dart    # Parseo offline KanjiVG + KANJIDIC2 → JSON seed

raw_data/                       # Datos crudos KanjiVG / KANJIDIC2 (no incluidos en app)
```

## Esquema de Datos

### KanaEntity
| Campo | Tipo | Descripción |
|---|---|---|
| `id` | `Id` | Isar auto-ID |
| `character` | `String` | El carácter kana |
| `romaji` | `String` | Lectura romaji |
| `historyBlob` | `List<int>` | Historial comprimido en bits |
| `score` | `double` | Score SRS acumulado |
| `tier` | `String` | E/D/C/B/A/S |

### KanjiEntity
| Campo | Tipo | Descripción |
|---|---|---|
| `character` | `String` | El carácter kanji |
| `svgPaths` | `List<String>` | Rutas SVG de trazos (KanjiVG) |
| `onyomi` | `List<String>` | Lecturas On'yomi |
| `kunyomi` | `List<String>` | Lecturas Kun'yomi |
| `meaningEs` | `String` | Significado en español |
| `meaningEn` | `String` | Significado en inglés |
| `jlptLevel` | `int?` | Nivel JLPT (1-5) |
| `grade` | `int?` | Grado escolar japonés |

## Codificación historyBlob

Cada entrada del historial se comprime en **un entero de 16 bits**:
```
bit 15  = isCorrect   (0x8000)
bit 14  = isDoubleStroke (0x4000)
bits 0-13 = responseMs (0x3FFF, máx 16383 ms)
```

## DatabaseInitializerService

Usa un Isolate para no bloquear el hilo principal durante el splash:
```dart
await DatabaseInitializerService.seedInBackground(isarPath);
```
Siembra bloques de 1000 kanjis (`seedBatchSize`) desde `assets/data/kanji_seed.json`.

## Código Generado

Tras cambios en entidades, regenerar con:
```bash
dart run build_runner build --delete-conflicting-outputs
```
