"""Check the soles and cuffs and photograph the production seated player pose."""
import argparse
import json
from pathlib import Path
import re
import sys

import numpy as np

from fitting_room import ROOT, controls, fixture, run_engine
sys.path.insert(0, str(ROOT / "assets/generators"))
from character_mesh_frames import read_model


def geometry():
    folder = ROOT / "src/models/caelum/players"
    paths = sorted(folder.glob("b*_boots.md3")) + sorted((folder/"gear").glob("a3_*.md3"))
    assert len(paths) == 18
    largest = 0
    for path in paths:
        frames = np.concatenate([m.positions for m in read_model(path.read_bytes())], axis=1)
        for side in (-1, 1):
            neutral = frames[0]
            shoe = (neutral[:, 1]*side > 0) & (neutral[:, 2] < 9)
            delta = frames[16, shoe] - neutral[shoe]
            largest = max(largest, float(np.ptp(delta, axis=0).max()))
            assert np.abs(delta[:, 2]).max() < 0.04 and largest <= 2/64, path
            cuff = (neutral[:, 1]*side > 0) & (neutral[:, 2] >= 28)
            assert np.ptp((frames[16, cuff]-neutral[cuff])[:, 2]) < 0.15, path
    return {"boot_pairs": len(paths), "maximum_seated_sole_displacement_spread": largest}


def photograph(game, out):
    out.mkdir(parents=True, exist_ok=True)
    overlay, sockets = fixture(out, game)
    config = controls(out, [])
    sequence = [f"netevent outfit_select 0 {next(i for i, k in enumerate(sockets) if k == (5,3,1))}",
                "netevent outfit_turn 2", "wait 14", "screenshot standing.png", "netevent outfit_seat",
                "wait 14", "screenshot armored.png", "netevent outfit_empty", "wait 14",
                "screenshot base.png", "netevent outfit_seat", "wait 14", "screenshot restored.png", "wait 8", "quit"]
    with config.open("a", encoding="utf8") as stream:
        stream.write("wait 140; "+"; ".join(sequence)+"\n")
    log = run_engine(game, overlay, out, config, [1]*12)
    assert "FITPOSE pose=16 seated=1" in log
    for key in ("armored", "base", "restored", "standing"):
        assert f"Captured {key}.png" in log
    assert re.search(r"slots=-1,-1,-1,-1,-1,-1\s+FITPOSE pose=16 seated=1",log)
    assert re.search(r"slots=-1,-1,-1,-1,-1,4\s+FITPOSE pose=16 seated=1",log)
    return {"engine": "4.14.2", "seated_pose": 16, "views": 4}


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--game", type=Path)
    parser.add_argument("--output", type=Path)
    args = parser.parse_args()
    result = geometry()
    if args.game:
        result.update(photograph(args.game.resolve(), args.output.resolve()))
        (args.output/"result.json").write_text(json.dumps(result, indent=2)+"\n", encoding="utf8")
    print(json.dumps(result))
