"""Compare the twelve worn helmets on the real player and measure exported coverage."""
import argparse
from pathlib import Path
import json
import re
import sys

import numpy as np
from PIL import Image, ImageChops

ROOT = Path(__file__).resolve().parents[2]
sys.path[:0] = [str(ROOT/"assets/validation_v5_18_15"),str(ROOT/"assets/generators")]
from fitting_room import controls, fixture, run_engine
from character_mesh_frames import read_model
from wearable_helmet_fit import BRIM, stature


def intersects(triangles, z, direction):
    # Intersect a horizontal ray from the skull axis with the actual surface.
    origin = np.array((0,0,z))
    edges1 = triangles[:,1]-triangles[:,0]
    edges2 = triangles[:,2]-triangles[:,0]
    normal = np.cross(direction,edges2)
    det = np.sum(edges1*normal,axis=1)
    valid = abs(det)>1e-7
    offset = origin-triangles[valid,0]
    side = np.cross(offset,edges1[valid])
    u = np.sum(offset*normal[valid],axis=1)/det[valid]
    v = side@direction/det[valid]
    t = np.sum(edges2[valid]*side,axis=1)/det[valid]
    return np.any((u>=0)&(v>=0)&(u+v<=1)&(t>0))


def coverage():
    gear=ROOT/"src/models/caelum/players/gear"
    for family,scale in enumerate(stature()):
        suffix=f"_f{family}" if family else ""
        bounds=[]
        for kind in range(4):
            meshes=read_model((gear/f"a0_{kind}{suffix}.md3").read_bytes())
            tris=np.concatenate([m.positions[0,m.faces] for m in meshes])/scale
            points=tris.reshape(-1,3)
            bounds.append(np.stack((points.min(0),points.max(0))))
            if kind==1:
                assert points[:,2].min()>BRIM-.1,(family,"skullcap below brow")
            if kind==2:
                for z in (148.35,152.57,155.75):
                    for direction in ((1,.15,0),(1,-.15,0),(1,0,0)):
                        assert not intersects(tris,z,np.array(direction)),(family,"face blocked",z)
                    for direction in ((-1,0,0),(0,1,0),(0,-1,0)):
                        assert intersects(tris,z,np.array(direction)),(family,"open nape/cheek",z)
        hat,cap=bounds[:2]
        assert np.ptp(hat[:,1])>1.45*np.ptp(cap[:,1]) and hat[1,2]>cap[1,2]+7
    return {"families":7,"medium_face_side_and_nape_rays":126}


def changed(first,second):
    with Image.open(first) as a, Image.open(second) as b:
        w,h=a.size
        box=(w*.32,h*.14,w*.68,h*.72)
        delta=ImageChops.difference(a.convert("RGB").crop(box),b.convert("RGB").crop(box))
        return sum(delta.convert("L").histogram()[9:])


def native(game,out,forms):
    out.mkdir(parents=True,exist_ok=True)
    overlay,sockets=fixture(out,game)
    cfg=controls(out,[])
    helmets=[i for i,(slot,_,_) in enumerate(sockets) if slot==2]
    cases=[(f,k,t) for f in forms for k in range(4) for t in (1,2,3)]
    with cfg.open("a",encoding="utf8") as stream:
        stream.write("wait 145; netevent outfit_still; netevent outfit_detail 1; wait 12; exec helmet0.cfg\n")
    for index,(form,kind,tier) in enumerate(cases):
        name=f"f{form}-k{kind}-t{tier}"
        commands=[f"netevent outfit_select {form} {helmets[kind]}",f"netevent outfit_tier {tier}",
                  "wait 14",f"netevent outfit_select {form} {helmets[kind]}",f"netevent outfit_tier {tier}",
                  "wait 23",f"screenshot {name}.png","wait 8",
                  "netevent outfit_reference 5","wait 15","netevent outfit_reference 5","wait 20",
                  f"screenshot ref-{name}.png","wait 8",
                  "quit" if index==len(cases)-1 else f"exec helmet{index+1}.cfg"]
        (out/f"helmet{index}.cfg").write_bytes(("; ".join(commands)+"\n").encode())
    log=run_engine(game,overlay,out,cfg,[1]*(len(cases)*2))
    assert "Script error" not in log and "Unknown command" not in log
    diffs=[]
    for form,kind,tier in cases:
        name=f"f{form}-k{kind}-t{tier}.png"
        assert f"HELMET kind={kind} tier={tier} key={kind+1+4*(tier-1)}" in log
        assert changed(out/name,out/("ref-"+name))==0,("incorrect mesh or tier skin",name)
        if tier>1:
            pixels=changed(out/name,out/f"f{form}-k{kind}-t{tier-1}.png")
            assert pixels>20,("indistinguishable tier",name,pixels)
            diffs.append(pixels)
    return {"forms":forms,"native_bindings":len(cases),"visible_tier_changes":len(diffs),
            "minimum_pixels_changed_between_successive_tiers":min(diffs)}


def roster(game,out):
    out.mkdir(parents=True,exist_ok=True)
    overlay,sockets=fixture(out,game)
    cfg=controls(out,[])
    helmets=[i for i,(slot,_,_) in enumerate(sockets) if slot==2]
    expected=set()
    with cfg.open("a",encoding="utf8") as stream:
        stream.write("wait 145; exec family0.cfg\n")
    for form in range(14):
        commands=[]
        for kind,item in enumerate(helmets):
            for tier in (1,2,3):
                select=f"netevent outfit_select {form} {item} {tier}"
                commands.extend([select,"wait 7",select,"wait 8"])
                expected.add((form,item,kind,tier,1+kind+4*(tier-1)))
        commands.append("quit" if form==13 else f"exec family{form+1}.cfg")
        (out/f"family{form}.cfg").write_bytes(("; ".join(commands)+"\n").encode())
    log=run_engine(game,overlay,out,cfg,[1]*84)
    found={tuple(map(int,m)) for m in re.findall(
        r"FITTING form=(\d+) resolved=\d+ item=(\d+) slots=[^\n]+\nHELMET kind=(\d+) tier=(\d+) key=(\d+)",log)}
    assert expected<=found, sorted(expected-found)
    return {"live_body_type_tier_bindings":len(expected)}


if __name__=="__main__":
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--game",type=Path)
    parser.add_argument("--output",type=Path)
    parser.add_argument("--forms",type=int,nargs="+",default=[0,7])
    parser.add_argument("--roster",action="store_true")
    args=parser.parse_args()
    result=coverage()
    if args.game:
        game,out=args.game.resolve(),args.output.resolve()
        result.update(roster(game,out) if args.roster else native(game,out,args.forms))
        (args.output/"checked.json").write_text(json.dumps(result,indent=2)+"\n",encoding="utf8")
    print(json.dumps(result))
