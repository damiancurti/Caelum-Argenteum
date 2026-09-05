#!/usr/bin/env python3
"""Construye y audita el parche incremental 4.31.0g desde 4.31.0f."""

from __future__ import annotations

import argparse
import hashlib
import os
import runpy
import shutil
import subprocess
import sys
import tempfile
import zipfile
from pathlib import Path


RUNTIME_CHANGES = (
    "LANGUAGE",
    "MAPINFO",
    "MODELDEF",
    "caelum/hud/CaelumJournalOverlay.zs",
    "caelum/player/CaelumPlayer.zs",
    "caelum/world/CaelumEnvironmentProps.zs",
    "models/caelum/world/resources/ca_vein_coal3.obj",
    "models/caelum/world/resources/ca_vein_gold2.obj",
    "models/caelum/world/resources/ca_vein_silver.obj",
)

PROJECT_CHANGES = (
    "APLICAR_4_31_0g.txt",
    "CAPACIDADES_RECURSOS_4_31_0g.txt",
    "PRUEBAS_4_31_0g.txt",
    "docs/IMPLEMENTATION_STATUS.md",
    "docs/ROADMAP.md",
    "docs/V4_31_WORLD_RESOURCES_AND_STASHES.md",
    "tools/audit_4_31_0g.py",
    "tools/build_patch_4_31_0g.py",
    "tools/generate_environment_models.py",
    "tools/generate_mineral_veins.py",
)


def require(condition: bool, message: str) -> None:
    if not condition:
        raise RuntimeError(message)


def replace_once(text: str, old: str, new: str, label: str) -> str:
    require(text.count(old) == 1, f"Reemplazo ambiguo o ausente: {label}")
    return text.replace(old, new, 1)


def patch_player(path: Path) -> None:
    text = path.read_text(encoding="utf-8")
    text = replace_once(
        text,
        """        LastCraftingAction = CaelumConstants.CRAFTING_ACTION_NONE;
        RefreshCraftingPreview();
        SetCraftingJournalState(true);""",
        """        LastCraftingAction = CaelumConstants.CRAFTING_ACTION_NONE;
        LastEquipmentAction = CaelumConstants.EQUIPMENT_ACTION_NONE;
        RefreshCraftingPreview();
        SetCraftingJournalState(true);""",
        "limpieza al abrir estación",
    )
    text = replace_once(
        text,
        """    void BeginRepairSelectedEquipment()
    {
        LastEquipmentAction =""",
        """    void BeginRepairSelectedEquipment()
    {
        LastCraftingAction = CaelumConstants.CRAFTING_ACTION_NONE;
        LastEquipmentAction =""",
        "estado de reparación",
    )
    text = replace_once(
        text,
        """    void BeginDismantleSelectedEquipment()
    {
        LastEquipmentAction =""",
        """    void BeginDismantleSelectedEquipment()
    {
        LastCraftingAction = CaelumConstants.CRAFTING_ACTION_NONE;
        LastEquipmentAction =""",
        "estado de desarme",
    )
    text = replace_once(
        text,
        """        else if (extractedResourceUnits > 0.0)
        {
            // Una fuente invulnerable no devuelve daño de salud, pero un golpe
            // de extracción válido sí desgasta el arma y transmite su impulso.
            ApplyWeaponDurabilityFromSuccessfulDamage(
                integerDamage,
                WeaponModel.WeaponType,
                WeaponModel.Tier,
                WeaponModel.Size
            );
            ApplyAttackPushToTarget(
                targetData.linetarget,
                attackAngle,
                DerivedStats.PhysicalPushMultiplier
            );
        }""",
        """        else if (extractedResourceUnits > 0.0)
        {
            // Una fuente invulnerable no devuelve daño de salud, pero un golpe
            // de extracción válido sí desgasta el arma. Sólo las fuentes
            // declaradas movibles reciben impulso; los árboles están arraigados.
            ApplyWeaponDurabilityFromSuccessfulDamage(
                integerDamage,
                WeaponModel.WeaponType,
                WeaponModel.Tier,
                WeaponModel.Size
            );
            if (resourceTarget.IsEnvironmentMovable())
            {
                ApplyAttackPushToTarget(
                    targetData.linetarget,
                    attackAngle,
                    DerivedStats.PhysicalPushMultiplier
                );
            }
            else
            {
                LastAttackPushForce = 0.0;
            }
        }""",
        "impulso de extracción",
    )
    path.write_text(text, encoding="utf-8")


