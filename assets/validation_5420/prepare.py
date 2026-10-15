"""Freeze Arcane Cloud gameplay and isolated native fixtures."""
from pathlib import Path
import argparse, importlib.util, json, struct
ROOT=Path(__file__).resolve().parents[2];HERE=Path(__file__).parent
spec=importlib.util.spec_from_file_location('shared',HERE.parent/'validation_5218/prepare.py')
shared=importlib.util.module_from_spec(spec);spec.loader.exec_module(shared)
p=argparse.ArgumentParser(description=__doc__);p.add_argument('--directory',required=True);a=p.parse_args()
if not a.directory or any(c not in 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_' for c in a.directory):p.error('Plain directory name required.')
out=ROOT/'build'/a.directory;out.mkdir(exist_ok=False)
def wad(kind=0):
    text='namespace="ZDoom";\n'
    for x,y in [(-4096,-4096),(-4096,4096),(4096,4096),(4096,-4096),(512,-128),(640,-128),(640,128),(512,128)]:
        text+=f'vertex {{ x={x}; y={y}; }}\n'
    text+='sector { id=99; heightfloor=0; heightceiling=1024; texturefloor="FLAT5_4"; textureceiling="CEIL3_5"; lightlevel=224; }\n'
    for i in range(8):
        end=(i+1)%4 if i<4 else 4+(i+1-4)%4
        text+='sidedef { sector=0; texturemiddle="STARTAN3"; }\n'
        text+=f'linedef {{ v1={i}; v2={end}; sidefront={i}; blocking=true; }}\n'
    if kind:
        for x,y in [(5000,0),(5000,32),(5032,32),(5032,0)]:text+=f'vertex {{ x={x}; y={y}; }}\n'
        text+=f'sector {{ heightfloor={128 if kind==1 else -8}; heightceiling=160; texturefloor="FLAT5_4"; textureceiling="FLAT5_4"; lightlevel=160; }}\n'
        for i in range(4):
            text+='sidedef { sector=1; texturemiddle="STARTAN3"; }\n'
            action=f'special=160; arg0=99; arg1={1 if kind==1 else 2}; arg3=255;' if i==0 else ''
            text+=f'linedef {{ v1={8+i}; v2={8+(i+1)%4}; sidefront={8+i}; blocking=true; {action} }}\n'
    text+='thing { x=0; y=0; angle=0; type=1; skill1=true; skill2=true; skill3=true; skill4=true; skill5=true; single=true; coop=true; dm=true; }\n'
    data=b'';directory=b''
    for name,payload in [('MAP99',b''),('TEXTMAP',text.encode()),('ENDMAP',b'')]:
        directory+=struct.pack('<ii8s',12+len(data),len(payload),name.encode());data+=payload
    return struct.pack('<4sii',b'PWAD',3,12+len(data))+data+directory
manifest={'runtime_sha256':shared.package(out/'production.pk3',{q.relative_to(ROOT/'src').as_posix():q.read_bytes() for q in (ROOT/'src').rglob('*') if q.is_file()}),
    'fixture_sha256':shared.package(out/'cloud.pk3',{
        'ZSCRIPT':b'version "4.14"\n#include "cloud.zs"\n','cloud.zs':(HERE/'cloud.zs').read_bytes(),
        'maps/MAP99.wad':wad(),'maps/MAP98.wad':wad(),'maps/MAP97.wad':wad(1),'maps/MAP96.wad':wad(2),'maps/MAP95.wad':wad(),
        'MAPINFO':b'GameInfo { AddEventHandlers="CA251Probe" }\ncluster 99 { hub }\nmap MAP99 "Cloud fixture" { cluster=99 nointermission sky1="SKY1",0 }\nmap MAP98 "Cloud hub" { cluster=99 nointermission sky1="SKY1",0 }\nmap MAP97 "Cloud roof" { cluster=99 nointermission sky1="SKY1",0 }\nmap MAP96 "Cloud water" { cluster=99 nointermission sky1="SKY1",0 }\nmap MAP95 "Cloud outside hub" { nointermission sky1="SKY1",0 }\n'})}
start='wait 100; netevent c251_setup; '
done='netevent c251_done; wait 2; quit\n'
scripts={name+'.cfg':start+'netevent c251_'+name+'; '+done for name in ['rain','roof','cry','coexist','stops','journey','movement']}
scripts.update({
 'timing.cfg':start+'netevent c251_timing; wait 10; netevent c251_early; wait 3; netevent c251_first; wait 23; netevent c251_second; '+done,
 'casting.cfg':start+'wait 5; +user4; wait 35; -user4; netevent c251_partial; wait 2; +user4; wait 2; -user4; netevent c251_cancel; wait 5; +user4; wait 110; -user4; netevent c251_cast; wait 350; netevent c251_expired; '+done,
 'death.cfg':start+'netevent c251_contract; netevent c251_kill; wait 2; netevent c251_dead; '+done,
 'save.cfg':start+'netevent c251_seed; wait 10; save cloud.zds; wait 2; '+done,
 'load.cfg':'wait 1; netevent c251_loaded; changemap MAP98; wait 10; netevent c251_loaded; changemap MAP99; wait 10; netevent c251_loaded; netevent c251_outside; wait 10; netevent c251_loaded; '+done,
 'water.cfg':start+'netevent c251_contract; changemap MAP96; wait 5; netevent c251_expired; '+done,
 'overlap.cfg':start+'addbot; wait 20; netevent c251_overlap; '+done,
 'save-prep.cfg':start+'wait 5; +user4; wait 35; -user4; netevent c251_partial; save preparation.zds; wait 2; '+done,
 'load-prep.cfg':'wait 1; netevent c251_prep_loaded; wait 75; netevent c251_cast; '+done,
 'collision.cfg':start+'netevent c251_motion_start; +forward; wait 80; -forward; netevent c251_wall; netevent c251_ceiling_start; +moveup; wait 60; -moveup; netevent c251_ceiling; '+done,
})
manual='language es; con_notifytime 0; use_mouse true; bind f +user4; bind f6 "netevent c251_manual"; bind f7 "netevent c251_ready"; bind f8 "netevent c251_intimidate"; bind f9 "changemap MAP98"; bind f10 "chase"; bind f11 "netevent c251_end"; bind f12 "netevent c251_view"; bind home +moveup; bind end +movedown; wait 100; netevent c251_manual; '
scripts['manual.cfg']=manual+'netevent c251_done;\n'
scripts['preview.cfg']=manual+'wait 5; +user4; wait 110; -user4; +moveup; wait 20; -moveup; chase; wait 5; screenshot cloud-seated.png; wait 20; screenshot cloud-rain.png; '+done
scripts['side.cfg']=manual+'wait 5; +user4; wait 110; -user4; +moveup; wait 30; -moveup; netevent c251_view; wait 5; screenshot cloud-side.png; '+done
for name,code in scripts.items():(out/name).write_text(code,encoding='utf-8',newline='\n')
(out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf-8',newline='\n');print(json.dumps(manifest))
