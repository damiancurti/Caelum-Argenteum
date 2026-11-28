"""Fit owned inventory models to the player's animated hand, head and clothing sockets."""
from collections import defaultdict
from pathlib import Path
import hashlib
import json
import math

import numpy as np
from PIL import Image

from character_mesh_frames import ROOT, Surface, animate, animate_boot, encode, read_model, rigid_track, subset
from wearable_helmet_fit import fit_helmet
from carried_shields import sculpt as sculpt_shield
from sculpted_character_art import surfaces as sculpt_surfaces

SRC = ROOT / "src"
DEST = SRC / "models/caelum/players/gear"
ART = ROOT / "assets/source/art/worn_equipment_904"
WEAPONS = ("sword staff carbine dagger hatchet machete javelin axe flail spear greatsword "
           "war_axe halberd giant_gauntlets shotgun longbow crossbow bell scepter orb pickaxe "
           "utility_staff bolas book censer statuette effigy").split()
TIERS = {"scepter", "orb", "book", "censer", "statuette", "effigy"}
SHIELDS = ("buckler", "kite", "tower", "magic")
ARMOR = ("helmets", "torso", "hands", "feet")
MATERIALS = ("magic", "light", "medium", "heavy")
# Native player art uses centimeters from sole to crown, prior to actor scaling.
LENGTH = (90,160,99,33,60,70,155,93,88,184,132,119,186,32,104,148,83,24,66,24,98,153,62,28,36,25,31)


def load_obj(path):
    vertices, tex, groups = [], [], defaultdict(list)
    for line in path.read_text("utf8").splitlines():
        words = line.split()
        if not words:
            continue
        if words[0] == "v":
            x, y, z = map(float, words[1:4])
            vertices.append((x, -z, y))
        elif words[0] == "vt":
            u, v = map(float, words[1:3])
            tex.append((u, 1-v))
        elif words[0] == "usemtl":
            skin = words[1]
        elif words[0] == "f":
            face = [tuple(int(i)-1 for i in token.split("/")[:2]) for token in words[1:]]
            groups[skin].extend((face[0], face[i], face[i+1]) for i in range(1, len(face)-1))
    result = []
    for skin, triangles in groups.items():
        pairs, ids = np.unique(np.asarray(triangles).reshape(-1,2), axis=0, return_inverse=True)
        result.append(Surface(np.asarray(vertices)[pairs[:,0]][None], ids.reshape(-1,3),
                              np.asarray(tex)[pairs[:,1]], skin))
    return result


