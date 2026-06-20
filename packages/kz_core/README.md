# kz_core

Capa base del monorepo **KanjiZen**. Define constantes globales, el sistema de diseño Cyber-Zen, interfaces abstractas y errores de dominio.

> Sin dependencias externas complejas — puede importarse desde cualquier capa sin riesgo de ciclos.

---

## Responsabilidad

- Exportar el tema visual (`CyberTheme`, `CyberThemeExtension`)
- Definir constantes globales (`KzConstants`)
- Declarar interfaces abstractas (`ICharacterRepository`)
- Centralizar tipos de error de dominio

## Estructura

```
lib/src/
├── constants/     # KzConstants (thresholds SRS, batch sizes, etc.)
├── errors/        # Tipos de error de dominio
├── interfaces/    # ICharacterRepository y contratos abstractos
└── theme/         # CyberTheme, CyberThemeExtension, tokens de color
```

## Sistema de Diseño — Tokens de Color

| Token | Hex | Uso |
|---|---|---|
| `bgObsidian` | `#000000` | Fondo OLED absoluto |
| `textNeutral` | `#FFFFFF` | Texto principal |
| `errorRed` | `#E53935` | Feedback de error inmediato |
| `defaultAccent` | `#00E676` | Acento primario (verde) |

Los acentos son dinámicos: `CyberAccent.green / red / orange / blue / purple / white`. Se leen en runtime desde `settingsProvider` — nunca se hardcodean en widgets de usuario.

## Reglas de Uso

- **No** agregar dependencias de Flutter (`flutter_riverpod`, `go_router`, etc.) a este paquete.
- Los organisms de `kz_ui_components` leen el acento vía `Theme.of(context).extension<CyberThemeExtension>()?.accentColor ?? CyberTheme.defaultAccent`.
