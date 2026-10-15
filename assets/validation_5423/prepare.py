"""Freeze the controlled #283 native model pilot; never package fixtures in src."""
from pathlib import Path
import argparse
import importlib.util
import json

ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).parent
spec=importlib.util.spec_from_file_location('seal',HERE.parent/'validation_5421/prepare.py')
seal=importlib.util.module_from_spec(spec);spec.loader.exec_module(seal)

def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--directory',required=True)
    p.add_argument('--visual',action='store_true',help='Omit HUD overlays only in the isolated art fixture.')
    a=p.parse_args()
    if any(c not in 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_' for c in a.directory):p.error('Plain directory name required.')
    out=ROOT/'build'/a.directory;out.mkdir(exist_ok=False)
    handlers='AddEventHandlers="CA283Probe"'
    mapinfo='GameInfo { PlayerClasses="CaelumDomingoPilotPlayer" '+handlers+' }\ncluster 99 { hub }\nmap MAP99 "Domingo pilot" { cluster=99 nointermission sky1="SKY1",0 }\nmap MAP98 "Domingo pilot hub" { cluster=99 nointermission sky1="SKY1",0 }\n'
    modeldef=(ROOT/'src/MODELDEF').read_text(encoding='utf-8').split('// BEGIN DOMINGO 3D PILOT\n')[1].split('// END DOMINGO 3D PILOT')[0]
    modeldef=modeldef.replace('Model CaelumDomingoPilotBody','Model CA283ModelProxy')
    manifest={'runtime_sha256':seal.shared.package(out/'production.pk3',{
        q.relative_to(ROOT/'src').as_posix():q.read_bytes() for q in (ROOT/'src').rglob('*') if q.is_file()}),
        'fixture_sha256':seal.shared.package(out/'pilot.pk3',{
            'ZSCRIPT':b'version "4.14"\n#include "equipment.zs"\n#include "probe.zs"\n','probe.zs':(HERE/'probe.zs').read_bytes(),
            'equipment.zs':(HERE.parent/'validation_541/session.zs').read_bytes(),
            'MODELDEF':modeldef.encode(),
            'maps/MAP99.wad':seal.wad(),'maps/MAP98.wad':seal.wad(),
            'MAPINFO':mapinfo.encode()})}
    start='wait 100; netevent c283_setup; wait 35; con_notifytime 0; '
    if a.visual:start+='netevent c283_hide; wait 10; '
    done='netevent c283_done; wait 35; quit\n'
    scripts={'preview.cfg':start+'wait 35; screenshot pilot-front.png; netevent c283_side; wait 35; screenshot pilot-side.png; netevent c283_rear; wait 35; screenshot pilot-rear.png; netevent c283_original; wait 35; screenshot pilot-original.png; '+done,
             'compile.cfg':'wait 100; netevent c283_done; wait 35; quit\n',
             'actions.cfg':start+'netevent c283_audit; cl_run false; +forward; wait 12; -forward; wait 10; +speed; +forward; wait 12; -forward; -speed; wait 10; netevent c283_moved; +attack; wait 60; -attack; wait 20; netevent c283_attacked; '+done,
             'rest.cfg':start+'netevent c283_chair; wait 35; screenshot pilot-chair.png; netevent c283_stand; wait 35; netevent c283_bed; wait 35; screenshot pilot-bed.png; netevent c283_stand; wait 35; netevent c283_ground; wait 35; screenshot pilot-ground.png; netevent c283_stand; '+done,
             'save.cfg':start+'save piloto.zds; wait 35; '+done,
             'load.cfg':'wait 35; netevent c283_loaded; '+done,
             'fallback.cfg':start+'netevent c283_fallback; '+done,
             'travel.cfg':'wait 35; netevent c283_loaded; changemap MAP98; wait 35; netevent c283_loaded; changemap MAP99; wait 35; netevent c283_loaded; '+done,
             'manual.cfg':start+'netevent c283_manual; chase_dist 150; chase_height 10; language es; use_mouse true; bind f6 "netevent c283_compare"; bind f7 "netevent c283_next_rest"; bind f8 "netevent c283_orbit"; netevent c283_done;\n',
             'death.cfg':start+'netevent c283_kill; wait 70; netevent c283_dead; screenshot pilot-death.png; '+done}
    scripts['death-console.cfg']=start+'kill; wait 70; netevent c283_dead; screenshot pilot-death-still.png; '+done
    scripts['camera.cfg']=start+'netevent c283_manual; wait 5; netevent c283_camera_audit; screenshot pilot-review-front.png; +forward; wait 10; -forward; wait 5; netevent c283_camera_audit; netevent c283_orbit; wait 5; netevent c283_camera_audit; screenshot pilot-review-side.png; '+done
    for count in (1,64):
        for model in (0,1):
            scripts[f'bench-{count}-{model}.cfg']=start+f'vid_vsync false; vid_maxfps 0; netevent c283_bench {count} {model}; wait 175; netevent c283_record; wait 350; netevent c283_record_end; profilethinkers -t 20; wait 35; screenshot pilot-bench-{count}-{model}.png; '+done
    for name,code in scripts.items():(out/name).write_text(code,encoding='utf-8',newline='\n')
    (out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf-8',newline='\n')
    print(json.dumps(manifest))

if __name__=='__main__':main()
