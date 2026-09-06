#!/usr/bin/env python3
"""Deterministic source and package audit for Caelum 4.32.0c."""

from __future__ import annotations

import argparse
import hashlib
import re
import struct
import zipfile
from itertools import product
from pathlib import Path


CHANGED_EXISTING = {
    "LANGUAGE",
    "caelum/actors/CaelumFolkloreCharacters.zs",
    "caelum/core/CaelumConstants.zs",
    "caelum/hud/CaelumJournalOverlay.zs",
    "caelum/player/CaelumPlayer.zs",
}
NEW_FILES: set[str] = set()
RUNTIME_DELTA = CHANGED_EXISTING | NEW_FILES
MAGIC_BOX_ICON_SHA256 = (
    "4e01ee0473bdbfa92ae1321b12f99ff6a7a6f737608c89d36cc99a422dccbdae"
)
MAGIC_BOX_ICON = "graphics/caelum/ui/journal/icons/ca_ui_magic_box.png"
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


def require(condition: bool, message: str) -> None:
    if not condition:
        raise AssertionError(message)


def sha256_bytes(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def sha256(path: Path) -> str:
    return sha256_bytes(path.read_bytes())


def file_set(root: Path) -> set[str]:
    return {
        path.relative_to(root).as_posix()
        for path in root.rglob("*")
        if path.is_file()
    }


def declared_constants(text: str) -> dict[str, str]:
    return dict(re.findall(
        r"(?m)^\s*const\s+([A-Za-z_][A-Za-z0-9_]*)\s*=\s*([^;]+);",
        text,
    ))


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
                f"unexpected delimiter in {label}:{index}",
            )
            stack.pop()
    require(not stack, f"unclosed delimiter in {label}: {stack[-1:]}")


def read_wad(path: Path) -> tuple[bytes, list[tuple[bytes, bytes]]]:
    data = path.read_bytes()
    require(len(data) >= 12, f"truncated WAD: {path}")
    magic, count, directory_offset = struct.unpack_from("<4sii", data, 0)
    require(magic in {b"PWAD", b"IWAD"}, f"invalid WAD magic: {path}")
    require(count > 0, f"empty WAD: {path}")
    lumps: list[tuple[bytes, bytes]] = []
    for index in range(count):
        entry = directory_offset + index * 16
        require(entry + 16 <= len(data), f"truncated WAD directory: {path}")
        offset, size, name = struct.unpack_from("<ii8s", data, entry)
        require(
            offset >= 0 and size >= 0 and offset + size <= len(data),
            f"bad WAD lump {index}: {path}",
        )
        lumps.append((name.rstrip(b"\0"), data[offset : offset + size]))
    return magic, lumps


def check_runtime_delta(runtime: Path, baseline: Path) -> None:
    base_files = file_set(baseline)
    candidate_files = file_set(runtime)
    require(candidate_files - base_files == NEW_FILES, "unexpected new runtime files")
    require(not (base_files - candidate_files), "runtime files were removed")
    changed = {
        relative
        for relative in base_files
        if (runtime / relative).read_bytes() != (baseline / relative).read_bytes()
    }
    require(changed == CHANGED_EXISTING, f"unexpected runtime delta: {changed}")


def check_map(runtime: Path, baseline: Path) -> None:
    _, current = read_wad(runtime / "maps/MAP01.wad")
    _, original = read_wad(baseline / "maps/MAP01.wad")
    require([name for name, _ in current] == [b"MAP01", b"TEXTMAP", b"ENDMAP"],
            "MAP01 lump order changed")
    require([name for name, _ in original] == [b"MAP01", b"TEXTMAP", b"ENDMAP"],
            "baseline MAP01 lump order unexpected")
    require(current[0][1] == original[0][1] and current[2][1] == original[2][1],
            "MAP01 marker lumps changed")
    current_text = current[1][1].decode("utf-8")
    require(current_text.count(PALOMO_BLOCK) == 1, "Palomo block is not exact")
    require((runtime / "maps/MAP01.wad").read_bytes()
            == (baseline / "maps/MAP01.wad").read_bytes(), "MAP01 changed")
    require(len(re.findall(r"(?m)^\s*type\s*=\s*18036\s*;", current_text)) == 1,
            "MAP01 must contain exactly one Palomo")
    require((runtime / "maps/MAP02.wad").read_bytes()
            == (baseline / "maps/MAP02.wad").read_bytes(), "MAP02 changed")


