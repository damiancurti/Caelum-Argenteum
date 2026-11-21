"""Build a private equivalent native-carrier value-dispatch candidate."""
from pathlib import Path
import hashlib, json, re, zipfile

import argparse
root = Path(__file__).resolve().parents[2]
p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--runtime', type=Path, required=True)
p.add_argument('--output', type=Path, required=True)
a = p.parse_args();runtime = a.runtime.resolve(strict=True);out = a.output.resolve()
out.relative_to(root/'build')
out.mkdir(exist_ok=False)
path = 'caelum/survival/CaelumContaminationState.zs'
with zipfile.ZipFile(runtime) as z:
    original = z.read(path)
newline = '\r\n' if b'\r\n' in original else '\n'
source = original.decode('utf-8').replace('\r\n', '\n')
start = source.index('    static double Value(Actor body)')
end = source.index('    static void Set(Actor body,double value)', start)
old = source[start:end]
boundary = old.index('        // Contacto/recogida')
prefix = old[old.index('        if(CaelumContaminationStack.Eligible'):boundary]
assert prefix.endswith('        let entry=Get(body);\n')
fallback = prefix.replace('        let entry=Get(body);', '        entry=Get(body);')
new = '''    static double Value(Actor body)
    {
        CaelumContaminationState entry;
        // Las piezas medidas no pueden ser pilas, cofres remotos ni jugadores.
        if(NativeCarrierBody(body))entry=GetCarrier(body,false,null);
        else if(body is 'CaelumCombatActor')entry=Get(body);
        else
        {
'''+''.join('    '+line+'\n' for line in fallback.splitlines())+'''        }
'''+old[boundary:]
candidate = source[:start]+new+source[end:]
assert candidate.replace(new, old) == source
assert new[new.index('        // Contacto/recogida'):] == old[boundary:]
classes = {}
for p in (root/'src/caelum').rglob('*.zs'):
    for name, parent in re.findall(r'^class\s+(\w+)\s*:\s*(\w+)', p.read_text(encoding='utf-8'), re.M):
        classes[name] = (parent, p)
def ancestry(name):
    chain = [name]
    while name in classes:
        name = classes[name][0]
        assert name not in chain
        chain.append(name)
    return chain
excluded = ['Inventory', 'CaelumPlayer', 'CaelumCombatActor', 'CaelumStashChest']
assert ancestry('CaelumCombatActor') == ['CaelumCombatActor', 'Actor']
for other in ('Inventory', 'CaelumPlayer', 'CaelumStashChest'):
    assert 'CaelumCombatActor' not in ancestry(other)
families = ['CaelumGateBlocker', 'CaelumVehiclePart']
for family in families:
    assert ancestry(family) == [family, 'Actor']
    for other in excluded:
        assert family not in ancestry(other) and other not in ancestry(family)
sha = lambda b: hashlib.sha256(b).hexdigest()
data = candidate.replace('\n', newline).encode('utf-8')
target = out/'source'/path
target.parent.mkdir(parents=True, exist_ok=True)
target.write_bytes(data)
(out/'original-value.zs').write_text(old, encoding='utf-8', newline='\n')
(out/'candidate-value.zs').write_text(new, encoding='utf-8', newline='\n')
with zipfile.ZipFile(out/'prototype.pk3', 'w') as z:
    z.writestr(zipfile.ZipInfo(path, (2026,11,21,0,0,0)), data)
manifest = dict(issue=864, runtime_sha256=sha(runtime.read_bytes()), original_sha256=sha(original),
    candidate_sha256=sha(data), overlay_sha256=sha((out/'prototype.pk3').read_bytes()), inverse_exact=True,
    scope='Only Value dispatch changes; the exclusive NPC branch uses the unchanged Get method. Original GetCarrier, settlement, revision test and concentration read remain exact. No fields, caches, data or saved schema changes.',
    ancestry={n:ancestry(n) for n in families+excluded},
    proof='Single inheritance excludes stack eligibility, remote chest synchronization, player illness, and the NPC branch of Get for both native-carrier families. NPC inheritance also excludes Inventory, CaelumPlayer and CaelumStashChest; its original Get still owns cache reconstruction. Skipped original paths contain only pure failed guards/casts. GetCarrier retains native attachment migration and individual record ownership; SettleNow still runs on every read.',
    class_sources={n:dict(path=classes[n][1].relative_to(root).as_posix(), sha256=sha(classes[n][1].read_bytes())) for n in families+excluded if n in classes})
(out/'manifest.json').write_text(json.dumps(manifest, indent=2)+'\n', encoding='utf-8')
print(json.dumps(dict(output=str(out), overlay_sha256=manifest['overlay_sha256'])))
