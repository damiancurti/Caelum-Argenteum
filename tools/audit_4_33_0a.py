#!/usr/bin/env python3
"""Deterministic focused audit for Caelum Argenteum 4.33.0a."""

from __future__ import annotations

import argparse
import re
import zipfile
from pathlib import Path, PurePosixPath


RUNTIME_FILES = {
    "ZSCRIPT",
    "LANGUAGE",
    "caelum/core/CaelumConstants.zs",
    "caelum/factions/CaelumFactionRules.zs",
    "caelum/equipment/CaelumPersistentCharacterState.zs",
    "caelum/player/CaelumPlayer.zs",
    "caelum/quests/CaelumSocialDebugActions.zs",
    "caelum/hud/CaelumJournalOverlay.zs",
}

PROJECT_FILES = {
    "APLICAR_4_33_0a.txt",
    "PRUEBAS_4_33_0a.txt",
    "docs/QUESTS_REPUTATION_FACTIONS.md",
    "docs/DIALOGUE.md",
    "docs/MAGIC_BOX.md",
    "docs/FIRST_PERSON.md",
    "docs/IMPLEMENTATION_STATUS.md",
    "docs/ROADMAP.md",
    "tools/audit_4_33_0a.py",
    "tools/build_source_patch_4_33_0a.py",
}

NEW_LANGUAGE_KEYS = {
    "CA_JOURNAL_QUESTS_EMPTY",
    "CA_QUEST_STATUS_LABEL",
    "CA_QUEST_STAGE_LABEL",
    "CA_QUEST_OBJECTIVES_LABEL",
    "CA_QUEST_STATUS_ACTIVE",
    "CA_QUEST_STATUS_COMPLETED",
    "CA_QUEST_STATUS_FAILED",
    "CA_QUEST_PALOMO_ADVENTURE",
    "CA_QUEST_PALOMO_STAGE_ACCEPTED",
    "CA_QUEST_PALOMO_OBJECTIVE_MAGIC_BOX",
    "CA_QUEST_PALOMO_LOCATION_LABEL",
    "CA_PALOMO_PLACEMENT_MANSION",
    "CA_QUEST_FOUNDATION_NOTE",
    "CA_REPUTATION_VALUE_LABEL",
    "CA_FACTION_MEMBERSHIP_LABEL",
    "CA_FACTION_MEMBER_YES",
    "CA_FACTION_MEMBER_NO",
    "CA_FACTION_GENDARMERIA",
    "CA_FACTION_SETTLEMENTS",
    "CA_FACTION_CARAVANS",
    "CA_FACTION_POLITICAL_ACTORS",
    "CA_REPUTATION_FOUNDATION_NOTE",
}

QUEST_CONSTANTS = {
    "QUEST_CAPACITY": "32",
    "QUEST_OBJECTIVE_CAPACITY": "8",
    "QUEST_DEFINED_COUNT": "1",
    "QUEST_PALOMO_ADVENTURE": "0",
    "QUEST_STATE_UNDISCOVERED": "0",
    "QUEST_STATE_ACTIVE": "1",
    "QUEST_STATE_COMPLETED": "2",
    "QUEST_STATE_FAILED": "3",
    "QUEST_PALOMO_STAGE_ACCEPTED": "1",
    "QUEST_PALOMO_OBJECTIVE_MAGIC_BOX": "0",
    "PALOMO_PLACEMENT_MANSION": "0",
}

FACTION_CONSTANTS = {
    "FACTION_GENDARMERIA": "0",
    "FACTION_SETTLEMENTS": "1",
    "FACTION_CARAVANS": "2",
    "FACTION_POLITICAL_ACTORS": "3",
    "FACTION_COUNT": "4",
    "FACTION_REPUTATION_MINIMUM": "-1000",
    "FACTION_REPUTATION_MAXIMUM": "1000",
    "FACTION_RELATION_HOSTILE": "-1",
    "FACTION_RELATION_NEUTRAL": "0",
    "FACTION_RELATION_FRIENDLY": "1",
}

DEBUG_CLASSES = {
    "CaelumDebugJoinGendarmeria",
    "CaelumDebugLeaveGendarmeria",
    "CaelumDebugGendarmeriaReputationPlus25",
    "CaelumDebugGendarmeriaReputationMinus50",
    "CaelumDebugResetFactions",
}