def patch_journal(path: Path) -> None:
    text = path.read_text(encoding="utf-8")
    old = """        else
        {
            DrawTextLine(
                SmallFont,
                localPlayer.LastCraftingAction
                        == CaelumConstants.CRAFTING_ACTION_NONE
                    ? Font.CR_GRAY : Font.CR_GOLD,
                52.0, 304.0,
                StringTable.Localize(
                    GetCraftingActionKey(localPlayer.LastCraftingAction),
                    false
                )
            );
        }"""
    new = """        else
        {
            bool showEquipmentAction = localPlayer.LastCraftingAction
                    == CaelumConstants.CRAFTING_ACTION_NONE
                && localPlayer.LastEquipmentAction
                    != CaelumConstants.EQUIPMENT_ACTION_NONE;
            DrawTextLine(
                SmallFont,
                !showEquipmentAction
                    && localPlayer.LastCraftingAction
                        == CaelumConstants.CRAFTING_ACTION_NONE
                    ? Font.CR_GRAY : Font.CR_GOLD,
                52.0, 304.0,
                StringTable.Localize(
                    showEquipmentAction
                        ? GetEquipmentActionKey(
                            localPlayer.LastEquipmentAction
                        )
                        : GetCraftingActionKey(
                            localPlayer.LastCraftingAction
                        ),
                    false
                )
            );
        }"""
    path.write_text(
        replace_once(text, old, new, "mensaje de reparación"),
        encoding="utf-8",
    )


