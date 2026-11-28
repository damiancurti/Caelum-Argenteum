"""Verify shell shape, covered head bindings and restoration on the real player."""
import argparse
import json
from pathlib import Path
import sys

import numpy as np
from PIL import Image, ImageChops

from check_crowns import check as check_roofs
from fitting_room import ROOT, controls, fixture, run_engine
sys.path.insert(0,str(ROOT/"assets/generators"))
from character_mesh_frames import read_model
from wearable_helmet_fit import stature


def neutral(path):
    return np.concatenate([m.positions[0] for m in read_model(path.read_bytes())])


def geometry():
    folder=ROOT/"src/models/caelum/players"
    maximum=0.
    for material in range(4):
        base=neutral(folder/f"gear/a0_{material}.md3")
        for family,scale in enumerate(stature()[1:],1):
            fitted=neutral(folder/f"gear/a0_{material}_f{family}.md3")
            maximum=max(maximum,float(np.abs(fitted/scale-base).max()))
    assert maximum<.03125,maximum
    files=sorted((folder/"tuck").glob("*.md3"))
    assert len(files)==56
    for path in files:
        free,covered=neutral(folder/path.name),neutral(path)
        assert free.shape==covered.shape and np.max(np.abs(free-covered))>1, path
    return {**check_roofs(),"covered_head_and_hair_meshes":len(files),
            "maximum_normalized_shell_coordinate_difference":round(maximum,4)}


def same_crop(first,second):
    with Image.open(first) as a, Image.open(second) as b:
        w,h=a.size
        box=(w*.30,h*.20,w*.70,h*.80)
        return ImageChops.difference(a.convert("RGB").crop(box),b.convert("RGB").crop(box)).getbbox() is None


def style_roundtrip(game, out):
    out.mkdir(parents=True,exist_ok=True)
    overlay,sockets=fixture(out,game)
    helmet=next(i for i,(slot,_,_) in enumerate(sockets) if slot==2)
    config=controls(out,[])
    commands=["wait 145","netevent outfit_still","netevent outfit_select 4 0","wait 28",
              "screenshot original.png","wait 10","netevent outfit_face","wait 10",
              "netevent outfit_hair","wait 18","screenshot selected.png","wait 10",
              f"netevent outfit_select 4 {helmet}","wait 28","screenshot equipped.png","wait 8",
              "netevent outfit_empty","wait 28","screenshot removed.png","wait 12","quit"]
    with config.open("a",encoding="utf8") as stream:
        stream.write("; ".join(commands)+"\n")
    log=run_engine(game,overlay,out,config,[1]*12)
    assert "slots=-1,-1,1,-1,-1,-1" in log
    assert same_crop(out/"selected.png",out/"removed.png")
    assert not same_crop(out/"original.png",out/"selected.png")


def photograph(game,out):
    out.mkdir(parents=True,exist_ok=True)
    overlay,sockets=fixture(out,game)
    helmets=[i for i,(slot,_,_) in enumerate(sockets) if slot==2]
    config=controls(out,[])
    with config.open("a",encoding="utf8") as stream:
        stream.write("wait 145; netevent outfit_still; netevent outfit_zoom; wait 12; exec fit0.cfg\n")
    for form in range(14):
        commands=[]
        def shot(event,label):
            commands.extend([event, "wait 14", event, "wait 22", f"screenshot {label}{form}.png","wait 8"])
        shot(f"netevent outfit_select {form} 0","bare")
        for material,item in enumerate(helmets):
            shot(f"netevent outfit_select {form} {item}",f"shell{material}-")
        shot("netevent outfit_reference 3","actual")
        shot("netevent outfit_reference 4","reference")
        shot(f"netevent outfit_select {form} 0","restored")
        commands.append("quit" if form==13 else f"exec fit{form+1}.cfg")
        (out/f"fit{form}.cfg").write_bytes(("; ".join(commands)+"\n").encode())
    log=run_engine(game,overlay,out,config,[1]*112)
    for form in range(14):
        for material,item in enumerate(helmets):
            assert f"FITTING form={form} resolved={form} item={item} slots=-1,-1,{material+1},-1,-1,-1" in log
            assert (out/f"shell{material}-{form}.png").is_file()
        assert same_crop(out/f"actual{form}.png",out/f"reference{form}.png"),("covered",form)
        assert same_crop(out/f"restored{form}.png",out/f"bare{form}.png"),("uncovered",form)
    return {"engine":"4.14.2","worn_helmet_captures":56,"explicit_covered_matches":14,
            "unequip_restoration_matches":14}


if __name__=="__main__":
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--game",type=Path)
    parser.add_argument("--output",type=Path)
    args=parser.parse_args()
    result=geometry()
    if args.game:
        result.update(photograph(args.game.resolve(),args.output.resolve()))
        style_roundtrip(args.game.resolve(),args.output.resolve()/"styles")
        result["nondefault_face_and_hair_restored"]=True
        (args.output/"result.json").write_text(json.dumps(result,indent=2)+"\n",encoding="utf8")
    print(json.dumps(result))