FIXED_ZIP_TIME = (2026, 9, 7, 19, 0, 0)


def require(condition: bool, message: str) -> None:
    if not condition:
        raise AssertionError(message)


def read_text(path: Path) -> str:
    require(path.is_file(), f"missing file: {path}")
    return path.read_text(encoding="utf-8")


def runtime_path(root: Path, relative: str) -> Path:
    under_src = root / "src" / relative
    if under_src.is_file():
        return under_src
    return root / relative


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
            require(
                bool(stack) and pairs[stack[-1][0]] == character,
                f"unexpected {character!r} in {label} at byte {index}",
            )
            stack.pop()
    require(not stack, f"unclosed delimiter in {label}: {stack[-1:]}")


def braced_span(text: str, pattern: str, label: str) -> str:
    match = re.search(pattern, text)
    require(match is not None, f"missing {label}")
    opening = text.find("{", match.end())
    require(opening >= 0, f"missing body for {label}")
    depth = 0
    for index in range(opening, len(text)):
        if text[index] == "{":
            depth += 1
        elif text[index] == "}":
            depth -= 1
            if depth == 0:
                return text[match.start():index + 1]
    raise AssertionError(f"unclosed body for {label}")


def method_span(text: str, method_name: str) -> str:
    return braced_span(
        text,
        rf"\b(?:bool|int|double|void|String)\s+{re.escape(method_name)}\s*\(",
        f"method {method_name}",
    )


def constant_definitions(text: str) -> dict[str, str]:
    return {
        match.group(1): match.group(2).strip()
        for match in re.finditer(
            r"^\s*const\s+([A-Za-z_][A-Za-z0-9_]*)\s*=\s*([^;]+);",
            text,
            flags=re.MULTILINE,
        )
    }


def expected_package_entries() -> set[str]:
    return {
        *(f"src/{relative}" for relative in RUNTIME_FILES),
        *PROJECT_FILES,
    }


def audit_constants(project: Path, baseline_0d: Path) -> None:
    current_text = read_text(project / "src/caelum/core/CaelumConstants.zs")
    baseline_text = read_text(runtime_path(
        baseline_0d, "caelum/core/CaelumConstants.zs"
    ))
    current = constant_definitions(current_text)
    baseline = constant_definitions(baseline_text)
    require(set(baseline) <= set(current), "a cumulative V4.32 constant was lost")

    for name, value in {**QUEST_CONSTANTS, **FACTION_CONSTANTS}.items():
        require(name in current, f"missing constant {name}")
        require(current[name] == value, f"unexpected value for {name}")

    require(
        "QUEST_CAPACITY * QUEST_OBJECTIVE_CAPACITY"
            in current["QUEST_OBJECTIVE_STORAGE_COUNT"],
        "quest objective storage is no longer derived from its capacities",
    )
    require(
        "QUEST_DEFINED_COUNT * QUEST_OBJECTIVE_CAPACITY"
            in current["QUEST_JOURNAL_OBJECTIVE_STORAGE_COUNT"],
        "journal objective storage is no longer bounded to authored quests",
    )


def audit_zscript(project: Path, full_runtime: Path) -> None:
    root_text = read_text(project / "src/ZSCRIPT")
    includes = re.findall(r'^\s*#include\s+"([^"]+)"', root_text, re.MULTILINE)
    require(len(includes) == len(set(includes)), "duplicate ZSCRIPT include")
    for include in includes:
        require(
            runtime_path(full_runtime, include).is_file(),
            f"ZSCRIPT include does not exist in cumulative runtime: {include}",
        )

    required_order = [
        "caelum/core/CaelumConstants.zs",
        "caelum/factions/CaelumFactionRules.zs",
        "caelum/equipment/CaelumPersistentCharacterState.zs",
        "caelum/player/CaelumPlayer.zs",
        "caelum/quests/CaelumSocialDebugActions.zs",
        "caelum/dialogue/CaelumPalomoDialogue.zs",
        "caelum/hud/CaelumJournalOverlay.zs",
    ]
    positions = []
    for include in required_order:
        require(include in includes, f"missing ZSCRIPT include: {include}")
        positions.append(includes.index(include))
    require(positions == sorted(positions), "new ZSCRIPT includes are out of order")

    definitions = constant_definitions(
        read_text(project / "src/caelum/core/CaelumConstants.zs")
    )
    references: set[str] = set()
    for path in full_runtime.rglob("*.zs"):
        references.update(re.findall(
            r"\bCaelumConstants\.([A-Za-z_][A-Za-z0-9_]*)", read_text(path)
        ))
    missing = sorted(references - set(definitions))
    require(not missing, f"undefined CaelumConstants references: {missing}")


