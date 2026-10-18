"""Package exact production bytes with private siege-focus correctness controls."""
from pathlib import Path
import argparse
import hashlib
import importlib.util
import json
import re
import subprocess
import zipfile

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).parent
spec = importlib.util.spec_from_file_location('prior', ROOT/'assets/validation_5443/prepare.py')
prior = importlib.util.module_from_spec(spec)
spec.loader.exec_module(prior)
BASE_REF = 'f3fedf95'


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--directory', required=True)
    parser.add_argument('--scenario', choices=['checks', 'live', 'rollback'], default='checks')
    parser.add_argument('--runtime', type=Path)
    args = parser.parse_args()
    assert re.fullmatch(r'issue361-[a-z0-9-]+', args.directory)
    out = ROOT/'build'/args.directory
    out.mkdir(exist_ok=False)
    members = {p.relative_to(ROOT/'src').as_posix(): p.read_bytes()
               for p in (ROOT/'src').rglob('*') if p.is_file()}
    if args.runtime:
        with zipfile.ZipFile(args.runtime) as archive:
            members = {name: archive.read(name) for name in archive.namelist()}
    fixture = {'ZSCRIPT': b'version "4.14"\n#include "probe.zs"\n'}
    probe = (HERE/(args.scenario+'.zs')).read_text(encoding='utf-8')
    if args.scenario == 'checks':
        original = subprocess.check_output(['git', 'show', BASE_REF+':src/caelum/actors/CaelumCombatActor.zs'], cwd=ROOT).decode('utf-8-sig')
        start = original.index('    void CalculateCombatHealthEffects()')
        end = original.index('    void CycleDebugCombatHealthState()', start)
        method = original[start:end].replace('CalculateCombatHealthEffects()', 'ReferenceHealth()')
        probe += '\nclass CA361Mandinga : CaelumMandinga\n{\n'+method+'}\n'
        fixture['maps/MAP03.wad'] = prior.flat_map()
        fixture['MAPINFO'] = b'GameInfo { AddEventHandlers="CA361Checks" }\n'
    else:
        compatibility = (ROOT/'assets/validation_5446/trace.zs').read_text(encoding='utf-8').split('class CA334NativeTrace')[0]
        probe = compatibility+probe
        fixture['MAPINFO'] = b'GameInfo { AddEventHandlers="CA353Performance", "CA361Live" }\n'
        for name in ['auto00.zds', 'auto03.zds']:
            (out/name).write_bytes((ROOT/'build/issue354-preview01'/name).read_bytes())
    fixture['probe.zs'] = probe.encode('utf-8')
    package = prior.prior.base.package
    manifest = dict(issue=361, release='5.4.47', scenario=args.scenario,
                    reference_commit=BASE_REF,
                    source_commit=subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True).strip(),
                    runtime_sha256=package(out/'baseline.pk3', members),
                    fixture_sha256=package(out/'city.pk3', fixture),
                    source_hashes={n: hashlib.sha256(data).hexdigest() for n, data in members.items()})
    (out/'manifest.json').write_text(json.dumps(manifest, indent=2)+'\n', encoding='utf-8')
    scripts = {
        'checks': 'wait 100; quit',
        'city': 'wait 70; netevent ca361_check; wait 2; storesavepic false; save focus-city; wait 3; quit',
        'roundtrip': 'wait 70; netevent ca361_check; wait 2; changemap CAH008; wait 140; netevent ca361_check; wait 2; storesavepic false; save focus-house; wait 3; changemap MAP03; wait 140; netevent ca361_check; wait 2; quit',
        'house': 'wait 70; netevent ca361_check; wait 2; changemap MAP03; wait 140; netevent ca361_check; wait 2; quit',
        'reload': 'wait 70; netevent ca361_check; wait 3; quit',
    }
    for name, commands in scripts.items():
        if args.scenario != 'checks':
            commands = 'cl_capfps true; wipetype 0; '+commands.replace('wait 70;', 'wait 350;').replace('wait 140;', 'wait 350;')
        (out/(name+'.cfg')).write_text(commands+'\n', encoding='utf-8')
    print(json.dumps({k: v for k, v in manifest.items() if k != 'source_hashes'}))


if __name__ == '__main__':
    main()
