# Sleeping-bag clearance — #412 / 5.8.15

80 executed native assertions, zero failures, in 11 selected GZDoom 4.14.2 runs.
The original package reproduces the rejected berth; the final package admits
the same native crouched body and unchanged model footprint. Both rectangular
berths, neighboring body, overlapping/crossed bags, small low/head obstacles,
rear/world walls and open-floor placement are covered. Normal and existing solo
accelerated sleep retain the original bag, recovery factor and tent shelter;
waking releases occupancy. The earlier 18 packing-guard checks pass unchanged.

New save/load preserves an actual tent sleep. A genuine 5.8.14 native active-bag
save loads in this runtime; the original package also reloads the untouched
original save. Five assertions verify continuing progress, ownership, deployed
model identity and releasing control in each compatibility direction. No saved
fields, map geometry or art are changed. Final runtime: 16,917 source-identical
members, SHA-256 `078d33640c90864e875400160570c1abe65814d70657add60b7256d6b686d0f4`.
Static validation is clean; exact commands and machine/package metadata are in
native/*-run.json. Private runtime/IWAD/save files are not distributed.

The existing model bounds are X [-20,20.4], Y [0,8], Z [-44,44]; symmetric
clearance half-width20.4 intentionally overcovers the left zipper-free edge.
The final top-down capture uses two copies of the unchanged model and hides
only the tent roof in the diagnostic addon. It is visual geometry evidence,
not a production rendering change or two connected players.

Performance comparison: the same peaceful tent scene calls clearance once per
native tic, covering the highest normal support-refresh frequency. Both runs
present 1,199 frame callbacks over700 tics/about20 seconds at1280x720 Vulkan,
60-FPS cap, unpaused background with5% audio. Previous p95/p99/worst callback
intervals:16.9281/17.2775/17.6299ms; final:16.9625/17.2718/17.8331ms.
This is a frame-cadence proxy, not measured GPU/display presentation or a
mansion/sewer/army performance claim. Clearance allocates one reused probe,
uses55 footprint cells, one local blockmap query and MAXPLAYERS reservations;
no new routine global actor scan is introduced.

Resolved fixture failures are retained locally: initial second-body checks
released native crouch before sampling height, and the supposed open-floor
point was beside the rear wall. Core05 and the selected final-core retain native
crouch and use genuinely clear ground. A diagnostic vector printf was replaced
with scalar components. Preview subclasses need their own MODELDEF entry to
display the inherited bag states; the addon copies the existing declaration.

Limits: grid circles conservatively overhang cell edges; tight gaps can still
be refused. This stage does not remove the existing solo-rest gate or change
world-clock ownership. Two-client normal/rest-calendar consensus, and the
remaining #410 furniture integration, remain unfinished. CA412-BAG-01 awaits
the author's return; no manual acceptance is inferred. The prepared author
terminal was not opened while the author was away.

Author scheduling update, 2026-10-26: two-player rest verification is deferred
to V5.12. The individual CA412-BAG-01 remains unconfirmed; no native tests were
rerun for this documentation-only scheduling change.
