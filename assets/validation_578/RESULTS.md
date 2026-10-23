# 5.7.8 / #479 - Integrated support implements

Status: author visual acceptance is complete as of 2026-10-22. After accepting
the other five designs, the author confirmed the Orb handoff: "Ahora si dio bien
la prueba." CA479-01 retains gameplay, campaign acquisition and save/load checks
in root pending_test.txt. The initial procedural rejection remains historical.

## Lethal support damage correction - 2026-10-23

The author gameplay run aborted in CaelumSupportStatus.Tick after a curse killed
its recipient. Native DamageMobj calls OwnerDied, which removes the status and
clears Owner before Tick returns. The tick now rechecks that reference before
reading health or advancing another role. The private F2 reset replaces dead
targets with live actors. No art, formulas, save fields or revision numbers change.

The original 16,722-entry package reproduces the author's exact null-owner VM
abort. The fixed full package matches src; its only changed runtime entry is
CaelumSupportMagic.zs. 150 assertions pass across eight native runs: lethal
Book/Effigy, concurrent curse/healing roles, removed caster, player death, repeated
real attack/F2 cycles, two loads of a pre-fix lethal save, existing nonlethal
gameplay/controls and an older active-effect save. Four additional assertions
prepare the pre-fix save in its original runtime. The original active-effect
save and pre-fix package are preserved byte-for-byte.

Evidence: owner_death_report.json, native/owner_death/ and collect_owner_death.py.
The initial automated probe set health before deferred PostBeginPlay completed;
its eight failed assertions are preserved and excluded. The corrected probe
waits for initialization and reproduces the exact reported failure before the fix.
All counted fixed runs exit normally without VM errors. Tests run unpaused in
the background at 5% audio; no rendering-performance claim is made.

