"""Adapt #121's verified method wrappers to isolated #132 profiling copies."""
from pathlib import Path
import importlib.util
import json
import re
import zipfile
from prepare import ROOT, HERE, OUT, package

spec = importlib.util.spec_from_file_location('audit', ROOT/'assets/validation_500/audit_sources.py')
audit = importlib.util.module_from_spec(spec)
spec.loader.exec_module(audit)
selected = {
    'CaelumCombatActor': {'Tick':0, 'CA121NativeTick':1, 'CollidedWith':2, 'UpdateImpactContactLatch':3,
                         'UpdateCombatHealthEffects':4, 'UpdateActorOffensiveStatistics':5,
                         'PulseResourceRecovery':6, 'ResourceRecoveryActive':7},
    'CaelumPortSiege': {'Pulse':9, 'AttackerTarget':10, 'ElectCommands':11, 'RefreshTargets':13,
                       'RefillCrews':14, 'OrderGuns':15, 'CannonTarget':16, 'WalkTo':17, 'Tick':18},
    'CaelumHostileMachine': {'ObserveGuards':20}, 'CaelumCannon': {'Tick':21},
    'CaelumCannonProjectile': {'Tick':22}, 'CaelumPlayer': {'Tick':23},
    'CaelumElementalStatus': {'Tick':24}, 'CaelumActorProjectile': {'Tick':27},
    'CaelumActorSimpleElementalProjectile': {'Tick':28},
    'CaelumSiegeReinforcements': {'RefreshLiving':29, 'Place':30, 'Tick':31},
    'CaelumThermalRuntime': {'NPCStep':32},
    'CaelumThermalService': {'Advance':33, 'Integrate':35},
    'CaelumThermalEnvironment': {'Sample':34},
}

def instrument(text, manifest):
    edits = []
    for cls in audit.declarations(text):
        for method in cls['methods']:
            name = method['name']
            if name not in selected.get(cls['name'], {}):
                continue
            key = selected[cls['name']][name]
            start, end, signature = method['body_start'], method['body_end'], method['signature']
            header_start = text.rfind(name, 0, start)
            while header_start > 0 and text[header_start-1] not in '\n;{}':
                header_start -= 1
            header = text[header_start:start]
            args = signature[signature.index('(')+1:signature.rindex(')')]
            arg_names = [a.split('=')[0].strip().split()[-1] for a in args.split(',') if a.strip()]
            result = re.sub(r'\b(?:override|virtual|static|action|ui|play|clearscope)\b', '', signature[:signature.index(name)]).strip()
            assert result in ('void', 'bool', 'Actor', 'double'), signature
            inner = 'CA121Body_'+name
            inner_header = re.sub(r'\b(?:override|virtual)\s+', '', header).replace(name+'(', inner+'(').replace(name+' (', inner+' (')
            prefix = '' if result == 'void' else result+' result = '
            wrapper = (header+'{\n CA121Profiler p; if(level.time%37==0){p=CA121Profiler.Get();p.Begin('+str(key)+');}\n '
                       +prefix+inner+'('+', '.join(arg_names)+');\n if(p!=null)p.End('+str(key)+');\n'
                       +(' return result;\n' if result != 'void' else '')+'}\n')
            edits.append((header_start, end+1, wrapper+inner_header+text[start:end+1]))
            manifest.append({'class':cls['name'], 'method':name, 'category':key, 'signature':signature})
    for start, end, replacement in sorted(edits, reverse=True):
        text = text[:start]+replacement+text[end:]
    return text

manifest = {'scope':'Sample every 37th tic. Exclusive time subtracts instrumented children only; isolated copies, never frame-rate comparisons.', 'packages':{}}
for name in ('baseline', 'production'):
    with zipfile.ZipFile(OUT/(name+'.pk3')) as z:
        members = {n:z.read(n) for n in z.namelist()}
    methods = []
    for path, data in list(members.items()):
        if not path.lower().endswith('.zs'):
            continue
        text = data.decode('utf-8-sig').replace('\r\n', '\n')
        if path.endswith('CaelumCombatActor.zs'):
            cls = next(c for c in audit.declarations(text) if c['name'] == 'CaelumCombatActor')
            method = next(m for m in cls['methods'] if m['name'] == 'Tick')
            start, end = method['body_start'], method['body_end']
            text = text[:start]+text[start:end+1].replace('Super.Tick();', 'CA121NativeTick();')+'\n void CA121NativeTick() { Super.Tick(); }\n'+text[end+1:]
            if name == 'baseline':
                die = next(m for c in audit.declarations(text) if c['name'] == 'CaelumCombatActor'
                           for m in c['methods'] if m['name'] == 'Die')
                i = die['body_start']+1
                text = text[:i]+'\n CA132DeathAudit.Record(self,MeansOfDeath);\n'+text[i:]
        if any(c['name'] in selected for c in audit.declarations(text)):
            members[path] = instrument(text, methods).encode()
    members['ZSCRIPT'] += b'\n#include "ca132_profile.zs"\n'
    source = (ROOT/'assets/validation_505/observer.zs').read_text(encoding='utf-8')
    members['ca132_profile.zs'] = source[:source.index('class CA121Observer')].encode()
    members['MAPINFO'] += b'\nGameInfo { AddEventHandlers="CA121Profiler" }\n'
    if name == 'baseline':
        members['ZSCRIPT'] += b'\n#include "ca132_deaths.zs"\n'
        members['ca132_deaths.zs'] = (HERE/'deaths.zs').read_bytes()
        members['MAPINFO'] += b'\nGameInfo { AddEventHandlers="CA132DeathAudit" }\n'
    manifest['packages'][name] = {'sha256':package('profile-'+name+'.pk3', members), 'methods':methods}
    folder = OUT/'profile'
    folder.mkdir(exist_ok=True)
    (folder/(name+'.pk3')).write_bytes((OUT/('profile-'+name+'.pk3')).read_bytes())
for config in ('profile.cfg', 'profile-late.cfg', 'profile-deaths.cfg', 'natural-final.cfg'):
    (OUT/config).write_bytes((HERE/config).read_bytes())
(HERE/'PROFILE_MANIFEST.json').write_text(json.dumps(manifest, indent=2)+'\n', encoding='utf-8')
print('Prepared two separate instrumented copies; production source unchanged.')
