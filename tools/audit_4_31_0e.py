#!/usr/bin/env python3
"""Audita el parche ambiental 4.31.0e sin modificar el proyecto."""

from __future__ import annotations

import argparse
import hashlib
import re
import runpy
import shutil
import tempfile
import zipfile
from pathlib import Path


def require(condition: bool, message: str) -> None:
    if not condition:
        raise AssertionError(message)


def class_block(text: str, class_name: str) -> str:
    marker = f"class {class_name} :"
    start = text.find(marker)
    require(start >= 0, f"Falta la clase {class_name}")
    following = text.find("\nclass ", start + len(marker))
    return text[start:] if following < 0 else text[start:following]


def model_block(text: str, actor_name: str) -> str:
    marker = f"Model {actor_name}\n{{"
    start = text.find(marker)
    require(start >= 0, f"Falta MODELDEF para {actor_name}")
    following = text.find("\nModel ", start + len(marker))
    return text[start:] if following < 0 else text[start:following]


def sha256(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--runtime-root", type=Path, default=Path("src"))
    parser.add_argument(
        "--base-pk3",
        type=Path,
        default=Path("../recovered/caelum_argenteum_4.31.0d_test.pk3"),
    )
    parser.add_argument(
        "--candidate-pk3",
        type=Path,
        default=Path("build/caelum_argenteum_dev.pk3"),
    )
    parser.add_argument(
        "--generator",
        type=Path,
        default=Path("tools/generate_environment_models.py"),
    )
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    runtime = args.runtime_root.resolve()
    generator_path = args.generator.resolve()
    base_pk3 = args.base_pk3.resolve()
    candidate_pk3 = args.candidate_pk3.resolve()

    require(runtime.is_dir(), f"No existe runtime: {runtime}")
    require(generator_path.is_file(), f"No existe generador: {generator_path}")
    require(base_pk3.is_file(), f"No existe base: {base_pk3}")
    require(candidate_pk3.is_file(), f"No existe build: {candidate_pk3}")

    module = runpy.run_path(str(generator_path), run_name="ca_env_audit")
    rock_records = module["rock_records"]()
    tree_records = module["tree_records"]()
    records = rock_records + tree_records

    require(len(rock_records) == 75, "El catálogo debe contener 75 rocas")
    require(len(tree_records) == 111, "El catálogo debe contener 111 árboles")
    require(len(records) == 186, "El catálogo ambiental debe contener 186 actores")
    adult_records = [r for r in tree_records if "Adult" in str(r["actor"])]
    require(len(adult_records) == 48, "Deben existir 48 actores adultos")
    adult_families = {str(r["base_actor"]) for r in adult_records}
    require(len(adult_families) == 16, "Deben existir 16 familias adultas")

    actor_text = (runtime / "caelum/world/CaelumEnvironmentProps.zs").read_text(
        encoding="utf-8"
    )
    model_text = (runtime / "MODELDEF").read_text(encoding="utf-8")
    mapinfo_text = (runtime / "MAPINFO").read_text(encoding="utf-8")

    require(
        "class CaelumEnvironmentProp : CaelumMovableProp" in actor_text,
        "La base ambiental no integra CaelumMovableProp",
    )
    require(
        "class CaelumRockEnvironmentProp : CaelumEnvironmentProp" in actor_text,
        "Falta la base movible de rocas",
    )
    require(
        "class CaelumTreeEnvironmentProp : CaelumEnvironmentProp" in actor_text,
        "Falta la base arraigada de árboles",
    )

    for record in records:
        actor = str(record["actor"])
        actor_section = class_block(actor_text, actor)
        expected_mass = int(record["mass"])
        require(
            re.search(rf"^\s*Mass\s+{expected_mass};", actor_section, re.MULTILINE)
            is not None,
            f"Masa incorrecta para {actor}",
        )

        model_section = model_block(model_text, actor)
        expected_model = str(record["model"])
        require(
            f'Model 0 "{expected_model}"' in model_section,
            f"Modelo incorrecto para {actor}",
        )
        expected_scale = module["scalar"](float(record["scale"]))
        require(
            f"Scale {expected_scale} {expected_scale} {expected_scale}"
            in model_section,
            f"Escala incorrecta para {actor}",
        )
        require(
            (runtime / module["MODEL_DIRECTORY"] / expected_model).is_file(),
            f"No existe la malla de {actor}: {expected_model}",
        )

    editor_pairs = [
        (int(number), actor)
        for number, actor in re.findall(
            r"^\s*(\d+)\s*=\s*(Caelum(?:Rock|Tree)\w+)\s*$",
            mapinfo_text,
            re.MULTILINE,
        )
    ]
    expected_actors = {str(record["actor"]) for record in records}
    require(len(editor_pairs) == 186, "Deben existir 186 DoomEdNums ambientales")
    require(len({number for number, _ in editor_pairs}) == 186, "DoomEdNum repetido")
    require({actor for _, actor in editor_pairs} == expected_actors, "MAPINFO incompleto")

    adult_numbers = sorted(
        number for number, actor in editor_pairs if "Adult" in actor
    )
    require(adult_numbers == list(range(18412, 18460)), "Rango adulto incorrecto")

    player_text = (runtime / "caelum/player/CaelumPlayer.zs").read_text(
        encoding="utf-8"
    )
    combat_text = (runtime / "caelum/actors/CaelumCombatActor.zs").read_text(
        encoding="utf-8"
    )
    movable_text = (runtime / "caelum/actors/CaelumMovableProp.zs").read_text(
        encoding="utf-8"
    )
    for text, label in ((player_text, "jugador"), (combat_text, "actor")):
        require("ResolveRootedEnvironmentImpact" in text, f"Falta impacto de {label}")
        require("resolvePassiveRock" in text, f"Falta callback pasivo de roca en {label}")
        require("GetEnvironmentMassKg" in text, f"Falta masa ambiental en {label}")
    require(
        "virtual bool TryPushFrom" in movable_text,
        "CaelumMovableProp no permite especializar el empuje",
    )

    environment_prefix = "models/caelum/world/environment/"
    with zipfile.ZipFile(base_pk3) as base:
        base_names = set(base.namelist())
        preserved = [
            name
            for name in base_names
            if name.startswith(environment_prefix)
            and (name.endswith(".obj") or name.endswith(".png"))
        ]
        require(len([n for n in preserved if n.endswith(".obj")]) == 78, "OBJ base")
        for name in preserved:
            current = (runtime / name).read_bytes()
            require(
                sha256(current) == sha256(base.read(name)),
                f"El asset aprobado cambió: {name}",
            )
        for map_name in ("maps/MAP01.wad", "maps/MAP02.wad"):
            require(map_name in base_names, f"Falta {map_name} en la base")
            require(
                sha256((runtime / map_name).read_bytes()) == sha256(base.read(map_name)),
                f"El mapa cambió: {map_name}",
            )

    allowed_runtime_changes = {
        "MAPINFO",
        "MODELDEF",
        "caelum/actors/CaelumCombatActor.zs",
        "caelum/actors/CaelumMovableProp.zs",
        "caelum/player/CaelumPlayer.zs",
        "caelum/world/CaelumEnvironmentProps.zs",
        "licenses/VISUAL_ASSETS_4_31.md",
    }
    with zipfile.ZipFile(base_pk3) as base, zipfile.ZipFile(candidate_pk3) as build:
        base_names = base.namelist()
        build_names = build.namelist()
        require(len(base_names) == len(set(base_names)), "Entrada duplicada en la base")
        require(len(build_names) == len(set(build_names)), "Entrada duplicada en la build")
        require(set(base_names) == set(build_names), "La build cambió el catálogo ZIP")

        actual_changes: set[str] = set()
        for name in base_names:
            if sha256(base.read(name)) != sha256(build.read(name)):
                actual_changes.add(name)
        require(
            actual_changes == allowed_runtime_changes,
            "Cambios runtime inesperados: "
            + ", ".join(sorted(actual_changes ^ allowed_runtime_changes)),
        )
        for name in allowed_runtime_changes:
            require(
                sha256(build.read(name)) == sha256((runtime / name).read_bytes()),
                f"La build no contiene la fuente final: {name}",
            )

    with tempfile.TemporaryDirectory(prefix="ca4310e-audit-") as temp_name:
        temp = Path(temp_name)
        for relative in (
            Path("caelum/world/CaelumEnvironmentProps.zs"),
            Path("MODELDEF"),
            Path("MAPINFO"),
        ):
            destination = temp / relative
            destination.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(runtime / relative, destination)
        module["write_actor_definitions"](temp)
        module["write_model_definitions"](temp)
        module["write_editor_numbers"](temp)
        for relative in (
            Path("caelum/world/CaelumEnvironmentProps.zs"),
            Path("MODELDEF"),
            Path("MAPINFO"),
        ):
            require(
                (temp / relative).read_bytes() == (runtime / relative).read_bytes(),
                f"La regeneración no es determinista: {relative}",
            )

    masses = [int(record["mass"]) for record in records]
    print("OK: 186 actores ambientales (75 rocas + 111 árboles)")
    print("OK: 48 adultos, 16 familias, DoomEdNums 18412-18459")
    print(f"OK: masas cilíndricas {min(masses)}-{max(masses)} kg")
    print("OK: 78 OBJ y todos los materiales ambientales byte-idénticos")
    print("OK: MAP01 y MAP02 byte-idénticos a 4.31.0d")
    print("OK: build con exactamente siete archivos runtime modificados")
    print("OK: integración estática/dinámica y regeneración determinista")


if __name__ == "__main__":
    main()
