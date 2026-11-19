"""Prototype native null-base sequence behavior without duplicate state lookup."""
from pathlib import Path
import argparse,hashlib,json,zipfile
ROOT=Path('C:/GZDooMProjects/CaelumArgenteum/build/v517/work-713')
p=argparse.ArgumentParser(description=__doc__)
for name in ('runtime','output','native-source'):p.add_argument('--'+name,type=Path,required=True)
a=p.parse_args();out=a.output.resolve();out.relative_to(ROOT/'build');out.mkdir(exist_ok=False)
path='caelum/actors/CaelumDemonService.zs'
with zipfile.ZipFile(a.runtime) as z:original=z.read(path)
nl='\r\n' if b'\r\n' in original else '\n';source=original.decode('utf-8').replace('\r\n','\n');candidate=source;edits=[]
for old in ['npc.FindState("RacialBreath")!=null\n            && ','npc.FindState("Pain")!=null && ']:
    assert candidate.count(old)==1
    before=candidate;candidate=candidate.replace(old,'',1);edits.append(dict(removed=old))
    assert len(before)>len(candidate)
expected=source.replace('npc.FindState("RacialBreath")!=null\n            && ','',1).replace('npc.FindState("Pain")!=null && ','',1)
assert candidate==expected
restored=candidate.replace('if(resume && npc.health>0 && npc.InStateSequence','if(resume && npc.health>0 && npc.FindState("RacialBreath")!=null\n            && npc.InStateSequence',1)
restored=restored.replace('|| (npc.InStateSequence(npc.CurState,npc.FindState("Pain")))','|| (npc.FindState("Pain")!=null && npc.InStateSequence(npc.CurState,npc.FindState("Pain")))',1)
assert restored==source
native=a.native_source/'src/playsim/p_mobj.cpp';native_text=native.read_text(encoding='utf-8')
start=native_text.index('static int InStateSequence(FState * newstate, FState * basestate)');end=native_text.index('\nDEFINE_ACTION_FUNCTION_NATIVE(AActor, InStateSequence',start)
predicate=native_text[start:end];assert 'if (basestate == NULL) return false;' in predicate
assert 'thisstate = thisstate->GetNextState();' in predicate and 'return false;' in predicate
lookup=a.native_source/'src/p_states.cpp';lookup_text=lookup.read_text(encoding='utf-8')
assert 'DEFINE_ACTION_FUNCTION(AActor, FindState)' in lookup_text
assert 'ACTION_RETURN_STATE(StateLabels.GetState(newstate, self->GetClass(), exact));' in lookup_text
data=candidate.replace('\n',nl).encode('utf-8')
with zipfile.ZipFile(out/'prototype.pk3','w') as z:z.writestr(zipfile.ZipInfo(path,(2026,11,19,0,0,0)),data)
target=out/'source'/path;target.parent.mkdir(parents=True);target.write_bytes(data)
sha=lambda b:hashlib.sha256(b).hexdigest()
manifest=dict(issue=853,runtime_sha256=sha(a.runtime.read_bytes()),baseline_source_sha256=sha(original),candidate_source_sha256=sha(data),overlay_sha256=sha((out/'prototype.pk3').read_bytes()),inverse_exact=True,removed_duplicate_guards=edits,native_sources={str(native):sha(native.read_bytes()),str(lookup):sha(lookup.read_bytes())},native_predicate=predicate,qualification='Prototype only; selection requires measurement and native tests. Native InStateSequence is a pure comparison and returns false for a null base. Literal FindState reads class state labels without intervening effects. Remove only the duplicated non-null guard; preserve all surrounding short circuits, actor/state operands and state/resource operations. No fields, caches, schema, data or cadence changes.')
(out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf-8',newline='\n');print(json.dumps(dict(output=str(out),sha256=manifest['overlay_sha256'])))
