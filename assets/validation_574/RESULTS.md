# 5.7.4 - Fixed Alchemy station (#470)

Infrastructure adds the approved 3D fermentation table/still at MAP01
(1128,448,0) and MAP03 (-656,1472,0), with 60 x 60 x 72 collision. Station ID
12 and editor ID 18013 append; existing recipes, learning and task ownership
remain intact. No new recipe, fuel or construction balance is introduced.

Static project validation passes (13 station models, CONTEXT 2499 words).
Two full regenerations preserve all four generated-output hashes. Final native
evidence: **216 PASS / zero FAIL in 15 selected runs**. Author check CA470-01
passed on 2026-10-22. No gameplay VM/parser failure occurred in this patch's tests.

The final package is `2a23c2b418598ec352f027ac1cfb0d08a963e85bdd5d023773413bfaf4b1fd77`;
all 16,458 members match the tested source tree. The selected runs cover:

- Inclusive/exclusive 128-unit, vertical/diagonal, group, transitive and cycle boundaries.
- Existing seven recipe families, discovery, reservations, efficiency, pause,
  cancel, completion and duplicate-output rejection with Alchemy connected.
- Real 5.7.3 MAP01/MAP03 save upgrades, upgraded reload and retained original files.
- Three travel visits, current saved tasks and an old task's exact inventory authority.
- Blocked installation, saved retry, unblock, removal without respawn and reload.
- Real Use opening the shared catalogue in both approved placements; visible captures.

The only new production typed census finds the map-owned installation roster
once per supported map load, with 0-1 results; the cached pointer is invalidated
on WorldLoaded. Retries use that pointer and local collision checks, never a
world census. The largest measured 1,000-lookup batch was 8.950 ms in peaceful
MAP03 with its 600 housed defenders, giving a conservative 8.950-ms bound for
any one lookup in that batch. Normal network traversal uses BlockThingsIterator.

| Peaceful view | Runtime | Callback mean ms | p95 ms | p99 ms | Worst ms | 1,000 network scans ms |
| --- | --- | ---: | ---: | ---: | ---: | ---: |
| MAP01 workshop | 5.7.3 | 16.666 | 17.132 | 17.490 | 20.069 | 28.834 |
| MAP01 workshop | 5.7.4 | 16.666 | 17.665 | 18.510 | 22.775 | 7.857 |
| MAP03 workshop | 5.7.3 | 16.667 | 17.425 | 17.872 | 18.723 | 15.088 |
| MAP03 workshop | 5.7.4 | 16.666 | 17.429 | 17.977 | 19.199 | 0.773 |

Each single 15-second window contains 899 render intervals at approximately
60 callbacks/s and 35 simulation tics/s. The mansion tail is higher in this
sample; no frame-rate improvement or whole-map performance acceptance is
claimed. Network timings occur before the frame window.
The final `report.json` records each package, fixture, config, environment,
selected assertion count and log hash. Packages, private saves, generated
test maps, the development IWAD and engine are not distributed.

`prepare.py` reuses frozen #405 room geometry and the #376 crafting checks;
the current fixture adds Alchemy to that suite's station network. The baseline
fixture preserves its twelve stations for real pre-feature save generation.
`run_native.ps1` prevents overlapping engines and runs unpaused at 5% audio.
`manual.ps1` opens the author scene and explains every control in Spanish.
Known existing recipes are enabled only inside that test scene.

Render callback intervals and simulation throughput are separate measurements.
Windows denied PresentMon trace access; application presentation, display
refresh and GPU duration are unavailable. This is not proof of whole-map 60-FPS
acceptance. Matched peaceful views use GZDoom 4.14.2, Vulkan, 1280 x 720 and a
60-FPS cap on the recorded Ryzen 9 5950X / RTX 3070 Ti environment.

Initial hidden-window captures retained an earlier scene despite passing
simulation assertions. Matched final-hidden/final-visible evidence verifies
that visible-window captures are needed on this environment; native visual
review uses the visible mansion/city images. Initial travel scripts omitted a
wait after the final netevent and quit before the last assertion was processed;
the corrected script records all three visits. Both cases are fixture issues,
not claimed gameplay fixes. Failed PresentMon collection is retained separately.

Art generation requires Pillow in the optional generator environment. Run
`python assets/generators/generate_alchemy_data.py` for approved placement data
and `python assets/generators/generate_alchemy_station.py` for owned art.
Regenerate dialogue/localization indexes after a LANGUAGE change, then use
the normal project validator and package builder.
