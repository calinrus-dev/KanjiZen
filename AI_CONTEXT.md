# 🤖 KANJIZEN AI CONTEXT
> Documento de Referencia Inmutable para Agentes LLM y Arquitectos de Software.

Este documento establece las directrices visuales, arquitectónicas y de comportamiento **inmutables** para el monorepo Kanjizen. **TODO código generado debe ceñirse ESTRICTAMENTE a estas especificaciones.**

## 1. SISTEMA DE DISEÑO CYBER-ZEN INDUSTRIAL
La interfaz maneja un contraste radical, plano y de alta visibilidad. No se permiten degradados ni suavizados que incrementen la latencia de repintado.
*   `bgObsidian` (`0xFF0D0E15`): Fondo absoluto y mate. Evita destellos.
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
1.  **RayitaInput (Molecule)**: TextField sin bordes. Renderiza solo `Border(bottom)`. Si falla (InputState.error), aplica un `shakeX` inmediato con `flutter_animate`.
2.  **KanjiVectorPainter**: Procesa SVG crudos de KanjiVG y los dibuja por comandos Dart. Prohibido usar librerías de SVG pesadas.
3.  **Layout Reactivo al Teclado**: Todo layout principal (`HomeScreen`) debe envolverse en un `LayoutBuilder` escuchando `viewInsets.bottom` para levantar la caja de texto estáticamente **sobre** el teclado nativo, sin repintar el Canvas central.
4.  **Generación de Código**: Todo cambio en `kz_data` o `kz_domain` requiere correr `dart run build_runner build -d`. Freezed v3+ requiere usar `abstract class Modelo with _$Modelo`.

## 4. PERSISTENCIA DE DATOS Y RENDIMIENTO
- No se permiten guardados asíncronos en el hilo principal durante el gameplay.
- El historial se almacena en un `historyBlob` (Lista de enteros) manipulando bits (Codificando isCorrect, doubleStroke, responseMs) para evitar tablas relacionales pesadas.
- La semilla inicial de la BD (138+ caracteres) se hace mediante un `Isolate` (`compute`) detrás del Splash Screen.

---
*Fin de las directivas. Actúa de forma pragmática, con latencia cero y omite cualquier "boilerplate" innecesario en tus respuestas.*
