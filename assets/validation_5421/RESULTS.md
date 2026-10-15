# Issue #252 - Seal climate and channel presentation

Version: 5.4.21. Native target: GZDoom 4.14.2, Windows 11, Vulkan.
Base: `a3b305b6` (`integration/v54-accepted-251-238`).
Implementation branch: `feat/issue252-seal-climate-extensions`.

Original gameplay validation passed 233 assertions across 20 qualified native
runs. The author's visual feedback prompted the revision below, which passes
142 assertions across nine additional qualified native runs. CA252-01 remains
pending; no author acceptance, merge or closure is claimed.
Gameplay: `3a8bba88`. Separate presentation change: `26a00596`.
`prepare.py` freezes normal source bytes and deterministic isolated fixtures;
`run_native.ps1` runs one engine at a time, hidden, unpaused, with 5% sound.
Fixtures, IWADs, engines and generated saves stay local under `build/`.

## Revised presentation after author feedback

Implementation commit: `9ccab64b`.

The author reported that the drawing should be on the ground and that Water
showed a face, then requested a giant elemental orb like Arcane Sun. The author
confirmed that the orb is purely visual and floats above the head. This is a
continuation of #252 / 5.4.21, not acceptance of the original CA252-01 scene.

Water/Air aliases lacked native state registration. The revision appends those
states and tests nonnegative sprite indices before checking the selected image.
A downward native trace projects the horizontal mark onto the ground, native
3D floors or solid actor architecture even with an airborne caster. The orb
reuses Arcane Sun's scale and existing primary-element animations; texture size
places its bottom above the head. It has no mass, collision or attack behavior.
Both visuals are cleaned up on stop, interruption and map departure, and old
active saves recreate the added orb without changing climate ledgers.

Current evidence is `presentation_evidence.json`, recorded by
`python assets/validation_5421/record_presentation.py`. Final directory:
`build/issue252-visual-05`. All nine engine exit codes are zero:

| Revised run | Assertions |
| --- | ---: |
| presentation | 80 |
| roof | 5 |
| input | 13 |
| interruptions | 10 |
| save-02 | 2 |
| load | 8 |
| travel | 16 |
| old-load | 8 |
| gallery | 0; ten rendered captures inspected |

Runtime SHA-256: `f8b92313d140018cca3e41357c5a1c3dfb22273230bd72315e7eda5153a6b414`.
Fixture SHA-256: `97a3229b265ff6cdddc43d26408550d54923c30af7ee24aa742f3fc23f5078d0`.
Repeated preparation in `build/issue252-visual-repeat` matches. The frozen and
normal development packages match all 16,178 source members; static validation
and `build_dev.ps1` exit 0 (`issue252-visual-validation.json` / `issue252-visual-build.txt`).
Only presentation source and its additive reference changed; the original
climate/damage/force evidence below is reused for those unchanged consumers.
`record_evidence.py` and `evidence.json` describe the original tested source at
8f57a690; they are retained rather than relabeled as the revised package.

Rejected development observations remain qualified: `visual-01` found a ZScript
expression limitation requiring the returned texture size in a local vector;
`visual-03` lacked a completion marker and initially activated before equipment
was ready; `visual-04` deferred screenshots captured the next camera setting.
The final gallery waits for setup and for each capture before changing cameras.
The first `visual-05/save` wrote its save but exited before the completion event;
`save-02` waits for delivery and passes. These runs are excluded from the counts.

The revised author scene uses F to channel/stop, F6 for the next Seal, F7 for a
wide orb view, F8 for a close ground view, and J for Journal/Climate. Its wide
camera values are test-only; production chasecam settings are unchanged. CA252-01
remains the single pending author check, including the earlier climate steps.

Native probes cover the numerical accumulation sequences, weather/thermal
agreement and removal, native and actor-built walls/floors, armor bypass with
physical Toughness, SI continuous force, native input, gravity overlap/expiry and
flight, and all five ground-emblem/camera lifecycles. Active save/load, hub travel,
genuine 5.4.20 save migration and 500-body service checks also pass. The final
chasecam capture was visually inspected; this does not replace author review.

Early development failures are preserved rather than overwritten:
- `issue252-dev-01`: reserved ZScript identifier `state`; renamed before execution.
- `issue252-dev-02`: 75 formula checks passed, but the runner expected a differently
  ordered completion marker. Earth's zero-height endpoint reached the native floor;
  the trace now distinguishes an obstruction from contact at its destination.
  Input fixture had no equipped weapon; reused the accepted native equipment helper.
- `issue252-dev-03`: native LineTracer callbacks are data scope; the callback now
  classifies immutable actor types without calling gameplay methods.
- `issue252-dev-05`: an Actor/Player ternary required an explicit common Actor type.
- `issue252-legacy-01/seed-01`: orchestration started the engine before preparation
  finished. The log reported a missing `legacy.cfg` while packages were still being
  replaced. The author's CrashReport matches this command line, reports no active
  level and a native C0000005 read at address 0x8. ZIP SHA-256:
  `1aff7af8169cb8607ba82be4b61fbddcbfbac19aeb8980d95f179422792c2d2a`.
  The local ZIP is preserved with the failed run; it is not distributed. The runner
  now requires the final manifest, scripts and matching package hashes before
  launch, and treats missing-file output as failure. Fully prepared `seed-02` and
  the current runtime's `issue252-dev-08/upgrade-01` both completed successfully.
  This startup failure is not evidence of a crash during Seal gameplay.
