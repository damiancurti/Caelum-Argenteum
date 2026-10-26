# Non-solid physical scenery exposure - #502 / 5.8.16

Mansion shrubs, five decorative cave gems and shop signs join the existing
physical-object scheduler. Trees keep their accepted collision. The new base
adds no fields, Tick, sprite, model or collision; native saves retain identity.
No balance value, body-contamination rule, ambient class or rain rate changes.

## Native evidence

GZDoom 4.14.2 / Windows 11 / Ryzen 9 5950X / RTX 3070 Ti / Vulkan,
1280 x 720, cap 60, background running, 5% audio. `report.json` records 232
executed PASS / zero FAIL in ten selected runs; inherited cumulative summaries
are not counted twice. The original accepted 5.8.15 entry03 is the immutable
baseline. Tests cover classification, actual spawn registration, cylinder area,
world-time integration, no duplicate exposure, washing, new saves, genuine
previous-runtime save migration and original-runtime/original-save rollback.
Original solid-object/equipment checks and numerical regression pass.
MAP03: 3,803 actors, 1,582 eligible nodes, 0.5311 ms for the existing one-time
load census. Eligibility changes do not introduce another global actor scan.

Final current03 SHA256:
`55fd9270df6d696d22113496aa53fbc3d83fabb8f628fa34c2e6d35a28439ef2`.
All 16,919 archive members match source. Relative to behavior/performance
current02, only Spanish comments in the fieldless base differ; final core and
old-save loading were run again with current03. The fixture is unshipped.

## Performance and limits

The shared object-performance runner adds an optional `--scenery` condition,
leaving its original solid-object default unchanged. Both builds use identical
1,000-object diagnostic appearance, map, settings and random seed. Before:
zero receivers exposed; after: all 1,000 exposed. One-time initialization census
cost: 0.0362 -> 1.1824 ms. Simulation 700 tics: 20.024 -> 20.051 s (100 ms
poll uncertainty). Callback mean: 16.6666 -> 16.6681 ms; p95: 16.9790 ->
17.5653 ms; p99: 17.2022 -> 18.1962 ms; worst: 18.6077 -> 23.1095 ms.
There is measurable added cost. These RenderOverlay intervals are a renderer
cadence proxy, not displayed-frame or GPU timings. PresentMon reported
unavailable privileges; its raw output is retained. This is a narrow peaceful
comparison, not mansion, sewer, siege or campaign-wide performance acceptance.

## Failed attempts and manual status

`scenery-core-01` failed 14 fixture assertions because case-insensitive ZScript
parameter `expected` shadowed field `Expected`; the distinct
`ExpectedMembership` field fixes the fixture (known CA-KP-169 lesson).
`scenery-manual-check01` rejected the reserved parameter name `action`; renamed
to `operationKey`. Neither failure required a production behavior change.

Direct manual commands pass 24 assertions. Captures visibly show all eight
objects at 80, then 60 after an isolated 10 mm/h, 30-minute wash. This private
fixture changes only each object's elapsed exposure interval, not thirty
minutes of unrelated AI or the player's contamination. F3 independently
starts at 20 and applies ten seconds of ambient 80 exposure.

Desktop keyboard automation did not establish key receipt. The old Sky helper
pipe was unavailable; an alternative window controller captured the live scene
but F2/F4/Escape produced no confirmed input. That agent-owned session was
stopped. No physical-key or author acceptance is claimed. The fixture's native
live-menu adapter also routes its own F1-F4 commands, so opening a live journal
does not accidentally route to the older object fixture's uninitialized data.
The author terminal is prepared, not opened during absence; CA502-SCENERY-01
remains in pending_test.txt. Original #411/#412 corrections are already accepted.

## Reproduce

Prepare: `python assets/validation_5816/prepare.py` with GZDoom closed.
Use `run_native.ps1` with a new Label, Runtime current03, Script core or
manual-check and -Checks. `author_terminal.ps1` offers the interactive scene.
For performance prepare the existing contact fixture, place the immutable
packages under build/issue502-hygiene/scenery-base and scenery-current, then
run `assets/validation_5812/object_performance.py RUNTIME NEW_LABEL --scenery`.
Never overwrite an archive open in GZDoom. Evidence includes raw failed runs.

Remaining #502: other non-solid adapters, stackable item/contact handling and
unloaded exposure/household history. This slice does not close the issue.
