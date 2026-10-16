# Issue #283 - Domingo 3D prototype evidence (5.4.23, accepted)

The author accepted the corrected Domingo prototype and ended #283 on 2026-10-15.
CA283-02 is accepted; CA283-01's earlier qualified acceptance remains historical.
The latest shield-grip-01 runtime passed 105 assertions in 12 native runs; exact
geometry/export/package evidence is preserved below. No new engine run is needed
for this documentation-only closure, and no additional manual step is inferred.

The author moved the actual sprite-to-model migration to the future V5.17 roadmap,
with mandatory interchangeable weapon/shield/armor/hair/face parts. Remaining
2/3/4-second rest/provision transitions, fine polish and broader conversion tests
move with it; they are not implemented by this fixed-surface prototype. Earlier
pending/incomplete labels below describe their original test stages.

## Earlier review and validation stages

Initial author review reported sideways knee flexion and rigid elbows while
walking, and requested a shield-block animation. These findings were still open
at that stage; the technical assertions alone did not establish visual acceptance.

The preceding anatomy revision corrects the knee plane and adds varying elbow
flexion. `anatomy-joints.json` checks 186 evaluated joint samples;
`anatomy-evidence.json` records the corrective native runs and current package
separately from the 98-assertion foundation in `evidence.json` (commit 9515fb2c).
The old `record_evidence.py` reproduces that foundation at its original revision;
use `record_anatomy_evidence.py` at its recorded revision for that candidate.
The correction passes 52 native assertions in five runs on the same production
hash: action selection, rest/furniture, moving review camera, terminal death and
loading the previous pilot's save. Static validation reports zero errors; normal
packaging matches all 16,187 source members and seven export files repeat exactly.
These runs use the separately fingerprinted anatomy-01/02/03 fixtures. The failed
anatomy-01 camera assertion identified a one-tic lag; updating the camera actor
in Tick resolves it. Manual author-02 starts from the front in anatomy-03.
The author also requires shield-block and one-second jump/landing animations.
Jump waits for preparation; damage cancels it; movement/attack/block remain
available. These animations and modularity remain outstanding.

## Quiet walk and distinct run revision

The author reported excessive walking hand sway. This revision reduces the hand
arc to 23-28% of the previous candidate while retaining elbow flexion, and gives
Run a separate, more flexed arm pose and broader swing. Native timings and other
poses remain unchanged. The old manual configuration inherited always-run; the
new fixture sets `cl_run false` and binds Shift to native `+speed` in its separate
settings file. This makes the two gaits explicit during author review.

`arm-motion-joints.json` retains 186 evaluated joint samples and comparison with
the preserved candidate-07 Blender source. `arm-motion-evidence.json` records
only this revision's native runs, frozen package and export parity. Reproduce
with `record_anatomy_evidence.py --revision arm-motion`; earlier foundation and
anatomy evidence remain separate. The static studio poses and native walk/run
views support review but do not establish author acceptance. CA283-01 stays open.
This revision passes 32 assertions in three native runs (actions, camera and gait
selection), 186 joint samples, static validation and normal packaging. Seven
export artifacts are deterministic. All 175 non-walk/run model frames remain
byte-identical to the preceding candidate; no broader regression claim is made.

## Human head, layered hair and running grip

The author found walk/run better, requested a more perpendicular running sword,
human head anatomy and improved hair, then selected polished 3D references over
sprite-constrained anatomy. This candidate adapts the pinned CC0 MakeHuman hm08
head and eye volumes; its source/license and modifications are recorded in
DESIGN.json and runtime attribution. Snow (Blender Studio) and petemc's head scan
are visual references only. New curved, tapered hair locks follow the scalp.
The original texture RGB is unchanged; rear head UVs do not repeat the face.

`check_head_grip.py` checks 12,042 unchanged object/pose combinations across all
exported frames against candidate-08. It excludes changed head/hair/eyes and the
Run sword. Thirteen evaluated Run samples verify a perpendicular blade/hand axis
and maintained grip contact (less than 0.001 source unit error). The report is
head-grip-geometry.json. This verifies geometry constraints, not visual acceptance.
The larger model requires fresh native rendering evidence, separate from prior
32/52/98-assertion revisions. Author review and modular/timed-action work remain
open. The current fixture is `build/issue283-head-grip-02`.
The prior head-grip-01 passed its functional checks, but its flat hair color
lost detail in native lighting; the final candidate samples varied owned hair
texture strands. No texture pixels or gameplay scripts changed.


