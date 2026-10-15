# #260 / 5.4.15 — player acceleration and directional impulse

## Completed implementation; impulse author check pending

The same-patch impulse continuation implements the author's 2026-10-15 answers:
0.4 seconds between presses, current walk/run/crouch mode and full current
direction, including a held diagonal and activation while moving. Ground, water
and flight are eligible; ordinary jumps/falls are not. The complete running-rate
times mass-duration cost is paid once through the existing Air authority. Failure
spends nothing and leaves ordinary movement active. Native directional buttons
distinguish a released opposite key from another press; analog-only axes retain
native sign edges. Partial gestures are transient and are cleared by UI changes.

**143 assertions in ten native runs pass**, plus a zero-assertion save seed.
The current normal PK3 has **16,164 members**, all byte-identical to both src and
the frozen tested runtime. Project validation reports no errors. Runtime SHA-256:
`c42fffcff3d89dc38bd0b91a7ff1dcbfc574fe8253e4a21ef13ebcdf7b30e987`.
Exact runs, scripts, hashes, measurements and copied-save inputs are recorded in
`impulse_evidence.json`. Native evidence is separate from CA260-02, which remains
in pending_test.txt. CA260-01's prior acceptance is unchanged.

- `issue260-impulse-final/contract-final`: 88 assertions cover 50/100/200 kg,
  four directions, run/crouch, current diagonal while moving, simultaneous axes,
  single hold, repeated pairs, exact 14-tic and late 15-tic windows, zero/short/
  exact Air, menu/stun interruption, ordinary falling and native flight. Measured
  native velocity and actual displacement match the current cap. Controlled costs
  are 3/6/12 Air; ordinary running expenditure remains additional while running.
- `input-final`: five assertions reproduce/fix the held-forward/opposite-key case
  and exercise a real native jump on the second press without impulse payment.
- `water-final`: four assertions use real 3D underwater geometry.
- `edges-final`: twelve assertions cover the real Caelith effect and current Anima
  modifiers, synchronized gesture reset, guarded prediction and faster external
  momentum. The last two are direct service probes, not multiplayer evidence.
- `world-final`: six assertions cover current facing and native wall collision.
- `load-final`: ten assertions load the half-tap seed, retain ordinary progress,
  discard gesture fields and require a fresh pair for exactly one payment.
- `issue260-impulse-final-upgrade/upgrade-final` and `ordinary-final`: four copied
  pre-impulse save checks plus six actual ordinary-ramp/regression checks.
- `issue260-impulse-final-rollback/rollback-final` and
  `issue260-impulse-final-return/return-final`: three direct 5.4.14 rollback and
  five current-return assertions. Original saves and copies have equal hashes.

Reproduce with `prepare.py --directory <fresh-name> --impulse` and
`run_native.ps1 -Directory <name> -Label <fresh-label> -Script impulse-contract.cfg`.
Other scripts are impulse-input/water/edges/world/save/load.cfg; water uses
`-Map CA260W`, load uses `-LoadGame half-tap.zds`. Run one engine at a time.
For the author, `launch_impulse.ps1` opens the frozen final scenario; its overlay
reports successful impulses and debit while the fixture restores resources.
Physical bindings/UI interaction, broad campaign, performance and multiplayer
acceptance are not inferred from automated commands.

Preserved impulse iterations:

- `impulse02/contract02`: an oversized single console line skipped early cases;
  short explicitly chained scripts fixed the fixture (CA-KP-098).
- `impulse04/edges04`: a hardcoded 3-Anima assertion ignored live modifiers;
  the captured canonical per-command cost was 3.6 and passed. Corrected the
  extra assertion to retain the live modifiers; no gameplay-cost change.
- `impulse-input-baseline/input-baseline`: the draft sign-only detector produced
  one unintended payment when W stayed held while S was released. The final
  native-button detector passes the same reproduction without a payment.

## Previously accepted ordinary acceleration component

Windows 11, installed GZDoom 4.14.2, private development IWAD. Native tests use
unpaused background execution and 5% audio; no interactive window was launched
while the author was away. That initial component did not implement the impulse.
CA260-01 passed on 2026-10-15 for ordinary movement only;
acceptance.json records the author confirmation and interactive run.

Original component result: **90 qualified native assertions in eight runs**, plus seed and
visual-observation runs. Project validation reports zero errors; normal packaging
succeeds and all **16,163 members** equal the frozen final runtime. Runtime SHA-256:
`29f3e2082dced3d2a6feaddac444105a0e4499b1144123479176e66a82cb52a3`.

