#!/usr/bin/env python3
"""Audita la corrección incremental 4.31.0g contra la base 4.31.0f."""

from __future__ import annotations

import argparse
import hashlib
import math
import re
import runpy
import zipfile
from pathlib import Path


EXPECTED_RUNTIME_CHANGES = {
    "LANGUAGE",
    "MAPINFO",
    "MODELDEF",
    "caelum/hud/CaelumJournalOverlay.zs",
    "caelum/player/CaelumPlayer.zs",
    "caelum/world/CaelumEnvironmentProps.zs",
    "models/caelum/world/resources/ca_vein_coal3.obj",
    "models/caelum/world/resources/ca_vein_gold2.obj",
    "models/caelum/world/resources/ca_vein_silver.obj",
}

CORRECTED_VEIN_MODELS = {
    "ca_vein_coal3.obj",
    "ca_vein_gold2.obj",
    "ca_vein_silver.obj",
}


def require(condition: bool, message: str) -> None:
    if not condition:
        raise AssertionError(message)


def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--runtime-root", type=Path, default=Path("src"))
    parser.add_argument(
        "--base-root",
        type=Path,
        default=Path("../ca_resources_next_o7ylPS/src"),
    )
    parser.add_argument(
        "--base-pk3",
        type=Path,
        default=Path("../ca_resources_next_o7ylPS/build/caelum_argenteum_dev.pk3"),
    )
    parser.add_argument(
        "--candidate-pk3",
        type=Path,
        default=Path("build/caelum_argenteum_dev.pk3"),
    )
    return parser.parse_args()


def relative_files(root: Path) -> dict[str, Path]:
    return {
        path.relative_to(root).as_posix(): path
        for path in root.rglob("*")
        if path.is_file()
    }


def zip_digests(path: Path) -> dict[str, str]:
    with zipfile.ZipFile(path) as archive:
        return {
            info.filename: hashlib.sha256(archive.read(info.filename)).hexdigest()
            for info in archive.infolist()
            if not info.is_dir()
        }


