"""Document the completed native Value patch and its measured limits."""
from pathlib import Path
import json, re, subprocess, sys

root=Path('C:/GZDooMProjects/CaelumArgenteum/build/v517/work-713')
scope=json.loads((root/'build/issue864-scope.json').read_text())
suite=json.loads((root/'build/issue864-native-suite.json').read_text());assert len(suite)==5 and all(r['passed'] for r in suite)
scenes=json.loads((root/'build/issue864-production-performance.json').read_text());assert len(scenes)==6
assert scenes[0]['states']==scenes[1]['states'] and scenes[0]['census']==scenes[1]['census']
total=sum(r['checks'] for r in suite);final=sum(r['checks'] for r in suite if r['label'] in ('fresh','upgrade','reload'))
log=(root/'build/issue864-native-fresh01/engine.log').read_text(encoding='utf-8')
bench=re.findall(r'CA864 VALUE_BENCH class=(\w+) mode=(\d+) calls_each=(\d+) original_ms=([\d.]+) candidate_ms=([\d.]+) mismatches=(\d+)',log)
assert len(bench)==6 and all(int(row[-1])==0 for row in bench)
micro='| Native class / setup | Original / final ms per 160,000 reads |\n| --- | ---: |\n'
for name,mode,calls,old,new,mismatch in bench:
    setup='seed state' if mode=='0' else 'settled exposure' if name!='CA864NpcProbe' else 'repeated NPC control'
    micro+=f'| {name} / {setup} | {float(old):.4f} / {float(new):.4f} |\n'
table='| Scene | Queue presents/s | Present p95 / p99 / max ms | Tic mean / p95 / p99 / max ms |\n| --- | ---: | --- | --- |\n'
for row in scenes:
    present=row['presentation'];p=present['present_intervals'];t=row['simulation']
    table+=f"| {row['label']} | {present['mean_present_fps']:.3f} | {p['p95_ms']:.3f} / {p['p99_ms']:.3f} / {p['max_ms']:.3f} | {t['mean_ms']:.3f} / {t['p95_ms']:.3f} / {t['p99_ms']:.3f} / {t['max_ms']:.3f} |\n"
title='## 5.17.110 - Shorten measured native contamination value dispatch (#864)\n\n'
sections={
'ASSETS.md':'''No art, geometry, material, pose or attachment changes. The native mansion,
sewer, peaceful city/ground and normal-siege references use the retained assets.
Evidence and captures are in assets/validation_v5_17_110; those fixed-camera
samples are engineering references, not acceptance of the broader #463 finish.
Existing #736, clothing, grip and sewer-material review gates remain pending.
''',
'SYSTEMS.md':'''CaelumContaminationStorage.Value now dispatches the measured GateBlocker and
VehiclePart families directly to their unchanged native carrier lookup. NPCs
use the existing Get path directly. Their single-inheritance chains exclude
inventory stacks, remote household chests and player illness; the skipped
branches only performed failed pure checks for those types. Other objects retain
the original ordered stack, remote-storage, player and general lookup paths.

After either lookup, the same exposure SettleNow call still runs before the
revision test and concentration read. Every physical part keeps its individual
carrier/resource. No concentration, timestamp, ownership or exposure result is
cached. No saved fields, schema, cadence, gameplay constants, contact rules or
global actor scans are added. Existing lazy first-read/load settlement, stack
lots, delegation and carrier attachment migration remain authoritative.

The typed reduction operates automatically wherever those native reads occur,
including normal dense gameplay. It does not change the whole-map >=500 living
combatant census or suppress offscreen effects. Native upgrade, reload and direct
old-runtime rollback pass; author acceptance and overall siege fluency remain open.
''',
'PROJECT.md':'''Implemented one measured read-dispatch reduction under #454/#864, preserving
individual contamination records and live exposure settlement. Exact source and
package scope, original-result comparisons, retained ownership contracts and
reversible native saves are verified. HISTORY records scoped timings and the
final/control frame/tic distributions; assets/validation_v5_17_110 retains evidence.

This is a bounded subsystem improvement. Overall siege performance and the
remaining character/equipment/scenery/campaign work are unfinished. The complete
existing author queue is preserved; the requested consolidated terminal follows
the remaining batch. Native evidence does not approve #736 or unauthored design.
''',
'TASKS.md':'''Completed the current-source contact/value diagnosis, typed dispatch, fallback
revision, independent exposure/ownership comparisons, reversible saves and final
runtime/reference measurements. Preserve the qualified timing evidence and the
unresolved full-siege performance requirement.

Continue the authorized V5.16/V5.17 batch, including scenery candidates/inventory,
character/equipment limits and recorded campaign authoring gates. No new manual
check is added for this equivalent internal dispatch; CA454-MAP03-01 and every
existing author check remain outstanding for the single final session.
''',
'HISTORY.md':f'''The current 109 runtime was profiled before selecting a change. Deep sampled
scopes measured Exchange 4.4021, Transfer 2.9949, Value 2.1461, SettleNow 0.7415 and
Get 0.7375 ms per sampled tic. These scopes nest and include instrumentation;
they cannot be added or treated as uninstrumented savings. A separate 42-tic
classification observed 154,994 Value calls: 148,678 from native gate/vehicle
families, 5,733 warm NPC reads, 378 inventory reads and 205 other actor reads.
Warm NPC pointer comparisons had zero mismatches. Exact launch/source manifests
and all raw samples are retained.

The final Value branch bypasses pure checks that cannot match these exclusive
families, retaining the original GetCarrier/Get bodies, exposure settlement and
revision/concentration tail. No fields, caches, data or migration are introduced.
Only that source member and two release strings change. All 18,764 other members
of the 18,767-member runtime are byte-identical; all members match src and the
Value source matches prototype02. Runtime SHA256:
{scope['runtime_sha256']}.
The portable prototype builder repeats the private overlay byte for byte.

Prototype01 passed 745 assertions and improved native-piece reads but slowed the
NPC fallback (4.3955 to 5.5801ms per 160,000 seed reads). It was superseded by the
explicit NPC path in prototype02. Prototype02 passed 745 assertions; extending the
fixture with pending first-read exposure brought the separate prototype run to 787.
These are supplementary attempts, not part of the final continuity count.

The canonical five-phase suite passes {total:,} assertions: baseline 787, final
fresh 787, upgrade 638, reload 638 and old-runtime rollback 638. Of these, {final:,}
run on the final package and {total-final:,} on the prior package. Paired independent
records/exposures compare values and mutation effects across the native families,
NPC controls, pending first-read settlement, equal/future timestamps and a legacy
record revision. Retained stack/vessel contracts cover ownership and heterogeneous
lots. Persistence seeds deliberately isolate environmental exposure; the paired
matrix separately covers first-read exposure effects. Neither is manual acceptance.

Final-runtime synchronous loops alternate original/final order; every comparison
agrees. The second NPC row repeats its unmodified control setup. Loop costs are
not frame-time measurements:

{micro}
Six final/control reference windows use the recorded GZDoom 4.14.2, Windows 11,
Ryzen 9 5950X and RTX 3070 Ti/Vulkan environment, one hidden unpaused engine at 5%
audio with no concurrent heavy work. The normal siege retains its existing
1,000-attacker admission cap/600-defender design; the two measured windows agree
on actual census, health and observer position. No retired 6,000-attacker test runs.

{table}
Queue presents are application submissions, not monitor scanout. Tic intervals
include pacing/frame work. These fixed entrances, two city angles and bounded
siege samples are not full-map or route acceptance. The small dispatch reduction
does not resolve the overall siege rendering requirement; do not extrapolate the
microbenchmark ratios to complete-frame gains. All prior author checks and the
broader batch remain open. Evidence/reproduction: assets/validation_v5_17_110.
'''
}
for name,body in sections.items():
    p=root/'docs'/name;s=p.read_text(encoding='utf-8');assert title not in s
    at=s.index('\n## ')+1;p.write_text(s[:at]+title+body+'\n'+s[at:],encoding='utf-8',newline='\n')
