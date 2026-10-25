# Persistent surface contamination - #502 / 5.8.12

The approved1m2 floor/wall zones retain contamination, contact history and elapsed
regional exposure across saves and travel. Floor coordinates follow the actual
support plane, including slopes and3D-floor model identity; wall identity includes
line face, distance along the wall and height. Native blockmap/trace queries find
only the nearest touching torso wall. One representative foot zone uses0.04m2,
and torso brushing0.10m2. Outer armor/clothing receives the contact first.
Grounded contact remains possible at the bottom of the actual mansion pool;
swimming clear of the bottom ends that contact. Existing potable-body washing
remains independent.

The author clarified on2026-10-25 that light/heavy rain removes10/20 degrees every
30 world minutes, repeatedly while it continues. Exposure and washing integrate
together. Roofed interiors are excluded; clearing rain retains completed washing.
A stable series avoids cancellation at near-zero drizzle. The registry starts
at first map observation without retroactive old-save dirt, and preserves existing
body/equipment contamination. Unvisited zones are evaluated lazily; saved climate
parameters reconstruct elapsed regional minutes. Active contact uses actual local
microclimate. Waiting uses independent copies and includes new-zone catch-up;
forecast revision16 invalidates earlier snapshots.

## Validation

157 executed native assertions in 15 selected runs; static validation
passes. Source equality covers 16893 members;169 production maps and13,826
art members are unchanged. Final surface-final05 SHA256: `2e7d8c6b0c65f17be568533c6c5b7383905f5c33612dbbe6d624168930614c7b`.
Selected raw logs/configurations/hardware hashes are in native; captures were
visually inspected. Collector verifies exact source deltas before reusing final03
and final04 evidence. Old-save assertions are counted from executed PASS lines,
not cumulative saved result counters. Original-runtime rollback passes too.

The checks cover rain arithmetic/subdivision, near-zero rain, sparse10,000-zone
identity, actual floor/wall geometry, source conservation, body-mass scaling,
immersed support, changed cover, untouched forecast state, seeded climate over
30days, real accelerated rain, dirty-floor waiting parity, save/load/hub identity,
pre-feature saves and cleaning/bath/toilet regressions. In the live rainfall
scenario the exterior fell100->88.8966 over30 world minutes while the roofed
comparison stayed100.

## Timing and limits

Matched peaceful fixed-camera windows use GZDoom4.14.2/Vulkan,1280x720,5% audio,
unpaused background operation and the same60FPS cap. Table values are native
RenderOverlay callback intervals in milliseconds; they are not application
presents, monitor refresh or GPU execution. PresentMon trace access was denied
on this session; that failure is preserved under performance. No elevated trace
or system-policy change was requested. Simulation throughput is reported separately.

| Map / pitch | Runtime | Mean ms | p95 ms | p99 ms | Max ms | Tics/s |
| --- | --- | ---: | ---: | ---: | ---: | ---: |
| MAP01 0 | clean-final06 | 16.83 | 19.19 | 20.55 | 22.64 | 35.01 |
| MAP01 0 | surface-final04 | 16.69 | 18.50 | 19.57 | 21.29 | 35.00 |
| MAP02 0 | clean-final06 | 16.69 | 17.37 | 17.72 | 34.77 | 35.01 |
| MAP02 0 | surface-final04 | 16.69 | 17.17 | 17.55 | 39.89 | 35.01 |
| MAP03 0 | clean-final06 | 16.67 | 17.35 | 18.01 | 19.31 | 35.00 |
| MAP03 0 | surface-final04 | 16.67 | 17.10 | 17.43 | 17.80 | 35.00 |
| MAP03 75 | clean-final06 | 16.67 | 17.60 | 18.43 | 20.13 | 35.00 |
| MAP03 75 | surface-final04 | 16.67 | 17.47 | 18.17 | 19.78 | 35.00 |

The repeated sewer window's p99 is close to baseline; the39.89ms maximum remains
visible in the evidence. These short windows do not establish full-map60FPS
acceptance or a performance improvement. No army/stress fixture was run. Queries
use the player list, sparse hash buckets and local blockmap lines, not a routine
world-actor census. Prior climate-marker/supply scans are unchanged by this patch.

Other-actor/combat contact, NPC domestic cleaning and calendar/exhaustion pre-sleep
cleaning remain unfinished. Unloaded surfaces reconstruct regional climate and
saved shelter, not transient magical emitters in an absent map. Multiplayer and
moving-geometry histories are not accepted by these checks. New-zone exposure
starts at first map observation; no unvisited campaign history is invented.

CA502-SURFACE-01 remains pending in pending_test.txt. The separate author terminal
provides F1 floor, F3 wall, F4 real seeded rainfall, F5 thirty-minute advancement,
F2 readings and F6 console. No issue/release closure is implied.

