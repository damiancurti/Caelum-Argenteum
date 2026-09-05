#!/usr/bin/env python3
"""Audita el correctivo mínimo 4.31.0j contra 4.31.0i."""

from __future__ import annotations

import argparse
import hashlib
import re
import zipfile
from pathlib import Path


CONSTANTS_PATH = "caelum/core/CaelumConstants.zs"
RESTORED_MEMBER = "POTABLE_WATER_THIRST_RECOVERY_RATIO_PER_SECOND"


def require(condition: bool, message: str) -> None:
    if not condition:
        raise AssertionError(message)


def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def relative_files(root: Path) -> dict[str, Path]:
    return {
        path.relative_to(root).as_posix(): path
        for path in root.rglob("*")
        if path.is_file()
    }


def zip_digests(path: Path) -> dict[str, str]:
    with zipfile.ZipFile(path) as archive:
        return {
            info.filename: hashlib.sha256(archive.read(info.filename)).hexdigest()
            for info in archive.infolist()
            if not info.is_dir()
        }


def declared_constants(text: str) -> set[str]:
    return set(re.findall(r"(?m)^\s*const\s+([A-Za-z_][A-Za-z0-9_]*)\b", text))


def referenced_constants(runtime: Path) -> set[str]:
    references: set[str] = set()
    for source in runtime.rglob("*.zs"):
        references.update(
            re.findall(
                r"\bCaelumConstants\.([A-Za-z_][A-Za-z0-9_]*)\b",
                source.read_text(encoding="utf-8"),
            )
        )
    return references


def check_delimiters(source: Path) -> None:
    text = source.read_text(encoding="utf-8")
    text = re.sub(r"/\*.*?\*/", "", text, flags=re.DOTALL)
    text = re.sub(r"//[^\n]*", "", text)
    text = re.sub(r'"(?:\\.|[^"\\])*"', '""', text)
    pairs = {"{": "}", "(": ")", "[": "]"}
    stack: list[tuple[str, int]] = []
    for index, character in enumerate(text):
        if character in pairs:
            stack.append((character, index))
        elif character in pairs.values():
            require(
                bool(stack) and pairs[stack[-1][0]] == character,
                f"Delimitador inesperado en {source}:{index}",
            )
            stack.pop()
    if stack:
        raise AssertionError(
            f"Delimitador sin cerrar en {source}:{stack[-1][1]}"
        )


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--runtime-root", type=Path, required=True)
    parser.add_argument("--base-root", type=Path, required=True)
    parser.add_argument("--base-pk3", type=Path, required=True)
    parser.add_argument("--candidate-pk3", type=Path, required=True)
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    runtime = args.runtime_root.resolve()
    base_root = args.base_root.resolve()
    base_pk3 = args.base_pk3.resolve()
    candidate_pk3 = args.candidate_pk3.resolve()
    for directory in (runtime, base_root):
        require(directory.is_dir(), f"No existe el directorio: {directory}")
    for package in (base_pk3, candidate_pk3):
        require(package.is_file(), f"No existe el paquete: {package}")

    base_constants_text = (base_root / CONSTANTS_PATH).read_text(encoding="utf-8")
    constants_path = runtime / CONSTANTS_PATH
    constants_text = constants_path.read_text(encoding="utf-8")
    base_members = declared_constants(base_constants_text)
    candidate_members = declared_constants(constants_text)
    require(
        candidate_members - base_members == {RESTORED_MEMBER},
        "4.31.0j debe añadir únicamente la constante de agua potable",
    )
    require(
        not base_members - candidate_members,
        f"Constantes previas eliminadas: {sorted(base_members - candidate_members)}",
    )
    require(
        re.search(
            rf"(?m)^\s*const\s+{RESTORED_MEMBER}\s*=\s*0\.01\s*;",
            constants_text,
        )
        is not None,
        "La recuperación potable debe conservar el valor exacto 0.01",
    )

    references = referenced_constants(runtime)
    unresolved = references - candidate_members
    require(
        not unresolved,
        f"Referencias CaelumConstants sin declarar: {sorted(unresolved)}",
    )
    require(RESTORED_MEMBER in references, "El jugador ya no usa la constante restaurada")
    check_delimiters(constants_path)

    base_files = relative_files(base_root)
    runtime_files = relative_files(runtime)
    require(base_files.keys() == runtime_files.keys(), "Cambió el catálogo runtime")
    changed_runtime = {
        name
        for name in base_files
        if digest(base_files[name]) != digest(runtime_files[name])
    }
    require(
        changed_runtime == {CONSTANTS_PATH},
        f"Cambios runtime inesperados: {sorted(changed_runtime)}",
    )

    base_zip = zip_digests(base_pk3)
    candidate_zip = zip_digests(candidate_pk3)
    require(base_zip.keys() == candidate_zip.keys(), "Cambió el catálogo del PK3")
    changed_zip = {
        name for name in base_zip if base_zip[name] != candidate_zip[name]
    }
    require(changed_zip == {CONSTANTS_PATH}, "El PK3 cambia archivos inesperados")
    with zipfile.ZipFile(base_pk3) as base_archive, zipfile.ZipFile(
        candidate_pk3
    ) as candidate_archive:
        require(
            len(base_archive.infolist()) == len(candidate_archive.infolist()),
            "Cambió la cantidad de entradas del PK3",
        )
        require(candidate_archive.testzip() is None, "El PK3 está corrupto")

    print("4.31.0j audit passed")
    print(f"restored constant: {RESTORED_MEMBER}=0.01")
    print(f"CaelumConstants references checked: {len(references)}")
    print(f"CaelumConstants members declared: {len(candidate_members)}")
    print("runtime changes: 1 (CaelumConstants.zs)")
    print(f"PK3 entries preserved: {len(zipfile.ZipFile(candidate_pk3).infolist())}")


if __name__ == "__main__":
    main()
