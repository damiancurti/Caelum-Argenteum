"""Build the approved six-block Buenos Aires geometry from owned city profiles."""
from pathlib import Path
import json
import sys

sys.dont_write_bytecode = True
from generate_coastal_trials import CoastalMap

ROOT = Path(__file__).resolve().parents[2]
DATA = ROOT / "assets/buenos_aires/CITY.json"


def generate():
    data = json.loads(DATA.read_text(encoding="utf-8"))
    reference = json.loads((ROOT / "assets/map06_port/CITY.json").read_text(encoding="utf-8"))
    city = CoastalMap(data["map"])
    city.compact = True
    city.optimize_open_geometry = True
    city.add_default_things = False
    city.control_origin = tuple(data["control_origin"])
    city.control_columns = data["control_columns"]
    city.room(*data["ground"], flat=data["ground_flat"], wall=data["boundary_wall"])
    city.volume(data["water_tag"], data["water_floor"], data["water_surface"], data["water_flat"], data["water_flat"], water=True)
    city.room(*data["water"], floor=data["water_floor"], flat="CVPL02", volume=data["water_tag"])
    for block in data["blocks"]:
        x, y = block["column"]*data["step"][0], block["row"]*data["step"][1]
        city.room(x, y, x+data["step"][0]-data["street"], y+data["step"][1]-data["street"], flat=data["lot_flat"])
    for building in data["buildings"]:
        profile = reference["profiles"][building["profile"]]
        x1, y1, x2, y2 = building["bounds"]
        tag = building["tag"]
        city.volume(tag, profile["headroom"], profile["height"], profile["roof"], "CVCI04")
        city.room(x1, y1, x2, y2, floor=profile["height"], flat=profile["roof"], wall=profile["wall"])
        city.room(x1+64, y1+64, x2-64, y2-64, flat=profile["floor"], wall=profile["wall"], light=168, volume=tag)
        door_y = building["door_y"]
        city.room(x2-64, door_y, x2, door_y+profile["door_width"], flat=profile["floor"], wall=profile["wall"], light=184, volume=tag)
        city.volume(tag+1, profile["window_head"], profile["height"], profile["roof"], "CVCI04")
        for x in range(x1+128, x2-64, reference["detail"]["window_step"]):
            for y in [y1, y2-64]:
                city.room(x, y, x+64, y+64, floor=profile["window_sill"], flat="CMST03", wall=profile["wall"], light=176, volume=tag+1)
        if building["profile"] == "shop":
            city.room(x1+128, y1+128, x1+192, y2-128, floor=reference["detail"]["counter_height"], flat="CVPO01", wall="CVPO06", volume=tag)
    for rectangle in data["service_approaches"]+data["plaza_paths"]:
        city.room(*rectangle, flat=data["ground_flat"])
    city.room(*data["platform"], flat="CMST01")
    city.room(*data["track"], flat="CVPO06")
    city.room(*data["quay"], flat="CMST01")
    city.room(*data["pier"], flat=data["pier_flat"], wall="CVPO06")
    for rectangle in data["boundary_rectangles"]:
        city.room(*rectangle, floor=data["boundary_height"], flat="CMST01", wall=data["boundary_wall"])
    x, y, angle = data["spawn"]
    city.prop(1, x, y, angle)
    city.prop(30950, x, y+64, args=(1,0))
    # The six districts have walkable source geometry before content actors
    # are installed. No old WAD, texture or private fixture is distributed.
    city.write(ROOT / "src/maps")
    report = {"issue": 416, "map": data["map"], "blocks": len(data["blocks"]),
              "buildings": len(data["buildings"]), "cells": len(city.cells),
              "geometry_reduction": getattr(city, "geometry_reduction", {}),
              "qualification": "Geometry only; gameplay services and author visual acceptance remain pending."}
    (ROOT / "assets/buenos_aires/geometry.json").write_text(json.dumps(report, indent=2)+"\n", encoding="utf-8")


if __name__ == "__main__":
    generate()