- The first observational `weather` script released and pressed User2 in the same
  frame, so the channel did not stop. It is excluded from final evidence. The
  corrected `weather-02` run separates these edges by two tics and confirms removal.

Engine declarations verified from the installed 4.14.2 `gzdoom.pk3`:
`Actor.A_QuakeEx`, `QF_SHAKEONLY`, `LineTracer.Trace`/`TraceCallback`,
`TraceResults.Distance`, `PlayerInfo.cheats` and `CF_CHASECAM`.
Native quake damage/thrust are disabled; authored Earth damage and force remain
separate. The existing trap emblems and jewelry icons are owned runtime assets.

## Final evidence

`evidence.json` records each qualified run's engine/runtime/fixture/script/log
hashes, assertion count and exit code. All 20 exit codes are zero. The final
runtime is frozen in `build/issue252-release-5421`; an independent preparation in
`build/issue252-determinism-5421` produces identical package hashes.

- Runtime SHA-256: `b14534df2b01a00a94ea7061bc42517527fdc43b23020dd5d52eb8137f7aa727`.
- Fixture SHA-256: `297566955bfbec702c0b8337fe57c89efd9703aa425b87c3fa5492ff58fb413c`.
- The frozen and normal development packages match all 16,178 current source
  members byte for byte; generated test resources are outside `src/`.
- `python validate_project.py`: exit 0, empty errors, preserved in
  `build/issue252-release-validation.json`. `build_dev.ps1`: exit 0, preserved in
  `build/issue252-normal-build.txt`.

| Final run | Assertions | Coverage |
| --- | ---: | --- |
| formulas | 75 | Authored accumulation, overlap, baseline weather and thermal projection |
| earth | 23 | Mass, distance, SI force, grounded eligibility and geometry |
| environment | 12 | Ambient direction, multiple sources, shelter and expiry |
| defenses | 4 | Armor bypass with physical Toughness and final damage rules |
| gravity | 12 | Initial minimum, overlap, baseline restoration and flight |
| presentation | 37 | Five images, double trap scale and prior camera restoration |
| falling | 4 | Real simulation fall and one-second gravity expiry |
| input | 13 | Native User2, real equipment, pulse phase and stop |
| interruptions | 10 | Channel cleanup and existing resource/control boundaries |
| performance | 3 | Services with 500 living combatant bodies |
| save / gravity-save | 2 / 2 | Active channel and released gravity save seeds |
| roof | 3 | Native floor/ceiling separation on MAP97 |
| load / gravity-load | 7 / 5 | Saved phase, ownership and expiry |
| travel | 13 | Departure, destination and hub return cleanup |
| upgrade | 7 | Genuine old-save migration without retroactive accumulation |
| preview / weather-02 | 0 / 0 | Qualified visual and actual weather observations |
| legacy seed-02 | 1 | Accepted 5.4.20 runtime creates the preserved migration save |

The actual weather report samples local/regional temperature as
15.9572/15.7624 C before channeling, 17.6825/15.7890 C during the first Fire
increment, and 15.9825/15.7890 C after stopping. The ordinary calendar advances
between the first two samples; stopping removes exactly 1.7 C while regional
weather remains unchanged. There is no overwrite of heat already exchanged.

The isolated 500-body measurements are 1.054 ms for baseline weather samples,
1.722 ms for climate samples and 24.042 ms total for 35 continuous Earth-force
steps. Fixture combatant ticks are controlled for service measurement; these are
not full-battle frame-rate results or multiplayer acceptance.

The legacy save uses the accepted 5.4.20 runtime, SHA-256
`8e08de05120b4b3409f221835d9753a1d85430ffff3ce89df6276ef28fe9fc6f`.
Its original snapshot is preserved and a copy is upgraded. The old pulse phase
continues, the new ledger starts at zero and camera ownership is restored.
Downgrading new active classes into an unsupported older engine package is not
claimed; the preserved pre-upgrade snapshot remains the rollback source.

## Reproduce and author review

Wait for preparation to finish successfully before starting a native run. Use
fresh directory/label names to preserve existing evidence:

```powershell
python assets/validation_5421/prepare.py --directory issue252-recheck
powershell -NoProfile -ExecutionPolicy Bypass -File assets/validation_5421/run_native.ps1 -Directory issue252-recheck -Label formulas -Script formulas.cfg
```

Each table label has a matching generated script, except `weather-02` uses
`weather-fixed.cfg`. Use `-Map MAP97` for `roof.cfg`, `-LoadGame seal.zds` for
`load.cfg`, `-LoadGame gravity.zds` for `gravity-load.cfg`, and
`-LoadGame seal-repeat.zds` for `travel.cfg`. `prepare.py --legacy` freezes the
accepted runtime and old-save fixture. The evidence recorder verifies the named
final runs, static report, determinism and source parity without rerunning them.

CA252-01 uses `manual.cfg` with `-Interactive`: F toggles Channel, F6 stops it and
selects the next Seal without the fixture cooldown, and J opens Journal/Climate.
The scene supplies real equipment, fixed magical power x1.7 and protected targets
for observation. It is an author review fixture, not a production balance preset.
Root `pending_test.txt` holds the outstanding steps. No campaign-wide, network or
author acceptance is inferred from automated checks.
