#!/usr/bin/env python3
"""Genera las vetas minerales compactas de Caelum Argenteum."""

from __future__ import annotations

import argparse
import math
import random
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import List, Tuple

from PIL import Image

sys.path.insert(0, str(Path(__file__).resolve().parent))

from generate_environment_models import (
    MAP_UNITS_PER_METER,
    Mesh,
    add_irregular_rock,
    scalar,
)


MODEL_DIRECTORY = "models/caelum/world/resources"
HOST_MATERIAL = "models/caelum/world/environment/rock_granite.png"
MODEL_BEGIN = "// --- BEGIN GENERATED CAELUM MINERAL VEIN MODELS ---"
MODEL_END = "// --- END GENERATED CAELUM MINERAL VEIN MODELS ---"
MAPINFO_BEGIN = "    // --- BEGIN GENERATED CAELUM MINERAL VEIN DOOMEDNUMS ---"
MAPINFO_END = "    // --- END GENERATED CAELUM MINERAL VEIN DOOMEDNUMS ---"
ENVIRONMENT_MAPINFO_END = "    // --- END GENERATED CAELUM ENVIRONMENT DOOMEDNUMS ---"

# Estas tres combinaciones mostraron una banda prismática fuera de la roca.
# Conservan sus nueve inclusiones irregulares y omiten sólo las bandas largas.
VEINS_WITHOUT_LONG_BANDS = {
    ("coal", "3"),
    ("silver", ""),
    ("gold", "2"),
}


@dataclass(frozen=True)
class VeinSpec:
    stem: str
    actor_suffix: str
    frame: str
    material_constant: str
    language_key: str
    hardness: float
    abundance: float
    primary_color: Tuple[int, int, int]
    highlight_color: Tuple[int, int, int]
    crystal: bool = False


@dataclass(frozen=True)
class VeinVariant:
    suffix: str
    scale: float
    seed_offset: int


VEINS: Tuple[VeinSpec, ...] = (
    VeinSpec("iron", "Iron", "A", "MATERIAL_RAW_IRON", "CA_VEIN_IRON", 5.5, 0.60, (104, 92, 84), (181, 154, 127)),
    VeinSpec("coal", "Coal", "B", "MATERIAL_COAL", "CA_VEIN_COAL", 2.5, 0.60, (25, 27, 29), (72, 76, 79)),
    VeinSpec("copper", "Copper", "C", "MATERIAL_RAW_COPPER", "CA_VEIN_COPPER", 3.5, 0.50, (126, 68, 41), (75, 157, 128)),
    VeinSpec("tin", "Tin", "D", "MATERIAL_RAW_TIN", "CA_VEIN_TIN", 6.5, 0.40, (115, 119, 123), (196, 205, 208)),
    VeinSpec("silver", "Silver", "E", "MATERIAL_RAW_SILVER", "CA_VEIN_SILVER", 3.0, 0.20, (125, 137, 150), (222, 229, 236)),
    VeinSpec("gold", "Gold", "F", "MATERIAL_RAW_GOLD", "CA_VEIN_GOLD", 3.0, 0.10, (139, 94, 23), (240, 193, 61)),
    VeinSpec("opal", "Opal", "G", "MATERIAL_RAW_OPAL", "CA_VEIN_OPAL", 6.0, 0.075, (112, 151, 153), (222, 188, 229), True),
    VeinSpec("topaz", "Topaz", "H", "MATERIAL_RAW_TOPAZ", "CA_VEIN_TOPAZ", 8.0, 0.05, (150, 105, 34), (241, 192, 83), True),
    VeinSpec("sapphire", "Sapphire", "I", "MATERIAL_RAW_SAPPHIRE", "CA_VEIN_SAPPHIRE", 9.0, 0.04, (37, 65, 135), (93, 151, 232), True),
    VeinSpec("ruby", "Ruby", "J", "MATERIAL_RAW_RUBY", "CA_VEIN_RUBY", 9.0, 0.03, (123, 27, 43), (231, 70, 91), True),
    VeinSpec("emerald", "Emerald", "K", "MATERIAL_RAW_EMERALD", "CA_VEIN_EMERALD", 7.5, 0.02, (27, 103, 65), (75, 210, 129), True),
)


VARIANTS: Tuple[VeinVariant, ...] = (
    VeinVariant("", 1.0, 0),
    VeinVariant("2", 0.75, 1000),
    VeinVariant("3", 1.25, 2000),
)


def cylinder_mass_kg(radius_mu: float, height_mu: float) -> int:
    radius_m = radius_mu / MAP_UNITS_PER_METER
    height_m = height_mu / MAP_UNITS_PER_METER
    return max(1, round(math.pi * radius_m * radius_m * height_m * 2700.0))


