# 5.4.42 / #318 - Actor-local maintenance and 100-tic scheduling

## Scope and author decisions

The author requested actual comparisons of statistics, inventory and resources,
then target selection and temperature, with actor-local change notifications and
maintenance distributed over at most 100 tics. Physics, movement and active
resource recovery retain their existing cadence. The author additionally
approved maximum adrenaline for siege participants and explicitly ignoring
hunger/thirst performance penalties while preserving consumption and damage.

This delivery tests those changes in a private runtime. It does not activate
the prototype in normal gameplay or treat a timing change as an equivalent
optimization. Accepted production improvements must follow the existing
automatic >=500-living-combatant policy; siege adrenaline must be scoped to
participants and the actual encounter lifetime. The retired 6,000-simultaneous
case is never run.

## Reproducible method

Source baseline: `ae8408f58a49e3fd20d3bcf592338d5e54191445`. The deterministic
builder transforms copies of source members, leaving `src/` untouched by the
prototype. Runtime SHA-256:
`34763cc801daa92cd242ec72713fe0e3c7480d51f5033ab59c04dcaa937ba401`.
Fixture SHA-256:
`ef849c4d8f29d2cdf84afa6773b6defa36828161449b5f47f30707b8004fd117`.

GZDoom 4.14.2, Windows 11, Ryzen 9 5950X/RTX 3070 Ti, Vulkan 1280x720,
seed 282, uncapped/vsync-off, one unpaused engine, background rendering and 5%
audio. PresentMon 2.6 captures application presentation intervals through ETW.
The collector runs under the author's existing administrator authorization.

The normal MAP03 siege warms up for 3,640 tics, including gradual deployment,
before a private seed save. All runs load that same save, arm the mode through the console after
a short wait, then continue normal gameplay until WorldTick 3750. Only that
exact simulation tic may begin measurement; missing/late arming fails explicitly. No freeze or replay replaces normal
combat. The measurement spans tics 3750..4450: 700 tics, approximately 20 seconds.
The start has 600 living soldiers, 997 living Mandingas and the commander;
1,601 registered combatant bodies include three already-dead Mandingas.
Inventories, collision, fire, projectiles, damage, deaths and all nonselected
systems remain active. This is a short siege interval, not a full-battle result.
The fixed-camera player is invulnerable and supplies no interactive input;
NPC damage/death remains active. This does not measure active player combat.

The city camera is at body(0,320,0), eye Z 41, yaw 180; the front camera is at
body(-14464,-14000,0), eye Z 41, yaw 270. Both have pitch 0. Three repeats reverse
active-mode order in the middle repeat. Each camera/repeat starts and ends
with baseline: 72 windows, including 12 controls and 60 selected variants.
No second engine, build or heavy validation runs during the matrix.

The observer performs one startup actor census, then registers spawns and
notifies affected actors/groups directly. A common diagnostic census of the
registered list every 100 tics records aggregate population, HP, anima, air,
exposure and camera. Cache dependency guards, instrumentation and counters
remain in measured runtime cost. This is not an overhead-free production gain.

ETW selection uses the matching engine PID and host QPC observations of BEGIN/
END, polled every 50 ms. One second is removed at each end; a selected interval
must fit completely inside those bounds. Coverage before/after, a single
swapchain, positive finite intervals, complete labels/conditions, source/engine/
seed hashes, camera and simulation checkpoints are validated. FPS is 1000 divided
by mean `MsBetweenPresents`; it is not monitor refresh. Frame-time p99 describes
the upper tail of application presentation intervals, not measured CPU/GPU cost.
RenderOverlay callback intervals cover the full 700 tics and remain separate.
Native bench is only a snapshot.

## Variants

| Mode | Change from baseline |
| --- | --- |
| 0 | Original calculations plus common diagnostic hooks/counters |
| 1 | Cache health-derived and offensive statistics; local dependency guards and 100-tic phased refresh |
| 2 | Cache carried weight; native inventory ownership/use/stack/split notifications and local armor guards |
| 4 | Skip recovery calculations only while all four resource balances are full; active recovery still every tic |
| 7 | Modes 1+2+4 |
| 15 | Mode 7 plus grouped target refresh at 100 tics instead of 8; local target death invalidation |
| 23 | Mode 7 plus periodic NPC thermal refresh at 100 tics instead of 35; forced/local-change updates retained |
| 31 | Mode 7 plus both target and thermal timing changes |
| 39 | Mode 7 plus maximum adrenaline, using the original wound formulas |
| 103 | Mode 39 plus algebraically simplified maximum-adrenaline wound formulas |
| 127 | Mode 31 plus maximum adrenaline and simplified wound formulas |

