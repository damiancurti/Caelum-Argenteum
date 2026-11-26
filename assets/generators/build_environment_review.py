"""Compose verified opt-in environment proposals without installing art or maps."""
from pathlib import Path
import argparse,hashlib,json,re,zipfile
ROOT=Path(__file__).resolve().parents[2]
SHA=lambda data:hashlib.sha256(data).hexdigest()
SOURCES={
    'remasters':('assets/source/art/environment_remasters_866/INVENTORY.json','overlay'),
    'vaults':('assets/validation_v5_17_116/evidence/builds/issue875-vault02/MANIFEST.json',None),
    'joinery':('assets/validation_v5_17_117/evidence/builds/issue878-joinery02/MANIFEST.json',None)}

def load_component(label,path):
    manifest_name,child=SOURCES[label]
    manifest=json.loads((ROOT/manifest_name).read_text(encoding='utf-8'))
    record=manifest[child] if child else manifest
    expected=record['sha256'] if child else record['overlay_sha256']
    data=path.read_bytes();assert SHA(data)==expected,(label,'unverified component bytes')
    with zipfile.ZipFile(path) as z:
        names=z.namelist();assert len(set(n.lower() for n in names))==len(names)
        members={n:z.read(n) for n in names}
    return members,dict(issue=manifest['issue'],sha256=expected,evidence=manifest_name,
                        members={n:SHA(b) for n,b in members.items()})

def compose(labels,components):
    result={};owners={};texture_blocks=[];texture_keys=set()
    for label in labels:
        for name,data in components[label].items():
            key=name.lower();assert '..' not in Path(name).parts and not name.startswith(('/', '\\'))
            if key=='textures':
                text=data.decode('utf-8-sig')
                definitions=re.findall(r'(?im)^\s*(Texture|Flat|Sprite|Graphic|WallTexture)\s+"([^\"]+)"',text)
                assert definitions,(label,'missing native texture declarations')
                for kind,alias in definitions:
                    identity=(kind.lower(),alias.lower());assert identity not in texture_keys,identity
                    texture_keys.add(identity)
                texture_blocks.append(data);owners.setdefault('TEXTURES',[]).append(label)
            else:
                assert key not in {n.lower() for n in result},('duplicate package member',name)
                result[name]=data;owners[name]=[label]
    # Each original definition fragment stays byte-identical; only a separating LF
    # is inserted. Unlike silent last-wins replacement, duplicate native aliases fail.
    result['TEXTURES']=b'\n'.join(texture_blocks)
    return result,owners,sorted(texture_keys)

def main():
    p=argparse.ArgumentParser(description=__doc__)
    for name in ['runtime','remasters','vaults','joinery','output']:p.add_argument('--'+name,type=Path,required=True)
    a=p.parse_args();out=a.output.resolve();out.relative_to(ROOT/'build');out.mkdir(parents=True,exist_ok=False)
    components={};inputs={}
    for label in SOURCES:components[label],inputs[label]=load_component(label,getattr(a,label))
    with zipfile.ZipFile(a.runtime) as z:
        runtime={n.lower():n for n in z.namelist()}
        facade=z.read(runtime['caelum/world/caelumbarracasfacades.zs'])
        assert b'RenderRadius 781;' in facade,'The production #879 facade correction is required'
        source_map=z.read(runtime['maps/map02.wad'])
        vault=json.loads((ROOT/SOURCES['vaults'][0]).read_text())
        assert SHA(source_map)==vault['source_map_sha256'],'Different base sewer geometry'
        assert z.read(runtime['models/caelum/architecture/barracas/house-960-1216.obj'])==(ROOT/'src/models/caelum/architecture/barracas/house-960-1216.obj').read_bytes()
        baseline={key:SHA(z.read(name)) for key,name in runtime.items() if key in {
            'maps/map01.wad','maps/map02.wad','maps/map03.wad','maps/cah000.wad',
            'models/caelum/architecture/barracas/house-960-1216.obj'}}
    variants=[]
    for name,labels in [('appearance',['remasters','joinery']),('vaults',['remasters','joinery','vaults'])]:
        members,owners,keys=compose(labels,components)
        target=out/(name+'.pk3')
        with zipfile.ZipFile(target,'x',compression=zipfile.ZIP_STORED) as z:
            for member,data in sorted(members.items()):z.writestr(zipfile.ZipInfo(member,(2026,11,21,0,0,0)),data)
        changed_maps=[n for n in members if n.lower().startswith('maps/')]
        assert changed_maps==([] if name=='appearance' else ['maps/MAP02.wad'])
        variants.append(dict(name=name,sha256=SHA(target.read_bytes()),bytes=target.stat().st_size,
                             components=labels,changed_maps=changed_maps,texture_definitions=keys,
                             members={n:dict(sha256=SHA(b),owners=owners[n],overrides_runtime=n.lower() in runtime) for n,b in sorted(members.items())},
                             requires_fresh_geometry_session=name=='vaults'))
    report=dict(issue=881,author_acceptance=False,runtime_sha256=SHA(a.runtime.read_bytes()),
                builder_sha256=SHA(Path(__file__).read_bytes()),inputs=inputs,baseline_resources=baseline,variants=variants,
                scope='Private review options only. No src installation or save conversion. Appearance preserves map geometry; vaults changes only MAP02 and its existing checksum-qualified Justice table. No fixture, class replacement, new actor or decoration placement is embedded. Texture fragments are concatenated after duplicate kind/name rejection; every image and model byte comes unchanged from its verified component.')
    (out/'MANIFEST.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8',newline='\n')
    print(json.dumps(dict(issue=881,variants=[{k:r[k] for k in ['name','sha256','bytes','changed_maps']} for r in variants])))

if __name__=='__main__':main()