## F2 visibility correction - 2026-10-25

The author's session logged body readings, but F2 did not open the in-game
console; the native runner disables transient console notifications. F2 now
dispatches the reading, waits two command tics and opens the console. Its label
is "Tu contaminacion". PowerShell instructions identify the correct window.

The generated surface-reading script reuses the exact command assigned to F2.
Run surface-f2-fix02 completed without errors; its capture visibly shows
"Tu contaminacion=11.5671 / 100" with floor and outer-equipment values.
This is a native UI smoke/capture check, not additional gameplay assertions.
Physical keyboard automation could not connect to the Computer Use native pipe
after the documented retry/reset; no physical F2 key acceptance is claimed.
Evidence is under native and captures. Fixture generation remains deterministic.
No src member or production package changed, so the preceding gameplay results
and package hash remain applicable. CA502-SURFACE-01 remains author-pending.

## Interactive action responsiveness and rain interpretation - 2026-10-25

The author reported hitches mainly on F4/F5 and apparent contamination from rain.
The previous manual session retained outer-equipment contamination around67 while
resetting the body to0. Exposure from that equipment and the remaining ambient
source continued; the exterior control was being washed correctly. F1/F3/F4 now
start independent CAS502 scenarios with clean body/equipment and a fresh sparse
surface epoch after the synthetic weather-date jump. This is a diagnostic reset,
not a change to production save history or cleaning mechanics.

Manual F5 schedules at most16 personal simulation steps or2ms per native tic.
It advances to a world-clock target30minutes ahead, counting ordinary progress;
the focused check reaches exactly1800seconds in186 batches. Duplicate presses
do not queue more time; F1/F3/F4 cancel it. Notifications report start/completion.
F2 labels exterior/interior separately and explains that rainfall is not bathing.
The unchanged production package remains surface-final05 with the hash above.

Eight focused native assertions pass: independent clean setup, fresh epoch,
duplicate-command protection, cancellation, yielding, exact clock target,
exterior/roofed comparison and synchronous rain regression. The final visual
capture repeats three assertions and shows exterior100->88.8966, interior100
after30minutes. Body contamination reaches8.5883 because remaining exposure is
active. No direct body-washing effect from rainfall was added or approved.

Matched action windows use the same native configuration as the earlier timing
section. Each run measures dry, rain and F5 phases. Repeated runs add six F4
commands. Raw logs, configurations, hashes, metrics, capture and manifest are
under responsiveness. The baseline addon retains the prior fixture source.

| Run / phase | Mean ms | p95 ms | p99 ms | Worst ms |
| --- | ---: | ---: | ---: | ---: |
| Before / dry | 16.666 | 16.923 | 17.137 | 17.258 |
| Before / rain | 16.667 | 16.838 | 17.005 | 25.664 |
| Before / F5 | 16.734 | 17.027 | 17.556 | 69.560 |
| After / dry | 16.666 | 16.858 | 17.001 | 17.280 |
| After / rain | 16.666 | 16.840 | 16.938 | 17.478 |
| After / F5 | 16.666 | 16.883 | 17.042 | 17.212 |
| Repeated before / dry | 16.666 | 16.972 | 17.182 | 17.718 |
| Repeated before / rain | 16.880 | 17.046 | 17.648 | 103.097 |
| Repeated before / F5 | 16.733 | 16.953 | 17.184 | 71.903 |
| Repeated after / dry | 16.669 | 16.961 | 17.217 | 22.505 |
| Repeated after / rain | 16.666 | 17.027 | 17.454 | 17.863 |
| Repeated after / F5 | 16.666 | 16.964 | 17.209 | 17.527 |

The old F5 command itself takes52.75/55.21ms; new dispatch takes0.024/0.026ms,
with work performed in later batches. Measured complete-batch maxima are below1ms
in the retained runs. F4 setup itself remains below1.4ms; the older repeated
scenario's larger gap includes deferred catch-up after the artificial date jump.
The22.505ms dry-control maximum remains visible; no uniform60FPS claim is made.
Simulation averages remain near35tics/s (raw metrics retained), but action-window
tic throughput starts after synchronous commands whereas frame samples include
their transitions. Do not use that counter as a presentation-rate measurement.
These are RenderOverlay intervals, not application presents or GPU/display time;
the earlier PresentMon access limitation still applies. CA502-SURFACE-01 remains
pending for author confirmation of the corrected interaction.

## Author acceptance - 2026-10-25

CA502-SURFACE-01 passed without qualifications after the F2 visibility and F4/F5
responsiveness corrections (0c9cb53a). Earlier pending statements above record
the status at each delivery and are superseded by this explicit confirmation.
This does not imply campaign-wide FPS acceptance or completion of #502.
