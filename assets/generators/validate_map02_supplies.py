#!/usr/bin/env python3
"""Audit MAP02's finite supplies against its accepted per-instance ledger.

Read-only inputs; the optional report records static checks separately from
native logs. Native recipe evidence must execute crafting, not only print budgets.
The corrected 4.37.8 ledger keys recipe inputs by catalogue identity. The original
4.37.6 report is preserved as provenance; its array-position join was incorrect.
"""
import argparse
from collections import Counter
import hashlib
import json
from pathlib import Path
import re

from validate_map02_layout import read_map

ROOT = Path(__file__).resolve().parents[2]
LEDGER = ROOT / "assets/validation_4378/MATERIAL_LEDGER.json"


def identity(item):
    return (item["catalogue_index"], item["chest"], item["chest_slot"],
            item["cls"], tuple(item["args"]), item["size_policy"])


def audit(manifest, map_data, ledger, constants, recipe_log=None, route_log=None):
    checks = []

    def check(label, passed):
        checks.append({"check": label, "passed": bool(passed)})

    things = map_data["thing"]
    counts = Counter(thing["type"] for thing in things)
    check("WAD map things match the generated manifest", things == manifest["things"])
    check("96 Mandingas, 192 rats and 39 chests", all(
        counts[kind] == number for kind, number in ((18037, 96), (18029, 192), (30973, 39))))
    check("65 actual equipment instances retain identities and chest allocation",
          len(manifest["loot"]) == 65 and len(ledger["instances"]) == 65
          and Counter(map(identity, manifest["loot"])) == Counter(map(identity, ledger["instances"]))
          and all(item["quantity"] == item["before_quantity"] == 1 for item in ledger["instances"]))
    check("No pre-existing chest materials are lost or counted twice",
          ledger["existing_chest_materials"] == 0)
    check("No authored finished equipment, ammunition, rations or keys on the floor",
          manifest["counts"]["equipment"] == 0 and all(
              counts[kind] == 0 for kind in (30970, 30971, 30972, 30982, 30983, 30984,
                                            30985, 30986, 30978, 30979, 18110, 18111, 18112,
                                            18100, 18101, 18102, 18103, 18104, 18123, 18124,
                                            18130, 18131, 18539)))
    drops = manifest["drops"]
    by_tid = {thing.get("id"): thing for thing in things}
    check("Each carrier has at most one assigned object", len({d["tid"] for d in drops}) == len(drops))
    totals = Counter()
    for drop in drops:
        totals[drop["cls"]] += drop["amount"]
        check(f"Carrier {drop['tid']} exists with the correct actor type",
              by_tid.get(drop["tid"], {}).get("type") == (18029 if drop["actor"] == "CaelumGiantRat" else 18037))
        check(f"Carrier {drop['tid']} has a dry original upper recovery anchor",
              drop["position"][2] == 0 and drop["position"][:2] ==
              [by_tid.get(drop["tid"], {}).get("x"), by_tid.get(drop["tid"], {}).get("y")])
    expected = {"CaelumArrowAmmo": 240, "CaelumBoltAmmo": 120, "CaelumCarbineAmmo": 120,
                "CaelumFoodRation": 96, "CaelumWaterRation": 96}
    for cls, amount in expected.items():
        check(f"Exact finite supply: {cls} = {amount}", totals[cls] == amount)
    keys = ("CaelumMazeSluiceKey", "CaelumMazeCryptKey", "CaelumMazeSanctumKey", "CaelumMazeNorthKey",
            "CaelumMazeSouthCellKey", "CaelumMazeWestCellKey", "CaelumMazeEastCellKey", "CaelumMazeNorthCellKey")
    check("Only the 224 authorized death objects, all with positive quantities",
          len(drops) == 224 and set(totals) == set(expected) | set(keys)
          and all(drop["amount"] > 0 for drop in drops))
    check("Exactly the eight established keys, once each",
          {name: amount for name, amount in totals.items() if name.endswith("Key")} == dict.fromkeys(keys, 1))
    for zone in range(4):
        assigned = [drop for drop in drops if drop["zone"] == zone]
        rats = [drop for drop in assigned if drop["actor"] == "CaelumGiantRat"]
        check(f"Block {zone}: 48 rats each supply exactly one ration",
              len(rats) == 48 and all(d["amount"] == 1 for d in rats)
              and Counter(d["cls"] for d in rats) == {"CaelumFoodRation": 24, "CaelumWaterRation": 24})
        key_carriers = [drop for drop in assigned if drop["cls"].endswith("Key")]
        check(f"Block {zone}: both local keys belong to Mandingas outside their cells",
              {d["cls"] for d in key_carriers} == {keys[zone], keys[zone + 4]}
              and all(d["actor"] == "CaelumMandinga" for d in key_carriers)
              and {tuple(d["position"][:2]) for d in key_carriers} ==
              {tuple(manifest["zones"][zone]["position"]), tuple(manifest["zones"][zone]["cell_key_position"])})
    ammunition = [drop for drop in drops if drop["cls"] in expected and drop["actor"] == "CaelumMandinga"]
    check("24 single-type ammunition stacks, each of the authorized 20 units",
          len(ammunition) == 24 and all(drop["amount"] == 20 for drop in ammunition))
    material_names = {int(value): name for name, value in re.findall(
        r"const\s+(MATERIAL_[A-Z0-9_]+)\s*=\s*(\d+)\s*;", constants)
        if name not in ("MATERIAL_TYPE_COUNT", "MATERIAL_FIRST_ACTIVE") and not name.startswith("MATERIAL_FAMILY_")}
    aggregates = {str(size): Counter() for size in range(5)}
    for item in ledger["instances"]:
        check(f"Equipment {item['catalogue_index']} has all five positive basic-material budgets",
              set(item["materials_by_size"]) == set(aggregates)
              and all(values and all(units > 0 and name in material_names.values() for name, units in values.items())
                      for values in item["materials_by_size"].values()))
        for size, materials in item["materials_by_size"].items():
            aggregates[size].update(materials)
    check("Per-instance budgets sum exactly to the accepted aggregate ledger",
          {size: dict(value) for size, value in aggregates.items()} == ledger["aggregate_basic_material_units_by_size"])
    if recipe_log is not None:
        check("Native completion covers all 325 item/size combinations without failures",
              "QA75_CRAFT_DONE cases=325 failures=0" in recipe_log
              and "QA75_CRAFT FAIL" not in recipe_log and "Script error" not in recipe_log)
        inputs = {}
        for entry, size, material, units in re.findall(
                r"QA75_RECIPE_INPUT entry=(\d+) size=(\d+) material=(\d+) units=(\d+)", recipe_log):
            inputs.setdefault((int(entry), size), {})[material_names.get(int(material), material)] = int(units)
        check("Native run reports exactly 325 allocated budgets", len(inputs) == 325)
        for item in ledger["instances"]:
            for size, materials in item["materials_by_size"].items():
                check(f"Native inputs match accepted equipment {item['catalogue_index']} size {size}",
                      inputs.get((item["catalogue_index"], size)) == materials)
    if route_log is not None:
        check("Native keyed route and collection complete without failure",
              "QA75_DONE failures=0 steps=3848" in route_log
              and "QA75 FAIL" not in route_log and "Script error" not in route_log)
        for phase in (0, 2):
            check(f"Native persistence phase {phase}: 12 gates, 288 death guards and drained chest",
                  f"QA75_PERSIST phase={phase} failures=0 opened=12 released=288" in route_log)
    return checks


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--recipe-log", type=Path)
    parser.add_argument("--route-log", type=Path)
    parser.add_argument("--output", type=Path)
    args = parser.parse_args()
    manifest_path = ROOT / "assets/map02_maze/MAP02_MANIFEST.json"
    map_path = ROOT / "src/maps/MAP02.wad"
    constants_path = ROOT / "src/caelum/core/CaelumConstants.zs"
    checks = audit(json.loads(manifest_path.read_text(encoding="utf-8")), read_map(map_path),
                   json.loads(LEDGER.read_text(encoding="utf-8")), constants_path.read_text(encoding="utf-8"),
                   args.recipe_log.read_text(encoding="utf-8") if args.recipe_log else None,
                   args.route_log.read_text(encoding="utf-8") if args.route_log else None)
    report = {"issue": 75, "checks": len(checks), "failures": sum(not c["passed"] for c in checks),
              "native_evidence_supplied": bool(args.recipe_log and args.route_log),
              "author_acceptance": "Recorded separately in HISTORY, originating release 4.37.6.",
              "sha256": {str(path.relative_to(ROOT)).replace("\\", "/"): hashlib.sha256(path.read_bytes()).hexdigest()
                         for path in (manifest_path, map_path, LEDGER, constants_path)}, "results": checks}
    if args.output:
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_bytes((json.dumps(report, indent=2) + "\n").encode("utf-8"))
    print(json.dumps({key: report[key] for key in ("issue", "checks", "failures", "native_evidence_supplied")}))
    for check in checks:
        if not check["passed"]:
            print("FAIL:", check["check"])
    return int(report["failures"] != 0)


if __name__ == "__main__":
    raise SystemExit(main())
