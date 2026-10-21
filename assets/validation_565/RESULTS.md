# V5.6.5 / #382 — padlocks, household title and local witnesses

## Author follow-up: keep the chest stationary when breaking its lock

The author reported chest movement after the original delivery (`59f9844c`).
`push-before-01` reproduces it with real flail input: four checks pass but the
new position/velocity check fails. Both manual combat push helpers now honor
the receiver's existing DONTTHRUST flag, retaining zero recorded impulse for
the uppercut guard. No serialized fields or balance values change.

**Four focused native runs / 17 passing assertions.**
`push-report.json` and `push-project-validation.json` cover the corrected
package: real flail break, unchanged contents/one theft, stationary position and
velocity, player/NPC push controls on ordinary combatants and movable rocks,
clearing a previous positive impulse, and actual attack after scene save/reload.
Independent static review found no outstanding P1/P2. Author retest is pending.
`collect_push.py` verifies that only the two helpers changed in the runtime and
that the normal package matches all tested members. Reuse the other original
checks within their documented boundaries; the 20-run report below remains
historical evidence for its exact original package, not a rerun of this fix.

Reproduce with the current runner's `attack`, `push-controls`, `push-save` and
`push-reload` scripts (`-LoadGame ca382-push.zds` for the latter). The original
package is retained privately in `build/issue382/pre-push-fix`. `collect.py`
describes collection at the original commit; use `collect_push.py` for this fix.

## Original delivery

The approved steel locks and paired keys use native inventory, individual saved
identities and five existing crafting tasks. Another owner's locked chest raises
theft once on opening or a blunt break. A local spatial query alerts living
combat-capable witnesses within 32 meters and direct sight of the player.
Own/public chests, native quest locks and legacy unclassified items retain access.

Each of the 160 city houses receives a small locked household chest with ten
gold coins, issued once through the traveling resident roster. Obstructed
placement retries; missing residents never respawn. An existing household
resident receives its key. Removing/destroying a chest cannot replenish it.

## Verification

**20 required native runs, 134 passing assertions, zero failing gates.**
`report.json` records the required native runs, assertions, exact engine/package
hashes, configuration, commands and machine environment. GZDoom 4.14.2 / Windows
11, unpaused background execution, 5% audio; native runs are sequential.
`collect.py` checks that the normal build and tested frozen runtime contain the
same bytes and that runtime sources match. `project-validation.json` is the
separate read-only static validation. No author acceptance is claimed.

- Suite: access/ownership, key identity, reusable picks/master, native quest
  protection, pure-steel reservations, all five recipes and repeat completion.
- Witness controls: exact range boundary, wall occlusion, dead/dormant bodies,
  sleeping/stunned bodies, active Redemption and conversation pause. The latter
  directly sets the native conversation flag; no full dialogue interaction is claimed.
- Inventory: second same-tier keys still undergo capacity checks; separate native
  instances retain their pairing. The installed lock adds weight once, outside slots.
- Household tests: two houses, return without coin refill, matching native key,
  obstructed migration, destroyed first resident and an entirely empty household.
- Current saves: carried chest/key/title and witness state; hub and non-hub travel.
  Stationary chest plus traveling key/title checks exercise a distinct hub path.
- Original 5.5.8a and immediate 5.6.4 saves upgrade without retroactive title or
  theft. Upgraded reload is idempotent; original saves still load with their
  original packages. 5.6.4 recipe sheets/knowledge/practice remain intact.
- The author fixture supplies own/foreign/public chests, tools, an equipped flail,
  known recipes, workstations and steel. A real primary flail attack tests breaking.
  Bilingual menu captures are inspected locally; private map captures are not shipped.

## Corrections and scope

Exploratory logs are retained separately from passing gates. `hub-01` exposed a
real pointer-identity defect across hub reconstruction; saved value tokens fix it
(`hub-02`, `final-hub`; CA-KP-145). `suite-02` read storage revision before
initialization in its fixture. Other failed exploratory runs are fixture compiler
errors or author-scene equipment setup: a utility staff casts elements and is not
the requested blunt melee test weapon, so the final scene uses the existing flail.
Independent review also corrected per-instance capacity, guard carbine use,
escort targeting, sleeping/stunned state, conversation/Redemption priority and
household placement. The reviewer performed static analysis, not engine tests.

Vendor/library availability is a separate #383 change. This patch adds no
replenishment, faction-wide response, penalties, new clothes or historical loot
table replacement. Installed padlocks reuse the existing locked chest mesh at
0.5/1/2 scale; carried tools reuse the current key sprite/icon.
No allocation-exhaustion, multiplayer, frame-time or ordinary campaign acceptance
claim follows from these isolated tests. Private packages, IWADs and saves stay local.

## Reproduction

Run `python assets/validation_565/prepare.py`, freeze the normal package under
`build/issue382/current/caelum_argenteum_dev.pk3`, then invoke the runner with
`powershell -NoProfile -ExecutionPolicy Bypass -File assets/validation_565/run_native.ps1 -Label <unique> -Checks -Script suite`.
Other script names and ordered save dependencies are in `prepare.py` and the report.
Use `-Runtime baseline -BaselineChecks` for 5.5.8a and `-Runtime legacy -LegacyChecks`
for 5.6.4. `LoadGame` accepts a filename relative to `build/issue382`.
Use `-Checks -Interactive -Script interactive` to leave the supplied scene open.
