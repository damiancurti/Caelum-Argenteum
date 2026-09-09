#!/usr/bin/env python3
"""Deterministic focused audit for Caelum Argenteum 4.33.0b."""

from __future__ import annotations

import argparse
import hashlib
import re
import zipfile
from pathlib import Path, PurePosixPath


RUNTIME_FILES = {
    "CAPALOMO",
    "LANGUAGE",
    "MAPINFO",
    "ZSCRIPT",
    "caelum/actors/CaelumFolkloreCharacters.zs",
    "caelum/core/CaelumConstants.zs",
    "caelum/dialogue/CaelumPalomoDialogue.zs",
    "caelum/equipment/CaelumPersistentCharacterState.zs",
    "caelum/hud/CaelumJournalOverlay.zs",
    "caelum/player/CaelumPlayer.zs",
    "caelum/quests/CaelumMainM00QuestController.zs",
}

PROJECT_FILES = {
    "APLICAR_4_33_0b.txt",
    "PRUEBAS_4_33_0b.txt",
    "docs/DIALOGUE.md",
    "docs/IMPLEMENTATION_STATUS.md",
    "docs/MAGIC_BOX.md",
    "docs/MAP01_HISTORIA_Y_PROGRAMACION_v1_0.txt",
    "docs/QUESTS_REPUTATION_FACTIONS.md",
    "docs/ROADMAP.md",
    "tools/audit_4_33_0b.py",
    "tools/build_source_patch_4_33_0b.py",
}

NEW_LANGUAGE_KEYS = {
    "CA_MAP01_NAME",
    "CA_Q_M01_TITLE",
    "CA_Q_M01_SUMMARY",
    "CA_Q_M01_STATE_INITIALIZE",
    "CA_Q_M01_STATE_AWAKEN",
    "CA_Q_M01_STATE_MEET_PALOMO",
    "CA_Q_M01_STATE_ARGENTO_SOCIAL",
    "CA_Q_M01_STATE_CAELLA_MAGIC",
    "CA_Q_M01_STATE_RONNIE_SURVIVAL",
    "CA_Q_M01_STATE_PREPARE_WEAPON",
    "CA_Q_M01_STATE_RULO_COMBAT",
    "CA_Q_M01_STATE_PALOMO_FINAL",
    "CA_Q_M01_STATE_CAPTURE_THE_FOOL",
    "CA_Q_M01_STATE_RETURN_TO_BODY",
    "CA_Q_M01_STATE_COMPLETE",
    "CA_Q_M01_OBJ_FIND_HELP",
    "CA_Q_M01_OBJ_TALK_ARGENTO",
    "CA_Q_M01_OBJ_CONVINCE_RESIDENTS",
    "CA_Q_M01_OBJ_FOLLOW_CAELLA",
    "CA_Q_M01_OBJ_SOLVE_RIDDLE",
    "CA_Q_M01_OBJ_FOLLOW_RONNIE",
    "CA_Q_M01_OBJ_GATHER_MATERIALS",
    "CA_Q_M01_OBJ_PREPARE_WEAPON",
    "CA_Q_M01_OBJ_TALK_RULO",
    "CA_Q_M01_OBJ_DEFEAT_BULL",
    "CA_Q_M01_OBJ_FIND_PALOMO",
    "CA_Q_M01_OBJ_CAPTURE_FOOL",
    "CA_Q_M01_OBJ_LEAVE_MANSION",
    "CA_Q_M01_COMPLETE",
    "CA_PALOMO_PLACEMENT_HIDDEN",
    "CA_PALOMO_PLACEMENT_MANSION_FOYER",
    "CA_PALOMO_PLACEMENT_MANSION_UPSTAIRS",
    "CA_SPEAKER_UNKNOWN_VOICE",
    "CA_DLG_M01_UNKNOWN_VOICE_WAKE",
    "CA_DLG_M01_UNKNOWN_VOICE_ASK_WHO",
    "CA_DLG_M01_UNKNOWN_VOICE_WHO_REPLY",
    "CA_DLG_M01_UNKNOWN_VOICE_ASK_WHERE",
    "CA_DLG_M01_UNKNOWN_VOICE_WHERE_REPLY",
    "CA_DLG_M01_UNKNOWN_VOICE_SILENCE",
    "CA_DLG_M01_CONTINUE",
    "CA_DLG_M01_BACK",
    "CA_DLG_M01_PALOMO_LEAVE",
    "CA_DLG_M01_PALOMO_FOYER",
    "CA_DLG_M01_PALOMO_ASK_WHERE",
    "CA_DLG_M01_PALOMO_WHERE_REPLY",
    "CA_DLG_M01_PALOMO_ASK_WHAT_HAPPENED",
    "CA_DLG_M01_PALOMO_WHAT_HAPPENED_REPLY",
    "CA_DLG_M01_PALOMO_MEMORY_GAP",
    "CA_DLG_M01_PALOMO_MEMORY_GAP_REPLY",
    "CA_DLG_M01_PALOMO_MENTION_VOICE",
    "CA_DLG_M01_PALOMO_VOICE_REPLY",
    "CA_DLG_M01_PALOMO_VOICE_DOUBT",
    "CA_DLG_M01_PALOMO_VOICE_DOUBT_REPLY",
    "CA_DLG_M01_PALOMO_ASK_GUIDANCE",
    "CA_DLG_M01_PALOMO_GUIDANCE_REPLY",
    "CA_DLG_M01_PALOMO_WAITING_ARGENTO",
}

