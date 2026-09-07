#!/usr/bin/env python3
"""Deterministic focused audit for Caelum Argenteum 4.32.0o."""

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
    "src/sprites/RFNGA0.png": (320, 200, (160, 32), False),
    "src/sprites/RFNGB0.png": (320, 200, (160, 32), False),
    "src/sprites/DSHDI0.png": (450, 300, (225, 48), False),
    "src/sprites/LHNDI0.png": (450, 300, (225, 48), False),
    "src/sprites/RHNDH0.png": (320, 200, (160, 32), False),
    "src/sprites/RHNDI0.png": (320, 200, (160, 32), False),
    "src/sprites/DSWDH0.png": (320, 200, (160, 32), False),
    "src/sprites/DSWDI0.png": (320, 200, (160, 32), False),
    "src/sprites/RFNGH0.png": (320, 200, (160, 32), False),
    "src/sprites/RFNGI0.png": (320, 200, (160, 32), False),
}
ART_SPECS = {
    "art_source/domingo_fp_4_32_0h/RHNDA0_2x_960x480.png": (960, 480),
    "art_source/domingo_fp_4_32_0i/DSHDI0_2x_900x600.png": (900, 600),
    "art_source/domingo_fp_4_32_0i/LHNDI0_2x_900x600.png": (900, 600),
    "art_source/domingo_fp_4_32_0j/RHNDH0_FLIPPED.png": (320, 200),
    "art_source/domingo_fp_4_32_0j/RHNDI0_FLIPPED.png": (320, 200),
    "art_source/domingo_fp_4_32_0j/DSWDH0_FLIPPED.png": (320, 200),
    "art_source/domingo_fp_4_32_0j/DSWDI0_FLIPPED.png": (320, 200),
    "art_source/domingo_fp_4_32_0j/RFNGH0_FLIPPED.png": (320, 200),
    "art_source/domingo_fp_4_32_0j/RFNGI0_FLIPPED.png": (320, 200),
    "art_source/domingo_fp_4_32_0n/RFNGA0_THUMB_MASTER_2x_640x400.png": (640, 400),
    "art_source/domingo_fp_4_32_0n/RFNGB0_THUMB_MASTER_2x_640x400.png": (640, 400),
}
MIRRORED_RUNTIME = {
    "sprites/RHNDH0.png",
    "sprites/RHNDI0.png",
    "sprites/DSWDH0.png",
    "sprites/DSWDI0.png",
    "sprites/RFNGH0.png",
    "sprites/RFNGI0.png",
}
RUNTIME_FILES = {
    PLAYABLE_WEAPONS,
    *(relative.removeprefix("src/") for relative in SPRITE_SPECS),
}
PROJECT_FILES = {
    "APLICAR_4_32_0o.txt",
    "PRUEBAS_4_32_0o.txt",
    "docs/DOMINGO_FP_4_32_0k_TRAYECTORIA.md",
    "docs/DOMINGO_FP_4_32_0l_CAPAS.md",
    "docs/DOMINGO_FP_4_32_0m_CORRECCION.md",
    "docs/DOMINGO_FP_4_32_0n_RIG.md",
    "docs/DOMINGO_FP_4_32_0o_PIVOTES.md",
    "docs/DOMINGO_FP_4_32_0o_SHA256.txt",
    "docs/FIRST_PERSON.md",
    "docs/IMPLEMENTATION_STATUS.md",
    "docs/ROADMAP.md",
    "tools/audit_4_32_0o.py",
    "tools/build_source_patch_4_32_0o.py",
    "tools/inject_png_grab_4_32_0o.mjs",
    "art_source/domingo_fp_4_32_0j/IMAGEGEN_PROMPTS.txt",
    "art_source/domingo_fp_4_32_0n/IMAGEGEN_PROMPTS.txt",
    *ART_SPECS,
}
FIXED_ZIP_TIME = (2026, 9, 7, 9, 0, 0)


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
    path = project / "docs/DOMINGO_FP_4_32_0o_SHA256.txt"
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


