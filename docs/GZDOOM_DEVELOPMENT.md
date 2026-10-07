# GZDoom development guide — Caelum Argenteum

Status: integrated engineering reference (issue #22, patch 4.36.1b).
Prepared: 2026-09-23. Inherits the project's release after integration; this is not a new game release.
Source baseline: PR #7, commit `1dc390576fa330d37ff543526fc7e69a397fc28f`.
Target: GZDoom 4.14.2 on Windows 11. Observations below are scoped to that baseline unless stated otherwise.

## Purpose and authority

Give a new contributor or AI enough technical orientation to work without reconstructing the conversation or loading the entire history. This document transfers explicit project knowledge, not model training or a guarantee of correctness.

Read the current root AGENTS.md and docs/CONTEXT.md first. Then read the assigned issue, this guide's relevant sections, the canonical specification and actual consumers. Current author decisions define intended behavior; source inspection establishes implemented behavior. Report differences instead of silently changing either side. This guide does not supersede AGENTS, invent balance or authorize unrelated work.

The author explicitly requested these additional documents, satisfying AGENTS premise 7's exception for new permanent guides. They are registered in AGENTS, README, CONTEXT and validate_project.py, and inherit README's current release without duplicate version headers.

## Fast task startup

1. Identify the repository, branch, exact HEAD and local changes. Preserve unrelated work.
2. Read the issue's objective, exclusions, dependencies and acceptance criteria. A planned feature is not an implemented feature.
3. Locate the authoritative data and one existing implementation with the same responsibility. Search for the symbol and its consumers before editing.
4. Establish what is reproducible. Record the original error or observable behavior before proposing a fix.
5. Change the smallest coherent unit, update its sources/generated outputs together, and perform the affected checks.
6. Report the commit, scope, evidence, limitations and outstanding author tests. Review and acceptance are separate stages from implementation.

Do not read all of HISTORY.md by default. Search its relevant headings or issue/test IDs. Do not translate or rewrite the canonical documentation again to perform a small patch.

For any maintained doc under docs/ with strictly more than 5,000 words, query [DOCUMENT_INDEX.md](DOCUMENT_INDEX.md) first and extract only the relevant source ranges (see its header and `build_document_index.py`). Small documents may be read directly; full-document review remains appropriate when the task requires it.

## Selective reading examples

These examples apply the policy from `AGENTS.md`; they are illustrative and are
not claimed as executed evidence. Commands are PowerShell. `rg --files` lists
paths without printing contents, `rg -n` prints matching lines with line
numbers, and `-B`/`-A` add neighboring context. Angle-bracketed values are
placeholders: substitute the real path or range for the current task.

Code issue: find a repair rule and read only the affected code.

```powershell
rg --files src/caelum/equipment
rg -n "repair" src/caelum/equipment
rg -n -B 2 -A 30 "CaelumRepairRules" src/caelum/equipment/CaelumCraftingRules.zs
```

Read the reported ranges first; follow callers, initialization, persistence or
shared rules only when the change requires them.

Long document: locate the current repair contract without loading all of
`docs/SYSTEMS.md`.

```powershell
python build_document_index.py list "repair"
python build_document_index.py read SYSTEMS.md <start> <end>
```

Replace `<start>` and `<end>` with the returned inclusive range, and confirm
the index is fresh first (`python validate_project.py` reports stale hashes or
line numbers).

Failed test log: start with a targeted filename search, then read the relevant
excerpt before the whole artifact.

```powershell
rg --files build | rg "validation|RESULTS|log"
rg -n "FAIL|ERROR|unresolved" build/<current-task-log>
```

Inspect the surrounding lines, then open the full log or captures only when
that excerpt does not explain the failure. Report the offending lines instead
of pasting the whole artifact.

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

Issue #17 / 4.36.28 adds `build_playtest.py --ref <commit> --output <directory>`
for release exports. At `fa6fb9bb`, `committed_files` reads raw Git blobs with
`cat-file --batch`; it does not depend on checkout line endings or `git archive`
conversion. Fixed metadata and stored ZIP entries make repeat exports identical.
The independent `assets/validation_43628/verify_export.py` compares every runtime
member to `git ls-tree` blob IDs, verifies SHA-256 coverage and checks the delivery
allowlist. Native startup/save/reload evidence remains distinct from ordinary
campaign acceptance. Keep the normal development builder and legacy map modes.

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

### Continuing campaigns after a map rebuild

Issue #77 distinguishes four MAP06 geometries. A normal build selects the
960 m southern city. `-LegacyMap06NorthCity` / `--legacy-map06-north-city` selects
the exact first 4.37.9 northern city; `-LegacyMap06Siege` / `--legacy-map06-siege`
selects the 4.36.27–4.37.8 siege port; `-LegacyMap06` / `--legacy-map06` keeps the
pre-siege 4.36.26 port. Select the layout already visited, including stored hub
maps. The three legacy port modes are mutually exclusive and each can accompany
the separate legacy MAP02 option. Keep original saves/packages for rollback.
The legacy_4378 and legacy_4379_north provenance files preserve exact sources.
Current native repeated-load/rollback evidence is in validation_4379/south.

The new controller's saved map argument marks layout revision 2; older maps keep
their original deployment data. SetupRevision prevents redeployment after load.
New defender waypoint fields default inactive in legacy saves and activate only
for the new layout. Preserve both the physical map and the matching coordinates;
updating a global coordinate table alone would silently misroute old actors.

The #77 group-cap follow-up changes only the ordinary command rebuild. Its
100-member limit includes the leader; existing saved memberships converge on
the next 35-tic/death-triggered refresh without replacing actors or save fields.

Programmatic traversal tests must retain native vertical velocity when advancing
engine tics. Resetting all three velocity components each tic can suspend a
descending player above the next tread. A collision sweep with explicit floor
settling and an actual-tic traversal test provide different evidence; label both.

For issue #11, `run_dev.bat --legacy-map02` rebuilds current code with the
preserved 4.36.4 MAP02. The equivalent builder switch is `-LegacyMap02`.
Keep this mode for a campaign that has already visited the old maze, including
saves currently in another hub map. A normal build selects the new layout.
Both modes keep the established package name and map IDs. This is reversible
build selection, not an automatic geometry migration; preserve save copies.
See CA-KP-008 and the README for the checksum constraint and tested scope.

## Reusable project patterns

### Equipment size is a domain mapping

The inspected helper is CaelumEquipmentRules.GetDefaultSizeForCharacterTier(int). Existing callers include the Ronnie and magic trial quests. Character body tier and equipment-size enum are different domains; do not pass a body tier as an equipment size without this mapping.

The baseline helper clamps body tiers to 1–7 and maps 1–2 to XS, 3–5 to M, 6 to L and 7 to XL. This is a code observation, not permission to rebalance the mapping or add a missing S branch. Recheck the helper when implementing a later revision. Fit eligibility and default selection are separate operations.

Issue #10 implements `CaelumEquipmentItem.SizePolicy`: `CHARACTER_DEFAULT=1`
is the default for natural world/reward equipment; `FIXED_SIZE=2` is an explicit
authoring override. This policy is separate from editor `args[0]` (0 still
defaults to M) and resolved EquipmentSize (enum 0 is XS). Use the nonmutating
Preview methods for inspection and the shared native pickup transaction for
collection. Resolve size-dependent capacity before assigning identity. An old
failed pickup can have ItemId/PickupDataInitialized without ever being acquired;
neither alone proves ownership. Temporary BecomePickup flags on container loot
must not turn that state into acquired equipment. Revision 1 preserves acquired
size/wear and serializes retired unclaimed MAP02 T2/T3 for reversible migration.
Crafting, merchant stock and explicit debug selection keep their own rules.
See CA-KP-002 and the 4.36.4 native evidence for tested boundaries.

### Economy has shared helpers

CaelumEconomy.zs contains RoundCopperUp and GetPriceChargedByMerchant. Inspect signatures and their callers before reuse. Do not confuse the merchant's selling price with buyback value or add a second markup. The rescue reward belongs to issue #14 and SYSTEMS; the latest author decision is a fixed 25 gold, independent of this equipment-sizing policy. The former weapon-price average is superseded.

### Visual reuse is not story-identity reuse

NPC visual sources and actor behavior are separate concerns. A recolored mansion character must not accidentally inherit its tutorial quest, anchoring or trade identity. Follow issues #13/#14 for the appearance/profile/escort division; planned escort behavior is not a proven reusable implementation yet.

### Generated files have a source

Identify the generator and input manifest before changing generated maps, catalogues or art. Commit the intentional source/output changes together. Re-run the affected deterministic generator and compare outputs. Do not regenerate unrelated accepted assets or execute every generator as a routine build step.

### Persistent narrative observes completed gameplay events

`CaelumDemoNarrative` (#34 / 4.36.22) keeps pending/delivered events in the
travelling character Inventory. Observe successful state transitions, especially
reward delivery, and let the current native conversation finish before opening
another. `ConversationNPC` can remain non-null after closure: use
`HasActiveConversation()` to distinguish a live dialogue from that retained pointer.
UI formatting reads snapshots; gameplay state changes remain in play scope.
For encounter reactions, latch authoritative health states before healing, and
clear only on a new attempt. Older saves cannot supply damage history they never
recorded. Validate both state/queue logic and rendered native menu closures;
directly invoking an action does not exercise the complete presentation path.

#78 reuses existing USDF pages with `userstring` presentation tags, preserving
global saved node indexes. `CaelumSiegeIntelligence` formats the same quest and
calendar information for dialogue and Journal without writing state in UI scope.
Its native checks include an old save made with the paid conversation open and
an active conversation changing to completed text; see validation_43710.

For a narrative clue added to the fixed-capacity quest record, reserve a new ID
and migrate only that slot once; do not infer dialogue knowledge from map visits.
When increasing QUEST_DEFINED_COUNT, audit category ranges such as IsRescue rather
than treating every later ID as a prisoner. #79's native old-save, open-page and
hub tests cover this extension and its derived Journal arrays; evidence is in
assets/validation_43711. Keep conversation pages appended to preserve older indexes.

## ZScript and engine investigation discipline

- Prefer the project's working patterns and the target engine's supported API. Similarity to C++, C# or another scripting language is not evidence that a method, field or overload exists in ZScript.
- For an unfamiliar API, verify its declaration/signature against target-version engine sources or authoritative documentation and record the source. Do not label a remembered API as verified.
- Adding a class requires checking actual inclusion through src/ZSCRIPT and its dependency order, then compiling in the engine. Python validation alone is insufficient.
- Trace state transitions, actor ownership and save behavior before changing shared lifecycle code. Preserve existing schemas or implement the explicit migration required by AGENTS.
- Scenery represented by an Actor is not combat provenance. In #49 over
  f064f92, CaelumPlayer classifies scenery actor impacts as environmental;
  stationary-rock eligibility is sampled before impulse changes its velocity.
  Isolated callback, native wall and save evidence is in assets/validation_43621.
- For a retreat toward a solid travel gate, validate both the approach volume
  and a start outside the arena. In #33 (4.36.20 over baseline `245d3bb5`),
  `CaelumZupayColossus` uses native attack-free `A_Chase` at the existing
  cadence and completes within one step of gate contact, with sight and height
  checks. Arena/corridor and saved-retreat evidence is in
  `assets/validation_43620/RESULTS.json`; author acceptance remains separate.
- For visual changes, verify in-engine transforms, pivot, layering and viewing scale. A guessed sign convention or an external mockup is not final evidence.
- For stalls, separate cold startup from repeated activation, loaded from empty state, and resource cost from repeated logic. Measure before naming a root cause.
- For physics, use the existing approved units and formulas. Animation, contact detection and damage application must be checked together; a moving mesh alone does not prove a functional mechanism.

## Evidence levels and minimal test selection

### Architecture extraction and native timing (#116)

At baseline `20143c31`, #116 uses
`assets/validation_500/verify_extraction.py` to compare pawn field declarations,
method signatures and the moved method bodies after removing only explicit pawn
qualification. It also checks package-member changes. This static proof supports
the narrow move into `CaelumPlayerPresentation`; it does not replace native
compilation, semantic projection checks or current save/reload. The same native
contract checks run against original and extracted implementations. The author
waived older-save compatibility for this issue, not ordinary current-save operation.

For the MAP06 benchmark, `benchmark.zs` is a separate observation addon, never a
production include. `Object.MSTimeF()` supplies wall milliseconds;
`WorldTick` samples `level.time` and real population, while `RenderOverlay`
records callback intervals. Do not call either simulation throughput or overlay
intervals GPU frame time. The latter includes simulation stalls and instrumentation.
Input observation needs a separate timestamped route; visual sluggishness alone
does not quantify device-to-photon latency.

Native `profilethinkers -t 20` reports a **single simulation tic**, sorted by total
class time, in milliseconds. Several scheduled samples identify expensive actor
classes but do not isolate the cost of target search, collision, state actions or
rendering. The verified implementation is GZDoom g4.14.2
`src/playsim/dthinker.cpp`; API declarations are in the installed
`gzdoom.pk3:zscript/engine/base.zs` and `zscript/events.zs`.
Commands, hashes, hardware, actual native resolution, initial/final INI and raw
logs are recorded with the #116 evidence. Requested window dimensions can differ
from the renderer's reported resolution; record the latter. Keep audio enabled
with the author-requested 5% master volume for subsequent live tests unless a
specific test requires otherwise.

#118's runner rejects overlapping GZDoom processes and waits for each recorded
PID to exit. Its isolated benchmark observer consumes local input events, so a
stray movement key cannot change the fixed scene. Compare all sampled positions,
population and group counts before comparing timings; discard overlapping or
camera-drift samples, as recorded in `assets/validation_502/RESULTS.json`.
These controls belong to the observation addon, never to production input code.

For #121 and subsequent Windows measurements, explicitly set
`i_pauseinbackground=false`, `vid_activeinbackground=true` and
`vid_lowerinbackground=false`. The second setting enables rendering, not
simulation. Keep `i_soundinbackground=true` and `snd_mastervolume=0.05` for
the requested audio condition. Record the values read by the running engine,
initial/final configuration and any menu or focus intervention. A minimized
window continuing to render is not itself proof that `level.time` advances.

The #121 probes wrap original methods only in ignored diagnostic packages.
`verify.py` removes the known instrumentation and compares original body tokens
and field declarations. The main timer samples every 37th tic with a nested
stack: inclusive scopes contain their children; exclusive scopes subtract
instrumented children. Uninstrumented work and probe overhead remain inside
the enclosing scope. Sparse periodic operations need separate burst evidence;
a short coprime sampling window can still miss an operation entirely.
`eventprobe.pk3` therefore records every command-election, lane-refresh,
crew-refill and cannon-target call. It is a separate diagnostic run.

GZDoom 4.14.2 also exposes `stat sight`, `stat rendertimes`, `bench` and
`stat gpu`. `bench` appends native rendering **CPU-side** timing and scene
counts to `benchmarks.txt`; preserve each run's byte range before the next run.
`stat gpu` uses Vulkan timestamp query ranges on this hardware, with a wait
when retrieving results. Capture that overlay in separate runs and preserve
the screenshots; GPU ranges may nest and are not whole-frame/presentation time.
The Vulkan range call sites inspected for #121 cover selected postprocessing
effects. The default scene produces an empty GPU listing; enabling only FXAA
in a separate control exposes its range (0.75–0.76 ms), not scene GPU time.
Do not infer zero GPU cost from an empty listing or rename CPU `All` as GPU time.
The implementations are `src/playsim/p_sight.cpp`,
`src/common/rendering/hwrenderer/data/hw_clock.cpp`,
`src/common/engine/stats.h` and
`src/common/rendering/vulkan/system/vk_commandbuffer.cpp` at tag `g4.14.2`.

For #128, `assets/validation_506/prepare.py --baseline` reconstructs the pinned
5.0.5 baseline and the first experimental source commit, then packages current
`src/` separately as `production.pk3`. The historical `current-a/b` labels mean
the first staggered experiment, not the selected production implementation.
`prepare_checks.py` emits isolated native maps, work counters and full-search
guard/cannon oracles. `run_suite.ps1 -Labels label-a,label-b` runs normal-combat
comparisons serially; `run_validation.ps1` handles boundary/save/travel/oracle
checks. All runners reject overlapping engines and preserve unique labels.
Use a fresh ignored work directory for a complete replay, and retain the old
save identified by SAVE_IDENTITY for the historical upgrade/rollback route.
The functional fixtures can create their own new saves on any clean checkout.

`summarize.py`, `verify_native.py` and `verify.py` summarize completed native
evidence, check exact target/random-stream traces and compare final package
content with source. `cannon_study.zs` compares 96 target selections and the
native `CheckSight` RNG stream; an invisible uncompetitive candidate can still
consume that stream. Never assume all native visibility calls are pure.
After closing the engines, `verify_reproduction.py` builds the diagnostic
packages twice and checks their byte hashes against the final native runs;
`REPRODUCTION.json` separates those exact identities from the first Windows
experiment's line-ending differences, retained in EXPERIMENT_MANIFEST.
`keep_awake.ps1` makes a bounded thread-local execution-state request without
editing the power plan. Start it hidden, create `build/issue128/release-awake.signal`
after testing, and retain the returned release result and before/after plan.

Reproduce #121 with `python assets/validation_505/prepare.py --from-git`, then
`powershell -NoProfile -ExecutionPolicy Bypass -File assets/validation_505/run_suite.ps1`.
The preparer uses the pinned accepted commit and verifies a canonical runtime
content fingerprint; a rebuilt ZIP may have different metadata/line endings
from the original recorded package. Engine and IWAD paths are parameters of
`run_native.ps1`; neither binary, saves nor generated packages are distributed.
Run packages serially, with unique labels. Keep input/camera fixed, compare
scene rows, and distinguish ordinary observer overhead from the deliberately
different formation and shared-perception workloads. `summarize.py` produces
the measured windows and `verify.py` checks the source boundary.

`guard-check.pk3` retains an every-call full-population oracle alongside the
spatial broad phase; any `CA121 GUARD_MISMATCH` invalidates that check. Its
timings are not the spatial-query speed measurement. Run the query-only package
separately. Likewise, assess the cannon retry alone before combining it with
shared targeting or formation: movement changes which negative searches repeat.
The eight-tic diagnostic retry reuses `TARGET_UPDATE_TICS` but intentionally
changes acquisition latency, so it must not silently enter production.

For an unattended session, launch `assets/validation_505/keep_awake.ps1` in a
hidden PowerShell process. It makes a bounded Windows execution-state request,
not a power-plan edit. Finish by creating `build/issue121/release-awake.signal`,
wait for the helper to exit and inspect `power-request.json` for successful
release and equal before/after plan identifiers. Preserve prior markers/evidence
under distinct names before a new session; never overwrite a previous result.
An execution-state request does not defeat an explicit user sleep command.

For inventory extraction, distinguish detached incoming pickups from an existing
owned stack. Validate `Owner` before mutating either pointer; resolve instance IDs
inside the requesting pawn's native inventory. #118's stateless service retains
the original saved fields and coordinator preconditions, and its verifier checks
every moved body/literal, explicit guard, unchanged body and package member.
This proof supplements native transaction/save/travel checks; it does not prove
arbitrary low-level commit calls are valid without their coordinator's checks.

#119 retains the Tarot record and adapters and checks all 936 card/attribute
contributions on both packages. Its native non-hub travel exposed a missing
PowerFlight instance despite a positive saved effect timer; CA-KP-040 records
the idempotent restoration and old-save regression test.
For UI evidence, GZDoom's internal `screenshot` command can capture the world
without the native menu layer even while `Menu.GetCurrentMenu()` reports the
correct open menu. Inspect an actual target-window capture before claiming
menu rendering or interaction. The #119 window evidence also exercises native
card-selection/confirmation keys after old-save loading.
When synthesizing an anchored NPC, set its canonical spawn argument before
deferred PostBeginPlay; setting only the derived `StoryAnchored` flag is reset
by initialization. Require the intended save file and post-load event in the
log before treating an automated startup schedule as completed persistence QA.

#120 distinguishes a current native player pawn from a merely non-null actor:
use the explicit receiver contract, then verify canonical record/item/preview
ownership before mutation. Native event player slots must be checked before
array indexing; never use a local-player fallback in domain commands. Preserve
read-only lookup during prediction, while rejecting writes and query helpers
that initialize/refresh authoritative state.
Its two-player fixture uses native `addbot` and actual PlayerInfo/pawn slots.
On Windows GZDoom reads `zcajun/bots.cfg` under the executable directory; a
test-only copy of the installed engine can supply this file without modifying
the installation. Assert that a second participant actually joined before
claiming owner isolation. This one-process fixture proves neither two-client
transport nor join/reconnect/respawn/session behavior. The existing world-clock
single-participant gate must remain documented as an unsupported shared-time
boundary, not quietly removed to make a test pass.

### Evidence categories

For #117, `assets/validation_501/verify_extraction.py` additionally retains quoted
literals in body comparison and checks all nonmoved methods. The two stateless
services preserve pawn fields and method signatures; native baseline/final fixtures
compare profile/resource output and save data, then exercise hub travel. When
loading the old fixture with new code, preserve the package basename recorded by
the save (`current-runtime/baseline.pk3` holds the new bytes). GZDoom rejects a
missing basename before compatibility can be tested. Record package hashes so
this staging convention cannot be mistaken for loading the old implementation.
Synthetic equipment must declare its intended `WeaponDurabilityRevision`; leaving
it at zero correctly invokes the existing legacy migration and is not an extraction
regression. Keep fixture corrections separate from production fixes.
The #117 native UI fixture uses real menu methods to produce a draft, then a
console map start to exercise its consumption. `Menu.StartGameDirect` requires
`DMenu::InMenu`, which native menu input callbacks establish; invoking the final
introduction action from `EventHandler.ConsoleProcess` aborts even while a menu
is displayed. This was verified in GZDoom g4.14.2
`src/menu/doommenu.cpp:StartGameDirect` and `src/common/menu/menu.cpp` callbacks.
Do not claim that scripted console calls cover the physical final menu keypress.

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
9. Before merge, check links, paths, commands, consistency with canonical rules and validator coverage. This guide inherits README's current release and carries no duplicate version header; update it in the same patch that establishes or changes a reusable lesson.

## Sources and limitations

Inspected baseline: https://github.com/damiancurti/Caelum-Argenteum/commit/1dc390576fa330d37ff543526fc7e69a397fc28f
Workflow: AGENTS.md, build_dev.ps1, run_dev.bat, validate_project.py and the source paths above at that baseline. Open issues #8–#21 describe future work, not completed behavior. Later author confirmation makes MAP02 equipment and rescue price references T1 and character-sized, superseding earlier fixed-M/tier-pending wording. Integrators must reconcile that decision in current canonical documents.
