# Structural cache notifications — investigation #354 / 5.4.44

This is a private follow-up to the production adoption in #353. It does not
change normal gameplay. The question is whether the remaining cache dependency
guards can do less repeated work while retaining immediate correctness.

## Candidate and mutation contract

The control is the exact normal #353 runtime
`a22f81b13507e8a016ec83d338f80e790f8c8e74fcf9ac0540a6b3b98248e090`.
The private candidate is
`ecdcca005d21d2c62d2d9e9a9a3199e5b995a421b2ce591ed9d636312c3bd108`.
Only six runtime members change. The manifest records every before/after hash;
the generator applies assertions to each replacement and never edits src.

Each health/offense guard stops reading 12 armor type/tier/durability fields
and five personality revision/value fields: 17 structural reads removed per
guard invocation. This is not removal of all cache guards. Mass, actual HP,
attributes, adrenaline, movement/thermal/elemental inputs and every weight
guard remain. Fallback deadlines remain at most 100 tics and are phased as in
production. Cached outputs still restore every assigned field.

Owner-local notices invalidate health/offense caches at all identified current
NPC structural writers: base initialization, armor initialization/replacement,
personality migration, contact-impact wear, explosion wear, direct armor-impact
wear, Rulo initialization/repair, and bull/rat initialization. Wear notifications
occur before zero-HP-damage early returns. The armor model has no owner; the
NPC caller sends the notice, without searching all actors for an owner.

Future direct writes or third-party extensions must call this notice explicitly.
The negative control demonstrates why: an unnotified structural write does not
invalidate either guard; forcing its deadline to expire then causes a refresh.
It does not simulate a real 100-tic wait or prove an incorrect derived output
from that particular helmet change. The production suite separately checks
all phase/deadline bounds. No claim of universal writer coverage extends beyond
the inspected source and tested paths.

## Correctness evidence

`issue354-research01/checks01`: 3,958 assertions, zero failures, including the
3,705 production-cache controls adapted so direct fixture writes explicitly
notify their owner. The 253 extra assertions cover native armor initialization,
replacement and personality migration; an unnotified-write negative control;
real contact and explosion wear with damage annulled by Toughness; direct
armor-impact wear/invalidation (that method itself never subtracts HP); and actual
Rulo repair with cached broken light-armour hand/foot bonuses. Each derived
output is compared immediately against the original calculation. Rulo's
dexterity must actually increase, preventing a no-op repair test.

Two separate 700-tic native battle audits pass: retained-body read counters are
1,108,490/1,108,489/296,861 and 1,108,492/1,108,492/296,919 for
health/offense/weight, exactly matching production audit counts, with zero
mismatches. Their timings are excluded from the FPS comparison. Research
metadata uses 5.4.44 while the private
runtime retains the #353 release labels, keeping the control bytes fixed.

## Performance method

Eighteen windows use the exact same private saved battle and observation addon
as #353. Three repetitions per camera each bracket the candidate with normal
#353 controls. Each run has 700 simulation tics; initial saved actor state/camera
must match, and all nine state checkpoints must match every paired control.
The presentation window begins after 70 tics of startup warmup and also trims
one second at each end. Total replay callbacks/tics-per-second include the
initial capped startup and are separate from this ETW interval.
Same-condition replay divergence invalidates results. Aggregate equality alone
does not prove individual cached values; the separate read audits provide that
additional check.

The initial18 research01 windows are excluded from FPS because the collector
recorded GDI/Other/0x0 events. Research02 uses the corrected wait35 startup
and FPS_BEGIN marker described in CA-KP-131. Native checks/audits of the same
candidate bytes remain valid. No invalid presentation records supply a result.

Use the #353 `report.py --require-equivalent` ETW validation: exact PID/runtime/
fixture bindings, complete presentation intervals within QPC bounds after 1 s
trims, one nonzero DXGI swapchain, monotonic timestamps and surrounding coverage. Native
Vulkan/RTX3070Ti/1280x720, uncapped, background rendering/unpaused, 5% audio.
Results are application presentation FPS and frame-time tails, not isolated
instruction costs or a general 50 FPS guarantee. Thermal cadence, resources,
adrenaline, geometry and target-search policy are the same in both variants.

## Result and recommendation

The final 18 windows (`issue354-research02`, prefix `final`) supply 10,822 validated
DXGI presentation intervals, all Composed Flip. The collector reports no errors.
All 18 same-condition comparisons and all 12 candidate/control comparisons match
every one of the nine checkpoints. The table describes medians of run means.

| Camera / runtime | Median FPS [run range] | Median p99 ms [run range] |
| --- | ---: | ---: |
| City / conservative production | 39.85 [39.12-48.05] | 79.52 [66.40-81.07] |
| City / structural notifications | 44.12 [39.67-47.25] | 65.42 [65.12-79.70] |
| Front / conservative production | 32.32 [30.81-39.21] | 119.63 [110.85-124.31] |
| Front / structural notifications | 32.93 [31.16-39.59] | 123.30 [109.90-131.36] |

The paired measure compares each candidate with the mean of its two adjacent
controls: city median +0.20%, range -0.52..+19.67%; front median +2.95%, range
-1.70..+3.96%. These gains are not the ratio between the general medians above.
Both views include a negative pair. The city outlier and control variability
prevent a claim of consistent improvement; the front's median p99 does not
improve. These short windows do not establish statistical significance or an
exact cost per guard invocation, and must not be compared to the preceding
production batch as though they shared contemporaneous controls.

Recommendation: retain the conservative guards in normal gameplay. The private
candidate passed the inspected mutation contract, but its extra maintenance
obligation is not justified by a demonstrated consistent FPS benefit. Preserve
the tooling and writer audit for future profiling; first localize the remaining
update/render stalls before removing more correctness guards. Neither variant
establishes stable 50 FPS in this batch. Normal thermal and adrenaline rules are
unchanged; the separately approved siege-adrenaline production work remains open.

The candidate runtime and checks fixture reproduce identically in research01
and research02; only the observation warmup changed. Final normal release 5.4.44
retains production #353 logic and changes its two diagnostic release labels only.
Project validation, normal packaging/smoke, archive integrity and lifecycle
checks are recorded in delivery_checks.json. Author CA353-01 remains pending.

## Reproduction and limits

Start from the #353 normal runtime and its saved benchmark state. In a fresh
build directory run this folder's `prepare.py --directory <fresh> --control
<normal353.pk3> --seed <cache-battle.zds>`. Use checks.cfg with current/baseline.pk3
and quick.pk3. Use validation_5443/prepare_audit.py with `--issue 354 --release
5.4.44` for a separate instrumented candidate.
Run validation_5443/run_matrix.py and its report.py with `--require-equivalent`.
All dependencies remain local; no engine, IWAD, private save or PK3 is distributed.

This research does not replace the production package, confirm CA353-01, or
close #318/#327. Promotion would require the explicit mutation contract to be
maintained whenever a new NPC structural writer is introduced. The 100-tic
fallback remains a recovery mechanism, not a substitute for correct notices.
