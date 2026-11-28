"""Check exported hand contact and inspect the carried board from three camera angles."""
import argparse
import json
from pathlib import Path
import sys

import numpy as np
from scipy.spatial import cKDTree

from fitting_room import ROOT, controls, fixture, run_engine
sys.path.insert(0, str(ROOT/"assets/generators"))
from character_mesh_frames import read_model
from carried_shields import NORMAL, PALM


def vertices(file):
    return np.concatenate([m.positions for m in read_model(file.read_bytes())], axis=1)


def geometry():
    path = ROOT/"src/models/caelum/players"
    hands = [vertices(path/f"b{i}_hands.md3") for i in range(14)]
    worst = 0.
    depths = []
    for k in range(4):
        shield = vertices(path/f"gear/s{k}.md3")
        assert len(shield)==33
        origin = shield[0] - PALM
        grip = (np.linalg.norm(origin[:,:2],axis=1)<2.2) & (np.abs(origin[:,2])<=5)
        assert grip.any()
        depths.append(round(float(np.ptp(origin @ NORMAL)),2))
        for body in hands:
            # Track the closest palm and grip vertices over every exported pose.
            for frame in range(33):
                distance,_ = cKDTree(body[frame]).query(shield[frame,grip])
                worst=max(worst,float(min(distance)))
    assert min(depths)>17 and worst<2, (depths,worst)
    return {"grip_checks":4*14*33, "maximum_nearest_grip_distance":round(worst,3),
            "thickness_including_grip":depths}


def photograph(game,out):
    out.mkdir(parents=True,exist_ok=True)
    overlay,sockets=fixture(out,game)
    config=controls(out,[])
    commands=["wait 140","netevent outfit_detail 1","wait 10"]
    for item,(slot,kind,_) in enumerate(sockets):
        if slot!=1:
            continue
        for angle in (0,3,6):
            commands += [f"netevent outfit_select 0 {item}", f"netevent outfit_angle {angle}", "wait 14",
                         f"screenshot shield{kind}-{angle}.png","wait 8"]
    with config.open("a",encoding="utf8") as stream:
        stream.write("; ".join([*commands,"quit"])+"\n")
    log=run_engine(game,overlay,out,config,[1]*20)
    for k in range(4):
        assert f"slots=-1,{k+1},-1,-1,-1,-1" in log
        for a in (0,3,6):
            assert f"Captured shield{k}-{a}.png" in log
    return {"engine":"4.14.2","carried_shield_views":12}


if __name__=="__main__":
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--game",type=Path)
    parser.add_argument("--output",type=Path)
    args=parser.parse_args()
    result=geometry()
    if args.game:
        result.update(photograph(args.game.resolve(),args.output.resolve()))
        (args.output/"result.json").write_text(json.dumps(result,indent=2)+"\n",encoding="utf8")
    print(json.dumps(result))
