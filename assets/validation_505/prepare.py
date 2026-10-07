"""Build isolated #121 observers and instrumented copies, never modify src/."""
import argparse
import hashlib
import importlib.util
import json
from pathlib import Path
import re
import shutil
import subprocess
import zipfile
from runtime_identity import tree_hash

ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).resolve().parent
parser=argparse.ArgumentParser(description=__doc__)
parser.add_argument('--packages',nargs='+',help='Regenerate only named packages; never select a package used by a running engine.')
parser.add_argument('--from-git',action='store_true',help='Rebuild the accepted runtime from the pinned Git commit; ZIP metadata/text line endings may differ.')
parser.add_argument('--baseline',type=Path,help='An existing accepted 5.0.4 runtime package, verified by canonical content.')
parser.add_argument('--output',type=Path,default=ROOT/'build/issue121')
args=parser.parse_args()
OUT=args.output.resolve();OUT.mkdir(parents=True,exist_ok=True)
if not args.packages:
    process_list=subprocess.run(['tasklist','/FI','IMAGENAME eq gzdoom.exe','/NH'],capture_output=True,text=True,check=True).stdout
    if 'gzdoom.exe' in process_list.lower():raise SystemExit('Stop the diagnostic engine before regenerating packages.')
spec=importlib.util.spec_from_file_location('audit',ROOT/'assets/validation_500/audit_sources.py')
audit=importlib.util.module_from_spec(spec);spec.loader.exec_module(audit)
identity=json.loads((HERE/'BASELINE_IDENTITY.json').read_text())
SOURCE=args.baseline or ROOT/'build/issue120/current.pk3'
from_git=args.from_git or not SOURCE.exists()
if from_git:
    SOURCE=OUT/'reference-source.zip'
    subprocess.run(['git','archive','--format=zip','--output',str(SOURCE),identity['source_commit'],'src'],cwd=ROOT,check=True)
with zipfile.ZipFile(SOURCE) as z:
    baseline_members={(n.removeprefix('src/') if from_git else n):z.read(n) for n in z.namelist() if not n.endswith('/')}
assert tree_hash(baseline_members,canonical=True)==identity['canonical_runtime_tree_sha256'],'The runtime does not match the accepted baseline.'
EXPECTED=identity['accepted_archive_sha256']

def package(path,members):
    if args.packages and path.name not in args.packages:return
    with zipfile.ZipFile(path,'w',zipfile.ZIP_STORED) as z:
        for name,data in sorted(members.items()):
            info=zipfile.ZipInfo(name,(2000,1,1,0,0,0));info.compress_type=zipfile.ZIP_STORED
            z.writestr(info,data)

if from_git:package(OUT/'baseline.pk3',baseline_members)
elif not args.packages or 'baseline.pk3' in args.packages:
    if not (OUT/'baseline.pk3').exists() or (OUT/'baseline.pk3').read_bytes()!=SOURCE.read_bytes():
        shutil.copyfile(SOURCE,OUT/'baseline.pk3')

addon={'ZSCRIPT':b'version "4.14"\n#include "observer.zs"\n#include "input_probe.zs"\n',
       'MAPINFO':b'GameInfo { AddEventHandlers = "CA121Profiler", "CA121Observer", "CA116InputProbe" }\n',
       'observer.zs':(HERE/'observer.zs').read_bytes(),
       'input_probe.zs':(ROOT/'assets/validation_500/input_probe.zs').read_bytes()}
package(OUT/'observer.pk3',addon)
members=dict(baseline_members)

# Categories are nested: exclusive time subtracts instrumented children only.
selected={
 'CaelumCombatActor': {'Tick':0,'CA121NativeTick':1,'CollidedWith':2,'UpdateImpactContactLatch':3,
   'UpdateCombatHealthEffects':4,'UpdateActorOffensiveStatistics':5,'PulseResourceRecovery':6,
   'ResourceRecoveryActive':7,'UpdateCaelumRecognitionSound':8},
 'CaelumPortSiege': {'Pulse':9,'AttackerTarget':10,'ElectCommands':11,'RefreshTargets':13,
   'RefillCrews':14,'OrderGuns':15,'CannonTarget':16,'WalkTo':17,'Tick':18,'Calendar':19},
 'CaelumHostileMachine': {'ObserveGuards':20},
 'CaelumCannon': {'Tick':21},
 'CaelumCannonProjectile': {'Tick':22},
 'CaelumPlayer': {'Tick':23},
 'CaelumElementalStatus': {'Tick':24},
 'CaelumActorProjectile': {'Tick':27},
 'CaelumActorSimpleElementalProjectile': {'Tick':28},
}
manifest=[]

