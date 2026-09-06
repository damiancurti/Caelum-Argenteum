#!/usr/bin/env python3
"""Focused deterministic audit for Caelum Argenteum 4.32.0e."""

from __future__ import annotations

import argparse
import hashlib
import re
import struct
import zipfile
import zlib
from pathlib import Path, PurePosixPath


CHANGED_EXISTING = {
    "LANGUAGE",
    "ZSCRIPT",
    "caelum/dialogue/CaelumPalomoDialogue.zs",
    "caelum/equipment/CaelumPersistentCharacterState.zs",
    "caelum/hud/CaelumHUDOverlay.zs",
    "caelum/player/CaelumPlayer.zs",
}
PROTOTYPE_SOURCE = "caelum/prototypes/CaelumDomingoFirstPersonPrototype.zs"
MODULE_PREFIXES = ("LHND", "DSHD", "DSWD", "RHND")
MODULE_SPRITES = {
    f"sprites/{prefix}{frame}0.png"
    for prefix in MODULE_PREFIXES
    for frame in "ABCDEFGHI"
}
COMPOSITE_SPRITES = {
    "sprites/DFPAA0.png", "sprites/DFPAB0.png", "sprites/DFPAC0.png",
    "sprites/DFPBA0.png", "sprites/DFPBB0.png",
    "sprites/DFPRA0.png", "sprites/DFPRB0.png",
    "sprites/DFPSA0.png", "sprites/DFPSB0.png",
}
SPRITES = MODULE_SPRITES | COMPOSITE_SPRITES
NEW_RUNTIME = {PROTOTYPE_SOURCE} | SPRITES
PROJECT_FILES = {
    "APLICAR_4_32_0e.txt",
    "PRUEBAS_4_32_0e.txt",
    "docs/DIALOGUE.md",
    "docs/DOMINGO_FP_4_32_0e_SHA256.txt",
    "docs/FIRST_PERSON.md",
    "docs/IMPLEMENTATION_STATUS.md",
    "docs/MAGIC_BOX.md",
    "docs/ROADMAP.md",
    "tools/audit_4_32_0e.py",
    "tools/build_source_patch_4_32_0e.py",
}
FIXED_ZIP_TIME = (2026, 9, 6, 12, 0, 0)


def require(condition: bool, message: str) -> None:
    if not condition:
        raise AssertionError(message)


