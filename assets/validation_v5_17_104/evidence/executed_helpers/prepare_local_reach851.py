"""Prototype the existing conservative reach bound in dense local queries."""
from pathlib import Path
import argparse,hashlib,json,zipfile
ROOT=Path('C:/GZDooMProjects/CaelumArgenteum/build/v517/work-713')
p=argparse.ArgumentParser(description=__doc__);p.add_argument('--runtime',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args()
out=a.output.resolve();out.relative_to(ROOT/'build');out.mkdir(exist_ok=False);path='caelum/actors/CaelumVisualPerception.zs'
with zipfile.ZipFile(a.runtime) as z:original=z.read(path)
nl='\r\n' if b'\r\n' in original else '\n';source=original.decode('utf-8').replace('\r\n','\n')
anchor='        let local=BlockThingsIterator.Create(observer,QueryRadius(observer));'
insert='''        // #851: la cota compartida también descarta vecinos locales invisibles.
        // Las relaciones con migración conservan su consulta antes del descarte.
        let localPopulation=CaelumPopulationState.Get();
        double localSightUpper=localPopulation!=null && localPopulation.HighDensity && level.GetPortalGroupCount()==1
            ? CaelumPhysicsUnits.MapUnits(CaelumPerceptionData.VISUAL_BASE_METERS)*InsightFactor(observer) : -1;
        bool readOnlyLocalRelation=!(observer is "CaelumAnchoredResident")
            && !(observer is "CaelumSummonedZupay")
            && !(observer is "CaelumTarotAutomaton") && !(observer is "CaelumTarotClone");
'''
before='''            let candidate=local.thing;
            if(!Opponent(observer,candidate))'''
after='''            let candidate=local.thing;
            if(readOnlyLocalRelation && localSightUpper>=0 && candidate!=null && OutsideGroupReach(observer,candidate,localSightUpper))continue;
            bool localOpponent=Opponent(observer,candidate);
            if(!readOnlyLocalRelation && localSightUpper>=0 && candidate!=null && OutsideGroupReach(observer,candidate,localSightUpper))continue;
            if(!localOpponent)'''
assert source.count(anchor)==1 and source.count(before)==1
candidate=source.replace(anchor,insert+anchor).replace(before,after)
assert candidate.replace(after,before).replace(insert,'')==source
data=candidate.replace('\n',nl).encode('utf-8')
with zipfile.ZipFile(out/'prototype.pk3','w') as z:z.writestr(zipfile.ZipInfo(path,(2026,11,19,0,0,0)),data)
target=out/'source'/path;target.parent.mkdir(parents=True);target.write_bytes(data)
sha=lambda b:hashlib.sha256(b).hexdigest()
manifest=dict(issue=851,runtime_sha256=sha(a.runtime.read_bytes()),baseline_source_sha256=sha(original),candidate_source_sha256=sha(data),overlay_sha256=sha((out/'prototype.pk3').read_bytes()),inverse_exact=True,no_new_fields_or_gameplay_data=True,qualification='Prototype only. Local iterator order, group and unlinked-guard paths remain intact. Reuses the exact existing bound only with the shared HighDensity flag and one portal group. Read-only relationship paths may reject before Opponent; residents/summoned/automaton/clone observers retain Opponent first. Communication eligibility is read-only. Skipped bodies cannot pass the original contact or sight range tests; derived keyed insight/stealth cache warming may occur at a different point.')
(out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf-8',newline='\n');print(json.dumps(dict(output=str(out),sha256=manifest['overlay_sha256'])))
