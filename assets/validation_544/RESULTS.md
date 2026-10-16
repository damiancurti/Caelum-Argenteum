# 5.4.4 / #238 - Shared lifecycle, HUD and Sleep


## Completion - 2026-10-15

The shared controller/HUD/Sleep scope is complete. CA238-01 and CA238-02 retain
their explicit author acceptance; concrete racial effects stay in #239-242.
The previously open paid-state rollback boundary now has an isolated, pinned
5.4.3 schema bridge and native round-trip evidence in rollback_evidence.json.
The sections below describe earlier checkpoints, with their original hashes
and qualifications. They do not override this completion record.

The bridge preserves new serialized fields/classes and appended state indices.
It runs old gameplay, not the new cast/racial controllers. New fields remain inert;
old cooldown/Sleep timers continue normally. Returning to the current runtime
resumes paid preparation, retains the Sleep hit counter/power, and never refunds
or duplicates the cast payment. This is a specific recovery path, not a universal
downgrade of later powers or a promise of new ability behavior in the old game.
Keep original saves and runtime packages; all tests use isolated copies.

Production gameplay is unchanged from 0e0ae85f. The new native runtime is packaged
from that pinned Git tree; its text line endings differ from Windows checkout
packages, so earlier byte hashes remain distinct. Current save/input/hub evidence
is reused only for the unchanged controller. No new manual test is required for
this tooling-only completion. PR280 is ready; no merge or closure is inferred.

Reproduce with `python assets/validation_544/prepare_paid_rollback.py --directory
<fresh-prefix>`; it creates `<prefix>-current` and `<prefix>-bridge`. Use
`run_native.ps1 -Fixture paid.pk3` for each stage. Create `paid.zds` with
paid-seed.cfg in current, copy it to bridge, and run bridge-paid.cfg with
`-LoadGame paid.zds`. Copy bridged-paid.zds back to current, run repeat.cfg
loading it, then resume.cfg loading repeated.zds. Separately create cooldown.zds
with cooldown-seed.cfg, copy it to bridge and run bridge-cooldown.cfg, then copy
bridged-cooldown.zds to current and load it with cooldown.cfg. Use fresh labels,
check every exit and save artifact before the next stage, and never run two
engines at once. No runtime, save, development IWAD or engine is distributed.

## Current lifecycle follow-up

The later shared racial follow-up is recorded in racial_evidence.json. User1
now dispatches a revision-1 effect object, current per-tic Anima debit, held-input
latching and forced-control cleanup. Production has no concrete effect factory
yet; the isolated fixture overrides it with counters only. Forty-three native
contract/input checks cover nine real weapon families plus unarmed; save (25),
reload (3), hub return (27), the existing class/Sleep contract (1,021) and neutral
5.4.3 upgrade pass. The native upgrade asserts the new racial object is null and
revision 1. Normal packaging matches all 16,155 native-tested runtime members.

Numerical journey forecasts retain the existing unsupported-effect restriction
for pending class preparation and racial effects, without spending resources or
stopping the effect. Native map/hub transitions remain supported. The full
paid-state rollback boundary below and consumer-specific #239-242 checks remain
open; this is not manual acceptance of a playable racial bonus. Failed reserved
method-name and fixture cost-oracle attempts remain recorded in the evidence.

Production User4 now owns preparation/payment/release for Arcanist Sleep. The
shared controller requires the full cost, snapshots it and debits uniformly over
105 tics. A second press, forced control/death or insufficient next payment cancels
without refund or cooldown. Attacks, blocking, weapon/inventory mutations and new
Seal/Tarot/racial activations are blocked. Movement and damage alone do not cancel.
The release starts exactly 60 seconds of reuse. Other professions retain their own
pending effect issues; no synthetic racial activation is enabled.

Sleep has schema-1 saved hit/multiplier/pose state. Native damage receivers count
actual HP loss and multiply final damage after project defenses, including native
DamageFactor and integer rounding. The third enemy hit still receives the factor;
zero-damage impacts do not count, and DOT applications count separately. Allies
and neutrals retain one-hit wake without the multiplier. Expiry and reapplication
use the author-confirmed rules. Existing RestLying poses restore safely without
replaying actions. The later visual follow-up below fills the four missing bodies.

Lifecycle-tested production SHA-256 (before the separate icon reduction below):
`346f3bd66b9ef6369f40c3e62fb3a925ac2724193c58321b770ba8f54548a899`.
Native Windows/GZDoom 4.14.2 evidence is in lifecycle_evidence.json. Key runs:

- issue238-release/contract-01: 1,021 checks, actual User4 armed/unarmed,
  three starts, two releases and one cancellation; inventory guards included.
- Same runtime save-01: 178 checks; load-01: 4 checks, complementary resource/debit,
  one release, saved enemy count two and damage factor six.
- issue238-release/hub-01: 459 checks, real MAP02 -> MAP03 -> MAP02, paid
  preparation retained and NPC Sleep state restored; only one successful release.
- issue238-lifecycle-upgrade/upgrade-01: original 5.4.3 save loads neutral new fields,
  revision 1, no paid cast and no new Sleep object.

The native TakeSpecialDamage hook follows project defenses and native factors.
Production damage paths use the project's armor system. Arbitrary third-party
native inventory armor and telefrag exceptions are not validated by these checks.
The final wake path preserves indefinite state tics. New unarmed input states are appended after all old states to preserve save indices. The preceding runtime passed 4,239 native User4 checks across nine weapon families and unarmed; the final contract repeats the changed wake and unarmed paths. New save data and full rollback coverage remain an explicit completion boundary;
keep original saves/runtime packages. The prior visual-component rollback evidence
below is not upgraded into a paid-state rollback claim.

