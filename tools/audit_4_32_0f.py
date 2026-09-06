#!/usr/bin/env python3
"""Deterministic focused audit for Caelum Argenteum 4.32.0f."""

from __future__ import annotations

import argparse
import hashlib
import re
import struct
import zipfile
import zlib
from pathlib import Path, PurePosixPath


TEXT_RUNTIME = {
    "LANGUAGE",
    "ZSCRIPT",
    "caelum/dialogue/CaelumPalomoDialogue.zs",
    "caelum/equipment/CaelumPersistentCharacterState.zs",
    "caelum/equipment/CaelumPlayableWeapons.zs",
    "caelum/hud/CaelumHUDOverlay.zs",
    "caelum/player/CaelumPlayer.zs",
}
SUPPLIED_PREFIXES = ("LHND", "DSHD", "DSWD", "RHND")
SUPPLIED_MODULES = {
    f"sprites/{prefix}{frame}0.png"
    for prefix in SUPPLIED_PREFIXES
    for frame in "ABCDEFGHI"
}
SUPPLIED_COMPOSITES = {
    "sprites/DFPAA0.png", "sprites/DFPAB0.png", "sprites/DFPAC0.png",
    "sprites/DFPBA0.png", "sprites/DFPBB0.png",
    "sprites/DFPRA0.png", "sprites/DFPRB0.png",
    "sprites/DFPSA0.png", "sprites/DFPSB0.png",
}
SUPPLIED_SPRITES = SUPPLIED_MODULES | SUPPLIED_COMPOSITES
FINGER_SPRITES = {
    f"sprites/RFNG{frame}0.png" for frame in "ABCDEFGHI"
}
SPRITES = SUPPLIED_SPRITES | FINGER_SPRITES
RUNTIME_FILES = TEXT_RUNTIME | SPRITES
OBSOLETE_PROTOTYPE = "caelum/prototypes/CaelumDomingoFirstPersonPrototype.zs"

CHANGED_FROM_0E = {
    "LANGUAGE",
    "ZSCRIPT",
    "caelum/dialogue/CaelumPalomoDialogue.zs",
    "caelum/equipment/CaelumPersistentCharacterState.zs",
    "caelum/hud/CaelumHUDOverlay.zs",
    "caelum/player/CaelumPlayer.zs",
    "sprites/DFPAA0.png", "sprites/DFPAB0.png", "sprites/DFPAC0.png",
    "sprites/DFPBA0.png", "sprites/DFPBB0.png",
    "sprites/DFPRA0.png", "sprites/DFPRB0.png",
    "sprites/DFPSA0.png", "sprites/DFPSB0.png",
    "sprites/DSHDA0.png", "sprites/DSHDB0.png", "sprites/DSHDC0.png",
    "sprites/DSHDD0.png", "sprites/DSHDE0.png", "sprites/DSHDF0.png",
    "sprites/DSHDG0.png", "sprites/DSHDH0.png", "sprites/DSHDI0.png",
    "sprites/DSWDC0.png", "sprites/DSWDD0.png",
    "sprites/LHNDC0.png", "sprites/LHNDD0.png",
    "sprites/RHNDC0.png", "sprites/RHNDD0.png",
}
ADDED_FROM_0E = {
    "caelum/equipment/CaelumPlayableWeapons.zs",
} | FINGER_SPRITES

PROJECT_FILES = {
    "APLICAR_4_32_0f.txt",
    "PRUEBAS_4_32_0f.txt",
    "docs/DIALOGUE.md",
    "docs/DOMINGO_FP_4_32_0f_SHA256.txt",
    "docs/FIRST_PERSON.md",
    "docs/IMPLEMENTATION_STATUS.md",
    "docs/MAGIC_BOX.md",
    "docs/ROADMAP.md",
    "tools/audit_4_32_0f.py",
    "tools/build_source_patch_4_32_0f.py",
}
FIXED_ZIP_TIME = (2026, 9, 6, 20, 0, 0)


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


def class_span(text: str, class_name: str) -> tuple[int, int]:
    match = re.search(rf"\bclass\s+{re.escape(class_name)}\b", text)
    require(match is not None, f"missing class {class_name}")
    opening = text.find("{", match.end())
    require(opening >= 0, f"missing class body for {class_name}")
    depth = 0
    for index in range(opening, len(text)):
        if text[index] == "{":
            depth += 1
        elif text[index] == "}":
            depth -= 1
            if depth == 0:
                return match.start(), index + 1
    raise AssertionError(f"unclosed class body for {class_name}")


def read_sprite_manifest(project: Path) -> dict[str, str]:
    manifest = project / "docs/DOMINGO_FP_4_32_0f_SHA256.txt"
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


