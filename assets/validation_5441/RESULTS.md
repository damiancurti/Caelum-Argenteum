# 5.4.41 / #318 - Individual siege workload controls

This supplement answers the author's request to enable each of nine measured
update families separately, against a control with all nine disabled. It does
not remove any production gameplay system. The original 6,000-simultaneous
scenario is retired and is not used.

## Method

The diagnostic starts the normal MAP03 siege, including its gradual deployment,
and records 35 tics of actual method calls after 3,600 warmup tics. It saves the
scene with 600 living defenders and 998 living Mandingas, including their real
inventories, commander, machinery, projectiles and other actors: 8,910 actors
in total. Every measured run loads that same private diagnostic save.

Each run replays the captured call/argument cadence for 350 tics. The renderer,
map, inventories and actor identities remain present. The central camera is
(0,320,41), yaw 180; the frontline camera is (-14464,-14000,41), yaw 270. Both have
pitch 0. The selected family is dispatched directly so disabling its caller
does not accidentally reduce its measured workload to zero. The eight other
named families are gated. The all-off control traverses the same call trace
and performs the same temporary thermal/status copying without dispatching
any selected method.

GZDoom 4.14.2, Windows 11, Ryzen 9 5950X/RTX 3070 Ti, Vulkan 1280x720, seed 282,
uncapped/vsync-off, one unpaused engine, background rendering, 5% audio. Three
repeats per camera reverse the active-family order in the middle repeat. Each
pass starts and ends with all-off: 66 runs, including 12 controls and 54 selected
variants. No package builds or second engine run during measured windows.

`MSTimeF()` surrounds the replay batch once per tic; scene restoration is
timed separately. This is elapsed wall-clock time of synchronous work, including
possible scheduling delays, not measured thread/process CPU time. Additional
invariants run outside that batch. The reported
delta subtracts the mean of the two controls bracketing that camera/repeat.
It includes the selected instrumentation gates/counters and any interactions
with the common harness; it is not an overhead-free production function time.

Native `bench` writes a single FPS/renderer snapshot during each measured
window. These are neither mean presented FPS nor frame-time percentiles.
PresentMon's non-elevated preflight failed with exit 6/access denied; Windows
reported cancellation of the authorized UAC launch. No ETW frame-presentation
series is available for this matrix.

## Results

All 66 windows passed: 23,100 sampled tics, identical captured calls and
start tic 3774, all 8,910 actors retained, no unexpected spawns, native poison,
external pose/reference changes or health losses. The selected family alone
executed ten times its captured 35-tic call count in every active variant.

Each delta is elapsed milliseconds per **simulation tic**, not per rendered frame.
GZDoom targets 35 tics/s. Brackets show the range of the three repeat deltas;
they are not statistical confidence intervals. FPS columns are median native
snapshots and their range (three per active variant, six per control).

| Family enabled | Extra elapsed ms/tic, city | Extra elapsed ms/tic, front | Native FPS snapshot, city | Native FPS snapshot, front |
| --- | ---: | ---: | ---: | ---: |
| All nine off | 0 (reference) | 0 (reference) | 180 [176-186] | 149 [138-151] |
| Residual combatant Tick | 2.986 [2.946-3.051] | 2.942 [2.846-3.034] | 108 [108-113] | 96 [96-98] |
| Attacker target selection | 3.150 [3.032-3.268] | 3.146 [3.081-3.184] | 129 [127-131] | 116 [98-117] |
| Thermal integration | 0.914 [0.888-0.945] | 0.903 [0.869-0.923] | 149 [148-152] | 122 [117-129] |
| Breath management | 1.234 [1.224-1.251] | 1.259 [1.211-1.301] | 142 [142-146] | 123 [123-124] |
| Breath mouth position | 0.809 [0.787-0.837] | 0.708 [0.685-0.726] | 151 [144-161] | 135 [131-137] |
| Elemental status | 0.743 [0.722-0.783] | 0.786 [0.736-0.846] | 156 [150-160] | 130 [122-132] |
| Health-derived statistics | 1.383 [1.360-1.400] | 1.392 [1.345-1.424] | 136 [136-140] | 115 [113-121] |
| Offensive statistics | 1.080 [1.062-1.107] | 1.081 [1.076-1.088] | 146 [143-150] | 122 [122-126] |
| WalkTo / navigation | 0.897 [0.890-0.907] | 0.945 [0.926-0.955] | 144 [143-152] | 124 [115-124] |

The all-off replay batch itself averages 0.897ms/tic city and 0.781ms/tic front. This common diagnostic work is subtracted above; it is not a production subsystem.

| Family | Captured calls / 35 tics | Restore ms/tic, city | Restore ms/tic, front |
| --- | ---: | ---: | ---: |
| All nine off | 0 dispatched | 0.568 | 0.585 |
| Residual combatant Tick | 56,035 | 0.592 | 0.684 |
| Attacker target selection | 12,379 | 0.669 | 0.684 |
| Thermal integration | 1,635 | 0.626 | 0.616 |
| Breath management | 56,035 | 0.611 | 0.594 |
| Breath mouth position | 34,988 | 0.613 | 0.606 |
| Elemental status | 56,035 | 0.616 | 0.637 |
| Health-derived statistics | 56,069 | 0.698 | 0.681 |
| Offensive statistics | 56,065 | 0.622 | 0.645 |
| WalkTo / navigation | 5,244 | 0.790 | 0.794 |

