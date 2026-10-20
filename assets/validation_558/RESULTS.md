# #369 / 5.5.8 bull model validation

## Current coat, brows and scale revision

The author requested the same head/body texture, more threatening brows or hair,
and a larger whole bull. On 2026-10-19 the author approved a uniform **1.5 visual
scale**, retaining existing physical collision and combat. The head/ears and
modeled brow/forehead locks now reuse a continuous brown coat patch from the
retained body albedo. Rounded tapered locks preserve visible irises/pupils.
The model has 10,580 triangles, 9,273 UV-split vertices, 136 samples, 23 bones
and one 2048-square atlas. The exporter scales geometry and visual walk/run
stride together (39/78 MU); native animation timing and movement are unchanged.
Render bounds are 65/92 and refresh through the existing load hook. Physical
radius/height/mass remain 15.6/51.8/900, intentionally smaller than the artwork.

Current verification: `collect_coat.py`, `report-coat.json`, `evidence-coat/`.
The frozen ordinary package SHA256 is `2c78110b858a6192e34c067ed74232178885dc8526617500e2499a6d9e99612a`.
Both pinned Blender exports match byte for byte. Only MD3, skin, generated
visual stride/bounds and the provenance notice differ from candidate c3519ea4.
All other packaged bytes, including combat and helper lifecycle logic, match.
Project validation and normal build pass. Native checks completed 2026-10-20.

Six final runs pass 46 newly logged checks: front/angle/full-body inspection,
all pose transitions and stopped gait, prior candidate save loading, MAP01
encounter, 512 peaceful bulls and the MAP01 performance reference. The 181-tic
combat trace equals the original baseline apart from the sprite registration
index. The population remains alive=512, census=513, high-density=1. Read-only
review found no source blocker; author acceptance CA369-01 remains pending.

| Condition | tics/s | Render-callback mean / p95 / p99 / maximum (ms) |
| --- | ---: | --- |
| 512 peaceful bulls | 34.99 | 16.67 / 17.77 / 18.21 / 18.93 |
| MAP01 fixed spawn | 35.00 | 16.67 / 18.08 / 18.95 / 20.55 |

Same recorded environment/method as the historical sections below; single
windows are not statistical performance claims. Application presentation remains
unmeasured after the earlier ETW denial; callbacks do not establish display FPS.
No retired stress case was run.

Retained iteration evidence: coat01 projected UVs across body-atlas seams and
used angular locks; coat02 uses a continuous coat patch and rounded locks.
An early shell invocation was blocked by local script policy; the normal
launcher invocation completed the build. coat-final02 is an earlier appearance
check before the provenance notice update. final03/04/05 each exposed the same
initial idle fixture failure. Clearing charge/target did not solve it and that
hypothesis was rejected. diagnostic06/07 showed queued setup/assertion events:
the helper held its tic-16 pose at the tic-17 assertion; a direct UpdateVisual
selected idle, but that diagnostic call is excluded from native pass counts.
The final08 fixture gates the idle assertion in WorldTick and defers the next
pose. It records setup=17, helper=18, check=19 and passes without forced updates.
CA-KP-139 records the reusable lesson. Failed and diagnostic logs are retained
separately; this required no production behavior change.

`preview.ps1` opens the final08 inspection room immediately and keeps the terminal.
F1 resets, F10 shows the face and F11 shows the whole body. Other pose/toggle
controls remain listed in the terminal. Close GZDoom to open MAP01 from its menu.
The earlier reports below are historical candidates, not current art acceptance.

## Facial revision at commit c3519ea4 (historical)

The author requested a more symmetric head, defined eyes rather than black
points, and a more bovine muzzle. This follow-up remains in #369 / PR #373 and
version 5.5.8, with CA369-01 pending. The current editable source has centered
facial geometry, paired ears/horns, contoured eyelids, brown irises, horizontal
pupils, a broad muzzle with recessed lateral nostrils and lips, and a softened
neck join. A 2048-square atlas retains the brown/ivory palette and provides
soft bilateral shape/cavity shading for the face under native sector lighting.
The runtime mesh has 9,108 triangles, 7,381 UV-split vertices and 136 samples.
The 23-bone rig and existing action keyframes/sample timing remain intact.