p=root/'docs/KNOWN_PITFALLS.md';s=p.read_text(encoding='utf-8');assert '## CA-KP-266' not in s
lesson='''## CA-KP-266 - Measure the fallback after adding a typed shortcut

Status/evidence: CODE-VERIFIED and ENGINE-VERIFIED, #864 / 5.17.110,
2026-11-21, GZDoom 4.14.2. Native verification is not author acceptance.

A faster hot-family branch can add work to other frequent callers. The first
Value prototype improved gate/vehicle reads but increased the repeated NPC
control from 4.3955 to 5.5801ms per 160,000 calls. Adding an exclusive NPC dispatch
through the unchanged Get method removed that observed fallback regression.
Measure all relevant families and alternate loop order; preserve rejected
performance attempts rather than reporting only the fastest type.

Do not shortcut a live Value read to a stored scalar: it first settles pending
exposure and may repair carrier attachment or delegated state. Prove the skipped
type branches are pure and impossible, retain the shared settlement/revision
tail, and compare independent records with pending first-read, equal/future
clock boundaries and legacy revisions. Repeated reads of an already-settled
object alone cannot verify the first-read effects. Ownership, native save/load
and old-runtime reversal need separate evidence. No value cache was added here.

Raw source/class proofs, independent native cases, loop measurements and the
qualified full-scene presentation/tic windows: assets/validation_v5_17_110.
Nested diagnostic scopes are not additive; a faster lookup is not proof that
the full siege meets the author's rendering expectation.

'''
at=s.index('\n## ')+1;p.write_text(s[:at]+lesson+s[at:],encoding='utf-8',newline='\n')
p=root/'README.md';s=p.read_text(encoding='utf-8');at=s.index('\n#861')+1
s=s[:at]+'''#864 shortens measured contamination reads for native physical pieces and NPCs,
preserving individual records and exposure settlement. Native original-result,
ownership/save/reversal checks and frame/tic evidence are recorded in
docs/HISTORY.md and assets/validation_v5_17_110. Overall siege performance and
the broader batch remain open; author review stays in the final session.

'''+s[at:];p.write_text(s,encoding='utf-8',newline='\n')
p=root/'docs/CONTEXT.md';s=p.read_text(encoding='utf-8');old='#859:grips; #861:clothing hands.';assert s.count(old)==1
s=s.replace(old,'#859:grips; #861:clothing hands; #864:contact reads.');assert len(s.split())<2500
p.write_text(s,encoding='utf-8',newline='\n')
subprocess.run([sys.executable,'build_document_index.py'],cwd=root,check=True,stdout=subprocess.DEVNULL)
print(json.dumps(dict(version='5.17.110',canonical_assertions=total,final_assertions=final,context_words=len(s.split()))))
