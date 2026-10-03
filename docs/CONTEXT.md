# CONTEXT.md — Ultra-condensed summary of Caelum Argenteum

Documentation version: **4.37.9** — 2026-10-03.

**#77:** MAP06: 960 × 960 m, 288 constructions:
160 houses, 64 shops, 24 factories and 40 works in progress. Six gates face the
southern assault; four towers and all wall walks have stairs. Forces: 6,000
Mandingas + commander, 600 soldiers, six hostile guns/six rams. Defenders install
36 guns; eight south-wall and four tower guns fire. MAP01 → MAP02 → MAP06 retains
Ace/Zupay and 10 km planning. Evidence: validation_4379/south. City/route checks
accepted. Old port saves select their legacy layout;
--legacy-map06-north-city preserves the first 4.37.9 northern city.

**Combat follow-up:** nearest player/guard; range/costs, retreat/idle, Pain,
double chair Anima. 90 checks pass; merge approved. Performance: #86 (13.5/35 tics/s).
See south/COMBAT_RECOVERY.json. Author checks passed 2026-10-03.

**Accepted #73/#74/#75:** cardinal maze, material chests/finite enemy supplies,
six flooded returns, four grates and central elevator. Closed blocks keep covers
shut until normal entry. #75 corrected per-item report associations, not totals.
Accepted 2026-10-02; PRs #76/#83/#84 merged. MAP02 old-save waiver stays specific.

**Accepted base:** #64/#65 (Y/time and daily tables), #63 (Palomo loadout),
#68 (magic), #62 (dummy), #61 (landscape), #17 (export). HISTORY retains evidence
and acceptance. #61 geometry needs fresh MAP01. Rights: LICENSE.md and notices.

## The game's premise

Caelum Argenteum is an independent dark-fantasy FPS-RPG inspired by
nineteenth-century Argentina, built on GZDoom 4.14.2/ZScript. The newly
formed nation is divided by political, social, and territorial interests while
facing two simultaneous invasions.

The first invasion is external: the Caelith, original inhabitants of the Moon,
descend upon the Earth under the command of Queen Selene. The second is
internal: the Tarot, a power from Hell, infiltrates people, creatures, objects,
places, and conflicts; the Cult of the Tarot uses that influence to sharpen
the existing divisions and weaken the resistance. Both threats come from the
plan of an infernal prince who, after repeatedly failing to conquer the Earth
by force, decided to corrupt the Moon and break the Earth from within.

The protagonist does not begin as a hero or a declared member of a faction: he
is a wanderer trying to escape the conflict, dies in circumstances he does not
remember, and wakes in an impossible mansion without knowing he is in Limbo.
The main species are allegorical of nineteenth-century Argentina: the Beast Men
represent the native peoples, the Caelith European colonialism, the duendes
the gauchos and rural culture, and the humans the urban porteño society.

## Implemented systems

- **Combat:** physical melee weapons, ranged weapons, and magical implements in
  three tiers; blocking, aim/ADS, charged attacks, sweeping heavy weapons, and
  the equipped-Seal Channel.
- **Survival:** Hunger, Thirst, Sleep, Air, and health; regeneration, needs by
  body mass, digestion, rest, and wait.
- **Attributes and abilities:** twelve attributes, agreed racial and class
  abilities (only the Arcanist Sleep is implemented), runes, and seals.
- **Crafting and equipment:** recipes, repair, disassembly, stations, armor,
  ammunition (arrows and bolts), and material allowances.
- **Economy and Magic Box:** physical currency, transactions, and a persistent
  Box with weight reduction and restricted contents.
- **Quests, reputation, and factions:** optional quest base, states, reusable
  dialogue/access/trade conditions, and faction conditions.
- **Tarot:** persistent collection and shared capture of El loco, Ace of Cups and Knight of Wands; base passives for
  the 56 Minor Arcana by suit; card rewards.
- **World and travel:** world Journal, visited locations, connections, grouped
  doors, caravans, coastal vehicles (carriage and merchant ship), and measured
  routes with provisions.
- **Time, calendar, and climate:** persistent global clock, civil and campaign
  calendar (epoch 1889-11-03 09:00), monthly event agenda, SMN regional
  climate, and position-dependent shelter.
- **Physics and hazards:** Impact Physics core, trapdoor, pit, rocks, explosive
  mines, teleport, ceiling crusher, resting weight, and levers.
- **MAP01 (mansion/tutorial):** prologue, Unknown Voice, Palomo, Argento,
  Caella, Ronnie, and Rulo; first weapon, Box, and exit to MAP02.
- **MAP02 (maze):** four sections, 100 junction rooms, 96 Mandingas, 45 traps,
  four progression/arena and four cell keys, 39 chests, 65 unique T1 pieces,
  four cell beds/refuges, final Zupay retreat, Ace of Cups and the workshop exit.
