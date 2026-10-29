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

## Author-launch correction, 2026-10-26

The corrected manual script queries all six intended bindings, including T=+user3. Eleven solo-rest assertions pass with no failures. The author terminal now regenerates its fixture before launching. Multiplayer checks remain deferred to V5.12.

Native startup evidence: `native/bindings-fixed-smoke-01.txt` and
`native/bindings-ready-live-02.txt`, with separate command/environment records.
The exact interactive entry reaches the readiness marker; the launcher now
waits for it and reports failure instead of silently handing off an unseeded
scene. The frozen gameplay package is unchanged. This startup evidence is
separate from the original gameplay assertion counts.

Remote desktop key injection did not reach GZDoom. Native binding queries and
scripted commands are agent evidence; physical-key author check CA412-BAG-01
remains pending. No author pass is inferred from fixing the launcher.

## Outside tent interaction correction, 2026-10-26

The author reported that entering the tent and ordinary Use did not work.
The pending individual check now covers production Use -> Rest/Pack -> native
USDF duration selection -> owned bag inside -> safe return outside. It no longer
requires fixture-only teleport/rest keys. No tent, bag or character art changed.

73 newly executed assertions pass in 11 selected native runs; persisted cumulative
counters are not counted twice. `entry-report.json` lists each run and digest.
Coverage includes native Use and MenuEvent/USDF reply routing, ordinary/solo
accelerated rest, Limbo untimed rest, cleaning reservation/cancellation and exact
costs, blocked berth/exit, new save/load, genuine prior active-bag save and original
runtime/original-save rollback. Entry revision0 preserves old behavior; revision1
saves the entrance and native crouch. All16,918 package members match current src.
Runtime entry03 SHA256: `ee9fb082ac2259d80c770f6b4995099801f86985dab5bd4a04eb231538e17407`.
Static validation passes. Captures `tent-native-*` retain the production roof;
the canvas can occlude the resting camera. The camera can orbit through the
existing rest controls; no diagnostic roof hiding is used for this delivery.

Resolved local attempts are retained: missing fixture title, deferred native
crouch Height and overlarge furniture exit distance gate. A fixture variable
used a reserved identifier; a repeated inventory action was already autoactivated;
renaming the rollback addon violated the save's required basename. The selected
runs resolve those errors. Early direct-action captures left the USDF UI open;
the submitted native menu-event captures use the real reply/closure path.

Entry/exit performs bounded event-time probes; there is no new recurring actor
scan. No new rendering-performance or multiplayer claim follows from these
functional checks. CA412-BAG-01 remains pending until the author corroborates
this interaction correction. Tests/questions are held while the author is away.

Final author acceptance, 2026-10-26: CA412-BAG-01 passed, including outside
interaction and the original sleeping bag inside the tent. The pending entry
is retired; no new native execution is claimed for this acceptance update.
Multiplayer verification remains deferred to V5.12.