The 1,601 workers occupy 100 phases of 16 or 17 bodies. Changed dependencies are
checked when consumed; this is not a blind delay of every field until 100 tics.
The initial worker allocation and cold-cache fills precede steady maintenance;
the ETW trim removes the first second without proving that every on-demand
cache is warm. The phase distribution does not establish a bounded cost for
adopting the feature or spawning an army.
Cached methods restore all assigned outputs, including Speed: merely returning
would compound the carbine's reload slowdown. Inventory mutations outside the
covered native paths, such as direct Amount/UnitWeight/InMagicBox writes, must
explicitly notify their owner before production adoption. The 100-tic fallback
does not establish same-tic correctness for an unnotified write.

Saturated-resource skipping does not bank elapsed recovery time. Spending a
resource immediately resumes original steps. Stun, combat and adrenaline timers
remain outside that skipped block. Maximum adrenaline does not remove thermal,
elemental, reload, immobilization, damage or actual resource effects. NPCs do
not run the player's hunger/thirst performance calculation; preserving player
critical states and their damage is verified separately.

Target selection already shared a query among groups of at most 100; the new
variant lengthens the shared deadline from 8 to 100 tics. Native attack visibility/
range checks remain. Death invalidation notifies subscribed groups, but finding
a newly available target can wait approximately 2.86 seconds instead of 0.23.
That changes combat response and is not an equivalent cache optimization.

## Correctness evidence

The final native fixture passes 1,068 assertions. Coverage includes derived
statistics and their mutated dependencies, reload Speed restoration, effective armor type, break/repair, tier/size, finite potion use/last unit/stack/split/transfer,
explicit inventory mutation notification, 150 resource-step comparisons,
maximum-adrenaline wound simplification across 100 health levels, player
critical hunger/thirst states, consumption and damage, combat-timer advancement, shared-target
reuse/death invalidation, and all 100 phase/deadline bounds.

Separate 700-tic audits of modes 7, 103, 127 compare cached derived reads against
the uncached calculation for that selected variant on every hit. All three
finish with zero mismatches. In mode 7 that is the original formula; modes 103/127
use the simplified formula. Its separate comparison against the original
maximum-adrenaline formula covers the 100 health cases in the native fixture.
Audit cost is excluded from the 72 performance windows. These checks plus
aggregate checkpoint comparisons are not a proof of every individual field,
all mutation paths, save/hub migration, or the entire siege.

Twenty-four paired thermal controls call the existing Integrate solver with
35-/100-tic intervals over equal elapsed time, including changes of shelter,
wind, immersion and a fire source. They demonstrate numerical non-equivalence:
maximum final exposure error 0.105778204760, maximum intermediate cached-exposure
gap 7.221963914582, integrated-dose difference 0.349911587618, clothing-water
difference 0.000287987824 kg, and hydration difference 0.000096906387.
No acceptable gameplay tolerance is assumed. `first35/first100` means first
severe state observed after integration; the input can already be severe at
tic 0, so these values do not measure a new threshold crossing. The numerical
control flushes the previous environment before an event. Actual NPCStep
samples the new environment after sector/water changes; these errors are not
a bound on the complete 100-tic runtime's error.

## Performance results

All 72 matched windows completed: 50,400 measured simulation tics and 56,144
selected ETW intervals, 665-960 per window. Simulation throughput is
34.87293-35.03358 tics/s; the largest host-marker observation mismatch is
43.4331 ms. Tables report the median of per-run application-present means and
per-run p99 values. Brackets are observed repeat ranges, not confidence bounds.
The baseline has six runs per camera; each variant has three.

