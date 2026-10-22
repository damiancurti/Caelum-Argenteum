# Source recovery validation - 5.7.3 / #406

The source clock now ignores time at or below its last credited timestamp.
Returning from a backward observation therefore cannot regenerate the same
interval twice. Rescheduling recovery includes any wait until that credited
timestamp is reached. Civil-calendar and elapsed-source clocks have different
origins; only the waiting duration is converted between them.

The approved 0.1%-per-day rate, capacities, fractional carry, calendar identity,
finite tutorial quotas and merchant ownership are unchanged. No saved field or
schema is added. Existing art and MAP01/MAP03 geometry are unchanged.

## Static checks

Project validation passes, including current version headers, dialogue data and
document-index freshness. collect.py verifies every member of the final PK3
against src and records the package hash in report.json. Test packages, private
saves, the engine and IWAD are local-only; no binary dependency is distributed.

## Native evidence

The final selection has 100 PASS / zero FAIL across fourteen serial GZDoom
4.14.2 runs. Windows 11, Ryzen 9 5950X, RTX 3070 Ti, Vulkan 1280x720, 60-FPS cap,
unpaused background and 5% audio; complete launch/environment records are in
report.json and raw output is retained under native/.

- Seven new source profiles plus the existing tree, iron vein and fiber bush:
  hourly versus one-day catch-up, exact rate, repeated observation, cap/carry.
- Unstamped old source, backward/returning clock, million-day capped catch-up,
  finite tutorial gold and decorative exceptions.
- One idempotent calendar entry per source; rewind-aware due date; independent
  source renewal versus merchant stock/wallet changes.
- Offscreen recovery through ordinary unpaused engine ticks.
- Actual save/load, five-day resumed catch-up and hub round trip.
- Actual 5.7.2 save loaded in 5.7.3, saved again and reloaded. The original save
  hash is unchanged and the original runtime still loads that original save.
- The manual scene's native Use input, forward/backward time controls and saved
  reserve are exercised automatically before the author launcher is opened.

The million-day check uses one capped arithmetic operation, not a loop over
historical days. The measured call duration is retained in the boundary log;
a single timing sample does not establish throughput or rendering performance.
No rendering change, FPS improvement or mansion/sewer/siege acceptance is claimed.

## Preserved exploratory evidence

baseline-boundaries reproduces three failures in the previous runtime: the
credited stamp rewinds, returning time duplicates recovery, and later recovery
retains that excess. deadline-regression reproduces an early calendar deadline
in the guard-only implementation; the final code includes the waiting interval.

current-matrix's three failures came from a fixture expecting a full 0.25 g
deficit to recover in one day even for 10/50 g sources. Its cap test now starts
half a day's recovery below capacity. final-matrix records a compile error in
the new private manual helper: `action` was a reserved parameter name. It was
renamed. Neither fixture issue changes production balance. Earlier passing
delivery-* runs are retained but superseded by verified-* after the deadline fix.

## Author check

CA406-01 remains pending in the root pending_test.txt. Run prepare.py, then the
manual.ps1 launcher with PowerShell execution-policy bypass. The visible terminal
is a Spanish guide; all controls are pressed inside the private game. E extracts
honey, F2 advances 100 days, F3 shows the reserve, F4/F5 save/load, and F6 rewinds
100 days. F6 followed by F2 must not re-credit the same interval. F1 displays
state without refilling. The private clock controls never modify a campaign save.