def audit_persistent_state(project: Path) -> None:
    text = read_text(
        project / "src/caelum/equipment/CaelumPersistentCharacterState.zs"
    )
    for fragment in (
        "int QuestStateVersion;",
        "int QuestState[CaelumConstants.QUEST_CAPACITY];",
        "int QuestStage[CaelumConstants.QUEST_CAPACITY];",
        "bool QuestObjectiveKnown[",
        "int QuestObjectiveProgress[",
        "int QuestObjectiveTarget[",
        "int FactionStateVersion;",
        "bool FactionMember[CaelumConstants.FACTION_COUNT];",
        "int FactionReputation[CaelumConstants.FACTION_COUNT];",
    ):
        require(fragment in text, f"missing persistent field: {fragment}")

    quest_init = method_span(text, "EnsureQuestStateInitialized")
    require("EnsureMagicBoxOwnershipInitialized();" in quest_init,
            "quest migration does not initialize Magic Box ownership")
    require("bool acceptedAdventure = MagicBoxOwned;" in quest_init,
            "V4.32 Magic Box evidence is not migrated")
    require("RecordPalomoAdventureAcceptedWithoutInitialization();" in quest_init,
            "accepted V4.32 adventure is not reconstructed")

    accept = method_span(text, "RecordPalomoAdventureAcceptedWithoutInitialization")
    for fragment in (
        "QUEST_STATE_ACTIVE",
        "QUEST_PALOMO_STAGE_ACCEPTED",
        "QUEST_PALOMO_OBJECTIVE_MAGIC_BOX",
        "QuestObjectiveKnown[objective] = true;",
        "QuestObjectiveProgress[objective] = 1;",
        "QuestObjectiveTarget[objective] = 1;",
    ):
        require(fragment in accept, f"Palomo acceptance lost: {fragment}")

    placement = method_span(text, "ResolvePalomoPlacement")
    require("PALOMO_PLACEMENT_MANSION" in placement,
            "Palomo placement is not resolved to the authorized mansion post")
    require("QuestStage[CaelumConstants.QUEST_PALOMO_ADVENTURE]" in placement,
            "Palomo placement no longer derives from the quest stage")

    reputation = method_span(text, "ChangeFactionReputation")
    require("FACTION_REPUTATION_MINIMUM" in reputation
            and "FACTION_REPUTATION_MAXIMUM" in reputation,
            "reputation no longer saturates to documented bounds")
    require("int room" in reputation,
            "reputation addition is not protected against integer overflow")


def audit_player(project: Path, baseline_0o: Path) -> None:
    text = read_text(project / "src/caelum/player/CaelumPlayer.zs")
    baseline = read_text(runtime_path(baseline_0o, "caelum/player/CaelumPlayer.zs"))

    for fragment in (
        "int JournalKnownQuestCount;",
        "int JournalQuestState[CaelumConstants.QUEST_DEFINED_COUNT];",
        "int JournalPalomoPlacement;",
        "bool JournalFactionMember[CaelumConstants.FACTION_COUNT];",
        "int JournalFactionReputation[CaelumConstants.FACTION_COUNT];",
    ):
        require(fragment in text, f"missing journal snapshot field: {fragment}")

    refresh = method_span(text, "RefreshSocialJournalSnapshot")
    for fragment in (
        "EnsureQuestStateInitialized();",
        "EnsureFactionStateInitialized();",
        "ResolvePalomoPlacement();",
        "JournalFactionReputation[factionId]",
    ):
        require(fragment in refresh, f"social snapshot lost: {fragment}")

    grant = method_span(text, "GrantMagicBoxFromPalomo")
    require("EnsureQuestStateInitialized();" in grant,
            "Magic Box grant does not initialize quest state")
    require(grant.count("RecordPalomoAdventureAccepted();") >= 3,
            "not every Magic Box ownership route records the adventure")
    require("PersistCharacterState();" in grant,
            "Magic Box/quest transition is not persisted atomically")

    persist = method_span(text, "PersistCharacterState")
    restore = method_span(text, "RestorePersistentCharacterState")
    for body, label in ((persist, "persist"), (restore, "restore")):
        require("EnsureQuestStateInitialized();" in body,
                f"{label} path omits quest schema")
        require("EnsureFactionStateInitialized();" in body,
                f"{label} path omits faction schema")

    new_character = method_span(text, "SpawnStartingDevelopmentEquipment")
    require("InitializeNewQuestState();" in new_character,
            "new characters do not receive an explicit empty quest schema")
    require("InitializeNewFactionState();" in new_character,
            "new characters do not receive an explicit neutral faction schema")

    accepted_sync = method_span(text, "SyncLiveMagicBoxOwnershipFromPersistentState")
    require("GetPersistentCharacterState(true)" in accepted_sync,
            "accepted V4.32 Magic Box live synchronization regressed")
    baseline_sync = method_span(baseline, "SyncLiveMagicBoxOwnershipFromPersistentState")
    require("GetPersistentCharacterState(true)" in baseline_sync,
            "the supplied V4.32.0o baseline is not the accepted source")

    dialogue_sync = method_span(text, "SyncPalomoDialogueTokens")
    require("MagicBoxOwned = persistentState.MagicBoxOwned" not in dialogue_sync,
            "rejected V4.32 dialogue-time ownership reconciliation returned")


