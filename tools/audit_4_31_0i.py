#!/usr/bin/env python3
"""Audita las correcciones de crafteo 4.31.0i contra 4.31.0h."""

from __future__ import annotations

import argparse
import hashlib
import math
import re
import zipfile
from pathlib import Path


EXPECTED_RUNTIME_CHANGES = {
    "LANGUAGE",
    "caelum/core/CaelumConstants.zs",
    "caelum/equipment/CaelumCraftingRules.zs",
    "caelum/hud/CaelumJournalOverlay.zs",
    "caelum/player/CaelumPlayer.zs",
}


def require(condition: bool, message: str) -> None:
    if not condition:
        raise AssertionError(message)


def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


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


def function_body(text: str, name: str) -> str:
    match = re.search(rf"(?m)^    (?:bool|double|int|void) {name}\(", text)
    require(match is not None, f"Falta la función {name}")
    opening = text.find("{", match.start())
    require(opening >= 0, f"Falta el cuerpo de {name}")
    depth = 0
    quote = ""
    escaped = False
    for index in range(opening, len(text)):
        char = text[index]
        if quote:
            if escaped:
                escaped = False
            elif char == "\\":
                escaped = True
            elif char == quote:
                quote = ""
            continue
        if char in ('"', "'"):
            quote = char
        elif char == "{":
            depth += 1
        elif char == "}":
            depth -= 1
            if depth == 0:
                return text[match.start() : index + 1]
    raise AssertionError(f"Cuerpo sin cerrar en {name}")


def adjusted_units(theoretical: int, percent: int) -> int:
    return max(1, math.ceil(theoretical * 100.0 / percent - 0.0000001))


