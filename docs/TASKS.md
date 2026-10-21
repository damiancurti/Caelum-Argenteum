# TASKS.md — Active tasks

Documentation version: **5.6.7** — 2026-10-21.

## 5.6.7 - Individual clothing object sprites (#387)

Delivered for author review: 25 unique inventory/crafting icons and dropped-item
sprites, source provenance and deterministic exports. CA387-01 in pending_test.txt
covers the implemented object artwork; assets/validation_567/RESULTS.md separates
static/native evidence from author acceptance.
Still required for #387: worn-character, character-preview and first-person
coverage for supported body/sex/species/size combinations, plus visual acceptance
and measured rendering evidence for those bindings. No new NPC wardrobe assignment
is implied. Keep #387 open; this stage is not completion of the full issue.
#386 is accepted, merged in PR #396 and closed. Remaining catalogue/ammunition/
restock work stays in #379/#380/#383/#385, with its own commits, tests and PRs.

## 5.6.6 - Native ordinary clothing (#386)

The approved 25 rows now use native item IDs, size, prices, fabric/leather/rope
recipes and a separate layer under armor. ClothingRevision 1 grants four initial
pieces once and transfers implicit base moisture without changing equipped armor.
Stored garments retain moisture; wet mass counts in transfer/carry limits and
water above changed capacity becomes runoff without cooling. No wear/repair.
Static/native evidence and screenshots: assets/validation_566/RESULTS.md.
CA386-01 passed author acceptance on 2026-10-21; #386 has no remaining author check
and is ready for integration under the standing merge instruction.
Library and vendor integration remain #383; model coverage/art remain #387.
The accepted batch PRs #388–395 was merged on 2026-10-21; issues #376, #377,
#378, #381, #382 and #384 are closed. Remaining issues: #379, #380, #383,
#385 and #387 after integrating accepted #386. Keep their scopes, tests and PRs separate.

## 5.6.4 - Review one-time death loot (#384)

Implementation retains current tables and closes native death callback/unblock
repetition, including frozen resurrected bodies. Revision-1 migration preserves
old pending/spent claims and frozen phase timers. The focused native set passes
16 runs / 113 assertions; source/package comparison preserves unrelated paths.
See assets/validation_564/RESULTS.md for evidence and reused-test boundaries.
CA384-01, CA381-01 and CA378-01 passed author review on 2026-10-20.
At this delivery all author checks had passed and the pending queue was empty.
No new table, ownership rule, random pool or historical-map refill is authorized.

## 5.6.3b - Review ordinary-clothing data before implementation (#386)

The author approved the full SYSTEMS table on 2026-10-20, including garment rows,
balance, layering, durability and one-time legacy outfit/capacity policy.
Implementation is delivered in 5.6.6. #387 art needs separate coverage and visual
approval after #386. CA377-01, CA381-01 and CA378-01 passed on 2026-10-20.
Each check uses its frozen package, not this proposal's diagnostic labels.

## 5.6.5 - Implement approved locks and ownership (#382)

The author approved the complete proposal on 2026-10-20 and then added hostile
witnesses: living combat-capable NPCs within 32 meters and direct sight of the
player, only for another owner's new padlocked chest. On 2026-10-21 the author
assigned a small locked chest with ten gold coins to each city household.
Native evidence covers crafting, pickup, storage, saves, hub travel, household
issuance and witness controls (20 runs / 134 passing assertions). CA382-01 passed on 2026-10-21.
The author reported chest movement on a padlock hit; corrected manual thrust
respects DONTTHRUST for player/NPC hits. The corrected retest passed author review.
Vendor/library availability is a separate #383 integration. #381/#377 are accepted.
#384 retains current tables; #385 leaves products without a game recipe unrenewed.

## 5.6.3 - Recipe acquisition and study (#378)

Physical sheets/book, per-tier learning, source retry, Intelligence M3 reading,
practice snapshots and capped time reductions are implemented. Furniture and
bilingual controls are included. Evidence: `assets/validation_563/RESULTS.md`;
CA378-01 passed author review on 2026-10-20. CA381-01 also passed; CA377-01 also passed.
The author returned; the second temporary keep-awake request was released
on 2026-10-20 without changing the Windows power plan.
Next: #383 library commerce uses all approved recipe/tier books and replaces
some repeated city shops, grouped by existing recipe categories. Other balance,
source/ownership and clothing decisions remain in their own issue scopes.

## 5.6.2 - Native ordinary containers (#381)

Implemented the author's capacity, size, mass, transport and destruction rules
on native chest inventories. Exact transactional guards and the live menu retain
existing locks, quotas and protected items. Revision-1 migration and carried
save/travel checks are recorded in `assets/validation_562/RESULTS.md`.
CA381-01 passed author review on 2026-10-20; CA377-01 also passed on 2026-10-20.
At that delivery the author was away. Remaining catalogue/balance decisions
stay in their separate issues, not the author-test queue.

## 5.6.1 - Merchant coordination (#377)

Implemented compatible adapters, stateless session/quote coordination and
shared inventory commits with preallocation. Focused static/native/save checks
and retained baseline regressions: `assets/validation_561/RESULTS.md`.
CA377-01 passed author review on 2026-10-20. The author-test queue is empty.
The author accepted CA376-01 on 2026-10-20. #378 follows on its own branch;
recipe learning, ammunition, containers, ownership, shop content/replenishment
and clothing remain separately scoped #378-387 work.

## 5.6.0 - Crafting coordination (#376)

The 48-method stateless extraction is implemented with unchanged fields,
signatures, lifecycle and inventory commits. Static/native/save evidence:
`assets/validation_560/RESULTS.md`. CA376-01 passed with explicit author
confirmation on 2026-10-20; its confirmed entry is removed from pending_test.txt.

Next technical slice: #377 merchant coordination. The remaining V5.6 issues
#378-387 require the individual author decisions listed in their GitHub design
gates. Missing design stays here/in its issue, never in the manual-test queue.
No new recipes, finished-ammunition components, containers, title/theft rules,
shop/loot stock, renewal policy or physical clothing is claimed by #376.

## 5.5.8a - Deferred issue closed at author request (#316)

#316 was closed as not planned on 2026-10-20. It is no longer an active issue;
avalanches remain unimplemented. A future authored map/encounter and explicit
design decision would require a new focused issue. Older deferred/open notes
below are historical status, not a current instruction to keep #316 open.
PRs #370-373 are merged, #363/#314/#315/#369 are closed, and pending_test.txt is
empty. Wider roadmap topics do not become implemented through issue closure.

## 5.5.8 - Bull visual replacement (#369)

Implementation includes source preservation, surface cleanup, author-approved
forehead/horn reconstruction, reduced mesh, quadruped rig/skin, native animated
export and inherited MAP01 coverage. Combat/state timing and collision remain
unchanged; rollback is documented in SYSTEMS. Isolated QA and limitations live
in `assets/validation_558/RESULTS.md`. The author accepted CA369-01 on 2026-10-20:
"El toro quedó bien", and authorized merge/closure. The final coat, brows and
1.5 visual scale are accepted; the confirmed entry is removed from pending_test.
Native checks remain distinct from author-reported visual approval; no display
FPS result is inferred. Keep #316 deferred and all issue PRs separate.

## 5.5.7 - Future melee energy contract; conversion deferred (#315)

The author decided on 2026-10-19: "Documentar el diseño y aplazar la conversión;
conservar el daño actual". SYSTEMS now separates the current damage pipeline
from a future energy candidate, inventories existing/missing data, and compares
T1-T3 weapon damage, nominal Air and thermal work. Worked matched player/NPC
calculations reuse Rulo's authored mass/Strength; they are not new character
defaults. Body-collision 1 J/HP and muscular work do not define blade damage.
No future impact coefficients or production conversion are approved. Required
speed, effective-mass, contact/material, penetration and resource calibration
remain author decisions for a focused follow-up. Current combat and saves remain
unchanged; only release diagnostics change at runtime. No manual test is queued
for a deferred design. Static validation and normal build pass; a final native
MAP01 compile/startup smoke passes. Packaged gameplay bytes match 5.5.6; only
release diagnostics differ. Independent review verified the nine comparisons
and their sources. Evidence: assets/validation_557/RESULTS.md.
#369 remains separate; #316 retains its authored-map
prerequisite and deferral.

## 5.5.6 - Ice and lava ground contact (#314)

