"""Consolidate the measured #838 result without recording author acceptance."""
from pathlib import Path
import json
root=Path(__file__).resolve().parents[2]/'build/v517/work-713'
summary=json.loads((root/'assets/validation_v5_17_97/evidence/SUMMARY.json').read_text(encoding='utf-8'))
rows={r['label']:r for r in summary['campaign_runs']};final=rows['final01'];control=rows['baseline01']
t=final['simulation'];p=final['presentation'];count=summary['final_suite_assertions'];assert count==392
title='## 5.17.97 - Skip unreachable read-only relationship queries (#838, #454)\n\n'
decision=f'''The production shared-candidate loop now rejects unreachable bodies before
relationship queries only when the observer's relationship path reads state.
Residents, summoned Zupays, tarot automatons and clones retain the previous
relationship-before-bound order. In the final approved siege run, simulation
p95/p99 are {t['p95_ms']:.4f}/{t['p99_ms']:.4f} ms and queue presentation is
{p['mean_present_fps']:.2f} presents/s. Severe siege stalls remain; this patch
does not establish fluent gameplay or author acceptance.
'''
def write(name,s):(root/name).write_text(s,encoding='utf-8',newline='\n')
def section(name,s):
    old=(root/name).read_text(encoding='utf-8');a=old.index('## 5.17.97 -');b=old.index('\n## ',a+1)
    write(name,old[:a]+s.rstrip()+'\n'+old[b:])
section('docs/PROJECT.md',title+decision+'''
The unchanged conservative reach bound, linked-portal fallback, candidate order,
private evidence and original visibility/relationship functions remain
authoritative. The automatic whole-map >=500 census and individual offscreen
combat/resources/collision are unchanged. No schema or saved-field changes.
Native sampled equivalence and 392 final/control assertions pass, including
resident/delegated schema side effects and upgrade/reload/rollback. Evidence:
validation_v5_17_97; lesson CA-KP-256. CA454-MAP03-01 and the complete V5.16/V5.17
author session remain pending; all other unfinished parent-issue scopes remain.
''')
section('docs/TASKS.md',title+decision+'''
Completed: every-tic nested diagnosis, bounded GC control/ablation, one production
query reduction, original-order sampled oracle, relationship/visibility/portal
fixtures, reversible save checks and exact runtime preservation. The oracle
matches 2,066 queries/360,048 visits, avoiding 360,047 read-only relationship
calls with zero nearest-target mismatches. Six final/control fixture runs pass
392 assertions, of which 263 execute the final package. Existing author checks
remain pending; no partial test terminal or acceptance is recorded.

Next: isolate remaining frame-boundary residuals and native/scripted state-action
bursts before selecting another measured reduction. GC cycle suppression did
not remove long pauses and is not a production solution. Do not stagger combat
cadence, remove gameplay or replace the whole-map living census. Retain mansion,
sewer, city and ground-facing references; this siege result does not certify
their 60-FPS expectation. The broader character/equipment/first-person, scenery
and unauthored campaign assignments remain under their existing parent issues.
''')
table='| Run | Queue presents/s | Present p95 / p99 / max ms | Simulation mean / p95 / p99 / max ms |\n| --- | ---: | --- | --- |\n'
for label in ['gc-control','gc-stop','prototype','final01','baseline01']:
    row=rows[label];q=row['presentation'];v=q['present_intervals'];sim=row['simulation']
    table+=f"| {label} | {q['mean_present_fps']:.4f} | {v['p95_ms']:.4f} / {v['p99_ms']:.4f} / {v['max_ms']:.4f} | {sim['mean_ms']:.4f} / {sim['p95_ms']:.4f} / {sim['p99_ms']:.4f} / {sim['max_ms']:.4f} |\n"
