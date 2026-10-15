"""Freeze issue #252 runtime and isolated native geometry/probe fixtures."""
from pathlib import Path
import argparse
import importlib.util
import json
import struct

ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).parent
spec=importlib.util.spec_from_file_location('shared',HERE.parent/'validation_5218/prepare.py')
shared=importlib.util.module_from_spec(spec)
spec.loader.exec_module(shared)

def wad(roof=False):
    text='namespace="ZDoom";\n'
    points=[(-4096,-4096),(-4096,4096),(4096,4096),(4096,-4096),
            (512,-128),(640,-128),(640,128),(512,128)]
    for x,y in points:text+=f'vertex {{ x={x}; y={y}; }}\n'
    text+='sector { id=99; heightfloor=0; heightceiling=2048; texturefloor="FLAT5_4"; textureceiling="CEIL3_5"; lightlevel=224; }\n'
    for i in range(8):
        end=(i+1)%4 if i<4 else 4+(i-3)%4
        text+='sidedef { sector=0; texturemiddle="STARTAN3"; }\n'
        text+=f'linedef {{ v1={i}; v2={end}; sidefront={i}; blocking=true; }}\n'
    if roof:
        for x,y in [(5000,0),(5000,32),(5032,32),(5032,0)]:text+=f'vertex {{ x={x}; y={y}; }}\n'
        text+='sector { heightfloor=128; heightceiling=160; texturefloor="FLAT5_4"; textureceiling="FLAT5_4"; lightlevel=160; }\n'
        for i in range(4):
            text+='sidedef { sector=1; texturemiddle="STARTAN3"; }\n'
            action='special=160; arg0=99; arg1=1; arg3=255;' if i==0 else ''
            text+=f'linedef {{ v1={8+i}; v2={8+(i+1)%4}; sidefront={8+i}; blocking=true; {action} }}\n'
    text+='thing { x=0; y=0; angle=0; type=1; skill1=true; skill2=true; skill3=true; skill4=true; skill5=true; single=true; coop=true; dm=true; }\n'
    data=b'';directory=b''
    for name,payload in [('MAP99',b''),('TEXTMAP',text.encode()),('ENDMAP',b'')]:
        directory+=struct.pack('<ii8s',12+len(data),len(payload),name.encode());data+=payload
    return struct.pack('<4sii',b'PWAD',3,12+len(data))+data+directory

def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--directory',required=True)
    p.add_argument('--legacy',action='store_true',help='Package the pinned accepted 5.4.20 runtime and compatible save seed.')
    a=p.parse_args()
    if not a.directory or any(c not in 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_' for c in a.directory):p.error('Plain directory name required.')
    out=ROOT/'build'/a.directory;out.mkdir(exist_ok=False)
    manifest={'runtime_sha256':shared.package(out/'production.pk3',{q.relative_to(ROOT/'src').as_posix():q.read_bytes() for q in (ROOT/'src').rglob('*') if q.is_file()}),
        'fixture_sha256':shared.package(out/'seal.pk3',{
            'ZSCRIPT':b'version "4.14"\n#include "equipment.zs"\n#include "legacy.zs"\n#include "seal.zs"\n','seal.zs':(HERE/'seal.zs').read_bytes(),
            'legacy.zs':(HERE/'legacy.zs').read_bytes(),
            'equipment.zs':(HERE.parent/'validation_541/session.zs').read_bytes(),
            'maps/MAP99.wad':wad(),'maps/MAP98.wad':wad(),'maps/MAP97.wad':wad(True),
            'MAPINFO':b'GameInfo { AddEventHandlers="CA252Legacy","CA252Probe" }\ncluster 99 { hub }\nmap MAP99 "Seal fixture" { cluster=99 nointermission sky1="SKY1",0 }\nmap MAP98 "Seal hub" { cluster=99 nointermission sky1="SKY1",0 }\nmap MAP97 "Seal floor" { cluster=99 nointermission sky1="SKY1",0 }\n'})}
    if a.legacy:
        import hashlib
        from zipfile import ZipFile
        # Preserve originals. No author save or existing evidence is overwritten.
        runtime=ROOT/'build/issue251-release-5420/production.pk3'
        data=runtime.read_bytes()
        assert hashlib.sha256(data).hexdigest()=='8e08de05120b4b3409f221835d9753a1d85430ffff3ce89df6276ef28fe9fc6f'
        (out/'production.pk3').write_bytes(data)
        manifest['runtime_sha256']=hashlib.sha256(data).hexdigest()
        with ZipFile(out/'seal.pk3') as archive:parts={n:archive.read(n) for n in archive.namelist()}
        parts['ZSCRIPT']=b'version "4.14"\n#include "equipment.zs"\n#include "legacy.zs"\n'
        parts['MAPINFO']=parts['MAPINFO'].replace(b'"CA252Legacy","CA252Probe"',b'"CA252Legacy"')
        manifest['fixture_sha256']=shared.package(out/'seal.pk3',parts)
    start='wait 100; netevent c252_setup; '
    done='netevent c252_done; wait 2; quit\n'
    scripts={name+'.cfg':start+'netevent c252_'+name+'; '+done for name in ['formulas','earth','gravity','roof','environment','defenses','presentation','performance','interruptions']}
    scripts['falling.cfg']=start+'netevent c252_falling; wait 10; netevent c252_fallen; wait 30; netevent c252_gravity_expired; '+done
    scripts['save.cfg']=start+'netevent c252_seed; save seal.zds; wait 8; '+done
    scripts['gravity-save.cfg']=start+'netevent c252_gravity_seed; save gravity.zds; wait 8; '+done
    scripts['gravity-load.cfg']='wait 1; netevent c252_gravity_loaded; wait 40; netevent c252_gravity_load_expired; '+done
    scripts['load.cfg']='wait 1; netevent c252_loaded; save seal-repeat.zds; wait 8; '+done
    scripts['travel.cfg']='wait 1; netevent c252_loaded; changemap MAP98; wait 20; netevent c252_travelled; changemap MAP99; wait 20; netevent c252_travelled; '+done
    scripts['legacy.cfg']='wait 100; netevent c252_legacy; save legacy.zds; wait 8; quit\n'
    scripts['upgrade.cfg']='wait 1; netevent c252_upgrade; '+done
    manual='language es; con_notifytime 0; use_mouse true; bind f +user2; bind j ca_journal_toggle; bind f6 "netevent c252_next"; wait 100; netevent c252_manual; '
    scripts['manual.cfg']=manual+'netevent c252_done;\n'
    scripts['preview.cfg']=manual+'wait 100; +user2; wait 40; -user2; screenshot seal-chase.png; wait 5; '+done
    scripts['weather-fixed.cfg']=manual+'wait 100; netevent ca_debug_weather_report; +user2; wait 40; -user2; wait 2; netevent ca_debug_weather_report; +user2; wait 2; -user2; wait 1; netevent ca_debug_weather_report; '+done
    scripts['input.cfg']=start+'wait 100; +user2; wait 32; -user2; netevent c252_early; wait 4; netevent c252_first; wait 35; netevent c252_second; wait 35; netevent c252_third; +user2; wait 2; -user2; netevent c252_stopped; '+done
    for name,code in scripts.items():(out/name).write_text(code,encoding='utf-8',newline='\n')
    (out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf-8',newline='\n')
    print(json.dumps(manifest))

if __name__=='__main__':main()