def audit_factions_and_debug(project: Path) -> None:
    faction_text = read_text(
        project / "src/caelum/factions/CaelumFactionRules.zs"
    )
    relation = method_span(faction_text, "GetRelation")
    require("sourceFactionId == targetFactionId" in relation,
            "same-faction friendly relation is missing")
    require("FACTION_RELATION_NEUTRAL" in relation,
            "neutral default relation is missing")
    forbidden = (
        "ThinkerIterator", "ActorIterator", "BlockThingsIterator",
        "A_Look", "LineOfSight", "CheckSight", "Path", "Spawn",
    )
    for token in forbidden:
        require(token.lower() not in faction_text.lower(),
                f"faction lookup contains forbidden actor/AI work: {token}")

    debug_text = read_text(
        project / "src/caelum/quests/CaelumSocialDebugActions.zs"
    )
    base = braced_span(
        debug_text, r"\bclass\s+CaelumSocialDebugAction\b",
        "class CaelumSocialDebugAction",
    )
    require("Inventory.MaxAmount 0;" in base and "+INVENTORY.AUTOACTIVATE" in base,
            "debug actions are no longer zero-capacity autoactivators")
    clean_debug = strip_comments_and_strings(debug_text)
    require(re.search(r"\bDoomEdNum\b", clean_debug) is None,
            "debug actions must not have DoomEdNums")
    for class_name in DEBUG_CLASSES:
        require(re.search(rf"\bclass\s+{class_name}\b", debug_text) is not None,
                f"missing debug class {class_name}")


def audit_journal_and_language(project: Path, baseline_0d: Path) -> None:
    journal = read_text(project / "src/caelum/hud/CaelumJournalOverlay.zs")
    baseline = read_text(runtime_path(
        baseline_0d, "caelum/hud/CaelumJournalOverlay.zs"
    ))
    legacy_anchors = (
        "ca_coin_silver.png",
        "ca_ui_magic_box.png",
        "DrawPalomoMerchant",
        "ca_palomo_merchant_quantity_previous",
        "ca_palomo_merchant_quantity_next",
        "ca_palomo_merchant_mode",
        "ca_palomo_merchant_transact",
    )
    for anchor in legacy_anchors:
        require(anchor in baseline, f"bad V4.32.0d baseline; missing {anchor}")
        require(anchor in journal, f"cumulative Journal behavior lost: {anchor}")

    for fragment in (
        "ui void DrawQuestPage",
        "ui void DrawReputationPage",
        'SendNetworkEvent("ca_social_refresh")',
        'e.Name == "ca_social_refresh"',
        "DrawQuestPage(localPlayer)",
        "DrawReputationPage(localPlayer)",
    ):
        require(fragment in journal, f"social Journal integration lost: {fragment}")
    require('DrawPlannedPage("CA_JOURNAL_QUESTS_PENDING")' not in journal,
            "Missions page still renders its old placeholder")
    require('DrawPlannedPage("CA_JOURNAL_REPUTATION_PENDING")' not in journal,
            "Reputation page still renders its old placeholder")

    language = read_text(project / "src/LANGUAGE")
    for key in NEW_LANGUAGE_KEYS:
        definitions = re.findall(rf"^\s*{re.escape(key)}\s*=", language, re.MULTILINE)
        require(len(definitions) == 2,
                f"{key} must have exactly English and Spanish definitions")


