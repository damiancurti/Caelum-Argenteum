# 5.1.8 / issue #137 validation

Native engine: GZDoom 4.14.2, Windows 11, Vulkan, 1280x720 window,
60 FPS cap, VSync disabled. Ryzen 9 5950X, RTX 3070 Ti. Every launch uses
an isolated INI, 5% master audio and unpaused background simulation. The
individual `*-run.json` files retain engine/package/addon hashes, arguments,
settings, timestamps, process identity and clean exit status. These are native
engine observations, not author aesthetic acceptance.
Tracked log/INI copies normalize trailing whitespace and encoding only
(`TEXT_NORMALIZATION.json`); the original native files remain in build/issue137.

Baseline: main commit `126ceabe9841ce45090193dab28d85f7dad1b5dd` (5.1.7).
Only the project-owned test room is used. Development IWAD, engine, test PK3s
and saves remain local under `build/issue137`; none is included in this patch.

## Source audit and affected consumers

| Stage / consumer | Observed baseline | Delivery |
| --- | --- | --- |
| Player staff, bell, book, statuette; T1-T3, primary/secondary, charged/unmodified | Static flight frames; existing charged, homing, multishot and explosive routes | Four-phase fire/light, water/ice, earth/poison, air/lightning and quintessence materials; native light and finite trails; existing release timing and gameplay retained |
| NPC simple/explosive elemental projectiles | Cached sprite selection was overwritten by the looping spawn state | Shared per-tic presentation, including the real freed Federal prisoner's electric attack |
| Electricity | Small NPC streak and different player sprite | Same animated, flight-aligned three-plane travelling ray for all eight projectile variants; visual length extends behind collision origin |
| Burn, poison, freeze, lightning stun/impact | Hard rectangular boundaries and fixed presentation | Open silhouettes scaled to owner height/width; real status expiry/death/removal governs cleanup |
| Mandinga / Zupay breath | Vertical flame columns | Animated directional cone segments attached to the existing mouth, direction and visibility samples; no second heat/contact calculation |
| Existing mine burst | Static fire frame | Shared animated fire/light; original explosion and twenty-tic lifetime |
| Arrow, bolt, bullet, pellet, javelin flight | Flat sprites | Original low-poly models; native momentum pitch; existing impact, javelin breakage and recovery unchanged |
| Player damage / Health / Lucidity | Doom absolute damage-point flash; understated Lucidity bands | Actual post-defense positive Health fraction, approved colors, peripheral Health thresholds and animated Lucidity feedback |

Other existing cast poses, environmental pressure/teleport glyphs and abilities
retain their existing art and rules. Physical impact still has the pre-existing
development puff dependency; new atlases/meshes themselves contain no Doom art.

## Native checks

| Run | Result / coverage |
| --- | --- |
| `checks-cells-final` | 14 assertions, zero failures: proportional hits, native Doom counter cleared, burn/poison context restored, prevented damage, overlapping statuses, moving/dead owner, real wall impact, one impact emitter, bounded expiry, actual freed Federal attack uses staff ray, fatal overkill counts only remaining positive Health |
| `invariance-before-a` / `invariance-cells-final` | Baseline 263 assertions; current 1499 assertions. 240 player combinations, 18 NPC elemental cases and five physical types launch 623 projectiles. Trace comparison covers class/count, prepared damage/critical/payload, size, range, position and velocity. New frames and native registrations are also checked. |
| `gallery-before-final-c` / `gallery-cells-final` | All nine families in side/outgoing/incoming views at two times; bright/dark flight; four simultaneous statuses on moving bodies; bright/dark status scenes |
| `sizes-before-final` / final gallery varied-sizes | Rat, bull, Zupay and Mandinga show the appropriate body scaling. Elevated camera exposes the small rat above the HUD. |
| `showcase-before-final` / `showcase-cells-final` | Five physical models, both demon breaths, five approved damage palettes, 2.5%/25% hits, Health 49%/9%, Lucidity 49%/9%, combined feedback, rising/apex/falling javelin |
| `water-cells-final` | Real swimmable 3D floor; player and all nine elemental projectiles report native WaterLevel 3; no VM error |
| `persist-before-b` / `persist-upgrade-final` | Save created by baseline with live ice projectile, arrow and four attached states; current engine loads it, continues timers/positions and saves the upgraded copy |
| `persist-hub-final` | Loads upgraded copy, goes to CA137B, reopens CA137; exactly four states, no duplicates, continued timers/positions |
| `persist-rollback-final` | Original untouched save still loads with original package; rollback pair remains usable |
| `cost-*` / `battle-*` | Bounded cleanup and the automatic 500-living-combatant cosmetic mode; see measurements below |

