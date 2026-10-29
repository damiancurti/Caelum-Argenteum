# Constant Limbo object-exposure history — 5.8.23 / #502

Objects now retain the last valid constant Limbo exposure interval across native
save restoration and hub absence. The first read or explicit cleaning settles
that interval before using the stored concentration. The existing analytical
solver, contact rates and exposed area remain authoritative. Revision-1 saves
retain their concentration and start history now; no retrospective dirt is added.

This is a limited production continuation, not completion of #502. Historical
exterior weather, temporary climate effects, NPC physiology, unloaded household
cleaning and remaining stackable/contact adapters are still pending. No new
global scan, actor registry, per-tic scheduler, artwork or map edit is introduced.

## Static and package evidence

- `validate_project.py`: zero errors; documentation index regenerated.
- Official `build_dev.ps1` output `final23` SHA256:
  `d139789ce6aec44d9c4bd05a96d104344ee87e8c183df51a5adbf5d3b9a9c0b6`.
- All 16,962 members equal current `src`; all 14,026 map/model/sprite/graphic
  members equal the prior official 5.8.22 package. Four source members have
  substantive changes (two runtime files and two version diagnostics). Two
  inherited bathroom source files differ only by checkout CRLF/LF endings.
- `collect_evidence.py` verifies hashes, source equality, each executed PASS,
  failures, run exit codes and test provenance. Saved cumulative counters are
  not summed. Native save files remain local test evidence, not shipped assets.

## Native GZDoom 4.14.2 checks

78 executed PASS, zero FAIL in nine selected runs: 13 core invariants; four
hub checks; three previous-version migration checks; one current save seed and
three restored-save checks; ten author-fixture checks; 42 existing object/rain/
pickup/storage regressions; two original-version seed/rollback checks.

Coverage includes idempotence, backward clocks, retaining dirty concentrations
above clean ambient, no constant snapshot for variable climate, query-before-tic
settlement, cleaning order, actual hub actor identity and preserved saved fields.
The final core settles ten years in about 0.0094 ms in this recorded run, using
one analytical operation rather than a loop over elapsed seconds.

The private author demonstration uses an existing first-floor mansion sink.
It records 0.000 before leaving and 15.750 after half an hour away, matching the
captured ambient value. Native collision checks and before/after screenshots
verify the viewpoint and fixture. Normal controls are loaded; the final game
and console stay open when launched interactively. Earlier chair-camera probes
had an occupied viewpoint and an unsuitable view; they are retained in local
build evidence and excluded from delivered author instructions. No production
geometry or artwork was changed to accommodate a diagnostic.

## Matched performance comparison

Same private peaceful 1,000-solid-object scene, 700 tics, 1280×720 Vulkan,
60-FPS cap, unpaused background and 5% audio. All 1,000 receivers were exposed.

| Measurement | Official 5.8.22 | Final 5.8.23 |
| --- | ---: | ---: |
| RenderOverlay mean interval, ms | 16.6684 | 16.6663 |
| P95 interval, ms | 16.9875 | 16.9185 |
| P99 interval, ms | 17.4085 | 17.5615 |
| Worst interval, ms | 18.2886 | 18.0299 |
| 700-tic phase, seconds | 19.9366 | 20.0341 |
| One initialization census, ms | 1.0553 | 1.0186 |

Phase-bound polling uncertainty is ±100 ms. Callback intervals describe renderer
cadence, not GPU time or displayed frames. PresentMon trace access was denied;
this is not whole-map, campaign, siege or displayed-60-FPS acceptance. The narrow
comparison shows no material regression in these recorded conditions.

## Author status

`CA502-LIMBO-HISTORY-01` is pending in root `pending_test.txt`. The author is away;
the terminal helper is prepared but has not been launched for author review.
No pending test was retired and no issue closure or release completion is claimed.
