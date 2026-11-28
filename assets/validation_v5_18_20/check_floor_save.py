"""Load a dropped helmet from the previous beta and from the current MAP01 save."""
import argparse
import json
import os
from pathlib import Path
import re
import subprocess
import zipfile

HERE = Path(__file__).resolve().parent
PROBE = re.compile(r"^FLOORSAVE id=(\d+) tier=(\d+) size=(\d+) durability=(\d+) frame=(\d+)", re.M)


def verify(previous, current, out):
    out.mkdir(parents=True, exist_ok=True)
    overlay = out / "floor-check.pk3"
    with zipfile.ZipFile(overlay, "w") as package:
        package.write(HERE / "floor_save.zs", "ZSCRIPT")
        package.writestr("MAPINFO", 'gameinfo { AddEventHandlers = "FloorHelmetSaveCheck" }\n')
    engine = os.environ.get("GZDOOM_EXE", r"C:\Program Files (x86)\GZDoom\gzdoom.exe")
    saved_identity = None
    for label, game, slot, save in [
        ("original", previous, None, "oldhelmet"),
        ("import", current, "oldhelmet", "newhelmet"),
        ("reload", current, "newhelmet", None),
    ]:
        config = out / f"{label}.cfg"
        log = out / f"{label}.log"
        commands = ["wait 120"]
        if not slot:
            commands += ["netevent ground933_make", "wait 85"]
        commands += ["netevent ground933_inspect", "wait 45"]
        if save:
            commands += [f"save {save}", "wait 65"]
        config.write_text("i_pauseinbackground false\nvid_activeinbackground true\nvid_lowerinbackground false\n"
                          "snd_mastervolume 0\n" + "; ".join(commands + ["quit"]) + "\n", encoding="utf8")
        entry = ["-loadgame", slot + ".zds"] if slot else ["+map", "MAP01"]
        with (out / f"{label}.stdout").open("wb") as output:
            subprocess.run([engine, "-nosound", "-noautoload", "-iwad", str(game), "-file", str(overlay),
                            "-savedir", str(out), "-config", str(out / "test.ini"), "-window",
                            "+logfile", str(log), *entry, "+exec", str(config)], cwd=out, stdout=output,
                           stderr=output, check=True, timeout=165)
        written = log.read_text("utf8", errors="replace")
        assert not re.search("Script error|VM execution aborted|Execution could not continue", written, re.I)
        rows = {tuple(map(int, row)) for row in PROBE.findall(written)}
        assert len(rows) == 1, (label, rows)
        row = rows.pop()
        if saved_identity is None:
            saved_identity = row[:4]
        assert row[:4] == saved_identity and row[1] == 3 and row[4] == (3 if slot else 0), (label, row)
        if save:
            assert (out / (save + ".zds")).is_file()
    return {"map": "MAP01", "previous_floor_frame": 0, "imported_floor_frame": 3, "reloaded_floor_frame": 3,
            "item_id": saved_identity[0], "tier": saved_identity[1], "size": saved_identity[2],
            "durability": saved_identity[3]}


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--previous", required=True, type=Path)
    parser.add_argument("--game", required=True, type=Path)
    parser.add_argument("--output", required=True, type=Path)
    args = parser.parse_args()
    results = verify(args.previous.resolve(), args.game.resolve(), args.output.resolve())
    (args.output / "result.json").write_text(json.dumps(results, indent=2) + "\n", encoding="utf8")