def sha256_bytes(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def sha256(path: Path) -> str:
    result = hashlib.sha256()
    with path.open("rb") as source:
        for block in iter(lambda: source.read(1024 * 1024), b""):
            result.update(block)
    return result.hexdigest()


def file_set(root: Path) -> set[str]:
    return {
        path.relative_to(root).as_posix()
        for path in root.rglob("*")
        if path.is_file()
    }


def expected_runtime_delta() -> set[str]:
    return CHANGED_EXISTING | NEW_RUNTIME


def strip_comments_and_strings(text: str) -> str:
    text = re.sub(r"/\*.*?\*/", "", text, flags=re.DOTALL)
    text = re.sub(r"//[^\n]*", "", text)
    return re.sub(r'"(?:\\.|[^"\\])*"', '""', text)


def check_delimiters(text: str, label: str) -> None:
    clean = strip_comments_and_strings(text)
    pairs = {"{": "}", "(": ")", "[": "]"}
    stack: list[tuple[str, int]] = []
    for index, character in enumerate(clean):
        if character in pairs:
            stack.append((character, index))
        elif character in pairs.values():
            require(
                bool(stack) and pairs[stack[-1][0]] == character,
                f"unexpected {character!r} in {label} at byte {index}",
            )
            stack.pop()
    require(not stack, f"unclosed delimiter in {label}: {stack[-1:]}")


def check_runtime_delta(runtime: Path, baseline: Path) -> None:
    base_files = file_set(baseline)
    candidate_files = file_set(runtime)
    require(
        candidate_files - base_files == NEW_RUNTIME,
        "unexpected new runtime files: "
        + repr(sorted((candidate_files - base_files) ^ NEW_RUNTIME)),
    )
    require(
        not (base_files - candidate_files),
        f"runtime files were removed: {sorted(base_files - candidate_files)}",
    )
    actual_changed = {
        relative
        for relative in base_files
        if (runtime / relative).read_bytes() != (baseline / relative).read_bytes()
    }
    require(
        actual_changed == CHANGED_EXISTING,
        f"unexpected changed runtime files: {sorted(actual_changed ^ CHANGED_EXISTING)}",
    )


def read_sprite_manifest(project: Path) -> dict[str, str]:
    manifest = project / "docs/DOMINGO_FP_4_32_0e_SHA256.txt"
    require(manifest.is_file(), f"missing sprite digest manifest: {manifest}")
    result: dict[str, str] = {}
    for line_number, raw in enumerate(manifest.read_text("utf-8").splitlines(), 1):
        line = raw.strip()
        if not line or line.startswith("#"):
            continue
        parts = line.split(maxsplit=1)
        require(len(parts) == 2, f"bad manifest line {line_number}")
        digest, relative = parts
        require(
            re.fullmatch(r"[0-9a-f]{64}", digest) is not None,
            f"bad SHA-256 on manifest line {line_number}",
        )
        require(relative not in result, f"duplicate manifest path: {relative}")
        result[relative] = digest
    require(set(result) == SPRITES, "sprite manifest file set is not exact")
    return result


def png_metadata(data: bytes, label: str) -> tuple[int, int, int, int, tuple[int, int]]:
    require(data[:8] == b"\x89PNG\r\n\x1a\n", f"bad PNG signature: {label}")
    offset = 8
    ihdr: tuple[int, int, int, int] | None = None
    grab: tuple[int, int] | None = None
    saw_iend = False
    while offset < len(data):
        require(offset + 12 <= len(data), f"truncated PNG chunk: {label}")
        length = struct.unpack(">I", data[offset:offset + 4])[0]
        chunk_type = data[offset + 4:offset + 8]
        end = offset + 12 + length
        require(end <= len(data), f"truncated PNG payload: {label}")
        payload = data[offset + 8:offset + 8 + length]
        stored_crc = struct.unpack(">I", data[offset + 8 + length:end])[0]
        actual_crc = zlib.crc32(chunk_type + payload) & 0xFFFFFFFF
        require(stored_crc == actual_crc, f"bad PNG CRC: {label}")
        if chunk_type == b"IHDR":
            require(length == 13 and ihdr is None, f"bad/duplicate IHDR: {label}")
            width, height, depth, colour, comp, filt, interlace = struct.unpack(
                ">IIBBBBB", payload
            )
            require((comp, filt, interlace) == (0, 0, 0), f"unsupported PNG: {label}")
            ihdr = (width, height, depth, colour)
        elif chunk_type == b"grAb":
            require(length == 8 and grab is None, f"bad/duplicate grAb: {label}")
            grab = struct.unpack(">ii", payload)
        elif chunk_type == b"IEND":
            require(length == 0, f"bad IEND: {label}")
            saw_iend = True
            require(end == len(data), f"bytes after IEND: {label}")
        offset = end
    require(ihdr is not None and grab is not None and saw_iend, f"incomplete PNG: {label}")
    return (*ihdr, grab)


def check_sprites(runtime: Path, project: Path, supplied_assets: Path | None) -> None:
    manifest = read_sprite_manifest(project)
    for relative in sorted(SPRITES):
        path = runtime / relative
        require(path.is_file(), f"missing runtime sprite: {relative}")
        data = path.read_bytes()
        require(sha256_bytes(data) == manifest[relative], f"sprite digest changed: {relative}")
        require(
            png_metadata(data, relative) == (320, 200, 8, 6, (160, 32)),
            f"sprite format/offset changed: {relative}",
        )
    require(len(MODULE_SPRITES) == 36 and len(COMPOSITE_SPRITES) == 9, "bad sprite partition")

    if supplied_assets is not None:
        supplied_root = supplied_assets.resolve()
        supplied_files = {
            f"sprites/{path.name}" for path in (supplied_root / "sprites").glob("*.png")
        }
        require(supplied_files == SPRITES, "supplied sprite file set is not exact")
        for relative in SPRITES:
            require(
                (runtime / relative).read_bytes() == (supplied_root / relative).read_bytes(),
                f"runtime sprite differs byte-for-byte from delivery: {relative}",
            )


def check_sources(runtime: Path, project: Path) -> None:
    for source in runtime.rglob("*.zs"):
        check_delimiters(source.read_text("utf-8"), source.as_posix())

    zscript = (runtime / "ZSCRIPT").read_text("utf-8")
    prototype_include = '#include "caelum/prototypes/CaelumDomingoFirstPersonPrototype.zs"'
    require(zscript.count(prototype_include) == 1, "prototype include missing/duplicated")
    require(
        zscript.index("CaelumPlayableWeapons.zs")
        < zscript.index("CaelumDomingoFirstPersonPrototype.zs")
        < zscript.index("CaelumHUDOverlay.zs"),
        "prototype include order is unsafe",
    )

    persistent = (runtime / "caelum/equipment/CaelumPersistentCharacterState.zs").read_text("utf-8")
    for token in (
        "MagicBoxOwnershipVersion = 2;",
        "if (MagicBoxOwnershipVersion >= 2) { return; }",
        "if (MagicBoxOwnershipVersion < 1)",
        "MagicBoxOwned = ProfileCommitted;",
    ):
        require(token in persistent, f"missing ownership schema contract: {token}")

    dialogue = (runtime / "caelum/dialogue/CaelumPalomoDialogue.zs").read_text("utf-8")
    marker = re.search(
        r"class\s+CaelumMagicBoxOwnershipToken\s*:\s*CaelumPalomoDialogueMarker\s*\{(.*?)\n\}",
        dialogue,
        flags=re.DOTALL,
    )
    require(marker is not None, "Magic Box ownership marker class missing")
    require("+INVENTORY.UNTOSSABLE" in marker.group(1), "ownership marker is tossable")
    for token in (
        "Inventory.InterHubAmount 1;",
        "+INVENTORY.UNDROPPABLE",
        "+INVENTORY.UNCLEARABLE",
        "+INVENTORY.KEEPDEPLETED",
    ):
        require(token in dialogue, f"missing travelling marker protection: {token}")

    player = (runtime / "caelum/player/CaelumPlayer.zs").read_text("utf-8")
    for token in (
        "bool HasMagicBoxOwnershipToken()",
        "void ReconcileMagicBoxOwnership(bool createState = true)",
        "bool resolvedOwnership = MagicBoxOwned\n            || HasMagicBoxOwnershipToken()\n            || (persistentState != null && persistentState.MagicBoxOwned);",
        "persistentState.MagicBoxOwned = true;",
        '"CaelumMagicBoxOwnershipToken", resolvedOwnership',
        "void SyncLiveMagicBoxOwnershipFromPersistentState()\n    {\n        ReconcileMagicBoxOwnership(true);",
        "override void PreTravelled()",
        "override void Travelled()",
        "ReconcileMagicBoxOwnership(true);\n        RestorePersistentCharacterState();\n        ReconcileMagicBoxOwnership(true);",
    ):
        require(token in player, f"missing monotonic travel contract: {token}")
    require(
        player.index("ReconcileMagicBoxOwnership(true);", player.index("void PersistCharacterState()"))
        < player.index("persistentState.MagicBoxOwned = MagicBoxOwned;"),
        "persist writes ownership before reconciling it",
    )
    require(player.count("MagicBoxOwned = false;") == 1, "unexpected live ownership reset path")

    prototype = (runtime / PROTOTYPE_SOURCE).read_text("utf-8")
    for token in (
        "class CA_DomingoFPSwordShield : Weapon",
        'Tag "$CA_DOMINGO_FP_PROTOTYPE_NAME";',
        "+INVENTORY.UNDROPPABLE",
        "A_ClearOverlays(10, 40)",
        "A_CustomPunch(30, true)",
        "CA_LeftSelect:", "CA_ShieldSelect:", "CA_SwordSelect:", "CA_RightSelect:",
        "LHND AB 8;", "DSHD AB 8;", "DSWD AB 8;", "RHND AB 8;",
        "LHND E 2;", "DSHD E 2;", "DSWD E 2;", "RHND E 2;",
        "LHND H 3;", "DSHD H 3;", "DSWD H 3;", "RHND H 3;",
    ):
        require(token in prototype, f"missing prototype contract: {token}")
    overlays = re.findall(r"A_Overlay\((10|20|30|40),", prototype)
    require(len(overlays) == 16, f"expected 16 overlay starts, got {len(overlays)}")
    require(all(overlays.count(str(layer)) == 4 for layer in (10, 20, 30, 40)),
            "prototype overlay layers are unbalanced")
    require(prototype.count("A_CustomPunch(") == 1, "prototype test attack is not isolated")

    hud = (runtime / "caelum/hud/CaelumHUDOverlay.zs").read_text("utf-8")
    require("ui bool IsDomingoFirstPersonPrototypeActive" in hud, "HUD prototype guard missing")
    require("localPlayer.player.ReadyWeapon is 'CA_DomingoFPSwordShield'" in hud,
            "HUD does not identify the ready prototype")
    require(hud.count("if (IsDomingoFirstPersonPrototypeActive(localPlayer)) { return; }") == 2,
            "HUD prototype overlap guards changed")

    language = (runtime / "LANGUAGE").read_text("utf-8")
    require(
        len(re.findall(r"(?m)^CA_DOMINGO_FP_PROTOTYPE_NAME\s*=", language)) == 2,
        "prototype name must be localized in English and Spanish",
    )

    required_docs = {
        "docs/MAGIC_BOX.md": ("V4.32.0e", "changemap MAP02", "monotónica"),
        "docs/DIALOGUE.md": ("V4.32.0e", "¿Qué querés?"),
        "docs/FIRST_PERSON.md": ("CA_DomingoFPSwordShield", "320×200", "consola"),
        "docs/IMPLEMENTATION_STATUS.md": ("4.32.0e", "monotonic"),
        "docs/ROADMAP.md": ("V4.32.0e", "V4.33"),
        "APLICAR_4_32_0e.txt": ("NO contiene un PK3", "4.32.0d"),
        "PRUEBAS_4_32_0e.txt": ("changemap MAP02", "CA_DomingoFPSwordShield"),
    }
    for relative, tokens in required_docs.items():
        text = (project / relative).read_text("utf-8")
        for token in tokens:
            require(token in text, f"missing documentation token {token!r} in {relative}")


def expected_package_entries() -> set[str]:
    return {f"src/{relative}" for relative in expected_runtime_delta()} | PROJECT_FILES


def check_package(package: Path, runtime: Path, project: Path) -> None:
    expected = expected_package_entries()
    with zipfile.ZipFile(package) as archive:
        infos = archive.infolist()
        names = [info.filename for info in infos]
        require(names == sorted(expected), "package entries are missing, extra or unsorted")
        require(len(names) == len(set(names)), "duplicate package entries")
        require(not archive.comment, "package comment must be empty")
        for info in infos:
            pure = PurePosixPath(info.filename)
            require(not pure.is_absolute() and ".." not in pure.parts, "unsafe package path")
            require(not info.is_dir(), f"directory entry is not allowed: {info.filename}")
            require(info.date_time == FIXED_ZIP_TIME, f"non-deterministic time: {info.filename}")
            require((info.external_attr >> 16) & 0o170000 == 0o100000,
                    f"entry is not a regular file: {info.filename}")
            expected_path = (
                runtime / info.filename.removeprefix("src/")
                if info.filename.startswith("src/")
                else project / info.filename
            )
            require(archive.read(info) == expected_path.read_bytes(),
                    f"package content mismatch: {info.filename}")
    lowered = [name.lower() for name in expected]
    require(not any(name.endswith((".pk3", ".wad")) for name in lowered),
            "compiled game/map output entered source package")
    require(not any(name.startswith("build/") or "/__pycache__/" in name for name in lowered),
            "build/cache output entered source package")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--runtime-root", type=Path, required=True)
    parser.add_argument("--baseline-runtime", type=Path, required=True)
    parser.add_argument("--project-root", type=Path, required=True)
    parser.add_argument("--supplied-assets", type=Path)
    parser.add_argument("--package", type=Path)
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    runtime = args.runtime_root.resolve()
    baseline = args.baseline_runtime.resolve()
    project = args.project_root.resolve()
    require(runtime.is_dir(), f"missing runtime: {runtime}")
    require(baseline.is_dir(), f"missing baseline: {baseline}")
    require(project.is_dir(), f"missing project: {project}")
    require(all((project / relative).is_file() for relative in PROJECT_FILES),
            "a required project file is missing")

    check_runtime_delta(runtime, baseline)
    check_sprites(runtime, project, args.supplied_assets)
    check_sources(runtime, project)
    if args.package is not None:
        check_package(args.package.resolve(), runtime, project)

    print("Caelum Argenteum 4.32.0e audit: PASS")
    print(f"Runtime delta: {len(expected_runtime_delta())} files")
    print(f"Sprites: {len(SPRITES)} exact PNGs (36 modular + 9 composite)")
    print("Magic Box: monotonic three-proof travel reconciliation present")
    if args.supplied_assets is not None:
        print("Supplier comparison: exact byte match")
    if args.package is not None:
        print(f"Package entries: {len(expected_package_entries())}")
        print(f"Package SHA-256: {sha256(args.package.resolve())}")


if __name__ == "__main__":
    main()