CANONICAL_VISIBLE_KEYS = NEW_LANGUAGE_KEYS | {
    "CA_PALOMO_NAME",
    "CA_QUEST_STATUS_ACTIVE",
    "CA_QUEST_STATUS_COMPLETED",
    "CA_QUEST_STATUS_FAILED",
    "CA_QUEST_STAGE_LABEL",
    "CA_QUEST_OBJECTIVES_LABEL",
    "CA_QUEST_PALOMO_LOCATION_LABEL",
    "CA_QUEST_FOUNDATION_NOTE",
}

DEBUG_CLASSES = {
    "CaelumDebugJoinGendarmeria",
    "CaelumDebugLeaveGendarmeria",
    "CaelumDebugGendarmeriaReputationPlus25",
    "CaelumDebugGendarmeriaReputationMinus50",
    "CaelumDebugResetFactions",
}

MAIN_STATES = {
    "MAIN_M00_STATE_INITIALIZE": 0,
    "MAIN_M00_STATE_AWAKENED": 10,
    "MAIN_M00_STATE_MET_PALOMO": 20,
    "MAIN_M00_STATE_ARGENTO_ACTIVE": 30,
    "MAIN_M00_STATE_ARGENTO_COMPLETE": 35,
    "MAIN_M00_STATE_CAELLA_ACTIVE": 40,
    "MAIN_M00_STATE_CAELLA_COMPLETE": 45,
    "MAIN_M00_STATE_RONNIE_ACTIVE": 50,
    "MAIN_M00_STATE_RONNIE_COMPLETE": 55,
    "MAIN_M00_STATE_WEAPON_READY": 60,
    "MAIN_M00_STATE_RULO_ACTIVE": 70,
    "MAIN_M00_STATE_RULO_COMPLETE": 75,
    "MAIN_M00_STATE_BOX_RECEIVED": 80,
    "MAIN_M00_STATE_FOOL_CAPTURED": 90,
    "MAIN_M00_STATE_EXIT_CONFIRMED": 95,
    "MAIN_M00_STATE_COMPLETE": 100,
}

