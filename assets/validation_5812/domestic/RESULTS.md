# Domestic cleaning — 5.8.12 / #502

Author acceptance: **CA502-HOUSEKEEPING-01 passed on 2026-10-25**, without
reported qualifications: "La prueba dio correcta, sigue con el resto."
This completes loaded-home cleaning, not #502 or V5.8 as a whole.

The delivered `domestic-final02` package has SHA256
`41db7950e5e4cab2d7ba6a56829e939e0602a5a2a47c77ba679aadb3d1943991`.
All16,901 members match source; maps and art match the prior objects-final03.
`report.json` records each run's exact package/fixture/log hash and counts
executed assertions rather than serialized cumulative counters.

## Validation

- Static project validation, document-index freshness and `git diff --check`
  pass (raw engine logs retain their original trailing spaces). The current release remains5.8.12; this is a continuation of the patch.
- **193 executed native PASS, zero FAIL** across16 selected runs. Native
  GZDoom4.14.2/Windows11 checks cover real city stock, parked shop identity,
  exact coffer payments/change, merchant credit, stock conservation, player
  funds excluded, partial affordability, full-coffer rejection, hidden metadata
  excluded, cloth/soap/water shortages and fractional soap weight/state.
- Actual floor/furniture cleaning, one shared daily quota, forward/backward
  dates, paid partial progress, native unattended movement/world time and
  accelerated personal time pass. Current saves, city/house return, genuine
  objects-final03 saves, idempotent migration and original-runtime rollback pass.
- Object, NPC, continuous contact and calendar core regressions ran on final01.
  The only subsequent runtime edit excludes hidden metadata from coffer storage;
  final02 covers that change through economy, controls, saves/hub and accelerated
  calendar checks. Their distinct hashes and this reuse limit are explicit.
- Automatic control logs show no-soap work stopping at20 seconds and53.33 floor
  contamination; after purchase, coffer funds fall393145→387325 and cleaning
  resumes. Restocking advances normally, so the shop's observed net reduction
  includes replenishment over elapsed time.

The author-facing fixture uses a real CAH000 household and the real original
MAP03 merchant, then seeds dirty surfaces and supplies for observation. F1 resets;
F2 prints; F3 removes diagnostic soap/disables restocking purchases; F4 buys;
F5 pauses the diagnostic routine. The detailed panel appears in the live menu.
There is no new scrubbing animation. A CUA screenshot confirmed the resident
and house; physical Escape stopped agent input before the planned F1 action.
The author then independently confirmed the test passed. Do not report that
stopped input as an agent-performed interactive demonstration.

## Rendering measurement

Matched CAH000, four native residents, normal AI/collision,1280x720 Vulkan,
60FPS cap, unpaused background,5% audio, Ryzen5950X/RTX3070Ti:

| Measurement | Prior objects-final03 | domestic-final02 |
| --- | ---: | ---: |
| RenderOverlay callbacks | 1199 | 1200 |
| Mean interval,ms | 16.666 | 16.666 |
| p95,ms | 16.979 | 16.930 |
| p99,ms | 17.182 | 17.104 |
| Worst,ms | 18.608 | 17.787 |
| 700-tic observed phase,ms | 20066 | 19937 |
| Whole soap remaining,g | 300 | 273 |

These are renderer callback intervals, not displayed-frame/GPU measurements.
PresentMon capture was unavailable in the recorded environment (see objects
evidence). Phase boundaries have100ms polling uncertainty. Samples start after
initialization; they do not establish cold-load or whole-campaign performance.
No artificial army or retired6,000-combatant stress case was run.

## Reproduction and limits

Run `prepare_domestic.py`, build an immutable current runtime, then use
`run_native.ps1` with the scripts/arguments preserved in `native/*-run.json`.
`author_domestic_terminal.ps1` offers the accepted manual scene and focused checks.
`domestic_performance.py` generates the identical before/after diagnostic setup.
PK3s, engine, IWAD, save files and diagnostic maps are not distributed here.

Earlier development failures remain in ignored `build/issue502-hygiene` evidence:
missing NPC UseRange, fixture null/format errors, case-insensitive local Chest/Day
shadowing, and parked merchant restoration before Travelled. The interactive
replenishment check exposed metadata consuming a cargo slot; final02 fixes it.
See CA-KP-169. PowerShell execution-policy/preflight errors did not run engines
and are not counted as native results.

Loaded-house only: no historical work is invented while its map is absent.
Actual shops must have been initialized by visiting MAP03. Exact-date resource
forecasts refuse mutable household scenes; ordinary waiting remains supported.
Unloaded-house work/history, non-solid or stackable-object exposure and remaining
contact adapters stay in #415/#502. Separate treatment/toilet author checks stay
in the root queue; this acceptance does not silently retire them.
