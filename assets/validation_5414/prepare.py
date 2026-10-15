"""Freeze the current runtime and observe the original MAP01 encounter."""
from pathlib import Path
import argparse,importlib.util,json,shutil
ROOT=Path(__file__).resolve().parents[2];HERE=Path(__file__).parent
spec=importlib.util.spec_from_file_location('room',HERE.parent/'validation_5218/prepare.py')
room=importlib.util.module_from_spec(spec);spec.loader.exec_module(room)
p=argparse.ArgumentParser(description=__doc__);p.add_argument('--directory',required=True)
p.add_argument('--runtime',type=Path);p.add_argument('--save',type=Path);p.add_argument('--case',choices=['encounter','migration'],default='encounter');a=p.parse_args()
if not a.directory or any(c not in 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_' for c in a.directory):p.error('Plain directory name required.')
if a.save and not a.save.is_file():p.error('Input save must exist before preparing its next run.')
if a.runtime and not a.runtime.is_file():p.error('Input runtime must exist.')
out=ROOT/'build'/a.directory;out.mkdir(exist_ok=False)
manifest={}
if a.runtime:
    import hashlib
    shutil.copyfile(a.runtime,out/'production.pk3');manifest['runtime_sha256']=hashlib.sha256(a.runtime.read_bytes()).hexdigest()
else:manifest['runtime_sha256']=room.package(out/'production.pk3',{p.relative_to(ROOT/'src').as_posix():p.read_bytes() for p in (ROOT/'src').rglob('*') if p.is_file()})
source=a.case+'.zs';handler='CA253Probe' if a.case=='encounter' else 'CA253Migration'
manifest['fixture_sha256']=room.package(out/'encounter.pk3',{'ZSCRIPT':f'version "4.14"\n#include "{source}"\n'.encode(),source:(HERE/source).read_bytes(),'MAPINFO':f'GameInfo {{ AddEventHandlers="{handler}" }}\n'.encode()})
if a.save:shutil.copyfile(a.save,out/'input.zds')
(out/'observe.cfg').write_bytes(b'wait 2200; netevent c253_done; wait 35; quit\n')
scripts={
 'walk.cfg':'wait 25; +forward; wait 140; -forward; wait 75; screenshot floor.png; wait 1860; netevent c253_check; wait 5; netevent c253_win; wait 35; netevent c253_won; wait 35; netevent c253_done; wait 35; quit\n',
 'save.cfg':'wait 25; +forward; wait 140; -forward; wait 15; save encounter.zds; wait 35; netevent c253_saved; wait 35; quit\n',
 'load.cfg':'wait 2100; netevent c253_check; wait 5; netevent c253_win; wait 35; netevent c253_won; wait 35; netevent c253_done; wait 35; quit\n',
 'seed.cfg':'wait 100; netevent c253_seed; wait 5; save legacy.zds; wait 35; quit\n',
 'migration.cfg':'wait 20; netevent c253_migration; wait 35; save migrated.zds; wait 35; quit\n',
 'manual.cfg':'language es; con_notifytime 0; use_mouse true; bind f7 "netevent c253_win"; wait 100; netevent c253_done;\n'}
for name,script in scripts.items():(out/name).write_bytes(script.encode())
(out/'manifest.json').write_bytes((json.dumps(manifest,indent=2)+'\n').encode());print(json.dumps(manifest))
