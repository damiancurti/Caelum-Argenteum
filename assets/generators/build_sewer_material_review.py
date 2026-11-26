"""Build the opt-in #847 visual overlay without altering production resources."""
from pathlib import Path
import argparse,hashlib,json,struct,zipfile

ROOT=Path(__file__).resolve().parents[2]
SOURCE=ROOT/'assets/source/art/sewer_material_847'

def build(output):
    inventory=json.loads((SOURCE/'INVENTORY.json').read_text(encoding='utf-8'))
    wall=SOURCE/inventory['wall']['source']
    content=wall.read_bytes();width,height=struct.unpack('>II',content[16:24])
    assert (width,height)==tuple(inventory['wall']['pixels'])
    assert hashlib.sha256(content).hexdigest()==inventory['wall']['sha256']
    tile=inventory['wall']['display_repeat_mu']
    floor=inventory['floor'];scale=floor['pixels'][0]/floor['display_repeat_mu']
    text=f'''// Candidato visual #847: cargar solamente en la sesion dedicada de MAP02.
Texture "CASWRWAL", {width}, {height}
{{
    XScale {width/tile:.8f}
    YScale {height/tile:.8f}
    Patch "graphics/caelum/review847/brick-v1.png", 0, 0
}}
Flat "CASWRFLR", {floor['pixels'][0]}, {floor['pixels'][1]}
{{
    XScale {scale:.8f}
    YScale {scale:.8f}
    Patch "{floor['runtime_source']}", 0, 0
}}
'''
    members={'TEXTURES':text.encode('utf-8'),'graphics/caelum/review847/brick-v1.png':content}
    output=output.resolve();output.relative_to(ROOT/'build');output.parent.mkdir(parents=True,exist_ok=True)
    if output.exists():raise FileExistsError(output)
    with zipfile.ZipFile(output,'w') as package:
        for name,data in sorted(members.items()):
            package.writestr(zipfile.ZipInfo(name,(2026,11,19,0,0,0)),data)
    return dict(path=str(output.relative_to(ROOT)),sha256=hashlib.sha256(output.read_bytes()).hexdigest(),members=list(members),bytes=output.stat().st_size)

if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--output',type=Path,required=True);a=p.parse_args()
    print(json.dumps(build(a.output)))
