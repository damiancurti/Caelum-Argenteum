"""Export painted camp inventory sources without repainting or replacing alpha."""
from pathlib import Path
import hashlib,json
from PIL import Image
ROOT=Path(__file__).resolve().parents[2]

def main():
    source=ROOT/'assets/art_source/camp_equipment'
    target=ROOT/'src/graphics/caelum/icons/camp';target.mkdir(parents=True,exist_ok=True)
    manifest=[]
    for name,sprite in [('tent','CPTNA0.png'),('iron_pot','CPPTA0.png')]:
        path=source/(name+'-source-v1.png')
        image=Image.open(path).convert('RGBA')
        # Crop only to the generated alpha bounds, then fit the unchanged art.
        image=image.crop(image.getchannel('A').getbbox())
        image.thumbnail((120,120),Image.Resampling.LANCZOS)
        output=Image.new('RGBA',(128,128));output.alpha_composite(image,((128-image.width)//2,(128-image.height)//2))
        icon=target/(name+'.png');output.save(icon,optimize=False)
        world=ROOT/'src/sprites'/sprite;world.write_bytes(icon.read_bytes())
        manifest.append({'source':path.relative_to(ROOT).as_posix(),'source_sha256':hashlib.sha256(path.read_bytes()).hexdigest(),
            'icon':icon.relative_to(ROOT).as_posix(),'icon_sha256':hashlib.sha256(icon.read_bytes()).hexdigest(),'world_sprite':sprite})
    (source/'EXPORT.json').write_bytes((json.dumps(manifest,indent=2)+'\n').encode())
    print('Exported two painted camp icons and native sprite registrations.')
if __name__=='__main__':main()
