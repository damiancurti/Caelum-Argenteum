#!/usr/bin/env python3
"""Audita la economía y la Caja Mágica de Caelum 4.32.0a-r3."""

from __future__ import annotations

import argparse
import hashlib
import math
import re
import struct
import zipfile
from pathlib import Path


EXISTING_RUNTIME_CHANGES = {
    "ZSCRIPT",
    "LANGUAGE",
    "caelum/core/CaelumConstants.zs",
    "caelum/ui/CaelumDisplayNames.zs",
    "caelum/player/CaelumPlayer.zs",
    "caelum/hud/CaelumJournalOverlay.zs",
    "caelum/debug/CaelumDebugOverlay.zs",
    "caelum/equipment/CaelumConsumables.zs",
    "caelum/equipment/CaelumEquipmentPickups.zs",
    "caelum/equipment/CaelumPersistentCharacterState.zs",
    "caelum/equipment/CaelumSpecialItems.zs",
    "caelum/statistics/CaelumDerivedStats.zs",
}

NEW_RUNTIME_FILES = {
    "caelum/equipment/CaelumEconomy.zs",
    "graphics/caelum/icons/currency/ca_coin_copper.png",
    "graphics/caelum/icons/currency/ca_coin_silver.png",
    "graphics/caelum/icons/currency/ca_coin_gold.png",
    "sprites/caelum/currency/CCOPA0.png",
    "sprites/caelum/currency/CSILA0.png",
    "sprites/caelum/currency/CGOLA0.png",
}

RUNTIME_CHANGES = EXISTING_RUNTIME_CHANGES | NEW_RUNTIME_FILES

ICON_DIGESTS = {
    "graphics/caelum/icons/currency/ca_coin_copper.png":
        "1a9d5909ea825f1898424df7dcb14a660455904e0ba863ee503eabb3adddc1bb",
    "graphics/caelum/icons/currency/ca_coin_silver.png":
        "58b3a04fd5ce8184e52bab7c69b899e3799bd53e7379b05ad11af902afa6760d",
    "graphics/caelum/icons/currency/ca_coin_gold.png":
        "16d90390d480f92721c7c2c423e3c3ea4458c6d0d06ed288259da87f4d5b7066",
}

RAW_VALUES = {
    "MATERIAL_WOOD": 2.0,
    "MATERIAL_PLANT_FIBER": 3.0,
    "MATERIAL_WOOL": 2.0,
    "MATERIAL_COTTON": 4.0,
    "MATERIAL_RAW_SILK": 8.0,
    "MATERIAL_COW_HIDE": 3.0,
    "MATERIAL_PREDATOR_HIDE": 4.0,
    "MATERIAL_MONSTER_HIDE": 8.0,
    "MATERIAL_COAL": 5.0,
    "MATERIAL_RAW_COPPER": 5.0,
    "MATERIAL_RAW_IRON": 7.0,
    "MATERIAL_RAW_TIN": 5.0,
    "MATERIAL_RAW_SILVER": 100.0,
    "MATERIAL_RAW_GOLD": 1000.0,
    "MATERIAL_RAW_OPAL": 500.0,
    "MATERIAL_RAW_TOPAZ": 500.0,
    "MATERIAL_RAW_EMERALD": 500.0,
    "MATERIAL_RAW_SAPPHIRE": 500.0,
    "MATERIAL_RAW_RUBY": 500.0,
}

CURRENCY_CLASSES = {
    "CaelumCopperCoin": "CURRENCY_COPPER",
    "CaelumCopperCoin5": "CURRENCY_COPPER_FIVE",
    "CaelumCopperCoin20": "CURRENCY_COPPER_TWENTY",
    "CaelumCopperCoin50": "CURRENCY_COPPER_FIFTY",
    "CaelumCopperCoin100": "CURRENCY_COPPER_HUNDRED",
    "CaelumSilverCoin": "CURRENCY_SILVER",
    "CaelumSilverCoin5": "CURRENCY_SILVER_FIVE",
    "CaelumSilverCoin20": "CURRENCY_SILVER_TWENTY",
    "CaelumSilverCoin50": "CURRENCY_SILVER_FIFTY",
    "CaelumSilverCoin100": "CURRENCY_SILVER_HUNDRED",
    "CaelumGoldCoin": "CURRENCY_GOLD",
    "CaelumGoldCoin5": "CURRENCY_GOLD_FIVE",
    "CaelumGoldCoin20": "CURRENCY_GOLD_TWENTY",
    "CaelumGoldCoin50": "CURRENCY_GOLD_FIFTY",
    "CaelumGoldCoin100": "CURRENCY_GOLD_HUNDRED",
}


