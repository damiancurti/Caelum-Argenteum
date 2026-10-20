# #369 / 5.5.8 bull model validation

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
