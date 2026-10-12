# 5.2.18 / #209 - Modular poses, rest and female hands

The author requested repairs after observing facial outlines, missing running,
head/body detachment, rolled sleep/death art, incorrect rest perspective/height,
F cancelling seated food actions, a flat table canteen and a rear punch that
dragged trousers. Clarifications: supine sleep; Domingo pose/anatomy references
except his rear attack; distinct female first-person hand anatomy. Built-in
imagegen sources/prompts and retained candidates are in
`assets/source/art/appearance_5218/PROVENANCE.json`. Python technical processing
was explicitly authorized. No Doom artwork was copied into game resources.

## Implementation

- 33 semantic body poses preserve all old indices and native player action
  timings. Four run phases, four punch phases, buckling/kneeling/fallen death
  and eight-view supine sleep replace the affected rigged poses. Complete
  punch body paintings avoid dragging trousers through an arm cutout.
- Common grounding/neck registration and head WorldOffset following preserve
  attachment. Low-alpha cleanup removes source fringes after resampling.
  Supine depth/head projection is registered per native world view; no main
  camera determines actor art or world heading.
- Furniture support is derived from model surfaces and character scale, with
  no physical-capsule or balance change. Old active rests recompute their own
  offset from OriginalWorldOffset and restore it on exit; no save field added.
- Contextual F/G/T precede generic movement/action cancellation. Journal and
  time-skip remaps retain priority. F toggles automatic eating; it does not
  deposit inventory. The existing table transfer interaction is unchanged.
- 37 hand variants preserve the original 18 male bare variants and add 18
  female skin/fur variants plus female gloves. Actual equipment selects gloves.
  Existing male gloves and weapon art, grip pivots, action/cost clocks remain.
- The table canteen has a new original beveled solid OBJ mesh with cap/strap,
  using the owned icon texture and existing display scale/inventory identity.

## Native evidence

Baseline `fca87921`, GZDoom 4.14.2 on Windows 11/Vulkan, VSync, isolated 960x540
configs, RNG seed 209, background simulation unpaused and audio 5%. The real
`build/gzdoom.ini` was not edited. `runs.json` records engine/runtime/fixture
hashes and scoped keep-awake release. A separate temporary keep-awake helper
covers preparation and visual work; its release record is retained.
Retained logs normalize installation paths, LF and trailing whitespace; raw
and retained hashes are recorded separately. No diagnostic lines are omitted.

| Run | Result and boundary |
| --- | --- |
| baseline-visual-04 | Expected regression: chair rest begins but head offset remains 0 while body moves 16 units. |
| current-offset-01 | The same native chair offset assertion passes after WorldOffset following. |
| native-motion-01 | Actual +forward/+speed visits 4/5/29/30; native PlayAttacking visits 9/31/10/32; lethal MAP99 damage visits 12/13/14/15. |
| contracts-final | 114 passes: body banks/hand variant lookup, run mapping, actual Menu.Key F/G/T with conflicting gameplay binds, rest/canteen identity and Q exit restoring (2,3,4). |
| remap-final | 4 passes: F bound to Journal retains that command's priority and exits rest, restoring the original offset. The reused exit assertion is labelled Q in the log; this run sends F. |
| support-01 | 64 passes: short/tall, both sexes, all four races; seat support matches model surface, humanoid head follows; deployed owned sleeping bag remains active. |
| hand-actual-02 | 15 passes: actual unarmed overlays 51/52 and selected variants for male/female human, female Caelith/wolf and equipped female gloves. |
| weapons-visual-01 | 3 native equipment assertions and captures: female sword/attack, shield block, shotgun bare/gloved. |
| save-old-02 / load-old-02 | Baseline seated save loads under the same package filename with new code; 14 passes for active rest, preserved original offset, repeated identical correction, head offset and canteen owner/3 liters; Q restores original. |
| load-current-01 | 14 passes loading the new seated save and repeating the same idempotency/exit checks. |
| bed-visual-02 / rest-visual-02 | Native captures of both human sexes in all eight supine directions, chair and solid canteen from multiple directions. |
| gallery-final | Native manual-pose gallery for movement/punch/fall/rest. A subsequent targeted rear-corpse neck correction is covered by the final capture recorded in runs.json. |
| capture-final | Final package: 102 passes for registry/run contracts, plus rear corpses and standing faces for both sexes of human, Caelith and goblin after the last neck-angle adjustment. |
| live-input-01 | Windows Computer Use activated the native window and physically sent F, G, clicked Eat and sent Q. Observed food ON/rest active; water ON/rest active; click food OFF/rest active; Q returned to gameplay. |

