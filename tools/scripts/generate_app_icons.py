#!/usr/bin/env python3
"""Genera los iconos de la app KanjiZen para Android en todas las densidades."""

from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

# ─── CONFIGURACIÓN ───────────────────────────────────────────────────────────

BASE_DIR = Path(__file__).resolve().parent.parent.parent
ANDROID_RES = BASE_DIR / "apps" / "kanjizen_app" / "android" / "app" / "src" / "main" / "res"
PLAYSTORE_DIR = BASE_DIR / "apps" / "kanjizen_app" / "android" / "app" / "src" / "main" / "playstore"

SIZES = {
    "mipmap-mdpi": 48,
    "mipmap-hdpi": 72,
    "mipmap-xhdpi": 96,
    "mipmap-xxhdpi": 144,
    "mipmap-xxxhdpi": 192,
}

BG_COLOR = "#000000"
ACCENT_COLOR = "#00E676"


def get_font(size: int) -> ImageFont.FreeTypeFont:
    """Intenta cargar una fuente monoespaciada del sistema; fallback a default."""
    candidates = [
        "C:/Windows/Fonts/consola.ttf",
        "C:/Windows/Fonts/courbd.ttf",
        "C:/Windows/Fonts/arialbd.ttf",
        "/usr/share/fonts/truetype/dejavu/DejaVuSansMono-Bold.ttf",
        "/System/Library/Fonts/Helvetica.ttc",
    ]
    for path in candidates:
        try:
            return ImageFont.truetype(path, size)
        except Exception:
            continue
    return ImageFont.load_default()


def draw_icon(size: int) -> Image.Image:
    """Dibuja un icono cuadrado con fondo negro, marco verde neón y monograma KZ."""
    img = Image.new("RGBA", (size, size), BG_COLOR)
    draw = ImageDraw.Draw(img)

    # Marco cuadrado con esquinas ligeramente redondeadas
    border_width = max(1, size // 32)
    inset = size // 12
    draw.rounded_rectangle(
        [inset, inset, size - inset, size - inset],
        radius=size // 16,
        outline=ACCENT_COLOR,
        width=border_width,
    )

    # Líneas diagonales de acento en las esquinas (estilo cyber)
    line_len = size // 8
    gap = size // 24
    corners = [
        (inset + gap, inset + gap, 1, 1),          # arriba-izq
        (size - inset - gap, inset + gap, -1, 1),   # arriba-der
        (inset + gap, size - inset - gap, 1, -1),   # abajo-izq
        (size - inset - gap, size - inset - gap, -1, -1),  # abajo-der
    ]
    for x, y, sx, sy in corners:
        draw.line(
            [(x, y), (x + line_len * sx, y)],
            fill=ACCENT_COLOR,
            width=max(1, size // 64),
        )
        draw.line(
            [(x, y), (x, y + line_len * sy)],
            fill=ACCENT_COLOR,
            width=max(1, size // 64),
        )

    # Monograma "KZ" centrado
    font_size = size // 3
    font = get_font(font_size)
    text = "KZ"
    bbox = draw.textbbox((0, 0), text, font=font)
    text_w = bbox[2] - bbox[0]
    text_h = bbox[3] - bbox[1]
    x = (size - text_w) // 2
    y = (size - text_h) // 2 - size // 32
    draw.text((x, y), text, font=font, fill=ACCENT_COLOR)

    return img


def main() -> None:
    for folder, size in SIZES.items():
        out_dir = ANDROID_RES / folder
        out_dir.mkdir(parents=True, exist_ok=True)
        img = draw_icon(size)
        out_path = out_dir / "ic_launcher.png"
        img.save(out_path, "PNG")
        print(f"Generado: {out_path}")

    # Icono de 512x512 para Google Play Console
    PLAYSTORE_DIR.mkdir(parents=True, exist_ok=True)
    playstore_icon = draw_icon(512)
    playstore_path = PLAYSTORE_DIR / "ic_launcher_512.png"
    playstore_icon.save(playstore_path, "PNG")
    print(f"Generado: {playstore_path}")


if __name__ == "__main__":
    main()
