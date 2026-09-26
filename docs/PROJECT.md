# Caelum Argenteum — Project, status and roadmap

Documentation version: **4.36.14a** — 2026-09-26.

## 4.36.14a — Author-requested siege asset correction (#18)

The closed #18 receives a focused visual follow-up: continuous two-leaf gates
in wood, reinforced wood and iron-clad armor; clearer cannon and ram geometry;
and independent per-state rendering. MAP03 displays nine gate previews plus
the four cannon and three ram states. No balance, campaign geometry or save
schema changes. The original author acceptance remains historical; the revised
appearance awaits `CA-43614A-SIEGE-ART-01`. Exact historical cannon dimensions
remain unverified. See ASSETS for reference geometry and evidence limits.

## 4.36.10 — Reusable siege preview assets (issue #18)

Issue #18 is a visual-assets delivery, not a gameplay change. A deterministic
generator produces the reusable cannon, battering ram and destructible gate
meshes plus their per-state sprite frames and `MODELDEF` bindings. The MAP03
workshop/tank shows a visual-only preview gallery: its trial chairs, dining
tables and cots are retired, and every cannon/ram/gate state is laid out in the
open reservoir for the author to check appearance, orientation, attachment
points, collision envelopes and clearances before the siege mechanics land in
#19-#21. Mass, damage, reload time and gate hardness remain unverified and are
not invented here.

The preview does not alter MAP01/MAP02, recipes, economy, save schema or the
accepted station/rest systems. The only persistent addition is the static
gallery actor data in `src/caelum/world/CaelumSiegeAssets.zs` and its
`src/ZSCRIPT` include, plus the generated `src/models/caelum/siege` and sprite
files.
## 4.36.8 — Prisoner rescue, escort and port rewards (issue #14)

The four MAP02 prisoners become optional live companions: a cell dialogue
releases each captive, and a freed prisoner follows and fights with the source
character's accepted combat statistics while staying back from the northern
Zupay. A follower is extracted only by reaching the pre-boss reservation alive
before that boss fight; killing the boss is not required, and a follower that
dies earlier is not rescued. Zero, one or four rescues are valid. Each outcome
persists across save/load/travel, and each rescued prisoner appears once at the
MAP06 port, granting +10 reputation with that prisoner's own faction and 25 gold
coins (1,000,000 copper) once, independent of character size, with retryable
coin delivery and no duplicate payout. Six canonical factions (Unitarians,
Federals, Free Peoples, Caelith, Cult of the Tarot and Sun Warriors) replace
the provisional social domains without relabeling accepted IDs 0-3; broad
companion formations remain out of scope.

The author confirmed CA-4368-RESCUE-01 passed on 2026-09-25, covering release,
follow, combat, extraction, persistence, the one-time port rewards and the six
canonical factions, and requested closure of issue #14.

## 4.36.7 — Recolored prisoner appearances (issue #13)

MAP02 places one inert, friendly, invulnerable prisoner in each of its four
reserved endpoint cells. The appearances reuse the accepted mansion actor
sprites and combat profiles, recolored deterministically per material
(hair/fur/cloak/cloth) with muted per-faction ramps; skin and metallic
accessories keep the accepted RGB, and no new character model or replacement illustration is created.

| Visual/profile source | Gameplay faction | Provisional display name | Recolor |
| --- | --- | --- | --- |
| Caella | Unitarians | Leonor Benítez | Celeste |
| Ronnie | Federals | Rufino Acosta | Punzó red |
| Rulo | Free Peoples | Santos Barrera | Black/brown/green |
| Argento | Cult of the Tarot | Leandro Farías | Gold/silver over black |

Each prisoner is a distinct identity: persistent map IDs and class names do not
depend on the provisional display names. Appearance reuse does not inherit
mansion anchoring, prologue quest identity, trade inventory, faction assignment
or story-protection behavior. The cells keep their stable lock/route geometry;
rescue, escort, combat and rewards remain #14. Original mansion NPC art is
unchanged; in the same release their MAP01 idle cycle alternates the accepted
monster idle A and B breathing poses. While inert, each prisoner keeps the
accepted A/B idle breathing poses and never enters the walking/chase animation.
The author visual check CA-4367-PRISONER-ART-01 passed on 2026-09-24.

## 4.36.6 — Hostile sewer rats (issue #12)

MAP02 keeps its four keyed sections and all accepted #10/#11 contents, and adds
two hostile sewer rats per Mandinga: 192 rats against the retained 96 Mandingas
and one Zupay (a fixed 2:1 ratio, 24 Mandingas / 48 rats per section). Rats
reuse the existing accepted `CaelumGiantRat` actor (DoomEdNum 18029) and RATG
sprite/combat profile. No new art, damage, health, AI or balance value is
introduced.

Placement is deterministic: the MAP02 generator writes two fixed dry-walkway
positions per Mandinga junction and records each rat in the per-section
manifest. Rats are initial placements only and never respawn or resurrect, so
the exact ratio holds for the whole map. Static layout validation records are
in `assets/validation_4366/`; native combat and save/load evidence are separate
from author acceptance. The author check CA-4366-RATS-01 passed on 2026-09-24.
## 4.36.5a — Selective file reading for agents (#29)

