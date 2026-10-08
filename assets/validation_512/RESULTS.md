# #132 / 5.1.2 native siege experiment

The opt-in controller is implemented. Population scheduling, rejected/partial
placement, terminal conditions and persistence pass native checks. Staging
substantially improves the arrival workload, but background routes and late
phases do not establish the reference of stable 35 simulation tics/s and at least
30 displayed FPS throughout the battle. This is a workload change, not a demonstrated improvement in
per-actor efficiency. A short foreground control does reach 53.11 displayed FPS
and 34.84 tics/s near 2,000 alive; it does not establish full-battle stability.
Author gameplay acceptance remains CA132-01.

## Observed result and contributors

The natural background arrival comparison is 21.00 tics/s and 1.23 displayed FPS
for the full army, versus 34.97 tics/s and 45.03 displayed FPS for staging
(100-962 alive). A complete background cap control with 1,953-2,000 alive gives
34.98 tics/s and 19.79 displayed FPS. Another staged arrival gives 22.43 displayed
FPS despite 56.58 RenderOverlay callbacks/s: background presentation and competing
desktop activity materially affect these measurements.

After the author reserved foreground time, `focus-full-a` and `focus-cap-a` use
the same camera/settings and production AI. Window activation is recorded in
`*-focus.json`; the comparison excludes startup/activation and uses tics 700-1050.
Full army: 32.58 tics/s, 1.94 displayed FPS, median/p95 interval 524.99/566.65 ms.
Cap: 34.84 tics/s, 53.11 displayed FPS, median/p95 interval 16.67/33.34 ms.
This ten-simulation-second control demonstrates a benefit near the cap, not a
full-route foreground certification. The full-army foreground tail has few frames.

Both complete-budget staged runs produce the same population endpoints: 6,000
successful Mandingas, zero reserves, at most 1,402 living during this particular
buildup, and 6,013 final corpses including defenders. Natural deaths prevent
normal buildup from reaching the cap. In the final captured run, late tics
20,650-22,750 give 29.18 tics/s and 2.20 displayed FPS with 790-1,293 living and
4,719-5,223 corpses; that interval includes the explicitly labelled late save.
Native callbacks are also only about 2.26/s there, so display occlusion alone
does not explain that stall. Final decline recovers to 35.16 tics/s over its
window but only 13.99 displayed FPS; short-window catch-up can exceed 35 slightly.
The first long run gives 31.96 whole-run tics/s, the final repeat 34.30: report
variation rather than selecting one run as a hardware guarantee.

Sampled diagnostic costs (inclusive ms/sample tic) reinforce the workload
attribution: CombatActor.Tick falls from 21.26 in the 6,000 control to 7.80 in
the 2,000 control; siege Pulse from 6.04 to 1.91; NPC thermal work remains inside
those totals. Thermal environment sampling alone falls from 2.43 to 0.87 ms.
These overlapping scopes must not be added. In the late saved scenario, actor
Tick returns to 19.61 ms despite many dead bodies; individual target lookup
averages 4.74 ms and cannon targeting 3.21 ms per sampled tic, with only four
cannon-target calls in 19 samples. This identifies burst work, not a uniform
3.21-ms cost every tick. Reinforcement census/placement is separately identified
in PROFILE_RESULTS.json; sparse sampling is not a spawn-spike benchmark.

`profile-deaths-a` instruments the actual MeansOfDeath argument without changing
damage: of 5,961 Mandinga deaths after loading the tic-3,500 baseline checkpoint,
5,946 are `CaelumThermal`, the other 15 are ordinary impact deaths. Representative
cold deaths have exposure about -14.7, air 21.4 C, comfort 32 C and 798 accumulated
thermal HP loss. This pre-existing accepted thermal behavior empties the baseline
before the diagnostic's first forced casualty. It is not a reinforcement benefit.
Retest after #135 self-warming rather than silently disabling physiology here.

## Reproduction and exact artifacts

Use GZDoom 4.14.2, Windows/Vulkan, 1280x720, 60-FPS ceiling, RNG seed 116 and skill
2. Each `*-run.json` records hardware/driver, engine/IWAD/package/addon hashes,
arguments, initial configuration, script and completion. Final INIs and native
logs accompany it. The fixture is the unchanged southern MAP06 layout: 600
defenders, one commander, 12 hostile machines and 42 guns. Audio is 5%; rendering,
sound and simulation continue in the background. `power-request.json` records
the thread-scoped keep-awake request and its release without a power-plan change.

