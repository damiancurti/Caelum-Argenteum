#!/usr/bin/env python3
"""Deterministic focused audit for Caelum Argenteum 4.32.0i."""

from __future__ import annotations

import argparse
import hashlib
import re
import struct
import zipfile
import zlib
from pathlib import Path, PurePosixPath


PLAYABLE_WEAPONS = "caelum/equipment/CaelumPlayableWeapons.zs"
SPRITE_SPECS = {
    "src/sprites/DSWDA0.png": (320, 200, (160, 32), False),
    "src/sprites/DSWDB0.png": (320, 200, (160, 32), False),
    "src/sprites/DSWDD0.png": (320, 200, (160, 32), False),
    "src/sprites/DSWDG0.png": (320, 200, (160, 32), False),
    "src/sprites/RHNDA0.png": (480, 240, (160, 72), True),
    "src/sprites/RHNDB0.png": (480, 240, (160, 72), True),
    "src/sprites/DSHDI0.png": (450, 300, (225, 48), False),
    "src/sprites/LHNDI0.png": (450, 300, (225, 48), False),
}
ART_SPECS = {
    "art_source/domingo_fp_4_32_0h/RHNDA0_2x_960x480.png": (960, 480),
    "art_source/domingo_fp_4_32_0i/DSHDI0_2x_900x600.png": (900, 600),
    "art_source/domingo_fp_4_32_0i/LHNDI0_2x_900x600.png": (900, 600),
}
RUNTIME_FILES = {
    PLAYABLE_WEAPONS,
    *(relative.removeprefix("src/") for relative in SPRITE_SPECS),
}
PROJECT_FILES = {
    "APLICAR_4_32_0i.txt",
    "PRUEBAS_4_32_0i.txt",
    "docs/DOMINGO_FP_4_32_0i_ARTE.md",
    "docs/DOMINGO_FP_4_32_0i_SHA256.txt",
    "docs/FIRST_PERSON.md",
    "docs/IMPLEMENTATION_STATUS.md",
    "docs/ROADMAP.md",
    "tools/audit_4_32_0i.py",
    "tools/build_source_patch_4_32_0i.py",
    "tools/inject_png_grab_4_32_0i.mjs",
    "art_source/domingo_fp_4_32_0i/IMAGEGEN_PROMPTS.txt",
    *ART_SPECS,
}
FIXED_ZIP_TIME = (2026, 9, 7, 0, 30, 0)


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


def paeth(left: int, up: int, upper_left: int) -> int:
    prediction = left + up - upper_left
    distances = (
        abs(prediction - left),
        abs(prediction - up),
        abs(prediction - upper_left),
    )
    return (left, up, upper_left)[distances.index(min(distances))]


def decode_png(
    data: bytes, label: str
) -> tuple[tuple[int, int, int, int, tuple[int, int] | None], bytes]:
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

    require(ihdr is not None and saw_iend, f"incomplete PNG: {label}")
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