The runtime uses a linear fraction increment `100/(3*mass*TICRATE)` and compensates
only the native command's thrust for friction. It does not replace total velocity,
collision or NPC movement. For fixed target speed/mass/input, the native velocity
trace and actual position increments agree with the linear ramp. The first command
tic is startup; fractional durations clamp at the next tic. 100 kg forward walking
reaches 4 m/s on input tic 106 and stays there. 50/200 kg take 1.5/6 seconds plus
that input startup/quantization. Dynamic target/direction retains native response.

## Evidence and scope

- `build/issue260-native05/contract05`: eight 270-input-tic cases, walking/running,
  forward/lateral, 50/100/200 kg and native flight. Seven cases are reused. Its
  original 50+50 kg case used a synthetic carried-item field that the authoritative
  inventory refresh replaced; that case is excluded from accepted evidence.
- `build/issue260-native05/water05`: real 3D water sector, 270 input tics, full
  submersion, linear velocity/displacement and native stop/reset.
- `build/issue260-author/extended-final`: corrected 50 kg body + 50 kg diagnostic
  load; settled crouch; diagonal running. All three cases pass. Diagnostic load
  isolates the mass curve; it is not a claim about actual item transfer by itself.
- `build/issue260-author/interactions-final`: changing mass during motion halves
  the ramp increment; a sideways external impulse survives forward thrust;
  ordinary airborne movement falls and freezes progression; revision 1 is
  idempotent. Actual native equipment objects and persistent Box ownership verify
  equipped/personal/reduced Box weight counted once, moving content out, removal,
  and the ramp's use of the authoritative aggregate.
- `build/issue260-load-final/load-final`: copied mid-ramp save retains exact
  fraction, simulation seconds and next-tic compensation; native stopping resets it.
- `issue260-legacy-final` seeds a partial ramp on 5.4.14; `issue260-upgrade-final`
  verifies migration to 5.4.15. `issue260-rollback-final2` loads a new save directly
  on 5.4.14 and `issue260-return-final2` returns it to 5.4.15. All preserve the
  saved fraction/time; current saves also preserve compensation. Input-copy hashes
  prove that the original saves were retained unchanged.

The prepared author directory is `build/issue260-author-ready`. Its only later
fixture change displays actual per-tic displacement instead of a velocity sampled
after friction; a fresh native screenshot was inspected. Runtime is identical,
and this observation-only overlay is excluded from the 90 assertions. The
interactive launcher was used for accepted CA260-01 on 2026-10-15.

The native05 runtime differs from the final runtime only in the version strings
of two diagnostic messages. Every gameplay file is byte-identical. Final-runtime
interaction/extended/save tests compile and execute the final build. See
`evidence.json` for exact hashes, process arguments, pass lines and compatibility
results. No performance/benchmark or broad campaign acceptance is claimed.

## Reproduction

`python assets/validation_5415/prepare.py --directory <fresh-name>` freezes src,
the fixture and scripts. Run `run_native.ps1 -Directory <name> -Label <fresh-label>
-Script contract.cfg`, then `water.cfg -Map CA260W`, `extended.cfg` and
`interactions.cfg`, one engine at a time. The interaction run saves `ramp.zds`.
Prepare a separate directory with `--save <input>` and run `-LoadGame input.zds
-Script load.cfg`. Never overwrite a campaign save.

Compatibility uses `--runtime <5.4.14-pk3> --compatibility` and `legacy.cfg` for
an old seed, then separate copied-save directories for upgrade/rollback/return.
`compatibility.zs` references only pre-#260 gameplay fields. No migration actor or
state-list bridge is required; additive primitive fields deserialize natively.
Keep original input files unchanged and verify their hashes.

Normal delivery gates are `python build_document_index.py`,
`python validate_project.py`, and `powershell -NoProfile -ExecutionPolicy Bypass
-File build_dev.ps1`. Final gate results are recorded in evidence.json.

## Preserved diagnostic iterations

- native02: fixture compilation rejected `.XY` on a temporary expression; a named
  vector fixes the fixture. No runtime change was needed.
- native03: fixed 4 m/s expectation omitted an existing effective-speed modifier
  after synthetic inventory churn. The oracle now uses the current effective cap.
- final/interactions06: writing CarriedItemWeight directly was correctly replaced
  by the real inventory service; use diagnostic load for the controlled comparison.
- final07: setting the live Box boolean alone was correctly superseded by saved
  ownership. The final fixture grants it through the existing canonical service.
- return-final: the initial compatibility script pressed forward before native
  load cleared input, saving a stopped ramp. Preserved fractions/times still loaded
  exactly. Corrected scripts wait for load completion before issuing movement.

These are fixture failures and are not hidden or counted as passed checks.
The remaining issue design and manual acceptance stay outstanding.
