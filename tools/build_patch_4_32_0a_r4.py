#!/usr/bin/env python3
"""Construye y audita la revisión Caelum Argenteum 4.32.0a-r4."""

from __future__ import annotations

import argparse
import copy
import hashlib
import subprocess
import sys
import tempfile
import zipfile
from pathlib import Path


EXISTING_RUNTIME_CHANGES = {
    "ZSCRIPT",
    "LANGUAGE",
    "caelum/core/CaelumConstants.zs",
    "caelum/ui/CaelumDisplayNames.zs",
    "caelum/player/CaelumPlayer.zs",
    "caelum/hud/CaelumJournalOverlay.zs",
    "caelum/debug/CaelumDebugOverlay.zs",
    "caelum/equipment/CaelumConsumables.zs",
    "caelum/equipment/CaelumEquipmentPickups.zs",
    "caelum/equipment/CaelumPersistentCharacterState.zs",
    "caelum/equipment/CaelumSpecialItems.zs",
    "caelum/statistics/CaelumDerivedStats.zs",
}

NEW_RUNTIME_FILES = {
    "caelum/equipment/CaelumEconomy.zs",
    "graphics/caelum/icons/currency/ca_coin_copper.png",
    "graphics/caelum/icons/currency/ca_coin_silver.png",
    "graphics/caelum/icons/currency/ca_coin_gold.png",
    "sprites/caelum/currency/CCOPA0.png",
    "sprites/caelum/currency/CSILA0.png",
    "sprites/caelum/currency/CGOLA0.png",
}

RUNTIME_CHANGES = EXISTING_RUNTIME_CHANGES | NEW_RUNTIME_FILES
BASE_PK3_ENTRY = "build/caelum_argenteum_dev.pk3"
FIXED_ZIP_TIME = (2026, 9, 5, 0, 0, 0)

