#!/usr/bin/env python3
"""Deterministic focused audit for Caelum Argenteum 4.32.0g."""

from __future__ import annotations

import argparse
import hashlib
import re
import struct
import zipfile
import zlib
from pathlib import Path, PurePosixPath


PLAYABLE_WEAPONS = "caelum/equipment/CaelumPlayableWeapons.zs"
MIRROR_PIVOTS = {
    "sprites/DSWDA0.png": 178,
    "sprites/DSWDB0.png": 179,
    "sprites/DSWDD0.png": 137,
    "sprites/DSWDG0.png": 178,
}
RUNTIME_FILES = {PLAYABLE_WEAPONS, *MIRROR_PIVOTS}
PROJECT_FILES = {
    "APLICAR_4_32_0g.txt",
    "PRUEBAS_4_32_0g.txt",
    "docs/DOMINGO_FP_4_32_0g_SHA256.txt",
    "docs/FIRST_PERSON.md",
    "docs/IMPLEMENTATION_STATUS.md",
    "docs/ROADMAP.md",
    "tools/audit_4_32_0g.py",
    "tools/build_source_patch_4_32_0g.py",
    "tools/inject_png_grab_4_32_0g.mjs",
}
FIXED_ZIP_TIME = (2026, 9, 6, 22, 30, 0)


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


def braced_span(text: str, pattern: str, label: str) -> tuple[int, int]:
    match = re.search(pattern, text)
    require(match is not None, f"missing {label}")
    opening = text.find("{", match.end())
    require(opening >= 0, f"missing body for {label}")
    depth = 0
    for index in range(opening, len(text)):
        if text[index] == "{":
            depth += 1
        elif text[index] == "}":
            depth -= 1
            if depth == 0:
                return match.start(), index + 1
    raise AssertionError(f"unclosed body for {label}")


def class_span(text: str, class_name: str) -> tuple[int, int]:
    return braced_span(
        text,
        rf"\bclass\s+{re.escape(class_name)}\b",
        f"class {class_name}",
    )


def read_sprite_manifest(project: Path) -> dict[str, str]:
    manifest = project / "docs/DOMINGO_FP_4_32_0g_SHA256.txt"
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
    require(set(result) == set(MIRROR_PIVOTS), "sprite manifest file set is not exact")
    return result


def paeth(left: int, up: int, upper_left: int) -> int:
    prediction = left + up - upper_left
    left_distance = abs(prediction - left)
    up_distance = abs(prediction - up)
    upper_left_distance = abs(prediction - upper_left)
    if left_distance <= up_distance and left_distance <= upper_left_distance:
        return left
    if up_distance <= upper_left_distance:
        return up
    return upper_left


