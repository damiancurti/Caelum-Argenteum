#!/usr/bin/env python3
"""Deterministic source/package audit for Caelum Argenteum 4.32.0d."""

from __future__ import annotations

import argparse
import hashlib
import re
import struct
import zipfile
from pathlib import Path, PurePosixPath


NON_ICON_CHANGED_EXISTING = {
    "LANGUAGE",
    "MAPINFO",
    "ZSCRIPT",
    "caelum/actors/CaelumFolkloreCharacters.zs",
    "caelum/core/CaelumConstants.zs",
    "caelum/debug/CaelumDebugOverlay.zs",
    "caelum/equipment/CaelumEconomy.zs",
    "caelum/equipment/CaelumEquipmentPickups.zs",
    "caelum/equipment/CaelumPersistentCharacterState.zs",
    "caelum/hud/CaelumHUDOverlay.zs",
    "caelum/hud/CaelumJournalOverlay.zs",
    "caelum/player/CaelumPlayer.zs",
}
NON_ICON_NEW = {
    "CAPALOMO",
    "caelum/dialogue/CaelumPalomoDialogue.zs",
    "caelum/ui/CaelumIconResolver.zs",
}
PROJECT_FILES = {
    "APLICAR_4_32_0d.txt",
    "PRUEBAS_4_32_0d.txt",
    "docs/DIALOGUE.md",
    "docs/ECONOMY.md",
    "docs/ICONOGRAPHY.md",
    "docs/ICONOS_4_32_0d_SHA256.txt",
    "docs/IMPLEMENTATION_STATUS.md",
    "docs/MAGIC_BOX.md",
    "docs/ROADMAP.md",
    "tools/audit_4_32_0d.py",
    "tools/build_source_patch_4_32_0d.py",
}
FIXED_ZIP_TIME = (2026, 9, 6, 12, 0, 0)


def require(condition: bool, message: str) -> None:
    if not condition:
        raise AssertionError(message)


