"""Typed native-save graph inspection for personal profile transfers (#434).

References are resolved from the exact runtime/engine ZScript declarations.
An arbitrary integer is never interpreted as an object index. World actors are
not part of a personal graph merely because an inventory object points at them.
"""
from __future__ import annotations

from dataclasses import dataclass
import copy
import hashlib
import json
from pathlib import Path
import re
from typing import Iterator
import zipfile

from caelum_profiles import ProfileError


@dataclass(frozen=True)
class Field:
    kind: str
    array: bool = False


@dataclass
class Declaration:
    parent: str
    fields: dict[str, Field]
    struct: bool = False
    native: bool = False


def _matching(text: str, begin: int, left: str = "{", right: str = "}") -> int:
    depth = 1
    for i in range(begin + 1, len(text)):
        if text[i] == left:
            depth += 1
        elif text[i] == right:
            depth -= 1
            if not depth:
                return i
    raise ProfileError("Unbalanced ZScript declaration in the selected runtime.")


def _clean(text: str) -> str:
    # Preserve length and line structure while hiding comments/string literals.
    return re.sub(r'//[^\n]*|/\*.*?\*/|"(?:\\.|[^"\\])*"|\'(?:\\.|[^\'\\])*\'',
                  lambda m: " " * len(m[0]), text, flags=re.S)


def _members(body: str) -> Iterator[str]:
    start = i = 0
    while i < len(body):
        if body[i] == "{":
            i = _matching(body, i)
            start = i + 1
        elif body[i] == ";":
            yield body[start:i].strip()
            start = i + 1
        i += 1


def _field(statement: str) -> Iterator[tuple[str, Field]]:
    statement = re.sub(r"\bdeprecated\s*\([^)]*\)", "", statement).strip()
    if not statement or "(" in statement or "=" in statement:
        return
    qualifiers = r"(?:(?:native|readonly|private|protected|transient|meta|deprecated|static|play|ui|clearscope)\s+)*"
    match = re.fullmatch(qualifiers + r"(Array\s*<\s*\w+\s*>|class\s*<\s*\w+\s*>|\w+)\s+(.+)", statement, re.S | re.I)
    if not match:
        return
    kind, names = match.groups()
    if kind.lower().startswith("class") and "<" in kind:
        kind = "classname"
    dynamic = kind.lower().startswith("array") and "<" in kind
    if dynamic:
        kind = re.search(r"<\s*(\w+)", kind)[1]
    for item in names.split(","):
        name = re.fullmatch(r"\s*(\w+)\s*(\[[^\]]+\])?\s*", item, re.S)
        if name:
            yield name[1].lower(), Field(kind.lower(), dynamic or name[2] is not None)


