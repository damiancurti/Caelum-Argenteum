"""Record the shared clothing-hand extension and preserve every prior section."""
from pathlib import Path
root=Path('C:/GZDooMProjects/CaelumArgenteum/build/v517/work-713')
title='## 5.17.109 - Select shared hand art from actual clothing gloves (#861)\n\n'
sections={
'SYSTEMS.md':'''The shared hand selector now accepts either legitimate worn hand armor or
the actual worn GF/GC/GW/GP clothing item. The historical #148 implementation
was armor-only; this is an explicit scope extension, not a retroactive claim
that the documented old rule was broken. Outer armor retains precedence.
An item must belong to the current player, match its equipped native ID and
hand region, have the correct kind/type, be equipped and remain outside Box.
Broken but still worn gloves retain their visual presence. No defense, weight,
durability, resource, collision, targeting or combat rule changes.

Five transient cache declarations retain the persistent record and two possible
hand-layer references. Cold access reads the existing record directly without
invoking its general migration accessor. Equipment-ID changes or the existing
native inventory event refresh references; each use still validates the actual
record/item owner and identity. Load reconstructs the unsaved references. No
new saved gameplay fields, classes, schema or migration are introduced; native
upgrade/reload/hub/death and direct older-build rollback remain supported.

First-person layers, world appearance, appearance preview and new Moon clones
use the same selector. Death and existing clones retain their saved creation
snapshots: upgrading an old bare-hand corpse does not retroactively glove it.
The existing male/female shared glove artwork, bare skin/fur variants, weapon
pivots and animation clocks remain unchanged. Material-specific glove imagery
is separate artwork. CA861-HANDS-01 remains pending consolidated author review.
''',
'ASSETS.md':'''#861 connects the four actually worn clothing glove types to the retained
shared male/female glove artwork. It adds no image, model, frame, pivot or pose.
The male padded brown glove and distinct female brown glove are the existing
shared resources; they do not depict each GF/GC/GW/GP material individually.
Bare skin/fur remains selected when no legitimate hand layer is worn. The
opt-in #857/#859 full-body garment and grip candidates remain separate.

Native sword idle/attack/guard/restored, carbine reload, composed staff charge,
world/preview and save/death captures are retained in assets/validation_v5_17_109.
Its review.html is a capture gallery for the eventual consolidated review,
not an intermediate author handoff. Existing carbine reload framing leaves
much of the hands below the image; layer-state checks do not prove complete
visual contact. No author acceptance or material-specific art is claimed.
''',
'PROJECT.md':'''The focused #861 shared-hand extension is implemented using actual owned
clothing gloves and the existing artwork. Native ownership, shared consumers,
first-person actions and saved-state continuity are verified; transient caches
avoid warm inventory walks. HISTORY and assets/validation_v5_17_109 record exact
evidence and performance limits. CA861-HANDS-01 remains pending.

This completes a defined #462 integration step. The broader character, equipment,
scenery and siege-performance work remains open, including material-specific
and other-body art. #736 proposals are unapproved. The author requested one
consolidated test terminal after the remaining batch; no intermediate approval
is inferred from native checks or a draft PR.
''',
'TASKS.md':'''Implemented the explicit extension from historical armor-only hand selection
to actual clothing gloves, retaining outer-armor priority and shared male/female
art. Verified native ownership, replacement/drop/Box/chest, save/hub/death,
preview/Moon consumers and representative first-person action clocks. Transient
references reconstruct after load; no saved schema or gameplay values change.

CA861-HANDS-01 remains in the single author queue for the final consolidated
terminal. Continue the broader #462/#459/#458 and #463/scenery/performance scope;
the existing shared glove image does not complete material-specific first-person
art, other-body equipment or #736 approval. Preserve all prior author checks.
''',
'HISTORY.md':'''The historical #148 contract selected gloves from armor only. #861 explicitly
extends selection to actual GF/GC/GW/GP clothing, following #857's equipped
wardrobe and #859's fitted grips. This patch changes three gameplay source
members plus two release diagnostic strings. The complete18,767-member runtime
matches src;18,762 prior members are byte-identical, with no members added or
removed. All existing textures, poses, pivots and equipment rules are unchanged.
Runtime SHA256:8fcef709b7615d6dd6f808f1de6e46a37718b97b0d35ecf1d6568eb66de7a574.
The three-member final prototype matches the runtime exactly.

Five new declarations are transient only. The native saved JSON omits them and
retains the existing death-glove snapshot. Warm use validates owner/ID/kind/
region/equipped/Box state without traversing inventory. The clothing record is
read directly: the general GetPersistentCharacterState(false) accessor also
executes unrelated schema checks and is deliberately not used by rendering.
Native inventory changes invalidate references, including same-ID replacements.

NATIVE861_PENDING

Five instrumented1000-call batches cover bare, clothing, armor over clothing,
armor only and bare after inventory events. All5000 warm results agree and
perform zero record/item lookups. Cold counts are respectively1/0,1/1,0/1,0/1,
1/0 (record/item). The51 counter assertions pass. Timers include diagnostic
instrumentation; they do not establish production frame cost. A portable overlay
rebuild is byte-identical to the tested counter overlay; counters never enter src.

Rejected fixture attempts remain explicit: an old command name ran no checks;
an initial hub sequence lacked settled map transitions; map-local handler fields
required a diagnostic traveling witness; and a sword-hand assertion incorrectly
expected layer52 during frontal shield guard. The accepted guard intentionally
clears sword layers and retains shield44/left hand45. The corrected test checks
that existing rule. One later compile attempt collided diagnostic placeholder
names; unique placeholders resolved it before execution. No gameplay change was
made to satisfy these fixture errors. Prototype01's general record accessor is
superseded by prototype02's direct read. Raw failures remain archived separately.

PERFORMANCE861_PENDING

Direct visual review records only explicitly viewed image paths and hashes.
Shared brown glove art is not a material-specific representation of all four
clothing types. Carbine reload framing leaves much of each hand below the image;
successful native layer checks are not complete hand-contact evidence. No art,
combat clock, resource amount or existing saved snapshot is rewritten. The
broader artwork/performance batch and author acceptance remain open. Review
CA861-HANDS-01 at the requested final consolidated terminal.
'''}
for name,body in sections.items():
 p=root/'docs'/name;s=p.read_text(encoding='utf-8');assert title not in s;i=s.index('\n## ')
 p.write_text(s[:i]+'\n'+title+body.strip()+'\n'+s[i:],encoding='utf-8',newline='\n')