The physical inspection models are deliberately slowed **only in the showcase
fixture**. Full-speed data are checked in the invariance fixture; the javelin
flight uses its native ballistic path. None of these fixture overrides ships
in `src`. Persistence tests precede the final atlas-only cell correction and
fatal-flash cap; neither change alters classes, state order, save data or travel.
The final compile/behavior run includes both corrections.

## Incremental cost

`MEASUREMENTS.json` retains the compared native `bench` fields and sampled
process CPU/wall intervals. These are single native-render snapshots and short
process samples, with background presentation and a 60 FPS cap. They are not
PresentMon presented-FPS traces, percentile measurements or a MAP06 fluency claim.
Native `Finish` includes substantial frame limiting/presentation wait.

| Scene | Native Render ms before / after | Native FPS snapshot before / after | Process CPU s / sample wall s, before | After |
| --- | --- | --- | --- | --- |
| Single source | 0.058 / 0.030 | 60 / 60 | 1.422 / 9.118 | 2.266 / 10.087 |
| 24 passive NPCs | 0.103 / 0.124 | 60 / 60 | 1.922 / 10.142 | 1.406 / 10.111 |
| 500 living, synthetic effects | 0.238 / 0.629 | 60 / 60 | 2.453 / 10.104 | 2.516 / 10.080 |
| 500 living, native battle | 0.195 / 0.231 | 33 / 35 | 7.422 / 11.118 | 7.391 / 11.143 |

The synthetic scene separates visual overhead with 0, 24 or 499 passive NPCs
and respectively 1, 8 or 24 projectile emissions per batch. The separate battle
uses 499 ordinary Mandingas plus the player, actual attack/resource/AI paths,
and no synthetic projectile emitter. At measurement start the native population
service reports exactly 500 living combatants and dense mode enabled. An
invulnerable observer makes the comparison reproducible. Cleanup is verified
after the measurement, not used to improve the measured interval.

More light/geometry can add render cost, especially with many simultaneous
effects. The evidence is an overhead measurement, not a claimed optimization.
Gameplay resources, targeting, physics and combat remain individual.

## Art registration and evidence interpretation

Original PNGs and prompts are in `assets/source/art/elemental_518`; original
pixels are copied unchanged. `DESIGN.json` records measured cell boundaries.
The generated sheet is **not** a uniform grid: initial equal-row clips cut the
ice tip and admitted fragments of earth. `gallery-after-final-b` and earlier
art captures are superseded by `gallery-cells-final`, which uses those measured
gaps for native TEXTURES and model UVs. The corrected native ice frame is whole
and contains no adjacent earth fragment. Two full optional-generator runs are
byte-identical (`DETERMINISM.json`).

Selected original native PNGs are preserved under `captures/`, with hashes and
run/package association in `CAPTURES.json`. `GALLERY.html` provides before/after
inspection without raster editing. Additional raw captures remain local. Source
art, native checks and author preference are separate evidence levels.
`flight-video-before/after.mp4` show actual flight for all nine families in side,
outgoing and incoming views. Each contains 324 native screenshots sampled every
two game tics and encoded at 17.5 FPS without audio. `VIDEOS.json` retains source
frame and video hashes. Both streams pass full decode. These are motion evidence,
not presented-FPS captures or replacements for the separate cost measurements.

Rejected attempts are retained locally: early compilation/fixture errors;
initial +Z-forward meshes (wrong native pitch axis); absolute `-loadgame` paths
that doubled the save directory; too-short load/transition delays; a captive
Federal fixture that correctly would not attack; post-destruction impact
emission; and a console command line exceeding the parser buffer after labels
were added. Corrected runs use explicit native frame registration, +X-forward
meshes, save basenames, adequate load delays, the real released-prisoner state,
native Death-entry impact actions and bounded command chunks. A passing marker
never overrides a crash, VM error, unknown command or nonzero engine exit.