section('docs/HISTORY.md',title+decision+'''
On 2026-11-19, a complete 700-tic diagnostic balances 28 nested scopes with zero
stack errors. Its largest wall interval is 202.2989 ms, with 178.9117 ms outside
those measured game-code blocks. Those residuals include uninstrumented native,
player and frame work; they do not prove a GPU bottleneck. Most periodic
scripted bursts concentrate in combat-actor Tick, including state actions.
Inclusive parent/child timings overlap and must not be added.

A paired private GC diagnostic forces collection at tic3200 in both runs, then
disables new cycles only in one process. Long pauses remain; active objects at
exit grow from979,459(control) to3,617,130(stop). No GC setting is adopted.
The production change instead avoids relation work already ruled out by #836's
conservative current-geometry bound. The source audit found a real side effect:
resident reputation invokes GetPersistentCharacterState(false), which may
maintain four material schemas. Delegated target lookup can reach that resident
path too. Both families retain the original ordering; ordinary observer paths
only read relation data. Every retained candidate uses the unchanged functions.

The sampled same-scene oracle checks 2,066 queries/360,048 visits and identifies
360,047 safely avoidable relation calls, with zero ordered nearest-target
differences. The final/control fixture matrix passes392 assertions(263 on final):
null/dead/friendly/Emperor cases, equal-distance order, four fallback families,
remote resident and delegated-automaton migrations, visibility/range/contact
edges, linked portals, parent-save upgrade, reload and reverse loading.
No saved fields or schema changes. Failed test-only syntax iterations remain
in the evidence alongside the corrected passing fixture.

All measurements use the approved normal1,000attacker-cap/600defender scene,
Vulkan1280x720, uncapped, background unpaused and5%audio. Each window has700
simulation intervals. Exact start/end census and registered health match:
988attacker NPCs+601defenders(including subcaptain)+player=1,590living;
registered health1,421,137 and player health1,248. Machines retain cap slots.
No heavy export/build/full validator overlaps the measurements.

'''+table+'''
Queue intervals describe vkQueuePresentKHR calls, not display scanout, Internet
latency or GPU execution time. GC rows are diagnostic ablations. Initial bench
requests exited before its five-second native wait; the final/control adapter
captures the unchanged scene/window first and allows350 extra tics afterward.
Those later native CPU snapshots do not replace whole-window/GPU measurement.
The final package has18,719members and matches every src byte. Only the visual
guard/order and two diagnostic version strings differ from parent9387ab0e;
the independent inverse transformation restores the parent's visual source.
Full project validation and evidence hashes are recorded with this release.
Prior mansion/sewer/city/ground evidence, historical headings and author tests
are preserved. CA454-MAP03-01 remains pending for the consolidated author review.
''')
section('docs/ASSETS.md',title+'''
No art, sound, model, map, balance or saved-state ownership changes. The package
retains18,719members; only the visual relationship-order guard and two diagnostic
release strings change. Source/runtime byte and inverse-transform audits pass.

assets/validation_v5_17_97 retains the complete nested profile, GC comparison,
source overlays, ordered-target oracle, relationship/portal/save fixtures,
native logs, scene captures, queue traces and later CPU benchmark snapshots.
Six final/control fixture runs pass392assertions(263 final). The source contract
records why resident and delegated relation paths must keep their ordering.
Private IWADs, executables, PK3/WAD test packages and saves remain local.
The reproducible run_relation_edges.py extends validation_v5_17_96 and takes an
explicit parent runtime as its independent baseline. check_preservation.py
audits the package/source contract; evidence/SUMMARY.json indexes retained
hashes and measured limitations. Full validation is recorded in the same patch.
These checks do not advance character proposals, art approval or author tests.
''')
p=root/'README.md';s=p.read_text(encoding='utf-8');a=s.index('#838 avoids relationship queries');b=s.index('\n#836 reduces',a)
s=s[:a]+f'''#838 avoids unreachable read-only relationship queries while preserving resident
and delegated state updates. Native equivalence,392edge/save checks and package
preservation pass. Final siege simulation p95/p99: {t['p95_ms']:.2f}/{t['p99_ms']:.2f}ms;
queue presentation: {final['presentation']['mean_present_fps']:.2f}presents/s. Severe stalls remain.
Evidence: assets/validation_v5_17_97; author review remains pending.
\n'''+s[b:];write('README.md',s)
p=root/'docs/CONTEXT.md';s=p.read_text(encoding='utf-8');old='#838:relation filter;2,066queries matched;prototype-p95=47.48ms;final-checks-pending.'
assert old in s;s=s.replace(old,f"#838:relation filter;392checks;2,066queries matched;siege~{final['presentation']['mean_present_fps']:.2f}presents/s.",1);write('docs/CONTEXT.md',s)
p=root/'docs/KNOWN_PITFALLS.md';s=p.read_text(encoding='utf-8');a=s.index('\n## CA-KP-255')
lesson='''
## CA-KP-256 - Preserve predicate side effects and measure unexplained residuals

Status/evidence: CODE-VERIFIED and ENGINE-VERIFIED, #838, 2026-11-19.
Scope: shared high-density candidate query, approved Barracas siege, native
GZDoom4.14.2; parent9387ab0e. No author acceptance or universal timing claim.

Moving a cheap rejection before a relationship predicate requires auditing its
effects, not just its boolean result. GetPersistentCharacterState(false) does
not create a missing record but may migrate material schemas. Resident faction
queries call it, and delegated major-target lookup can reach the same resident
path. #838 therefore retains relationship-before-bound order for anchored
residents, summoned Zupays, tarot automatons and clones. The ordinary shared
observer path only reads relations. Retained candidates keep original functions
and list order; no cached geometry, new scan, cadence or saved-field change.
Reaudit the guard whenever relationship routing gains another effect.

The original-order sampled oracle matches2,066queries/360,048visits and skips
360,047read-only relations without nearest-target differences. Native fixtures
verify actual remote resident and delegated-automaton migrations, along with
visibility, ordering, portal and reversible-save checks. All392assertions pass
across six final/control runs. This evidence is scoped, not universal proof.

The complete700tic/28scope diagnostic separates inclusive and exclusive costs.
Its largest interval leaves178.9117ms outside measured game code; do not call
that remainder GPU time. A paired prewindow full-GC/control and stopped-cycle
ablation retains long pauses while increasing live collector objects. GC stop
is not a production optimization. Native bench also waits five wall seconds
before output: capture after it completes and distinguish that later CPU
snapshot from the measured queue window. Production presentation remains poor;
preserve offscreen mechanics and investigate the remaining work independently.
Evidence, exact source contracts and limitations: assets/validation_v5_17_97.
'''
assert '## CA-KP-256' not in s;s=s[:a]+lesson+s[a:];write('docs/KNOWN_PITFALLS.md',s)
print('Consolidated #838 evidence; context words='+str(len((root/'docs/CONTEXT.md').read_text(encoding='utf-8').split())))
