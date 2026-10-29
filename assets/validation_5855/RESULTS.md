# 5.8.55 / #415 city regression

An illness damage tick called Rally.Strongest for each defender. GZDoom's typed
ThinkerIterator still traversed the thinker population with no active Rally. The
private nested timing probes isolated CombatActor.Tick -> IllnessStep -> DamageMobj
-> Rally lookup; changing that lookup alone removed the collapse. Production now
looks up the at-most-one cast in each active player's inventory. The periodic
Rally pulse uses BlockThingsIterator plus the existing UnlinkedGuards registry,
preserving range, allies, line of sight and bodies outside the blockmap/camera.
The authoritative shared >=500 combatant census remains unchanged.

Visible, unpaused GZDoom 4.14.2/Vulkan, RTX 3070 Ti, Ryzen 5950X, Windows 11,
1280x720, 60 cap, 5% audio. Same production MAP03 first arrival at 3600 world
seconds, fixed seed and 40 wall-second stationary/walk/stationary sequence. No
retired 6000-attacker scenarios were run. Final ten-second phase:

| Measure | Before | After |
| --- | ---: | ---: |
| Render callback intervals | 9 | 352 |
| Mean interval | 1125.93 ms | 28.34 ms |
| p95 | 1155.32 ms | 33.51 ms |
| Maximum | 1175.00 ms | 54.05 ms |
| Simulation ticks in phase | 153 | 350 |

These are engine RenderOverlay callback intervals, not ETW display-present times.
PresentMon was attempted for both runs and denied trace-session access (exit6).
No 60-FPS claim is made; the remaining city workload is still measurable. Raw
logs/configuration/package hashes accompany report.json. Different simulation
throughput means wall-time windows cannot be compared as identical world outcomes.

13 focused assertions passed: no cast, active cast, adrenaline factor, illness
defense, allied/ranged/dead recipients, local and unlinked-guard pulses, expiry,
revision and native save/load. Each performance scenario also passed its six
arrival checks. No illness, defender, targeting or resource rule was removed.
Author confirmation of the corrected city remains pending.