Final candidate: 62 assertions pass across eight native runs (actions, gait,
camera, rest, preview, terminal death and two 64-proxy rendering cases). Static
validation has zero errors; normal packaging matches all 16,188 source members.
Seven export artifacts repeat byte-for-byte. `head-grip-evidence.json` records
hashes, captures and scope; reproduce with `record_head_grip_evidence.py` after
running the listed cases and static/export checks. The 64-proxy means are
0.802678 ms for sprites and 1.162604 ms for this model, Vulkan 1280 x 720,
uncapped after warm-up. This isolated rendering cost is higher; it is not a
combat or 500-actor benchmark and does not justify global character conversion.

## Shield guard and queued jump revision

The opt-in pilot now reads actual native shield-block state for guard poses.
Jump uses one second of preparation before native takeoff, even after releasing
the key, then one second of reversed flexion on landing. Movement, attacks and
blocking retain their ordinary rules. Health loss or incapacity cancels a queued
jump; native CheckJump remains the only velocity/Air/thermal authority. Revision
2 migrates older pilot saves idempotently and retains a saved preparation's time.

`guard-jump-geometry.json` verifies all 195 older MD3 frames remain byte-identical,
36 reverse-pose samples and 144 planted-foot samples (maximum error 0.0055 source
unit). Knees flex predominantly forward and the body lowers 19 source units.
The source/export now contains 24 actions and 375 frames; export-16/-17 repeat
all seven artifacts exactly. Native rendering of guard and preparation was
inspected separately from the geometry assertions. CA283-02 remains pending.

`guard-jump-evidence.json` records the precise motion-01/02 run/fixture hashes,
save migration/rollback, assertion counts, package parity and static results.
These are separate from the older art/performance measurements above. The
revision passes 180 assertions in 19 runs, zero static errors and normal package
parity across 16,188 source members. The original rollback fixture expected
revision 1 and failed only that metadata check; a separate fixture changes the
expectation to 2, with all eight assertions passing. This checks a resting migrated
save, not downgrade during an animation absent from the older model. Both logs
remain preserved. The
motion-01 jump-save fixture quit too early to save/finish its event; its failed
log is preserved. Motion-02 waits for native completion. No gameplay fix was
needed for that fixture failure. Modularity and rest/provision timing remain open.

## Shield attachment and ten-tic preparation correction

CA283-02 remains open: the author praised the flexion but requested ten-tic
preparation and a shield held by its grip, resting in the forward/back plane
beside the body. The shield now follows hand.L and has a visible rear grip.
The evaluated handle center remains in the hand across all 375 poses; 16,500
non-shield object/pose comparisons remain unchanged. Maximum contact error is
0.000032 source unit. The landing stays at 35 tics. DESIGN.json supplies native
sample times independently of retained source poses, preserving every frame ID.

`shield-grip-evidence.json` records this revision's native, static, export and
package checks: 105 assertions in 12 native runs, zero static errors and matching
normal package/source members. Seven export files repeat exactly.
`shield-grip-geometry.json` records the geometry comparisons.
Prior evidence above belongs to the preceding builds. The first travel fixture
waited until the shortened preparation had already launched; the corrected
fixture waits one startup tic before changing map. An intermediate attempt with
no wait ran before the loaded game was active and was rejected by the engine.
Both failed logs remain preserved. CA283-02 requires review of this corrected build.

## Artifact and reproduction

- Editable source: `assets/source/art/domingo_3d_pilot/domingo.blend`; its packed
  skin preserves source RGB. Source/provenance and deferred questions: DESIGN.json.
- Pinned tool: Blender 4.5.3 LTS, official build 67807e1800cc. See DESIGN.json for
  the archive fingerprint and ASSETS for the export command. The committed blend is the art input;
  its initial authoring transcript is not a deterministic blend-file generator.
- Current export: one surface, 10,689 UV-split vertices, 17,447 triangles, 375 frames,
  32,383,160 MD3 bytes; 1254 x 1254 skin, 1,863,217 PNG bytes.
