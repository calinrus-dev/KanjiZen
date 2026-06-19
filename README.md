# KanjiZen ⛩️
> Zero BS. Latencia Cero. Fluidez Nativa.

KanjiZen no es una aplicación más para estudiar japonés con tablas planas y estáticas. Es un sistema implacable diseñado bajo el manifiesto de la ineficiencia absoluta del estudio tradicional, transformando el aprendizaje en **mecanización pura**.

Si estás estancado memorizando símbolos en una pared, este es tu cambio de juego.

## 🎯 La Metodología (MecaNet × Anki × Kahoot)

Kanjizen no te enseña a dibujar; te enseña a **mecanizar**.

*   **Orientación Espacial Pura (Teclado Flick):** Aprendes hacia dónde va cada vocal y consonante por memoria muscular. Si machacas el movimiento, cuando ves el dibujo ya sabes cómo suena en tu cabeza antes de pensarlo. (Soporta QWERTY con Romaji en PC/Web).
*   **Fusión de Conceptos:** La repetición implacable de las flashcards (Anki), la velocidad y corrección de escritura de MecaNet, y el ritmo frenético de un Kahoot.
*   **Interiorización Total:** En el Modo Kanji no solo escribes letras; relacionas conceptos, aíslas radicales y entiendes la lógica interna del carácter, no una simple traducción plana.

## ⚙️ Arquitectura Técnica (Bajo el Capó)

No hay fugas de estado ni interfaces que arrastran los pies. El código está diseñado bajo un modelo de dominio guiado (DDD) para no perdonar ni un milisegundo de latencia.

*   **Topología Melos:** Monorepo dividido estrictamente en paquetes (`kz_core`, `kz_data`, `kz_domain`, `kz_ui_components`) para aislar responsabilidades de forma draconiana.
*   **Zero Boilerplate UI:** Animaciones y micro-interacciones manejadas de forma fluida con `flutter_animate` (cero AnimationControllers expuestos).
*   **Estado Inmutable:** Flujo de datos unidireccional garantizado por `riverpod_annotation` y `freezed`.
*   **Base de Datos Híbrida (Isar):** Lecturas síncronas cacheadas en memoria para no bloquear la interfaz, y escrituras asíncronas en segundo plano. Historial ultrarrápido almacenando el progreso en un `historyBlob` comprimido en enteros mediante manipulación de bits.

## 🎮 Flujo de Aplicación

La interfaz reacciona de forma dinámica para evitar repintados innecesarios y no perder ni un frame.

1.  **Onboarding Invisible:** Durante el Splash, un *Isolate* silencioso carga y siembra la base de datos local para que todo esté listo al instante.
2.  **Pantalla Principal (Modo Meca):** Un panel de control reactivo. Header con métricas de racha y latencia cruda, área central de vectores, y `RayitaInput` abajo (un campo de texto sin bordes que tiembla al fallar).
3.  **Motor SRS y Tiers:** Un sistema que calcula tu "Tiempo Efectivo" (t_eff). Te clasifica sin piedad. Si quieres el *Tier S*, necesitas clavar los caracteres en menos de 500 ms.
4.  **Inventario y Perfil:** Drawers laterales con un *Activity Graph* estilo GitHub de tus últimos 365 días, mostrando tus 5 kanas dominantes frente a tus 5 errores críticos.

## 🔌 Créditos y Dependencias Core
Este ecosistema se alimenta de las mejores bases abiertas, parseadas en local para latencia cero:
*   **KanjiVG:** Archivos vectoriales crudos compilados a comandos Dart.
*   **KANJIDIC2:** Filtrado salvaje para inyectar solo lecturas Onyomi/Kunyomi y nodos de significado en español.
