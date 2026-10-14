# Issue #231 validation — 5.3.4

Implemented against `7b90cfde` (5.3.3). Final evidence: **14 completed native
runs, 65 assertions, 11 exact save comparisons and 14 inspected captures**.
Environment: GZDoom 4.14.2, Windows 11, Vulkan, fixed seed 184, 5% audio,
unpaused background simulation. The manifest identifies exact runtime,
fixture, executable, input-save and image hashes; every retained run exited 0.
No engine, IWAD, package, map fixture or save is distributed.

| Runs | Verified scope |
| --- | --- |
| `contract-05` | Native full/overlay modes, unchanged known/hidden line flags, zoom/pan without player movement, native crosshair guard, remapped/unbound hints, no M/mark reset, preserved custom colors/textures/rotation and empty objective hook. |
| `clock-limbo-02`, `clock-campaign-02` | Distinct seeded local Limbo time and campaign calendar produce the expected literal timestamps, rather than reusing one clock everywhere. |
| `old-save-01`, `current-load-03`, `current-reload-03`, `rollback-01` | Genuine 5.3.3 engine save, 5.3.4 load/reload and rollback through the unchanged original. Entire native automap objects, linedefs and character records compare exactly: marks, zoom/bounds, exploration, identity/equipment/quest/Tarot/world fields present in this isolated scenario survive. |
| `hub-02` | MAP03 → MAP04 → MAP03 retains the original native automap object and linedefs exactly. Each visited map still contains unknown lines. |
| `floors-es-04` | Actual MAP01 ground/first/second floor supports; five captures including native texturing and rotation. Known linework overlaps storeys; no floor picker is claimed. |
| `layout-43-es-02`, `layout-169-en-02`, `layout-wide-en-03` | Spanish/English, 800×600, 1280×720, 1680×720; UI/message scales 1 and 8, full map and overlay, MAP01 and MAP02. Fourteen total captures include this matrix and the floor series. |
| `perf-baseline-02`, `perf-current-02` | Bounded MAP06 frame-interval comparison below. |

The initially observed large-ultrawide overlap was corrected by reserving the
actual resource-label edge, including its baseline offset. Final captures
show separated header, resources and survival warnings. Native console
diagnostics are visible at large message scale in the overlay captures; they
retain native lifetime and rendering. Earlier diagnostic failures/captures
remain under `build/issue231` and are not final passes.

MAP06 measurements use the same fixture and scenario, 1280×720, VSync with
60 FPS cap, 175 tics per phase after warm-up. The prior interactive #258 engine
was closed before this comparison; its restart terminal remains available.

| Phase | 5.3.3 FPS | 5.3.4 FPS | Median ms, old → new | p95 ms, old → new |
| --- | ---: | ---: | ---: | ---: |
| Ordinary view | 34.50 | 34.09 | 28.62 → 28.64 | 31.27 → 32.64 |
| Full map | 31.39 | 30.19 | 30.56 → 31.19 | 41.70 → 45.43 |
| Pan / zoom / rotation | 31.23 | 30.77 | 30.69 → 31.07 | 42.85 → 43.03 |
| Overlay | 31.59 | 30.64 | 30.37 → 30.90 | 41.66 → 42.44 |

These short samples show map-mode FPS about 1.5–3.8% below baseline, with
the full-map p95 increasing about 3.7 ms. They do not isolate UI cost from
whole-scene variation, establish a statistical performance budget, measure
physical input latency, or certify mass AI. The slowdown is reported rather
than called a no-regression pass; author responsiveness acceptance is pending.

Static validation: `python validate_project.py`, exit 0, `errors: []`.
Normal `powershell.exe -NoProfile -ExecutionPolicy Bypass -File build_dev.ps1`:
exit 0, **16,058 files**, no directory entries. Dialogue/localization and document
indexes were regenerated. Production adds no saved owner or schema.

Reproduce: `python assets/validation_534/prepare.py`, then adjacent
`run_native.ps1` with a fresh label and the fixture/script/map/settings in
`evidence.json`. The saves were created by the real old engine package in an
isolated scenario; they do not certify every author campaign or multiplayer.
Source audit: g4.14.2 commit `99aa489d09015a95bb78df2b30ede29f328cc874`,
`src/am_map.cpp`, `src/am_map.h` and `src/g_mapinfo.cpp`; support inventory
and limits are in SYSTEMS and CA-KP-092.

**CA231-01 passed author acceptance on 2026-10-13:** "Dieron bien las pruebas
del mapa." No exceptions were reported. The author returned after the earlier
Computer Use Escape interruption and tested the frozen 5.3.4 package with an
isolated INI. The retained `author-return-20261013-225540` log records native
map controls and all three authored floor anchors. This is separate from the
scripted 14-run matrix; no unreported physical-controller coverage is claimed.
The confirmed check was removed from pending_test.txt and recorded in HISTORY.
The minimized terminal retains `Probar231`, `Probar231 MAP02` and `Probar231
MAP06`; F6/F7/F8 select mansion floors only in the fixture, F9 records state
and F10 closes it. No runtime behavior or release number changed on acceptance.
