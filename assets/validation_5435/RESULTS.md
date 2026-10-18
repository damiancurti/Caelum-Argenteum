# 5.4.35 / #322 - One prisoner escort movement owner

The author reported excessive turning and slow walking again during the #324
autosave preview, while confirming that its bag and companion survived reload.
On October 18 the author explicitly replaced #307's source-actor pace with the
player's walking formula, using each prisoner's own attributes and penalties.

## Reproduction and implementation

Baseline b74ca613 has the same packaged runtime as #324. With the player still,
one friendly SoundAlert caused the Unitario to travel 504.804498 MU and change
angle 53 times, accumulating 5,150.890932 degrees in 140 tics. Tick and the
EscortFollow state's resident Look action competed: Look could enter native
See/A_Chase wandering before Tick forced following again. Its four one-tic
walking frames also animated a stopped follower. The matched replacement run
records zero displacement, turning, state changes and native See frames.

CaelumPrisonerEscort owns ordinary locomotion. Idle/walking poses contain no
steering actions. Conversation stops movement; threats and existing resource
retreat explicitly retain native combat ownership. Quiet resource recovery gets
a completion pulse at the existing four-tic cadence. Nearby visible followers
wait only when their supporting floor matches the leader's. Acceleration uses
the player's mass-scaled ramp and does not grow during ordinary airtime.

The bounded breadcrumb trail starts at release; an actor-radius local grid
detours around walls and bodies. Player commands express reversal intent even
when collision recoil points the other way. A yielding follower moves only as
far as its footprint fits. A narrow passage can require the player to strafe too;
the corridor diagnostic explicitly includes that maneuver and counts sidesteps.

The four-body reversal also exposed a stale breadcrumb occupied by a settled
follower. A longer observation eventually passed the loose distance threshold
while another body still detoured toward the old point. The direct-trail shortcut
now distinguishes map geometry from all actors (including solid props), then
retains the local avoidance route toward the leader. Only the synchronous
geometry query ignores actors; its flag is restored before returning, and native
movement and local navigation keep full collision. On the original 1,400-tic
route all four now settle within the authored follow radius. A further 140-tic
check verifies no group movement, turning or walking pose and restored collision.

In the 96-MU corridor two waiting companions span the passage. A 2,800-tic
observation showed the rear pair continually taking lateral escape paths even
after satisfying the distance check. For a stationary leader with no old trail
points left, navigation now keeps the closest reachable progress and waits when
it cannot get closer. Moving intent, old trail points and different floor levels
retain lateral escape. The final corridor test allows the full passage plus
settling time and then requires another 140 tics of physical and visual stillness;
it does not enlarge the production follow radius or disable collision. A separate
resumption test then starts player movement again without releasing prisoners a
second time or resetting any controller. All four move more than their own radius
within 350 tics while body/wall collision remains intact.

The first resumption driver reversed into the settled group instead of moving
away. It stopped after 62 MU; every follower remained inside the 96-MU follow
radius and all four displacement assertions failed. Full collision and the
finite GiveWay candidate sampling could not clear that packed row. This is a
retained circulation limitation, not proof of a regression in the lateral-escape
guard (Follow returns before reaching it). No claim of geometrical impossibility
is made. The separate resumption check moves the leader away along the available
corridor and requires actual leader arrival plus renewed movement of all four,
without resetting controllers. Passing it does not resolve packed-row passage.

The real campaign exposed a breadcrumb just outside the Federal's clearance
around a chest. Its 5.89-MU gap was shorter than the local grid unit but longer
than one walking step, leaving an empty route. Breadcrumb arrival now uses the
larger of one step and half the body radius, with a supporting-height check.
The retained failed campaign save reproduces the blockage; its matched current
load passes the chest without overlap or recovery teleportation.

A second fixture places the player directly above a follower on a solid 3D
platform with a connected narrow staircase. Arrival requires compatible floor
height; partial routes continue from the floor actually reached. A 32-MU stair
can leave only 3.6 MU of valid body-center space between grid samples. If the
initial search makes no vertical progress, quarter-unit shifted sampling phases
reuse the same local window and validate their initial link from the real body.
All phases share a ceiling of 4,225 native position queries per search. The
fixture was not widened to make this pass. The current body reaches the upper
floor by tic 280 and settles within ordinary following distance.

Recovery retains the approved 1,024-MU distance and twelve legacy ring candidates.
It validates floor support, ceiling, native fit and all local solid bodies,
including non-shootable props. Leader sight rejects BSP void outside the map
outline, which TestMobjLocation alone can accept. A failed candidate search never
moves the original body onto the player. No per-tic global actor scan is added.
Old escorts lazily adopt revision 1 without replacing their original actors;
new idle states are appended after existing states to retain saved offsets.

## Native evidence and boundaries

GZDoom 4.14.2, Windows Vulkan, fixed RNG 282, 1280x720, one engine at a time,
background simulation enabled, master audio 5%. These are functional movement
tests, not a MAP03 siege FPS benchmark. The final immutable gate passes 23 runs
and 375 assertions. The normal build, frozen tested runtime and all 16,375 source
members agree byte for byte. Final runtime SHA-256:
`3420254ceb56c9a8dd0d4e6ea47cd1528ac5496c72727f30faddc832f2881b2e`.
Cases use issue322-final17; resumption uses issue322-resume02 and port reload/
round trip use issue322-ports01, all with that identical production fingerprint.
Independent code review found no
remaining blocker; project validation and build pass.