`report-face.json` and `evidence-face/` are the current evidence; `collect_face.py`
verifies the final package/source, repeat export, native logs and unchanged
combat bytes. The final ordinary runtime SHA256 is
`b80b2c82daf7fd32f8c83d88eb4fa6cd3538c1a9c757b9dbab87815379f531f7`.
Two frozen-source exports match byte for byte. Source inspection measures a
maximum mirrored facial surface deviation of 0.000187 source units (about
0.016 map units, at the MD3 positional quantization scale). This measures the
new face, not the deliberately retained original body's asymmetry.

Six final native runs pass 46 new checks: close frontal/angled appearance,
poses, a prior candidate's live/dead/archived/tutorial save, the actual MAP01
encounter, 512 peaceful bulls and a fixed MAP01 performance reference. The
181-tic encounter trace still matches the pre-model baseline except for the
numeric sprite registration index. The only executable follow-up changes
refresh the non-colliding helpers' saved render bounds during the existing
typed load census (44 radius / 61 height); actual bull collision stays
15.6 / 51.8, mass 900. No combat code, state timing or save schema changes.
Project validation, normal build and read-only independent review pass.
Earlier lifecycle/rollback evidence below remains applicable to the unchanged
ownership/teardown logic; its screenshots are not current visual evidence.

Same environment/method as below, single ten-second windows, no statistical
speedup or display-FPS claim:

| Condition | tics/s | Render-callback mean / p95 / p99 / maximum (ms) |
| --- | ---: | --- |
| 512 peaceful bulls, revised face | 34.99 | 16.67 / 17.88 / 18.81 / 19.63 |
| MAP01 fixed spawn, revised face | 34.99 | 16.67 / 18.30 / 18.57 / 19.07 |

The population still reports 512 surviving bulls, census 513, high-density=1.
The earlier sprite baseline and first model comparison below are retained for
context; no retired stress case was repeated. Presentation remains unmeasured
because of the recorded same-session ETW denial.

The final art is `build/issue369-face06`, exported twice in face-export03/04 and
frozen in `build/issue369-face-final02`. Earlier face01/02 cut-and-cap drafts
produced a poor neck seam; face03 exposed part of the retained muzzle. The
final source nests that old volume inside the replacement, blends the neck
and bakes readable facial shading. Superseded drafts remain local evidence.

`preview.ps1` now opens the inspection room immediately and leaves its terminal
open. F1 resets, F10 returns to the close frontal view, and F2-F9 retain their
listed functions. Close the game to select MAP01 from the terminal menu.
Author acceptance of symmetry, eyes, muzzle and motion is still required.

## Initial candidate at commit 885fe498 (historical)

The remaining inventory, hashes, captures and `report.json` describe the first
candidate. Its `verify.py`/`collect.py` reproduce that frozen source revision;
use `collect_coat.py` to validate the current follow-up.

The author supplied the GLB and approved local forehead/horn reconstruction
on 2026-10-19. The original source and both embedded images are retained.
Image 1 is metallic/roughness, not a normal map. The editable Blender source
has 23 bones and 12 actions. The installed MD3 has one surface, 6,000 triangles,
4,983 UV-split vertices and 136 samples; native death reaches the corpse at tic 25.

**Static and export:** project validation and normal packaging pass. The final
ordinary package contains exactly the current `src/` bytes. After removing only
the new presentation calls/fields, both native bull implementations match the
baseline byte for byte after newline normalization. Existing damage, speed,
mass, collision, AI, resources, state ordering and tic durations remain intact.
Two exports from the frozen Blender 4.5.3 source match in every output byte.
`verify.py` checks these claims and the explicit packaged-file allowlist.
Read-only independent review found no remaining blocker.

**Native:** 18 retained Windows GZDoom 4.14.2 runs, 147 newly logged PASS lines,
zero failed checks in that inventory. Sixteen runs use the final fixtures;
two baseline runs supply the old save and original MAP01 trace. Loaded save
counters are cumulative, so the total counts PASS lines, not DONE counters.
The final ordinary runtime SHA256 is
`4205d286abf7078c5b20d1b33f83377a87fafa2bb9464871dd4ff7ff14496931`.
The MD3 SHA256 is
`8bd61cf23abfe68b66df0b9fa98500882b106edd3fd048c7bac7f537ad57a9f3`.
See `report.json` for each run, input hashes, raw logs and captures.

