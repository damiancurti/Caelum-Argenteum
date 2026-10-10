# Issue #163 - recoverable bolas, release 5.1.16

Implemented the approved single-tier family-1 tool, bronze/leather recipe,
one-second accuracy preparation, recoverable native item and independent
five-second restraint. Fire, shared-speed cutting and one Strength roll govern
destruction; own demon breath uses actual paid contact. Author handling/art
acceptance remains CA163-01. Permanent Rulo/Caella grants remain #164.
This focused branch is stacked on issue-162-utility-staff (PR167, dc757efe).

Static validation passes with zero errors (`static-validation.json`). The normal
build succeeds with 6,307 files; every member is byte-identical to the final
native package. The atlas remains unchanged and its registration generator
produces identical bytes on two repeated runs (`build-verification.json`).

## Native evidence

Windows 11, GZDoom 4.14.2, Vulkan, 1280x720, fixed RNG seed 163, unpaused in the
background at 5% audio. No keep-awake request was acquired. Raw run metadata
records commands, engine/IWAD/package/fixture fingerprints and exit codes.
No engine, development IWAD, generated PK3, save or binary test map is included.

| Run | New passing assertions | Scope |
| --- | ---: | --- |
| delivered-checks | 40 | IDs, one tier, reference mass/materials, spread boundaries, cutting classification, Strength 0/50/100/>100, one-item recovery, repeat hits, immunity, fire/ice, death/removal, interruption, unrelated stuns, simultaneous resolution |
| delivered-crafting | 20 | Five sizes by three efficiencies, network requirements, native craft, binary intact output, excluded repair/salvage, legacy inventory dismantle hotkey rejection |
| final-npcs | 17 | Possessed machete/sword, held-carbine eligibility and ammunition, bull/Zupay exclusions, payable/insufficient own breath, stationary restraint, automatic soldier and Mandinga cuts, no early Strength release |
| delivered-inputs | 10 | Real held secondary, cap/cancel, primary during preparation, native flight collision without damage, missed ground recovery, exact ID/integrity, visible binding and natural expiry |
| delivered-prepared-observed | 3 | Native save restores 35 preparation tics and the owned item; released input then cancels normally |
| final-attached-reload | 3 | Same attached item, timer and both rope sprites; one intact recovery after loaded expiry |
| final-escape | 8 | Real movement/attack/Reload input while bound, no ammunition use/reload, pain cancellation and explicit restart, destruction on cut completion |
| final-escape-reload | 4 | Saved cutting progress/timer/item, ammunition independence, exactly one completion |
| final-travel | 7 | Player departure drop/release, owned-item identity, no traveler duplicate, paused NPC timer and visible restraint on hub return |
| final-regression | 35 | #162 utility-staff geometry, thermal transfer/contact, Anima, wear and cleanup remain valid; recipe revision expectation advances to 7 |
| delivered-legacy / delivered-legacy-again | 6 + 6 | Real 5.1.15 save migration, retained wand identity/tier/size/essence/durability and prior recipe knowledge, locked new recipe, idempotent repeat load |

Total: **159 passing assertion executions**, with zero failures in the selected
final runs. Saved handler counters include earlier assertions; the table counts
only new PASS lines from each run. `native-summary.json` records those counts
and package identities. Native screenshots show ready/spin/release/recovery,
body-fitting ropes below the mouth, dropped pickup and inventory icon/name.

The full mechanics runs used package
`a2f649afbc9a5935df1fee150331585ba909c7be92a975793faeacd72de3aa3b`.
Two subsequent runtime changes added the HUD icon fallback and rejected the
legacy inventory dismantling shortcut. Both were checked with the affected
native UI/crafting runs, plus repeated mechanics and migration checks.
`build-verification.json` reconstructs that earlier package exactly by reversing
only those two changes, documenting the evidence boundary without claiming that
every run used the final bytes. Final native package:
`a55086711c954f5af2a409fdc2c6c8d896af5f1c8ccffc9db77f46749136e202`.
Normal development PK3:
`bf56e70c2ab224a2fd5a8d85203edcb768e83b75307506d01053237ee73b65a3`.

## Findings resolved during validation

- Native SpecialMissileHit defines MHIT_DEFAULT, MHIT_DESTROY and MHIT_PASS;
  there is no MHIT_ABORT. Declaration verified in the installed 4.14.2
  gzdoom.pk3, zscript/doombase.zs; native compilation verifies the final use.
- An initial collision assertion read a fixture's pre-PostBeginPlay Health.
  The corrected test captures the initialized Health before collision.
- An apparent early bull escape was real external fire from Zupay, not an early
  Strength roll. `exploratory-fire.txt` retains the fire-contact trace (tic 122,
  CaelumMagicTest, CaelumActorSimpleElementalProjectile) and the superseded failed
  isolation assertion. Quiet demon fixtures isolate the expiry test; the final
  bull stays bound until natural expiry. DiagnosticPassiveAI alone does not
  disable native state actions.
- Preparation was correctly serialized as 35 in the native save, but testing
  after released-input ticks mistook normal cancellation for serialization loss.
  A StaticEventHandler.WorldLoaded observer verifies the pre-tick state. See
  CA-KP-072 in KNOWN_PITFALLS and delivered-prepared-observed.txt.
- Visual inspection reduced oversized restraints, preserved round weights with
  uniform scale and removed a neighboring atlas fragment through native clipping.
- Final review found that the legacy inventory B shortcut bypassed crafting-task
  salvage eligibility. It now rejects bolas explicitly; the real transaction
  test confirms no item destruction or materials.

Earlier exploratory runs remain local under build/issue163. They are not final
passes or author acceptance. Relevant static/engine evidence is distinguished
from CA163-01 and from the future #164 campaign tutorial test.

## Reproduction and original art

Run `python assets/validation_5116/prepare.py`, then
`powershell -NoProfile -ExecutionPolicy Bypass -File assets/validation_5116/run_suite.ps1 -Prefix fresh163`.
Use a new prefix to preserve earlier logs. The script runs serially, verifies
native error/PASS lines and retains outputs under build/issue163. Inspect the
resulting screenshots separately. pending_test.txt supplies the interactive
author procedure; close that engine normally when finished.

The built-in imagegen tool produced the original
[RGBA atlas](../source/art/bolas_5116/atlas.png). The exact prompt and provenance
are in [PROVENANCE.json](../source/art/bolas_5116/PROVENANCE.json); measured native
clips are in [DESIGN.json](../source/art/bolas_5116/DESIGN.json). The deterministic
[registration generator](../generators/register_bolas.py) copies the pixels to
src/graphics/caelum/bolas/atlas.png and registers all views through TEXTURES.
Existing project hands are reused. Museum sources establish the physical
reference/material tradition; the approved 800 g bronze/218 g leather split
is explicitly a design allocation, not a historical gram measurement.
