# 5.4.4 / #238 - Preparation component checkpoint (in progress)

Baseline: c07be5a2 / 5.4.3. This is an intermediate #238 checkpoint. It does not
complete the ability issue or enable the new lifecycle through production User4.
The existing instant Sleep input remains until payment/release integration is
ready. There is no new class effect, racial toggle or left ability HUD yet.

## Implemented component

Shared 105-tic presentation lowers the real equipped weapon/hands, raises empty
fists, turns/opens palms, then returns the ordinary view. It uses saved identity
and equipped glove selection. Real primary/secondary, unarmed, ranged, charged,
magic, utility-stream, bolas and block entry guards reject preparation. This
component does not add movement immobilization or charge Anima; it exposes a
start operation for the future authoritative lifecycle. The start operation
clears pending weapon attacks/charge/block/reload. Full admission/interruption
policies remain pending and are not selected by this component test.

Two fields on the existing player, ClassPreparationRevision and
ClassPreparationTics, provide revision-1 neutral defaults and the saved clock.
No new inventory/effect actor is created. A new actor class supplies visual
states only; no instance of that class is spawned. Current saves resume the
remaining clock, rather than replaying all three seconds.

## Native evidence

Windows 11 / GZDoom 4.14.2 / Vulkan, isolated configuration, unpaused in background,
5% audio. Final runtime SHA-256:
`60f23f87a058f8029d9dfd0324c8880ec95f12b8fc84be8b8c9f76b766ddb2e2`.
Fixture SHA-256:
`03fb75b7ed6fd950c6e2671410bc0c5ca621f30593807b125c4331df758e8408`.

`build/issue238-component-render-final/matrix-03` passes **2,142 checks** across
10 full cycles: staff, book, statuette, bell, sword, carbine, shotgun, bow,
crossbow and unarmed. Each cycle observes 105 clock transitions through zero,
plus the initial boundary, while native +attack is held. Direct entry checks
also verify no resource debit, no pending weapon attack and rejected block
eligibility. This does not establish a shielded physical-input block test,
actual movement displacement, native User4 activation/cancellation, every utility
weapon or final ability eligibility. Those remain part of the full issue.

Native male human, male wolf, female human and unarmed previews were inspected.
No source art was redrawn: cast-only male palms correct the original atlas row
extraction through the existing deterministic fit/tint pipeline. All 36 PNGs and
two native registrations repeat byte-for-byte. Existing weapon hand modules and
their generator outputs are untouched. Female/gloved palettes reuse their old
registrations; a full variant/input/resolution author review remains pending.

The composed weapon controller clears and reconstructs overlays. Reusing its
interpolation history produced moving origins/cropped limbs during the new pose;
the cast component now owns those coordinates and disables that stale overlay
interpolation during its 35-Hz sequence. Ordinary drawing restores its original
interpolation flags. Source-art hashes/provenance are in palms.json.

## Failures and limits

Earlier preserved runs include a fixture local/field name collision (ZScript is
case-insensitive), an off-by-one WorldTick observation assumption, and a fixture
attempt to use a fourth ConsoleEvent argument. The final fixture asserts complete
cycle coverage; no earlier superficial completion line is counted as that pass.
Visual iterations exposed detached atlas strips and clipped forearm framing;
those captures remain preserved. Artistic/animation approval is outstanding.

Raw 5.4.3 rollback loads the body/ready weapon but reports two discarded new visual
states. The optional rollback_bridge.zs maps those state indices to old hand
poses until ordinary weapon drawing takes over. It is for the old runtime only;
never load it beside production CaelumClassCastHandFrames. It changes no balance
or saved inventory. Exact save tests/qualifications are recorded in evidence.json.
Full preparation payment/effects/cooldown/hub compatibility is not claimed.

## Remaining work and author handoff

Complete payment, release, cancellation and independent input handling; implement
revised Sleep and racial lifecycle, plus the left-side class/racial HUD. Preserve
the author's fixed three-hit rule and resolve exact social scaling/composition,
initial/partial Anima eligibility and interruption policies after return.
No actionable author acceptance entry is added for this incomplete component.
Existing CA259/261/254 checks remain pending. No manual acceptance, merge or issue
closure is inferred. Tests have not been handed off while the author is away.

## Reproduction

Use fresh directories/labels to preserve evidence. Fixtures remain outside src.

```powershell
python assets/validation_544/prepare.py --directory issue238-recheck
powershell -NoProfile -ExecutionPolicy Bypass -File assets/validation_544/run_native.ps1 -Directory issue238-recheck -Label matrix -Script matrix.cfg
powershell -NoProfile -ExecutionPolicy Bypass -File assets/validation_544/run_native.ps1 -Directory issue238-recheck -Label preview -Script variants.cfg
```

The packager also writes save.cfg. prepare_compatibility.py accepts --runtime,
--save, --directory and --mode old/old-bridge/current/legacy-current; it copies
inputs without changing the originals. Its launcher uses -Fixture probe-v2.pk3
-Script verify.cfg -LoadGame stage.zds. The old seed uses seed.cfg without a
LoadGame argument. Generator: Python/Pillow 11.3.0, generate_class_cast_palms.py.
No engine, development IWAD, saves or test PK3 is included in the delivery.

## Final compatibility and static results

The final-runtime save contains 19 preparation tics. reload-02 observes 19 on
WorldLoaded and expiry to zero without restarting. rollback-02 loads that save
on 5.4.3 with the visual bridge, preserves a live player/ready weapon and emits
no invalid-state warnings. seed-01 creates a neutral 5.4.3 save; upgrade-02 loads
it on the final runtime, observes zero preparation and idempotent revision 1.
An earlier legacy test sent its mode event before the save finished loading;
its failed assertion is preserved. Waiting before that event fixes the fixture.
These are isolated component checks, not the still-unimplemented paid lifecycle.

`python build_document_index.py` refreshed the locator. `python validate_project.py`
passed with `errors: []`, 2,480 CONTEXT words. Normal `build_dev.ps1` passed with
16,118 files and no directory entries. Every member equals the final native-tested
runtime. `git diff --check` passed. Unrelated local deletion/untracked files and
all earlier evidence remain untouched.
