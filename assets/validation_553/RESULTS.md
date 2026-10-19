# V5.5.3 / #312 — sustained pressure and native crushing

**Technical gate: PASS — 20 required native runs, 306 completed-phase checks;
45 runs preserved, including excluded failures and superseded previews.**
Author check CA312-01 is separate and pending. The visual smoke contributes zero
numeric checks; later PASS lines after a completed phase are not counted again.
Project validation and normal build_dev.ps1 packaging pass. Read-only peer review
found no production blockers; evidence guards were strengthened from its findings.
GZDoom 4.14.2 / Windows 11; implementation base 4b7cbfcd (accepted #311).
Frozen package hashes identify the tested working tree, not that baseline commit.

| Required coverage | Completed checks |
| --- | ---: |
| Endpoint removal, support, interruption, lethal release and resident parking | 35 |
| Native moving pressure, partial/full intervals, changing loads and rest | 19 |
| Accepted regional defenses and actual motion controls | 47 + 15 |
| Two native hub roundtrips | 13 |
| Body-pressure old checkpoint, current save/load, upgrade and two rollbacks | 2 + 2 + 13 + 13 + 6 + 6 |
| Native four-panel crusher | 23 |
| Paused ceiling, source changes and actor-driven same-tic restart | 56 |
| Ceiling old checkpoint, current save/load, upgrade and two rollbacks | 4 + 4 + 12 + 12 + 12 + 12 |
| Visible preview, screenshots inspected locally | 0 |

The final normal PK3 has 16,380 members and SHA-256
`4693f37eb27a0d3bd7502f8c6bb4f379ac697243dbd69e3d606b9040d329a5de`.
Ten unaffected final01 runs are reused from
`72d087e42ccbc578c5243f21fba5a2561b7cefe8c2c4a35299033e1619cedc41`:
only CaelumCrushingDamage/CaelumCeilingPressure differ, verified member-by-member.
All final ceiling runs and the preview use the final normal package. Genuine old
checkpoints/rollback use accepted 5.5.2 runtime
`47d92bb8a03cc46aa7b57cec18a5694b290f89c0bc4ea37558aab092ca1a603b`.

The audit reproduced three integration defects without changing authored energy,
capacity, creep, armor/cushioning, Toughness, geometry or cadence:

- Destroying one contact endpoint discarded the survivor's pending work because
  the closing latch required a non-null peer. Saved geometry is now consumed once
  before delivery; missing/dead recipients are skipped.
- Non-solid/noclip/dead bodies and parked residents retained unfinished static
  load intervals. Living release closes the interval with existing defenses;
  death and legacy percentage carry are discarded before revival. Prediction
  remains excluded, and closure state clears before damage, including lethal work.
- Native crusher pulse spacing included paused tics. Local inventory sampling
  records downward attempted movement; the actual callback reconciles the current
  tic after possible actor-driven reactivation. Changing source invalidates
  continuity even after a quick return; the same trap's panels remain one source.

Native controls reproduced 23,040 J of partial motion work and one survivor pulse,
44,800 J per 35-sample interval, and 392.357396571 J of released static work yielding
312 HP after one 80-HP Toughness subtraction. The 507,600-kg four-panel crusher
retains its original force and same-tic deduplication.

A separate native tagged ceiling, stopped for two tics, formerly charged 1 m
instead of 0.5 m. The extended test also leaves for another ceiling and returns,
and restarts the original ceiling from Actor.Tick after Inventory.Tick. Those
controls exposed source mixing and a stale zero current-tic sample in the first
candidate; the final sampler addresses both. Raw exploratory failures are retained.

SamplingRevision=1 adds FirstSampleTick, LastSampleTick, PendingCompressionMeters,
LastSampleMeters and SourceInterrupted. Current saves preserve unfinished samples.
Old saves have no record of past pauses; only their unrecorded pre-sampling tics
use the previous approximation in the first interval. Repeated initialization is
inert. Original saves/runtime remain intact for rollback; no conversion overwrites
an input. No global actor scan is added by the sampler: source checking uses the
current native ceiling and the existing trap's bounded panel list.

Two native hub roundtrips passed without a new travel hook, so the experimental
PreTravelled change was not retained. The first player-removal fixture incorrectly
expected HP loss despite full biological cushioning; its raw-work assertions
remained valid and the corrected oracle preserves that defense. Another excluded
fixture used unsupported named action methods; the final test invokes native
action specials 42/44 via A_CallSpecial, verified against GZDoom 4.14.2 source.
Two excluded old-save attempts exposed fixture requirements: preserve both the
original QA map sector tag and the original ceilingsave.pk3 basename. final04
does so; its upgrade, original rollback and converted rollback all pass. Failed
dependent loads are retained, never counted as evidence of compatibility.

The #194 energy/armor/motion and four-panel pressure fixtures are reused without
balance changes. Their historical MAP08 diagnostic label remains in the source;
the actual launch uses the current THAZARD map. The frozen static-load fixtures
isolate support accounting; the reused native pressure case and new native motion
case separately exercise real engine movement and the production updater.

Run prepare.py into a fresh directory with --runtime build/caelum_argenteum_dev.pk3,
then run_suite.ps1 through PowerShell with process-local ExecutionPolicy Bypass.
Seed original-ongoing.zds from issue312-save-old and original.pk3 from the accepted
5.5.2 runtime for the body upgrade/rollback cases. For old ceiling saves, prepare
a separate directory with --legacy-ceiling, copy the unchanged old checkpoint as
original-ceiling.zds and the accepted old runtime as original.pk3, then invoke
run_suite.ps1 -LegacyCeilingOnly. Never overwrite a frozen fixture or input save.
The suite reuses validation_552/run_native.ps1:
one engine, unpaused in the background, 5% audio, immutable inputs and fresh labels.
CeilingOnly repeats only the subsystem changed by the final sampler refinement.
collect.py verifies the exact completed case set, final phase counts, both hub
returns, pinned runtime hashes, executed CFG and fixture hashes, actual serialized
pressure state and unchanged original saves. Raw logs, manifests and records are
retained in evidence/; evidence.json gives the full preserved run list.

The preview uses production motion and pressure with extreme diagnostic masses.
The first visual attempt captured before setup; the final script limits its own
test instance to 60 FPS and waits for setup before issuing actions. Its cumulative
actual-damage counters expose pressure without normal idle healing hiding the
loss on these unusually large-health targets. Normal healing is preserved.
The initial crusher body does not press the plate until F6, allowing the author
to watch the first descent. Earlier visual captures remain excluded evidence.
F6 lowers the crusher, F7 places a weight, F8 removes it, and F10 resets the room.
Save/load retains these counters and ongoing pressure. The visible smoke checks
presentation; precision and persistence are covered separately by native fixtures.
It does not establish campaign FPS or balance. Campaign FPS remains postponed.
No development IWAD, executable, fixture PK3, screenshot or save is distributed.
