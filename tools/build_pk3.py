"""Construye el PK3 sin entradas de directorio interpretables como texturas."""

import argparse
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


def build(source, destination):
    files = sorted(path for path in source.rglob("*") if path.is_file())
    if not files:
        raise ValueError(f"No hay archivos para empaquetar en {source}")

    for path in files:
        if path.stat().st_size == 0:
            raise ValueError(f"Archivo vacío no permitido en PK3: {path}")
        if path.suffix.lower() == ".png":
            validate_png(path)

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
