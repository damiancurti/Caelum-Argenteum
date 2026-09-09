#!/usr/bin/env python3
"""Apply the single-sidedef MAP01 fix to the exact V4.33.0d source map."""
from __future__ import annotations

import argparse
import hashlib
import re
import struct
from pathlib import Path

BASE_SHA256 = "a2cb4f74391bd71e1256ff460bb407e0fc2afafa64a4c685f2c63fece07f4cb9"
TARGET_SIDE = 1637


def patch_map(source: bytes) -> bytes:
    # El hash impide aplicar índices de 0d sobre otro mapa o una edición local.
    if hashlib.sha256(source).hexdigest() != BASE_SHA256:
        raise ValueError("Se requiere el MAP01.wad original de V4.33.0d.")

    magic, count, directory = struct.unpack_from("<4sii", source)
    entries = [struct.unpack_from("<ii8s", source, directory + i * 16)
               for i in range(count)]
    names = [entry[2].rstrip(b"\0") for entry in entries]
    if magic != b"PWAD" or names != [b"MAP01", b"TEXTMAP", b"ENDMAP"]:
        raise ValueError("Estructura WAD inesperada.")

    start, size, _ = entries[1]
    textmap = source[start:start + size]
    sides = list(re.finditer(rb"(?ms)^sidedef\s*\{.*?^\}", textmap))
    target = sides[TARGET_SIDE]
    body = target.group()
    if b"    sector = 655;" not in body:
        raise ValueError("La cara no pertenece al sector del ascensor.")
    old = b'    texturebottom = "-";'
    new = b'    texturebottom = "CACVROCK";'
    if body.count(old) != 1:
        raise ValueError("La cara interior no coincide con la base 0d.")

    # El borde sur ya existía antes del ascensor, con ambos suelos a Z=0.
    # Al descender el suelo de la cabina aparece esta superficie inferior.
    # Mantiene la entrada superior abierta y todos los especiales originales.
    textmap = textmap[:target.start()] + body.replace(old, new) + textmap[target.end():]

    result = bytearray(b"\0" * 12)
    rebuilt_entries = []
    for index, (start, size, name) in enumerate(entries):
        payload = textmap if index == 1 else source[start:start + size]
        rebuilt_entries.append((len(result), len(payload), name))
        result.extend(payload)
    directory = len(result)
    for entry in rebuilt_entries:
        result.extend(struct.pack("<ii8s", *entry))
    struct.pack_into("<4sii", result, 0, magic, count, directory)
    return bytes(result)


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--input", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    result = patch_map(args.input.read_bytes())
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_bytes(result)
    print("MAP01 V4.33.0e:", args.output)
    print("SHA256:", hashlib.sha256(result).hexdigest())
    print("Cambio: sidedef 1637, texturebottom: '-' -> 'CACVROCK'.")


if __name__ == "__main__":
    main()
