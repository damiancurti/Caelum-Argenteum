# GZDoom development guide — Caelum Argenteum

Status: author-requested handoff draft; formal repository integration pending.
Prepared: 2026-09-23. Inherits the project's release after integration; this is not a new game release.
Source baseline: PR #7, commit `1dc390576fa330d37ff543526fc7e69a397fc28f`.
Target: GZDoom 4.14.2 on Windows 11. Observations below are scoped to that baseline unless stated otherwise.

## Purpose and authority

Give a new contributor or AI enough technical orientation to work without reconstructing the conversation or loading the entire history. This document transfers explicit project knowledge, not model training or a guarantee of correctness.

Read the current root AGENTS.md and docs/CONTEXT.md first. Then read the assigned issue, this guide's relevant sections, the canonical specification and actual consumers. Current author decisions define intended behavior; source inspection establishes implemented behavior. Report differences instead of silently changing either side. This guide does not supersede AGENTS, invent balance or authorize unrelated work.

The author explicitly requested these additional documents, satisfying AGENTS premise 7's exception for new permanent guides. Their registration, navigation links and validation are a later integration task.

## Fast task startup

1. Identify the repository, branch, exact HEAD and local changes. Preserve unrelated work.
2. Read the issue's objective, exclusions, dependencies and acceptance criteria. A planned feature is not an implemented feature.
3. Locate the authoritative data and one existing implementation with the same responsibility. Search for the symbol and its consumers before editing.
4. Establish what is reproducible. Record the original error or observable behavior before proposing a fix.
5. Change the smallest coherent unit, update its sources/generated outputs together, and perform the affected checks.
6. Report the commit, scope, evidence, limitations and outstanding author tests. Review and acceptance are separate stages from implementation.

Do not read all of HISTORY.md by default. Search its relevant headings or issue/test IDs. Do not translate or rewrite the canonical documentation again to perform a small patch.

## Repository navigation

All paths in this section are relative to the repository root and were inspected at the baseline.

| Responsibility | Entry points |
| --- | --- |
| Runtime inclusion | src/ZSCRIPT (declares language version "4.14" and ordered includes), src/MAPINFO |
| Shared constants and character profile | src/caelum/core/CaelumConstants.zs; src/caelum/character/CaelumCharacterProfile.zs |
| Player orchestration | src/caelum/player/CaelumPlayer.zs |
| Equipment fit and size | src/caelum/equipment/CaelumEquipmentRules.zs |
| Weapon definitions, crafting and prices | src/caelum/equipment/CaelumWeaponCatalogue.zs; CaelumWeaponModel.zs; CaelumCraftingRules.zs; CaelumEconomy.zs in the same directory |
| Pickups and saved equipment | src/caelum/equipment/CaelumEquipmentPickups.zs; CaelumPersistentCharacterState.zs in the same directory |
| First-person presentation | src/caelum/equipment/CaelumFirstPersonView.zs; CaelumFirstPersonLayers.zs; CaelumPlayableWeapons.zs in the same directory |
| Combatants and mansion NPCs | src/caelum/actors/CaelumCombatActor.zs; CaelumAnchoredResident.zs; CaelumArgento.zs; CaelumCaella.zs; CaelumRulo.zs; CaelumRonnie.zs |
| Sewer content and travel | src/caelum/world/CaelumSewerMaze.zs; CaelumMazeLootCatalogue.zs; CaelumSewerTravel.zs |
| Doors and physical hazards | src/caelum/world/CaelumSlidingDoor.zs; CaelumPhysicalHazards.zs; src/impactphysics/ |
| Generated maze sources | assets/generators/generate_map02_maze.py; assets/map02_maze/MAP02_MANIFEST.json |
| Resource bindings | src/TEXTURES; src/MODELDEF; src/SNDINFO |

Only src/ is packaged by the normal builder. assets/ contains sources, generators and manifests; docs/ is documentation; build/ is regenerable output. Adding a source image to assets/ does not itself make it available in-game.

## Build and launch on Windows

Run from the repository root. Use the installed Python command described by the current README; no additional Python installation is required solely for this guide.

```powershell
python --version
python validate_project.py
$LASTEXITCODE
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\build_dev.ps1
$LASTEXITCODE
```

The validator should return exit code 0 and an empty errors list. Read the whole report; a successful validator is not a ZScript compiler or a gameplay test. The builder should report the created PK3 at build/caelum_argenteum_dev.pk3 and exit successfully. Its source default is src/.

The inspected builder rejects empty files, checks PNG signatures/dimensions, writes file entries with relative paths, checks the archive and replaces the output only after successful creation. It does not prove that the engine can load every resource or that game behavior is correct. Do not assume byte-identical PK3 archives merely because generated source outputs are deterministic; archive metadata also matters.

```powershell
.\run_dev.bat
```

The inspected launcher checks configured engine/IWAD paths, rebuilds through build_dev.ps1 and launches the resulting package. Its installation paths are machine-specific. Set them for the user's installation according to README; do not copy another machine's private absolute paths into shared guidance. Launch failure before build or engine startup is distinct from a game defect.

In a disposable test session, the following console commands directly load maps:

```text
map MAP01
map MAP02
```

Direct map loading tests startup, not normal campaign progression. Use an ordinary-player route when keys, quests, exits or persistent progression are in scope. Preserve the user's real saves and use copies for migration tests.

## Reusable project patterns

### Equipment size is a domain mapping

