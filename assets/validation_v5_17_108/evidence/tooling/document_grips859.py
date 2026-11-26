"""Document the finite grip correction without retiring historical evidence."""
from pathlib import Path
import json
root=Path('C:/GZDooMProjects/CaelumArgenteum/build/v517/work-713')
title='## 5.17.108 - Fit first-body hands and retained equipment across native poses (#859)\n\n'
sections={
'ASSETS.md':'''Eight separate MD3 variants provide closed left/right hands, GF/GC/GW/GP
gloves and rigidly fitted retained sword/shield for the opt-in #857 wardrobe.
The original modules, textures and editable sources remain unchanged. Source,
visual fitting data and provenance: assets/source/art/grips_859. The canonical
Blender4.5.3 container is retained; independently rebuilt authoring sources
produce byte-identical native exports. This does not claim identical .blend
container bytes across saves. The three assets/generators/*equipment_grip*
tools author, export and bind the variants; native evidence is in
assets/validation_v5_17_108. The gallery links directly to final native captures.

Finger landmarks come from the retained CC0 anatomy. Editable helper bones
close the fingers around the existing handles; shared wrist positions and
native rig weights are retained. Gloves use the original shell offsets and UVs.
All375 original samples/24 actions keep their timing. Exported attachment
transforms compensate the independent equipment rotation, including running.
All eight files retain their original vertex/triangle counts, UVs and byte
lengths. The shield includes its evaluated Solidify back geometry. No extra
runtime actor, texture, model slot or gameplay rule is introduced.

This is a finite reference-body grip candidate. Flat construction skin, angular
hands/wrist shading, original clothing/face/hair and death-pose limits remain
visible; it is not final skin, other weapons, first-person equipment, other
bodies/species or approval of #736. Review CA859-GRIP-01 in the consolidated
author session. Existing default presentation is unchanged.
''',
'SYSTEMS.md':'''The default-off ca_wardrobe_candidate now uses the #859 hand/glove and
sword/shield variants in its five existing affected model slots. Its #857
reference-profile eligibility, actual inventory ownership and fallback rules
remain authoritative. This patch adds no classes, saved fields, revision or
migration; revision1 wardrobe state and native equipment identity remain intact.
Item weight, durability, resources, collision, actions and combat are unchanged.

Old candidate saves, reload, disabled presentation, cleaned rollback and the
retained death outfit were checked with the final runtime. The original
seven-module presentation remains available. Bare hands and all four equipped
glove types keep contact through native walk/run/attack/guard/jump/landing/death
checks. Visual approval remains CA859-GRIP-01 at the final consolidated terminal.
''',
'PROJECT.md':'''The finite #859 grip correction is implemented for the opt-in equipped
reference body: two hands, four glove variants and the retained sword/shield.
All original assets/default presentation and equipment gameplay stay intact.
Independent exports match, model/frame budgets are preserved and native
equipment/save/reversal checks pass. HISTORY records exact test counts,
rejected evidence, measurements and limits; assets/validation_v5_17_108 retains
the artifacts. CA859-GRIP-01 remains pending consolidated author acceptance.

This completes this focused attachment implementation, not the wider character,
equipment, scenery or performance batch. Other bodies/species, first-person
equipment and unauthored coverage remain under their parent issues. #736 visual
approval and all outstanding author checks remain deferred to the final session.
''',
'TASKS.md':'''Implemented the finite sword/shield contact correction following #857's
separate frame-binding fix. Closed bare hands and four glove shells retain the
original rig samples, equipment geometry budgets, UVs and wrist seams. Native
pose, ownership, upgrade/reload/disable/rollback/death checks pass; final paired
presentation results and remaining visual limits are recorded in HISTORY.

Author check CA859-GRIP-01 remains pending. Continue the authorized broader
#462/#459/#458 and scenery/performance work without treating this candidate or
the unapproved #736 proposals as production conversion approval. The requested
single test terminal follows the remaining batch; no partial author handoff.
''',
'HISTORY.md':'''#859 follows the corrected #857 frame bindings and fits the retained equipment
to closed first-body hands. Eight new MD3 files and a provenance notice are
added. Only the two candidate binding/data files and two release diagnostic
strings change among existing runtime members; all18,754 other members are
byte-identical to5.17.107. All18,767 final package members match src. The ten
prototype members match the final package exactly. Runtime SHA256:
7aa0a9c8e11ccf878ce099142b29a5b9fbc3c9d1a03e11f139677ff6287a226e.

The retained Blender4.5.3 authoring source is independently reconstructed.
Both sources produce identical native exports. The editable .blend container
itself is not asserted byte-reproducible. Existing anatomical finger landmarks
drive editable construction bones; shared wrist positions and native weights
are preserved. Four glove shells use their original offsets and UVs. Rigid
sword/shield placement and compensated sample transforms preserve contact even
when the original Run action rotates the sword independently from the hand.
All375 samples,24 actions,17 model slots and FrameIndex directives remain.
23,625 quantized seam comparisons and1,057,500 rigid-grip vertex checks pass;
fitted-center error is zero before native quantization.

An independent serialized-model comparison caught a rejected export defect:
raw mesh topology omitted25 shield vertices/72 triangles from the evaluated
Solidify result, although native assertions had passed. Final topology, UVs
and sampled positions all come from the evaluated mesh. The restored shield
has1,748 vertices/2,124 triangles. All eight final modules retain the original
counts, UVs and byte lengths; the six equipment/glove triangle arrays are exact.
Bare-hand vertex ordering is reindexed, preserving the same topology. Existing
CA-KP-254 is extended with this recurrence; rejected native images/builds remain
explicitly rejected evidence and are not reused as final qualification.

Thirteen canonical native runs produce517 passing assertion lines:503 on the
final package and14 on the previous-build rollback. Coverage includes bare/GF/
GC/GW/GP motion, fresh state, prior candidate save, reload, disabling, rollback,
death/dead reload and281 ownership assertions. The five motion runs additionally
match all55 captured poses against native traces. Six corrected close-camera
runs add120 native assertions and66 capture/pose matches. Counts use actual
PASS lines per process, excluding inherited EventHandler counters. Death uses
native -host 1 mode because single-player correctly refuses dead-player saves.
No save classes/fields, gameplay logic, resources, collision, rig timing or
equipment rules change. The original default seven-module body is retained.

Direct visual review covers native walking/running, attack, guard, jump,
landing, death and bare/four-glove grips. The exact viewed-image list and hashes
are retained; captured-pose assertions do not claim every image was inspected.
Source studies and misframed camera attempts remain labeled separately. The
correct close camera accounts for native CameraHeight and MD3 level.pixelstretch.
One oblique close guard image leaves the hand outside the view; the canonical
front guard image is usable. That oblique image is not grip-contact evidence.
The initial static-array diagnostic camera aborted; its exact engine/compiler
cause was not isolated. The replacement uses a literal sampled-anchor switch.

Flat sampled construction skin, angular hand/wrist shading and the original
clothing, face, hair and death-pose limitations remain visible. This correction
does not establish final art, first-person equipment, other bodies/weapons or
#736 approval. CA859-GRIP-01 remains in the outstanding author queue. All author
acceptance and the requested test terminal remain deferred to the final batch.

PERFORMANCE859_PENDING
'''}
for name,body in sections.items():
 p=root/'docs'/name;s=p.read_text(encoding='utf-8');assert title not in s
 i=s.index('\n## ');p.write_text(s[:i]+'\n'+title+body.strip()+'\n'+s[i:],encoding='utf-8',newline='\n')