The full-army comparison is commit
`72eba5fb6b4708c9b38fe3aba79ec95acb6df43e` (accepted #131 / merged PR #138), not the
pre-thermal #128 executable. Its PK3 SHA256 is
`880a668f609d839e488549d4dbaf15147835e9cbca7469ec3b850dcfe83fa334`.
The final production fixture is
`a62777eb114208341f505262c8954d829c17cab51d5a88f1cfe8eea5c52313a2`.
`MANIFEST.json` identifies observer/check addons. `PROFILE_MANIFEST.json` identifies
separate instrumented packages; those are never used for FPS conclusions.

Run `python -X utf8 assets/validation_512/prepare.py` in a fresh checkout/work
directory, then the explicit jobs in `run_persistence.ps1`, `run_check.ps1` and
`run_remaining.ps1`. `natural.cfg` and `long.cfg` define the short and complete
routes; `long-final.cfg` also saves a late checkpoint. Prepare the profiling
copies with `prepare_profile.py`. Runners reject overlapping engines and reused
labels. Do not replace packages while an engine uses them. IWADs, executables,
PK3s and saves stay local under build/issue132 and are not distributed.

For a playable production test, rebuild with build_dev.ps1, enter
`ca_test_siege_reinforcements true`, then `map MAP06`. Set it false before another
fresh map for the original army. Loading an existing encounter preserves its
saved choice. Existing full armies are never culled to enforce the new cap.

## Functional and persistence evidence

`final-boundaries.txt` passes 22 native assertions, repeated through
`final-pending-reload.txt`: first 100 includes all 74 operators; non-Mandinga
populations and the independent whole-map 500-combatant gate remain intact;
cadence is 350 tics; 1,901 alive waits and 1,900 admits a group; simultaneous
vacancies permit only one group; missed opportunities do not accumulate.

100 obstructed candidates consume neither the reinforcement budget nor native
total-monster count. Clearing half produces exactly 50 successful members;
save/load preserves the remaining bitmap, cursor and exact deadline. The rest
finish without duplicates. An empty field with 3,700 reserves is not victory;
confirmed commander retreat plus all machines neutralized stops spawning and
retains the unused budget. Native candidate rejection calls ClearCounters before
Destroy, matching the installed engine's blocked-monster pattern.

`SAVE_VERIFICATION.json` records 52 comparisons of actual native saves: pending
state, old-army actor/roster identities and 74 crew assignments, revision-1
disabled migration, original-package/original-save rollback, staged reload,
next scheduled group and hub return. New staged saves require the new schema;
rollback is explicitly the untouched original save with its original package.

Actual placement policy: try original crew stations, then the authored infantry
formation; infantry uses a saved rolling formation cursor. Native collision and
vertical fit plus combatant-body overlap checks run before registration. 28 crew
stations were initially occupied in these fixtures and used safe formation
fallback. Those operators walk to their assigned stations; there is no teleport
to a station, living-actor removal or added corpse cleanup. No further failed
candidate placements occurred in the complete-budget runs. This safe placement
also differs from the original forced deployment and is part of the comparison.

The first group is immediate. Samples run before the controller: the WorldTick
sample at 350 reports the preceding count, while 385 sees the group created at
350. A partial group retries before another can start. The saved map tic timer
does not follow the accelerated campaign calendar or advance while paused.

## Measurement interpretation

`PERFORMANCE.json` contains per-phase and per-camera simulation rates, displayed
frame-interval median/p95/p99/worst, population ranges, spawn windows and coverage.
Tables in `MEASUREMENTS.md` are generated from those values. Frame quantiles use
nearest rank; median uses the ordinary sample median. Mean displayed FPS is
1000 divided by mean display interval, not the mean of instantaneous reciprocals.
Native RenderOverlay intervals remain labelled callback-only.

Every 1,750 simulation tics the observer changes between the same four cameras:
two army/approach views, one frontal approach and one wall-occluded interior view.
The unknown-voice dialogue overlay is present in both variants; it does not pause
the simulation, but this is not a clean-HUD presentation test. Player/camera
observers are protected; ordinary NPC movement, collisions, attacks, resources,
thermal simulation and offscreen processing remain enabled. Desktop activity is
not exclusively controlled, and repeated starts vary. Single-run ratios are not
confidence intervals or portable hardware guarantees.

Natural short runs contain no programmed NPC deaths. `cap-natural-*` compresses
the first 20 scheduling opportunities at tic 3 to create the 2,000-alive control,
then restores normal cadence and combat. It does not establish the speed or
casualty history of normal buildup. Natural casualties prevented the ordinary
staged buildup from actually reaching 2,000 alive, so this control is necessary.

Long diagnostics enable ordinary commander invulnerability and force native
damage to 100 living Mandingas every 350 tics from 6,999 through 20,649, then 500
per opportunity from 22,749 through 24,499 for final decline. This fixture reaches
exactly 6,000 successful spawns; corpses remain. Existing thermal health loss
bypasses ordinary invulnerability, so this flag is not universal immortality.
Neither diagnostic reached legitimate terminal victory before completing the
budget. Scripted and natural casualties are separately counted. After populations
diverge, matching route/time does not mean matching living/corpse workloads.

Native bench/profilethinkers commands and screenshots have overhead. Raw tails
include it; do not attribute the worst raw frame to spawning. `spawn_windows`
excludes command/camera-transition opportunities and measures one second either
side of the other group opportunities. The late checkpoint save at tic 22,050 in
staged-long-b is explicitly an additional pause in that run. Native `bench` gives
CPU-side rendering timings/scene counts, not whole-scene GPU or displayed time.
`BENCHMARKS.json` records exact byte slices of the accumulated native benchmark,
bounded by the next run's starting offset. Native bench is deferred: the final
requested sample often does not finish before quit. Requested and completed
counts are separate; no following run's sample fills that gap. Synchronous native
profilethinkers output and screenshots still preserve the terminal observations.

## Capture provenance and limitations

Official PresentMon 2.6.0 x64 came from
https://github.com/GameTechDev/PresentMon/releases/download/v2.6.0/PresentMon-2.6.0-x64.exe
with SHA256 `b2a706bc6ad475749e3b7e3409263aa1e6906d45bdcf993f6dbc0f660188f1af`.
The first unelevated probe was rejected by Windows. The author explicitly chose
and launched the administrative helper. The corrected helper scopes capture to
each recorded owned GZDoom PID/start time, gracefully stops its trace when the
game exits, and exits on our stop signal. The restart warning refers to stopping
the previous trace and is not a failed new capture.

The original helper waited indefinitely for a Vulkan process-exit notification.
Consequently baseline-natural-a and staged-long-a have no presentation trace;
their native simulation evidence is valid but their callbacks are not displayed
FPS. staged-natural-a's trace was recovered intact. cap-natural-a covers only
about 70% of its measurement window. Later `*-b` controls and baseline-long-a use
the corrected handoff and full capture. Compressed `*-present.csv.gz` files retain
the CSV bytes; their uncompressed hashes are recorded in PERFORMANCE.json.

The pinned PresentMon implementation was checked at:

- https://github.com/GameTechDev/PresentMon/blob/v2.6.0/PresentMon/CsvOutput.cpp
- https://github.com/GameTechDev/PresentMon/blob/v2.6.0/IntelPresentMon/CommonUtilities/mc/MetricsCalculator.cpp
- https://github.com/GameTechDev/PresentMon/blob/v2.6.0/IntelPresentMon/CommonUtilities/mc/MetricsCalculatorCpuGpu.cpp
- https://github.com/GameTechDev/PresentMon/blob/v2.6.0/IntelPresentMon/CommonUtilities/mc/MetricsCalculatorDisplay.cpp

For this Vulkan/Other provider, MsInPresentAPI is zero and current absolute
presentation time is CPUStartQPCTimeInMs + MsCPUBusy. The CSV's TimeInSeconds header
contains relative milliseconds under --qpc_time_ms. Adding MsUntilDisplayed gives
the displayed timestamp; MsBetweenDisplayChange measures the preceding display
interval. The analyzer verifies consistent clock origin and adjacent display
timestamps independently. QPC/UTC calibration joins the native clock, with a
reported uncertainty allowing 5 ms non-atomic clock-call jitter. NA display rows
are not silently treated as displayed frames. PresentMon GPU-busy samples are
attributed GPU activity, not a complete scene critical-path measurement; its
CPU-busy field includes waits outside Present and is not pure CPU computation.
One staged-long-b row has zero CPU/previous-present duration and an unusable
CPU-start origin; the analyzer calibrates origin from positive-duration rows and
uses the relative present timestamp for every row. Its display field is NA.

A read-only window inspection found the game occluded by another active window.
The author then reserved two minutes for the foreground controls; Computer Use
activated only the owned GZDoom window. No unrelated window/content is retained
in this evidence. Full-route foreground repetition remains future evidence.

Early staged-natural-a used the preceding fixture; final code adds native kill-
counter cleanup to rejected candidates and skips the disabled controller census.
The former affects rejected-spawn statistics; the latter affects only disabled
mode. staged-long-a differs from final production only in rejected-candidate
counter cleanup. Final 22-assertion/save checks, cap-natural-b and staged-long-b
use the final production bytes. Every historical run keeps its original hashes.

Development failures are not counted as passing tests: the first functional
cap check allowed incidental combat deaths, the first pending fixture used an
unsaved StaticEventHandler, immediate startup saves were rejected, and an old
save initially requested its original package filename. Each was corrected and
retested; logs under build/issue132 preserve the unsuccessful attempts. The final
runner rejects missing-save dependencies, unsaveable-state messages, script/VM
errors and failed assertions. Intermediate successful checks remain clearly
labelled with their earlier 20-assertion count.

## Scope and follow-up

No map geometry, defender placement, weapon behavior, difficulty, thermal rules
or individual collision/resource rules were changed. Geometry/defender work is
#133; its combined scenario cannot be measured before that implementation exists.
Demon self-warming and supplies are #135. Repeat the same population/camera
controls after those changes. Do not count earlier thermal deaths as a successful
optimization. The long-run diagnostic and author assessment are separate evidence
levels; only the author can accept CA132-01.