def alpha_bbox(pixels: bytes, width: int, height: int) -> tuple[int, int, int, int]:
    points = [
        (index // 4 % width, index // 4 // width)
        for index in range(0, len(pixels), 4)
        if pixels[index + 3] != 0
    ]
    require(points, "PNG contains no visible pixels")
    xs = [point[0] for point in points]
    ys = [point[1] for point in points]
    return min(xs), min(ys), max(xs), max(ys)


def read_manifest(project: Path) -> dict[str, str]:
    path = project / "docs/DOMINGO_FP_4_32_0i_SHA256.txt"
    result: dict[str, str] = {}
    for line_number, raw in enumerate(path.read_text("utf-8").splitlines(), 1):
        line = raw.strip()
        if not line or line.startswith("#"):
            continue
        parts = line.split(maxsplit=1)
        require(len(parts) == 2, f"bad manifest line {line_number}")
        digest, relative = parts
        require(re.fullmatch(r"[0-9a-f]{64}", digest) is not None, "bad digest")
        require(relative not in result, f"duplicate manifest path: {relative}")
        result[relative] = digest
    require(set(result) == set(SPRITE_SPECS) | set(ART_SPECS), "manifest set differs")
    return result


def check_pngs(project: Path) -> None:
    manifest = read_manifest(project)
    for relative, (width, height, grab, must_reach_right) in SPRITE_SPECS.items():
        data = (project / relative).read_bytes()
        require(sha256_bytes(data) == manifest[relative], f"hash mismatch: {relative}")
        meta, pixels = decode_png(data, relative)
        require(meta == (width, height, 8, 6, grab), f"bad PNG metadata: {relative}")
        require(
            all(pixels[i + 3] != 0 or pixels[i:i + 3] == b"\0\0\0"
                for i in range(0, len(pixels), 4)),
            f"nonzero RGB beneath transparent pixels: {relative}",
        )
        bbox = alpha_bbox(pixels, width, height)
        if must_reach_right:
            require(bbox[2] == width - 1, f"arm does not reach right edge: {relative}")

    for relative, (width, height) in ART_SPECS.items():
        data = (project / relative).read_bytes()
        require(sha256_bytes(data) == manifest[relative], f"hash mismatch: {relative}")
        meta, pixels = decode_png(data, relative)
        require(meta == (width, height, 8, 6, None), f"bad art metadata: {relative}")
        require(alpha_bbox(pixels, width, height)[2] == width - 1 or "RHNDA0" not in relative,
                f"master arm does not reach right edge: {relative}")

    shield_meta, shield_pixels = decode_png(
        (project / "src/sprites/DSHDI0.png").read_bytes(), "DSHDI0"
    )
    hand_meta, hand_pixels = decode_png(
        (project / "src/sprites/LHNDI0.png").read_bytes(), "LHNDI0"
    )
    shield_box = alpha_bbox(shield_pixels, shield_meta[0], shield_meta[1])
    hand_box = alpha_bbox(hand_pixels, hand_meta[0], hand_meta[1])
    require(shield_box == (79, 0, 371, 243), f"unexpected shield alpha box: {shield_box}")
    require(hand_box == (121, 74, 333, 242), f"unexpected hand alpha box: {hand_box}")

    shield_width = shield_box[2] - shield_box[0] + 1
    shield_height = shield_box[3] - shield_box[1] + 1
    hand_width = hand_box[2] - hand_box[0] + 1
    hand_height = hand_box[3] - hand_box[1] + 1
    require(
        (shield_width, shield_height) == (293, 244),
        "held shield is not the registered 293x244 frame",
    )
    require(
        abs(shield_height / 195.0 - 1.25) < 0.01,
        "held shield is not 125% of the 4.32.0h displayed height",
    )
    require(
        abs(shield_width / shield_height - 1.2) < 0.01,
        "held shield does not compensate Doom's 1.2 pixel aspect",
    )
    require(
        (hand_width, hand_height) == (213, 169),
        "held hand is not the registered 125% frame",
    )
    require(
        abs(hand_width / 170.0 - 1.25) < 0.01
        and abs(hand_height / 135.0 - 1.25) < 0.01,
        "held hand is not 125% of the 4.32.0h frame",
    )


def check_sources(project: Path, baseline_root: Path) -> None:
    candidate = project / "src"
    baseline = baseline_root / "src" if (baseline_root / "src").is_dir() else baseline_root
    require(baseline.is_dir(), f"missing 4.32.0f baseline: {baseline}")
    require(file_set(candidate) == file_set(baseline), "source file set changed")
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
    sword = new_text[new_start:new_end]

    required = (
        "bool CaelumSwordViewAttacking;",
        "double CaelumSwordViewRotation;",
        "invoker.CaelumSwordViewBlocking ? 160.0 : 105.0",
        "invoker.CaelumSwordViewBlocking ? 100.0 : 0.0",
        "invoker.CaelumSwordViewBlocking ? 0.0 : -18.0",
        "A_OverlayPivot(30, 0.55625, 0.83);",
        "A_OverlayRotate(30, swordRotation);",
        "invoker.CaelumSwordViewRotation = 24.0;",
        "invoker.CaelumSwordViewRotation = 43.0;",
        "invoker.CaelumSwordViewRotation = 31.0;",
        "A_OverlayOffset(25, 174.0, -10.0);",
        "A_OverlayOffset(25, 132.0, -36.0);",
        "A_OverlayOffset(25, 148.0, -25.0);",
        "RHND A 2 A_CaelumSwordAttackRetract;",
        "RHND A 3 A_CaelumSwordAttackExtend;",
        "RHND A 3 A_CaelumSwordAttackRecover;",
        "PerformWeaponFamilyPrimaryAttack",
        "PerformWeaponFamilySecondaryAction",
    )
    for token in required:
        require(token in sword, f"missing sword token: {token}")
    for prefix in ("DSHD", "LHND", "RHND", "DSWD", "RFNG"):
        require(f"{prefix} I -1;" in sword, f"Block does not hold {prefix} I")
    require(sword.count(" I -1;") == 5, "unexpected indefinite Block state")
    require(not re.search(r"(?m)^\s+(?:DSHD|LHND|RHND|DSWD|RFNG) [EFG] [0-9]", sword),
            "attack still references rotating E/F/G art")
    require("A_WeaponOffset" not in sword, "main weapon offset was changed")

    check_pngs(project)

    required_docs = {
        "docs/FIRST_PERSON.md": ("V4.32.0i", "Y=100", "293×244", "43°"),
        "docs/IMPLEMENTATION_STATUS.md": ("4.32.0i", "orthographic", "125.1%"),
        "docs/ROADMAP.md": ("V4.32.0i", "V4.33", "pixel aspect"),
        "docs/DOMINGO_FP_4_32_0i_ARTE.md": (
            "precise-object-edit", "background-extraction", "900×600"
        ),
        "APLICAR_4_32_0i.txt": ("NO contiene un PK3", "4.32.0f, 4.32.0g o 4.32.0h"),
        "PRUEBAS_4_32_0i.txt": ("75–80°", "95–110°", "diecinueve puntos"),
        "art_source/domingo_fp_4_32_0i/IMAGEGEN_PROMPTS.txt": (
            "precise-object-edit", "background-extraction", "true orthographic"
        ),
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

    print("Caelum Argenteum 4.32.0i audit: PASS")
    print(f"Runtime delta from 4.32.0f: {len(RUNTIME_FILES)} files")
    print("Idle shield: X=105; held Block: I at (160,100), 125%, no loop")
    print("Shield: orthographic 293x244 frame compensates 1.2 pixel aspect")
    print("Sword: base Y=-18; ~79-degree rest to ~104-degree impact")
    print("Right arm: 480x240 canvas reaches the panoramic edge")
    print("Gameplay and every non-sword source: byte-identical to 4.32.0f")
    if args.package is not None:
        print(f"Package entries: {len(expected_package_entries())}")
        print(f"Package SHA-256: {sha256(args.package.resolve())}")


if __name__ == "__main__":
    main()
