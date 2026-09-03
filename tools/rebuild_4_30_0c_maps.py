"""Compacta los sectores huérfanos introducidos en MAP01 4.30.0b.

La geometría, los actores y las propiedades observables permanecen intactos.
Sólo se eliminan los 17 bloques ``sector`` que no posee ningún ``sidedef`` y
se remapean de forma canónica los índices de sector de los lados restantes.
"""

from __future__ import annotations

from collections import Counter, defaultdict
from dataclasses import dataclass
from hashlib import sha256
import os
from pathlib import Path
import re
import stat
import struct
import tempfile


ROOT = Path(__file__).resolve().parents[1]
MAP01 = ROOT / "src/maps/MAP01.wad"

MAP01_BASE_COUNTS = (1419, 1983, 3544, 635, 322)
MAP01_BASE_SHA256 = (
    "ebc4c8aa654bdfc7c3ccd4eb60a8aa9bc4a745f85715189325612cf7bdec6f90"
)
MAP01_UPDATED_COUNTS = (1419, 1983, 3544, 618, 322)
MAP01_UPDATED_SHA256 = (
    "b333acc001de94d9d1342f62c92596e7e521ff007da620432e0bbdabbfabddfe"
)

EXPECTED_ORPHAN_SECTORS = (
    30,
    31,
    33,
    34,
    75,
    82,
    84,
    94,
    96,
    244,
    245,
    268,
    271,
    322,
    323,
    346,
    349,
)

BLOCK_PATTERN = re.compile(
    r"(?ms)^([A-Za-z_][A-Za-z0-9_]*)\s*\{\s*.*?^\}[ \t]*$"
)
PROPERTY_PATTERN = re.compile(
    r"(?m)^\s*([A-Za-z_][A-Za-z0-9_]*)\s*=\s*(.*?)\s*;\s*$"
)
MAP_KINDS = ("vertex", "linedef", "sidedef", "sector", "thing")


@dataclass(frozen=True)
class MapBlock:
    kind: str
    index: int
    start: int
    end: int
    raw: str
    properties: dict[str, str]


def read_wad(path: Path) -> tuple[bytes, list[tuple[bytes, bytes]]]:
    data = path.read_bytes()
    if len(data) < 12:
        raise ValueError(f"WAD truncado: {path}")

    signature, lump_count, directory_offset = struct.unpack_from("<4sII", data)
    if signature not in (b"IWAD", b"PWAD"):
        raise ValueError(f"Firma WAD inválida: {signature!r}")
    if directory_offset + lump_count * 16 > len(data):
        raise ValueError("El directorio WAD excede el archivo")

    lumps: list[tuple[bytes, bytes]] = []
    for index in range(lump_count):
        position, size, raw_name = struct.unpack_from(
            "<II8s", data, directory_offset + index * 16
        )
        if position + size > len(data):
            raise ValueError(f"Lump {index} fuera del WAD")
        name = raw_name.rstrip(b"\0")
        lumps.append((name, data[position : position + size]))
    return signature, lumps


def render_wad(signature: bytes, lumps: list[tuple[bytes, bytes]]) -> bytes:
    output = bytearray(b"\0" * 12)
    directory: list[tuple[int, int, bytes]] = []

    for name, contents in lumps:
        if len(name) > 8:
            raise ValueError(f"Nombre de lump demasiado largo: {name!r}")
        position = len(output)
        output.extend(contents)
        directory.append((position, len(contents), name))

    directory_offset = len(output)
    for position, size, name in directory:
        output.extend(struct.pack("<II8s", position, size, name.ljust(8, b"\0")))

    struct.pack_into("<4sII", output, 0, signature, len(lumps), directory_offset)
    return bytes(output)


def write_atomic(path: Path, contents: bytes) -> None:
    # El reemplazo atómico evita dejar un WAD parcial si la escritura falla.
    mode = stat.S_IMODE(path.stat().st_mode)
    descriptor, temporary_name = tempfile.mkstemp(
        prefix=f".{path.name}.", suffix=".tmp", dir=path.parent
    )
    temporary_path = Path(temporary_name)
    try:
        with os.fdopen(descriptor, "wb") as stream:
            stream.write(contents)
            stream.flush()
            os.fsync(stream.fileno())
        os.chmod(temporary_path, mode)
        os.replace(temporary_path, path)
    finally:
        if temporary_path.exists():
            temporary_path.unlink()


