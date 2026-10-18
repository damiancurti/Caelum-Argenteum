"""Package the current normal runtime and a private #353 acceptance fixture."""
from pathlib import Path
import argparse
import hashlib
import importlib.util
import json
import re
import struct
import subprocess
import zipfile

ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).parent
spec=importlib.util.spec_from_file_location('prior',ROOT/'assets/validation_5442/prepare.py')
prior=importlib.util.module_from_spec(spec);spec.loader.exec_module(prior)

def flat_map():
    # Fixture coordinates, not campaign map or balance data.
    text='namespace="ZDoom";\n'
    points=[(-32768,-32768),(-32768,32768),(32768,32768),(32768,-32768)]
    for x,y in points:text+=f'vertex {{ x={x}.0; y={y}.0; }}\n'
    for i in range(4):
        text+=f'linedef {{ v1={i}; v2={(i+1)%4}; sidefront={i}; blocking=true; }}\n'
        text+='sidedef { sector=0; texturemiddle="STARTAN3"; }\n'
    text+='sector { heightfloor=0; heightceiling=4096; texturefloor="FLOOR0_1"; textureceiling="F_SKY1"; lightlevel=192; }\n'
    text+='thing { x=0.0; y=0.0; angle=0; type=1; skill1=true; skill2=true; skill3=true; skill4=true; skill5=true; single=true; coop=true; }\n'
    lumps=[('MAP99',b''),('TEXTMAP',text.encode()),('ENDMAP',b'')]
    body=b'';directory=b'';offset=12
    for name,data in lumps:
        directory+=struct.pack('<ii8s',offset,len(data),name.encode().ljust(8,b'\0'));body+=data;offset+=len(data)
    return b'PWAD'+struct.pack('<ii',len(lumps),offset)+body+directory

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--directory',required=True)
    parser.add_argument('--scenario',choices=['checks','save','travel'],default='checks')
    parser.add_argument('--baseline-runtime',type=Path)
    args=parser.parse_args()
    assert re.fullmatch(r'issue353-[a-z0-9-]+',args.directory)
    out=ROOT/'build'/args.directory;out.mkdir(exist_ok=False)
    members={p.relative_to(ROOT/'src').as_posix():p.read_bytes() for p in (ROOT/'src').rglob('*') if p.is_file()}
    if args.baseline_runtime:
        assert args.scenario=='save'
        with zipfile.ZipFile(args.baseline_runtime) as archive:
            members={n:archive.read(n) for n in archive.namelist()}
    probe=(HERE/('probe.zs' if args.scenario=='checks' else args.scenario+'.zs')).read_text(encoding='utf-8')
    if args.baseline_runtime:probe=re.sub(r'        // CURRENT_BEGIN.*?        // CURRENT_END','',probe,flags=re.S)
    handler={'checks':'CA353Probe','save':'CA353SaveProbe','travel':'CA353TravelProbe'}[args.scenario]
    fixture={'ZSCRIPT':b'version "4.14"\n#include "probe.zs"\n',
             'probe.zs':probe.encode(),
             'MAPINFO':('GameInfo { AddEventHandlers="'+handler+'" }\ncluster 99 { hub }\nmap MAP99 "Actor cache checks" { next="MAP99" sky1="SKY1" cluster=99 }\nmap MAP98 "Actor cache travel" { next="MAP99" sky1="SKY1" cluster=99 }\n').encode(),
             'maps/map99.wad':flat_map()}
    fixture['maps/map98.wad']=flat_map()
    manifest=dict(issue=353,release='5.4.43',source_commit=subprocess.check_output(['git','rev-parse','HEAD'],text=True).strip(),
                  runtime_sha256=prior.base.package(out/'production.pk3',members),fixture_sha256=prior.base.package(out/'quick.pk3',fixture),
                  exact_source_members=len(members),source_hashes={n:hashlib.sha256(data).hexdigest() for n,data in members.items() if n.endswith('.zs') or n=='ZSCRIPT'})
    manifest['scenario']=args.scenario
    if args.baseline_runtime:manifest['baseline_input_sha256']=hashlib.sha256(args.baseline_runtime.read_bytes()).hexdigest()
    (out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf-8')
    (out/'checks.cfg').write_text('wait 180; quit\n')
    (out/'save.cfg').write_text('wait 70; netevent ca353_save_prepare; wait 2; storesavepic false; save cache-seed; wait 3; netevent ca353_save_verify; wait 3; quit\n')
    (out/'load.cfg').write_text('wait 5; netevent ca353_save_verify; wait 2; storesavepic false; save cache-forward; wait 3; quit\n')
    (out/'travel.cfg').write_text('wait 35; netevent ca353_travel_create; wait 10; netevent ca353_travel_prepare; wait 2; changemap MAP98; wait 20; netevent ca353_travel_prepare; wait 2; changemap MAP99; wait 90; quit\n')
    print(json.dumps({k:v for k,v in manifest.items() if k!='source_hashes'}))

if __name__=='__main__':main()