- **Presentation:** modular first-person view, event audio, Spanish/English
  localization, project typography, and hub transitions.


**4.36.26 / #37:** common 14-tic attack duration scales with effective
Dexterity/Eloquence and weapon-plus-glove mass over maximum capacity; 100%
blocks attacks. Full-cycle animations include the author's five grip-centered
thrusts (30 down, 60 advance, 16/16/48/20% phases). Weapon durability ×10 migrates
proportional wear once; projectile wear follows the exact item. Authored enemies
spend shared resources, idle/recover when exhausted, and retain the 80-tic Zupay
slam exception. Native rules/cycles, persistence and visual evidence:
assets/validation_43626. Both author checks passed 2026-09-30; merge/closure authorized.

## Current status

**4.36.25 / #36:** mansion enclosure, guards, shutters, finishes and hinged
doors passed native traversal/access checks and author acceptance
CA-43625-MANSION-01 on 2026-09-29. Start fresh. Architecture: ASSETS/MAP01;
evidence: assets/validation_43625/caella. Startup model-surface failure is fixed.

**4.36.24 / #35:** Journal filters retain main/side and active/completed records,
including separate rescue/extraction and payment status. Native legacy/reload/hub
and UI checks pass (assets/validation_43624). CA-43624-JOURNAL-01 passed author
acceptance on 2026-09-28; merge/closure authorized. Controls/classification and
legacy limits: SYSTEMS. Port and #17 export are author-accepted.

**4.36.23 / #52:** Toughness subtracts uncapped L*(L+1)/101 maximum-health percentage points before armor.
Magical armor loses mental bonuses; shields stay unchanged. Palomo absorbs 77%;
gates absorb 10/20/30%, with Constitution 0 and Toughness 25/50/75.
Native combat/siege and save migration pass. Tables: SYSTEMS; evidence:
assets/validation_43623. Author confirmed all three checks passed 2026-09-28; merge authorized.

**4.36.22 / #34:** revised Palomo/Voice/companion narrative, secondary-wind
sprite freeze fix and legacy dialogue migration passed author acceptance
CA-43622-NARRATIVE-01 on 2026-09-27. Evidence: assets/validation_43622;
details retained in SYSTEMS/HISTORY. Siege deployment is now implemented in #16.

**4.36.21 / #49:** environmental contacts retain accepted absorption and no
longer grant combat adrenaline. SYSTEMS/HISTORY retain the complete rules.
Evidence: assets/validation_43621. The author confirmed CA-43621-IMPACT-01
passed on 2026-09-27. PR #50 targets main.