Measured healthy native speeds use ordinary collision and the complete ramp:

| Prisoner | MU/tic | m/s |
| --- | ---: | ---: |
| Unitario | 3.629370 | 3.969623 |
| Federal | 3.827037 | 4.185822 |
| Bestia | 3.266635 | 3.572882 |
| Tarot | 3.732683 | 4.082622 |

The former healthy Unitario was 87.5 MU/s (2.734375 m/s). Individual carried
loads and Agility explain the different current speeds. Post-physics velocity
samples already contain native friction; displacement is the travel measurement.
The first Bestia sample stopped after 210 tics, before its heavier mass completed
the ramp. Extending the observation to 420 tics reached the exact expected speed;
the production formula did not change to make that test pass.

For an unreachable upper destination, 35 isolated native searches averaged
2.415323 ms, with a measured peak of 2.448400 ms and at most 4,225 queries.
These are elapsed search costs on this machine, not a universal CPU bound or
an FPS measurement. Failed route searches retry at most once per second.

The matrix covers four-body open corners/reversal and a 96-MU corridor with a
closed/reopened sector door, stationary sound/dialogue, recovery clearance,
low ceilings, unsupported floors, void candidates, stale intent, stairs,
overlapping floors, narrow stair sampling, the shared query ceiling,
airborne acceleration, quiet recovery completion, combat ownership, native
current/legacy save loading, ongoing/blocked escorts and hub return. Exact
saved references, inventories, health, identity and unpaid rewards are checked.
Save loads require exact health. An unpaused hub return permits only the existing
regeneration rate over elapsed map tics; an initial zero-regeneration expectation
incorrectly rejected that legitimate healing and remains a diagnostic failure.

The campaign itinerary is generated from MAP02_MANIFEST.json's upper_cells,
which include upper slabs over the return tunnels. It uses actual original
prisoners, production release actions and native key/gate opening. Combatants
are removed and pressure triggers disarmed only in this diagnostic; trapdoor
bodies retain their supporting collision. Thus it validates navigation and
progression, not combat survival, key discovery or ordinary puzzle completion.
Its driver uses native movement and waits for followers before recovery range;
no released follower is repositioned by the driver. The final 136-point itinerary
passes with six driver sidesteps and all four original bodies extracted without
overlap or recovery teleportation. Native port representations pay exactly four
authored rewards, retain paid state after save/reload and remain single on hub
return; extracted originals do not reappear in the sewer. Native extraction owns
that change of representation; the test does not claim a single Actor crosses it.

The first full driver also collided with the real chest; it now uses native
TryMove and local sidesteps without removing that prop. Resuming a diagnostic
from a campaign save must reconstruct its EventHandler's original-body links
and itinerary cursor: those diagnostic fields are not serialized by the engine.
The failed resume fixtures and the separate genuine follower blockage remain
distinct in the evidence archive.

One full itinerary reached all four cells and its final waypoint without overlap
or relocation, but the driver's rounded endpoint lay before the extraction
marker. Three followers correctly stopped at their 96-MU following distance
outside extraction. The diagnostic now continues beyond the marker by the
authored follow distance so the group can enter its radius. No production
extraction or following threshold changes; the premature-endpoint failure is
retained and the corrected full campaign is tested separately.

Earlier compile failures, centerline-only driver deadlocks, the missing-current-
input driver, incomplete heavy-body ramp, void recovery failure and the invalid
absolute Windows save argument remain archived as failed development evidence.
Loading uses the basename relative to the isolated savedir; that does not alter
the saved file. A ten-tic startup wait on a MAP03 save exited normally before
the diagnostic callback ran: no completion marker or assertion was recorded.
The retained retry uses the exact same packages and save with seventy-tic
command waits; both port reload and the sewer/port round trip pass. This is a
launcher-timing correction, not a save-state or production-runtime change.
The evidence gate also rejects the early successful DONE before those later
map phases: complete native logs pass, truncated logs and wrong counts fail.
An actor autoactivated when granted as inventory caused the
initial release-action diagnostic to call Use twice; the final driver attaches
the action explicitly and invokes its production Use once.

## Reproduction and author acceptance

prepare.py freezes source and fixture hashes. run_matrix.py runs sequentially;
--campaign selects the long MAP02 itinerary. A legacy runtime can be supplied to
prepare.py --legacy-runtime to generate an actual old-version save. Keep private
saves, generated WADs/PK3s, the engine and development IWAD out of distribution.
archive.py retains raw compressed logs, scripts, source evidence, launch records
and save hashes, then verifies all normal package members against tested source.
Final checks may reuse unchanged passing cases only with an identical production
runtime fingerprint. Each fixture fingerprint, source, command and sampling
duration remains attached to its own run; added save/campaign diagnostics do not
retroactively change the fixture used for earlier movement cases.

Author acceptance: CA322-01 (origin 5.4.35 / #322) passed on 2026-10-18, when
the author explicitly approved prisoners after the earlier following/idle
confirmation. No qualifications were reported. Native results and their limits
remain unchanged, including the documented packed-row obstruction; approval
does not claim a new fix for it.