MAIN_FLAGS = [
    "STARTED",
    "UNKNOWN_VOICE_HEARD",
    "PALOMO_MET",
    "ARGENTO_STARTED",
    "RULO_CONVINCED",
    "RONNIE_CONVINCED",
    "CAELLA_CONVINCED",
    "ARGENTO_COMPLETE",
    "CAELLA_STARTED",
    "MAGIC_IMPLEMENT_GIVEN",
    "MAGIC_SEAL_GIVEN",
    "MAGIC_PRIMARY_USED",
    "MAGIC_SECONDARY_USED",
    "MAGIC_CHANNEL_USED",
    "RUNE_EARTH",
    "RUNE_AIR",
    "RUNE_FIRE",
    "RUNE_WATER",
    "SECRET_PASSAGE_OPEN",
    "CAELLA_COMPLETE",
    "RONNIE_STARTED",
    "REPAIR_TUTORIAL_COMPLETE",
    "SURVIVAL_FOOD_USED",
    "SURVIVAL_WATER_USED",
    "SURVIVAL_AIR_SEEN",
    "SURVIVAL_LOAD_SEEN",
    "MATERIALS_COMPLETE",
    "RONNIE_COMPLETE",
    "STARTER_WEAPON_CRAFTED",
    "STARTER_WEAPON_PRESERVED",
    "RULO_STARTED",
    "COMBAT_PRIMARY_USED",
    "COMBAT_SECONDARY_USED",
    "COMBAT_DEFENSE_USED",
    "COMBAT_CHARGED_USED",
    "BULL_STARTED",
    "BULL_DEFEATED",
    "RULO_COMPLETE",
    "PALOMO_UPSTAIRS_ENABLED",
    "MAGIC_BOX_GRANTED",
    "THE_FOOL_CAPTURED",
    "EXIT_READY",
    "EXIT_CONFIRMED",
    "INVENTORY_SANITIZED",
    "COMPLETE",
    "ASKED_PALOMO_WHERE",
    "ASKED_PALOMO_WHAT_HAPPENED",
    "TOLD_PALOMO_ABOUT_VOICE",
    "PALOMO_CALLED_IT_HALLUCINATION",
    "HEARD_ARGENTO_QUOTE",
    "HEARD_CAELLA_QUOTE",
    "HEARD_RONNIE_QUOTE",
    "HEARD_RULO_QUOTE",
    "NOTICED_MEMORY_GAP",
    "NOTICED_LOOPING_PATH",
    "NOTICED_WRONG_CLOCKS",
    "NOTICED_ROOM_GEOMETRY",
]

REMOVED_0A_CONSTANTS = {
    "QUEST_PALOMO_STAGE_ACCEPTED",
    "QUEST_PALOMO_OBJECTIVE_MAGIC_BOX",
}
CHANGED_0A_CONSTANTS = {
    "QUEST_PALOMO_ADVENTURE",
    "PALOMO_PLACEMENT_MANSION",
    "PALOMO_PLACEMENT_COUNT",
}

FIXED_ZIP_TIME = (2026, 9, 9, 12, 0, 0)
STORY_SHA256 = "9bc00b885dc04bbaa1bc0813c1764533813a9a9475573a832dd980452ce5f7b0"


def require(condition: bool, message: str) -> None:
    if not condition:
        raise AssertionError(message)


