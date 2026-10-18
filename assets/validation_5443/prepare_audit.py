"""Instrument cached reads in a separate private runtime, never the FPS package."""
from pathlib import Path
import argparse
import hashlib
import importlib.util
import json
import zipfile

HERE=Path(__file__).parent
spec=importlib.util.spec_from_file_location('cache_preparation',HERE/'prepare.py')
prepare=importlib.util.module_from_spec(spec);spec.loader.exec_module(prepare)
ROOT=prepare.ROOT

def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--directory',required=True)
    p.add_argument('--runtime',type=Path,required=True)
    p.add_argument('--seed',type=Path,required=True)
    p.add_argument('--issue',type=int,default=353)
    p.add_argument('--release',default='5.4.43')
    a=p.parse_args();out=ROOT/'build'/a.directory;out.mkdir(exist_ok=False)
    with zipfile.ZipFile(a.runtime) as archive:members={n:archive.read(n) for n in archive.namelist()}
    cache=members['caelum/actors/CaelumActorMaintenance.zs'].decode()
    cache=cache.replace('    const REVISION=1;','    const REVISION=1;\n    int AuditReads[3],AuditFailures;')
    for method,next_method,raw,outputs in [
        ('RestoreHealth','OffenseChanged','CalculateCombatHealthEffects',
         ['CombatHealthState','CombatHealthPerformanceMultiplier','CombatHealthPainMultiplier','CombatAdrenalineGainMultiplier','EffectiveCombatEvasionChance','Speed']),
        ('RestoreOffense','WeightChanged','CalculateActorOffensiveStatistics',
         ['CombatEffectiveDexterity','CombatEffectiveInsight','CombatEffectiveIntelligence','CombatPhysicalAccuracyPercent','CombatMagicalAccuracyPercent','CombatPhysicalCriticalChancePercent','CombatMagicalCriticalChancePercent','CombatPhysicalPushMultiplier','CombatMagicalPushMultiplier'])]:
        start=cache.index('    void '+method);end=cache.index('    bool '+next_method,start)
        chunk=cache[start:end];pos=chunk.rindex('    }')
        array='HealthOutputs' if method=='RestoreHealth' else 'OffenseOutputs'
        key=0 if method=='RestoreHealth' else 1
        condition=' || '.join(f'body.{name}!={array}[{i}]' for i,name in enumerate(outputs))
        chunk=chunk[:pos]+f'        body.{raw}();\n        AuditReads[{key}]++;if({condition}){{AuditFailures++;Console.Printf("CA282 FAIL cached read key={key} tic=%d",level.time);}}\n'+chunk[pos:]
        cache=cache[:start]+chunk+cache[end:]
    members['caelum/actors/CaelumActorMaintenance.zs']=cache.encode()
    actor=members['caelum/actors/CaelumCombatActor.zs'].decode()
    needle='        return cache.Weight;';assert actor.count(needle)==1
    actor=actor.replace(needle,'        cache.AuditReads[2]++;if(cache.Weight!=CalculateAttackCarriedWeight()){cache.AuditFailures++;Console.Printf("CA282 FAIL cached weight tic=%d",level.time);}\n'+needle)
    members['caelum/actors/CaelumCombatActor.zs']=actor.encode()
    observer=(HERE/'performance.zs').read_text(encoding='utf-8')
    observer=observer.replace('        Finished=true;Census("end");','''        int reads[3];int failures=0;
        for(int i=0;i<Bodies.Size();i++)
        {
            let body=Bodies[i];if(body==null || body.Maintenance==null)continue;
            for(int k=0;k<3;k++)reads[k]+=body.Maintenance.AuditReads[k];
            failures+=body.Maintenance.AuditFailures;
        }
        Console.Printf("CACHE AUDIT health=%d offense=%d weight=%d failures=%d",reads[0],reads[1],reads[2],failures);
        Finished=true;Census("end");''')
    hashes={'baseline.pk3':prepare.prior.base.package(out/'baseline.pk3',members)}
    for site,name in [(0,'city.pk3'),(1,'front/city.pk3')]:
        (out/name).parent.mkdir(exist_ok=True)
        hashes[name]=prepare.prior.base.package(out/name,{'ZSCRIPT':b'version "4.14"\n#include "probe.zs"\n',
            'probe.zs':observer.replace('const SITE=0;',f'const SITE={site};').encode(),
            'MAPINFO':b'GameInfo { AddEventHandlers="CA353Performance" }\n'})
    manifest=dict(issue=a.issue,release=a.release,hashes=hashes,audited_input_sha256=hashlib.sha256(a.runtime.read_bytes()).hexdigest(),
        instrumentation='Raw calculation at each cached read; these timings must never be reported as normal-runtime FPS')
    (out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
    (out/'cache-battle.zds').write_bytes(a.seed.read_bytes())
    (out/'measure.cfg').write_text('wait 735; quit\n')
    print(json.dumps(manifest))

if __name__=='__main__':main()
