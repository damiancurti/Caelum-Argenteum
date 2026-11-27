"""Generate own standalone compatibility data without commercial asset bytes."""
from pathlib import Path
import argparse,hashlib,json

ROOT=Path(__file__).resolve().parents[2]


def generate(root=ROOT):
    source=root/'assets/source/art/standalone_467'
    registration=json.loads((source/'REGISTRATION.json').read_text(encoding='utf8'))
    image=(root/registration['source']).read_bytes()
    assert hashlib.sha256(image).hexdigest()==registration['sha256']
    baseline_data=json.loads((source/registration['baseline_dimensions']).read_text())
    baseline=baseline_data['sprites']
    compatibility=json.loads((source/'COMPATIBILITY.json').read_text())
    texture_path=registration['runtime'].removeprefix('src/')
    lines=['// #467: recortes RGBA propios; dimensiones y estados conservados.']
    def sprite(name,frame,dimensions):
        x,y,right,bottom=registration['frames'][frame]['bounds'];w=right-x;h=bottom-y
        sx=w/dimensions['width'];sy=h/dimensions['height']
        lines.append(f'Sprite "{name}", {w}, {h} {{ XScale {sx:.9f} YScale {sy:.9f} Offset {round(dimensions["left"]*sx)}, {round(dimensions["top"]*sy)} Patch "{texture_path}", {-x}, {-y} }}')
    for i,letter in enumerate('ABCD'):sprite('PUFF'+letter+'0',i,baseline['PUFF'+letter+'0'])
    # Native Blood advances C -> B -> A. Keep the early, expanded and sparse frames.
    for letter,frame in [('C',4),('B',5),('A',7)]:sprite('BLUD'+letter+'0',frame,baseline['BLUD'+letter+'0'])
    # AxeBlood retains six native state slots; it reuses this same owned effect family.
    for letter,frame in zip('FGHIJK',[4,4,5,6,7,7]):sprite('FAXE'+letter+'0',frame,baseline['BLUDC0'])
    lines.append(f'Flat "F_SKY1", 64, 64 {{ Patch "{compatibility["invisible"]}", 0, 0 }}')
    # Base descriptors parse before localized project StaticText replaces them.
    for name in compatibility['menu_headers']:
        lines.append(f'Graphic "{name}", 1, 1 {{ Patch "{compatibility["invisible"]}", 0, 0 }}')
    for row in compatibility['switches']:
        w,h=compatibility['switch_crop_size'];old=baseline_data['textures'][row['name']]
        lines.append(f'Texture "{row["name"]}", {w}, {h} {{ XScale {w/old["width"]:.9f} YScale {h/old["height"]:.9f} Patch "{compatibility["switch_source"]}", {-row["left"]}, {-row["top"]} }}')
    for row in compatibility['armor_icons']:
        w,h=row['size'];old=baseline[row['baseline']];sx=w/old['width'];sy=h/old['height']
        for frame in 'AB':
            lines.append(f'Sprite "{row["prefix"]}{frame}0", {w}, {h} {{ XScale {sx:.9f} YScale {sy:.9f} Offset {round(old["left"]*sx)}, {round(old["top"]*sy)} Patch "{row["source"]}", 0, 0 }}')
    # Standard RGB332 construction, independently generated; no imported PLAYPAL.
    palette=bytes(c for i in range(256) for c in (round(((i>>5)&7)*255/7),round(((i>>2)&7)*255/7),round((i&3)*255/3)))
    outputs={registration['runtime']:image,'src/PLAYPAL':palette,
        'src/caelum/data/standalone.textures':('\n'.join(lines)+'\n').encode('utf8')}
    outputs['assets/source/art/standalone_467/GENERATED.json']=(json.dumps({'issue':467,'outputs':{name:{'sha256':hashlib.sha256(blob).hexdigest(),'bytes':len(blob)} for name,blob in outputs.items()}},indent=2)+'\n').encode()
    return outputs


def main():
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--check',action='store_true');args=parser.parse_args()
    outputs=generate()
    for name,blob in outputs.items():
        path=ROOT/name
        if args.check:
            if not path.exists() or path.read_bytes()!=blob:raise SystemExit('Stale standalone output: '+name)
        else:path.parent.mkdir(parents=True,exist_ok=True);path.write_bytes(blob)
    print(f'{len(outputs)} standalone outputs '+('verified' if args.check else 'written'))


if __name__=='__main__':main()
