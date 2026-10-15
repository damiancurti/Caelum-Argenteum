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
args = parser.parse_args()
if not args.directory or any(c not in 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_' for c in args.directory):
    parser.error('Use a plain directory name.')
out = ROOT/'build'/args.directory
out.mkdir(exist_ok=False)
shutil.copyfile(args.runtime, out/'production.pk3')
with zipfile.ZipFile(args.room) as room:
    fixture = {n:room.read(n) for n in ['maps/MAP02.wad','textures/C251TEST.png']}
fixture.update({
    'ZSCRIPT': b'version "4.14"\n#include "flight_probe.zs"\n',
    'flight_probe.zs': (HERE/'flight_probe.zs').read_bytes(),
    'MAPINFO': b'GameInfo { AddEventHandlers="CA251FlightProbe" }\n',
})
manifest = {
    'issue':251,
    'scope':'Native flight API coexistence only; not the cloud implementation or author acceptance.',
    'runtime_sha256':hashlib.sha256(args.runtime.read_bytes()).hexdigest(),
    'fixture_sha256':shared.package(out/'probe.pk3',fixture),
    'reused_room_fixture_sha256':hashlib.sha256(args.room.read_bytes()).hexdigest(),
}
(out/'probe.cfg').write_text('wait 100; netevent c251_flight; wait 3; quit\n', encoding='utf-8',newline='\n')
(out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf-8',newline='\n')
print(json.dumps(manifest))
