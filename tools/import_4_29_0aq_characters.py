"""Importa los tres personajes originales suministrados para V4.29.0aq.

El paquete fuente conserva nombres descriptivos largos. GZDoom resuelve las
rotaciones mundiales mediante nombres de sprite de cuatro caracteres, una letra
de cuadro y un número de rotación. Este importador valida el manifiesto, las
dimensiones RGBA y la cantidad exacta de cuadros antes de crear esos alias.

Los atlas permanecen en el paquete fuente: el PK3 sólo necesita los 380 cuadros
individuales. Los README y manifiestos sí se conservan bajo docs/assets para
que las instrucciones visuales sigan auditables en el repositorio público.
"""

from __future__ import annotations

import argparse
import json
import re
import struct
from pathlib import Path
from zipfile import ZipFile


PACKAGE_ROOT = "Caelum_Argenteum_Ultimos_3_Personajes_v1"
DIRECTIONS = (
    "front",
    "front_left",
    "left",
    "back_left",
    "back",
    "back_right",
    "right",
    "front_right",
)
SPRITE_NAME = re.compile(r"^[A-Z0-9]{4}[A-Z][0-8]\.png$")

PALOMO_BASE_STATES = {
    "idle": "A",
    "walk_a": "B",
    "walk_b": "C",
    "talk": "D",
}
PALOMO_EMOTIONS = {
    "laugh": "PLLF",
    "anger": "PLAG",
    "joy": "PLJY",
    "surprise": "PLSP",
    "sadness": "PLSD",
    "thought": "PLTH",
}
MANDINGA_STATES = {
    "idle": "A",
    "walk_a": "B",
    "walk_b": "C",
    "attack_windup": "D",
    "attack_strike": "E",
    "pain": "F",
}
ZUPAY_CORE_STATES = MANDINGA_STATES
ZUPAY_OBJECT_STATES = {
    "lift_reach": "M",
    "lift_raise": "N",
    "lift_hold": "O",
    "throw_windup": "P",
    "throw_release": "Q",
    "throw_recover": "R",
}

DOCUMENT_FILES = (
    "README_ULTIMOS_3_PERSONAJES.md",
    "character_pack_manifest.json",
    "Palomo/README_PALOMO.md",
    "Palomo/palomo_manifest.json",
    "Mandinga/README_MANDINGA.md",
    "Mandinga/mandinga_manifest.json",
    "Zupay_Colosal/README_ZUPAY_COLOSSUS.md",
    "Zupay_Colosal/zupay_colossus_manifest.json",
)

TEXTURES_BEGIN = "// BEGIN GENERATED 4.29.0aq CHARACTER SPRITES"
TEXTURES_END = "// END GENERATED 4.29.0aq CHARACTER SPRITES"


def member_name(relative: str) -> str:
    return f"{PACKAGE_ROOT}/{relative}"


def read_member(archive: ZipFile, relative: str) -> bytes:
    name = member_name(relative)
    try:
        return archive.read(name)
    except KeyError as error:
        raise ValueError(f"Falta el archivo obligatorio del paquete: {name}") from error


def png_info(data: bytes, relative: str) -> tuple[int, int]:
    if len(data) < 33 or data[:8] != b"\x89PNG\r\n\x1a\n":
        raise ValueError(f"PNG inválido: {relative}")
    if data[12:16] != b"IHDR":
        raise ValueError(f"PNG sin IHDR inicial: {relative}")
    width, height, depth, color_type = struct.unpack(">IIBB", data[16:26])
    if depth != 8 or color_type != 6:
        raise ValueError(
            f"{relative} debe ser PNG RGBA de 8 bits; recibió "
            f"profundidad {depth}, tipo {color_type}"
        )
    return width, height


def write_if_changed(destination: Path, data: bytes) -> bool:
    if destination.exists() and destination.read_bytes() == data:
        return False
    destination.parent.mkdir(parents=True, exist_ok=True)
    destination.write_bytes(data)
    return True


def import_png(
    archive: ZipFile,
    source_relative: str,
    destination: Path,
    expected_size: tuple[int, int],
) -> bool:
    if not SPRITE_NAME.fullmatch(destination.name):
        raise ValueError(f"Nombre de sprite GZDoom inválido: {destination.name}")
    data = read_member(archive, source_relative)
    actual_size = png_info(data, source_relative)
    if actual_size != expected_size:
        raise ValueError(
            f"{source_relative} mide {actual_size}; se esperaba {expected_size}"
        )
    return write_if_changed(destination, data)