def parse_textmap(text: str) -> tuple[list[MapBlock], dict[str, list[MapBlock]]]:
    indexes: Counter[str] = Counter()
    blocks: list[MapBlock] = []
    by_kind: dict[str, list[MapBlock]] = defaultdict(list)

    for match in BLOCK_PATTERN.finditer(text):
        kind = match.group(1)
        if kind not in MAP_KINDS:
            continue
        raw = match.group(0)
        block = MapBlock(
            kind=kind,
            index=indexes[kind],
            start=match.start(),
            end=match.end(),
            raw=raw,
            properties=dict(PROPERTY_PATTERN.findall(raw)),
        )
        indexes[kind] += 1
        blocks.append(block)
        by_kind[kind].append(block)

    missing = [kind for kind in MAP_KINDS if kind not in by_kind]
    if missing:
        raise ValueError(f"TEXTMAP sin bloques requeridos: {missing}")
    return blocks, by_kind


def integer(block: MapBlock, key: str) -> int:
    try:
        return int(block.properties[key])
    except (KeyError, ValueError) as error:
        raise ValueError(
            f"{block.kind} {block.index}: propiedad entera inválida {key}"
        ) from error


def map_counts(by_kind: dict[str, list[MapBlock]]) -> tuple[int, ...]:
    return tuple(len(by_kind[kind]) for kind in MAP_KINDS)


def sector_references(by_kind: dict[str, list[MapBlock]]) -> Counter[int]:
    references: Counter[int] = Counter()
    sector_count = len(by_kind["sector"])
    for side in by_kind["sidedef"]:
        sector_index = integer(side, "sector")
        if not 0 <= sector_index < sector_count:
            raise ValueError(
                f"sidedef {side.index}: sector inexistente {sector_index}"
            )
        references[sector_index] += 1
    return references


def orphan_sectors(by_kind: dict[str, list[MapBlock]]) -> tuple[int, ...]:
    references = sector_references(by_kind)
    return tuple(
        index
        for index in range(len(by_kind["sector"]))
        if references[index] == 0
    )


def validate_references(
    by_kind: dict[str, list[MapBlock]],
    expected_counts: tuple[int, ...],
    expected_orphans: tuple[int, ...],
) -> None:
    counts = map_counts(by_kind)
    if counts != expected_counts:
        raise ValueError(f"Estructura MAP01 inesperada: {counts}")

    vertex_count = len(by_kind["vertex"])
    side_count = len(by_kind["sidedef"])
    used_sides: Counter[int] = Counter()
    coordinate_segments: dict[
        tuple[tuple[float, float], tuple[float, float]], list[int]
    ] = defaultdict(list)
    vertices = [
        (float(vertex.properties["x"]), float(vertex.properties["y"]))
        for vertex in by_kind["vertex"]
    ]

    for line in by_kind["linedef"]:
        v1 = integer(line, "v1")
        v2 = integer(line, "v2")
        if not 0 <= v1 < vertex_count or not 0 <= v2 < vertex_count:
            raise ValueError(f"linedef {line.index}: vértice inexistente")
        if v1 == v2 or vertices[v1] == vertices[v2]:
            raise ValueError(f"linedef {line.index}: longitud cero")

        segment = tuple(sorted((vertices[v1], vertices[v2])))
        coordinate_segments[segment].append(line.index)

        if "sidefront" not in line.properties:
            raise ValueError(f"linedef {line.index}: no tiene lado frontal")
        for key in ("sidefront", "sideback"):
            if key not in line.properties:
                continue
            side_index = integer(line, key)
            if not 0 <= side_index < side_count:
                raise ValueError(
                    f"linedef {line.index}: {key} inexistente {side_index}"
                )
            used_sides[side_index] += 1

        two_sided = line.properties.get("twosided") == "true"
        if two_sided != ("sideback" in line.properties):
            raise ValueError(
                f"linedef {line.index}: desacuerdo entre sideback y twosided"
            )

    bad_side_uses = {
        index: used_sides[index]
        for index in range(side_count)
        if used_sides[index] != 1
    }
    if bad_side_uses:
        raise ValueError(f"Sidedefs huérfanos o compartidos: {bad_side_uses}")

    duplicates = {
        segment: indexes
        for segment, indexes in coordinate_segments.items()
        if len(indexes) != 1
    }
    if duplicates:
        raise ValueError(f"Linedefs coincidentes: {duplicates}")

    actual_orphans = orphan_sectors(by_kind)
    if actual_orphans != expected_orphans:
        raise ValueError(
            "Sectores huérfanos inesperados: "
            f"esperados={expected_orphans}, actuales={actual_orphans}"
        )

    # GZDoom admite este rango para vértices y Things del mapa UDMF actual.
    for kind in ("vertex", "thing"):
        for block in by_kind[kind]:
            for key in ("x", "y"):
                value = float(block.properties[key])
                if not -32768.0 <= value <= 32768.0:
                    raise ValueError(
                        f"{kind} {block.index}: {key} fuera de rango ({value:g})"
                    )