class NativeSchema:
    """Read-only type catalogue pinned to the two actual package hashes."""

    def __init__(self, engine: Path, runtime: Path):
        self.packages = {"engine": hashlib.sha256(engine.read_bytes()).hexdigest(),
                         "runtime": hashlib.sha256(runtime.read_bytes()).hexdigest()}
        self.types: dict[str, Declaration] = {}
        # The engine provides native class declarations; the runtime supplies
        # project classes. Reading sources once is an offline tool operation.
        for package in (engine, runtime):
            with zipfile.ZipFile(package) as archive:
                for name in archive.namelist():
                    if not name.lower().endswith(".zs"):
                        continue
                    text = _clean(archive.read(name).decode("utf-8-sig"))
                    for match in re.finditer(r"\b(class|struct)\s+(\w+)\s*(?::\s*(\w+))?[^;{}]*\{", text, re.I):
                        begin = match.end() - 1
                        end = _matching(text, begin)
                        fields = dict(pair for statement in _members(text[begin + 1:end]) for pair in _field(statement))
                        key = match[2].lower()
                        if key in self.types:
                            # Extensions may repeat a declaration, but conflicting
                            # reference types must never silently change meaning.
                            previous = self.types[key]
                            if any(k in previous.fields and previous.fields[k] != v for k, v in fields.items()):
                                raise ProfileError(f"Conflicting field declaration: {key}")
                            if match[3]:
                                if previous.parent and previous.parent != match[3].lower():
                                    raise ProfileError(f"Conflicting parent declaration: {key}")
                                previous.parent = match[3].lower()
                            previous.fields.update(fields)
                        else:
                            self.types[key] = Declaration((match[3] or "").lower(), fields,
                                                          match[1].lower() == "struct",
                                                          bool(re.search(r"\bnative\b", match[0], re.I)))

    def inherits(self, name: str, base: str) -> bool:
        visited = set()
        while name.lower() not in visited:
            key = name.lower()
            if key == base.lower():
                return True
            visited.add(key)
            declaration = self.types.get(key)
            if declaration is None or not declaration.parent:
                return False
            name = declaration.parent
        raise ProfileError("Cyclic native class inheritance.")

    def is_reference(self, field: Field) -> bool:
        target = self.types.get(field.kind)
        return target is not None and not target.struct and field.kind != "state"

    def references(self, obj: dict) -> Iterator[tuple[tuple[str | int, ...], int]]:
        """Yield only typed, non-null native object references."""
        def field_value(field: Field, value, path):
            if value is None:
                return
            if field.array:
                if not isinstance(value, list):
                    raise ProfileError(f"Invalid native array: {path}")
                for i, element in enumerate(value):
                    yield from field_value(Field(field.kind), element, (*path, i))
            elif self.is_reference(field):
                if isinstance(value, bool) or not isinstance(value, int):
                    raise ProfileError(f"Invalid native reference: {path}")
                yield path, value
            elif field.kind in self.types and self.types[field.kind].struct:
                # Engine handles (Font, Sector, Line, etc.) use their native
                # serializers: names/indices, not the objects[] namespace.
                if self.types[field.kind].native:
                    return
                yield from members(field.kind, value, path)

        def members(kind: str, value: dict, path):
            declaration = self.types.get(kind.lower())
            if declaration is None:
                raise ProfileError(f"Unknown saved class: {kind}")
            if not isinstance(value, dict):
                raise ProfileError(f"Invalid native class data: {path}")
            for key, data in value.items():
                field = declaration.fields.get(key.lower())
                if field is None:
                    raise ProfileError(f"Unknown saved field: {kind}.{key}")
                yield from field_value(field, data, (*path, key))

        for key, value in obj.items():
            if key.startswith("class:"):
                yield from members(key[6:], value, (key,))
        # Native AActor::Serialize uses historical names for several fields.
        # These are object references, not sector/TID/player/state indices.
        for key in ("inventory", "target", "master", "tracer", "lastenemy", "lastheard",
                    "lastlookactor", "damagesource", "poisoner", "alternative", "goal",
                    "blockingmobj", "viewpos"):
            if obj.get(key) is not None:
                value = obj[key]
                if isinstance(value, bool) or not isinstance(value, int):
                    raise ProfileError(f"Invalid native actor reference: {key}")
                yield (key,), value


def native_archive(path: Path) -> tuple[dict[str, bytes], dict, dict]:
    """Validate native data before producing any new recovery artifact."""
    with zipfile.ZipFile(path) as archive:
        if len(archive.namelist()) != len(set(archive.namelist())) or archive.testzip() is not None:
            raise ProfileError("Native save has duplicate members or a failed checksum.")
        members = {name: archive.read(name) for name in archive.namelist()}
    info = json.loads(members["info.json"])
    if info.get("Save Version") != 4560:
        raise ProfileError("Unsupported native save version; original retained.")
    return members, info, json.loads(members[info["Current Map"].lower() + ".map.json"])


def _set_path(obj: dict, path: tuple, value) -> None:
    for part in path[:-1]:
        obj = obj[part]
    obj[path[-1]] = value


