# #421 / 5.9.4 Barracas story

Extended conversations cover rescue arrival, existing captain recognition,
preparation and real siege aftermath. Paid prisoner accounts and the guard's
account are remembered privately and listed in the Journal. Original rewards,
amnesia and concealed identities remain unchanged. #422 adds the two separate
quest chains and restitution, not this patch.

## Verification

- Static: zero validator errors, fresh indexes, diff check. The original USDF
  runtime is an exact byte prefix of the extension; old native indices survive.
- Native: GZDoom 4.14.2, Windows 11, Vulkan, Ryzen 9 5950X, RTX 3070 Ti;
  unpaused background at 5% audio. Isolated MAP03 fixture with real prisoner and
  guard classes, not the full city or a performance measurement.
- legacy-03: 2 PASS, real 5.9.3 open-dialogue save retained.
- final-migration-03: 23 PASS, zero FAIL. No invented legacy testimony; payment
  prerequisite; repeated/private accounts; actual preparation/attack/victory
  flags; native guard recognition and unchanged clue; invalid interlocutor;
  current save and real MAP03 -> CA421B -> MAP03 travel. Final map-local counter
  is 21 after restoration; 23 assertions were emitted including UI inspection.
- final-reload: 3 PASS, exact accounts/arrival/reward/victory persisted.
- final-ui-layout: 1 PASS from native reply; inspected all five known names in
  the final compact layout. Diagnostic all-known mask is for layout only.
- final-ui-guard: 3 PASS, real recognition entry and native defense reply;
  inspected Spanish recognition and preparation screens.
- final-rollback: original save opens using preserved 5.9.3 package/fixture.
  Saved counter 2, no new assertions. Original package/save remain local.

After migration/reload tests, only the account-list presentation changed from
one name per line to a semicolon-separated list so all five fit above replies.
Final UI runs cover that change; hashes distinguish the two packages. No logic
or save schema changed after migration tests. Author acceptance waits for the
complete V5.9 handoff. Screenshots use existing appearances pending #423.

## Reproduction and failed probes

Build the current package under build/issue421/current, run prepare.py, then
run_native.py with evidence.json commands and new labels. Saves, PK3s and old
failed logs stay local; no engine/IWAD/fixture package is committed.

The initial fixture guessed a nonexistent defender subclass, then spawned a
prisoner in MAP03 without recording extraction; its normal initialization
removed that actor. Corrected to the real defender and extracted state. The
first guard probe stood beyond the existing Use range; moving it within that
range fixed the assertion without changing production interaction rules. A UI
assertion ran before its preceding network event committed; a wait separates
those clocks. These fixture failures remain recorded locally. No unresolved
runtime failure remains in the final cases above.
