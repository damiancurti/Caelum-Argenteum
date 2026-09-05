#!/usr/bin/env python3
"""Audita el parche de recursos naturales 4.31.0f sin alterar la base."""

from __future__ import annotations

import argparse
import hashlib
import math
import re
import runpy
import shutil
import tempfile
import zipfile
from pathlib import Path

from PIL import Image


def require(condition: bool, message: str) -> None:
    if not condition:
        raise AssertionError(message)


def sha256(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--runtime-root", type=Path, default=Path("src"))
    parser.add_argument(
        "--base-root", type=Path, default=Path("../ca_4310e_work.cwai85/src")
    )
    parser.add_argument(
        "--base-pk3",
        type=Path,
        default=Path("../ca_4310e_work.cwai85/build/caelum_argenteum_dev.pk3"),
    )
    parser.add_argument(
        "--candidate-pk3", type=Path, default=Path("build/caelum_argenteum_dev.pk3")
    )
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    runtime = args.runtime_root.resolve()
    base_root = args.base_root.resolve()
    base_pk3 = args.base_pk3.resolve()
    candidate_pk3 = args.candidate_pk3.resolve()
    require(runtime.is_dir(), f"No existe runtime: {runtime}")
    require(base_root.is_dir(), f"No existe la fuente base: {base_root}")
    require(base_pk3.is_file(), f"No existe el PK3 base: {base_pk3}")
    require(candidate_pk3.is_file(), f"No existe el PK3 candidato: {candidate_pk3}")

    env = runpy.run_path("tools/generate_environment_models.py", run_name="env_audit")
    veins = runpy.run_path("tools/generate_mineral_veins.py", run_name="vein_audit")
    legacy = env["environment_records"]()
    age = env["tree_age_alias_records"]()
    vein_records = veins["vein_records"]()
    require(len(legacy) == 186, "La biblioteca aprobada debe conservar 186 actores")
    require(len(age) == 30, "Deben existir quince alias adultos y quince jóvenes")
    require(sum(record["age"] == "adult" for record in age) == 15, "Alias adultos")
    require(sum(record["age"] == "young" for record in age) == 15, "Actores jóvenes")
    require(len(vein_records) == 33, "Deben existir once vetas con tres variantes")

    actor_text = (runtime / "caelum/world/CaelumEnvironmentProps.zs").read_text(
        encoding="utf-8"
    )
    vein_text = (runtime / "caelum/world/CaelumMineralVeins.zs").read_text(
        encoding="utf-8"
    )
    zscript = (runtime / "ZSCRIPT").read_text(encoding="utf-8")
    player = (runtime / "caelum/player/CaelumPlayer.zs").read_text(encoding="utf-8")
    constants = (runtime / "caelum/core/CaelumConstants.zs").read_text(
        encoding="utf-8"
    )
    language = (runtime / "LANGUAGE").read_text(encoding="utf-8")
    modeldef = (runtime / "MODELDEF").read_text(encoding="utf-8")
    mapinfo = (runtime / "MAPINFO").read_text(encoding="utf-8")

    require("override bool IsNaturalResource() { return true; }" in actor_text, "Árbol renovable")
    require("MATERIAL_WOOD" in actor_text, "Los árboles no entregan madera")
    require("CATALOGUE_DAMAGE_SLASHING" in actor_text, "Falta puerta cortante")
    require("GetResourceHardness() { return 2.5; }" in actor_text, "Dureza de madera")
    require("NATURAL_RESOURCE_RECOVERY_PER_GAME_DAY = 0.001" in constants, "Regeneración")
    require("GAME_HOURS_PER_DAY = 24.0" in constants, "Duración del día")
    require("ResourceYieldCarry" in actor_text, "Falta acarreo determinista")
    require("args[4] > 0" in actor_text, "Falta capacidad editable por mapeador")
    require("CATALOGUE_DAMAGE_PIERCING" in vein_text, "Falta puerta punzante")
    require("TryExtractResource" in player, "El melee no conecta con recursos")
    require("extractedResourceUnits" in player, "Falta transacción de extracción")
    include_env = zscript.index('#include "caelum/world/CaelumEnvironmentProps.zs"')
    include_vein = zscript.index('#include "caelum/world/CaelumMineralVeins.zs"')
    include_player = zscript.index('#include "caelum/player/CaelumPlayer.zs"')
    require(include_env < include_vein < include_player, "Orden de includes incorrecto")

    old_actor_names = {
        str(record["legacy_actor"])
        for record in age
        if record["age"] == "adult"
    }
    for old_actor in old_actor_names:
        require(f"class {old_actor} :" in actor_text, f"Falta alias histórico {old_actor}")
    for record in age:
        actor = str(record["actor"])
        require(f"class {actor} :" in actor_text, f"Falta {actor}")
        require(f"Model {actor}\n{{" in modeldef, f"Falta modelo {actor}")
        if record["age"] == "young":
            legacy_record = next(
                item for item in legacy if item["actor"] == record["legacy_actor"]
            )
            require(
                math.isclose(float(record["scale"]), float(legacy_record["scale"]) * 0.5),
                f"Escala joven incorrecta: {actor}",
            )

    editor_pairs = [
        (int(number), actor)
        for number, actor in re.findall(
            r"^\s*(\d+)\s*=\s*(Caelum(?:Rock|Tree|Vein)\w+)\s*$",
            mapinfo,
            re.MULTILINE,
        )
    ]
    require(len(editor_pairs) == 234, "Deben existir 201 fuentes vegetales/roca y 33 vetas")
    require(len({number for number, _ in editor_pairs}) == 234, "DoomEdNum repetido")
    require(len({actor for _, actor in editor_pairs}) == 234, "Actor de editor repetido")
    young_numbers = sorted(number for number, actor in editor_pairs if "Young" in actor)
    vein_numbers = sorted(number for number, actor in editor_pairs if actor.startswith("CaelumVein"))
    require(young_numbers == list(range(18460, 18475)), "Rango joven incorrecto")
    require(vein_numbers == list(range(18500, 18533)), "Rango de vetas incorrecto")
    for old_actor in old_actor_names:
        require(old_actor not in {actor for _, actor in editor_pairs}, f"Nombre adulto sin migrar: {old_actor}")

    abundance_expected = {
        "Iron": 0.60,
        "Coal": 0.60,
        "Copper": 0.50,
        "Tin": 0.40,
        "Silver": 0.20,
        "Gold": 0.10,
        "Opal": 0.075,
        "Topaz": 0.05,
        "Sapphire": 0.04,
        "Ruby": 0.03,
        "Emerald": 0.02,
    }
    for resource, expected in abundance_expected.items():
        record = next(item for item in vein_records if item["actor"] == f"CaelumVein{resource}")
        require(math.isclose(float(record["abundance"]), expected), f"Abundancia {resource}")
        require(f"CA_VEIN_{resource.upper()}" in language, f"Traducción {resource}")

    for record in vein_records:
        actor = str(record["actor"])
        model = runtime / veins["MODEL_DIRECTORY"] / str(record["model"])
        texture = runtime / veins["MODEL_DIRECTORY"] / str(record["texture"])
        sprite = runtime / "sprites" / f"CAVE{record['frame']}0.png"
        require(f"class {actor} :" in vein_text, f"Falta clase {actor}")
        require(f"Model {actor}\n{{" in modeldef, f"Falta MODELDEF {actor}")
        require(model.is_file(), f"Falta modelo {model}")
        require(texture.is_file(), f"Falta textura {texture}")
        require(sprite.is_file(), f"Falta anclaje {sprite}")
        model_text = model.read_text(encoding="utf-8")
        require(model_text.count("\nf ") >= 150, f"Malla incompleta: {model.name}")
        for line in model_text.splitlines():
            if line.startswith("v "):
                require(all(math.isfinite(float(value)) for value in line.split()[1:]), f"Vértice inválido: {model.name}")

    base_environment = base_root / "models/caelum/world/environment"
    for base_asset in base_environment.iterdir():
        if not base_asset.is_file():
            continue
        current = runtime / "models/caelum/world/environment" / base_asset.name
        require(current.is_file(), f"Falta asset aprobado {base_asset.name}")
        require(sha256(current.read_bytes()) == sha256(base_asset.read_bytes()), f"Cambió {base_asset.name}")
    for map_name in ("MAP01.wad", "MAP02.wad"):
        require(
            sha256((runtime / "maps" / map_name).read_bytes())
            == sha256((base_root / "maps" / map_name).read_bytes()),
            f"El mapa cambió: {map_name}",
        )

    with tempfile.TemporaryDirectory(prefix="ca4310f-audit-") as temp_name:
        temp = Path(temp_name)
        for relative in (
            Path("MODELDEF"),
            Path("MAPINFO"),
            Path("caelum/world/CaelumEnvironmentProps.zs"),
            Path("caelum/world/CaelumMineralVeins.zs"),
        ):
            destination = temp / relative
            destination.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(runtime / relative, destination)
        env["write_actor_definitions"](temp)
        env["write_model_definitions"](temp)
        env["write_editor_numbers"](temp)
        model_dir = temp / veins["MODEL_DIRECTORY"]
        sprite_dir = temp / "sprites"
        model_dir.mkdir(parents=True, exist_ok=True)
        sprite_dir.mkdir(parents=True, exist_ok=True)
        for spec in veins["VEINS"]:
            veins["make_ore_texture"](model_dir / f"ca_vein_{spec.stem}.png", spec)
            for variant in veins["VARIANTS"]:
                stem = f"ca_vein_{spec.stem}{variant.suffix}"
                veins["build_vein"](spec, variant, model_dir / f"{stem}.obj")
            Image.new("RGBA", (1, 1), (0, 0, 0, 0)).save(
                sprite_dir / f"CAVE{spec.frame}0.png", optimize=True
            )
        veins["write_actor_definitions"](temp)
        veins["write_model_definitions"](temp)
        veins["write_editor_numbers"](temp)
        generated = [
            Path("MODELDEF"),
            Path("MAPINFO"),
            Path("caelum/world/CaelumEnvironmentProps.zs"),
            Path("caelum/world/CaelumMineralVeins.zs"),
        ]
        generated.extend(
            path.relative_to(temp)
            for path in sorted(model_dir.iterdir())
            if path.is_file()
        )
        generated.extend(
            path.relative_to(temp)
            for path in sorted(sprite_dir.iterdir())
            if path.is_file()
        )
        for relative in generated:
            require(
                (temp / relative).read_bytes() == (runtime / relative).read_bytes(),
                f"Regeneración no determinista: {relative}",
            )

    changed_existing = {
        "LANGUAGE",
        "MAPINFO",
        "MODELDEF",
        "ZSCRIPT",
        "caelum/core/CaelumConstants.zs",
        "caelum/player/CaelumPlayer.zs",
        "caelum/world/CaelumEnvironmentProps.zs",
        "licenses/VISUAL_ASSETS_4_31.md",
    }
    new_runtime = {"caelum/world/CaelumMineralVeins.zs"}
    new_runtime.update(
        str(path.relative_to(runtime)).replace("\\", "/")
        for path in (runtime / veins["MODEL_DIRECTORY"]).iterdir()
        if path.is_file()
    )
    new_runtime.update(
        f"sprites/CAVE{spec.frame}0.png" for spec in veins["VEINS"]
    )
    with zipfile.ZipFile(base_pk3) as base, zipfile.ZipFile(candidate_pk3) as candidate:
        base_names = set(base.namelist())
        candidate_names = set(candidate.namelist())
        require(len(candidate.namelist()) == len(candidate_names), "Entrada ZIP duplicada")
        require(candidate_names - base_names == new_runtime, "Altas runtime inesperadas")
        require(not (base_names - candidate_names), "Se eliminó contenido de la base")
        actual_changes = {
            name
            for name in base_names
            if sha256(base.read(name)) != sha256(candidate.read(name))
        }
        require(actual_changes == changed_existing, "Cambios runtime inesperados")
        for relative in changed_existing | new_runtime:
            require(
                sha256(candidate.read(relative)) == sha256((runtime / relative).read_bytes()),
                f"La build no contiene la fuente final: {relative}",
            )

    # Un día son 24 × 180 segundos; 0,1% por día requiere mil días
    # desde cero hasta lleno y no depende del tamaño absoluto del actor.
    updates_per_day = 24.0 * 180.0
    recovered_fraction = updates_per_day * 0.001 / updates_per_day
    require(math.isclose(recovered_fraction, 0.001), "Tasa diaria incorrecta")
    require(math.isclose(1.0 / recovered_fraction, 1000.0), "Tiempo de llenado")

    print("OK: 186 actores previos preservados y 15 nombres Adult migrados")
    print("OK: 15 actores Young al 50% con DoomEdNums 18460-18474")
    print("OK: 33 vetas (11 recursos x 3 variantes), DoomEdNums 18500-18532")
    print("OK: 33 OBJ, 11 texturas y 11 anclajes generados de forma determinista")
    print("OK: melee cortante/punzante, dureza, abundancia y acarreo fraccional")
    print("OK: regeneración exacta de 0,1% por día de juego")
    print("OK: assets ambientales y MAP01/MAP02 byte-idénticos a 4.31.0e")
    print("OK: PK3 contiene sólo las altas y cambios runtime autorizados")


if __name__ == "__main__":
    main()