The inspected helper is CaelumEquipmentRules.GetDefaultSizeForCharacterTier(int). Existing callers include the Ronnie and magic trial quests. Character body tier and equipment-size enum are different domains; do not pass a body tier as an equipment size without this mapping.

The baseline helper clamps body tiers to 1–7 and maps 1–2 to XS, 3–5 to M, 6 to L and 7 to XL. This is a code observation, not permission to rebalance the mapping or add a missing S branch. Recheck the helper when implementing a later revision. Fit eligibility and default selection are separate operations.

For new recipient-sized MAP02 loot, consult issue #10 for the confirmed acquisition policy. Do not resize already-owned items on drop/re-pick or load. This requirement is planned; the helper's existence does not prove that all MAP02 loot already uses it.

### Economy has shared helpers

CaelumEconomy.zs contains RoundCopperUp and GetPriceChargedByMerchant. Inspect signatures and their callers before reuse. Do not confuse the merchant's selling price with buyback value or add a second markup. The rescue reward's T1/recipient-size rule belongs to issue #14 and SYSTEMS; this guide deliberately does not introduce a fixed reward amount.

### Visual reuse is not story-identity reuse

NPC visual sources and actor behavior are separate concerns. A recolored mansion character must not accidentally inherit its tutorial quest, anchoring or trade identity. Follow issues #13/#14 for the appearance/profile/escort division; planned escort behavior is not a proven reusable implementation yet.

### Generated files have a source

Identify the generator and input manifest before changing generated maps, catalogues or art. Commit the intentional source/output changes together. Re-run the affected deterministic generator and compare outputs. Do not regenerate unrelated accepted assets or execute every generator as a routine build step.

## ZScript and engine investigation discipline

- Prefer the project's working patterns and the target engine's supported API. Similarity to C++, C# or another scripting language is not evidence that a method, field or overload exists in ZScript.
- For an unfamiliar API, verify its declaration/signature against target-version engine sources or authoritative documentation and record the source. Do not label a remembered API as verified.
- Adding a class requires checking actual inclusion through src/ZSCRIPT and its dependency order, then compiling in the engine. Python validation alone is insufficient.
- Trace state transitions, actor ownership and save behavior before changing shared lifecycle code. Preserve existing schemas or implement the explicit migration required by AGENTS.
- For visual changes, verify in-engine transforms, pivot, layering and viewing scale. A guessed sign convention or an external mockup is not final evidence.
- For stalls, separate cold startup from repeated activation, loaded from empty state, and resource cost from repeated logic. Measure before naming a root cause.
- For physics, use the existing approved units and formulas. Animation, contact detection and damage application must be checked together; a moving mesh alone does not prove a functional mechanism.

## Evidence levels and minimal test selection

| Evidence | What it supports | What it does not establish |
| --- | --- | --- |
| Source inspection | Specific code/data facts at a commit | Runtime correctness |
| Static validator/build | Covered references, headers and packaging | Successful engine compilation or gameplay |
| Isolated engine test | Observed behavior under recorded conditions | Complete campaign acceptance |
| Author acceptance | The explicitly confirmed test and qualifications | Unrelated tests or every platform |

Record engine version, OS, renderer, IWAD, commit, config/mod list where relevant, fresh versus existing save, steps and evidence artifact. Linux/Freedoom development checks do not replace the target Windows/IWAD acceptance. No engine test was performed to create this handoff.

Choose tests for the actual change: visual assets need native captures; acquisition needs capacity/retry/persistence checks; stateful rewards need repeated interaction and travel/save checks; collision changes need traversal from relevant sides; broad map progression needs reachable-key and normal-route checks. Broaden tests only for an affected dependency or remaining risk.

pending_test.txt remains the only author-test queue. Only explicit confirmation moves a test to its originating HISTORY entry. Record failures and partial results accurately; a merge never means a manual test passed.

## Rules for maintaining this guide

1. Update it in the same issue/PR when a reusable development contract changes. No automatic append for every patch.
2. Keep design/balance in SYSTEMS, roadmap in PROJECT/TASKS, chronology and acceptance in HISTORY, attribution in ASSETS. Link instead of duplicating.
3. Add a pattern only after checking its declaration, at least one real caller and the appropriate evidence. State whether it is code-inspected or engine-tested.
4. Every technical addition names a path/symbol, baseline commit, scope and verification method. Put unresolved symptoms in KNOWN_PITFALLS, not as general engine laws.
5. Keep examples short and executable; label pseudocode explicitly. Never paste uncompiled speculative snippets as working recipes.
6. Use English UTF-8 documentation. Apply AGENTS' current language rules to source-code comments; this guide does not change them.
7. Revise superseded advice in place with a pointer to history. Preserve important qualifications; never silently promote a plan or hypothesis into a verified fact.
8. Keep model choice and provider prices out of this technical guide. A different AI should be able to use the same instructions and evidence.
9. Before merge, check links, paths, commands, consistency with canonical rules and validator coverage. Inherit README's version unless the integration issue explicitly adopts current-version headers for these guides.

## Sources and limitations

Inspected baseline: https://github.com/damiancurti/Caelum-Argenteum/commit/1dc390576fa330d37ff543526fc7e69a397fc28f
Workflow: AGENTS.md, build_dev.ps1, run_dev.bat, validate_project.py and the source paths above at that baseline. Open issues #8–#21 describe future work, not completed behavior. Later author confirmation makes MAP02 equipment and rescue price references T1 and character-sized, superseding earlier fixed-M/tier-pending wording. Integrators must reconcile that decision in current canonical documents.
