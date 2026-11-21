"""Prepare a private, narrowly typed Exterior candidate from the exact baseline."""
from pathlib import Path
import argparse, hashlib, json, re, zipfile

ROOT = Path('C:/GZDooMProjects/CaelumArgenteum/build/v517/work-713')
p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--output', type=Path, required=True)
p.add_argument('--npc-first', action='store_true')
p.add_argument('--inline-only', action='store_true')
a = p.parse_args()
runtime = ROOT/'build/issue866-review01.pk3'
out = a.output.resolve(); out.relative_to(ROOT/'build'); out.mkdir(exist_ok=False)
path = 'caelum/survival/CaelumContaminationCombat.zs'
with zipfile.ZipFile(runtime) as z:
    original = z.read(path)
source = original.decode('utf-8').replace('\r\n', '\n')
start = source.index('    static CaelumContaminationContactPoint Exterior(')
end = source.index('    static bool Physical(', start)
old = source[start:end]
shortcut = '''        // Estas familias no son inventario, roca contenida ni cuerpos con dosis por masa.
        if(CaelumContaminationStorage.NativeCarrierBody(body))
        {
            let point=reuse!=null?reuse:new('CaelumContaminationContactPoint');
            point.Body=body;point.Record=null;point.Dose=1;return point;
        }
'''
if a.inline_only:
    point_start=source.index('        if(body==null || CaelumContaminationStorage.IsShielded(body))')
    point_end=source.index('    }',point_start)
    point_body=source[point_start:point_end]
    assert old.count('        return ActorPoint(body,reuse);')==1
    new=old.replace('        return ActorPoint(body,reuse);\n',point_body)
elif a.npc_first:
    signature = old[:old.index('        let user=')]
    npc = old[old.index('        let npc='):old.index('        return ActorPoint(body,reuse);')]
    npc = npc.replace('if(npc!=null && npc.CombatArmor!=null', 'if(npc.CombatArmor!=null')
    declaration, rest = npc.split('\n', 1)
    new = signature+declaration+'\n        if(npc!=null)\n        {\n'+''.join('    '+s+'\n' for s in rest.splitlines())+'            return ActorPoint(body,reuse);\n        }\n'+shortcut+old[old.index('        let user='):old.index('        let npc=')]+old[old.index('        return ActorPoint(body,reuse);'):]
else:
    new = old.replace('        let user=', shortcut+'        let user=', 1)
candidate = source[:start]+new+source[end:]
assert candidate.replace(new,old)==source
data = candidate.replace('\n','\r\n' if b'\r\n' in original else '\n').encode()
target=out/'source'/path; target.parent.mkdir(parents=True); target.write_bytes(data)
(out/'original-exterior.zs').write_text(old,encoding='utf-8',newline='\n')
(out/'candidate-exterior.zs').write_text(new,encoding='utf-8',newline='\n')
with zipfile.ZipFile(out/'prototype.pk3','x') as z:
    z.writestr(zipfile.ZipInfo(path,(2026,11,21,0,0,0)),data)
classes={}
for f in (ROOT/'src/caelum').rglob('*.zs'):
    for name,parent in re.findall(r'^class\s+(\w+)\s*:\s*(\w+)',f.read_text(encoding='utf-8'),re.M): classes[name]=(parent,f)
def chain(name):
    result=[name]
    while name in classes:
        name=classes[name][0]; assert name not in result; result.append(name)
    return result
families=['CaelumGateBlocker','CaelumVehiclePart']
excluded=['Inventory','CaelumPlayer','CaelumCombatActor','CaelumTarotRock']
for family in families:
    assert chain(family)==[family,'Actor']
    for other in excluded: assert family not in chain(other) and other not in chain(family)
sha=lambda b:hashlib.sha256(b).hexdigest()
manifest=dict(issue=868,npc_first=a.npc_first,inline_only=a.inline_only,runtime_sha256=sha(runtime.read_bytes()),original_sha256=sha(original),candidate_sha256=sha(data),overlay_sha256=sha((out/'prototype.pk3').read_bytes()),inverse_exact=True,
    ancestry={n:chain(n) for n in families+excluded},
    scope='Only Exterior changes. The native-family endpoint still resets Body, Record and Dose on every call. No persisted fields, caches, skipped exposure/transfer, cadence or data changes.',
    proof='Single inheritance excludes player/NPC casts, Inventory shielding and contained TarotRock shielding. The original Dose fallback is exactly 1. No skipped path has effects before its impossible cast succeeds.',
    class_sources={n:dict(path=classes[n][1].relative_to(ROOT).as_posix(),sha256=sha(classes[n][1].read_bytes())) for n in families+excluded if n in classes})
if a.inline_only:
    manifest['proof']='The terminal ActorPoint call is expanded to its exact current four-line body. Player outer-equipment and NPC armor branches, null/shielding order, allocation/reuse/reset and live Dose remain unchanged for every class. No typed shortcut or skipped guard remains.'
(out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf-8',newline='\n')
print(json.dumps(dict(output=str(out),overlay_sha256=manifest['overlay_sha256'])))