def read_text(path: Path) -> str:
    require(path.is_file(), f"missing file: {path}")
    return path.read_text(encoding="utf-8")


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as source:
        for block in iter(lambda: source.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


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


def class_span(text: str, class_name: str) -> str:
    return braced_span(
        text,
        rf"\bclass\s+{re.escape(class_name)}\b",
        f"class {class_name}",
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


def language_values(text: str, key: str) -> list[str]:
    pattern = rf'^\s*{re.escape(key)}\s*=\s*"((?:\\.|[^"\\])*)";'
    return re.findall(pattern, text, flags=re.MULTILINE)


def expected_package_entries() -> set[str]:
    return {
        *(f"src/{relative}" for relative in RUNTIME_FILES),
        *PROJECT_FILES,
    }


def audit_runtime_reconstruction(
    project: Path, baseline_0a: Path, full_runtime: Path
) -> None:
    baseline_files = {
        path.relative_to(baseline_0a).as_posix()
        for path in baseline_0a.rglob("*") if path.is_file()
    }
    current_files = {
        path.relative_to(full_runtime).as_posix()
        for path in full_runtime.rglob("*") if path.is_file()
    }
    require(
        current_files == baseline_files | {
            "caelum/quests/CaelumMainM00QuestController.zs"
        },
        "full runtime is not an exact V4.33.0a reconstruction plus controller",
    )

    for relative in sorted(baseline_files - RUNTIME_FILES):
        require(
            (baseline_0a / relative).read_bytes()
                == (full_runtime / relative).read_bytes(),
            f"unrelated accepted runtime file changed: {relative}",
        )
    for relative in RUNTIME_FILES:
        require(
            (project / "src" / relative).read_bytes()
                == (full_runtime / relative).read_bytes(),
            f"full runtime does not contain project source: {relative}",
        )


def audit_constants(project: Path, baseline_0a: Path) -> None:
    current_text = read_text(project / "src/caelum/core/CaelumConstants.zs")
    baseline_text = read_text(
        baseline_0a / "caelum/core/CaelumConstants.zs"
    )
    current = constant_definitions(current_text)
    baseline = constant_definitions(baseline_text)

    for name, value in baseline.items():
        if name in REMOVED_0A_CONSTANTS or name in CHANGED_0A_CONSTANTS:
            continue
        require(current.get(name) == value, f"accepted constant changed: {name}")
    require(not (REMOVED_0A_CONSTANTS & set(current)),
            "discarded test-quest constants remain")

    required = {
        "QUEST_CAPACITY": "32",
        "QUEST_OBJECTIVE_CAPACITY": "8",
        "QUEST_DEFINED_COUNT": "1",
        "QUEST_MAIN_M00_THE_FOOL": "0",
        "QUEST_PALOMO_ADVENTURE": "QUEST_MAIN_M00_THE_FOOL",
        "MAIN_M00_FLAG_CAPACITY": "64",
        "MAIN_M00_UNKNOWN_VOICE_CONVERSATION_ID": "43300",
        "MAIN_M00_AWAKEN_FADE_TICS": "28",
        "MAIN_M00_UNKNOWN_VOICE_DELAY_TICS": "18",
        "PALOMO_PLACEMENT_HIDDEN": "0",
        "PALOMO_PLACEMENT_MANSION_FOYER": "1",
        "PALOMO_PLACEMENT_MANSION_UPSTAIRS": "2",
        "PALOMO_PLACEMENT_MANSION": "PALOMO_PLACEMENT_MANSION_FOYER",
        "PALOMO_PLACEMENT_COUNT": "3",
    }
    for name, value in required.items():
        require(current.get(name) == value, f"unexpected constant {name}")
    for name, value in MAIN_STATES.items():
        require(current.get(name) == str(value), f"unexpected state {name}")
    for value, suffix in enumerate(MAIN_FLAGS):
        name = f"MAIN_M00_FLAG_{suffix}"
        require(current.get(name) == str(value), f"unexpected flag {name}")
    for objective_id, suffix in enumerate((
        "FIND_HELP", "CONVINCE_RESIDENTS", "SOLVE_RIDDLE",
        "GATHER_MATERIALS", "PREPARE_WEAPON", "DEFEAT_BULL",
        "CAPTURE_FOOL", "LEAVE_MANSION",
    )):
        name = f"MAIN_M00_OBJECTIVE_{suffix}"
        require(current.get(name) == str(objective_id),
                f"unexpected objective {name}")


def audit_zscript_and_mapinfo(project: Path, full_runtime: Path) -> None:
    root_text = read_text(project / "src/ZSCRIPT")
    includes = re.findall(r'^\s*#include\s+"([^"]+)"', root_text, re.MULTILINE)
    require(len(includes) == len(set(includes)), "duplicate ZSCRIPT include")
    for include in includes:
        require((full_runtime / include).is_file(),
                f"missing cumulative include: {include}")
    required_order = [
        "caelum/core/CaelumConstants.zs",
        "caelum/equipment/CaelumPersistentCharacterState.zs",
        "caelum/player/CaelumPlayer.zs",
        "caelum/quests/CaelumMainM00QuestController.zs",
        "caelum/quests/CaelumSocialDebugActions.zs",
        "caelum/dialogue/CaelumPalomoDialogue.zs",
        "caelum/hud/CaelumJournalOverlay.zs",
    ]
    positions = []
    for include in required_order:
        require(include in includes, f"missing ZSCRIPT include: {include}")
        positions.append(includes.index(include))
    require(positions == sorted(positions), "quest includes are out of order")

    definitions = constant_definitions(
        read_text(project / "src/caelum/core/CaelumConstants.zs")
    )
    references: set[str] = set()
    for path in full_runtime.rglob("*.zs"):
        references.update(re.findall(
            r"\bCaelumConstants\.([A-Za-z_][A-Za-z0-9_]*)",
            read_text(path),
        ))
    missing = sorted(references - set(definitions))
    require(not missing, f"undefined CaelumConstants references: {missing}")

    mapinfo = read_text(project / "src/MAPINFO")
    require(mapinfo.count('"CaelumMainM00QuestController"') == 1,
            "quest controller is not registered exactly once")
    require('AddDialogues = "CAPALOMO"' in mapinfo,
            "native dialogue resource is not registered")
    require('map MAP01 "$CA_MAP01_NAME"' in mapinfo,
            "MAP01 title is not localized")


def audit_persistent_state(project: Path) -> None:
    text = read_text(
        project / "src/caelum/equipment/CaelumPersistentCharacterState.zs"
    )
    for fragment in (
        "int QuestStateVersion;",
        "int QuestState[CaelumConstants.QUEST_CAPACITY];",
        "int QuestStage[CaelumConstants.QUEST_CAPACITY];",
        "bool MainM00Flag[CaelumConstants.MAIN_M00_FLAG_CAPACITY];",
        "int FactionStateVersion;",
    ):
        require(fragment in text, f"missing persistent field: {fragment}")

    initialize = method_span(text, "InitializeNewQuestState")
    require("QuestStateVersion = 2;" in initialize,
            "new character does not receive quest schema 2")
    ensure = method_span(text, "EnsureQuestStateInitialized")
    require("if (QuestStateVersion >= 2)" in ensure,
            "quest migration version guard is missing")
    require("ClearMainM00QuestRecord();" in ensure,
            "V4.33.0a test story is not reset")
    require("QuestStateVersion = 2;" in ensure,
            "quest migration is not committed")
    require("MagicBoxOwned =" not in ensure
            and "GrantMagicBox" not in ensure,
            "quest migration changes Magic Box ownership")

    begin = method_span(text, "BeginMainM00Prologue")
    for fragment in (
        "QUEST_MAIN_M00_THE_FOOL",
        "QUEST_STATE_ACTIVE",
        "MAIN_M00_STATE_AWAKENED",
        "MAIN_M00_FLAG_STARTED",
        "MAIN_M00_OBJECTIVE_FIND_HELP",
        "QuestObjectiveProgress[objective] = 0;",
        "int normalizedProgress = Clamp(",
        "QuestObjectiveProgress[objective] = normalizedProgress;",
        "QuestObjectiveTarget[objective] = 1;",
    ):
        require(fragment in begin, f"prologue initialization lost: {fragment}")
    require("QuestObjectiveProgress[objective] != 0" not in begin,
            "prologue initializer would reset completed objective progress")

    advance = method_span(text, "TryAdvanceMainM00State")
    require("QuestStage[questId] != expectedState" in advance,
            "stage transition does not require the expected state")
    require("nextState <= expectedState" in advance,
            "stage transition accepts a non-forward state")

    voice = method_span(text, "RecordMainM00UnknownVoiceHeard")
    require("MAIN_M00_STATE_AWAKENED" in voice
            and "MAIN_M00_STATE_MET_PALOMO" in voice
            and "MAIN_M00_FLAG_UNKNOWN_VOICE_HEARD" in voice,
            "Unknown Voice transition is incomplete")
    palomo = method_span(text, "RecordMainM00PalomoMet")
    for fragment in (
        "MAIN_M00_FLAG_UNKNOWN_VOICE_HEARD",
        "MAIN_M00_STATE_MET_PALOMO",
        "MAIN_M00_STATE_ARGENTO_ACTIVE",
        "MAIN_M00_FLAG_PALOMO_MET",
        "QuestObjectiveProgress[objective] = 1;",
    ):
        require(fragment in palomo, f"Palomo transition lost: {fragment}")

    placement = method_span(text, "ResolvePalomoPlacement")
    for fragment in (
        "PALOMO_PLACEMENT_HIDDEN",
        "PALOMO_PLACEMENT_MANSION_FOYER",
        "PALOMO_PLACEMENT_MANSION_UPSTAIRS",
        "MAIN_M00_STATE_ARGENTO_ACTIVE",
        "MAIN_M00_STATE_BOX_RECEIVED",
    ):
        require(fragment in placement, f"placement rule lost: {fragment}")
    require("RecordPalomoAdventureAccepted" not in text,
            "discarded Palomo adventure mutation remains")


def audit_player(project: Path) -> None:
    text = read_text(project / "src/caelum/player/CaelumPlayer.zs")
    for fragment in (
        "Actor MainM00UnknownVoiceSpeaker;",
        "int MainM00UnknownVoiceDelayTics;",
        "bool MainM00AwakeningVisualStarted;",
    ):
        require(fragment in text, f"missing transient prologue field: {fragment}")

    grant = method_span(text, "GrantMagicBoxFromPalomo")
    require("GrantMagicBoxOwnership()" in grant,
            "isolated Magic Box grant was removed")
    require("RecordMainM00" not in grant
            and "BeginMainM00" not in grant,
            "Magic Box grant still advances the canonical quest")

    voice = method_span(text, "OpenMainM00UnknownVoiceDialogue")
    for fragment in (
        'Spawn(\n            "CaelumUnknownVoiceSpeaker"',
        "MAIN_M00_UNKNOWN_VOICE_CONVERSATION_ID",
        "voice.StartConversation(self, false, false)",
        "RecordMainM00UnknownVoiceHeard();",
    ):
        require(fragment in voice, f"native Voice opening lost: {fragment}")

    update = method_span(text, "UpdateMainM00Prologue")
    for fragment in (
        'level.MapName != "MAP01"',
        "CharacterCreationComplete",
        "BeginMainM00Prologue()",
        "A_SetBlend(",
        '"caelum/ui/map_transition"',
        "MAIN_M00_UNKNOWN_VOICE_DELAY_TICS",
        "OpenMainM00UnknownVoiceDialogue();",
    ):
        require(fragment in update, f"prologue controller path lost: {fragment}")

    open_palomo = method_span(text, "OpenPalomoDialogue")
    require("MAIN_M00_FLAG_UNKNOWN_VOICE_HEARD" in open_palomo,
            "Palomo can be opened before the Voice")
    require("speaker.StartConversation(self, true, true)" in open_palomo,
            "Palomo no longer uses native conversation")

    sync = method_span(text, "SyncPalomoDialogueTokens")
    for token in (
        "CaelumMainM00PalomoMetToken",
        "CaelumMainM00AskedPalomoWhereToken",
        "CaelumMainM00AskedPalomoWhatHappenedToken",
        "CaelumMainM00NoticedMemoryGapToken",
        "CaelumMainM00ToldPalomoAboutVoiceToken",
    ):
        require(token in sync, f"dialogue token is not synchronized: {token}")

    for method_name in (
        "PersistCharacterState", "RestorePersistentCharacterState"
    ):
        body = method_span(text, method_name)
        require("EnsureQuestStateInitialized();" in body,
                f"{method_name} omits quest schema")
        require("EnsureFactionStateInitialized();" in body,
                f"{method_name} omits faction schema")
    new_character = method_span(text, "SpawnStartingDevelopmentEquipment")
    require("InitializeNewQuestState();" in new_character,
            "new characters do not initialize quest schema")


def audit_actor_dialogue_and_controller(project: Path) -> None:
    actor = read_text(
        project / "src/caelum/actors/CaelumFolkloreCharacters.zs"
    )
    palomo = class_span(actor, "CaelumPalomo")
    for fragment in (
        "bool NarrativeDismissed;",
        "bool IsNarrativeRevealReady()",
        "bool IsNarrativeFoyerComplete()",
        "bool IsVisibleToAnyActivePlayer()",
        "CheckSight(self)",
        "DeltaAngle(",
        "viewOffset <= 70.0",
        "!bInConversation",
        "Alpha = 0.0;",
        "Alpha = Min(1.0, Alpha + 0.08);",
        "PALOMO_MERCHANT_RETURN_DISTANCE",
    ):
        require(fragment in palomo, f"Palomo narrative behavior lost: {fragment}")

    dialogue = read_text(
        project / "src/caelum/dialogue/CaelumPalomoDialogue.zs"
    )
    for class_name in (
        "CaelumMainM00AskPalomoWhereAction",
        "CaelumMainM00AskPalomoWhatHappenedAction",
        "CaelumMainM00TellPalomoMemoryGapAction",
        "CaelumMainM00TellPalomoAboutVoiceAction",
        "CaelumMainM00FinishPalomoFoyerAction",
        "CaelumUnknownVoiceSpeaker",
        "CaelumPalomoConversationMenu",
    ):
        require(re.search(rf"\bclass\s+{class_name}\b", dialogue) is not None,
                f"missing dialogue class {class_name}")
    unknown = class_span(dialogue, "CaelumUnknownVoiceSpeaker")
    for fragment in (
        'RenderStyle "None";', "+NOBLOCKMAP", "+NOGRAVITY",
        "MarkConversationOpened()", "Destroy();",
    ):
        require(fragment in unknown, f"technical Voice speaker lost: {fragment}")

    capalomo = read_text(project / "src/CAPALOMO")
    require(re.findall(r"\bid\s*=\s*(\d+)\s*;", capalomo) == ["43300", "43200"],
            "CAPALOMO conversation IDs changed")
    pages = set(re.findall(r'\bpagename\s*=\s*"([^"]+)"', capalomo))
    targets = set(re.findall(r'\b(?:nextpage|link)\s*=\s*"([^"]+)"', capalomo))
    require(targets <= pages, f"USDF points to missing pages: {sorted(targets - pages)}")
    require("palomo_answer_voice_doubt" in pages,
            "authored hallucination follow-up is missing")
    for forbidden in (
        "CaelumPalomoAcceptAdventureAction",
        "CaelumPalomoTradeAction",
        "CaelumPalomoDiscountAction",
        "CaelumMagicBoxOwnershipToken",
        "CaelumPalomoEloquenceEligibleToken",
    ):
        require(forbidden not in capalomo,
                f"test-only Palomo route remains in canonical USDF: {forbidden}")
    giveitems = set(re.findall(r'\bgiveitem\s*=\s*"([^"]+)"', capalomo))
    classes = set(re.findall(
        r"\bclass\s+([A-Za-z_][A-Za-z0-9_]*)\b", dialogue
    ))
    require(giveitems <= classes,
            f"USDF action class is undefined: {sorted(giveitems - classes)}")

    controller = read_text(
        project / "src/caelum/quests/CaelumMainM00QuestController.zs"
    )
    body = class_span(controller, "CaelumMainM00QuestController")
    require("override void WorldTick()" in body,
            "MAP01 controller has no WorldTick")
    require('level.MapName != "MAP01"' in body,
            "MAP01 controller is not map-scoped")
    require("UpdateMainM00Prologue();" in body,
            "MAP01 controller does not reconstruct the prologue")
    require("QuestState[" not in body and "MainM00Flag[" not in body,
            "MAP01 controller stores authoritative quest state")


def audit_journal_and_language(project: Path) -> None:
    journal = read_text(project / "src/caelum/hud/CaelumJournalOverlay.zs")
    for fragment in (
        "QUEST_MAIN_M00_THE_FOOL",
        'return "CA_Q_M01_TITLE";',
        "MAIN_M00_STATE_ARGENTO_ACTIVE",
        'return "CA_Q_M01_STATE_ARGENTO_SOCIAL";',
        "MAIN_M00_OBJECTIVE_FIND_HELP",
        'return "CA_Q_M01_OBJ_FIND_HELP";',
        "PALOMO_PLACEMENT_MANSION_FOYER",
        "PALOMO_PLACEMENT_MANSION_UPSTAIRS",
        'default: return "CA_PALOMO_PLACEMENT_HIDDEN";',
    ):
        require(fragment in journal, f"Journal integration lost: {fragment}")

    language = read_text(project / "src/LANGUAGE")
    for key in NEW_LANGUAGE_KEYS:
        values = language_values(language, key)
        require(len(values) == 2,
                f"{key} must have exactly English and Spanish definitions")
    exact_spanish = {
        "CA_SPEAKER_UNKNOWN_VOICE": "Voz desconocida",
        "CA_DLG_M01_UNKNOWN_VOICE_WAKE": (
            "Despertá. No intentes recordar todavía. Hay alguien cerca que "
            "puede ayudarte a encontrar el camino."
        ),
        "CA_DLG_M01_PALOMO_FOYER": (
            "Buen día. O algo suficientemente parecido como para no discutir "
            "con el reloj."
        ),
        "CA_DLG_M01_PALOMO_VOICE_DOUBT": "No parece una alucinación.",
        "CA_DLG_M01_PALOMO_VOICE_DOUBT_REPLY": (
            "Las buenas nunca lo parecen."
        ),
        "CA_Q_M01_OBJ_TALK_ARGENTO": "Hablar con Argento",
    }
    for key, expected in exact_spanish.items():
        require(language_values(language, key)[1] == expected,
                f"authored Spanish text changed: {key}")

    referenced = set(re.findall(
        r"\$([A-Z][A-Z0-9_]+)",
        read_text(project / "src/CAPALOMO")
            + read_text(project / "src/MAPINFO"),
    ))
    require(referenced <= set(re.findall(
        r"^\s*([A-Z][A-Z0-9_]+)\s*=", language, re.MULTILINE
    )), f"unlocalized canonical keys: {sorted(referenced)}")

    forbidden_terms = (
        "selene", "limbo", "muerte", "muerto", "alma", "resurrección",
        "cadáver", "cuerpo corrompido", "death", "dead", "soul",
        "resurrection", "corpse", "corrupted body",
    )
    for key in CANONICAL_VISIBLE_KEYS:
        for value in language_values(language, key):
            lowered = value.lower()
            for term in forbidden_terms:
                require(term not in lowered,
                        f"mystery leak in visible key {key}: {term}")


def audit_accepted_foundations(project: Path, baseline_0a: Path) -> None:
    for relative in (
        "caelum/factions/CaelumFactionRules.zs",
        "caelum/quests/CaelumSocialDebugActions.zs",
        "caelum/equipment/CaelumPlayableWeapons.zs",
    ):
        current = runtime_path(project, relative)
        if not current.is_file():
            continue
        require(current.read_bytes() == (baseline_0a / relative).read_bytes(),
                f"accepted foundation changed in project: {relative}")
    debug = read_text(baseline_0a / "caelum/quests/CaelumSocialDebugActions.zs")
    for class_name in DEBUG_CLASSES:
        require(re.search(rf"\bclass\s+{class_name}\b", debug) is not None,
                f"accepted debug action is missing: {class_name}")


def audit_documents(project: Path) -> None:
    apply_text = read_text(project / "APLICAR_4_33_0b.txt")
    tests = read_text(project / "PRUEBAS_4_33_0b.txt")
    dialogue = read_text(project / "docs/DIALOGUE.md")
    quests = read_text(project / "docs/QUESTS_REPUTATION_FACTIONS.md")
    magic_box = read_text(project / "docs/MAGIC_BOX.md")
    status = read_text(project / "docs/IMPLEMENTATION_STATUS.md")
    roadmap = read_text(project / "docs/ROADMAP.md")
    require("NO contiene un PK3" in apply_text,
            "application guide is not source-only")
    require("V4.33.0a" in apply_text and "once" in apply_text,
            "application guide lacks baseline or file count")
    for section in ("A.", "B.", "C.", "D.", "E.", "F."):
        require(section in tests, f"manual test section is missing: {section}")
    for phrase in (
        "Voz desconocida", "No parece una alucinación",
        "Las buenas nunca lo parecen", "Hablar con Argento",
        "fuera del campo visual", "CaelumDebug",
    ):
        require(phrase in tests, f"manual matrix omits: {phrase}")
    require("USDF" in dialogue and "fuera de todos los campos visuales" in dialogue,
            "dialogue documentation is incomplete")
    require("MainM00Flag[64]" in quests and "V4.33.0a" in quests,
            "quest schema or migration is undocumented")
    require("GrantMagicBoxFromPalomo()" in magic_box,
            "Magic Box decoupling is undocumented")
    require("4.33.0b" in status and "4.33.0b" in roadmap,
            "status/roadmap do not record the revision")
    require("deterministic audits passed" in status,
            "implementation status still reports audits pending")
    story = project / "docs/MAP01_HISTORIA_Y_PROGRAMACION_v1_0.txt"
    require(sha256(story) == STORY_SHA256,
            "author-supplied MAP01 specification changed")


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
                    f"compiled output in package: {info.filename}")
            local = project / info.filename
            require(local.is_file(), f"package source is missing: {info.filename}")
            require(archive.read(info) == local.read_bytes(),
                    f"package bytes differ from project: {info.filename}")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--project-root", type=Path, required=True)
    parser.add_argument("--baseline-0a", type=Path, required=True)
    parser.add_argument("--full-runtime", type=Path, required=True)
    parser.add_argument("--package", type=Path)
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    project = args.project_root.resolve()
    baseline_0a = args.baseline_0a.resolve()
    full_runtime = args.full_runtime.resolve()

    for relative in RUNTIME_FILES:
        require((project / "src" / relative).is_file(),
                f"missing runtime source: {relative}")
    for relative in PROJECT_FILES:
        require((project / relative).is_file(),
                f"missing project source: {relative}")
    for relative in RUNTIME_FILES - {"LANGUAGE"}:
        path = project / "src" / relative
        if path.suffix == ".zs" or relative in {"CAPALOMO", "MAPINFO"}:
            check_delimiters(read_text(path), path.relative_to(project).as_posix())

    audit_runtime_reconstruction(project, baseline_0a, full_runtime)
    audit_constants(project, baseline_0a)
    audit_zscript_and_mapinfo(project, full_runtime)
    audit_persistent_state(project)
    audit_player(project)
    audit_actor_dialogue_and_controller(project)
    audit_journal_and_language(project)
    audit_accepted_foundations(project, baseline_0a)
    audit_documents(project)
    if args.package is not None:
        audit_package(project, args.package.resolve())
    print("V4.33.0b deterministic audit passed.")


if __name__ == "__main__":
    main()
