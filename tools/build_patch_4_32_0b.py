#!/usr/bin/env python3
"""Build and audit the distributable Caelum Argenteum 4.32.0b patch."""

from __future__ import annotations

import argparse
import copy
import hashlib
import subprocess
import sys
import tempfile
import zipfile
from pathlib import Path


CHANGED_EXISTING = {
    "LANGUAGE",
    "MAPINFO",
    "caelum/actors/CaelumFolkloreCharacters.zs",
    "caelum/core/CaelumConstants.zs",
    "caelum/debug/CaelumDebugOverlay.zs",
    "caelum/equipment/CaelumEconomy.zs",
    "caelum/equipment/CaelumPersistentCharacterState.zs",
    "caelum/hud/CaelumJournalOverlay.zs",
    "caelum/player/CaelumPlayer.zs",
    "maps/MAP01.wad",
}
NEW_FILES = {
    "graphics/caelum/ui/journal/icons/ca_ui_magic_box.png",
}
RUNTIME_DELTA = CHANGED_EXISTING | NEW_FILES
BASE_PK3_ENTRY = "build/caelum_argenteum_dev.pk3"
FIXED_ZIP_TIME = (2026, 9, 6, 0, 0, 0)
PROJECT_FILES = {
    "APLICAR_4_32_0b.txt",
    "PRUEBAS_4_32_0b.txt",
    "docs/ECONOMY.md",
    "docs/IMPLEMENTATION_STATUS.md",
    "docs/MAGIC_BOX.md",
    "docs/ROADMAP.md",
    "tools/audit_4_32_0b.py",
    "tools/build_patch_4_32_0b.py",
    "tools/place_palomo_4_32_0b.py",
}


def require(condition: bool, message: str) -> None:
    if not condition:
        raise RuntimeError(message)


def sha256(path: Path) -> str:
    result = hashlib.sha256()
    with path.open("rb") as source:
        for block in iter(lambda: source.read(1024 * 1024), b""):
            result.update(block)
    return result.hexdigest()


def zip_info(name: str, compression: int) -> zipfile.ZipInfo:
    info = zipfile.ZipInfo(name, FIXED_ZIP_TIME)
    info.compress_type = compression
    info.create_system = 3
    info.external_attr = 0o100644 << 16
    return info


def write_entry(
    archive: zipfile.ZipFile,
    name: str,
    data: bytes,
    compression: int = zipfile.ZIP_DEFLATED,
) -> None:
    archive.writestr(
        zip_info(name, compression), data,
        compress_type=compression,
        compresslevel=9 if compression == zipfile.ZIP_DEFLATED else None,
    )


def extract_base_pk3(base_patch: Path, destination: Path) -> None:
    with zipfile.ZipFile(base_patch) as archive:
        require(archive.testzip() is None, "base patch is corrupt")
        require(BASE_PK3_ENTRY in archive.namelist(), "base patch has no runtime PK3")
        destination.write_bytes(archive.read(BASE_PK3_ENTRY))


def build_candidate(base_pk3: Path, runtime: Path, output: Path) -> None:
    for relative in RUNTIME_DELTA:
        require((runtime / relative).is_file(), f"missing runtime file: {relative}")

    with zipfile.ZipFile(base_pk3) as source:
        require(source.testzip() is None, "base PK3 is corrupt")
        names = [entry.filename for entry in source.infolist()]
        require(len(names) == len(set(names)), "base PK3 has duplicate entries")
        require(not (CHANGED_EXISTING - set(names)), "base PK3 lacks replaceable files")
        require(not (NEW_FILES & set(names)), "new runtime file already exists in base")

        with zipfile.ZipFile(output, "w", allowZip64=True) as target:
            for original in source.infolist():
                data = ((runtime / original.filename).read_bytes()
                        if original.filename in CHANGED_EXISTING
                        else source.read(original.filename))
                target.writestr(copy.copy(original), data)
            for relative in sorted(NEW_FILES):
                write_entry(target, relative, (runtime / relative).read_bytes())

    with zipfile.ZipFile(output) as candidate:
        require(candidate.testzip() is None, "candidate PK3 is corrupt")


def run_audit(
    project: Path,
    runtime: Path,
    baseline_runtime: Path,
    base_pk3: Path,
    candidate_pk3: Path,
) -> None:
    subprocess.run(
        [
            sys.executable,
            str(project / "tools/audit_4_32_0b.py"),
            "--runtime-root", str(runtime),
            "--baseline-runtime", str(baseline_runtime),
            "--base-pk3", str(base_pk3),
            "--candidate-pk3", str(candidate_pk3),
        ],
        check=True,
    )


def build_outer(project: Path, runtime: Path, candidate: Path, output: Path) -> None:
    expected = {f"src/{relative}" for relative in RUNTIME_DELTA}
    expected |= PROJECT_FILES
    expected.add(BASE_PK3_ENTRY)
    output.parent.mkdir(parents=True, exist_ok=True)
    with zipfile.ZipFile(output, "w", allowZip64=True) as archive:
        for relative in sorted(RUNTIME_DELTA):
            write_entry(archive, f"src/{relative}", (runtime / relative).read_bytes())
        for relative in sorted(PROJECT_FILES):
            path = project / relative
            require(path.is_file(), f"missing project file: {relative}")
            write_entry(archive, relative, path.read_bytes())
        write_entry(archive, BASE_PK3_ENTRY, candidate.read_bytes(), zipfile.ZIP_STORED)

    with zipfile.ZipFile(output) as archive:
        require(archive.testzip() is None, "outer patch is corrupt")
        actual = {entry.filename for entry in archive.infolist() if not entry.is_dir()}
        require(actual == expected, "outer patch has unexpected entries")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--runtime-root", type=Path, required=True)
    parser.add_argument("--baseline-runtime", type=Path, required=True)
    parser.add_argument("--project-root", type=Path, required=True)
    parser.add_argument("--base-patch", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    with tempfile.TemporaryDirectory(prefix="caelum_4_32_0b_build_") as temp:
        temp_root = Path(temp)
        base_pk3 = temp_root / "base.pk3"
        candidate = temp_root / "caelum_argenteum_dev.pk3"
        extract_base_pk3(args.base_patch, base_pk3)
        build_candidate(base_pk3, args.runtime_root, candidate)
        run_audit(
            args.project_root, args.runtime_root, args.baseline_runtime,
            base_pk3, candidate,
        )
        build_outer(args.project_root, args.runtime_root, candidate, args.output)

    print(f"Built: {args.output}")
    print(f"SHA-256: {sha256(args.output)}")


if __name__ == "__main__":
    main()