def main() -> None:
    args = parse_args()
    runtime = args.runtime_root.resolve()
    base_root = args.base_root.resolve()
    base_pk3 = args.base_pk3.resolve()
    candidate_pk3 = args.candidate_pk3.resolve()
    for path in (runtime, base_root):
        require(path.is_dir(), f"No existe el directorio: {path}")
    for path in (base_pk3, candidate_pk3):
        require(path.is_file(), f"No existe el paquete: {path}")

    env = runpy.run_path(
        "tools/generate_environment_models.py", run_name="environment_audit"
    )
    veins = runpy.run_path(
        "tools/generate_mineral_veins.py", run_name="vein_audit"
    )
    legacy = env["environment_records"]()
    existing_age = env["tree_age_alias_records"]()
    new_young = env["tree_young_alias_records"]()
    vein_records = veins["vein_records"]()

    require(len(legacy) == 186, "Deben conservarse los 186 actores históricos")
    require(len(existing_age) == 30, "Deben conservarse los 30 alias de cinco especies")
    require(len(new_young) == 48, "Deben agregarse los 48 nombres Young restantes")
    require(len(vein_records) == 33, "Deben conservarse las 33 vetas")

    actor_text = (runtime / "caelum/world/CaelumEnvironmentProps.zs").read_text(
        encoding="utf-8"
    )
    player_text = (runtime / "caelum/player/CaelumPlayer.zs").read_text(
        encoding="utf-8"
    )
    journal_text = (runtime / "caelum/hud/CaelumJournalOverlay.zs").read_text(
        encoding="utf-8"
    )
    language = (runtime / "LANGUAGE").read_text(encoding="utf-8")
    mapinfo = (runtime / "MAPINFO").read_text(encoding="utf-8")
    modeldef = (runtime / "MODELDEF").read_text(encoding="utf-8")

    legacy_trees = [record for record in legacy if record["kind"] == "tree"]
    require(len(legacy_trees) == 111, "La biblioteca histórica de árboles cambió")
    for record in legacy_trees:
        require(
            f"class {record['actor']} :" in actor_text,
            f"Falta compatibilidad con {record['actor']}",
        )
    for record in existing_age + new_young:
        actor = str(record["actor"])
        require(f"class {actor} :" in actor_text, f"Falta clase {actor}")
        require(f"Model {actor}\n{{" in modeldef, f"Falta MODELDEF de {actor}")
        require(str(record["tag"]).removeprefix("$") in language, f"Falta Tag de {actor}")

    for record in new_young:
        source = next(
            item for item in legacy_trees if item["actor"] == record["legacy_actor"]
        )
        require(
            math.isclose(float(record["scale"]), float(source["scale"])),
            f"El alias Young cambió la escala de {record['legacy_actor']}",
        )
        require(int(record["mass"]) == int(source["mass"]), "Masa Young alterada")

    editor_pairs = [
        (int(number), actor)
        for number, actor in re.findall(
            r"^\s*(\d+)\s*=\s*(Caelum(?:Rock|Tree|Vein)\w+)\s*$",
            mapinfo,
            re.MULTILINE,
        )
    ]
    require(len(editor_pairs) == 234, "El catálogo de editor debe tener 234 actores")
    require(len({number for number, _ in editor_pairs}) == 234, "DoomEdNum repetido")
    tree_editor = [actor for _, actor in editor_pairs if actor.startswith("CaelumTree")]
    require(len(tree_editor) == 126, "Deben existir 126 árboles de editor")
    require(
        all("Adult" in actor or "Young" in actor for actor in tree_editor),
        "Quedó un árbol de editor sin edad explícita",
    )
    require(sum("Adult" in actor for actor in tree_editor) == 63, "Adult incompleto")
    require(sum("Young" in actor for actor in tree_editor) == 63, "Young incompleto")

    require(
        "if (resourceTarget.IsEnvironmentMovable())" in player_text,
        "La extracción todavía empuja fuentes arraigadas",
    )
    require(
        "LastAttackPushForce = 0.0;" in player_text,
        "Falta limpiar el impulso de una fuente estática",
    )
    require("F repair" in language and "F reparar" in language, "Ayuda de reparación")
    require("D dismantle" in language and "D desarmar" in language, "Ayuda de desarme")
    require("showEquipmentAction" in journal_text, "El menú no informa fallos de reparación")

    model_root = runtime / veins["MODEL_DIRECTORY"]
    base_model_root = base_root / veins["MODEL_DIRECTORY"]
    for record in vein_records:
        name = str(record["model"])
        candidate = model_root / name
        original = base_model_root / name
        require(candidate.is_file() and original.is_file(), f"Falta malla {name}")
        vertices = sum(
            1 for line in candidate.read_text(encoding="utf-8").splitlines()
            if line.startswith("v ")
        )
        if name in CORRECTED_VEIN_MODELS:
            require(vertices == 770, f"No se retiró la banda anómala de {name}")
            require(digest(candidate) != digest(original), f"No cambió {name}")
        else:
            require(digest(candidate) == digest(original), f"Cambio visual no pedido: {name}")

    runtime_files = relative_files(runtime)
    base_files = relative_files(base_root)
    require(runtime_files.keys() == base_files.keys(), "Cambió el catálogo del runtime")
    changed_runtime = {
        name
        for name in runtime_files
        if digest(runtime_files[name]) != digest(base_files[name])
    }
    require(
        changed_runtime == EXPECTED_RUNTIME_CHANGES,
        f"Cambios runtime inesperados: {sorted(changed_runtime ^ EXPECTED_RUNTIME_CHANGES)}",
    )
    for map_name in ("maps/MAP01.wad", "maps/MAP02.wad"):
        require(digest(runtime / map_name) == digest(base_root / map_name), f"Cambió {map_name}")

    base_zip = zip_digests(base_pk3)
    candidate_zip = zip_digests(candidate_pk3)
    require(base_zip.keys() == candidate_zip.keys(), "Cambió el catálogo interno del PK3")
    changed_zip = {
        name for name in base_zip if base_zip[name] != candidate_zip[name]
    }
    require(changed_zip == EXPECTED_RUNTIME_CHANGES, "El PK3 no refleja sólo la corrección")
    require(len(candidate_zip) == 3952, "El PK3 debe conservar sus 3952 archivos")
    with zipfile.ZipFile(candidate_pk3) as archive:
        require(len(archive.infolist()) == 4062, "El PK3 debe conservar sus 4062 entradas")

    named_age_records = (
        [record for record in legacy_trees if "Adult" in str(record["actor"])]
        + existing_age
        + new_young
    )
    require(len(named_age_records) == 126, "Catálogo de edades incompleto")
    tree_capacities = [int(record["mass"]) * 1000 for record in named_age_records]
    vein_capacities = [
        round(int(record["mass"]) * float(record["abundance"]) * 1000)
        for record in vein_records
    ]
    require(min(tree_capacities) == 117000, "Mínimo arbóreo inesperado")
    require(max(tree_capacities) == 669509000, "Máximo arbóreo inesperado")
    require(min(vein_capacities) == 287540, "Mínimo mineral inesperado")
    require(max(vein_capacities) == 35946000, "Máximo mineral inesperado")

    print("4.31.0g audit passed")
    print(f"runtime changes: {len(changed_runtime)}")
    print("trees: 63 Adult + 63 Young; 63 historical aliases retained")
    print("corrected veins: coal3, silver1, gold2")
    print("maps unchanged; PK3 entries: 4062")


if __name__ == "__main__":
    main()
