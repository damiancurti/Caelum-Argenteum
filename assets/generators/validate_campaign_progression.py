"""Audit authored campaign structure; unresolved design is not runtime completion.

Run without arguments for the current planning audit. --require-complete rejects
the open authoring fields; it is a delivery gate, not the default project check.
This reads data only and neither generates runtime gates nor changes saves.
"""
from pathlib import Path
import argparse
import json
import sys

ROOT = Path(__file__).resolve().parents[2]


def audit(plan):
    errors = []
    pending = []

    def check(condition, message):
        if not condition:
            errors.append(message)

    chapters = plan["chapters"]
    chapter_ids = [row["id"] for row in chapters]
    check(len(chapter_ids) == len(set(chapter_ids)), "Duplicate chapter IDs")
    check(plan["chapter_order"] == chapter_ids, "Chapter order differs from the authored sequence")
    check([row["major_essences"] for row in chapters] == [1, 7, 7, 7], "Canonical Major distribution changed")
    check(sum(row["major_essences"] for row in chapters) == plan["targets"]["major_essences"], "Major total differs from target")
    cards = json.loads((ROOT / "assets/manifests/tarot_78_v4369.json").read_text(encoding="utf-8-sig"))["cards"]
    card_ids = {row["card_id"] for row in cards}
    check(card_ids == set(range(78)), "Existing Tarot manifest must cover IDs 0..77")
    check(plan["targets"]["minor_essences"] == sum(row["arcana"] == "minor" for row in cards), "Minor total differs from manifest")
    check(plan["progression_policy"]["final_card_id"] == 21, "Canonical final World card changed")
    route = plan["established_route"]
    nodes = {row["id"]: row for row in route["nodes"]}
    check(len(nodes) == len(route["nodes"]), "Duplicate opening-route node IDs")
    check(route["entry"] in nodes, "Opening-route entry missing")
    placed = [row["essence_id"] for row in nodes.values()]
    check(len(placed) == len(set(placed)), "Duplicate opening essence placement")
    check({row["map"]: row["essence_id"] for row in nodes.values()} == {"MAP01": 0, "MAP02": 36, "MAP03": 60}, "Accepted opening essence placements changed")
    for node in nodes.values():
        check(node["chapter"] in chapter_ids, f"Unknown chapter for {node['id']}")
        check(node["essence_id"] in card_ids, f"Unknown essence for {node['id']}")
        check((ROOT / "src/maps" / (node["map"] + ".wad")).is_file(), f"Missing established map {node['map']}")
    for edge in route["edges"]:
        check(edge["from"] in nodes and edge["to"] in nodes, "Unknown opening-route endpoint")
    reachable = {route["entry"]} if route["entry"] in nodes else set()
    while True:
        expanded = reachable | {edge["to"] for edge in route["edges"] if edge["from"] in reachable and edge["to"] in nodes}
        if expanded == reachable:
            break
        reachable = expanded
    check(reachable == set(nodes), "Unreachable opening-route node")
    for chapter in chapters:
        pending.extend(f"{chapter['id']}: {item}" for item in chapter.get("unresolved", []))
    finale = plan["finale"]
    check(finale["condition_operator"] == "AND", "Finale must combine reputation AND acquired essences")
    for field in ("reputation_track", "reputation_minimum", "acquired_essence_minimum", "mandatory_essence_ids", "cooperative_eligibility"):
        if finale[field] is None:
            pending.append("finale: " + field)
    if finale["acquired_essence_minimum"] is not None:
        check(finale["acquired_essence_minimum"] == len(card_ids), "Approved finale requires all acquired essences")
        check(set(finale["mandatory_essence_ids"]) == card_ids, "Finale mandatory identities do not cover the catalogue")
        check(finale["acquired_essence_minimum"] == finale["existing_deity_damage_power"]["required_acquired_essences"], "Finale and existing deity-damage requirements differ")
        check(finale.get("reputation_track_operator") == "ANY", "Finale reputation requires any one approved faction")
        check(finale.get("faction_membership_required") is False, "Finale must not add faction membership")
    unassigned = sorted(card_ids - set(placed))
    pending.append(f"Campaign acquisition assignments outside opening route: {len(unassigned)}")
    pending.append("Full regional geographic/ability graph and circular-lock audit remain unauthored")
    check(not plan["runtime_enabled"], "This authoring plan must not silently enable runtime behavior")
    return {"issue": plan["issue"], "errors": errors, "pending_authoring": pending,
            "opening_nodes_reachable": sorted(reachable), "unassigned_campaign_essence_ids": unassigned,
            "scope": "Static opening graph and canonical count audit; no full-campaign reachability or native acceptance claim"}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--require-complete", action="store_true")
    args = parser.parse_args()
    plan = json.loads((ROOT / "assets/campaign/PROGRESSION.json").read_text(encoding="utf-8"))
    result = audit(plan)
    print(json.dumps(result, indent=2))
    return int(bool(result["errors"] or (args.require_complete and result["pending_authoring"])))


if __name__ == "__main__":
    sys.exit(main())