def vein_records() -> List[dict[str, object]]:
    records: List[dict[str, object]] = []
    for spec in VEINS:
        base_radius = 44.0 if spec.crystal else 46.0
        base_height = 68.0 if spec.crystal else 56.0
        base_actor = f"CaelumVein{spec.actor_suffix}"
        for variant in VARIANTS:
            radius = base_radius * variant.scale
            height = base_height * variant.scale
            records.append({
                "actor": f"{base_actor}{variant.suffix}",
                "base_actor": base_actor,
                "model": f"ca_vein_{spec.stem}{variant.suffix}.obj",
                "texture": f"ca_vein_{spec.stem}.png",
                "frame": spec.frame,
                "scale": variant.scale,
                "radius": radius,
                "height": height,
                "mass": cylinder_mass_kg(radius, height),
                "material_constant": spec.material_constant,
                "language_key": spec.language_key,
                "hardness": spec.hardness,
                "abundance": spec.abundance,
                "is_base": variant.suffix == "",
                "seed": 500000 + VEINS.index(spec) * 10000 + variant.seed_offset,
                "crystal": spec.crystal,
            })
    return records


def make_ore_texture(path: Path, spec: VeinSpec) -> None:
    rng = random.Random(510000 + VEINS.index(spec))
    size = 256
    half = 128
    tile = Image.new("RGB", (half, half))
    pixels = tile.load()
    for y in range(half):
        for x in range(half):
            wave = 0.5 + 0.5 * math.sin(x * 0.13 + y * 0.07)
            grain = rng.uniform(-0.15, 0.15)
            blend = max(0.0, min(1.0, 0.22 + wave * 0.33 + grain))
            pixels[x, y] = tuple(
                max(0, min(255, round(a + (b - a) * blend)))
                for a, b in zip(spec.primary_color, spec.highlight_color)
            )
    image = Image.new("RGB", (size, size))
    image.paste(tile, (0, 0))
    image.paste(tile.transpose(Image.Transpose.FLIP_LEFT_RIGHT), (half, 0))
    lower = tile.transpose(Image.Transpose.FLIP_TOP_BOTTOM)
    image.paste(lower, (0, half))
    image.paste(lower.transpose(Image.Transpose.FLIP_LEFT_RIGHT), (half, half))
    image.save(path, optimize=True)


def resource_material(spec: VeinSpec) -> str:
    return f"{MODEL_DIRECTORY}/ca_vein_{spec.stem}.png"


def build_vein(spec: VeinSpec, variant: VeinVariant, output: Path) -> Tuple[int, int]:
    seed = 500000 + VEINS.index(spec) * 10000 + variant.seed_offset
    rng = random.Random(seed)
    mesh = Mesh(f"ca_vein_{spec.stem}{variant.suffix}")
    add_irregular_rock(
        mesh,
        HOST_MATERIAL,
        (0.0, 0.0, 0.0),
        (88.0, 47.0 if spec.crystal else 52.0, 76.0),
        seed,
        10,
    )
    ore = resource_material(spec)
    if spec.crystal:
        for index in range(7):
            angle = math.tau * index / 7.0 + rng.uniform(-0.22, 0.22)
            distance = rng.uniform(8.0, 29.0)
            x = math.cos(angle) * distance
            z = math.sin(angle) * distance
            start_y = rng.uniform(23.0, 34.0)
            crystal_height = rng.uniform(20.0, 37.0)
            lean = rng.uniform(-5.0, 5.0)
            radius = rng.uniform(3.5, 7.0)
            mesh.add_frustum(
                ore,
                (x, start_y, z),
                (x + lean, start_y + crystal_height, z + lean * 0.35),
                radius,
                0.45,
                6,
                True,
                True,
                phase=index * 0.17,
            )
    else:
        for index in range(9):
            angle = math.tau * index / 9.0 + rng.uniform(-0.18, 0.18)
            distance = rng.uniform(27.0, 42.0)
            center = (
                math.cos(angle) * distance,
                rng.uniform(12.0, 39.0),
                math.sin(angle) * distance * 0.80,
            )
            mesh.add_ellipsoid(
                ore,
                center,
                (rng.uniform(5.0, 10.0), rng.uniform(3.0, 7.0), rng.uniform(5.0, 10.0)),
                seed + index + 100,
                rings=3,
                segments=7,
                irregularity=0.18,
            )
        if (spec.stem, variant.suffix) not in VEINS_WITHOUT_LONG_BANDS:
            for index in range(3):
                start = (
                    rng.uniform(-34.0, -12.0),
                    rng.uniform(25.0, 40.0),
                    rng.uniform(-22.0, 22.0),
                )
                end = (
                    rng.uniform(13.0, 34.0),
                    start[1] + rng.uniform(-7.0, 8.0),
                    start[2] + rng.uniform(-11.0, 11.0),
                )
                mesh.add_frustum(ore, start, end, 2.8, 1.4, 6, True, True)
    mesh.write(output)
    return len(mesh.vertices), len(mesh.faces)