PROJECT_FILES = {
    "APLICAR_4_32_0a_r4.txt",
    "PRUEBAS_4_32_0a_r4.txt",
    "docs/ECONOMY.md",
    "docs/MAGIC_BOX.md",
    "docs/IMPLEMENTATION_STATUS.md",
    "docs/ROADMAP.md",
    "tools/audit_4_32_0a_r4.py",
    "tools/build_patch_4_32_0a_r4.py",
}


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--runtime-root", type=Path, required=True)
    parser.add_argument("--project-root", type=Path, required=True)
    parser.add_argument("--base-patch", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    return parser.parse_args()


def require(condition: bool, message: str) -> None:
    if not condition:
        raise RuntimeError(message)


def sha256(path: Path) -> str:
    result = hashlib.sha256()
    with path.open("rb") as source:
        for block in iter(lambda: source.read(1024 * 1024), b""):
            result.update(block)
    return result.hexdigest()


def new_zip_info(name: str, compression: int) -> zipfile.ZipInfo:
    info = zipfile.ZipInfo(name, FIXED_ZIP_TIME)
    info.compress_type = compression
    info.create_system = 3
    info.external_attr = 0o100644 << 16
    return info


def write_new_entry(
    archive: zipfile.ZipFile,
    name: str,
    data: bytes,
    compression: int = zipfile.ZIP_DEFLATED,
) -> None:
    archive.writestr(
        new_zip_info(name, compression),
        data,
        compress_type=compression,
        compresslevel=9 if compression == zipfile.ZIP_DEFLATED else None,
    )


def extract_base_pk3(base_patch: Path, destination: Path) -> None:
    with zipfile.ZipFile(base_patch) as archive:
        require(archive.testzip() is None, "El parche base está corrupto")
        require(
            BASE_PK3_ENTRY in archive.namelist(),
            f"El parche base no contiene {BASE_PK3_ENTRY}",
        )
        destination.write_bytes(archive.read(BASE_PK3_ENTRY))


def build_candidate_pk3(
    base_pk3: Path,
    runtime: Path,
    candidate_pk3: Path,
) -> None:
    for relative in RUNTIME_CHANGES:
        require(
            (runtime / relative).is_file(),
            f"Falta fuente runtime: {relative}",
        )

    with zipfile.ZipFile(base_pk3) as source:
        require(source.testzip() is None, "El PK3 base está corrupto")
        names = [info.filename for info in source.infolist()]
        require(len(names) == len(set(names)), "El PK3 base tiene entradas duplicadas")
        require(
            not (EXISTING_RUNTIME_CHANGES - set(names)),
            "El PK3 base no contiene todos los archivos que deben reemplazarse",
        )
        require(
            not (NEW_RUNTIME_FILES & set(names)),
            "Un archivo marcado como nuevo ya existe en el PK3 base",
        )

        with zipfile.ZipFile(
            candidate_pk3, "w", allowZip64=True
        ) as target:
            for original_info in source.infolist():
                data = (
                    (runtime / original_info.filename).read_bytes()
                    if original_info.filename in EXISTING_RUNTIME_CHANGES
                    else source.read(original_info.filename)
                )
                info = copy.copy(original_info)
                target.writestr(info, data)

            for relative in sorted(NEW_RUNTIME_FILES):
                write_new_entry(
                    target,
                    relative,
                    (runtime / relative).read_bytes(),
                )

    with zipfile.ZipFile(candidate_pk3) as archive:
        require(archive.testzip() is None, "El PK3 construido está corrupto")


def run_audit(
    project: Path,
    runtime: Path,
    base_pk3: Path,
    candidate_pk3: Path,
) -> None:
    audit = project / "tools/audit_4_32_0a_r4.py"
    require(audit.is_file(), "Falta tools/audit_4_32_0a_r4.py")
    subprocess.run(
        [
            sys.executable,
            str(audit),
            "--runtime-root",
            str(runtime),
            "--project-root",
            str(project),
            "--base-pk3",
            str(base_pk3),
            "--candidate-pk3",
            str(candidate_pk3),
        ],
        check=True,
    )


def build_outer_patch(
    project: Path,
    runtime: Path,
    candidate_pk3: Path,
    output: Path,
) -> None:
    expected_entries = {f"src/{name}" for name in RUNTIME_CHANGES}
    expected_entries |= PROJECT_FILES
    expected_entries.add(BASE_PK3_ENTRY)

    output.parent.mkdir(parents=True, exist_ok=True)
    with zipfile.ZipFile(output, "w", allowZip64=True) as archive:
        for relative in sorted(RUNTIME_CHANGES):
            write_new_entry(
                archive,
                f"src/{relative}",
                (runtime / relative).read_bytes(),
            )
        for relative in sorted(PROJECT_FILES):
            path = project / relative
            require(path.is_file(), f"Falta archivo del parche: {relative}")
            write_new_entry(archive, relative, path.read_bytes())
        write_new_entry(
            archive,
            BASE_PK3_ENTRY,
            candidate_pk3.read_bytes(),
            zipfile.ZIP_STORED,
        )

    with zipfile.ZipFile(output) as archive:
        require(archive.testzip() is None, "El parche final está corrupto")
        actual_entries = {
            info.filename for info in archive.infolist() if not info.is_dir()
        }
        require(
            actual_entries == expected_entries,
            "El parche final contiene entradas faltantes o inesperadas",
        )


def main() -> None:
    args = parse_args()
    runtime = args.runtime_root.resolve()
    project = args.project_root.resolve()
    base_patch = args.base_patch.resolve()
    output = args.output.resolve()
    require(runtime.is_dir(), f"No existe runtime-root: {runtime}")
    require(project.is_dir(), f"No existe project-root: {project}")
    require(base_patch.is_file(), f"No existe base-patch: {base_patch}")

    with tempfile.TemporaryDirectory(prefix="caelum_4_32_0a_r4_") as temp_name:
        temp = Path(temp_name)
        base_pk3 = temp / "base.pk3"
        candidate_pk3 = temp / "caelum_argenteum_dev.pk3"
        extract_base_pk3(base_patch, base_pk3)
        build_candidate_pk3(base_pk3, runtime, candidate_pk3)
        run_audit(project, runtime, base_pk3, candidate_pk3)
        build_outer_patch(project, runtime, candidate_pk3, output)

    print(f"Patch: {output}")
    print(f"Size: {output.stat().st_size} bytes")
    print(f"SHA-256: {sha256(output)}")


if __name__ == "__main__":
    main()
