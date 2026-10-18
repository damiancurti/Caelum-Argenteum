# Production actor maintenance — issue #353 / 5.4.43

The author adopted three #318 results: derived-statistics/carried-weight caches,
skipping already-full resource recovery, and phased port attacker group targeting.
This delivery integrates them into normal gameplay at the existing map-wide
threshold of 500 living shootable combatants. The player counts toward that
threshold; offscreen bodies count. No additional discovery scan is introduced.

Health, damage, resource balances, inventory, collisions and movement remain
individual. Active recovery and timers retain their cadence. Only existing port
attacker command groups share the new 100-tic target deadline; attacks still
check native visibility/range. Target timing deliberately changes combat.
Temperature remains at 35 tics. The separately approved maximum-adrenaline
policy is outside this focused implementation; #354 is separate cache research.

## Runtime and native evidence

Final normal runtime: `a22f81b13507e8a016ec83d338f80e790f8c8e74fcf9ac0540a6b3b98248e090`,
16,378 members, exact current source with release labels 5.4.43. No measurement
hooks are inserted in the FPS runtime. Baseline is the normal 5.4.42 runtime,
repacked deterministically as `a54546d67f01d733b910e93b58c62cd67d7b72c062a0c3f26410cbd180a3e1a1`
from input `a3c887560a07edca77621f229856ac830b2e082a7bd7d4c79f8ec8950473bebd`.

- `issue353-final-checks01`: 3,705 assertions, zero failures. All 15 derived
  outputs; stable/changed inputs; real armor types, four slots, break/repair,
  finite stack/split/transfer/use/last-unit mutations; active/saturated recovery;
  deadline distribution; native target death/destruction; retirement; 499/500
  threshold and offscreen/shootability/lifecycle controls are covered.
- `issue353-final-save01`: new save, same-runtime reload and 5.4.42 forward load
  retain actual HP, anima, air, lucidity and finite inventory; cache migration
  is idempotent. Each prints cumulative 10 passes; this is 28 newly executed
  assertions across the three runs, not 30 independent assertions.
- `issue353-save-legacy01/finalrollback01`: the final runtime's forward save
  reloads in normal5.4.42 with actual HP/resources/inventory/weight intact.
  The counter reaches15: five new assertions after the saved ten. This completes
  the reversible old->final->old load, not merely the earlier candidate rollback.
- `issue353-final-travel01`: actual MAP99 -> MAP98 -> MAP99 hub round trip,
  cumulative 20 assertions, zero failures. House resident, summoned and converted
  identities/HP/inventory persist; player subscriptions clear; map-local caches
  are replaced. Acceptance requires both stage2/MAP98 and stage3/MAP99 markers.
- `issue353-audit02`: two separate 700-tic combat windows compare every cached
  read against the original calculation. Retained-body counters are
  1,108,490 / 1,108,489 / 296,861 (health/offense/weight), then
  1,108,492 / 1,108,492 / 296,919; zero mismatches. Destroyed bodies may no longer
  contribute counters; any mismatch still emits an immediate failure. These
  instrumented runs are excluded from FPS results.

Earlier development checks include 847 assertions, expanded 3,705 checks and
20 travel checks before the final guard-array write optimization. A 5.4.42 save
was loaded by that candidate, saved again and loaded by 5.4.42: actual state
survived the reversible round trip. That earlier rollback used `e68e74ef...`;
the final-runtime reversible round trip is listed separately above.

## Presented-frame comparison

Completed 18 normal-runtime windows: three repeats at each of
two fixed cameras, with a baseline before and after each integrated-runtime run.
Each simulation replay starts at saved tic 3641 and ends at 4341. FPS capture
begins at tic3711, after a 70-tic warmup, then trims one second at each end.
Startup is capped; wait35 precedes uncapping. Callback intervals and total
tics/second include that startup and describe a different window. The common save starts
with 600 living defenders, 998 living Mandingas and Zupay, from the accepted
1,000-admission siege. Initial aggregate state must match exactly across runs.
The actor limit is never raised to 6,000.

The observer is common to both runtimes and performs startup/100-tic censuses,
tic timestamps and render-callback timestamps. This overhead is shared and is
not a removable production subsystem cost. The two cameras are city
`(0,320,0), yaw180` and front `(-14464,-14000,0), yaw270`, pitch0.
Native Vulkan, RTX3070Ti, 1280x720, uncapped, unpaused/background rendering,
5% master audio. PresentMon records actual application presentation intervals.
External QPC markers are polled every50ms; discard one second at each end and
require complete positive intervals inside those bounds, one nonzero DXGI swapchain,
monotonic timestamps and surrounding coverage. Render callbacks are reported
separately and are not substituted for ETW FPS. The mean-FPS and p99 measures
do not certify continuous50FPS on every street/view or during a whole siege.