def audit_documents(project: Path) -> None:
    apply_text = read_text(project / "APLICAR_4_33_0a.txt")
    tests = read_text(project / "PRUEBAS_4_33_0a.txt")
    design = read_text(project / "docs/QUESTS_REPUTATION_FACTIONS.md")
    status = read_text(project / "docs/IMPLEMENTATION_STATUS.md")
    roadmap = read_text(project / "docs/ROADMAP.md")
    first_person = read_text(project / "docs/FIRST_PERSON.md")
    require("NO contiene un PK3" in apply_text, "application guide is not source-only")
    require("V4.32.0o" in apply_text, "application guide lacks accepted baseline")
    for command in DEBUG_CLASSES:
        require(command in tests and command in design,
                f"debug action is undocumented: {command}")
    require("4.33.0a" in status and "4.33.0a" in roadmap,
            "status/roadmap do not record this revision")
    require("aceptada" in first_person.lower(),
            "accepted V4.32 first-person reference was not preserved")


def audit_package(project: Path, package: Path) -> None:
    require(package.is_file(), f"package does not exist: {package}")
    expected = expected_package_entries()
    with zipfile.ZipFile(package) as archive:
        infos = archive.infolist()
        names = [info.filename for info in infos]
        require(len(names) == len(set(names)), "duplicate ZIP entry")
        require(set(names) == expected, "unexpected source-package entry set")
        for info in infos:
            pure = PurePosixPath(info.filename)
            require(not info.is_dir(), f"directory entry is not allowed: {info.filename}")
            require(not pure.is_absolute() and ".." not in pure.parts,
                    f"unsafe ZIP entry: {info.filename}")
            require(info.date_time == FIXED_ZIP_TIME,
                    f"non-deterministic ZIP timestamp: {info.filename}")
            require(not info.filename.lower().endswith((".pk3", ".wad")),
                    f"compiled output in source package: {info.filename}")
            local = project / info.filename
            require(local.is_file(), f"package entry has no project source: {info.filename}")
            require(archive.read(info) == local.read_bytes(),
                    f"package bytes differ from project: {info.filename}")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--project-root", type=Path, required=True)
    parser.add_argument("--baseline-0o", type=Path, required=True)
    parser.add_argument("--baseline-0d", type=Path, required=True)
    parser.add_argument("--full-runtime", type=Path, required=True)
    parser.add_argument("--package", type=Path)
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    project = args.project_root.resolve()
    baseline_0o = args.baseline_0o.resolve()
    baseline_0d = args.baseline_0d.resolve()
    full_runtime = args.full_runtime.resolve()

    for relative in RUNTIME_FILES:
        require((project / "src" / relative).is_file(),
                f"missing runtime source: {relative}")
    for relative in PROJECT_FILES:
        require((project / relative).is_file(),
                f"missing project source: {relative}")
    for path in (
        project / "src/caelum/core/CaelumConstants.zs",
        project / "src/caelum/factions/CaelumFactionRules.zs",
        project / "src/caelum/equipment/CaelumPersistentCharacterState.zs",
        project / "src/caelum/player/CaelumPlayer.zs",
        project / "src/caelum/quests/CaelumSocialDebugActions.zs",
        project / "src/caelum/hud/CaelumJournalOverlay.zs",
    ):
        check_delimiters(read_text(path), path.relative_to(project).as_posix())

    audit_constants(project, baseline_0d)
    audit_zscript(project, full_runtime)
    audit_persistent_state(project)
    audit_player(project, baseline_0o)
    audit_factions_and_debug(project)
    audit_journal_and_language(project, baseline_0d)
    audit_documents(project)
    if args.package is not None:
        audit_package(project, args.package.resolve())

    print("Caelum Argenteum 4.33.0a audit: PASS")
    print(f"Runtime files: {len(RUNTIME_FILES)}")
    print(f"Package entries: {len(expected_package_entries())}")
    print("Quest slots/objectives: 32 / 8 each")
    print("Faction domains: 4; relation lookup: O(1), neutral by default")


if __name__ == "__main__":
    main()
