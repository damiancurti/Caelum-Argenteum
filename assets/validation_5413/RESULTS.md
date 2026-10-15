# 5.4.13 / #246 - Arcane Sun

This focused patch stacks on accepted #245 (720acb5b). Mage User4 replaces the
superseded Brainstorm discounts with the author's traveling fire orb. It reuses
the accepted paid class lifecycle and existing elemental projectile, defense,
burning and visual consumers. No new art or development IWAD is distributed.
CA246-01 passed author review on 2026-10-15: "La prueba dio bien". The offered
isolated scenario is accepted without an additional itemized or campaign claim.
See acceptance.json for the interactive run and hashes. The temporary keep-awake
request was released when the author returned; no merge or closure is implied.

## Approved contract

The 2026-10-15 confirmations settle tier-one uncharged fire-staff reference damage
using current Intelligence/modifiers, independent of equipment; tenfold central
impact/explosion/burning, normal children; enemies only; normal staff speed;
character pass-through and one direct impact per enemy per launch; scenery/expiry
explosion; 40-m base burning/acquisition area, Eloquence scaling and sight; one
nearest-enemy homing child each second; Charisma-scaled burn DPS and three-second
tail; normal child range, persistence and reacquisition; native explosion falloff
and wall protection. The approved 25-shot distribution uses a Fibonacci sphere
with exact vertical poles and near-uniform spacing. Count and size do not scale
with social potency. SYSTEMS is the canonical current rule.

Revision-1 world actors retain offensive snapshots, timers and recipients. Existing
saves have no Sun actors to migrate. Saved native preparation uses the accepted
revision-1 common controller. The optional rollback bridge is restricted to copies
loaded under 5.4.12: it removes unsupported projectiles and cancels Mage preparation
without refund. Preserve the original save to reverse that operation. No existing
campaign save is modified by the tooling.

## Static and normal packaging

Run `python build_dialogue_index.py build`, `python build_document_index.py`,
`python validate_project.py`, then `powershell -NoProfile -ExecutionPolicy Bypass
-File build_dev.ps1`. evidence.json records actual results and compares every
normal-package member with the frozen native runtime. Only src enters the PK3.

## Isolated GZDoom 4.14.2 evidence

Prepare: `python assets/validation_5413/prepare.py --directory issue246-final`.
Run sequentially with `powershell -NoProfile -ExecutionPolicy Bypass -File
assets/validation_5413/run_native.ps1 -Directory issue246-final -Label <case>-01
-Script <case>.cfg`. load/load_prep additionally use `-LoadGame sun.zds` and
`-LoadGame preparing.zds`; names are relative to the engine savedir. The runner
requires a fresh label and no existing GZDoom instance. Hidden automatic runs are
unpaused in the background at 5% audio. It preserves stdout/stderr, exact arguments,
hashes, timestamps, completion markers and exits. evidence.json is the result ledger.

Final result: 84 focused checks across 20 runs passed. The normal package contains
16,163 files, all byte-identical to the frozen runtime's members; static validation
reports no errors. Gameplay runtime SHA256:
`e9e527d3e8549fcfb3534e2a4ccb14b2f0ece30413f69f40b04fa71d5c51dbcb`.
The final manual fixture displays counters during flight and enables native burning
for its stationary recipients; its separate preview passed against the same runtime.

- contract: shared offensive admission, geometry/speed, release-time damage and
  social snapshots, native enemy filters, single direct impact, burning payload,
  real wall visibility, nearest target, child metadata and 25 distinct unit vectors.
- casting: native User4 progressive debit, second-press cancellation without refund,
  later release and reuse. The unchanged full input-lockout/hold/rebind/menu evidence
  remains in validation_544 and is not reported as rerun.
- flight/impacts/nearwall: actual normal-speed movement, no early periodic shot,
  ten timed shots, expiry, walls/floor/ceiling and a release next to a wall; one
  terminal explosion and 25 children, with children surviving the orb.
- explosion/contact: native radial distance falloff, actual wall occlusion and
  unchanged allied/neutral health; actual character crossings and re-entry without
  a repeated central hit. The contact-only fixture postpones periodic children so
  their legitimate extra damage is not mistaken for duplicate central damage.
- guided/range/burn: actual turn and reacquisition, continued child flight with a
  dead source, normal travel budget, periodic health loss after leaving the orb,
  resistance-adjusted expiry and no later periodic health loss.
- save/load: mid-period clock, no repayment, serialized per-enemy direct-hit list
  and child travel/damage, original-map hub projectile and one terminal burst.
  Saved native preparation releases once, with the original fixed payment.
- compatibility: prior neutral save upgrade, optional copied-save rollback of a
  live orb/child or preparation, then re-upgrade of the bridged copy.
- preview: automatic native cast and screenshots for visual inspection. This is
  agent inspection, not a physical author test.

The fixture intentionally fixes resources and suppresses NPC movement/ordinary
regeneration. Burn tests separately call the real periodic status consumer. Its
temporary death check sets source Health to zero; it is not a campaign death/respawn
acceptance test. Native actor allegiance is reused; no network multiplayer result
is inferred. Existing VFX density policy still activates at 500 living combatants;
this patch makes no new performance claim.

## Preserved iterations

v1 used an unsupported Vector3 dynamic array in the fixture. v2 used nonexistent
test-only evasion/armor identifiers. Their compile errors are preserved; production
compiled after fixing fixture types. v3 rejected a vector-sum tolerance of 0.2:
the approved Fibonacci sphere has sum length about 0.245 for 25 samples, so the
finite-distribution test uses 0.25 while checking all distinct unit directions and
both hemispheres. v4 contact assertions counted a legitimate periodic child as a
duplicate direct impact; the focused test now isolates the central orb. Radial
fixtures initially spawned/replaced NPCs and exploded before deferred PostBeginPlay
initialized anatomy; initialized bodies now demonstrate the native falloff.

Some v3-v5 scripts exited with code zero before queued network assertions arrived.
The runner correctly rejected their missing completion markers. Additional terminal
waits let native events drain; this does not change game timing or balance. v6
confirmed the repaired radial and homing cases. Final evidence uses the final
frozen runtime, including current release diagnostics. Logs remain in build;
evidence.json records hashes and limits rather than silently counting failed runs.

## Deferred author check

CA246-01 is in the root pending_test.txt. launch.ps1 opens the isolated game after
the author returns: F cast/cancel, F6 open-flight reset, F7 wall reset. A persistent
PowerShell window was previously rejected by automatic approval review; the direct
launcher opens the game and is the supported handoff. Do not launch the manual
scenario while the author is away, and do not mark the issue accepted without their
explicit result. No merge or closure is authorized for this batch yet.