Reproduce the focused scenarios with prepare.py and run_native.ps1 -Checks,
using Script lethal, lethal-player, lethal-controls, lethal-save/lethal-load,
gameplay, controls and live-load. Use a fresh Label for each run; LoadGame names
the corresponding retained save relative to build/issue479. current contains
the corrected package; pre-owner-death preserves the original for reproduction.
On 2026-10-23 the author confirmed "La prueba dio bien" after the focused
lethal Book/Effigy and F2 repopulation retest. That portion of CA479-01 (origin:
5.7.8 / #479) passed without qualifications, using author-combat-20261023-160550
and the fixed package above. HISTORY records acceptance; only that completed
check is removed from pending_test.txt. Other gameplay, campaign acquisition and
save/load checks remain pending. owner_death_report.json retains the original
agent-run snapshot. Accepted visual checks are not repeated.

## Current floating-Orb follow-up

The author accepted the five non-Orb designs and requested only a baseless Orb
held like the Book. Three tier sprites now float over the original Book palm;
inventory/world/component icons have the same baseless silhouette. All other
weapon images and existing hand images match ee99a337 byte-for-byte. The original
Orb source is retained beside the targeted edit and exact built-in imagegen prompt.

The 16,722-entry full PK3 matches src bytes. GZDoom 4.14.2 passes 23 checks:
five selections, three inventory resolutions, three original Book/Statuette
identity checks, and four sets of three Orb palm/pivot checks. Agent inspection
covers all tiers in world/inventory, primary/return, switching back to the Book,
and the female palm variant. All 38 existing palm states resolve. Exact package
hash, source hashes, native log and captures: floating_orb_report.json,
native/floating-orb-01* and visuals/floating-orb-*. Registration is byte-identical
on repeated runs. Static validation and document/localization freshness pass.

Reproduce with prepare.py and run_native.ps1 -Checks -Script floating-orb;
collect_orb.py uses the recorded final label. launch_author.ps1 -Mode orb opens
the focused author scene. The author accepted this Orb retest on 2026-10-22
using author-orb-20261022-231123 and package hash recorded in floating_orb_report.json.
Visual approval is complete; remaining CA479-01 gameplay/acquisition/save checks
still await confirmation. Report JSON files retain their original pre-acceptance
run status; HISTORY records the subsequent author confirmation.
The earlier 75-check package is retained under build/issue479/pre-floating-orb.

## Initial painted correction

Book/Statuette restore the original inventory/crafting icons, world billboards,
first-person poses and appearance hands. Scepter/Orb/Censer/Effigy use twelve
painted type/tier variants. Sources, exact imagegen prompts and registration
manifest are in assets/art_source/support_sprites. Rejected sources are retained.
The Journal now actually draws these six weapons' tier icons beside their rows.

Full package SHA-256:
`96d9fddaf7ebdb7498baf7616485daff625fa37dcb06c89ed1eb915943dec1a0`.
All 16,721 entries match src bytes. Three sequential GZDoom 4.14.2 runs exit 0,
with 75 PASS / 0 FAIL: 41 gallery/legacy-art checks, 14 native-control checks and
20 selection/asset checks during T1 primary/block-input/return capture. The latter
count verifies selections and texture resolution, not 20 combat assertions.
Agent visual review covers all 18 held/world views, all 18 actual inventory rows
and six T1 input sequences. See painted_report.json, native/painted-* and
visuals/painted-*. No missing icons, model bindings, lost hand layers or VM errors
were observed. Original Book/Statuette PNGs match commit 87089226 byte-for-byte;
registration and fixture generation reproduce identically. Static validation
and document/localization freshness pass. Author art acceptance remains pending.

The earlier 176+2 runtime checks below remain tied to the retained pre-correction
package under build/issue479/pre-sprite. No gameplay/balance logic changed, so
the correction reruns affected presentation and native input rather than claiming
a second complete gameplay/migration campaign. No performance claim is made.

Reproduce with prepare.py, then run_native.ps1 -Checks using painted-gallery,
controls and painted-actions (fresh labels). collect_painted.py records the
final labels and requires Pillow for technical contact-sheet assembly. The
gallery uses two ordered exec files to stay within the native command buffer;
both contents and tail hash are recorded. Oversized and independently split-line
attempts exited before checks and remain in diagnostics; neither is a pass.
The initial alias-driven inventory capture did not open the Journal; the final
fixture sets its UI CVars explicitly and the native captures show the actual UI.
An overlay-only trial retained earlier world-model bindings: final evidence and
author handoff use the complete rebuilt package, without that overlay.

## Pre-correction integrated runtime evidence

GZDoom 4.14.2 / Windows 11 / Vulkan / RTX 3070 Ti / Ryzen 9 5950X, 1280x720.
Native processes ran sequentially, hidden, unpaused in the background, at 5%
audio. `final_report.json` records package/source identity, deterministic fixture
and art checks, exact launch/environment metadata and raw logs under native/.

Full package SHA-256:
`c63429a68820715d186bd9cecb0caf12022b0afdddc9de942f3986d6057d5fcd`.
All 16,695 entries match src bytes. There are 176 PASS / 0 FAIL assertions on
this package, with all eight native runs exiting normally:

| Scope | PASS |
| --- | ---: |
| Gameplay, area/occlusion, team rules, health/damage/movement, prices, recipes, shops/libraries, profession starter mappings | 77 |
| Native slot 0 and primary/secondary input, exact costs, no support charge | 14 |
| Calculation model, curves, stacking, refresh, fraction/expiry and revision rules | 51 |
| Real actor/inventory ticks | 4 |
| Real receiver/source/active-effect save/load | 4 |
| Earlier offensive item/Box/learning migration | 6 |
| 18 type/tier gallery, repeated first selection and all icon/pose resolution | 20 |

Two separate old-runtime checks establish the saved baseline and rollback with
the retained foundation package (`bdff4ea858b89ccc080fedd76f69d5785167b05ddbbb11586bb8a6b2b006ad5b`).
The original `ca479-legacy-v2.zds` retains offensive Quintessence for rollback;
loading it with the new package retires that authorized test item while keeping
old elemental IDs, tier, 1,234 wear, Box placement and learned recipe indices.
Counts use emitted PASS lines; serialized cumulative counters are not new checks.

The native gallery's 18 distinct captures were visually inspected. Full-resolution
examples and the contact sheet are in visuals/. All models stay within 32 OBJ
surface runs; the art manifest validates every input/output hash and two identical
generation runs. Hands remain the existing appearance layers. Neither visual
inspection by the agent nor asset loading establishes author art acceptance.

## Corrections found during integration

- Native primary input previously enumerated only the old magic types. Direct
  effect tests passed but real support input failed. The shared magical type
  classifier now routes primary casts; full-package controls validate the fix.
- New frame states require Actor/Weapon/Overlay usage; long first-person PNG
  names belong outside the sprite namespace. Persistent hand layers and the
  shared grip align all six designs. Tier icon paths now resolve T1/T2/T3.
- The first legacy fixture omitted the pre-existing durability revision, causing
  the old runtime itself to multiply test wear by ten. Baseline inspection
  established this before changing the fixture. No production migration was
  weakened to satisfy the assertion; the corrected seed/current/rollback pass.
- Early control cost assertions observed natural Anima recovery and character
  profile recalculation. The private fixture now holds its authored test stats
  and suspends only natural Anima recovery; production recovery is unchanged.

Representative failed diagnostics are retained under diagnostics/. Earlier
foundation/overlay results below remain historical evidence, not the final PK3.

## Reproduction and limits

Run `python validate_project.py`, rebuild with `build_dev.ps1 -Destination
build/issue479/current/caelum_argenteum_dev.pk3`, then `python
assets/validation_578/prepare.py`. Keep the earlier foundation package locally
under build/issue479/foundation with the same PK3 basename; use run_native.ps1
with `-Runtime foundation -Checks -Addon legacy-fixture.pk3 -Script legacy-save`
to prepare the earlier save. `run_suite.ps1 -Prefix <fresh-label>` runs the eight
current cases sequentially. Use fresh labels to retain logs; the final collector
uses the recorded `complete-*` labels. Run legacy-rollback against the original
save and foundation runtime, then collect_final.py. No engine, IWAD, PK3 or saved
fixture is distributed. The historical collect.py belongs to the foundation
checkpoint and must be reproduced at that earlier source revision.

For author use after return: launch_author.ps1 defaults to combat; `-Mode gallery`
opens manual F1 cycling. Launch it with PowerShell -NoExit so the terminal remains
available. Test instructions and outstanding ordinary campaign acquisition/
crafting checks are in pending_test.txt. Native effect/catalogue assertions do
not claim an end-to-end author UI test. This patch adds local cast queries and
four-slot receiver state; no routine global per-tic scan is introduced. No new
frame-presentation or large-map performance claim is made.

## Historical foundation checkpoint

The following records the earlier partial commit, before runtime integration.
Its open decisions were subsequently resolved in SYSTEMS and the issue.


This is an implementation checkpoint, not delivery of playable support weapons.
It packages the approved role/cost/radius data and a serializable per-effect-class
calculation state. Existing actors, weapons, movement, damage and recipes do not
call it yet. No old item is migrated and no new item is sold or granted.

## Verified scope

Native GZDoom 4.14.2 tests cover M2 at 0/100 and effective levels above 100, all
four role mappings and tier costs, fractional per-tic integration, expiry,
stacking with different caster strengths, duration reset, changing maximum
health, independent benefit/curse state, the 100% factor, unknown revisions and
idempotent initialization. Native save/load checks retain intensity, revision,
fractional remaining time and accumulated fractional health, then compare the
resumed result with uninterrupted integration. report.json records exact counts,
package/fixture hashes and source-byte equality; native/ records environment and
normal process exits. The fixture is deterministic and adds no runtime overrides.
The final result is 56 PASS / 0 FAIL: 51 model assertions and five save/load
assertions, with all final native processes exiting 0. The validator passes at
5.7.8 with 2,499 CONTEXT words. All 16,598 package entries match current src bytes.

The initial fixture used `state` as a local identifier, which conflicts with
ZScript grammar; that parser failure is preserved in diagnostics/model-01.txt.
Renaming the local fixed the fixture without changing production code.

There are no active per-tic hooks or scans in this partial patch. This establishes
calculation and serialization behavior, not combat, frame-presentation, whole-map
performance, item migration or author acceptance. No engine, IWAD, PK3 or save
is distributed. No manual check is added for an unexposed calculation layer.

## Source audit and deferred integration

- CaelumConstants assigns old Book/Statuette weapon types 18/19. Keeping those
  persisted identities for Scepter/Orb is compatible with the approved migration;
  support entries must be separate. Learned essence recipes currently encode four
  implement groups in CaelumCraftingRules.GetUnifiedEssenceWeaponType.
- CaelumPlayableWeapons assigns offensive Quintessence selectors to native slot
  0; CaelumPlayer.GetWeaponFamilyForType uses internal magical family 6. Reserving
  slot 0 exclusively for support requires an authored destination for its old
  offensive selectors, not a blind replacement of unrelated numeric IDs.
- The approved baseline radius is ESSENCE_EXPLOSION_BASE_RADIUS=128. Existing
  offensive Statuette casting applies AbilityRangePercent and the charged linear
  multiplier; Orb must retain that behavior. Initial support has no charge.
- CaelumSealResistance already retains 85% of Quintessence health damage for a
  Quintessence seal. Support mitigation and rare resistance distribution remain
  undecided. The calculation layer returns fractional HP before mitigation; it
  does not authorize bypassing seals or rounding damage once per tic.
- Existing Miracle restores other resources and has global scans. It is not an
  appropriate implementation to copy for health-only local support effects.
- Economy/fabrication/masses, overlapping effect-class identity, selector routing,
  artwork, authoritative recipient integration and full migration remain open.

The author requested postponing questions and manual tests until returning.
The canonical contract/status is in SYSTEMS/TASKS; this report is test evidence.

## Reproduction

Run validate_project.py and build_dev.ps1 with destination
build/issue479/current/caelum_argenteum_dev.pk3. Run prepare.py, then run_native.ps1
with -Checks for smoke, -Script save, and -Script load -LoadGame ca479-state.zds,
using a fresh label for each process. collect.py verifies the final artifacts.

## Subsequent runtime integration (2026-10-22, in progress)

The author's later approvals are recorded in SYSTEMS. Development overlay
`gameplay-04` passed 62 gameplay assertions; `live-01` passed four real-tic
assertions (40 elapsed tics, 2.857142857 s remaining, health 960/1000).
The overlay is only a development diagnostic; the foundation package above is
not the integrated final build. New preparation/fixture sources are tracked.
Artwork, legacy/current saves and final full-package evidence remain in progress.
Author manual tests/questions are postponed during the renewed absence.
Earlier failed iterations remain in local logs; none is acceptance evidence.

`live-save-02` / `live-load-02` also passed four native receiver/inventory/
caster/duration checks after a real save/load. At elapsed tic 41 the loaded
receiver had 960 HP, 2.828571429 s remaining and 6.857142857 fractional HP.
`integration_report.json` records the diagnostic package/overlay hashes; logs
and launch metadata are in native/. The first save attempt quit before the
engine wrote its file; the corrected fixture waits five frames before quitting.
No production save defect was inferred from that fixture error.
