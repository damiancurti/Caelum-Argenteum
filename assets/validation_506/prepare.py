"""Prepare deterministic #128 packages and isolated observation addons."""
from pathlib import Path
import argparse
import hashlib
import json
import subprocess
import zipfile

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent
OUT = ROOT / 'build/issue128'
BASE = '0e2b9eab9e93096993f04beab5d5ef94d69ca0e3'
EXPERIMENT = '031c8877636a7dfd50fefb7fcf117f956b25d886'
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--baseline', action='store_true')
args = parser.parse_args()
processes=subprocess.run(['tasklist','/FI','IMAGENAME eq gzdoom.exe','/NH'],capture_output=True,text=True,check=True).stdout
if 'gzdoom.exe' in processes.lower():raise SystemExit('Stop the native run before replacing diagnostic packages.')
OUT.mkdir(exist_ok=True)

def package(name, members):
    path = OUT / name
    with zipfile.ZipFile(path, 'w', zipfile.ZIP_STORED) as z:
        for key, data in sorted(members.items()):
            z.writestr(zipfile.ZipInfo(key, (2000, 1, 1, 0, 0, 0)), data)
    return hashlib.sha256(path.read_bytes()).hexdigest()

if args.baseline:
    subprocess.run(['git', 'archive', '--format=zip', '--output', str(OUT/'source.zip'), BASE, 'src'], check=True, cwd=ROOT)
    with zipfile.ZipFile(OUT/'source.zip') as z:
        baseline = {n.removeprefix('src/'): z.read(n) for n in z.namelist() if not n.endswith('/')}
    package('baseline.pk3', baseline)

production = {p.relative_to(ROOT/'src').as_posix():p.read_bytes() for p in (ROOT/'src').rglob('*') if p.is_file()}
subprocess.run(['git','archive','--format=zip','--output',str(OUT/'experiment-source.zip'),EXPERIMENT,'src'],check=True,cwd=ROOT)
with zipfile.ZipFile(OUT/'experiment-source.zip') as z:
    current={n.removeprefix('src/'):z.read(n) for n in z.namelist() if not n.endswith('/')}
port = 'caelum/world/CaelumPortSiege.zs'
text = current[port].decode('utf-8-sig').replace('\r\n', '\n')
variants = {'current': text}
# Separate factors: identical native combat and full population in all variants.
variants['no-candidates'] = text.replace('if(CandidatesValid && CandidateTic==level.time)return;', '// Rebuild the same candidate list per leader for the isolated control.')
variants['no-stagger'] = text.replace('            ScheduleGroupTargets();', '').replace('-(level.time%interval-leader.CommandGroup%interval+interval)%interval;', ';')
variants['neither'] = variants['no-stagger'].replace('if(CandidatesValid && CandidateTic==level.time)return;', '// No cross-leader candidate reuse in this control.')
# Reproduce #121's approved combined combat algorithm with the same population
# service and observation overhead, so a follow-up gain is measured directly.
legacy=text.replace('            ScheduleGroupTargets();','')
start=legacy.index('    Actor AttackerTarget(CaelumSiegeCombatant entry)')
end=legacy.index('    Actor IndividualAttackerTarget',start)
legacy=legacy[:start]+'''    Actor AttackerTarget(CaelumSiegeCombatant entry)
    {
        if(!HighDensity)return IndividualAttackerTarget(entry);
        let leader=entry.CommandLeader;
        if(leader==null || !ActiveEntry(leader))leader=entry;
        if(!leader.SharedTargetValid || leader.SharedTargetTic!=level.time)
        {
            leader.SharedTarget=IndividualAttackerTarget(leader);
            leader.SharedTargetTic=level.time;leader.SharedTargetValid=true;
        }
        return leader.SharedTarget;
    }

'''+legacy[end:]
variants['legacy-shared']=legacy
# Exact-priority alternative: skip expensive sight for normal visible actors
# that cannot beat the current nearest/crew winner. Preserve native sight RNG
# consumption for invisible or special-style candidates.
needle='''            if(!gun.EligibleTarget(candidate) || gun.Barrel==null || !gun.Barrel.CheckSight(candidate))continue;
            double distance=(candidate.Pos-gun.Pos).Length();'''
replacement='''            if(!gun.EligibleTarget(candidate) || gun.Barrel==null)continue;
            double distance=(candidate.Pos-gun.Pos).Length();
            bool competitive=chosen==null || (crew && !chosenCrew) || (crew==chosenCrew && distance<best);
            bool plain=candidate.GetRenderStyle()==STYLE_Normal && candidate.Alpha>0
                && !candidate.bInvisible && !candidate.bMInvisible;
            if(HighDensity && !competitive && plain)continue;
            if(!gun.Barrel.CheckSight(candidate))continue;'''
assert variants['no-stagger'].count(needle)==1
variants['pruned-cannon']=variants['no-stagger'].replace(needle,replacement)
manifest = {'baseline_commit': BASE, 'experiment_commit':EXPERIMENT, 'variants': {}}
for name, source in variants.items():
    members = dict(current)
    members[port] = source.encode('utf-8')
    manifest['variants'][name] = package(name+'.pk3', members)
manifest['production_sha256']=package('production.pk3',production)
observer = (ROOT/'assets/validation_505/observer.zs').read_bytes()
addon = {'ZSCRIPT': b'version "4.14"\n#include "observer.zs"\n#include "input_probe.zs"\n',
         'MAPINFO': b'GameInfo { AddEventHandlers = "CA121Profiler", "CA121Observer", "CA116InputProbe" }\n',
         'observer.zs': observer,
         'input_probe.zs': (ROOT/'assets/validation_500/input_probe.zs').read_bytes()}
manifest['observer_sha256'] = package('observer.pk3', addon)
for name in ['long.cfg', 'matched.cfg']:
    (OUT/name).write_bytes((HERE/name).read_bytes())
(OUT/'smoke.cfg').write_text('wait 70; quit\n', encoding='utf-8')
(OUT/'MANIFEST.json').write_text(json.dumps(manifest, indent=2)+'\n', encoding='utf-8')
print(json.dumps(manifest, indent=2))
