"""Freeze actual house-door travel without changing production presentation."""
from pathlib import Path
import argparse
import importlib.util
import json

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).parent

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--directory', required=True)
    parser.add_argument('--vehicle',action='store_true')
    parser.add_argument('--fixed',action='store_true')
    args = parser.parse_args()
    if not args.directory.startswith('issue334-') or any(c not in 'abcdefghijklmnopqrstuvwxyz0123456789-_' for c in args.directory):
        parser.error('Expected a plain issue334 directory')
    spec = importlib.util.spec_from_file_location('quick', ROOT/'assets/validation_5422/prepare.py')
    quick = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(quick)
    package = quick.seal.shared.package
    folder = ROOT/'build'/args.directory
    folder.mkdir(exist_ok=False)
    manifest = {
        'runtime_sha256': package(folder/'production.pk3', {p.relative_to(ROOT/'src').as_posix():p.read_bytes() for p in (ROOT/'src').rglob('*') if p.is_file()}),
        'fixture_sha256': package(folder/'quick.pk3', {
            'ZSCRIPT': b'version "4.14"\n#include "probe.zs"\n#include "house334.zs"\n'+(b'#include "vehicle.zs"\n' if args.vehicle else b''),
            'probe.zs': (ROOT/'assets/validation_5422/probe.zs').read_bytes(),
            'house334.zs': (HERE/'house334-probe.zs').read_bytes(),
            **({'vehicle.zs':(HERE/'house334-vehicle.zs').read_bytes()} if args.vehicle else {}),
            'MAPINFO': ('GameInfo { AddEventHandlers="'+('CA334VehicleProbe' if args.vehicle else 'CA334Probe')+'" }\n').encode()})}
    for kind in (1, 3):
        script = f'wipetype {kind}; wait 70; netevent c334_seed; netevent c334_position 0; wait 5; +use; wait 10; -use; wait 70; netevent c334_inside 0; screenshot inside-{kind}.png; netevent c334_position 0; wait 5; +use; wait 10; -use; wait 70; netevent c334_outside; screenshot outside-{kind}.png; netevent c282_done; wait 5; quit\n'
        (folder/f'normal{kind}.cfg').write_text(script,encoding='utf-8')
    if args.vehicle:
        for mode in (3,4):
            for early in (0,1):
                script=f'cl_capfps 1; wipetype 2; wait 100; netevent c334_vehicle_seed {mode} {early} {int(args.fixed)}; wait 10; netevent c334_board; wait 450; netevent c334_vehiclecheck; wait 15; quit\n'
                (folder/f'vehicle{mode}-{early}.cfg').write_text(script,encoding='utf-8')
    (folder/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf-8')
    print(json.dumps(manifest))

if __name__=='__main__':main()
