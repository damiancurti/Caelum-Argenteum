# 5.8.13 / #411 - Campfire and mounted pot

Author acceptance is pending: **CA411-FIRE-01**. The author is away. The author
terminal is prepared; these checks do not complete camp cooking or V5.8.

The selected runs and executed assertion count are in `report.json`; do not sum
RESULT lines because their counters survive saves. `native/` preserves the raw
logs and runtime/configuration hashes. Final delivery is `final05`; all 16,914
package members match source. Between the behavior-tested final03 and final05,
only eight flame-model files changed. Gameplay scripts, maps, localization and
other package members are byte-identical. New visual capture/performance runs
cover the final artwork. No development IWAD, executable, saved game or generated
fixture PK3 is shipped in the source delivery.

Native GZDoom4.14.2 checks cover permitted/blocked ground, occupied fire space,
one-minute work and cancellation, native network-menu dispatch, accelerated
attended work, 10kg capacity, exact fuel recovery including fractions, 1.92kg/h
burn, exhaustion, heat-source registration/removal, pot identity/capacity,
heating/60-second boiling, biological-only treatment, evaporation and cooling.
Save/load, restored unfinished tasks and hub return preserve fuel/ownership;
departure extinguishes. The unchanged tent suite adds40 PASS for the shared
camp-task and placement boundary. A genuine prior-runtime save from #502's
domestic-final02 preserves a13L contaminated pot on upgrade and on rollback to
that original runtime. Original saves remain separate and unmodified.

Agent visual inspection: final world/menu captures are in `captures/`. The iron
pot rests on the log pile; flame quads use the unchanged author-accepted #137
atlas around its sides. Painted inventory sprites are unchanged. Deterministic
generation reproduced the same manifest/model hashes. This is agent inspection,
not author art acceptance.

Rendering evidence: 1280x720 Vulkan, 60FPS cap, unpaused background at5% audio,
Ryzen9 5950X/RTX3070Ti. The fixed-source comparison uses the identical fixture.

| Scene | Callbacks /700 tics | p95 ms | p99 ms | Worst ms |
| --- | ---: | ---: | ---: | ---: |
| Prior runtime, fixed source |1199|16.9159|17.1525|18.5099|
| New runtime, same fixed source |1199|16.8864|17.0806|17.4348|
| Final burning campfire |1199|16.9229|17.2275|17.5298|

Each interval covers about20seconds, with100ms polling uncertainty on the phase
boundary. RenderOverlay intervals measure rendering callback cadence, not
displayed frames or GPU latency. These small peaceful scenes do not establish
60FPS for the mansion, sewer, city, combat armies or arbitrarily many campfires.
The thermal reader still evaluates each declared source individually; only its
old recurring global source census was replaced by lifecycle registration.

Resolved development findings: ZScript needs named enums and literal state-label
resolution; material recovery must merge the established stack. A test archive
was regenerated while a native hub run was open, causing `No map CFIR411` and a
timeout. The builder now refuses regeneration while GZDoom is running; the same
route then passed. An initial legacy-load command fired before the large mansion
finished initializing; a70-tic startup allowance executes and passes the check.
Those attempts remain under the issue's local build directory; they are not
included in the selected final pass count. See CA-KP-170.

Run `python assets/validation_5813/prepare.py` only with GZDoom closed, build a
fresh immutable runtime, then use `run_native.ps1` with the named scripts from
`prepare.py`. Legacy checks use `legacy-checks.pk3`; the previous complete
runtime is needed for the genuine save/rollback. `performance.py` accepts the
runtime directory and a new label; add `--camp` for the new rendered fire.

## Author-launch correction, 2026-10-26

The original exact manual script failed to seed and retained engine defaults. The corrected manual script queries all six intended bindings and seeds 20 kg wood plus the original filled pot.

Native startup evidence: `native/bindings-fixed-smoke-05.txt` and
`native/bindings-ready-live-06.txt`, with separate command/environment records.
The exact interactive entry reaches the readiness marker; the launcher now
waits for it and reports failure instead of silently handing off an unseeded
scene. The frozen gameplay package is unchanged. This startup evidence is
separate from the original gameplay assertion counts.

Remote desktop key injection did not reach GZDoom. Native binding queries and
scripted commands are agent evidence; physical-key author check CA411-FIRE-01
remains pending. No author pass is inferred from fixing the launcher.

## Integral trivet correction, 2026-10-26

Author approved the original functional checks, requesting a support beneath the
pot. Approved support: 32 cm ring, three 50 cm legs, 10 mm iron rod, 1.6 kg
including joints. Empty carried/recipe mass becomes 7.1 kg. Catalogue revision3
updates both pot and recipe prices idempotently, without replenishing sold stock
or resetting current production. The vessel retains its own 5.5 kg thermal mass.

Runtime trivet01 SHA256:
`d274e94ed25febbee3885c5b17b3c5833de35f88a76e33630e8c00e9655f600d`.
All 16,914 members match source. Pot checks16 PASS; catalogue3 PASS;
previous native pot save6 PASS; original-package rollback6 PASS; zero FAIL.
Capture initialization3 PASS is separate from these31 behavior assertions.
The ten regenerated meshes are byte-identical. Agent inspected the native
mounted-pot capture: pot supported above the wood, original owned textures.
Original functional acceptance is recorded; corrected visual/mass/recipe remain
for author corroboration. No map geometry or persisted pot fields changed.

Final author acceptance, 2026-10-26: CA411-FIRE-01 passed in full, including
the integral trivet, carried mass and recipe correction. The pending entry is
retired. No new native execution is claimed for this documentation-only update.