def instrument(text):
    edits=[]
    for cls in audit.declarations(text):
        for method in cls['methods']:
            if method['name'] not in selected.get(cls['name'],{}):continue
            key=selected[cls['name']][method['name']]
            start,end=method['body_start'],method['body_end']
            signature=method['signature']
            name=method['name']
            match=re.search(r'\b'+name+r'\s*\(',text[:start][max(0,start-1500):])
            # The declaration signature is normalized by the lexical inventory.
            header_start=text.rfind(name,0,start)
            while header_start>0 and text[header_start-1] not in '\n;{}':header_start-=1
            raw_header=text[header_start:start]
            args=signature[signature.index('(')+1:signature.rindex(')')]
            arg_names=[]
            for arg in args.split(','):
                if arg.strip():arg_names.append(arg.split('=')[0].strip().split()[-1])
            result_type=re.sub(r'\b(?:override|virtual|static|action|ui|play|clearscope)\b','',signature[:signature.index(name)]).strip()
            if result_type not in ['void','bool','Actor']:raise ValueError(signature)
            inner='CA121Body_'+name
            body_header=re.sub(r'\b(?:override|virtual)\s+','',raw_header).replace(name+'(',inner+'(').replace(name+' (',inner+' (')
            prefix='' if result_type=='void' else result_type+' result = '
            wrapper=raw_header+'{\n CA121Profiler p; if(level.time%37==0){p=CA121Profiler.Get();p.Begin('+str(key)+');}\n '+prefix+inner+'('+', '.join(arg_names)+');\n if(p!=null)p.End('+str(key)+');\n'+(' return result;\n' if result_type!='void' else '')+'}\n'
            edits.append((header_start,end+1,wrapper+body_header+text[start:end+1]))
            manifest.append({'class':cls['name'],'method':name,'category':key,'signature':signature})
    for start,end,replacement in sorted(edits,reverse=True):text=text[:start]+replacement+text[end:]
    return text

for path,data in list(members.items()):
    if not path.lower().endswith('.zs'):continue
    text=data.decode('utf-8-sig').replace('\r\n','\n')
    if path.endswith('CaelumCombatActor.zs'):
        # This helper retains the native parent dispatch and separates it from script Tick work.
        cls=next(c for c in audit.declarations(text) if c['name']=='CaelumCombatActor')
        method=next(m for m in cls['methods'] if m['name']=='Tick')
        start,end=method['body_start'],method['body_end']
        text=text[:start]+text[start:end+1].replace('Super.Tick();','CA121NativeTick();')+'\n void CA121NativeTick() { Super.Tick(); }\n'+text[end+1:]
    if path.endswith('CaelumPortSiege.zs'):
        text=re.sub(r'(\w+(?:\.\w+)*)\.CheckSight\((\w+)\)',r'CA121Profiler.LOS(\1,\2)',text)
        # Both defender loops visit all entries; count once, not once per candidate.
        text=text.replace('for(int i=0;i<Defenders.Size();i++)','CA121Profiler.Candidate(Defenders.Size());for(int i=0;i<Defenders.Size();i++)')
        text=text.replace('while(queue.Size()<CaelumPortData.COMMAND_GROUP_LIMIT && neighbors.Next())\n                {','while(queue.Size()<CaelumPortData.COMMAND_GROUP_LIMIT && neighbors.Next())\n                { CA121Profiler.Candidate();')
        text=re.sub(r'body\.A_Chase\([^;]*\);',lambda m:'{ CA121Profiler cp; if(level.time%37==0){cp=CA121Profiler.Get();cp.Begin(25);} '+m.group()+' if(cp!=null)cp.End(25); }',text)
    if any(c['name'] in selected for c in audit.declarations(text)):
        members[path]=instrument(text).encode('utf-8')
# Include observer before gameplay; ZScript resolves class references across includes.
zscript=next(n for n in members if n.upper()=='ZSCRIPT')
members[zscript]+=b'\n#include "ca121_profiler.zs"\n'
members['ca121_profiler.zs']=addon['observer.zs']
package(OUT/'instrumented.pk3',members)
instrument_addon=dict(addon);instrument_addon['ZSCRIPT']=b'version "4.14"\n#include "input_probe.zs"\n'
package(OUT/'instrument-observer.pk3',instrument_addon)
# Capture every sparse controller call, including bursts the 37-tic sampler misses.
event_members=dict(members)
event_port=next(n for n in members if n.endswith('CaelumPortSiege.zs'))
event_text=event_members[event_port].decode('utf-8')
for method,key,arguments,result in [('ElectCommands',11,'',''),('RefreshTargets',13,'',''),('RefillCrews',14,'',''),('CannonTarget',16,'gun','Actor result = ')]:
    needle=' '+result+'CA121Body_'+method+'('+arguments+');\n'
    assert event_text.count(needle)==1,(method,event_text.count(needle))
    event_text=event_text.replace(needle,' double ca121RareStart=MSTimeF();\n'+needle+' Console.Printf("CA121 RARE tic=%d id='+str(key)+' ms=%.6f",level.time,MSTimeF()-ca121RareStart);\n')
