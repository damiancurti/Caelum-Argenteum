# Issue #183 — 5.2.4 validation

Tested on 2026-10-11 with native Windows GZDoom 4.14.2, against base
`d313c227`. These are agent checks; author acceptance remains CA183-01 in
`pending_test.txt`. The author explicitly requested fresh test games and waived
earlier-save migration. New-version partial rewards, hub travel and reloads are
tested. No engine, IWAD, package or save is distributed here.

## Passing native checks

| Runs | Scope |
| --- | --- |
| `matrix-03` | All 64 race/ordered-class recommendations spend +4/+30 legally; family fallback and necklace priority; all 50 profession/size kits; Box endpoints 30/100; aggregate chest budget. |
| `capacity-02` | 384 ordinary race/class/sex/height profiles receive every gift and can carry the raw lesson reward. Independent native recipe oracle verifies armor ×1, weapon ×3, pickaxe/staff ×5 and five manufactured replacement bolas. |
| `journey-final` | Native gold depletion, partial/one-time exchange, bag/Seal/canteen transactions and cancellation, no replay repair/duplicates; real native hub transition preserves item IDs, wear, water, Fool deck and ammunition; all 39 finite chests; refuge armor repair; five replacement bolas manufactured from the budget. |
| `reload-final2` | MAP02 save/load preserves exact utility references, contents, deck/ammo and exhausted chests. |
| `partial-final`, `partial-reload-final` | Save/load during a partly claimed reward preserves paid gold, depleted rock and remaining grant; subsequent collection cannot duplicate it. |
| `endurance-final` | Actual forecast and full native time-skip execution for all three crafts: bag 4,179.331307 s, Seal 16,717.325228 s, canteen 208.966565 s. Native food/water planning succeeds; duplicates reject before payment. |
| `creator-es-final`, `creator-en-final` | Native menu input, localized activities/profession names, editable recommendations/refund, back/reopen draft persistence and confirmation. |
| `dialogue-es-release`, `dialogue-en-final` | Native Palomo Seal-only root/effects and gold-swindle exchange in both languages; Bull death produces no leather. The release log prints the corrected Spanish Bull notification; release captures record the displayed UI. |

Each final run reports zero `CA183 FAIL` markers and reaches its completion
marker. `runs.json` records original log hashes, package hashes, engine hash,
arguments and timing; normalized readable logs are in `logs/`. Later production
packages differ from early matrix/journey packages only where follow-up fixes
required their own targeted checks. Fixtures and preparation/launch scripts are
included so the final source can be repackaged and rerun.

The journey fixture seeds previously accepted social/magic/combat/Fool
milestones and uses controlled mining strike power. It exercises real inventory,
crafting, reward, chest and travel transactions; its individual task clocks are
accelerated. `endurance-final` separately executes all three full crafting times.
Chest collection tests normal capacity/partial withdrawal; the subsequent repair
fixture puts collected material totals into the Box to avoid manufacturing an
unrelated personal-overload failure. This is isolated engine evidence, not a
claim that a human completed every tutorial encounter or traversed the maze.
Native runs use isolated configs, background execution and 5% audio.

## Static checks

- `check.py`: 13 checks, zero failures. Every vertex, sector, sidedef and linedef
  equals the issue base. Only four armor-workshop things are added; original
  things, drop carriers, positions and quantities remain. Map and dialogue-history
  generation are byte-for-byte deterministic.
- `supplies-audit.json`: 547 checks, zero failures. All 600 allocated rounds are
  preserved as 360 arrows and 240 bolts. `ammunition-audit.json` records the
  before/after allocation ledger. The historical 65-equipment ledger remains
  provenance, not the current character-dependent material budget.
- `validate_project.py`: version 5.2.4, zero errors. Document index regenerated;
  `build_dev.ps1` succeeds with 6,318 files. `git diff --check` passes.

`layout-audit.json` retains a **nonpassing legacy audit: 129 of 213 checks fail**.
Its revision-3 single-floor pathfinder does not model the already accepted
revision-4 flooded return network/3D floors. These failures therefore cannot
establish current native traversability. The targeted delta audit proves that
this patch retains all baseline geometry; native checks cover the affected
refuge station/repair transaction. No maze-wide movement acceptance is inferred.

## Preserved diagnostics

Earlier logs are retained, including corrected compile errors, the initial
bolas budget mismatch (resolved by the author's replacement-crafting decision),
fixture time-skip menu state, insufficient station setup, personal-overload
setup and absolute save-path errors. Early dialogue captures marked `initial`
show a stale Bull leather notification, corrected in the final localized
captures. These diagnostic runs are not counted as passing evidence.

## Reproduction

Run `python assets/validation_524/prepare.py`, then invoke `run_native.ps1` with
an unused `-Label`, the selected `-Fixture` and matching `-Script`. Configure
local `-Engine`/`-Iwad` paths as needed. For reload use `-Fixture journey`,
`-Script reload.cfg` and the saved **basename**, such as `ca183-journey.zds`.
`partial.cfg` selects partial-reward save creation. Creator/dialogue checks use
`-Language es` or `enu`. `archive.py` preserves new run metadata and logs.
