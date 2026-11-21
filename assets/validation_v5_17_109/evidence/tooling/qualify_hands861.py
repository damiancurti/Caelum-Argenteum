"""Summarize completed #861 runs before full project validation."""
from pathlib import Path
import json
root=Path('C:/GZDooMProjects/CaelumArgenteum/build/v517/work-713')
canonical=json.loads((root/'build/issue861-final05/SUMMARY.json').read_text());assert len(canonical)==16 and all(r['passed'] for r in canonical)
actions=json.loads((root/'build/issue861-actions-final.json').read_text());assert len(actions)==4 and all(r['passed'] for r in actions)
for name in ('issue861-consumers-male01','issue861-consumers-female01','issue861-ordinary01'):assert json.loads((root/'build'/name/'RESULTS.json').read_text())['passed']
plain=[r for r in canonical if r['runtime']=='final'];old=[r for r in canonical if r['runtime']=='baseline'];instrumented=[r for r in canonical if r['runtime']=='instrumented final']
native=f'''The 16-phase qualified continuity/motion/ownership/counter record contains
{sum(r['pass_lines'] for r in canonical)} passing assertion lines: {sum(r['pass_lines'] for r in plain)} on the final runtime, {sum(r['pass_lines'] for r in old)} on prior-runtime
rollback/legacy-death creation, and {sum(r['pass_lines'] for r in instrumented)} on the separately instrumented counter overlay.
The first seven continuity phases from final03 remain valid: later fixture
changes only correct Pose assertions and add an optional legacy-death expectation.
Four corrected sword-motion cases cover both sexes, bare and actual GP gloves.
The final owned-item matrix covers all four clothing kinds and 42 profile
choices, including native equip/unequip/Box/chest and invalid cached-object guards.
Old saves upgrade/reload/travel and roll back directly. Native death/dead reload
preserve the current snapshot; a pre-109 bare corpse retains its old false glove
snapshot through upgrade and a second reload. Death uses native one-player coop.

The ordinary player independently passes the same 446 ownership assertions.
Two male/female consumer runs add 66 assertions for native drop/replacement,
same-ID rebind, foreign-record rejection, armor/clothing layers, broken worn
armor, actual Moon initialization snapshots and the rendered appearance editor.
The editor is opened, observed and closed without committing appearance changes.
Four actual input-driven carbine-reload/staff-charge runs add 152 assertions;
native clocks advance and the carbine reaches its canonical capacity. Diagnostic
setup supplies equipment/ammunition but never pins active clocks/resources.
Full Moon permissions/resources and every weapon/material are outside this test.
'''
rows=json.loads((root/'build/issue861-presentation-final.json').read_text());assert len(rows)==8
performance='''Eight fresh paired first-person windows compare the108 runtime with109,
using the same actual GP item, player setup and scene. They add 168 fixture
assertions. GZDoom4.14.2, Ryzen9 5950X, RTX3070Ti, Vulkan, unpaused background
and5% audio are recorded. The command requests1280x720; native images are
1520x825. No heavy build/hash/validator or second engine overlaps the windows.

| Scene / runtime | Queue presents/s | Present p95 / p99 / max ms | Tic mean / p95 / p99 / max ms |
| --- | ---: | --- | --- |
'''
for row in rows:
 p=row['presentation'];q=p['present_intervals'];t=row['simulation']
 performance+=f"| {row['scene']} / {row['kind']} | {p['mean_present_fps']:.3f} | {q['p95_ms']:.3f} / {q['p99_ms']:.3f} / {q['max_ms']:.3f} | {t['mean_ms']:.3f} / {t['p95_ms']:.3f} / {t['p99_ms']:.3f} / {t['max_ms']:.3f} |\n"
performance+='''
These observations are paired scene samples, not a general speedup or regression
claim. Queue presentation is not monitor scanout; tic intervals include pacing
and frame work. One player at fixed entrance views does not establish full-map,
combat, crowd or siege performance. The mansion opening dialogue and original
sewer/city rules are retained. Overall siege performance remains unresolved.
Raw samples, exact runtime/layer hashes, native captures and the explicitly
viewed-image list are retained in assets/validation_v5_17_109.
'''
p=root/'docs/HISTORY.md';s=p.read_text(encoding='utf-8');assert s.count('NATIVE861_PENDING')==1 and s.count('PERFORMANCE861_PENDING')==1
s=s.replace('NATIVE861_PENDING',native.rstrip()).replace('PERFORMANCE861_PENDING',performance.rstrip());p.write_text(s,encoding='utf-8',newline='\n')
# Improve numeric readability only in the new sections; keep history exact.
replacements={'complete18,767':'complete 18,767','src;18,762':'src; 18,762','SHA256:8fcef':'SHA256: 8fcef','instrumented1000-call':'instrumented 1,000-call','All5000':'All 5,000','respectively1/0':'respectively 1/0','The51':'The 51','layers46..53':'layers 46..53','shield44/left hand45':'shield 44/left hand 45','/5.17.109':'/ 5.17.109','GZDoom4.14.2':'GZDoom 4.14.2','Five1000-call':'Five 1,000-call','the108 runtime with109':'the 108 runtime with 109','Ryzen9 5950X':'Ryzen 9 5950X','RTX3070Ti':'RTX 3070 Ti','and5%':'and 5%','requests1280x720':'requests 1280x720'}
for name in ('HISTORY.md','ASSETS.md','SYSTEMS.md','PROJECT.md','TASKS.md','KNOWN_PITFALLS.md'):
 p=root/'docs'/name;s=p.read_text(encoding='utf-8');start=s.index('\n## ');end=s.index('\n## ',start+1);section=s[start:end]
 for a,b in replacements.items():section=section.replace(a,b)
 p.write_text(s[:start]+section+s[end:],encoding='utf-8',newline='\n')
print('Qualified native counts and8 presentation windows recorded.')
