# 5.1.9 / #152 - Shotgun follow-up

The author's `Prueba` checkpoint reproduces an owned shotgun-ammunition actor
still linked to the world. Native baseline `saved-before-b` reports 1,081 shells
with Owner set and bSpecial=true, bNoSector=false and bNoBlockmap=false. The
895 carbine rounds already have the correct held state. This is an incomplete
native inventory transition, not a second collectible supply.

## Changes

- Distinct-ammunition creation uses AttachToOwner, including BecomeItem. Existing
  owned ammunition with invalid world flags is normalized once on Tick. Amount,
  owner, Box placement and native held-state indices remain intact; no new
  serialized inventory schema is introduced.
- Ranged alternate aim uses an independent transient press/release latch. Zoom
  retains its existing latch. Other secondary-action branches are unchanged.
- Ready/open poses use one full pair below the weapon; loading hands/cartridges
  stay foreground. The first foreground support-hand cut was rejected by the
  author as a duplicate and is now cleared. Revised brown gloves, narrow red cuffs
  and dark bracers use canonical Domingo references. Original assets, old state
  indices, unused foreground states, aimed carbine hands and timing are retained.
- Cartridge world artwork shrinks from 37.5 cm to the 6 cm reference explicitly
  approved by the author on 2026-10-09. Editable data is in
  shotgun_517/PICKUP_LAYOUT.json. CA152-01 was accepted on 2026-10-09. Inventory icon,
  ammunition mass/price/count and actor collision remain unchanged.

## Native evidence

GZDoom g4.14.2, Windows 11, Vulkan at 1280x720; installed author IWAD, no autoload,
one GZDoom process at a time. Each runner INI enables unpaused background
simulation/rendering and 5% master volume. Scripted +altattack/+zoom/+forward
commands enter the native input path. Test addons stay outside production.

| Run | Result |
| --- | --- |
| `saved-before-b` / `saved-fixed-a` | Original-save reproduction and repair; 1,081 shells / 895 bullets preserved; after the first corrected Tick both are held and absent from world links |
| `pickups-before` / `checks-fixed-a` | Baseline fails the held-state check; correction passes 9 checks: initial/stack pickup, native held flags, separate bullet counts, shared javelin path, capacity rejection and retry |
| `input-before-b` | Reproduces 212 aim transitions from two held alternate-fire presses plus two Zoom presses |
| `input-fixed-shotgun`, `input-fixed-carbine`, `input-fixed-longbow`, `input-fixed-crossbow` | Four expected transitions each, four assertions each, exit 0; each button held for 100 tics |
| `visual-fixed-a` | Initial pose captures; superseded for hands after the author rejected the duplicated support hand and costume mismatch |
| `world-fixed-b` | Actual forward movement collects 20 shells once, destroys source actor and retains a held-only stack; 3 checks pass, exit 0; native scale comparison captured |
| `save-upgrade` / `save-reload` | Original checkpoint loads, resaves and reloads with exact ammunition amounts and native Inventory.Held states; both exit 0 |
| `thermal-diagnostic` | Diagnosis on forecast copies only, described below; exit 0 |

PERSISTENCE.json binds the untouched original-save hash, upgraded-save hash and
serialized held states. Original checkpoint/package remain local for rollback;
`saved-before-b` proves their load. No user save is overwritten or distributed.
INPUTS.json pins baseline commit/package/save. DETERMINISM.json records identical
output from two final registration runs. DELIVERY.json binds the normal final
package and validation results. Raw packages and save files remain under build/.

The native world comparison shows the carbine-ammunition illustration unchanged
beside the now much smaller shell cluster. The author accepted pickup/size as
CA152-01 on 2026-10-09; technical and author evidence remain separate.

## Hand follow-up after author rejection

The author selected the rightmost left-hand silhouette, below the gun. Ready/open
poses now clear overlay 51 and draw the complete hand pair only on 49, below
weapon 50. Loading uses 51 alone; aimed canonical hands use 48/49. The two unused
foreground states remain defined so saved state indices do not move.

Built-in image_gen restyled the separate hand atlas from canonical FH05A0/FH06A0
references. The first draft made the forearms overly red; the selected iteration
restores dark bracers and narrow red wrist bands. Exact generated PNGs and both
prompts are retained in shotgun_517/HAND_STYLE_519.json. Runtime hands_domingo.png
is byte-identical to the selected output; all earlier source PNGs are retained.
The generated 1087x1446 canvas differs from the requested 1086x1448. Native old
row offsets and 362-pixel virtual canvases preserve registration without raster
resampling; the two missing bottom rows are transparent outside the source.