event_members[event_port]=event_text.encode()
package(OUT/'eventprobe.pk3',event_members)
# Single-factor diagnostic: share a command leader's perception for one tic.
# Followers still execute native chase, collision, attacks and all resource Ticks.
shared=dict(members)
encounter=next(n for n in shared if n.endswith('CaelumSiegeEncounter.zs'))
text=shared[encounter].decode('utf-8')
start=text.index('{',text.index('class CaelumSiegeCombatant '))
shared[encounter]=(text[:start+1]+'\n int CA121TargetTic; bool CA121TargetValid; Actor CA121SharedTarget;\n'+text[start+1:]).encode()
port=next(n for n in shared if n.endswith('CaelumPortSiege.zs'))
text=shared[port].decode('utf-8')
needle='Actor CA121Body_AttackerTarget(CaelumSiegeCombatant entry)'
assert needle in text
replacement='''Actor CA121Body_AttackerTarget(CaelumSiegeCombatant entry)
    {
        let leader=entry.CommandLeader;
        if(leader==null || !ActiveEntry(leader))leader=entry;
        if(!leader.CA121TargetValid || leader.CA121TargetTic!=level.time)
        {
            leader.CA121SharedTarget=CA121OriginalTarget(leader);
            leader.CA121TargetTic=level.time;leader.CA121TargetValid=true;
        }
        return leader.CA121SharedTarget;
    }
    Actor CA121OriginalTarget(CaelumSiegeCombatant entry)'''
shared[port]=text.replace(needle,replacement).encode()
package(OUT/'shared-target.pk3',shared)
formation_members=dict(members)
combat=next(n for n in members if n.endswith('CaelumCombatActor.zs'))
text=formation_members[combat].decode('utf-8')
start=text.index('{',text.index('class CaelumCombatActor '))
formation_members[combat]=(text[:start+1]+'\n bool CA121FormationActive;\n'+text[start+1:]).encode()
port=next(n for n in members if n.endswith('CaelumPortSiege.zs'))
text=formation_members[port].decode('utf-8')
needle='static bool CA121Body_Pulse(CaelumCombatActor body)\n    {'
assert needle in text
formation_members[port]=text.replace(needle,needle+'\n if(body.CA121FormationActive)return true;').encode()
folklore=next(n for n in members if n.endswith('CaelumFolkloreCharacters.zs'))
text=formation_members[folklore].decode('utf-8').replace('\r\n','\n')
start=text.index('class CaelumMandinga ')
end=text.index('class ',start+6)
chunk=text[start:end]
marker='    Spawn:\n'
assert marker in chunk
chunk=chunk.replace(marker,'    CA121Formation:\n        MIRN ABCD 4;\n        Loop;\n'+marker,1)
formation_members[folklore]=(text[:start]+chunk+text[end:]).encode()
formation_members['ca121_formation.zs']=(HERE/'formation.zs').read_bytes()
formation_members[zscript]+=b'\n#include "ca121_formation.zs"\n'
package(OUT/'formation.pk3',formation_members)
formation_addon=dict(instrument_addon)
formation_addon['CVARINFO']=b'server int ca121_group_size = 100;\n'
formation_addon['MAPINFO']=b'GameInfo { AddEventHandlers = "CA121Profiler", "CA121Formation", "CA121Observer", "CA116InputProbe" }\n'
package(OUT/'formation-observer.pk3',formation_addon)

def cannon_retry(source):
    """Diagnostic negative-query cache; acquisition can be delayed by seven tics."""
    result=dict(source)
    cannon=next(n for n in result if n.endswith('CaelumCannon.zs'))
    text=result[cannon].decode('utf-8')
    start=text.index('{',text.index('class CaelumCannon :'))
    result[cannon]=(text[:start+1]+'\n int CA121NextTargetQuery;\n'+text[start+1:]).encode()
    text=result[port].decode('utf-8')
    needle='gun.CancelShot();let victim=CannonTarget(gun);if(victim==null)continue;'
    assert text.count(needle)==1
    text=text.replace(needle,'''if(level.time<gun.CA121NextTargetQuery)continue;
            gun.CancelShot();let victim=CannonTarget(gun);
            if(victim==null){gun.CA121NextTargetQuery=level.time+CaelumPortData.TARGET_UPDATE_TICS;continue;}
            gun.CA121NextTargetQuery=0;''')
    result[port]=text.encode()
    return result

