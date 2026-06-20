# 🤖 KANJIZEN AI CONTEXT
> Documento de Referencia Inmutable para Agentes LLM y Arquitectos de Software.

Este documento establece las directrices visuales, arquitectónicas y de comportamiento **inmutables** para el monorepo Kanjizen. **TODO código generado debe ceñirse ESTRICTAMENTE a estas especificaciones.**

## 1. SISTEMA DE DISEÑO CYBER-ZEN INDUSTRIAL
La interfaz maneja un contraste radical, plano y de alta visibilidad. No se permiten degradados ni suavizados que incrementen la latencia de repintado.
*   `bgObsidian` (`0xFF000000`): Fondo absoluto OLED. Negro puro.
*   `textNeutral` (`0xFFFFFFFF`): Texto principal de alto contraste.
*   `errorRed` (`0xFFE53935`): Feedback inmediato para fallos críticos de entrada.
*   `defaultAccent` (`0xFF00E676`): Acento primario para éxito. Controlado dinámicamente vía Riverpod.

## 2. ARQUITECTURA DEL MONOREPO (MELOS)
El proyecto es un monorepo gestionado por Melos con división draconiana (DDD):
1.  `kz_core`: Temas, constantes, interfaces abstractas (`ICharacterRepository`). Cero dependencias externas complejas.
2.  `kz_data`: Modelos `@collection` de Isar, servicios de inicialización por Isolates, y repositorios locales.
3.  `kz_domain`: Lógica de negocio pura, Freezed models inmutables, `InputValidator`, y `SrsEngine` (Riverpod).
4.  `kz_ui_components`: Sistema Atómico (Atoms, Molecules, Organisms). Uso estricto de `flutter_animate` (prohibido `AnimationController` manual para micro-animaciones UI). Painters de alto rendimiento vectorial.
5.  `kanjizen_app`: Aplicación orquestadora. Inyección de Riverpod, GoRouter, y pantallas principales.

## 3. REGLAS ESTRUCTURALES Y UI
1.  **RayitaInput (Molecule)**: TextField sin bordes. Renderiza solo `Border(bottom)`. Si falla (InputState.error), aplica un `shakeX` inmediato con `flutter_animate`. El `shakeX` usa `target: 1/0` — no `AnimationController` manual.
2.  **KanjiVectorPainter** (`kz_ui_components/src/painters/`): Painter de producción. Procesa SVG crudos de KanjiVG y los dibuja por comandos Dart vía `path_drawing`. Soporta modo estático (`progress=1.0`) y animado trazo a trazo. Incluye efecto glow con `MaskFilter`. **Siempre envolver en `canvas.save()`/`canvas.restore()`.**
3.  **KanjiVgPainter** (`kz_ui_components/src/atoms/`): Painter alternativo que acepta `Animation<double>`. Usar cuando se requiere integración directa con `AnimationController`. También requiere `canvas.save()`/`canvas.restore()`.
4.  **Layout Reactivo al Teclado**: Todo layout principal (`HomeScreen`) debe envolverse en un `LayoutBuilder` escuchando `viewInsets.bottom` para levantar la caja de texto estáticamente **sobre** el teclado nativo, sin repintar el Canvas central.
5.  **Generación de Código**: Todo cambio en `kz_data` o `kz_domain` requiere correr `dart run build_runner build -d`. Freezed v3+ requiere usar `abstract class Modelo with _$Modelo`.
6.  **Accent desde Theme**: Los organisms (`CyberZenModal`, etc.) deben leer el acento del usuario via `Theme.of(context).extension<CyberThemeExtension>()?.accentColor ?? CyberTheme.defaultAccent`. Nunca hardcodear `CyberTheme.defaultAccent` en widgets que se muestran al usuario.

## 4. MOTOR SRS — REGLAS CRÍTICAS

### InputValidator (kz_domain)
*   Soporta alternativas romaji: `si`→`shi`, `ti`→`chi`, `tu`→`tsu`, `hu`→`fu`, `zi`→`ji`, `sya`→`sha`, `tya`→`cha`, etc.
*   **CRÍTICO**: Los checks de alternativas COMPLETAS deben ejecutarse ANTES del check de prefijos en `evaluateStep()`. Si 'si' está en `_multiCharRomaji['shi']` como prefijo, la comprobación de éxito nunca se alcanza — el orden importa.
*   `_multiCharRomaji` contiene solo **prefijos** parciales para cada romaji multi-char. Los matches completos se manejan en los `if` explícitos al inicio de `evaluateStep`.

### MecaEvaluator (kz_domain)
*   Motor de evaluación on-change para el motor MECA.
*   Idéntico orden de precedencia: alternativas completas → prefijo canónico → prefijos de alternativas → error.
*   Usa `const _romajiAlternatives` (top-level) para el mapeo.

### TierCalculator (kz_domain)
*   `calculate({hitRate, avgMs, isUnlocked})` devuelve `KanaTier.e` si:
    - `!isUnlocked`
    - `avgMs == 0 && hitRate == 0.0` (sin práctica aún — evita inflar tier)
*   El `avgMs=0` **NO** se trata como "rápido" — no suma puntos al score.

### GameNotifier (kanjizen_app)
*   Usa `final Random _random = Random()` (de `dart:math`) para la selección ponderada. **NO** usar `DateTime.now().microsecondsSinceEpoch % 1000` como fuente de aleatoriedad.
*   `avgMs` en `GameState` es un **promedio móvil** de todos los intentos de la sesión, no el último tiempo de respuesta.
*   Fórmula: `newAvgMs = prevAttempts > 0 ? ((state.avgMs * prevAttempts + responseMs) ~/ (prevAttempts + 1)) : responseMs`

### KanjiSrsNotifier (kanjizen_app)
*   Penalizaciones por fase: `initial=0.1`, `withdrawal=0.25`, `inversion=0.5`, `discriminatory=0.1`.
*   Tras cada intento, usar `_updatePoolAfterAttempt(updatedKanji)` para actualización en memoria. Solo llama a `_initializePool()` cuando `avgScore >= KzConstants.kanjiPoolThreshold (7.0)`.
*   **NO** llamar a `_initializePool()` directamente en `recordSuccess`/`recordError` — es costoso (read completo de BD).

## 5. PERSISTENCIA DE DATOS Y RENDIMIENTO
- No se permiten guardados asíncronos en el hilo principal durante el gameplay.
- El historial se almacena en un `historyBlob` (Lista de enteros) manipulando bits (Codificando isCorrect, doubleStroke, responseMs) para evitar tablas relacionales pesadas.
- Encoding: `bit 15 = isCorrect (0x8000)`, `bit 14 = isDoubleStroke (0x4000)`, `bits 0-13 = ms (0x3FFF)`.
- La semilla inicial de la BD (138+ caracteres) se hace mediante `DatabaseInitializerService.seedInBackground()` (llamado desde Splash).
- Los kanjis se siembran desde `assets/data/kanji_seed.json` en bloques de 1000 (`seedBatchSize`).

## 6. ESTADO DEL ANÁLISIS ESTÁTICO
- **Última verificación**: `dart analyze` → **No issues found** (0 errores, 0 warnings, 0 infos).
- Comando para re-verificar desde raíz del monorepo: `dart analyze`

---
*Fin de las directivas. Actúa de forma pragmática, con latencia cero y omite cualquier "boilerplate" innecesario en tus respuestas.*