| Variant | City FPS | Front FPS | City p99 ms | Front p99 ms |
| --- | ---: | ---: | ---: | ---: |
| 0: baseline | 43.52 [43.28-43.88] | 37.55 [37.15-37.77] | 67.48 [65.22-72.68] | 112.64 [104.76-115.34] |
| 1: statistics | 44.27 [43.76-44.48] | 38.30 [38.15-38.39] | 65.39 [62.96-65.55] | 111.23 [109.94-112.06] |
| 2: inventory | 43.68 [43.30-44.29] | 37.49 [37.10-37.85] | 71.26 [57.65-71.35] | 107.85 [103.36-122.94] |
| 4: saturated resources | 43.85 [43.34-44.09] | 37.68 [37.50-38.15] | 65.99 [63.71-73.49] | 106.84 [105.76-113.83] |
| 7: stats+inventory+resources | 44.70 [43.95-45.25] | 38.93 [38.26-38.95] | 61.64 [58.39-73.29] | 105.21 [102.79-113.58] |
| 15: 7+targets100 | 51.26 [50.54-51.26] | 46.50 [45.64-46.56] | 60.18 [59.06-63.34] | 34.82 [34.45-36.84] |
| 23: 7+thermal100 | 45.94 [45.68-46.97] | 39.61 [39.41-40.10] | 56.07 [52.71-71.18] | 104.97 [104.26-106.81] |
| 31: all | 52.75 [52.18-52.78] | 47.69 [46.79-47.70] | 50.93 [48.81-57.84] | 33.72 [31.10-36.42] |
| 39: 7+maximum adrenaline, original formulas | 45.05 [44.61-45.43] | 39.06 [38.97-39.87] | 56.38 [46.56-57.91] | 76.49 [75.83-81.34] |
| 103: 39+simplified wound formulas | 45.02 [44.85-45.12] | 39.63 [39.33-40.30] | 50.85 [48.74-57.45] | 75.76 [74.72-76.70] |
| 127: all+maximum adrenaline+simplification | 52.80 [52.49-53.45] | 45.52 [45.20-45.85] | 44.00 [41.77-48.84] | 91.93 [84.73-92.16] |

| Complete calculations / city window | Baseline | Mode 7 | Reduction |
| --- | ---: | ---: | ---: |
| Health-derived statistics | 1,121,326 | 12,965 | 98.84% |
| Offensive statistics | 1,121,224 | 12,892 | 98.85% |
| Carried-weight traversal | 295,569 | 12,646 | 95.72% |
| Resource recovery block | 1,120,700 | 96,285 | 91.41% |

| Variant vs bracketing baseline | City FPS change % | Front FPS change % |
| --- | ---: | ---: |
| 1: statistics | 1.80 [0.52-1.82] | 1.74 [1.64-2.86] |
| 2: inventory | 0.34 [-0.41-1.35] | -0.50 [-1.07-1.42] |
| 4: saturated resources | 0.35 [-0.45-1.41] | 0.48 [0.48-1.25] |
| 7: stats+inventory+resources | 2.81 [0.57-3.93] | 3.35 [2.49-3.81] |
| 15: 7+targets100 | 17.30 [16.25-17.74] | 24.00 [21.12-24.75] |
| 23: 7+thermal100 | 5.68 [4.53-7.89] | 5.58 [5.11-6.94] |
| 31: all | 20.71 [19.87-21.39] | 26.58 [24.78-27.78] |
| 39: 7+maximum adrenaline, original formulas | 3.47 [2.08-4.50] | 4.41 [3.66-6.33] |
| 103: 39+simplified wound formulas | 3.41 [2.63-3.78] | 5.18 [4.89-7.97] |
| 127: all+maximum adrenaline+simplification | 21.27 [20.73-22.31] | 21.38 [19.95-22.84] |

Modes 1, 2, 4 and 7 preserve the recorded aggregate state at every checkpoint
against the matched baseline. Mode103 also matches mode 39 at every checkpoint.
These are 36 nontrivial comparisons, all passing, plus six baseline self-reference
rows. Aggregate equality is narrower than individual actor-state equality.

The combined conservative group 7 saves 2.81% city / 3.35% front in paired FPS
relative to its bracketing controls. Full calculations drop by 91-99%, but
dependency guards, other actor updates and rendering remain. Inventory-only
and saturated-resource-only repeat ranges overlap their controls and do not
establish a consistent independent FPS benefit. Inventory caching only covers
carried-weight traversal; it does not eliminate all inventory/potion work.

Target100 reduces city queries from 1,009 to 181 and front queries from 1,019
to 182 per window, about 82%. This gives the largest measured gain, but response
can wait 2.86 seconds and battle outcomes change. Baseline/group 7 ends with
600 soldiers/968 Mandingas in the city and 600/971 at the front; modes 15/31
end with 598/963 and 600/973 respectively. Each result repeats from its own
matched initial state. This is not a pure computation-cost comparison.

Thermal100 adds modest FPS but changes numerical results. For example, final
city aggregate exposure is -3018.492469716 in mode 23 versus -2954.034540227 in
mode 7, while their HP/anima/air/population aggregates match over this short
window. Exposure is an internal gameplay quantity, not degrees Celsius. The
separate solver controls above also reject numerical equivalence; this trial
does not recommend adopting thermal100 as an equivalent optimization.

