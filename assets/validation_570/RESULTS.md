# #408 — Water quality, 5.7.0

Fourteen selected native runs contain **166 PASS, zero FAIL**. Static validation
and normal packaging pass. CA408-01 passed explicit author review on 2026-10-21.

## Scope

- All 64 ordered contamination mixtures conserve volume and all source flags.
- Ten real fully submerged source rooms cover potable, seven contaminated
  combinations, unmarked water and invalid mapper data. Automatic refill is
  potable-only; explicit refill preserves contamination and rejects full,
  overweight and Box vessels without mutation.
- Drinking, quick use, dining, rest forecasts and journey provisions reject
  unsafe water. Empty/refill and native toss preserve the intended state.
- Current save/reload, hub exit/return, a real prior-release save, upgraded
  resave/reload and original-save rollback pass. The accepted V5.6 runtime is
  pinned by hash in report.json; original saves remain local in build/issue408.
- Production network inventory actions collect/empty the selected container.
  ES/EN Inventory and ES quick-use captures were visually inspected. Actual
  author acceptance was confirmed for CA408-01 on 2026-10-21; see HISTORY.
- Final-package MAP01 startup without the diagnostic addon succeeds.

The final source package has 16,434 members. `collect.py` compares every member
byte-for-byte with src. The tested gameplay package and final package differ
only in two required diagnostic release labels, from 5.6.11a to 5.7.0; the
collector verifies this exact replacement and rejects any other difference.
Final-package production dispatch, HUD and normal MAP01 startup were rerun.
Every run records its package/addon hash and environment separately.

## Environment and performance boundary

GZDoom 4.14.2, Windows 11 build 26200, Ryzen 9 5950X, RTX 3070 Ti, Vulkan,
1280x720. The engine reports pause=0, background rendering=1, lowering=0,
background sound=1 and master volume=0.050. Runs are sequential and temporary
test configurations do not replace the player's normal configuration. No
keep-awake request was needed. No frame-presentation or performance improvement
claim is made; no retired army scenario was run. The change adds no actor scan.

## Preserved exploratory failures

`diagnostic-suite-01` exposed a case-insensitive ZScript constant/method name
collision; `diagnostic-suite-02` exposed a missing play context on the inventory
action. Both were corrected before final native tests. The third suite used an
obsolete M/500 hydration expectation; the current accepted M/400 contract in
SYSTEMS and the runtime agree, so only that test expectation changed.

The first save test allowed automatic drinking below the existing 50-point
ordinary target. Its saved clean volume was correctly 0.50 L rather than the
fixture's pre-tick 0.75 L. The corrected persistence fixture starts at full
Thirst; quantity/quality survive the subsequent tests. Original failing logs
are retained under native/diagnostic-* and are excluded from the pass total.

## Reproduction

Run `python assets/validation_570/prepare.py`, build with `build_dev.ps1
-Destination build/issue408/current/caelum_argenteum_dev.pk3`, then invoke
`run_native.ps1` with a new Label, `-Checks` and the desired Script. The runner
rejects overlapping GZDoom processes and existing labels. `run_final.ps1`
groups current, compatibility and UI scenarios; pass a unique LabelPrefix.
Compatibility requires the pinned baseline package and original legacy save;
these engine-dependent binary fixtures are not distributed.

The manual launch uses Script=interactive and Interactive, preserving an open
engine session. F1–F5 choose the private sources; Inventory R collects, V empties
and Enter drinks. The ordinary test menu also provides mouse buttons. No
campaign water placements, heating, boiling, Alchemy or mate are delivered by
this issue; those remain their own V5.7 patches.