`hands-followup-a` exits 0 and records fourteen native captures: ready, aim,
recoil, empty opening, two-shell insertion, completion, one-shell insertion,
partial opening/insertion, T2/T3, carbine, return to shotgun and dagger. Layer
samples show one full hand pair in ready/open poses, foreground-only loading,
canonical aim and completed switch cleanup. Switching retains the lowering weapon
briefly; its intermediate samples are not described as persistent overlays.
HAND_CHECKS.json records the counts and comparison, with the images as visual
evidence. `hands-followup-save` loads the prior upgraded save, preserving 1,081
shells and 895 bullets, and exits 0. Both runs bind the final 6,294-file package;
all entries match src. Original saves remain untouched and are not distributed.

HANDS_DETERMINISM.json records two identical current registration runs; the
initial DETERMINISM.json and initial delivery fingerprint remain historical
evidence. DELIVERY.json holds the current fingerprint plus the initial delivery.
HANDS_NORMALIZATION.json records UTF-8/LF evidence-copy normalization; raw files
stay local. power-152-hands.json confirms the temporary request was released
and the active power plan did not change. Revised hands awaited author acceptance
at this delivery (now accepted below); pickup/input mechanics and deferred thermal rules were
not changed by this follow-up.

## Thermal findings, deliberately deferred

The checkpoint's body mass is 200 kg, carried mass 285.428 kg, total moved mass
485.428 kg. Native gravity resolves to 38.28125 m/s2. Positive stair ascent counts
that gravity and the whole rise, while the approved jump budget uses 0.5 m at
9.81 m/s2 regardless of the attribute-enhanced trajectory.

An 8.25 m vertical ascent therefore adds **459,924.068 J** (delta exposure 16.2923)
before horizontal locomotion work and concurrent exchange, versus **7,143.073 J**
(delta exposure 0.2530) for one accepted jump: a 64.3874 ratio. This is a native
formula diagnostic using the saved actor's parameters, not a measured stair
traversal or a physiological endorsement of either calibration.

Sweating already responds to positive exposure inside Normal. Isolated forecast
copies start at E=19.99, just below this character's Heat threshold of 20, with
3.711975 kg/hour sweat. Both dry-start and saved-wetness copies cool: at 300 world
seconds E=11.6621/6.7646, and at 1,800 seconds E=-1.7004/-1.8152. Hydration falls.
These integrations keep the saved environment and supply 30 world seconds / 0.5
real seconds per step; they are diagnostic forecasts, not elapsed live play.
The supplied save itself is E=-0.4818 with 97.816% clothing wetness, so it does
not capture the reported hot plateau. Exposure is an equivalent thermal state,
not literal core temperature or a target that must reach zero.

Beastfolk currently receive the furred-race comfort value but no separate fur
water reservoir/insulation layer. Isometric blocking/pushing already create heat
without net displacement; the author's proposed broader metabolic-power model,
jump treatment and fur coefficients remain pending design. No thermal runtime
file, action-energy value, threshold or cooling coefficient changed in this patch.

## Rejected diagnostic attempts

- `saved-before`: addon called protected TryPickup directly; compilation rejected.
  Corrected to public CallTryPickup; the owned failed process was stopped.
- `input-before`: StaticEventHandler tried character initialization before native
  profile setup; VM aborted. Initialization moved to tic 10 in the addon only.
- `world-fixed`: SetOrigin placed the pawn on a source but did not execute native
  movement/touch; two assertions failed. `world-fixed-b` instead walks across it
  with +forward and passes all three. The production code was unchanged between
  these attempts.

Initial runs without an exit-code recorder are qualified by complete logs and
captured markers; later runs record exit_code in their run JSON. A failed or
incomplete attempt is never substituted for a final pass.

## Author acceptance

On 2026-10-09 the author accepted CA152-01 (pickup/size) and CA152-03 (held aim),
both originating in 5.1.9 / #152, without qualifications. HISTORY records their
removal from pending_test.txt. CA152-02 (same origin, grip appearance) initially
FAILED for duplicated hands and costume mismatch. The author subsequently
confirmed the revised hands passed on 2026-10-09, without qualifications, and
requested #152 closure and PR #153 merge. CA152-02 is now PASSED and its entry
is removed, leaving pending_test.txt empty. Historical run snapshots retain the
review status at capture time; this explicit author confirmation is separate
from native verification. Acceptance changes no runtime files or package bytes.