def check_block_mirrors(candidate: Path, baseline: Path) -> None:
    """Prove that every Block hand sublayer is an exact horizontal mirror."""
    for relative in sorted(MIRRORED_RUNTIME):
        old_meta, old_pixels = decode_png(
            (baseline / relative).read_bytes(), f"baseline/{relative}"
        )
        new_meta, new_pixels = decode_png(
            (candidate / relative).read_bytes(), f"candidate/{relative}"
        )
        require(old_meta == new_meta, f"metadata changed while mirroring {relative}")
        width, height = old_meta[0], old_meta[1]
        stride = width * 4
        expected = bytearray()
        for y in range(height):
            row = old_pixels[y * stride:(y + 1) * stride]
            for x in range(width - 1, -1, -1):
                expected.extend(row[x * 4:x * 4 + 4])
        require(new_pixels == bytes(expected), f"non-mirror pixel edit in {relative}")


def check_thumb_extension(project: Path, candidate: Path, baseline: Path) -> None:
    """Prove the complete thumb mask is additive and keeps the authored pixels."""
    old_meta, old_pixels = decode_png(
        (baseline / "sprites/RFNGA0.png").read_bytes(), "baseline/RFNGA0"
    )
    new_meta, new_pixels = decode_png(
        (candidate / "sprites/RFNGA0.png").read_bytes(), "candidate/RFNGA0"
    )
    frame_b_meta, frame_b_pixels = decode_png(
        (candidate / "sprites/RFNGB0.png").read_bytes(), "candidate/RFNGB0"
    )
    hand_meta, hand_pixels = decode_png(
        (candidate / "sprites/RHNDA0.png").read_bytes(), "candidate/RHNDA0"
    )
    require(
        old_meta == new_meta == frame_b_meta == (320, 200, 8, 6, (160, 32)),
        "thumb runtime metadata changed",
    )
    require(
        hand_meta == (480, 240, 8, 6, (160, 72)),
        "unexpected source-hand metadata",
    )
    require(
        alpha_bbox(new_pixels, 320, 200) == (148, 92, 210, 151),
        "unexpected RFNGA0 thumb box",
    )
    require(
        alpha_bbox(frame_b_pixels, 320, 200) == (149, 93, 211, 152),
        "unexpected RFNGB0 thumb box",
    )

    additions: list[tuple[int, int]] = []
    clipped_edge_pixels = 0
    for y in range(200):
        for x in range(320):
            index = (y * 320 + x) * 4
            old_pixel = old_pixels[index:index + 4]
            new_pixel = new_pixels[index:index + 4]
            if old_pixel[3] != 0:
                require(new_pixel == old_pixel, f"existing RFNG pixel changed at {(x, y)}")
            if new_pixel != old_pixel:
                require(
                    old_pixel[3] == 0 and new_pixel[3] != 0,
                    f"thumb change is not a transparent-to-visible addition at {(x, y)}",
                )
                hand_index = ((y + 40) * 480 + x) * 4
                hand_pixel = hand_pixels[hand_index:hand_index + 4]
                require(
                    new_pixel[:3] == hand_pixel[:3]
                    and 0 < new_pixel[3] <= hand_pixel[3],
                    f"thumb colour/coverage does not derive from RHNDA0 at {(x, y)}",
                )
                if new_pixel[3] != hand_pixel[3]:
                    clipped_edge_pixels += 1
                additions.append((x, y))
    require(len(additions) == 443, f"expected 443 thumb pixels, got {len(additions)}")
    require(
        clipped_edge_pixels == 30,
        f"expected 30 anti-aliased boundary pixels, got {clipped_edge_pixels}",
    )
    require(
        (min(x for x, _ in additions), min(y for _, y in additions),
         max(x for x, _ in additions), max(y for _, y in additions))
        == (180, 92, 210, 129),
        "unexpected added-thumb region",
    )

    shifted_b = bytearray(len(new_pixels))
    for y in range(199):
        for x in range(319):
            source = (y * 320 + x) * 4
            target = ((y + 1) * 320 + x + 1) * 4
            shifted_b[target:target + 4] = new_pixels[source:source + 4]
    require(frame_b_pixels == bytes(shifted_b), "RFNGB0 is not RFNGA0 shifted (+1,+1)")

    master_a_meta, master_a = decode_png(
        (project / "art_source/domingo_fp_4_32_0n/"
         "RFNGA0_THUMB_MASTER_2x_640x400.png").read_bytes(),
        "thumb master A",
    )
    master_b_meta, master_b = decode_png(
        (project / "art_source/domingo_fp_4_32_0n/"
         "RFNGB0_THUMB_MASTER_2x_640x400.png").read_bytes(),
        "thumb master B",
    )
    require(
        master_a_meta == master_b_meta == (640, 400, 8, 6, None),
        "thumb-master metadata changed",
    )
    require(
        alpha_bbox(master_a, 640, 400) == (300, 180, 432, 301),
        "unexpected A master thumb box",
    )
    require(
        alpha_bbox(master_b, 640, 400) == (302, 182, 434, 303),
        "unexpected B master thumb box",
    )
    shifted_master_b = bytearray(len(master_a))
    for y in range(398):
        for x in range(638):
            source = (y * 640 + x) * 4
            target = ((y + 2) * 640 + x + 2) * 4
            shifted_master_b[target:target + 4] = master_a[source:source + 4]
    require(
        master_b == bytes(shifted_master_b),
        "B thumb master is not A shifted (+2,+2)",
    )