def check_sources(runtime: Path) -> None:
    for source in runtime.rglob("*.zs"):
        check_delimiter_text(source.read_text(encoding="utf-8"), str(source))
    check_delimiter_text((runtime / "MAPINFO").read_text(encoding="utf-8"), "MAPINFO")

    constants_path = runtime / "caelum/core/CaelumConstants.zs"
    constants_text = constants_path.read_text(encoding="utf-8")
    constants = declared_constants(constants_text)
    expected_constants = {
        "PALOMO_MERCHANT_ANCHORED": "1",
        "PALOMO_MERCHANT_SESSION_DISTANCE": "160.0",
        "PALOMO_MERCHANT_RETURN_DISTANCE": "500.0",
        "PALOMO_INTERACTION_REARM_GUARD_TICS": "2",
        "PALOMO_MERCHANT_ITEM_COUNT": "5",
        "PALOMO_MERCHANT_START_FOOD": "20",
        "PALOMO_MERCHANT_START_WATER": "20",
        "PALOMO_MERCHANT_START_WOOD": "100",
        "PALOMO_MERCHANT_START_RAW_COPPER": "50",
        "PALOMO_MERCHANT_START_RAW_TIN": "50",
        "PALOMO_MERCHANT_START_COPPER": "200",
        "EQUIPMENT_ACTION_FAILED_MAGIC_BOX_UNOWNED": "29",
    }
    for name, expected in expected_constants.items():
        require(constants.get(name, "").strip() == expected, f"bad constant {name}")

    referenced: set[str] = set()
    for source in runtime.rglob("*.zs"):
        referenced.update(re.findall(
            r"\bCaelumConstants\.([A-Za-z_][A-Za-z0-9_]*)\b",
            source.read_text(encoding="utf-8"),
        ))
    require(not (referenced - set(constants)),
            f"undeclared constants: {sorted(referenced - set(constants))}")

    economy = (runtime / "caelum/equipment/CaelumEconomy.zs").read_text("utf-8")
    for token in (
        "static clearscope int GetPalomoMerchantBaseValue",
        "static clearscope int GetPalomoMerchantLotPrice",
        "return (baseLot * 3 + 1) / 2;",
        "return baseLot / 2;",
        "play static double GetInventoryUnitBaseValue",
        "play static double GetInventoryStackBaseValue",
        "play static double GetEquipmentItemBaseValue",
    ):
        require(token in economy, f"missing economy contract: {token}")

    persistent = (runtime / "caelum/equipment/CaelumPersistentCharacterState.zs").read_text("utf-8")
    for token in (
        "int MagicBoxOwnershipVersion;",
        "bool MagicBoxOwned;",
        "int PalomoMerchantVersion;",
        "int PalomoMerchantStock[5];",
        "void EnsurePalomoMerchantInitialized()",
    ):
        require(token in persistent, f"missing persistent state: {token}")

    player = (runtime / "caelum/player/CaelumPlayer.zs").read_text("utf-8")
    for token in (
        "bool GrantMagicBoxFromPalomo()",
        "void OpenPalomoMerchant(Actor merchant)",
        "void ExecutePalomoMerchantTransaction()",
        "bool BuildPalomoCurrencyPaymentPlan(int copperAmount)",
        "bool BuildPalomoCurrencyCreditPlan(int copperAmount)",
        "void NormalizeUnownedMagicBoxStorage()",
        "EQUIPMENT_ACTION_FAILED_MAGIC_BOX_UNOWNED",
        "persistentState.InitializeNewMagicBoxOwnership();",
        "persistentState.EnsureMagicBoxOwnershipInitialized();",
        "UpdatePalomoMerchantSession();",
        "bool FolkloreInteractionUseLatched;",
        "int FolkloreInteractionReleaseGuardTics;",
        "int PalomoMerchantVisibleItemCount;",
        "int PalomoMerchantVisibleItems[CaelumConstants.PALOMO_MERCHANT_ITEM_COUNT];",
        "void CyclePalomoMerchantQuantity(int direction)",
        "&& !PalomoMerchantMenuOpen",
        "FolkloreInteractionReleaseGuardTics--",
        "PalomoMerchantWalletCopper",
        ">= CaelumEconomyRules.GetPalomoMerchantLotPrice(",
    ):
        require(token in player, f"missing player contract: {token}")
    require("if (!MagicBoxOwned || DerivedStats == null) { return false; }" in player,
            "Magic Box slot access is not ownership-gated")

    actors = (runtime / "caelum/actors/CaelumFolkloreCharacters.zs").read_text("utf-8")
    for token in (
        "class CaelumInteractiveFolkloreActor",
        "virtual bool InteractWithCaelumPlayer",
        "class CaelumPalomo : CaelumInteractiveFolkloreActor",
        "MerchantAnchored = args[0]",
        "MerchantReturningHome",
        ">= CaelumConstants.PALOMO_MERCHANT_RETURN_DISTANCE",
        "* CaelumConstants.GZDOOM_BASE_MAX_RUN_SPEED",
        "caelumPlayer.FolkloreInteractionUseLatched",
        "(caelumPlayer.player.cmd.buttons & BT_USE) == 0",
        "caelumPlayer.OpenPalomoMerchant(self);",
    ):
        require(token in actors, f"missing Palomo interaction: {token}")

    journal = (runtime / "caelum/hud/CaelumJournalOverlay.zs").read_text("utf-8")
    for token in (
        "graphics/caelum/icons/currency/ca_coin_silver.png",
        "graphics/caelum/ui/journal/icons/ca_ui_magic_box.png",
        "ui void DrawPalomoMerchant",
        'SendNetworkEvent("ca_palomo_merchant_transact")',
        'e.Name == "ca_palomo_merchant_transact"',
        'SendNetworkEvent("ca_palomo_merchant_quantity_previous")',
        'SendNetworkEvent("ca_palomo_merchant_quantity_next")',
        'SendNetworkEvent("ca_palomo_merchant_mode")',
        "localPlayer.PalomoMerchantVisibleItems[visibleRow]",
        "CA_PALOMO_MERCHANT_NOTHING_TO_SELL",
    ):
        require(token in journal, f"missing merchant UI: {token}")
    require('SendNetworkEvent("ca_palomo_merchant_quantity");' not in journal,
            "obsolete one-way lot control remains")

    language = (runtime / "LANGUAGE").read_text(encoding="utf-8")
    required_keys = {
        "CA_MAGIC_BOX_NOT_ACQUIRED",
        "CA_PALOMO_MAGIC_BOX_RECEIVED",
        "CA_PALOMO_MERCHANT_TITLE",
        "CA_PALOMO_MERCHANT_ACTION_BOUGHT",
        "CA_PALOMO_MERCHANT_ACTION_SOLD",
        "CA_PALOMO_MERCHANT_ACTION_FAILED_CAPACITY",
        "CA_PALOMO_MERCHANT_NOTHING_TO_SELL",
    }
    for key in required_keys:
        definitions = re.findall(rf"(?m)^{re.escape(key)}\s*=", language)
        require(len(definitions) == 2, f"{key} must have EN and ES definitions")
    language_keys = set(re.findall(r"(?m)^([A-Z][A-Z0-9_]*)\s*=", language))
    literal_refs: set[str] = set()
    for source in runtime.rglob("*.zs"):
        literal_refs.update(re.findall(r'"(CA_[A-Z0-9_]+)"', source.read_text("utf-8")))
    require(not (literal_refs - language_keys),
            f"missing LANGUAGE keys: {sorted(literal_refs - language_keys)}")

    require(
        'CA_PALOMO_MERCHANT_HELP = "Up/Down item | Left/Right lot | Space/X buy/sell | Enter/A confirm | Q/Esc close";'
        in language,
        "English merchant help does not match the accepted controls",
    )
    require(
        'CA_PALOMO_MERCHANT_HELP = "Arriba/Abajo objeto | Izq./Der. lote | Espacio/X comprar/vender | Enter/A confirmar | Q/Esc cerrar";'
        in language,
        "Spanish merchant help does not match the accepted controls",
    )

    icon = runtime / MAGIC_BOX_ICON
    data = icon.read_bytes()
    require(sha256_bytes(data) == MAGIC_BOX_ICON_SHA256, "Magic Box icon digest changed")
    require(data[:8] == b"\x89PNG\r\n\x1a\n" and data[12:16] == b"IHDR",
            "Magic Box icon is not a PNG")
    width, height, bit_depth, color_type = struct.unpack(">IIBB", data[16:26])
    require((width, height, bit_depth, color_type) == (64, 64, 8, 6),
            "Magic Box icon must be 64x64 RGBA8")


