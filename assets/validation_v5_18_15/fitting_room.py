"""Open the silent modular equipment fitting room or check its real player bindings."""
import argparse
import ctypes
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import struct
import subprocess
import sys
import zipfile

from PIL import Image, ImageChops

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[1]
sys.path.insert(0, str(HERE.parent / "validation_v5_18_13"))
from check_slam import stage_wad


def binding(key):
    indices = [int(value) for value in key[1:].split("_")]
    if key.startswith("w"):
        return 0, indices[0], indices[1]
    if key.startswith("s"):
        return 1, indices[0], 1
    return 2 + indices[0], indices[1], 1


def expected_sockets():
    constants = (ROOT / "src/caelum/core/CaelumConstants.zs").read_text("utf8")
    ids = {}
    for key, value in re.findall(r"const ((?:WEAPON_TYPE_|SHIELD_TYPE_|ARMOR_TYPE_|ARMOR_SLOT_)\w+)\s*=\s*(\w+);", constants):
        if value.isdecimal():
            ids[key] = int(value)
        elif value in ids:
            ids[key] = ids[value]
    tiered = {ids["WEAPON_TYPE_"+name] for name in
              ("SCEPTER", "ORB", "SUPPORT_BOOK", "CENSER", "SUPPORT_STATUETTE", "EFFIGY")}
    weapons = {(0, kind, tier) for kind in range(ids["WEAPON_TYPE_COUNT"])
               for tier in ((1, 2, 3) if kind in tiered else (1,))}
    shields = {(1, kind, 1) for kind in range(ids["SHIELD_TYPE_COUNT"])}
    armor = {(2+slot, kind, 1) for slot in range(ids["ARMOR_SLOT_COUNT"])
             for kind in range(ids["ARMOR_TYPE_COUNT"]) if kind != ids["ARMOR_TYPE_BASE_CLOTHING"]}
    return weapons | shields | armor


def fixture(out, game):
    subprocess.run([sys.executable, "-X", "utf8", str(HERE.parent / "validation_v5_18_10/build_gallery.py"),
                    "--output", str(out)], check=True)
    modules = json.loads((ROOT / "assets/source/art/worn_equipment_904/MODULES.json").read_bytes())
    roster = json.loads((out / "roster.json").read_bytes())
    bodies = [row["label"] for row in roster if row["group"] == "Jugadores"]
    labels = ["Sin equipo"] + [row["label"] for row in roster if row["group"] == "Equipo"]
    assert len(labels) == 1 + len(modules) and len(bodies) == 14
    sockets = [(-1, 0, 1)]
    with zipfile.ZipFile(game) as package:
        for module in modules:
            key = module["module"]
            sockets.append(binding(key))
            stem = "models/caelum/players/gear/" + key
            fits = module.get("family_sha256", [module["sha256"]])
            for family, checksum in enumerate(fits):
                mesh = package.read(stem + (f"_f{family}" if family else "") + ".md3")
                assert hashlib.sha256(mesh).hexdigest() == checksum, (key, family)
                assert mesh[:4] == b"IDP3" and struct.unpack_from("<I", mesh, 76)[0] == 33, key
            assert package.read(stem + ".png").startswith(b"\x89PNG\r\n\x1a\n"), key
    assert set(sockets[1:]) == expected_sockets() and len(set(sockets)) == len(sockets)
    source = (HERE / "fitting_room.zs").read_text("utf8")
    slots, kinds, tiers = zip(*sockets)
    for placeholder, values in (("BODIES", bodies), ("PIECES", labels), ("SLOTS", slots),
                                ("KINDS", kinds), ("TIERS", tiers)):
        source = source.replace(placeholder, ",".join(json.dumps(v, ensure_ascii=False) for v in values))
    source = source.replace("ITEM_COUNT", str(len(modules)))
    overlay = out / "wardrobe.pk3"
    with zipfile.ZipFile(overlay, "w") as archive, zipfile.ZipFile(out / "galeria.pk3") as gallery:
        archive.writestr("ZSCRIPT", source.encode("utf8"))
        archive.writestr("MAPINFO", 'gameinfo { PlayerClasses = "CaelumPlayer" EventHandlers = "FittingRoom" }\n'
                         'map VESTIDOR "Probador de equipo" { nointermission }')
        archive.writestr("maps/VESTIDOR.wad", stage_wad())
        for name in gallery.namelist():
            if name.lower().startswith("textures/"):
                archive.writestr(name, gallery.read(name))
    return overlay, sockets


def controls(out, pairs):
    commands = [
        "snd_mastervolume 0", "i_pauseinbackground false", "vid_activeinbackground true",
        "vid_lowerinbackground false", "show_messages false", "crosshair 0", "screenblocks 12",
        'bind s "netevent outfit_seat"', 'bind b "netevent outfit_boots"', 'bind 0 "netevent outfit_empty"',
        "r_drawplayersprites false", "vid_maxfps 60", 'bind pgup "netevent outfit_item -1"',
        'bind pgdn "netevent outfit_item 1"', 'bind f2 "netevent outfit_form -1"',
        'bind f3 "netevent outfit_form 1"', 'bind leftarrow "netevent outfit_turn -1"',
        'bind rightarrow "netevent outfit_turn 1"', 'bind c "netevent outfit_set"',
    ]
    if pairs:
        commands.append("wait 140; exec step0000.cfg")
        for n, (form, item) in enumerate(pairs):
            following = "quit" if n + 1 == len(pairs) else f"exec step{n + 1:04}.cfg"
            select = f"netevent outfit_select {form} {item}"
            # Allow for the asynchronous console event when hardware capture stalls a tic.
            command = f"{select}; wait 5; {select}; wait 6; screenshot f{form:02}-i{item:02}.png; wait 4; {following}"
            (out / f"step{n:04}.cfg").write_bytes((command + "\n").encode())
    path = out / "view.cfg"
    path.write_bytes(("\n".join(commands) + "\n").encode())
    return path


