# World-object exposure - #502, 5.8.12 continuation

2026-10-25. Branch feat/issue502-hygiene-actions, PR506, baseline d801ae4c.
Physical scenery and loose native equipment receive ambient contamination and
repeating rain washing. This does not complete #502 or V5.8.
Author acceptance: CA502-OBJECTS-01 passed on 2026-10-25 without qualifications.
The separate treatment/toilet author checks remain pending.

Functional and author-tested runtime objects-final02 SHA256:
`01cf3d99bd62b2ba27906448d092b168707ce382e0f0c04a55f572d64328e2bf`.
Delivered runtime objects-final03 SHA256:
`8616456f726ec0de5d2df7e7bd510150c951061e6ae2c6dc4f5582f9b4b3008d`.
Only full-line Spanish comments in CaelumContaminationObject.zs differ between
those packages: the final package repairs their UTF-8 encoding. The collector
verifies unchanged executable text and every other member byte for byte.
A separate final03 native parse/startup test exits successfully. The 165
functional assertions were not repeated or attributed to that later package.
All 16,897 final members match src; all 169 maps and 13,826 art members remain
byte-identical to contact-final01. No new balance, recipe, map or art changes.
Project static validation passes with zero errors (static.json). Two fixture
regenerations reproduce the tested bytes exactly (determinism.json); new Python
tools pass syntax parsing. The generated document index is current.

## Native verification

GZDoom 4.14.2, Windows 11, Vulkan, 1280x720, 60-FPS cap, background unpaused,
5% audio. 165 executed PASS / 0 FAIL across 15 selected serial runs; restored
cumulative totals are not counted again. report.json identifies each runtime,
fixture and log hash. native/ preserves commands, hardware/configuration and
raw logs. Development fixtures and PK3s are not runtime distribution assets.

- Core: registration of physical props and actual native equipment; single
  scheduler identity; cylinder/weapon/size surfaces; elapsed clock charged once;
  independent copies; occupied chairs retaining exposure while lending their
  collision; pickup closing the exposed interval; owned equipment releasing its
  scheduler; native drop resuming exposure; destroyed-object cleanup.
- Simultaneous rain/exposure: small objects may settle below ambient. Six
  independent fixed-step RK4 references converge at 0.02/0.01-second steps
  within 0.00001 and match production within 0.00002. The reference uses the
  differential rates, not the production integral/root solver.
- Rain: real seeded city rain at 2.792269 mm/h, uncovered versus roofed props,
  repeated 30-minute washing, approved interpolation and environment reduction.
- Storage: a real player Box preserves the actual sword's concentration over
  175 tics; native dropping resumes exposure over another 175 tics.
- Current save/load/hub: concentration and single scheduler identity survive;
  a boxed sword retains 31 with no world scheduler. Hub references are reacquired
  by item identity rather than retaining stale cross-map actor references.
- Prior-save migration/hub/rollback: genuine contact-final01 saves retain
  concentration; missing schedulers initialize idempotently without retroactive
  dirt. The original package still loads the original save. The bridge addon
  retains the basename required by GZDoom's save loader.
- Campaign census: MAP03 has 3,738 actors and 1,518 eligible nodes; the
  idempotent census measured 0.7785 ms. No invalid nodes remained.
- Regressions: native sustained contact 24, NPC exposure 20, melee 19 and
  calendar hygiene 31 executed checks pass.

Development failures are retained in development-failures/. Initial fixtures
used a reserved identifier, an unavailable calendar field, or queried a spawned
node before dispatch. A destruction check exposed the missing bDestroyed guard;
Eligible/Release now avoid dead inventories. Rain fixtures initially found no
10-mm/h event in their search interval; the final fixture uses an actual event
above 2 mm/h without changing weather. The first hub fixture retained a stale
carried-item reference; identity reacquisition fixed the fixture. Final selected
runs contain no unresolved startup/runtime failures.

## Performance and scan exception

Each eligible object owns one revision1 map-local Thinker. Spawn and inventory
events maintain ownership; updates share weather samples and stagger across the
existing one-real-second cadence. No recurring global scan, visibility cutoff,
population cutoff or offscreen suspension is added.

CaelumContaminationWorld owns one idempotent Actor census at WorldLoaded to
attach missing nodes to map actors and previous saves. Its bound is the loaded
native map population, including hidden actors; it is not repeated per object
or tic. A matched peaceful 1,000-object fixture measured initial census cost
at 0.9535 ms for 1,019 preexisting actors and 1,000 created nodes, versus
0.0055 ms without the new registry. MAP03's idempotent result is reported above;
neither is a universal worst-case performance guarantee.

| Renderer callback interval | Baseline contact-final01 | objects-final02 |
| --- | ---: | ---: |
| Mean ms | 16.666 | 16.669 |
| p95 ms | 17.157 | 17.385 |
| p99 ms | 17.443 | 17.892 |
| Worst ms | 17.747 | 18.883 |

Each sample contains 1,199 callbacks and 700 simulation tics. Phase durations
were 19,933/20,029 ms with 100-ms polling uncertainty. All 1,000 final objects
receive exposure; the baseline has zero exposed receivers. Objects remain
native actors with exposure/climate sampling active. No combatant stress
scenario or gameplay ablation is used. PresentMon could not start its Windows
trace because privileges were unavailable. Callback cadence is not displayed
frames, GPU timing, campaign FPS or author acceptance of a performance target.

## Persistence, limits and author handoff

Concentration schema1 is unchanged; its optional exposure node uses revision1.
Transient clocks rebase after load/hub restoration without inventing unloaded
history. Pickup closes elapsed exposure before transferring state; Box/owned
storage releases the world node. Copies retain dirt without sharing nodes.
Non-solid scenery, stackable pickups, contacts without native registration,
historical unloaded-map exposure and resident housekeeping remain unfinished.

author_objects_terminal.ps1 preserves the accepted interactive laboratory.
F1 resets, F3 stores the sword, F4 drops it, F5 selects actual rain, F6 integrates
30 minutes for the two chairs only, and F2 reports values. F6 does not advance
the rest of the world. The author confirmed the live test. The agent's attempted
UI inspection in the prior turn was stopped with Escape, so it is not claimed
as agent visual verification. Automatic native verification is separate.
