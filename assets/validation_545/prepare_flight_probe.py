"""Freeze a native PowerFlight coexistence probe, without implementing #251."""
from pathlib import Path
import argparse
import hashlib
import importlib.util
import json
import shutil
import zipfile

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location('shared', HERE.parent/'validation_541/prepare.py')
shared = importlib.util.module_from_spec(spec)
spec.loader.exec_module(shared)
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--directory', required=True)
parser.add_argument('--runtime', required=True, type=Path)
parser.add_argument('--room', required=True, type=Path)
parser.add_argument('--owned', action='store_true', help='Test the production ownership helper with real Tarot and a second fixture source.')
args = parser.parse_args()
if not args.directory or any(c not in 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_' for c in args.directory):
    parser.error('Use a plain directory name.')
out = ROOT/'build'/args.directory
out.mkdir(exist_ok=False)
shutil.copyfile(args.runtime, out/'production.pk3')
with zipfile.ZipFile(args.room) as room:
    fixture = {n:room.read(n) for n in ['maps/MAP02.wad','textures/C251TEST.png']}
probe = 'owned_flight_probe.zs' if args.owned else 'flight_probe.zs'
handler = 'CA251OwnedFlightProbe' if args.owned else 'CA251FlightProbe'
event = 'c251_owned_flight' if args.owned else 'c251_flight'
fixture.update({
    'ZSCRIPT': f'version "4.14"\n#include "{probe}"\n'.encode(),
    probe: (HERE/probe).read_bytes(),
    'MAPINFO': f'GameInfo {{ AddEventHandlers="{handler}" }}\n'.encode(),
})
manifest = {
    'issue':251,
    'scope':'Flight ownership component with real Tarot and a fixture source; not full cloud implementation or author acceptance.' if args.owned else 'Native flight API coexistence only; not the cloud implementation or author acceptance.',
    'runtime_sha256':hashlib.sha256(args.runtime.read_bytes()).hexdigest(),
    'fixture_sha256':shared.package(out/'probe.pk3',fixture),
    'reused_room_fixture_sha256':hashlib.sha256(args.room.read_bytes()).hexdigest(),
}
(out/'probe.cfg').write_text(f'wait 100; netevent {event}; wait 3; quit\n', encoding='utf-8',newline='\n')
(out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf-8',newline='\n')
print(json.dumps(manifest))