CA238-01 is the executable preparation/HUD author check only. A fresh isolated
configuration binds F to User4, F6 to reset test resources/reuse, F7 to the next
real weapon, F8 to unarmed and F9 to one Anima below the actual modified cost.
The fixture gives invulnerability and disables Anima regeneration to expose debit;
it does not change production balance. No full Sleep visual acceptance is claimed.

## Smaller class/racial icons - author-requested visual follow-up

The author requested smaller glyphs, close to Tarot/Seal size. The two square
frames are reduced from 88 to 64 logical units (27.3% per side), matching the
Tarot frame width and approaching the Seal artwork's visible width. They remain
centered in the same column; labels and class countdown move beneath the glyphs.
No art source, Tarot/Seal rendering, resource bar or gameplay state is changed.

Native HUD checks pass 16 assertions each at 1280x720 and 640x480/high scale.
The latter run's six state captures were inspected. Both runs use the same screenshot
names: the retained six files belong to the later 640x480 run; no preserved 1280x720
state capture is claimed. The separate author seed provides a retained 1280x720
comparison with owned Tarot and Seal. Runtime/fixture/capture hashes and normal
build comparison are recorded in small_icons.json. The author passed CA238-01 on 2026-10-14; see acceptance.json. This covers preparation/HUD only, including the smaller icons.

## Original presentation checkpoint (historical scope)


Baseline: c07be5a2 / 5.4.3. This is an intermediate #238 checkpoint. It does not
complete the ability issue or enable the new lifecycle through production User4.
The existing instant Sleep input remains until payment/release integration is
ready. There is no new class effect or racial toggle yet. A same-version follow-up adds
the left class/racial HUD; its separately frozen evidence is recorded below.

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

## Original checkpoint remaining work (superseded by current scope)

Complete payment, release, cancellation and independent input handling; implement
revised Sleep and racial lifecycle. Preserve
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

## Left HUD follow-up (same issue/version)

Runtime `31db33a10640b21870d61b730da9445921638c03cba160a3b4bca35b6918ac5c`
adds the class/racial column using the existing power scale and owned generic
icons. The original component matrix remains evidence for unchanged preparation
and guards; it is not relabeled as a test of this later package. Class readiness
reuses extracted Sleep eligibility/cost, including insufficient/exact-cost
boundaries. There is no new paid lifecycle. Racial active/inactive state is set
synthetically for this presentation fixture and does not apply a racial effect.

Four native runs each pass the same 16 assertions: 1280x720 and 1024x768 Spanish,
1920x810 English, and 640x480 Spanish with hud_scale=8. Captured PNG dimensions
confirm these viewport sizes. Inspected captures cover preparation, availability,
dim-gray unavailability, a progressing 60-to-58-second class cooldown, racial
active/inactive and coexisting Tarot/Seal indicators. Compass/notices reserve the
left column. The six resource bars retain their established positions. This is
agent visual inspection, not author approval or all-configuration coverage.

The same final runtime loads the prior 19-tic preparation save without restarting,
and a neutral 5.4.3 save initializes revision 1 with zero preparation. Both saves
keep the new racial display boolean false. Exact logs, capture hashes and run
settings are recorded in hud_evidence.json. The initial HUD compile error from
accessing a temporary vector's X component is preserved; a local vector fixed it.

Reproduction: prepare.py also creates hud.pk3 and hud.cfg. Run run_native.ps1
with -Fixture hud.pk3 -Script hud.cfg and optional -Width/-Height/-HudScale/
-Language. Use separate directories or distinct screenshot prefixes to retain
all captures. No interactive author handoff has occurred while the author is away.

HUD follow-up static validation passed with errors: [], 2,483 CONTEXT words;
normal packaging contains 16,119 files and no directory entries. Every member
matches the frozen HUD-tested runtime. Dialogue/document indexes are current.

## Author design follow-up - 2026-10-14

Confirmed existing Eloquence radius/cost, Charisma harmful power/duration and
Empathy beneficial/healing power/duration curves; direct damage stays with
Intelligence. Scale whole authored multipliers (x3 with x2 power becomes x6),
never the three-hit Sleep count. Require the full modified cost before starting,
then debit progressively through the fixed three-second preparation. These are
contract updates only; no new lifecycle/effect test or manual acceptance is claimed.

## Living creature poses (same-version visual follow-up)

Eight views each cover naturally lying rat/Bull and supine Mandinga/Zupay. Only
new art/registrations and appended actor states change production. Existing
collision, attributes, death art and earlier state indices are retained. Native
captures inspect all 32 views. Registration repeats byte-for-byte with Pillow
11.3.0; sources, prompts and hashes are in assets/source/art/sleep_544.

Final runtime: 15a025e20e3f06186c025e0c39d7c4ff8fd179412b850c34ea052efd70f5a59c.
issue238-sleep/poses-05 passes 36 checks: living poses, unchanged collision,
three final-x3 HP hits and waking/expiry in all four actors. load-03 passes four
saved-pose/two-hit checks. sleep_pose_evidence.json records exact fixture hashes,
native User4 handoff checks, commands and preceding fixture failures. A contact
sheet is a locator; full captures remain under the identified build directory.

This visual follow-up does not rerun unrelated class/HUD matrices. Earlier
casting contracts retain their documented runtime hashes. No paid-state rollback
or full multiplayer claim is added. A previously saved null Sleep lying pointer
keeps its pre-art presentation until expiry/reapplication; the effect is retained.
The author passed CA238-02 on 2026-10-14: "Estas pruebas dieron correcto."
The game exited normally (0). Exact scope: sleep_acceptance.json. This confirms
the offered creature poses and wake behavior; #238 remains in progress.
