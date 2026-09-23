# CONTEXT.md — Ultra-condensed summary of Caelum Argenteum

Summary so an AI or a contributor can understand the project without reading
the five full canonical documents. Source: `docs/PROJECT.md`,
`docs/SYSTEMS.md`, `docs/MAP01.txt`, `docs/ASSETS.md`, `docs/HISTORY.md`, and
`README.md`. Documentation version: **4.36.0i**.

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
- **Tarot:** persistent collection and capture of El Loco; base passives for
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

Version **4.36.0i**. Native compilation and tests were run on GZDoom g4.14.2
on Linux with development Freedoom. Working: the 4.36 base (trapdoor, rocks,
approved traps, ceiling), the MAP02 maze, the approved resting-weight formula,
rations, and MAP01 tables at full capacity.

Pending:

- Visual acceptance and playthrough on Windows 11.
- Manual save/load interrupting traps or combat.
- Closing 4.36: damaging surfaces, avalanches, rams, catapults, and moving
  sectors, with their integration and validation before extracting Impact
  Physics.

After 4.36 comes 4.37 (Tarot/Trucazo), then the V4 playtest export, and only
then V5.

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

1. Code and identifiers in English; explanatory comments and documentation in
   Spanish.
2. Prefer stable native GZDoom 4.14.2 functions and a single authoritative
   data source.
3. Final product independent of Doom assets; preserve provenance.
4. Do not invent balance, recipes, story, or pending decisions.
5. Protect what is accepted and validate only what is affected.
6. Deliver new/modified files and a test TXT; no installers.
7. Consolidated documentation updated in every patch.
8. Every delivery updates version, status, and results in the same change.
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

