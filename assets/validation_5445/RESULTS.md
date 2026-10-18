# Navigation-only demon breath regression — #357 / 5.4.45

The author's private MAP03 autosave reproduces the reported artillery behavior.
Its SHA-256 is `20d00394f1da5039aeb2bc982e6f10a9197435e2dacd83fbdfda40faf62c9a84`.
The save was copied, never edited. Neither it nor any game dependency is shipped.

| Native replay, same 175-tic interval | 5.4.44 control | Corrected |
| --- | ---: | ---: |
| Initial navigation-only breath emitters | 20 | 20 |
| Navigation-only emitters at the next 35-tic sample | 20 | 0 |
| Original affected bodies moving by the end | 0/20 | 20/20 |
| Original affected bodies released from breath | 0/20 | 20/20 |
| Final breath against other targets | 0 | 4 |

Every initially affected body was an artillery operator targeting its own
CaelumSewerEscapeTarget, with neither cold nor bolas justifying fire. Some had
already paid over a minute of continuous breath. The source loop accepts the
shootable waypoint as an enemy and prevents the next route action. Excluding
that class in CanReach fixes both combat activation and noncombat aiming,
without changing native navigation flags or introducing an actor scan.

GZDoom 4.14.2 isolated checks pass **41 assertions** for Mandinga and Zupay:
real nearby targets, unchanged paid Anima cost, no fire with empty Anima or an
out-of-range target, no resource spending on a waypoint, active-emitter retirement,
cold fire, and real bolas attachment/fire/release. The candidate save observer
fails if navigation-only fire persists after its initial sample. Baseline
observer completion means the observation ran, not that the defect is absent.

Final evidence: `issue357-checks06`, `issue357-observe-baseline03`, and
`issue357-observe-candidate02`. Earlier `observe-baseline01` also reproduces
the 20 stuck bodies. Draft checks01–04 failed the positive visibility control:
the inherited +/-32768 flat map makes native CheckSight false even with a
nearby ordinary victim. Bounded +/-16384 checks05 pass 31 assertions; checks06
adds ten real-restraint assertions. No exact engine-level cause is claimed.
Draft observe-baseline02 failed compilation (boolean constant and Vector3
dynamic array unsupported); it was stopped and replaced with numeric constants
and component arrays. The rejected candidate01 was never launched while that
engine was active. All these failures remain archived; none counts as a pass.

The successful runtime was built with the gameplay fix before the diagnostic
release labels were advanced. Final package/source equality and the exact
two-label-only difference are recorded in `delivery_checks.json`. No saved
schema changed; the old actual autosave loaded successfully. These are native
correctness results, **not an FPS benchmark**. Other battle state may diverge
as the freed operators resume their roles.

The author accepted the other current CA353-01 preview checks on 2026-10-18,
but reported this exception and the separate #334 house presentation issue.
The group-behavior retest remains pending. Older CA318/CA327 checks are untouched.

Reproduce with `prepare.py --directory <fresh-name> --runtime <pk3>` and
`--scenario checks`, or `--seed <private-save> --require-fixed` for the corrected
replay. Use `assets/validation_5422/run_native.ps1` sequentially, with
`-Runtime baseline.pk3 -Fixture city.pk3 -Script probe.cfg`, and `-LoadGame
author.zds -Map MAP03` for replays. The evidence archive contains text only.
