# Issue #283 - Domingo 3D pilot evidence (5.4.23, draft)

The default player is unchanged. This opt-in pilot uses the author-supplied
Domingo materials, a CC0 human head, an editable Blender mesh/UV/26-bone rig with 15 actions,
and deterministic native MD3 registration. The author provisionally accepted
the head-grip-02 presentation on 2026-10-15 (CA283-01); fine polish is deferred.
The overall issue is not complete. Earlier pending labels below describe each
evidence stage before this qualified acceptance.
The runtime appearance is fixed; the author now requires interchangeable parts
for weapon, shield, armor, hair and face, demonstrated first on Domingo. This
intermediate export does not satisfy that requirement. Approved chair transitions
(2 seconds), lie/get-up (3 seconds) and eating/drinking (4 seconds) with action
locks remain to be implemented. Native rest still changes pose immediately. Minor floor/cloth polish and unsupported-variant coverage are
recorded in TASKS and DESIGN.json. No issue closure or merge is requested.
Initial author review reported sideways knee flexion and rigid elbows while
walking, and requested a shield-block animation. These findings remain open;
the successful technical assertions do not establish visual acceptance.

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

## Artifact and reproduction

- Editable source: `assets/source/art/domingo_3d_pilot/domingo.blend`; its packed
  skin preserves source RGB. Source/provenance and deferred questions: DESIGN.json.
- Pinned tool: Blender 4.5.3 LTS, official build 67807e1800cc. See DESIGN.json for
  the archive fingerprint and ASSETS for the export command. The committed blend is the art input;
  its initial authoring transcript is not a deterministic blend-file generator.
- Current export: one surface, 10,629 UV-split vertices, 17,339 triangles, 195 frames,
  16,885,544 MD3 bytes; 1254 x 1254 skin, 1,863,217 PNG bytes.
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
  viewpoints. Q exits a rest panel before another fixture shortcut. CA283-01 is
  only a prototype review; CA282-01 is independently accepted.

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
