"""Freeze #313 ammo tests, reusing accepted #309 setup and #192 defenses."""
from pathlib import Path
import argparse,hashlib,importlib.util,json,subprocess,zipfile
ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).parent
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--directory',required=True);p.add_argument('--runtime',type=Path,required=True)
    a=p.parse_args();assert a.directory.replace('-','').replace('_','').isalnum()
    out=ROOT/'build'/a.directory;out.mkdir(exist_ok=False)
    spec=importlib.util.spec_from_file_location('qa194',HERE.parent/'validation_5211/prepare.py');qa=importlib.util.module_from_spec(spec);spec.loader.exec_module(qa)
    (out/'production.pk3').write_bytes(a.runtime.read_bytes())
    sources=[HERE.parent/'validation_550/probe.zs',HERE/'probe.zs']
    code=b'\n'.join(p.read_bytes() for p in sources)
    common={'maps/MAPQA.wad':qa.test_map(),'maps/MAPQB.wad':qa.test_map(),'ZSCRIPT':b'version "4.14"\n#include "probe.zs"\n'}
    info='cluster 99 { hub }\nmap MAPQA "Ammo audit" { cluster=99 nointermission }\nmap MAPQB "Ammo return" { cluster=99 nointermission }\n'
    qa.package(out/'qa.pk3',dict(common,**{'probe.zs':code,'MAPINFO':(info+'GameInfo { AddEventHandlers="CA313Probe","CA313HUD" }\n').encode()}))
    defense=[HERE.parent/'validation_5210/base.zs.inc',HERE.parent/'validation_5210/ranged.zs']
    data=b'\n'.join(p.read_bytes() for p in defense)
    data+=b'\nclass CA313Ranged : CA192Ranged { override void WorldTick(){Super.WorldTick();if(Age==101)Console.Printf("CA194 DONE failures=%d passes=%d",Failures,Passes);} }\n'
    qa.package(out/'ranged.pk3',dict(common,**{'probe.zs':data,'MAPINFO':(info+'GameInfo { AddEventHandlers="CA313Ranged" }\n').encode()}))
    start='vid_maxfps 60; wait 180; netevent c313_setup; wait 80; '
    end='netevent c313_done; wait 5; quit\n'
    scripts={'inventory.cfg':start+'netevent c313_inventory; wait 10; '+end,
             'ranged.cfg':'wait 190; quit\n',
             'save.cfg':start+'netevent c313_checkpoint; wait 5; storesavepic false; save ca313-ammo; wait 5; '+end,
             'old-save.cfg':start.replace('c313_setup;','c313_setup 1;')+'netevent c313_checkpoint; wait 5; storesavepic false; save ca313-ammo; wait 5; '+end,
             'load.cfg':'vid_maxfps 60; wait 45; netevent c313_loaded; wait 5; storesavepic false; save ca313-upgraded; '+end,
             'rollback.cfg':'vid_maxfps 60; wait 45; netevent c313_loaded 1; wait 5; '+end,
             'hub.cfg':start+'netevent c313_checkpoint; wait 5; changemap MAPQB; wait 40; changemap MAPQA; wait 45; netevent c313_loaded 0 1; '+end}
    firing=''
    for kind in (2,14,15,16):
        firing+=f'netevent c313_equip {kind}; wait 70; netevent c313_before; wait 2; +reload; wait 1; -reload; wait 320; netevent c313_after 0; wait 5; netevent c313_before; wait 2; +attack; wait 1; -attack; wait 60; netevent c313_after 1; wait 5; '
    scripts['fire.cfg']=start+firing+end
    scripts['preview.cfg']=start.replace('c313_setup;','c313_setup 0 1;')+'use_mouse true; language es; bind f6 "netevent c313_equip 2"; bind f7 "netevent c313_equip 14"; bind f8 "netevent c313_box"; bind f10 "map MAPQA; exec preview.cfg"; con_notifytime 0; netevent c313_done;\n'
    # Keep delayed commands on one line: exec queues separate lines independently.
    scripts['preview-smoke.cfg']=scripts['preview.cfg'].strip()+' wait 90; screenshot preview.png; wait 5; quit\n'
    for n,s in scripts.items():(out/n).write_text(s,encoding='utf-8',newline='\n')
    manifest={'source_commit':subprocess.check_output(['git','rev-parse','HEAD'],cwd=ROOT,text=True).strip(),'runtime_sha256':sha(out/'production.pk3'),
              'fixtures':{n:sha(out/n) for n in ('qa.pk3','ranged.pk3')},'script_hashes':{n:sha(out/n) for n in scripts},
              'source_hashes':{str(p.relative_to(ROOT)):sha(p) for p in sources+defense+[Path(__file__)]}}
    (out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf-8',newline='\n');print(out)
if __name__=='__main__':main()
