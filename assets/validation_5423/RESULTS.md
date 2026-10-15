# Issue #283 - Domingo 3D pilot evidence (5.4.23, draft)

The default player is unchanged. This opt-in pilot uses the author-supplied
original Domingo sheet, an editable Blender mesh/UV/26-bone rig with 15 actions,
and deterministic native MD3 registration. It is not author-approved or complete.
The runtime appearance is fixed; the author now requires interchangeable parts
for weapon, shield, armor, hair and face, demonstrated first on Domingo. This
intermediate export does not satisfy that requirement. Approved chair transitions
(2 seconds), lie/get-up (3 seconds) and eating/drinking (4 seconds) with action
locks remain to be implemented. Native rest still changes pose immediately. Minor floor/cloth polish and unsupported-variant coverage are
recorded in TASKS and DESIGN.json. No issue closure or merge is requested.
Initial author review reported sideways knee flexion and rigid elbows while
walking, and requested a shield-block animation. These findings remain open;
the successful technical assertions do not establish visual acceptance.

## Artifact and reproduction

- Editable source: `assets/source/art/domingo_3d_pilot/domingo.blend`; its packed
  skin preserves source RGB. Source/provenance and deferred questions: DESIGN.json.
- Pinned tool: Blender 4.5.3 LTS, official build 67807e1800cc. See DESIGN.json for
  the archive fingerprint and ASSETS for the export command. The committed blend is the art input;
  its initial authoring transcript is not a deterministic blend-file generator.
- Export: one surface, 5,516 UV-split vertices, 7,232 triangles, 195 frames,
  8,747,076 MD3 bytes; 1254 x 1254 skin, 1,863,217 PNG bytes.
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
  only a prototype review; CA282-01 remains independently pending.

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

`issue283-final-15` is the final isolated build. Its native capture files remain
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
run/death/raise floor intersections, so those remain art polish rather than being
silently described as passed visual acceptance. Hidden-view/proportion feedback,
transition design and the requested modular integration remain pending.
