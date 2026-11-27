"""Regenerate the original Mandinga, Zupay and giant-rat combat models (#902)."""
from collections import defaultdict
from functools import lru_cache
import hashlib
import json
from pathlib import Path
import re

from PIL import Image
from reconstruct_actor_mesh import shape_and_skin, silhouette

ROOT=Path(__file__).resolve().parents[2]
SRC=ROOT/"src"
DESIGNS={
    "mandinga":("CaelumMandinga","mandinga","MIIDA","SLMDA","MDBR"),
    "zupay":("CaelumZupayColossus","zupay_colossus","ZUIDA","SLZUA","ZUBR"),
    "rat":("CaelumGiantRat","giant_rat","RATGA","SLRTA",None),
}


@lru_cache(maxsize=8)
def sheet(path):
    with Image.open(path) as im:
        return im.convert("RGBA")


def virtual_frames(descriptor, prefix):
    text=(SRC/descriptor).read_text(encoding="utf8")
    for name,w,h,body in re.findall(r'Sprite\s+"([^"]+)",\s*(\d+),\s*(\d+)\s*\{([^}]+)\}',text,re.I):
        if not name.startswith(prefix):
            continue
        patch,x,y=re.search(r'Patch\s+"([^"]+)",\s*(-?\d+),\s*(-?\d+)',body).groups()
        x,y=-int(x),-int(y)
        image=sheet(SRC/patch).crop((x,y,x+int(w),y+int(h)))
        yscale=float(re.search(r'YScale\s+([\d.]+)',body)[1])
        yield name,image,yscale


def source_views(design):
    actor,directory,idle,sleep,breath=design
    frames=defaultdict(dict)
    scales={}
    for p in sorted((SRC/"sprites/caelum/actors"/directory).glob("*.png")):
        if len(p.stem)!=6:
            continue
        with Image.open(p) as im:
            frames[p.stem[:5]][max(int(p.stem[5])-1,0)*45]=im.convert("RGBA")
        scales[p.stem[:5]]=1
    for descriptor,prefix in [("graphics/caelum/sleep_creatures/sleep.textures",sleep),
                              ("graphics/caelum/demon_breath.textures",breath)]:
        if not prefix:
            continue
        for name,img,yscale in virtual_frames(descriptor,prefix):
            frames[name[:5]][(int(name[5])-1)*45]=img
            scales[name[:5]]=yscale
    return [(name,frames[name],scales[name]) for name in [idle,*sorted(set(frames)-{idle})]]


def write_sources():
    blocks=[]
    inventory={}
    for key,design in DESIGNS.items():
        path="models/caelum/creatures/"+key
        (SRC/path).mkdir(parents=True,exist_ok=True)
        for name,views,yscale in source_views(design):
            base=path+"/"+name.lower()
            height=silhouette(views[0]).height/yscale
            # The native actor keeps its own Scale. MD3 dimensions are unscaled sprite units.
            model,png,_=shape_and_skin(views,height,base+".png",design[0]+" "+name)
            for ext,blob in [(".md3",model),(".png",png)]:
                rel=base+ext
                (SRC/rel).write_bytes(blob)
                inventory["src/"+rel]=hashlib.sha256(blob).hexdigest()
            blocks.append(f'Model {design[0]}\n{{\n    Path "{path}"\n    Model 0 "{name.lower()}.md3"\n'
                          f'    Skin 0 "{name.lower()}.png"\n    CorrectPixelStretch\n    DontCullBackFaces\n'
                          f'    FrameIndex {name[:4]} {name[4]} 0 0\n}}\n')
        print(design[0],"ready",flush=True)
    rel="caelum/data/native_creatures.modeldef"
    definition=("\n".join(blocks)).encode()
    (SRC/rel).write_bytes(definition)
    inventory["src/"+rel]=hashlib.sha256(definition).hexdigest()
    source=ROOT/"assets/source/art/native_creatures_902"
    source.mkdir(parents=True,exist_ok=True)
    provenance=dict(issue=902,method="Closed textured visual hulls reconstructed from the game's registered artwork. Single-view death frames recover thickness from the local contour.",
        original_actor_sprites=["src/sprites/caelum/actors/"+d[1] for d in DESIGNS.values()],
        registered_atlases=["src/graphics/caelum/sleep_creatures/sleep.textures","src/graphics/caelum/demon_breath.textures"],
        producer="assets/generators/generate_native_creatures.py",dependencies="Authoring only: Pillow, NumPy, SciPy, scikit-image, fast-simplification.",
        sha256=inventory)
    (source/"PROVENANCE.json").write_bytes((json.dumps(provenance,indent=2)+"\n").encode())


if __name__=="__main__":
    write_sources()
