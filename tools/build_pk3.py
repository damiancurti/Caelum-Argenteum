"""Construye el PK3 sin entradas de directorio interpretables como texturas."""

import argparse
import re
import struct
import tempfile
from pathlib import Path
from zipfile import ZIP_DEFLATED, ZipFile


def validate_png(path):
    with path.open("rb") as stream:
        header = stream.read(24)
    if len(header) < 24 or header[:8] != b"\x89PNG\r\n\x1a\n":
        raise ValueError(f"PNG inválido: {path}")
    width, height = struct.unpack(">II", header[16:24])
    if width == 0 or height == 0:
        raise ValueError(f"PNG de tamaño cero: {path}")


def udmf_blocks(text, kind):
    pattern = re.compile(
        rf"(?m)^{re.escape(kind)}\s*\n\{{.*?^\}}", re.DOTALL
    )
    return pattern.findall(text)


def integer_property(block, name, required=True):
    match = re.search(
        rf"(?m)^\s*{re.escape(name)}\s*=\s*(-?\d+)\s*;", block
    )
    if match is None:
        if required:
            raise ValueError(f"Propiedad UDMF ausente: {name}")
        return None
    return int(match.group(1))


def number_property(block, name):
    match = re.search(
        rf"(?m)^\s*{re.escape(name)}\s*=\s*"
        r"([-+]?(?:\d+(?:\.\d*)?|\.\d+)(?:[eE][-+]?\d+)?)\s*;",
        block,
    )
    if match is None:
        raise ValueError(f"Propiedad UDMF ausente: {name}")
    return float(match.group(1))


def validate_udmf_textmap(path, text):
    vertices = udmf_blocks(text, "vertex")
    linedefs = udmf_blocks(text, "linedef")
    sidedefs = udmf_blocks(text, "sidedef")
    sectors = udmf_blocks(text, "sector")
    things = udmf_blocks(text, "thing")
    referenced_sides = []
    vertex_positions = [
        (number_property(vertex, "x"), number_property(vertex, "y"))
        for vertex in vertices
    ]

    for index, (x, y) in enumerate(vertex_positions):
        if not (-32768 <= x <= 32768 and -32768 <= y <= 32768):
            raise ValueError(
                f"{path}: vertex {index} excede el rango de coordenadas UDMF"
            )

    for index, thing in enumerate(things):
        x = number_property(thing, "x")
        y = number_property(thing, "y")
        if not (-32768 <= x <= 32768 and -32768 <= y <= 32768):
            raise ValueError(
                f"{path}: thing {index} excede el rango de coordenadas UDMF"
            )

    for index, linedef in enumerate(linedefs):
        v1 = integer_property(linedef, "v1")
        v2 = integer_property(linedef, "v2")
        front = integer_property(linedef, "sidefront")
        back = integer_property(linedef, "sideback", required=False)
        two_sided = re.search(
            r"(?m)^\s*twosided\s*=\s*true\s*;", linedef
        ) is not None

        if not (0 <= v1 < len(vertices)) or not (0 <= v2 < len(vertices)):
            raise ValueError(f"{path}: linedef {index} referencia un vertex inválido")
        if vertex_positions[v1] == vertex_positions[v2]:
            raise ValueError(f"{path}: linedef {index} tiene longitud nula")
        if not 0 <= front < len(sidedefs):
            raise ValueError(f"{path}: linedef {index} no tiene front sidedef válido")
        referenced_sides.append(front)

        if back is not None:
            if not 0 <= back < len(sidedefs):
                raise ValueError(f"{path}: linedef {index} tiene sideback inválido")
            referenced_sides.append(back)

        if (back is not None) != two_sided:
            raise ValueError(
                f"{path}: linedef {index} no concuerda entre sideback y twosided"
            )

    for index, sidedef in enumerate(sidedefs):
        sector = integer_property(sidedef, "sector")
        if not 0 <= sector < len(sectors):
            raise ValueError(f"{path}: sidedef {index} referencia un sector inválido")

    used = set(referenced_sides)
    if len(used) != len(referenced_sides):
        raise ValueError(f"{path}: uno o más sidedefs están compartidos por linedefs")
    if used != set(range(len(sidedefs))):
        missing = sorted(set(range(len(sidedefs))) - used)
        raise ValueError(
            f"{path}: sidedefs huérfanos o tabla discontinua: {missing[:12]}"
        )


def validate_wad(path):
    data = path.read_bytes()
    if len(data) < 12:
        raise ValueError(f"WAD truncado: {path}")

    signature, lump_count, directory_offset = struct.unpack_from("<4sII", data, 0)
    if signature not in (b"PWAD", b"IWAD"):
        raise ValueError(f"Firma WAD inválida: {path}")
    if directory_offset + lump_count * 16 > len(data):
        raise ValueError(f"Directorio WAD fuera de rango: {path}")

    for index in range(lump_count):
        offset, size, raw_name = struct.unpack_from(
            "<II8s", data, directory_offset + index * 16
        )
        if offset + size > len(data):
            raise ValueError(f"Lump WAD fuera de rango: {path}")
        name = raw_name.rstrip(b"\0")
        if name == b"TEXTMAP":
            try:
                text = data[offset : offset + size].decode("utf-8")
            except UnicodeDecodeError as error:
                raise ValueError(f"TEXTMAP no es UTF-8 válido: {path}") from error
            validate_udmf_textmap(path, text)


def build(source, destination):
    files = sorted(path for path in source.rglob("*") if path.is_file())
    if not files:
        raise ValueError(f"No hay archivos para empaquetar en {source}")

    for path in files:
        if path.stat().st_size == 0:
            raise ValueError(f"Archivo vacío no permitido en PK3: {path}")
        if path.suffix.lower() == ".png":
            validate_png(path)
        if path.suffix.lower() == ".wad":
            validate_wad(path)

    destination.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.NamedTemporaryFile(
        prefix=destination.stem + "_", suffix=".tmp", dir=destination.parent,
        delete=False
    ) as temporary:
        temporary_path = Path(temporary.name)

    try:
        with ZipFile(temporary_path, "w", ZIP_DEFLATED, compresslevel=9) as archive:
            for path in files:
                # ZipFile.write sobre archivos solamente no crea directorios.
                archive.write(path, path.relative_to(source).as_posix())

        with ZipFile(temporary_path) as archive:
            entries = archive.infolist()
            if any(entry.is_dir() for entry in entries):
                raise ValueError("El PK3 contiene entradas de directorio")
            if any(entry.file_size == 0 for entry in entries):
                raise ValueError("El PK3 contiene archivos vacíos")
            bad = archive.testzip()
            if bad is not None:
                raise ValueError(f"Entrada ZIP corrupta: {bad}")

        temporary_path.replace(destination)
    finally:
        if temporary_path.exists():
            temporary_path.unlink()


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("source", nargs="?", type=Path, default=Path("src"))
    parser.add_argument(
        "destination", nargs="?", type=Path,
        default=Path("build/caelum_argenteum_dev.pk3")
    )
    args = parser.parse_args()
    build(args.source.resolve(), args.destination.resolve())
    print(args.destination)


if __name__ == "__main__":
    main()
