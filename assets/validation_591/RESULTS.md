# #420 / 5.9.1 faction consequences

Implemented: seven approved ranks, purchase/sale factor helpers, enemy matrix,
per-character assistance receipts and membership disclosure consequences;
confirmed rescued representatives become hostile only after port arrival.
The existing rescue reward owns payment; the new receipt records its reputation
change once. No generic outfit/race infers allegiance and Leandro remains
unconfirmed. Dialogue declarations/reports are integrated under #419; faction
service transactions under #424. These are outstanding integrations, not a
claim that the whole issue or V5.9 is complete.

## Verification

- Static: project validator zero errors; current dialogue/localization index,
  regenerated document index, diff whitespace check.
- Native: GZDoom 4.14.2 / Windows 11 / Ryzen 9 5950X / RTX 3070 Ti / Vulkan;
  unpaused background, 5% master audio, requested 1280x720 (engine reports
  1520x825 after desktop scaling). Isolated fixtures, not presentation/FPS evidence.
- `legacy-01`: 2 PASS, real 5.8.56 record with simultaneous concealed memberships,
  exact reputations and claimed prisoner reward. Original input save retained.
- `final-migration-hub`: 86 PASS / no FAIL in the emitted log. Loads that original
  save, tests idempotent migration, all rank boundaries/36 matrix cells, lot
  rounding, capped aid, explicit knowledge, one-time expulsion and private
  unrelated factions. Saves current state; actually travels CA420A -> CA420B ->
  CA420A. Confirms captive protection, post-arrival native attacks/resource
  expenditure, hostile dialogue rejection, Leandro protection and de-escalation.
  The final handler counter is 83 because its map-local counter is restored by
  hub travel; pass_count counts all emitted assertions, not that saved counter.
- `final-reload`: 5 PASS after loading the newly saved record; balances,
  memberships, hidden knowledge and duplicate-event guards remain correct.
- `final-rollback`: original untouched save loads with the preserved 5.8.56
  runtime and its original fixture. This is reversible recovery of the original
  save/package, not permission to load new saves in an old engine package.
- Author acceptance: pending the complete V5.9 manual handoff.

The targeting path only examines MAXPLAYERS for the three confirmed port
representatives at their existing four-tic movement cadence; it does not query
the actor population. Other actors and >=500-combatant policy are unchanged.
No performance improvement or 60-displayed-FPS claim follows from this fixture.

## Reproduction and failed probes

Build to build/issue420/current/caelum_argenteum_dev.pk3, run prepare.py, then
run_native.py with the exact commands/load basename in evidence.json and a new
label. prepare.py preserves the 5.8.56 package already used by validation_590 in
the sibling issue418-work worktree. Saves, generated PK3s and failed logs stay
local in build/issue420; no IWAD/executable/test package is distributed.

The first hub script used unsupported changelevel; it was rejected as evidence
and replaced by changemap. The runner now fails on unknown commands. The first
attack assertion read a diagnostic counter active only in TACTORS; final checks
observe native resource expenditure instead. Both failed logs remain local.
Tests were not broadened to retired stress cases. Code-only comment cleanup
after the final build does not change the executable behavior in its hashes.