def check_delta_from_n(candidate: Path, baseline_n_root: Path) -> None:
    """Prove 4.32.0o changes only the two erroneous pivot values from 0n."""
    baseline_n = (
        baseline_n_root / "src"
        if (baseline_n_root / "src").is_dir()
        else baseline_n_root
    )
    require(baseline_n.is_dir(), f"missing 4.32.0n baseline: {baseline_n}")
    require(file_set(candidate) == file_set(baseline_n), "0n source file set changed")
    changed = {
        relative
        for relative in file_set(candidate)
        if (candidate / relative).read_bytes() != (baseline_n / relative).read_bytes()
    }
    require(changed == {PLAYABLE_WEAPONS}, f"unexpected delta from 0n: {sorted(changed)}")

    old_text = (baseline_n / PLAYABLE_WEAPONS).read_text("utf-8")
    new_text = (candidate / PLAYABLE_WEAPONS).read_text("utf-8")
    old_start, old_end = class_span(old_text, "CaelumSwordSelectorWeapon")
    new_start, new_end = class_span(new_text, "CaelumSwordSelectorWeapon")
    require(
        old_text[:old_start] + old_text[old_end:]
        == new_text[:new_start] + new_text[new_end:],
        "4.32.0o changed source outside the sword selector",
    )
    old_sword = re.sub(
        r"\s+", " ", strip_comments_and_strings(old_text[old_start:old_end])
    ).strip()
    new_sword = re.sub(
        r"\s+", " ", strip_comments_and_strings(new_text[new_start:new_end])
    ).strip()
    normalized = new_sword.replace(
        "A_OverlayPivot(25, 0.2091403904, 0.2550892857);",
        "A_OverlayPivot(25, 0.325, 0.725);",
    ).replace(
        "A_OverlayPivot(40, 1.0895833333, 0.4095);",
        "A_OverlayPivot(40, 0.4875, 0.67);",
    )
    require(
        normalized == old_sword,
        "4.32.0o contains a semantic code change beyond the two pivots",
    )


