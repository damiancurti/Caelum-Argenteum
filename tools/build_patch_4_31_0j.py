#!/usr/bin/env python3
"""Construye y audita el parche incremental 4.31.0j desde 4.31.0i."""

from __future__ import annotations

import argparse
import hashlib
import os
import shutil
import subprocess
import sys
import tempfile
import zipfile
from pathlib import Path


RUNTIME_CHANGE = "caelum/core/CaelumConstants.zs"
PROJECT_CHANGES = (
    "APLICAR_4_31_0j.txt",
    "PRUEBAS_4_31_0j.txt",
    "docs/IMPLEMENTATION_STATUS.md",
    "docs/ROADMAP.md",
    "tools/audit_4_31_0j.py",
    "tools/build_patch_4_31_0j.py",
)
EMBEDDED_PK3 = "build/caelum_argenteum_dev.pk3"
ARCHIVE_TIME = (2026, 9, 6, 1, 0, 0)


def require(condition: bool, message: str) -> None:
    if not condition:
        raise RuntimeError(message)


def copy_zip_info(info: zipfile.ZipInfo) -> zipfile.ZipInfo:
    copied = zipfile.ZipInfo(info.filename, info.date_time)
    copied.comment = info.comment
    copied.extra = info.extra
    copied.create_system = info.create_system
    copied.create_version = info.create_version
    copied.extract_version = info.extract_version
    copied.external_attr = info.external_attr
    copied.internal_attr = info.internal_attr
    copied.flag_bits = info.flag_bits & ~0x08
    copied.compress_type = info.compress_type
    return copied


def rebuild_pk3(base_pk3: Path, source: Path, output: Path) -> None:
    with zipfile.ZipFile(base_pk3, "r") as base, zipfile.ZipFile(
        output, "w", allowZip64=True
    ) as candidate:
        for info in base.infolist():
            data = source.read_bytes() if info.filename == RUNTIME_CHANGE else base.read(info.filename)
            candidate.writestr(copy_zip_info(info), data, compresslevel=9)


def add_file(
    archive: zipfile.ZipFile,
    source: Path,
    destination: str,
    stored: bool = False,
) -> None:
    info = zipfile.ZipInfo(destination, ARCHIVE_TIME)
    info.create_system = 3
    info.external_attr = (0o100644 & 0xFFFF) << 16
    info.compress_type = zipfile.ZIP_STORED if stored else zipfile.ZIP_DEFLATED
    archive.writestr(info, source.read_bytes(), compresslevel=None if stored else 9)


def build_outer_patch(
    project: Path, source: Path, candidate_pk3: Path, output: Path
) -> None:
    temporary = output.with_suffix(output.suffix + ".tmp")
    if temporary.exists():
        temporary.unlink()
    with zipfile.ZipFile(temporary, "w", allowZip64=True) as archive:
        add_file(archive, source, f"src/{RUNTIME_CHANGE}")
        for relative in PROJECT_CHANGES:
            add_file(archive, project / relative, relative)
        add_file(archive, candidate_pk3, EMBEDDED_PK3, stored=True)
    with zipfile.ZipFile(temporary) as archive:
        require(archive.testzip() is None, "El ZIP incremental está corrupto")
        require(
            len(archive.infolist()) == len(PROJECT_CHANGES) + 2,
            "Cantidad de archivos inesperada",
        )
    os.replace(temporary, output)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--project-root", type=Path, required=True)
    parser.add_argument("--base-patch", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    project = args.project_root.resolve()
    base_patch = args.base_patch.resolve()
    output = args.output.resolve()
    source = project / "src" / RUNTIME_CHANGE
    require(project.is_dir(), f"No existe el proyecto: {project}")
    require(base_patch.is_file(), f"No existe el parche base: {base_patch}")
    require(source.is_file(), f"Falta el archivo corregido: {source}")
    output.parent.mkdir(parents=True, exist_ok=True)

    with tempfile.TemporaryDirectory(prefix="ca_4310j_build_") as name:
        temporary = Path(name)
        base_pk3 = temporary / "base_4_31_0i.pk3"
        with zipfile.ZipFile(base_patch) as archive:
            require(EMBEDDED_PK3 in archive.namelist(), "La base no contiene el PK3")
            base_pk3.write_bytes(archive.read(EMBEDDED_PK3))

        base_root = temporary / "base_src"
        runtime = temporary / "candidate_src"
        base_root.mkdir()
        with zipfile.ZipFile(base_pk3) as archive:
            archive.extractall(base_root)
        shutil.copytree(base_root, runtime)
        shutil.copy2(source, runtime / RUNTIME_CHANGE)

        candidate_pk3 = temporary / "caelum_argenteum_dev.pk3"
        rebuild_pk3(base_pk3, source, candidate_pk3)
        subprocess.run(
            [
                sys.executable,
                str(project / "tools/audit_4_31_0j.py"),
                "--runtime-root",
                str(runtime),
                "--base-root",
                str(base_root),
                "--base-pk3",
                str(base_pk3),
                "--candidate-pk3",
                str(candidate_pk3),
            ],
            cwd=project,
            check=True,
        )
        build_outer_patch(project, source, candidate_pk3, output)

    print(f"patch: {output}")
    print(f"size: {output.stat().st_size}")
    print(f"sha256: {hashlib.sha256(output.read_bytes()).hexdigest()}")


if __name__ == "__main__":
    main()