The author approved a private test room with ice at -40 C and lava at 1,000 C,
using existing temperature exposure and damage. The approved first approximation
uses 100 W/m² K and the lowest anatomical row (1/16 of body area); the current
clothing path insulates it. Ground contact replaces that area's air exchange;
water takes priority. Jumping, flight and unsupported floors stop contact.
Native supporting floors and solid 3D platforms are distinguished. Current
temperature defenses and real-time damage remain authoritative; no direct lava
damage, elemental fire status or new immunity is added. The obsolete Pilgrim
Amparo reference is superseded by the existing Redemption rules (#250).
No campaign placement is authorized. Transient projections require no save
schema migration. Native evidence: assets/validation_556/RESULTS.md.
Static validation and normal packaging pass. Sixteen native runs contain 93
passing checks, including old/current saves, rollback and hub return. Independent
review found no blocker. Five performance windows retain simulation and render
callback tails; ETW access was denied, so no presentation/FPS acceptance is claimed.
The author accepted CA314-01 (origin 5.5.6 / #314) on 2026-10-19:
"La prueba dio correcto", without qualifications. Its pending entry is removed.
This confirmation reuses native evidence; it does not establish ETW presentation
or campaign placement acceptance. #315/#369 stay separate; #316 is deferred.

## 5.5.5 - Equipped-Seal input while unarmed (#363)

The unarmed fallback now opts into native User2 and delegates to the existing
equipped-Seal channel authority. Press starts, release keeps the channel active,
and a second press stops it; holding never creates repeated effects or payments.
Resource exhaustion, missing seals and cooldown retain their existing rules.
The new states are appended; previous state indices and saved fields are unchanged.
Native baseline/revised input, exact spending, rejection, old/current saves,
rollback and hub evidence are recorded in assets/validation_555/RESULTS.md.
Static validation and normal packaging pass. Independent review found no
production defect. The author accepted CA363-01 (origin 5.5.5 / #363) on
2026-10-19: "La prueba dio correcta", without qualifications. Its pending entry
is removed. Existing native evidence is reused; no new engine test or FPS claim.

## 5.5.4 - Ammunition mass and finished-component contract (#313)

The author selected Argentine Remington 1879 and late-nineteenth-century paper
12-bore shotgun references. Complete cartridge masses are explicitly approved
design approximations: 40 g carbine and 45 g shotgun, replacing the shared 3 g
placeholder. Historical exact component weights were not established. V5.6
receives a finished-component assembly contract; no playable recipe or new
material interaction is introduced. Count/type identities, magazines, damage,
armor penetration, shields and projectile physics retain their accepted rules.
Native validation_554: 12 required runs / 1,323 checks pass, including old-save
upgrade/rollback and unchanged defense rules. Build/static checks pass.
CA313-01 (origin 5.5.4 / #313) passed on 2026-10-19: the author confirmed
"La prueba dio bien", without qualifications. The confirmed pending entry is
removed. This acceptance reuses native evidence; no new engine test is claimed.
The author also authorized merging PRs #364-368 and closing #309-313.
#314, #315 and #363 remain open for a later session; #316 and campaign FPS
stay deferred.

## 5.5.3 - Sustained pressure lifecycle and native descent (#312)

Pending moving work now reaches the surviving receiver after its peer is
destroyed. Static pressure closes on support loss, non-solid/noclip interruption
and resident suspension; dead receivers discard the old interval before revival.
Existing energy, armor/cushioning, Toughness, capacity, creep and cadence remain.
Native ceiling pressure records local per-tic attempted descent, excluding pauses
instead of multiplying the whole pulse gap by the latest speed. Sampling revision
1 preserves saved samples; only pre-sampling tics in an old save's first pulse
retain the former approximation. No map geometry or native telefrag change.
Evidence: validation_553; 20 required native runs with 306 completed-phase checks,
including old/current saves and rollback. The visual smoke contributes no numeric
assertions. Project validation and normal packaging pass. The author accepted CA312-01 on 2026-10-19.
Campaign FPS remains deferred; #313–315 stay separate and #316 stays deferred.

## 5.5.2 - Multiple-contact identity and armor (#311)

Correct the reproduced zero release distance, validate native simultaneous and
chained collisions, shared-region armor, distinct event identities and save
continuity. Preserve original saves and test a previous-runtime checkpoint.
Record bounded dense-contact CPU costs separately from deferred campaign FPS.
Evidence: validation_552; all 24 required native runs pass. CA311-01 was accepted
by the author on 2026-10-18. Keep #312–315 and deferred #316 separate.

Current acceptance, 2026-10-18: CA318-01..05 and CA327-01 are explicitly
approved, including the old city/breath/doors/residents/sky/waves checks.
All pre-V5.5 author checks are complete. Older pending statements below are historical
checkpoints superseded by this confirmation and HISTORY. FPS work under #318
is deferred by the author. Siege-adrenaline production integration is #361.

## 5.5.1 - Combat dispatch extraction (#310)

Extract only equipped primary/secondary/sweep coordination, retaining all pawn
adapters, saved fields and native start/commit paths. Reuse #309 fixtures and
compare actual per-tic actions, resources, ammunition, hits and exact-item wear.
New authority checks must reject prediction/stale/detached receivers before a
mature action can commit. All 31 required native runs pass, with 1,793 identical
observations in 20 paired scenarios. Evidence: validation_551; CA310-01 passed author
acceptance on 2026-10-18. No FPS conclusion is inferred from moving code. Continue #311–315
separately; #316 remains deferred.

## 5.5.0 - Weapon/input audit (#309)

Implement only reproduced authored deviations: one Reload action per press,
idempotent empty-magazine reload, and blunt uppercut classification. Preserve
native state ordering and existing saved fields. Evidence: validation_550.
CA309-01 passed author acceptance on 2026-10-18; the author queue is empty.
#310–315 remain separate; #316 remains deferred by explicit author instruction.
Record new #313 historical-mass and #314 ice/lava decisions in their own patches.

## 5.4.47 - Production siege adrenaline (#361)

Revised author scope: maximum only for active MAP03 NPC/monster attackers and
defenders; the player is always excluded to preserve seal balance. Restore the
pre-issue player code and remove its now-unused encounter cache. Native controls
cover NPC formulas/lifetime plus ordinary player penalties, decay and finite
seal spending/exhaustion. Recheck old/current/earlier-preview saves and hub travel;
Six complete revised cases pass6,928 assertions, including642 isolated controls;
the initial6,830 assertions belong to the superseded player-inclusive candidate.
The author accepted the revised NPC-only CA361-01 on 2026-10-18. No author
checks remain outstanding; all six old CA318/CA327 checks are also accepted.
FPS work remains deferred.

## 5.4.46 - Revised house transition (#334)

Implement the author's replacement contract: Melt in both directions, retaining
arrival autosaves and global settings. Own-source capture, cancellation and
visited-hub controls pass13 runs/82 checks in validation_5446. The older CA334-01 acceptance
does not approve this revised presentation. The author accepted the other preview
checks, including CA353-01, then approved the corrected exit on2026-10-18.
CA334-02 is complete; older CA318/CA327 checks remain unchanged.

## 5.4.45 - Artillery navigation breath fixed (#357)

Implemented and verified against the author's real siege autosave: 20 false
navigation attacks become zero; all 20 tracked bodies move again within 175
tics. Isolated Mandinga/Zupay controls pass 41 assertions. The author accepted
the narrowed CA353-01 group-behavior retest on2026-10-18; other steps were already
accepted. CA318/CA327 checks are not implicitly closed. The author also
reported house exit presentation; that follow-up remains scoped to #334.

## 5.4.44 - Structural-cache investigation delivered (#354)

Completed private writer-notification prototype,3,958 native assertions, two
cached-read audits and 18 normal-combat presented-frame comparisons. All nine
checkpoints match across variants. Paired medians+0.20% city/+2.95% front include
negative pairs; no consistent FPS benefit is established. Retain conservative
production guards; do not promote the private candidate. Evidence is archived
in validation_5444. Next profiling should localize remaining update/render
stalls. The approved siege-adrenaline production work remains separate;
CA353-01 and wider #318/#327 author checks are still pending.

## 5.4.43 - Adopted production caches and group targeting (#353)

Scope: production adoption of the three author-approved #318 improvements,
automatic at the existing >=500 threshold. Derived state, native mutation hooks,
subscriber lifecycle and reversible save/hub migration are implemented.
Native regression passes 3,705 assertions, save/reload/forward migration, both
hub legs and two cached-read audits. Presented-frame evidence is recorded in
validation_5443. CA353-01 remains an actionable author check. This does not close
the wider #318/#327 performance/route work. #354 separately investigates fewer
structural dependency reads; no research approximation is adopted here.
The18-run production comparison improves every paired candidate, but city46.80
and front32.20 median FPS plus high frame-time tails do not meet stable50FPS.
Retain the broad control ranges in validation_5443 when interpreting gains.

## 5.4.42 - Actor-local 100-tic maintenance trial (#318)

Requested: compare statistics/inventory/resources first, then targets and
temperature, with local invalidation and staggered fallback. Include maximum
siege adrenaline and simplified wound penalties; preserve hunger/thirst
consumption/damage. The private candidate passes 1,068 assertions and three
700-tic audited comparisons with zero cached-read mismatches. The 72-window
presented-frame comparison is complete: caches/resources improve paired FPS
2.81% city / 3.35% front. Target100 adds more but changes combat; thermal100
changes numerical results. Wound simplification has no consistent extra FPS
gain. Normal build/loading, source equality, static validation and review pass.
Next: select improvements using matched FPS plus gameplay evidence, then apply
accepted changes automatically under the existing >=500 policy with participant
scope, complete mutation hooks and save/hub/lifetime checks. Target100 and
thermal100 require a deliberate behavior decision; the solver is not equivalent.
No existing author test is confirmed by these agent measurements.

## 5.4.41 - Isolated siege update costs (#318)

Completed: 66 windows / 23,100 sampled tics, nine individual families plus
bracketing all-off controls, three repeats and two cameras; zero unexpected
spawns, losses, external pose changes or health loss. All windows preserve
600/998 living soldiers/Mandingas and 8,910 actors. Reproducible scripts, raw
logs and hashes are in validation_5441. Target selection and the residual Tick
are the first paths to investigate. No subsystem is declared dispensable.
Static validation, index, normal build/member equality and native compilation/loading smoke pass; temporary keep-awake released.
Next: validate any production optimization in matched normal combat, including
presented-frame timing when the collector is available. Do not sum isolated
cores or interpret their FPS as normal combat. Existing author checks remain.

## 5.4.40 - Shared rest safety (#325)

Verify visible/hidden/friendly/dead boundaries, real bag/bed and MAP01/MAP02
contexts, each periodic effect and heat, actual attacks/death, current/legacy
saves, cloud refusal and subsequent recovery. Keep unsupported exact forecasts
explicit. Completed: 28 native runs/278 assertions, review, validation/build and package
equality. CA325-01 was accepted by the author on 2026-10-18; no rest author
checks remain.

## 5.4.39 - Voluntary-jump wall cushioning (#339)

Compare native jump ascent/descent against the unchanged runtime, then exclusions,
excess energy, HP, landing, buckler and save/travel lifecycle. Keep displacement
controls distinct from normal native input and recorded author acceptance.
Completed: 135 current/41 baseline native assertions, review, validation/build.
CA339-01 was accepted by the author on 2026-10-18; no jump-cushioning author
checks remain. No new biological coefficient or collision exemption.

## 5.4.38 - Complete top-aligned map legend (#321)

Verify the entire collapsed panel disappears except its localized show hint;
expansion stays at the top with normal/large UI, English/Spanish and remapped
keys. Five runs/28 assertions and three inspected rendered configurations pass;
normal packaging matches the tested source. CA321-02 was accepted by the author
on 2026-10-18; no legend author checks remain.

## 5.4.37 - Current MAP03 attribution supplement (#318)

Eight measured native runs are retained in validation_5437. Normal bounded
deployment now underlies the comparison; do not reuse old full-population
fixtures. Remaining work: isolate shared-target/LOS search bursts and combat
update work with matched controls, then measure any safe improvement through
presentation data and a longer normal siege. Preserve perception cadence,
individual combat/resources/collision and author-approved caps. No subsystem is
removed based on an inclusive profile. CA318-01..05/CA327-01 remain pending.

## 5.4.36 - House-door presentation isolation (#334)

Implemented explicit house-door intent and inherited-overlay cleanup. Native
verification passes8 runs/64 assertions: normal cart/ship effects, both directions
of real portal Use and inside/outside autosave reloads. Review, project validation,
build and16,375-member equivalence pass. The early vehicle/house reproduction
injects only the approach. The author approved house transitions on 2026-10-18,
completing CA334-01 for that release; revised CA334-02 is pending. Evidence:
validation_5436. The diagnostic attribution limit remains unchanged.

## 5.4.35 - Prisoner escort replacement (#322)

Implemented one movement owner, inert waiting poses, individual player-formula
walking, bounded local navigation and collision-safe recovery. Native validation
passes 23 runs/375 assertions, including group stillness/resumption, narrow doors,
height changes, current/legacy saves and the full rescue/reward itinerary. Review,
project validation and 16,375-member package equivalence pass. CA322-01 was
accepted by the author on 2026-10-18. The isolated preview launcher is
assets/validation_5435/preview.ps1; its terminal stays open after the game closes.

The earlier following/idle confirmation was completed by explicit prisoner
approval on 2026-10-18; no CA322-01 author checks remain. Known development
limit: a compact row of all four can still block reversal in a 96-MU corridor;
this acceptance does not establish a fix for that obstruction.

## 5.4.34 - Active-play autosaving (#324)

Implemented the shared periodic/checkpoint/arrival owner and last-autosave clock.
Native validation passes 36 runs/138 assertions: the full 300-second interval,
pause/menu/console, acceleration, deferred/late invalid bodies, queue/travel races,
native slot settings and generated-file loading with retained state. Independent
review, project validation, build and all 16,373 package-member comparisons pass.
Evidence: assets/validation_5434. The author approved autosave on 2026-10-18,
completing CA324-01; no autosave author checks remain. The short preview seeds ten
seconds remaining without changing production timing. Follower turning/slowness
reported during that preview belongs to #322, not autosave acceptance.

## 5.4.33 - Western crusher sector isolation (#323)

Implemented the generator ordering correction and exact-footprint invariants.
Static comparison changes only the intended sixteen cells; repeated generation
matches. Native baseline/current walking, all nine crusher cycles, neighboring
ceilings, before/during saves and exact revision-4 recovery pass (108 current,
26 baseline and 10 recovery assertions). CA323-01 passed on 2026-10-17.
Evidence: assets/validation_5433. #312 damage/pressure rules remain separate.

## 5.4.32 - Direct demon projectile aim (#320)

Implement the author's explicit direct-aim exception after identifying #259
spread as the cause. Verify current target position/elevation, native attack
states, the >=500 population path, unrelated spread and previous-runtime saves.
Completed: 504 current/488 baseline native assertions, validation/build and
package equivalence pass. Evidence: assets/validation_5432. CA320-01 passed
on 2026-10-17; author observed direct fire/stone aim in the preview.

## 5.4.31 - Collapsible map legend (#321)

Implement hidden-by-default help, real binding hints and a discoverable toggle.
Native UI, rebinding, save/load/travel and resolution checks are recorded in
assets/validation_5431. Author check CA321-01 accepted on 2026-10-17; scope in HISTORY. The controls
generator preserves its nongenerated aliases; no map/progression rule changes.

## 5.4.30 - Sleeping bag quick-item access (#319)

Implementation delegates native Use to the existing bag interaction without
consumption; selection includes only personally carried bags. Focused input,
storage, rest and persistence checks: assets/validation_5430. CA319-01 was accepted on 2026-10-17. Other issues #318/#320-325 retain
their separate scope, commits, tests and PRs.

## 5.4.29 - Adopted MAP03 city (#327)

Implement the author's MAP01/MAP02 preservation, low-sky MAP03 adoption and named
test scenarios; retain private interiors and stable world identities. Normal
reinforcements use a 6,600 reserve and 1,000 deployment cap with resurrection
unchanged. Current static/native evidence is assets/validation_5429; manual
checks remain in the single pending_test.txt. #318's unresolved performance
acceptance is not closed by renaming maps or merging code.

Follow-up performance work: the cumulative Attackers history can reach 6,601
entries. Machine observation below the density threshold and command/target
consumers still traverse historical entries. Profile the late battle with few
living bodies before choosing a registry optimization. Do not repeat a 6,000
simultaneous body test or infer a measured cost from source inspection alone.

## 5.4.28 - MAP06 issue #318 (contact heat implemented; map performance unresolved)

Variable-sky follow-up completed as an isolated experiment: 184-MU house/shop
districts, 1,024-MU wall/exterior region; 871 native assertions and 24 fresh
ETW windows. Fresh paired ETW means (tall opaque walls versus zoned sky): exterior forward 280.79-284.08 versus 330.73-337.53 FPS; exterior ground 103.47-114.89 versus 121.75-123.65.
Within the residential street, forward means are 268.93-272.96 versus 261.85-268.56 FPS; ground-facing means are 205.90-244.94 versus 219.61-252.60.
With 600 defenders, the 1,000-attacker city view measures 3.85-5.05 versus 6.42-7.16 FPS and the front line 3.72-4.44 versus 3.53-4.39. The unchanged opaque control is substantially slower than in the earlier session despite identical package/config/population records; the cause is not established. Compare fresh pairs only, not historical FPS as a new baseline.

During this batch the author permanently retired the 6,000-simultaneous-attacker scale. The final active test was stopped immediately; three already-completed runs and the interrupted fourth remain archived outside the current comparison. Never rerun that scale. Continue with peace and 1,000/600 controls; do not invent a new production budget.

Next: author review of sky transitions and physical flight/roof restrictions
(CA318-05), then a production-compatible geometry decision. Normal geometry
and army counts remain unchanged. Bounded attacker deployment and repeated
target/body simulation remain outstanding; these tests do not close #318.

Earlier house-hub implementation (author decision 2026-10-17): preserve the 160 house
footprints, heights and every street width; move interiors to individual native
hub maps; keep residents present/interactable and retain each body's state;
deploy them from their own doors; add period-style signs for existing shop stock.
Native portal/state/save/deployment and status/death/placement checks pass;
private-map, exterior-map and sign regeneration is byte-identical. The normal
16,370-member package matches the native runtime and source. The ETW report
is complete; author tests remain pending. The comparison
includes the author's second variant: the same interiors with house walls raised
to the existing sky ceiling, without changing XY boundaries or production height.
All 28 valid native measurement windows are complete, including separate
1,000/6,000 profiles and CAH158. Three premature startup changemap attempts are
excluded from interior results. Opaque closure improves peaceful forward FPS
from 36.62-37.03 to 402.03-405.19 and ground-facing FPS from 28.54-29.76 to
165.66-166.03. The 1,000-attacker central siege remains 27.97-29.88 FPS with
closure; its front-line view does not improve. Both 6,000-attacker variants
remain near 0.7 FPS / 12 tics/s. CAH158 exceeds 1,000 FPS with three residents.
Next: choose a production-compatible occlusion design and address bounded
attacker deployment plus repeated target/actor work without inventing budgets
or perception rules. The diagnostic 1,024-MU walls are not adopted geometry.
Do not close #318 on these house tests: synchronous attacker deployment and full
siege playability remain separate outstanding acceptance requirements.

The author requires exhaustive measurement, a functional peaceful city and siege,
bounded normal deployment, and diagnosis of ground-facing slowdown. Audit evidence:
[validation_issue318](../assets/validation_issue318/RESULTS.md). KNOWN_PITFALLS
CA-KP-110 onward is the maintained performance guidance requested by the author.
The authorized contact-only breath heat is implemented with receiver-owned
energy and revisioned save migration. The 1,000-Mandinga control retains 600
soldiers and does not change production counts. The global-scan exception policy
is in AGENTS/CA-KP-115. Conservative MAP06 boundary reduction is integrated;
native finite-height city doors are also integrated. Ordinary deployment remains
unchanged. CA-KP-116/118 record the geometry and native-door limits.

On 2026-10-17 the author additionally authorized replacing MAP06's 960 door
leaves with native PolyObjects after inspecting gz_bigcity's working swing door,
and explicitly waived compatibility with previous saves for this work. Preserve
the existing backups, but prioritize fresh-game behavior and measured performance.
The replacement removes 7,680 blockers, retaining the current models, paired
operation, access checks, NPC requests, finite height and obstruction protection.
Native DoorSwing alone thrusts bodies and cannot renew an active wait; production
instead uses guarded native rotations and a temporary controller per active pair.
Current-game save/hub checks remain relevant despite the old-save waiver.

The author-requested flat-map comparison is complete: 40 native measurements
cover 6,000/1,000 and 1,000/600 combatants, sprites/Domingo MODELDEF, inventory
removal, frozen render controls and sampled profiles. The 1,600-body battle
maintains about 35 tics/s; its 30-simulated-second windows average 53.54 FPS
with sprites and 43.76 with Domingo, versus 0.86/0.81 FPS at 7,000 bodies.
This is not stable 60 FPS: the 1,600-body sprite window has empirical p95/p99
frame intervals of 22.31/99.76 ms. Its final HUD snapshot near 77 FPS is a point
sample, not the window mean. Inventory removal improves onset, but sustained
1,600-body measurements (49.86/42.74 FPS) do not establish a lasting benefit;
weight, attack air, collision mass and longer combat outcomes also change.
Fixtures preserve individual bodies/resources/collision and omit MAP06's city
routes, carbine orders, cannons and reinforcement controller. No army total,
inventory rule or production art changes follow from these diagnostic results.
FLAT_VERIFICATION.json checks all populations, matching visual-variant end
states, empty inventories and process cleanup. CA-KP-119 records the limits.

Remaining implementation/acceptance work:

- Bound ordinary attacker creation/registration; resolve any new design budget
  explicitly, preserve finite reserves, crews, commander and victory accounting.
- Remove or justify inherited global scans in affected systems, including the
  utility wand's separately approved radiation. Preserve its rules until an
  equivalent measured implementation or author-approved change is available.
- Obtain author acceptance of the integrated native doors and measured improvement.
- Continue reducing city geometry cost beyond the integrated conservative pass.
  Preserve roof/flight, views, thermal shelter and current-game hub continuity. The
  closed-house control changes upper space and is not an approved design.
- Verify peaceful traversal, pitch changes, actual time skip, approach and sustained
  combat using application presentation and simulation metrics on the final build.
- Verify fresh/pre-siege/full-army saves and hub state; obtain author playability
  acceptance. CA318-01/02/03 in pending_test.txt cover contact heat, geometry and doors;
  it is not acceptance of full MAP06 performance. No unconfirmed pass is recorded.

## 5.4.27 - Normal prisoner escort speed (#307, accepted)

Use normal resolved movement speed while following; keep existing proximity and
the author-confirmed recovery teleport. Branch fix/issue307-prisoner-follow-speed
stacks on #305/PR308. Native movement, modifiers, collision and save compatibility
pass with 334 current-runtime assertions and 14 legacy-control assertions;
validation/build pass. Evidence: validation_5427/RESULTS.md; delivery PR317.
CA307-01 passed author review on 2026-10-16 without reported exceptions. The
author confirmed all tests passed and authorized merge/closure of #304, #305 and
#307. No implementation or author-test work remains for these deliveries;
pending_test.txt is empty. Release 5.4.27 and the tested runtime are unchanged.

## 5.4.26 - Active seal lookup optimization (#305, accepted)

Implemented on feat/issue305-active-seal-registry, separately from #304/PR306.
Native equivalence, existing seal rules, current/old saves and map/hub transitions
pass. Repeated matched MAP06 controls retain NPC thermal simulation and improve
approach throughput by approximately 60% and saved-combat throughput by 85%.
Evidence and limits: validation_5426/RESULTS.md; delivery PR308. Accepted by the
author on 2026-10-16. Earlier that day the author requested
resumption, commit and push; delivery validation and 27 repeated native checks
pass against the unchanged tested runtime. Remaining
combat costs are follow-up profiling candidates, not changes included in #305.

## 5.4.25 - Performance issue #304 (accepted)

Branch feat/issue304-siege-performance. Implement and validate the production
MAP06 100-visible-corpse FIFO archive with saved resurrection and dropped-loot
retention. Run isolated 6,660-total/1,000-live reinforcement boundary checks,
repeated NPC thermal and 3-second targeting comparisons, and soldier sprite/3D
controls using the accepted prototype. Reuse prior profiling infrastructure;
keep implementation, profiling and art-control evidence separately scoped.
Archive/save/hub/old-save/Redemption and thermal-clock native checks passed.
Repeated approach controls, long natural battle and exact reserve/corpse controls
are recorded in validation_5425. Final saved-combat/capture checks pass; CA304-01
passed author review on 2026-10-16 without reported exceptions. Delivery: PR306.
Removal of thermal simulation or target-period changes is outside this scope. The
active-seal lookup optimization is delivered separately by #305.

## Current V5.4 batch completion

All 24 requested issues (#237-254, #259-261 and #282-284) are implemented and
accepted within their documented scopes. No implementation or author-test work
remains for that batch. Every focused issue PR is
merged. PR303 delivers the assembled history to main and closes the completed
issues, as authorized on 2026-10-15. The #283 full modular migration remains
future roadmap work. The version sections below preserve earlier checkpoints;
their former queues and merge restrictions are superseded by this status.

## 5.4.24 - Demon combat and rock (#284, accepted)

Branch feat/issue284-demon-fire-rock follows accepted #283 and implements the approved
physical-plus-Fire machete with one impact and weighted Toughness, demon
personalities without base-attribute changes, and cosmetic Zupay rock. Keep
combat/personality and art commits separate within this issue's PR.

Focused combat/action, migration/reload/hub/rollback and rendered checks pass,
with 62 assertions across eight scoped runs. Deterministic generation, static
validation and 16,192-member package parity pass. CA284-01 passed author review
on 2026-10-15; PR302 is merged and pending_test.txt is empty. PR303 delivers
the author-authorized batch integration. V5.17 owns the deferred modular
3D migration. The isolated trial launcher remains in validation_5424.

## 5.4.23 - Domingo 3D prototype (#283, accepted)

On 2026-10-15 the author accepted the corrected prototype and explicitly ended
#283 at that scope. CA283-02 is accepted; HISTORY records the qualified result.
PR301 is ready. The author clarified that the later sprites work is in the
roadmap, not an existing issue; do not create a duplicate issue for this handoff.

The V5.17 presentation roadmap in PROJECT now owns sprite-to-model migration,
mandatory interchangeable weapon/shield/armor/hair/face parts, remaining timed
rest/provision animations, finer polish and representative performance checks.
Keep the approved timings/control rules there; these deferred features are not
implemented by the fixed-surface prototype. Original sprites and all evidence remain.

Next implementation: #284, on its own branch, commits, tests and PR. Its scope
preserves Mandinga attributes and adds the approved machete Fire, personalities
and cosmetic Zupay rock. The author has not requested new batch merges here.

## 5.4.22 - Quick-use HUD (#282, accepted)

Branch feat/issue282-quick-use-hud: native selection/use, bottom-center carousel,
name/count above the selected icon, smaller neighboring icons, independent
water-container previews, Box exclusion and idempotent old-save reconciliation.
Static/build, 47 assertions in 11 final native runs, and four rendered views pass
(validation_5422). CA282-01 passed author review on 2026-10-15; PR300 is ready.
The author returned and temporary keep-awake was released without changing the power plan.
Next: #283's editable Domingo 3D pilot, then revised #284. No batch merges or
closures have been authorized.

## 5.4.21 - Seal extensions (#252, accepted)

Branch feat/issue252-seal-climate-extensions targets integration/v54-accepted-251-238.
All requested formulas and the chasecam/ground-emblem addition are confirmed.
Static validation, normal packaging and 233 assertions across 20 qualified native
runs pass: formulas, geometry, defenses, flight, presentation, save/load, travel
and old-save migration. The 500-body service benchmark is not full-battle FPS
evidence. CA252-01 passed author review on 2026-10-15; PR299 is ready.
Its first visual review reported incorrect ground placement and Water's image.
The revised scene includes the corrected marks and newly requested purely visual
elemental orb above the head. The final depth correction keeps the mark behind
the body; 88 further native assertions and rendered views passed before approval.
#237's completion audit is ready; next #282, #283 and #284 stay separate. The author
added #283 (editable animated Domingo 3D pilot) and #284 on 2026-10-15. The revised
#284 preserves Mandinga's base attributes, adds magical Fire damage to its
physical machete hit, assigns approved personalities to both demons, and gives
Zupay's existing projectile a purely cosmetic 3D rock. Each requires its own
branch, evidence, commits and linked PR. Shared #238 completion is
already delivered as aa253eed / PR280; it is not pending #252 gameplay work.


## 5.4.20 - Arcane Cloud (#251, accepted)

PR281 continues from accepted #250 baseline e9c79de8, retaining the original
5.4.5 cloud asset/provenance. Shared casting, seated native flight, full-factor
attribute scaling, restorative rain, Air-seal lightning and saved lifecycle are
implemented. SYSTEMS is the current contract; validation_5420 records native
input, effects, overlap, interruptions, collision, flight ownership and travel
checks, including the repaired transition crash. CA251-01 passed author review
on 2026-10-15; PR281 is ready. No merge/closure is authorized in this batch. #252, the #238/#237
completion audits and later #282 retain their separate scopes.

## 5.4.19 - Redemption (#250, accepted)

Branch feat/issue250-redemption starts at accepted #249 commit 6578c8b7 / PR297.
SYSTEMS records the confirmed moving area, corpse eligibility, recovery, Toughness,
once-per-cast identity, no-duplicate-rewards and travel rules. Restoration, mobile
area membership, temporary following/allied attacks, fixed-Toughness consumers and
saved lifecycle are implemented. Native casting, corpse/resource/defense tests,
reload/hub/pending arrival, real journeys and neutral copied-save roundtrip pass;
validation_5419 retains exact scope and hashes. CA250-01 passed author review on
2026-10-15; acceptance.json/HISTORY retain the confirmation and PR298 is ready.
No merge/closure; broader campaign/network checks are not claimed.

## 5.4.18 - Summoning (#249, accepted)

The implementation branch feat/issue249-summoning starts at accepted #248
b87f977b / PR296. SYSTEMS and the issue record the author's placement, replacement,
attribute-scaling, targeting, death and travel decisions. Static checks, packaging
and 132 assertions in 19 native runs pass (validation_5418), with copied-save
upgrade/rollback/return and agent visual review. CA249-01 passed author review on
2026-10-15; the pending entry is removed and PR297 is ready. No merge/closure.
#250-252 keep their scope; #282 follows the batch.

## 5.4.17 - Rally (#248, accepted)

The author confirmed moving visible-allied area, current maxima, delayed first
pulse, full-factor Empathy scaling, pre-hit bar snapshots, final outgoing/incoming
damage scaling, strongest overlap, renewal and self-damage protection. Periodic
effects apply Rally only once per damage event, not also to their stored dose.
Implemented on feat/issue248-rally, ready PR296 based on accepted #247 / PR295. Static,
normal package and 74 qualified native assertions pass, including copied-save
upgrade/rollback/return. CA248-01 passed on 2026-10-15; acceptance.json/HISTORY
retain the offered scope. No merge or closure is inferred.
#249-252 remain separately scoped; #282 follows the batch.

## 5.4.16 - Formation Breaker (#247, accepted)

The author's traversal, stance, running-cost, collision and afterimage decisions
are now explicit in SYSTEMS and issue #247. Implementation uses the accepted #260
native gesture and #238 class preparation. Native interruption, collision, appearance,
preparation/save/load, hub and copied-save checks pass; see validation_5416/RESULTS.md.
CA247-01 passed on 2026-10-15; acceptance.json/HISTORY retain the offered scope.
PR295 is ready, stacked on #260/PR294; no merge or closure authorized.
Temporary keep-awake is released. #248 is delivered and accepted above; #249-252 remain separately scoped, and #282 follows the batch.

## 5.4.15 - Player acceleration and impulse (#260, accepted)

Both the linear mass-based ramp and the authored Air-paid 0.4-second double tap
are implemented on the focused branch/PR294 based on #253. Native evidence:
assets/validation_5415. CA260-01/02 passed on 2026-10-15; PR294 is ready for review.
Acceptance retains this same version and leaves no #260 author check queued. No merge/closure is authorized.
#247 now consumes the forward gesture in its separate 5.4.16 patch above.
#248-252 retain their own designs; #282 follows the batch. CA246-01/CA253-01 passed.

## 5.4.14 - Resident participation at the protected floor (#253)

Reproduced in native MAP01 with the ordinary encounter controller and forward input:
player reached 1 HP on tic 131 and stayed alive; encounter references remained.
All four healthy resident movement bases were zero. A scoped fresh-spawn repair
and revision-1 saved-base repair recover authored defaults without replacing actors
or replenishing resources. Positive custom bases and genuine downing are retained.
Evidence: assets/validation_5414. CA253-01 and CA246-01 passed on 2026-10-15.
HISTORY and the corresponding acceptance.json files retain scope and run evidence. Keep this
PR separate, based on #246. No merge or issue closure. #247-252/#260 still require
their unresolved author design decisions; #282 follows the batch.

## 5.4.13 - Arcane Sun (#246)

Implemented the author's replacement Mage ability using existing elemental damage,
defense, visuals and paid class lifecycle. Author confirmations on 2026-10-15 settle
reference damage, speed, character pass-through, one impact per enemy, sight/range,
burning cadence/tail, guided targeting, child persistence and native radial falloff.
Focused automated evidence and copied-save helpers: assets/validation_5413.
CA246-01 passed author review on 2026-10-15; HISTORY and validation_5413/acceptance.json
record the result. Keep the focused PR based on accepted #245;
no merge or closure. Remaining class issues, then #282, stay separate.

## 5.4.12 - Miracle (#245)

Implemented Priest's moving recovery area through the shared class lifecycle and
authoritative player/NPC resource consumers. Author decisions on 2026-10-15 cover
current maxima, additive ordinary recovery, dynamic membership, pulse-time sight,
native allies excluding neutrals/enemies, first pulse after one second, strongest
overlap and renewal without clock reset. Focused checks and compatibility helpers:
assets/validation_5412. CA245-01 passed author review on 2026-10-15; HISTORY and
acceptance.json preserve the confirmation. PR291 is ready, based on accepted #244;
remaining class issues and then #282 stay separate.

## 5.4.11 - Survival Instinct (#244)

Implemented the Explorer's shared class release and four temporary contributions
at real consumers. Author confirmations cover both attack categories, current-value
composition and combat/ability Adrenaline gains excluding tutorial/debug reserves.
Focused native evidence and compatibility helpers live in assets/validation_5411.
CA244-01 passed author review on 2026-10-15; HISTORY and acceptance.json preserve
the confirmation. PR290 is ready for review, stacked on accepted #243. Remaining
class powers and then #282 retain separate scope and delivery.

## 5.4.10 - Battle Cry (#243)

Implemented the shared Warrior cast, release-time enemy/sight selection, attack
gates, continuous-attack interruption and siege staffing distinction. Native
weapon, NPC, movement/defense, projectile/DOT, save/hub and compatibility evidence
lives in assets/validation_5410. CA243-01 passed author review on 2026-10-15;
HISTORY and acceptance.json preserve the confirmation. PR289 is ready for review,
based on accepted #239. Remaining class issues and then #282 stay separate.

## 5.4.9 - Hunter's Instinct (#239)

Implemented effective stealth in native movement noise, rear melee/sweep chance
and saved projectile eligibility/chance/roll. Existing caps and critical damage
remain. Native weapon, geometry, payment, noise, damage and persistence evidence
is recorded in assets/validation_549. CA239-01 passed author review on 2026-10-15;
HISTORY and acceptance.json preserve the result. Complete visual perception stays with its roadmap;
keep remaining class powers and #282 in their separate issues/branches/PRs.

## 5.4.8 - Socialization (#240)

Implemented current Dialogue/Persuasion multipliers, continuous payment and
authoritative visible-page snapshots. Actual native Ronnie/Caella responses,
manual stop/exhaustion, active/stopped saves, hub travel and compatibility checks
are recorded in assets/validation_548. CA240-01 passed on 2026-10-14; HISTORY and
acceptance.json record the author's confirmation. Keep #239 and the remaining
class powers in their own branches, tests, commits and PRs; #282 follows the batch.

## 5.4.7 - Telekinesis (#241)

The approved targeting, F/m force, mass-based payment and action suppression are
implemented on their own branch. Native body/scenery input, physical movement,
release, persistence and rollback evidence lives in assets/validation_547.
CA241-01 passed author review on 2026-10-14; HISTORY and validation_547/acceptance.json record the result.
Keep remaining racial/class powers and #282 in their separate issues and PRs.

## 5.4.6 - Supernatural Breathing (#242)

Implement the approved Caelith User1 Anima-for-Air substitution with all existing
Air consumers, normal modifiers, complete-effort fallback and no fixed drain.
Production integration is present. Native input checks cover sword, firearms,
bow/crossbow, javelin, bolas, fists, running, jumping and gauntlet blocking.
Native immersion, save/load, hub return, old-save upgrade and a reversible
5.4.4 bridge pass. CA242-01 passed author review on 2026-10-14; acceptance is
recorded in HISTORY and assets/validation_546/acceptance.json.
Keep the remaining racial powers in their own
branches and PRs. The Telekinesis force/range/control decisions are recorded in
#241; no Telekinesis movement is implemented by #242.

## 5.4.4 - Shared class preparation (#238)

Production User4 now uses the shared 105-tic presentation, fixed-cost progressive
payment, full-cost admission, cancellation and release-only reuse. Native attack,
block, weapon/inventory change and other-power activation guards are integrated.
Revised Sleep counts actual HP-losing impacts after defenses, supports final-damage
scaling, neutral/ally exceptions, expiry and renewed-hit/power/remaining-time rules.
SYSTEMS records the approved contract; do not re-ask those decisions.

Evidence: assets/validation_544. Lifecycle contract: 1,021 native assertions;
partial-payment/Sleep save and reload pass; MAP02 -> MAP03 -> MAP02 retains paid
preparation and NPC hit counts, with one release. Earlier component/HUD evidence
remains separately identified. CA238-01 covers only executable preparation/HUD
author checks, passed on 2026-10-14; this does not complete the whole issue.
The requested smaller class/racial icons use centered 64-unit frames. Native
HUD state checks pass at 1280x720 and 640x480 with high scale; the author also
approved icon size in CA238-01. Evidence: validation_544/small_icons.json and acceptance.json.

Eight living views now cover rat/Bull/Mandinga/Zupay. Native checks cover all
four bodies, hit/expiry wake and saved pose/counters; CA238-02 passed on 2026-10-14.
Shared racial lifecycle is integrated: 43 native contract/input checks cover all
nine weapon families and unarmed; saved object/debit and hub return pass. The
factory remains empty until each #239-242 consumer is implemented. The existing
journey forecast refuses active effects it cannot simulate; native hub travel
retains them. Shared paid-state rollback/re-upgrade checks now pass through the
pinned optional 5.4.3 schema bridge; PR280 is ready. Each consumer's input/effect
checks belong to #239-242, new class effects to #243-251 and movement to #260.
The shared controller is complete within this scope. No merge or closure is
inferred from component or author checks.

Queue: finish the current 21-issue batch (#237-254 and #259-261), then implement
#282, with its own branch, scope, tests, commits and linked PR. The author requested
this order on 2026-10-14; #282 is not part of the #238 patch.

## 5.4.3 - MAP02 rat movement and audio (#254)

Implemented and engine-tested the rat-only initialization repair, idempotent
saved-body migration and alert/bite/pain/death cues. The final contract passes
11 assertions; old-save upgrade, reload, rollback and hub return pass. Audio
regeneration is byte-identical. The author passed CA254-01 on 2026-10-14;
assets/validation_543 records scope, fixtures and earlier failed approaches.
No new population, balance change or broader combat-AI repair belongs here.

## 5.4.2 - Equipped-Seal resistances (#261)

Implemented fixed matching-pair factors (0.5) and Quintessence (0.85), including
actual direct/area attacks and fractional harmful DOT. Character's existing body
average now includes the equipped Seal. Native evidence: assets/validation_542;
CA261-01 passed on 2026-10-14 after the four-element correction; PR274 is ready
for review. Existing Human innate armor is 7.5%. Class/racial
lifecycle and social scaling belong to #238 and their individual issues.
Do not merge or close the new batch without instruction.

## 5.4.1 - Weapon dispersion tiers (#259)

Implemented the approved family/tier/Lucidity rule in actual player and NPC
weapon consumers, preserving single-tier tools and natural attacks without an
authored weapon identity. Source and native validation: assets/validation_541.
CA259-01 passed on 2026-10-14; PR273 is ready for review. No merge is inferred.
The separate #238 lifecycle uses the author's latest confirmed Sleep hit rules
and continuous racial toggles; this patch does not implement those powers.


## 5.4.0 - Attribute audit (#237)

Completed the source-to-consumer matrix, fractional/0/100/above-100 boundary
checks, equipment/Tarot ordering and representative NPC/personality verification.
The isolated engine audit passed 160 assertions; evidence: assets/validation_540.
No gameplay rebalance, save migration or new author-input test is part of this
documentation delivery. The 2026-10-15 completion on accepted 5.4.21 refreshes
real class/racial consumers and passes the same 160 native checks. SYSTEMS owns
the remaining academic/perception/survival and parity decisions; the V5.4 social
ability contract is resolved. PR272 is ready, based on integration/v54-accepted-252.
Derived fields/debug observers must not be counted as completed effects. Commit/PR review remains separate
from author acceptance; do not merge or close the new batch without instruction.

## 5.3.9 - Exploration entry points (#236)

Implemented the entry-point audit, shared Explore navigation, native popup
adapters and a read-only owned keys/documents view. Existing pages, filters,
travel confirmations, notes and world/local ownership remain authoritative.
No new default binding, saved schema, document body or note gameplay effect.
Static/build and 202 native assertions passed; 28 save comparisons and 17
inspected captures are in assets/validation_539. On 2026-10-14 the author passed
CA236-01's first five handoff steps: connected navigation/Back, Crafting entry,
non-consuming document viewing, map center/zoom and owned/tracked save-load.
CA236-01 passed full author acceptance on 2026-10-14. No merge is inferred.

## 5.3.8 - Multiple mission tracking (#235)

The subsequent author request adds a native target symbol at current known
destinations, updated on stage changes and removed on untracking/completion.
CA235-02 passed author review on 2026-10-14; CA235-01 stays accepted.
No #235 author checks remain outstanding.

Implemented independent saved selections, native Journal action, shared objective
text, known-place associations and bounded map rows. Terminal/history/filter
semantics remain intact. The read-only catalogue hides premature legacy lesson
flags before their documented stages; underlying quest progress is untouched.
Validation evidence: assets/validation_538. On 2026-10-14 the author accepted
CA235-01's four presented handoff steps: independent T/button tracking with the
held-key latch, simultaneous map selections, filters/detail/Back and saved choices,
and terminal objectives leaving the map while remaining in history. CA235-01 passed full author acceptance on 2026-10-14.
Earlier author checks are accepted. Next separate patch: #236.

Future decision inventory, not implemented as guessed waypoints: precise NPC
disclosure events and positions for the refuge, moving companions, rune/secret
content and battle targets. Current tracking uses authored directions as text
and already-observed POIs only. Future author decisions are required before
adding these disclosures; they are outside this completed implementation.

## 5.3.7 - Existing-map exploration (#234)

Implemented the explicit SYSTEMS catalogue, existing actor bindings, ten mansion
room regions, observed sewer grates, current city gates/towers/services and
loaded-layout guards. No secret/loot/enemy annotation or new access rule.
The author approved one marker per south gate and east-arch crossing; siege-sector
warnings remain a design gap, explicitly deferred. Static/build and focused
native checks passed (151 assertions, 16 save comparisons). On 2026-10-14 the
author passed CA234-01's five mansion handoff steps, including entered rooms,
interacted services, secrecy and save/load. CA234-01 passed full author acceptance on 2026-10-14. #233/#258 are accepted; #235/#236 retain separate acceptance records.
CA234-01 sewer feedback exposed a category-only padlock despite an open label.
The marker now uses the saved observed access; the original runtime reproduces
the mismatch and the fix passes 43 focused native assertions.
The author confirmed the icon change and requested an open padlock;
dedicated transparent artwork replaces the initial hand only for observed-open
grates. Another 43 native assertions/two save comparisons passed. On 2026-10-14
the author accepted the three unlocked_handoff.ps1 steps: closed padlock on denied
use, open padlock after F8/key and successful use, and persistence on save/load.
Diagnostic positioning does not certify ordinary sewer traversal or secrecy;
those checks and the remaining CA234-01 cases subsequently passed on 2026-10-14.
The subsequent city handoff failed author review: gates retained the generic
hand and southwest factory stations added no marker. The same #234 patch now
records gate observations before/after use and binds all 96 authored factory
stations individually, with the current-layout guard and existing bilingual names.
On 2026-10-14 the author accepted the three cityfix_handoff.ps1 steps: denied/open
gate padlocks, separate workbench/adjacent-station markers, and save/load retention.
CA234-01 passed full author acceptance on 2026-10-14. This
acceptance does not increment the patch version or certify all 96 stations manually.
The focused city regression reproduces eight baseline failures and passes 92
corrected native assertions, five save comparisons and three inspected captures.
All 96 slots match the WAD; static/build and generator determinism checks pass.

## 5.3.6 - Manual map notes (#233)

Implemented native-center placement, clickable/native-navigation list, native
text input, editable category and confirmed deletion with character/map-owned
revision-one data. Save commands validate stable ID and serial. Notes are not
automatic knowledge and do not replace native numbered marks or bindings.
Native persistence/input/layout checks passed. On 2026-10-14 the author passed
CA233-01's five editing handoff steps, including accented/long text, cancellation,
deletion, save/load and presentation-only service categories. CA233-01 passed full author acceptance on 2026-10-14. Evidence: assets/validation_536.
Keep #234/#235/#236 implementation and acceptance separate.

## 5.3.5 - Personal POI knowledge (#232)

Implemented revision-one personal facts, stable map/POI identities, valid
service interaction hooks and read-only native icon/name presentation. Scope
excludes authored map registrations and remote NPC information. Native renderer
privacy limitation: derived icons are suppressed with multiple participants.
Evidence: assets/validation_535/RESULTS.md. CA232-01 passed author acceptance
on 2026-10-14 after the corrected MAP04 handoff; the earlier MAP03 fixture
failure remains documented. No merge or issue closure is claimed.
Continue #233/#234/#235/#236 separately: manual Note + five service categories,
rooms/towers on entry and services on use, multiple tracked missions, then
Journal map navigation. CA258-01 passed full author acceptance on 2026-10-14.

## 5.3.4 - Native local cartography (#231)

Implemented native palette/header integration and the 4.14.2 support audit.
Static validation/build passed. Native checks cover floor captures,
discovery/save boundaries, languages/scales and bounded MAP06 behavior;
the recorded short-sample slowdown is not a new AI-performance pass.
Evidence: assets/validation_534/RESULTS.md. CA231-01 passed author acceptance
on 2026-10-13 after the author returned and tested the prepared map build.
No floor-selection policy or new marking binding is introduced. Subsequent
#232/#233/#234/#235/#236 retain separate discovery, notes, catalogue, tracking
and navigation scopes.

## 5.3.3 - Exhaustion sleep (#258)

Implement deterministic zero-Sleep lying, strict >10% standing eligibility,
truthful support and persistent enforcement without changing physics or
hazards. Author decision: immediately lie down in air/water without relocation.
Evidence: assets/validation_533/RESULTS.md; CA258-01 passed full author acceptance on 2026-10-14. Continue #233-#236 in separate branches, commits and PRs.

## 5.3.2 - Automatic provisions (#257)

Implement independent below-50% consumption, 100% seated/lying targets and
author-confirmed F/G pause/resume with mandatory below-50% restart. Preserve
real sources and unify native time paths. Evidence: assets/validation_532;
CA257-01 passed author acceptance on 2026-10-13. #258 will add exhaustion lying using the shared eligibility.
Follow-up discrepancy found during native comparison: time-skip forecasting
does not integrate evolving shivering/sweat costs. Do not treat matching
portion counts as proof of an exact thermal/calendar forecast.

## 5.3.1 - Survival and combat presentation (#256)

Implemented Character resources, current evasion/criticals and mean elemental
resistance. Author decisions: unsupported category = Not applicable; fists use
their real 0% critical; resistance excludes Toughness; HUD columns ordered
Load/Lucidity/Health and Adrenaline/Anima/Air. Native evidence is collected in
assets/validation_531; CA256-01 passed author acceptance on 2026-10-13. No #257/#258 behavior is included.
For later #232/#234, rooms/towers become known on entry and services on use;
the author approved #233 as a separate delivery required by #236.

## 5.3.0 - Power indicators (#255)

Implementation and focused evidence: assets/validation_530/RESULTS.md.
CA255-01 passed author acceptance on 2026-10-13. Keep #256's survival presentation and
#257/#258 behavior separate. The requested V5.3 sequence is #231, #232, #233,
#234, #235, #236, each with its own branch, commits, tests and PR. The author
confirmed #233 inclusion and interaction/use-only POI discovery on 2026-10-13.

## 5.2.27 - Empty Magic Box weighs one gram (#229)

Apply the author's empty-mass decision separately from #227, retaining the
existing content divisor and gram truncation. Verify real inventory totals,
ownership and normal recalculation of a save made with the old 10 kg tare.
Evidence: assets/validation_5227. CA229-01 passed author acceptance on
2026-10-13; PR230 merge and #229 closure authorized.

## 5.2.26 - Rest control diagnosis and feedback (#227)

Expose T/F/G results within native rest, enable author-approved provision use
from chairs and sleeping bags without a table, synchronize x105 captions, and
test key/click dispatch, finite carried/Box supplies, genuine MAP01/MAP02
furniture, rejected actions and readable feedback. Evidence:
assets/validation_5226. CA227-01 passed author acceptance on 2026-10-13,
without qualifications; PR228 merged and #227 closed. Accepted safety and
finite-consumption rules remain.

## 5.2.25 - Staff matches statuette dispersion (#222)

Share the existing 2-20 degree category for the magical staff, preserving other
weapons and book homing. Native validation covers T1-T3 and actual shots at
Insight 0/100; evidence: assets/validation_5225. CA222-01 passed author acceptance
on 2026-10-13. All six current checks passed without qualifications; the author
authorized their PR merges and issue closures, now completed. The subsequent
rest report is tracked separately under #227 above.

## 5.2.24 - MAP02 Mandinga drops (#220)

Fix the generated predicate from real assignments; verify unassigned potion,
assigned key/ammunition, exhaustion, last unit, repeated death and save/load.
Evidence: assets/validation_5224. CA220-01 passed author acceptance on
2026-10-13; PR223 merge and #220 closure are authorized. The subsequent #222
staff adjustment and earlier checks were accepted in the same confirmation.

## 5.2.23 - Sewer sleeping-bag acceleration (#219)

Implement the author-approved MAP02 exception only for actual bag sleep,
retaining all danger guards and normal clocks/comfort. Validate T completion,
Y transition and waking, bag loss/Box storage, current and baseline saved rest.
Evidence: assets/validation_5223. CA219-01 passed author acceptance on
2026-10-13; PR221 merge and #219 closure are authorized. The separate #220
Mandinga loot repair and earlier checks are also accepted.

## 5.2.22 - Current menu controls (#215)

Implemented parenthesized existing controls across custom and native engine
menus, including remapped bindings and contextual precedence. Preserve native
search/key capture/save titles and verify complete captions at different scales.
Evidence: assets/validation_5222. CA215-01 passed author acceptance on
2026-10-13; PR218 merge and #215 closure are authorized. CA213-01 and CA216-01
were accepted in the same confirmation.

Static validation and normal packaging pass; all 16,053 official runtime
members match the final tested package. The selected native runs record 95
passing assertions, with inspected English/Spanish captures at 1280x720 and
960x720. Temporary keep-awake was released without changing the power plan.
Evidence and physical-input limits: assets/validation_5222/RESULTS.md.

## 5.2.21 - Visible tutorial gold (#216)

Fresh MAP01 games spawned the finite 2 kg gold actor with collision but no
model registration for its subclass. Register the existing gold-rock OBJ for
CaelumTutorialGoldVein; keep placement, harvesting, quota and depletion intact.
Native before/after captures and extraction/save-load checks are recorded in
assets/validation_5221. Author visual acceptance CA216-01 passed on 2026-10-13.

The author identified the reported obstruction as this same rock position.
The author authorized PR217 merge and #216 closure; no checks remain.

## Issue #213 - Resource bar layout (5.2.20)

Implemented: independent lower-corner anchors; author-approved 1.95 scale;
labels above all ten bars; right labels grow inward; measured viewport fitting
and conditional clearance for central weapon status. Existing art and native
HUD preferences remain. Static validation and isolated native visual evidence
are recorded in assets/validation_5220. CA213-01 passed author acceptance
on 2026-10-13; PR214 merge and #213 closure are authorized.

Static validation and normal packaging pass. Final native render checks cover
1280x720/960x720 Spanish, 1600x675 English and 1920x1080 fullscreen with copied
user preferences. All 16,052 official runtime members match the tested package;
the user's INI is unchanged. Selected captures/logs and scope: validation_5220.

## Issue #211 - Horizontal landing capacity (5.2.19)

Player and charging bull use 150% of their own landing speed capacity for
eligible horizontal contacts. Validate threshold, zero delta, load/impairment,
immobilization, buckler overlap, exclusions, bilateral contacts, charge
interruption and old/current saves. Falls also use 150% for every biological
body, as subsequently requested. Preserve actual jumps/crushing and
record native evidence in assets/validation_5219. CA211-01 passed author
acceptance on 2026-10-12 without qualifications; its entry was removed from
the author queue. The author authorized PR212 merge and #211 closure.
350 native checks pass; release 5.2.19 and the tested runtime remain unchanged.

## Issue #209 - Modular animation and rest repair (5.2.18)

Implemented the reported pose/attachment, seating/input and table-model fixes,
plus the author's female-hand amendment. Source provenance and native test
fixtures: assets/source/art/appearance_5218 and assets/validation_5218.
CA209-01 and CA209-02 passed author acceptance on 2026-10-12 without
qualifications. The author authorized PR210 merge and #209 closure. Their
confirmed results are recorded in HISTORY and removed from the author queue;
the tested runtime and release 5.2.18 remain unchanged.

## Issue #207 - MAP01 player stays alive at 1 HP (5.2.17)

Implemented the author-requested map-scoped floor before native player death,
plus direct survival/thermal/journey consumers and scripted death fallback.
No persisted protection, global cheat/config change, NPC rule or other-map
mortality change. Evidence: assets/validation_5217/RESULTS.md. Native identity,
damage, save/load and travel checks are separate from author gameplay acceptance.
CA207-01 passed on 2026-10-12 without qualifications. The author requested PR208
merge and #207 closure; no author checks remain. Release 5.2.17 is unchanged.

## Issue #204 - Fullscreen native cursor (5.2.16)

Accepted native-setting workaround: Vulkan with VSync enabled in the author's
existing launcher config. Two fullscreen starts, three menu click routes and
gameplay/menu capture transitions passed CA204-01 on 2026-10-12. Native restart
and configuration preservation evidence: assets/validation_5216/RESULTS.md.
No forced renderer/default, cursor refresh loop, gameplay or save change.
Accepted delivery: PR205. The author requested commit, push, issue closure and
PR merge; no author checks remain. Lower-level engine/driver diagnosis is not
claimed as completed.

The post-merge checkout follow-up refreshes the LANGUAGE index's source hash
from canonical LF bytes. No text, key, location or gameplay change; evidence
is retained in assets/validation_5216/checkout-followup.json.

## Issue #150 - Readability and comfort (5.2.15)

Implemented shared UI/HUD/message scaling, restored native crosshair, native
comfort options and author-approved recent-notice overflow/history. Preserved
identity ownership, native Save/Load, input remaps, combat and #137 feedback.
Accepted delivery: PR203; evidence: assets/validation_5215/RESULTS.md.
CA150-01 passed author visual/comfort acceptance on 2026-10-12 without
qualifications. The author requested merge and closure; no author checks remain.
No engine fork, new effect-intensity default or combat/balance change is part
of this delivery. Native health-color normalization is documented in SYSTEMS.

## Issue #149 - Controls and synchronized hints (5.2.14)

Implemented native command groups, all-normal-binding/unbound hints, approved
explicit reset/first-start preset and binding-aware Journal/time input. Native
slot 2 dispatch retains exact equipment cycling through the existing network
event. Save/config persistence and focused native checks are recorded in
assets/validation_5214/RESULTS.md. CA149-01 passed on 2026-10-12 without qualifications;
physical controller acceptance is conditional on available hardware. No new
controller UI or double-binding hint introspection is claimed. PR202 merged b36ef830; #149 closed. #150 is the current delivery.
PR201/#148 are merged/closed; its accepted tests remain accepted.

## Issue #148 - Native cosmetics and preview (5.2.13)

Implemented modular race/sex/skin/fur appearance, wolf/bear/puma/jaguar forms,
saved cosmetic editing, native preview and equipment-dependent first-person
hands. Author decisions and supported/missing asset matrix are in SYSTEMS/ASSETS.
Scope excludes a full new animation set, wardrobe, respec and new voice bank.
Sources/generators are retained and deterministic. Isolated engine checks cover
creation, editor transactions, old/current saves, restart, travel and gloves.
Evidence: assets/validation_5213/RESULTS.md. CA148-01 passed author acceptance
on 2026-10-12; PR201 merge and #148 closure are authorized.
Author reported an invisible cursor in fullscreen MainMenu, Options and creator,
with working clicks and recovery after Alt+Enter. The isolated repeat began with
a visible cursor; #204 later reproduced the failure and verified the native
VSync workaround above.
PR200/#195 are merged/closed following the prior explicit acceptance.
Author extension: four faces and four hairstyles for each human/goblin/Caelith
sex, six natural hair colors for all three races, all editable in-game. Follow
the requested dedicated SPRITE_ART_DIRECTION.md before further generation;
modular integration is implemented, with revision-2 persistence and native
head/body composition. Agent evidence is in RESULTS; final author tests passed.
The earlier cursor report remains historical evidence, without a runtime fix.

## Issue #195 - Bull balance and resident actions (5.2.12)

Implemented approved speed/acceleration, moving-target charge and personal
biological cushioning without doubled mass. Finite actual resident tools,
War Axe/Sword charged attacks, encounter fire exclusion and eight functional
personalities share player combat rules. Current and previous-save tests are
included in assets/validation_5212. CA195-01 passed author acceptance on
2026-10-11 without qualifications; merge/closure authorized. No further balance values
were invented. PR198/PR199 are merged and #192/#194 closed.
Delivery: PR200, committed and pushed; the author requested its merge and #195 closure.

## Issue #194 - Collision energy and contact area (5.2.11)

Implemented reduced-mass SI energy, bilateral area-weighted defenses, anchored
gate handling, one-time wear/Toughness and cannon armor-bypass removal. Continuous
pressure uses accumulated work; static loads use 0.1 mm/s internal creep and
MAP08's solid-stone ceiling block uses 507600 kg. Decisions are in SYSTEMS and
the issue; validation evidence is assets/validation_5211/RESULTS.md.
CA194-01 passed author acceptance on 2026-10-11 without qualifications; the
author test queue is empty. #195 remains the separate bull-specific rebalance.
PR198 is merged into main. Accepted delivery: PR199, targeting main, with
merge and #194 closure explicitly authorized. No unrelated roadmap work is claimed.

## Issue #192 - Ranged amendment and shotgun naming (5.2.10)

Implemented the approved bow/crossbow penetration table, four-family ideology
exclusion and author-requested removal of active former-weapon names. Native
and static evidence: assets/validation_5210/RESULTS.md. CA192-02 passed author
acceptance on 2026-10-11 without qualifications; the queue is now empty. Commit/push are complete and
#192 is closed again as requested. PR198 merged into main on 2026-10-11.

## Issue #192 - Personality and magical bell (5.2.9)

Implemented four creation layers, author-approved magical POWER semantics,
Normal/Center old-save migration, equipped armor/shield ideology rules and
12 individually mitigated bell projectiles. Native impact preparation and
soldier shields preserve defense order and one-time wear. Evidence:
assets/validation_529/RESULTS.md. CA192-01 and CA188-01 passed author acceptance
on 2026-10-11 without qualifications. PR193 then PR196 merges and #188/#192
closure are explicitly authorized. Confirmed tests are recorded in HISTORY;
the author queue was empty at that acceptance. Next separate roadmap task: #148.

## Issue #188 - Toughness (5.2.8)

Implemented shared post-defense mass subtraction and Type-1 sustained status
resistance. Evidence: assets/validation_528. CA188-01 passed author acceptance
on 2026-10-11 on the combined 5.2.9 build, including #192's native projectile
ordering correction. PR193 merge and #188 closure explicitly authorized;
HISTORY preserves the original evidence scope and the author's confirmation.

## Issue #184 - Mouse interaction (5.2.6)

Implemented native card mouse handling and shared transient pointer controls
for live crafting/time skip. Evidence: assets/validation_526/RESULTS.md.
CA184-01 passed author acceptance on 2026-10-11 without qualifications;
PR190 merge and #184 closure explicitly authorized.

## Issue #189 - Native interactive menus (5.2.7)

Implemented after #184 on a separate stacked branch. All interactive overlays
now use native menu ownership and preserved artwork/actions. Creator/NPC mouse
controls, right-drag rest camera, live simulation and nested native pause are
covered by assets/validation_527/RESULTS.md. CA189-01 and CA184-01 passed author
acceptance on 2026-10-11 without qualifications. PR191 merge after PR190 and
#189 closure explicitly authorized; confirmed tests removed, author queue empty.
#149 controls and #150 accessibility remain separate tasks.

## Issue #183 - Profession onboarding and MAP02 supplies (5.2.4)

Implemented the fixed kits, editable +4/+30 recommendations, resident grants,
finite gold exchange, mandatory bag/Seal/5 L canteen crafts, boxed departure,
one-for-one ammunition replacements and aggregate repair budget. The author
confirmed five manufactured replacement bolas (no reparable wear exists), a
30-to-100-slot Type3 Box formula, leather/rope recipes and fresh saves without
old-save migration. Evidence: assets/validation_524/RESULTS.md. CA183-01 passed
author acceptance on 2026-10-11 without qualifications. PR186 is merged and
#183 closed; the confirmed pending entry has been removed.

## Issue #185 - Indexed NPC dialogue and localization sources (5.2.5)

Implemented after #183/PR186: 19 authoritative NPC/shared sources under
src/dialogues, indexed by index.json; generated runtime retains all 53
conversations/422 pages in the original order. LANGUAGE index covers all 2,369
keys; bounded lookup and build/validation freshness gates are implemented.
Static and bilingual native evidence: assets/validation_525/RESULTS.md.
The author accepted all #185 tests on 2026-10-11 without qualifications and
authorized PR187 merge/#185 closure. CA183-01 also passed; the author queue
is empty. Acceptance changes documentation only; release 5.2.5 is unchanged.

## Issue #180 - Allied Mandinga retaliation (5.2.3)

Implemented native target eligibility and idempotent cleanup of already-saved
allied targets. Existing damage/heat, resources, enemy retaliation and explicit
hostility orders remain. Evidence: assets/validation_523. CA180-01 passed author
acceptance on 2026-10-11 without qualifications; PR182 merge/#180 closure
authorized. CA147-01, CA177-01 and CA178-01 also passed. The author queue is
empty; HISTORY records the confirmations. Next roadmap: #148.

## Issue #178 - Faster multi-day time skipping (5.2.2)

Implemented bounded processing-budget changes and one native crafting-network
scan per stationary live batch. Evidence: assets/validation_522. Existing
simulation rates, real inventory and interruption boundaries remain. CA178-01
passed author acceptance on 2026-10-11 without qualifications. PR181 is merged
and #178 closed; the separate Mandinga correction is accepted under #180.

## Issue #177 - Tutorial equipment, provisions and portable rest (5.2.1)

Implemented the author's follow-ups while preserving #147: autoequip newly
received tutorial weapons; remove recurring Bull arena relocation; correct
Palomo shotgun text and optional necklace ordering; expose progressive finite
materials in the basement chest; provide unlimited mansion food/water with
large canteens and correct forecasting; grant Palomo's sleeping bag once and
retire MAP02 fixed beds with occupied-save deferral.

Native/static evidence: assets/validation_521. CA177-01 passed author acceptance
on 2026-10-11 without qualifications. PR179 is merged and #177 closed.

## Issue #147 - Unified identity and native settings (5.2.0)

Implemented shared saved profile/allocation ownership, revision-1 migration,
session-only creator draft recovery, committed-profile protection and a shared
appearance/voice interface. Preserved creation text, profession combinations,
stat rules and existing appearance/audio. Reconciled native setup selectors.
The author's additional control cleanup moves normal actions to native groups
and keeps debugging in the console; full #149 hint/input work remains pending.
Native/static evidence: assets/validation_520. CA147-01 passed author acceptance
on 2026-10-11 without qualifications. PR176 is merged and #147 closed.
Next: #148 appearance/preview; remaining #149 work stays open.

## Issue #173 - MAP06 interior doors and time skip (5.1.20)

Implemented two hinged pairs per home in existing openings, additive old-save
placement and peaceful-city eligibility for time skip. Native checks cover both
door orientations, street/house use, cancellation, the exact scheduled siege
boundary, normal full deployment and migration of an occupied saved opening.
Evidence: assets/validation_5120. CA173-01 passed author acceptance on 2026-10-10
without qualifications; PR175 merge/#173 closure authorized. No outstanding
author checks remain. Acceptance is recorded under each release in HISTORY.

## Issue #172 - Shared NPC dialogue history (5.1.19)

Implemented informational-reply filtering, persistent per-speaker history and
read-only replay through every NPC menu subclass. Actions/navigation remain
usable, with original native reply mappings and paginated lists. Static/native
UI/save evidence: assets/validation_5119. CA172-01 passed author acceptance on
2026-10-10 without qualifications; PR174 merged and #172 closed.

## Issue #164 - Permanent gifts and assisted Bull checkpoint (5.1.18)

Implemented the Argento/Caella/Ronnie/Rulo permanent gifts and final Palomo Box,
weapon-only mandatory crafting, optional Channel without a new Seal, promotion
of legacy loans, native pre-fight autosave and ordinary death/manual loading.
Preserve the four helpers, existing supplies/recipes, necklace choice and saves.
Native tests cover the route, actual checkpoint files, retries, optional tasks
and migration; passing evidence is in assets/validation_5118. CA164-01 passed
author acceptance on 2026-10-10 without qualifications; PR171 merged/#164 closed.
#162/#163/#169 are closed; PR167/PR168/PR170 merged.

## Issue #169 - Medikit names (5.1.17)

Implemented the author's Spanish botiquín choice and English medikit names for
all three sizes and pickup text. Functional changes are LANGUAGE labels; the
diagnostic release markers follow 5.1.17. Item identities and #135 rules remain. Evidence: assets/validation_5117.
Author accepted #169 and CA162-01/CA163-01 on 2026-10-10; all three merged/closed.

## Issue #163 - Recoverable bolas (5.1.16)

Implementation and focused native validation are recorded in
assets/validation_5116/RESULTS.md: crafting, preparation/throw/recovery, restraint,
fire/cut/Strength resolutions, demon costs, save migration and hub lifecycle.
Approved author decisions: bronze 800 g plus leather 218 g at M; javelin
ballistics, 60-to-6-degree linear preparation and 6 base Air; two-second base
cut with shared physical speed and pain/sleep/stun interruption. The author
requested a hanging ready pose, 3 Hz spin and rear rope arcs hidden by the body;
these corrections and bound-save visual migration are implemented. Extended
forearms and a finite flame for immediate paid demon escape address later feedback.
CA163-01 passed author acceptance on 2026-10-10, with merge/closure authorized.
The dependent #164 permanent gifts and assisted checkpoint are now accepted.

## Issue #162 - Bronze utility staff (5.1.15)

Implemented family 1, one tier, original art, exact Pickaxe components and
maximum durability, fire/ice streams, once-per-second contact wear and wand
terminology. Recipe revision 6 preserves old knowledge and equipment identity.
Static/native evidence and reproducible fixtures: assets/validation_5115.
The right-leaning pose and CA162-01 passed author acceptance on 2026-10-10.
PR167 merged/#162 closed. Caella's permanent grant and full tutorial are accepted
separately under CA164-01 above.

## Issue #165 - Damage flash across map travel (5.1.14)

Implemented bounded, shared flash evaluation; future/expired timestamps never
revive a hit. Native travel clears its map-local flash; existing visual revision
2 repairs legacy saves idempotently. Preserved Health, inventory, position, damage
colors/intensity/fade and paid Tarot state. Native screenshots and 34 checks pass,
including actual airborne MAP01/MAP02 crossing and ground MAP03/MAP02 return.
CA165-01 accepted 2026-10-10 without reported qualifications; #165 closure and
PR166 merge requested. The author queue is empty. #158 and #160 were accepted and
closed during this task; PR159/PR161 are merged and their IDs remain in HISTORY.

## Issue #160 - Argento silver-key handoff (5.1.13)

Implemented the authorized release/check/transfer transaction, including rollback
to Argento when capacity rejects the pickup. Keep generic ownership guards, quest
requirements, the single existing key and native silver-lock behavior. The author
checkpoint reproduces the old rejection; 20 native checks pass after correction.
The author accepted CA160-01 and CA158-01 on 2026-10-10 and requested closure
and merge: #158/PR159 first, then #160/PR161. HISTORY records both confirmations.

## Issue #158 - Preserve crafting equipment size (5.1.12)

Implemented: browsing Seals, amulets and ammunition no longer replaces the
remembered equipment size with M. Fixed-size task completion preserves a later
size choice, including legacy task snapshots. Sized tasks still restore their
own size; fixed-size output/display metadata stays canonical. The author save
needs XS selected once, not extra materials. Native before/after checks, actual
staff/shield transactions using original stock, and task/completed save reloads
passed. CA158-01 accepted 2026-10-10; PR159 merge and #158 closure authorized.
No quota top-up or forced selection based on race was introduced.

## Issue #156 - Time-skip letter controls (5.1.11)

Implemented the native KeyChar path for Q/R while retaining scan-code controls,
key release propagation and authoritative network actions. The author's save
contains a finished task and past destination, explaining the valid Enter warning.
Native dispatch/state checks and save/reload passed. The author's baseline Tab
check confirms the panel can receive real input; synthetic Windows presses were
not delivered reliably and are not counted as validation. The author accepted
CA156-01 on 2026-10-10 without reported qualifications and requested PR157 merge
and #156 closure after #154 / PR155. The author queue is empty.

## Issue #154 — SI physics and growth (5.1.10)

Implemented: shared Type 1/2/3 consumers, SI gravity, calibrated movement,
energy-based jumps, fall-threshold conversion, physical projectile gravity and
launch-time ballistic aiming, attribute-dependent muscular efficiency, explicit
save migration. Existing acceleration, combat equations and fixed work data remain.

Native evidence covers numeric consumers, actual input/movement/jumps, real
projectile collisions, falls/traps, map traversal and protected-save migration.
Static/final-build results and limitations are recorded in validation_5110.
CA154-01 and CA154-02 accepted by the author on 2026-10-10 without reported
qualifications; #154 closure and PR155 merge requested. HISTORY retains the IDs.
No mass-siege benchmark or unapproved force/power acceleration redesign is included.

## Issue #152 - Shotgun follow-up (5.1.9)

Fix the reproduced owned-but-visible ammunition stack, correct right-hand/stock
occlusion and make ranged alternate aim act once per press. Native pickup checks
cover capacity failure/retry and independent carbine/shotgun counts. Existing-save
upgrade and ranged input tests have separate evidence in validation_519.
The author accepted CA152-01 (pickup/6 cm size) and CA152-03 (held aim) on
2026-10-09. CA152-02 failed because the left hand was duplicated and its costume
differed from the other weapons. The revised atlas and single under-gun hand pair
have native pose/save evidence. The author subsequently accepted revised hands
(CA152-02, origin 5.1.9/#152) without qualifications on 2026-10-09 and requested
PR #153 merge and #152 closure. All checks are accepted; pending_test.txt is empty.

Thermal follow-up is deferred while the author decides: stair/jump work references,
metabolic power including zero-net-work effort, and beastfolk fur water/insulation.
Diagnosis confirms sweat is active inside the Normal range and the supplied
save's exposure is -0.482, not a captured hot state. No thermal runtime edits.

## Issue #137 - Elemental VFX and screen feedback (5.1.8)

Implemented scope: original animated family materials, shared player/NPC light,
trails and impacts, attached statuses, directional demon breath, original 3D
physical projectiles including javelins, and the Federal prisoner's staff ray.
Author-approved additions: proportional colored damage feedback, peripheral
Health warnings and stronger Lucidity visuals. The later reported Domingo/rat
death cuts now use recovered original poses; older assets/timing are retained.
No gameplay/balance changes.
Native evidence and qualifications are maintained in assets/validation_518/RESULTS.md;
static/build gates accompany delivery. The author accepted CA137-01/02/03 on
2026-10-09 and requested PR #151 merge and #137 closure. Results are recorded in
HISTORY; pending_test.txt is empty.

Author follow-up: audit every rat/bull sprite and repair defective cuts. All 48
rat and 118 bull images were inspected. Nine rat movement/pain border cuts were
restored alongside the original deaths. Bull cuts are intact. Visible source
labels/neighbor RGB outside some rats have alpha zero and do not render; they
were a misleading preview, not an outstanding gameplay rendering defect.

## Issue #136 - Shortbow shotgun and armor bypass (5.1.7)

Implemented contract: two barrels/cartridges, twelve D/10 pellets, half range,
Maximum spread, carbine-equivalent costs/time/recipe/mass/condition/critical,
independent ammo and eligible MAP02/armory supplies. Equipped-only penetration
shares the player/NPC path; revision-1 migration preserves ownership and condition.
First-person hands and weapons are independent reusable layers, with original
world/icon/pickup art. Focused mechanics, actual inputs/deaths, migration/save/hub
and checkpoint rollback have native evidence in assets/validation_517.
Author inspection also requests smaller/muted hands and carbine-style aiming.
The reported calor-136 save exposes the old lingering activity-heat peak. The
author's final rule is heat only during the action, superseding the proposed
finite recovery filter. Revision 7 preserves accumulated exposure and resources.
Focused reproduction, action timing and save checks: FOLLOWUP_RESULTS.
The high-stat follow-up also replaces jump-amplified swimming/pushing with the
approved 6/10 MET swimming and 6 MET pushing profiles; actual Air is unchanged.
The final contract replaces the remaining jump/Air proxies with fixed work:
human 0.5 m jump at 9.81 m/s2, approved weapon/NPC tables, per-cycle firearms and
per-distance locomotion, with heat = 3 * work. Swimming uses 75% of its approved
net metabolic reference as heat; pushing/blocking remain isometric profiles.
Revision 8 preserves completed energy and tracks reload progress. Resilience
adaptation uses base plus Type 2; thermal Toughness thresholds already did so.
Final tests and qualifications: assets/validation_517/ENERGY_RESULTS.md.

Accepted on 2026-10-08: CA136-01 appearance/gameplay, CA136-02 thermal follow-up
and carried CA143-01 all passed without reported qualifications. Issue #136
closure and PR #146 integration are authorized; the author queue was empty at that acceptance.
A future hand appearance selector may reuse these layers; no new balance is implied.

## Issue #143 - Crouched aimed soldiers (5.1.6)

Implemented: native half-height posture/clearance; lowered shared muzzle;
existing crouch and aim modifiers; interrupt/target/movement transitions;
revision-2 carbine migration; invariant thermal body height; original 32-frame
Domingo atlas and deterministic registration. Player stationary crouch uses
it without double compression; walking remains the existing animation.

Focused engine checks, ordinary soldier AI, player input, save/reload/hub and
old-save migration/checkpoint rollback are recorded in validation_516. No mass
siege retest is required for this patch. The author explicitly requests commit,
push, and merge/closure if implementation and verification are complete.
PR #145 is merged; CA143-01 was separately confirmed passed on 2026-10-08.
Next: retain the accepted city deployment and high-density AI policy; any new
movement or combat balance requires its own authored issue.

## Issue #135 - Demon breath and potions (5.1.5)

Implemented: native 6/6/6 supplies; nine typed ten-second doses; automatic strict
below-50% consumption with per-family waiting; approved prices, weight and
silver/gold sprite distinctions; predefined priority and weighted single-unit
loot; cold/combat breath with real-time spending, contact burn and thermal heat.
All design questions were resolved by the author. Native evidence includes
normal-AI cold warming, concurrent regeneration, obstruction, interruptions,
scripted retreat, current save/hub and original-save migration/rollback.

Finite exhaustion, dedicated exhalation loops, corrected Zupay action rotations
and bounded incremental-cost checks pass. Final source-bound results and
static/package gates are recorded in validation_515. No mass siege retest is
requested. The reported shutdown crash has a targeted teardown fix;
only runs with explicit clean exit codes count as final clean-exit proof.
Author confirmation, 2026-10-08: CA135-01/02 passed; PR #144 merge and #135
closure authorized. No #135 author checks remain pending.
PR #144 merged as 5e550484 and #135 closed on 2026-10-08. The separate #143
implementation and delivery are recorded above.

#140 is closed; PR #142 merged 5f9202ad. CA133-01/02/03 were accepted on 2026-10-08.

## Issue #133 - City interiors and deployment (5.1.3, closure and merge authorized)

Implemented: revision-3 interiors and factory networks; 160 furnished homes,
64 independent T1 shops, the 600 housed soldiers and authoritative siege date;
native carbine combat and 48 shared world sprite frames; exact revision-2
geometry backup/build selector. Commerce, furniture and recipe probes pass.
The fresh routing control reaches all 600 posts, including crew stairs and return
from temporary access yields. Compatibility/save/hub controls and combined
performance are recorded with their exact scope in validation_513/RESULTS.md.
On 2026-10-08 the author authorizes issue closure and PR #141 merge, assigning
the remaining thermal work to #140. Later that day the author explicitly
confirmed CA133-01/02/03 passed. HISTORY records the original version and
current thermal-rule qualifications; no #133 author checks remain pending.
The author sets the shop/pricing and calendar decisions recorded in SYSTEMS.

Follow-up design finding from #133: the unchanged #130 action-heat profile makes
the 600-body continuous-fire control stop at 14 shots and one reload per soldier;
all then die from thermal damage by tic 1400. HEAT_LIMIT.json confirms the native
state and cause. The author subsequently approved surface-scaled sweating and
actual water loss, retaining carbine heat rather than exempting firearms.
The first new native control retains 600 living soldiers at tic 3500 but exposes
post-exertion cold from wet clothing. Do not equate added cooling with accepted
sustained-fire balance. The sweat extension passes native math/provisions,
persistence/migration and carbine checks; final combined simulation/render rates
are 31.21/5.57, with 598 surviving defenders and a different workload from the
pre-sweat control. The previous half-Health proposal was clarified and superseded
in #140: quarter-Health full-bar Hunger/Thirst costs, player only. Agent validation
is distinct from CA133-01/02/03 acceptance.

## Issue #140 - Thermal cache and physiology (5.1.4, implemented)

Implemented: disposable per-actor coefficient/anatomy caches, revision-6 migration,
quarter-Health player Air/Anima costs, bull/rat sweat, max-selected heat/fatigue
ventilation, signed respiratory transfer and supplied male/female audio.
Author follow-up adds dagger-scale carbine Air, separate 2/2.5-MET fire/reload
heat and 1-to-5-MET cold shivering with proportional player Hunger cost.
CA140-01/02 were accepted before these follow-ups; newer controls remain separate.
Native comparison exposed lethal post-exertion/immersion wet-clothing cold
without shivering. The approved regulation passes clean temperate pool, magic, heavy-weapon pacing,
firearm and drying controls. Five armor categories are covered by native cases;
87 mechanic, 39 effort/magic and 30 geometry/immersion/drying assertions pass.
Author integration/closure is authorized after these stable focused controls.
Mass performance tests remain explicitly deferred. No full-scene throughput
improvement is asserted. Movement shedding has no approved new coefficients;
keep absorbed clothing water separate from any future free-droplet model.

## Issue #132 - Staged siege performance test (5.1.2)

Implemented: 100/350-tic cadence, 2,000-living cap and 6,000 successful-spawn
total; existing full armies retained. 22 native lifecycle checks and 52 native
save comparisons pass. Natural arrival/cap controls and complete-budget diagnostic
captures are recorded in [validation_512](../assets/validation_512/RESULTS.md).
Staging improves arrival but does not establish stable 35 tics/s plus 30 displayed
FPS everywhere. The author accepted CA132-01 on 2026-10-07 and authorized
issue closure and PR #139 merge. No #132 author checks remain pending.
Combined geometry/defender measurements follow #133, with thermal survival
and demon self-warming effects kept explicit when #135 changes the workload.

## Issue #131 - Thermal HUD and attribute adaptation (5.1.1)

Implemented and agent-verified: exposure bar above Load, bilingual read-only presentation,
Constitution Sleep loss and gradual adaptation-limit return. #136 subsequently
changes the original Type-4 Resilience adaptation to base plus Type 2.
Long travel blends endpoint climate by distance at the current journey time;
walking sleep pauses distance and ships continue. Retain forecast rejection,
vehicle shelter and no invented real-time damage.

47 native assertions, viewed-pawn ownership, save/hub/rollback, aspect/scale
and bilingual checks pass; evidence belongs to validation_511. On 2026-10-07
the author accepted CA131-01/02, including the final diagonal icon, and authorized
PR #138 merge and #131 closure. No author checks remain. Future region assignments must remain consistent
between the destination catalogue and authored map markers.

## Issue #130 — Thermal survival (5.1.0)

Implemented in [PR #134](https://github.com/damiancurti/Caelum-Argenteum/pull/134).
The author confirmed CA130-01/02/03 passed on 2026-10-07 and authorized merge
and issue closure. Native verification remains separately recorded in
[5.1.0 evidence](../assets/validation_510/RESULTS.json).

- Authoritative per-character exposure, moisture, acclimatization and damage
  fractions; effective Toughness thresholds and heat/cold consequences.
- Actual regional equipment coverage, rain/evaporation/immersion, explicit
  water temperatures, shelter, optional rated fires and native magic energy.
- Sourced locomotion/jump heat and author-approved action profiles; separate
  world/real time and safe time-advance/journey integration.
- Revision-1 migration, preserved inventory/quests, save/reload/hub evidence,
  reversible 5.0.6 bridge and bilingual status.
- Full-army cost measured with normal AI; no population or offscreen exemption.

No author checks remain for #130; HISTORY records all three accepted IDs.
Follow-up refinements: actual hot/cold consumable metadata, ratings for authored
decorative fires, species-specific moisture, complex support/room geometry,
late-battle frame cost and broader multiplayer remain separate scoped work.
Do not invent missing follow-up data. #131 has its own implementation and
acceptance entry above; #130 acceptance does not accept that later patch.

## Issue #128 — Automatic normal high-density AI (5.0.6)

- Implemented and agent-verified. Final source passes 38 functional checks,
  96 target/native-RNG comparisons, full guard/cannon oracles, cold load,
  hub travel and old-save upgrade/reload/rollback. Source/package verification
  retains all native combat/physics/resources and maps. The author confirmed
  CA128-01 passed on 2026-10-07 and authorized PR #129 merge / #128 closure.
  No author checks remain pending for this delivery.
- Selected: on-demand leader decisions/candidates, spatial guards including
  same-tic NOBLOCKMAP registration, negative cannon retry and safe sight
  pruning. Rejected: background staggering, whose congestion tail is worse.
- Final late throughput is 26.639–27.035 tics/s versus baseline 3.266, with
  only 1.575–1.601 frame callbacks/s. The 35-tic/30-FPS reference is unmet.
  Direct #121-combination controls show a modest additional common-window
  gain: 1.58–1.74% simulation, 9.20–10.29% callbacks, shorter p95 gaps.
- Retain the following scope/acceptance contract and reproducible evidence.
- Implement the author's map-wide 500-living-combatant threshold and explicit
  leader-target policy. Retain individual movement, attacks, collision,
  resource/status updates and the full army.
- Promote spatial guards with NOBLOCKMAP coverage and bounded negative cannon
  retries. Evaluate shared candidates and staggered group perception separately
  and combined. Do not ship diagnostic march/reduced-actor shortcuts.
- Validate 499/500/501, offscreen counting, death/removal/revival, mode exits,
  target/leader loss, occlusion, remembered guards, neutralization, save/load,
  old-save upgrade/rollback and map travel with real GZDoom 4.14.2.
- Measure baseline and repeated normal-combat variants through early,
  congested and late windows; retain callback tails and native thinker/render
  evidence. Record positive results and limits in KNOWN_PITFALLS.
- Keep background simulation active, audio at 5%, and the machine awake with
  a bounded request. Release it and verify the original power plan afterward.
- Update consolidated docs, validate, commit, push and deliver a linked PR.
  Author acceptance is complete; merge and closure are authorized for #128.

## Issue #121 — Siege subsystem diagnosis and combined experiments (5.0.5)

- Accepted on 2026-10-07: the author considers the demonstrated fluency close
  enough for this stage and authorizes #121 closure / PR #127 merge. Further
  fluency tests are future work; experimental AI remains outside production.
- Implementation and agent validation complete: 21 comparison runs plus two
  GPU/visual controls and the final production/background smoke check. Exact
  source/package checks and two-pass reconstruction of 15 diagnostic packages
  pass. The temporary keep-awake request is released with no power-plan change.
- Positive findings: shared perception, exact spatial guard broad phase, and
  failed-query retry within the changed formation workload. The combined march
  reaches nominal simulation rate but averages only 20–23 frame callbacks/s;
  normal combat still slows to 24–25 tics/s late. The 35-tic/30-FPS target is
  **not met**. KNOWN_PITFALLS CA-KP-041–045 preserve tested results and boundaries.
- Record the accepted 5.0.4 full-army baseline, representative approach,
  congestion and late battle, exact source/package identity, native settings,
  camera, hardware, populations and independent timing domains.
- Rank target enumeration/sight, movement/contact work, per-actor updates,
  group/controller scans, artillery/projectiles, player and rendering costs.
  Use nested 37-tic samples plus every-call sparse-event probes; preserve
  native thinker, CPU renderer and separate GPU-range evidence.
- Validate observer overhead in reversed-order, scene-identical pairs;
  distinguish scope-time percentages from whole-process/wall/GPU cost.
- Test the author's aligned groups of 100 against independent march, then
  normal shared perception, spatial guards, cannon retries and combinations.
  Disclose altered movement/awareness/acquisition and interactions. The original
  35-tic/30-FPS target remains a measurement reference, not a fulfilled metric
  or a blocker to the author's accepted closure of this diagnostic stage.
- Keep production behavior/save fields unchanged. Evidence lives in
  `assets/validation_505`; measured interpretation is in PROJECT and confirmed
  reusable findings in KNOWN_PITFALLS. #121 author acceptance is recorded in HISTORY.
- Next focused optimization candidates: preserve member-specific target/LOS
  semantics while reducing repeated perception; exact spatial guard queries;
  explicit cannon acquisition retry policy; renderer submission cost. Design
  cohesive formations separately from per-body collision and individual combat.
  Historical #86 remains closed; #121 does not authorize a silent population cut.

## Issue #120 — Per-player authority and integrated closure (5.0.4)

- Implemented a stateless current-pawn/prediction/record authority helper, 203
  explicit operation guards and bounds-checked Journal/Trucazo/Truco event
  routing. Native fields, schemas, inputs and compatible adapters are retained.
- Source verification checks exact guards, remaining bodies/signatures/fields
  and the final package boundary. Evidence: `assets/validation_504/RESULTS.json`.
  Native tests cover player resources, inventory/crafting, Tarot, save/upgrade/
  repeat-load/original rollback and the MAP01/MAP02/MAP06/hub path.
- Passed per package: 249 player, 127 inventory, 93 Tarot, 79 transaction and
  65 pickup assertions. Old/current/upgraded/original-rollback saves pass, as
  does the 5.0.0 save path. Native creation passes in both languages; actual
  keyboard/window checks confirm Journal selection and both restored matches.
- Two native participants (human plus bot) pass 36 isolation checks, including
  foreign records/previews, prediction rejection and actual drop/pickup with an
  ID collision. This is not a multi-client transport or lifecycle validation.
- The original Architecture 1 baseline is compared with the integrated build;
  simulation throughput, overlay intervals and synthetic UI/play/UI event timing
  remain separate measurements. Earlier #117/#118 regressions remain evidence.
- Complete matched pairs measure +4.09% and -8.72% simulation throughput versus
  4.37.24, with 49 identical scene rows each. One incomplete run is excluded and
  retained diagnostically. Desktop/GPU load and focus are uncontrolled; no stable
  gain or whole-scene cause is established. HISTORY records separate timing types.
- The author confirmed CA-503-TAROT-01 and CA-504-AUTHORITY-01 passed on
  2026-10-06 and authorized #119/#120 closure and PR #125/#126 merge.
  Compatibility adapters remain; measured performance limitations are unchanged.
- Follow-up boundaries: shared clock/progress/reward/session policy and native
  multi-client lifecycle tests; separate crafting/session and combat/narrative
  coordination issues; thermal exposure, native UI and campaign expansion.
  Measured mass-AI costs require a focused performance issue without changing
  accepted army counts or rules. Historical #86 stays closed.
- Measured performance candidate: native thinker profiles charge the dominant
  actor work to 6,000 `CaelumMandinga` instances. A focused follow-up should
  instrument resource recovery, `CaelumPortSiege.Pulse/AttackerTarget`, sight
  queries and native chase separately before selecting an optimization. The
  siege controller's own Tick sample excludes work called through actors;
  class-level timing alone cannot identify which internal operation dominates.

## Issue #119 — Tarot consolidation (5.0.3)

- Implemented one stateless service for collection, bonuses, powers, capture
  checks and Journal projection; 24 compatible method adapters and all saved
  fields remain. Physical inventory and separate match state retain ownership.
- Corrected the pre-existing loss of native flight across non-hub travel while
  preserving paid selection, remaining timers and resources. SYSTEMS documents
  the explicit behavioral correction and original-pair rollback.
- Evidence: `assets/validation_503/RESULTS.json`; before/after native contracts,
  old/new saves, hub return, match/UI checks and bounded MAP06 comparison.
- Passed: 93 route/capture/power assertions per package; 936 identical fixed-bonus
  rows; 223 identical initial record fields and both initial match payloads.
  Old/new/upgraded reload, original rollback and native menu key actions pass.
  MAP06: 12.997/13.091 tics/s (+0.72%), 49 scene-identical rows; no meaningful
  speedup is inferred from this single pair.
- Author check CA-503-TAROT-01 passed on 2026-10-06; merge/closure authorized.
  The separate #120 delivery is also accepted. Earlier performance regressions
  remain evidence; #121 profiles contributors. No new multiplayer support is claimed.

## Issue #118 — Inventory/equipment consolidation (5.0.2)

- Baseline: #117 accepted, PR #123 merged, issue closed on 2026-10-06.
- Implemented 157 pawn and three physical Box/deck operations in stateless
  `CaelumInventoryService`, retaining native ownership, fields and adapters.
  Shared operations cover identity, equipment, capacity, storage, projections,
  reservations and inventory commits; SYSTEMS records preconditions and remaining
  recipe/session/quest/native-I/O boundaries. No save schema or balance changes.
- Evidence: `assets/validation_502/RESULTS.json`, adjacent source-equivalence
  manifest, native contracts, save/reload/travel/rollback and before/after timing.
  Foreign-reference guards are explicit; ordinary valid-owner behavior is compared
  against 5.0.1. Agent fixtures and author acceptance remain separate.
- Native inventory/hub checks: 127 per package; nine crafting categories and
  merchant buy/sell: 79 per package; stack pickup/capacity: 65 per package.
  Original-save upgrade/travel: 50; fresh/upgraded/original rollback: ten each.
  Seven extra ownership checks pass; all 592 pawn fields and 23 native-item
  payloads match. Bilingual inventory captures were inspected.
- #118 MAP06 regression versus 5.0.1: 12.632/12.160 tics/s (-3.74%);
  reversed-order 12.967/12.170 (-6.15%), with 49 identical scene observations.
  Mean native player samples: 0.0417/0.0445 ms and 0.0441/0.0487 ms.
  Attribution remains unresolved; carry both #117/#118 evidence into #120.
- Author confirmed CA-502-INVENTORY-01 and all #118 tests passed on 2026-10-06;
  PR #124 merge and issue closure authorized. Continue with #119 Tarot. #120
  retains the unresolved performance measurements from #117/#118.

## Issue #117 — Compatible player domain adapters (5.0.1)

- Author confirmed all tests and CA-501-PLAYER-01 passed on 2026-10-06;
  PR #123 merge and issue closure authorized. Performance evidence stays open
  for attribution in #120; continue inventory consolidation in #118.

- Baseline: accepted #116, PR #122 merged and issue closed on 2026-10-06.
- Implemented ten character and 29 resource operations in stateless services,
  preserving all pawn fields, signatures, other method bodies and native order.
  PROJECT reconciles the audit sequence with #117/#118/#119 scope; SYSTEMS
  documents preconditions, owner/copy direction and original-save rollback.
- Static equivalence covers moved bodies including literals, unchanged methods,
  declarations and package contents. Native before/after fixtures exercise 64
  race/class combinations, draft consume/reject, resource thresholds, personal
  time, air debt, consumables, selectors and MAP03/MAP02/MAP06 hub travel.
- Evidence, current/previous package identities, save-load/rollback and matched
  MAP06 measurements: `assets/validation_501/RESULTS.json`. No performance gain
  or author acceptance is inferred from source organization or agent checks.
- Observed performance regression: MAP06 base/current 12.546/11.794 tics/s;
  reversed-order repeat 12.633/12.017 (-4.88% to -5.99%). Player samples average
  0.0381/0.0489 ms per tic. Whole-scene attribution remains unresolved; carry the
  measurements into #120's integrated comparison, without changing army/game rules.
- Inventory/Box/crafting transaction extraction belongs to #118; Tarot to #119.
  Native input/UI overhaul, thermal exposure and broader gameplay remain separate.

## Issue #116 — Architecture audit and first extraction (5.0.0)

- Author expanded the audit-only issue on 2026-10-06 to begin refactoring and
  waived compatibility with older saves for this work. Existing field identities
  are nevertheless retained; no old-save acceptance is claimed.
- PROJECT contains the concrete dependency/responsibility map and ordered A1–A8
  plan. SYSTEMS contains authoritative owners, lifecycle/input/selector contracts
  and rollback boundaries. No future patch numbers are assigned.
- A1 extracts three HUD/Journal projection routines into the stateless
  `CaelumPlayerPresentation`, retaining pawn adapters and fields. Later inventory,
  crafting, combat, quest and siege extractions remain separate focused issues.
- Evidence and reproducible tooling: `assets/validation_500/RESULTS.json` and the
  adjacent source inventory, native checks and MAP06 measurements. Static checks,
  native observations and author acceptance remain separate.
- Completed: static validator/build; identical pawn declarations/signatures and
  moved-body checks; 35 native projection checks on original and final runtimes;
  current save/reload; bilingual Journal/Tarot captures; current MAP06 baseline,
  three native thinker profiles and three diagnostic UI/play/UI round trips.
- #86 remains closed; the #77 performance evidence is historical. Current native
  measurements do not demonstrate a speedup or justify changing accepted AI rules.
- Author acceptance passed on 2026-10-06: all tests confirmed correct, with
  PR #122 merge and #116 closure authorized. Continue with #117.

## Issue #82 — V4.37 closing delivery (4.37.24)

- Scope reconciled against closed dependencies #74, #75, #77, #78, #79, #80 and
  #81 and their recorded author acceptance. Earlier accepted work and subsequent
  accepted refinements remain integrated. V5 expansion is not a V4.37 blocker.
- New export from committed source with accurate three-map route, manifest,
  hashes, license notices and portable launcher. Historical #17 ZIP preserved.
- First-start controls: Tab Journal, M automap, B Seal, R Reload, F Zoom, T Tarot.
  Keep later user remapping; no migration or reset of existing configurations.
- Final integrated campaign/state, Tarot, NPC Trucazo and export checks are
  recorded in assets/validation_43724. Native fixtures seed prerequisites where
  stated; they do not replace the already recorded ordinary-play acceptance.
- Export from bf12c897 is independently verified and byte-identically reproduced.
  CA-43724-EXPORT-01 passed by explicit author confirmation on 2026-10-05.
- The author approved the delivery, PR #115 merge and #82 closure. No author
  check remains pending. HISTORY retains the result and diagnostic limits.
  V4.37 closes at 4.37.24; next development scope is V5.0.

## Issue #112 - Contextual character creation (4.37.23)

- Native two-column descriptions before confirmation, both languages, all
  playable races/classes, ten professions, four families and twelve attributes.
- Exact requested Spanish headings; all sixteen class combinations and the
  summary reuse the actual profile mapping. Backtracking refreshes immediately.
- Author-authorized fix: replace the creator's incorrect duplicated Human/
  Priest Social-Mental contribution with the actual profile distribution.
- No invented penalties or unfinished powers presented as available. Existing
  allocation budgets/caps/refunds, input handlers, draft persistence and #103
  introduction remain authoritative. No new saved fields.
- Evidence: assets/validation_43723/RESULTS.json. Commit/push, focused linked PR,
  merge and closure authorized by the author after implementation/verification.
- Implementation and native verification complete: 1,224 matrix assertions and
  twelve interactive checks passed, including confirmation, introduction,
  ordinary MAP01 startup and author-assisted save/reload. Fifty native captures
  cover both languages and 4:3, 16:9 and 21:9. No outstanding author check.

## Historical release-status reconciliation before #82 — 2026-10-05

- **Task CA-DOC-RELEASE-STATUS:** correct stale planning labels at the author's
  request. This is an acceptance/status correction, not a new gameplay patch.
- **4.36 is closed.** The author explicitly reconfirmed closure on 2026-10-05.
  The accepted siege (#16 / 4.36.27) and test export (#17 / 4.36.28) remain
  complete; historical planning text below must not reopen their release gates.
- **4.37 remains open, nearing closure.** The author reports only final details
  remain. Preserve outstanding issue scope; this correction does not declare
  final release acceptance or invent additional requirements.
- `pending_test.txt` is empty at this reconciliation. It tracks outstanding
  author checks, not all development work; an empty queue does not close 4.37.
- V5 remains future work under `PROJECT.md`, including CA-V5-NATIVE-UI.
  Deferred environmental features are not reopened 4.36 blockers.
- Earlier issue entries preserve their original scope, evidence and sequence.
  Read historical "Next" statements in that context, not as today's work order.

## Issue #106 - First-person shield sets (4.37.22)

- Shared equipped-item artwork for kite, tower and magic; preserve the round
  shield and accepted left-hand framing. All tiers/sizes use the real item type.
- Original source sheets, native registration generator, palette and provenance
  retained in assets/first_person_shields. The author accepted design/positions
  and requested muted colors; the existing greatsword palette is applied.
- Native accessory layers cover physical/magical selectors and compatible
  unarmed equipment, with real block/return and stale-overlay cleanup.
- Author scope extension, 2026-10-05: dedicated T1-T3 giant-gauntlet boxer
  guard; existing idle/attack art and block rules retained. Follow-up revises
  thin guards and replaces the three-hand inventory silhouette with two gloves.
- Static/native matrix, aspect ratios and persistence evidence are recorded in
  assets/validation_43722/RESULTS.json. Gameplay data and save schema stay intact.
- CA-43722-SHIELD-ART-01 passed by explicit author confirmation on 2026-10-05
  (sprites, positions and final palette). CA-43722-SHIELD-PLAY-01
  also passed by explicit author confirmation on 2026-10-05. Merge/closure
  authorized after commit/push and linked PR #113.

The author accepted the revised gauntlet guard and two-glove icons on 2026-10-05
(CA-43722-GAUNTLET-ART-01). Manual gameplay confirmation also passed on 2026-10-05.

## Issue #103 - Narrative artwork and introductory page (4.37.21)

- Exact approved sources, supplied title-bearing README banner and provenance
  are committed separately from runtime changes (883ad8f2).
- One Unicode typewriter page after new character creation, current bindings,
  existing survival guidance, exact requested Spanish quotations and English
  localization. First press reveals all, next begins; CA_MUS01 then MAP01/CA_MUS02.
- Shared fitted image for intro and native quit/farewell; original confirmation,
  cancellation and shutdown audio retained, inherited text ENDOOM suppressed.
- No persistent field/map/progression/port-completion changes. Native direct quit
  and quick exit remain bypasses. Test sound: all enabled, master 15%, isolated INI.
- Static/native evidence: assets/validation_43721. The author accepted
  CA-43721-INTRO-01, CA-43721-EXIT-01 and CA-43721-SAVE-01 on 2026-10-04
  without reported qualifications; issue #103 closure and PR #111 merge authorized.
- Implementation and author acceptance are complete. No #103 checks remain
  outstanding; HISTORY records the results. Runtime and release stay unchanged.

## Issue #98 - Textured training dummy model (4.37.20)

- Recreated the existing articulated mannequin and six targets as original
  textured volume, retaining editable sources and project provenance.
- Bound both existing actor classes and all visible frames; kept the accepted
  collision, location, health, practice logic and save schema.
- Evidence: assets/validation_43720 (determinism, native views, real impacts,
  old active/completed saves and new reload). The author accepted
  CA-43720-DUMMY-ART-01, CA-43720-DUMMY-PRACTICE-01 and CA-43720-DUMMY-SAVE-01
  on 2026-10-04 without reported qualifications; issue #98 is closed and
  PR #110 merged as 2ec2405c.
- #96 accepted and closed; PR #109 merged 76757fd7 on 2026-10-04.

## Issue #96 - Palomo necklace and shield names (4.37.19)

- Implemented the author's four-choice T1 gift with Palomo and same-recipe
  teaching by Caella. No automatic accessory replacement or new balance.
- Native capacity, actual item identity, no duplicate on repeat/reload, owned
  T1 recognition and deferred active crafting use grant revision 1.
- Kept the four original crafting choices, accepted trials and saved dialogue
  indices; old Caella pages teach/refer without changing a selection.
- All four shields use canonical inventory names in both languages, including
  previews, confirmation and summary; item mapping and statistics are retained.
- Evidence: assets/validation_43719. The author accepted CA-43719-NECKLACE-01,
  CA-43719-SHIELDS-01 and CA-43719-SAVE-01 on 2026-10-04 without reported
  qualifications, and authorized #96 closure and PR #109 merge.

## Issue #91 - Crafting sections and Tarot fields (4.37.18)

- Implemented Craft/Repair/Dismantle icons and lists: known recipes only,
  real owned weapon IDs, wear/variants, actionable blocking reasons and live
  refresh. Confirmation revalidates exact ownership and requirements.
- Pickaxe repair recognizes its learned recipe. Existing costs/recovery,
  durations, station rules, protections and reservations are preserved.
- Tarot labels passive, active and Trucazo effects; shared fixed-bonus data,
  honest unknown/unimplemented states, scrolling and unchanged selection/timers.
- Reused game art/fonts and native C moon cursor; keyboard, mouse and existing
  controller bindings share the Journal dispatcher. Browser state is transient.
- Static/native and save compatibility evidence: assets/validation_43718.
  Author acceptance on 2026-10-04: CA-43718-CRAFT-01, CA-43718-TAROT-01 and
  CA-43718-UI-01 PASSED; issue closure and PR #108 merge requested.

## Issue #89 - Pickaxe and gathering feedback (4.37.17)

- Implemented one T1 owned utility tool, family 1; approved slash/pierce attacks,
  shared axe data/recipe, ×10 chopping and ×100 mining within existing limits.
- Ronnie grants it once with recipe knowledge; the chosen weapon still needs
  crafting. Additive migration preserves old swords, progress and recipe IDs.
- Integrated supplied reference art and CC0 sounds with preserved provenance.
  Every successful extracting weapon emits one sound and centered CaelumText
  notice; invalid/exhausted hits do not.
- Static/native evidence: assets/validation_43717. All three author checks
  passed on 2026-10-04; HISTORY records their IDs. Issue closure and merge
  of PR #107 were authorized and completed on 2026-10-04.

## Issue #87 - Compass and project menu pointers (4.37.16)

- Implemented view-driven compass, north +Y, eight bilingual directions,
  bounded native HUD scaling and reserved message space.
- Author refinement: corrected visible letter alignment; added silver laurels
  and a subdued Sun of May behind the needle. Native evidence under
  assets/validation_43716/compass_refinement; visual acceptance passed 2026-10-04.
- Sun of May replaces both skull frames; C moon supplies the native cursor.
  Immutable generated art inputs and deterministic vector integration retained.
- Evidence: assets/validation_43716. Author checks passed 2026-10-04; closure/merge authorized.

## Issue #101 - Traditional ranked Truco (4.37.15)

- Separate Argentine Truco against Argento: 30 points, optional Flor, no
  RPG damage or future rating service. Author's confirmed variants: SYSTEMS.
- Preserve accepted practice, deck/quest rules and saved matches. Additive
  revision-1 inventory, existing card art and native pause/save/load.
- Evidence: assets/validation_43715. Author checks passed 2026-10-04; closure/merge authorized.

## Issue #99 - Argento practice choice order (4.37.14a)

- Practice is the final ordinary reply before goodbye in all existing pages.
- Preserve page identity and every other reply/action/condition; native verify
  the displayed order and entry into the already accepted match.
- Evidence: assets/validation_43714a. Author checks passed 2026-10-04; closure/merge authorized.

## Issue #97 - Palomo's first upstairs deck handoff (4.37.14)

- Grant the physical deck upon successful conversation opening after following
  Palomo upstairs, before choosing equipment or receiving the later Box.
- Reuse the existing grant record/capacity guards; preserve repeated dialogue,
  saves, essences, route and USDF page indexes. Explain the new timing in EN/ES.
- Evidence: assets/validation_43714. Author checks passed 2026-10-04; closure/merge authorized.
- Focused PR follows #95; #81 is accepted/merged, #93 is author-accepted.

## Issue #93 - Crafting time help (4.37.13a)

- Show keyboard Y time skip next to T acceleration in the lower EN/ES help and
  active-task status; preserve existing controls, mechanics and saves.
- Agent evidence: assets/validation_43713a. Author checks passed 2026-10-04; closure/merge authorized.
- Based on accepted #81, merged via PR #94. Author acceptance passed 2026-10-04.

## Issue #81 — Trucazo against Argento (4.37.13)

- Requested 2026-10-04: one complete single-player match against Argento in
  MAP01, with native validation, commit and push.
- Isolated branch `issue-81-trucazo-argento` starts from #80 commit c7fe3fe9;
  #80 is now author-accepted and merged via PR #92. Its original build stays
  available while the author tests it.
- The contract in SYSTEMS incorporates the author's original Trucazo
  v2.0 document and 2026-10-04 decisions: traditional Truco base, ties to mano,
  no Majors or Magic Senses in this practice, no wagers, abandonment is defeat.
  Patience-squared health and row-based damage come from the source. The author
  resolved both source contradictions: one shared 56-Minor deck, first-row
  nonplayables from the initial five, second-row nonplayables from replacements
  up to three playable cards; Intelligence uses Type 1. The exact deal was
  confirmed separately. Native menu/network probing verifies actions can run
  while the world remains paused.
- Implemented: ordinary Argento challenge, bilingual card/menu presentation,
  complete hands/calls/damage/result loop, legal NPC policy with no hidden-hand
  inputs, abandonment confirmation and native save/load. Additive revision-1
  Inventory and static UI restoration preserve old saves and current matches.
- Evidence: assets/validation_43713; native rules, 100 automatic matches,
  ordinary dialogue entry, screenshots and save/restore/rollback checks.
- Accepted 2026-10-04: CA-43713-TRUCAZO-01/02 passed; closure/merge authorized.
  Next: #99 reorders the practice choice. Multiplayer, teams and broader
  services/full Major expansion stay deferred.

## Issue #80 — Campaign Tarot activation (4.37.12)

- Implemented: up to three selected captured essences; shared User3 activation,
  1000 Anima once, 60-second effects and 600-second cooldown from activation.
- Powers: Fool flight; fixed Minor bonuses double. Permanent collection,
  acquisition rewards and the authored mansion transition are preserved.
- Deck: Palomo's once-only 78 cards, 780 grams and one slot; protected against
  sale/drop/breakage. Capture requires it inside the player's own Box. Captured
  essences and powers remain personal.
- Compatibility: additive revisions, idempotent legacy recovery, saved selection,
  active set and timers. Changing selection never changes a running effect.
- Evidence: assets/validation_43712. The author confirmed CA-43712-TAROT-01/02
  passed on 2026-10-04 and authorized #80 closure and PR #92 merge.
  Normal validator/build, nine static and 171 native assertions pass, plus two
  baseline/rollback checks.
- Follow-up implemented: HUD duration/cooldown above the side Seal indicator;
  rest and committed journeys advance the shared timers.
- #81 supplies the first Trucazo practice; remaining Major powers/acquisition/
  awakening belong to V5. #80 author checks passed on 2026-10-04.
  No design values remain pending for this implementation.


## Issue #79 — The amnesiac guard captain (4.37.11)

- Implemented: captain canon, first/repeat local guard recognition, amnesiac
  responses and one persistent main Journal clue, independent of prisoner rescues.
- Reconciled: active wanderer/intact-memory biography and prologue Journal;
  original wording retained in HISTORY. Limbo/Unknown Voice mystery remains.
- Preserved: player customization, factions, class, stats, rewards, army control,
  prisoner briefing, siege objectives and narrator queue.
- Compatibility: quest revision 3 initializes reserved slot 9 once; existing
  USDF page indexes and 32-slot persistent quest arrays remain unchanged.
- Evidence: `assets/validation_43711`; nine static and 149 current-version native
  assertions pass, plus fourteen baseline/rollback checks. Controlled native
  victory is not a full normal battle.
- Accepted 2026-10-04: the author confirmed CA-43711-CAPTAIN-01 and
  CA-43711-CAPTAIN-02 passed without reported exceptions and authorized PR #90
  merge / #79 closure. HISTORY records both results; `pending_test.txt` has no remaining #79 checks.
  Acceptance retains version 4.37.11.
- Pending design: unspecified prior biography and future siege scheduling;
  performance remains #86. No additional story facts or mechanics are inferred.

## Issue #78 — Prisoner siege intelligence (4.37.10)

- Implemented: successful payment gates every prisoner briefing; repeat access,
  paid-rescue Journal details and the port quest use common bilingual information.
- Preserved: 25 gold/+10 own-faction rewards, Selene's event queue, page indexes,
  existing save schemas, current siege trigger and both victory requirements.
- Canon: concealed Selene service and anti-demon motive; implanted souls and
  bodily identity; amnesia and Limbo denial; Zupay retreats now, death in Chapter II.
- Evidence: `assets/validation_43710/RESULTS.json`; the author confirmed
  CA-43710-BRIEFING-01 and CA-43710-BRIEFING-02 passed on 2026-10-04 without
  reported exceptions and authorized PR #88 merge / #78 closure. HISTORY records
  both results; no #78 author checks remain. Acceptance retained version 4.37.10.
- PENDING author design: a future siege date/hour or scheduling change. Current
  data only records actual entry/deployment and victory; no deadline was invented.
- Captain recognition is implemented separately in #79 / 4.37.11 above;
  #86 still owns full-city performance. Neither belongs to the #78 patch.

## Issue #77 — Expanded southern Barracas al Sud (4.37.9)

- Author approved PR #85 merge and #77 closure on 2026-10-03, explicitly
  deferring performance work to issue #86, then explicitly confirmed all manual
  tests passed. HISTORY records the three accepted IDs; pending_test.txt is empty.
- Final author-approved scope: 960 × 960 m; 160 houses, 64 shops, 24 factories,
  40 construction sites; four accessible cannon towers and a connected wall walk.
- South assault integrated into six city gates; north/west fortified exits,
  eastern docks. All four directions remain inside MAP06.
- Forces: 6,000 Mandingas plus one commander, 600 defenders, six hostile guns
  and six rams. Thirty-six defensive guns are installed; eight southern wall
  guns plus four tower guns are active, with 24 staffed reserve emplacements.
- Physical stairs and saved crew routes retain existing actors and resources.
  Twelve hostile objectives plus commander defeat still gate victory/rewards.
- Author follow-up: at most 100 enemies per attacking command group, including
  its leader. Preserve Zupay priority, stable ties, sight links and the full army.
- Direct MAP02 → MAP06 uses the accepted Ace/Zupay and 10 km journey contract;
  the legacy MAP03 onward route remains for existing workshop saves.
- Exact prior layouts are selectable with --legacy-map06-north-city,
  --legacy-map06-siege or --legacy-map06. Current code preserves their state;
  the saved geometry/population is not converted into the expanded city.
- Evidence: assets/validation_4379/south. Original validation_4379 results
  describe the superseded 96 m northern iteration, not the final battle scale.
- Combat follow-up implemented: nearest visible player/guard, shared attack
  ranges/costs, retreat then idle until both resources fill, Pain interruption,
  double idle/chair Anima and player projectile limits. Ninety native checks pass;
  save/reload retains recovery, projectile budget and old crew identities.
- Deferred performance (#86): the final 300.5-second run reaches about 13.5 tics/s
  instead of 35. Windows responds in all 248 observations. The comparison gives
  3.9 before targeting and 14.3 with targeting alone; RNG differs between runs.
  COMBAT_RECOVERY.json records current evidence; GROUP100.json/LIVE_FREEZE.json
  retain the prior failures. No permanent deadlock or performance fix is claimed.
- Accepted on 2026-10-03: CA-4379-CITY-01 / CA-4379-ROUTE-01 /
  CA-4379-COMBAT-01 (all originating in 4.37.9 / #77).
- Next: reproduce/profile the measured live-performance failure in #86.
  Captain identity/intelligence and later V4.37 work remain separate.

## Issue #75 — Material supplies and corrected audit (4.37.8)

- Gameplay delivered and accepted with #73, retained by #74: 65 equipment
  equivalents in 39 material chests; finite enemy supplies and local keys.
- Correct the positional ledger join using catalogue_index: 63 instances /
  315 size rows. Original evidence preserved; totals/runtime unchanged.
- Auditor passes 866 checks, rejects 11 invalid variants and verifies new native
  evidence. Two generator runs match all four current outputs byte for byte.
- GZDoom: 325 recipe completions, 3,848-step keyed route, exact death supplies,
  partial/capacity collection, real save/load and hub return. Evidence and fixture
  limits: assets/validation_4378. Existing stations/knowledge remain required.
- CA-MAP02-MATERIALS-DROPS-01 was accepted 2026-10-02 (4.37.6 / #73 and #75).
  Preserve that acceptance and the old-save waiver; no unchanged test reopened.
  On 2026-10-02 the author also accepted this corrected report and #75 delivery
  without reported exceptions, authorizing PR #84 merge and #75 closure.
  HISTORY records this approval; pending_test.txt remains empty.

## Issue #74 — Flooded pit returns (4.37.7)

- Implemented: six stairless pits, one connected shallow-water network, four
  exterior-only independent grates, central native elevator and safe calls
  from either landing, including descending while all grates remain closed.
- Author decisions: previous-save compatibility waived; closed blocks keep
  their trap covers shut until their normal entrance opens.
- Population, other hazards, #75 supplies, surface locks and extraction retained.
- Static/native evidence: assets/validation_4377. New-layout save/load, hub return,
  all sizes, key recovery and four followers tested. The author confirmed all
  CA-MAP02-PIT-RETURN-01 checks passed on 2026-10-02 without reported exceptions
  and authorized PR #83 merge / #74 closure. Acceptance is recorded in HISTORY;
  the author-test queue is empty. Release 4.37.7 remains unchanged.

## Issue #73 — Cardinal MAP02 (4.37.6)

- Implements central arrival, south/west/east/north blocks and local carriers
  for all eight keys; includes the #75 supply changes explicitly required by #73.
- Author confirmed retaining current stations and waived old-save compatibility.
- This patch reserved the central footprint only; #74 implements the lower
  water tunnels/four return grates/elevator in 4.37.7 above.
- Evidence: assets/validation_4376. The author confirmed both CA-MAP02 checks
  passed on 2026-10-02 and authorized merge and closure of #73. HISTORY records
  acceptance separately from static/native evidence. #74 was also accepted on 2026-10-02.


## Issue #65 — Daily mansion food/water (4.37.5)

- Authorized by the author as a separate implementation/PR alongside #64.
- Implemented on issue-65-daily-tables, stacked on issue-64-time-skip / PR #71.
  Authored 2/2, 9/9 and 30/30 targets share the local midnight event and forecast.
- Per-table revision/day guards prevent duplicate stock. Deposited items and
  legacy rations remain; full old tables normalize only through consumption and
  later refills. Palomo explains daily timing in both languages.
- Evidence: assets/validation_4375/RESULTS.json. The author accepted
  CA-4375-TABLES-01 and CA-4375-SAVES-01 on 2026-10-02 without reported exceptions
  and authorized PR #72 merge / #65 closure. HISTORY records the results.
- PR #71 is merged and #64 closed; its acceptance is integrated before delivering
  #65 to main. All five confirmed pending entries are removed. Runtime and release
  4.37.5 remain unchanged; author acceptance is distinct from native evidence.

## Issue #64 — Date/time skip and automatic care (4.37.4)

- Implemented on issue-64-time-skip with Y destination selection, current T mode,
  native provisions/rest/work substeps and a nonmutating task-completion forecast.
- Author confirmed 10%/100% sleep policy and access throughout the safe location.
  Clock revision 1 preserves legacy counters/dates while freezing future exterior
  progression in Limbo. Original-save/package rollback remains available.
- Static/build and isolated GZDoom evidence: assets/validation_4374/RESULTS.json.
  The author accepted CA-4374-TIME-01, CA-4374-CARE-01 and CA-4374-SAVE-01 on
  2026-10-02 without reported exceptions; HISTORY records the results. Their
  pending entries are removed. Runtime and release 4.37.4 remain unchanged.
- The author also authorized #65 in another branch/PR. Its daily 50/50 table
  policy consumes #64's midnight and forecast contracts; combined multi-day
  verification belongs to that dependent patch. PR #71 merge and #64 closure
  are explicitly authorized; #65 is delivered separately through PR #72.

## Issue #63 — Move equipment guidance to Palomo (4.37.3)

- Implemented on issue-63-palomo-loadout: physical follow invitation, reviewable
  weapon/armor/Seal/shield plan and existing Ronnie recipe/material/task flow.
- Shield allowance uses current recipes and existing sources; no missing supply
  decision. Caella retains the amulet, and #65 food-source dialogue is coordinated.
- All own equipment survives departure; loans return and supplies are removed
  according to the author's explicit clarification. Revision-1 migration keeps
  old choices, quotas and progress; original-save/package rollback is tested.
- Static/build and isolated native evidence: assets/validation_4373/RESULTS.json.
  Native checks cover 49 choices, menu callbacks, physical route, all four shield
  recipes, cancellation, pending tasks, old saves and narrative exit/reload.
- Author accepted CA-4373-LOADOUT-01, CA-4373-SAVES-01 and CA-4373-EXIT-01 on
  2026-10-01 without reported exceptions and authorized PR #70 merge and #63
  closure. HISTORY records the results; the confirmed entries are removed from
  pending_test.txt. Runtime and release 4.37.3 remain unchanged.

## Issue #68 — Magic-weapon Anima base costs divided by ten (4.37.2)

- Author request after accepting #62; focused branch issue-68-anima-costs.
- Bases staff/book/bell/statuette: 50/70/100/100. Existing Eloquence Type 4
  division gives one third at 100; tiers/charge, damage and other costs remain.
- Shared constants cover player and authored NPC magic. Attribute revision 3
  updates saved derived costs and pending unpaid casts once, preserving state.
- Static/build, 240 native quotes, 48 live payments and save migration/reload
  checks pass. Evidence: assets/validation_4372/RESULTS.json. The author accepted
  CA-4372-ANIMA-01 on 2026-10-01 and authorized PR #69 merge and #68 closure.
  HISTORY records acceptance; no #68 author checks remain outstanding.

## Issue #62 — Caella's exercises against the training dummy (4.37.1)

- Implemented on issue-62-caella-dummy: offensive completion comes from a valid
  player magic projectile received by the shared mansion dummy. Projectile
  metadata identifies primary/secondary even after an equipment change.
- Actual Anima spending/recovery and Seal Channel retain independent checks;
  runes, return conversation, loans, passage and Rulo rules retain their gates.
- Reuses the existing target recovery path during Caella equipment preparation;
  adds no target class, placement, balance values or persistent schema revision.
- English/Spanish Caella and Journal instructions identify the target and room.
- Static validation, forty native spell combinations, negative/resource/rune/loan
  checks and active/completed save continuity pass. Evidence:
  assets/validation_4371/RESULTS.json. Native fixtures are isolated from
  the package. The author accepted all tests on 2026-10-01 without exceptions;
  CA-4371-CAELLA-01 is recorded in HISTORY and removed from pending_test.txt.
  Issue #62 / PR #67 is accepted; the new Anima-cost balance is a separate patch.

## Issue #61 — MAP01 terrain, vegetation and filled tympana (4.37.0)

- Implemented on issue-61-mansion-terrain: continuous native hills, mixed gentle
  and marked relief, sixteen decorative trees/twenty-four decorative shrubs,
  and filled triangular/arched tympana across all 32 original door groups.
- Author selected mixed relief and decorative-only additions on 2026-10-01;
  existing gathering resources remain unchanged. Old-save work is explicitly
  waived; use fresh MAP01/new game.
- Deterministic sources/manifests and read-only geometric preservation/continuity
  checks are included. Native traversal/resource/Palomo checks and 429 door
  regressions pass; the native tour captured 128 door views. Detailed evidence
  and scoped FPS observations belong in assets/validation_4370.
- Author correction: vegetation stays outside the pool, including underwater.
  Corrected three placements (two in the pool, one in a cave opening); generation
  now enforces dry exterior ground and a margin around the water.
- Author follow-up 2026-10-01: the other tests passed; distant ground at
  (17455,7394,0) was transparent and Prueba identified a roof-front gap above the
  top doorway. Both are corrected in the same 4.37.0 patch and PR #66.
- The author subsequently confirmed both repairs and all remaining original
  checks: CA-4370-MANSION-01 is accepted, recorded in HISTORY.
- New same-issue scope: Prueba at (23268,23285,0) identified another transparent
  area. Add the selected small mound cave, gentle descent, short bent tunnel
  and decorative rocks of all five gems. Native roof, passage, damage/resource
  and expanded distant-ground views are covered by the cave evidence.
- Author confirmed CA-4370-CAVE-01 on 2026-10-01; the original tutorial cave,
  gathering reserves and progression stay unchanged.
- Latest Prueba position (25630,29408,0): corrected invisible boundary/dark area
  by relocating 69 detached auxiliary rooms outside the playable horizon while
  preserving their control data. Static isolation and native surface, boundary,
  traversal and door regressions are in assets/validation_4370/CONTROLS.json.
  CA-4370-EXTERIOR-01 was accepted on 2026-10-01.
- Northern stations: six original actors at Y=1040 escaped relocation when hills
  raised their absolute Z above the old filter. Floor-relative recognition fixes
  selection and the spare fallback. The 38-station/five-room layout and original
  instances are retained; evidence: assets/validation_4370/STATIONS.json.
  Author confirmed CA-4370-STATIONS-01 and all remaining tests on 2026-10-01,
  authorizing PR #66 merge/issue #61 closure. No pending author checks remain;
  HISTORY records acceptance. Tested runtime and version 4.37.0 are preserved.
- Deferred Tarot/Trucazo remains separate final V4 scope before V5.

## Issue #17 — Verify and export the complete three-map test build (4.36.28)

- Author authorized export of current content on 2026-10-01 and explicitly
  deferred 4.37 Tarot/Trucazo until afterward. The accepted #16 content is frozen.
- Implemented commit-based deterministic export, SHA-256 manifest, portable
  clean-profile launcher, license notices and README-owned player instructions.
- Author reported an installation failure with engine/IWAD beside the package.
  Same-patch correction detects both locally and handles relative/quoted paths
  and folders; six process-level checks pass. Author accepted the retry.
- Static/build, exact blob identity, byte-identical reproduction and four-map
  native load/save/reload checks pass. Clean-install engine evidence is in
  assets/validation_43628/RESULTS.json; prior acceptance links and measured
  performance retain their original conditions and scope there.
- Author confirmed all tests passed on 2026-10-01 and authorized PR #60 merge
  and issue #17 closure. CA-43628-EXPORT-01 (corrected installation, ordinary
  campaign, cross-map saves and reward/resource continuity) is recorded as PASS
  in HISTORY without reported exceptions and removed from the pending queue.
- The accepted ZIP retains source commit 8415f225 and its recorded checksums.
  No GitHub Release/tag publication is requested; 4.37 remains the next work.
- Usage report retains the 75% baseline, unknown reset, separate Work/desktop
  evidence and unmeasured stages. On 2026-10-01 the author discontinued further
  weekly-allowance measurement; no additional quota tests/final balance are
  required. Missing counters do not become token or quota estimates.

## Issue #16 — Complete port siege (4.36.27)

- Implemented on `issue-16-port-siege`: full concurrent deployment, connected
  command groups, machine crews/gates, automatic unlimited cannons, 10/20-second
  reload, 100 equipped Domingo-appearance soldiers and half-health Zupay retreat.
- Victory requires twelve neutralized attacking machines plus commander defeat;
  surviving attackers physically retreat. Knight capture, prisoner rewards,
  calendar state and the explicit port endpoint use the existing shared systems.
- Native checks cover both objective orders, current save/load, original-save
  migration and rollback, exact reload times, targeting, reward/capture and the
  full 1,001-attacker/100-defender/24-machine scene. See assets/validation_43627.
- Author confirmed CA-43627-PORT-01 and CA-43627-SAVE-01 passed on 2026-09-30
  without reported exceptions and authorized PR #59 merge and issue #16 closure.
- Author reported missing crew relief and mostly stationary attackers during
  the initial port playtest. Follow-up implements nearest available same-side
  replacements and physical pursuit while magic resources recover. These
  follow-ups are included in the author's acceptance.
- Current author-requested trial enables attacks despite insufficient Air/Anima
  for registered hostile port enemies. Player/allied limits remain. The data
  switch remains reversible; the author accepted the current setting.
- #17 export passed author acceptance on 2026-10-01. Next: deferred 4.37;
  final independent distribution remains future work.

## Issue #37 — Attack cadence, durability and thrusts (4.36.26)

- Implemented: approved common duration/weight/attribute formula, full-cycle
  animations, the author's five thrusts, ×10 weapon durability and proportional
  migration, exact projectile source identity, authored enemy resource spending,
  idle recovery and the 80-tic Zupay slam.
- Verified: native shared-rule matrix, twenty weapon cycles, held Fire, cancelled
  casts/swings, exhaustion/recovery, cumulative magic phases at Eloquence
  0/33/100/1000, legacy migration/reload/rollback, pending-attack save/load and poses.
- Evidence: assets/validation_43626. Independent same-model review found and
  corrected state-index, bull recovery, encoded-pickup, phase rounding, charge
  overlap and input-deadline risks; DeepSeek was not available in this session.
- Author accepted CA-43626-COMBAT-01 and CA-43626-THRUST-01 on 2026-09-30
  and authorized PR #58 merge and issue closure. No author checks remain pending.
- Resident/companion weapon-resource assignments remain outside the authored
  hostile mappings; no guessed costs or equivalent equipment were added.


## Issue #36 — Mansion enclosure and architectural detail (4.36.25)

- Implemented: upper-storey roof/gable closure, native balcony guards,
  interior/exterior wall finishes, closed shutters, stone trim, two reliefs
  and an invisible but blocking outer horizon.
  Author follow-up: flat upper ceiling, raised finite shutters, east-wing
  interior materials and hinged wooden leaves. Latest clarification: remove four
  unwanted side doors at Z=136 and centre four independent front singles.
  Corrected the door exporter's excessive surface count behind the reproduced
  "Trying to create zero size texture" startup failure; see CA-KP-020.
- Author-approved visual proposal: aged render, wood, iron and discreet reliefs,
  2026-09-28. Historical rationale and source attribution are in ASSETS.
- Verified: preserved unaffected placements/actions/planes, deterministic output,
  focused native geometry traversal for body tiers 1/4/7, railing collision,
  roof closure and native views. Evidence: assets/validation_43625.
  Follow-up evidence covers both opening directions, three body sizes, access
  locks, swept-body obstruction and the flat ceiling; see followup and layout.
- Author confirmed the remaining prior work correct on 2026-09-29. Latest
  request: Rulo/Ronnie/Argento side doors open toward central rooms, away from
  beds; target moves to the empty north-central ground-floor room. Direction,
  placement, practice detection and bilingual guidance are implemented.
- Author confirmed those door/target tests passed on 2026-09-29, then requested
  Caella's bedside connection (908) also open toward the corridor. Implemented.
- Accepted: CA-43625-MANSION-01 fully passed on 2026-09-29, including Caella's
  last door change. The author authorized PR #57 merge and #36 closure. No
  #36 author checks remain. Evidence: assets/validation_43625/caella; #17 is separate.
- Author explicitly prioritized rebuilding over old MAP01 saves. Use a fresh
  MAP01/new game; the preserved source baseline is not an automatic migration.

## Issue #55 — Proprietary rights notice (4.36.24a)

Implemented: root LICENSE.md, README link, scoped reservation of the author's
rights and explicit preservation of third-party terms. Validate documentation
markers, index freshness and changed paths before the authorized merge/closure.
No gameplay acceptance check is added.

## Issue #35 — Quest journal (4.36.24)

- Implemented: stable main/side catalogue, independent type/status filters,
  completed records, sewer progress and four separate optional rescue records.
- Author-approved categories: mansion main; sewers/port/rescues side. Live
  extraction completes each rescue; port payment remains separate.
- Verified: validator/build and focused native state, navigation, bilingual
  layouts, legacy load, reload and hub persistence. Evidence: assets/validation_43624.
- Accepted: the author confirmed all CA-43624-JOURNAL-01 checks passed on
  2026-09-28 and authorized PR #54 merge and issue #35 closure.
- Subsequent #16 port deployment and #17 export are now author-accepted.

## Issue #52 — Final armor absorption (4.36.23)

Author revision, 2026-09-28: attacks and collisions now subtract Toughness
through its historical growth R(L)=L(L+1)/101 as percentage points of maximum
health, uncapped and with no minimum-damage floor. This supersedes the initial
direct-level subtraction. An
incoming 101% at Toughness 100 leaves 1% before armor; <=100% is still negated.
Final gate revision, also approved on 2026-09-28: Constitution 0 for all gates;
Toughness 25/50/75 and maximum resistance 5,500/6,500/11,000. Armor remains
10/20/30%. Small rams break common/reinforced/armored gates in 2/2/7 hits;
large rams in 1/2/2. Cannons retain Toughness reduction and deal zero gate damage.
Gate balance revision 2 preserves remaining-health ratio, open/broken states
and contact serials; repeated loads are idempotent. See SYSTEMS.
Current native evidence supersedes the previous matrices, retained as
DIVISOR_RESULTS.json, TOUGHNESS_RESULTS.json and GATE_RESULTS.json in
assets/validation_43623. The curve revision changes no saved levels or maxima. Release remains 4.36.23 because
all author revisions and acceptance belong to the same issue/PR patch.

- Implemented: shield/anatomy/Toughness/armor order; additive racial and equipped
  physical/magical defenses; approved tier values; Palomo 77%; gate 10/20/30%.
- Magical armor no longer grants mental attributes; other armor bonuses and
  shield rules remain. Fractional UI values use the same balance data.
- Legacy player/NPC derived statistics migrate idempotently; gate state and
  equipment are preserved. Original saves permit rollback with the previous build.
- Validation: native numerical/combat/impact/siege checks and save migration;
  evidence in assets/validation_43623/RESULTS.json. The author confirmed
  CA-43623-ARMOR-01, CA-43623-SAVE-01 and CA-43623-TOUGHNESS-01 passed on
  2026-09-28 and authorized PR #53 merge. No author checks remain pending.
- Scope: no siege penetration/explosion, new recipes, shield rebalance, map
  geometry or redesign of the existing player/NPC elemental-DOT asymmetry.

## Issue #34 — Demo quest narrative (4.36.22)

- **Implemented:** Palomo quest activation/survival/material guidance, Ronnie
  crafting/calendar, per-NPC peak Bull injury reactions, persistent queued rescue
  and paid-reward guidance, sewer death/escape line, actual-controller port quest.
- **Preserved:** main quest and item IDs, saved survival progress, crafting supplies,
  payouts, factions, combat balance, world pause rules and the single Tarot path.
- **Validation:** assets/validation_43622/RESULTS.json and STATIC.json; static,
  focused native behavior, old-save migration and rendered-menu checks pass.
- **MAP02 followup:** secondary-wind CELH sprite registration fixes the reproduced
  native rendering hang; both projectile variants/older-save checks pass.
  Author retest of the second rescue and rats passed 2026-09-27; see wind_render_fix.json
  in assets/validation_43622.
- **Legacy dialogue followup:** reproduced Palomo needs after old MAP02 reload;
  versioned Voice rebinding and safe closure/reopen of other old dialogues pass
  native checks. New saves preserve their exact page; original saves permit
  rollback. Author death/reload retest passed 2026-09-27.
- **Author acceptance:** CA-43622-NARRATIVE-01 passed on 2026-09-27; the author
  confirmed all tests and authorized merge/issue closure.
- **Dependency boundary:** #16 must deploy the complete MAP06 army/routes. The
  port quest stays hidden in the present pre-siege port; registered encounter
  integration is tested in isolation. After deployment, accept the full port
  narrative and retreat in campaign before #17 export. No fake victory is inferred.

## Issue #49 — Scenery collisions and running (4.36.21)

- **Issue:** https://github.com/damiancurti/Caelum-Argenteum/issues/49
- **Implemented:** environmental collision provenance without adrenaline or
  combat refresh; existing absorption extended to running and stationary scenery.
- **Preserved:** impact formulas, shield/landing/crush rules, genuine combat,
  saved fields, states and approved artwork/geometry.
- **Validation:** isolated native before/after and save checks plus static
  validation; assets/validation_43621/RESULTS.json.
- **Author acceptance:** CA-43621-IMPACT-01 passed on 2026-09-27.
- **Delivery:** PR #50 targets main after #48 merged; author approved merge on 2026-09-27.

## Issue #33 — Arcana capture, wounded Zupay and forward route (4.36.20)

- **Issue:** https://github.com/damiancurti/Caelum-Argenteum/issues/33
- **Implemented:** shared capture for IDs 0/36/60, El loco naming, confirmed
  boss-defeat reveal, provisional actual-reward gate for the Knight, wounded
  sewer-boss retreat at triple speed, MAP02 -> MAP03 -> MAP06 only forward route.
- **Preserved:** accepted extraction/rewards, siege test room cleanup, artwork,
  card effects, map geometry and old ownership/IDs.
- **Evidence:** assets/validation_43620 distinguishes static checks, native
  scenarios, saved-game migration and review from author acceptance.
- **Author acceptance:** CA-43620-ARCANA-01 and CA-43620-ROUTE-01 passed on 2026-09-27.
- **Author-reported failure corrected:** Ace Use froze before confirmation.
  Registered both Minor front sprites; native rendered dialogue/capture
  retests pass. Author retest passed; see capture_render_fix.json and HISTORY.
- **Next:** review the linked PR; #16/#17 replace the Knight's provisional
  appearance rule when the complete port siege is implemented.

## Issue #43 — Walking wall-impact absorption (4.36.18)

- **Issue:** https://github.com/damiancurti/Caelum-Argenteum/issues/43
- **Implemented:** existing crouched wall fraction also applies to grounded
  directional walking, using native effective run state. Walls only, no new balance.
- **Evidence:** 24 isolated native checks, including real wall traversal and a
  same-height jump with 80 kg body /20 kg equipment; assets/validation_43618.
- **Accepted:** author confirmed CA-43618-WALK-01 passed on 2026-09-27;
  merged and #43 closed. Final collision balancing is in 4.36.19 under #21.

## Issue #21 — Controlled cannon ballistics (4.36.17, final balance 4.36.19)

- **Issue:** https://github.com/damiancurti/Caelum-Argenteum/issues/21
- **Implemented:** physical 500 m/s inert projectiles, native gravity/collision,
  muzzle checks, load/fire/recovery, two/one/zero-operator behavior, separate
  faction ownership and persistent hostile-machine neutralization.
- **Decisions:** approximate reconstruction approved; 4.3 kg /75 x 185 mm inert
  rounds; 30/60-second cycles; Type 4 collision mitigation and 50/100/200 gate
  Toughness/Constitution. Final matrix approved 2026-09-27; merged and #21 closed.
- **Evidence:** assets/validation_43617; 41 cannon and 53 ram/shared-siege checks,
  plus save/hub/legacy checks passed. Manual CA-43613-CATAPULT-01 passed by author confirmation on 2026-09-27.
- **Final evidence:** assets/validation_43619; reversible gate balance migration,
  native damage matrix and affected regressions. The author confirmed
  CA-43619-BALANCE-01 passed on 2026-09-27; no manual checks remain pending.
- **Next:** #16 authors campaign placement, operators, ammunition/aim and rewards;
  #17 verifies the complete encounter. No full army is instantiated by #21.

## Issue #20 — Operational demonic rams (4.36.16; planned label 4.36.12)

- **Issue:** https://github.com/damiancurti/Caelum-Argenteum/issues/20
- **Implemented:** native approach/alignment, separate moving assembly,
  single-contact strike/recovery, full 6/32 staffing, persistent local death
  records, one-time neutralization, twelve-objective-plus-boss victory hook
  and authored-route withdrawal without kill rewards.
- **Author decisions:** 2026-09-26 full crew required; small rams affect wood
  and reinforced gates, large also armored; demonic contact velocity permitted.
- **Evidence:** assets/validation_43616. Static validation/build passed; 53
  native ram checks, 50 gate/body regression checks and save/hub/legacy
  persistence checks passed. The author confirmed CA-43612-RAM-01 passed on
  2026-09-26 and requested merge/closure; its result is recorded in HISTORY.
- **Next:** #21 cannon operation; #16 authors port routes/operator choreography,
  placements and victory rewards; #17 verifies complete encounter integration.

## Issue #19 — Breakable actor gates (4.36.15; planned label 4.36.11)

- **Issue:** https://github.com/damiancurti/Caelum-Argenteum/issues/19
- **Delivered:** explicit gate controllers, three approved material profiles,
  finite collision, damage/Use/key/faction groups, idempotent destruction and
  an assembly-mass/contact-velocity API for #20/#21. Optional MAP03 trial reuses
  accepted positions. MAP01/MAP02 doors and existing save schemas are unchanged.
- **Validation:** native fresh suite and actual save/load/hub-return chain pass;
  legacy 4.36.14a save and repeat trial activation pass. See assets/validation_43615.
- **Acceptance:** CA-43611-GATES-01 passed on 2026-09-26. The author confirmed
  every test after the reciprocal body-collision correction df4c668b and asked
  to close #19. HISTORY records the result; the pending entry is removed.
  Native evidence remains 13 focused assertions and 37 gate regression checks.
- **Next:** #20 ram strikes, #21 cannon ballistics/contact at approved speed,
  #16/#17 authored port placements and complete encounter. No provisional cannon
  projectile mass or forced gate destruction is introduced.

## Issue #18 follow-up — Siege art correction (4.36.14a)

- **Request:** author correction on 2026-09-26; linked to closed issue #18.
- **Scope:** defined cannon/ram forms, continuous two-leaf doors, wood/metal
  material variants and one visible model per state; fresh MAP03 preview.
- **Validation:** native state views and open-passage checks; deterministic
  generation, resource references, validator and normal package build.
- **Acceptance:** author confirmed all visual tests passed on 2026-09-26
  (`CA-43614A-SIEGE-ART-01`); transferred to HISTORY and removed from the queue.
- **Follow-up:** remove all remaining MAP03 tables, chairs, beds and crafting
  stations, prevent respawn and cover existing saves; native evidence in
  `assets/validation_43614a/cleanup`. Historical cannon scale/breech verification
  remains separate from this visual correction.
- **Next:** #19 damageable gates, #20 ram physics and #21 cannon physics;
  retain the authored hardness values in #18 without inventing new data.

## Issue #31 — Pain sounds, dialogue cue, map music and story intermissions (4.36.14)

- **Issue:** https://github.com/damiancurti/Caelum-Argenteum/issues/31
- **Scope:** integrate the author-selected pain sounds for Mandinga, Zupay,
  Bull, Argento, Ronnie, Caella and the applicable player voice profile;
  replace the dialogue-opening cue with the supplied Suno WAV; reassign MAP01
  to the former MAP02 music, MAP02 to the local sewer track, MAP06 to the local
  port track and MAP07 to the local coast track; reserve the former MAP01 music
  for future chapter-end intermissions.
- **Author contract:** no new Suno generation, no death/chase assignments, no
  activation of unused stock or MP3 backups, no invented lore or chapter text.
  Rulo remains silent for combat pain. External pain-source licenses remain to
  be verified; source URLs and local files are preserved.
- **Status:** implemented on the focused branch; static validation, build and
  native ZScript compile pass. Author-accepted on 2026-09-25
  (CA-43614-AUDIO-01 passed).
- **Next:** #18 / 4.36.10 owns siege assets after this delivery.

## Issue #18 — Reusable siege preview assets (4.36.10)

- **Issue:** https://github.com/damiancurti/Caelum-Argenteum/issues/18
- **Scope:** add reusable cannon, battering-ram and destructible-gate assets as
  verified-rendering content. Generate deterministic OBJ meshes under
  `src/models/caelum/siege`, transparent `CSGN A-D`/`CRAM A-C`/`CAGT A-C`
  frames, guarded `MODELDEF` bindings and the three runtime actor classes. On
  MAP03, retire the trial chairs, dining tables and cots and show every state
  in the open tank for author review.
- **Author contract:** no siege mechanics, mass, damage, reload time or gate
  hardness in this patch; those values remain #19-#21. Scale/orientation are
  provisional until the live preview is accepted.
- **Acceptance:** `CA-43610-SIEGE-ART-01` passed on 2026-09-26, as
  recorded in HISTORY. The 4.36.14a follow-up was also accepted on 2026-09-26; see its entry above.
- **Next:** #19 / 4.36.11 owns damageable gates and persistent opening.

## Issue #15 — Approved Tarot fronts and collection bindings (4.36.9)

- **Issue:** https://github.com/damiancurti/Caelum-Argenteum/issues/15
- **Scope:** integrate the author-supplied 78 PNG Tarot fronts under
  `src/graphics/caelum/tarot`, preserve the shared card back, map every source
  filename to its persistent card ID, and bind the Ace of Cups front in the
  Journal instead of showing a back. The Marseille court order is preserved:
  within each suit, Ace, 2–10, Knight, Page, Queen, King.
- **Author contract:** no new powers, rewards or campaign grants; unobtained
  cards are not granted by importing art; the Ace of Cups remains card 36; the
  Knight of Wands (`Tarot/61 - Caballero de basto.png`) is bound but its
  campaign reward stays in #16.
- **Acceptance:** CA-4369-TAROT-ART-01 passed on 2026-09-25; the author confirmed
  the imported fronts, persistent-ID bindings and Journal preview. The pending
  entry is removed and the author-test queue is empty.
- **Next:** #18 / 4.36.10 owns siege assets after this delivery.

## Issue #14 — Prisoner rescue, escort and port rewards (4.36.8)

- **Issue:** https://github.com/damiancurti/Caelum-Argenteum/issues/14
- **Scope:** release the four MAP02 prisoners through cell dialogue; freed
  prisoners follow and fight with the source character's stats while staying
  back from the northern Zupay; extract each alive at the pre-boss reservation
  before that fight (killing the boss is not required); persist outcomes and
  spawn rescued prisoners once at the MAP06 port, granting +10 own-faction
  reputation and 25 gold coins (1,000,000 copper) once per rescued prisoner,
  independent of character size, with no duplicate payout and retryable coin
  delivery. Replace the provisional social domains with six canonical factions:
  Unitarians=0, Federals=1, Free Peoples=2, Caelith=3, Cult of the Tarot=4 and
  Sun Warriors=5.
- **Author contract:** a follower that dies before extraction is not rescued;
  zero, one or four rescues are valid; no death respawn; do not reopen other
  cells; no broad companion formations. The Tarot remains the next issue.
- **Acceptance:** CA-4368-RESCUE-01 passed on 2026-09-25; the author confirmed
  the full release/follow/extraction/port-reward route and requested closure of
  issue #14. The pending entry is removed and the author-test queue is empty.
- **Next:** delivered through #15 / 4.36.9.

## Issue #13 — Recolored prisoner appearances (4.36.7)

- **Issue:** https://github.com/damiancurti/Caelum-Argenteum/issues/13
- **Scope:** add four distinct prisoner appearances that reuse Caella, Ronnie,
  Rulo and Argento with deterministic per-material muted palettes (hair/fur/cloak/cloth
  changed, skin and accessories kept); place one inert variant
  in each reserved MAP02 endpoint cell; keep the source combat profile and the
  original mansion NPCs unchanged.
- **Author contract:** provisional display names Leonor Benítez (Unitarians),
  Rufino Acosta (Federals), Santos Barrera (Free Peoples) and Leandro Farías
  (Cult of the Tarot); stable persistent IDs independent of names; no inherited
  anchoring, quest, inventory or story-protection logic; no rescue/reward logic
  in this visual patch.
- **Acceptance:** CA-4367-PRISONER-ART-01 passed on 2026-09-24; the author confirmed
  the four variants, visual-source/faction mapping and per-material recolors.
- **Next:** #14 / 4.36.8 owns escort, combat, dialogue and rewards.

## Issue #12 — Hostile sewer rats (4.36.6)

- **Issue:** https://github.com/damiancurti/Caelum-Argenteum/issues/12
- **Scope:** add two hostile sewer rats per Mandinga across the four MAP02
  sections, reusing the existing accepted `CaelumGiantRat` actor (DoomEdNum
  18029, RATG sprites) with no new art, damage, health or AI. Preserve 96
  Mandingas and one Zupay; place exactly 192 rats at fixed dry-walkway
  positions (two per Mandinga junction), recorded in the per-section manifest.
- **Determinism:** the MAP02 generator and layout validator are updated
  together; rats are initial placements only (no death respawn/resurrection),
  preserving the 2:1 ratio per section (24 Mandingas / 48 rats each).
- **Acceptance:** CA-4366-RATS-01 passed, explicitly confirmed by the author on
  2026-09-24 without qualifications; the confirmed entry is removed and the
  author-test queue is empty. Static/native evidence remains separate from that
  confirmation.
- **Next:** #13 / 4.36.7 after this delivery; #14 owns live escort AI.
## Issue #29 — Selective file reading for agents (4.36.5a)

- **Issue:** https://github.com/damiancurti/Caelum-Argenteum/issues/29
- **Status:** Implemented and statically verified; documentation/workflow only.
- **References:** `AGENTS.md`, `README.md`, `docs/CONTEXT.md`,
  `docs/GZDOOM_DEVELOPMENT.md`, `docs/DOCUMENT_INDEX.md` and
  `validate_project.py`.
- **Scope:** make selective file reading explicit in the agent workflow,
  reconcile it with the existing task/document mapping and index rules, and
  add practical search and range-reading examples in the engineering guide.
- **Acceptance:** `python validate_project.py` exits 0 with version `4.36.5a`,
  ten documents and no errors; `python build_document_index.py` regenerates
  `docs/DOCUMENT_INDEX.md` byte-for-byte; `git diff --check` passes. No
  gameplay, balance, asset, map, localization or save change is introduced.
- **Next:** #12 / 4.36.6 remains the next gameplay delivery.

## Issue #11 — Four-section sewer, cells and repair refuges (4.36.5)

- **Issue:** https://github.com/damiancurti/Caelum-Argenteum/issues/11
- **Scope:** four keyed sections/cells, beds and refuges; wider walkways and
  transparent barred gates; exact approved ammunition and retained population/loot.
- **Author decision:** repair known weapon recipes only; no new recipe/material
  allowance. Preserve finite salvage, costs, time and normal breakage.
- **Compatibility:** explicit legacy build continues already-visited MAP02 saves
  without map-ID changes, reset, lost loot or rewritten save data.
- **Acceptance:** CA-4365-MAZE-01 passed, explicitly confirmed by the author on
  2026-09-24 without qualifications; delivered through PR #28. HISTORY and
  validation_4365 keep author evidence separate from static/native checks.
  The confirmed entry is removed; the author-test queue is empty.
- **Next:** #12 rat population after this delivery; #14 owns live escort AI,
  extraction and rewards. #16 owns the MAP06 player-route reconciliation.

## Issue #10 — T1 loot, default sizing and pickup feedback (4.36.4)

- **Issue:** https://github.com/damiancurti/Caelum-Argenteum/issues/10
- **Scope:** complete 65-entry T1 MAP02 catalogue, reusable recipient sizing for
  natural/reward weapons/armor/shields, nonmutating chest previews with explicit
  collection, and actual acquisition names in a bounded 20-entry message feed.
- **Compatibility:** preserve owned/imported gear, old looted slots, existing
  size mapping and balance; revisioned unclaimed-loot migration, no replenishment.
- **Evidence:** HISTORY and `assets/validation_4364/` separate static/native
  results from author acceptance. The author confirmed CA-4364-T1-LOOT-01 passed
  on 2026-09-23; its entry is removed and the author-test queue is empty.
- **Status:** implemented and author-accepted; delivered through PR #27.
- **Next:** #11 / 4.36.5; no unrelated MAP01
  replay or implementation of the future rescue rewards belongs to this patch.

List of the project's active tasks. It is updated with every task.

Format of each entry: ID, title, status, reference documents, and acceptance
criteria. If a datum is not defined in the canonical documents, write
`PENDING`; do not invent it.

## Issue #22 — Engineering guides and document index (4.36.1b)

- **Issue:** https://github.com/damiancurti/Caelum-Argenteum/issues/22
- **Status:** Implemented and merged in PR #23; static verification is recorded
  in HISTORY. Documentation/tooling only.
- **References:** AGENTS, README, the canonical documents,
  `GZDOOM_DEVELOPMENT.md`, `KNOWN_PITFALLS.md`, `build_document_index.py` and the
  generated `DOCUMENT_INDEX.md`.
- **Scope:** integrate the two development handoff guides into `docs/`, generate a
  deterministic index for every maintained document over 5,000 words, extend the
  validator to cover guide/index metadata, hashes, links and word counts, and
  reconcile the prisoner coin reward to the confirmed T1/recipient-size rule.
- **Acceptance:** `python validate_project.py` exits 0 with version `4.36.1b`,
  ten documents and no errors; `python build_document_index.py` regenerates
  `docs/DOCUMENT_INDEX.md` byte-for-byte; `git diff --check` passes. No gameplay,
  balance, asset, map, localization or save change is introduced.
- **Regenerate/verify:** from the repo root run `python build_document_index.py`,
  then `python validate_project.py`.

## Issue #6 — Documentation and validation workflow (4.36.1)

- **Issue:** https://github.com/damiancurti/Caelum-Argenteum/issues/6
- **Status:** Implemented and statically verified; PR #7 is merged. On 2026-09-23
  the author confirmed zero validator errors, successful rebuild/launch and both
  4.36.1 diagnostic headers. CA-4361-WINDOWS-01 is passed and recorded in HISTORY;
  its pending entry is removed.
- **References:** AGENTS, README and the five canonical documents; validator,
  builder, launcher and issue template.
- **Scope:** English maintained documentation; numeric versions; repository-first
  delivery; a persistent root author-test queue; related validator/tooling updates.
- **Acceptance:** preserve canonical content, formulas, provenance and historical
  labels; synchronize 4.36.1 current markers; pass full-tree validation and focused
  positive/negative cases; demonstrate the queue lifecycle on disposable records;
  deliver a PR linked to #6 with executed evidence and outstanding author tests.
- **Evidence:** record actual commands, environment, exit codes and results in
  the PR and the 4.36.1 entry of HISTORY. Author checks live in
  [pending_test.txt](../pending_test.txt); confirmed outcomes move to the originating
  release's history entry only after explicit author confirmation.
- **Excluded:** gameplay, balance, map geometry, assets, localization and saves,
  apart from current-version diagnostic labels.

One issue defines one patch; its GitHub number is independent of the version.
Plan in Work, implement/test in desktop Codex on a focused branch, review the
linked PR, then record author acceptance when required. Multiple implementation
commits and later acceptance retain the same patch version. Outstanding tests
from earlier releases stay in the same queue. The queue may be empty; it must
remain tracked. Backlog tasks below are not executable author tests.

## Focused corrections after the author's 4.36.0i tests

- **Issue #8 / 4.36.2:** [Empty-bow equip stall](https://github.com/damiancurti/Caelum-Argenteum/issues/8).
  First-use texture-composition stalls reproduced in native GZDoom 4.14.2
  on Windows. Deterministic bow crop caches remove repeated composition;
  native evidence is in HISTORY. The author confirmed CA-4362-BOW-EMPTY-01
  passed on 2026-09-23; its entry is removed from the pending queue. Bow
  appearance, ammunition rules and save compatibility are retained.
- **Issue #9 / 4.36.3:** [Additional flail rotation](https://github.com/damiancurti/Caelum-Argenteum/issues/9).
  Implemented: shared handle offset -39.5 -> -29.5 degrees. Native Windows
  before/after T1–T3 captures and grip/joint, rest, full spin, return and re-equip
  checks passed; evidence is in HISTORY and `assets/validation_4363/`.
  The author confirmed CA-4360I-VISUAL-01 passed on 2026-09-23, with no
  reported exceptions, and requested issue closure. The pending entry is
  removed; PR #26 includes the implementation and acceptance record.
- Start each patch from the preceding merged version. These two issues are not
  implemented by the 4.36.1 acceptance-record update. Accepted maze, save/load,
  table and bow-art checks are recorded in HISTORY and are not reopened.

## Author-requested sewer and playtest batch — 2026-09-23

Historical batch, delivered during the now-closed 4.36 series. Read PROJECT
and the individual acceptance entries for canonical scope and evidence.
The original planning order is preserved; it is not a current pending queue.
PR #7 itself only updated documentation; subsequent patches delivered the work.

| Patch / stage | Issue | Delivery and acceptance |
| --- | --- | --- |
| 4.36.4 | [#10](https://github.com/damiancurti/Caelum-Argenteum/issues/10) | Implemented and author-accepted on 2026-09-23. Complete T1 catalogue, recipient sizing, chest preview and feedback. |
| 4.36.5 | [#11](https://github.com/damiancurti/Caelum-Argenteum/issues/11) | Implemented and author-accepted on 2026-09-24; CA-4365-MAZE-01 passed (PR #28). Four sections, keys/cells/beds, recipe-gated repair refuges, widened channels and northern boss room. |
| 4.36.6 | [#12](https://github.com/damiancurti/Caelum-Argenteum/issues/12) | Implemented and author-accepted on 2026-09-24; CA-4366-RATS-01 passed. 192 fixed rats/96 Mandingas at 2:1, no respawn. |
| 4.36.7 | [#13](https://github.com/damiancurti/Caelum-Argenteum/issues/13) | Implemented and author-accepted on 2026-09-24; CA-4367-PRISONER-ART-01 passed. Four per-material recolored prisoner appearances in the reserved cells. |
| 4.36.8 | [#14](https://github.com/damiancurti/Caelum-Argenteum/issues/14) | Implemented and author-accepted on 2026-09-25; CA-4368-RESCUE-01 passed. Follow/fight with source-character stats; extract alive before MAP02 boss; port thanks, +10 own-faction reputation and a fixed 25 gold coins independent of character size once per rescue. |
| 4.36.9 | [#15](https://github.com/damiancurti/Caelum-Argenteum/issues/15) | Tarot fronts and correct collection bindings. Implemented from the verified local source archive; author-accepted on 2026-09-25 (CA-4369-TAROT-ART-01 passed). |
| 4.36.14 | [#31](https://github.com/damiancurti/Caelum-Argenteum/issues/31) | Author-selected pain sounds, supplied dialogue-opening cue, local sewer/port/coast music and the reserved chapter-end story intermission. Implemented and author-accepted on 2026-09-25 (CA-43614-AUDIO-01 passed). |
| 4.36.10 | [#18](https://github.com/damiancurti/Caelum-Argenteum/issues/18) | Implemented and author-accepted on 2026-09-26; includes the accepted 4.36.14a art correction. |
| 4.36.11 | [#19](https://github.com/damiancurti/Caelum-Argenteum/issues/19) | Delivered as 4.36.15; CA-43611-GATES-01 passed on 2026-09-26. Original planned label retained in this column. |
| 4.36.12 | [#20](https://github.com/damiancurti/Caelum-Argenteum/issues/20) | Delivered as 4.36.16; CA-43612-RAM-01 passed on 2026-09-26. Original planned label retained in this column. |
| 4.36.13 | [#21](https://github.com/damiancurti/Caelum-Argenteum/issues/21) | Delivered as 4.36.17 with final 4.36.19 balance (500 m/s); cannon and balance checks accepted on 2026-09-27. Original planned label retained in this column. |
| 4.36.27 | [#16](https://github.com/damiancurti/Caelum-Argenteum/issues/16) | Complete MAP06 port siege and Knight of Wands. All author tests passed on 2026-09-30; PR #59 merge and issue closure authorized. |
| 4.36.28 | [#17](https://github.com/damiancurti/Caelum-Argenteum/issues/17) | Reproducible three-map package and corrected launcher accepted on 2026-10-01; PR #60 merge/closure authorized. Further weekly quota measurement discontinued; 4.37 remains next. |

The source/faction mapping is Caella/Unitarians, Ronnie/Federals,
Rulo/Free Peoples (Pueblos Libres) and Argento/Cult of the Tarot. These are new
prisoners; do not alter the mansion residents or reuse unrelated saved faction IDs.
The confirmed three-map route uses MAP06 for the existing port, not a
renumbered MAP03. Issue #16 replaces the former player exit to MAP07
with the approved route. El Loco is the first Major; Ace of Cups remains MAP02.

Preserve the historical #8–#21 Usage evidence and correction records. The author
discontinued further weekly-allowance measurements on 2026-10-01. The initial
75% remaining baseline has an unknown reset and is not a token count. Existing
Work/desktop, resets, concurrent-work and missing-measurement distinctions remain.
Only add actionable author checks to pending_test.txt after implementation;
missing design/assets belong here and in issues, not in that queue.

## Environmental scope — closed 4.36 and deferred work

The author's 2026-09-23 clarification in #8 distinguishes covered mechanisms
from deferred features. The 4.36 release is closed, explicitly reconfirmed on
2026-10-05. Its trapdoor, pit, rocks, approved traps, ceiling crusher and
resting-weight formula remain accepted. Deferred surfaces and avalanches below
remain future backlog, not reasons to reopen 4.36 or delay closing 4.37.

### CA-436-01 — Damaging surfaces

- **Status:** Deferred until environmental temperature effects are implemented
  (author confirmation in #8, 2026-09-23). Future backlog, not a 4.36 blocker;
  no acid or lava is requested now. Not implemented.
- **Reference documents:** `docs/PROJECT.md` (V4.36 roadmap),
  `docs/SYSTEMS.md` (physical hazards section).
- **Acceptance criteria:** PENDING. The current documentation only states it
  as a planned base; the concrete criteria are set by the author.

### CA-436-02 — Avalanches

- **Status:** Deferred until additional maps are developed (author confirmation
  in #8, 2026-09-23). Future backlog, not a 4.36 blocker. Not implemented.
- **Reference documents:** `docs/PROJECT.md` (V4.36 roadmap).
- **Acceptance criteria:** PENDING.

### CA-436-03 — Rams

- **Status:** Implemented in #20 / 4.36.16 (planned label 4.36.12), with native evidence in assets/validation_43616. Author acceptance CA-43612-RAM-01 passed on 2026-09-26.
- **Reference documents:** `docs/PROJECT.md` (V4.36 roadmap).
- **Acceptance criteria:** Native visible strike/contact/recovery with one
  physical impact per strike, gate interaction and save/reset persistence.
  Mass/speed/cadence parameters require canonical reuse or author approval;
  render-only assets do not close this gate.

### CA-436-04 — Cannons (historical catapult task ID)

- **Status:** Implemented in #21 /4.36.17 (planned 4.36.13); native evidence in assets/validation_43617. CA-43613-CATAPULT-01 author acceptance passed on 2026-09-27.
- **Reference documents:** `docs/PROJECT.md` (V4.36 roadmap).
- **Acceptance criteria:** One physical projectile per synchronized launch,
  native trajectory/collision, approved impact rules and loaded/in-flight
  save persistence. Projectile/launch/reload parameters need canonical reuse
  or author approval; final encounter integration belongs to #16.

### CA-436-05 — Moving sectors

- **Status:** Covered by the existing crushing ceiling and native elevator,
  per the author's 2026-09-23 confirmation in #8. No longer a 4.36 blocker.
- **Reference documents:** `docs/PROJECT.md` (current 4.36.4 scope).
- **Acceptance:** Scope confirmation only; no new engine test or replay is
  claimed. No rotating/translating rooms or additional platforms are requested.

## Integration and closing of 4.36

- **Status:** Closed. Explicitly reconfirmed by the author on 2026-10-05.
- **References:** `docs/PROJECT.md`, `docs/HISTORY.md` and the accepted
  #16 / 4.36.27 siege and #17 / 4.36.28 test-export entries above.
- **Evidence:** #16 author tests passed on 2026-09-30; the reproducible
  three-map export and corrected launcher were accepted on 2026-10-01.
  Existing individual physics/integration checks retain their recorded results.
- **Historical gate:** gallery integration, persistence/reset and validation
  before any Impact Physics extraction were original planning criteria.
  This correction records release closure, not a new engine test or a claim
  that a separate standalone extraction was performed.
- **Next:** finish the remaining 4.37 details, then follow the V5 roadmap.