def validate_package(archive: ZipFile) -> None:
    files = [entry for entry in archive.infolist() if not entry.is_dir()]
    if len(files) != 398:
        raise ValueError(f"El paquete debe contener 398 archivos; contiene {len(files)}")
    png_files = [entry for entry in files if entry.filename.lower().endswith(".png")]
    if len(png_files) != 390:
        raise ValueError(f"El paquete debe contener 390 PNG; contiene {len(png_files)}")

    manifest = json.loads(read_member(archive, "character_pack_manifest.json"))
    if manifest.get("total_individual_frames") != 380:
        raise ValueError("El manifiesto no declara los 380 cuadros esperados")
    if manifest.get("total_sprite_sheets") != 10:
        raise ValueError("El manifiesto no declara los 10 atlas esperados")
    if tuple(manifest.get("direction_order", ())) != DIRECTIONS:
        raise ValueError("El orden direccional del manifiesto no es el aprobado")

    bad = archive.testzip()
    if bad is not None:
        raise ValueError(f"El ZIP falla su comprobación CRC en {bad}")


def import_palomo(archive: ZipFile, sprites_root: Path) -> tuple[int, int]:
    directory = sprites_root / "palomo"
    written = 0
    total = 0
    for rotation, direction in enumerate(DIRECTIONS, start=1):
        for state, frame in PALOMO_BASE_STATES.items():
            source = f"Palomo/frames/base/ca_palomo_{direction}_{state}.png"
            destination = directory / f"PALM{frame}{rotation}.png"
            written += import_png(archive, source, destination, (256, 256))
            total += 1

        for emotion, prefix in PALOMO_EMOTIONS.items():
            for index, frame in enumerate("ABCD", start=1):
                source = (
                    f"Palomo/frames/emotions/{emotion}/"
                    f"ca_palomo_{emotion}_{direction}_{index}.png"
                )
                destination = directory / f"{prefix}{frame}{rotation}.png"
                written += import_png(archive, source, destination, (256, 256))
                total += 1
    return written, total


def import_mandinga(archive: ZipFile, sprites_root: Path) -> tuple[int, int]:
    directory = sprites_root / "mandinga"
    written = 0
    total = 0
    for rotation, direction in enumerate(DIRECTIONS, start=1):
        for state, frame in MANDINGA_STATES.items():
            source = f"Mandinga/frames/ca_enemy_mandinga_{direction}_{state}.png"
            destination = directory / f"MNDG{frame}{rotation}.png"
            written += import_png(archive, source, destination, (256, 256))
            total += 1
    for index, frame in enumerate("GHIJKL", start=1):
        source = f"Mandinga/frames/ca_enemy_mandinga_death_{index}.png"
        destination = directory / f"MNDG{frame}0.png"
        written += import_png(archive, source, destination, (256, 256))
        total += 1
    return written, total


def import_zupay(archive: ZipFile, sprites_root: Path) -> tuple[int, int]:
    directory = sprites_root / "zupay_colossus"
    written = 0
    total = 0
    for rotation, direction in enumerate(DIRECTIONS, start=1):
        for state, frame in ZUPAY_CORE_STATES.items():
            source = (
                "Zupay_Colosal/frames/"
                f"ca_enemy_zupay_colossus_{direction}_{state}.png"
            )
            destination = directory / f"ZUPY{frame}{rotation}.png"
            written += import_png(archive, source, destination, (416, 416))
            total += 1
        for state, frame in ZUPAY_OBJECT_STATES.items():
            source = (
                "Zupay_Colosal/frames/"
                f"ca_enemy_zupay_colossus_{direction}_{state}.png"
            )
            destination = directory / f"ZUPY{frame}{rotation}.png"
            written += import_png(archive, source, destination, (416, 416))
            total += 1
    for index, frame in enumerate("GHIJKL", start=1):
        source = f"Zupay_Colosal/frames/ca_enemy_zupay_colossus_death_{index}.png"
        destination = directory / f"ZUPY{frame}0.png"
        written += import_png(archive, source, destination, (416, 416))
        total += 1
    return written, total


def import_documents(archive: ZipFile, documentation_root: Path) -> int:
    written = 0
    for relative in DOCUMENT_FILES:
        data = read_member(archive, relative)
        written += write_if_changed(documentation_root / relative, data)
    return written


def make_sprite_alias(
    name: str,
    path: str,
    width: int,
    height: int,
    offset_x: int,
    offset_y: int,
) -> str:
    return (
        f'Sprite "{name}", {width}, {height} '
        f'{{ Offset {offset_x}, {offset_y} Patch "{path}", 0, 0 }}'
    )


