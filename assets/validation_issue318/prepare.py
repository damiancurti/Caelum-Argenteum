"""Build isolated MAP06 measurement packages; production sources are read-only."""
from pathlib import Path
import argparse
import hashlib
import importlib.util
import json
import re
import shutil
import sys
import zipfile

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(ROOT / 'assets/validation_5425'))
import prepare_study as previous
audit = previous.audit

METHODS = {
    'CaelumCombatActor': 'Tick NativeTick CollidedWith UpdateImpactContactLatch UpdateCombatHealthEffects UpdateActorOffensiveStatistics ResourceRecoveryActive IsCombatIdle InitializeCombatProfile',
    'CaelumPortDefender': 'Tick AssignHome AdvanceDeployment',
    'CaelumCityCarbine': 'Tick Initialize',
    'CaelumCarbineWorld': 'Apply Restore',
    'CaelumPopulationState': 'Refresh',
    'CaelumPortSiege': 'Tick Deploy AddDemon Calendar ElectCommands RefreshTargets RefillCrews OrderGuns AttackerTarget CannonTarget WalkTo Pulse',
    'CaelumSiegeEncounter': 'RegisterAttacker Tick',
    'CaelumCityWorld': 'Prepare SiegeDue Peaceful',
    'CaelumDemonService': 'UpdateBreath UpdatePotions Initialize StopBreath',
    'CaelumDemonBreath': 'PaidTick Mouth CanReach Contact Burn Visible FlushHeat Tick',
    'CaelumDemonFlameVisual': 'Tick',
    'CaelumElementalStream': 'Transfer Contact ApplyContact ReceivedWatts Visible',
    'CaelumThermalRuntime': 'NPCStep PlayerStep',
    'CaelumThermalService': 'Advance Integrate',
    'CaelumThermalEnvironment': 'Sample SampleWater',
    'CaelumThermalMotion': 'Support Physics Path',
    'CaelumThermalBody': 'Refresh SampleCoverage Get',
    'CaelumThermalShelter': 'Roof WindBlocked',
    'CaelumThermalFire': 'Sample',
    'CaelumSealClimate': 'ApplyThermal',
    'CaelumPlayer': 'Tick SimulatePersonalTic UpdateHudCache',
    'CaelumTimeSkipState': 'Pump',
    'CaelumSlidingDoorBlocker': 'Tick',
    'CaelumSlidingDoorLeaf': 'Tick EnsureBlockers',
    'CaelumHingedDoorLeaf': 'Tick PlaceAtProgress BlockerPosition',
    'CaelumDiningTable': 'Tick',
    'CaelumMansionBed': 'Tick',
    'CaelumCorpseArchive': 'Tick',
    'CaelumCannon': 'Tick',
    'CaelumHostileMachine': 'ObserveGuards',
    'CaelumElementalStatus': 'Tick TickBurnHeat ApplyBurnHeat TakeBurnHeat',
    'CaelumCityInteriorDoors': 'Ensure',
    'CaelumWeightPressure': 'WorldTick Update MassAbove SupportCount',
    'CaelumInteractionHint': 'Find ForActor',
    'CaelumSiegeReinforcements': 'Tick RefreshLiving Place',
}
ALWAYS = {'Deploy', 'AddDemon', 'RegisterAttacker', 'Prepare', 'AssignHome', 'InitializeCombatProfile', 'Pump'}

def package(path, members):
    with zipfile.ZipFile(path, 'w', zipfile.ZIP_STORED) as archive:
        for name, data in sorted(members.items()):
            archive.writestr(zipfile.ZipInfo(name, (2000, 1, 1, 0, 0, 0)), data)
    return hashlib.sha256(path.read_bytes()).hexdigest()

def replace(members, ending, old, new):
    name = next(n for n in members if n.endswith(ending))
    text = members[name].decode('utf-8-sig').replace('\r\n', '\n')
    assert text.count(old) == 1, (ending, old)
    members[name] = text.replace(old, new).encode()

