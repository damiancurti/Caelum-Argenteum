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