def check_sources(project: Path, baseline_root: Path, baseline_n_root: Path) -> None:
    candidate = project / "src"
    baseline = baseline_root / "src" if (baseline_root / "src").is_dir() else baseline_root
    require(baseline.is_dir(), f"missing 4.32.0f baseline: {baseline}")
    check_delta_from_n(candidate, baseline_n_root)
    require(file_set(candidate) == file_set(baseline), "source file set changed")
    changed = {
        relative
        for relative in file_set(candidate)
        if (candidate / relative).read_bytes() != (baseline / relative).read_bytes()
    }
    require(changed == RUNTIME_FILES, f"unexpected runtime delta: {sorted(changed ^ RUNTIME_FILES)}")
    check_block_mirrors(candidate, baseline)
    check_thumb_extension(project, candidate, baseline)

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
        "invoker.CaelumSwordViewBlocking ? 160.0 : 82.0",
        "invoker.CaelumSwordViewBlocking ? 100.0 : 45.0",
        "invoker.CaelumSwordViewBlocking ? 160.0 : 282.0",
        "invoker.CaelumSwordViewBlocking ? 0.0 : 32.0",
        "invoker.CaelumSwordViewBlocking ? 160.0 : 260.0",
        "double swordY = 0.0;",
        "action void A_CaelumSwordApplyRigRotation()",
        "A_OverlayFlags(25, PSPF_PIVOTPERCENT, true);",
        "A_OverlayPivot(25, 0.2091403904, 0.2550892857);",
        "A_OverlayFlags(30, PSPF_PIVOTPERCENT, true);",
        "A_OverlayPivot(30, 0.55625, 0.83);",
        "A_OverlayFlags(40, PSPF_PIVOTPERCENT, true);",
        "A_OverlayPivot(40, 1.0895833333, 0.4095);",
        "double handRotation = swordRotation - 18.0;",
        "A_OverlayRotate(25, handRotation);",
        "A_OverlayRotate(30, swordRotation);",
        "A_OverlayRotate(40, handRotation);",
        "invoker.CaelumSwordViewRotation = 21.0;",
        "invoker.CaelumSwordViewRotation = 24.0;",
        "invoker.CaelumSwordViewRotation = 31.0;",
        "invoker.CaelumSwordViewRotation = 38.0;",
        "invoker.CaelumSwordViewRotation = 43.0;",
        "invoker.CaelumSwordViewRotation = 39.0;",
        "A_OverlayOffset(25, 318.0, -4.0);",
        "A_OverlayOffset(25, 201.0, 21.0);",
        "A_OverlayOffset(25, 228.0, 25.0);",
        "A_OverlayOffset(25, 255.0, 28.0);",
        "A_OverlayOffset(25, 275.0, 31.0);",
        "A_OverlayOffset(30, 179.0, -11.0);",
        "RHND A 1 A_CaelumSwordAttackCurveStart;",
        "RHND A 1 A_CaelumSwordAttackCurveApex;",
        "RHND A 1 A_CaelumSwordAttackCurveSweep;",
        "RHND A 1 A_CaelumSwordAttackCurveNearImpact;",
        "RHND A 1 A_CaelumSwordAttackImpact;",
        "RHND A 1 A_CaelumSwordAttackReturnOne;",
        "RHND A 1 A_CaelumSwordAttackReturnTwo;",
        "RHND A 1 A_CaelumSwordAttackReturnThree;",
        "DSWD A 8;",
        "RFNG A 8;",
        "PerformWeaponFamilyPrimaryAttack",
        "PerformWeaponFamilySecondaryAction",
    )
    for token in required:
        require(token in sword, f"missing sword token: {token}")
    require(
        sword.count("A_CaelumSwordApplyRigRotation();") == 9,
        "rig rotation is not applied at rest and every attack point",
    )
    # PSPF_PIVOTPERCENT is evaluated against each visible alpha rectangle.
    pivot_points = (
        (147 + 0.2091403904 * 333 - 160,
         128 + 0.2550892857 * 112 - 72),
        (-22 + 168 + 0.55625 * 127 - 160,
         -32 + 0 + 0.83 * 179 - 32),
        (148 + 1.0895833333 * 63 - 160,
         92 + 0.4095 * 60 - 32),
    )
    require(
        all(abs(x - 56.64375) < 1e-7 and abs(y - 84.57) < 1e-7
            for x, y in pivot_points),
        "alpha-compensated layers do not resolve to (56.64375,84.57)",
    )
    require(
        "A_OverlayPivot(25, 0.325, 0.725);" not in sword
        and "A_OverlayPivot(40, 0.4875, 0.67);" not in sword,
        "the full-canvas pivots from 4.32.0n are still active",
    )
    require(
        sword.count("invoker.CaelumSwordViewBlocking ? 160.0 : 82.0") == 2,
        "shield and correct left hand do not share X=82/X=160",
    )
    require(
        sword.count("invoker.CaelumSwordViewBlocking ? 100.0 : 45.0") == 2,
        "shield and correct left hand do not share Y=45/Y=100",
    )

    # Block must keep shield/LHND and clear the lower-right main-hand assembly.
    block_start, block_end = braced_span(
        sword,
        r"\baction\s+void\s+A_CaelumSwordStartBlockView\s*\(\s*\)",
        "A_CaelumSwordStartBlockView",
    )
    block_action = sword[block_start:block_end]
    require(
        'A_Overlay(10, "CA_SwordShieldBlock");' in block_action
        and 'A_Overlay(20, "CA_SwordLeftBlock");' in block_action,
        "normal Block entry does not keep shield and correct left hand",
    )
    for layer in (25, 30, 40):
        require(
            f"A_ClearOverlays({layer}, {layer});" in block_action,
            f"normal Block entry does not clear redundant layer {layer}",
        )
    for state in (
        "CA_SwordRightBlock", "CA_SwordBladeBlock", "CA_SwordFingersBlock"
    ):
        require(
            f'A_Overlay(25, "{state}")' not in sword
            and f'A_Overlay(30, "{state}")' not in sword
            and f'A_Overlay(40, "{state}")' not in sword
            and f"{state}:" not in sword,
            f"redundant Block state remains reachable: {state}",
        )
    sync_sequence = (
        'A_Overlay(10, "CA_SwordShieldBlock");\n'
        '                    A_Overlay(20, "CA_SwordLeftBlock");\n'
        '                    A_ClearOverlays(25, 25);\n'
        '                    A_ClearOverlays(30, 30);\n'
        '                    A_ClearOverlays(40, 40);'
    )
    require(
        sync_sequence in sword,
        "equipment resynchronization does not enforce the corrected Block layers",
    )

    # The accepted hand curve is frozen; the blade is raised four units.
    hand_path = (
        (300, 15), (318, -4), (287, -1), (236, 11),
        (201, 21), (228, 25), (255, 28), (275, 31), (282, 32),
    )
    blade_path = (
        (278, -17), (296, -36), (265, -33), (214, -21),
        (179, -11), (206, -7), (233, -4), (253, -1), (260, 0),
    )
    for hand, blade in zip(hand_path, blade_path):
        require(
            blade == (hand[0] - 22, hand[1] - 32),
            "blade registration is not the constant (-22,-32)",
        )
        if hand != hand_path[-1]:
            require(
                f"A_OverlayOffset(25, {hand[0]}.0, {hand[1]}.0);" in sword
                and f"A_OverlayOffset(40, {hand[0]}.0, {hand[1]}.0);" in sword
                and f"A_OverlayOffset(30, {blade[0]}.0, {blade[1]}.0);" in sword,
                f"attack registration changed at hand point {hand}",
            )

    # Impact plus three recovery points and rest must approximate one line.
    recovery = ((201, 21), (228, 25), (255, 28), (275, 31), (282, 32))
    full_dx = recovery[-1][0] - recovery[0][0]
    full_dy = recovery[-1][1] - recovery[0][1]
    for x, y in recovery[1:-1]:
        cross = (x - recovery[0][0]) * full_dy \
            - (y - recovery[0][1]) * full_dx
        require(abs(cross) <= 30, "attack recovery is not a straight line")
    for prefix in ("DSHD", "LHND"):
        require(f"{prefix} I -1;" in sword, f"Block does not hold {prefix} I")
    for prefix in ("RHND", "DSWD", "RFNG"):
        require(
            f"{prefix} I -1;" not in sword,
            f"redundant Block layer still has a held state: {prefix}",
        )
    require(sword.count(" I -1;") == 2, "unexpected indefinite Block state")
    require(not re.search(r"(?m)^\s+(?:DSHD|LHND|RHND|DSWD|RFNG) [EFG] [0-9]", sword),
            "attack still references rotating E/F/G art")
    require("A_WeaponOffset" not in sword, "main weapon offset was changed")

    check_pngs(project)

    required_docs = {
        "docs/FIRST_PERSON.md": (
            "V4.32.0o", "X=82, Y=45", "X=282, Y=32", "X=260, Y=0",
            "443 píxeles", "(56.64375,84.57)", "1.0895833333", "0→25°",
        ),
        "docs/IMPLEMENTATION_STATUS.md": (
            "4.32.0o", "duplicated-hand", "(56.64375,84.57)", "V4.33",
        ),
        "docs/ROADMAP.md": ("V4.32.0o", "V4.33", "actual alpha bounds"),
        "docs/DOMINGO_FP_4_32_0k_TRAYECTORIA.md": (
            "(318,-4)", "(201,21)", "colineales"
        ),
        "docs/DOMINGO_FP_4_32_0l_CAPAS.md": (
            "Superada por V4.32.0m", "mano equivocada"
        ),
        "docs/DOMINGO_FP_4_32_0m_CORRECCION.md": (
            "V4.32.0n", "capa 20", "(260,4)", "(-22,-28)"
        ),
        "docs/DOMINGO_FP_4_32_0n_RIG.md": (
            "V4.32.0o", "443", "(+1,+1)", "giro_mano",
        ),
        "docs/DOMINGO_FP_4_32_0o_PIVOTES.md": (
            "dos manos", "(56.64375,84.57)", "1.0895833333", "V4.33",
        ),
        "APLICAR_4_32_0o.txt": (
            "NO contiene un PK3", "V4.32.0g–V4.32.0n", "17 archivos",
        ),
        "PRUEBAS_4_32_0o.txt": (
            "ocho cuadros", "diez ataques", "seis puntos", "V4.33",
        ),
        "art_source/domingo_fp_4_32_0j/IMAGEGEN_PROMPTS.txt": (
            "precise-object-edit", "discarded", "fixed fist/grip anchor"
        ),
        "art_source/domingo_fp_4_32_0n/IMAGEGEN_PROMPTS.txt": (
            "precise-object-edit", "background-extraction", "443 píxeles",
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
    parser.add_argument("--baseline-0n", type=Path, required=True)
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
    check_sources(
        project,
        args.baseline_0f.resolve(),
        args.baseline_0n.resolve(),
    )
    if args.package is not None:
        check_package(args.package.resolve(), project)

    print("Caelum Argenteum 4.32.0o audit: PASS")
    print(f"Runtime delta from 4.32.0f: {len(RUNTIME_FILES)} files")
    print("Idle: shield/left hand (82,45), right hand (282,32), sword (260,0)")
    print("Held Block: shield/LHND retained; redundant layers 25/30/40 cleared")
    print("Attack: accepted curve retained; blade registered at (-22,-32)")
    print("Grip: alpha-compensated pivots converge at (56.64375,84.57)")
    print("Thumb: complete additive RFNG mask; 443 original pixels; B=(+1,+1)")
    print("Sword angles: ~79-degree rest to ~104-degree impact")
    print("Right arm: 480x240 canvas reaches the panoramic edge")
    print("Gameplay and every non-sword source: byte-identical to 4.32.0f")
    print("Delta from 4.32.0n: CaelumPlayableWeapons.zs only")
    if args.package is not None:
        print(f"Package entries: {len(expected_package_entries())}")
        print(f"Package SHA-256: {sha256(args.package.resolve())}")


if __name__ == "__main__":
    main()