class PersonalGraph:
    """Produce a closed personal graph without importing an entire campaign."""

    def __init__(self, schema: NativeSchema, policy: Path | None = None):
        self.schema = schema
        path = policy or Path(__file__).parent / "assets/profiles/personal-boundary.json"
        self.policy = json.loads(path.read_text(encoding="utf-8"))
        if self.policy["revision"] != 1:
            raise ProfileError("Unsupported personal boundary revision.")

    def personal_item(self, obj: dict) -> bool:
        return any(self.schema.inherits(obj["classtype"], base) for base in self.policy["root_bases"])

    def clean(self, obj: dict) -> dict:
        result = copy.deepcopy(obj)
        record = result.get("class:CaelumPersistentCharacterState")
        if record is not None:
            for key in self.policy["record_world_fields"]:
                record.pop(key, None)
        for kind, fields in self.policy["exclude_reference_fields"].items():
            data = result.get("class:" + kind)
            if data is not None:
                for key in fields:
                    data.pop(key, None)
        return result

    def transfer_ready(self, level: dict, player: int) -> None:
        """Transfers require a quiescent character; ordinary saves do not."""
        native = level['players'][player]
        body = level['objects'][native['mo']]
        live = body.get('class:CaelumPlayer', {})
        for field in self.policy['transfer_blocked_body_flags']:
            if live.get(field):
                raise ProfileError(f'Finish or cancel the active operation before transfer: {field}')
        # GZDoom 4.14.2 deliberately serializes the misspelled "conversionnpc".
        # Its pointer can outlive the dialogue; only the actor's active flag
        # blocks transfer. These are native ABI bindings, not gameplay tuning.
        guard = self.policy['native_conversation']
        speaker = native.get(guard['reference'])
        if speaker is not None:
            if isinstance(speaker,bool) or not isinstance(speaker,int) or not 0 <= speaker < len(level['objects']):
                raise ProfileError('Invalid native conversation reference.')
            flags = level['objects'][speaker].get(guard['flags'], 0)
            if isinstance(flags,bool) or not isinstance(flags,int):
                raise ProfileError('Invalid native conversation flags.')
            if flags & guard['active_mask']:
                raise ProfileError('Finish the current conversation before transfer.')
        cursor = body.get('inventory')
        seen = set()
        while cursor is not None:
            if cursor in seen:
                raise ProfileError('Cyclic inventory during transfer preparation.')
            seen.add(cursor)
            obj = level['objects'][cursor]
            for kind, fields in self.policy['transfer_blocked_inventory_fields'].items():
                values = obj.get('class:' + kind, {})
                if any(values.get(field) in prohibited for field, prohibited in fields.items()):
                    raise ProfileError(f'Finish or cancel the campaign activity before transfer: {kind}')
            for kind, fields in self.policy.get('transfer_blocked_inventory_references', {}).items():
                values = obj.get('class:' + kind, {})
                if any(values.get(field) is not None for field in fields):
                    raise ProfileError(f'Release the campaign object before transfer: {kind}')
            seat = obj.get('class:CaelumCardSeat', {})
            if seat.get('Duel') is not None:
                raise ProfileError('Leave the card session before transferring.')
            clock = obj.get('class:CaelumWorldClock', {})
            for field in ('TimeVote', 'TravelVote'):
                index = clock.get(field)
                if index is not None:
                    vote = level['objects'][index]
                    if any(values.get('Opened') for kind, values in vote.items() if kind.startswith('class:')):
                        raise ProfileError('Resolve the shared vote before transferring.')
            cursor = obj.get('inventory')

    def capture(self, level: dict, player: int) -> dict:
        if isinstance(player, bool) or not isinstance(player, int) or not 0 <= player < len(level["players"]):
            raise ProfileError("Invalid native character slot.")
        body = level["players"][player]["mo"]
        objects = level["objects"]

        def read(index: int) -> dict:
            if isinstance(index, bool) or not isinstance(index, int) or not 0 <= index < len(objects):
                raise ProfileError("Invalid object reference in the native ownership graph.")
            return objects[index]

        actor = read(body)
        if self.schema.inherits(actor['classtype'], 'CaelumStandalonePlayer'):
            raise ProfileError('Standalone match characters cannot become campaign profiles.')
        if actor["classtype"] != "CaelumPlayer":
            raise ProfileError("Selected owner is not a Caelum character.")
        live = actor.get("class:CaelumPlayer", {})
        roots, seen = [], set()
        cursor = actor.get("inventory")
        while cursor is not None:
            if cursor in seen:
                raise ProfileError("Cyclic native inventory chain.")
            seen.add(cursor)
            obj = read(cursor)
            if obj.get("class:Inventory", {}).get("Owner") != body:
                raise ProfileError("A native inventory link belongs to another owner.")
            if self.personal_item(obj):
                roots.append(cursor)
            cursor = obj.get("inventory")
        records = [index for index in roots if read(index)["classtype"] == "CaelumPersistentCharacterState"]
        if len(records) != 1:
            raise ProfileError("Exactly one committed personal record is required.")
        record = read(records[0])["class:CaelumPersistentCharacterState"]
        if not record.get("ProfileCommitted"):
            raise ProfileError("Finish character creation before transferring the profile.")
        if record.get('ProfileDeparted'):
            raise ProfileError('This character has departed to another campaign.')

        body_data = copy.deepcopy(live)
        # Include typed personal attributes/models without taking UI/world links.
        body_projection = {"classtype": "CaelumPlayer", "class:CaelumPlayer": body_data}
        for path, _ in list(self.schema.references(body_projection)):
            if path[1] not in self.policy["body_personal_fields"]:
                _set_path(body_projection, path, None)
        owned_actors = set(roots)
        pending = roots + [target for _, target in self.schema.references(body_projection)]
        captured: dict[int, dict] = {}
        while pending:
            index = pending.pop()
            if index == body or index in captured:
                continue
            obj = self.clean(read(index))
            if self.schema.inherits(obj["classtype"], "Actor") and index not in owned_actors:
                continue
            captured[index] = obj
            # A carried cargo/packed furniture edge conveys ownership, unlike
            # arbitrary target, opponent, dialogue or companion references.
            for kind, fields in self.policy["owned_actor_edges"].items():
                values = obj.get("class:" + kind, {})
                for key in fields:
                    value = values.get(key)
                    for target in value if isinstance(value, list) else [value]:
                        if target is not None:
                            read(target)
                            owned_actors.add(target)
                            pending.append(target)
            # Nested inventory belongs to the carried object, never a nearby NPC.
            if index in owned_actors and index not in roots and not self.schema.inherits(obj["classtype"], "Inventory"):
                cursor = obj.get("inventory")
                chain = set()
                while cursor is not None:
                    if cursor in chain:
                        raise ProfileError("Cyclic carried-container inventory.")
                    chain.add(cursor)
                    child = read(cursor)
                    if child.get("class:Inventory", {}).get("Owner") != index:
                        raise ProfileError("Carried container points at another owner's item.")
                    owned_actors.add(cursor)
                    pending.append(cursor)
                    cursor = child.get("inventory")
            pending.extend(target for _, target in self.schema.references(obj))

        order = sorted(captured)
        mapping = {old: new for new, old in enumerate(order)}
        mapping[body] = -1  # Explicit personal-owner marker; not an array index.
        removed = []

        def remap(obj):
            for path, target in list(self.schema.references(obj)):
                if target not in mapping:
                    removed.append({"class": obj["classtype"], "path": list(path),
                                    "world_class": read(target)["classtype"]})
                _set_path(obj, path, mapping.get(target))

        for obj in captured.values():
            remap(obj)
        remap(body_projection)
        # Preserve original inventory order while excluding world controllers.
        for position, root in enumerate(roots):
            captured[root]["inventory"] = mapping[roots[position + 1]] if position + 1 < len(roots) else None
        stats = {index: group for group, members in enumerate(level["thinkers"]) for index in members}
        return {"schema": 1, "packages": self.schema.packages.copy(),
                "source_indices": order,
                "objects": [captured[index] for index in order],
                "roots": [mapping[index] for index in roots],
                "record": mapping[records[0]], "body": body_projection,
                "health": actor.get("health", record.get("StoredHealth")),
                "name": level["players"][player].get("playername", ""),
                "readyweapon": mapping.get(level["players"][player].get("readyweapon")),
                "playerstate": level["players"][player].get("playerstate"),
                "thinker_groups": {str(mapping[index]): stats[index] for index in order if index in stats},
                "world_links_excluded": removed}

    def retire(self, level: dict, player: int, identity: str) -> dict:
        """Remove the carried material graph from a copy of the source world.

        Original files and campaign actors are retained. The inactive native slot
        can only be used again after an authorized profile installation.
        """
        graph = self.capture(level, player)
        result = copy.deepcopy(level)
        objects = result["objects"]
        body_index = result["players"][player]["mo"]
        body = objects[body_index]
        record_index = graph["source_indices"][graph["record"]]
        record = objects[record_index]["class:CaelumPersistentCharacterState"]
        if record.get("ExternalProfileId") != identity:
            raise ProfileError("The source slot does not own this external identity.")
        retired = {i for i in graph["source_indices"] if i != record_index
                   and self.schema.inherits(objects[i]["classtype"], "Actor")}
        retained = []
        cursor = body.get("inventory")
        while cursor is not None:
            if cursor not in retired:
                retained.append(cursor)
            cursor = objects[cursor].get("inventory")
        # A single offline pass clears links to retired material actors. This is
        # not a runtime actor census and never changes the original checkpoint.
        for obj in objects:
            for path, target in list(self.schema.references(obj)):
                if target in retired:
                    _set_path(obj, path, None)
        for index in retired:
            item = objects[index].get("class:Inventory")
            if item is not None:
                item.update(Owner=None, Amount=0)
            objects[index]["inventory"] = None
        for group in result["thinkers"]:
            group[:] = [index for index in group if index not in retired]
        for i, index in enumerate(retained):
            objects[index]["inventory"] = retained[i + 1] if i + 1 < len(retained) else None
        body["inventory"] = retained[0] if retained else None
        # ZScript bools use numeric bytes; engine-native bool members use JSON
        # booleans. Preserve the latter rather than globally converting JSON.
        record.update(ProfileDeparted=1)
        body["class:CaelumPlayer"]["ProfileDeparted"] = 1
        result["players"][player].update(readyweapon=None, pendingweapon=-1, psprites=None)
        return result

    def install(self, level: dict, graph: dict, player: int, identity: str, revision: int) -> dict:
        """Install into an uncommitted slot, returning a new level value only.

        Durable custody and native verification must precede publishing this
        artifact as a campaign checkpoint. This function never writes a file.
        """
        if graph.get("schema") != 1 or graph.get("packages") != self.schema.packages:
            raise ProfileError("Profile requires its exact engine and runtime packages.")
        if not identity or revision < 0 or not isinstance(graph.get("health"), int):
            raise ProfileError("Missing profile identity, revision or native health.")
        if not 0 <= player < len(level["players"]):
            raise ProfileError("Destination native slot does not exist.")
        result = copy.deepcopy(level)
        objects = result["objects"]
        native = result["players"][player]
        body_index = native["mo"]
        body = objects[body_index]
        if body["classtype"] != "CaelumPlayer":
            raise ProfileError("Destination is not a Caelum player.")
        existing, seen = [], set()
        cursor = body.get("inventory")
        while cursor is not None:
            if cursor in seen or not isinstance(cursor, int) or not 0 <= cursor < len(objects):
                raise ProfileError("Invalid destination inventory chain.")
            seen.add(cursor)
            obj = objects[cursor]
            if obj.get("class:Inventory", {}).get("Owner") != body_index:
                raise ProfileError("Destination slot references someone else's inventory.")
            existing.append(cursor)
            cursor = obj.get("inventory")
        records = [i for i in existing if objects[i]["classtype"] == "CaelumPersistentCharacterState"]
        if len(records) != 1:
            raise ProfileError("Destination needs one initialized empty personal record.")
        record_index = records[0]
        old_record = objects[record_index]["class:CaelumPersistentCharacterState"]
        if old_record.get("ProfileCommitted") and old_record.get("ExternalProfileId") != identity:
            raise ProfileError("Destination belongs to a different character; no inventory was replaced.")
        world_fields = {k: copy.deepcopy(old_record[k]) for k in self.policy["record_world_fields"] if k in old_record}
        retired = {i for i in existing if self.personal_item(objects[i]) and i != record_index}
        retained = [i for i in existing if i not in retired and i != record_index]
        for i in retired:
            objects[i]["class:Inventory"]["Owner"] = None
            objects[i]["class:Inventory"]["Amount"] = 0
            objects[i]["inventory"] = None
        for group in result["thinkers"]:
            group[:] = [i for i in group if i not in retired and i != record_index]

        # Campaign eligibility may still reference the former record. Keep that
        # historical object detached instead of replacing its identity in place.
        # Otherwise an imported character would inherit a prior occupant's reward.
        objects[record_index]["class:Inventory"]["Owner"] = None
        objects[record_index]["inventory"] = None
        mapping = {-1: body_index}
        for i in range(len(graph["objects"])):
            if i not in mapping:
                mapping[i] = len(objects)
                objects.append({})

        def remap(obj):
            for path, target in list(self.schema.references(obj)):
                if target not in mapping:
                    raise ProfileError("Personal payload contains an unresolved object reference.")
                _set_path(obj, path, mapping[target])

        for index, value in enumerate(graph["objects"]):
            obj = copy.deepcopy(value)
            remap(obj)
            for kind, resets in self.policy["rebase_fields"].items():
                if "class:" + kind in obj:
                    obj["class:" + kind].update({key: int(value) if isinstance(value, bool) else copy.deepcopy(value)
                                               for key, value in resets.items()})
            if self.schema.inherits(obj["classtype"], "Actor"):
                # Geometry indices belong to the destination. Carried items keep
                # their flags, physical dimensions and state; no source sectors.
                for key in ("pos", "sector", "floorsector", "ceilingsector", "floorz", "ceilingz", "floorpic", "ceilingpic"):
                    obj.pop(key, None)
                    if key in body:
                        obj[key] = copy.deepcopy(body[key])
                for key in ("tid", "watersector", "blockingline", "blockingmobj", "viewpos"):
                    obj.pop(key, None)
                obj["spawnpoint"] = copy.deepcopy(body["pos"])
                result["spawnindex"] = result.get("spawnindex", 0) + 1
                obj["spawnorder"] = result["spawnindex"]
            objects[mapping[index]] = obj
        target_record = objects[mapping[graph["record"]]]["class:CaelumPersistentCharacterState"]
        target_record.update(world_fields)
        target_record.update(ExternalProfileId=identity, ExternalProfileRevision=revision,
                             ProfileImportSerial=revision + 1, ProfileImportApplied=0, ProfileDeparted=0)
        personal_body = copy.deepcopy(graph["body"])
        remap(personal_body)
        body["class:CaelumPlayer"] = personal_body["class:CaelumPlayer"]
        body["class:CaelumPlayer"]["ProfileDeparted"] = 0
        body["health"] = graph["health"]
        # Native serialization and the game share one resource snapshot. The
        # import hook restores from these current values, not an older travel.
        resource_names = {"StoredAnima": "CurrentAnima", "StoredAir": "CurrentAir",
                          "StoredAdrenaline": "CurrentAdrenaline", "StoredLucidity": "CurrentLucidity",
                          "StoredHunger": "CurrentHunger", "StoredThirst": "CurrentThirst", "StoredSleep": "CurrentSleep"}
        target_record["StoredHealth"] = graph["health"]
        for stored, live in resource_names.items():
            if live in body["class:CaelumPlayer"]:
                target_record[stored] = body["class:CaelumPlayer"][live]
        chain = [mapping[i] for i in graph["roots"]] + retained
        for i, index in enumerate(chain):
            objects[index]["inventory"] = chain[i + 1] if i + 1 < len(chain) else None
            objects[index]["class:Inventory"]["Owner"] = body_index
        body["inventory"] = chain[0] if chain else None
        for index in graph["roots"]:
            body["inventoryid"] = body.get("inventoryid", 0) + 1
            objects[mapping[index]]["inventoryid"] = body["inventoryid"]
        for index, group in graph["thinker_groups"].items():
            while len(result["thinkers"]) <= group:
                result["thinkers"].append([])
            result["thinkers"][group].append(mapping[int(index)])
        native.update(health=graph["health"], playerstate=graph["playerstate"], camera=body_index,
                      readyweapon=mapping.get(graph["readyweapon"]), pendingweapon=-1)
        return result