def captured_pairs(log, sockets):
    current = None
    matches = set()
    for line in log.splitlines():
        state = re.search(r"FITTING form=(\d+) resolved=(\d+) item=(\d+) slots=([-\d,]+)", line)
        if state:
            form, identity, item = map(int, state.groups()[:3])
            values = [int(value) for value in state[4].split(",")]
            expected = [-1] * 6
            if item:
                slot, kind, tier = sockets[item]
                expected[slot] = 1 + kind if slot else 3 * kind + tier
            current = (form, item) if form == identity and values == expected else None
        captured = re.search(r"Captured f(\d+)-i(\d+)\.png", line)
        if captured and current == tuple(map(int, captured.groups())):
            matches.add(current)
    return matches


def check(out, pairs, sockets):
    baselines = {}
    visible = []
    for form, item in pairs:
        screenshot = out / f"f{form:02}-i{item:02}.png"
        with Image.open(screenshot) as frame:
            width, height = frame.size
            # Ignore changing HUD counters and the localized title. This also
            # catches a slot that reports a valid key while its item is invisible.
            figure = frame.convert("RGB").crop((width//5, height//7, width*4//5, height*9//10))
        if item == 0:
            baselines[form] = figure
        elif form in baselines:
            delta = ImageChops.difference(figure, baselines[form])
            changed = sum(delta.convert("L").histogram()[12:])
            assert changed > 0, ("Invisible equipment", form, item)
            visible.append(changed)
    result = {"forms": sorted({f for f, _ in pairs}), "captures": len(pairs), "modules": len(sockets) - 1,
              "poses_per_mesh": 33, "visible_equipment_comparisons": len(visible)}
    if visible:
        result["minimum_changed_pixels"] = min(visible)
    (out / "checked.json").write_text(json.dumps(result, indent=2) + "\n", encoding="utf8")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--game", type=Path)
    parser.add_argument("--output", type=Path, default=ROOT / "build/modular-fitting-room")
    parser.add_argument("--forms", nargs="+", type=int, choices=range(14),
                        help="Capture every piece and the empty baseline for these body IDs.")
    parser.add_argument("--items", nargs="+", type=int, help="Limit the capture to these catalogue positions.")
    args = parser.parse_args()
    out = args.output.resolve()
    out.mkdir(exist_ok=True, parents=True)
    version = re.search(r"Current release:\s*(\d+\.\d+\.\d+[a-z]?)", (ROOT / "README.md").read_text("utf8"))[1]
    folder = ROOT / "build" / f"CaelumArgenteum-{version}-prologue"
    game = args.game or folder / "caelum_argenteum.ipk3"
    if args.game is None and not game.is_file():
        subprocess.run([sys.executable, str(ROOT / "build_release.py"), "--output", str(folder)], check=True)
    game = game.resolve(strict=True)
    overlay, sockets = fixture(out, game)
    if args.items and (not args.forms or any(i < 0 or i >= len(sockets) for i in args.items)):
        parser.error("--items needs --forms and valid catalogue positions")
    items = list(dict.fromkeys([0, *args.items])) if args.items else range(len(sockets))
    pairs = [(f, i) for f in (args.forms or []) for i in items]
    print("AvPág/RePág cambia de pieza. F2/F3 cambia de personaje. Las flechas giran la figura.\n"
          "B: botas. S: sentarse o levantarse. 0: quitar equipo. C: conjunto. Sonido desactivado.", flush=True)
    awake = ctypes.windll.kernel32.SetThreadExecutionState
    awake.argtypes = [ctypes.c_uint]
    awake.restype = ctypes.c_uint
    if not awake(0x80000001):
        raise OSError("Windows declined the temporary keep-awake request")
    try:
        pending = pairs
        for attempt in range(3):
            run = out if not attempt else out / f"retry-{attempt}"
            run.mkdir(exist_ok=True)
            log = run_engine(game, overlay, run, controls(run, pending), pending)
            if not pending:
                return
            # Console captures can run ahead of a delayed network event in the
            # background. Keep a capture only after the engine reports that exact fit.
            captured = captured_pairs(log, sockets)
            if attempt:
                for form, item in captured:
                    shot = f"f{form:02}-i{item:02}.png"
                    shutil.copyfile(run/shot, out/shot)
            pending = [pair for pair in pending if pair not in captured]
            if not pending:
                break
        if pending:
            raise RuntimeError(f"Missing synchronized equipment captures: {pending}")
        check(out, pairs, sockets)
    finally:
        awake(0x80000000)


def run_engine(game, overlay, out, config, pairs):
    engine = os.environ.get("GZDOOM_EXE", r"C:\Program Files (x86)\GZDoom\gzdoom.exe")
    command = [engine, "-nosound", "-noautoload", "-iwad", str(game), "-file", str(overlay),
               "-config", str(out/"review.ini"), "-window", "+logfile", str(out/"engine.log"),
               "+map", "VESTIDOR", "+exec", str(config), "+language", "es"]
    with (out/"stdout.log").open("wb") as stream:
        native = subprocess.run(command, cwd=out, stdout=stream, stderr=stream,
                                timeout=120 + 2*len(pairs) if pairs else None)
    log = (out/"engine.log").read_text("utf8", errors="replace")
    if native.returncode or re.search(r"Script error|VM execution aborted|Execution could not continue", log, re.I):
        raise RuntimeError(log[-2000:])
    return log


if __name__ == "__main__":
    main()