4.36.20 (#33) unifies Arcana capture and routes MAP02 through MAP03 to MAP06.
The Zupay flees at 50% health at triple speed; escape confirms defeat and unlocks
the Ace. The former rescue-payment Knight condition is superseded by #16
for current MAP06 and preserved only for legacy geometry. The Ace rendering freeze was corrected.
The author confirmed CA-43620-ARCANA-01 and CA-43620-ROUTE-01 passed 2026-09-27.

The preceding **4.36.19** applies the author-approved final #21 balance:
new cannon shots 500 m/s; gate Toughness/Constitution 50/100/200; Type 4 division
for player/NPC/gate collisions. SYSTEMS holds the damage matrix. Versioned
gate migration preserves remaining-health ratio and passage state with explicit
rollback; saved projectiles retain velocity. Evidence: assets/validation_43619.
Merged; #21 closed. Author confirmed CA-43619-BALANCE-01 passed 2026-09-27.

4.36.18 (#43, closed) adds walking-only wall absorption;
author confirmed CA-43618-WALK-01 passed 2026-09-27. No manual checks remain pending.
Native traversal and loaded self-jump pass. 4.36.17 implemented #21 controlled
cannons, approximate 4.3 kg ammunition, 30/60-second crews and bounded saved
projectiles; its original CA-43613-CATAPULT-01 passed 2026-09-27. Those native
mechanics and sources remain in assets/validation_43617; final balance supersedes
the original 400 m/s /zero-gate-damage result. Port and export are now author-accepted.

**4.36.16 / #20:** operational rams passed CA-43612-RAM-01 on 2026-09-26;
merge/closure authorized. Mechanics, debug commands and evidence remain in
SYSTEMS/HISTORY and assets/validation_43616. Port and export are now author-accepted.

The accepted **4.36.15** (#19) implements breakable actor gates, using approved 30%/50%/70% reductions and 550/650/1,100 kg moving masses. Intact, damaged and broken states persist across save/load and hub travel; old-save and native body-contact tests pass. CA-43611-GATES-01 passed on 2026-09-26. Full implementation and acceptance details remain in HISTORY; subsequent #21 balance supersedes original gate Constitution.

**4.36.14a / #18:** author accepted the corrected gate/cannon/ram forms and
independent MODELDEF states on 2026-09-26 (CA-43614A-SIEGE-ART-01). MAP03
furniture/stations and saved instances were retired, retaining table contents
as pickups. Other maps/save schemas were unchanged. Details: ASSETS/HISTORY;
historical cannon scale remains unverified.

**4.36.14 / #31:** author-selected combat pain, dialogue-opening cue and
sewer/port/coast music are integrated. Sources, unused backups and the former
mansion track remain preserved; ASSETS retains exact bindings and HISTORY
records CA-43614-AUDIO-01, passed 2026-09-25.

Issue **#18** supplies the accepted deterministic siege art and cleared MAP03
gallery. ASSETS retains its models, sprite/state bindings and generator details;
#19-#21 own the subsequent mechanics and balance.

**4.36.9 / #15:** all 78 approved Tarot fronts use persistent card IDs and
the shared back. Journal selection shows owned fronts; the separate development
preview grants no progress. Ace remains ID 36; no powers/rewards added.
CA-4369-TAROT-ART-01 passed 2026-09-25; ASSETS/HISTORY retain full evidence.

The preceding **4.36.8** implements #14: the four MAP02 prisoners can be
released, then follow and fight alongside the player with their source combat
profiles while staying back from the northern Zupay. Each prisoner is extracted
only by reaching the pre-boss reservation alive before that fight (killing the
boss is not required); a follower that dies earlier is not rescued. At the
MAP06 port, each extracted prisoner grants +10 reputation with its own faction
and 25 gold coins (1,000,000 copper) once, independent of character size, with
no duplicate payout across retry, save/load or travel. The provisional social
domains are replaced by six canonical factions: Unitarians, Federals, Free
Peoples, Caelith, Cult of the Tarot and Sun Warriors. GZDoom 4.14.2 compiles the
complete package and loads MAP01/MAP02/MAP06 without script errors; author
confirmed CA-4368-RESCUE-01 passed on 2026-09-25.

**4.36.7 / #13 and 4.36.6 / #12:** reused prisoner appearances and 192 sewer
rats are author-accepted; provenance and results remain in ASSETS/HISTORY.

The preceding **4.36.5** implements #11: wider four-section sewers, keyed
barred gates/cells, beds, repair refuges, pre-boss extraction reservation and
240 arrows/120 bolts/120 bullets. Only known weapon recipes permit repair;
no materials or recipes are added. The author confirmed CA-4365-MAZE-01 passed
on 2026-09-24.

The merged **4.36.5a** documentation patch records the selective file-reading
workflow for agents (#29) without changing gameplay, balance, maps, saves or
assets.
Saved campaigns that visited old MAP02 use `run_dev.bat --legacy-map02` to
continue byte-identical legacy geometry; normal builds use the new layout.
The accepted **4.36.4** implements #10: the complete T1 maze catalogue,
recipient-sized natural equipment/rewards, explicit chest previews/collection
and a bounded recent-message feed. The author confirmed CA-4364-T1-LOOT-01 passed
on 2026-09-23; its acceptance remains recorded separately in HISTORY.
The retained 4.36.3 issue #9 flail-handle rotation adds 10 degrees
further counterclockwise across T1–T3. Native before/after, full spin, return
and re-equip checks passed; the author confirmed CA-4360I-VISUAL-01 passed
on 2026-09-23. The
4.36.2 bow crop cache and author-approved environmental scope are retained. Native Windows evidence is
recorded in HISTORY; the author confirmed CA-4362-BOW-EMPTY-01 passed on
2026-09-23. Gameplay
rules, accepted bow art and saves are unchanged. The engineering guides/index
from #22 and English documentation/acceptance workflow from #6 remain in force.

The **4.36.0i gameplay baseline** was compiled and tested on GZDoom g4.14.2
on Linux with development Freedoom. Working: the 4.36 base (trapdoor, rocks,
approved traps, ceiling), the MAP02 maze, the approved resting-weight formula,
rations, and MAP01 tables at full capacity.

Pending:

- #8–#16, #18–#21, #33–#37, #43 and #49 are author-accepted within their recorded
  scope. #17 exported-package acceptance passed on 2026-10-01.
- Extract Impact Physics only after its separate integration/save/reset closure. Per the author's 2026-09-23 #8 decision,
  existing ceiling/elevator cover moving sectors; avalanches await additional
  maps and damaging surfaces await temperature effects (no acid/lava requested).
  Those three items do not block 4.36; export is accepted and Tarot remains next.

On 2026-09-23 the author accepted the 4.36.0i maze, save/load and table checks
and bow appearance. The author also confirmed the complete 4.36.1 Windows
validator/launcher/header check. The bow stall and final flail pose are now accepted;
detailed results are in HISTORY. PR #7 and the #22 integration PR #23 are merged.

The 2026-10-01 author decision puts the current-content V4 playtest export
before 4.37 (Tarot/Trucazo); V5 follows the remaining V4 work. The 2026-09-23 author decision requires three complete maps with the
prologue, confirmed El Loco and two Minors before export (#16/#17). Confirmed
route under #77: mansion MAP01 -> maze MAP02 -> port MAP06. The accepted
port siege replaces the Knight of Wands' provisional #33 appearance condition.
Prisoners match their source character's combat stats, follow/fight alongside
the player and extract alive through an exit before the MAP02 boss; they do
not fight that boss. At the port, each grants +10 reputation with its own
faction and a fixed 25 gold coins once, independent of character size.
The latest #10/#14 author decision supersedes the former weapon-price formula.
The #15 approved Tarot fronts are integrated; activation/powers stay pending after this playtest;
the current siege rules are author-accepted.
Prisoner source/faction mapping: Caella/Unitarians, Ronnie/Federals,
Rulo/Free Peoples, Argento/Cult of the Tarot; do not reassign mansion NPCs.
PROJECT contains the authoritative scope and dependency order. The author
discontinued further weekly-allowance measurements on 2026-10-01; historical
usage evidence remains preserved.

## Repository structure (summarized)

- `src/`: everything packaged into the PK3 (maps, ZScript, sprites, models,
  fonts, sounds, music, graphics, licenses).
- `docs/`: the five canonical documents plus `CONTEXT.md` and `TASKS.md`, the
  engineering guides `GZDOOM_DEVELOPMENT.md` and `KNOWN_PITFALLS.md`, and the
  generated `DOCUMENT_INDEX.md`.
- `assets/`: art/audio sources, climate, first-person views, optional
  generators, and manifests; not packaged at runtime.
- `build/`: regenerable PK3.
- `archive/`: backups of previous versions.
- Root: `README.md`, `build_dev.ps1`, `run_dev.bat`, `validate_project.py`,
  `build_document_index.py`.

Use DOCUMENT_INDEX for long documents; follow the engineering guides.

## Critical premises (summary of the 20)

1. Code, identifiers and maintained documentation in English; gameplay-code
   explanatory comments remain Spanish. Modified tooling uses English throughout.
2. Prefer stable native GZDoom 4.14.2 functions and a single authoritative
   data source.
3. Final product independent of Doom assets; preserve provenance.
4. Do not invent balance, recipes, story, or pending decisions.
5. Protect what is accepted and validate only what is affected.
6. GitHub issue -> focused branch -> linked PR. ZIPs are optional exports.
7. Consolidated documentation updated in every patch.
8. Every patch updates status and results; use numeric MAJOR.MINOR.PATCH.
   Implementation commits and later acceptance retain the same patch version.
9. Preserve history and unique content; do not delete silently.
10. Folders with clear responsibility; package only `src`.
11. Every change must be traceable to an issue or task.
12. No agent deletes files without explicit authorization.
13. Generators must be deterministic (same input, same byte-for-byte output).
14. One model per task: routine → economical model (DeepSeek); architecture,
    narrative, or complex review → advanced model (ChatGPT Pro).
15. Saves always migratable: explicit, tested, reversible migration with a
    revision number and idempotent logic.
16. Data outside logic: balance, recipes, coordinates, names, and texts live in
    data or documents; ask rather than invent.
17. One change, one reason: do not mix visual, balance, and code changes.
18. Cross-verification between AIs: DeepSeek reviews ChatGPT's code, ChatGPT
    reviews DeepSeek's design.
19. Documentation is the contract: if code and docs differ, the docs prevail
    until updated; report discrepancies, do not "fix" the code silently.
20. Issues are the unit of work: every significant change comes from an issue
    with scope and acceptance criteria; a PR without a linked issue is not
    reviewed.

The full verbatim list is in `AGENTS.md` and `docs/PROJECT.md`.

Work plans issues; Codex implements/tests; the author confirms manual acceptance.
Keep implementation, static/native evidence and author acceptance distinct.

[pending_test.txt](../pending_test.txt) is the single author-test queue. Preserve
outstanding tests across versions. Only an explicit pass confirmed by the author
moves a test's ID, originating version/issue, result, date and qualifications to
its release in [HISTORY.md](HISTORY.md); remove that entry in the same update.
Partial, failed and unconfirmed checks remain. An empty tracked queue is valid.
All seven docs and AGENTS declare the current version; ancillary guides without
a header inherit README's version. Historical labels retain their original meaning.