def atlas(name, surfaces, write_image=True):
    skins = sorted({s.shader for s in surfaces})
    side = math.ceil(math.sqrt(len(skins)))
    tile = 256
    img = Image.new("RGBA",(tile*side,tile*side)) if write_image else None
    for index, skin in enumerate(skins):
        x,y = (index%side)*tile,(index//side)*tile
        for surface in surfaces:
            if surface.shader == skin:
                surface.uv = (np.clip(surface.uv,0,1)*(tile-4)+[x+2,y+2])/(tile*side)
        if img is None:
            continue
        with Image.open(SRC/skin) as page:
            page = page.convert("RGBA").resize((tile-4,tile-4),Image.Resampling.LANCZOS)
        img.paste(page,(x+2,y+2))
        # Extend border texels so mipmaps do not introduce black seams.
        img.paste(page.crop((0,0,1,tile-4)).resize((2,tile-4)),(x,y+2))
        img.paste(page.crop((tile-5,0,tile-4,tile-4)).resize((2,tile-4)),(x+tile-2,y+2))
        img.paste(img.crop((x,y+2,x+tile,y+3)).resize((tile,2)),(x,y))
        img.paste(img.crop((x,y+tile-3,x+tile,y+tile-2)).resize((tile,2)),(x,y+tile-2))
    if img is not None:
        img.save(DEST/(name+".png"),optimize=False)


def bounds(surfaces):
    return np.vstack([s.positions[0] for s in surfaces])


def fit(points, low, high, center, dimensions):
    p = (points-(low+high)/2)/np.maximum(high-low,0.01)
    return p[:,[1,0,2]] * [-dimensions[0],dimensions[1],dimensions[2]] + center


def build(name, path, category, index, label, helmet_family=0):
    raw = load_obj(path) if path.suffix == ".obj" else read_model(path.read_bytes())
    skin_name = name.split("_f")[0]
    atlas(skin_name,raw,write_image=helmet_family==0)
    all_points = bounds(raw)
    low, high = all_points.min(0), all_points.max(0)
    surfaces = []
    pair = (category=="weapon" and label=="giant_gauntlets") or (category=="armor" and index in (2,3))
    for side in ((-1,1) if pair else (0,)):
        pieces = [subset(s, side * (s.positions[0][s.faces].mean(axis=1)[:,0]-(low[0]+high[0])/2)>=0) for s in raw] if pair else raw
        pieces = [s for s in pieces if s is not None]
        data = bounds(pieces)
        a,b = data.min(0), data.max(0)
        # Align the dominant axis of the display model to the held direction.
        flat = data[:,[0,2]]
        _, eig = np.linalg.eigh(np.cov(flat.T))
        axis = eig[:,-1]
        if axis[1]<0: axis=-axis
        forward = flat @ axis
        lateral = flat @ [axis[1],-axis[0]]
        foot = category=="armor" and index==3
        if foot:
            center = (5, side*12.5, 16)
            dimensions = (29,15,32)
            shoe = fit(data,a,b,center,dimensions)
            cuff = shoe[shoe[:, 2] > 31]
            cuff_center = (cuff.min(0)[:2] + cuff.max(0)[:2])/2
            cuff_scale = (18.5,17.5)/np.ptp(cuff[:, :2],axis=0)
        for s in pieces:
            # The tabletop artists use split vertices at every face. Weld only vertices
            # whose position AND UV agree before duplicating geometry across poses.
            unique, ids = np.unique(np.column_stack((s.positions[0],s.uv)),axis=0,return_inverse=True)
            p,uv = unique[:,:3],unique[:,3:]
            if pair:
                if foot:
                    pose = fit(p,a,b,center,dimensions)
                    # Inventory boots are splayed on display. Align the shaft
                    # to the shin separately from the toe so trousers fit inside.
                    blend = np.clip((pose[:, 2:3]-7)/14,0,1)
                    upper = (pose[:, :2]-cuff_center)*cuff_scale + [-0.75,side*12.8]
                    pose[:, :2] += blend*(upper-pose[:, :2])
                    frames = animate_boot(pose,("clothing",))
                else:
                    pose = fit(p,a,b,(5,side*28,83),(19,16,26))
                    frames = rigid_track(pose,"left_hand" if side>0 else "right_hand")
            elif category=="armor":
                helmet = index==0
                if helmet:
                    pose = fit_helmet(p, helmet_family, path.stem)
                else:
                    pose = fit(p,a,b,(2,0,117),(40,61,60))
                frames = rigid_track(pose,"face") if helmet else animate(pose,("clothing","underbody"))
            else:
                horizontal = label in ("carbine","shotgun","crossbow")
                grip = 0.24 if horizontal else 0.49 if label in ("spear","javelin","staff","utility_staff","halberd","longbow","bolas") else 0.16
                scale = LENGTH[index]/max(np.ptp(forward),1)
                span = (p[:,[0,2]]@axis-forward.min()-grip*np.ptp(forward))*scale
                across = (p[:,[0,2]]@[axis[1],-axis[0]]-np.median(lateral))*scale
                depth = (p[:,1]-(a[1]+b[1])/2)*scale
                pose = np.column_stack((span,-depth,-across)) if horizontal else np.column_stack((across,-depth,span))
                frames = rigid_track(pose+[7,-31,82],"right_hand")
            surfaces.append(Surface(frames,ids[s.faces],uv,"models/caelum/players/gear/"+skin_name+".png"))
    blob = encode(name,surfaces)
    (DEST/(name+".md3")).write_bytes(blob)
    return {"module":name,"category":category,"item":label,"source":path.relative_to(SRC).as_posix(),
            "frames":len(surfaces[0].positions),"surfaces":len(surfaces),"sha256":hashlib.sha256(blob).hexdigest()}


def shield_module(index, label):
    name = f"s{index}"
    sculpt, bitmap = sculpt_shield(index)
    skin = "models/caelum/players/gear/"+name+".png"
    meshes = sculpt_surfaces(sculpt.parts, skin, lambda part: part.vertices[None])
    for mesh in meshes:
        mesh.positions = rigid_track(mesh.positions[0],"left_hand")
    blob = encode(name, meshes)
    (DEST/(name+".md3")).write_bytes(blob)
    (DEST/(name+".png")).write_bytes(bitmap)
    return {"module":name, "category":"shield", "item":label,
            "source":f"models/caelum/inventory/shields/{label}.md3",
            "sculpt":"assets/generators/carried_shields.py", "frames":len(meshes[0].positions),
            "surfaces":len(meshes), "sha256":hashlib.sha256(blob).hexdigest()}


def armor_module(index, material, name):
    kind = ARMOR[index]
    key = f"a{index}_{material}"
    path = SRC/"models/caelum/inventory"/("armor_"+kind)/(name+".md3")
    record = build(key, path, "armor", index, kind+"_"+name)
    if index == 0:
        fits = [record["sha256"]]
        for family in range(1,7):
            mesh = build(f"{key}_f{family}", path, "armor", index, kind+"_"+name, family)
            fits.append(mesh["sha256"])
        record["family_sha256"] = fits
    return record


def main():
    DEST.mkdir(parents=True,exist_ok=True)
    ART.mkdir(parents=True,exist_ok=True)
    inventory = SRC/"models/caelum/inventory"
    report = []
    for index,name in enumerate(WEAPONS):
        if name in TIERS:
            for tier in range(1,4):
                path = SRC/f"models/caelum/equipment/support_implements/{name}_t{tier}.obj"
                report.append(build(f"w{index}_{tier}",path,"weapon",index,name))
        else:
            path, = (p for p in inventory.glob("*/"+name+".md3") if p.parent.name not in ("ammunition","documents"))
            report.append(build(f"w{index}_1",path,"weapon",index,name))
    for index,name in enumerate(SHIELDS):
        report.append(shield_module(index,name))
    for index,kind in enumerate(ARMOR):
        for material,name in enumerate(MATERIALS):
            report.append(armor_module(index, material, name))
    (ART/"MODULES.json").write_bytes((json.dumps(report,indent=2)+"\n").encode())
    print(f"{len(report)} modules fitted to the existing 33 poses")


if __name__=="__main__":
    main()
