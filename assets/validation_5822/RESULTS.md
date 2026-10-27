# Shared-water mansion fixtures — 5.8.22 / #410

The four existing first-floor bedrooms gain one washstand, bathtub and toilet
each, using accepted art and dimensions. All twelve fixtures share the kitchen
sink's existing 200-L reserve. The source map and all model/sprite/graphic bytes
remain unchanged. No old pending author check is retired.

Final build: `build/issue410-cooking/final22c/caelum_argenteum_dev.pk3`.
`report.json` records its exact SHA256, source comparison, unchanged asset count,
executed literal PASS count and original-version rollback evidence. The
collector rejects assertion, VM, static and native-exit failures; it counts
newly executed PASS lines, not cumulative counters restored from saves.

## Native coverage

- All twelve fixtures: actual first-floor geometry, solid collision, clear
  approaches, aimed Use range, water-source lookup, posture ownership and exits.
- Existing first-floor doors: full sampled leaf sweeps remain clear of the
  additions. Existing bedroom beds and complete table/chair layouts remain.
- Occupied placement defers without retaining an overlapping fixture; other
  completed positions remain. Clearing the spot allows the next retry.
- Shared reserve: canteen filling, partial/empty supply, exact bath water/soap,
  seated toilet completion and cancellation, another bedroom drawing the same
  supply, one-litre refill and independent city-house supply.
- Save/hub persistence: one installation, thirteen total mansion water/hygiene
  fixtures including the existing kitchen sink, original actors and only elapsed
  water refill. Original 5.8.21 save forward load and untouched-copy rollback pass.
- Prepared author controls load normal bindings and supply water, soap, an empty
  canteen, contamination and metabolic credit. No new F-key dependency.
- Actual mansion screenshots cover all four layouts and native lying/seated
  poses. Art is reused, not newly generated. Author placement review remains pending.

The focused resource check advances the existing bath/toilet services directly;
it verifies source binding and transaction amounts, not a new full-duration
clock test. Previously accepted #502 timing rules remain unchanged.

## Initial failures and final correction

Early layouts passed fixture-only placement while blocking approaches; one
washstand also stood at a doorway. The expanded review found tables101/103
missing because their chairs were being placed after overlapping new tubs.
Final coordinates preserve doors and the old complete layouts; the quest now
prepares accepted furniture before bathroom additions. CA-KP-178 documents this
lesson. Private failed `bath-layout01..05` / `bath-access01..02` logs remain in
the worktree build folder; they do not count as accepted evidence. The initial
compiler failure was a test-only incorrect `FoodIllness.Get` signature.

Visual review then found four bathtub angles and two toilet angles that put the
existing posture camera against a wall. Their final orientations keep the camera
inside the room. The final twelve captures are named `finald-mansion-*`; earlier
captures remain historical evidence and must not be mistaken for the final layout.
The private capture helper also needed to wait for normal quest installation
before its first picture; it now reports failure instead of silently skipping
a missing fixture. The author helper uses the same readiness interval.

The previous `final22` package differs only in the six fixture angles. Its
resource transactions and original-save/hub checks remain applicable; final
placement, access, all four seated/lying views and manual setup were repeated
against `final22c`. `report.json` identifies the package used by each run.

## Performance limits

Matched native 20-second, 700-tic peaceful northwest-bedroom windows use the same
camera, RNG, 1280×720 Vulkan, 60-FPS cap, unpaused background and 5% audio. The
original/final render-callback mean is 16.6667/16.6644 ms; P95 is 17.6638/17.6394 ms,
P99 is 18.5615/18.6085 ms, worst 19.8151/19.7417 ms. Simulation windows measured
19.9601/20.0677 s with 100 ms polling uncertainty. These two samples show similar
callback cadence in this selected scene; they are not GPU/display presentation
measurements or a claim of general 60-FPS mansion/sewer/army performance.

The installation performs a typed lookup of one controller only during initial
placement/retry and at most twelve local collision queries per call. After
success the quest's saved ready flag stops these calls. The controller has no
custom Tick; native actor bookkeeping remains. Twelve new fixtures retain normal
individual physics/interactions and accepted contamination behavior.

## Author status

`CA410-MANSION-BATH-01` remains in root `pending_test.txt`. The terminal helper is
prepared and intentionally not opened while the author is away. Earlier kitchen
and camp-cooking checks remain separate. This patch does not complete #410 or
V5.8, and no merge/issue closure or manual acceptance is inferred.
