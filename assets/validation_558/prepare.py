"""Freeze the issue #369 model fixture, source package and command scripts."""
from pathlib import Path
import argparse
import hashlib
import json
import shutil
import struct
import zipfile

ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).parent

def package(path,members):
    with zipfile.ZipFile(path,'w',compression=zipfile.ZIP_DEFLATED,compresslevel=1) as archive:
        for name,data in sorted(members.items()):
            info=zipfile.ZipInfo(name,(2026,10,19,0,0,0));info.compress_type=zipfile.ZIP_DEFLATED;info.external_attr=0o100644<<16
            archive.writestr(info,data,compresslevel=1)
    return hashlib.sha256(path.read_bytes()).hexdigest()

def geometry():
    text=['namespace="ZDoom";','sector { heightfloor=0; heightceiling=256; texturefloor="CMGR03"; textureceiling="F_SKY1"; lightlevel=224; }']
    points=[(-2048,-2048),(-2048,2048),(2048,2048),(2048,-2048)]
    for x,y in points:text.append(f'vertex {{ x={x}; y={y}; }}')
    for i in range(4):
        text.append('sidedef { sector=0; texturemiddle="CACVROCK"; }')
        text.append(f'linedef {{ v1={i}; v2={(i+1)%4}; sidefront={i}; }}')
    text.append('thing { x=-128; y=0; type=1; angle=0; skill1=true; skill2=true; skill3=true; skill4=true; skill5=true; single=true; }')
    data=b'';directory=b''
    for name,content in [('TBULL',b''),('TEXTMAP','\n'.join(text).encode()),('ENDMAP',b'')]:
        directory+=struct.pack('<ii8s',12+len(data),len(content),name.encode());data+=content
    return struct.pack('<4sii',b'PWAD',3,12+len(data))+data+directory

