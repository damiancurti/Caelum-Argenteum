# Issue #211 — impact and landing capacity, 5.2.19

Date: 2026-10-12 (America/Buenos_Aires). Baseline: main `4549991a` / 5.2.18.
Engine: installed GZDoom 4.14.2, Windows, Vulkan. Native runs were unpaused in
the background at 5% master volume, with disposable configuration and saves.
Author acceptance remains **CA211-01** in root pending_test.txt.

## Final contract

The author first requested horizontal cushioning at 150% of the body's own
jump-speed capacity, confirming player and bull separately. The later amendment
also applies 150% to falls for every already cushioned biological body, but
explicitly excludes crushing. Actual jump physics is unchanged.

For eligible impacts, subtract `1.5 * unscaledJumpAbsorptionSpeed` from normal
delta-speed, clamp at zero and retain the square of the residual speed ratio.
Keep the zero-delta guard and the active buckler x2 enhancement once. Existing
contact eligibility and independent bilateral energy assignments remain.
Ordinary NPCs gain the new fall capacity, not new horizontal protection.

Crushing retains the unscaled jump helper. Player hazard-rock pressure keeps
its prior buckler fraction; weighted NPC rock pressure stays uncushioned, and
the bull's unweighted/direct rock-pressure fallback retains its old fraction.
Preserve the original pressure kind before relabeling a hazard as environment.
An incoming falling rock with active buckler uses the new impact capacity.

## Native evidence

| Run | Passed | Coverage |
| --- | ---: | --- |
| checks-delivery | 59 | Agility 0, load, health/elemental jump modifiers, below/at/above capacity, zero delta, exclusions, buckler overlap, immobilization, all-body falls, ordinary and hazard pressure, weighted/unweighted bull fallback |
| contacts-delivery | 216 | Four mansion residents, stationary/same-direction/opposing motion, both recipient orders, neutral/real anatomy and armor; bull cushioning never reduces the resident's assigned energy |
| bull-delivery | 14 | Native acceleration to 10 m/s, target tracking, Pain/bolas interruption, release and normal collision mass |
| motion-delivery | 15 | Native body/floor landing, one-shot collision callbacks, cannon, rock, gate and continuous contact-work delivery |
| pressure-delivery | 23 | Native MAP08 stone crusher work, pulse deduplication, sustained static load and original crushing rules |
| movement-delivery | 7 | Actual crouch input, native player wall collision, player and ordinary-NPC falls; final energy follows the 150% formula once |
| save-current / load-current | 1 / 7 | Current active bull charge preserves identity, speed, health and state, recomputes capacity, and stops normally |
| save-baseline / load-baseline | 1 / 7 | A newly created 5.2.18 save loads under the new runtime with the same preserved charge checks |

All 350 checks above pass. The six `-delivery` runs use the final runtime;
persistence ran with identical mechanics before only the two console release
labels were updated to 5.2.19. No saved field or state index changed.

`checks-baseline-final` runs the final 59-case fixture on 5.2.18: **18 expected
failures and 41 passes**. The failures identify the new horizontal/fall contract;
the preserved pressure expectations pass. It is regression evidence, not a
passing new-rule run.

Actual native examples: the player's wall delta of 5 MU/tic is fully cushioned;
at a falling delta of 15.587657143 MU/tic, 14533.420050 J becomes 4839.476188 J
after the player's cushioning. An ordinary NPC in the same motion fixture
retains 4722.366235 J from 12353.407043 J. These are energy diagnostics before
defenses, not expected universal HP loss. The motion fixture protects observers
from death while retaining production movement and collision callbacks.

## Static, packaging and review

`static-validation.json` records the final project validator result. The normal
builder succeeds, and `package-check.json` compares all **16,052** runtime
members byte for byte with the tested production package. Test fixtures,
temporary saves, engine and development IWAD are excluded from the official PK3.
`runs.json`, `manifest.json` and `logs/` retain run/package hashes and diagnostics.

Independent agent review identified environmental relabeling in both player
and NPC pressure paths; explicit provenance and separate old-pressure helpers
close those cases, with direct and preweighted delivery tests. This is agent
review and native evidence, not author gameplay acceptance or a performance
benchmark. No exhaustive campaign playthrough is claimed.

## Diagnostic attempts retained

The early 48-case checks and 14-failure baseline preceded the author's expanded
fall scope. The intermediate 55-case checks preceded the NPC unweighted-pressure
fallback correction. They are superseded by final delivery runs.

`movement-01` issued crouch/position setup before startup menus finished resetting
input, so no intended wall contact occurred. Its diagnostic division by zero
was in the fixture, not production. `movement-02` and `movement-delivery` wait
for initialization, guard zero delta and pass all seven native motion checks.
Original failed logs remain available and are not counted as passing evidence.

## Reproduction and temporary power request

Run `python assets/validation_5219/prepare.py` with no concurrent native test,
then `run_native.ps1` with a fresh label, matching fixture/config and MAPQA
(MAP08 for pressure). Use `-Baseline -ExpectRegression` for the baseline formula
test. Persistence uses persistence.cfg or legacy.cfg, then reload.cfg with the
saved basename. The runner records exact arguments and hashes for each run.
Adapted #194/#195 fixtures are assembled explicitly in prepare.py; their
original historical sources and evidence are preserved.

The thread-scoped keep-awake request was released after native testing, without
changing the Windows power plan; see power-request.json. The real launcher
configuration and the author's existing saves were not modified.
