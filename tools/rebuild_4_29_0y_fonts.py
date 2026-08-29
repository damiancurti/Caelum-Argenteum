#!/usr/bin/env python3
"""Reconstruye las fuentes bitmap V4.29.0y a resolución física 2x."""

from __future__ import annotations

import argparse
import math
from dataclasses import dataclass
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


@dataclass(frozen=True)
class FontConfig:
    source: str
    point_size: int
    font_height: int
    space_width: int


FONT_CONFIGS = {
    "alternativebigfont": FontConfig("serif", 12, 19, 7),
    "alternativesmallfont": FontConfig("serif", 10, 17, 8),
    "bigfont": FontConfig("serif", 12, 19, 7),
    "caelumdisplay": FontConfig("serif", 13, 21, 8),
    "caelummono": FontConfig("mono", 8, 14, 8),
    "caelumsmall": FontConfig("serif", 7, 13, 5),
    "caelumtext": FontConfig("serif", 9, 16, 8),
    "consolefont": FontConfig("mono", 8, 14, 8),
    "indexfont": FontConfig("serif", 7, 13, 5),
    "newconsolefont": FontConfig("mono", 9, 16, 8),
    "newsmallfont": FontConfig("serif", 10, 17, 8),
    "smallfont": FontConfig("serif", 8, 14, 8),
}

CODEPOINTS = (*range(33, 127), *range(161, 256))
FILL = (255, 255, 255, 255)
OUTLINE = (18, 20, 24, 230)


def logical_width(font: ImageFont.FreeTypeFont, character: str) -> int:
    # El guion blando no dibuja píxeles en DejaVu, pero el atlas histórico le
    # reserva cinco unidades. Se conserva para no alterar métricas guardadas.
    if ord(character) == 0x00AD:
        return 5
    bbox = font.getbbox(character, stroke_width=1)
    draw_x = 2 - bbox[0]
    return math.ceil(font.getlength(character)) + draw_x + 1


def render_glyph(
    logical_font: ImageFont.FreeTypeFont,
    high_resolution_font: ImageFont.FreeTypeFont,
    character: str,
    logical_height: int,
) -> Image.Image:
    width = logical_width(logical_font, character) * 2
    bbox = high_resolution_font.getbbox(character, stroke_width=2)
    draw_x = 4 - bbox[0]
    draw_y = 4

    # FreeType puede redondear un borde a medio píxel al duplicar el tamaño.
    # Una columna física impar conserva el mismo XMove porque GZDoom aplica
    # Scale 2 antes de convertir el avance a entero.
    required_width = draw_x + bbox[2]
    width = max(width, required_width)
    image = Image.new("RGBA", (width, logical_height * 2), (0, 0, 0, 0))
    ImageDraw.Draw(image).text(
        (draw_x, draw_y),
        character,
        font=high_resolution_font,
        fill=FILL,
        stroke_width=2,
        stroke_fill=OUTLINE,
    )
    return image


def rebuild_font(
    fonts_root: Path,
    directory_name: str,
    config: FontConfig,
    source_paths: dict[str, Path],
) -> None:
    destination = fonts_root / directory_name
    if not destination.is_dir():
        raise FileNotFoundError(f"No existe el directorio de fuente: {destination}")

    source_path = source_paths[config.source]
    logical_font = ImageFont.truetype(str(source_path), config.point_size)
    high_resolution_font = ImageFont.truetype(
        str(source_path), config.point_size * 2
    )

    for codepoint in CODEPOINTS:
        glyph = render_glyph(
            logical_font,
            high_resolution_font,
            chr(codepoint),
            config.font_height,
        )
        glyph.save(destination / f"{codepoint:04X}.png", optimize=True)

    (destination / "font.inf").write_text(
        "\n".join(
            (
                f"FontHeight {config.font_height}",
                f"SpaceWidth {config.space_width}",
                "Kerning -4",
                "Scale 2",
                "",
            )
        ),
        encoding="utf-8",
    )


def parse_arguments() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--project-root",
        type=Path,
        default=Path(__file__).resolve().parents[1],
    )
    parser.add_argument(
        "--serif-font",
        type=Path,
        default=Path("/usr/share/fonts/truetype/dejavu/DejaVuSerif-Bold.ttf"),
    )
    parser.add_argument(
        "--mono-font",
        type=Path,
        default=Path("/usr/share/fonts/truetype/dejavu/DejaVuSansMono-Bold.ttf"),
    )
    return parser.parse_args()


def main() -> None:
    arguments = parse_arguments()
    source_paths = {
        "serif": arguments.serif_font.resolve(),
        "mono": arguments.mono_font.resolve(),
    }
    for source_path in source_paths.values():
        if not source_path.is_file():
            raise FileNotFoundError(f"No existe la fuente TTF: {source_path}")

    fonts_root = arguments.project_root.resolve() / "src" / "fonts"
    for directory_name, config in FONT_CONFIGS.items():
        rebuild_font(fonts_root, directory_name, config, source_paths)

    print(
        f"Fuentes 2x reconstruidas: {len(FONT_CONFIGS)} familias, "
        f"{len(CODEPOINTS)} glifos por familia."
    )


if __name__ == "__main__":
    main()