def generated_texture_block() -> str:
    """Genera los 380 alias con pivotes de suelo verificables.

    Mandinga y Zupay traen sus pivotes en el paquete. Palomo usa la línea de
    suelo común Y=246 inferida del conjunto. Los pivotes permanecen fijos para
    que las poses que levantan un pie no produzcan vibración vertical.
    """

    aliases: list[str] = []
    palomo_names: list[str] = []
    for rotation in range(1, 9):
        for frame in PALOMO_BASE_STATES.values():
            palomo_names.append(f"PALM{frame}{rotation}.png")
        for prefix in PALOMO_EMOTIONS.values():
            for frame in "ABCD":
                palomo_names.append(f"{prefix}{frame}{rotation}.png")
    for filename in palomo_names:
        aliases.append(
            make_sprite_alias(
                filename[:-4],
                f"sprites/caelum/actors/palomo/{filename}",
                256,
                256,
                128,
                246,
            )
        )

    mandinga_names = [
        f"MNDG{frame}{rotation}.png"
        for rotation in range(1, 9)
        for frame in MANDINGA_STATES.values()
    ]
    mandinga_names.extend(f"MNDG{frame}0.png" for frame in "GHIJKL")
    for filename in mandinga_names:
        aliases.append(
            make_sprite_alias(
                filename[:-4],
                f"sprites/caelum/actors/mandinga/{filename}",
                256,
                256,
                128,
                248,
            )
        )

    zupay_frames = tuple(ZUPAY_CORE_STATES.values()) + tuple(
        ZUPAY_OBJECT_STATES.values()
    )
    zupay_names = [
        f"ZUPY{frame}{rotation}.png"
        for rotation in range(1, 9)
        for frame in zupay_frames
    ]
    zupay_names.extend(f"ZUPY{frame}0.png" for frame in "GHIJKL")
    for filename in zupay_names:
        aliases.append(
            make_sprite_alias(
                filename[:-4],
                f"sprites/caelum/actors/zupay_colossus/{filename}",
                416,
                416,
                208,
                400,
            )
        )

    if len(aliases) != 380 or len(set(aliases)) != 380:
        raise ValueError("La tabla TEXTURES no produjo 380 alias únicos")
    return "\n".join((TEXTURES_BEGIN, *aliases, TEXTURES_END))


def update_textures(repository: Path) -> bool:
    destination = repository / "src/TEXTURES"
    original = destination.read_text(encoding="utf-8")
    block = generated_texture_block()
    begin_count = original.count(TEXTURES_BEGIN)
    end_count = original.count(TEXTURES_END)
    if (begin_count, end_count) == (0, 0):
        updated = original.rstrip() + "\n\n" + block + "\n"
    elif (begin_count, end_count) == (1, 1):
        prefix, remainder = original.split(TEXTURES_BEGIN, 1)
        _, suffix = remainder.split(TEXTURES_END, 1)
        updated = prefix.rstrip() + "\n\n" + block + suffix
    else:
        raise ValueError("Marcadores 4.29.0aq inconsistentes en src/TEXTURES")
    if updated == original:
        return False
    destination.write_text(updated, encoding="utf-8")
    return True


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("package", type=Path, help="ZIP original suministrado por el autor")
    parser.add_argument(
        "--repository",
        type=Path,
        default=Path(__file__).resolve().parents[1],
        help="Raíz del repositorio de Caelum Argenteum",
    )
    args = parser.parse_args()

    repository = args.repository.resolve()
    sprites_root = repository / "src/sprites/caelum/actors"
    documentation_root = repository / "docs/assets/characters"

    with ZipFile(args.package.resolve()) as archive:
        validate_package(archive)
        palomo_written, palomo_total = import_palomo(archive, sprites_root)
        mandinga_written, mandinga_total = import_mandinga(archive, sprites_root)
        zupay_written, zupay_total = import_zupay(archive, sprites_root)
        document_written = import_documents(archive, documentation_root)

    textures_updated = update_textures(repository)

    total = palomo_total + mandinga_total + zupay_total
    if (palomo_total, mandinga_total, zupay_total, total) != (224, 54, 102, 380):
        raise ValueError("La importación no produjo la distribución 224/54/102/380")

    print(
        "Cuadros validados: "
        f"Palomo={palomo_total}, Mandinga={mandinga_total}, "
        f"Zupay={zupay_total}, total={total}"
    )
    print(
        "Archivos actualizados: "
        f"sprites={palomo_written + mandinga_written + zupay_written}, "
        f"documentos={document_written}, TEXTURES={int(textures_updated)}"
    )


if __name__ == "__main__":
    main()
