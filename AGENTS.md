# AGENTS.md — Caelum Argenteum

Startup guide for AI agents and human contributors. This file describes **how
to work** on the project, not what balance or design it contains. Balance
values, recipes, and design decisions live in the canonical documents in
`docs/` and in the author's decisions.

## What this project is

- **Caelum Argenteum** is an independent dark-fantasy FPS-RPG inspired by
  nineteenth-century Argentina, built on GZDoom/ZScript.
- **Author and designer:** Damián Curti.
- **Target engine:** GZDoom 4.14.2 (Windows 11).
- **Current documentation version:** 4.36.0i.
- **Status:** the final product must be independent of Doom assets.

## Repository structure

| Path | Contents |
| --- | --- |
| `src/` | Everything packaged into the PK3: maps (`maps/`), ZScript code (`caelum/`, `impactphysics/`, `crafting/`), sprites, models, fonts, sounds, music, graphics, and license notices. |
| `docs/` | Canonical documentation: `PROJECT.md`, `SYSTEMS.md`, `MAP01.txt`, `ASSETS.md`, `HISTORY.md`, plus the working documents (`CONTEXT.md`, `TASKS.md`). |
| `assets/` | Art and audio sources, climate data, first-person views, optional generators (`generators/`), manifests, and validation records. Not packaged at runtime. |
| `build/` | Regenerable PK3 (`caelum_argenteum_dev.pk3`), rebuilt with `build_dev.ps1`. |
| `archive/` | Known backups of previous versions, kept for recovery. |
| Root | `README.md`, `build_dev.ps1`, `run_dev.bat`, `validate_project.py`. |

Only `src/` goes into `build/caelum_argenteum_dev.pk3`. `assets/generators/`
are optional editing utilities; their outputs are already in `src/`.

## Which document to read per task

| Task | Reference document(s) |
| --- | --- |
| Understand the project, premises, roadmap, status, and current validation | `docs/PROJECT.md` |
| Game rules: controls, combat, crafting, economy, Box, survival, dialogue | `docs/SYSTEMS.md` |
| Story, canon, MAP01 specification, and implementation boundaries | `docs/MAP01.txt` |
| Audio, art, first-person views, attributions, and generators | `docs/ASSETS.md` |
| History of decisions and previous documents | `docs/HISTORY.md` |
| Installation, build, and summarized status | `README.md` |
| Quick summary before reading the rest | `docs/CONTEXT.md` |
| Active tasks and acceptance criteria | `docs/TASKS.md` |

## Conventions

- Code, identifiers, and the general README are **in English**.
- Explanatory comments and working documentation are **in Spanish**.
- Textual documentation sources use UTF-8.
- Preserve provenance and attribution for owned and external resources.

## Permanent premises

Premises 1 to 10 come from `docs/PROJECT.md`, section "Premisas permanentes".
Premises 11 to 20 were added on request by the author.

1. Code, identifiers, README, and all documentation in English. Explanatory
   comments inside code remain in Spanish, so the author and Spanish-speaking
   collaborators understand the intent of each block.
2. Prefer stable native GZDoom 4.14.2 functions. Keep a single authoritative
   source for data and a shared architecture between weapons and actors.
3. The final product must be independent: do not distribute Doom assets.
   Preserve provenance, attribution, and modifications for owned or external
   resources. Development dependencies do not equal authorization to distribute.
4. Do not invent balance values, recipes, story, or pending decisions. The
   author's design and later corrections set those data.
5. Protect what is already accepted and validate only what a revision affects.
   Distinguish static analysis, an isolated engine test, and author acceptance.
6. Deliver only new/modified files to copy and paste, plus a TXT with the
   required application and tests; no patch installers. Do not include IWADs,
   executables, test fixtures, or a full PK3 as if it were the definitive base
   when only a delta is available.
7. **Consolidated documentation updated in every patch.** `README.md` is the
   general entry point and is reviewed with each delivery. Keep these five
   `docs/` files; integrate new topics into their chapters before creating
   another file. A new permanent document is justified only if the author
   requires it.
8. Every delivery updates version, real status, decisions, next steps, and test
   results in the same change. Do not duplicate state between a per-patch
   README and several thematic reports. Temporary ZIP instructions stay out of
   the installation; older ones go to the history.
9. Preserve history and unique content. Before retiring a document, integrate
   its current information and preserve the original. Do not silently delete
   local files or keep obsolete requirements as current instructions.
10. **Folders with a clear responsibility.** Before removing files, check
    consumers and provenance. Keep useful sources in assets, package only src,
    and back up known retirements. Each delivery's test TXT does not accumulate
    in the five active documents. V5.0 reorganizes code through small changes
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

## Expected workflow

1. **Read context.** Start with `docs/CONTEXT.md`, then the canonical document
   for the task per the table above.
2. **Review impact.** Check whether the change affects already-accepted
   systems; do not reopen what was approved without reason and do not invent
   pending values.
3. **Make minimal changes.** Modify only what is necessary and only new or
   affected files.
4. **Update documentation.** Reflect version, status, decisions, and test
   results in the same change.
5. **Report tests.** Separate static analysis, an isolated engine test, and
   author acceptance; state what remains pending.