def patch_language(path: Path) -> None:
    text = path.read_text(encoding="utf-8")
    text = replace_once(
        text,
        'CA_JOURNAL_CRAFTING_HELP = "Left/Right recipe | Up/Down step | X efficiency | Space tier/batch | R size | E craft | T +10m | Q close";',
        'CA_JOURNAL_CRAFTING_HELP = "Left/Right recipe | Up/Down step | X efficiency | Space tier | R size | E craft | F repair | D dismantle | T +10m | Q close";',
        "ayuda inglesa",
    )
    text = replace_once(
        text,
        'CA_JOURNAL_CRAFTING_HELP = "Izq/Der receta | Arr/Ab paso | X eficiencia | Esp tier/lote | R talle | E fabricar | T +10m | Q cerrar";',
        'CA_JOURNAL_CRAFTING_HELP = "Izq/Der receta | Arr/Ab paso | X eficiencia | Esp tier | R talle | E crear | F reparar | D desarmar | T +10m | Q cerrar";',
        "ayuda española",
    )
    english = """CA_TREE_JUNGLE_LAPACHO_YOUNG = "young lapacho";
CA_TREE_JUNGLE_PALO_ROSA_YOUNG = "young palo rosa";
CA_TREE_JUNGLE_TIMBO_YOUNG = "young timbó";
CA_TREE_TUNDRA_LENGA_YOUNG = "young lenga";
CA_TREE_TUNDRA_NIRE_YOUNG = "young ñire";
CA_TREE_TUNDRA_GUINDO_YOUNG = "young guindo";
CA_TREE_MOUNTAIN_PEHUEN_YOUNG = "young pehuén";
CA_TREE_MOUNTAIN_CYPRESS_YOUNG = "young Patagonian cypress";
CA_TREE_MOUNTAIN_COIHUE_YOUNG = "young coihue";
CA_TREE_PLAINS_OMBU_YOUNG = "young ombú";
CA_TREE_PLAINS_TALA_YOUNG = "young tala";
CA_TREE_COAST_CORONILLO_YOUNG = "young coronillo";
CA_TREE_COAST_WILLOW_YOUNG = "young creole willow";
CA_TREE_CITY_JACARANDA_YOUNG = "young jacarandá";
CA_TREE_CITY_TIPA_YOUNG = "young tipa";
CA_TREE_CITY_PLANE_YOUNG = "young plane tree";"""
    spanish = """CA_TREE_JUNGLE_LAPACHO_YOUNG = "lapacho joven";
CA_TREE_JUNGLE_PALO_ROSA_YOUNG = "palo rosa joven";
CA_TREE_JUNGLE_TIMBO_YOUNG = "timbó joven";
CA_TREE_TUNDRA_LENGA_YOUNG = "lenga joven";
CA_TREE_TUNDRA_NIRE_YOUNG = "ñire joven";
CA_TREE_TUNDRA_GUINDO_YOUNG = "guindo joven";
CA_TREE_MOUNTAIN_PEHUEN_YOUNG = "pehuén joven";
CA_TREE_MOUNTAIN_CYPRESS_YOUNG = "ciprés de la cordillera joven";
CA_TREE_MOUNTAIN_COIHUE_YOUNG = "coihue joven";
CA_TREE_PLAINS_OMBU_YOUNG = "ombú joven";
CA_TREE_PLAINS_TALA_YOUNG = "tala joven";
CA_TREE_COAST_CORONILLO_YOUNG = "coronillo joven";
CA_TREE_COAST_WILLOW_YOUNG = "sauce criollo joven";
CA_TREE_CITY_JACARANDA_YOUNG = "jacarandá joven";
CA_TREE_CITY_TIPA_YOUNG = "tipa joven";
CA_TREE_CITY_PLANE_YOUNG = "plátano joven";"""
    text = replace_once(
        text,
        'CA_TREE_COAST_CEIBO_YOUNG = "young ceibo";\nCA_VEIN_IRON',
        'CA_TREE_COAST_CEIBO_YOUNG = "young ceibo";\n' + english + '\nCA_VEIN_IRON',
        "nombres Young ingleses",
    )
    text = replace_once(
        text,
        'CA_TREE_COAST_CEIBO_YOUNG = "ceibo joven";\nCA_VEIN_IRON',
        'CA_TREE_COAST_CEIBO_YOUNG = "ceibo joven";\n' + spanish + '\nCA_VEIN_IRON',
        "nombres Young españoles",
    )
    path.write_text(text, encoding="utf-8")


def copy_zip_info(info: zipfile.ZipInfo) -> zipfile.ZipInfo:
    copied = zipfile.ZipInfo(info.filename, info.date_time)
    copied.comment = info.comment
    copied.extra = info.extra
    copied.create_system = info.create_system
    copied.create_version = info.create_version
    copied.extract_version = info.extract_version
    copied.external_attr = info.external_attr
    copied.internal_attr = info.internal_attr
    copied.flag_bits = info.flag_bits & ~0x08
    copied.compress_type = info.compress_type
    return copied


def rebuild_pk3(base_pk3: Path, runtime: Path, output: Path) -> None:
    substitutions = set(RUNTIME_CHANGES)
    with zipfile.ZipFile(base_pk3, "r") as source, zipfile.ZipFile(
        output, "w", allowZip64=True
    ) as target:
        for info in source.infolist():
            data = (
                (runtime / info.filename).read_bytes()
                if info.filename in substitutions
                else source.read(info.filename)
            )
            target.writestr(copy_zip_info(info), data, compresslevel=9)


def add_file(
    archive: zipfile.ZipFile,
    source: Path,
    destination: str,
    stored: bool = False,
) -> None:
    info = zipfile.ZipInfo(destination, (2026, 9, 5, 12, 0, 0))
    info.create_system = 3
    info.external_attr = (0o100644 & 0xFFFF) << 16
    info.compress_type = zipfile.ZIP_STORED if stored else zipfile.ZIP_DEFLATED
    archive.writestr(info, source.read_bytes(), compresslevel=None if stored else 9)


