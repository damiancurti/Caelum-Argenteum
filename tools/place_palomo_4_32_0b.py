#!/usr/bin/env python3
"""Place the anchored Palomo merchant in MAP01 without touching geometry."""

from __future__ import annotations

import argparse
import os
import re
import struct
import tempfile
from pathlib import Path


MARKER = "// CAELUM_PALOMO_MERCHANT_4_32_0B"
PALOMO_BLOCK = """

// CAELUM_PALOMO_MERCHANT_4_32_0B
thing
{
    x = -1536.0;
    y = 0.0;
    height = 0.0;
    angle = 180;
    type = 18036;
    id = 43201;
    arg0 = 1;
    arg1 = 0;
    arg2 = 0;
    arg3 = 0;
    arg4 = 0;
    skill1 = true;
    skill2 = true;
    skill3 = true;
    skill4 = true;
    skill5 = true;
    single = true;
    coop = true;
    dm = false;
}
"""


def read_wad(path: Path) -> tuple[bytes, list[tuple[bytes, bytes]]]:
    data = path.read_bytes()
    if len(data) < 12:
        raise ValueError("WAD header is truncated")
    magic, count, directory_offset = struct.unpack_from("<4sii", data, 0)
    if magic not in {b"PWAD", b"IWAD"}:
        raise ValueError(f"unsupported WAD magic: {magic!r}")
    if count <= 0 or directory_offset < 12:
        raise ValueError("invalid WAD directory")
    lumps: list[tuple[bytes, bytes]] = []
    for index in range(count):
        entry_offset = directory_offset + index * 16
        lump_offset, lump_size, raw_name = struct.unpack_from(
            "<ii8s", data, entry_offset
        )
        if lump_offset < 0 or lump_size < 0 or lump_offset + lump_size > len(data):
            raise ValueError(f"invalid lump bounds at directory index {index}")
        lumps.append((raw_name, data[lump_offset : lump_offset + lump_size]))
    return magic, lumps


def write_wad(path: Path, magic: bytes, lumps: list[tuple[bytes, bytes]]) -> None:
    body = bytearray(struct.pack("<4sii", magic, len(lumps), 0))
    directory: list[tuple[int, int, bytes]] = []
    for raw_name, payload in lumps:
        offset = len(body)
        body.extend(payload)
        directory.append((offset, len(payload), raw_name))
    directory_offset = len(body)
    for offset, size, raw_name in directory:
        body.extend(struct.pack("<ii8s", offset, size, raw_name))
    struct.pack_into("<i", body, 8, directory_offset)

    with tempfile.NamedTemporaryFile(
        prefix=path.name + ".", suffix=".tmp", dir=path.parent, delete=False
    ) as handle:
        temporary = Path(handle.name)
        handle.write(body)
        handle.flush()
        os.fsync(handle.fileno())
    os.replace(temporary, path)


def patch_textmap(text: str) -> str:
    if MARKER in text or re.search(r"(?m)^\s*type\s*=\s*18036\s*;", text):
        raise ValueError("MAP01 already contains Palomo")

    thing_pattern = re.compile(r"(?ms)^thing\s*\n\{.*?^\}\s*$")
    player_starts = []
    for match in thing_pattern.finditer(text):
        block = match.group(0)
        if re.search(r"(?m)^\s*type\s*=\s*1\s*;\s*$", block):
            player_starts.append(match)
    if len(player_starts) != 1:
        raise ValueError(f"expected one player-1 start, found {len(player_starts)}")

    start = player_starts[0]
    block = start.group(0)
    required = {
        "x": "-1600.0",
        "y": "0.0",
        "height": "0.0",
        "angle": "0",
    }
    for key, value in required.items():
        if not re.search(
            rf"(?m)^\s*{key}\s*=\s*{re.escape(value)}\s*;\s*$", block
        ):
            raise ValueError(f"unexpected player-start {key}; placement aborted")

    return text[: start.end()] + PALOMO_BLOCK + text[start.end() :]


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("wad", type=Path, help="MAP01 WAD to update in place")
    args = parser.parse_args()

    magic, lumps = read_wad(args.wad)
    names = [name.rstrip(b"\0") for name, _ in lumps]
    if names != [b"MAP01", b"TEXTMAP", b"ENDMAP"]:
        raise ValueError(f"unexpected MAP01 lump order: {names!r}")

    text = lumps[1][1].decode("utf-8")
    patched = patch_textmap(text).encode("utf-8")
    lumps[1] = (lumps[1][0], patched)
    write_wad(args.wad, magic, lumps)

    _, verified_lumps = read_wad(args.wad)
    verified = verified_lumps[1][1].decode("utf-8")
    if verified.count(MARKER) != 1 or verified.count("type = 18036;") != 1:
        raise RuntimeError("post-write Palomo verification failed")
    print(
        "Placed anchored Palomo at (-1536, 0), 64 MU in front of "
        "the MAP01 player start."
    )


if __name__ == "__main__":
    main()