def check_sprites(project: Path, supplied_assets: Path | None) -> None:
    runtime = project / "src"
    manifest = read_sprite_manifest(project)
    for relative in sorted(SPRITES):
        path = runtime / relative
        require(path.is_file(), f"missing runtime sprite: {relative}")
        data = path.read_bytes()
        require(sha256_bytes(data) == manifest[relative], f"digest mismatch: {relative}")
        require(
            png_metadata(data, relative) == (320, 200, 8, 6, (160, 32)),
            f"bad sprite format/offset: {relative}",
        )
    require(len(SUPPLIED_SPRITES) == 45, "bad supplied sprite partition")
    require(len(FINGER_SPRITES) == 9, "bad finger sprite partition")

    if supplied_assets is not None:
        supplied = supplied_assets.resolve()
        supplied_files = {
            f"sprites/{path.name}" for path in (supplied / "sprites").glob("*.png")
        }
        require(supplied_files == SUPPLIED_SPRITES, "supplied file set is not exact")
        for relative in SUPPLIED_SPRITES:
            require(
                (runtime / relative).read_bytes() == (supplied / relative).read_bytes(),
                f"runtime differs from supplied revision 2: {relative}",
            )


def check_baselines(project: Path, baseline_0e: Path, base_runtime: Path) -> None:
    candidate = project / "src"
    baseline = baseline_0e / "src" if (baseline_0e / "src").is_dir() else baseline_0e
    base = base_runtime
    require(baseline.is_dir(), f"missing 4.32.0e baseline: {baseline}")
    require(base.is_dir(), f"missing base runtime: {base}")

    shared = file_set(candidate) & file_set(baseline)
    changed = {
        relative for relative in shared
        if (candidate / relative).read_bytes() != (baseline / relative).read_bytes()
    }
    require(changed == CHANGED_FROM_0E, f"unexpected changes from 0e: {sorted(changed ^ CHANGED_FROM_0E)}")
    require(
        file_set(candidate) - file_set(baseline) == ADDED_FROM_0E,
        "unexpected files added relative to 0e",
    )
    require(
        file_set(baseline) - file_set(candidate) == {OBSOLETE_PROTOTYPE},
        "obsolete prototype is not the sole removed patch file",
    )

    relative = "caelum/equipment/CaelumPlayableWeapons.zs"
    old_text = (base / relative).read_text("utf-8")
    new_text = (candidate / relative).read_text("utf-8")
    old_start, old_end = class_span(old_text, "CaelumSwordSelectorWeapon")
    new_start, new_end = class_span(new_text, "CaelumSwordSelectorWeapon")
    require(
        old_text[:old_start] + old_text[old_end:]
        == new_text[:new_start] + new_text[new_end:],
        "a non-sword section of CaelumPlayableWeapons.zs changed",
    )


