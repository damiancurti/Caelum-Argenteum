"""Record verified ownership binding, migration and the visual review limits."""
from pathlib import Path
import json
root=Path('C:/GZDooMProjects/CaelumArgenteum/build/v517/work-713')
d=json.loads((root/'assets/validation_v5_17_107/evidence/SUMMARY.json').read_text())
heading='## 5.17.107 - Bind the opt-in first-body wardrobe to owned clothing (#857)\n\n'
table='| Scene / mode | Queue presents/s | Present p95 / p99 / max ms | Tic mean / p95 / p99 / max ms |\n| --- | ---: | --- | --- |\n'
for row in sorted(d['performance'],key=lambda r:(r['scene'],r['kind'])):
    p=row['presentation'];i=p['present_intervals'];t=row['simulation']
    table+=f"| {row['scene']} / {row['kind']} | {p['mean_present_fps']:.3f} | {i['p95_ms']:.3f} / {i['p99_ms']:.3f} / {i['max_ms']:.3f} | {t['mean_ms']:.3f} / {t['p95_ms']:.3f} / {t['p99_ms']:.3f} / {t['max_ms']:.3f} |\n"
contract='''The default-off server CVAR ca_wardrobe_candidate enables the first-body
candidate only on the existing opt-in CaelumDomingoPilotPlayer. Supported living
profiles are the retained human male reference skin/face/hair, sword and shield,
with no modeled armor layer. Unsupported armor/appearance keeps the existing
pilot body; unsupported body or attachments retain the existing sprite fallback.
The ordinary player and accepted default presentation are not replaced.

Actual persistent equipped clothing IDs select the 25 retained #829 garments.
Four cached object references are resolved only after an ID change, inventory
change or load; every use verifies identity, owner, kind, region, equipped and
Box state. Rebinding occurs only when selection or transient bindings change.
No per-tic inventory walk or global actor scan is introduced. Stats, item
creation, ownership, eligibility, weight, durability, collision, resources and
combat stay in their existing native owners.

Presentation revision1 initializes idempotently. Object references/binding
readiness are transient; chosen appearance and the last legitimate death outfit
are saved. Native hub travel reconstructs the local visual body. The activation
CVAR is nosave/noarchive: enable it explicitly for candidate inspection/loading.
To return a candidate save to the earlier build, disable the CVAR, allow the
native visual cleanup to run, then save; rollback of that cleaned save is tested.
Do not load a save retaining the new visual actor directly into the older build.
'''
history=contract+f'''
Eleven canonical native runs produce {d['canonical_passes']} passing assertion
lines, including {d['final_package_passes']} on the final package. Counts exclude
inherited totals serialized in the diagnostic handler. Coverage includes all25
equip/unequip/replacements, native drop/Box/chest operations, stale-owner rejection,
unsupported combinations, old-save upgrade, reload, hub roundtrip, disabling,
old-build rollback and native walk/run/attack/guard/jump/landing. Death and dead
reload use GZDoom's -host1 mode (cooperative with one player, no network peers):
ordinary single-player correctly refuses saving a dead player. Failed fixture
attempts and their actual causes remain archived, not counted as passing tests.

Direct captures found a generation defect missed by pose/ownership assertions:
GZDoom snapshots the full current model-frame array at each FrameIndex line.
Appending accessory entries after all body frames overwrote 5,610 body-slot
bindings across374 states with body frame374. The final generator emits all17
slots together for every one of375 states and checks the engine's accumulation
semantics. Corrected native captures restore body/accessory pose agreement.
The original failed captures/runtime and their measurements remain explicit
rejected evidence. The retained hands are still relaxed construction meshes;
item-specific grips/remaining attachment coverage continue under #859/#462.
No geometry, texture, native animation timing or accepted source is edited here.

The final package has {d['scope']['members']} members, each byte-identical to src.
It changes six existing members (including two release diagnostic strings) and
adds three presentation/data members. All other packaged members, including
geometry/textures, are exact. Source generation is deterministic. The final
gameplay/binding files match prototype06. Build SHA256:
{d['scope']['runtime_sha256']}.

Eight paired one-player captures compare the existing seven-module body with
the equipped candidate in the studio and campaign entrances. The four affected
candidate captures were repeated after the binding correction; original control
captures are reused because they never use the changed candidate definition.
GZDoom4.14.2, Ryzen9 5950X, RTX3070Ti, unpaused background and5% audio are recorded.
No heavy build/validator/hash runs overlap the measurement windows. The first
scope audit ended at22:37:59UTC; the corrected studio window began at22:38:07UTC.

'''+table+'''
Queue presents are not monitor scanout. Tic intervals include pacing and frame
work, not isolated simulation CPU cost. These are one equipped player's fixed
views, not a crowd, combat, full-map traversal or siege result. Mansion retains
the opening dialogue; sewer and city entrances are inspected with unchanged
world rules. Siege performance remains unresolved. Native tests and draft PR
delivery do not confer author acceptance. Evidence: assets/validation_v5_17_107;
author check CA857-EQUIPMENT-01 is deferred to the consolidated terminal.
'''
sections={
 'HISTORY.md':history,
 'SYSTEMS.md':contract+'\nThis is presentation-only review work. The four clothing regions and all25\nexisting item identities remain authoritative. #859 retains item-specific grip\nreview; no new weapon/armor fit, species or balance is authorized by this switch.\n',
 'ASSETS.md':'''The #857 candidate connects actual native equipped items to the existing
#827/#829 first-body modules, coverage masks and trouser hems. All geometry,
textures, provenance and accepted default modules remain exact. Generated
CaelumWornClothingModelData and wardrobe_candidate.modeldef use the canonical
clothing IDs and existing DESIGN/VISIBILITY sources; their portable deterministic
generator and native evidence live in assets/validation_v5_17_107.

Contiguous17-slot FrameIndex groups correct the failed append-only accessory
binding. Native corrected pose captures are reviewed; relaxed construction hands
still need item-specific grip coverage under #859/#462. Reference appearance,
sword/shield and no-armor limits remain explicit. No #736 proposal or broad
species conversion is accepted. Final consolidated visual acceptance is pending.
''',
 'PROJECT.md':f'''The default-off first-body wardrobe now follows actual native owned clothing.
{d['canonical_passes']} canonical native assertion lines pass ({d['final_package_passes']}
on the final package), including equipment/ownership and reversible save/hub
continuity. The native frame-order defect is corrected; item-specific hand/grip
work continues in #859. HISTORY records fixed-view presentation/frame/tic tails
and limitations. This is a reviewable opt-in candidate, not a default character
conversion or author acceptance. Complete the remaining authorized batch before
opening the consolidated test terminal.
''',
 'TASKS.md':'''Completed #857 equipment authority binding, bounded invalidation, revisioned
presentation, native ownership/save/hub/rollback tests, corrected frame grouping,
deterministic package proof and paired one-player presentation evidence.
Continue #859/#462 item-specific hands/grips and remaining authorized character,
equipment/scenery and V5.16 work. Existing unauthored design decisions and #736
visual approval remain pending. Preserve every outstanding author check and
deliver the single consolidated terminal only after the batch is worked.
'''}
for name,body in sections.items():
    path=root/'docs'/name;source=path.read_text(encoding='utf-8');at=source.index('\n\n',source.index('Documentation version:'))+2
    assert heading not in source;path.write_text(source[:at]+heading+body.strip()+'\n\n'+source[at:],encoding='utf-8',newline='\n')
