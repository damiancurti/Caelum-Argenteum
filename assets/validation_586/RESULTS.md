# Issue #411 - Central property access, 5.8.6 (partial issue)

One existing central Barracas dwelling supports purchase and prepaid rental.
Former residents and their chest move to CAH070 with their original identities,
locks, keys and inventory. Camp construction and furniture placement remain
pending; this stage does not implement or accept the full issue.

## Native evidence

**142 PASS across 16 selected runs.** GZDoom 4.14.2, Windows 11, one instance,
unpaused background, 5% audio.
`report.json` lists selected runs and individual PASS lines, excluding restored
handlers' cumulative RESULT totals. Original saves and PK3 files stay private.

- Purchase/rental prices, exact expiry boundary, early/late renewal, no arrears,
  no refund when buying, insufficient funds and repeated UI input.
- Normal and accelerated rest share the residence gate. Expiry denies new
  deposits but allows retrieval without changing stored items or money.
- Save/load, two-way native hub travel, actual doorway UI action and return.
- The 600-resident roster remains intact. Four residents change home; all 596
  unaffected deployment routes remain identical and each changed route retains
  its combat destination. The route generator produces identical bytes twice.
- Original 5.8.5 save migration preserves the actual injured body, chest and
  inventory during transport. Hub revisits preserve TIDs, lock/key tokens,
  exact quantities and uniqueness. The old house does not reacquire the chest.
  The untouched original save remains loadable using its original package.
- Spanish/English property panels were visually inspected at 1280 x 720.
  The author fixture provides diagnostic funds and an owned chest separately
  from production furnishings; it does not alter existing campaign saves.

The one-time typed migration scan measured 0.0073 ms with 256 unrelated chests
in a private fixture. It runs only on initial migration in the original house,
owned by the saved resident registry; it is not a per-tic or per-resident scan.
The authored population is one household chest plus any player-placed chests,
so there is no claimed hard population bound. The 256-chest sample is a measured
diagnostic bound, not an inventory cap or worst-case proof for unlimited content.
No render/frame-tail or 60-FPS acceptance is claimed by this test.

## Failures and corrections

Retained earlier logs show a reserved identifier and missing play scope caught
at compilation; a fixture incorrectly gave overweight copper instead of compact
gold denominations; direct old-save loading skipped migration behind saved
Ready; default CheckSight rejected the intentionally invisible doorway; and
legacy health/pointer assertions incorrectly ignored normal regeneration and
native hub pointer lifetime. Production migration and visibility were corrected;
fixtures now distinguish transport identity from restored map identity. The
initial half-Life injury and original save remain preserved for rollback.

A final UTF-8 comment repair changed no executable lines. The collector proves
all other package members and all non-comment lines are identical to the full
suite build; the final core and author fixture are checked again on the final
source-matched package. A shell wrapper after final-core-01 reported an escaped
variable error after the engine had exited successfully; native metadata records
exit code zero and all 15 assertions. That shell wrapper is not used for delivery.

## Static checks and author status

Project validation and generated indexes must be current. The collector checks
every packaged source member and records package, engine, IWAD and save hashes.
No new art, map geometry, external asset or accepted balance outside #411 changes.
CA-KP-158 records the reusable migration/visibility/identity findings.

CA411-PROPERTY-01 is pending in the single root pending_test.txt. The terminal
runs a private campaign at the real property. Agent evidence does not establish
author acceptance. Camp equipment approvals are recorded in SYSTEMS/#411;
physical calibration, acquisition, placement and remaining V5.8 issues stay open.
