"""Check the twelve floor presentations and exercise pickup, equip, drop and recollection."""
import argparse
import json
from pathlib import Path
import re
import sys
import zipfile

import numpy as np
from PIL import Image, ImageChops

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[1]
sys.path[:0] = [str(ROOT / "assets/validation_v5_18_15"), str(ROOT / "assets/generators")]
from fitting_room import controls, fixture, run_engine
from character_mesh_frames import read_model


def verify_meshes(game):
    with zipfile.ZipFile(game) as archive:
        bindings = archive.read("caelum/data/ground_helmet_tiers.modeldef").decode()
        gear = "models/caelum/players/gear/"
        for kind, sprite in enumerate(("CHMG", "CHLT", "CHMD", "CHEH")):
            name = f"a0_{kind}.md3"
            worn = read_model(archive.read(gear + name))
            ground = read_model(archive.read(gear + "ground/" + name))
            assert len(ground) == len(worn)
            floor = min(mesh.positions[0, :, 2].min() for mesh in worn)
            for source, prop in zip(worn, ground):
                points = source.positions[0].copy()
                points[:, 2] -= floor
                assert len(prop.positions) == 1 and np.array_equal(points, prop.positions[0])
                assert np.array_equal(source.faces, prop.faces)
                assert np.array_equal(source.uv, prop.uv) and source.shader == prop.shader
            for tier, letter in enumerate("BCD", 1):
                skin = f"a0_{kind}" + (f"_t{tier}" if tier > 1 else "") + ".png"
                assert archive.getinfo(gear + skin).file_size > 0
                model_and_skin = f'Model 0 "ground/{name}" Skin 0 "{skin}"'
                frame = f"FrameIndex {sprite} {letter} 0 0"
                assert re.search(re.escape(model_and_skin) + r"[^}]*" + re.escape(frame), bindings)
    return {"identical_neutral_meshes_and_uvs": 4, "registered_tier_finishes": 12}


def photograph(game, out):
    overlay, sockets = fixture(out, game)
    helmets = [index for index, (slot, _, _) in enumerate(sockets) if slot == 2]
    cfg = controls(out, [])
    commands = ["wait 145", "netevent outfit_still", "netevent outfit_detail 1", "netevent outfit_floor 0", "wait 15"]
    # G from any other catalogue piece should open the floor view, even when
    # the last helmet was inspected on the floor.
    for _ in range(2):
        commands.extend(["netevent outfit_select 0 0 1", "wait 10", "netevent outfit_ground", "wait 15"])
    commands.extend(["netevent outfit_ground", "wait 15"])
    for kind, item in enumerate(helmets):
        for tier in (1, 2, 3):
            select = f"netevent outfit_select 0 {item} {tier}"
            commands.extend([select, "wait 12", select, "wait 19", f"screenshot worn{kind}-{tier}.png", "wait 8",
                             "netevent outfit_ground", "wait 21", f"screenshot floor{kind}-{tier}.png", "wait 8",
                             "netevent outfit_ground", "wait 19"])
    with cfg.open("a", encoding="utf8") as stream:
        stream.write("; ".join(commands + ["quit"]) + "\n")
    log = run_engine(game, overlay, out, cfg, [1] * 24)
    assert log.partition("Captured worn0-1.png")[0].count("FLOOR kind=0 tier=1 frame=1") >= 2
    deltas = []
    for kind in range(4):
        for tier in (1, 2, 3):
            floor = f"floor{kind}-{tier}.png"
            worn = f"worn{kind}-{tier}.png"
            worn_log, marker, following = log.partition(f"Captured {worn}")
            assert marker and f"HELMET kind={kind} tier={tier} key={1+kind+4*(tier-1)}" in worn_log
            switched, marker, _ = following.partition(f"Captured {floor}")
            assert marker and f"FLOOR kind={kind} tier={tier} frame={tier}" in switched
            assert (out / worn).is_file()
            if tier > 1:
                with Image.open(out / floor) as after, Image.open(out / f"floor{kind}-{tier-1}.png") as before:
                    w, h = after.size
                    region = (w * .25, h * .2, w * .75, h * .85)
                    diff = ImageChops.difference(after.convert("RGB").crop(region), before.convert("RGB").crop(region))
                    changed = sum(diff.convert("L").histogram()[9:])
                    assert changed > 20, (kind, tier, changed)
                    deltas.append(changed)
    return {"floor_captures": 12, "equipped_captures": 12, "minimum_pixels_changed_at_a_tier_switch": min(deltas)}


def transactions(game, out):
    wardrobe, _ = fixture(out, game)
    overlay = out / "roundtrip.pk3"
    with zipfile.ZipFile(wardrobe) as source, zipfile.ZipFile(overlay, "w") as target:
        for path in source.namelist():
            if path.lower().startswith(("maps/", "textures/")):
                target.writestr(path, source.read(path))
        target.writestr("ZSCRIPT", (HERE / "roundtrip.zs").read_bytes())
        target.writestr("MAPINFO", 'gameinfo { PlayerClasses="CaelumPlayer" EventHandlers="HelmetTransaction" }\n'
                        'map VESTIDOR "Helmet transactions" { nointermission }\n')
    cfg = controls(out, [])
    with cfg.open("a", encoding="utf8") as stream:
        stream.write("wait 1060; quit\n")
    log = run_engine(game, overlay, out, cfg, [1] * 50)
    found = {tuple(map(int, row)) for row in re.findall(r"HELMETROUND kind=(\d) tier=(\d) item=(\d+)", log)}
    assert "HELMETFAIL" not in log
    assert {(k, t) for k, t, _ in found} == {(k, t) for k in range(4) for t in (1, 2, 3)}, found
    assert len({item for _, _, item in found}) == 12
    return {"real_pickup_equip_drop_recollect_reequip_cycles": len(found)}


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--game", required=True, type=Path)
    parser.add_argument("--output", required=True, type=Path)
    parser.add_argument("--transactions", action="store_true")
    args = parser.parse_args()
    game, out = args.game.resolve(), args.output.resolve()
    out.mkdir(parents=True, exist_ok=True)
    report = verify_meshes(game)
    report.update(transactions(game, out) if args.transactions else photograph(game, out))
    (out / "result.json").write_text(json.dumps(report, indent=2) + "\n", encoding="utf8")
    print(json.dumps(report))
