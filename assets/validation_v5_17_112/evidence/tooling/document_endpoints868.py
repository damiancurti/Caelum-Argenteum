"""Record the endpoint diagnosis, unchanged production path and test limits."""
from pathlib import Path
import json
ROOT=Path('C:/GZDooMProjects/CaelumArgenteum/build/v517/work-713')
scope=json.loads((ROOT/'build/issue868-scope.json').read_text())
suite=json.loads((ROOT/'build/issue868-suite.json').read_text());assert len(suite)==5 and all(r['passed'] for r in suite)
final=json.loads((ROOT/'build/issue868-final01/RESULTS.json').read_text());assert final['passed']
scene=json.loads((ROOT/'build/issue868-siege-final01-summary.json').read_text())
prior=json.loads((ROOT/'assets/validation_v5_17_111/evidence/performance.json').read_text())
old=json.loads((ROOT/'assets/validation_v5_17_110/evidence/production-performance.json').read_text())
rows=[r for r in prior if r['label'] in ('mansion-control01','city-control01','ground-control01')]
sewers=[r for r in old if r['label']=='sewers-final01'];assert len(sewers)==1
rows+=sewers+[scene];assert len(rows)==5
table='| Window (original release retained) | Queue presents/s | Present p95 / p99 / max ms | Tic mean / p95 / p99 / max ms |\n| --- | ---: | --- | --- |\n'
for r in rows:
    p=r['presentation'];t=r['simulation'];tail=p['present_intervals']
    release='112' if r is scene else '110' if r in sewers else '111'
    table+=f"| {r['label']} ({release}) | {p['mean_present_fps']:.3f} | {tail['p95_ms']:.3f} / {tail['p99_ms']:.3f} / {tail['max_ms']:.3f} | {t['mean_ms']:.3f} / {t['p95_ms']:.3f} / {t['p99_ms']:.3f} / {t['max_ms']:.3f} |\n"
