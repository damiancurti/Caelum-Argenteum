# #314 / 5.5.6 thermal surfaces

The author approved ice -40 C and lava 1,000 C in a private test room,
100 W/m² K contact transfer and the lowest anatomical 1/16 body row.
Existing thermal exposure, clothing and damage rules remain authoritative.

**Static:** project validation and normal packaging pass. Existing thermal
revision 9 and all persisted fields remain unchanged. Surface projection,
coefficients and schedules are transient. The final ordinary package matches
the frozen runtime member bytes. Read-only independent review found no blocker.

**Native:** 16 required Windows GZDoom 4.14.2 runs / 93 logged PASS checks.
See report.json and byte-exact evidence/. Frozen final runtime in
build/issue314-current06 and current07:
`3ddd551ad2358d78e22626e753ebd6b164508ec6cd1a00adb176ac6323ce3799`.
Final interactive fixture:
`401353aa7dddc7366e7e6f00eead9b13c25ecb0aac235bb1b8feac7d50322d4e`.
Baseline is the accepted #363 / 5.5.5 runtime.

- Native supporting sectors, solid 3D platforms, water over ice, covered ice,
  unsupported ground below a platform, flight/noclip and upward motion.
- Exact 1/16 area, air-area replacement, approved conductance, stronger existing
  insulation, wet-contact nonduplication, split world-time equivalence, shared
  Toughness damage and zero-time/no-direct-damage checks.
- Player sustained contact, native crouch/jump/landing; live NPC enter/leave,
  per-tic contact cadence and repeated same-tic callbacks.
- Old/current save loading, rollback to 5.5.5, and hub destination/reopened NPC
  support. Exposure persists without unloaded-map catch-up.
- English/Spanish labels and owned blue/orange surface textures were inspected
  in native captures. These are private diagnostic visuals, not final landscape art.

Failed attempts remain archived: an unavailable fixture water function, a
reserved fixture identifier, an actual stale NPC projection on exit (fixed),
and an incorrect fixture assumption that changemap returns the player to the
previous coordinates. Native player arrival uses the map start; retained NPCs
correctly keep their surface and exposure. None is counted as a passing run.

**Performance:** Windows 11, Ryzen 9 5950X / RTX 3070 Ti, Vulkan, 1280×720,
60-frame cap, background unpaused, 5% audio, one engine. One ten-second window
per condition; no statistically established speedup. All 512 private peaceful
bulls survived, including offscreen bodies. Untagged baseline/revised final
mean exposure is exactly -0.566452 in the recorded precision.

| Condition | tics/s | Render-callback mean / p95 / p99 / maximum (ms) |
| --- | ---: | --- |
| 512 neutral, baseline | 34.98 | 16.67 / 19.25 / 20.55 / 22.40 |
| 512 neutral, revised | 34.99 | 16.66 / 19.12 / 20.41 / 22.86 |
| 512 on lava, revised | 35.01 | 16.72 / 20.61 / 24.76 / 50.28 |
| MAP01 native spawn | 34.98 | 16.67 / 18.08 / 19.10 / 20.61 |
| MAP02 native spawn | 35.00 | 16.67 / 20.38 / 21.49 / 25.12 |

These are simulation and renderer-callback measurements. **Application
presentation is unavailable:** PresentMon ETW returned access denied; raw errors
are retained, and reference runs did not retry. Callbacks do not establish
application presents or monitor refresh. No 60-FPS presentation acceptance is
claimed. The lava tail reaches 50.28 ms. Native mansion/sewer populations were
not separately counted; those samples are fixed spawn references, not full-map
traversal or the deferred campaign FPS acceptance.

**Author:** CA314-01 remains pending. `preview.ps1` opens the final room with
F6 ice, F7 lava, F8 neutral, F9 water, F10 fixture health/exposure reset.
Accumulated heat/cold persists after leaving and follows ordinary recovery.
The manual check does not approve campaign placement.

The fixture uses owned project textures, deterministic geometry and bilingual
labels. Development IWAD, executable, packages and saves are not distributed.

Reproduce with `python -X utf8 assets/validation_556/prepare.py --directory NAME`,
then run the matching scripts through run_native.ps1. Use a fresh label per run;
save loading takes a relative basename within the isolated savedir. The baseline
probe accepts --runtime plus --baseline-probe. performance.py collects raw
simulation/render callbacks; ETW requires OS privileges unavailable in this run.
collect.py verifies the retained frozen runs and hashes before copying evidence.