Maximum adrenaline and the wound simplification preserve needs consumption
and damage in their controls. Comparing 39 to 103 isolates the simplification:
paired FPS changes are [-0.0512%, -0.6858%, +0.5346%] city and
[+3.4022%, +1.4670%, -1.3587%] front. There is no consistent extra FPS gain.
The combined mode 127 is not universally best: front mean 45.52 FPS/p99 91.93ms
versus mode 31's 47.69 FPS/33.72ms. Their combat also differs, so this evidence
does not attribute that regression to one calculation. No tested combination
reaches 60 FPS in both views.

The evidence supports completing production-safe statistics/weight/resource
invalidation first, with a modest performance expectation. Target cadence
needs a deliberate response-time tradeoff; thermal timing needs further
numerical work. Approved siege focus still needs participant/lifetime and
save/hub implementation. No cache, approximate thermal step or siege focus
is silently enabled in the normal package by this diagnostic delivery.

## Delivery checks

The final private generator reproduces both PK3s byte for byte in a second
directory. The normal build contains 16,376 exact source members, no staggered
probe, and passes native MAP03 compilation/loading. Normal source changes are
only two informational release labels. Project validation, document-index
freshness and Python compilation are delivery gates recorded in
`delivery_checks.json`; they do not substitute for author acceptance.
The textual archive retains logs, configurations, manifests, host timing,
per-frame ETW rows plus coverage context, analyses and power/collector state.
`WithinWindow=1` identifies selected complete ETW intervals. It excludes
engine/IWAD, private saves and generated game packages.

## Excluded attempts and limits

Early drafts are preserved locally: native override defaults/duplicate methods,
a protected TryPickup call, and a fixture that tested actors before deferred
PostBeginPlay were corrected before final measurement. A final02 attempt used
nonexistent MAP99, fell back to MAP01 and aborted; it is excluded. The valid
final04 checks01 explicitly uses MAP03. Review also exposed a no-op durability
test on base clothing; the final fixture equips real armor with positive
defense/durability before checking all four types/slots, broken/repaired states
and cached values. A console-wait matrix was stopped after 21 recorded windows
(and one final engine completed after its runner stopped): starts 3686..3688
were not identical. All 22 engine windows are excluded. The final runtime
starts inside WorldTick 3750 and rejects unarmed/late starts; the matrix runner
compares initial checkpoints immediately, not only at final analysis. Final01's extra player early return
would have stopped the combat timer; review caught it and final02 preserves
that timer, with an added assertion. No failed draft contributes FPS results.

The whole evolving battle can diverge under target/thermal timing and maximum
adrenaline. Their FPS differences combine computational savings and changed
combat workload. Only 39 versus 103 isolates the additional formula simplification at
the same maximum-adrenaline rule. Changes must not be summed as independent
production savings. No stable 60-FPS guarantee follows from a mean above 60.

## Reproduction

Use this delivery's validation_5442 tools and their existing validation_5441/
earlier helper imports over a checkout or copy of `src` from the pinned
ae8408f5 baseline for the exact hashes above. The builder reads the current
`src`; this delivery's two normal release-label updates change that hash if
used directly. Merely checking out ae8408f5 does not provide the new tools.
Use a local GZDoom 4.14.2 and legally available development IWAD.
Engine binaries, IWADs, private saves
and generated PK3s are not distributed. Use fresh directory/label names; do not
overwrite evidence. PresentMon capture must already be running with QPC-time
output and cover all engine PIDs. Run commands sequentially:

```powershell
python assets/validation_5442/prepare.py --directory issue318-stagger-final04 --extended-checks
powershell -NoProfile -ExecutionPolicy Bypass -File assets/validation_5422/run_native.ps1 -Directory issue318-stagger-final04 -Label checks01 -Script checks.cfg -Map MAP03
powershell -NoProfile -ExecutionPolicy Bypass -File assets/validation_5422/run_native.ps1 -Directory issue318-stagger-final04 -Label seed01 -Script seed.cfg -Map MAP03
python assets/validation_5442/run_matrix.py --directory issue318-stagger-final04 --prefix audit --modes 7,103,127 --sites 0 --rounds 1 --audit
python assets/validation_5442/run_matrix.py --directory issue318-stagger-final04
python assets/validation_5442/report.py --directory issue318-stagger-final04 --collector build/issue318-stagger-session01/presentmon.csv
```

Close the collector through its stop marker before analysis so the CSV is
flushed. The temporary thread-scoped sleep request does not alter the power
plan and must be released after testing. Existing CA318-01..05/CA327-01 author
checks remain outstanding; this diagnostic does not confirm them.