title='## 5.17.112 - Measure endpoint setup and retain the shared production path (#868, #454)\n\n'
sections={
'SYSTEMS.md':'''The measured Exterior endpoint routine remains unchanged. A private typed
GateBlocker/VehiclePart shortcut preserved results but penalized NPC and other
fallback callers; it was rejected. A second prototype expanded the final
ActorPoint call into its existing body. Its small repeated-call advantage,
alongside a nonzero unchanged-clone control, does not justify duplicated live
shielding/dose logic. Neither prototype is included in normal gameplay.

The same player outer-equipment selection, NPC armor/fur rules, live shielding,
mass-scaled dose, allocation/reuse/reset, exposure settlement and contact transfer
remain authoritative. No concentration cache, fields/schema, cadence, actor scan,
collision/resource rule or whole-map >=500 census change was introduced. Native
probe saves reload and return to the original implementation; this is diagnostic
verification, not author acceptance of the pending batch.
''',
'PROJECT.md':'''Completed the focused endpoint investigation under #454/#868 and retained the
existing shared implementation. This delivery records rejected alternatives,
an unchanged-source timing control, corrected native diagnostic assertions and
save/reversal evidence. It does not claim a production performance improvement.
Only two runtime release labels differ from 5.17.111; the remaining 18,765 package
members are exact. Overall siege fluency and the broader V5.16/V5.17 work remain
open. The next performance work must locate the full frame/tic bottleneck instead
of treating a tiny repeated-call saving as a rendering solution.
''',
'TASKS.md':'''Completed: immutable111 nested profile; typed and inline-only private
prototypes; same-code timing control; original-result point/transfer comparisons;
five corrected full fixture runs plus final112 published-runner reload; exact
runtime preservation; retained failures; one final uninstrumented normal-siege
window and transparently reused unchanged-source reference scenes.

Rejected: native-family-first dispatch regresses fallbacks; duplicated ActorPoint
body has too little demonstrated benefit over the unchanged-clone control to
justify splitting shared live guards. Production Exterior remains exact.
Pending: full-frame siege bottleneck, authorized city/sewer finish and the rest
of the existing batch. Author-gated character variants/assignments stay gated;
no intermediate question, acceptance, issue closure or test terminal is implied.
The outstanding author queue is byte-for-byte preserved.
''',
'ASSETS.md':'''No production image, model, map or resource changed under #868. The two
endpoint alternatives remain private reconstruction outputs; neither is shipped
as runtime logic. assets/validation_v5_17_112 retains exact original/candidate
sources, class proofs, sampled timings, native check/config/log evidence, the
corrected portable runner and source-preservation records. Engine executables,
IWADs, generated PK3s, WAD fixtures and saves remain local. The observed native
crash dialog is recorded as diagnostic text; no crash report was sent externally.

Mansion/city/ground windows are reused from validation_v5_17_111 and normal sewers
from validation_v5_17_110 after byte-level runtime comparison. Their original
versions, hashes and visual qualifications remain visible. A new112 normal-siege
capture and frame/tic traces are separate. Visual/art acceptance and #736 review
remain deferred to the final consolidated session.
''',
'HISTORY.md':f'''Production choice: retain the existing Exterior/ActorPoint path. This is a
diagnosis delivery, not an implemented optimization. Runtime SHA-256:
{scope['runtime_sha256']}.
Relative to both110 and111, only the two release-diagnostic strings differ;
18,765 of18,767 members are identical, including all endpoint logic and assets.

The immutable111 deep profile sampled42 tics at period17 in the approved normal
siege. Inclusive means: Contact.Exchange3.446448ms, Transfer2.068702ms,
Value1.250940ms, Exterior0.816762ms and ActorPoint0.439310ms. Exterior had149,637
sampled calls. Nested timers include lookup/wrapper overhead and are not additive
or production CPU budgets. No retired6000 case was run.

The native-family-first prototype passed1,144 comparisons but increased bare-NPC
repeated-call time from4.9245 to6.1328ms and armored NPC from3.6505 to4.8776ms per
160,000 calls; rats/materials/signs/player also regressed in that window. Gate
4.7046->1.3467 and vehicle4.7667->1.9325 do not justify penalizing the other paths.
That prototype is rejected.

Inline-only removes one terminal call while preserving its exact four-line body.
In the corrected fresh run, gate4.7136->4.3186 and vehicle4.7893->4.4141ms per
160,000 calls; the unchanged-code control already shows gate4.7223->4.5298 and
vehicle4.7931->4.6192ms. Repeated reload/rollback controls are retained. Alternating
16 rounds/10,000 calls per side reduces order bias but does not remove function
layout, loop, timer or warm-cache effects. These tiny absolute differences do not
establish a full-scene gain; shared live guards are retained instead of duplicated.

Five corrected runs pass5,744 assertions: baseline/fresh1,144 each and prototype
upgrade/reload/original rollback1,152 each. They cover fresh/reused points, null,
Box/closed-chest/contained-rock rejection, player mass/outer surface, NPC armor,
fur/bare body, stale Record/Body/Dose reset, all four slots, native piece families,
both transfer directions/equality, body versus vertical-support area, saved
individual concentrations, symmetric contact links and lazy transient rebuild.
The portable runner additionally reloads the final112 package with9 checks:
5,753 corrected full/final assertions, all with clean process exit.
Probe bodies disable Tick and use bMissile to isolate environmental exposure;
the saved contact subclass disables automatic Tick but inherits production
Exchange and transient fields. This does not prove normal free-running collision
or whole-campaign save acceptance. No production behavior changed.

Rejected diagnostics remain explicit. The original chained returned-object/list
assertion caused native C0000005 read0x40000000 or a VM null-address abort on load.
The same old assertion aborts with vm_jit and vm_jit_aot disabled; it is not proven
JIT-only. Local record references plus null/size checks remove the observed
failure in minimal and full runs. No record was missing in the corrected load;
the underlying engine/compiler cause was not further isolated. A diagnostic
Name/String ternary also failed compilation before correction. Two attempted
follow-on launches were refused by the single-engine guard before launch. The
first timeout JSON had errors[] but passed=false/exit1 and is not counted as pass;
the maintained runner explicitly records timeout/native-dialog uncertainty.

Windows11/Ryzen9 5950X/RTX3070Ti, GZDoom4.14.2, Vulkan1280x720, unpaused
background and5% audio. The unchanged-source mansion/city/ground111 and normal
sewer110 windows are reused with original hashes; they are not claimed as112
executions. Only the final normal-siege row is newly run with112. QueuePresent
is not monitor scanout, and tic interval tails include pacing/frame work rather
than isolated simulation CPU time. No causal production speedup is claimed.

{table}
The final siege keeps the approved1,000-attacker/600-defender scenario; its actual
census and observer state are retained separately. Overall siege fluency remains
unresolved. No author test is added or removed, and no author acceptance is
inferred. Reproducible tools/evidence: assets/validation_v5_17_112; CA-KP-268.
Full project validation is pending at this documentation checkpoint.
'''}
for name,body in sections.items():
    p=ROOT/'docs'/name;s=p.read_text(encoding='utf-8');assert title not in s;i=s.index('\n## ')
    p.write_text(s[:i]+'\n'+title+body.strip()+'\n'+s[i:],encoding='utf-8',newline='\n')