def sha256_bytes(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def sha256(path: Path) -> str:
    result = hashlib.sha256()
    with path.open("rb") as source:
        for block in iter(lambda: source.read(1024 * 1024), b""):
            result.update(block)
    return result.hexdigest()


def file_set(root: Path) -> set[str]:
    return {
        path.relative_to(root).as_posix()
        for path in root.rglob("*")
        if path.is_file()
    }


def read_icon_manifest(project: Path) -> dict[str, str]:
    path = project / "docs/ICONOS_4_32_0d_SHA256.txt"
    require(path.is_file(), f"missing icon digest manifest: {path}")
    result: dict[str, str] = {}
    for line_number, raw in enumerate(path.read_text("utf-8").splitlines(), 1):
        line = raw.strip()
        if not line or line.startswith("#"):
            continue
        parts = line.split(maxsplit=1)
        require(len(parts) == 2, f"bad icon manifest line {line_number}")
        digest, relative = parts
        require(re.fullmatch(r"[0-9a-f]{64}", digest) is not None,
                f"bad SHA-256 on icon manifest line {line_number}")
        require(relative.startswith("graphics/caelum/icons/"),
                f"icon manifest path escaped icon tree: {relative}")
        require(relative not in result, f"duplicate icon manifest path: {relative}")
        result[relative] = digest
    require(len(result) == 121, f"expected 121 distributed icons, got {len(result)}")
    return result


def expected_runtime_delta(
    project: Path, baseline: Path,
) -> tuple[set[str], set[str], set[str], dict[str, str]]:
    icons = read_icon_manifest(project)
    corrected = {relative for relative in icons if (baseline / relative).is_file()}
    added = set(icons) - corrected
    require(len(corrected) == 23, f"expected 23 corrected icons, got {len(corrected)}")
    require(len(added) == 98, f"expected 98 new tier icons, got {len(added)}")
    changed = NON_ICON_CHANGED_EXISTING | corrected
    new = NON_ICON_NEW | added
    return changed | new, changed, new, icons


def strip_comments_and_strings(text: str) -> str:
    text = re.sub(r"/\*.*?\*/", "", text, flags=re.DOTALL)
    text = re.sub(r"//[^\n]*", "", text)
    return re.sub(r'"(?:\\.|[^"\\])*"', '""', text)


def check_delimiters(text: str, label: str) -> None:
    clean = strip_comments_and_strings(text)
    pairs = {"{": "}", "(": ")", "[": "]"}
    stack: list[tuple[str, int]] = []
    for index, character in enumerate(clean):
        if character in pairs:
            stack.append((character, index))
        elif character in pairs.values():
            require(bool(stack) and pairs[stack[-1][0]] == character,
                    f"unexpected {character!r} in {label} at byte {index}")
            stack.pop()
    require(not stack, f"unclosed delimiter in {label}: {stack[-1:]}")


def declared_constants(text: str) -> dict[str, str]:
    return dict(re.findall(
        r"(?m)^\s*const\s+([A-Za-z_][A-Za-z0-9_]*)\s*=\s*([^;]+);",
        text,
    ))


def class_names(runtime: Path) -> set[str]:
    names: set[str] = set()
    for source in runtime.rglob("*.zs"):
        names.update(re.findall(
            r"(?mi)^\s*class\s+([A-Za-z_][A-Za-z0-9_]*)\b",
            source.read_text("utf-8"),
        ))
    return names


def check_runtime_delta(
    runtime: Path, baseline: Path, changed: set[str], new: set[str],
) -> None:
    base_files = file_set(baseline)
    candidate_files = file_set(runtime)
    require(candidate_files - base_files == new,
            f"unexpected new runtime files: {sorted((candidate_files-base_files)^new)}")
    require(not (base_files - candidate_files),
            f"runtime files were removed: {sorted(base_files-candidate_files)}")
    actual_changed = {
        relative for relative in base_files
        if (runtime / relative).read_bytes() != (baseline / relative).read_bytes()
    }
    require(actual_changed == changed,
            f"unexpected changed runtime files: {sorted(actual_changed^changed)}")


def check_sources(runtime: Path) -> None:
    for source in runtime.rglob("*.zs"):
        check_delimiters(source.read_text("utf-8"), source.as_posix())
    for relative in ("MAPINFO", "CAPALOMO"):
        check_delimiters((runtime / relative).read_text("utf-8"), relative)

    zscript = (runtime / "ZSCRIPT").read_text("utf-8")
    for include in (
        '#include "caelum/ui/CaelumIconResolver.zs"',
        '#include "caelum/dialogue/CaelumPalomoDialogue.zs"',
    ):
        require(zscript.count(include) == 1, f"missing/duplicate ZSCRIPT include: {include}")
    require(zscript.index("CaelumIconResolver.zs")
            < zscript.index("CaelumEquipmentPickups.zs"),
            "icon resolver must load before equipment sources")
    require(zscript.index("CaelumPlayer.zs")
            < zscript.index("CaelumPalomoDialogue.zs"),
            "dialogue actions must load after CaelumPlayer")

    constants_text = (runtime / "caelum/core/CaelumConstants.zs").read_text("utf-8")
    constants = declared_constants(constants_text)
    expected = {
        "PALOMO_CONVERSATION_ID": "43200",
        "GZDOOM_THING_SET_CONVERSATION_SPECIAL": "79",
        "PALOMO_DIALOGUE_DIFFICULTY": "50",
        "PALOMO_DISCOUNT_MINIMUM_ELOQUENCE": "50",
        "PALOMO_DISCOUNT_BUY_PERCENT": "140",
        "PALOMO_DISCOUNT_SELL_PERCENT": "60",
        "PALOMO_MERCHANT_RETURN_DISTANCE": "500.0",
    }
    for name, value in expected.items():
        require(constants.get(name, "").strip() == value, f"bad constant {name}")
    referenced: set[str] = set()
    for source in runtime.rglob("*.zs"):
        referenced.update(re.findall(
            r"\bCaelumConstants\.([A-Za-z_][A-Za-z0-9_]*)\b",
            source.read_text("utf-8"),
        ))
    require(not (referenced - set(constants)),
            f"undeclared constants: {sorted(referenced-set(constants))}")

    mapinfo = (runtime / "MAPINFO").read_text("utf-8")
    require(mapinfo.count('AddDialogues = "CAPALOMO"') == 1,
            "CAPALOMO is not loaded additively exactly once")

    player = (runtime / "caelum/player/CaelumPlayer.zs").read_text("utf-8")
    for token in (
        "bool PalomoMerchantDiscountGranted;",
        "void SyncPalomoDialogueTokens()",
        "bool OpenPalomoDialogue(Actor speaker)",
        "speaker.StartConversation(self, true, true)",
        "bool ResolvePalomoDiscountRequest()",
        "Attributes.Eloquence\n                > CaelumConstants.PALOMO_DISCOUNT_MINIMUM_ELOQUENCE",
        "Random[CaelumPalomoDiscount](1, 100)",
        "persistentState.PalomoDiscountGranted = true;",
        "PalomoMerchantDiscountGranted =\n            persistentState.PalomoDiscountGranted;",
    ):
        require(token in player, f"missing player dialogue contract: {token}")
    require("if (PalomoMerchantMenuOpen) { ClosePalomoMerchant(); }" in player,
            "dialogue must not arm the merchant close guard when no shop is open")

    persistent = (runtime / "caelum/equipment/CaelumPersistentCharacterState.zs").read_text("utf-8")
    for token in (
        "int PalomoDiscountVersion;",
        "bool PalomoDiscountGranted;",
        "void InitializeNewPalomoDiscount()",
        "void EnsurePalomoDiscountInitialized()",
    ):
        require(token in persistent, f"missing persistent discount contract: {token}")

    economy = (runtime / "caelum/equipment/CaelumEconomy.zs").read_text("utf-8")
    for token in (
        "bool negotiatedDiscount = false",
        "? CaelumConstants.PALOMO_DISCOUNT_SELL_PERCENT : 50",
        "? CaelumConstants.PALOMO_DISCOUNT_BUY_PERCENT : 150",
        "return baseLot * sellPercent / 100;",
        "return (baseLot * buyPercent + 99) / 100;",
    ):
        require(token in economy, f"missing negotiated-price contract: {token}")

    actors = (runtime / "caelum/actors/CaelumFolkloreCharacters.zs").read_text("utf-8")
    for token in (
        "if (!bInConversation && HasConversation())",
        "GZDOOM_THING_SET_CONVERSATION_SPECIAL",
        "return caelumPlayer.OpenPalomoDialogue(self);",
        ">= CaelumConstants.PALOMO_MERCHANT_RETURN_DISTANCE",
    ):
        require(token in actors, f"missing Palomo actor contract: {token}")

    dialogue = (runtime / "caelum/dialogue/CaelumPalomoDialogue.zs").read_text("utf-8")
    for token in (
        "class CaelumMagicBoxOwnershipToken",
        "class CaelumPalomoDiscountGrantedToken",
        "class CaelumPalomoEloquenceEligibleToken",
        "+INVENTORY.AUTOACTIVATE",
        "caelumPlayer.GrantMagicBoxFromPalomo(false);",
        "caelumPlayer.OpenPalomoMerchant(merchant);",
        "caelumPlayer.ResolvePalomoDiscountRequest();",
        "class CaelumPalomoConversationMenu : ConversationMenu",
        "override void FormatSpeakerMessage()",
        "override bool OnUIEvent(UIEvent ev)",
        "return MenuEvent(MKEY_Back, false);",
    ):
        require(token in dialogue, f"missing native dialogue bridge: {token}")


def check_usdf(runtime: Path) -> None:
    text = (runtime / "CAPALOMO").read_text("utf-8")
    clean = re.sub(r"/\*.*?\*/|//[^\n]*", "", text, flags=re.DOTALL)
    require(re.match(r'^\s*namespace\s*=\s*"GZDoom"\s*;', clean) is not None,
            "USDF namespace must be first and GZDoom")
    require(len(re.findall(r"\bconversation\s*\{", clean)) == 1,
            "CAPALOMO must define one conversation")
    require(re.search(r"\bid\s*=\s*43200\s*;", clean) is not None,
            "USDF conversation id changed")
    require(re.search(r'\bclass\s*=\s*"CaelumPalomoConversationMenu"\s*;', clean),
            "USDF custom native menu class missing")
    page_names = re.findall(r'\bpagename\s*=\s*"([^"]+)"\s*;', clean)
    require(len(page_names) == 7 and len(set(page_names)) == 7,
            f"expected seven uniquely named pages, got {page_names}")
    require(len(re.findall(r"\bchoice\s*\{", clean)) == 12,
            "unexpected number of USDF choices")
    linked = re.findall(r'\b(?:nextpage|link)\s*=\s*"([^"]+)"\s*;', clean)
    require(set(linked) <= set(page_names),
            f"USDF links reference missing pages: {sorted(set(linked)-set(page_names))}")
    require(len(re.findall(r"\brequire\s*\{", clean)) == 1,
            "discount reply must have one native require block")
    require(len(re.findall(r"\bexclude\s*\{", clean)) == 1,
            "discount reply must have one native exclude block")
    require(len(re.findall(r"\bifitem\s*\{", clean)) == 2,
            "ownership/result routing must use two native ifitem blocks")

    known_classes = class_names(runtime)
    actor_refs = re.findall(r'\b(?:item|giveitem)\s*=\s*"([A-Za-z_][A-Za-z0-9_]*)"', clean)
    require(set(actor_refs) <= known_classes,
            f"USDF references unknown classes: {sorted(set(actor_refs)-known_classes)}")


def check_language(runtime: Path) -> None:
    language = (runtime / "LANGUAGE").read_text("utf-8")
    required = {
        "CA_PALOMO_DIALOGUE_INTRO",
        "CA_PALOMO_DIALOGUE_YES",
        "CA_PALOMO_DIALOGUE_NO",
        "CA_PALOMO_DIALOGUE_ARE_YOU_SURE",
        "CA_PALOMO_DIALOGUE_PITY",
        "CA_PALOMO_DIALOGUE_GIFT",
        "CA_PALOMO_DIALOGUE_MAIN",
        "CA_PALOMO_DIALOGUE_TRADE",
        "CA_PALOMO_DIALOGUE_TALK",
        "CA_PALOMO_DIALOGUE_REQUEST_DISCOUNT",
        "CA_PALOMO_DIALOGUE_DISCOUNT_CONFIRM",
        "CA_PALOMO_DIALOGUE_DISCOUNT_FAILURE",
        "CA_PALOMO_DIALOGUE_DISCOUNT_SUCCESS",
        "CA_PALOMO_MERCHANT_DISCOUNT_ACTIVE",
    }
    for key in required:
        require(len(re.findall(rf"(?m)^{re.escape(key)}\s*=", language)) == 2,
                f"{key} must have English and Spanish definitions")
    language_keys = set(re.findall(r"(?m)^([A-Z][A-Z0-9_]*)\s*=", language))
    refs: set[str] = set()
    for source in runtime.rglob("*.zs"):
        refs.update(re.findall(r'"(CA_[A-Z0-9_]+)"', source.read_text("utf-8")))
    refs.update(re.findall(r'\$(CA_[A-Z0-9_]+)', (runtime / "CAPALOMO").read_text("utf-8")))
    require(not (refs - language_keys),
            f"missing LANGUAGE keys: {sorted(refs-language_keys)}")


def png_info(path: Path) -> tuple[int, int, int, int]:
    data = path.read_bytes()
    require(data[:8] == b"\x89PNG\r\n\x1a\n" and data[12:16] == b"IHDR",
            f"not a valid PNG header: {path}")
    return struct.unpack(">IIBB", data[16:26])


def check_icons(runtime: Path, icons: dict[str, str]) -> None:
    for relative, expected_digest in icons.items():
        path = runtime / relative
        require(path.is_file(), f"missing distributed icon: {relative}")
        require(sha256(path) == expected_digest, f"icon digest mismatch: {relative}")
        require(png_info(path) == (128, 128, 8, 6),
                f"distributed icon must be 128x128 RGBA8: {relative}")

    all_icons = list((runtime / "graphics/caelum/icons").rglob("*.png"))
    tier2 = {p.relative_to(runtime).as_posix() for p in all_icons if p.name.endswith("_t2.png")}
    tier3 = {p.relative_to(runtime).as_posix() for p in all_icons if p.name.endswith("_t3.png")}
    require(len(all_icons) == 255, f"runtime icon count changed: {len(all_icons)}")
    require(len(tier2) == 49 and len(tier3) == 49,
            f"tier icon count changed: T2={len(tier2)}, T3={len(tier3)}")
    tier_bases = {
        re.sub(r"_t[23]\.png$", ".png", path) for path in tier2 | tier3
    }
    require(len(tier_bases) == 49, "T2/T3 stems do not form 49 complete families")
    for base in tier_bases:
        require((runtime / base).is_file(), f"tier family has no T1 base: {base}")
        require(base[:-4] + "_t2.png" in tier2, f"tier family has no T2: {base}")
        require(base[:-4] + "_t3.png" in tier3, f"tier family has no T3: {base}")

    resolver = (runtime / "caelum/ui/CaelumIconResolver.zs").read_text("utf-8")
    mapped_bases = set(re.findall(
        r'"(graphics/caelum/icons/[^"\n]+\.png)"', resolver,
    ))
    require(mapped_bases == tier_bases,
            f"resolver/tier families differ: {sorted(mapped_bases^tier_bases)}")


def check_numeric_models() -> None:
    base_values = [4, 6, 2, 5, 5]
    for base in base_values:
        for quantity in (1, 5, 20, 50, 100):
            lot = base * quantity
            normal_buy = (lot * 150 + 99) // 100
            normal_sell = lot * 50 // 100
            discount_buy = (lot * 140 + 99) // 100
            discount_sell = lot * 60 // 100
            require(discount_buy <= normal_buy,
                    "negotiated buying price increased")
            require(discount_sell >= normal_sell,
                    "negotiated selling price decreased")
    require(((25 * 150 + 99) // 100, 25 * 50 // 100) == (38, 12),
            "normal five-unit raw-metal lot changed")
    require(((25 * 140 + 99) // 100, 25 * 60 // 100) == (35, 15),
            "discount five-unit raw-metal lot changed")
    require(((20 * 140 + 99) // 100, 20 * 60 // 100) == (28, 12),
            "discount five-food lot changed")
    require(((30 * 140 + 99) // 100, 30 * 60 // 100) == (42, 18),
            "discount five-water lot changed")

    def odds(eloquence: int) -> tuple[bool, int, bool]:
        eligible = eloquence > 50
        skill = eloquence * (eloquence + 1) / 101.0
        automatic = skill >= 50
        chance = 100 if automatic else max(0, min(100, int(skill * 100 / 50)))
        return eligible, chance, automatic

    require(odds(50) == (False, 50, False), "Eloquence 50 boundary changed")
    require(odds(51) == (True, 52, False), "Eloquence 51 boundary changed")
    require(odds(70) == (True, 98, False), "Eloquence 70 odds changed")
    require(odds(71) == (True, 100, True), "automatic-success boundary changed")
    require(odds(75) == (True, 100, True), "debug-75 odds changed")


def check_package(
    package: Path, expected_delta: set[str], project: Path, runtime: Path,
) -> None:
    require(package.is_file(), f"package does not exist: {package}")
    expected = {f"src/{relative}" for relative in expected_delta} | PROJECT_FILES
    with zipfile.ZipFile(package) as archive:
        require(archive.testzip() is None, "package contains corrupt entries")
        infos = [info for info in archive.infolist() if not info.is_dir()]
        names = [info.filename for info in infos]
        require(len(names) == len(set(names)), "package has duplicate entries")
        require(names == sorted(names), "package entries are not deterministic/sorted")
        require(set(names) == expected,
                f"package entry set differs: {sorted(set(names)^expected)}")
        for info in infos:
            path = PurePosixPath(info.filename)
            require(not path.is_absolute() and ".." not in path.parts,
                    f"unsafe package path: {info.filename}")
            require(info.date_time == FIXED_ZIP_TIME,
                    f"non-deterministic timestamp: {info.filename}")
            require(info.filename.lower().endswith(".pk3") is False,
                    f"compiled PK3 is forbidden: {info.filename}")
            require(not info.filename.startswith("build/"),
                    f"compiled build content is forbidden: {info.filename}")
            source = (runtime / info.filename[4:] if info.filename.startswith("src/")
                      else project / info.filename)
            require(archive.read(info) == source.read_bytes(),
                    f"package bytes differ from source: {info.filename}")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--runtime-root", type=Path, required=True)
    parser.add_argument("--baseline-runtime", type=Path, required=True)
    parser.add_argument("--project-root", type=Path)
    parser.add_argument("--package", type=Path)
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    project = args.project_root or Path(__file__).resolve().parents[1]
    runtime = args.runtime_root.resolve()
    baseline = args.baseline_runtime.resolve()
    require(runtime.is_dir(), f"runtime root is not a directory: {runtime}")
    require(baseline.is_dir(), f"baseline root is not a directory: {baseline}")
    delta, changed, new, icons = expected_runtime_delta(project, baseline)
    check_runtime_delta(runtime, baseline, changed, new)
    check_sources(runtime)
    check_usdf(runtime)
    check_language(runtime)
    check_icons(runtime, icons)
    check_numeric_models()
    if args.package:
        check_package(args.package.resolve(), delta, project, runtime)
    print("Caelum Argenteum 4.32.0d audit: PASS")
    print(f"Runtime delta: {len(changed)} changed + {len(new)} new = {len(delta)} files")
    print("Icons: 23 corrected + 49 T2 + 49 T3 = 121 distributed PNGs")
    if args.package:
        print(f"Source package SHA-256: {sha256(args.package.resolve())}")


if __name__ == "__main__":
    main()