Issue [#29](https://github.com/damiancurti/Caelum-Argenteum/issues/29) is a
documentation patch that extends `AGENTS.md` and the engineering guide with an
explicit selective-reading workflow: search names, symbols and indexed
headings before opening large files, read relevant ranges and their required
dependencies, treat `build/` as targeted test evidence, and review PRs from
the diff outward. The practical examples live in `GZDOOM_DEVELOPMENT.md`. No
gameplay, balance, map, asset, localization or save change is introduced.

## 4.36.5 — Four-section sewer layout (issue #11)

MAP02 now contains four identifiable sections, each ending in a separately
keyed prisoner cell and usable bed. The northern section leads to the keyed
Zupay arena; the Ace of Cups and existing boss/card exit checks remain. A
reachable prisoner extraction reservation lies outside that arena; escort
actors, extraction state and rewards remain #14. The player still uses the
existing MAP07 connection; #16 owns the later MAP06 route reconciliation.

Passages provide two 160-MU dry walkways beside a harmless 64-MU channel,
384-MU level crossings/open gates and 128-MU gate headroom. Existing maximum
player/prisoner collision diameters are 42.6667/42.6 MU and maximum height
74.7 MU. Cell exits, bends and refuge accesses use the same clear dimensions.
Existing barred-gate and iron artwork is reused; no Doom asset or MAP01 change.

The retained counts are 96 Mandingas, one Zupay, 45 traps, 39 chests/65 unique
recipient-sized T1 items and 120 food/120 water. Ammunition totals are 240 arrows,
120 bolts and 120 bullets, counted as units rather than bundles. Four maintenance
alcoves provide connected T1 stations without placed enemies/traps. Existing
rest/combat, finite salvage, crafting costs and times still apply.

Author clarification during #11: repair only weapons whose final recipe is
known; other weapons may wear out and break. No extra recipes or materials are
authorized. The implementation now checks knowledge before reserving components.
The former all-family repair-supply expectation is superseded by this decision.

Compatibility continuation is explicit: a previously visited MAP02 requires
`run_dev.bat --legacy-map02`, retaining its original WAD and every saved state.
New layouts do not overwrite existing maze progress. HISTORY records static,
native and compatibility evidence separately from the author-confirmed PASS of
CA-4365-MAZE-01 on 2026-09-24 (PR #28). Next implementation: #12 / 4.36.6.

## 4.36.4 — T1 acquisition, recipient sizes and feedback

Issue [#10](https://github.com/damiancurti/Caelum-Argenteum/issues/10) replaces
the former all-tier MAP02 acquisition catalogue with 65 unique T1 combinations:
16 armor pieces/types, 36 weapon/essence variants, four shields, four amulets
and five seals. Fresh maps distribute these across the existing 39 chests.
The three-section geometry, enemies, traps and 120 rations of each kind remain.

Natural world/reward weapons, armor and shields use an explicit reusable
character-default size policy; actual acquisition resolves the recipient's
existing body-to-equipment mapping before capacity checks. Fixed-size authoring
remains possible, and already acquired equipment retains its size and condition.
Opening a chest previews its actual remaining contents in Spanish without
transferring or binding them; collection is explicit and revalidates the recipient.
A bounded feed retains up to 20 recent gameplay/acquisition entries with separate
expiry, initially eight seconds through one configurable project parameter.

SYSTEMS defines the contract and migration details; HISTORY records actual
verification separately from author check CA-4364-T1-LOOT-01, confirmed passed
on 2026-09-23. The next implementation is #11 / 4.36.5.
The updated #10/#14 author decisions also supersede the former price-average
rescue reward with a fixed 25 gold; #14 still owns its future implementation.

## 4.36.3 — Additional first-person flail rotation

Issue [#9](https://github.com/damiancurti/Caelum-Argenteum/issues/9) adds the
author-requested 10 degrees counterclockwise to the 0i handle pose through the
shared T1–T3 transform. Grip insertion, rear chain/ball, vertical rest and the
full attack revolution remain intact. No gameplay rule, source artwork or save
schema changes. Native before/after evidence is recorded in HISTORY and
`assets/validation_4363/`; CA-4360I-VISUAL-01 retains its original provenance
and passed on the author's explicit confirmation on 2026-09-23. Its pending
entry is removed; no new release number or gameplay change accompanies this
acceptance. PR #26 was integrated before the 4.36.4 implementation above.

## 4.36.2 — Bow first-use stall and environmental scope

Issue [#8](https://github.com/damiancurti/Caelum-Argenteum/issues/8) replaces
runtime reconstruction of bow crop strips with six deterministic PNG caches
derived from the original images. Native palette effects, all 18 sprite names,
scales/offsets, presentation logic, ammunition and save schemas remain intact.
Native evidence and the author's 2026-09-23 pass confirmation for
CA-4362-BOW-EMPTY-01 are recorded in HISTORY.

The author's 2026-09-23 scope clarification in #8 covers moving sectors with
the existing crushing ceiling and native elevator. Avalanches are deferred
until additional maps are developed; damaging surfaces until environmental
temperature effects, with no acid/lava requested now. These three items are
not 4.36 release blockers. Rams/catapults, remaining integration/save/reset
checks, 4.37 Tarot/Trucazo and the three-map demo requirements remain pending.
This decision introduces no new environmental gameplay or engine claim.

## 4.36.1 — Documentation and contribution workflow

Issue [#6](https://github.com/damiancurti/Caelum-Argenteum/issues/6) establishes
English maintained documentation, numeric patch versions, repository-first
delivery and one persistent [author-test queue](../pending_test.txt).
The gameplay baseline remains 4.36.0i. This patch changes no game rule, balance,
asset, map geometry, localization or save schema; only the two current-version
diagnostic labels change in gameplay sources.

The release-specific sections below preserve their original scope, accepted
decisions, evidence and then-pending work. Older ZIP/application guides are
historical records. Current installation is in [README](../README.md), and
only the root queue defines outstanding actionable author checks. Old test
references do not reopen already accepted work. Implementation evidence and
remaining acceptance are recorded in [HISTORY](HISTORY.md).

Current releases use MAJOR.MINOR.PATCH: 4.36.0i -> 4.36.1 -> 4.36.1b -> 4.36.2 -> 4.36.3 -> 4.36.4.
Intermediate commits and later acceptance retain the originating patch version.
The larger roadmap remains in force. Proper names, identifiers, literal game
dialogue, formulas and original external source material retain their spelling;
English explanatory text does not change the bilingual game localization.

## 4.36.1b — Engineering guides and long-document index

Issue [#22](https://github.com/damiancurti/Caelum-Argenteum/issues/22) integrates
the development handoff into the maintained documentation, adds a deterministic
[document index](DOCUMENT_INDEX.md) for every maintained document over 5,000
words, and extends the validator to keep guide/index metadata, hashes, links and
word counts in sync. It also reconciles the prisoner coin reward in SYSTEMS to
the confirmed T1/recipient-size rule. This is documentation and tooling only:
no game rule, balance, asset, map geometry, localization or save schema changes.

## Author roadmap update — 2026-09-23

The author requires **three complete campaign maps**, covering the prologue,
El Loco / the Fool (0) and two Minor Arcana, before the external V4 playtest.
This small campaign slice is now an explicit exception to deferring new
campaign content to V5. It does not waive the existing 4.36 physics or 4.37
Tarot/Trucazo gates. Test arenas and travel stubs do not count as complete maps.

The release sections above record completed implementations; later stages remain planned.

| Patch / stage | Issue | Scope |
| --- | --- | --- |
| 4.36.2 | [#8](https://github.com/damiancurti/Caelum-Argenteum/issues/8) | Empty-bow equip stall. |
| 4.36.3 | [#9](https://github.com/damiancurti/Caelum-Argenteum/issues/9) | Additional flail rotation. |
| 4.36.4 | [#10](https://github.com/damiancurti/Caelum-Argenteum/issues/10) | MAP02 equipment is Tier 1 only; retain every starter weapon/essence and armor/accessory combination. |
| 4.36.5 | [#11](https://github.com/damiancurti/Caelum-Argenteum/issues/11) | Four keyed sewer sections, endpoint cells with beds, repair refuges, channels/decor and the northern locked Zupay chamber. |
| 4.36.6 | [#12](https://github.com/damiancurti/Caelum-Argenteum/issues/12) | Two hostile rats per Mandinga in each section: preserve 96 Mandingas, add 192 rats. |
| 4.36.7 | [#13](https://github.com/damiancurti/Caelum-Argenteum/issues/13) | Four prisoner palette variants reusing the mansion characters. |
| 4.36.8 | [#14](https://github.com/damiancurti/Caelum-Argenteum/issues/14) | Following/fighting prisoners, living extraction before the MAP02 boss, port arrivals, one-time +10 own-faction reputation and a fixed 25 gold coins independent of character size per rescue. |
| 4.36.9 | [#15](https://github.com/damiancurti/Caelum-Argenteum/issues/15) | Integrate approved Tarot fronts, including the Ace of Cups; no new powers. |
| 4.36.14 | [#31](https://github.com/damiancurti/Caelum-Argenteum/issues/31) | Integrate selected pain sounds, the supplied dialogue-opening cue, local sewer/port/coast music and the reserved chapter-end story intermission. |
| 4.36.10 | [#18](https://github.com/damiancurti/Caelum-Argenteum/issues/18) | Catapult, ram and breakable-gate assets with documented states/attachments. |
| 4.36.11 | [#19](https://github.com/damiancurti/Caelum-Argenteum/issues/19) | Damageable actor gates and persistent passage opening on destruction. |
| 4.36.12 | [#20](https://github.com/damiancurti/Caelum-Argenteum/issues/20) | Ram strikes using the approved physical-impact foundation. |
| 4.36.13 | [#21](https://github.com/damiancurti/Caelum-Argenteum/issues/21) | Native catapult trajectories/projectiles and physical impacts. |
| V4 playtest content | [#16](https://github.com/damiancurti/Caelum-Argenteum/issues/16) | Stop the demon siege at MAP06 port; its commanding Zupay holds the second Minor. |
| V4 playtest delivery | [#17](https://github.com/damiancurti/Caelum-Argenteum/issues/17) | End-to-end acceptance and reproducible export after the retained system gates. |

Issue #10 supersedes the earlier all-tier MAP02 loot request for future
implementation. The current accepted 0i map remains three sections with T1–T3
until these patches land. Preserve 120 food and 120 water rations, existing
repair costs/durability and the 45-trap set when rebuilding; provide actual
repair stations and audit existing recipes/material access rather than making
repairs free. Keys must admit a complete route without circular locks.

The prisoner appearances/factions are author-defined: Caella -> Unitarians;
Ronnie -> Federals; Rulo -> Free Peoples; Argento -> Cult of the Tarot.
These are new identities, not changes to the mansion residents. The six
canonical factions replace the former provisional IDs: Unitarians=0, Federals=1,
Free Peoples=2, Caelith=3, Cult of the Tarot=4 and Sun Warriors=5. Each prisoner
has the same initialized combat statistics as the source mansion character,
with separate identity and no inherited mansion-only anchoring/quest logic.
Freed prisoners follow and fight alongside the player. They must reach a
physical exit alive, before the northern MAP02 Zupay fight, to be extracted
to the port; they do not participate in that boss encounter. This NPC exit
must not bypass the player's boss/card progression. Persist each outcome.
At the port, thanks grant **+10 reputation with that prisoner's own faction
and 25 gold coins, once per successful rescue**, independent of character size.
The latest #10/#14 author decision replaces the old weapon-price average;
SYSTEMS, Economy, "Prisoner coin reward" records the fixed payout. Implementation
remains in #14, not this loot-policy patch.
Unrescued NPCs must not appear there; benefits cannot duplicate on retry,
save/load or travel. Broad companion formations remain outside this patch.

Confirmed three-map route: MAP01 mansion/Fool -> MAP02 sewer/Ace of Cups ->
existing MAP06 port/second Minor. Preserve map IDs. The current MAP02 exit
targets MAP07, so #16 must update that player connection explicitly.
The third map's objective is to stop a demon siege; its separate commanding
Zupay holds the second Minor, whose exact identity is still PENDING.
Catapults, rams and damageable actor gates are required, with separate
asset/mechanic issues #18–#21. This bounded port encounter is now part of
the playtest; a general world-siege director remains V5. Encounter counts,
machine/gate parameter tables and detailed win/fail rules need authored data.
The Tarot source ZIP was verified locally; its definitive manifest is committed
as `assets/manifests/tarot_78_v4369.json` while the oversized archive is not
stored in normal Git. Do not regenerate approved art.

The remaining mechanism gates are rams and catapults (#20/#21), followed by
integration/save/reset validation before extracting Impact Physics. The
author's #8 clarification covers moving sectors and defers avalanches and
damaging surfaces as described above; none of those three blocks 4.36. For
ram/catapult scope,
assets alone do not close those bases. Missing numerical criteria still
need approval. Later campaign expansion remains V5.

### Usage measurement for this batch

Author-confirmed baseline on 2026-09-23: **75% of weekly allowance remaining**.
It is an author report, not a directly observed account counter; the reset
time is unknown. Capture source/timestamp, model/provider/effort/speed, token
categories when exposed, correction rounds and final allowance. Keep Work
planning/review separate from desktop implementation; mark missing coverage,
resets and concurrent unrelated usage. Never infer tokens from changed lines
or quota percentages, or compare the full translation as an equivalent patch.
Issues #8–#21 define the current measured implementation batch. Details and
per-patch evidence belong in the linked PRs; #17 consolidates the final report.

## 4.36.0i — maze, flail, rations and approved weight

[ACCEPTED BY THE AUTHOR] Proposed static-weight formula, bows except thickness,
carriage and other 0h tests. It is authorized to rebuild MAP02 without preserving previous saves. This delivery is incremental on the complete 0h project.

[IMPLEMENTED AND COMPILED IN GZDoom g4.14.2]

- Flail: +22,5° anti-clockwise from 0h, half of the exposed handle sunk into the hand; chain/ball in
  independent back layer, vertical at rest and complete counterclockwise turn when
  attacking. Damage and attack rate are preserved.
- Normal/long bows T1–T3: double transverse thickness only in the first person. Curvature,
  palette, hands, string and arrow maintain the accepted rules.
- Food ration 200 g; water 200 ml/200 g. At 80 kg, 2 kg or 2 L restore 100 percentage
  points after completing its ten portions.
- MAP01 tables filled once: four small ×4, one normal ×18 and one large ×60 =94 rations.
  No periodic replenishment.
- Static weight due to excess capacity, percentage of maximum health, native support, split between
  supports and retained fractional remainder. Formula in SYSTEMS.
- MAP02: three 49 room sectors, 96 Mandingas, 45 traps, three keys, 39 chests with 195
  different T1–T3 equipment pieces; 120 rations of each provision.
- End with Zupay, Ace (1) of Cups and exit to MAP07. The other test accesses are left in the
  final chamber. The hub retains the objects and the loot removed.

[VERIFIED] Compilation and native tests in Linux with GZDoom 4.14.2 and development Freedoom. Real inventory of chests, locks, card, food, water, tables, weight and spin
of the flail; coverage and static routes of the map. Reports separate those checks from a complete human playthrough. On 2026-09-23 the author accepted the maze, save/load, table and bow-art checks. Final flail pose remains partial: approximately 10 degrees more counterclockwise is requested (#9). A new report of a multi-second stall when equipping an empty bow is tracked in #8. The original guide was PRUEBAS_4_36_0i.txt; current outstanding checks are carried in [pending_test.txt](../pending_test.txt), with confirmations in HISTORY.

### Major Arcana and block closure

It was not possible to confirm another Major Arcana passive besides El Loco, La Estrella
and El Sol. Old ideas for other Majors are not converted into approved assignments. The Ace (1) of Cups applies the current Minor rule. There is only front art of El Loco on this base;
the Ace of Cups uses the shared reverse and its textual identification, without inventing a
front.

The flail pose remains in #9; the author accepted the 4.36.2 empty-bow
correction (#8) on 2026-09-23. The other reported 0i tests remain accepted. Rams, catapults
and remaining integration/save/reset validation still precede Impact Physics
extraction; the three environmental items follow the current #8 scope above.
The following sections record previous deliveries and then-pending plans.


## Historical 4.36.0h — bow reference, clockwise rotation and served tables

[ACCEPTED BY THE AUTHOR] The rest of the 0g tests were good. The accepted shapes,
proportions and palettes are preserved. The new visual review is limited to the flail and
grip marked on the attached screenshot.

[IMPLEMENTED IN SOURCES] Flail: 90° clockwise relative to 0g (+28° → −62° native), with the grip shifted to keep it in frame. Bows: upper index finger behind; section marked in blue behind the thumb and the other phalanges.

[IMPLEMENTED IN SOURCES] Real initial food at all MAP01 tables: one ration per seat,
discounting food already present. Six tables, 26 seats. Persistent initialization for new
games and tables from previous saves; does not replenish what is consumed or replace objects from
a full table.

[IMPLEMENTED IN SOURCES] Native ceiling: pulse damage expressed in percentage of maximum health
for player and NPC Caelum. Current value 10 → 10% per pulse. Maintains timing and native
immunities; does not convert impacts again.

[PROPOSED, NOT ACTIVATED] Damage from stationary mass resting on the character. The formula of sustained
impulse was found, but not an approved static formula. Damage proportional to the overload
of the actual capacity is proposed; k=10% maximum health per second for each additional
capacity. Formula and examples in SYSTEMS. The premise of not inventing balance requires
the author's decision on this rule.

[VERIFIED LOCALLY] Resources, rotation/masks, percentage arithmetic and food conservation
model. GZDoom was not executed nor was native save verified. Increment tests in PRUEBAS_4_36_0h.txt.

### What is needed to close 4.36

Historical 0h checklist. Later 0i acceptance and the 2026-09-23 author
clarification in #8 supersede its then-pending requirements; use the current
4.36.2 scope and TASKS for active gates.

1. Accept these corrections and verify boot, tables, damage and saves.
2. Agree and implement the static weight: stacked masses, split between supports, victim
   release and absence of double damage with landing.
3. Complete the planned bases for surfaces with their own damage, avalanches, rams, catapults and
   mobile sectors using the physics core.
4. Validate the integration of those mechanisms into the gallery, persistence and restart.
   Extract Impact Physics only after validating its use in Caelum.

0g tests accepted are not reopened except for regressions of this delta. After 4.36
corresponds 4.37 (Tarot/Trucazo), and then export V4.

## 4.36.0g — proportions, flail and palette

[IMPLEMENTED IN SOURCES] Flail T1–T3: +28° rotation to the left at rest, more marked than +14° of 0f. It was found that kind 8
reaches CaelumFirstPersonLayers; the observed failure is not attributed to a cache or run
path that could not be replicated in the engine.

Axe with a 50% larger head and separate handle. Halberd with its shaft lengthened along its axis, without enlarging blade, ribbons or hands. Greatsword with the same shape and
less saturated/darker colors in view, inventory and ground sprite. Bows: index finger behind the wood; thumb and phalanges of the other three fingers in front. Arrow continues on
top layer.

[PRESERVED RULE] The axe secondary is documented as blunt, stronger and shorter-ranged than the slashing primary. Combat, actual reach, resources and physics were not modified with this presentation review.

[VERIFIED LOCALLY] Texture dependencies, order of states, pivots, clips, palettes, preservation of silhouettes and sources. Reconstructions of the three tiers and three phases of both bows
were inspected. [PENDING] Start, saves and visual acceptance in GZDoom 4.14.2 on Windows
11: the engine was not executed. The recovered base is partial. Application on 0f;
PRUEBAS_4_36_0g.txt guide.

The above sections are history. The author's test indicated that the 0f flail was
still without the correction expected and that the palettes were vivid.

## 4.36.0f — corrections after the author's test

[CORRECTED IN SOURCES] Rotation sign of hatchet, machete, axe, war axe and halberd: its
upper ends lean to the right. Flail incorporated to the modular layers, with inclination
to the left. Hatchet 24 MU lower than the grip; NoTrim canvases and absolute pivots.

[INTEGRATED ART] Greatsword blade enlarged in T1–T3, also in inventory and ground sprite. Bows with muted palettes, fingers behind, thumb in front and arrow in the top layer. String
built with native vertices.

[REQUESTED ADJUSTMENT] MAP08 Rolling Rock: 8 → 32 MU/tic, without forced death or change of the
damage curve. Compatibility on the next activation of saves with the old value. A released rock is not re-launched.

[AUDITED] Rock impacts use mass/speed. The ceiling uses native Crush at 10 points per
pulse. The motionless rock supported on a victim does not apply continuous pressure due to
its weight. Formulas and limits in SYSTEMS.md.

[VERIFIED LOCALLY] Structure, data, resources and views reconstructed with the order of
4.14.2 renderer transformations. They are not game screenshots. [PENDING] Compile and test in
GZDoom 4.14.2 / Windows 11. The engine download failed and the recovered base is partial.
Guide: PRUEBAS_4_36_0f.txt.

The sections prior to 0f are history; 0e's orientation and string statements were refuted
by the author's subsequent test.


## 4.36.0e — corrections requested after testing 0d

[PROGRAMMED] Fists with continuous forearms and the same glove of the other weapons; left
and right come from the same original PNG, reflected by TEXTURES. The original set of
hands is also used for both bows. The left hand is in a layer before the right. Glove
sizes independent of the size of the weapon.

[PROGRAMMED] Hatchet, axe, war axe and halberd tilted to the right with the handle seated
on the grip. +20% sword and greatsword +15% relative to 0d. Normal recurve bow and longbow with continuous limbs, both in T1–T3, with a string between the tips and hand, and visible
arrow only if loaded.

[PROGRAMMED] Trimmed MAP01 chord at the first revelation of the Arcanum. Original level up
sound by confirming its capture and applying the bonus. [CONFIRMED BY THE AUTHOR] Correct
0d transitions; its logic is preserved.

[PROGRAMMED] Carriage with front axle and two front wheels: four wheels in total. On the
boat, non-solid Use volume in front of the hull, in addition to the sign; the warning
remains centered and retains the requirements of boarding. New parts are added once when
preparing vehicles, also when loading.

[VERIFIED LOCALLY] Structure of changed sources and resources, references, layers, OBJ
geometry and reconstructed weapon/model views. GZDoom was not run for 0e: the complete
baseline had not been recovered and no engine was installed. Changed files start from
their latest recovered versions. [PENDING] Compilation and gameplay/visual testing in
GZDoom 4.14.2 / Windows 11. Instructions: PRUEBAS_4_36_0e.txt. The following sections are
historical.

## Previous base: 4.36.0d — grips, fists and visible mechanisms

Delta on the complete project 4.36.0c. The author’s observations and his four attached
references are taken care of. Dagger and magic weapons retain the approved art. Only the
weapon is inverted into hatchet, machete, axe, war axe and halberd; the hands retain
their laterality. The hatchet is held lower on its handle. Axe, greatsword, war axe and
halberd increase in size; the last three show two hands. The sword adopts the small hands
of the new package. All families move down and to the left when put away.

Crossbow and carbine are presented below, with the hands below and the left support
centered. The empty carbine uses rest, without permanent flash. Both bows lower and show
the back of the left hand on the grip, following the photograph. This grip and a pair of
closed fists are generated; the other corrections use native transformations of existing
art. Bullets on the ground reduce their scale from 0,25 to 0,10, including those saved.

CaelumUnarmedWeapon replaces the Fist fallback. It is equipped when left without a usable weapon and after cleaning objects of MAP01→MAP02. It retains the range, damage and cadence
of the previous fallback, with its own presentation; does not add a family of equipment or
modify the balance of the weapons of the catalog.

Looking at a caravan/carriage, boat, table or chair within reach shows "Use:" and its name.
Mechanism 4 is identified as local teleport and confirms arrival by message, flash and
target rune. A MAP08 side lever rearms the gallery, also in 0c saves; it rejects restart
if the crusher moves or there are bodies in the areas to be restored.

It reproduces the visual absence of hub trips: GZDoom g4.14.2 suppresses the wipes during
the first 35 rendered frames. The patch retains the departure view during that lock and then
executes the native carriage/caravan crossfade or the melt of the boat. Screenshots from the renderer confirm both effects. The accepted El Loco burn, provisions, travel time, sound
clips and global wipetype preference are retained.

Validation: GZDoom g4.14.2/Linux, 60 family/tier selections, real actions and reloads,
narrative return with fists, two trap resets, uses, confirmed trips and loading an
authentic 0c save. Native rendering was reviewed in 4:3 and 16:9. The eight WADs and
previous state blocks are preserved. Final visual/gameplay acceptance on Windows 11
belongs to the author; PRUEBAS_4_36_0d.txt accompanies that release. 4.36 remains open and
the immobilization rune remains under review only. The following sections are historical
and do not supersede these corrections.

## History: 4.36.0c — first person, audio and corrections

Delta on the complete 4.36.0b project. The author accepts the lever design and asks for
half size, reports that mechanism 4 was not activated and asks about the rock mass. He provides the packages Primera Persona v1 and Audio Events v1 (1.4 revision) and requests
crossfade for the carriage and burn for El Loco.

The lever uses 0,045 scale, also on serialized actors. It reproduces a pressure failure on
the edge of the teleport plate: 0b required the character's center to enter the radius. It
now counts the support of his feet. It maintains the guards of height, free destination
and absence of telefrag; the report explains rejections of the latest attempt. The exact
case of the author's save is not available; a occupied destination continues to be
deliberately rejected.

19 new first-person families, T1/T2/T3, are connected to the inventory and the real
selectors. The already accepted sword rig remains active; the three variants of sword
provided are available as resources. The 101 PNG and 93 compositions come from the
author's package, without regenerating art. Visual phases follow ammunition, reload,
aim, blocking and effective callbacks.

The six supplied OGGs are incorporated and the five main uses are connected: lever,
carriage, boat, tarot capture and rolling rock. The main ship clip (3–9 s) is chosen.
The tarot clip preserves revision 1.4 exactly. El Loco MAP01→MAP02 uses burn; carriage, crossfade; ship, melt. The request is created only when confirming a crossing and
does not modify wipetype.

The large granite sphere weighs 38170 kg (38,17 t). The native fall test with Toughness 13 and
without armor caused 1343/1780 points of health damage. The actual mass, speed and defenses are
printed in the diagnostic report. An old boulder that does not fit still retain its size and mass of
0a; its expansion within occupied geometry is not forced. The new patch does not rebalance
the impact core.

MAP01–08 and previous states of weapons/actors retain their bytes/indices. Tests run in
GZDoom g4.14.2/Linux; playable, visual and mixing acceptance in Windows 11 corresponds to
the author. Guide: PRUEBAS_4_36_0c.txt. The 4.36 stage remains open; the immobilization
rune remains only under review.

## History: 4.36.0b — traps, levers and presentation

Delta on the complete project 4.36.0a. The author confirms the other tests of 0a correctly
and asks to correct the size of the bull and rocks. Approves explosive magic mines,
teleport and crushing; asks for a lever on column, audible transitions and a melt effect for boat trips.

These three traps are implemented in MAP08. The MAP01–08 maps retain their WADs byte for byte. MagicHazardRevision of the existing controller incorporates the new actors once,
also in old saves. The trap and the already used mechanisms retain their status. The used levers are shown down.

Bull: general visual increase of the 25% and normalization of each running view relative to rest; its anatomy, mass, collision or attack is not changed. The PNGs provided
by the author retain their bytes. 0a rocks were small test granite; the hazard ones
receive an irregular sphere of 96 MU of diameter, central pivot and spherical granite mass
(38170 kg). The damage follows the current physics core and depends on the conditions
of impact, without automatic death.

The three traps, dimensions and values of MAP08 are test configurations; they do not set
narrative locations or definitive balance. The rest of 4.36 continues with special
surfaces, avalanches, rams, catapults and other mechanisms. 4.37 is not advanced nor is
Impact Physics yet extracted as an external package.

Proposal for revision only: a temporary immobilization rune. Duration, endurance, cost or
damage is not implemented or assigned without the author's decision. gameplay/visual
revision of 0b in Windows 11 remains pending; follow PRUEBAS_4_36_0b.txt. The above
sections are history.

## Approved base: 4.36.0a — trapdoor and first physical hazards

The author confirms "All correct" for 4.35.0q: 4.35 is approved and closed. Authorizes to
start 4.36 and adds ground traps that open when you step on them. This delta applies to
the complete 4.35.0q project.

Implemented: Reusable trapdoor on a real pit, gravity drop, rolling rock and suspended rock
released with Use. MAP08 incorporates a gallery with pit and exit ladder, connected to
MAP05 by a native access. MAP01–07 WAD retains its bytes and allows to load its saves. The
support is only removed when stepping on the lid; passing above or below does not fire it.
It remains open once activated and its state belongs to the map/hub.

The rocks reuse granite, mass and existing models. The impacts use the current formulas,
with an additional vertical adaptor and explicit environmental origin; they do not grant
combat adrenaline or add Doom thrust to the already resolved core. Saves, diagnostic report and TXT allow you to review the mechanisms. The configuration of the gallery is
trial; it does not fix narrative locations or a definitive new balance.

The author approves the remaining tests of this increment; the requested visual
corrections are addressed in 0b. 4.36 is still in development: surfaces with own damage,
avalanches, rams, catapults and large moving sectors. 4.37 is not advanced nor yet
extracted Impact Physics as an external package. The subsequent sequence remains 4.37 →
test export → V5.0 → V5.1.

The sections by version that follow retain the history; their old pending checks do not reopen
the blocks that the author has already approved.

## Approved base: 4.35.0q — sprites v4 and seated consumption

Delta on the complete project 4.35.0p, tested and approved by the author. The author
provides Caelum_Argenteum_Sprites_Iconos_v4(1).zip and modifies only the rate of seated eating/drinking: changes from 1/10 to 1/3 of the ordinary rate. Each complete
portion takes 30 seconds of simulation, retains its ten pulses and consumes the same
units/liters. Standing up resumes the normal rate.

The visual package is integrated into the current states of nine characters: breathing, running, Domingo/Palomo/Mandinga/Zupay walks, Palomo resting poses, Bull/Ronnie replacements
and icons, including the bag. The new states are attached to preserve 0p's save indexes.
Palomo retains its dialogues and exit route; its pose responds to the real movement. The
player retains priority of crouching, attack and rest.

The 0p travel, reserves, calendar, vehicle and map systems are approved. The author also
approved the visual integration and rhythm of 0q. 4.35 is closed; 4.36 begins with the
increment described above.

## Approved base: 4.35.0p — reserves and first vehicles

Delta over 4.35.0o. The author approves 0n/0o except for the corrected points here:
consumption sitting from inventory/Box and escape conflict. Authorizes a covered carriage
and a small merchant ship with sails and oars, with its facilities on both coastal maps. The
author approved these changes by requesting 0q.

The table first uses its own rations, then carried rations and finally those in the player's own Box. It retains the approved seated rhythm, the volume of the portions, digestion and
both independent toggles. It stops when satiating, exhausting the reserve or getting up.
Empty containers and remaining stacks are not extracted. Q/B cancels the estimate and
returns from the calendar/detail; Escape opens the native pause and allows to return to
the same screen.

MAP06 and MAP07 have a cargo carriage covered inside a ranch. MAP06 retains its port and
adds the merchant ship; MAP07 adds a wooden dock and another merchant ship. Using the carriage or
boarding sign opens the estimate of the 500 km route. They are testing services with
driver/draft team and guards, no fee for now; they are not free driving vehicles.

Carriage: 3 km/h while moving, 16 h traveling / 8 h camping. Merchant ship: 5 knots (9,26 km/h),
continuous navigation with favorable wind; the passenger sleeps during the crossing. The
calendar includes only time actually elapsed; sleeping on board does not add a second time
those hours. Speeds and dimensions are nominal values representative of design, not
measurements of a carriage or Argentine ship historical individual.

Structures and vehicles are installed once on entry/load, also on save maps
with 0o, and are kept in the hub. Confirmation requires to remain near the same vehicle and
recalculate the provisions before leaving.

### Historical closure of 4.35 (completed)

Manual 0p testing remains: table/Box, Q and Escape reservations, ranch entrance, boarding,
visual proportions and travel for each vehicle. If no faults arise, you can close 4.35 and
continue with 4.36 (physical dangers). No need to repeat the 0n/0o tests already approved
or add more maps or sieges.

## Base delivered: 4.35.0o — agenda and persistent events

Delta on the complete project 4.35.0n. The author defines the events: sieges, secondary
NPC/side-quest routines, rentals, shipments of goods, vein growth and future categories. Ask
for a calendar with its dates. 0n and 0o were tested by the author; 0p resolves the
comments received.

TAB → World → F/RT opens the monthly campaign calendar. It points out today, the selection
and how many known series fall in each day; shows time, type and occurrence
recorded/scheduled. Detail offers series status, first and next date, interval and
counter. Unknown events are not revealed. The date of climate debugging does not displace
this agenda.

The persistent record calculates the expired occurrences without reproducing thousands of
AI tics. It connects to the ordinary clock, Limbo 1:1, rest, x105 and confirmed trips; an estimate query does not trigger future events. Saving and loading retain dates, counters,
cancellation, debt and charges withdrawn.

Specific adapters: siege phases interrupting rest/acceleration; NPC testing that
changes its destination according to its routine; expiration of incomplete mission
targets; rental with debt/payment manual in real coins; loading of materials removed upon
dispatch and recoverable once in destination; recovery of resources that also accounts for
the absence of its map. Resources maintain 0,1 % capacity per campaign day, without
rebalancing them.

The trials are opt-in console tests. No campaign rentals, prices, schedules for the four
residents or canonical commercial shipments are invented. The infrastructure supports such
contracts when registered by a map/quest. The siege trial tests phases and temporary
blocking; the battle director, armies and political consequences retain their agreed V5
scope.

### 4.35 closure

The time-system implementation of this block remains a candidate for closure. The author's
manual acceptance of the 0q changes and resolution of any bugs that arise are still pending. No
new campaign content is required or repeated tests already approved. Then follow 4.36
(physical dangers), 4.37 (Tarot/Trucazo), V4 export, V5.0 reorganization and V5.1 thermal
exposure.

## Base delivered: 4.35.0n — measured travel and provisions

Delta on the complete project 4.35.0m. The author approves the food rations tests and
maps. Define 10 km between sewer reservoir and port, and 500 km between port and beach, with
days of 16 walking hours and 8 sleeping, current character speed and consumption of its
supplies.

The access shows an estimate before departure: real speed converted to km/h, walking/sleeping duration, rations required/carried/to be consumed, additional water in containers and
expected reserves/health upon arrival. Enter confirms; Q/B cancels without deducting rations or advancing the clock along the way. The world continues at its normal pace while
reading. If you change speed, consumption, stock or mortal risk, the view is updated
before a new confirmation.

The speed is measured as sustained walking on normal ground, 32 MU/m. It is fixed at
departure, without adding animation pauses or reducing the distance by the 20:1 factor of
the calendar. No night is added once the destination has been reached. The
diagnostic caravan is still walking, without vehicle or new fare. MAP02–05 interior
accesses retain their local treatment without assigned distance. Only the four connections
directed 8–11 have a travel-time estimate.

The numerical simulation of a tic applies needs, digestion, regeneration, lucidity and
sleep. It uses the character's own sleeping bag if carried, otherwise the ground; it does not create
rations, containers, furniture or comfort. It drinks first portions of water and then
liters of containers; it does not spend belongings of the Box. It does not start eating/drinking while asleep. Portions already started continue their pulses upon arrival. A mortal
forecast requires visible confirmation and ends with native death at origin without proof
of arrival; it does not require buying supplies to leave.

The route is applied atomically: one deduction, one clock interval, persistent registration,
weather to the date of arrival and change of map. The estimate is retained when saving; it
is always revalidated before charging. No AI, physics or encounters in the departure map are
simulated during those hours. Active effects and combat must end before the trip. Visible
technical limit: 30 days of travel per estimate; longer routes are not truncated.

## Base delivered: 4.35.0m — food by mass and coast

Food/water provide 800 / (body mass in kg) points per ration. 18 materials of the author,
MAP06 port and MAP07 coast were integrated, their native connections, shelters with two chairs,
physical coverage, non-potable river and climate of Buenos Aires confirmed in MAP02–07.
Their food tests and maps are approved.

## Base delivered: 4.35.0l — chairs, water and regional climate

The author approves 0j and 0k; of 0i only observes the second chair of Ronnie and Argento.
This delta is applied to the complete 4.35.0k project.

The chair existed, but was behind a wall on another sector with the same floor height.
Tables 102/104 move to (1072, ±480, 136), 0° orientation, with two visible and usable
chairs. Beds, accesses, original actors, content and references are preserved. A save with a seated character waits for them to stand before moving the furniture group. The preparation recovers an absent chair.

The water ration represents 0,16 liters and weighs 0,16 kg. It restores ten Thirst points
in the body M base of 80 kg; it retains the scale by body mass: 800/mass points per ration
(8 points at 100 kg). Clothing size M supports several masses and does not convert all
its users into identical bodies. Load, Box, trade and consumption are updated from a
common weight rule. Sitting preserves ten pulses during 100 s simulation, compared with 10 s standing. Containers continue to use their effective litres. An already active effect on a
save preserves the dose with which it began.

The climate uses contemporary monthly normals of the SMN, 1991–2020 period (published in
2023; 2011–2020 wind), for nine stations. The historical campaign date selects time of year
and time on that modern reference. 1889 observations are not reconstructed, and no forecast is queried during each game. Concrete episodes of rain, cloudiness and fronts are
reproducible synthesis; coverage factors are explicit approximations, not measurements of
the SMN.

Later confirmation in 0m: MAP02–05 and the following are in Buenos Aires. Buenos Aires Observatorio is their shared reference; a marker allows you to choose other regions in
future content. MAP01 maintains its Limbo exception: 20 °C, 55% RH, without wind or
precipitation, with 1:1 clock approved.

The ceilings are detected by geometrical traces, including 3D floors. The local sample
distinguishes exterior, open shelter, interior and underground; it responds to motion without
waiting for the next weather minute. The sky surfaces do not count as ceiling. Direct
precipitation is cancelled under cover; the relative humidity is recalculated according to
temperature/vapor pressure and underground humidity. Wind changes with region/fronts
and decreases under shelter.

The Journal reports region of reference and coverage. Seeds, calendar, pause and the same
result are preserved at normal/x105. See SYSTEMS.md for sources, formulas, limits and
commands; PRUEBAS_4_35_0l.txt for manual acceptance. Body exposure, wet clothing and
thermal damage continue at V5.1.

Closing 4.35 still requires events and trips with duration, joint integration and acceptance of
those increments. Then follow 4.36, 4.37, export testing and V5.0/V5.1 in the agreed
order.

## Base delivered: 4.35.0j — local rhythm, interaction and class areas

Delta over the complete 4.35.0i project. The author confirms the recovery of 100 Sleep points over 8 game hours, the 2 kg bag and the 1000 Anima base cost of Arcanist Sleep. He requests to match the radius of class skills with the base radius of
channeling seals: 1280 MU (40 m at the development scale). Sleep, the only class skill
implemented, uses that common base and the existing range modifier. Other skills remain
pending in V5; their future area follows the same rule.

Seated eating/drinking distributes the same effect and consumption during 30 simulation
seconds instead of 10 (0q adjustment of the divisor of 10 introduced in 0j). Do not change
the total for ration or liters per sip. Automatic repetition waits to finish each portion;
rising returns the remaining pulses to the ordinary rhythm. Digestion, limits and comfort retain its rules. The bag, 0i positions and accepted design are maintained.

The Limbo passes from time-stopped calendar to time 1:1 during active play at normal pace.
Clock and date advance; hourly needs and recovery of Sleep use local hours. Outside follows 1 game hour per 180 seconds. T speeds up local rhythm and compatible systems only
during valid rest/crafting. Native pause stops time; no reconstruction of previous
session time or time with the game closed. Palomo compares it to another place he knows.

Use checks the direction of the look for furniture, tables, residents and stations. A
rejected station, even on another floor, no longer cuts the Native Use route. Stations are reduced to 75% of their 0i size, i.e. 150% of before 0h: 30 radius, 72 height and 0,75 scale. The
migration is absolute, retains the actors, their networks, reserves and tasks; it does not
multiply again.

Verified in GZDoom 4.14.2/Linux: slow and automatic meals, liters/digestion, save/load,
local clock and parity with x105, accelerated sleep save of 0i, manufacturing,
dialogues/doors/furniture using Native Use, 38 Migrated Stations, Area Limits and Modifier.
Screenshots of Palomo and the workshops reviewed. Manual acceptance in Windows, including the 0i patch,
is missing; not taken for granted. PRUEBAS_4_35_0j.txt collects pending check.

To move to 4.36 you have to complete the 4.35 block: local weather (temperature, wind,
precipitation and humidity), scheduled events/travel with duration, clock adapters and
integration. Then: 4.36 physical hazards, 4.37 Tarot/Trucazo, test export, V5.0
reorganization and V5.1 thermal exposure. There is no fixed number of remaining patches.
The sections per version below describe their historical deliveries; this section sets the
current status.

## Base delivered: 4.35.0i — accesses, plates and advancement in Limbo

The author retains the design of food/water and reports six incidences of 0h. This delta
over 0h corrects the height of the dishes, exchanges bed/table zones of Ronnie and
Argento, moves the table of the back room 100 MU east, releases the eastern
gate from the northeast workshop and secures the Rulo practice dummy.

T is dedicated to advance during rest/crafting; the old +10 minutes of debugging is
maintained only by console. The Limbo allows to accelerate resources, rest, consumables
and manufacture without advancing clock or calendar. It retains the furniture sessions
without duration and the activity and danger guards.

The migration reuses furniture, chairs, objects and stations. If an affected bedroom is
occupied, wait to get up; try again if the destination is blocked. Saves with the old marker of the dummy but without actor recover one, without restarting the mission or
granting exercises or rewards.

Native tests in GZDoom 4.14.2/Linux: 26 seats/4 beds, 38 stations, real passage through
affected doors, target and practice record, exact comparison of 105 tics normal/accelerated
in Limbo, crafting and loading an occupied 0h bedroom. Revised screenshots. Full
Windows/playthrough controls in TXT.

## Base delivered: 4.35.0h — meals and furniture of the mansion

The author approves 0g, including guidance. This delta is applied on that basis. Eating consumes Sleep equivalent to Hunger actually restored / 4; the cost is bounded by the actual maximum and does not apply to drinking. F/G activates or separately stops the food/water
repetition at the table until it is satisfied. The current portion ends normally; rising
cancels the next ones. It does not restart for subsequent passive loss. Status and
belongings are saved.

Capacity: 4 servings on the 2-seat table, 18 on the 6-seat table and 60 on the 12-seat table. Original dishes with food and cups
represent the real belongings. Each bedroom of Rulo/Ronnie/Caella/Argento receives bed and
table of 2 chairs. There is a table of 6 in the false-wall/cave room and one of 12 on the
second floor.

All stations double their visual and physical dimensions. 26 stations from the bedrooms are moved to the ground floor workshops under each room; the 12 of the second floor are
preserved. Networks and specialties remain connected and separated by room; dialogues and
addresses are updated.

To use those furniture in MAP01 sessions are offered without duration, until rise.
Personal simulation continues; the Limbo clock is not moved nor is T allowed. The external
durations, comfort, Lucidity and orientation of 0g are preserved. Trucazo is not
implemented and WAD geometry is not modified.

Checked with GZDoom 4.14.2 in Linux: digestion and limits, food sequences, capabilities,
persistence, use of 26 seats and 4 mansion beds, volume of stations and networks, USDF
menus and clocks stopped. Revised captures. TXT 0h includes controls and route for Windows
acceptance.

## Base accepted: 4.35.0g — safe advance, tables and sleep

The author approves the 0f tests and authorizes the following patch. Optional advance with
T is implemented only while resting/sleeping or actively crafting, in safe testing
zones. Shares clock steps, resources, effects and manufacturing; does not depend on
i_timescale. Completion, cancellation or loss of validity stops the advance. Limbo retains stopped time. The overall range of weather, routes and events is still pending adapters
to the same time service.

MAP03 receives round table for 2, rectangular 192×96 for 6 and large 384×192 for 12; the
large doubles both dimensions. All chairs allow Wait. Use places/removes real possessions and F/G eats/drinks while seated at the table. Partial containers and contents are preserved
when saving. References table/chairs prepare the future Trucazo requirement, without yet
implementing the game.

Sleeping reduces Lucidity by 10/s and blocks its recovery. Lucidity stun does not interrupt sleep.
Arcanist User4 applies Area Sleep with the same logic, 10 s duration, waking on impact, 60 s cooldown and provisional base cost 1000 Anima. The test radius reuses 128 MU and the existing
area modifier. Other skills continue in V5. It does not change the approved attribute
block.

Fixed furniture orientation and reverse order of the lateral views of the unretouched PNG
atlas. GZDoom 4.14.2 in Linux compiles and verifies native rates versus accelerated, 20
chairs, consumables, USDF, manufacturing, skill and active saves. Captures verify sides
and back. PRUEBAS_4_35_0g.txt collects installation, controls, critical reserves and
Windows check.

## Base accepted: 4.35.0f — sleeping bag and comfort

The author approves all 0e tests. He requests a sleeping bag that can be taken in the
inventory and defines three rest factors: chair ×2, bag ×3 and bed/cot ×4 to recover
Health/Air, with loss of Hunger/Thirst divided by the same factor. They are implemented in
this delta over 0e. Resting on the floor retains ×1. Sitting does not recover Sleep;
sleeping retains the previous provisional rate, without multiplying it by the support.

The bag is a reusable native Inventory of provisional weight 2 kg. It appears in All and Keys/key items; Enter/A opens the durations, C stores it in/removes it from the Box and D
releases it, with existing controls. If it was in the Box, Enter first removes it.
Choosing a duration deploys its model on dry, clear and level ground; closing displays
nothing. The same object remains in the inventory during the session and is collected
visually when standing up, completing or interrupting, without copies or consumption.

An optional World > D/X preparation delivers a test bag in MAP02–MAP05; ca_debug_rest_bag
offers the same operation. It is not granted when loading, traveling or entering the map.
Having it prevents receiving another one for this preparation. Collection respects
capacity and space in the Box. No recipes, prices, permanent loot or new navigation
categories are added.

The comfort applies to natural regeneration and time expense. The consumption of
Hunger/Thirst includes both its passive loss and the costs of curing and recovering air.
Maximums, the fractional healing accumulator and blocks caused by critical reserves are preserved.
Anima, Lucidity and pulses of consumables do not earn bonuses. Recovery of pending Air
after immersion also accelerates by the active factor; outside the rest it retains its
three seconds of base.

Within GZDoom 4.14.2 on Linux, checks covered ×1/×2/×3/×4 rates, inventory activation and USDF responses, pickup/dropping/Box, blocked ground, cancellation, damage, maximums and critical reserves. A sleeping-bag session and a previous 0e save resting on a cot were loaded, which received ×4 preserving its progress. The sleeping-bag test and its
continuation after loading ended without failure; part of the check counter is preserved
from before the save. Native screenshots show bag, posture and factor. TXT covers the physical
controls and route of the hub to be checked by the author in Windows.

### 0f time-advance proposal adopted in 0g

The self-advance substep contract is now implemented with secure initial scope. SYSTEMS
describes exactly its adapters and limits.

## Base accepted: 4.35.0e — chairs, cots and rest camera

The author confirms that all 0d1 tests were correct and authorizes the following patch. 0d
rest base repaired by 0d1 is considered accepted. This delta adds a usable chair and cot
in each MAP02–MAP05 sewer. They also appear when loading a previous save; a repeated
preparation retains the existing pair. WADs are not modified or a return route to MAP01 is
created.

Using the chair opens Wait; using the cot opens Sleep. Choose between 5 minutes, 1, 4 or 8 game hours. The start occurs after closing the answer and validating reach, floor and
space. Close without choosing leaves the character standing. TAB > World > D/X retains
rest on the ground and its voluntary preparations. No resources are granted when
approaching, opening, loading or traveling.

The third person camera allows you to observe the existing poses and orbit with the look
controls. It uses native engine clipping against the environment. Q/B, movement or action
lifts the character; TAB lifts it up and opens the Journal; Escape keeps the pause.
completion/interruption releases the furniture and camera and recovers the input direction.
It seeks a free exit without telefrag; if the outputs are occupied, the furniture allows walking before recovering its collision. The player's physical height/radius are
retained.

Sleeping retains the provisional Sleep recovery of 100% over 8 game hours. Wait, Hunger,
Thirst and regeneration retain their approved rates. The initial date remains 03/11/1889
09:00; MAP01 stops the clock and the other maps progress to the common pace of 1 game hour per 180 real seconds. This increase does not accelerate the time. Agreed skills
continue to be recorded for your later block, without adding them to the rest system.

Verification: compilation with GZDoom 4.14.2 and automatic native tests in Linux for
Use/USDF interaction, repeated use, termination, damage, furniture loss, occupied outputs
and placement/use in the four sewers. An active session was saved and loaded and captures
of both positions were inspected. PRUEBAS_4_35_0e.txt instructions include pending check
in Windows, real controls, previous saves and hub travel.

## Base accepted: 4.35.0d1 — compilation correction

The author communicates nine parse errors when loading 0d into GZDoom 4.14.2: two pose
searches receive String instead of StateLabel, restPose remains undeclared for that first
error and six calls do not find IsTimelessMap. The catalog delivered in 0c contains that
function; it is included again complete to resolve the dependency when a previous copy was
left in the project.

CaelumPlayer.UpdateCrouchVisual and CaelumRestState.Begin now search for each pose with
their literal label. The states, formulas, persistent fields, duration, controls and
roadmap maintain the 0d contract. In that delivery playable tests were expected; the
author confirms them before 0e.

The three pose errors were reproduced with GZDoom 4.14.2 native and the correct catalog. After
applying the correction, the same engine compiled the 4621 script files of the reconstructed project. Check environment: Linux, SDL without physical screen, software rendering and
Freedoom 2 as IWAD test. This verifies ZScript parsing/compilation, not a Windows playthrough, interaction, presentation or saves. The engine and IWAD are not included in the
patch.

PRUEBAS_4_35_0d1.txt indicates how to combine all the files, rebuild the PK3, check the
0d1 report and retest Sleep/Wait, Use and Limbo time. The validator recognizes the
hotfix numeric suffix without removing checks.

## Functional base accepted with 0d1: 4.35.0d — rest and wait

The author approves all 4.35.0c tests and authorizes continuation. This 0c delta
incorporates Sleep and Wait sessions on the normal scale of the world, accessible from TAB
> World > D (X of the controller). The approved USDF dialog is used, with explicit
selection of duration: 5 game minutes, 1, 4 or 8 hours. The first lasts 15 real seconds
and allows a short check. Choosing the mode does not start the session; choosing the duration does. Closing grants no recovery and queues no pending action.

Sleep gradually recovers Sleep instead of its passive consumption. Provisional test value,
not finalized author-approved balance: 100% in 8 game hours, without exceeding 100%. Consumption of
Hunger/Thirst and usual regenerations are preserved; there is no additional healing,
automatic food or replacement of Anima or Adrenaline when starting/finishing. Waiting retains
the loss of Sleep. Critical fatigue does not cause damage while sleeping, allowing to
recover from exhausted Sleep; its remaining penalties are not canceled or damage by
Hunger/Thirst. Critical Hunger or Thirst prevent it from continuing.

The session uses a hidden Inventory and pulses of the existing clock. The character
remains still and adopts his world pose lying or sitting. You can look around; Q/B,
movement or an action lifts it. TAB raises it and opens the Journal; Escape keeps the
pause voluntary. Confirmation of the dialogue must be released before setting up the
input cancellation, and Use returns to the native path when rising without rewriting
usedown. No global freeze flags are used nor a new camera or physical furniture is added.

Effective damage, combat, displacement, water, loss of ground support, other activity, change of map or
external modification of the clock interrupt. A seal, crafting, reloading/charging, conversation or pending journey prevents start. Traveling during rest is refused. No
minutes are returned or the rest of a recovery is granted when cancelled. Terminations are
unique. The saved session preserves mode, duration, progress, position and last pulse;
loading continues if the context remains valid. Debugging dates of 0c does not modify that
clock or accelerate rest.

Limbo retains its date and rejects these timed sessions. They do not change the
pool or previous regeneration of MAP01. The menu offers voluntary preparations, without
objects: Hunger/Thirst 100%, Sleep 50% or 5%. They do not apply when opening, loading or
traveling. ca_debug_rest_report only consults; ca_debug_rest_hit requests a native impact
of 1 to check the interruption in the empty sewers. It does not represent a native test
already done here.

### Previous verification of 0d

317 assertions on rules, session methods and critical damage extracted from the ZScript
and compiled as C++, with undefined-behavior sanitizer. 33 conditions are checked at
the start and during the session. Duration, unique clock pulses, recovery, terminal
closing, input and release, prediction, fatigue and logical field restoration are checked.
Engine functions are replaced by test doubles: this does not verify ZScript compilation,
physics, native serialization or visual aspect of GZDoom.

In addition, sources, new USDF routes, translations, text width, resources and five
documents are reviewed. When preparing 0d the engine was not available; 0d1 incorporates
native build check. PRUEBAS_4_35_0d.txt retains playable tests pending. ZIP includes only
new/modified files. Maps, audio-visual, attributes, rates, recipes and 0c approved
chronology are preserved.

### Pending work to move from 4.35 to 4.36

1. Complete the rest block: accelerated advance with consistent application of time and
   interruptions. 0d/0d1 provide the session to normal scale and 0e incorporates
   chairs/cots and camera; 0f adds bag and comfort factors. 0g adds secure acceleration,
   tables/food and the Lucidity sleep rule. 0h incorporates automatic table meals,
   digestion and furniture from MAP01. 0i fixes accesses/presentation and allows personal
   advancement in Limbo without calendar. It is missing to integrate the future timed
   systems of the world.
2. Common local climate status implemented in 0k: temperature, wind, precipitation and
   humidity by calendar/location, with test profiles. Pending acceptance of this block and
   definitive regional values.
3. Plan events and trips with the same clock: schedules, duration of routes and resolution
   of events during waiting/rest or transfers.
4. Check the integration of those blocks with saves, trips and the Limbo exception, and
   close the native tests of the increments.

Then continues 4.36, mobile environment and physical hazards; then 4.37, Tarot and
Trucazo. The test is exported for other players before V5. The legacy/cross-system work,
weather over the body, class/racial skills except Sleep already implemented,
shelters/properties, automatic eating away from tables and the broader rest-quality system remain in
V5. A fixed number of patches to close 4.35 is not invented.

## Base accepted: 4.35.0c — campaign start and Limbo time

The author approves all 4.35.0b tests. Sets the start of events to 3 November 1889 at 09:00 and states that inside the Limbo time does not pass. This delta over 0b
incorporates that time rule before the next increase of rest; V4.35 continues with rest,
interruptible time advance, weather status and events/travel programmed.

The date is automatically initialized when the character is confirmed. MAP01, the Limbo
mansion, stops the global clock. On exiting the narrative route to MAP02, the same date
begins to move forward. MAP02–MAP05, CADEV02 and future maps without an explicit exception
use a clock tick per simulated tick: 1 game hour = 180 real seconds. There are no
independent clocks per map. A debug entry to Limbo stops the date reached, without
restarting it. A return connection to MAP01 is not enabled.

The suspension corresponds to the chronology of the world, not to the simulation of the
character. You can walk, talk without pause, use, capture, manufacture and complete the
tests of Limbo. Needs, regeneration, damage and recharges retain their timers and balance.
Outside Limbo the dialogues continue consuming campaign time; Escape retains the native
voluntary pause.

A previous save did not separate outside time from the Limbo. When updated, 03/11/1889
09:00 is fixed once over its current counter; CompletedDays/DayTics and all travel markers
already registered are retained. A civil date is not retrospectively assigned to those
trips. 0b inherited test calendars are replaced by this canonical start. 0c’s new saves
retain their moment when loading and browsing the hub maps.

The campaign and test view use separate anchors from the same clock.
DateSerial/CivilDayTics consult the default campaign; only the diagnostic UI asks for the
test. Changing or removing a test date does not restart the campaign: when the test is
removed, the actual date that continued to progress is shown again. Both anchors are
stopped in the Limbo. World explicitly states “Time is stopped in the Limbo”. 0b’s
southern monthly seasonal convention remains as proof: November appears as spring; no
weather is simulated.

### 0c Verification

8.849 automatic assertions on methods extracted from ZScript and compiled as C++, with
undefined-behavior sanitizer: 27 cases of migration, 4.320 projections of
campaign/test, initial date contrasted with std::chrono, rhythm per map, first midnight,
limits and isolation of debugging. The proven restoration copies the state fields: it is
not native serialization of GZDoom. The documentation/resource validator and source
review complement those calculations. There is no engine available in this environment;
ZScript compilation, real migration, save/load, travel and presentation of 0c require
PRUEBAS_4_35_0c.txt checks. The author subsequently confirmed all 0c tests; it is the
accepted basis of 0d.

The delivery contains only new or modified sources/documents and the root test guide.
MAPINFO, maps, conversation menus, input controls, audio-visual resources, attributes and
formulas of the character are preserved. V4 reaches 4.37 and then the test is exported for
other players; the legacy and cross-sectional work, including agreed skills, continues on
V5.

## Base accepted: 4.35.0b — calendar and unpaused conversations

The author approves all tests of 4.35.0a and authorizes to continue, incorporating recent
decisions on conversations and skills. This delivery is delta on 0a. Skills are still in
the already planned V5 block; here are recorded their concrete effects on SYSTEMS.md,
without presenting them as playable.

CaelumCalendarRules converts civil dates between the years 1 and 9999, with months of real
length and Gregorian leap-year rules. CaelumCalendarState saves an anchor with respect to
CaelumWorldClock. It does not have a second ticker. New and previous games start without
campaign date, as the author has not yet set it. Test commands allow to assign an explicit
date, prepare a midnight 12 simulated seconds away and remove that date without touching the
clock, resources, tasks, missions or travel marks already registered.

World shows date and season when there is anchor. The monthly austral test cycle uses
December–February, March–May, June–August and September–November. It is a technical
convention identified as evidence, not a simulation of equinoxes, light, temperature, or
weather. The historical date and its initial season remain for the author to define. Changes in the
test calendar do not trigger rewards or events and do not amount to resting or traveling
over time. The next increase of V4.35 will address rest and time advance with its
interruptions, followed by weather status and scheduled events.

MAPINFO uses UnFreezeSinglePlayerConversations on all six project maps. The common menu
CaelumPalomoConversationMenu omits the action of Ticker that pauses native conversations
at 20 tics. Derivative menus retain formatting, responses, Q/Back, sounds and capture
presentation. This path also covers conversations reopened from previous snapshots; it
does not write read-only level flags or force the global pause. The voluntary Escape menu
retains its native behavior.

The additional proposal to automatically close a dialogue for any damage is not
implemented in 0b. Its interaction with native cancellation must be checked and
completed; the change authorized here is to keep the world active. Socialization must
consume anima during the conversation when its toggle is implemented. No special cost is
added for reading a dialogue.

### 0b verification and delivery limit

The baseline was reconstructed from the author's sources, with all 4.33.0af deltas to
4.35.0a. The existing validator passed before editing. The GZDoom executable is not
available in this environment and its download could not be completed. Therefore, no
ZScript compilation, native execution, save/load or visual test within the 0b engine is
stated. These checks are described in PRUEBAS_4_35_0b.txt. The author subsequently
confirmed all of his tests; 0b is accepted as 0c base.

The arithmetic is extracted from the ZScript functions and compiled as C++ for comparison
with std::chrono: 3.652.059 civil dates, 7.840 valid/invalid input combinations and 1.728
anchor projections. Monthly seasons and integer limits are also reviewed. This test checks
the calculations; it does not replace the GZDoom compiler or virtual machine. The
documentation/resource validator finishes without errors. Review confirms five USDF
classes under the shared menu, eight new keys in both languages and 494 MU as a
conservative maximum date width within the available 544 MU. MAP01–MAP05, CADEV02, fonts,
sounds, sprites and models retain their bytes.

## Accepted base: 4.35.0a — persistent global clock

The author confirms "All right now yes" for 4.34.0e. The seal tests, crafting, use
recovery and travel are accepted. The global clock, the first increase of 4.35, is
continued; the calendar, rest, climate and events keep their place within the block.

CaelumWorldClock records full days and tics of the day in an Inventory native to the
character. CaelumWorldClockTicker is a static observer without its own time state:
consult that Inventory and advance once by simulation tic, after confirming the profile.
It is also recorded when loading a save that did not include this system. The current base
is individual.

The approved scale is retained: 1 game hour = 180 real seconds simulation, 24 hours per
day. At 35 tics/s, the hour has 6300 tics and the day
151200. Integer counters avoid accumulating roundings. TAB > World shows "Recorded time",
        expressed in past days and HH:MM, next to the scale. It does not amount to a
        narrative date or attribute seasons or changes of light.

The engine determines what time it is simulated. Pause, native menu and conversations that
pause the game stop the clock. The Journal does not pause the simulation; working in a
station continues to consume normal time. Save/load retains the counter; traveling and
returning to a map of the hub retains the traveling clock, without restoring the time of
the old snapshot of the place. It does not add up the time that GZDoom was closed nor that
of a load. Returning to a saved game restores its instant save. A new game has another
record.

A previous save starts to record from scratch when installing 0a; it does not infer past
duration from the map or missions. New sewer departures/arrivals keep markings from the same
clock. No historical 0e trips are dated or duration added to routes yet with no defined
time. The ca_debug_time_report report only consults. The travel report shows the marks
when they exist. The accepted costs or timers of needs, combat, seals and manufacturing
are not altered.

Delta delivery on 4.34.0e, with English README, five canonical documents and
PRUEBAS_4_35_0a.txt in the root. V4 continues to 4.37; then export is prepared for other
players. All legacy and cross-sectional work continues on V5, starting with code
reorganisation in V5.0.

### Native 0a Verification

GZDoom 4.14.2/Linux, with Freedoom 0.13.0 and llvmpipe: 35 correct observations, no script errors or execution aborts in the final six cases. Nine check creation, scale, unique hidden Inventory, integer hour/day boundaries, saturation, unchanged query and accurate advance
by tick. The extreme limits are prepared in an isolated counter; they do not represent
complete days spent during a manual test.

Seven observations use real keyboards: native pause, Esc menu, USDF conversation, their
respective resumptions and Journal open with active simulation. World is inspected in a
native screenshot in Spanish with five visits and three exits prepared to verify the
available space. The new line fits without overlapping with existing records or
controls.

Seven observations travel through MAP02 → MAP03 in caravan and the return for a gate with
Real Use. The clock accompanies the character, retains the inventory and date both routes;
returning to the hub does not recover the old time of MAP02. Reconciling again a resolved
arrival retains its marks and counters. Three observations load the native save of that
route and verify the save instant, the unique arrival and the exact continuation by tic.

A save is also created by running the original 4.34.0e sources, after a real arrival at
MAP03. 0a sources are superimposed on the same route before loading. Six observations check
the new clock from scratch, the previous history with no invented dates, the key and
preserved reserves, the available caravan and the marks of the first trip after the
update, including the return to the previous MAP02 snapshot.

The remaining three observations cross a prepared end of the day using real tics and start
another game using the engine: the new character has only one clock and starts from
scratch. It does not repeat the entire MAP01 story or all of the already accepted
manufacture. Fixtures, engine, IWAD and saves are left out of delivery. The project
validator checks the five updated documents and ends without errors. The author later
confirmed all tests of 0a on Windows.


## Base accepted: 4.34.0e — means to check activities and travel

The author approves what he could test of 0d, but could not check seals or crafting
because the sewers were empty. Those two tests are not taken for granted. 0e completes its
means before advancing to the 4.35 clock.

In each MAP02–MAP05 sewer there is a native workbench, sawmill and forge near arrival.
The existing TAB > World > C/Y adds “Prepare seal” and “Prepare crafting”. They are
voluntary diagnostic aids: they do not start a transfer, a channeling or a task by
themselves. The first reuses or grants Quintessence T1, equips it through the normal route and refills Adrenaline to its current maximum; its text warns that it also removes waiting
for the seal. It does not cause a fictitious combat. The second teaches Handle and
tops up to 40 wood units for the x10 batch. Deliveries respect carrying capacity. Repeat
does not duplicate the owned Seal or add wood beyond that batch. Load or travel do not
replenish resources.

Using a station in this network after preparing the recipe preselects Handle T1, batch x10 and
efficiency 100%. These are existing values; working time is calculated with the actual
Dexterity. Enter starts normal manufacturing, Q leaves the task pending and TAB > World >
C must reject the trip. Back with Use allows canceling with C or ending. For the seal your
usual control is used with a weapon equipped, and both cancellation and exhaustion is tested.

The stations are rebuilt once in previous saves and maintain their group and status within
the hub. Maps, arrival points and six routes are existing. There is no return to MAP01 or
mission changes, attributes, recipe, cost, consumption or quintessence effect. Delivery is
delta over 0d with PRUEBAS_4_34_0e.txt out of docs. After accepting these tests follow V4
to 4.37, export for other players and work inherited and cross-sectional in V5 (first V5.0
refactor).


The actual starting/closing/resuming test revealed that the Journal consumed the +use KeyUp event when
opening Crafts. 0e lets that release reach the engine so that the next Use works after Q;
it does not change the approved navigation clicks. The sequence is checked without
releasing the button by debugging commands or assigning
CraftingTaskActive/CombatChannelModeActive.

### Native 0e Verification

GZDoom 4.14.2/Linux, with Freedoom 0.13.0 and llvmpipe: 50 observations of the playable
route verify the World/C offer, native equipment, real User2 input, blocking with an
active Channel, cancellation, natural depletion, Use recovery, available recipe and batch,
Enter, Q, blocking by a pending task, resumption, cancellation and production with the
existing T acceleration. All six caravan directions are traversed; the four maps allow
using their stations, and the hub preserves groups, materials, product and the Seal
ItemId. The aids do not create a trip or repeat upon loading or changing maps. The
console-started diagnostic profile equips a native dagger to represent the weapon brought
from MAP01. Channel and crafting booleans are not assigned to simulate starting an
activity.

Seven additional observations load a native save with the actual production pending:
preserve reserves and pause, continue rejecting the journey, resume with Use and allow to
cancel without consuming or duplicating. Then a real caravan is confirmed and a single
arrival is recorded. Fixtures and saves remain outside src and are not part of the ZIP of
sources.

Compatibility is checked with a save created by running the original 0d sources, within a
caravan confirmation. 0e sources are superimposed on that same path before loading. Four
observations verify the automatically restored dialogue page without departure, three stations after closing
the dialogue, inventory/needs preserved and new preparation available without
inventing travel history. This check is not replaced by a new game. Author validation
on Windows is still pending.

Three additional checks reject actions of supplies outside of your conversation and
invalid identifiers, without granting objects or creating travel. Total: 64 correct native
observations in this verification. The Spanish offer and the physical station area of MAP02 are
inspected in native screenshots: the six responses and the three stations are visible. The
project validator ends without errors; the five documents have version 0e. They are
preserved by comparison of maps, assets, rules, attributes and the player. Only the
Journal changes the release of Use, and the presentation of stations is explicitly limited
to the test sewers.

## Previous increase: 4.34.0d — caravans and travel registration

The author confirms "All tests proved correct" for 4.34.0c and authorizes the following
patch. The MAP02–MAP05 network, its six directions and hub, is accepted, with the prohibition
to return to MAP01. Continues the V4 order to 4.37, export test for other players and then
everything inherited and transverse in V5, starting with the V5.0 refactor.

0d incorporates the caravan service base by means of an explicit test in TAB > World > C
(Y of the controller). It offers only the connections of the current sewer. The native
dialog separates selection, return to destinations, cancellation and confirmation. It is not a campaign NPC and assigns no faction; the test does not charge, create vehicles or simulate a duration.

The physical accesses and the caravan share CaelumTravelService. Before leaving, the
profile, health, origin, available destination, activity, prediction, single-player session
and absence of another pending transfer are checked. The accesses also retain their
placement, scope and vision checks. The engine moves the actual inventory and retains the
hub. The MAP01 narrative return → MAP02 continues with its exclusive confirmation and
cleanup.

CaelumJourneyState, a new and hidden Inventory, records last path, mode, sequence and
quantities of arrivals/interruptions. An arrival is counted only at the expected
destination and with its pending connection. Repeating the query or loading a resolved
arrival does not duplicate counters. Another arrival, an incompatible mark or loading an
output still in origin interrupts it without retrying. The query of a save 0c does not
invent history; it begins when traveling. World shows the last trip and offers the test.
The ca_debug_travel_report console report is read only.

The 4.34 service and registration base is implemented; the schedules, durations and
time integration of events continue in 4.35 with the clock. Transports, mini travel
map, incidents and deviations of the broad design are still planned and are not presented
as playable content of this trial. The next expected increase is the overall 4.35 clock,
subject to validation by the author of 0d. The code refactor remains in V5.0.

Delta delivery on 0c with English README, five canonical documents and PRUEBAS_4_34_0d.txt
out of docs. It does not include engine, IWAD, saves or fixtures.


### Verification of 0d and limits

In GZDoom 4.14.2 native, with Freedoom 0.13.0 and llvmpipe/Linux, 57 behavioral
observations are completed: 27 of safeguards and reconciliation, 21 for selection/cancellation/six directions and real Use, two for saved conversations, five migrations from original sources 0c and
two reloads in destination. Reconciliation cases prepare exit marks to test rejection,
interruption and resolution without attributing real paths.

The keyboard test comes from World with C, uses explicit responses from USDF and retains a
sealed card, silver key, reputation and needs during transfers. The saved conversation was
in MAP04 confirmation; loading continues there without leaving alone and a confirmation
produces an arrival. The save 0c was created by running its original sources and was
loaded after superimposing 0d on the same test path. The Box retains ItemId 1, next to
key, sealed card, 47 reputation and needs, before and after the trip. The subsequent save
contains MAP02/MAP03 snapshots and arrival log; loading does not count it again. It does not
simulate a new game as if it were a previous save. It does not repeat the whole story or
manufacturing.

World is inspected in Spanish and English with five visits and three exits prepared to
verify its complete layout; the confirmation page is captured during the native
conversation. Maps, assets, attributes, narrative inventory and accepted entries are
preserved; the new key only acts in Sewer World. Author validation in Windows pending.

## Base accepted: 4.34.0c — Test sewer network

The author confirms "All correct" for 4.34.0b. Authorizes to connect MAP02 to other sewer
maps, intended for mass testing, Tarot and the following systems. Leaves the connections
to implementation criteria, except to return to MAP01. This authorization extends the
testing space of V4; the complete campaign and legacy/cross-system work retain their
place in V5.

A star network is incorporated: MAP02 connects with MAP03, MAP04 and MAP05; each branch
returns to MAP02. There is no normal access back to MAP01. All six directions have
independent records. The narrative return retains its 1 identity, confirmation, limbo
cleaning and arrival with the Voice.

| Map | Space and purpose | Access from MAP02 |
| --- | --- | --- |
| MAP02 | Existing arrival and distribution of tests | The arrival of the prologue is preserved. |
| MAP03 | 4096 × 3072 MU reservoir, wide center, side channels and peripheral pillars; base for future massive testing | Left gate at the far north end, in (-236, 1104, 0). |
| MAP04 | Central chamber with side and rear chambers; base for future Tarot | Right gate at the far north end, in (236, 1104, 0). |
| MAP05 | Maintenance: ground floor, two stairs with eight steps of 12 MU and upper gallery at +96 MU | Wall gate right/east, in (344, 448, 0). |

Approaching the gate shows your destination and the use indication. The journey is
requested with the usual Use key. When entering MAP03–05 you look inwards; the return gate
is left behind. On returning to MAP02 you use the existing PlayerStart (-236, 32, 0),
separate from the gates. Holding Use during loading does not produce a bounce trip. There are
no costs, dummy travel time, automatic loading of enemies or gift cards.

The four sewer maps belong to the native 434 hub. GZDoom saves its actors, left objects
and modified geometry for the return and for session saves. The character inventory
travels as its own instances. Switching between sewers does not run the cleaning of the
Limbo again, does not cure or replenish needs. Traveling with active activities or menus,
freezing of others, invalid character, wrong origin, missing destination or several
players is refused; exit of the rest is not forced.

MAP01, MAP02 and CADEV02 are preserved. The gates are rebuilt from the existing
controller, so they also appear when MAP02 load from 0b. Prepare again does not duplicate
accesses. The persistent Inventory scheme is not changed: 32 slots and 1 World
version; content identities are added only in the reserved catalog positions.

TAB > World presents visits in one column and known exits of the current map in another.
Approaching an access discovers it; the visit and the tour are credited upon arrival.
Knowing or walking the way does not invent the return. The Journal is still of
consultation. The arrows and Page Up/Page Down keep their accepted actions. The completed return to the body is reported in the footer as a journey without step back to the mansion.

### Verification and 0c limits

- 23 catalog checks, reconstruction, origin/distance/height, prediction, death, character creation, activities, menus, freezing, discovery and query without altering missions, Tarot or
  attributes.
- 42 checks during the six native routes and a review: key Use real, independent
  addresses, keys/quantities/reputation, unfilled needs, absence of automatic mass
  population, conserved actors and soil objects and walking up the real stairs.
- Eight new checks when loading the network save: current map, visits/directions,
  inventory, inactive MAP02, resources and snapshots, followed by native return journey
  without duplicating gates.
- Ten checks when updating a save created with original 0b sources: adoption of the hub,
  reconstruction of three accesses, Box/weapon identities, backpack location and original
  durability, card/assignment/unique reward/reputation, travel to MAP03 and return keeping
  an actor who was already in the 0b save. Fixture prepares that data in 0b; it does not
  substitute for a complete repetition of the prologue.
- The actual narrative output is also verified from its prepared requirements: native Use/confirmation, pending mark, original cleaning, Box/first weapon in the Box, card,
  arrival at MAP02 and coexistence of Voice with accesses.
- Native visual review of gate, reservoir, chambers, stairs and full Journal in
  Spanish/English. For the capture of the Journal layout the five visits and six tours are
  prepared in a private fixture.

Environment: GZDoom 4.14.2, Freedoom and llvmpipe/SDL on Linux. Test fixtures prepare
positions, some objects and states; they are not distributed. The 0c check by the author
on Windows remains pending. The ability of MAP03 for a particular population has yet to be
measured: no approved massive test is declared. MAP04 does not advance new Tarot and MAP05
activations do not yet apply hazards, environmental damage or deep immersion.

Delivery: delta over 4.34.0b, reproducible UDMF generator in assets/generators, English
README, five canonical documents and PRUEBAS_4_34_0c.txt out of docs. Modular architecture
here is map. The transverse refactor of the code remains in V5.0. 4.34 remains the caravan
bases and travel integration; its durations/events will be supported by the 4.35 clock.
Then continue 4.36, 4.37 and export test for other players before V5.

## Base accepted: 4.34.0b — doors and accesses by group

The author confirms "All right" for 4.34.0a and authorizes the following patch. World,
places visited, return registered and save compatibility are accepted. The decision
remains: finish V4 to 4.37, export a test for other players and then board in V5 all
inherited and cross-sectional.

0b continues the architecture bases with closed doors and access requirements. The review
finds three unwanted opening routes: a free door leaf could bypass another leaf's key or arena lock; moreover, all doors with zero id were treated as a group. The behavior with the
0a sources is checked before correcting it. Now they validate key, arena and reputation
condition of each door leaf before altering requests or timers. Only positive ids link door leaves;
without id each door works alone.

The closure checks the original opening and the character's radius/height, even when the
leaves are removed. It keeps the whole group open while the player occupies the pass and
reopens it if it enters during the closing. Loss of the key does not lock it in an already
open door; once closed, the next request requires the key again. Express arena lock retains its previous priority. Normal speeds, travel and waiting are preserved.

LOCKDEFS remains the key authority and does not consume them. Its silent query precedes
the message/sound limited by the existing timer. 200/201 locks and the new 202 use its
own locked door sound, without superimposing manual playback to native sound.

### Optional test accessible

In a clear area of MAP01 or MAP02, close dialogue/trade and use: `give
CaelumDebugDoorTrial`. Place a two-leaf door in front of the character; only one declares
the 202 lock. Use anyone without the key must reject both. `give CaelumDebugDoorKey`
delivers a single reusable native key, independent of the silver key. Use opens the group;
remaining in the middle keeps the step open and removing allows normal closure.

`give CaelumDebugDoorTrialOff` removes those door leaves and their key. Blockers are removed in
their next ticks. Repeat activation retains the same instances. The test does not deliver
the Argento key, modify reputation, activate missions or record new trips. It does not add
a campaign obstacle: its isolated presentation only appears upon request. The key is a Key
marker without weight or row of equipment. It can be saved and loaded with the test.

`netevent ca_debug_door_report` consults rating, separate keys, map, group, lock and
progress/waiting/occupancy of each door leaf. It does not open doors or create the test. World,
Integration and El Loco diagnostics continue to work and update its header to 4.34.0b.

### Evidence and limits

- Twenty native requirements checks, rejection without partial changes, zero/negative id,
  different groups, reusable key, social conditions, arena, prediction, unevenness,
  occupation on both axes and NPC requests.
- Seventeen native use checks: test commands, instances preservation, key Use on both door leaves, incorrect/correct key, collision on entry, stay beyond normal waiting, key
  loss, closing and reopening when entering during movement. Repeating them in English
  checks the texts and does not increase the number of different cases.
- Eight new checks when reloading a partially closed 0b door: references, configuration,
  position/progress, keys, check without effect, continuation, withdrawal of the test and
  absence of orphan blockers.
- Seven new checks when loading a save produced with original 0a sources and a partially
  open door: actors/configuration, movement, World, key/reputation, opening/closing and
  restored door-leaf protection. Serialized preparation check is not counted again.
- Placing the test from the existing start of MAP02 and preserving your visits/Tarot
  without inventing a return. Revised native screenshots in MAP01/MAP02; messages in English
  and Spanish.

Environment: GZDoom 4.14.2, Freedoom, llvmpipe and SDL keyboard on Linux. The test
prepares positions and an extra silver key only in private fixtures to verify that it does
not substitute for key 202 and that withdrawal does not delete it. It does not repeat the
entire campaign or establish co-op support. Automatic occupancy checks protect players;
the forced arena closure retains its previous contract. The author subsequently confirms
"All correct" for 0b and authorizes 0c.

Delta over 4.34.0a with README, five canonical documents and PRUEBAS_4_34_0b.txt. 52
original door actors from MAP01 already use positive groups; their numbers, positions and
maps do not change. Attributes, navigation, missions, narrative inventory or the
persistent World scheme are not modified. The next increase continues architecture,
modules and access between floors in 4.34; calendar, hazards, Tarot/Trucazo and export
retain their order.

## Base accepted: 4.34.0a — locations and connections

The author will complete the current V4 roadmap, then prepare a test export for other
players and move all the work inherited and transverse to V5 after that export. Authorizes
to continue with the next patch; this decision allows progress from the 0ao technical
closure. No additional confirmation of all 0ao tests is recorded.

4.34.0a starts the world catalog and replaces the TAB > World provisional screen by
current location, visited places, and known connections. It uses the existing names of
MAP01 and MAP02. The "Back to Body" connection is known when the narrative output is
ready; its destination remains "To be discovered" until it arrives. In MAP02 it is
"Roamed" and it is indicated that it is a one-way trip. The Journal reports; confirmation
remains at the threshold.

The record resides in the character's persistent Inventory, with stable ids, visits,
knowledge, route and a pending connection. After the validated commit the pending
output is recorded; only the corresponding arrival converts it to travel. Save, view the
Journal or consult the console does not travel or award rewards. The cleaning of the
Limbo, the Box, the first weapon, El Loco and quests/reputation contracts of 4.33 are
retained.

The above saves record the current place. A full MAP02 save with MAIN_M00, first preserved
weapon and documented final cleaning also recovers the visit to the mansion and the return
made. Entering MAP02 using "map map02" without those facts records only the sewers.
CADEV02 and unchecked maps do not acquire a campaign id. No reverse path is inferred.

Explicit query: `netevent ca_debug_world_report`. Read registry version, current map/id,
visits, known/traveled connection and pending state, without creating records or touching
missions, inventory or attributes. Previous diagnoses remain available and update their
header to 4.34.0a.

### 4.34.0a Verification

- Eighteen boot checks, ids and saves, query and native Journal navigation: valid
  character, character creation/death/prediction, unconfirmed output rejection, invalid pending id
  and left/right/Page Up/Page Down.
- Four specific checks of the route: previous save of MAP01, transition confirmed still without
  destination visited, pending departure before ChangeLevel and actual arrival with the
  two visits and the connection traveled. The scenario also reuses capture, cancellation,
  +2%, cleaning, trade, missions, rewards and native arrival verified in 0ao.
- Six checks when loading a native 0ao MAP02 save: world migration, Box/first
  weapon/Tarot, unique endings and certificate, preserved reputation and trade, without
  repeating the finished arrival dialog.
- Four checks of a new session initiated directly at MAP02: current location without
  inventing the mansion or its return; a pending attempt without evidence of departure
  does not get tour either.
- New registration is saved and reloaded in MAP01 and MAP02. Native fields persist;
  arrival autosave also contains visits and tour. Serialized preparation checks are not
  counted as new.
- World native render before return and after arrival; texts of the known connection
  reviewed in English and Spanish. The visual scene prepares only the knowledge of the
  connection to check that it hides the name of the destination.

Technical environment: GZDoom 4.14.2, Freedoom, SDL keyboard and llvmpipe on Linux. The
integration scenarios start from QA saves and prepare the record of first weapon; they do
not repeat all resident tests or all manufacturing. The author subsequently confirms "All
correct" and authorizes 4.34.0b. Engine, IWAD, saves, fixtures and private captures are not
part of the delta.

Delivery on 4.33.0ao: README, five canonical documents and PRUEBAS_4_34_0a.txt.
Maps, assets, attribute formulas and Inventory/Quests controls remain unchanged. There
are no new destinations or fast travel, prices/durations travel, calendar or campaign
content on this patch. The following increments of 4.34 will continue its architecture,
connections and travel bases; 4.35–4.37 and export continue on the lower roadmap.

## Technical base: 4.33.0ao — integration closure

The author confirms that all 0an tests were correct and authorizes the following patch,
first requesting the complete V4 roadmap. reputation/membership requirements,
dialogue, access, trade, save and test controls are accepted. 0ao verifies its coexistence
with missions, capture and narrative output, retaining approved rules.

`netevent ca_debug_integration_report` is added: query the existing records of the player
requesting it. Shows MAIN_M00, objectives and endings of the two assignments, registered
delivery and certificate presented separately, the four reputations/memberships, Box,
first weapon, Tarot, commercial conditions, enabled testing and status of departure/arrival.
Do not create or repair records, award rewards, change reputation or activate
demonstrations. The detailed report of El Loco remains available, with 4.33.0ao header.

### Active conversation when loading

The arrival-autosave reload reproduces a specific discrepancy: ConversationNPC and
bInConversation are still active, but there is no USDF menu. Voice is marked as initiated
and the reputation test waits for that invisible dialogue. The native StartConversation function
shows the dialogue of the same interlocutor again without choosing answers or granting rewards.

CaelumConversationResume is a StaticEventHandler registered in MAPINFO. It receives
WorldLoaded with IsSaveGame and defers reopening to the first WorldTick. It checks
alive/created character, active conversational interlocutor and ConversationPC equal to the
player. It uses the saved orientation and saveAngle=false; it does not call Used, reassign a tree, delete references or modify records. It does not run on a normal map entry or on inactive references. Its marker is static and does not add data to the save.
It also fixes the reloading of the autosave created before this fix.

### Joint verification and limits

A native save is created with the original 0an sources: Box received in the Palomo dialog,
a real purchase of five wood units for 14 copper coins, trade with active condition/discount,
reputations and different memberships, completed Tour certificate and active Wait with passed
time. Loading it with 0ao checks preservation and non-repetition of the transaction. Trade
with Q is closed and the revelation, cancellation and explicit capture of El Loco, its
unique animation and bonus is traversed with native keyboard.

The exit is confirmed by the existing door and dialogue. The transition and cleanup of the
Limbo precede the journey: Box, first weapon in it, card, social records and certificate are
preserved; the physical objects of test subject to that cleaning, including coins and
purchased wood, are removed. The trade is closed and its temporary reduction does not
become a negotiated discount. The reputation test cannot interrupt the Voice of arrival;
it is then reopened in MAP02. Wait retains its state until completion/reward collection, and
the endings/rewards remain unique. Removing the test retains the records.

The final MAP02 save is also reloaded: both assignments and the certificate, reputations,
Box/weapon/card, commercial stocks and withdrawal of the test are preserved. The already
closed dialogue does not reopen. The integration query leaves intact inventory, health,
clock and records examined.

39 integration checks pass: 17 new when you continue the 0an save in MAP01, 16 from
arrival/assignments and six final reload. The four saves preparation controls with 0an do not
add up again. The six repeated checks when you reopen different pages do not duplicate
either; the recovery of both saved pages is checked by the native menu.

The private scenes start after the resident tests and prepare the Tour objective and the
first weapon record to test contracts. They do not repeat the entire campaign or its
manufacture. The engine, IWAD, SDL inputs and QA saves are left out of the patch.
Environment: GZDoom 4.14.2, Freedoom and llvmpipe on Linux; the author's Windows
verification of 0ao remains pending. The evidence of previous blocks already approved is
preserved and is not counted as new evidence. The author then authorizes to continue with
4.34.0a.

Delta delivery on 0an with README, five canonical documents and PRUEBAS_4_33_0ao.txt.
Maps, assets, attribute formulas, serialized states, reputation conditions and mission
logic are preserved. The author authorizes to continue with 4.34.0a: locations and
connections.

## Base accepted: 4.33.0an — Reputation conditions

The author confirms that 0am works and validates the two optional assignments: completing them
delivers the certificates, abandoning Tour prevents accepting Wait, and traveling to MAP02 before completing the route objective causes failure. Corrections of capture, seals and navigation are
accepted. The current attributes and Journal boundary controls are preserved.

0an connects the existing registry with reusable conditions for opening dialogues, sliding
doors and trade. Each condition declares faction, minimum reputation and optional
membership. Membership does not replace the minimum. Doors validate the entire group
before moving it; transactions revalidate before exchanging coins or objects. Reputation
discount is temporary and separate from persistent negotiated discount.

### Accessible test and scope

Save before and run `give CaelumDebugReputationTrial`. The test opens immediately; then
TAB > Reputation > F/Y reopens it. It offers five selectable states and three real
services. Use Unitarians as technical id:

| Test service | Requirement |
| --- | --- |
| Information | Reputation >= 25 |
| Physical door | Member and reputation >= 25 |
| Trade | Reputation >= 0 and own Box |
| Trade discount | Reputation >= 25; existing margins 140%/60% |

The five states are 0 without membership, 25 without membership, 25 member, -25 member and 0
member. They modify the actual register of Unitarians; they retain the other factions.
The test uses inventory, coins and actual stocks, without delivering Box, resources or
rewards. Close trade with Q/B; Esc retains the engine pause menu. To remove the test,
close your menus and use `give CaelumDebugReputationTrialOff`: removes guide and door,
without reversing reputation. Loading the previous save restores the pre-test status.

The current six ids, -1000..1000 scale and existing relationships are preserved. The
seven ranks and future relationships are still pending
thresholds and author matrix. The values of this test do not set that design. Maps,
missions, campaign reputation gains, regional price formulas or attribute bonuses are not
added.

### Evidence and validation of 0an

Thirty-seven native checks cover invalid limits and ids, independent membership, correct
faction, rejection of actions outside the dialogue, conditions of groups of doors, real
purchases/sales, exchange rate and closure due to loss of access. The separation between
temporary and negotiated reduction, coins/stock conservation is verified when refusing
and absence of duplication or alteration of missions, Tarot and attributes.

Nineteen interface checks use keyboard SDL events: activation, re-opening with F, native
menu states, dialogue and door permission, prices and purchases with Enter, Q-closure,
Reputation controls and withdrawal of the test. Spanish and English texts are reviewed
with the native render; repeating the same cases by language does not add different cases.

A native save created by the original 0am sources retains when loading with 0an the four
reputations/memberships, Box, coins, attributes, water, completed mission, certificate and
successor offer. An already open trade retains its negotiated discount without receiving
new requirements or activating the test. Then it saves and reloads a session with 0an
conditions: its fields, discount and owner/guide references are preserved. Withdrawing the
required membership blocks the transaction without expense; the native journey to MAP02
retains the records and allows rebuilding the presentation of the test there.

Environment: GZDoom 4.14.2, Freedoom and llvmpipe on Linux; controlled scenarios, not a
complete repeat of the campaign or a save of the author. The author later confirms that
all 0an tests were correct. QA helpers, saves and engine are out of the delta.
Application and instructions in PRUEBAS_4_33_0an.txt.

Delivery on the complete 0am project with README and five canonical documents. Its acceptance enables final 0ao integration before starting locations/connections/travel
4.34 bases.

## Base accepted: 4.33.0am — inactive conversation and Journal boundaries

The capture of the 0al log shows 80 phase, a valid owned Box, requirements met and essence
accessible at 32,6 MU. There is no channeling or reloading. ConversationNPC retains an
actor, but its bInConversation is false. Capture rejected any reference, even if there was
no active dialogue.

0am checks the real activity of the interlocutor when opening the essence and waiting for closure before animating it. It applies the same rule to the door, to the exit transition
and to the Arrival Voice. It does not erase native references or repair progress: an owned Box and explicit capture choice are still required; opening or canceling the dialogue does not grant the card. It retains the unique delivery and existing bonus of El Loco.

Left/Right runs through the known filters and missions. From the first element,
Left passes to the previous tab; from the last, Right passes to the next tab. Inventory: Tarot/Character. Missions: Crafts/Reputation. With a single mission, both arrows go out to
their adjacent tab. Upon returning the selection is retained. Page Up/Page Down or LB/RB
changes tabs directly; Up/Down and F/Y maintain their other functions. Spanish and
English aids explain the ends in a second line.

### Evidence and validation of 0am

The log status is reproduced in a controlled manner: reference of an NPC whose dialogue is
already closed. In the original 0al sources, Use does not open the essence. With 0am, the
same native input opens El Loco and Enter completes the capture, also after exhausting
Quintessence. The Box is received by the actual Palomo dialog, without giving it
directly. The scenario starts after the four resident tests; it is not a complete
execution of the mission nor does it use an author's save.

Twenty-eight Journal checks go through keyboard SDL events and the native dispatcher:
filters, both ends, one and three missions, gaps for unknown entries, Detail, retained
selection, Page Up/Page Down and absence of automatic acceptance. Language repetitions do not
add up to different cases. Twelve Palomo/Box/depletion/capture section checks confirm the fix on the reproduced state, identity and unique delivery with +2%.

Seventeen additional checks pass when loading with 0am a native save created by 0al with
inactive reference, in the coordinates communicated: Box and preserved attributes, absence
of capture while loading, protection of an active interlocutor, Use, cancellation with Esc
and new confirmation. The animation ends even if another inactive reference to the essence
is retained. The door opens and the transition arrives at MAP02 even with an inactive reference
to the threshold; surviving card, Box and first weapon and opening the Arrival Voice. The
weapon and its registration are prepared only to verify the departure contract; this test
does not repeat the crafting. The save files are not modified.

The engine compiles the sources without errors and passes validate_project.py: five
documents, 74 audio files and 12 station models. The delta contains 12 new/modified files. Environment: GZDoom 4.14.2, Freedoom and llvmpipe on Linux. The author's check on
Windows remains pending. Test aids, engine and IWAD are not part of the patch.

Delta delivery on 0al with README, five canonical documents and PRUEBAS_4_33_0am.txt.
Maps, assets, attributes and infrastructure protection/restoration are preserved. Author
accepts these settings before 0an.

## Base 4.33.0ak — Observed capture; revised controls in 0al

The author reports trees and stations displaced by Quintessence, blocking by capturing
the essence and controls of the Journal that change filter/tab instead of the intended
destination. 0aj is not approved. The base of optional missions is retained and these
corrections are prioritized before reputation.

The seal selection accepted infrastructure because it is also SHOOTABLE. 0ak excludes
CaelumMovableProp from the seal area, including captured mass and ejection. MAP01 relocates
the same plants and stations once: origin of the garden and current layout of the rooms.
It does not recreate the nodes or their stocks; it retains its references, tasks and
reserves. It also cleans unwanted velocity and suspension of targets in saves.

The normal capture was reproduced successfully on the original 0aj sources. The reproduced lock
appears when channeling: PlayerThink discarded Use. A fresh Use press now stops the Channel,
applies its normal cooldown and arrives at native interaction on that same press. El
Loco retains its own Box requirement and confirmation of the single delivery dialog.

Journal: Left/Right changes mission in Missions; in Inventory changes tabs
directly. F/Y retains the inventory filter. Page Up/Page Down or LB/RB changes tabs in any
section. The arrows of an open station retain their recipes; leaving Crafts closes the
native session and pauses work at the station. Help text is updated in Spanish and English.

### 0ak Technical Validation

GZDoom 4.14.2 with Freedoom and llvmpipe on Linux. Isolated scenarios on patch sources;
engine auxiliaries and resources are not delivered.

- 78 Target Checks: Actual infrastructure of MAP01 excluded, trees and stationary stations
  with Air/Quintessence, restored gravity and attraction/mass/expulsion continuity for
  combat targets.
- 34 Journal checks: ten filters, circular navigation between missions, Detail and
  cancellation of abandonment, tab keys and native closing of a real station. The same
  path of key codes used by InputProcess and its native events is invoked; keyboard/controller
  physical pending.
- 19 when loading a game saved by original 0aj sources with active Quintessence and
  displaced plants/stations: position, identity, gravity, partial stock, fractional yield, attributes, choices, 1,25 liters, Box, completed mission and reward
  preserved. Use interrupts the Channel and opens El Loco; confirm grants one card and only its current +2%. Repeated capture or reward is rejected.

131 different checks pass without failure. The interface is reviewed in both languages,
without adding up the repetitions of the same controls. The author's save has not been
received: the compatibility uses a native save prepared to reproduce its symptoms. It does
not represent a complete game. Application and acceptance in Windows:
PRUEBAS_4_33_0ak.txt. Maps, art, audio, models and attribute formulas are preserved with
respect to 0aj. The project validator passes without errors: five documents, 74 audio
files, 12 station models and references. The delta contains 12 files: five runtime files,
README, five documents and one application/test TXT.

## Base 4.33.0aj — comments corrected by 0ak

0ai is approved by the author. All attributes are preserved, including Resilience for
Sleep and consumption/regeneration divisors of Constitution. The previous audit is recorded
for future review.

0aj implements the optional mission base: offer, requirement for another completed
mission, explicit acceptance, objectives with bounded progress, complete, fail and abandon with
confirmation. An end is not overwritten or restarted. The reward uses native Inventory and
a mission delivery record; failed receipt allows retry, and the object is not replenished.

The Journal selects between known missions and shows Detail of the chosen one. The
diagnostic chain is enabled with give CaelumDebugQuestTrial: Tour followed by Wait. It
is separated from narrative content: certificate without weight, price or attributes,
without altering the main mission, Tarot or T1 resources. SYSTEMS.md defines rules and
limits; PRUEBAS_4_33_0aj.txt explains the route.

After resolving the capture and accepting the controls, the next block connects reputation
with reusable conditions. The integration will then be reviewed before V4.34. Bullets and
water treatment are still pending definition for later enlargements. V4.35 calendar
precedes Rest; V5.0 retains the refactor programming.

### 0aj Technical Validation

119 passed checks, zero failures, in GZDoom 4.14.2 with Freedoom and llvmpipe on Linux. The
evidence of the recovered work is preserved and the flow and interface is re-run over the
final sources; repetitions of the same scenario are not added as additional checks.

- 70 of the life cycle: discovery without acceptance, chain requirement, invalid indexes
  and targets, limits of progress, explicit completion, failure, abandonment, permanent
  endings and unique native reward. Removing the certificate does not reopen reward collection;
  a rejected reception admits retry. MAIN_M00 retains its status and its setters refuse
  to alter an end.
- 13 of the Journal in Spanish and 13 in English: circular selection, detail of the chosen
  mission, blocked offer, native acceptance/abandonment events, cancellation of confirmation
  and update of the screen. List captures, details and revised endings. The scenarios
  invoke the navigation and network events of the engine; the physical keyboard/controller is
  verified in Windows.
- Eight when loading a game created with original 0ai sources: log and main stage, Journal
  snapshot expansion, attributes, 1,25 liters of canteen and seal/amulets choices
  preserved. New offers do not appear until the test is explicitly enabled.
- Eight when reloading a 0aj save with partial wait: time, target, previous reward and
  main mission preserved, continuation and unique delivery of the second assignment.
- Seven in a ChangeLevel real MAP01 -> MAP02: travel the certificate, collection record and
  active counter; complete and collect the reward at destination without duplicating the previous
  reward.

The scenarios prepare profiles and objectives to isolate each condition; they do not
represent a complete game, the narrative crossover of Limbo or a cooperative validation.
The limits of the health observation described in SYSTEMS.md are maintained. The author's
acceptance on Windows remains by PRUEBAS_4_33_0aj.txt.

The project validator passes: five documents, 74 audio files, 12 station models and
preserved references. The delta is checked against the 0ai base recovered and matched with
its saved ZIP. All three WAD, audio resources and attribute calculations retain their
bytes. Delivery: 15 new/modified files and an application/test TXT. ZIP CRC and exact reconstruction of its contents verified.

## Base 4.33.0ai — approved by the author

The author corrected his previous indication: Sleep belongs to Resilience. 0ai restores
that association by retaining the Type 4 divisor (1 at attribute 0; 3 at 100).
Constitution controls Hunger/Thirst and now also divides their cost during health/Air regeneration, without repeating the passive consumption mass factor. Speeds remain
unchanged. The <=10% critical threshold restored in 0ah and the approved 0ag pool, partial refill and sips are preserved.

The audit of the twelve attributes is in SYSTEMS.md: matching families, active effects,
scale/assignment differences and pending functions. The author table remains as design
intent; the audited matrix does not treat fields that are only calculated as completed features. Its
differences in this patch are not automatically implemented. Ronnie is updated in both
languages, README and five docs, without creating more canonical documents.

A previous game updates the factors without restarting reserves, choices or progress.
Delta delivery over 0ah plus a TXT test. After accepting 0ai, close the review of the
tutorial and continue world/travel fundamentals, without expanding maps. Remains the
discrepancies of attributes recorded below, unsafe water treatment and bullet composition/processing. Calendar precedes Rest; V5 maintains the refactor of programming
architecture.

### 0ai Technical Validation

95 native checks approved in GZDoom 4.14.2, Freedoom and llvmpipe in Linux: independence
of Constitution/Resilience/Patience, 0/50/100 curve, 50/100/200 masses, fractional
attributes and limits, real passive consumption and factor update. Actual quantities and
costs of both regenerations, maximum, insufficient reserve, absence of double mass and
critical rule for all three reserves to 1/10/10,1 points are checked.

Another eight passed checks load a save created with the original 0ah files and a normal
profile with Patience other than Resilience. They verify new factor and cost,
attributes/reserves/liters preservation and choices and absence of accumulated division.
Total: 103 native checks, without faults. The preparation of the save was also verified
with the original formula; the save file was not edited to simulate compatibility. The
documentation/resource validator ends without errors, with five canonical documents.
Delivery of ten files, without binary resources or test code. The author confirmed that
all 0ai tests were correct. The attributes remain as they are; the differences of his
audit are postponed.

### 0ah Technical Validation

96 checks passed in GZDoom 4.14.2, Freedoom and llvmpipe on Linux. 88 check the curve at
0/50/100 with independent Constitution and Patience, masses of 50/100/200, fractional
attributes and limits, one second of native consumption, refresh of old factors,
thresholds 0/1/2/9,9/10/10,1/50 for all three reserves, combined damage and regeneration
blocking. The pool, partial refill and approved 0ag sip also pass their regression checks.

A save was created with original 0ag code, 100 attributes and zero factors; another eight
checks load it with 0ah and verify positive consumption without restarting reserves,
attributes, liters or choices. The divisor does not accumulate. The documentary and
resource validator ended without errors. The attribution to Patience and regeneration
costs are now replaced by 0ai; these previous tests are historical evidence, not
acceptance by the author of 0ah.

### 0ag Technical Validation

161 passed native checks in GZDoom 4.14.2 with Freedoom and llvmpipe, Linux. The water block adds
153: the six models to 50/100/200 kg, volume per sip and remainder, ten real pulses for
ten seconds, MAP01 with/without container, partial refill and load/Box limits, damage at zero Thirst, regeneration to 1 and 2 points and previous Hunger/Sleep rules.

Eight other checks load a save created with 0af delivered code: liters, pending drink
effect, progress and choices/allowance of preserved silver; new mass-adjusted sip and real
refill/hydration in the pool. The test isolates the prologue so that its automatic dialogue does not pause time. The documentation and resource validator ended
without errors. The author approved all tests of 0ag; the positive-Thirst rule is reverted
in 0ah at the author's request.

### 0af Technical Validation

GZDoom 4.14.2 with Freedoom, rendered by software in Linux: they pass the combinations of
the five seal choices by four amulets, the six containers, formula by mass, Ronnie
delivery, limited silver, personal manufacturing and persistence. A save generated with
the original 0ae code was also loaded and their pending seal was finished before choosing
the accessories. Native menus were toured in English and Spanish. RGBA Sprites reviewed as
images; the author's subsequent tests approved these resources. The documentary and
resource validator ends without errors.

## Base 4.33.0ae — approved by the author

The author confirmed that all 0ae tests passed. 0ae's full base was recovered
from the author's attachments.

The author approved all 0ad tests. Caella offers to show the five T1 Seals and their
components after completing their test. Read or postpone does not change the character;
accept enables optional knowledge and quota for one of each item. Use existing recipes,
without changing Channel costs or effects.

The set at 100% in each layer requires 1,8 kg gross copper, 0,2 kg gross tin and 0,6
kg of each gem. The quota is added to the chosen equipment without restarting what has
already been issued. If there is an owned T1 Seal when learning, only the missing
ones are budgeted; the Caella loan does not count. That initial existence is recorded:
manufacturing or losing a piece after it does not replenish the quota.

Native recursive crafting from raw materials, personal result without Box, one equipment slot and Detail 0/5–5/5. Caella's Workbench and the complete workshop on the
second floor have the infrastructure. Ronnie can lend the sword again for the outstanding
seal materials, even with its mission and repair completed, and accepts the return for its
workshop talk.

It does not add mission requirements or change runes, exit narrative or what comes out of
Limbo. Maps and audiovisuals retain their bytes. It is applied on 0ad by copying files
plus PRUEBAS_4_33_0ae.txt. Validation at the end of this document. Next block of systems:
water collection/treatment; composition and bullet processing still need author
definition. Calendar/rest and V5 architecture retain their place on the roadmap.

## Base 4.33.0ad — approved by the author

The author approved all tests of 0ac. Ronnie asks which armor family is desired after
choosing weapon: magical, light, medium or heavy, with description and confirmation. It
teaches the four pieces T1 and components; who already chose weapon can access by his
conversation about workshops. It does not force repeat missions or add a requirement to
the Bull or to the exit.

The supply to the 25% is replaced by a finite quota to the 100% in each layer: one weapon
chosen, one set chosen and ten arrows/bolts when applicable, at the chosen size. Leather
M: 5/10/20/40 kg sets, plus 6 kg if the weapon is the giant gauntlets. Each source
discounts the same quota per character. The Bull retains its maximum physical yield,
but shares a quota with the drawer. Previous stacks also respect the limit when
collecting; the new ones do not generate surplus. Partial collection and the drawer leave a
gram free of capacity.

Previous inventories are not deleted when updating: they count toward the 100% together with
components and first weapon already made. The drawer accepts unreserved surplus. The
above tasks maintain efficiency, time and reserves. The optional repair practice enables
only the missing amount proportional to the observed damage; it does not replenish a complete
batch. You can order and return the gathering sword for that practice. Native manufacturing,
equipment and progression.

Apply to 0ac: new/modified and PRUEBAS_4_33_0ad.txt files, without applicators or
PK3. README and five updated documents. Next block: teaching T1 seals and their quotas;
bullets need composition/process and water needs collection/treatment rules. Deferred new
maps; V5 maintains refactor.

## Base 4.33.0ac — approved by the author

The author approved all tests of 0ab. Bolt crafting is incorporated: Ronnie teaches the
recipe and dependencies when choosing crossbow. It also incorporates the knowledge of
saves with that choice, inside and outside MAP01. It does not give ammunition, materials
or another loan, and does not change the first weapon chosen.

Recipe 130, appended to the previous 130 recipes. Ten native 50 g bolts per batch; adopts the same
T1 structure of arrows: 70% shaft and 30% bronze tip. Waste and time of each layer are
calculated by the current rules, without other materials. Ronnie Workbench or second
floor, Ammunition filter. Personal output without mandatory Box, reservations and native
tasks. Guide in the Ronnie workshop section and in Detail for who chose crossbow.

Apply to 0ab with src, docs and README.md. Only new/modified files plus
PRUEBAS_4_33_0ac.txt. Maps and audiovisual resources are preserved. Next coverage:
acquisition of recipes from armor/Seals T1. Bullets need to define composition and
processing before defining their recipe; a complete recipe is not inferred from their current 3 g mass. Water requires collection/treatment rules. Calendar/rest mechanics and
architecture remain at its milestones.

## Base 4.33.0ab — approved by the author

The author approved all tests of 0aa. The following pending section of Ronnie is
implemented: breathing in the existing pool, behind the mansion to the east. Read the
proposal does not start; accepting enables an optional practice. Submerging the head for one second near the steps records actual Air expenditure. Raising the head again and completing the native three-second Air recovery after immersion records recovery. Detail and Ronnie recognize each phase.

Registration persists during immersion, recovery and after completion. Wet without
covering the head, swim before accepting or filling Air by debug do not replace events.
There is no requirement to cross the pool or return to Ronnie. It does not modify
resources, costs, geometry, Rulo requirements or output. MAP01 continues as testing
environment; new maps remain deferred.

Apply to 0aa by combining folders. Only new/modified and PRUEBAS_4_33_0ab.txt files.
Validation evidence below.

## Base 4.33.0aa — approved by the author

Minors add only base attributes by suit/rank before the collection percentage. A complete
suit gives +3 to its three attributes. Swords: mental; Cups: social; Wands: physical; Coins: technical. 78-index record retains property; Journal separates passive and
collection. El Loco remains the only card obtainable in the current content; no other
missions are advanced.

Zoom adds 360° sweep to greatsword, war axe and halberd at triple the primary Air cost, preserving
damage, reach and recovery. One hit per enemy, with respected geometry and allies; gauntlets retain blocking. General damage received and Anima cost are divided by the Type 4 factor from Toughness/Eloquence; at 100, the divisor is 3. Collisions, Pain and Lucidity retain the above rules.
Old statistics are reconstructed when loading without duplicating bonuses/progress.

Apply over 0z by combining folders. Deliver only modified files plus PRUEBAS_4_33_0aa.txt;
the validator now accepts multiple letter suffixes.

## 4.33.0z base — included in approved 0aa base

0y-based approved: The author confirmed that all tests were correct and that the
reported disagreement was an interpretation error. No mission state repair is applied and
no attribute mode at 100 is changed.

Ronnie Stage D: Load. Dialogue with real weight, capacity and Air factor. Optional
practice: lighten by releasing a surplus or save it in the Box if it reduces the weight.
Excludes the first weapon. It does not deliver objects, impose overload, alter costs or
add a lock. It uses the same inventory interface; loans and reserves maintain its
rules. Saves and travel preserve the result. MAP01 remains the system testing environment.

Apply src, docs and README.md to 0y, combining folders, and reconstructing with
run_dev.bat. PRUEBAS_4_33_0z.txt contains only new checks.

## Base 4.33.0y — approved by the author


Base: 0x complete, all tests approved by the author. Continues the C section of the
survival tutorial: Air and motion. Map construction and sewer expansion are still delayed;
MAP01 is the testing environment.

Ronnie offers the practice after returning the sword. Acceptance records a target equivalent to
the 1% of the current maximum Air, without modifying resources. The native expenditure
when running and moving accumulates the first part. The subsequent natural recovery
accumulates the second part. It does not require exhaustion, a concrete route, return with
Ronnie or complete to follow the mission. The partial state and results are preserved in
the Persistent Inventory. Detail shows what is missing. Drinks, attacks, jumps, immersion
and debug restorations do not replace the two points observed. It does not change
costs, rhythms or resources of the world.

Apply src, docs, and README.md to 0x, combining folders, and rebuilding with run_dev.bat.
PRUEBAS_4_33_0y.txt contains new tests.

## Base 4.33.0x — approved by the author


Base: 0w complete, including the cumulative from 0u. The author downloaded and approved
ALL these changes. The previous delivery rectification is resolved. Confirmed priority:
systems and roadmap mechanics, using MAP01 for testing. Build maps and expand sewers is
deferred.

Ronnie teaches food/water after the player returns his sword. The proposal requires
confirmation; only then lowers reserves above 90% to that level once and delivers a portion of each
type. Record native uses under the 100%, without requiring return or adding blockages.
Detail shows food and water separately. If you cannot deliver due to carrying capacity, try only the
pending ration when ordering it. Native consumables refresh respects ten seconds without stacking, even just before the effect expires. Maps, art and audio do not change.

Apply src, docs and README.md to 0w, combining folders, and reconstructing with
run_dev.bat. PRUEBAS_4_33_0x.txt contains only new checks.

## Base 4.33.0w — approved by the author


**Historical base of the cumulative 0w:** complete 0u folder. The 0w version was approved
by the author. The cumulative included 0v and 0w; the author subsequently approved both.
0w expands the tutorial with an optional Ronnie repair practice, available after returning
its sword. It does not require repeating branches or adding a lock to the implemented
closure. The actual first weapon is used, by its ItemId.

Ronnie explains how to inspect the wear, selecting/unequipping the part, use the Workbench on the second floor and press F on Crafts. Native repair retains costs, materials,
efficiencies, times and reserves. Practice is recorded only when actually restoring that
part; talking does not fix it, does not artificially damage it and does not credit a started/canceled/paused task. Detail shows the optional status. Saving and traveling
retain its result. If you leave the mansion without making it, no impossible pending objective is shown.

The T1 material inventory was audited using the current catalog in GZDoom. Leather is the
bottleneck, not the presence of the five gems. Quantities and limits are in SYSTEMS.md.
Neither the Bull loot nor the drawer authorized for the gauntlets is increased; no new
recipes are granted. Armor/Seal recipe distribution was still missing at that milestone.
0ad resolves armor choice and 0ae adds Seal teaching/allowances.

The three WADs, sounds, models and textures maintain their 0v hashes. Those who have
already left can continue in MAP02; to test this expansion a pre-crossing save is used. An
artificial return to the mansion is not opened.

### 4.33.0v changes included and approved by the author: exit and return to body

**Base:** complete 0u folder, with all tests approved by the author. The sword without
ghost shield, the contextual defense of Rulo and the previous blocks are preserved. 0v
implements MAP01 closure: phases 90 -> 95 -> 100.

After capturing El Loco, the exit responds at the back of the Bull room, on the ground
floor. Missions > Detail (F), Palomo, Ronnie and Rulo guide towards it. Only the Box
carrier, with card and completed tests, can activate it. The notice lists what is
preserved and allows to say "No. Not yet" unchanged. An outstanding manufacture requires
completion or cancellation personally.

Confirm starts a short saveable transition. At the end, the first weapon is saved by its
ItemId within the same Box; it retains type, size, essence and condition. The other
physical objects, including those stored, are removed. Tarot, recipes, character and
current resources are maintained; when removing equipment only the applicable maximums are enforced. The catalog of additional equipment by class and special values on awakening are
still undefined: no additional pieces or a free cure are granted.

The mission is completed before the native trip. MAP02 presents a short arrival to the
sewers, with a dry platform, central channel, footbridges and the Voice that warns the
protagonist. Inventory allows to recover and equip the weapon. It does not yet include the
complete route, encounters or exit of sewers. MAP01 does not have a normal return path
since this arrival.

The above test field is conserved as CADEV02, with the same TEXTMAP and its 16.508 things.
Its diagnostic filters now use that name. MAP01.wad remains identical to 0u: the
controller removes the provisional Exit and presents the door when starting or loading.
This avoids invalidating the saves by changing the map checksum. V5 programming
architecture is not reorganized.

The Tarot collection retains the +2% fractional El Loco bonus, on the twelve attributes and
without accumulation when loading. Recipes and objects still have a unique authoritative
source; neither the Box nor the weapon is duplicated when retrying. The current crossing is single-player: other players present are informed and the global transfer is not
initiated. The cooperative exit is left on the roadmap.

The approved 0n base includes:

- The 38 stations retain their instances: corners in bedrooms and a row of twelve against
  the wall of the bottom of the second floor. Doors and stations reject activations from
  another level or without a line of vision.
- Tab closes Crafts, also during a task; G filters. Close pauses the task.
- Bow and long bow teach ten arrows per lot and its components, using native crafting and
  inventory. They do not consume the place of the first weapon.
- Five veins of gemstones at the bottom of the cave. The drawer retains only T1 leather.
  The historical supply of 96 kg M for gauntlets to 25% is replaced in 0ad by the quota of
  the chosen equipment at 100%.
- Bull placed behind the silver door and Argento as guardian of the key. Delivery requires
  preparations with all four: Rulo practices precede the Bull. The leather budget for 0n
  recipes is replaced by the mass-based yield of 0q.
- Palomo runs visibly through fifteen waypoints, opens the necessary free doors and climbs up
  both stairs to the second floor room. It does not teleport or disappear; it continues
  from its current point when loading.
- Neutral shared display on the marked wall and updated resource dialogues. Caella 0m staff return is retained.

Repair, food/water, Air/movement, load and pool breathing are implemented as
optional practices. Bolts and their knowledge are approved in 0ac. Choice of armor and
quotas to 100% approved in 0ad. 0ae adds Seal recipes/allowances. Composition and
recipe of bullets and water collection/treatment remain; they do not block accepted
branches.

The MAP01 WAD, audio, models, garden and accepted poses are preserved. Stations continue
to offer T2 infrastructure; that scope does not require supplying T2. Format:
new/modified files to copy, plus a TXT test. The accepted 0h migration is preserved;
V5 will rearrange the programming code.

## Permanent premises

1. Code, identifiers, README, and all documentation in English. Explanatory
   comments inside code remain in Spanish, so the author and Spanish-speaking
   collaborators understand the intent of each block. Modified tooling uses
   English comments, docstrings, help and diagnostics.
2. Prefer stable native GZDoom 4.14.2 functions. Keep a single authoritative
   source for data and a shared architecture between weapons and actors.
3. The final product must be independent: do not distribute Doom assets.
   Preserve provenance, attribution, and modifications for owned or external
   resources. Development dependencies do not equal authorization to distribute.
4. Do not invent balance values, recipes, story, or pending decisions. The
   author's design and later corrections set those data.
5. Protect what is already accepted and validate only what a revision affects.
   Distinguish static analysis, an isolated engine test, and author acceptance.
6. GitHub is the primary working source: one issue defines one patch, implemented
   on a focused branch and delivered through a linked PR. Several focused commits
   may implement that issue. ZIPs are optional exports, not the source of truth.
   Do not distribute development IWADs, executables or test fixtures.
7. **Consolidated documentation updated in every patch.** `README.md` is the
   general entry point and is reviewed with each delivery. Keep these five
   `docs/` files; integrate new topics into their chapters before creating
   another file. A new permanent document is justified only if the author
   requires it.
8. Every delivery updates version, real status, decisions, next steps, and test
   results in the same change. Use numeric MAJOR.MINOR.PATCH releases, with an
   optional lowercase letter suffix where the author specifies one:
   4.36.0i -> 4.36.1 -> 4.36.1b -> 4.36.2 -> 4.36.3. Intermediate commits and later
   acceptance of the same patch do not increment its version. Keep historical
   labels unchanged. The larger-version roadmap remains in force. Do not duplicate
   state between a per-patch README and thematic reports. Keep temporary export
   instructions out of current installation guidance; preserve older ones in history.
9. Preserve history and unique content. Before retiring a document, integrate
   its current information and preserve the original. Do not silently delete
   local files or keep obsolete requirements as current instructions.
10. **Folders with a clear responsibility.** Before removing files, check
    consumers and provenance. Keep useful sources in assets, package only src,
    and back up known retirements. Keep outstanding author tests in the single
    root `pending_test.txt`, with confirmed results in `docs/HISTORY.md`.
    V5.0 reorganizes code through small changes
    with save compatibility.
11. Every change must be traceable to an issue or task.
12. No agent deletes files without explicit authorization.
13. Generators must be deterministic (same input, same byte-for-byte output).
14. One model per task. Routine tasks → economical model (DeepSeek).
    Architecture, narrative, or complex review → advanced model
    (ChatGPT Pro). Document in AGENTS.md which model is expected for each
    task type.
15. Saves always migratable. No change may invalidate an existing save
    without explicit, tested, and reversible migration. Schema changes
    carry a revision number and idempotent migration logic.
16. Data outside logic. Balance values, recipes, coordinates, names, and
    texts live in data or documents, never hardcoded in logic. If an agent
    needs a number that is not in the documents, it must ask, not invent it.
17. One change, one reason. Each commit or PR addresses a single purpose.
    Visual changes, balance changes, and code changes are not mixed, so
    that only what failed can be reverted.
18. Cross-verification between AIs. When possible, one AI reviews another's
    work. DeepSeek reviews ChatGPT's code; ChatGPT reviews DeepSeek's
    design. Reduces errors without the author having to review every line.
19. Documentation is the contract. If code and documentation differ, the
    documentation prevails until updated. An agent that finds a discrepancy
    must report it, not silently "fix" the code to match.
20. Issues are the unit of work. Every significant change (code, balance,
    document, map) originates in an issue describing the problem or
    objective, reference documents, explicit scope, and acceptance criteria.
    A PR without a linked issue is not reviewed.

## Document map

| File | Responsibility |
| --- | --- |
| [README.md](../README.md) | English entry, installation and summary status. |
| [PROJECT.md](PROJECT.md) | Premises, status, plan and current validation. |
| [SYSTEMS.md](SYSTEMS.md) | Rules, controls, crafting, economy, Box and dialogues. |
| [MAP01.txt](MAP01.txt) | History and full specification, preceded by the scope implemented. |
| [ASSETS.md](ASSETS.md) | Audio, art, first person and attribution references. |
| [HISTORY.md](HISTORY.md) | Registration of previous decisions and documents. |

The `src/licenses/` redistributive notices remain next to the assets. They are not
administrative duplicates and the reorganization does not eliminate them.


## Immediate Roadmap: Close systems and tests on MAP01

Each block ends with focused testing and acceptance by the author before expanding the
next one. The numbering of intermediate corrections depends on what these tests yield;
they are not delivery times.

| Order | Block | Remaining scope / closure criterion |
| --- | --- | --- |
| 0 | Base to 4.33.0n | All tests approved by the author the 2026-09-11. 0h migration is preserved. |
| 1 | 4.33.0o: removal of the external manual | Delivered; author asked to continue with Rulo. Keep cleaning and recipes learned. |
| 2 | 4.33.0p–0r: Rulo/Bull | 0q remaining tests approved. 0r corrects post-combat dialogue and protects residents; expresses leadership and innate strength. All 0r tests approved by the author. |
| 3 | 4.33.0s: Palomo final, phase 80 | Final Dialogue and Single Box. All tests approved by the author. |
| 4 | 4.33.0t: El Loco in the cave, phase 90 | Capture, collection and fractional +2% implemented; remaining tests approved by the author. Your two observations are corrected in 0u. |
| 5 | 4.33.0u: real shield and Rulo guide | All evidence approved by the author. |
| 6 | **4.33.0v: exit and return to body, phase 100** | Implemented: confirmation, weapon by ItemId in the Box, final cleaning and narrative arrival. Approved by the author as part of the cumulative 0w. Current retained resources; additional equipment and special values require further definition. |
| 7 | **4.33.0w: optional maintenance and audit T1** | Real repair of the first weapon with Ronnie, saveable and without a new mission lock. Materials audited; quantities in SYSTEMS.md. Approved by the author. |
| 8 | Remaining Extensions of the Tutorial | Food/water, Air/movement and 0aa load, 0ab breathing and 0ac bolts approved. Choice/recipes armor and quotas 100% 0ad approved. Teaching/allowances 0ae seals approved by the author. 0af incorporates containers and drinking collection; the rest was approved and 0ag tests also. 0ai restores Resilience for Sleep and applies Constitution to the expense of regenerating health/Air, preserving the divisors and critical thresholds of 0ah; all 0ai tests approved. composition/process bullets and non-potable water treatment remain. It is not promised to manufacture all sets nor to do so to 25%. Do not block accepted branches. |
| 8a | Authorized balance 0aa | Minor Arcana passives, sweeping heavy weapons and 4 type dividers approved by the author. |
| 8b | Audit of attributes 0ai — postponed by author | Maintain the current attributes. For a future review, specify reload/cooldown by Eloquence (munition today with Dexterity; 60 s fixed channel) and jump scale; complete duration of states by Constitution, debuffs/buffs scope, Empathy cures, overall mitigation of needs by Patience, academic tasks and hidden senses of Insight. Include Box by Intelligence and cost of Anima by Eloquence in the current table. The actual status in SYSTEMS.md is documented; these pending effects do not block 0aj nor the passage to V4.34. |
| 8c | 4.33.0aj: optional mission base | Offers, requirement between assignments, acceptance, limited progress, permanent endings and unique native reward per mission. Two expressly activated diagnostic orders, selection/Detail and abandonment confirmed in Journal. Approved by the author: delivery of rewards, lock after abandonment and failure to leave before goal. |
| 8d | 4.33.0ak–0am: seal corrections, capture and Journal | Infrastructure protected/restored. The 0al log identifies the inactive conversation reference; 0am corrects its lock and tab changes at the boundaries. Page Up/Page Down preserved. Approved by the author in 0am. |
| 8d.1 | 4.33.0an: reputation and conditions | Reusable dialogue, access and trade conditions implemented, with optional test accessible from Reputation. All tests approved by the author. Relationships, ranges and narrative assignments remain uninvented. |
| 8e | 4.33.0ao: integration closure | Combined save 0an, capture and exit narrative to tested MAP02; resumption of active conversations when loading, explicit report and updated roadmap. Author authorizes to continue with 4.34.0a. Bullets, water treatment and other legacy pending work pass to V5; no further repetition of all 0ao tests is presupposed. |
| 8f | 4.34.0a: locations and connections | Journal of the world, places visited and registration of the existing return MAP01 → MAP02; previous saves and preservation when traveling. First patch of 4.34, approved by the author. |
| 8g | 4.34.0b: doors and accesses by group | Native requirements of all door leaves, independent groups without id, passage occupancy and reopening during closing. Optional test with own key and previous saves. Approved by the author. |
| 8h | 4.34.0c: Sewers connected | MAP02 links with MAP03–05 for future massive testing, Tarot and environment. Six directions, native hub, stairs, Journal and saves; no return to MAP01. |
| 9 | Map construction and sewers | The 2026-09-23 author update requires a complete three-map V4 playtest slice (#10–#21); remaining campaign expansion stays in V5. Existing port/coast and sewer test spaces are reusable foundations, not completed campaign maps. Preserve map IDs and implement the confirmed mansion/maze/port route, including the port siege. |

The author-only truth and future revelations must not leak into the opening NPCs' knowledge.
MAP01.txt contains the full specification and corrections that prevail over its first
version.

## General roadmap by version

This is the sequence already planned, reconciled with what has been implemented. The original records are still complete in HISTORY.md. “Basis implemented” does not mean that
all the content of that system are finished.

Author decision of 2026-09-13: complete the numbered V4 roadmap through 4.37; then prepare
and export a test version for other players; begin V5 only after that export. All
inherited and cross-system pending work explicitly moves to V5, except for the
three-map playtest slice explicitly authorized above on 2026-09-23. No 4.38 block is added,
and completing the entire campaign is not required to export the playtest.

The current authorization allows to continue from the 4.33.0ao technical closure to
4.34.0a; it is not recorded as a new claim that the author has repeated all 0ao tests.
Each patch keeps its checks focused. The bases included in 4.34–4.37 retain its scope: its
content extensions and the pending previous versions are returned to V5.

| Milestone | Status and work to be done |
| --- | --- |
| V4.27: combat controls | Implemented native routes: Fire/AltFire, Context Reload, Zoom Block/ADS/sweep and User1–4. Pending matrix per family transferred to V5; keep what is accepted. |
| V4.28: Seals Channel | Current effects independent of weather accepted in 0bp. Climate-dependent extensions pass to V5; do not reopen closed effects. |
| V4.29–V4.31: crafting and equipment cycle | Basis of recipes, reserves, lots, independent efficiencies, repair and disassembly accepted. Narrative distribution of knowledge, rewards/sheets/shops/discoveries and efficiency bonuses without authorized values pass to V5. |
| V4.31: resources, loot and containers | Physical sources and caches are based; in V5, complete loot tables by plant/animal/monster, contents/capacity/ownership/theft/replenishment containers and systematic acquisition of materials. Persistent expansion of biomes goes in V5. |
| V4.32: NPC, trade and first person | Use/USDF, transactions, coins and Box accepted. Later canonical merchant, store content and first person of the other weapons with own art pass to V5. |
| V4.33: missions, reputation and factions | MAP01, assignment base and reusable conditions approved up to 0an. 0ao checks the final integration and recovers the menu from active conversations when loading. Broad narrative chains and rewards, composite conditions, ranges and concrete relationships pass to V5; the six canonical ids define the narrative factions, while ranks and relationships remain pending. |
| V4.34: world architecture and travel | 0a–0c approved: catalog, Journal, return, group doors and connected sewers. 0d implements caravans and shared registry; 0e adds test stations and supplies. The author now approves all 0e tests, including seals/crafting blocking and recovery of Use. MAP01 does not support return. Timetables, durations and events are integrated with the 4.35 clock. Code refactor is still in V5.0. |
| V4.35: calendar, weather and events | 0a–0g approved: clock/calendar, Limbo, rest, furniture/camera, sleeping bag and comfort. 0g implements safe acceleration, tables/seated meals and sleep Lucidity. 0h adds digestion, repeated servings and MAP01 furniture/workshops; native tests performed. 0i–0j correct access/Use, adjust stations/meals and establish Limbo 1:1; 0j and 0k approved by the author. 0l corrects chairs/water and adds regional SMN weather and geometric shelter. 0m scales food by mass, confirms Buenos Aires and adds author-approved port/coast test maps. 0n adds measured travel with provisions; 0o integrates the monthly agenda and persistent author-defined events. 0n/0o approved except for observations resolved in 0p, which adds reservations, Q and coastal vehicles. 0p and 0q approved; visual pack v4 and 1/3 eating rate accepted. 4.35 closed. Body thermal model in V5.1. |
| V4.36: mobile environment and physical hazards | The 0i weight formula, maze, tables, saves and bow art are accepted; #8 is corrected and author-accepted; #9 retains the flail correction. Author-requested #10–#15 add the T1 four-section sewer, rats, prisoner escorts/port rewards and Tarot artwork; #18–#21 supply siege assets, breakable actor gates, rams and catapults. Rams/catapults remain pending. Per the author's #8 clarification, the existing ceiling/elevator cover moving sectors; avalanches are deferred until additional maps and damaging surfaces until temperature effects, so those three are not release blockers. Validate integration/save/reset before extracting Impact Physics; neither assets nor a closed issue substitutes for acceptance. |
| V4.37: Tarot and Trucazo | Collection initiated in 0t and passive base of the Minor 56 implemented in 0aa; activation of owned/selected cards with User3 and costs/cooldowns; then card content and Trucazo minigame on stable inventory/NPC/events. |
| **V4 test export** | After 4.37 and before V5: complete and accept three campaign maps covering the prologue, the approved first Major and two distinct Minors (#16), including the sewer/rescue/art batch; then freeze an identifiable build and verify installation, controls, route, saves and issue reporting from the exported package (#17). Other V5 content is not required; this is not final standalone distribution. |
| **V5.0: modular code architecture** | First block of V5, after closing V4 and exporting the trial version. Separate responsibilities, reduce CaelumPlayer to coordination and migrate with small adapters. One implementation of inventory/player/Tarot; cross-player authority. Preserve saves, inputs and selectors. |
| V5.1: thermal exposure | Model of heat/cold based on climate, zones, activity, persistent humidity, wind and real equipment; Resilience, consumables, shelters, drying, rest and acclimatization. Numerical curves await the author's balance decisions. |
| V5.x: marine resources and biomes | Persistent 3D sources, melee extraction slashing/piercing, toughness/rarity/depth/region/skill, exhaustion and regeneration. Marine biomes, algae/iodine and non-potable waters; stores maintain access to remote materials. |

### Inherited and cross-cutting work: V5, after export

Except for the narrowly authorized three-map playtest slice above, commitments
in this table remain assigned to V5 by decision of the author. They also pass
to V5 the pending combat matrix, learning and recipe bonuses,
loot/containers/ownership, merchant and later stores, remaining first person,
quests/factions enlargement, postponing attributes audit, bullet composition and
water treatment. Their dependencies will determine the internal order; they do not invent
patch numbers or values not yet defined.

When an area shares name with 4.34–4.37, V4 completes its intended base and V5 develops
the following broad scope. The code architecture is reorganized into V5.0; the thermal
exposure maintains V5.1. The exported test is an earlier milestone, other than completing
the independent distribution.

| Area (V5) | Planned scope and current boundaries |
| --- | --- |
| Campaign and World | Target: 78 cards (22 Major and 56 Minor Arcana) and at least 78 maps; geography inspired by Argentina, coasts/Antarctica/deep sea, aerial cities and supernatural regions. Chapters, encounters, political outcomes and revelations follow canon. The first release remains focused on MAP01. |
| Quests | Main/side, requirements, objectives, chains/dependencies, failure and abandonment; item/money/reputation/unlock rewards The record has 32 slots and eight objectives per mission; 0aj adds offer and abandonment to the four original states, with unique requirements and rewards. The broad content, composite conditions and other types of rewards require development. Majors for main quests, Minors for side quests; assignments/events/rumors/contracts are not automatically another card. Do not introduce combat XP: Canonic progression depends on the Tarot. |
| Factions and secrecy | Unitarians, Federals, Free Peoples, Caelith, Cult of the Tarot and Sun Warriors. Seven ranks of reputation, changing relationships and consequences in prices, access, missions, hostility and sieges; membership/secrecy of Cult as future content. |
| Social dialogue | Reputation applied to rolls and thresholds, private emotions, combat/events interruption and conversations with multiple NPCs in sequence. MAP01 only uses the approved values for your tutorial; do not assign new factions or difficulties by default. |
| Travel | Carriage, ship, archaic submarine, aircraft, magic ship and portals; encounters, attacks, storms and mechanical failures. Global time, locations, routes and permanent changes of the world are dependencies. |
| Survival and rest | Action Rest with food/drink and time advance; camps/properties/shelters, recovery and quality of rest. Integrate thermal exposure; oxygen limits, height, water and future breathing capabilities according to cards. |
| Water and simulation off-map | Extend potability markers to marine/contaminated waters; network of volumes to different levels is technical capacity not yet built. Define resources/weather/events compensation when returning to unloaded maps by global calendar. |
| Perception and stealth | PerceptionCore, visual/acoustic sensors, stealth, detection/loss/reacquisition/memory and shared communication. The diagnosis of groups/perception is not the final AI; solve fields of vision, angular formulas, states/times, action/surface/cadence noise and stealth drift before assigning values. |
| Groups and companions | Playable formations, dynamic belonging, movement leaders, local offsets, distance sleep and shared memory. NPC fill-ins for incomplete party: accompanying/fighting without deciding dialogues. The diagnostic group baseline of 16 does not impose fixed size on visual formations. |
| Massive AI and performance | Maintain perception/targets step budget and space filters; resolve shared locomotion, contacts and step-by-step 1.875 testing → 3.750 → 7.500 → 15.000 active according to the latest approved gate. Load 15.000 passive actors does not test 15.000 fully active AIs. |
| Sieges | Director of battle, reinforcements, tactics, commanders, allies, machines/artillery/barricades, sabotage and alternative routes; time limit and permanent consequences on cities, routes and factions. It depends on AI, physics, world and stable calendar. |
| Physics | Complete multiple impacts/contacts validation, sustained thrust, crushing and anatomy/armor. Future melee impact physics requires speed, effective mass, area/edge, defined material, penetration and technique; do not replace accepted combat without that design. |
| Abilities | Racial User1 and class User4 effects were defined on 2026-09-14 and recorded in SYSTEMS.md; Arcanist Sleep implemented in 0g, the rest pending. The Pilgrim uses Amparo (50% less environmental damage), not Bless Food. User2 retains Seals; User3 retains Tarot. Do not invent powers or values to fill existing hooks. |
| Tarot | Persistent collection and global percentage initiated with El Loco in 0t; passive base by suit/rank of all Minors in 0aa. Selection, activation and awakening remain pending of essence weapons; cards with exploration, breathing and Box effects according to design. Complete the 78, its missions and persistence; do not confuse a hook with finished powers. |
| Trucazo | Truco with Tarot: Major modifiers, playable Minors/rows, Envido/Truco/Retruco/Vale 4, damage and health, Magic Senses, bets and consequences; casual/ranked and teams from 1v1 to 4v4. Implement layered after Tarot base rules and multiplayer authority. |
| Cooperative and PvP | Target 2–8 players, host authority, ownership/validation/synchronization, shared missions and world, travel, connection/disconnection and peers. Current individual persistence does not credit these modes. |
| Saving |  Keep native save and traveling Inventory. Independent external profile, narrative autosaves and world-shared state remain pending; test compatibility before removing V5 adapters. |
| Art, audio and interface | Remaining first-person views, visual content of maps, effects/emitters by region/hour/weather and adaptation of stock assets to scenes. Store accepted typography, icons and rigs; update inventory and credits with each resource. |
| Independent distribution | Replace any final art/audio/fonts/maps dependency from Doom, complete attributions and own packaging, validate startup/saves/maps and game modes. The IWAD development does not enter patches. |

### Decisions that still require author design

Complete balance of cards, racial/class abilities, economy and resources; tables/rules
harvesting and loot; container content and ownership; definitive sources of
recipes/components; final sensors and stealth; regional climate, encounters and
consequences of factions; thermal and melee-physics values. Historical documents
contain proposals: they are checked before implementation. The progress already accepted
is not reopened.

## 4.33.0h Folder Audit

Baseline: full ZIP provided by the author, 16.626 entries. CRC, routes, inventory and
consumers were verified. Cleaning uses an explicit list with SHA-256 per file; “does not
appear as text” is not enough to remove a sprite, source, model or resource that the engine resolves by convention.

| Folder / entry | Baseline files | Decision and resource rationale |
| --- | ---: | --- |
| Root | 4 | Updated README; build_dev.ps1 becomes the only Windows builder; run_dev points to it; the project configuration is retained. validate_project.py moves here. |
| docs | 5 | Keep the five canonical documents, integrate roadmap/audit and correct the actual status of 0g. |
| tools | 74 | Remove the active folder: keep builder/validator in root and three generators in assets. The other 69 files are utilities for previous revisions or redundant builders, preserved in backup. |
| art_source | 20 | Transfer all originals and records to assets/source/art with the same fingerprints. |
| assets | 13 | Store 05 source and package atlas with README/checksums; add source art and generators. Do not pack in runtime. |
| src | 4.276 | Maintain useful resources and modules; only audio and credit corrections are applied, plus the tab observer. Code architecture is reorganized into V5. |
| build | 1 | Regenerable PK3: rebuild it when applying. Preserved until atomic replacement is completed; do not accumulate 77 MB copies as source files. |
| archive | 1 | Keep 0g back-up and add a single verified backup prior to 0h. Historical records have recovery utility. |
| Git history | 11.803 | Keep it whole: it contains version history, not temporary delivery files. |

Detail of all immediate src directories, before the patch:

| Src input | Files | Proven utility/decision |
| --- | ---: | --- |
| Root lumps | 13 | ZSCRIPT, MAPINFO, SNDINFO, menus, USDF, native texts and records: preserve and adjust audio references. |
| caelum | 59 | Gameplay and UI modules linked from ZSCRIPT; add a UI observer, without splitting/relocating existing modules. |
| impactphysics | 1 | Physical core included by ZSCRIPT; store. |
| crafting | 1 | Catalogue of recipes loaded by the system; preserve. |
| maps | 3 | MAP01 invariable; MAP02 narrative arrival and field of evidence preserved as CADEV02 from 0v. |
| graphics | 556 | UI, icons/textures and graphics registrations; keep engine content and conventions. |
| hires | 1 | High resolution graphic resource of the project; preserve. |
| sprites | 1.129 | actors/weapons States and model base sprites; preserve, including necessary transparent markers. |
| models | 155 | Geometry/textures/models linked by MODELDEF; store. |
| fonts | 2.280 | Glyphs and typographical sets; their resolution is native, not a textual reference by character. |
| sounds | 72 | Used audio and registered reservation; replace only the derivative phrase. |
| music | 2 | MAP01/MAP02's own music; preserve. |
| licenses | 5 | Necessary redistribution notices, other than administrative documentation; update the modification of the harp and routes of the visual generators. |

No additional unambiguous temporary trash was found within src. Resources reserved for
future content are not declared useless. The installer manifest specifies each
removal/relocation; unknown local files are preserved. An audited file that changed from the
ZIP stops the application before writing and is reported with its path.

## Historical implementation and maintenance — 4.33.0ao

The following describes the original delivery. Current installation and
updates follow the repository workflow in [README](../README.md).

With GZDoom closed, copy src, docs and README.md over the full 0an folder and accept
replacements. Combine folders; do not replace src with a folder containing only the delta.
Start run_dev.bat to rebuild and play. ZIP only contains new/modified and
PRUEBAS_4_33_0ao.txt files.

Existing build_dev.ps1 and run_dev.bat are preserved: they build the game, they do not
install patches. 0h migration accepted and engine/IWAD paths of the author are maintained.
No more applicators are delivered or executed per version. TXT testing is next to the ZIP;
its results are integrated into these five documents.

## 4.33.0ae Validation

162 passed checks, zero failures, in GZDoom 4.14.2 Linux/Freedoom: 62 in Spanish, 62 in
English, 16 when updating an authentic 0ad save and 22 when reloading a paused Seal task. Only
new checks after each reload are counted, without adding the save counters back through the
scenes.

Use and choice in native USDF conversations: reading, rejection, acceptance, guides,
teaching before choosing weapon and consultation after completing Ronnie. The five recipes
and dependencies are learned without free items; recipes from other families are not
granted. The sum of quotas retains weapon, armor and ammunition. Real sources emit the
remaining amount and do not reissue when they exhaust it. For each seal, their quota to
100% matches the leaves reserved by the native manufacturing plan, without mandatory Box.

The five elements were manufactured and equipped one by one in the single slot. Detail
reached 5/5. The native beginning of Channel was verified with a crafted Seal, real
expense of Adrenaline and cooldown. The entire matrix of elementary effects previously
accepted was not revalidated. Pause, cancellation, resumption and save kept materials,
quotas and single output. Then the first crossbow and ten bolts could be made with their
preserved materials.

The old save was created with 0ad sources, then superimposing 0ae on the same route. It
includes first weapon, medium helmet, pending torso task, issued leather, completed lessons and a
player-owned Seal prepared at the scene. Learn recognizes that seal and only adds the
quota of the remaining four; it does not discount its cost from the previous counter
again. The old task retains time and 10.000 reserved units. Even if the view changes to
seals, it still gives the correct torso. The four missing seals are completed and the
loan/return of the sword uses the real pages of the Ronnie workshop, with repair
already done.

Visual review of the Caella guide and the Fire Seal tree in 819×614 screenshots: text, icon,
materials, infrastructure and readable controls.

The validator checks five documents, 74 audios, 12 station models and 24 Spanish Caella
keys, without errors; the new 13 keys have English and Spanish. The delta contains 14
modified files and the new TXT. CRC and overlap are verified against the entire tree used
by the engine; maps, art, models, music, sounds and assets retain their 0ad bytes.

Private scenes prepare stages, attributes, materials, and equipment, and advance time with
the existing diagnostic helper. They do not replace the complete path, real-time
manufacturing wait, or the author's test on Windows. 0ad is approved by the author; 0ae
is pending such acceptance.

## Validation of 4.33.0ad — approved by the author

394 passed checks, zero failures, in GZDoom 4.14.2 Linux/Freedoom: 62 in Spanish, 62 in English, 217 in families/allowances, 15 when updating an authentic 0ac save and 38 when reloading a paused armor crafting task. Only new checks after reloading, not their saved counters,
are counted.

Native USDF talks: choice of weapon, reading of the four families, confirmation of armor,
drawer and workshops. The four pieces of each family were manufactured and equipped. The
weapon quotas were compared with the reserves of the native plan for the 36 options and
five sizes (180 cases); the leather of the set was contrasted with the four native masses
in the 20 family/size combinations. Crossbow, ten bolts and medium set consumed their
exact raw materials.

Limited extraction before exhausting the source or generating objects, shared allowance across shrubs, old stacks, partial collection of new/old stacks with a free
gram, drawer withdrawal/return and shared Bull/drawer allowance The repair practice reserved and
consumed the missing proportional to the damage; ordering it again did not add another
batch. Loan and return of the sword retain the first weapon.

The migration was tested by creating the save with authentic 0ac sources and superimposing
0ad on the same route. It retained recipes, first weapon, practices, El Loco and an arrow
task to the 25% with its reserves and time. It retained the previous 96 kg of leather
until voluntarily leaving the surplus in the drawer; it left the leather useful for the
armor and did not touch any reserved components. The old task produced only once its
ammunition before making armor. Pause, save, restart and cancellation of armor maintain
quotas and reserves.

Visual review of the Ronnie guide and the manufacturing tree in 819×614 captures: text and
readable controls. The validator checks five documents, 74 audios, 12 station models and
24 Spanish Caella keys, no errors. The delta contains 18 modified files and a new TXT; CRC
and overlay verified against the entire tree used by the engine. It does not change maps,
models, sprites, music or sounds.

The private scenes prepare stages, materials and attributes and advance time through the
existing diagnostic helper. They check the native process and its persistence; they do not
substitute a complete route or wait for real-time manufacturing. The author later
confirmed that all 0ad tests proved correct; that basis is approved to continue with 0ae.

## Validation of 4.33.0ac — approved by the author

129 passed checks, zero failures, in GZDoom 4.14.2 Linux/Freedoom: 47 in Spanish, 47 in English, 17 in reloading a pending task, 2 after saving its result, 9 in updating an arrow task
of 0ab and 7 in updating a save 0ab that was already in MAP02. Reloads count only new checks, without adding back the counter persisted by the scene.

Real choice of crossbow for the USDF pages of Ronnie, query of ammunition and detail in
both languages. Teaching of recipe and dependencies without objects for free. In the Real
Workbench lots of ten were tested to 25%, 50% and 100%, from components and from raw
materials, with consumption of plan leaves and personal output without Box. Reservations
prevent discarding materials; closing pauses, saving preserves time/reserves and canceling releases them without consumption. Insufficient materials, unknown recipe and insufficient stack capacity do not produce ammunition or consume materials. Limit test reduces the stack maximum only in the private scene; the value of the game does not change.

Native crossbow crafting, reloading and firing: one bolt is consumed and
CaelumBoltProjectile is created; the stack of arrows is preserved. The ammunition does not
accredit or replace the first weapon. The development trip to MAP02 retains recipes and
traveling equipment; it does not replace the narrative output, whose physical object
cleaning remains in force.

The old saves were created with authentic 0ab sources, then superimposed 0ac on the same
route. The 130 previous knowledge, stages, lessons, El Loco and the identity of the first
weapon were retained. The 130 recipe was incorporated both in MAP01 and in MAP02. The old
task remained of arrows, with intact reserves and time: even by selecting bolts after
loading, it produced ten arrows once. Repeating the teaching does not duplicate anything.

Private scenes prepare stages, materials and equipment; advance manufacturing time by
means of the existing diagnostic helper. They verify the native process and its
persistence, not the author's complete playthrough or real-time wait. Visual review to 1280×720:
Ronnie guide and bolt recipe with its icon, tree and readable stations. Validator
approved: five documents, 74 audios, twelve station models and 24 Spanish texts of Caella.

Maps and audio-visual resources retain 0ab bytes. The delta passes CRC and exact
reconstruction on that basis: fifteen modified files plus PRUEBAS_4_33_0ac.txt, without
executors, private scenes or PK3. The author confirmed that all 0ac tests were correct.

## Validation of 4.33.0ab — approved by the author

109 passed checks, zero failures, in GZDoom 4.14.2 Linux/Freedoom: 33 in Spanish, 33 in
English, 15 when reloading during immersion, 11 in return and 8 after completion; 9 in
updating an authentic 0aa save, practice, climb the ladder and travel to MAP02. Reload figures count only checks executed after loading, without adding again the counter that
saved the scene.

Ronnie was opened with Use and toured the real USDF pages. Reading and rejection do not
start; confirm record; Detail and dialogue use the result. The real pool credited
WaterLevel 3 and native expense. Wet without covering the head, run the diagnostic helper
in dry, exemptions without expense and fill Air through debugging did not complete. Less than
a second remains pending; partial return also did not complete. It was not confused with
recovery of Air while running. Reopening keeps the practice and travel retains the
lessons.

Old save created with 0aa sources before superimposing the delta on the same route: three
new false booleans, stages, equipment, lessons and 78 cards preserved. Practice was accepted,
immersion was recorded and steps were climbed through movement with native collisions to
x2190/z8, WaterLevel 0, without losing health. Recovery completed the practice. Private
scenes prepare stages, attributes and equipment to cover cases; they do not add content or
replace the author's manual journey with his character.

Visual review of 1280×720: the seven options of Ronnie and the instructions of the pool
are read complete. Dialogue and Detail texts tested in both languages. Validator approved:
five documents, 74 audios, twelve station models and 24 Spanish texts of Caella. The three
WADs and all audio resources retain 0aa bytes. The code review confirms that observers do
not modify costs, regeneration or mission requirements. The delta passes CRC and exact
reconstruction on 0aa: thirteen modified files and PRUEBAS_4_33_0ab.txt, without
executors, private scenes or PK3. The author confirmed that all tests of 0ab proved
correct.

## Validation of 4.33.0aa — approved by the author

1271 passed checks, zero failures, in GZDoom 4.14.2 Linux/Freedoom: 1259
rules/actions, 10 when updating a real 0z save and traveling, and 2 when reloading the
resulting 0aa save and returning to travel.

Scope: 78 cards individually over the twelve attributes, complete collection, base before
percentage, decimals, recalculation without accumulation and snapshots of the Journal.
Divisors with attribute 0, 0,3, 1, 10, 25, 50, 100 and 150; real damage of player/NPC
and preservation of the Pain/Lucidity curve. Native collisions were compared with its
subtractive expression; in addition, the bodies of ReceiveCaelumImpact in player and NPC
are identical to 0z.

Sweeping: four directions, damage equal to the primary under controlled critical and
precision conditions, triple single cost, recovery, insufficient air, solid obstacles and
3D floor, allies and range. Zoom states of the native selectors of the three weapons and
gauntlets were executed; maintaining the button does not repeat. A charged sweep consumes the charge and costs six uncharged primaries. Magic: real costs of the four implements,
T1/T2/T3, normal/charged and rejection by insufficient Anima at Eloquence 100. Own bases
are preserved.

The 0z save was generated with its authentic sources before overlaying the delta. It
preserved cards/equipment/stage/lessons and rebuilt attributes and a pending charged spell
that previously cost zero. It was saved with 0aa, reloaded and tested with real travel to
MAP02 without duplicating bases or losing the weapon. The scenes prepare cards and
equipment for these tests: they add no content to the delivered game. Visual review of the
Journal at 1280×720: full collection and a Minor Arcana without El Loco, with separate
base and percentage tables. Acquisition of the remaining cards is still planned, not
declared complete.

Validator of the approved project: five documents, 74 audio definitions, 12 station models
and 24 Spanish texts of Caella. The three maps and all audiovisual resources maintain 0z
bytes. The ZIP passes CRC and exact reconstruction of the delta on that basis; includes
only 16 modified files and PRUEBAS_4_33_0aa.txt. It does not contain executors, private
maps or PK3. The author confirmed that all tests of 0aa gave correct.

## 4.33.0z Validation

75 checks passed, zero failures, in GZDoom 4.14.2 Linux/Freedoom: 25 in Spanish, 25 in
English, 13 when loading the pending practice, 5 when loading the completed practice and 7
when updating a real save generated with 0y sources. Ronnie was opened with Use, dialogue
traversed and native Inventory D/C actions performed on real objects. Checks covered
rejection of reserved material and an unowned Box, exclusion of consumables and the first
weapon, effective mass reduction, persistence and a real transition to MAP02. The scenes
prepare the stage and leftovers to check these paths; they do not replace the author's
playthrough. Load-value screenshot reviewed at 1280×720. Validator passed; all three WADs
and audiovisual resources retain their 0y bytes. ZIP passes CRC and exact delta
reconstruction over that baseline. 0z was integrated into the complete 0aa baseline whose
test the author approved.

## Validation of 4.33.0y — approved by the author

80 checks passed, zero failures, in GZDoom 4.14.2 Linux/Freedoom: 27 in Spanish, 27 in
English, 15 when loading partial progress, 4 when loading the completed practice and 7
when updating a real save generated with 0x sources. The original Ronnie was opened with
Use and native dialogue traversed. Scenarios inject movement conditions and call the real
expenditure/recovery functions in accelerated cycles: they verify accounting, not the pace
of a manual walk. Checks covered exclusion of the energy drink, no movement and empty
reserves; recovery costs; partial and completed saves; real travel to MAP02 and
preservation of the first weapon. Spanish screenshot reviewed at 1280×720. All three WADs
and audiovisual resources are identical to 0x. Validator passed; ZIP CRC and delta
reconstruction checked. The author approved controls and manual playthrough on Windows for
0y. No new map or obstacle route is claimed as tested.

## Validation of 4.33.0x — approved by the author

108 checks passed, zero failures, in native GZDoom 4.14.2 Linux/Freedoom: 32 in Spanish,
32 in English, 17 from a partial save, 4 from a completed save, 15 for
capacity/retries/low states/refresh of the five consumables and 8 when loading a real save
generated with 0w sources. Native Inventory was used for consumption; the ten real seconds
of pulses were allowed to elapse. The MAP02 transition was native and preserved progress
and the first weapon. Dialogue screenshot reviewed at 1280×720. Isolated scenarios prepare
stages, load and reserves to exercise these conditions; they do not replace the author
tests on Windows.

The validator passes. All three WADs and all audio-visual resources are identical to the
approved base. The ZIP is checked by CRC and by exact reconstruction of modified files on
0w. All 0x tests were approved by the author.

## Validation of 4.33.0w — approved by the author

Stages focused on GZDoom 4.14.2 native, Linux/Freedoom. Stages are prepared, first weapon
with wear and components; items/tasks production are the real ones. Only time is
advanced by debugging function to not wait for the full cycle. The game rhythm is not
declared in Windows.

- Use opens to the original Ronnie. The optional question, steps, pauses and back answer
  are checked in English and Spanish. Detail recognizes the completion.
- Selection and unequipping using Native Inventory; selection persists in Crafts. The
  real network on the second floor opens with Use and reserves materials.
- Start, cancel and pause do not prove the practice. Cancel releases reserves without
  consuming materials; closing pauses the counter of the same task.
- Finish repair consumes materials and restores the same ItemId, without objects, recipes
  or stage changes added as a reward.
- Real saves with paused task and finished practice; continue from them and cross
  preserves the record and the first weapon. Compatibility from 0v.
- Audit of four sets of armor and five T1 seals, size M, with 25/50/100% in all layers.
  Vein capacities read from the map on the engine. These calculations do not simulate
  extraction time, previous decreases or used stock.

Results: 83 passed checks, zero failures: 27 in Spanish, 27 in English, 11 in loading the
paused task, 5 in loading the completed practice and 13 in compatibility from a 0v save.
Capture of the revised Spanish dialogue to 1280×720. Validator of the approved project;
nine new keys in both languages. The three maps and audio-visual resources retain their 0v
bytes. The package is verified by CRC and by rebuilding the cumulative on 0u. The author
confirmed the download, application and approval of all 0w changes.

## 4.33.0v Validation — Approved within Cumulative 0w

GZDoom 4.14.2 native, Linux, Freedoom 0.13, with isolated scenarios that prepare the
stages and inventories. The actual journey is verified; it is not simulated by changing
the name of the map nor is it claimed to have repeated the full tutorial.

- Confirmation and cancellation using native Use/USDF; pending manufacture,
  distance/height, property, no cleaning before completion of the transition.
- Real ChangeLevel: mission completed, same Box/ItemId/Owner, weapon saved with its
  condition, removal of personal and stored extras, Tarot and recipes. No ghost
  shield/layers or full replenishment of resources. Recovery and equipment of the weapon
  from native inventory after arrival.
- Saved during the transition and loaded to continue the same transfer; save after equipping in
  sewers and load without repeating the Voice.
- Saved generated with 0u source and loaded on the same path with 0v. The check detected
  incompatibility when modifying TEXTMAP; MAP01.wad was kept accurate and the modification
  was moved to the controller. The final version must keep that hash to support existing
  games.
- Presentation and localization Spanish/English; native screenshots of doors and sewers.
  TEXTMAP preserved diagnosis and references moved to CADEV02.

Final results: 89 passed checks, zero failures: 38 native-route checks, 22 transition-resumption checks, 2 arrival-load checks, 12 for 0u -> 0v migration and 15 safeguards. The serialized counter of a game includes previous checks; they are not counted again
    when loading. The original save was created with real 0u source. Safeguards also cover
    fallen piece, piece destroyed without gift repair, four magic families, Box/card/Rulo
    requirement and interruption.

CADEV02 opened in GZDoom with mass AI disabled to check the rename; the crowd performance
test was not repeated. Validator passed: five documents, 74 audio files, 12 station models
and references preserved. All 17 return keys occur once in each language. MAP01.wad
retains SHA-256 c3c01999f2cd427ce0f618da82dd18148e6544c5f00ec14b5e066174edc0859c. Record
correction: the author confirmed that the last version received was 0u. The cumulative
release was then delivered and the author approved all its changes, including 0v and 0w.

## Validation of 4.33.0u — approved by the author

- GZDoom 4.14.2 native, Linux, Freedoom 0.13: 42 equipment checks, zero failures. Loan
  without shield; repair of obsolete model; real shield, lock, unequipped, missing
  reference, two-handed sword, sword return, storage, breakage, repair, removal and
  residual layers; giant gauntlets retain their own defense. Real identities are
  maintained.
- Dodge and UI: 13 checks in Spanish and 13 in English, zero failures. Native side
  motion input, Zoom and twist. Move into another room or floor and turn the camera do not
  grant the mark. Walking sideways 48 MU in the room does grant and update the Journal.
  Use opens to the original Rulo; start, review and equivalences show the indication of
  the two-handed sword.
- A truly created save with 0t source and obsolete shield status is loaded with 0u on the
  same route: 9 checks, zero failures. Layers and ghost blocking disappear; the loan preserves Owner, ItemId and mission stage. Traveler log stores repaired status without creating
  another object.
- Reproduction limits: 0t clean start the loan did not give a shield. The symptom was
  reproduced by preparing the incoherent state in the engine; the concrete save was not
  received from the author. The correction also covers residual layers without active
  logical status.
- Visual review of the Journal and error-free compilation of the delivered code. Version
  and five synchronized documents, translations of both languages, existing resources and
  proven ZIP CRC. MAP01.wad does not change.

They are focused scenarios that prepare inventory and stages; not all the already accepted
tutorial is repeated. The author confirmed all 0u checks successfully; the output
expansion is implemented in 0v.

## 4.33.0t Validation — remaining tests approved by author

- GZDoom 4.14.2, native Linux execution with Freedoom 0.13 as IWAD test: 65 flow and
  conversation checks, zero failures. Use opens the real USDF; closing leaves the essence, an
  interrupted capture allows you to retry, the complete gives a card and changes 80 -> 90.
- The twelve attributes retain exactly ×1,02 base. Five consecutive recalculations do not
  accumulate the factor, no health is given, and the Box retains Owner/ItemId. Two Major
  plus one Minor give 5%; the 78 cards give 100%, no compound interest. These latter
  combinations are registry tests, no content obtained during the tutorial. After checking
  them, only El Loco is restored.
- Save during animation and load resume capture: 24 approved later checks. A completed
  save retains collection, stage, Box and attributes; visual inspection part of that save.
- Real migration from 0s source to 0t on the same route: 14 passed checks. The Box, 500
  units of stored material, total mass and first weapon (ItemId 2) are preserved. The
  integer attributes of 0s load as double without loss. The essence appears and can be
  captured without starting new game.
- The original five actors open their subsequent conversations using Native Use. Palomo's
  collection and storage questions are also covered; the pages show their correct
  localized texts.
- Inspection of the appearance in the cave and the Journal in Spanish to 1280×720 and in
  English to 1024×768. The card retains proportions in 16:9 and 4:3. Character shows
  decimals; Missions and F/Detail reflect capture.
- Validator: version/README and five synchronized docs; 74 audios, 12 station models,
  preserved Caella keys and 25 new keys in both languages. MAP01.wad identical to 0s,
  SHA256: c3c01999f2cd427ce0f618da82dd18148e6544c5f00ec14b5e066174edc0859c.

The scenarios prepare already approved stages and conditions, and place Palomo at its
destination to check the conversation. They do not replace a complete game or listening on the author's Windows system. The author approved the other tests of 0t; the ghost shield and
defense guide were addressed in 0u. The output and active powers are not tested as
implemented functions.

## Validation of 4.33.0s — approved by the author

- 130 passed checks, zero failures, in GZDoom 4.14.2: 61 for dialogue/reward/storage, 17 when reloading a 0s save and 26 for each 0r save variant (without Box and with previous property).
- Use and USDF natives cover the thirteen new pages: early visit, optional questions, go
  back, close before accepting, accepting, and reopening later. Each missing mission
  requirement rejects the reward; it is also refused to open from another floor or out of
  reach.
- Acceptance advances 75 to 80, grants a single instance with Owner/ItemId and adds 10 kg
  once. Repeated action retains identity, stage and weight. Storage and removal of a
  personal stack of 5 kg retains quantity, slots and weight reduction. Box does not
  consume a slot of its contents.
- Native saves are created with 0r sources and loaded with 0s sources at the same path.
  The original Palomo, first weapon (ItemId 1), its contents and stage are preserved. The
  Box receives ItemId 2 only once. In the already-owned variant, loading and accepting
  preserve the 12,2 kg load; in the unowned variant, delivery changes it from 6,2 to 16,2
  kg.
- Reloading the save 0s retains Box, content, owner and phase 80; Palomo opens
  post-delivery support. Capture and output remain unrewarded and the mission remains
  active.
- The project validator passes: version/README, five docs, 74 audio files, 12 station
  models and 24 key Caella in Spanish. New 27 keys have Spanish and English versions.
  MAP01.wad retains SHA256
  c3c01999f2cd427ce0f618da82dd18148e6544c5f00ec14b5e066174edc0859c.

The scenarios prepare the stages and place the original instance of Palomo in its
destination, with the route completed. Use, USDF pages, storage and saves do run on the
engine. The route of stairs already accepted is not repeated nor a complete game. The
author confirmed after that all tests of 0s were correct and authorized to continue with
0t.

## Validation of 4.33.0r — approved by the author

- GZDoom 4.14.2 reproduces 0q block: Argento and Caella preserve all their health, but
  INCOMBAT=1 fails StartConversation. Rulo/Ronnie respond.
- 57 protection/recovery/USDF checks: normal and forced lethal damage for all four, 1 health, zero death events, body/height repair without altering totals, eight openings
  with real use and Rulo closure from native menu to 75 phase.
- 32 checks when loading a native 0q save on the same game path: Argento locked by combat
  and Caella as a real corpse (-898840 health, CORPSE/KILLED). Both are repaired; four
  instances remain, with correct height, protection, eight openings/closings dialog and 75
  phase preserved.
- 32 checks when loading the 0r save after closing: protection, health, four residents, 75
  stage and opening/reopening of your dialogs.
- The project validator passes: README/version, five docs, 74 audio files, 12 station
  models and 24 Caella keys in Spanish. The delta changes only LANGUAGE,
  CaelumAnchoredResident and documentation. MAP01.wad maintains SHA256
  c3c01999f2cd427ce0f618da82dd18148e6544c5f00ec14b5e066174edc0859c.

They are controlled scenarios with preconditions of mission and prepared damage; Use, USDF
and saves do pass through the engine. They do not replace the user's playthrough nor a
visual inspection of the encounter. The author confirmed correct all the tests of 0r and
asked to continue with the next block. An actor already destroyed cannot be repaired from
a non-existent instance; base residents leave persistent bodies and the proven variant is
recovered.

## 4.33.0q Validation — remaining tests approved by author

- 146 passed checks in GZDoom 4.14.2: 36 of branch/retry, 37 of the group, 7 of
  USDF/Use and 66 of migration/saves.
- The four inflict native damage on the Bull; it attacks fellows and can leave them down.
  The retry restores the four and a loss caused by a companion credits victory to the
  player. Friendly fire is rejected.
- Use real: first-person Argento orientation, key delivery and return to Rulo within the
  enclosure. Captures inspected in Spanish.
- Native 0p save in combat: preserves Bull damage, practices, owned/borrowed ammunition,
  ItemId, drawer consumption and 38 stations; incorporates group.
- 0q Saved: retains a fallen ally and group references; allows you to retry, beat, close
  and reload with 12.500 leather units.
- Saved 0p completed: retains its previous leather and the four instances at home. Also
  tested is the precondition of victory pending without Bull.
- The tests use a private copy, prepared mission preconditions and damage/timers
  controlled for the limits; the participation test allows the AI to act and records real
  impacts. It does not replace the author's balance assessment or claim to have completed a
  normal game from start to finish.

Previous saves already completed retain the spoils they had produced: the new amount
applies to still pending wins, without removing own leather or filling the drawer. The WAD
maintains the same 0p footprint. The author approved the other 0q tests. The post-combat
opening with Argento and Caella was not covered: 0r reproduces and corrects that omission.

## 4.33.0p Validation — remaining tests approved by author

- GZDoom 4.14.2: full load, 36 branch/enclosure/retry checks; 116 checks with the 36
  initial options and native actions. The ammunition replacement is checked without
  spending your own reserve or curing.
- Real Use/USDF: start of Rulo, practice pages, Argento key and final return. Detail is
  verified with F and engine captures.
- Native 0n save: preserves stage, paused manufacturing, drawer expense and 38 stations.
  On that game the link to the new branch is tested.
- Saved in combat: retains damage to the Bull, six practices, owner of the match, ItemId
  and spent ammunition. Defeat and restart work after loading.
- Saved in phase 75: retains only own ammunition, initial weapon and a single amount of
  leather. Dissipated Bull does not reappear.
- The WAD retains SHA-256
  `c3c01999f2cd427ce0f618da82dd18148e6544c5f00ec14b5e066174edc0859c`. No engine, IWAD, PK3,
  saves or fixtures are redistributed.

The trials prepare preconditions and accelerate timers in private copies; validate
transitions and engine actions, do not replace the author's playthrough. The author
confirmed the rest of his tests; the three observations are dealt with in 0q. That block
left the epilogue pending; 0s–0v incorporate its closure. The final audit of the tutorial
continues on the roadmap.

## 4.33.0o Validation

- GZDoom 4.14.2 compiles and loads new MAP01 and a real 0n save without script or load
  errors. The already approved game matrix is not repeated.
- The WAD contains a single manual type 18106, in (-364,800,0); the save retains the same
  origin. Removal targets only to that specimen of the world, with an independent
  marker to migrate saves already prepared by 0n.
- WAD and other runtime files retain their contents; only change the MAP01 controller. README
  and all five documents remain in 0o version. ZIP checked against 0n: seven modified
  files and one TXT test.

Verification requested in 0o: disappearance of the external manual and preservation of
recipes. The author continued with Rulo and then approved the other evidence of the base;
the observations of 0u were already approved by the author.

## Validation of 4.33.0n — accepted on 2026-09-11

- Full Runtime on GZDoom 4.14.2: load error-free. 281 checks of the 38 stations, collision/height,
  doors, single drawer and five veins.
- 48 checks quantities per size, withdrawal/return and leather migration,
  recipes/crafting/cancellation arrows, real raw material consumption, first weapon,
  custody/transfer key and unique bull loot.
- Native entry: 11 checks. Tab closes Crafts without station and with it; G filters; Use
  opens workbench/drawer/Argento and answers change inventory. Revised drawer captures, arrow
  recipe, key and row of stations.
- Palomo runs both flights of stairs with real motion and collision, reaches (500,120,264)
  visible/solid and without teleport. The route took about 21 seconds in the trial
  without obstructions; the player can block it.
- Three tours of save/load, 138 checks: load 0m keeping Caella and residents; save a
  paused arrow task and to Palomo running; resume and complete both; transfer key, defeat
  Bull, save/load again. 128/129 recipes, ammunition, spent stock, key and loot persist.
  Do not duplicate the Bull or return the key to the custodian.
- All previous trials ended without failure. Recipe tests inject raw materials and advance
  the manufacturing clock; the key ones prepare the future Rulo flags. They do not credit
  that playable chapter.
- README and five documents consistent with 0n. WAD, 74 audio files, twelve station models
  and unchanged art. Exact Delta over 0m; additional TXT with application/tests. No test
  tools included.

The author confirmed all 0n tests successfully. The acceptance covers the scope
implemented; it does not make the remaining branches playable. Isolated trials use GZDoom
4.14.2/OpenGL with private instrumentation. They do not credit duration of a game or
cooperative. Engine, IWAD, fixtures, captures and saves are left out of patch; 0m
validation in HISTORY.md.