The final batch (`issue353-performance04`, prefix`final`) contains 9,007 selected
DXGI intervals; all18 same-condition replay comparisons match all nine state
checkpoints. All12 cross-condition comparisons differ, as expected when target
cadence changes the battle. The collector reports no overflow/error for this
batch. The table gives medians of run means, not medians of individual frames.

| Camera / runtime | Median FPS [run range] | Median p99 ms [run range] |
| --- | ---: | ---: |
| City / normal5.4.42 | 34.40 [29.56-40.50] | 90.58 [79.36-106.05] |
| City / integrated5.4.43 | 46.80 [37.81-49.47] | 71.26 [65.98-80.96] |
| Front / normal5.4.42 | 20.58 [12.44-32.48] | 174.18 [143.93-256.71] |
| Front / integrated5.4.43 | 32.20 [29.78-39.42] | 120.95 [113.56-136.69] |

Against the mean of its two adjacent controls, each candidate run improves:
city median+26.16%, range+25.93..+31.66%; front median+70.70%, range+36.54..+75.51%.
Those are session observations, not exact subsystem costs or a statistical
confidence interval. Control variation is substantial, especially at the front;
three candidate repeats per camera cannot separate all host variability.
Two windows mix Composed Flip and Hardware Independent Flip on the same valid
DXGI chain (`final-s1-r0-n0-m0`, `final-s0-r2-n1-m1`); retain them rather than
selecting only favorable presentation modes. The slowest control has191
presentations, so its p99 depends on very few frames. Each of the six variants
also exceeds both adjacent controls individually; mixed-mode windows do not
account for the direction of every pair's improvement.
The improvement supports retaining the approved integration, but this batch
does not establish the author's partial goal of stable50FPS. Frame-time tails
remain high. Historical5.4.42 diagnostic numbers used another window/session
and must not be substituted for these contemporaneous controls.

## Review, exclusions and limits

Independent review caught player travel subscriptions and outgoing/retired
leader subscriptions; both were fixed before final checks. The private audit
initially referenced an addon class from an earlier-compiled PK3; audit01 failed
compilation and is excluded. Audit02 keeps its counters inside the instrumented
runtime. Native01 used `new` on an Actor; travel01 had a case-insensitive name
collision; travel02 verified only its first leg. All were corrected and are
excluded from final pass totals. Performance02's pilot lacked start/end markers
because the saved handler did not start on load; it is excluded. Performance03
uses a transient first-tick latch and strict exact-start checks. Its 18 windows
and the first 18 research windows yielded only GDI/Other/0x0 records, with an
overflow warning in the original collector; all are excluded from FPS. Enlarging
the buffer alone did not fix a startup pilot. Waiting35tics before uncapping
restored the game DXGI chain with the same observer. The final comparison uses
performance04, a warmed FPS marker and strict presentation-chain gates. Its
initial `matrix` attempt started before the collector request completed and is
also excluded; only the complete `final` prefix is eligible. No failed draft
contributes FPS results. The exact Windows/driver startup mechanism is unresolved.

Actor caches still pay per-call dependency guards. Native mutation hooks cover
the current writers; future direct item writes must notify the owner. Fallback
within100tics is not proof of same-tic correctness. Cold cache rebuilding is
not itself spread over100tics. Shared target response changes combat workload,
so the total FPS difference is not a pure cost of target-search instructions.
No agent test confirms CA353-01 or closes the wider #318/#327 route/performance
work. Pending author checks remain in the root pending_test.txt.

The normal development package matches all16,378 source members byte for byte.
The interactive-preview smoke loads MAP03 with the saved siege active and free
input; its city screenshot was inspected. The preview retains saved player
invulnerability and is not a performance measurement. The capture supervisor
and temporary keep-awake request were released after the shared measurements;
the active power plan is unchanged. Project/index/archive checks are recorded
in delivery_checks.json.

## Reproduction

Use the final source of this delivery, GZDoom4.14.2 and a locally owned development
IWAD. Rebuild a separate normal5.4.42 control from parent4293ee39. In fresh build
directories, `prepare.py` creates checks/save/travel fixtures;
`verify_native.py` runs the complete native gate, including both travel legs.
`prepare_performance.py --directory <fresh> --baseline-runtime <control.pk3>`
creates the ordinary runtime variants and common observation addons. Generate
the baseline `cache-battle.zds` with seed.cfg before measurement. Both variants
use the same PK3 basenames to satisfy native save dependencies.
Run `run_matrix.py --directory <fresh>` with an authorized active PresentMon
collector; afterward `report.py --directory <fresh> --collector <csv>` validates
all intervals and prints the comparison. `prepare_audit.py` creates a separate
instrumented package; never use its timings for the normal-runtime comparison.
Exact fingerprints distinguish the measured bytes from later repackaging.
Development engines, IWADs, packages and private saves are not distributed.
