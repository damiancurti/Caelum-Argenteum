# Native solid contact — #502, 5.8.12 continuation

2026-10-25. Branch feat/issue502-hygiene-actions, PR506, baseline c6508075.
This delivers collision-driven continuous contact; it does not complete #502.
Author acceptance: CA502-CONTACT-01 pending. NPC/combat/calendar acceptance stands.

Runtime contact-final01 SHA256:
`47cac19a6c1604633ff6e20ab8b81041836d657617d6ba65320343d5d7bc4bb9`.
All16,896 packaged members match src. All169 maps and13,826 art members match
npc-final02. No production map, art, balance, recipe or physics impulse changes.

## Native verification

GZDoom4.14.2, Windows11, Vulkan,1280x720,60FPS cap, background unpaused,5% audio.
124 executed PASS /0 FAIL across12 selected runs, including two assertions in
the previous runtime. Serialized cumulative totals are not counted again.
Exact commands, hashes, hardware/configuration and raw logs are in native/;
report.json supplies per-run counts. prepare_contact.py builds deterministic
unshipped fixtures; run_native.ps1 refuses overlapping engine sessions.

- Core24: real TryMove/CollidedWith registration; shared pair; one initial
  world-tic dose; repeated active/passive callbacks; approved area/mass/ratio;
  reverse transfer/equal concentrations; elapsed world clock without duplicate
  charge; foot support; outer NPC armor; cached endpoints; generic solid actor;
  noclip/separation/destruction; brief blocked contact with a remaining gap;
  native player collision and exact-calendar-forecast guard.
- Clock5: native Thinker runs while bodies stand still, separation freezes the
  receiver, recontact resumes from retained concentration, source stays80.
- Current save1/load6/hub6: actors and single pair identity survive; transfer
  continues; no duplicate bodies. Hub-owned actors are reacquired by diagnostic
  TID rather than a stale player-carried reference.
- Previous-runtime save1/migration4/hub6/rollback1: old concentrations survive,
  no historical contacts are invented, first collision creates state; the exact
  original save remains readable with npc-final02. The bridge fixture retains
  the legacy addon's basename required by the native save loader.
- Regressions: NPC exposure20, melee contact19, calendar hygiene31.

Saved pair schema1 is additive; transient clock/endpoints rebuild after load or
hub restoration. No transfer for unloaded-map time is inferred. Source is not
depleted. Only actual registered native contacts sustain pair updates. Initial
overlaps without a collision and non-solid actors are outside this slice.
The calendar forecast revision19 refuses an exact completion date while an
actor contact can mutate; normal elapsed-world-time contact continues.

Development failures are preserved in development-failures/. The first fixture
attempts assigned read-only size or used an unavailable size method; actor
defaults fixed them. A chained returned-object array access stopped in the
native fatal-error dialog after the first assertion (core03); binding the result
to a local and checking its size removed that failure. The engine-level cause
is unconfirmed; production and final fixtures use explicit local references.
Core04 also queried a newly spawned soldier before its deferred PostBeginPlay;
preparing it before the test fixed the armor checks. The initial hub fixture
retained cross-map actor references, and the initial legacy run used a mismatched
addon basename. Reacquisition and the bridge fixed those fixture errors; final
save/load/hub/migration/rollback runs passed. These are not hidden passing runs.

## Performance scope

Matched peaceful arena:1,000 bodies,500 pairs,700 tics, all1,000 survive. AI,
movement and thermal physiology are suppressed equally; production contact
Thinkers remain enabled. Previous npc-final02 exposes0 receivers; final exposes500.
There are no routine global scans, per-body world queries or visibility culls.
Only each colliding body's own contact list is searched; each active pair owns
one update, reusable endpoints and removal from both lists on separation.

| Renderer callback interval | Previous runtime | Final runtime |
| --- | ---: | ---: |
| Mean ms | 16.667 | 16.668 |
| p95 ms | 17.366 | 17.391 |
| p99 ms | 18.103 | 18.082 |
| Worst ms | 22.949 | 19.611 |

Both captured1,199 intervals;700-tic phase duration20,035/19,931ms with100ms
polling uncertainty. This single matched comparison shows similar cadence in
this fixture; it does not establish a general performance improvement.
PresentMon access was unavailable. Renderer callbacks are not displayed-frame
presentation, GPU duration, whole-campaign60FPS or siege acceptance.

## Author handoff

author_contact_terminal.ps1 opens the isolated Spanish panel. F1 resets80/20;
F3 separates and stops transfer; F4 rejoins without resetting; F2 reports only;
F6 toggles console. These fixture actors suppress AI/ambient exposure so contact
is visible independently. The game retains the accepted NPC thermal exposure.
Generic ambient exposure, unloaded-map history and resident cleaning remain
pending independently, as do the prior treatment/toilet author checks.
