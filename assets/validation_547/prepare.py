"""Freeze #241 runtime and native input/physics/persistence fixtures."""
from pathlib import Path
import argparse, importlib.util, json

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).parent
spec = importlib.util.spec_from_file_location('room209', HERE.parent/'validation_5218/prepare.py')
room = importlib.util.module_from_spec(spec)
spec.loader.exec_module(room)
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--directory', required=True)
args = parser.parse_args()
if not args.directory or any(c not in 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_' for c in args.directory):
    parser.error('Plain directory name required.')
out = ROOT/'build'/args.directory
out.mkdir(exist_ok=False)
manifest = {'runtime_sha256': room.package(out/'production.pk3', {
    p.relative_to(ROOT/'src').as_posix(): p.read_bytes() for p in (ROOT/'src').rglob('*') if p.is_file()})}
manifest['fixture_sha256'] = room.package(out/'telekinesis.pk3', {
    'ZSCRIPT': b'version "4.14"\n#include "telekinesis.zs"\n',
    'telekinesis.zs': (HERE/'telekinesis.zs').read_bytes(),
    'maps/MAP99.wad': room.room(), 'maps/MAP98.wad': room.room(),
    'MAPINFO': b'GameInfo { AddEventHandlers="CA241Probe" }\ncluster 99 { hub }\nmap MAP99 "Telekinesis fixture" { cluster=99 sky1="SKY1",0 }\nmap MAP98 "Telekinesis hub" { cluster=99 sky1="SKY1",0 }\n'})
setup = 'wait 100; netevent c241_setup; wait 10; '
on = '+user1; wait 35; -user1; wait 2; netevent c241_on; '
done = 'netevent c241_done; wait 2; quit\n'
scripts = {
    'gravity.cfg': setup+'netevent c241_gravity_seed 1000; wait 10; netevent c241_gravity_check; netevent c241_gravity_seed 66; wait 10; netevent c241_gravity_check; '+done,
    'return.cfg': 'wait 10; netevent c241_return; '+done,
    'real.cfg': setup+'netevent c241_real 0; wait 2; netevent c241_real 1; wait 2; netevent c241_real 2; wait 2; netevent c241_real 3; '+done,
    'contract.cfg': setup+'netevent c241_contract; netevent c241_setup; '+on
        +'netevent c241_move; wait 35; netevent c241_moved; +user1; wait 4; -user1; netevent c241_off; '
        +'netevent c241_setup; '+on+'netevent c241_exhaust; wait 2; netevent c241_exhausted; '+done,
    'save.cfg': setup+on+'netevent c241_save_seed; save telekinesis.zds; wait 5; '+done,
    'load.cfg': 'wait 10; netevent c241_loaded; +user1; wait 3; -user1; netevent c241_off; '+done,
    'hub.cfg': setup+on+'changemap MAP98; wait 10; netevent c241_off; changemap MAP99; wait 10; netevent c241_hub; '+done,
    'compile.cfg': 'wait 60; '+done,
}
manual = ('language es; bind f +user1; bind f6 "netevent c241_manual 0"; bind f7 "netevent c241_manual 1"; '
    'bind f8 "netevent c241_manual 2"; bind f9 "netevent c241_manual 3"; bind f10 "netevent c241_strong"; '
    'bind f11 "netevent c241_low"; wait 100; netevent c241_manual 0; ')
scripts['manual.cfg'] = manual+'\n'
scripts['preview.cfg'] = manual+'wait 2; +user1; wait 5; -user1; wait 5; screenshot telekinesis-ready.png; wait 5; quit\n'
for name, content in scripts.items():
    (out/name).write_bytes(content.encode('utf-8'))
(out/'manifest.json').write_bytes((json.dumps(manifest, indent=2)+'\n').encode())
print(json.dumps(manifest))