p=root/'README.md';s=p.read_text(encoding='utf-8');a=s.index('#857 adds');b=s.index('\n#855',a)
s=s[:a]+'''#859 fits closed hands and four glove variants to the retained sword/shield
across the first-body candidate's native poses. Deterministic exports,
equipment/save/reversal evidence and presentation measurements are recorded in
docs/HISTORY.md and assets/validation_v5_17_108. Gallery:
assets/source/art/grips_859/review.html. The #857 equipment authority and default
presentation remain unchanged. Broader work and consolidated author review
remain pending.
'''+s[b:];p.write_text(s,encoding='utf-8',newline='\n')
p=root/'docs/CONTEXT.md';s=p.read_text(encoding='utf-8').replace('#859:grips pending.','#859:grips verified.');assert len(s.split())<=2500;p.write_text(s,encoding='utf-8',newline='\n')
p=root/'docs/KNOWN_PITFALLS.md';s=p.read_text(encoding='utf-8');i=s.index('\n## CA-KP-253')
s=s[:i]+'''
#859 recurrence (CODE-VERIFIED and ENGINE-VERIFIED, 2026-11-19): a grip exporter
used raw topology with evaluated positions. That omitted25 vertices/72 triangles
of the shield's Solidify back despite passing native pose assertions. Compare
serialized counts, UVs and expected module byte lengths against the retained
reference, and derive topology/UVs/positions from the same evaluated mesh. The
corrected shield restores1,748 vertices/2,124 triangles; all eight finite modules
retain their original budgets and independently rebuilt exports are identical.
Evidence: assets/validation_v5_17_108. Native screenshots alone cannot establish
complete modifier output; source arithmetic alone cannot verify serialized data.
'''+s[i:];p.write_text(s,encoding='utf-8',newline='\n')
p=root/'pending_test.txt';s=p.read_text(encoding='utf-8');assert 'CA859-GRIP-01' not in s
s+='''
CA859-GRIP-01 | Origin 5.17.108 / #859 (parent #462) | Pending
Prerequisites: the final consolidated batch terminal, full runtime and opt-in reference human-male sword/shield candidate without armor. Preserve original campaign saves. Source/capture gallery: assets/source/art/grips_859/review.html.
Steps: inspect bare hands and all four actually equipped glove kinds, from front/back/sides, during idle, walking, running, attack, guard, jump/landing and death. Inspect both sword and shield contact and wrist seams. Save/reload, disable the candidate, then create a separate cleaned rollback save before comparing the earlier build.
Expected: the existing equipment stays attached to the closed hands through those poses; native inventory identity, weight, durability and gameplay remain intact. Report contact/clipping and shading concerns separately from the retained construction skin, original rig/body/garment limitations and first-person or other-body work. This does not accept #736, the wider equipment scope or the full batch.
''';p.write_text(s,encoding='utf-8',newline='\n')
print('Added focused108 status; performance and full validation still pending.')
