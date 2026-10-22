# 5.7.5 - Marine imports and iodine (#407)

Dried cachiyuyo imports and the abstract iodine recipe use the approved data
in `assets/generators/marine_resources.json`. Material IDs 87/88 and recipe 168
append without renumbering prior content. No coastline or downstream iodine
benefit is introduced. Two owned 3D models reuse existing owned textures.

**Static validation passes; 263 native assertions pass in 22 selected current
runs, plus 19 in three baseline/rollback runs; zero selected failures.**
CA407-01 remains pending author confirmation. CONTEXT contains 2,495 words;
all release markers agree on 5.7.5. Two generations preserve seven output
hashes. The meshes have 316 and 169 faces.

The delivered package is `a316970fbb773925472db86f09859c4e7aa3f3c52f181938540276bc858d6763`.
All 16,464 packaged members match the final source bytes. The full functional
matrix used the separately recorded tested package. Delivery changes only
two diagnostic release strings from 5.7.4 to 5.7.5: the collector verifies
that exact byte replacement and equality of every other member. Contract
checks and physical Use were repeated on the delivered package.

The visible 15-second sample with both 3D drops recorded 899 render intervals:
mean 16.663 ms, p95 16.780 ms, p99 16.982 ms, worst 17.139 ms; approximately
60.014 render callbacks/s and 35.005 simulation tics/s. These are scene-local
callback measurements, with the presentation limits described below.

`prepare.py` reuses the private #405 room geometry and unchanged #376 crafting
regression source. `run_final.ps1` runs the matrix and persistence checks, real
MAP03 commerce, visible model/menu captures, author controls, normal unpaused
task completion and a 15-second rendering sample. The runner prevents engine
overlap and keeps background simulation active at 5% audio.

The migration checks use an actual 5.7.4 package and retain original saves for
rollback. They preserve material slots, old recipe knowledge/practice, purchased
book quantities, vendor wallets and replenishment deadlines. Current saves and
hub travel preserve both new materials; old and new active tasks complete once.

Initial evidence is retained separately from final proof: one fixture referenced
an Actor sprite function without its class qualifier; another tried to preview
an unlearned recipe; the chest fixture omitted opening its native session. These
were test setup errors. Initial runtime valuation derived iodine's price from
its recipe instead of honoring the approved explicit value; the final economy
gives that authored value precedence. The author fixture also needed to close
the Journal after its setup preview before testing the physical Use key.

Generated packages, saves, private test maps and captures remain in build/issue407.
No engine, IWAD or generated test map is distributed. The report records capture
hashes; visible review confirms both dropped materials are volumetric at front
and side views. Inventory icons reuse owned art; no image generation service is used.

Rendering callback intervals and simulation throughput are separate evidence.
Application presentation/monitor/GPU timing is unavailable: Windows denied
PresentMon access during #470 in this environment. This small scene cannot
establish campaign-wide 60-FPS acceptance or claim a rendering improvement.

## Live recheck after terminal interruption - 2026-10-22

At the author's request, six new visible GZDoom 4.14.2 runs repeated the
contract, commerce, crafting, actual save/reload and ordinary unpaused task
completion: **80 PASS, zero FAIL**. `resume-report.json` records each run,
its configuration, package hash and raw log hash. All runs use the delivered
package identified above; no runtime source changed. A distinct save name
preserves the previous saves and full regression evidence.

A foreground Computer Use snapshot during the live completion run showed the
iodine crafting panel and its successful-processing message. The original
matrix still supplies old-save, rollback, hub, model and performance evidence;
this repeat adds no new frame-time claim or author acceptance. CA407-01 remains
pending. The existing `manual.ps1` launcher supplies the Spanish instructions
and prepared interactive scene for the author's review.