path=root/'README.md';source=path.read_text(encoding='utf-8');at=source.index('\n\n#855')
source=source[:at]+'''\n\n#857 adds a default-off first-body wardrobe driven by actual equipped clothing.
Native ownership/save/hub/reversal checks and corrected frame bindings are
recorded in docs/HISTORY.md and assets/validation_v5_17_107. Item-specific grips
continue in #859; character conversion and consolidated author acceptance remain
pending. Existing default presentation is retained.'''+source[at:]
path.write_text(source,encoding='utf-8',newline='\n')
path=root/'docs/CONTEXT.md';source=path.read_text(encoding='utf-8')
source=source.replace('#847:sewer candidate;#851:local reach verified;#853:breath diagnosis;#855:recognition verified; acceptance pending.','#847:sewer candidate;#851:reach;#855:recognition;#857:equipped wardrobe verified;#859:grips pending.')
path.write_text(source,encoding='utf-8',newline='\n')
path=root/'docs/KNOWN_PITFALLS.md';source=path.read_text(encoding='utf-8');at=source.index('## CA-KP-264')
lesson='''## CA-KP-265 - MODELDEF frame entries snapshot every model slot

Status/evidence: VERIFIED CORRECTION in 5.17.107 / #857, GZDoom4.14.2,
2026-11-19. Actual-equipment pose captures and native engine source; author
acceptance and item-specific grip review #859 remain pending.

Symptom: the owner selected correct native poses and item IDs, but its fitted
body stayed at the final pose while sword/shield animated independently.
Cause: FrameIndex updates one slot in a running FSpriteModelFrame, then pushes
a copy of the entire structure. Later entries for the same sprite/frame win.
Appending accessory entries after the375 body frames therefore retained frame374
in the first15 slots of earlier states (5,610 wrong slot assignments).

Fix: emit every model slot contiguously per sprite/frame. Validate final resolved
arrays using engine accumulation semantics, not just line counts/pose IDs. The
new generator checks all17 slots across375 states; corrected captures confirm
body/accessory agreement. No mesh/rig changes were needed for this failure.
Retain the rejected native captures and data so a later art task does not try to
compensate for a binding defect in geometry. Relaxed finger grips remain a
separate fit limit, not proof that the binding correction failed.

References: src/r_data/models.cpp in native GZDoom4.14.2 (FrameIndex parsing,
SpriteModelFrames hash and FindModelFrameRaw); portable generator and evidence
in assets/validation_v5_17_107; #857 and #859. Recheck this rule when adding model
slots or changing animation definitions. Pose assertions alone are insufficient.

'''
assert '## CA-KP-265' not in source;path.write_text(source[:at]+lesson+source[at:],encoding='utf-8',newline='\n')
path=root/'pending_test.txt';source=path.read_text(encoding='utf-8');assert 'CA857-EQUIPMENT-01' not in source
source+='''\nCA857-EQUIPMENT-01 | Origin 5.17.107 / #857 (parents #459/#462) | Pending
Prerequisites: the final consolidated batch terminal; complete runtime and existing Domingo candidate. Review after the remaining equipment/grip work; no intermediate handoff is requested.
Steps: enable the equipped first-body candidate, change each native clothing region, replace/unequip/re-equip garments and use native Box/coffer/drop operations. Compare supported clothing against armor/appearance fallback. Save/load, change maps and return. Disable the candidate before making a separate rollback save for an older build.
Expected: the visible selection follows the actual owned/equipped object without changing inventory identity, stats, collision or resources; load/travel reconstructs the same outfit and disabling restores the existing presentation. Inspect attachments through the later equipment review. This check does not accept other bodies/species, first-person equipment, unmodeled armor, performance or the complete batch.
'''
path.write_text(source,encoding='utf-8',newline='\n');print('Consolidated107 status/evidence and pending author check written; full validation pending.')