## Acceptance and remaining checks

CA137-01 and CA137-02 in root `pending_test.txt` require the author's visual
review. Technical passes do not mark them accepted. CA137-03 covers the author's
later report of clipped Domingo/giant-rat deaths. The existing PNGs themselves
already contained truncated body parts/neighbor fragments; the located old
graphics archive has identical damaged Domingo PNG hashes. New eight-pose atlases
were reconstructed with image_gen from project-owned references, retaining the
old files. `deathframes-before/after` inspects all sixteen native frames and the
uninterrupted production Death sequences. The rat is enlarged in individual
inspection frames only; the actual corpse view retains scale 0.11. Measured
transparent seams, constant scale and per-frame ground anchors are registered
by `register_death_frames.py`. No Death state, sound, action or duration changed.
These initial reconstructions have since been superseded by the author's original
sheets as described below; their evidence and assets remain intact.

Temporary keep-awake uses thread-scoped execution-state flags, never a changed
power plan. Its release record is retained with the completed delivery.

## Initial delivery gates

The normal `build_dev.ps1` creates a 6,276-file PK3 with no directory entries.
`release-checks` passes all fourteen assertions against that exact deliverable;
`release-save` loads the baseline save, preserves its four states and saves an
upgraded copy. Their package hashes identify the normal build, separate from
the deterministic fixture packager. All five generators were then run twice:
35 runtime outputs are byte-identical to each other and to the tested PK3.
The final project validator reports no errors and 2,498 CONTEXT words;
`git diff --check` passes. `DELIVERY.json` binds these gates to the final package.

## Original-sheet recovery and complete animal audit (2026-10-09)

The author supplied Domingo, rat and bull sheets from the same local source
folder and explicitly approved deterministic cropping/background removal.
Domingo uses its unchanged 1,254-square original sheet. Measured native clips
preserve all death-strip pixels with alpha >=16 exactly once; overlapping X/Y/Z
silhouettes use native subtextures. One 199/176 scale matches the original
standing drawing to existing DOIDA1. Eight original DOMI S-Z states retain timing.

The rat's seven original death drawings now occupy RATG F-M, repeating the final
corpse instead of inventing an eighth drawing or changing native duration.
Nine minor border cuts (B1/B5/C3/C4/C5/C6/C8/E1/E5) also use recovered source
pixels with their original source-relative anchors. The mask recovery preserves
existing valid alpha and source RGB, using seeded single-thread GrabCut only
where the old cuts lack pixels. All 118 bull images and 48 rat images were
inspected as alpha composites and native textures. No bull clipping was found.
Hidden labels/neighbor RGB in rat PNGs have alpha zero and do not render; the
earlier broader claim about those artifacts was a misleading preview.

`deathframes-original-final` records all sixteen individual death states plus
uninterrupted production sequences and final corpses. `animals-original-final`
renders every registered animal texture on contrasting backgrounds, including
all directional frames. Each texture fits its inspection cell independently;
this sheet does not compare world body sizes. Source/registration and alpha-composite inspections are
separate from native captures. Rat inspection poses are enlarged only in the
individual death fixture; its actual corpse keeps production scale 0.11.

Rejected iterations: `deathframes-original-a` had insufficient console settling
and skipped four frame selections; the fixture now holds each selection and
requires all sixteen before completion. Earlier baseline/reconstruction logs
already contained sixteen selections. The first rat rectangle-only segmentation
filled tail holes and altered dark fur, so the final extraction preserves/seeds
the known alpha. Early animal contact sheets were obscured by the HUD; a normal
EventHandler renders the final inspection after the gameplay HUD. These attempts
do not constitute final visual evidence.

`RECOVERY.json` binds source hashes, two repeated generator runs, runtime assets
and the normal final PK3. Updated static/native gates are in `DELIVERY.json`.
Temporary keep-awake release is recorded in `power-137-original.json` with no
power-plan change. CA137-01/02/03 remain pending author acceptance in PR #151.