def spatial_guards(source,verify=False):
    """Keep the exact 3D predicate and remembered history after a native broad phase."""
    result=dict(source)
    text=result[encounter].decode('utf-8')
    needle='''for (int i = 0; i < Encounter.Attackers.Size(); i++)
        {
            let entry = Encounter.Attackers[i];
            if (!IsNearby(entry)) continue;
            RememberGuard(entry);
        }'''
    assert text.count(needle)==1
    replacement='''let nearby=BlockThingsIterator.Create(self,GuardRadius);
        while(nearby.Next())
        {
            let body=CaelumCombatActor(nearby.thing);
            if(body==null || body.SiegeCombatant==null)continue;
            let entry=body.SiegeCombatant;
            if(entry.Encounter!=Encounter || !IsNearby(entry))continue;
            RememberGuard(entry);
            VERIFY_STAMP
        }
        VERIFY_SCAN'''
    if verify:
        start=text.index('{',text.index('class CaelumSiegeCombatant '))
        text=text[:start+1]+'\n int CA121GuardStamp;\n'+text[start+1:]
        replacement=replacement.replace('VERIFY_STAMP','entry.CA121GuardStamp=level.time*64+RegistryIndex+1;')
        replacement=replacement.replace('VERIFY_SCAN','''int expected=0;
        for(int i=0;i<Encounter.Attackers.Size();i++)
        {
            let entry=Encounter.Attackers[i];if(!IsNearby(entry))continue;
            expected++;
            if(entry.CA121GuardStamp!=level.time*64+RegistryIndex+1)
                Console.Printf("CA121 GUARD_MISMATCH tic=%d machine=%d actor=%d",level.time,RegistryIndex,i);
        }
        if(level.time%35==0)Console.Printf("CA121 GUARD_VERIFIED tic=%d machine=%d expected=%d",level.time,RegistryIndex,expected);''')
    else:replacement=replacement.replace('VERIFY_STAMP','').replace('VERIFY_SCAN','')
    result[encounter]=text.replace(needle,replacement).encode()
    return result

package(OUT/'cannon-retry.pk3',cannon_retry(members))
package(OUT/'formation-retry.pk3',cannon_retry(formation_members))
package(OUT/'spatial-guards.pk3',spatial_guards(members))
package(OUT/'guard-check.pk3',spatial_guards(members,verify=True))
package(OUT/'shared-guards.pk3',spatial_guards(shared))
package(OUT/'combined.pk3',cannon_retry(spatial_guards(shared)))
package(OUT/'formation-all.pk3',cannon_retry(spatial_guards(formation_members)))
(HERE/'categories.json').write_text(json.dumps({'baseline_sha256':EXPECTED,'sample_period':37,'methods':manifest,'additional_categories':{'12':'Port CheckSight native call','25':'Port native A_Chase','26':'Isolated formation controller WorldTick'}},indent=2)+'\n')
(OUT/'long.cfg').write_text('stat; cmdlist *profile*; cmdlist *bench*; stat rendertimes; stat think; wait 350; profilethinkers -t; bench; event ca116_probe; wait 350; profilethinkers -t; bench; wait 1050; profilethinkers -t; bench; event ca116_probe; wait 350; profilethinkers -t; bench; wait 1050; profilethinkers -t; bench; event ca116_probe; wait 350; profilethinkers -t; bench; wait 70; quit\n')
(OUT/'smoke.cfg').write_text('wait 140; profilethinkers -t; bench; wait 70; quit\n')
(OUT/'production.cfg').write_text('stat think; vid_fps 1; wait 1050; quit\n')
(OUT/'matched.cfg').write_text('stat rendertimes; stat think; wait 350; profilethinkers -t; bench; event ca116_probe; wait 350; profilethinkers -t; bench; wait 700; profilethinkers -t; bench; event ca116_probe; wait 350; profilethinkers -t; bench; wait 350; profilethinkers -t; bench; event ca116_probe; save ca121_late; wait 140; quit\n')
(OUT/'gpu-late.cfg').write_text('stat gpu; stat rendertimes; stat sight; vid_fps 1; wait 105; bench; wait 140; quit\n')
(OUT/'gpu-formation.cfg').write_text('ca121_group_size 100; stat gpu; stat rendertimes; vid_fps 1; wait 35; closemenu; wait 665; bench; gl_fxaa 1; echo CA121_FXAA_CONTROL_ENABLED; wait 1050; quit\n')
for size in [1,100]:
    (OUT/f'formation-{size}.cfg').write_text(f'ca121_group_size {size}; stat rendertimes; stat think; wait 35; closemenu; wait 315; profilethinkers -t; bench; event ca116_probe; wait 350; profilethinkers -t; bench; wait 350; profilethinkers -t; bench; event ca116_probe; wait 350; profilethinkers -t; bench; wait 350; quit\n')
print('Prepared',args.packages or 'all diagnostic packages','in',OUT,'; wrapped',len(manifest),'methods')
