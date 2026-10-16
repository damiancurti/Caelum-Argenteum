"""Build deterministic, isolated issue #304 packages; never modify campaign data."""
from pathlib import Path
import argparse
import hashlib
import importlib.util
import json
import shutil
import zipfile

ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).resolve().parent

def package(path,members):
    with zipfile.ZipFile(path,'w',zipfile.ZIP_STORED) as z:
        for name,data in sorted(members.items()):
            z.writestr(zipfile.ZipInfo(name,(2000,1,1,0,0,0)),data)
    return hashlib.sha256(path.read_bytes()).hexdigest()

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--directory',required=True)
    parser.add_argument('--legacy-runtime',type=Path)
    args=parser.parse_args()
    assert all(c.isalnum() or c in '-_' for c in args.directory)
    out=ROOT/'build'/args.directory;out.mkdir(exist_ok=False)
    members={p.relative_to(ROOT/'src').as_posix():p.read_bytes() for p in (ROOT/'src').rglob('*') if p.is_file()}
    manifest={'runtime_sha256':package(out/'production.pk3',members)}
    spec=importlib.util.spec_from_file_location('old',ROOT/'assets/validation_513/prepare.py')
    old=importlib.util.module_from_spec(spec);spec.loader.exec_module(old)
    manifest['fixture_sha256']=package(out/'corpses.pk3',{
        'ZSCRIPT':b'version "4.14"\n#include "corpses.zs"\n',
        'corpses.zs':(HERE/'corpses.zs').read_bytes(),
        'maps/MAP06.wad':old.test_map().replace(b'CA133',b'MAP06'),
        'maps/MAP98.wad':old.test_map().replace(b'CA133',b'MAP98'),
        'MAPINFO':b'GameInfo { AddEventHandlers="CA304Corpses" }\ncluster 434 { hub }\nmap MAP98 "Archive hub control" { cluster=434 }\n'})
    if args.legacy_runtime:
        shutil.copyfile(args.legacy_runtime,out/'legacy.pk3')
        manifest['legacy_sha256']=hashlib.sha256((out/'legacy.pk3').read_bytes()).hexdigest()
        source=(HERE/'corpses.zs').read_text(encoding='utf-8').split('    void Counts()')[0]
        source+='''    override void NetworkProcess(ConsoleEvent e)
    {if(e.Name=="c304_seed")Seed();
     if(e.Name=="c304_done")Console.Printf("CA304 DONE failures=0 legacy seed saved");}
}\n'''
        manifest['legacy_fixture_sha256']=package(out/'legacy-corpses.pk3',{
            'ZSCRIPT':b'version "4.14"\n#include "corpses.zs"\n','corpses.zs':source.encode(),
            'maps/MAP06.wad':old.test_map().replace(b'CA133',b'MAP06'),
            'MAPINFO':b'GameInfo { AddEventHandlers="CA304Corpses" }\n'})
    scripts={
        'outside.cfg':'wait 70; netevent c304_seed; wait 5; netevent c304_outside; netevent c304_done; wait 5; quit\n',
        'player.cfg':'wait 70; netevent c304_seed; wait 5; netevent c304_playerdie; wait 5; netevent c304_playercheck; netevent c304_done; wait 5; quit\n',
        'corpses.cfg':'wait 70; netevent c304_seed; wait 5; netevent c304_counts; wait 35; netevent c304_frozen; wait 5; netevent c304_resumed; wait 3; netevent c304_redeath; netevent c304_done; wait 5; quit\n',
        'save.cfg':'wait 70; netevent c304_seed; wait 5; netevent c304_counts; save corpses.zds; wait 5; netevent c304_done; wait 5; quit\n',
        'load.cfg':'wait 5; netevent c304_loaded; wait 35; netevent c304_frozen; wait 5; netevent c304_resumed; wait 3; netevent c304_redeath; netevent c304_done; wait 5; quit\n',
        'travel.cfg':'wait 5; changemap MAP98; wait 5; changemap MAP06; wait 5; netevent c304_loaded; wait 35; netevent c304_frozen; wait 5; netevent c304_resumed; wait 3; netevent c304_redeath; netevent c304_done; wait 5; quit\n',
        'redemption.cfg':'wait 70; netevent c304_seed; wait 5; netevent c304_counts; netevent c304_redemption; netevent c304_done; wait 5; quit\n'}
    for name,script in scripts.items():(out/name).write_text(script,encoding='utf-8',newline='\n')
    (out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf-8')
    print(json.dumps(manifest))

if __name__=='__main__':main()
