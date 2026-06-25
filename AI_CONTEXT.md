# 🤖 KANJIZEN AI CONTEXT
> Documento de referencia para agentes LLM y arquitectos de software.

Este archivo resume el estado actual del monorepo KanjiZen y las reglas que deben respetarse al generar o modificar código.

## 1. IDENTIDAD DEL PROYECTO
- Repositorio: [github.com/calinrus-dev/KanjiZen](https://github.com/calinrus-dev/KanjiZen)
- Rama principal: `main`
- Estructura: monorepo Flutter/Dart gestionado con Melos
- Objetivo: mecanización del estudio de kana y kanji con feedback inmediato, SRS local y UI de latencia baja

## 2. SISTEMA DE DISEÑO CYBER-ZEN INDUSTRIAL
La interfaz usa contraste radical, superficies planas y feedback de alta visibilidad. No se permiten degradados suaves ni adornos que añadan coste innecesario de repintado.

Tokens base:
- `bgObsidian` (`0xFF000000`): fondo OLED negro puro
- `textNeutral` (`0xFFFFFFFF`): texto principal
- `errorRed` (`0xFFE53935`): error crítico
- `defaultAccent` (`0xFF00E676`): acento primario por defecto

Reglas visuales:
- Los acentos del usuario se leen desde `settingsProvider`.
- Los organisms deben usar `Theme.of(context).extension<CyberThemeExtension>()?.accentColor ?? CyberTheme.defaultAccent`.
- `flutter_animate` se usa para micro-interacciones de UI; no introducir `AnimationController` manual salvo para animación explícita de trazos SVG.
- **NUEVO**: los layouts deben ser elásticos. Está prohibido usar anchos/altos estáticos en contenedores principales, diálogos y menús. Usar `LayoutBuilder`, `Expanded`, `Flexible`, `Wrap`, `FittedBox` y proporciones de `MediaQuery`.

## 3. ARQUITECTURA DEL MONOREPO
El proyecto está dividido por capas DDD:

1. `kz_core`: constantes, tema Cyber-Zen, contratos abstractos e interfaces.
2. `kz_data`: entidades Isar, repositorios locales, servicios de seed y parseo de datos.
3. `kz_domain`: lógica pura de negocio, modelos Freezed, validadores, SRS, settings.
4. `kz_ui_components`: sistema atómico UI, painters vectoriales, modales y widgets reutilizables.
5. `kanjizen_app`: orquestación Flutter, rutas, pantallas, providers y composición final.

## 4. ESTRUCTURA ACTUAL DEL APP
Rutas principales:

- `/` -> `SplashScreen`
- `/auth` -> `AuthScreen`
- `/home` -> `EngineSelectorScreen`
- `/home/inventory` -> `InventoryDashboardScreen`
- `/home/kanas` -> `KanaLevelMatrixScreen`
- `/home/kanjis` -> `KanjiLevelMatrixScreen`

Componentes clave actuales:
- `GeneralDrawer` incluye botón `[ KANJIS ]` y acceso al perfil.
- `ProfileDrawer` abre ajustes ampliados en un bottom sheet.
- `CharacterDetailSheet` muestra KanjiVG animado y botón TTS.
- `InventoryDashboardScreen` usa acento dinámico y autoexpande kanji al filtrar.
- `TimelineProvider` orquesta todos los motores (MECA, KANJI, QUIZ, ARCADE, WRITE) y aplica reset completo al cambiar de modo.

## 5. REGLAS ESTRUCTURALES Y UI
1. `RayitaInput` debe seguir siendo minimalista: solo borde inferior y `shakeX` en error mediante `flutter_animate`. **No debe limpiar su propio controller ni pedir foco.**
2. `KanjiVectorPainter` procesa rutas SVG de KanjiVG con `path_drawing`, admite modo estático y animado, e incluye `canvas.save()`/`canvas.restore()`.
3. `KanjiVgPainter` acepta `Animation<double>` y se usa cuando hay una animación de trazos real.
4. Los layouts sensibles al teclado deben usar `LayoutBuilder` y `resizeToAvoidBottomInset: true`. El canvas central debe vivir dentro de `Flexible`/`Expanded` para ceder espacio al teclado.
5. Cualquier cambio en `kz_data` o `kz_domain` requiere regenerar código con `dart run build_runner build --delete-conflicting-outputs`.
6. Freezed v3+ debe declararse como `abstract class Modelo with _$Modelo`.
7. **NUEVO - Cero cross-talk**: al cambiar de modo, `TimelineNotifier.setEngineMode` cancela timers, limpia campañas y resetea métricas de sesión. Nunca se debe arrastrar estado de un motor a otro.
8. **NUEVO - Feed finito**: el historial de nodos congelados está limitado a `kMaxFrozenNodes = 50`. No renderizar más nodos de los necesarios.
9. **NUEVO - Input buffer**: `DynamicTerminalBar` es el único propietario del `TextEditingController` y del foco. Limpia síncronamente al detectar `success`/`error` y al cambiar de nodo.
10. **NUEVO - Rejillas responsivas**: usar `SliverGridDelegateWithMaxCrossAxisExtent` en lugar de `crossAxisCount` fijo. Las celdas bloqueadas muestran el glifo atenuado + icono de candado pequeño (`16×16`) en esquina.

## 6. MOTOR SRS Y VALIDACIÓN
### InputValidator
- Soporta alternativas romaji: `si->shi`, `ti->chi`, `tu->tsu`, `hu->fu`, `zi->ji`, `sya->sha`, `tya->cha`, etc.
- Las alternativas completas se evalúan antes que los prefijos.
- `_multiCharRomaji` debe contener solo prefijos parciales.

### MecaEvaluator
- Misma precedencia que `InputValidator`: alternativas completas -> prefijo canónico -> prefijos de alternativas -> error.

### TierCalculator
- `calculate({hitRate, avgMs, isUnlocked})` devuelve `KanaTier.e` si no está desbloqueado o si no existe práctica real (`avgMs == 0 && hitRate == 0.0`).
- `avgMs = 0` no cuenta como rapidez.

### GameNotifier
- La selección ponderada usa `final Random _random = Random()`.
- `avgMs` es promedio móvil de toda la sesión, no el último intento.

### KanjiSrsNotifier
- Penalizaciones actuales: `initial=0.1`, `withdrawal=0.25`, `inversion=0.5`, `discriminatory=0.1`.
- `_updatePoolAfterAttempt(updatedKanji)` actualiza en memoria.
- `_initializePool()` solo se llama cuando `avgScore >= KzConstants.kanjiPoolThreshold (7.0)`.

## 7. PANTALLAS Y MODOS ACTUALES
- MECA es infinito en sesiones normales; solo hay pantalla de reporte en campañas y game over hardcore.
- `KanaLevelMatrixScreen` existe como mapa de niveles kana.
- `KanjiLevelMatrixScreen` es la pantalla de adquisición kanji en dos fases.
- `InventoryDashboardScreen` y `ProfileDrawer` ya forman parte de la navegación principal.
- `SettingsState` ya incluye `strokeWidth` y `strokeAnimationSpeed` además de audio, animación de trazos, hardcore y ajustes de grid.

## 8. PERSISTENCIA Y RENDIMIENTO
- No se permiten guardados asíncronos en el hilo principal durante el gameplay.
- El historial usa `historyBlob` con enteros de 16 bits:
    - bit 15 = `isCorrect` (`0x8000`)
    - bit 14 = `isDoubleStroke` (`0x4000`)
    - bits 0-13 = `ms` (`0x3FFF`)
- La semilla inicial se carga desde `DatabaseInitializerService.seedInBackground()`.
- Los kanjis se siembran desde `assets/data/kanji_seed.json` en lotes de 1000 (`seedBatchSize`).

## 9. STACK ACTUAL
- Flutter `>= 3.32.5`
- Dart `>= 3.8.1`
- Riverpod `2.6.1`
- Freezed `3.0.0`
- Isar `3.1.0+1`
- GoRouter `14.8.1`
- flutter_animate `4.5.2`
- flutter_tts `4.2.3`
- path_drawing `1.0.1`
- lottie `3.3.1`

## 10. ESTADO VERIFICADO DEL PROYECTO
- `flutter analyze` -> `No issues found`
- `melos run test` -> `All tests passed`
- Último dispositivo físico ejecutado: Realme RMX5010 (Android 15)
- El repositorio sincronizado con `origin/main`

## 11. REGLA DE TRABAJO PARA AGENTES
- Cambiar lo mínimo necesario.
- No reescribir áreas fuera del alcance.
- Si un cambio toca `kz_data` o `kz_domain`, validar regeneración de código y análisis estático.
- **NUEVO**: todo layout nuevo debe pasar la prueba de 320 dp de ancho sin `RenderFlex overflow`.
- **NUEVO**: todo motor nuevo debe integrarse con `TimelineNotifier` y respetar el ciclo de reset de `setEngineMode`.

---
Actúa de forma pragmática, con latencia cero, y omite boilerplate innecesario en las respuestas.