def check_price_and_change_model() -> None:
    base_values = [4, 6, 2, 5, 5]
    expected_buy = [6, 9, 3, 8, 8]
    expected_sell = [2, 3, 1, 2, 2]
    require([(value * 3 + 1) // 2 for value in base_values] == expected_buy,
            "unit buy prices changed")
    require([value // 2 for value in base_values] == expected_sell,
            "unit sell prices changed")
    require((5 * 5 * 3 + 1) // 2 == 38 and (5 * 5) // 2 == 12,
            "lot rounding changed")

    faces = [1, 5, 20, 50, 100, 200, 1000, 4000, 10000, 20000,
             40000, 200000, 800000, 2000000, 4000000]

    def payment_plan(amounts: list[int], price: int) -> list[int] | None:
        result = amounts.copy()
        remaining = price
        for index in range(len(faces) - 1, -1, -1):
            take = min(result[index], remaining // faces[index])
            result[index] -= take
            remaining -= take * faces[index]
        change = 0
        if remaining:
            for index, face in enumerate(faces):
                if result[index] > 0 and face > remaining:
                    result[index] -= 1
                    change = face - remaining
                    remaining = 0
                    break
        if remaining:
            return None
        for index in range(len(faces) - 1, -1, -1):
            returned = change // faces[index]
            result[index] += returned
            change -= returned * faces[index]
        return result if change == 0 else None

    checked = 0
    for low_amounts in product(range(3), repeat=5):
        amounts = list(low_amounts) + [0] * 10
        old_value = sum(amount * face for amount, face in zip(amounts, faces))
        for price in range(old_value + 1):
            result = payment_plan(amounts, price)
            require(result is not None and min(result) >= 0,
                    "payment planner failed an affordable holding")
            new_value = sum(amount * face for amount, face in zip(result, faces))
            require(new_value == old_value - price, "payment planner creates value")
            checked += 1
    require(checked > 10_000, "currency planner audit was not exhaustive enough")


def check_merchant_navigation_model() -> None:
    quantities = [1, 5, 20, 50, 100]

    def cycle(index: int, direction: int) -> int:
        return (index + (len(quantities) - 1 if direction < 0 else 1)) % len(quantities)

    forward: list[int] = []
    index = 0
    for _ in quantities:
        index = cycle(index, 1)
        forward.append(quantities[index])
    require(forward == [5, 20, 50, 100, 1], "right lot cycle changed")

    backward: list[int] = []
    index = 0
    for _ in quantities:
        index = cycle(index, -1)
        backward.append(quantities[index])
    require(backward == [100, 50, 20, 5, 1], "left lot cycle changed")

    sell_prices = [2, 3, 1, 2, 2]

    def visible_sell(owned: list[int], wallet: int) -> list[int]:
        return [
            item for item, amount in enumerate(owned)
            if amount > 0 and wallet >= sell_prices[item]
        ]

    require(visible_sell([0, 1, 4, 0, 0], 200) == [1, 2],
            "sell list is not compacted to owned products")
    require(visible_sell([0, 1, 4, 0, 0], 2) == [2],
            "sell list ignores Palomo's one-unit affordability")
    require(visible_sell([0, 0, 0, 0, 0], 200) == [],
            "empty sell state changed")


def check_candidate(runtime: Path, base_pk3: Path, candidate_pk3: Path) -> None:
    with zipfile.ZipFile(base_pk3) as base, zipfile.ZipFile(candidate_pk3) as candidate:
        require(base.testzip() is None, "base PK3 is corrupt")
        require(candidate.testzip() is None, "candidate PK3 is corrupt")
        base_names = [item.filename for item in base.infolist() if not item.is_dir()]
        names = [item.filename for item in candidate.infolist() if not item.is_dir()]
        require(len(names) == len(set(names)), "candidate PK3 has duplicate entries")
        require(set(names) == set(base_names), "candidate PK3 entry set changed")
        for name in names:
            require(candidate.read(name) == (runtime / name).read_bytes(),
                    f"candidate/runtime mismatch: {name}")
        for name in set(base_names) - CHANGED_EXISTING:
            require(candidate.read(name) == base.read(name), f"unchanged PK3 entry differs: {name}")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--runtime-root", type=Path, required=True)
    parser.add_argument("--baseline-runtime", type=Path, required=True)
    parser.add_argument("--base-pk3", type=Path)
    parser.add_argument("--candidate-pk3", type=Path)
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    check_runtime_delta(args.runtime_root, args.baseline_runtime)
    check_sources(args.runtime_root)
    check_map(args.runtime_root, args.baseline_runtime)
    check_price_and_change_model()
    check_merchant_navigation_model()
    if args.base_pk3 or args.candidate_pk3:
        require(args.base_pk3 is not None and args.candidate_pk3 is not None,
                "both PK3 paths are required together")
        check_candidate(args.runtime_root, args.base_pk3, args.candidate_pk3)
    print("Caelum 4.32.0c audit passed")
    print(f"Runtime delta: {len(CHANGED_EXISTING)} changed + {len(NEW_FILES)} new files")
    print("MAP01/MAP02: byte-identical to accepted 4.32.0b")
    print("Palomo: Use-release latch, filtered sale list and 500-MU return contract present")
    print("Merchant navigation/filter model: bidirectional lot and eligibility checks passed")
    print("Currency planner: exhaustive low-denomination conservation checks passed")


if __name__ == "__main__":
    main()