p=root/'README.md';s=p.read_text(encoding='utf-8');i=s.index('\n#859 fits')
s=s[:i]+'''
#861 connects actual clothing gloves to the existing shared first-person,
world and preview hand art. Ownership/save/action checks and frame measurements
are recorded in docs/HISTORY.md and assets/validation_v5_17_109. The capture
gallery is assets/validation_v5_17_109/review.html. Material-specific art and the
broader batch remain open; author review stays at the final consolidated terminal.
'''+s[i:];p.write_text(s,encoding='utf-8',newline='\n')
p=root/'docs/CONTEXT.md';s=p.read_text(encoding='utf-8');s=s.replace('#859:grips verified.','#859:grips verified;#861:actual clothing hand selection verified.')
p.write_text(s,encoding='utf-8',newline='\n')
p=root/'docs/KNOWN_PITFALLS.md';s=p.read_text(encoding='utf-8');i=s.index('\n## ')
lesson='''
## CA-KP-265 - Keep hand-layer ownership checks live while caching references

Status/evidence: CODE-VERIFIED and ENGINE-VERIFIED, #861 /5.17.109,
2026-11-19, GZDoom4.14.2. Native verification is not author acceptance.

Armor and clothing keep distinct equipped-ID sources. Extending an armor-only
visual selector requires resolving the actual clothing record/item, not treating
a glove-type flag or any inventory copy as worn. Cache clean absence and bounded
references, invalidate them through existing native inventory events, compare
current IDs, and validate record/item ownership plus item kind/region/equipped/
Box state every use. This rejects stale, destroyed and foreign objects while
retaining broken-but-worn visual presence. Same-ID replacement needs the event.

Use the narrow read path for presentation. Here the general persistent-state
accessor executes four unrelated schema checks even with create=false. The
selector instead reads and validates the existing native inventory record.
Five transient declarations avoid a save-schema change; actual saved JSON
contains none of them. Old save/reload/hub, native death and direct rollback
verify reconstruction, while prior corpse/clone glove snapshots remain intact.
Five1000-call warm batches perform zero inventory reads; measure production
presentation separately from counter-instrumented microbenchmarks.

Match diagnostic assertions to the renderer's actual contract: frontal shield
guard clears sword layers46..53 and retains shield44/left hand45. Assert that
selection rather than requiring a duplicate sword hand. Map-local EventHandler
fields also reset on fresh hub maps; carry diagnostic reference data in a
traveling inventory witness instead of mistaking handler reset for item loss.

Evidence: assets/validation_v5_17_109; SYSTEMS shared-hand extension. Existing
art/pivots/clocks are unchanged and material-specific glove art remains separate.
'''
assert '## CA-KP-265 ' not in s;p.write_text(s[:i]+lesson+s[i:],encoding='utf-8',newline='\n')
p=root/'pending_test.txt';s=p.read_text(encoding='utf-8');assert 'CA861-HANDS-01' not in s
s+='''
CA861-HANDS-01 | Origin 5.17.109 / #861 (parent #462) | Pending
Prerequisites: the final consolidated batch terminal and full runtime; preserve original saves. Capture gallery: assets/validation_v5_17_109/review.html. This uses the existing shared male/female glove art, not new material-specific imagery.
Steps: equip each actual GF/GC/GW/GP clothing glove, compare bare hands and outer hand armor, then replace/unequip/re-equip and use Box/chest/drop. Check sword rest/attack/guard, carbine reload, staff charge and the appearance preview for male/female profiles. Save/reload and travel between maps. Compare a newly created Moon clone and a separately saved corpse with their original appearance.
Expected: visible hands follow actual owned/worn layers; bare skin/fur returns when neither layer is worn. Existing clone/corpse snapshots remain intact. Equipment identity, resources, timing and weapon pivots stay unchanged. Report visual/material concerns separately; this does not accept #736, all equipment art, siege performance or the complete batch.
''';p.write_text(s,encoding='utf-8',newline='\n')
p=root/'.gitattributes';s=p.read_text(encoding='utf-8');s+='''
# Shared hand-selection sources and native evidence (#861).
assets/validation_v5_17_109/** -text -diff
assets/validation_v5_17_109/*.py text eol=lf diff
assets/validation_v5_17_109/*.zs text eol=lf diff
assets/validation_v5_17_109/*.json text eol=lf diff
assets/validation_v5_17_109/*.txt text eol=lf diff
assets/validation_v5_17_109/*.html text eol=lf diff
''';p.write_text(s,encoding='utf-8',newline='\n')
print('Consolidated109 sections and one pending author check added; native/performance summary awaits final records.')
