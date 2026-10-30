# #420 / 5.9.3 campaign membership

The three confirmed rescued representatives offer free membership at Neutral
or better reputation. The native action revalidates the speaker and current
eligibility. It updates existing membership storage, keeps hidden affiliations
private and grants neither reputation nor money. Other factions remain deferred.

Static: project validation has zero errors; indexes and diff checks pass. Native
conversation IDs/page order exactly match 5.9.2; only choices were added.

Native GZDoom 4.14.2 / Windows 11 / Vulkan / Ryzen 9 5950X / RTX 3070 Ti,
unpaused background at 5% audio; requested 1280x720 (desktop scales to 1520x825):
- legacy-01: 2 PASS, real 5.9.2 open-dialogue save retained.
- final-migration: 17 PASS; -50/-49 boundary, captive/sleeping/absent speaker,
  unconfirmed Leandro, repeat joining, all three confirmed faction IDs, unchanged
  money/reputation/reward flags, hidden membership, current save and hub travel.
  Final map-local counter is 16 after hub restoration; emitted assertions are 17.
- final-ui: 3 PASS through actual native menu replies; inspected Spanish choice.
- final-reload: 3 PASS, exact memberships/tenures/private knowledge retained.
- final-rollback: original save opens with preserved 5.9.2 runtime and fixture.
  No new assertions; saved counter 2. New saves are not sent to old packages.

Evidence records commands/hashes. Rebuild current package, run prepare.py and
replay run_native.py commands with new labels. Generated packages, saves and
engine/IWAD remain local. No population scan or frame-rate claim is introduced.
Author acceptance awaits the complete V5.9 terminal. Service wiring remains #424.
