"""Bind the finite #859 models to the default-off #857 wardrobe candidate."""
from pathlib import Path
import argparse,hashlib,importlib.util,json,re,zipfile
ROOT=Path(__file__).resolve().parents[2]
ART=ROOT/'assets/source/art/grips_859'

def generate():
    path=ROOT/'assets/validation_v5_17_107/prepare_wardrobe_data857.py'
    spec=importlib.util.spec_from_file_location('wardrobe857_bindings',path);module=importlib.util.module_from_spec(spec);spec.loader.exec_module(module)
    source,definition,base=module.generate();cfg=json.loads((ART/'DESIGN.json').read_text());native=cfg['native_path']
    start=source.index('    static clearscope String ModelPath');end=source.index('    static clearscope String SkinPath',start)
    paths=source[start:end]
    for slot in (7,8,11,15,16):
        paths,count=re.subn(r'case '+str(slot)+r':return "[^"]+";',f'case {slot}:return "{native}";',paths);assert count==1
        definition,count=re.subn(r'( Model '+str(slot)+r' ")[^"]+/([^/"]+\.md3")',r'\g<1>'+native+r'/\2',definition);assert count==1
    source=source[:start]+paths+source[end:]
    source=source.replace('// #857: generado desde el catalogo aprobado y las reglas de ajuste #829.','// #859: agarres derivados del catalogo y del ajuste de vestuario #857/#829.',1)
    current=[0]*17;resolved={}
    for sprite,letter,slot,frame in re.findall(r'^ FrameIndex (\S+) (\S+) (\d+) (\d+)$',definition,re.M):
        current[int(slot)]=int(frame);resolved[sprite,letter]=tuple(current)
    assert len(resolved)==375 and all(len(set(values))==1 for values in resolved.values())
    return {'caelum/data/CaelumWornClothingModelData.zs':source.encode(),'caelum/data/wardrobe_candidate.modeldef':definition.encode()},base

def main():
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--export',type=Path,required=True);parser.add_argument('--output',type=Path,required=True);parser.add_argument('--install',action='store_true');args=parser.parse_args()
    out=args.output.resolve();out.relative_to(ROOT/'build');out.mkdir(parents=True,exist_ok=False);files,base=generate();manifest=json.loads((args.export/'manifest.json').read_text());assert manifest['issue']==859 and manifest['frames']==375
    for name,expected in manifest['sha256'].items():
        blob=(args.export/name).read_bytes();assert hashlib.sha256(blob).hexdigest()==expected;files[name]=blob
    for name,blob in files.items():
        path=out/name;path.parent.mkdir(parents=True,exist_ok=True);path.write_bytes(blob)
        if args.install:
            path=ROOT/'src'/name;path.parent.mkdir(parents=True,exist_ok=True);path.write_bytes(blob)
    with zipfile.ZipFile(out/'prototype.pk3','w') as archive:
        for name,blob in sorted(files.items()):archive.writestr(zipfile.ZipInfo(name,(2026,11,19,0,0,0)),blob)
    report={'issue':859,'modules':8,'slots':17,'frames':375,'base_generator':base,'sha256':{n:hashlib.sha256(b).hexdigest() for n,b in files.items()},'prototype_sha256':hashlib.sha256((out/'prototype.pk3').read_bytes()).hexdigest()}
    (out/'manifest.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8');print(json.dumps({'members':len(files),'prototype_sha256':report['prototype_sha256']}))

if __name__=='__main__':main()