def inject(members, cls, method, code):
    for name in members:
        if not name.endswith('.zs'):
            continue
        text = members[name].decode('utf-8-sig').replace('\r\n', '\n')
        found = [m for c in audit.declarations(text) if c['name'] == cls for m in c['methods'] if m['name'] == method]
        if found:
            assert len(found) == 1
            at = found[0]['body_start'] + 1
            members[name] = (text[:at] + '\n' + code + '\n' + text[at:]).encode()
            return
    raise AssertionError((cls, method))

def profile(members, deep=False):
    manifest = []
    methods = METHODS.copy()
    if deep:
        methods['CaelumThermalFire'] = 'Sample AbsorbedAt'
    for path, data in list(members.items()):
        if not path.endswith('.zs'):
            continue
        text = data.decode('utf-8-sig').replace('\r\n', '\n')
        if path.endswith('/CaelumCombatActor.zs'):
            method = next(m for c in audit.declarations(text) if c['name'] == 'CaelumCombatActor' for m in c['methods'] if m['name'] == 'Tick')
            start, end = method['body_start'], method['body_end']
            text = text[:start] + text[start:end+1].replace('Super.Tick();', 'NativeTick();') + '\n void NativeTick(){Super.Tick();}\n' + text[end+1:]
        edits = []
        for cls in audit.declarations(text):
            for method in cls['methods']:
                name = method['name']
                if name not in methods.get(cls['name'], '').split():
                    continue
                start, end, sig = method['body_start'], method['body_end'], method['signature']
                header_start = text.rfind(name, 0, start)
                while header_start > 0 and text[header_start-1] not in '\n;{}':
                    header_start -= 1
                header = text[header_start:start]
                args = sig[sig.index('(')+1:sig.rindex(')')]
                arg_names = [a.split('=')[0].strip().split()[-1] for a in args.split(',') if a.strip()]
                result = re.sub(r'\b(?:override|virtual|static|action|ui|play|clearscope)\b', '', sig[:sig.index(name)]).strip()
                assert ',' not in result and '[' not in args, sig
                inner = 'CA318Body_' + name
                inner_header = re.sub(r'\b(?:override|virtual)\s+', '', header).replace(name+'(', inner+'(').replace(name+' (', inner+' (')
                prefix = '' if result == 'void' else result+' result = '
                key = len(manifest)
                condition = 'true' if name in ALWAYS else 'level.time%17==0'
                wrapper = (header+'{\n CA318Profiler p; if('+condition+'){p=CA318Profiler.Get();p.Begin('+str(key)+');}\n '+prefix+inner+'('+', '.join(arg_names)+');\n if(p!=null)p.End('+str(key)+');\n'+(' return result;\n' if result != 'void' else '')+'}\n')
                edits.append((header_start, end+1, wrapper+inner_header+text[start:end+1]))
                manifest.append({'id': key, 'class': cls['name'], 'method': name, 'signature': sig, 'always': name in ALWAYS})
        for start, end, replacement in sorted(edits, reverse=True):
            text = text[:start]+replacement+text[end:]
        if edits:
            members[path] = text.encode()
    assert len(manifest) < 256
    return manifest

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--directory', default='issue318-audit-01')
    parser.add_argument('--variants', nargs='+', default=['base', 'profile'])
    parser.add_argument('--source',type=Path,default=ROOT/'src',help='Explicit source tree for a detached baseline checkout')
    args = parser.parse_args()
    out = ROOT / 'build' / args.directory
    out.mkdir(exist_ok=True)
    source_root=args.source.resolve()
    assert (source_root/'ZSCRIPT').is_file(), 'Missing source ZSCRIPT'
    source = {p.relative_to(source_root).as_posix(): p.read_bytes() for p in sorted(source_root.rglob('*')) if p.is_file()}
    for variant in args.variants:
        dest = out / variant
        dest.mkdir(exist_ok=True)
        assert not (dest/'runtime.pk3').exists(), 'Preserve existing runtime: '+str(dest)
        members = source.copy()
        metadata = {'variant': variant, 'scope': 'Isolated measurement only', 'source_members': len(source)}
        mode=variant.removeprefix('army1000-')
        if mode!=variant:
            replace(members, '/CaelumPortData.zs', 'return IsSouth()?6000:MANDINGAS;', 'return MANDINGAS;')
            metadata['population_control']='Author-requested 1000 Mandingas; unchanged 600 soldiers/commander; diagnostic only'
        variant=mode
        if variant == 'thermal-off':
            metadata['changes'] = previous.thermal_off(members)
        elif variant == 'stats-off':
            for method in ('UpdateCombatHealthEffects', 'UpdateActorOffensiveStatistics'):
                inject(members, 'CaelumCombatActor', method, 'if(level.time>140)return;')
        elif variant == 'carbine-off':
            inject(members, 'CaelumCityCarbine', 'Tick', 'if(level.time>140)return;')
        elif variant == 'contacts-off':
            inject(members, 'CaelumCombatActor', 'UpdateImpactContactLatch', 'if(level.time>140)return;')
        elif variant == 'npc-tick-off':
            inject(members, 'CaelumCombatActor', 'Tick', 'if(level.time>140)return;')
        elif variant == 'population-off':
            inject(members, 'CaelumPopulationState', 'Refresh', 'if(level.time>140)return;')
        elif variant == 'blockers-off':
            inject(members, 'CaelumSlidingDoorBlocker', 'Tick', 'if(level.time>140)return;')
        elif variant == 'pressure-off':
            inject(members, 'CaelumWeightPressure', 'WorldTick', 'if(level.time>140)return;')
        elif variant == 'hints-off':
            inject(members, 'CaelumInteractionHint', 'Find', 'return "";')
        elif variant == 'blockers-stationary':
            replace(members, '/CaelumSlidingDoor.zs', 'SetOrigin(leaf.BlockerPosition(args[0]), true);',
                    'vector3 wanted=leaf.BlockerPosition(args[0]);if(wanted!=Pos)SetOrigin(wanted,true);')
        elif variant == 'breath-off':
            inject(members, 'CaelumDemonService', 'UpdateBreath', 'if(level.time>140){StopBreath(npc);return;}')
        elif variant == 'mandinga-breath-off':
            inject(members, 'CaelumDemonService', 'UpdateBreath', 'if(npc is "CaelumMandinga"){StopBreath(npc);return;}')
        elif variant == 'hud-off':
            for path, data in list(members.items()):
                if '/hud/' not in path or not path.endswith('.zs'):
                    continue
                text = data.decode('utf-8-sig')
                for cls in audit.declarations(text):
                    if any(m['name']=='RenderOverlay' for m in cls['methods']):
                        inject(members, cls['name'], 'RenderOverlay', 'return;')
        elif variant in ('profile', 'profile-deep', 'profile-mandinga-off'):
            if variant == 'profile-mandinga-off':
                inject(members, 'CaelumDemonService', 'UpdateBreath', 'if(npc is "CaelumMandinga"){StopBreath(npc);return;}')
            metadata['methods'] = profile(members, deep=variant!='profile')
        elif variant != 'base':
            raise ValueError(variant)
        members['ZSCRIPT']+=b'\n#include "ca318_profiler.zs"\n'
        members['ca318_profiler.zs']=(HERE/'profiler.zs').read_bytes()
        members['MAPINFO']+=b'\nGameInfo { AddEventHandlers="CA318Profiler" }\n'
        metadata['changed_members'] = {n: hashlib.sha256(v).hexdigest() for n, v in members.items() if source.get(n) != v}
        metadata['runtime_sha256'] = package(dest/'runtime.pk3', members)
        fixture = {'ZSCRIPT': b'version "4.14"\n#include "observer.zs"\n',
                   'observer.zs': (HERE/'observer.zs').read_bytes(),
                   'MAPINFO': b'GameInfo { AddEventHandlers="CA318Observer" }\n',
                   'CVARINFO': b'server int ca318_phase=0; server int ca318_site=1; server int ca318_pitch=0; server int ca318_window=350; server int ca318_warmup=140; server bool ca318_freeze=false; server bool ca318_save=false;\n'}
        metadata['fixture_sha256'] = package(dest/'observer.pk3', fixture)
        (dest/'manifest.json').write_text(json.dumps(metadata, indent=2)+'\n', encoding='utf-8')
        print(metadata['variant'], metadata['runtime_sha256'], 'instrumented_methods', len(metadata.get('methods', [])), flush=True)

if __name__ == '__main__':
    main()
