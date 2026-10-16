"""Build a pinned #238 schema bridge and an isolated paid-state round trip.

The old gameplay retains new fields as inert data. It cannot run the new
preparation or racial lifecycle. Use separate save copies and return to the
current runtime to resume them. This is not a general downgrade converter.
"""
import argparse
import importlib.util
import io
import json
from pathlib import Path
import re
import subprocess
import zipfile

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent
BASE = 'c07be5a2'
CURRENT = '0e0ae85f'


def module(path, name):
    spec = importlib.util.spec_from_file_location(name, path)
    result = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(result)
    return result


def source(ref):
    raw = subprocess.check_output(['git', 'archive', '--format=zip', ref, 'src'], cwd=ROOT)
    with zipfile.ZipFile(io.BytesIO(raw)) as archive:
        return {n[4:]: archive.read(n) for n in archive.namelist() if not n.endswith('/')}


def inject(members, name, declaration):
    text = members[name].decode('utf-8-sig')
    start = text.index('{', text.index('class ')) + 1
    members[name] = (text[:start] + '\n' + declaration + '\n' + text[start:]).encode()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--directory', required=True, help='Fresh build/ prefix, followed by -current and -bridge.')
    args = parser.parse_args()
    if not args.directory or any(c not in 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_' for c in args.directory):
        parser.error('Use a plain directory prefix.')
    outputs = {mode: ROOT / 'build' / (args.directory + '-' + mode) for mode in ['current', 'bridge']}
    if any(p.exists() for p in outputs.values()):
        parser.error('Use a fresh prefix; existing evidence is preserved.')
    shared = module(HERE.parent / 'validation_541/prepare.py', 'package541')
    baseline = source(BASE)
    current = source(CURRENT)
    bridge = dict(baseline)
    inject(bridge, 'caelum/player/CaelumPlayer.zs', '''
    CaelumSpellSleepState SpellSleep;
    int ClassPreparationRevision,ClassPreparationTics,ClassCastRevision,ClassCastProfession;
    bool ClassCastActive,RacialAbilityActive,RacialAbilityInputLatched;
    double ClassCastCost,ClassCastPaid;
    int RacialAbilityRevision;
    CaelumRacialAbilityEffect RacialAbility;
''')
    inject(bridge, 'caelum/actors/CaelumCombatActor.zs', '    CaelumSpellSleepState SpellSleep;')
    sleep = current['caelum/world/CaelumSleepRules.zs'].decode('utf-8-sig').split('// Regla común', 1)[0]
    racial = current['caelum/world/CaelumRacialAbilityRules.zs'].decode('utf-8-sig').split('class CaelumRacialAbilityRules', 1)[0]
    bridge['caelum/ability_rollback_schema.zs'] = (sleep + racial).encode()
    # Appended poses preserve state indices and saved pointers, without new actions.
    for name in ['CaelumBull.zs', 'CaelumGiantRat.zs', 'CaelumFolkloreCharacters.zs']:
        path = 'caelum/actors/' + name
        old = baseline[path].decode('utf-8-sig').replace('\r\n', '\n')
        new = current[path].decode('utf-8-sig').replace('\r\n', '\n')
        stripped = re.sub(r'    // Añadido al final para conservar los índices de estados guardados\.\n', '', new)
        stripped = re.sub(r'    RestLying:\n        SL\w{2} A -1;\n        Stop;\n', '', stripped)
        assert stripped == old, 'Only appended living poses are permitted: ' + path
        bridge[path] = current[path]
    path = 'caelum/equipment/CaelumUnarmedWeapon.zs'
    old = baseline[path].decode('utf-8-sig')
    end = old.rfind('    }')
    bridge[path] = (old[:end] + '''    User1:
        TNT1 A 0;
        TNT1 A 1;
        Goto Ready;
    User4:
        TNT1 A 0;
        TNT1 A 1;
        Goto Ready;
''' + old[end:]).encode()
    bridge['caelum/character/CaelumClassCastHandFrames.zs'] = current['caelum/character/CaelumClassCastHandFrames.zs']
    bridge['ZSCRIPT'] += b'\n#include "caelum/ability_rollback_schema.zs"\n#include "caelum/character/CaelumClassCastHandFrames.zs"\n'
    # Art and texture declarations support existing saved poses; no balance/UI changes.
    for name, value in current.items():
        if name.startswith(('graphics/caelum/class_cast', 'graphics/caelum/sleep_creatures')):
            bridge[name] = value
    old_textures = baseline['TEXTURES'].decode('utf-8-sig').replace('\r\n', '\n')
    new_textures = current['TEXTURES'].decode('utf-8-sig').replace('\r\n', '\n')
    assert new_textures.startswith(old_textures)
    bridge['TEXTURES'] = current['TEXTURES']
    # Include every new asset referenced by the appended living-pose states.
    for name, value in current.items():
        if name.startswith('sprites/') and name not in baseline:
            bridge[name] = value
    changes = [n for n in bridge if bridge[n] != baseline.get(n)]
    scripts = {
        'paid-seed': 'wait 100; netevent c238_paid_setup; wait 100; +user4; wait 75; -user4; netevent c238_paid_seed; save paid.zds; netevent c238_rollback_done; wait 2; quit',
        'cooldown-seed': 'wait 100; netevent c238_paid_setup; wait 100; +user4; wait 125; -user4; netevent c238_cooldown_seed; save cooldown.zds; netevent c238_rollback_done; wait 2; quit',
        'bridge-paid': 'wait 100; netevent c238_bridge_check; wait 5; save bridged-paid.zds; wait 35; netevent c238_rollback_done; wait 5; quit',
        'bridge-cooldown': 'wait 100; netevent c238_bridge_check; wait 5; save bridged-cooldown.zds; wait 35; netevent c238_rollback_done; wait 5; quit',
        'repeat': 'wait 20; netevent c238_resume_check; wait 5; save repeated.zds; wait 35; netevent c238_rollback_done; wait 5; quit',
        'resume': 'wait 2; netevent c238_resume_check; wait 80; netevent c238_resume_final; netevent c238_rollback_done; wait 2; quit',
        'cooldown': 'wait 100; netevent c238_cooldown_check; netevent c238_rollback_done; wait 5; quit',
    }
    manifests = {}
    for mode, out in outputs.items():
        out.mkdir()
        runtime = current if mode == 'current' else bridge
        entries = {'paid.zs': (HERE / 'paid_rollback.zs').read_bytes()}
        include = 'version "4.14"\n#include "paid.zs"\n'
        handler = 'CA238PaidRollback'
        if mode == 'current':
            entries['current.zs'] = (HERE / 'paid_rollback_current.zs').read_bytes()
            include += '#include "current.zs"\n'
            handler += 'Current'
        entries['ZSCRIPT'] = include.encode()
        entries['MAPINFO'] = ('GameInfo { AddEventHandlers="' + handler + '" }\n').encode()
        manifest = {
            'baseline_commit': subprocess.check_output(['git', 'rev-parse', BASE], cwd=ROOT, text=True).strip(),
            'current_commit': subprocess.check_output(['git', 'rev-parse', CURRENT], cwd=ROOT, text=True).strip(),
            'mode': mode,
            'runtime_sha256': shared.package(out / 'production.pk3', runtime),
            'fixture_sha256': shared.package(out / 'paid.pk3', entries),
            'bridge_changed_members': sorted(changes) if mode == 'bridge' else [],
        }
        for name, script in scripts.items():
            (out / (name + '.cfg')).write_text(script + '\n', encoding='utf-8')
        (out / 'manifest.json').write_text(json.dumps(manifest, indent=2) + '\n', encoding='utf-8')
        manifests[mode] = {k: v for k, v in manifest.items() if k != 'bridge_changed_members'}
    print(json.dumps(manifests, indent=2))


if __name__ == '__main__':
    main()