def write_actor_definitions(runtime_root: Path) -> None:
    lines = [
        "// Vetas 3D renovables del catálogo mineral compacto.",
        "class CaelumMineralVeinEnvironmentProp : CaelumRockEnvironmentProp",
        "{",
        "    override bool IsNaturalResource() { return true; }",
        "    override int GetRequiredHarvestDamageType()",
        "    {",
        "        return CaelumConstants.CATALOGUE_DAMAGE_PIERCING;",
        "    }",
        "}",
        "",
    ]
    records = vein_records()
    for spec in VEINS:
        base_actor = f"CaelumVein{spec.actor_suffix}"
        group = [record for record in records if record["base_actor"] == base_actor]
        base = next(record for record in group if record["is_base"])
        lines.extend([
            f"class {base_actor} : CaelumMineralVeinEnvironmentProp",
            "{",
            "    override int GetResourceMaterialType()",
            "    {",
            f"        return CaelumConstants.{base['material_constant']};",
            "    }",
            f"    override double GetResourceHardness() {{ return {scalar(float(base['hardness']))}; }}",
            f"    override double GetResourceAbundance() {{ return {scalar(float(base['abundance']))}; }}",
            "",
            "    Default",
            "    {",
            f"        Tag \"${base['language_key']}\";",
            f"        Radius {scalar(float(base['radius']))};",
            f"        Height {scalar(float(base['height']))};",
            f"        Mass {int(base['mass'])};",
            "    }",
            "    States",
            "    {",
            f"        Spawn: CAVE {base['frame']} -1; Stop;",
            "    }",
            "}",
            "",
        ])
        for record in group:
            if record["is_base"]:
                continue
            lines.extend([
                f"class {record['actor']} : {base_actor}",
                "{",
                "    Default",
                "    {",
                f"        Radius {scalar(float(record['radius']))};",
                f"        Height {scalar(float(record['height']))};",
                f"        Mass {int(record['mass'])};",
                "    }",
                "}",
                "",
            ])
    output = runtime_root / "caelum/world/CaelumMineralVeins.zs"
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text("\n".join(lines), encoding="utf-8")


def replace_or_append_block(path: Path, begin: str, end: str, block: str) -> None:
    text = path.read_text(encoding="utf-8")
    if begin in text:
        prefix, rest = text.split(begin, 1)
        _, suffix = rest.split(end, 1)
        result = prefix.rstrip() + "\n\n" + block + suffix
    else:
        result = text.rstrip() + "\n\n" + block + "\n"
    path.write_text(result, encoding="utf-8")


def write_model_definitions(runtime_root: Path) -> None:
    lines = [MODEL_BEGIN, "// Once recursos, cada uno con tres afloramientos originales."]
    for record in vein_records():
        scale = scalar(float(record["scale"]))
        lines.extend([
            f"Model {record['actor']}",
            "{",
            f"    Path \"{MODEL_DIRECTORY}\"",
            f"    Model 0 \"{record['model']}\"",
            f"    Scale {scale} {scale} {scale}",
            "    CorrectPixelStretch",
            "    DontCullBackFaces",
            f"    FrameIndex CAVE {record['frame']} 0 0",
            "}",
            "",
        ])
    lines.append(MODEL_END)
    replace_or_append_block(
        runtime_root / "MODELDEF", MODEL_BEGIN, MODEL_END, "\n".join(lines)
    )


def write_editor_numbers(runtime_root: Path) -> None:
    path = runtime_root / "MAPINFO"
    text = path.read_text(encoding="utf-8")
    lines = [
        MAPINFO_BEGIN,
        "    // Vetas convocables y listas para regiones mineras futuras.",
    ]
    for index, record in enumerate(vein_records()):
        lines.append(f"    {18500 + index} = {record['actor']}")
    lines.append(MAPINFO_END)
    block = "\n".join(lines)
    if MAPINFO_BEGIN in text:
        prefix, rest = text.split(MAPINFO_BEGIN, 1)
        _, suffix = rest.split(MAPINFO_END, 1)
        result = prefix.rstrip() + "\n" + block + suffix
    else:
        if ENVIRONMENT_MAPINFO_END not in text:
            raise ValueError("MAPINFO no contiene la sección ambiental esperada")
        result = text.replace(
            ENVIRONMENT_MAPINFO_END,
            ENVIRONMENT_MAPINFO_END + "\n" + block,
            1,
        )
    path.write_text(result, encoding="utf-8")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--runtime-root", type=Path, default=Path("src"))
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    model_dir = args.runtime_root / MODEL_DIRECTORY
    sprite_dir = args.runtime_root / "sprites"
    model_dir.mkdir(parents=True, exist_ok=True)
    sprite_dir.mkdir(parents=True, exist_ok=True)

    for old_model in model_dir.glob("ca_vein_*.obj"):
        old_model.unlink()
    for spec in VEINS:
        make_ore_texture(model_dir / f"ca_vein_{spec.stem}.png", spec)
        for variant in VARIANTS:
            stem = f"ca_vein_{spec.stem}{variant.suffix}"
            vertices, faces = build_vein(spec, variant, model_dir / f"{stem}.obj")
            print(f"{stem}: {vertices} vertices, {faces} faces")
        Image.new("RGBA", (1, 1), (0, 0, 0, 0)).save(
            sprite_dir / f"CAVE{spec.frame}0.png", optimize=True
        )

    write_actor_definitions(args.runtime_root)
    write_model_definitions(args.runtime_root)
    write_editor_numbers(args.runtime_root)
    print(f"Generated {len(vein_records())} mineral vein actors.")


if __name__ == "__main__":
    main()
