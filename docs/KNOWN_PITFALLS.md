# Known pitfalls and verified lessons — Caelum Argenteum

Status: integrated engineering register (issue #22, patch 4.36.1b).
Prepared: 2026-09-23. Inherits the project's release after integration.
Inspected baseline: `1dc390576fa330d37ff543526fc7e69a397fc28f` (PR #7).

## CA-KP-027 — Terrain relief can invalidate absolute-height relocation filters

Status/evidence: AUTHOR-REPORTED / CODE-VERIFIED / ENGINE-VERIFIED, #61 / PR #66.
First recorded / last checked: 2026-10-01 / 2026-10-01.
Affected baseline: 00e4322d; repair: subsequent station-relocation change in
PR #66, exact source/package hashes in assets/validation_4370/STATIONS.json.
Environment: GZDoom 4.14.2, Windows 11, Vulkan, development Doom II IWAD,
fresh MAP01 and isolated native fixture.

Six original stations remained outdoors at Y=1040 while their replacements
appeared inside, yielding 44 stations instead of 38. Their former flat staging
row now sits on hills at Z=1.08..3.30. PlaceStation and PrepareMansionLayout's
spare fallback required Abs(Pos.Z)<1, so both missed the grounded originals.
The map's original thing records were unchanged; that invariant alone could
not verify runtime relocation after a terrain change.

Both filters now compare Pos.Z with native FloorZ, retaining the existing XY
bounds, class and unassigned-group restrictions. Do not simply expand a magic
absolute Z range when the intended condition is standing on the local floor.
The fix reuses original actors and the existing destinations without deleting
stations, introducing recipes or changing saved fields.

Regression: native WorldLoaded captures all eighteen original references.
After preparation there must be 38 stations, none outside, groups 5/7/5/9/12,
and all originals retained. Test each station's network and physical access;
repeat preparation and save/reload to check identity and duplication.
Evidence: [station repair](../assets/validation_4370/STATIONS.json).
Author acceptance: CA-4370-STATIONS-01 confirmed 2026-10-01. Already prepared older worlds
are outside this fix under the author's explicit old-save waiver.

## CA-KP-026 — Detached control rooms must remain outside playable geometry

Status/evidence: AUTHOR-REPORTED / CODE-VERIFIED / ENGINE-VERIFIED, #61 / PR #66.
First recorded / last checked: 2026-10-01 / 2026-10-01.
Affected baseline: fe506a3e; fix: the subsequent control-relocation change in
PR #66, with exact source hashes in assets/validation_4370/CONTROLS.json.
Environment: GZDoom 4.14.2, Windows 11, Vulkan, development Doom II IWAD,
fresh MAP01, no autoload, isolated test fixture.

At (25630.19,29408,0), facing yaw 19.34, the engine selected auxiliary sector
539 and rendered black space with an isolated stone pillar. The author also
reported an invisible boundary. Sixty-nine detached original auxiliary polygons
intersected or touched the playable horizon; 63 were wholly inside it. Their
one-sided untextured walls do not form valid exterior holes with shared sides.
Checking only the outer boundary and sector references missed this topology.

CONTROL_RELOCATION.json identifies those polygons. mansion_control_relocation.py
translates only their vertices into an unused off-map grid, preserving control
lines and complete sector records. For models with explicit world-space planes,
preserve the plane coefficients; moving their coordinates alone must not shift
the target floor. The independent validator checks every 3D-floor model's bounds,
non-overlap and preserved data. Native before/after height samples catch effects
that an offline parser cannot establish.

Evidence: [control repair](../assets/validation_4370/CONTROLS.json), matched
reported views, 750 region samples/3,000 moves, 64 former room centres, actual
player traversal, 840 identical mansion surface samples and 429 door checks.
The black region is absent in the final views. This does not establish the
cause of the earlier oversized-floor defect in CA-KP-024 or cover every camera.
Author accepted this repair as CA-4370-EXTERIOR-01 on 2026-10-01.

## CA-KP-025 — Normalize all four coefficients of generated UDMF planes

Status/evidence: CODE-VERIFIED / ENGINE-VERIFIED, #61 / PR #66 / 4.37.0.
First recorded / last checked: 2026-10-01 / 2026-10-01.
Baseline: 3277ab2f plus the decorative-cave working tree; GZDoom 4.14.2,
Windows 11, Vulkan, fresh MAP01 and an isolated native fixture.

In the new cave near (23268,23285), writing an algebraically correct plane
with normal (-gx,-gy,1) produced the wrong native height: an intended Z=-32
ramp point reported about Z=221.31. Normalising A, B, C and D by the normal's
length corrected the same point to -32 and restored the continuous mound.
An offline ZatPoint calculation alone had passed because it evaluated the
raw coefficients, not the engine's loaded representation.

mansion_decorative_cave.py normalises its generated floor and roof planes.
validate_mansion_cave.py checks unit normals and authored vertex heights; the
native fixture independently samples all 1,152 new floor triangle centres.
Keep this native check for distant geometry, where a small coefficient error
can cause a large vertical displacement. This finding does not reinterpret
the already accepted mansion relief; the new cave generator is its scope.

Evidence: assets/validation_4370/CAVE.json and its retained diagnostic/final
logs. Original reports and failed local trials remain available separately.
New cave author acceptance CA-4370-CAVE-01 was confirmed on 2026-10-01.

## CA-KP-024 — A valid oversized floor can disappear in the renderer

Status/evidence: AUTHOR-REPORTED / ENGINE-VERIFIED, #61 / PR #66 / 4.37.0.
First recorded / last checked: 2026-10-01 / 2026-10-01.
Baseline: 30caa726 and f69e6f7e; GZDoom 4.14.2, Windows 11, Vulkan,
RTX 3070 Ti, author-installed development Doom II IWAD.

The author reported transparent exterior ground at (17455,7394,0). Native
PointInSector still identified sector 0 with floor Z=0, and its CMGR01A texture
was valid. The same view failed in the preserved baseline. Static texture and
collision checks therefore did not detect the visible defect. Removing the
horizon special, reducing the sky ceiling and splitting only long boundary
lines each failed to repair the rendering; an isolated bounded sector rendered.

The first correction partitioned the 60000-MU-wide exterior into nine bounded regions
with flat, two-sided internal joins. Existing terrain stays in the central
sector and original horizon extent/blocking remains. The reported point now
renders grass. This establishes a geometry-dependent failure and a verified
workaround, not a universal size limit or an identified internal renderer bug.
Retain native before/after captures, inspect distant views in addition to the
mansion, and verify that new joins preserve heights and traversal.

The author accepted that point's repair but later reproduced the defect near
(23268,23285,0). Sampling only region centres had missed it. The follow-up uses
25 regions and checks positions near all four corners and edge midpoints as
well as the reported locations. Do not generalise a few successful views into
a guarantee that the complete oversized exterior renders correctly.

Evidence and exact geometry: assets/validation_4370/FOLLOWUP.json, CAVE.json and
assets/map01_mansion/EXTERIOR.json. Original CA-4370-MANSION-01 is author-accepted;
CA-4370-CAVE-01 was subsequently accepted on 2026-10-01. The later distinct
auxiliary-room defect and its pending repair are covered by CA-KP-026.

## CA-KP-023 — OBJ height and map headroom use different vertical scales

Status/evidence: CODE-VERIFIED / ENGINE-VERIFIED, #61 / 4.37.0.
First recorded / last checked: 2026-10-01 / 2026-10-01.
Baseline: accepted MAP01 at 30caa726, Windows 11, GZDoom 4.14.2, Vulkan,
RTX 3070 Ti, development Doom II IWAD. The author accepted the general doorway
checks and subsequent roof-front correction on 2026-10-01.

Symptom: the accepted 120-unit mansion door OBJ leaves a visible upper gap even
when its actor blocker and nominal map opening both reach 120 MU. GZDoom's
model transform divides non-voxel height by the map pixel stretch; at MAP01's
1.2 ratio, the visible leaf ends at 100 MU. Actor collision is independent.

For the fixed #61 tympana, measure from that rendered top to the existing slab
underside. Their MODELDEF Z scale of 1.2 makes newly authored mesh heights match
map units. Fill the complete rectangular backing, including corners outside the
triangular/arched inset. Preserve the accepted leaf, its sweep and blockers.
Group faces into bounded material surfaces as described in CA-KP-020.

Evidence: assets/validation_4370, EXTERIOR.json, generated tympanum meshes and
native closed/open views from both sides. Reference: GZDoom g4.14.2
[models.cpp](https://github.com/ZDoom/gzdoom/blob/g4.14.2/src/r_data/models.cpp),
model transform around lines 143-192. This evidence establishes this map/model
combination, not a universal scale for sprites, voxels or other map ratios.

## CA-KP-022 — A magic-resource wait can strand an otherwise mobile army

Status/evidence: AUTHOR-REPORTED / CODE-VERIFIED / ENGINE-VERIFIED.
First recorded / last checked: 2026-09-30 / 2026-09-30.
Issue #16, baseline 2440558f; Windows 11, GZDoom 4.14.2, Vulkan, fresh MAP06.

The author reported mostly stationary enemies inside the port army. A native
probe separated motion over 175 tics from attack state and resource wait:
after 700 tics, 713 attackers waited for Anima despite having Air available.
The accepted #37 AttackResourceWait stops movement until the attempted attack
is affordable. That behavior was unsuitable for the port army's magic/melee
choice; it was not evidence that the mass scheduler disabled those enemies.

Port Pulse now excludes unaffordable spells from A_Chase. Saved magic waits
resume the existing See state when the physical attack is affordable. Physical
exhaustion, sleep/stun, other encounters and resource balance stay unchanged.
The comparable corrected sample moved 968 actors versus 429 before, with no
magic wait. This does not eliminate legitimate collision congestion in a crowd.
The author's subsequent resource trial deliberately permits both attack types
at zero resources for registered hostile port actors. This fallback behavior
remains available when enemy_attack_resource_trial is disabled in the port data.
Evidence: assets/validation_43627/relief, including native before/after movement,
full-roster operation and saved-wait continuation. The author accepted the final
resource trial and all #16 tests on 2026-09-30; see HISTORY for the test IDs.

## CA-KP-021 — Cannon target sight must originate at the raised barrel

Status/evidence: CODE-VERIFIED / ENGINE-VERIFIED, #16 / 4.36.27.
First recorded / last checked: 2026-09-30 / 2026-09-30.
Affected baseline: 918775e3 plus the issue-16-port-siege working tree.
Environment: Windows 11, GZDoom 4.14.2, Vulkan, development Doom II IWAD,
fresh MAP06 with twelve defensive guns on raised platforms.

An initial target selector called CheckSight from the non-interacting cannon
controller at platform-floor height. The parapet occluded that point even when
the raised barrel could fire over it. Only the six attacking guns fired in the
first full-scene probe. Use the existing barrel actor for target visibility;
keep the launch sweep from the physical pivot/muzzle and native projectile
collision unchanged. The corrected scene fires all eighteen cannons at the
first completed cycle. Select the aim point when the cannon becomes loaded,
rather than retaining a target position selected at the start of its reload.

Reproduction: start current MAP06 and observe each gun through its first
350 native tics, recording per-gun shot/contact counts and operator presence.
Evidence: [integration results](../assets/validation_43627/RESULTS.json),
integration/issue16_mass1.log (before) and issue16_mass_final.log (after).
The final run records eighteen shots/contacts by tic 385. This verifies the
tested platform geometry and native selector, not unrestricted ballistic
accuracy. Separate author acceptance of the battle was confirmed on 2026-09-30.

## CA-KP-020 — Repeated OBJ material declarations create unsafe surface counts

Status/evidence: AUTHOR-REPORTED / CODE-VERIFIED / ENGINE-VERIFIED, #36 / 4.36.25.
First recorded / last checked: 2026-09-29 / 2026-09-29.
Baseline: 99b399bc, Windows 11, GZDoom 4.14.2, Vulkan, RTX 3070 Ti,
gl_multithread=true and gl_precache=false. Author acceptance remains pending.

Symptom: starting MAP01 could abort with "Trying to create zero size texture"
after character allocation loaded. Some successful runs displayed incorrect
door hardware textures. The mansion OBJ exporter emitted one usemtl per face:
222 surfaces for three materials. GZDoom starts another surface even when the
material name repeats. Its OBJ RenderFrame indexes surfaceskinids[i] without
the i < MD3_MAX_SURFACES check used by AddSkins; the native limit is 32.
Out-of-range texture selection depends on memory layout, so a passing run or
a debugger session does not establish safety.

Correction: group opaque faces by material in the generator. The model now
has three surfaces, retaining all 222 faces, winding, dimensions and UVs.
The read-only model check compares each face with the original siege source
and rejects repeated surfaces or an exceeded engine limit. No engine binary,
graphics preference or gameplay rule is changed. An investigated inherited
state registration did not solve the failure and was removed.

Evidence: assets/validation_43625/layout, including the native error capture,
repeated corrected runs, creator and current-save tests. Source references:
[OBJ loader/renderer](https://github.com/ZDoom/gzdoom/blob/g4.14.2/src/common/models/models_obj.cpp)
and [surface limit](https://github.com/ZDoom/gzdoom/blob/g4.14.2/src/common/models/model.h).
The author still needs to confirm ordinary play and new-character startup in
CA-43625-MANSION-01.

## CA-KP-019 — A 3D wall inherits its control texture, not its visible face

Status/evidence: CODE-VERIFIED / ENGINE-VERIFIED, #36 / 4.36.25.
First recorded / last checked: 2026-09-28 / 2026-09-28.
Baseline: 61b3c74e; correction is the linked #36 patch, with native evidence
from its working tree. Environment: GZDoom 4.14.2, Windows 11, Vulkan,
development Doom II IWAD, fresh MAP01.

MAP01 reused CMIN01 on shared solid-wall controls, causing interior wallpaper
to appear outside. Changing ordinary sidedef textures alone does not fix those
3D wall faces. Sector_Set3dFloor argument 2 bits 16/32 select the target upper
or lower texture; the visible/observer side determines interior versus exterior.
Separate slots when one boundary supports different finishes at different levels.
Keep slab undersides, roofs, door controls and cave/water models distinct.

The same inspection found flat upper wall tops below a sloped roof. New solid
gable controls end on the original roof underside; preserve the actual roof
planes and intentional balcony/stair openings. Native before/after traces and
images demonstrate the closure. A guard inferred from an exposed slab edge can
incorrectly fence a narrow construction seam inside a continuous walkway: compare
ordinary-sized native movement against the baseline before accepting it.

Evidence: [#36 results](../assets/validation_43625/RESULTS.json), map generator
and read-only layout validator in assets/generators. Representative native
geometry probes ignore actors; final tutorial/Bull play remains author test
CA-43625-MANSION-01. Visual direction approved 2026-09-28; final playtest pending.

The author's #36 follow-up exposed three related authoring traps. A repeating
window texture inherits 3D-floor pegging and can put windows at ground level:
finite nonblocking panels with explicit sills remove that dependency. A broad
footprint misclassified the middle east-wing interior; use its actual Y=+/-320
wall face, not the older +/-287 estimate. Existing door actors also do not prove
their openings are open: four single leaves overlapped solid stacked wall models.
Rebuild only their authored rectangles and preserve the other vertical layers.
The corrected generator retains existing sidedef slots during subdivision and
keeps every retained sector outlined; static checks reject unused sides/empty
sectors after an intermediate candidate produced native missing-front errors.
For stacked-actor traversal probes, CANPASS is needed to match the player's
vertical actor separation. Evidence: assets/validation_43625/followup; generic
body probes and direct Use calls are not full companion/Bull play acceptance.

## CA-KP-015 — Git checkout can invalidate raw document hashes

Status/evidence: RESOLVED-VERIFIED tooling contract, #21 /4.36.19.
Observation: after merge 8e8b5d3f and Windows checkout, validation reported stale
HISTORY/SYSTEMS SHA-256 although Git showed no content changes.
Cause: the index hashes raw bytes; core.autocrlf converted newly edited LF
sources to CRLF. Resolution: .gitattributes pins maintained docs to LF and the
index is regenerated from LF sources. An isolated core.autocrlf=true checkout
matches the source hashes; static validation passes. Keep exact-byte freshness
checks and UTF-8 sources. This is tooling evidence, not gameplay acceptance.

2026-10-01 extension, #17 / 4.36.28: `git archive` at `9323b156` also applied
checkout conversions to runtime text under `core.autocrlf=true`; independently
comparing exported ANIMDEFS to its Git blob detected the mismatch. Repeated
exports on one machine alone did not catch it. RESOLVED-VERIFIED at `fa6fb9bb`:
`build_playtest.py:committed_files` reads `git cat-file --batch` blobs instead.
`assets/validation_43628/verify_export.py` verifies all 6,129 blob identities,
archive metadata and hashes; two subsequent archives matched byte for byte.
See [4.36.28 evidence](../assets/validation_43628/RESULTS.json). This is static
packaging evidence; export author acceptance remains pending.

## CA-KP-016 — Register dynamically selected Arcana front sprites

Status/evidence: AUTHOR-REPORTED / ENGINE-VERIFIED correction.
First recorded / last checked: 2026-09-27 / 2026-09-27.
Issue: #33, release 4.36.20; failing baseline c24589ca.
Environment: GZDoom 4.14.2, Windows 11, Vulkan, gl_multithread=true,
author-installed Doom II development IWAD.

Assigning CACU/CAWK only through Actor.GetSpriteIndex, without any actor state
using those frames, left their first rendering on an unsafe initialization
path. The author observed a complete freeze on Ace Use. An isolated baseline
also stopped after the first dialogue frame: a local dump, resolved with the
matching official PDB, showed the renderer worker in FTexture::TrimBorders
and the main thread waiting in HWDrawInfo::RenderBSP. Appending RevealedFront
states to the two essence classes registers their fronts when actors load.
Preserve old state offsets when adding these registrations for saved actors.

The corrected native tests draw at least 20 dialogue frames, submit through
ConversationMenu.MenuEvent, observe nonzero capture tics and ownership, then
continue ticking. Repeated Ace/Knight and a copied autosave pass. This is
scoped to these sprites and this engine; it is not a blanket guarantee about
all dynamic sprites. Checking Used's return value or manually invoking Tick
does not validate the rendered dialogue/capture path. See
[render correction evidence](../assets/validation_43620/capture_render_fix.json).
The author confirmed CA-43620-ARCANA-01 passed after the fix on 2026-09-27.

## CA-KP-017 — Unregistered NPC secondary-wind sprite freezes rendering

Status/evidence: AUTHOR-REPORTED / ENGINE-VERIFIED correction, #34 / 4.36.22.
First recorded / last checked: 2026-09-27 / 2026-09-27.
Environment: GZDoom 4.14.2, Windows 11, Vulkan, gl_multithread=true, development IWAD.

CELH existed as twelve PNG frames but had no native actor state. NPC simple and
explosive wind projectiles used GetSpriteIndex("CELH"), which returned -1.
The author's frozen MAP02 process retained C0000005 in FindModelFrameRaw
(RVA 0x397986), sprite -1/frame 9. The engine exception handler redirects the
worker to SleepForever and queues cleanup on the main thread; the latter is
waiting for that worker in RenderBSP. Ordinary post-hang stacks obscure the
original exception: recover CrashPointers/CrashAddress with matching symbols.
Do not mistake raw stack-address scans for an unwound call chain.

Append CELH A-L states after existing states so sprite registration is global
and old saved state offsets stay intact. A baseline secondary-wind discharge
reproduces the hang; corrected simple/explosive rendering and all twelve frames
pass. Recheck both consumers and pre-change saves when altering registrations.
This is related to CA-KP-016 but has a distinct measured invalid-index exception.
Author rescue/rats retest passed 2026-09-27 (CA-43622-NARRATIVE-01). See
[evidence](../assets/validation_43622/wind_render_fix.json).

## CA-KP-018 — USDF page insertion shifts saved conversations

Status/evidence: AUTHOR-REPORTED / ENGINE-VERIFIED correction, #34 / 4.36.22.
First recorded / last checked: 2026-09-27 / 2026-09-27.
Environment: GZDoom 4.14.2, Windows 11; pre-#34 save on the new CAPALOMO layout.

Native actor saves persist global conversationroot/conversation node numbers.
An unchanged public dialogue ID does not protect an already open saved page.
Old MAP02 Voice nodes 178/179 became Palomo food/water nodes in #34; death loading
the old save reproducibly restored the wrong menu. Current-release save/load
tests alone cannot validate this compatibility boundary.

Version the transient Voice speaker's layout and rebind its canonical ID before
resume; revision 0 restarts the brief conversation once, revision 1 preserves the
saved page. Snapshot the pre-#34 narrative revision in WorldLoaded before normal
migration. Other open old dialogues close without selecting any reply; normal
interaction supplies their canonical ID. Never migrate by executing Use/replies
automatically: that can replay rewards or actions. Retain original saves for
rollback, and recheck this boundary whenever USDF pages move.

Regression evidence includes old Voice wrong-page reproduction, death/reload,
old mentor/prisoner close/reopen, new exact-page saves and original-save rollback.
Author confirmation: CA-43622-NARRATIVE-01 passed 2026-09-27. See
[evidence](../assets/validation_43622/dialogue_resume_fix.json).

## How to read this register

This is a compact engineering memory, not a second bug tracker or a claim that every historical fix has been independently reproduced. Use the current issue for active scope and HISTORY for release chronology and author acceptance.

Evidence labels:
- CODE-VERIFIED: supported by inspected source at a named baseline; no runtime guarantee.
- AUTHOR-REPORTED: observed by the author; environment/reproduction may still be incomplete.
- ENGINE-VERIFIED: reproduced with retained engine evidence and conditions.
- RESOLVED-VERIFIED: cause and fix supported by before/after evidence, with acceptance stated separately.
- HYPOTHESIS: an unconfirmed explanation, explicitly not a verified lesson.
- SUPERSEDED: retained reference to advice no longer applicable.

CA-KP-003 records the focused 4.36.2 native runtime verification. CA-KP-001
is a resolved tooling contract. Author acceptance remains explicitly separate.

## CA-KP-001 — Adding a guide to docs breaks the current exact-file check

Status/evidence: RESOLVED-VERIFIED tooling contract (issue #22, patch 4.36.1b).

Observation: the validator used to require exactly the five canonical plus two working documents under docs/ and current-version headers in those registered documents. Copying these two guides into docs/ therefore failed that exact-set check.

Cause: an explicit exact-set validation contract, not invalid Markdown.

Resolution: issue #22 registers `GZDOOM_DEVELOPMENT.md`, `KNOWN_PITFALLS.md` and the generated `DOCUMENT_INDEX.md` as the explicit allowed docs set. The seven canonical/working documents and AGENTS remain subject to current-version checks; the ancillary guides inherit README's release. The unexpected-doc-file check stays active against the extended allowed set, and the guides' existence, UTF-8 readability and repository-relative links are validated.

Verification: before the patch, a disposable copy with the two guides failed the exact-set check; after the patch, `python validate_project.py` exits 0 with ten docs and an empty error list. Disposable negative cases still fail for a missing guide, a broken guide link, an unexpected docs file and a version mismatch.

Author acceptance: recorded separately for the 4.36.1b documentation patch; this entry describes the tooling fix, not a runtime defect.

## CA-KP-002 — Default equipment size is not the character's raw body tier

Status/evidence: ENGINE-VERIFIED in 4.36.4 (#10), GZDoom g4.14.2. Scope: shared recipient-size policy, native equipment acquisition and legacy MAP02 chest migration; author acceptance: CA-4364-T1-LOOT-01 passed on 2026-09-23.

Observation: a shared mapping converts character tiers into equipment-size constants; its current default selection does not select every possible equipment size. Do not infer a linear or one-to-one mapping, or change it as incidental cleanup.

Cause/fix: the former pickup path could initialize size and reserve ItemId before
capacity rejection. Treating those fields as proof of acquisition bound rejected
shared loot to its first viewer. Resolve a nonmutating projection, check capacity
before allocating identity, and commit only on transfer. Preserve genuine owned
or dropped equipment. A container's temporary BecomePickup/bDROPPED flag is not
evidence of previous ownership. Revisioned migration retains unclaimed higher-tier
objects separately without refilling looted slots; RestoreLegacyLootForMigration
reverses that storage change. Explicit CHARACTER_DEFAULT is distinct from legacy
editor argument 0 (M) and resolved size enum 0 (XS).

Prevention: reuse the mapping for the actual recipient, including multiplayer;
inspect fit, weight, durability, value and capacity. Preview and cancellation must
never assign identity or change size, wear, loot counts or stock state.

Verification: 232 native sizing checks passed across all seven body tiers; actual two-client small/large collection and stale confirmation passed. Fresh and baseline-save chest probes cover rejected legacy pickups, preservation of acquired T3 and looted holes, and reversible/idempotent migration. See assets/validation_4364/RESULTS.json for persistence and presentation evidence. These isolated checks do not constitute author acceptance.

## CA-KP-003 — Nested bow crop composition stalls on first presentation

Status/evidence: RESOLVED-VERIFIED in 4.36.2 (#8, fix commit `abdae0d`, PR #24).
Author acceptance: CA-4362-BOW-EMPTY-01 passed, explicitly confirmed on
2026-09-23 (America/Buenos_Aires), with no reported exceptions; see HISTORY.
Baseline: merged main `3b75054`.
Source: https://github.com/damiancurti/Caelum-Argenteum/issues/8

Native GZDoom g4.14.2 / Windows 11 / Vulkan / RTX 3070 Ti / development Doom II
reproduced a 10,442.647 ms inter-tick gap on first empty standard-bow presentation
and 5,210.706 ms when its loaded pose was first shown. Repeated equips were
responsive; the equip callback itself returned in 0.055 ms. The original
author's exact bow/tier remains unknown.

Cause: TEXTURES nested 167–173 row crops per tier through a full recolored
sheet. This is first-use resource work, not evidence of an infinite state loop.
The generator now writes six deterministic crop-only RGBA caches, retaining
native palette operations and the existing sprite declarations. No gameplay,
state table, save schema or original art changes. Do not reintroduce the nested
crop graph or hide the cost by delaying it to another gameplay action.

Evidence: [4.36.2 native results](../assets/validation_4362/RESULTS.json), adjacent
filtered logs and six native original/optimized captures; zero differing RGB
pixels on black, independently verified original crop/alpha equivalence, and
byte-identical repeated generation. HISTORY gives the cause/fix and scope.
Regression: cold and repeated empty/loaded equips for both bows, real one-arrow
reload/fire, arrow overlay visibility, aim and switch-away/back. Callback
automation does not replace physical-binding/normal-route author acceptance
or establish results on untested renderers.

## CA-KP-004 — Flail rotation must be judged around the rendered grip

Status/evidence: ENGINE-VERIFIED transform correction in 4.36.3 (#9).
Author acceptance: CA-4360I-VISUAL-01 (origin 4.36.0i) passed after the
4.36.3 correction, explicitly confirmed on 2026-09-23 (America/Buenos_Aires),
with no reported exceptions; see HISTORY.
Source: https://github.com/damiancurti/Caelum-Argenteum/issues/9

Baseline: merged 4.36.2 (`772f622`) used `handleAngle=rotation-39.5` in
`src/caelum/equipment/CaelumFirstPersonLayers.zs`. The author requested another
approximately 10 degrees counterclockwise. Native before/after captures verify
that increasing the offset to -29.5 produces this direction. The shared
`FLAIL_HANDLE_ANGLE` is the current source for both references; historical 0i
composition manifests and their generator output retain -39.5 as provenance.

Prevention: preserve the grip reference and connected layers. The handle still
hides half of its exposed shaft under the glove; the chain's position follows
the transformed joint, but its resting angle must not inherit the handle's
angle. Keep layer 46 behind handle 50 and hand 52. A plausible numeric sign or
a rotated screenshot is not proof of native screen-space direction.

Verification: GZDoom g4.14.2 / Windows 11 / Vulkan / RTX 3070 Ti / development
Doom II, fresh isolated MAP03 games. T1–T3 native before/after rest captures,
grip/joint checks, 45-degree attack increments through 360 degrees, return and
holster/re-equip passed with zero failures. The chain's 17.424612-degree native
rest offset stayed unchanged. [Evidence and conditions](../assets/validation_4363/RESULTS.json)
include filtered native logs; capture-only HUD suppression reveals the layers.
Automated native callbacks do not replace final author aesthetic approval or
prove untested renderers. No save field/state schema or combat timing changes.

## CA-KP-005 — A green validator or a built PK3 is not a gameplay pass

Status/evidence: CODE-VERIFIED tool scope. Baseline validate_project.py and build_dev.ps1.

Observation: Python checks selected project contracts; the builder packages source files and checks archive/PNG properties. Neither tool executes a normal player route or proves that ZScript compiles in GZDoom.

Prevention: report static validation, packaging, engine load, scenario behavior and author acceptance separately. Do not reuse an old engine success as evidence for a changed commit. State limitations of Linux/Freedoom fixtures and preserve target Windows verification.

Resolution: this is a workflow safeguard, not a bug awaiting a code fix. Each PR supplies the levels relevant to its change.

## CA-KP-006 — Planned state can drift between issues and canonical documents

Status/evidence: CODE/DOCUMENT-VERIFIED discrepancy plus explicit author clarification.

At the inspected PR #7 commit, its reward clarification still describes size-M prices with tiers pending. The author's later instruction and updated issues #10/#14 specify T1 and the recipient's equipment size. Local edited documents can be newer than their Git HEAD; they must not be cited as committed evidence.

Prevention: compare the exact commit and dirty-tree status, distinguish author-approved design from shipped implementation, and reconcile the current canonical sections during formal integration. Do not silently revert a later author decision because an older document says otherwise.

Acceptance: issue #22 reconciled the then-confirmed T1/recipient-size rule. The later #10/#14 author decision supersedes that reward formula with fixed 25 gold plus 10 own-faction reputation, implemented in future #14. Issue #10 reconciles current references and preserves the displaced formula in HISTORY. Historical fixed-M and price-average discussions remain historical.

## CA-KP-007 — New serialized event handlers are absent from older saves

Status/evidence: ENGINE-VERIFIED in 4.36.4 (#10), GZDoom g4.14.2.

Symptom/cause: a pre-4.36.4 MAP02 save restored its saved EventHandler list.
The new chest preview inventory correctly contained five real entries, but the
new map handler was absent (`open=1`, `count=5`, `handler=0`), so neither its
input nor its renderer was available. A fresh game did not expose the problem.

Fix/prevention: the stateless input/network controller is a StaticEventHandler,
independent of the saved map-handler list. Serializable preview state stays on
the recipient's inventory. Static render events precede map render events even
with a larger SetOrder value; draw the modal through the end of the existing HUD
instead, so bars and gameplay notices cannot cover its contents or actions.
Call EventHandler.SendNetworkEvent explicitly from the static controller.
Collection confirmation closes the modal so actual receipts/capacity notices are
visible before they expire; reopening reads the current remaining inventory.

Verification: the same old save, its migrated reload and five-entry 1024x768
native capture; fresh-save and hub-return probes. See validation_4364 evidence.
Author acceptance: CA-4364-T1-LOOT-01 passed on 2026-09-23. Preserve this separation when adding another
UI to an established save schema.

## CA-KP-008 — Changed map geometry prevents old saves from loading

Status/evidence: ENGINE-VERIFIED in 4.36.5 (#11), GZDoom g4.14.2.
Baseline: integrated 4.36.4, `3f3fa0c`; implementation evidence uses the #11
working tree, delivered in `a7b8f95` / PR #28. Author acceptance:
CA-4365-MAZE-01 passed on 2026-09-24 without reported qualifications.

GZDoom checks saved map geometry counts and checksum before restoring ZScript
objects (`p_saveg.cpp`, geometry validation). An inventory revision or a
WorldLoaded migration cannot repair that earlier rejection. A hub save on a
different active map can still contain the old MAP02 snapshot; testing only
fresh games or the active map misses this dependency.

Keep the original WAD and its provenance. The explicit `build_dev.ps1
-LegacyMap02` / `run_dev.bat --legacy-map02` mode packages that exact MAP02
under the established package name, with current code and unchanged map IDs.
The builder verifies SHA-256 before replacing its output. Current runtime
coordinates branch on the new layout marker, so restored old geometry keeps
its original travel/furniture positions. Compatibility is continuation of
the old layout, not conversion to the new layout or permission to reset saves.

Native regression: load a pre-patch save inside MAP02 and another in MAP03
with a saved MAP02 hub, return, and compare keys, chest ownership, identity,
size, wear and position. Both pass (49 and 48 checks respectively). Builder
verification also rejects missing/wrong legacy data without replacing the
previous package. See [validation evidence](../assets/validation_4365/RESULTS.json).
Keep compatibility mode for that campaign; normal builds provide the rebuilt
map for new campaigns. No external save rewriting is required.

## CA-KP-009 — MODELDEF slots overlay state meshes

Status/evidence: ENGINE-VERIFIED, 2026-09-26; #18 follow-up, 4.36.14a.
Affected baseline: `95d8f111` MODELDEF bindings; reproduced with remeshed
working-tree assets before correcting those bindings. Environment: Windows,
GZDoom 4.14.2, Vulkan, disposable fresh MAP03 and a local development IWAD.

Symptom: intact/damaged/open gate meshes appear together, leaving a visible
closed leaf across an open doorway. Cannon and ram states also overlap.
The actors themselves have no SOLID flag; this is not proof of a collider bug.

Cause: model slots describe simultaneous components. Defining three models in
slots 0/1/2 and assigning a different slot to each sprite frame does not exclude
the other components. Fix: generate a separate single-slot MODELDEF block for
each actor/frame. Preserve actor names and state labels.

Reproduction: fresh MAP03, inspect a gate's Intact and Broken gallery poses.
The old bindings overlay the panels; corrected bindings show one closed pair
or one open pair. Retained [evidence](../assets/validation_43614a/RESULTS.json)
contains the before screenshot, all final native views and the reproducible
QA addon. Native TryMove checks cross each open preview without noclip.
The failed intermediate north-wall placement is recorded separately; a clear
mesh does not imply clear map geometry behind it.

Regression: `python assets/validation_43614a/check_siege.py` checks exclusive
state bindings, valid OBJ/material references and two byte-identical generator
runs. Render affected states in the target engine after binding changes.
Author acceptance: `CA-43614A-SIEGE-ART-01` passed on 2026-09-26. This verifies visual
previews, not future breakable-gate physics or historical machinery dimensions.

## CA-KP-010 — Damage proxies must preserve native projectile damage callbacks

Status/evidence: RESOLVED-VERIFIED in the #19 working tree (runtime hashes in evidence).
First recorded / last checked: 2026-09-26 / 2026-09-26.
Issue: [#19](https://github.com/damiancurti/Caelum-Argenteum/issues/19).
Environment: GZDoom 4.14.2, Windows 11/Vulkan, development Doom II, isolated MAP03.
Scope: CaelumGateBlocker.DamageMobj / TakeSpecialDamage.

A proxy that overrides DamageMobj and forwards its raw damage directly to a
controller can bypass the projectile's native DoSpecialDamage. A test projectile
whose callback returns exactly 100 caused 400 health loss on a 50%-resistant gate
in the failing run, instead of 50. The random native projectile roll had reached
the gate before that callback resolved it.

Keep Super.DamageMobj on the contact proxy and forward from TakeSpecialDamage,
after native projectile preparation. The controller applies resistance once;
the auxiliary proxy keeps enough health not to die independently. In the fixed
native test, the same collision removes 50 health once. Hitscan, explosions,
sweeps and idempotent group destruction also pass. API signatures were checked
in the installed target engine's zscript/actors/actor.zs.

Evidence: [before/after native diagnostics](../assets/validation_43615/engine_evidence.txt)
and [tested source hashes](../assets/validation_43615/manifest.json). The local
test fixture remains development-only; neither it nor the IWAD is distributed.
Regression: fire a fixed-DoSpecialDamage projectile at a multi-block gate and
check one correctly reduced health loss. Recheck callback order if the target
engine changes. Author acceptance: CA-43611-GATES-01 passed on 2026-09-26.

## CA-KP-011 — A solid damageable actor is not automatically an Impact Physics body

Status/evidence: RESOLVED-VERIFIED in the #19 correction; author-accepted on 2026-09-26.
First recorded / last checked: 2026-09-26 / 2026-09-26.
Affected baseline: bab1c776, CaelumGateBlocker / CaelumBreakableGate.
Environment: GZDoom 4.14.2, Windows 11/Vulkan, isolated MAP03.

The author reported zero damage to player and gate on a fast bodily collision.
Native TryMove reproduced both zeros. The finite blocks stopped movement and
forwarded weapon damage, but their collision callbacks were not connected to
Impact Physics; testing the siege-impact API alone did not cover that route.

Forward CollidedWith to the owning gate and resolve both bodies through the
shared core. Use whole-gate mass/contact identity and the gate plane, not each
tiny block's position as a separate impact. Reuse the character's receiver and
existing separation/rearm state, including serialization. Keep neutral gate
surface resistance separate from the canonical hardness subtraction.

Regression: actual native movement into a closed gate, health changes on both
sides above threshold, repeated block callbacks, separation, active-contact
save/reload, rotated geometry and open-passage safety. Before/after evidence and
tested hashes: [body collision evidence](../assets/validation_43615/body_collision/engine_evidence.txt).
The 13-check body suite and original 37-check suite pass. The author confirmed
CA-43611-GATES-01 fully passed on 2026-09-26, including the collision retest. Test-only
speed/health reserves are not gameplay tuning. Low-energy collisions can still
correctly cause zero damage under the existing formulas.

## CA-KP-012 — A composite mover must query collision with a solid active proxy

Status/evidence: ENGINE-VERIFIED. Recorded/checked 2026-09-26, issue #20,
4.36.16 worktree based on 40ca8919. Environment: Windows GZDoom 4.14.2,
development Doom II IWAD, Vulkan; fixture assets/IWAD are not distributed.
Scope: CaelumBatteringRam.MoveFrame / MoveHead and owned collision proxies.

Disabling all owned proxies avoids self-collision, but leaving the currently
queried proxy non-solid also bypasses actor blocking in the native TryMove
path. The first thin-head probe traversed its gate with zero registered
contacts. Conversely, enabling all overlapping proxies makes a composite
machine collide with itself. Query each proxy with its own SOLID flag enabled
and its siblings disabled; restore the group afterward. On a failed group
move, restore every component to the last committed pose, not only the final
proxy. The ram's head must use the thin visible striking plate: an enclosing
14-MU radius produced contact in front of the rendered plate.

Regression: actual chassis obstruction, rollback, <=0.5-MU plate/gate gap,
one native strike, frame-mass independence and NPC/player contact. The final
ram suite exercises those paths; hashes/results are in
[4.36.16 evidence](../assets/validation_43616/manifest.json). Flat-lane tests
also reject floor-height changes rather than floating over a step or ditch.
This does not establish support for ramps or rotating sectors. Author visual
acceptance CA-43612-RAM-01 remains pending.

## CA-KP-013 — Old map saves can retain the pre-feature EventHandler list

Status/evidence: ENGINE-VERIFIED. Recorded/checked 2026-09-26, issue #20,
4.36.16 worktree based on 40ca8919. Windows GZDoom 4.14.2, existing 4.36.15
MAP03 save copied for testing; originals are preserved.

Adding CaelumSiegeEvents to GameInfo worked on fresh maps but did not supply
the death observer to that old saved map. New rams loaded and advanced, then
stopped for missing crew after native `kill monsters`, but remained
neutralized=0 because their confirmed-death records never received an event.
Do not resolve this by interpreting a missing actor or zero nearby count as
a kill: unloading and temporary absence must remain distinct.

CaelumCombatActor.Die now forwards registered siege deaths after Super.Die
to the same idempotent ConfirmDeath receiver used by WorldThingDied. Ordinary
actors with no siege record retain their existing path. On fresh maps, the
second notification is harmless; on pre-feature saved maps, the native Die
bridge supplies the missing notification. No file rewrite or destructive
save migration is required. The same legacy input then neutralized all six
trial machines; subsequent save/reload must retain that result.

Evidence: before/after legacy runs and source hashes in
[4.36.16 evidence](../assets/validation_43616/manifest.json). This finding is
scoped to the tested EventHandler/save lifecycle, not every GZDoom callback.
The author confirmed CA-43612-RAM-01 passed on 2026-09-26 (HISTORY).

## CA-KP-014 — FastProjectile collision does not integrate gravity

Status/evidence: CODE-VERIFIED / ENGINE-VERIFIED.
First recorded / last checked: 2026-09-26 / 2026-09-26.
Issue: [#21](https://github.com/damiancurti/Caelum-Argenteum/issues/21).
Baseline: 9676ec0d plus the #21 working tree; GZDoom 4.14.2, Windows/Vulkan.

The installed engine's `zscript/actors/shared/fastprojectile.zs` subdivides
movement according to radius and height and checks native actor, line and
plane collisions, but its Tick override never applies gravity. Merely clearing
NOGRAVITY does not produce a ballistic arc. CaelumCannonProjectile applies
native GetGravity() once per physical tic before calling Super.Tick, respecting
native freeze. Calendar acceleration is unrelated. Its 400 m/s converts to
365.714286 MU/tic, not a raw speed of 400 and not a slowed visual surrogate.

Native evidence: [#21 manifest](../assets/validation_43617/manifest.json).
In the isolated default-gravity map, a 10-tic unobstructed flight matched
z=z0+v0z*n-g*n*(n+1)/2 and vz=v0z-g*n; native g was 1 MU/tic². Thin wall,
blocked muzzle, floor/ceiling and actor contacts were tested separately. A
subclass that adds gravity should not also run ordinary Actor movement, which
would advance the projectile twice. Default engine gravity here corresponds
to 38.28125 m/s² at project units, not Earth's 9.80665 m/s².

This finding is scoped to GZDoom 4.14.2 FastProjectile, not all actors. The
game's accepted general collision damage/crushing formulas remain unchanged.
Author acceptance CA-43613-CATAPULT-01 is pending.

## CA-KP-015 — Input and multi-frame attacks need one absolute clock

Status/evidence: CODE-VERIFIED / ENGINE-VERIFIED.
First recorded / last checked: 2026-09-30 / 2026-09-30.
Issue: [#37](https://github.com/damiancurti/Caelum-Argenteum/issues/37).
Baseline: 29177813 plus the #37 patch; GZDoom 4.14.2, Windows/Vulkan.

In CaelumPlayer, native held-Fire input can observe the previous cooldown
before the player's normal timer update. Checking only that cached value
adds a tic between otherwise correctly timed attacks. RefreshWeaponAttackClock
checks the saved absolute start/deadline before accepting input. Delayed impact
must retain the remaining cycle instead of starting another full cooldown.

For multi-frame enemy casts, rounding every frame separately stretches fast
casts. CaelumCombatActor uses cumulative boundaries from the same start tic;
zero-duration intermediate poses advance immediately. The four tested Eloquence
levels produce complete cycles of 15, 12, 5 and 1 native tics, respectively.

Reproduction: hold Fire with the fixture's sword for 120 tics; compare successive
AttackAnimationStartTic values with Ceil(AttackAnimationDurationTics). Seven
intervals equal 15. Run the Zupay cast at Eloquence 0/33/100/1000 and observe
after the combat actor's Tick. A watcher created before that actor observes
stale state and can falsely report an extra tic. Likewise, test setup must run
after deferred PostBeginPlay initialization.

Evidence and source hashes: [4.36.26 results](../assets/validation_43626/RESULTS.json).
These isolated engine checks do not constitute author gameplay acceptance.

## Rules for adding and updating entries

1. Add an entry only for reusable engineering knowledge: a recurring failure, a non-obvious project constraint, or a verified cause/fix likely to prevent future work. Ordinary progress belongs in the issue.
2. Search for an existing ID/symptom before adding. Keep stable CA-KP identifiers and update the original entry instead of creating duplicates.
3. Record facts, hypotheses and approved requirements separately. A user-observed failure can be recorded immediately as AUTHOR-REPORTED; missing reproduction does not mean it is disproven.
4. Include the engine version, affected commit(s), path/symbol, scope, reproducible steps, evidence and limitations where available. Mark unavailable fields explicitly; never fabricate logs or confirmation.
5. To mark a defect RESOLVED-VERIFIED, retain the reproducer, identified cause, fix commit, before/after results and any residual risk. State whether the author accepted it; engine success alone is not author acceptance.
6. Record failed approaches only when they explain a trap or prevent a likely repeat. Do not paste entire conversations, speculative reasoning or raw session logs.
7. Link to durable repository/PR artifacts. Temporary sandbox paths and expiring downloads are not permanent evidence. Never commit credentials or private installation paths.
8. Recheck an entry when its owning code or engine version changes. Mark obsolete advice SUPERSEDED with a replacement reference; preserve unique history in HISTORY.
9. Keep entries concise (normally 150–300 words excluding a necessary small reproducer). Link to canonical formulas rather than copying large tables.
10. Review only the touched entries and connected rules during a patch. Do not add a full historical audit or additional engine run solely to expand this register.

## Copyable entry template

```text
## CA-KP-NNN — Concrete symptom or constraint
Status/evidence: AUTHOR-REPORTED | CODE-VERIFIED | ENGINE-VERIFIED |
                 RESOLVED-VERIFIED | HYPOTHESIS | SUPERSEDED
First recorded / last checked: YYYY-MM-DD / YYYY-MM-DD
Issue / PR: repository links, or not recorded
Affected baseline: exact commit and dirty-tree qualification
Environment: engine version, OS, IWAD, renderer/config, save state as relevant
Scope: path, symbol, affected consumers
Symptom or constraint:
Reproduction: shortest steps and expected/observed behavior
Cause: verified explanation, or UNCONFIRMED
Fix / prevention: actual change and commit, or PROPOSED/PENDING
Evidence: commands, exit codes, durable artifact links and results
Regression check: smallest test that catches recurrence
Author acceptance: exact confirmed ID/date/qualifications, or PENDING/NOT REQUIRED
Limitations / superseded by:
```

For non-runtime constraints, mark engine reproduction not applicable and provide the static/source evidence. Empty template fields are not executed tests.
