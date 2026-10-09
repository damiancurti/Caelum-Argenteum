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
- Native hand subtextures place the right grip behind the stock while keeping
  the left support hand and the insertion hand/cartridges in front as appropriate.
  Original PNG bytes, old state indices, aimed carbine hands and action timing
  remain unchanged. Two foreground hand states are appended.
- Cartridge world artwork shrinks from 37.5 cm to the 6 cm reference explicitly
  approved by the author on 2026-10-09. Editable data is in
  shotgun_517/PICKUP_LAYOUT.json. Native visual acceptance remains separate. Inventory icon,
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
| `visual-fixed-a` | Ready, aim, recoil, opening, insertion and completion captures; right grip behind stock, support hand retained, loading remains foreground |
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
beside the now much smaller shell cluster. Whether the 6 cm art is sufficiently
easy to spot is an author visual check, not a mechanical claim.

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

CA152-01 (pickup/size), CA152-02 (grip overlap) and CA152-03 (held aim), all
originating in 5.1.9 / #152, remain in pending_test.txt. Technical verification
does not imply author approval or authorize this new issue's merge/closure.
