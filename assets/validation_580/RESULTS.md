# #414 connected-water feasibility — 5.8.0

Date: 2026-10-23. Scope: the issue's required isolated engine feasibility gate.
Production gameplay and campaign maps are unchanged from main a49631d1.
Only diagnostic release labels in CaelumPhysicalHazards/CaelumSewerMaze change.
This is not completed #414 or V5.8 gameplay.

## Native result

Eight GZDoom 4.14.2 runs on Windows 11 passed **100 assertions**, with zero
assertion failures, script errors or VM aborts in the selected final evidence.
They run unpaused in the background at 5% master audio. Configurations, engine
and package hashes, commands and logs are retained in `native/`; `report.json`
counts individual PASS lines rather than saved cumulative counters. Final static
project validation is clean; both PowerShell launchers parse, the fixture is
byte-deterministic, and all 16,806 final PK3 entries match current src bytes.

| Run | PASS | Coverage |
| --- | ---: | --- |
| feasibility-02 | 23 | Stable IDs; native closed/open boundary collision; conservation; stop/resume/equalization; isolated pool; immersion; thermal wetness; rest rejection; dry exit |
| save-01 | 3 | Closed gate and intermediate levels saved |
| load-01 | 11 | Saved intermediate levels/gate; no transfer while closed; resumed equalization |
| hub-01 | 17 | Independent second map starts with its own initial levels; return retains the original map's final levels and gate |
| flow-save-02 | 3 | Save during active transfer |
| flow-load-01 | 8 | Active transfer resumes from the saved intermediate volume and reaches equilibrium |
| visual-02 | 12 | Improved overview capture before/after; native initial/final checks |
| final-suite-01 | 23 | Rebuilt 5.8.0 package after diagnostic-label synchronization; same complete suite |

The fixture moves two equal-area horizontal swimmable 3D-floor control ceilings
through `Sector.MoveCeiling`. World heights are converted with
`SecPlane.PointToDist`. Initial heights 192/32 converge to 112/112, preserving
14,680,064 cubic map units. The isolated third volume remains at 64. These are
diagnostic data in `fixture.json`, not authored campaign dimensions or rates.
The map-local EventHandler stores a revision-1 binding, sector references and
gate state. Only the two connected sectors are visited during active transfer;
initial binding examines the fixture's eight sectors once.

`captures/levels-before.png` and `captures/levels-after.png` were visually
inspected. They show the closed division/different surfaces and the open shared
level. This is geometry verification, not an art approval or rendering benchmark.

## Explicit limitation and next implementation

The existing production quality reader returns **-1 (unidentified)** in the
fully submerged 3D-floor fixture, while its control sector declares **2 (salt)**.
Native immersion and thermal sampling work, but source identity needs explicit
control-volume lookup. No quality mixing assertion is claimed in this stage.

The author approved conservative contaminant union, the first installation next
to the mansion pool, and automatic filling/draining by the game calendar.
Exact geometry, inflow/outflow mechanism, capacities, rates and source quality
still need a concrete approved proposal. No offline real-time progression is
authorized. Production integration, migration and catch-up remain #414 work.

## Reproduce

From this focused worktree:

```powershell
python -X utf8 assets/validation_580/prepare.py
powershell.exe -NoProfile -ExecutionPolicy Bypass -File build_dev.ps1 -Destination build/issue414/current/caelum_argenteum_dev.pk3
powershell.exe -NoProfile -ExecutionPolicy Bypass -File assets/validation_580/run_native.ps1 -Label unique-suite -Checks -Script suite
```

Use a fresh label per run to preserve evidence. `save` creates
`ca414-partial.zds`; `load -LoadGame ca414-partial.zds` creates `ca414-final.zds`;
`hub -LoadGame ca414-final.zds` checks map return. `flow-save` and `flow-load`
use `ca414-flow.zds`. Generated PK3s, saves and development IWADs are not tracked
or release exports. Textures resolve from the existing project/development IWAD.
Two consecutive fixture builds produce identical bytes; the digest is in the
report. Production packaging contains only `src/`, never this test add-on.

Superseded attempts remain in the local build directory: feasibility-01 needed
a wait before the final queued event/quit; visual-01 had poor camera framing;
flow-save-01 was correctly rejected by the runner because its command lacked
an assertion/RESULT marker. These were fixture issues, corrected before the
selected final runs; they are not counted as passed checks.

## Author review

**Pending CA414-PROTOTYPE-01.** Run `author_terminal.ps1` and choose 1. F1/F2
open/close; F3/F4 enter a basin; F5 returns to dry ground; F6 prints levels; F7
shows an overhead view. Save/load through Escape. Terminal option 2 resumes a
private save without resetting levels or moving the character. The authoritative
outstanding steps are in the root `pending_test.txt`. No author pass is claimed.
