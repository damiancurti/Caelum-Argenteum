"""Export closed coin meshes with unchanged owned face images for #647."""
from pathlib import Path
import argparse
import hashlib
import json
import math
import zipfile
from PIL import Image

ROOT=Path(__file__).resolve().parents[2]
CONFIG=ROOT/'assets/source/art/inventory_models_647/COINS.json'

def digest(blob):return hashlib.sha256(blob).hexdigest()

def render(root=ROOT):
    config_path=root/'assets/source/art/inventory_models_647/COINS.json'
    config=json.loads(config_path.read_text(encoding='utf-8'));shape=config['geometry'];segments=shape['segments']
    outputs={};definition=[];variants={}
    for name,item in config['variants'].items():
        image_path=root/item['image'];blob=image_path.read_bytes()
        if digest(blob)!=item['source_sha256']:raise ValueError('Existing coin face changed: '+name)
        source=Image.open(image_path).convert('RGBA');width,height=source.size
        bounds=source.getchannel('A').point(lambda value:255 if value>=128 else 0).getbbox()
        if bounds is None:raise ValueError('Empty coin face')
        center=((bounds[0]+bounds[2])/2,(bounds[1]+bounds[3])/2)
        radius=min(bounds[2]-bounds[0],bounds[3]-bounds[1])/2
        vertices=[];uv=[];faces=[]
        for multiplier,level in shape['profile']:
            for index in range(segments):
                angle=2*math.pi*index/segments
                vertices.append((radius*multiplier*math.cos(angle),shape['thickness_pixels']*level,radius*multiplier*math.sin(angle)))
                uv.append(tuple(shape['edge_uv']))
        for row in range(len(shape['profile'])-1):
            for index in range(segments):
                following=(index+1)%segments;a=row*segments+index;b=row*segments+following;c=b+segments;d=a+segments
                faces.extend([(a,c,b),(a,d,c)])
        for row,reverse in [(0,True),(len(shape['profile'])-1,False)]:
            cap_center=len(vertices);vertices.append((0,shape['thickness_pixels']*shape['profile'][row][1],0));uv.append((center[0]/width,1-center[1]/height))
            ring=[]
            for index in range(segments):
                angle=2*math.pi*index/segments;ring.append(len(vertices));vertices.append(vertices[row*segments+index])
                uv.append(((center[0]+radius*shape['cap_uv_radius_fraction']*math.cos(angle))/width,
                           1-(center[1]+radius*shape['cap_uv_radius_fraction']*math.sin(angle))/height))
            for index in range(segments):
                tri=(cap_center,ring[index],ring[(index+1)%segments]);faces.append(tri if reverse else tuple(reversed(tri)))
        lines=['# Original closed display mesh; native ownership/physics remain unchanged.',f'mtllib {name}.mtl',f'o CaelumDropCoin_{name}']
        lines += ['v '+' '.join(f'{value:.6f}' for value in point) for point in vertices]
        lines += ['vt '+' '.join(f'{value:.8f}' for value in point) for point in uv]
        lines += ['usemtl '+name]+['f '+' '.join(f'{index+1}/{index+1}' for index in face) for face in faces]
        base=config['model_path'];outputs[f'{base}/{name}.obj']=('\n'.join(lines)+'\n').encode()
        outputs[f'{base}/{name}.mtl']=f'newmtl {name}\nKd 1 1 1\nmap_Kd {name}.png\n'.encode()
        outputs[f'{base}/{name}.png']=blob
        for suffix in config['denomination_suffixes']:
            definition.append(f'Model {item["class"]+suffix} {{ Path "{base}" Model 0 "{name}.obj" Skin 0 "{name}.png" Scale 1 1 1 CorrectPixelStretch FrameIndex {item["sprite"]} A 0 0 }}')
        # Geometric edge closure ignores deliberate cap UV duplicates.
        edge_counts={}
        for face in faces:
            points=[tuple(round(value,6) for value in vertices[index]) for index in face]
            for a,b in zip(points,points[1:]+points[:1]):
                key=tuple(sorted((a,b)));edge_counts[key]=edge_counts.get(key,0)+1
        if not all(count==2 for count in edge_counts.values()):raise ValueError('Open coin mesh: '+name)
        volume=0
        for face in faces:
            a,b,c=(vertices[index] for index in face)
            cross=(b[1]*c[2]-b[2]*c[1],b[2]*c[0]-b[0]*c[2],b[0]*c[1]-b[1]*c[0])
            volume+=sum(a[index]*cross[index] for index in range(3))/6
        if volume<=0:raise ValueError('Inward coin mesh: '+name)
        variants[name]={'vertices':len(vertices),'triangles':len(faces),'closed_edges':len(edge_counts),'signed_volume':volume,'image_size':source.size,'opaque_bounds':bounds,'radius_art_pixels':radius,'thickness_art_pixels':shape['thickness_pixels']}
    outputs['caelum/data/inventory_coins.modeldef']=('\n'.join(definition)+'\n').encode()
    report={'schema_revision':1,'issue':647,'config_sha256':digest(config_path.read_bytes()),'generator_sha256':digest(Path(__file__).read_bytes()),
        'variants':variants,'class_bindings':len(definition),'sha256':{name:digest(blob) for name,blob in outputs.items()}}
    outputs['manifest.json']=(json.dumps(report,indent=2)+'\n').encode()
    return outputs

def main():
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--output',type=Path,required=True);parser.add_argument('--check',action='store_true')
    parser.add_argument('--install',action='store_true',help='Install or check generated runtime files and the source manifest.')
    args=parser.parse_args();output=args.output.resolve();files=render()
    for name,blob in files.items():
        path=output/name
        if args.check:
            if not path.is_file() or path.read_bytes()!=blob:raise ValueError('Stale output: '+name)
        else:path.parent.mkdir(parents=True,exist_ok=True);path.write_bytes(blob)
        if args.install:
            installed=CONFIG.with_name('COINS_EXPORT.json') if name=='manifest.json' else ROOT/'src'/name
            if args.check:
                if not installed.is_file() or installed.read_bytes()!=blob:raise ValueError('Stale installed output: '+name)
            else:installed.parent.mkdir(parents=True,exist_ok=True);installed.write_bytes(blob)
    if not args.check:
        with zipfile.ZipFile(output/'preview.pk3','w') as package:
            for name,blob in sorted(files.items()):
                if name=='manifest.json' or name.endswith('.mtl'):continue
                package.writestr(zipfile.ZipInfo('MODELDEF' if name.endswith('.modeldef') else name,(2026,11,13,0,0,0)),blob)
    print(json.dumps(json.loads(files['manifest.json'])['variants']))

if __name__=='__main__':main()