def require(condition: bool, message: str) -> None:
    if not condition:
        raise AssertionError(message)


def digest_bytes(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def digest(path: Path) -> str:
    return digest_bytes(path.read_bytes())


def zip_digests(path: Path) -> dict[str, str]:
    with zipfile.ZipFile(path) as archive:
        return {
            info.filename: digest_bytes(archive.read(info.filename))
            for info in archive.infolist()
            if not info.is_dir()
        }


def declared_constants(text: str) -> dict[str, str]:
    return dict(re.findall(
        r"(?m)^\s*const\s+([A-Za-z_][A-Za-z0-9_]*)\s*=\s*([^;]+);",
        text,
    ))


def referenced_constants_in_pk3(candidate_pk3: Path) -> set[str]:
    references: set[str] = set()
    with zipfile.ZipFile(candidate_pk3) as archive:
        for info in archive.infolist():
            if info.is_dir() or not info.filename.lower().endswith(".zs"):
                continue
            source_text = archive.read(info.filename).decode("utf-8")
            references.update(re.findall(
                r"\bCaelumConstants\.([A-Za-z_][A-Za-z0-9_]*)\b",
                source_text,
            ))
    return references


def check_delimiter_text(text: str, label: str) -> None:
    text = re.sub(r"/\*.*?\*/", "", text, flags=re.DOTALL)
    text = re.sub(r"//[^\n]*", "", text)
    text = re.sub(r'"(?:\\.|[^"\\])*"', '""', text)
    pairs = {"{": "}", "(": ")", "[": "]"}
    stack: list[tuple[str, int]] = []
    for index, character in enumerate(text):
        if character in pairs:
            stack.append((character, index))
        elif character in pairs.values():
            require(
                bool(stack) and pairs[stack[-1][0]] == character,
                f"Delimitador inesperado en {label}:{index}",
            )
            stack.pop()
    require(
        not stack,
        f"Delimitador sin cerrar en {label}:{stack[-1] if stack else ''}",
    )


def check_delimiters(source: Path) -> None:
    check_delimiter_text(source.read_text(encoding="utf-8"), str(source))


def check_candidate_delimiters(candidate_pk3: Path) -> None:
    with zipfile.ZipFile(candidate_pk3) as archive:
        for info in archive.infolist():
            if info.is_dir() or not info.filename.lower().endswith(".zs"):
                continue
            check_delimiter_text(
                archive.read(info.filename).decode("utf-8"),
                f"{candidate_pk3}!/{info.filename}",
            )


def png_header(path: Path) -> tuple[int, int, int, int]:
    data = path.read_bytes()
    require(data[:8] == b"\x89PNG\r\n\x1a\n", f"No es PNG: {path}")
    require(data[12:16] == b"IHDR", f"PNG sin IHDR: {path}")
    width, height, bit_depth, color_type = struct.unpack(">IIBB", data[16:26])
    return width, height, bit_depth, color_type


def check_economy_source(runtime: Path) -> None:
    constants_text = (runtime / "caelum/core/CaelumConstants.zs").read_text(
        encoding="utf-8"
    )
    constants = declared_constants(constants_text)
    exact = {
        "EQUIPMENT_KIND_CURRENCY": "10",
        "EQUIPMENT_KIND_COUNT": "11",
        "CURRENCY_COPPER": "0",
        "CURRENCY_COPPER_FIVE": "1",
        "CURRENCY_COPPER_TWENTY": "2",
        "CURRENCY_COPPER_FIFTY": "3",
        "CURRENCY_COPPER_HUNDRED": "4",
        "CURRENCY_SILVER": "5",
        "CURRENCY_SILVER_FIVE": "6",
        "CURRENCY_SILVER_TWENTY": "7",
        "CURRENCY_SILVER_FIFTY": "8",
        "CURRENCY_SILVER_HUNDRED": "9",
        "CURRENCY_GOLD": "10",
        "CURRENCY_GOLD_FIVE": "11",
        "CURRENCY_GOLD_TWENTY": "12",
        "CURRENCY_GOLD_FIFTY": "13",
        "CURRENCY_GOLD_HUNDRED": "14",
        "CURRENCY_TYPE_COUNT": "15",
        "CURRENCY_DENOMINATION_COUNT": "5",
        "CURRENCY_METAL_COPPER": "0",
        "CURRENCY_METAL_SILVER": "1",
        "CURRENCY_METAL_GOLD": "2",
        "CURRENCY_METAL_TYPE_COUNT": "3",
        "CURRENCY_COPPER_VALUE": "1",
        "CURRENCY_SILVER_VALUE": "200",
        "CURRENCY_GOLD_VALUE": "40000",
        "CURRENCY_UNIT_WEIGHT": "0.001",
        "ECONOMY_FOOD_RATION_VALUE": "4",
        "ECONOMY_WATER_RATION_VALUE": "6",
        "MATERIAL_UNIT_WEIGHT": "0.001",
        "ECONOMY_REFERENCE_EFFICIENCY_INDEX": "2",
        "ECONOMY_PROCESSING_MARKUP_PERCENT": "25",
        "ECONOMY_TIER_ONE_MARKUP_PERCENT": "25",
        "ECONOMY_TIER_TWO_MARKUP_PERCENT": "50",
        "ECONOMY_TIER_THREE_MARKUP_PERCENT": "100",
        "ECONOMY_MERCHANT_PAYS_MULTIPLIER": "0.50",
        "ECONOMY_MERCHANT_CHARGES_MULTIPLIER": "1.50",
    }
    for name, expected in exact.items():
        require(constants.get(name, "").strip() == expected, f"Valor incorrecto: {name}")

    economy = (runtime / "caelum/equipment/CaelumEconomy.zs").read_text(
        encoding="utf-8"
    )
    for class_name in (
        "CaelumCurrencyItem", *CURRENCY_CLASSES, "CaelumEconomyRules",
    ):
        require(
            re.search(rf"\bclass\s+{class_name}\b", economy) is not None,
            f"Falta clase {class_name}",
        )
    for class_name, currency_constant in CURRENCY_CLASSES.items():
        block = re.search(
            rf"\bclass\s+{class_name}\b(?P<body>.*?)(?=\nclass\s+|\Z)",
            economy,
            flags=re.DOTALL,
        )
        require(block is not None, f"No se pudo leer {class_name}")
        require(
            f"CaelumConstants.{currency_constant}" in block.group("body"),
            f"Tipo monetario incorrecto en {class_name}",
        )
    for sprite in ("CCOP A -1", "CSIL A -1", "CGOL A -1"):
        require(sprite in economy, f"Estado de moneda ausente: {sprite}")

    for helper in (
        "GetCurrencyMetalType",
        "GetCurrencyDenomination",
        "GetCurrencyMetalUnitValue",
        "GetCurrencyFaceValue",
        "GetCurrencyClassName",
    ):
        require(helper in economy, f"Falta helper monetario {helper}")
    for source_fragment in (
        "case 1: return 5;",
        "case 2: return 20;",
        "case 3: return 50;",
        "case 4: return 100;",
        "return GetCurrencyDenomination(currencyType)",
        "* GetCurrencyMetalUnitValue(GetCurrencyMetalType(currencyType))",
    ):
        require(source_fragment in economy, f"Escala nominal incompleta: {source_fragment}")

    for material, expected in RAW_VALUES.items():
        match = re.search(
            rf"case\s+CaelumConstants\.{material}:\s*return\s+([0-9.]+)\s*;",
            economy,
        )
        require(match is not None, f"Falta ancla económica {material}")
        require(float(match.group(1)) == expected, f"Ancla incorrecta {material}")

    require(
        "GetProcessingOutputUnitsAtEfficiency" in economy
        and "ECONOMY_REFERENCE_EFFICIENCY_INDEX" in economy,
        "El precio de procesamiento no usa eficiencia 100 %",
    )
    require(
        re.search(r"static\s+int\s+GetPricePaidByMerchant", economy) is not None
        and "ECONOMY_MERCHANT_PAYS_MULTIPLIER" in economy
        and "RoundCopperDown" in economy,
        "Falta margen/redondeo de compra del NPC",
    )
    require(
        re.search(r"static\s+int\s+GetPriceChargedByMerchant", economy) is not None
        and "ECONOMY_MERCHANT_CHARGES_MULTIPLIER" in economy
        and "RoundCopperUp" in economy,
        "Falta margen/redondeo de venta del NPC",
    )

    # Casos numéricos de referencia independientes del runtime.
    copper_ingot = RAW_VALUES["MATERIAL_RAW_COPPER"] * 1.25
    tin_ingot = RAW_VALUES["MATERIAL_RAW_TIN"] * 1.25
    bronze_ingot = (9 * copper_ingot + tin_ingot) * 1.25 / 10
    iron_ingot = RAW_VALUES["MATERIAL_RAW_IRON"] * 1.25
    steel_ingot = (
        497 * iron_ingot + 3 * RAW_VALUES["MATERIAL_COAL"]
    ) * 1.25 / 500
    require(copper_ingot == 6.25, "Referencia de lingote de cobre incorrecta")
    require(bronze_ingot == 7.8125, "Referencia de bronce incorrecta")
    require(abs(steel_ingot - 10.909375) < 1e-9, "Referencia de acero incorrecta")
    require(int(1 * 2.0 * 0.50) == 1, "Redondeo de lote vendido incorrecto")
    require(
        "GetConsumableUnitBaseValue" in economy
        and "ECONOMY_FOOD_RATION_VALUE" in economy
        and "ECONOMY_WATER_RATION_VALUE" in economy,
        "Faltan valores autorizados de comida/agua",
    )
    denominations = (1, 5, 20, 50, 100)
    metal_values = (1, 200, 40000)
    require(
        sum(denomination * metal_value
            for denomination in denominations
            for metal_value in metal_values) == 7075376,
        "Total nominal de referencia incorrecto",
    )


def check_ui_and_language(runtime: Path) -> None:
    player = (runtime / "caelum/player/CaelumPlayer.zs").read_text(encoding="utf-8")
    journal = (runtime / "caelum/hud/CaelumJournalOverlay.zs").read_text(encoding="utf-8")
    language = (runtime / "LANGUAGE").read_text(encoding="utf-8")
    require("FORMAL_INVENTORY_FILTER_COUNT = 10" in player, "Falta filtro de monedas")
    for field in (
        "HUDCopperCoinCount",
        "HUDSilverCoinCount",
        "HUDGoldCoinCount",
        "HUDTotalMoneyCopperValue",
    ):
        require(field in player and field in journal, f"Falta instantánea UI {field}")
    for field in (
        "HUDMagicBoxRawContentWeight",
        "HUDMagicBoxReducedContentWeight",
        "HUDMagicBoxTotalWeight",
    ):
        require(field in player, f"Falta instantánea de Caja Mágica {field}")
    for icon in ICON_DIGESTS:
        require(icon in journal or icon.endswith("ca_coin_gold.png"), f"Falta icono UI {icon}")
    for key in (
        "CA_JOURNAL_FILTER_CURRENCY",
        "CA_CURRENCY_COPPER_COIN",
        "CA_CURRENCY_COPPER_COIN_5",
        "CA_CURRENCY_COPPER_COIN_20",
        "CA_CURRENCY_COPPER_COIN_50",
        "CA_CURRENCY_COPPER_COIN_100",
        "CA_CURRENCY_SILVER_COIN",
        "CA_CURRENCY_SILVER_COIN_5",
        "CA_CURRENCY_SILVER_COIN_20",
        "CA_CURRENCY_SILVER_COIN_50",
        "CA_CURRENCY_SILVER_COIN_100",
        "CA_CURRENCY_GOLD_COIN",
        "CA_CURRENCY_GOLD_COIN_5",
        "CA_CURRENCY_GOLD_COIN_20",
        "CA_CURRENCY_GOLD_COIN_50",
        "CA_CURRENCY_GOLD_COIN_100",
        "CA_ECONOMY_TOTAL_MONEY",
        "CA_CRAFTING_ACTION_FAILED_CARRY_CAPACITY",
    ):
        require(language.count(key + " =") >= 2, f"Falta traducción enu/es: {key}")
    require(
        "HUDMagicBoxTotalWeight" in journal,
        "El inventario no muestra el peso total de la Caja Mágica",
    )
    require(
        "weight is now zero" not in language
        and "ahora pesa cero" not in language,
        "LANGUAGE conserva el contrato obsoleto de peso cero",
    )


def check_magic_box_source(runtime: Path) -> None:
    constants_text = (runtime / "caelum/core/CaelumConstants.zs").read_text(
        encoding="utf-8"
    )
    constants = declared_constants(constants_text)
    require(
        constants.get("MAGIC_BOX_BASE_WEIGHT", "").strip() == "10.0",
        "El peso base de la Caja Mágica no es 10 kg",
    )
    require(
        constants.get("MAGIC_BOX_WEIGHT_PRECISION", "").strip() == "0.001",
        "La precisión de la Caja Mágica no es 0,001 kg",
    )

    player = (runtime / "caelum/player/CaelumPlayer.zs").read_text(
        encoding="utf-8"
    )
    for fragment in (
        "int GetMagicBoxWeightDivisor()",
        "return Max(1, DerivedStats.MagicBoxCapacity);",
        "double CalculateMagicBoxReducedContentWeight",
        "Floor(reducedWeight / precision + 0.0000001) * precision",
        "double CalculateMagicBoxTotalWeight",
        "+ CalculateMagicBoxReducedContentWeight(rawContentWeight)",
        "bool CanApplyInventoryWeightTransition",
        "bool CanAddRawWeightToMagicBox",
        "bool CanMoveRawWeightFromMagicBoxToPersonal",
        "bool CanCompletePreparedMaterialOutput",
        "bool CanCompletePreparedEquipmentOutput",
        "bool CanCompletePreparedDismantle",
        "personalInventoryWeight += HUDMagicBoxTotalWeight;",
        "carriedItemWeight += HUDMagicBoxTotalWeight;",
    ):
        require(fragment in player, f"Falta contrato de Caja Mágica: {fragment}")
    require(
        player.count("magicBoxRawContentWeight +=") == 4,
        "El peso bruto no cubre exactamente equipo, munición, consumibles y especiales",
    )
    require(
        "EQUIPMENT_ACTION_FAILED_KEY_STORAGE" in player
        and "CaelumCarbineAmmo carbineStack" in player
        and "if (carbineStack == null)" in player,
        "Cambiaron las restricciones existentes de Caja Mágica",
    )

    def reduced(raw_weight: float, maximum_slots: int) -> float:
        return math.floor(
            raw_weight / max(1, maximum_slots) / 0.001 + 1e-7
        ) * 0.001

    require(reduced(0.0, 20) == 0.0, "Caja vacía con contenido no nulo")
    require(reduced(10.0, 20) == 0.5, "División 10 kg / 20 incorrecta")
    require(
        abs(reduced(0.38, 20) - 0.019) < 1e-12,
        "El agregado de pilas no conserva el redondeo único",
    )
    require(
        10.0 + reduced(10.0, 20) == 10.5,
        "La caja no suma estructura y contenido correctamente",
    )

    magic_box_doc = (runtime.parent / "docs/MAGIC_BOX.md")
    if magic_box_doc.is_file():
        documentation = magic_box_doc.read_text(encoding="utf-8")
        for fragment in (
            "10,000 kg",
            "peso real total guardado / slots máximos actuales",
            "Se usan los **slots máximos**, no los ocupados",
            "llaves comunes",
            "flechas y virotes",
        ):
            require(fragment in documentation, f"Documento incompleto: {fragment}")


def check_assets(runtime: Path) -> None:
    sprite_for_icon = {
        "graphics/caelum/icons/currency/ca_coin_copper.png":
            "sprites/caelum/currency/CCOPA0.png",
        "graphics/caelum/icons/currency/ca_coin_silver.png":
            "sprites/caelum/currency/CSILA0.png",
        "graphics/caelum/icons/currency/ca_coin_gold.png":
            "sprites/caelum/currency/CGOLA0.png",
    }
    for icon, expected_digest in ICON_DIGESTS.items():
        icon_path = runtime / icon
        require(digest(icon_path) == expected_digest, f"Checksum incorrecto: {icon}")
        require(png_header(icon_path) == (64, 64, 8, 6), f"Formato PNG incorrecto: {icon}")
        sprite_path = runtime / sprite_for_icon[icon]
        require(digest(sprite_path) == expected_digest, f"Sprite distinto del icono: {sprite_path}")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--runtime-root", type=Path, required=True)
    parser.add_argument("--project-root", type=Path, required=True)
    parser.add_argument("--base-pk3", type=Path, required=True)
    parser.add_argument("--candidate-pk3", type=Path, required=True)
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    runtime = args.runtime_root.resolve()
    project = args.project_root.resolve()
    base_pk3 = args.base_pk3.resolve()
    candidate_pk3 = args.candidate_pk3.resolve()
    for directory in (runtime, project):
        require(directory.is_dir(), f"No existe el directorio: {directory}")
    for package in (base_pk3, candidate_pk3):
        require(package.is_file(), f"No existe el paquete: {package}")

    check_economy_source(runtime)
    check_ui_and_language(runtime)
    check_magic_box_source(runtime)
    check_assets(runtime)
    for source in runtime.rglob("*.zs"):
        check_delimiters(source)
    check_candidate_delimiters(candidate_pk3)

    constants_text = (runtime / "caelum/core/CaelumConstants.zs").read_text(
        encoding="utf-8"
    )
    constants = set(declared_constants(constants_text))
    references = referenced_constants_in_pk3(candidate_pk3)
    require(not references - constants, f"Constantes sin declarar: {sorted(references - constants)}")

    zscript = (runtime / "ZSCRIPT").read_text(encoding="utf-8")
    economy_include = '#include "caelum/equipment/CaelumEconomy.zs"'
    require(zscript.count(economy_include) == 1, "Include de economía inválido")
    require(
        zscript.index('#include "caelum/equipment/CaelumSpecialItems.zs"')
        < zscript.index(economy_include)
        < zscript.index('#include "caelum/player/CaelumPlayer.zs"'),
        "Orden de include de economía inválido",
    )

    base = zip_digests(base_pk3)
    candidate = zip_digests(candidate_pk3)
    require(not (base.keys() - candidate.keys()), "El PK3 eliminó archivos runtime")
    added = candidate.keys() - base.keys()
    require(added == NEW_RUNTIME_FILES, f"Archivos runtime añadidos inesperados: {sorted(added)}")
    changed = {
        name for name in base.keys() & candidate.keys()
        if base[name] != candidate[name]
    }
    require(
        changed == EXISTING_RUNTIME_CHANGES,
        f"Cambios runtime existentes inesperados: {sorted(changed)}",
    )
    for relative in RUNTIME_CHANGES:
        require(
            candidate[relative] == digest(runtime / relative),
            f"El PK3 no coincide con la fuente: {relative}",
        )
    with zipfile.ZipFile(candidate_pk3) as archive:
        require(archive.testzip() is None, "El PK3 candidato está corrupto")

    for relative in (
        "APLICAR_4_32_0a_r3.txt",
        "PRUEBAS_4_32_0a_r3.txt",
        "docs/ECONOMY.md",
        "docs/MAGIC_BOX.md",
        "docs/IMPLEMENTATION_STATUS.md",
        "docs/ROADMAP.md",
    ):
        require((project / relative).is_file(), f"Falta documento: {relative}")

    print("4.32.0a-r3 audit passed")
    print("currency: denominations = 1/5/20/50/100; metal step = 200:1")
    print("currency: copper/silver/gold unit = 1/200/40000; weight = 0.001 kg")
    print("manufacturing: processing 25%; tiers 25/50/100%; merchant 50/150%")
    print("magic box: 10 kg base + floor_0.001(raw content / maximum slots)")
    print(f"constants referenced/declared: {len(references)}/{len(constants)}")
    print(f"PK3 entries: {len(candidate)} ({len(added)} added, {len(changed)} changed)")


if __name__ == "__main__":
    main()
