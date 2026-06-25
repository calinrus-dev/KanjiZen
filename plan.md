# KANJIZEN PRO — PLAN DE REFACTORIZACIÓN UI RESPONSIVE

## Estado actual (actualizado tras auditoría y refactor)

### ✅ Completado

1. **Auditoría de RenderFlex overflows**
   - Revisados 36+ archivos de UI en `apps/kanjizen_app` y `packages/kz_ui_components`.
   - Identificados y corregidos los puntos críticos de overflow.

2. **Fixes de UI críticos aplicados**
   - `dynamic_terminal_bar.dart`: grid de quiz con altura finita calculada por filas y scroll físico; altura del teclado Flick acotada.
   - `kanji_level_matrix_screen.dart`: motor de adquisición envuelto en `LayoutBuilder` + `SingleChildScrollView` + `ConstrainedBox(minHeight: ...)` para evitar bottom overflow con teclado.
   - `character_detail_sheet.dart`: modal con `SingleChildScrollView` y gráfico de telemetría con altura fija en lugar de `Expanded`.
   - `kana_display.dart`: tamaños adaptativos mediante `LayoutBuilder`; escala proporcional según el espacio disponible.
   - `engine_selector_screen.dart`, `meca_context_settings.dart`, `meca_pool_settings.dart`: padding inferior ahora suma `MediaQuery.viewInsets.bottom` y los bottom sheets usan `SingleChildScrollView`.
   - `inventory_dashboard_screen.dart`: filtro inferior ahora usa `isScrollControlled: true`, `SingleChildScrollView` y padding con `viewInsets`.

3. **Polymorphic Input Engine**
   - Los 4 estados (A text/flick, B chat, C quiz grid, D arcade deck) ya estaban implementados en `DynamicTerminalBar`.
   - Se movió el stub `ChatNode` desde la capa UI a `timeline_provider.dart` junto al resto de nodos.
   - Se corrigieron imports para cumplir `always_use_package_imports`.

4. **Play Store readiness**
   - Etiqueta de app actualizada a `KanjiZen` en `AndroidManifest.xml`.
   - Generados iconos propios para todas las densidades Android (mdpi a xxxhdpi) y un icono 512×512 para Play Console.
   - Añadida versión `1.0.0+1` en `pubspec.yaml`.
   - Añadida dependencia `cupertino_icons` para evitar warning de fuentes en build.

5. **Verificación**
   - `dart analyze` limpio en los 5 paquetes del workspace.
   - `flutter test` pasa en los 5 paquetes.
   - `flutter build apk --release` genera `app-release.apk` (55.5 MB) correctamente.

### 📋 Pendiente recomendado (no crítico para lanzamiento)

- Crear iconos adaptativos Android (`mipmap-anydpi-v26/ic_launcher.xml`) con capas vectoriales.
- Configurar firma de release con un keystore propio antes de subir a Play Store (actualmente usa `signingConfig debug`).
- Redactar política de privacidad y capturas de pantalla para Play Console.
- Implementar backend LLM y hacer alcanzable el `EngineMode.chat` desde el selector de modos.
- Migrar `MecaEngineScreen` legacy a `EngineSelectorScreen` para unificar flujos.

### Reglas respetadas

- Lógica de negocio intacta: no se modificaron `TimelineNotifier`, `GameNotifier`, `Settings`, `SrsEngine`, `TierCalculator`, `MecaEvaluator`, `InputValidator`, ni entidades Isar.
- No se reescribieron providers ni se movió lógica de dominio a widgets.
- Se mantuvo el estilo Cyber-Zen y los contratos de los providers.