def build_patch(project: Path, runtime: Path, candidate_pk3: Path, output: Path) -> None:
    temporary = output.with_suffix(output.suffix + ".tmp")
    if temporary.exists():
        temporary.unlink()
    with zipfile.ZipFile(temporary, "w", allowZip64=True) as archive:
        for relative in RUNTIME_CHANGES:
            add_file(archive, runtime / relative, f"src/{relative}")
        for relative in PROJECT_CHANGES:
            add_file(archive, project / relative, relative)
        add_file(
            archive,
            candidate_pk3,
            "build/caelum_argenteum_dev.pk3",
            stored=True,
        )
    with zipfile.ZipFile(temporary) as archive:
        require(archive.testzip() is None, "El ZIP incremental está corrupto")
        require(len(archive.infolist()) == len(RUNTIME_CHANGES) + len(PROJECT_CHANGES) + 1, "Cantidad de archivos inesperada")
    os.replace(temporary, output)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--project-root", type=Path, required=True)
    parser.add_argument("--base-root", type=Path, required=True)
    parser.add_argument("--base-pk3", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    project = args.project_root.resolve()
    base_root = args.base_root.resolve()
    base_pk3 = args.base_pk3.resolve()
    output = args.output.resolve()
    require(project.is_dir(), f"No existe el proyecto: {project}")
    require(base_root.is_dir(), f"No existe el runtime base: {base_root}")
    require(base_pk3.is_file(), f"No existe el PK3 base: {base_pk3}")
    output.parent.mkdir(parents=True, exist_ok=True)

    with tempfile.TemporaryDirectory(prefix="ca_4310g_build_") as temporary_name:
        temporary = Path(temporary_name)
        runtime = temporary / "src"
        shutil.copytree(base_root, runtime)

        sys.path.insert(0, str(project / "tools"))
        environment = runpy.run_path(
            str(project / "tools/generate_environment_models.py"),
            run_name="environment_build",
        )
        environment["write_actor_definitions"](runtime)
        environment["write_model_definitions"](runtime)
        environment["write_editor_numbers"](runtime)

        veins = runpy.run_path(
            str(project / "tools/generate_mineral_veins.py"),
            run_name="vein_build",
        )
        corrected = (("coal", "3"), ("silver", ""), ("gold", "2"))
        for stem, suffix in corrected:
            spec = next(item for item in veins["VEINS"] if item.stem == stem)
            variant = next(
                item for item in veins["VARIANTS"] if item.suffix == suffix
            )
            filename = f"ca_vein_{stem}{suffix}.obj"
            veins["build_vein"](
                spec,
                variant,
                runtime / veins["MODEL_DIRECTORY"] / filename,
            )

        patch_player(runtime / "caelum/player/CaelumPlayer.zs")
        patch_journal(runtime / "caelum/hud/CaelumJournalOverlay.zs")
        patch_language(runtime / "LANGUAGE")

        candidate_pk3 = temporary / "caelum_argenteum_dev.pk3"
        rebuild_pk3(base_pk3, runtime, candidate_pk3)
        subprocess.run(
            [
                sys.executable,
                str(project / "tools/audit_4_31_0g.py"),
                "--runtime-root",
                str(runtime),
                "--base-root",
                str(base_root),
                "--base-pk3",
                str(base_pk3),
                "--candidate-pk3",
                str(candidate_pk3),
            ],
            cwd=project,
            check=True,
        )
        build_patch(project, runtime, candidate_pk3, output)

    print(f"patch: {output}")
    print(f"size: {output.stat().st_size}")
    print(f"sha256: {hashlib.sha256(output.read_bytes()).hexdigest()}")


if __name__ == "__main__":
    main()
