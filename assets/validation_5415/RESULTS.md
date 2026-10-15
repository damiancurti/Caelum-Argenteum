# #260 / 5.4.15 — ordinary acceleration component (draft)

Windows 11, installed GZDoom 4.14.2, private development IWAD. Native tests use
unpaused background execution and 5% audio; no interactive window was launched
while the author was away. The impulse gesture is not implemented and has no
claimed acceptance. CA260-01 passed on 2026-10-15 for ordinary movement only;
acceptance.json records the author confirmation and interactive run.

Final result: **90 qualified native assertions in eight runs**, plus seed and
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
