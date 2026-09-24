#!/usr/bin/env python3
"""Audit MAP02 counts, keyed topology and conservative collision clearance.

This is static evidence, not a replacement for native movement or combat tests.
The search uses generated 32-MU cells and collision-size clearance, rather than
the generator's logical maze graph, so accidental room/corridor bypasses count.
"""
from collections import Counter, deque
from pathlib import Path
import hashlib
import json
import math
import re
import struct

ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / "assets/map02_maze"
REPORT = ROOT / "assets/validation_4366/LAYOUT.json"


def read_map(path):
    blob = path.read_bytes()
    _, count, offset = struct.unpack_from("<4sii", blob)
    lumps = {}
    for i in range(count):
        start, size, name = struct.unpack_from("<ii8s", blob, offset + 16 * i)
        lumps[name.rstrip(b"\0").decode()] = blob[start:start + size]
    objects = {}
    for kind, body in re.findall(r"(vertex|sector|sidedef|linedef|thing)\s*\{(.*?)\}", lumps["TEXTMAP"].decode(), re.S):
        entry = {}
        for key, value in re.findall(r"(\w+)\s*=\s*([^;]+);", body):
            entry[key] = json.loads(value.strip())
        objects.setdefault(kind, []).append(entry)
    return objects


def main():
    current = json.loads((SOURCE / "MAP02_MANIFEST.json").read_text(encoding="utf-8"))
    legacy = json.loads((SOURCE / "legacy_4364/MAP02_MANIFEST.json").read_text(encoding="utf-8"))
    data = json.loads((SOURCE / "LAYOUT.json").read_text(encoding="utf-8"))
    actual = read_map(ROOT / "src/maps/MAP02.wad")
    checks = []

    def check(name, passed, details=None):
        checks.append(dict(name=name, passed=bool(passed), details=details))

    check("WAD things exactly match manifest", actual["thing"] == current["things"])
    counts = Counter(t["type"] for t in actual["thing"])
    old_counts = Counter(t["type"] for t in legacy["things"])
    for kind, number in {18037: 96, 18029: 192, 18038: 1, 30973: 39, 30978: 24, 30979: 24,
                         18111: 12, 18112: 6, 18110: 6, 30987: 4}.items():
        check(f"actual actor count {kind}", counts[kind] == number, counts[kind])
    for kind in (18037, 18038, 30973, 30978, 30979, 30961, 30963, 30964, 30965, 30966, 30975, 30976):
        check(f"accepted actor count preserved {kind}", counts[kind] == old_counts[kind])
    check("45 traps preserve each accepted type", len(current["traps"]) == 45 and
          Counter(t["type"] for t in current["traps"]) == Counter(t["type"] for t in legacy["traps"]))
    for key, kind, expected in [("arrows", 18111, 240), ("bolts", 18112, 120), ("bullets", 18110, 120)]:
        check(f"actual {key} units", counts[kind] * data["ammunition_bundle_units"] == expected)
    for key, kind in [("food", 30978), ("water", 30979)]:
        check(f"actual {key} units", counts[kind] * data["provision_bundle_units"] == 120)
    identity = lambda item: (item["catalogue_index"], item["chest"], item["chest_slot"], item["cls"], tuple(item["args"]))
    check("65 unique accepted T1 identities and chest assignments preserved",
          len(current["loot"]) == 65 and len({identity(i) for i in current["loot"]}) == 65 and
          sorted(map(identity, current["loot"])) == sorted(map(identity, legacy["loot"])) and
          all(i["tier"] == 1 for i in current["loot"]))
    check("four sections and four independent cells", len(current["zones"]) == 4 and len(current["prisoners"]) == 4)
    check("192 rats recorded in the per-section manifest", len(current["rats"]) == 192 and current["counts"]["rats"] == 192)
    for z, zone in enumerate(current["zones"]):
        check(f"section {z + 1} has twice as many rats as Mandingas",
              sum(1 for rat in current["rats"] if rat["zone"] == z)
              == data["mandingas_per_section"][z] * data["rats_per_mandinga"])
    check("four unique section keys and four unique cell keys", all(counts[k] == 1 for k in (30970, 30971, 30972, 30982, 30983, 30984, 30985, 30986)))
    equipment_source = (ROOT / "src/caelum/equipment/CaelumEquipmentPickups.zs").read_text(encoding="utf-8")
    for cls in ("CaelumCarbineAmmo", "CaelumArrowAmmo", "CaelumBoltAmmo"):
        body = equipment_source.split("class " + cls + " :", 1)[1].split("\nclass ", 1)[0]
        match = re.search(r"Inventory.Amount\s+(\d+)\s*;", body)
        check(f"{cls} native bundle amount agrees with map data", match and int(match[1]) == data["ammunition_bundle_units"])
    gate_lines = {}
    for line in actual["linedef"]:
        if line.get("id") in current["locks"] or str(line.get("id")) in current["locks"]:
            gate_lines.setdefault(line["id"], []).append(line)
    for gate in current["gates"]:
        lines = gate_lines.get(gate["tag"], [])
        check(f"gate {gate['tag']} native transparent barrier", len(lines) == gate["width"] // data["grid"] and
              all(l.get("twosided") and l.get("blocking") and l.get("blockprojectiles") and l.get("blockhitscan") and
                  l.get("blockuse") and not l.get("blocksight") and l.get("playeruse") and l.get("playeruseback") and
                  l.get("arg3") == gate["lock"] and
                  all(actual["sidedef"][l[s]]["texturemiddle"] == "CMGT02" for s in ("sidefront", "sideback")) for l in lines))

    grid = data["grid"]
    cells = {tuple(c[:2]): c[2:] for c in current["cells"]}
    radius = max(data["largest_player_radius"], data["largest_prisoner_radius"])
    height = data["largest_supported_height"]
    # Conservative: all cells overlapped by the collision disc must be open,
    # have headroom and differ by no more than a 16-MU authored shallow step.
    # This deliberately avoids every pit rather than assuming a drop is safe.
    valid = set()
    for key, cell in cells.items():
        x, y = key
        if cell[1] - cell[0] < height:
            continue
        okay = True
        for dx in (-grid, 0, grid):
            for dy in (-grid, 0, grid):
                distance = math.hypot(max(abs(dx) - grid / 2, 0), max(abs(dy) - grid / 2, 0))
                if distance >= radius:
                    continue
                other = cells.get((x + dx, y + dy))
                if other is None or abs(other[0] - cell[0]) > 16 or other[1] - max(other[0], cell[0]) < height:
                    okay = False
        if okay:
            valid.add(key)

    def nodes_at(position):
        x, y = position[:2]
        base_x, base_y = math.floor(x / grid) * grid, math.floor(y / grid) * grid
        # Points lie on grid boundaries; use every adjacent cell center within
        # half a diagonal, never a distant node that might cross a barrier.
        return {(px, py) for px in (base_x - grid, base_x) for py in (base_y - grid, base_y)
                if math.hypot(px + grid / 2 - x, py + grid / 2 - y) <= grid / math.sqrt(2) + 0.01 and (px, py) in valid}

    def blocked(a, b, closed):
        ax, ay = a[0] + grid / 2, a[1] + grid / 2
        bx, by = b[0] + grid / 2, b[1] + grid / 2
        for gate in closed:
            gx, gy = gate["center"]
            width = gate["width"] / 2
            if gate["axis"] == "x" and min(ax, bx) < gx < max(ax, bx) and gy - width <= ay <= gy + width:
                return True
            if gate["axis"] == "y" and min(ay, by) < gy < max(ay, by) and gx - width <= ax <= gx + width:
                return True
        return False

    def reachable(keys):
        closed = [g for g in current["gates"] if g["lock"] and g["lock"] not in keys]
        seen = nodes_at((-1152, 0))
        todo = deque(seen)
        while todo:
            a = todo.popleft()
            for dx, dy in ((grid, 0), (-grid, 0), (0, grid), (0, -grid)):
                b = (a[0] + dx, a[1] + dy)
                if b not in seen and b in valid and abs(cells[a][0] - cells[b][0]) <= 16 and not blocked(a, b, closed):
                    seen.add(b)
                    todo.append(b)
        return seen

    keys = set()
    stages = []
    for z in range(4):
        reach = reachable(keys)
        zone = current["zones"][z]
        cell = current["prisoners"][z]
        is_reachable = lambda point: bool(nodes_at(point) & reach)
        check(f"section {z + 1} progression key reachable before its lock", is_reachable(zone["position"]))
        check(f"section {z + 1} cell key reachable outside its cell", is_reachable(zone["cell_key_position"]))
        check(f"section {z + 1} cell inaccessible without its key", not is_reachable(cell["cell_center"]))
        check(f"section {z + 1} repair refuge reachable", is_reachable(current["refuges"][z]["center"]))
        for future in range(z + 1, 4):
            check(f"section {future + 1} cannot bypass section {z + 1} lock", not is_reachable(current["zones"][future]["position"]))
        check(f"boss inaccessible at stage {z + 1}", not is_reachable(current["boss_center"]))
        if z == 3:
            check("extraction reachable before boss key use", is_reachable(current["extraction"]))
            check("card unavailable before boss gate", not is_reachable(current["card"]))
            for travel_id, pos in current["travel"].items():
                check(f"travel {travel_id} unavailable before boss gate", not is_reachable(pos))
        keys.add(207 + z)
        unlocked = reachable(keys)
        for label in ("cell_center", "bed", "reserved_actor"):
            check(f"section {z + 1} {label} accessible after own key", bool(nodes_at(cell[label]) & unlocked))
        stages.append(dict(section=z + 1, cells_before_key=len(reach), cells_after_cell_key=len(unlocked)))
        keys.add(203 + z)
    complete = reachable(keys)
    rat_positions = [rat["position"] for rat in current["rats"]]
    check("rat positions are unique", len(rat_positions) == len({tuple(pos) for pos in rat_positions}))
    check("every rat starts in a reachable open cell", all(nodes_at(pos) & complete for pos in rat_positions))
    for i, room in enumerate(current["rooms"]):
        x, y = room["center"]
        # The six accepted pits deliberately occupy room centers. Validate a
        # clear perimeter approach, never interpret standing in a pit as a
        # necessary route to a room or its safely offset loot.
        approaches = [(x + dx, y + dy) for dx, dy in ((-192, -192), (-192, 192), (192, -192), (192, 192))]
        check(f"room {i} reachable with maximum collision size", all(nodes_at(p) & complete for p in approaches))
    for label in ("boss_center", "card", "extraction"):
        check(f"final {label} reachable with keys", bool(nodes_at(current[label]) & complete))
    for i, refuge in enumerate(current["refuges"]):
        check(f"refuge {i} complete repair station types", {s["type"] for s in refuge["stations"]} == {18000, 18001, 18003, 18004})
    check("three largest actors fit each dry walkway", (data["passage_width"] - data["channel_width"]) / 2 >= 6 * radius)
    result = dict(version=current["version"], evidence="static analysis", checks=len(checks),
                  failures=sum(not c["passed"] for c in checks),
                  scope="Fresh revision-2 MAP02 only. Geometry clearance excludes dynamic actors; native movement, projectile and save migration tests remain separate.",
                  collision=dict(radius=radius, height=height, maximum_step=16, valid_grid_cells=len(valid)),
                  stages=stages, results=checks,
                  hashes={str(p.relative_to(ROOT)).replace("\\", "/"): hashlib.sha256(p.read_bytes()).hexdigest()
                          for p in (ROOT / "src/maps/MAP02.wad", SOURCE / "MAP02_MANIFEST.json", SOURCE / "LAYOUT.json", SOURCE / "legacy_4364/MAP02.wad")})
    REPORT.parent.mkdir(parents=True, exist_ok=True)
    REPORT.write_text(json.dumps(result, indent=2) + "\n", encoding="utf-8")
    print(f"MAP02 layout: {result['checks']} checks, {result['failures']} failures")
    for entry in checks:
        if not entry["passed"]:
            print("FAIL:", entry["name"], entry["details"])
    return bool(result["failures"])


if __name__ == "__main__":
    raise SystemExit(main())