def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--directory',required=True);p.add_argument('--runtime',type=Path);p.add_argument('--baseline-probe',action='store_true');a=p.parse_args()
    if any(c not in 'abcdefghijklmnopqrstuvwxyz0123456789-_' for c in a.directory):p.error('Plain directory name required')
    out=ROOT/'build'/a.directory;out.mkdir(exist_ok=False)
    if a.runtime:
        with zipfile.ZipFile(a.runtime) as archive:source={n:archive.read(n) for n in archive.namelist()}
        shutil.copyfile(a.runtime,out/'production.pk3')
        runtime_hash=hashlib.sha256((out/'production.pk3').read_bytes()).hexdigest()
    else:
        source={p.relative_to(ROOT/'src').as_posix():p.read_bytes() for p in (ROOT/'src').rglob('*') if p.is_file()}
        runtime_hash=package(out/'production.pk3',source)
    manifest={'runtime_sha256':runtime_hash,'source_hashes':{n:hashlib.sha256(b).hexdigest() for n,b in source.items()}}
    fixture={'ZSCRIPT':b'version "4.14"\n#include "common.zs"\n#include "probe.zs"\n','common.zs':(HERE/'common.zs').read_bytes(),'probe.zs':(HERE/('baseline.zs' if a.baseline_probe else 'probe.zs')).read_bytes(),'maps/TBULL.wad':geometry(),
        'MAPINFO':b'GameInfo { AddEventHandlers="CA369Probe" }\ncluster 98 { hub }\nmap TBULL "Bull presentation fixture" { cluster=98 sky1="CMLMSKY",0 }\nmap TBULL2 "Bull hub return" { cluster=98 sky1="CMLMSKY",0 }\n'}
    fixture['maps/TBULL2.wad']=fixture['maps/TBULL.wad']
    fixture['ZSCRIPT']+=b'#include "perf.zs"\n'
    fixture['perf.zs']=(HERE/'perf.zs').read_bytes()
    fixture['MAPINFO']=fixture['MAPINFO'].replace(b'AddEventHandlers="CA369Probe"',b'AddEventHandlers="CA369Probe","CA369Performance"')
    manifest['fixture_sha256']=package(out/'quick.pk3',fixture)
    scripts={'smoke.cfg':'wait 10; netevent c369_setup; wait 20; screenshot quick-idle.png; netevent c369_check; wait 2; netevent c369_done; wait 2; quit\n'}
    check='netevent c369_checkcast; '+('' if a.baseline_probe else 'netevent c369_checkmodels; ')
    done='netevent c369_done; wait 2; quit\n'
    scripts.update({
        'cast.cfg':'wait 10; netevent c369_cast; wait 3; netevent c369_killcast; wait 40; netevent c369_archive; wait 3; '+check+'save cast.zds; wait 3; '+done,
        'load.cfg':'wait 10; '+check+'save loaded.zds; wait 3; '+done,
        'reload.cfg':'wait 10; '+check+done,
        'rollback.cfg':'wait 10; ca_bull_3d false; wait 5; netevent c369_disabled; netevent c369_checkcast; save rollback.zds; wait 3; '+done,
        'encounter.cfg':'wait 10; netevent c369_encounter; wait 190; screenshot quick-map01.png; '+done,
        'hub-out.cfg':'wait 10; netevent c369_cast; wait 3; netevent c369_killcast; wait 40; netevent c369_archive; wait 3; '+check+'changemap TBULL2; wait 10; ca_bull_3d false; wait 5; save hub-rollback.zds; wait 3; '+done,
        'hub-back.cfg':'wait 10; changemap TBULL; wait 10; netevent c369_checkcast; '+done,
        'perf.cfg':'wait 10; netevent c369_user; netevent c369_perf 1; wait 425; screenshot quick-perf.png; '+done,
        'reference.cfg':'wait 10; netevent c369_user; netevent c369_perf 0; wait 425; screenshot quick-reference.png; '+done,
        'poses.cfg':'wait 10; netevent c369_setup; wait 3; con_notifytime 0; netevent c369_pose 0; wait 4; netevent c369_expect 0; screenshot quick-idle-side.png; netevent c369_pose 1; wait 10; netevent c369_expect 1; screenshot quick-walk.png; netevent c369_stop; wait 6; netevent c369_stopped; screenshot quick-stopped-a.png; wait 5; screenshot quick-stopped-b.png; exec poses2.cfg\n',
        'poses2.cfg':'netevent c369_pose 2; wait 10; netevent c369_expect 2; screenshot quick-run.png; netevent c369_pose 3; wait 2; netevent c369_expect 3; screenshot quick-prepare.png; netevent c369_pose 5; wait 2; netevent c369_expect 6; screenshot quick-gore.png; netevent c369_pose 4; wait 2; netevent c369_expect 7; screenshot quick-pain.png; exec poses3.cfg\n',
        'poses3.cfg':'netevent c369_pose 7; wait 4; netevent c369_expect 10; screenshot quick-rest.png; netevent c369_hide; wait 3; netevent c369_hidden; netevent c369_place; wait 3; netevent c369_visible; netevent c369_pose 8; wait 3; netevent c369_expect 11; screenshot quick-stun.png; netevent c369_pose 6; wait 10; netevent c369_expect 8; screenshot quick-death.png; wait 30; netevent c369_expect 9; screenshot quick-corpse.png; '+done,
        'recall.cfg':'wait 10; '+check+'netevent c369_recall; wait 3; netevent c369_recalled; '+done,
        'fade.cfg':'wait 10; netevent c369_fade; wait 75; netevent c369_fading; wait 50; netevent c369_faded; '+done,
        'manual.cfg':'wait 10; netevent c369_manual; netevent c369_reset; bind F1 "netevent c369_reset"; bind F2 "netevent c369_manualpose 1"; bind F3 "netevent c369_manualpose 2"; bind F4 "netevent c369_manualpose 3"; bind F5 "netevent c369_manualpose 5"; bind F6 "netevent c369_manualpose 4"; bind F7 "netevent c369_manualpose 7"; bind F8 "netevent c369_manualkill"; bind F9 "toggle ca_bull_3d"; con_notifytime 0\n',
        'manual-map.cfg':'wait 10; netevent c369_manualmap; bind F5 "netevent c369_encounter"; bind F8 "netevent c369_manualkill"; bind F9 "toggle ca_bull_3d"; con_notifytime 0\n',
    })
    for name,value in scripts.items():(out/name).write_text(value,encoding='utf-8')
    manifest['script_hashes']={name:hashlib.sha256((out/name).read_bytes()).hexdigest() for name in scripts}
    (out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf-8')
    print(out.relative_to(ROOT))

if __name__=='__main__':main()