- Native format/normal decoding checked against GZDoom g4.14.2
  `src/common/models/models_md3.cpp` and `model_md3.h`.
- Run the exporter twice into fresh directories; `validate_export.py <first>
  <second>` compares all seven artifacts, validates offsets/indices/UVs/frame
  bounds and checks installed source parity. No test IWAD or executable ships.
- `prepare.py --directory <fresh-name> [--visual]` freezes production plus an
  isolated fixture. `run_native.ps1 -Directory <name> -Label <fresh-label>
  -Script <case>.cfg` uses separate settings/save data, unpaused background
  execution and 5% audio. `--visual` removes only the permanent HUD in the fixture;
  the Journal/live-rest consumer is retained.
- Manual: omit `--visual`, use `manual.cfg -Interactive` while the author is available.
  F6 compares sprite/model, F7 cycles native chair/bed/ground rest, F8 changes
  viewpoints. B toggles native shield block, Space queues Jump, F9 applies test
  damage (while health is sufficient); F10 automatically queues a jump then
  applies damage during preparation. Q exits a rest panel before another
  shortcut. CA283-01 provisionally accepted the previous presentation; CA283-02
  covers guard/jump. CA282-01 is independently accepted.

## Evidence levels

Static checks validate the project, documents/index and deterministic MD3 output.
Native scripts use actual movement/weapon input and production equipment/rest APIs;
they separately check side-effect-free visual updates, terminal death/equipment
cleanup, sprite/firearm fallback, current saves and an actual hub round trip.
An unmodified 5.4.22 quick-use save is loaded in the new runtime to exercise the
ordinary CaelumPlayer, including preserved selection/stock. Author acceptance is
pending. All 98 assertions passed across 14 final native runs. Exact fingerprints,
assertions, capture hashes and measured frame intervals are recorded by
`record_evidence.py` in `evidence.json` for this intermediate prototype.

`issue283-final-15` is the preserved foundation build. Its native capture files remain
under build and are not distributed with development IWAD textures. The normal
PK3 is rebuilt from src and its member bytes are checked against the frozen build.

## Rendering measurements and limits

Matched cases render one or 64 sprite/model proxies with identical camera,
positions, settings, warm-up and measurement duration. The proxies deliberately
have no combat AI. Vulkan on RTX 3070 Ti, 1280 x 720; vsync/frame cap disabled only
in the isolated configuration. Frame intervals include rendering, simulation and
scheduling; they are not GPU timestamps. `profilethinkers -t 20` separately records
native thinker costs. The counts and final measurements are in evidence.json.
No large-battle or general performance improvement is claimed.

| Render proxies | Sprite mean interval (ms) | Model mean interval (ms) |
| --- | --- | --- |
| 1 | 0.530339 | 0.550085 |
| 64 | 0.585995 | 0.751940 |

## Preserved failures and remaining art work

Earlier candidates/logs remain locally in build/issue283-reference and
issue283-native-01 through -12. The initial export used the reserved ZScript
parameter name `action`; the native-state reader initially attempted Name to
StateLabel conversion. Both compile failures were corrected before passing runs.
The first fixture pinned shield data instead of equipping a real inventory item;
the passing scenario equips native sword/shield through production APIs.

A visual-fixture EventHandlers regex read past a semicolon-free line and tried to
register dialogues/runtime.usdf as an event handler (native-07 fatal dialog,
inspected with Computer Use). Removing the Journal handler then broke its live-menu
consumer (native-09). The final fixture retains Journal and moves its camera below
the rest panel. Neither experiment changes production HUD behavior.

Art revisions corrected repeated face UVs, the IK knee pole, seat support and cape
fold. Native furniture offsets are unchanged. The source contains candidate
40-tic sit/stand and lie/get-up clips, derived as workbench samples from Raise;
they do not match the subsequently approved durations and are not connected
gameplay transitions. Provision consumption must retain its current rate/quantity. Crouch is an
explicit existing-appearance fallback. Exported bounds expose small transient
death/raise floor intersections, so those remain art polish rather than being
silently described as passed visual acceptance. Hidden-view/proportion feedback,
transition design and the requested modular integration remain pending.
