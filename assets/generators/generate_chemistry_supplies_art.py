"""Create only new #471 supply props; never regenerate accepted ingredient artwork."""
import hashlib
import json
from pathlib import Path
from generate_alchemy_ingredients import Mesh, ellipsoid, rod, material, shade_faces, icon

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[1]
DATA = json.loads((HERE / "chemistry_supplies_art.json").read_text(encoding="utf-8"))
OUT = ROOT / "src/models/caelum/world/alchemy_ingredients"
ICONS = ROOT / "src/graphics/caelum/icons/materials"


def box(mesh, kind, lower, upper):
    x, y, z = lower
    X, Y, Z = upper
    first = len(mesh.faces)
    for face in (
        ((x,y,z),(X,y,z),(X,Y,z),(x,Y,z)),
        ((X,y,Z),(x,y,Z),(x,Y,Z),(X,Y,Z)),
        ((x,y,Z),(x,y,z),(x,Y,z),(x,Y,Z)),
        ((X,y,z),(X,y,Z),(X,Y,Z),(X,Y,z)),
        ((x,Y,z),(X,Y,z),(X,Y,Z),(x,Y,Z)),
        ((x,y,Z),(X,y,Z),(X,y,z),(x,y,z)),
    ):
        mesh.add_quad(material(kind), face)
    shade_faces(mesh, first, ((x+X)/2,(y+Y)/2,(z+Z)/2))


def geometry(key):
    mesh = Mesh("ca_" + key)
    if key == "sugar":
        ellipsoid(mesh, "cloth", (0,.35,0), (4.8,.35,3.7), 47199, rings=3, segments=10)
        for i,(x,z,r,h) in enumerate(((-1.5,-.7,1.8,3.6),(2,.3,1.3,2.2),(-1.1,2,1.1,1.2))):
            rod(mesh, "salt", (x,.6,z), (x,h,z), r, r*.6, sides=6)
        for x in (-4,4):
            ellipsoid(mesh,"cloth",(x,.7,0),(.8,.7,3),47200, rings=3, segments=6)
    elif key == "prepared_reagents":
        for x,y,z in ((-1.7,0,0),(1.7,0,0),(0,1.5,2.3)):
            rod(mesh,"cloth",(x,y+.3,z),(x,y+5,z),1.5,1.2,sides=6)
            rod(mesh,"cork",(x,y+5,z),(x,y+5.4,z),1.25,sides=6)
        rod(mesh,"charcoal",(-3,2.8,-1.4),(3,2.8,-1.4),.16,sides=6)
        rod(mesh,"charcoal",(3,2.8,-1.4),(0,4,3.9),.16,sides=6)
        rod(mesh,"charcoal",(0,4,3.9),(-3,2.8,-1.4),.16,sides=6)
    else:
        carbine = key == "sealed_carbine_parts"
        length, depth = (6,2.5) if carbine else (4.7,3.5)
        box(mesh,"wood",(-length,.2,-depth),(length,3.5,depth))
        box(mesh,"wood",(-length-.12,3.5,-depth-.12),(length+.12,4,depth+.12))
        for x in ((-3,3) if carbine else (0,)):
            box(mesh,"charcoal" if carbine else "cloth",(x-.3,.1,-depth-.17),(x+.3,4.08,depth+.17))
    mesh.faces.sort(key=lambda face:face[0])
    assert len({face[0] for face in mesh.faces}) <= 32
    return mesh


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    records = []
    for spec in DATA["assets"]:
        mesh = geometry(spec["key"])
        model = OUT / f"{spec['key']}.obj"
        sprite = ICONS / f"ca_material_{spec['key']}.png"
        mesh.write(model)
        icon(mesh,sprite)
        records.append({**spec,"model":model.relative_to(ROOT/"src").as_posix(),
                        "icon":sprite.relative_to(ROOT/"src").as_posix(),
                        "model_sha256":digest(model),"icon_sha256":digest(sprite),
                        "surfaces":len({face[0] for face in mesh.faces}),
                        "textures":sorted({face[0] for face in mesh.faces})})
    inputs=[Path(__file__),HERE/"chemistry_supplies_art.json",HERE/"generate_alchemy_ingredients.py",HERE/"generate_environment_models.py"]
    manifest={"issue":471,"provenance":DATA["provenance"],
              "inputs":{p.relative_to(ROOT).as_posix():digest(p) for p in inputs},"assets":records}
    (HERE/"chemistry_supplies_art_manifest.json").write_text(json.dumps(manifest,indent=2)+"\n",encoding="utf-8",newline="\n")
    print(f"Generated {len(records)} new supply models and inventory sprites")


if __name__ == "__main__":
    main()