p=ROOT/'README.md';s=p.read_text(encoding='utf-8');i=s.index('#866 recovers')
s=s[:i]+'''#868 measures contact endpoint setup and retains the shared production path.
Rejected prototypes, unchanged-code controls, corrected save/reversal checks and
frame/tic qualifications are recorded in docs/HISTORY.md and
assets/validation_v5_17_112. Siege fluency and the broader batch remain open;
the consolidated author terminal is still deferred.

'''+s[i:];p.write_text(s,encoding='utf-8',newline='\n')
p=ROOT/'docs/CONTEXT.md';s=p.read_text(encoding='utf-8');assert '#864:contact reads.' in s
s=s.replace('#864:contact reads.','#864:contact reads;#868:endpoint diagnosis.',1);assert len(s.split())<2500
p.write_text(s,encoding='utf-8',newline='\n')
p=ROOT/'docs/KNOWN_PITFALLS.md';s=p.read_text(encoding='utf-8');assert 'CA-KP-268' not in s;i=s.index('\n## ')
lesson='''
## CA-KP-268 - Validate diagnostic object references before interpreting results

Status/evidence: ENGINE-VERIFIED fixture correction, #868 /5.17.112,
2026-11-21, GZDoom4.14.2. Underlying engine/compiler cause remains unisolated.

A reload assertion chained Get(actor).Pairs[0] for both contact endpoints inside
one boolean argument. It failed with a VM null-address abort and, in another run,
a native C0000005 dialog absent from engine.log. Disabling both JIT switches did
not make the old expression pass. Materializing the two returned records in local
references, checking null and list bounds, then comparing identities passes the
same minimal save and the complete upgrade/reload/rollback suite. No record is
missing in those corrected loads. Do not diagnose a production save migration
failure from an unsafe fixture expression or claim a JIT-specific bug without
isolating it. Retain both the failed and corrected diagnostic sources and logs.

Also compare an unchanged source clone when interpreting very small timings:
the control itself can show an apparent advantage. Alternating loop order alone
does not eliminate layout/timer effects, and nested profile wrappers inflate
inclusive totals. #868 retains the shared endpoint routine rather than shipping
a regressive typed shortcut or duplicating guards for a tiny absolute saving.
Evidence: assets/validation_v5_17_112. Reject timeouts and nonzero exits even if
engine.log lacks a fatal marker; record native-dialog uncertainty explicitly.

'''
p.write_text(s[:i]+lesson+s[i:],encoding='utf-8',newline='\n')
(ROOT/'build/issue868-performance.json').write_text(json.dumps(rows,indent=2)+'\n',encoding='utf-8',newline='\n')
print(json.dumps(dict(documented='5.17.112',native_checks=5753,context_words=len((ROOT/'docs/CONTEXT.md').read_text().split()))))