def own_work(units: int, complexity: int, factor: float, dexterity: float) -> float:
    return units * complexity * factor / 35.0 * 100.0 / dexterity


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--runtime-root", type=Path, required=True)
    parser.add_argument("--base-root", type=Path, required=True)
    parser.add_argument("--base-pk3", type=Path, required=True)
    parser.add_argument("--candidate-pk3", type=Path, required=True)
    return parser.parse_args()


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

    constants = (runtime / "caelum/core/CaelumConstants.zs").read_text(
        encoding="utf-8"
    )
    rules = (runtime / "caelum/equipment/CaelumCraftingRules.zs").read_text(
        encoding="utf-8"
    )
    player = (runtime / "caelum/player/CaelumPlayer.zs").read_text(
        encoding="utf-8"
    )
    journal = (runtime / "caelum/hud/CaelumJournalOverlay.zs").read_text(
        encoding="utf-8"
    )
    language = (runtime / "LANGUAGE").read_text(encoding="utf-8")

    require(
        "CRAFTING_EFFICIENCY_FAST_TIME_FACTOR = 1.0" in constants
        and "CRAFTING_EFFICIENCY_CAREFUL_TIME_FACTOR = 10.0" in constants
        and "CRAFTING_EFFICIENCY_PERFECT_TIME_FACTOR = 100.0" in constants,
        "Cambió el régimen temporal 1x/10x/100x",
    )
    require(
        "CRAFTING_EFFICIENCY_FAST_PERCENT = 25" in constants
        and "CRAFTING_EFFICIENCY_CAREFUL_PERCENT = 50" in constants
        and "CRAFTING_EFFICIENCY_PERFECT_PERCENT = 100" in constants,
        "Cambió la eficiencia 25/50/100",
    )
    require(
        "EQUIPMENT_ACTION_FAILED_MATERIALS = 28" in constants,
        "Falta el resultado específico de reparación",
    )

    blueprint = function_body(player, "ExpandCraftingBlueprintMaterial")
    direct_step = function_body(player, "AddDirectCraftingStepWork")
    direct_require = function_body(player, "RequireDirectCraftingMaterial")
    direct_refresh = function_body(player, "RefreshDirectWeaponCraftingPlan")
    require(
        "ancestorTimeFactor" not in player
        and "rootBranchTimeFactor" not in player
        and "childAncestorTimeFactor" not in player,
        "Permanece un multiplicador temporal heredado",
    )
    require(
        "GetCraftingMaterialWorkSeconds(" in blueprint
        and "GetCraftingEfficiencyTimeFactor(" not in blueprint,
        "El árbol no aísla la eficiencia propia de cada operación",
    )
    require(
        "GetCraftingMaterialWorkSeconds(" in direct_step
        and "GetCraftingEfficiencyTimeFactor(" not in direct_step,
        "La ruta real vuelve a multiplicar la eficiencia de una capa",
    )
    require(
        "GetCraftingEfficiencyTimeFactor(" not in direct_require
        and "GetCraftingEfficiencyTimeFactor(" not in direct_refresh,
        "La ruta directa todavía hereda factores de sus padres",
    )
    require(
        "GetCraftingEfficiencyTimeFactor(efficiencyIndex)" in rules,
        "La propia operación dejó de aplicar su eficiencia",
    )

    # La merma continúa propagando cantidades, pero nunca factores temporales.
    percentages = (25, 50, 100)
    factors = (1.0, 10.0, 100.0)
    units = [adjusted_units(100, value) for value in percentages]
    require(units == [400, 200, 100], f"Merma inesperada: {units}")
    work = [
        own_work(amount, 1, factor, 5150.0)
        for amount, factor in zip(units, factors, strict=True)
    ]
    require(work[0] < work[1] < work[2], "El tiempo propio no crece por grado")
    require(math.isclose(work[1] / work[0], 5.0), "Relación 25->50 incorrecta")
    require(math.isclose(work[2] / work[1], 5.0), "Relación 50->100 incorrecta")
    child_fixed = own_work(400, 1, 1.0, 5150.0)
    corrected_branch = work[2] + child_fixed
    inherited_branch = work[2] + child_fixed * factors[2]
    require(
        corrected_branch < inherited_branch
        and math.isclose(
            corrected_branch - work[2], child_fixed, rel_tol=1e-12
        ),
        "La operación hija no conserva su tiempo independiente",
    )

    scaled_material = function_body(player, "AddScaledEquipmentTaskMaterial")
    repair = function_body(player, "BeginRepairSelectedEquipment")
    require(
        "RequireDirectCraftingMaterial(" in scaled_material,
        "Reparar no resuelve componentes desde materias primas",
    )
    require(
        "ClearDirectCraftingPlan();" in repair
        and "ReservePreparedDirectCraftingPlan()" in repair
        and "CraftingPlanStepSeconds[step]" in repair,
        "La reparación no prepara, reserva y temporiza su ruta recursiva",
    )
    require(
        "CRAFTING_ACTION_FAILED_MATERIALS" not in repair
        and "EQUIPMENT_ACTION_FAILED_MATERIALS" in repair,
        "La reparación todavía publica el mensaje de fabricación",
    )

    require(
        "CA_JOURNAL_CRAFTING_HELP_2" in journal
        and "CA_JOURNAL_CRAFTING_MATERIAL_USED" in journal
        and "MATERIAL_UNIT_WEIGHT" in journal,
        "La interfaz no separa ayuda o unidades de material",
    )
    require(
        'CA_JOURNAL_CRAFTING_HELP_2 = "R talle | E crear | F reparar | D desarmar | C cancelar | T +10m | Q cerrar";'
        in language,
        "La ayuda española no muestra C cancelar",
    )
    require(
        "B lote de materiales" in language,
        "La ayuda española no muestra B lote",
    )
    require(
        language.count("CA_JOURNAL_CRAFTING_MATERIAL_USED") == 2
        and language.count("CA_EQUIPMENT_ACTION_FAILED_MATERIALS") == 2,
        "Faltan traducciones inglesas o españolas",
    )

    base_files = relative_files(base_root)
    runtime_files = relative_files(runtime)
    require(base_files.keys() == runtime_files.keys(), "Cambió el catálogo runtime")
    changed_runtime = {
        name
        for name in base_files
        if digest(base_files[name]) != digest(runtime_files[name])
    }
    require(
        changed_runtime == EXPECTED_RUNTIME_CHANGES,
        f"Cambios runtime inesperados: {sorted(changed_runtime ^ EXPECTED_RUNTIME_CHANGES)}",
    )

    base_zip = zip_digests(base_pk3)
    candidate_zip = zip_digests(candidate_pk3)
    require(base_zip.keys() == candidate_zip.keys(), "Cambió el catálogo del PK3")
    changed_zip = {name for name in base_zip if base_zip[name] != candidate_zip[name]}
    require(changed_zip == EXPECTED_RUNTIME_CHANGES, "Cambios inesperados en PK3")
    require(len(candidate_zip) == 3952, "El PK3 debe conservar sus 3952 archivos")
    with zipfile.ZipFile(candidate_pk3) as archive:
        require(len(archive.infolist()) == 4062, "El PK3 debe conservar 4062 entradas")
        require(archive.testzip() is None, "El PK3 está corrupto")

    print("4.31.0i audit passed")
    print("runtime changes: 5")
    print("efficiency: 25/50/100%; own operation only: 1x/10x/100x")
    print("repair: existing components plus recursive raw-material fallback")
    print("UI: B batch, C cancel, explicit material units and kilograms")
    print("PK3 entries: 4062; files: 3952")


if __name__ == "__main__":
    main()