def check_sources(project: Path) -> None:
    runtime = project / "src"
    require(file_set(runtime) == RUNTIME_FILES, "project runtime file set is not exact")
    for source in runtime.rglob("*.zs"):
        check_delimiters(source.read_text("utf-8"), source.as_posix())

    zscript = (runtime / "ZSCRIPT").read_text("utf-8")
    require(zscript.count('#include "caelum/equipment/CaelumPlayableWeapons.zs"') == 1,
            "playable weapon include missing/duplicated")
    require("CaelumDomingoFirstPersonPrototype" not in zscript,
            "obsolete prototype remains included")

    playable = (runtime / "caelum/equipment/CaelumPlayableWeapons.zs").read_text("utf-8")
    start, end = class_span(playable, "CaelumSwordSelectorWeapon")
    sword = playable[start:end]
    for token in (
        "bool CaelumSwordViewShieldVisible;",
        "bool CaelumSwordViewBlocking;",
        "caelumPlayer.HasActiveBlockSource()",
        'A_Overlay(25, "CA_SwordRightIdle", true);',
        'A_Overlay(30, "CA_SwordBladeIdle", true);',
        'A_Overlay(40, "CA_SwordFingersIdle", true);',
        "A_ClearOverlays(10, 10);",
        "A_ClearOverlays(20, 20);",
        "PerformWeaponFamilyPrimaryAttack(",
        "PerformWeaponFamilySecondaryAction(",
        "EquippedWeaponCooldownRemaining > previousCooldown",
        "A_CaelumContextZoomInput",
        "WRF_ALLOWZOOM",
        "RFNG AB 8;",
        "RFNG C 3;",
        "RFNG E 2;",
        "RFNG H 3;",
        "RFNG I 1;",
    ):
        require(token in sword, f"missing real-sword view contract: {token}")
    require("A_CustomPunch" not in sword, "test punch remains in real sword")
    require("CA_DomingoFPSwordShield" not in playable, "special test weapon remains")
    overlay_layers = set(re.findall(r"A_Overlay\(\s*(10|20|25|30|40)\s*,", sword))
    require(overlay_layers == {"10", "20", "25", "30", "40"},
            f"wrong sword overlay layers: {sorted(overlay_layers)}")

    hud = (runtime / "caelum/hud/CaelumHUDOverlay.zs").read_text("utf-8")
    require("ui bool IsDomingoSwordViewActive" in hud, "real-sword HUD guard missing")
    require("ReadyWeapon is 'CaelumSwordSelectorWeapon'" in hud,
            "HUD guard does not identify the real sword")
    require(hud.count("if (IsDomingoSwordViewActive(localPlayer)) { return; }") == 2,
            "HUD overlap guards changed")
    require("IsDomingoFirstPersonPrototypeActive" not in hud,
            "prototype HUD guard remains")

    language = (runtime / "LANGUAGE").read_text("utf-8")
    require("CA_DOMINGO_FP_PROTOTYPE_NAME" not in language,
            "obsolete prototype localization remains")

    persistent = (runtime / "caelum/equipment/CaelumPersistentCharacterState.zs").read_text("utf-8")
    for token in (
        "MagicBoxOwnershipVersion = 1;",
        "if (MagicBoxOwnershipVersion >= 1) { return; }",
        "MagicBoxOwned = ProfileCommitted;",
    ):
        require(token in persistent, f"missing restored ownership schema: {token}")
    require("MagicBoxOwnershipVersion = 2;" not in persistent,
            "redundant ownership schema 2 remains")

    player = (runtime / "caelum/player/CaelumPlayer.zs").read_text("utf-8")
    for token in (
        "void SyncLiveMagicBoxOwnershipFromPersistentState()",
        "MagicBoxOwned = persistentState.MagicBoxOwned;",
        "override void PreTravelled()",
        "override void Travelled()",
        "Super.Travelled();\n        RestorePersistentCharacterState();",
    ):
        require(token in player, f"missing authoritative travel contract: {token}")
    require("ReconcileMagicBoxOwnership" not in player,
            "redundant ownership reconciliation remains")
    require("HasMagicBoxOwnershipToken" not in player,
            "dialogue token remains an ownership authority")

    dialogue = (runtime / "caelum/dialogue/CaelumPalomoDialogue.zs").read_text("utf-8")
    require("class CaelumMagicBoxOwnershipToken : CaelumPalomoDialogueMarker {}" in dialogue,
            "USDF ownership marker is not the simple derived marker")
    marker_start = dialogue.index("class CaelumMagicBoxOwnershipToken")
    marker_end = dialogue.index("class CaelumPalomoDiscountGrantedToken")
    require("UNTOSSABLE" not in dialogue[marker_start:marker_end],
            "redundant ownership-receipt flag remains")

    required_docs = {
        "docs/MAGIC_BOX.md": ("V4.32.0f", "map MAP02", "changemap MAP02"),
        "docs/DIALOGUE.md": ("V4.32.0f", "CaelumPersistentCharacterState"),
        "docs/FIRST_PERSON.md": ("CaelumSwordSelectorWeapon", "RFNG", "HasActiveBlockSource"),
        "docs/IMPLEMENTATION_STATUS.md": ("4.32.0f", "right-finger"),
        "docs/ROADMAP.md": ("V4.32.0f", "V4.33"),
        "APLICAR_4_32_0f.txt": ("NO contiene un PK3", "Base requerida: 4.32.0e"),
        "PRUEBAS_4_32_0f.txt": ("map MAP02", "Espada sin escudo"),
    }
    for relative, tokens in required_docs.items():
        text = (project / relative).read_text("utf-8")
        for token in tokens:
            require(token in text, f"missing documentation token {token!r} in {relative}")


def expected_package_entries() -> set[str]:
    return {f"src/{relative}" for relative in RUNTIME_FILES} | PROJECT_FILES


def check_package(package: Path, project: Path) -> None:
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
            expected_path = project / info.filename
            require(archive.read(info) == expected_path.read_bytes(),
                    f"package content mismatch: {info.filename}")
    lowered = [name.lower() for name in expected]
    require(not any(name.endswith((".pk3", ".wad")) for name in lowered),
            "compiled output entered source package")
    require(not any("/__pycache__/" in name for name in lowered),
            "cache output entered source package")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--project-root", type=Path, required=True)
    parser.add_argument("--baseline-0e", type=Path)
    parser.add_argument("--base-runtime", type=Path)
    parser.add_argument("--supplied-assets", type=Path)
    parser.add_argument("--package", type=Path)
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    project = args.project_root.resolve()
    require(project.is_dir(), f"missing project: {project}")
    require(all((project / relative).is_file() for relative in PROJECT_FILES),
            "a required project file is missing")
    require((args.baseline_0e is None) == (args.base_runtime is None),
            "baseline-0e and base-runtime must be supplied together")

    check_sources(project)
    check_sprites(project, args.supplied_assets)
    if args.baseline_0e is not None and args.base_runtime is not None:
        check_baselines(
            project,
            args.baseline_0e.resolve(),
            args.base_runtime.resolve(),
        )
    if args.package is not None:
        check_package(args.package.resolve(), project)

    print("Caelum Argenteum 4.32.0f audit: PASS")
    print(f"Runtime source delta: {len(RUNTIME_FILES)} files")
    print("Sprites: 45 supplied revision-2 PNGs + 9 derived finger layers")
    print("Sword: real selector, five PSprite depths, conditional shield")
    print("Magic Box: authoritative travel record; map/new-game semantics documented")
    if args.supplied_assets is not None:
        print("Supplier comparison: 45/45 exact byte matches")
    if args.package is not None:
        print(f"Package entries: {len(expected_package_entries())}")
        print(f"Package SHA-256: {sha256(args.package.resolve())}")


if __name__ == "__main__":
    main()