Restoration and invariants are outside the replay-batch timer but consume
real frame time, and restoring movement can cost more than restoring an
unchanged scene. Thus the FPS snapshots describe the whole diagnostic;
their difference must not be attributed entirely to the selected core.

Residual combatant updates and target selection dominate these isolated
controls. This prioritizes investigation of those paths; it does not
establish that their rules or any inventory item are dispensable.

Simulation interval rates across the windows range from 35.000 to 35.074 tics/s.

## Isolation boundaries

- The general row calls the base combatant Tick directly, bypassing subclass
  ticks, with regular state advancement suppressed by `tics=-1`. Named child families, potion updates,
  thermal motion/runtime and the siege Pulse are gated. Native movement remains,
  while Caelum collision-energy response, contact aging and world-impact damage
  are neutralized. This is the residual core under those exclusions.
- Targeting retains real spatial/visibility queries and the existing target
  caches. The 35-tic replay preserves the call cadence and start phase; saved
  absolute deadlines and navigation caches are not rolled back each tic. It is
  a fixed-scene query workload, not a frame-exact replay of the original battle.
- Thermal integration uses disposable copies of the frozen save's thermal
  states with the captured scalar arguments, not historical states per call.
  Transient coefficients are warmed before every measurement, including controls.
- Breath management retains its numerical/eligibility work but cannot create
  or destroy breath actors; paid attack effects are gated. Mouth queries run
  separately and supply a cached point when disabled.
- Elemental status runs on disposable copies; damage and visual emitters are
  gated. Health/offensive-statistics calculations retain their production bodies.
- WalkTo retains native collision/navigation work, then the shared restoration
  restores poses and target references. Navigation bookkeeping may evolve.
- The engine's Powerup Tick can expire regeneration items while the level is
  frozen. The diagnostic explicitly gates that hierarchy and DoEffect.

The harness restores position, velocity, orientation, animation state/tics,
health, targets, combat resource levels and selected residual timers/latches.
It verifies unchanged captured poses/references at the next WorldTick **before**
restoration, including the final check; it rejects unexpected spawns, losses,
native poison, health loss and missing actors. Counters prove that each selected
family executes its recorded call count and the other eight execute zero times.
This is not a complete snapshot/rollback of every private gameplay field.

Consequently these isolated deltas cannot be added to predict normal-battle FPS
or interpreted as the gain from removing a system in production. Full combat
contains state actions, attack effects, impacts and interactions deliberately
excluded here. The renderer/engine and common diagnostic work remain in all-off.
The existing #318/#327 author checks remain pending.

## Reproduction and evidence

The measured source is commit `8eb04042460ed200de62a5b0ad28cd76c01b5f21`
(5.4.40). For byte-identical reproduction, use that commit's `src` and the
validation_5441 tools from this delivery; those tools do not exist at the older
commit. Running the builder directly on 5.4.41 changes the package hash because
two informational diagnostic release labels changed. Gameplay source is
otherwise unchanged. From the chosen repository root:

```powershell
python assets/validation_5441/prepare.py --directory issue318-isolation-repro01
powershell -NoProfile -ExecutionPolicy Bypass -File assets/validation_5422/run_native.ps1 -Directory issue318-isolation-repro01 -Label seed01 -Script seed.cfg -Map MAP03
python assets/validation_5441/run_matrix.py --directory issue318-isolation-repro01
python assets/validation_5441/report.py issue318-isolation-repro01
```

The report rejects an incomplete matrix, changed package/seed/engine provenance,
different populations/call counts/start tics, failed guards or an FPS snapshot
outside the active workload. The archive retains raw compressed logs, scripts,
run arguments, benchmarks, source/package hashes and calculated results. Runtime
packages, the private seed save, engine and IWAD are not distributed.

Exploratory build01..08 remain local and are excluded from the final statistics.
They exposed two compilation mistakes, missing/overwritten start controls,
transient thermal-cache warming, a misplaced initial bench, inherited powerup
expiry and inadequate final invariants. Failed or incomplete controls are not
silently accepted as measurements. The final artifact records their disposition.

## Delivery validation

Project validation, document-index freshness and normal packaging pass.
All 16,376 production members match src byte for byte; the isolated harness is
absent. A separate native MAP03 compilation/loading smoke passes on the normal
5.4.41 package. Its first helper fixture had an invalid semicolon after the
version directive; the corrected fixture passes without changing production.
Independent review checked the harness, sample raw guards, final tables and
archival provenance. These checks do not replace outstanding author acceptance.

The temporary keep-awake request was released at 2026-10-18 16:51:49 UTC after
the final native test, with the original power plan unchanged. The record is
preserved in evidence/power-request.json. No elevated PresentMon collector was
left running by this task.