Logic/persistence tests precede the last rear-corpse registration adjustment;
their affected code is unchanged. Their per-run hashes remain separate from
the final package. Final packaging/equality and targeted capture are recorded
in `package-checks.json` and `runs.json`, not inferred from earlier hashes.
The older fall/rest overview is explicitly named before-rear-adjustment;
the six individual corpse captures document that final correction.

## Static and visual review

`check_assets.py --repeat` verifies every recorded module hash and referenced
PNG, 1,850 unique hand labels (50 per variant), triangle/quad-only OBJ faces,
and byte-identical regeneration. Published text fingerprints use canonical LF
so Git checkout normalization does not invalidate the report. Native state
audit confirmed the original 900 hand states retain their exact blocks.
World modules 2,288 + face/hair 3,072 + hands 770 remain shared; no complete
body/face/hair/color/weapon PNG product is generated. Five head anchor groups
per sex use 8,640 frames, below the engine's 16-bit frame limit.

Agent inspections cover front/profile/rear run and punch silhouettes, trousers,
head joints, real fall/rest poses, seat placement and canteen depth. Female
grip/fist/shotgun/shield images differ anatomically from male. Source images,
runtime registration, native screenshots and human artistic acceptance are
different evidence levels. On 2026-10-12 the author explicitly confirmed all
tests passed, accepting CA209-01 (world poses and furniture) and CA209-02
(female first-person hands), both originating in 5.2.18 / #209, without
qualifications. PR210 merge and #209 closure were authorized. The accepted
entries were removed from root pending_test.txt; the tested runtime is unchanged.
PROVENANCE.json preserves the source-selection status recorded before this
confirmation; this paragraph and HISTORY record subsequent author acceptance.
No multiplayer visual benchmark, every cosmetic combination, every ceiling or
every gl_spriteclip setting is claimed. The original clipping behavior is not
globally overridden. Material-specific glove wardrobes remain outside scope.

## Diagnostic corrections retained

Early fixture attempts exposed an invalid MAPINFO comma, multiline console
wait semantics, a gallery overwritten by the player Tick and a StaticEventHandler
lookup through the wrong handler API. A full loadgame path was incorrectly
combined with savedir; using the saved basename fixed that test invocation.
The earlier forced-hand gallery mixed a human overlay with a real wolf profile;
the actual-overlay test above corrects it. Initial OBJ n-gon caps did not render;
triangulation fixed the solid flask. Initial supine end views projected too much
vertical depth; low-camera projection and head rotation-before-projection fixed
that registration. Two generator writes encountered transient Windows file I/O
errors; a successful rerun and full repeat check replace that incomplete output.
Logs/candidates are retained; none of these attempts is counted as a passing
production test. The final rear corpse correction lowers the head with the body.

## Reproduce

Use Python3.12/Pillow11.3.0 for the four generators listed in ASSETS and the
asset check. Run `python assets/validation_5218/prepare_visuals.py`, then
`python assets/validation_5218/prepare.py` with no engine process active.
The latter builds separate baseline/production/fixture packages under build;
it never inserts MAP99 into src. Run `run_native.ps1 -Label <fresh-name>
-Script contract.cfg` (or the relevant retained cfg) with your installed engine
and IWAD paths. Each cfg is a single command chain because wait only delays
the rest of its own line. The native runner rejects reused labels and logs
compile/VM/assertion errors. Use `-Interactive -Script live.cfg` for physical
input; it is bounded and leaves the real launcher configuration untouched.
Save upgrade reproduction uses compatibility.pk3 with the baseline first and
current runtime second, preserving the filename saved in the game; pass only
the `.zds` basename to `-LoadGame` because savedir is already specified.

The official build remains `build_dev.ps1`; `validate_project.py` and document
index freshness checks are required. No engine executable, development IWAD,
PK3, generated test map or save is distributed with this evidence.