def decode_png(data: bytes, label: str) -> tuple[tuple[int, int, int, int, tuple[int, int]], bytes]:
    require(data[:8] == b"\x89PNG\r\n\x1a\n", f"bad PNG signature: {label}")
    cursor = 8
    ihdr: tuple[int, int, int, int] | None = None
    grab: tuple[int, int] | None = None
    idat = bytearray()
    saw_iend = False

    while cursor < len(data):
        require(cursor + 12 <= len(data), f"truncated PNG chunk: {label}")
        length = struct.unpack(">I", data[cursor:cursor + 4])[0]
        chunk_type = data[cursor + 4:cursor + 8]
        end = cursor + 12 + length
        require(end <= len(data), f"truncated PNG payload: {label}")
        payload = data[cursor + 8:cursor + 8 + length]
        stored_crc = struct.unpack(">I", data[cursor + 8 + length:end])[0]
        require(
            stored_crc == (zlib.crc32(chunk_type + payload) & 0xFFFFFFFF),
            f"bad PNG CRC: {label}",
        )
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
        elif chunk_type == b"IDAT":
            idat.extend(payload)
        elif chunk_type == b"IEND":
            require(length == 0 and end == len(data), f"bad IEND: {label}")
            saw_iend = True
        cursor = end

    require(ihdr is not None and grab is not None and saw_iend, f"incomplete PNG: {label}")
    width, height, depth, colour = ihdr
    require((depth, colour) == (8, 6), f"PNG is not 8-bit RGBA: {label}")
    stride = width * 4
    packed = zlib.decompress(bytes(idat))
    require(len(packed) == height * (stride + 1), f"bad scanline size: {label}")

    pixels = bytearray()
    previous = bytearray(stride)
    offset = 0
    for _ in range(height):
        filter_type = packed[offset]
        offset += 1
        row = bytearray(packed[offset:offset + stride])
        offset += stride
        require(filter_type <= 4, f"unknown PNG filter {filter_type}: {label}")
        for index in range(stride):
            left = row[index - 4] if index >= 4 else 0
            up = previous[index]
            upper_left = previous[index - 4] if index >= 4 else 0
            if filter_type == 1:
                row[index] = (row[index] + left) & 0xFF
            elif filter_type == 2:
                row[index] = (row[index] + up) & 0xFF
            elif filter_type == 3:
                row[index] = (row[index] + ((left + up) // 2)) & 0xFF
            elif filter_type == 4:
                row[index] = (row[index] + paeth(left, up, upper_left)) & 0xFF
        pixels.extend(row)
        previous = row

    return (width, height, depth, colour, grab), bytes(pixels)


def mirrored_pixels(source: bytes, width: int, height: int, pivot_x: int) -> bytes:
    result = bytearray(width * height * 4)
    for y in range(height):
        for x in range(width):
            source_x = 2 * pivot_x - x
            if 0 <= source_x < width:
                destination = (y * width + x) * 4
                origin = (y * width + source_x) * 4
                result[destination:destination + 4] = source[origin:origin + 4]
    return bytes(result)


def check_sprites(project: Path, baseline: Path) -> None:
    manifest = read_sprite_manifest(project)
    for relative, pivot in sorted(MIRROR_PIVOTS.items()):
        candidate_path = project / "src" / relative
        baseline_path = baseline / relative
        candidate_data = candidate_path.read_bytes()
        baseline_data = baseline_path.read_bytes()
        require(
            sha256_bytes(candidate_data) == manifest[relative],
            f"digest mismatch: {relative}",
        )
        candidate_meta, candidate_pixels = decode_png(candidate_data, relative)
        baseline_meta, baseline_pixels = decode_png(baseline_data, f"baseline/{relative}")
        require(
            candidate_meta == (320, 200, 8, 6, (160, 32)),
            f"bad candidate format/offset: {relative}",
        )
        require(
            baseline_meta == (320, 200, 8, 6, (160, 32)),
            f"bad baseline format/offset: {relative}",
        )
        require(
            candidate_pixels == mirrored_pixels(baseline_pixels, 320, 200, pivot),
            f"sprite is not the exact grip-pivot mirror: {relative}",
        )


def check_sources(project: Path, baseline_root: Path) -> None:
    candidate = project / "src"
    baseline = baseline_root / "src" if (baseline_root / "src").is_dir() else baseline_root
    require(baseline.is_dir(), f"missing 4.32.0f baseline: {baseline}")
    require(file_set(candidate) == file_set(baseline), "source file set changed from 4.32.0f")
    changed = {
        relative
        for relative in file_set(candidate)
        if (candidate / relative).read_bytes() != (baseline / relative).read_bytes()
    }
    require(changed == RUNTIME_FILES, f"unexpected runtime delta: {sorted(changed ^ RUNTIME_FILES)}")

    for source in candidate.rglob("*.zs"):
        check_delimiters(source.read_text("utf-8"), source.as_posix())

    old_text = (baseline / PLAYABLE_WEAPONS).read_text("utf-8")
    new_text = (candidate / PLAYABLE_WEAPONS).read_text("utf-8")
    old_start, old_end = class_span(old_text, "CaelumSwordSelectorWeapon")
    new_start, new_end = class_span(new_text, "CaelumSwordSelectorWeapon")
    require(
        old_text[:old_start] + old_text[old_end:]
        == new_text[:new_start] + new_text[new_end:],
        "a non-sword section of CaelumPlayableWeapons.zs changed",
    )

    old_sword = old_text[old_start:old_end]
    new_sword = new_text[new_start:new_end]
    helper_start, helper_end = braced_span(
        new_sword,
        r"\baction\s+void\s+A_CaelumSwordPlaceView\s*\(\s*\)",
        "A_CaelumSwordPlaceView",
    )
    without_helper = new_sword[:helper_start] + new_sword[helper_end:]
    without_calls = re.sub(
        r"(?m)^\s*A_CaelumSwordPlaceView\(\);\s*$",
        "",
        without_helper,
    )
    canonical = lambda value: re.sub(r"\s+", "", value)
    require(
        canonical(without_calls) == canonical(old_sword),
        "the sword class changed beyond the common placement helper",
    )

    for layer in (10, 20, 25, 30, 40):
        require(
            f"A_OverlayOffset({layer}, 160.0, 0.0);" in new_sword,
            f"missing common +160 offset on layer {layer}",
        )
    require(new_sword.count("A_OverlayOffset(") == 5, "unexpected overlay offset call")
    require(
        new_sword.count("A_CaelumSwordPlaceView();") == 7,
        "placement helper is not applied to every view transition",
    )
    require("A_WeaponOffset" not in new_sword, "main weapon offset was changed")

    check_sprites(project, baseline)

    required_docs = {
        "docs/FIRST_PERSON.md": ("V4.32.0g", "160", "arriba-derecha"),
        "docs/IMPLEMENTATION_STATUS.md": ("4.32.0g", "author validation pending"),
        "docs/ROADMAP.md": ("V4.32.0g", "V4.33"),
        "APLICAR_4_32_0g.txt": ("NO contiene un PK3", "Base requerida: 4.32.0f"),
        "PRUEBAS_4_32_0g.txt": ("arriba-derecha", "El resto de 4.32.0f"),
    }
    for relative, tokens in required_docs.items():
        document = (project / relative).read_text("utf-8")
        for token in tokens:
            require(token in document, f"missing token {token!r} in {relative}")


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
            require(
                (info.external_attr >> 16) & 0o170000 == 0o100000,
                f"entry is not a regular file: {info.filename}",
            )
            require(
                archive.read(info) == (project / info.filename).read_bytes(),
                f"package content mismatch: {info.filename}",
            )
    require(
        not any(name.lower().endswith((".pk3", ".wad")) for name in expected),
        "compiled output entered source package",
    )


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--project-root", type=Path, required=True)
    parser.add_argument("--baseline-0f", type=Path, required=True)
    parser.add_argument("--package", type=Path)
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    project = args.project_root.resolve()
    require(project.is_dir(), f"missing project: {project}")
    require(
        all((project / relative).is_file() for relative in PROJECT_FILES),
        "a required project file is missing",
    )
    check_sources(project, args.baseline_0f.resolve())
    if args.package is not None:
        check_package(args.package.resolve(), project)

    print("Caelum Argenteum 4.32.0g audit: PASS")
    print(f"Runtime delta from 4.32.0f: {len(RUNTIME_FILES)} files")
    print("Placement: five PSprite layers at X=160; inherited Y/bob unchanged")
    print("Sword: A/B idle, D select and G recovery mirrored around their grips")
    print("Gameplay and every non-sword source: byte-identical to 4.32.0f")
    if args.package is not None:
        print(f"Package entries: {len(expected_package_entries())}")
        print(f"Package SHA-256: {sha256(args.package.resolve())}")


if __name__ == "__main__":
    main()