def replace_sector_reference(raw: str, sector_index: int) -> str:
    pattern = re.compile(r"(?m)^(\s*sector\s*=\s*)-?\d+(\s*;\s*)$")
    replacement = rf"\g<1>{sector_index}\g<2>"
    updated, replacements = pattern.subn(replacement, raw, count=1)
    if replacements != 1:
        raise ValueError("sidedef sin una referencia de sector reemplazable")
    return updated


def compact_orphan_sectors(
    text: str,
    blocks: list[MapBlock],
    by_kind: dict[str, list[MapBlock]],
) -> tuple[str, dict[int, int]]:
    orphans = set(orphan_sectors(by_kind))
    sector_remap: dict[int, int] = {}
    next_sector = 0
    for sector in by_kind["sector"]:
        if sector.index in orphans:
            continue
        sector_remap[sector.index] = next_sector
        next_sector += 1

    output: list[str] = []
    cursor = 0
    for block in blocks:
        output.append(text[cursor : block.start])
        if block.kind == "sector" and block.index in orphans:
            replacement = ""
        elif block.kind == "sidedef":
            old_sector = integer(block, "sector")
            replacement = replace_sector_reference(
                block.raw, sector_remap[old_sector]
            )
        else:
            replacement = block.raw
        output.append(replacement)
        cursor = block.end
    output.append(text[cursor:])
    return "".join(output), sector_remap


def validate_preservation(
    before: dict[str, list[MapBlock]],
    after: dict[str, list[MapBlock]],
    sector_remap: dict[int, int],
) -> None:
    # Nada fuera de la tabla de sectores y sus índices puede cambiar.
    for kind in ("vertex", "linedef", "thing"):
        if [block.raw for block in before[kind]] != [
            block.raw for block in after[kind]
        ]:
            raise ValueError(f"La reparación alteró bloques {kind}")

    expected_sectors = [
        sector.raw
        for sector in before["sector"]
        if sector.index in sector_remap
    ]
    if expected_sectors != [sector.raw for sector in after["sector"]]:
        raise ValueError("La reparación alteró sectores conservados")

    if len(before["sidedef"]) != len(after["sidedef"]):
        raise ValueError("La cantidad de sidedefs cambió")
    for old_side, new_side in zip(before["sidedef"], after["sidedef"]):
        expected = dict(old_side.properties)
        expected["sector"] = str(sector_remap[integer(old_side, "sector")])
        if expected != new_side.properties:
            raise ValueError(f"sidedef {old_side.index}: cambió otra propiedad")


def repair_map01(path: Path = MAP01) -> bool:
    original_digest = sha256(path.read_bytes()).hexdigest()
    signature, lumps = read_wad(path)
    text_indexes = [
        index for index, (name, _) in enumerate(lumps) if name == b"TEXTMAP"
    ]
    if len(text_indexes) != 1:
        raise ValueError(f"MAP01 debe contener un TEXTMAP: {text_indexes}")
    text_index = text_indexes[0]
    text = lumps[text_index][1].decode("utf-8")
    blocks, by_kind = parse_textmap(text)

    if original_digest == MAP01_UPDATED_SHA256:
        validate_references(by_kind, MAP01_UPDATED_COUNTS, ())
        return False
    if original_digest != MAP01_BASE_SHA256:
        raise ValueError(
            "MAP01 no coincide con 4.30.0b ni con 4.30.0c: "
            f"{original_digest}"
        )

    validate_references(by_kind, MAP01_BASE_COUNTS, EXPECTED_ORPHAN_SECTORS)
    repaired_text, sector_remap = compact_orphan_sectors(text, blocks, by_kind)
    repaired_blocks, repaired_by_kind = parse_textmap(repaired_text)
    validate_references(repaired_by_kind, MAP01_UPDATED_COUNTS, ())
    validate_preservation(by_kind, repaired_by_kind, sector_remap)

    lumps[text_index] = (b"TEXTMAP", repaired_text.encode("utf-8"))
    repaired_wad = render_wad(signature, lumps)
    repaired_digest = sha256(repaired_wad).hexdigest()
    if repaired_digest != MAP01_UPDATED_SHA256:
        raise ValueError(f"Hash MAP01 4.30.0c inesperado: {repaired_digest}")

    write_atomic(path, repaired_wad)
    return True


def main() -> None:
    changed = repair_map01()
    digest = sha256(MAP01.read_bytes()).hexdigest()
    if changed:
        print("MAP01: 17 sectores huérfanos eliminados y referencias remapeadas")
    else:
        print("MAP01: topología 4.30.0c ya presente")
    print(f"MAP01 SHA-256: {digest}")


if __name__ == "__main__":
    main()
