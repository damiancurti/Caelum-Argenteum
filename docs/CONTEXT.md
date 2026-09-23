# CONTEXT.md — Ultra-condensed summary of Caelum Argenteum

Documentation version: **4.36.1** — 2026-09-23.

Summary so an AI or a contributor can understand the project without reading
the five full canonical documents. Source: `docs/PROJECT.md`,
`docs/SYSTEMS.md`, `docs/MAP01.txt`, `docs/ASSETS.md`, `docs/HISTORY.md`, and
`README.md`.

## The game's premise

Caelum Argenteum is an independent dark-fantasy FPS-RPG inspired by
nineteenth-century Argentina and built on GZDoom 4.14.2/ZScript. The newly
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
- **Tarot:** persistent collection and capture of El Loco and the Ace of Cups; base passives for
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
- **MAP02 (maze):** three sections, 147 rooms, 96 Mandingas, 45 traps, three
  keys, 39 chests, 195 equipment pieces, final Zupay, Ace of Cups, and the
  coast exit.
- **Presentation:** modular first-person view, event audio, Spanish/English
  localization, project typography, and hub transitions.

## Current status

Current release **4.36.1** implements issue #6: English documentation, numeric
patches, repository-first delivery and the root author-test queue. Its static
checks are recorded separately in HISTORY; no new gameplay is introduced.

The **4.36.0i gameplay baseline** was compiled and tested on GZDoom g4.14.2
on Linux with development Freedoom. Working: the 4.36 base (trapdoor, rocks,
approved traps, ceiling), the MAP02 maze, the approved resting-weight formula,
rations, and MAP01 tables at full capacity.

Pending:

- Final flail pose: approximately 10 degrees more counterclockwise (#9, planned 4.36.3).
- Reported multi-second stall when equipping a bow without arrows (#8, planned 4.36.2).
- Author-requested patches 4.36.4–4.36.9 (#10–#15): T1-only MAP02 equipment;
  four keyed sewer sections with cells/beds, repair refuges and northern Zupay;
  192 enemy rats alongside 96 Mandingas; four recolored prisoners; persistent
  rescues/port faction rewards; approved Tarot images. These are planned,
  not present in the accepted three-section 0i baseline.
- Planned 4.36.10–4.36.13 (#18–#21): siege-machine assets, breakable actor
  gates, physical ram strikes and native catapult projectiles for the port.
- Closing 4.36: damaging surfaces, avalanches, rams, catapults, and moving
  sectors, with their integration and validation before extracting Impact
  Physics.

On 2026-09-23 the author accepted the 4.36.0i maze, save/load and table checks
and bow appearance. The author also confirmed the complete 4.36.1 Windows
validator/launcher/header check. The weapon exceptions above remain open;
detailed results are in HISTORY. PR #7 still requires merge approval.

After 4.36 comes 4.37 (Tarot/Trucazo), then the V4 playtest export, and only
then V5. The 2026-09-23 author decision requires three complete maps with the
prologue, confirmed El Loco and two Minors before export (#16/#17). Confirmed
route: mansion MAP01 -> maze MAP02 -> port MAP06. Stop the port's demon siege;
its separate commanding Zupay holds the second Minor (identity pending).
Prisoners match their source character's combat stats, follow/fight alongside
the player and extract alive through an exit before the MAP02 boss; they do
not fight that boss. At the port, each grants +10 reputation with its own
faction once. Material rewards, detailed siege balance/conditions and the
definitive Tarot asset package remain pending.
Prisoner source/faction mapping: Caella/Unitarians, Ronnie/Federals,
Rulo/Wild Beast Men, Argento/Cult of the Tarot; do not reassign mansion NPCs.
PROJECT contains the authoritative scope, dependency order and usage protocol.
The author confirms a 75% weekly-allowance-remaining baseline; reset time is
unknown. Collect measured per-patch data rather than estimating.

## Repository structure (summarized)

- `src/`: everything packaged into the PK3 (maps, ZScript, sprites, models,
  fonts, sounds, music, graphics, licenses).
- `docs/`: the five canonical documents plus `CONTEXT.md` and `TASKS.md`.
- `assets/`: art/audio sources, climate, first-person views, optional
  generators, and manifests; not packaged at runtime.
- `build/`: regenerable PK3.
- `archive/`: backups of previous versions.
- Root: `README.md`, `build_dev.ps1`, `run_dev.bat`, `validate_project.py`.

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

Work plans a concrete issue; desktop Codex implements and tests it; PR review
checks the evidence; the author confirms manual acceptance where required.
Keep implementation, static verification, engine verification and author
acceptance separate. The issue number does not determine the patch version.

[pending_test.txt](../pending_test.txt) is the single author-test queue. Preserve
outstanding tests across versions. Only an explicit pass confirmed by the author
moves a test's ID, originating version/issue, result, date and qualifications to
its release in [HISTORY.md](HISTORY.md); remove that entry in the same update.
Partial, failed and unconfirmed checks remain. An empty tracked queue is valid.
All seven docs and AGENTS declare the current version; ancillary guides without
a header inherit README's version. Historical labels retain their original meaning.