- All twelve presentation actions are checked, including actual MAP01 tutorial
  preparation and charge. The 181-tic encounter trace matches the previous
  runtime in every field except the numeric sprite registration index.
- Ordinary live/dead, archived and tutorial idle/grace bodies survive old-save
  upgrade, current reload and documented rollback. Input save hashes are recorded
  for final load runs. Reload checks do not overwrite their input saves.
- Hub return works in both current and previous runtimes. Both final map
  snapshots contain zero model helpers after exit. Disabling `ca_bull_3d`
  restores original sprites and clears the registry; SYSTEMS documents rollback.
- Archived corpse Recall reconstructs the local model. Redemption hide/place
  mirrors visibility. The tutorial corpse mirrors native fading and destroys
  both owner and helper. Helpers retain no collision or gameplay decisions.
- Stopped walking holds its mesh sample: two native captures show zero changed
  pixels in the 400x205 bull rectangle (82,000 pixels). Distance-driven gaits
  use 35-Hz samples to avoid time interpolation advancing stationary feet;
  breathing, preparation, pain and death retain native interpolation.

**Failed attempts are retained separately:** unavailable production state accessor,
unqualified fixture sprite lookup, fixture death before deferred PostBeginPlay,
and early gore sampling/invalid fixture target. The gore test also exposed a
presentation priority problem, now fixed. A production hub defect required a
transition gate: WorldUnloaded alone still allowed a final tic to recreate
helpers before SnapshotLevel. The old-runtime failure log remains in evidence;
CA-KP-138 documents the native ordering. Earlier geometry/bake/rig drafts remain
under `build/issue369-clean*` and `build/issue369-rig*`; only the reviewed final
editable art is a maintained source. Failed attempts are not counted as passing.

**Performance:** Windows 11, Ryzen 9 5950X / RTX 3070 Ti, Vulkan, 1280x720,
60-frame cap, one engine at a time, background unpaused, 5% audio. Each sample
has 70 warm-up tics and a 350-tic window; one sample per condition, no statistical
speedup claim. The peaceful 512-bull fixture retains all living bodies, including
offscreen bodies. Both versions report census=513 and high_density=1, preserving
the shared >=500 policy. No retired 6,000-attacker scenario was run.

| Condition | tics/s | Render-callback mean / p95 / p99 / maximum (ms) |
| --- | ---: | --- |
| 512 peaceful bulls, sprites | 34.99 | 16.67 / 20.94 / 22.53 / 24.84 |
| 512 peaceful bulls, models | 35.05 | 16.67 / 19.13 / 19.88 / 20.11 |
| MAP01 fixed spawn, sprites | 35.00 | 16.67 / 18.58 / 19.08 / 19.58 |
| MAP01 fixed spawn, models | 35.04 | 16.67 / 17.94 / 18.44 / 19.52 |

Application presentation remains **unmeasured**: earlier same-session PresentMon
ETW access was denied (linked raw evidence in report.json); it was not retried
or elevated. Render callbacks do not establish display FPS. These fixed views
and simulation measurements do not approve full campaign rendering, city/siege
costs or 60-FPS mansion/sewer traversal. Earlier mansion/sewer reference evidence
remains in validation_556; it is not relabelled as a new model measurement.

**Author handoff:** CA369-01 remains pending. Run `preview.ps1` from this folder
in a retained PowerShell terminal. Option 1 opens the visual room; option 2
opens the authored MAP01 encounter. F1 resets the room, F2/F3 walk/run, F4
prepares, F5 gores, F6 shows pain, F7 rests, F8 kills, F9 toggles sprites/model.
In MAP01, F5 starts the native encounter and F8 allows inspecting its corpse
fade. The fixture player is invulnerable. Normal movement permits all-angle
inspection; each room gait demonstration stops after two animation durations.
Close the game to return to the terminal. Neither agent tests nor this preview
claim author approval of the cleaned surface, motion or gameplay appearance.

Reproduction: run `prepare.py --directory <fresh-name> --runtime <frozen-pk3>`
(add `--baseline-probe` for 5.5.7), then `run_native.ps1` with the corresponding
script/map/save. `collect.py` checks the recorded inventory and copies only
logs, hashes and owned captures; no engine, IWAD, fixture PK3 or save ships.
