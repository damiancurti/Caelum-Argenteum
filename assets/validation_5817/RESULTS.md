# #410 kitchen ingredients — 5.8.17

Five approved ingredients are integrated into Provisions, native gram stacks,
food lots and inventory. Raw beef, white fish and mixed vegetables can be eaten
in full 100 g portions through the journal and quick-use bar. Flour and salt
remain preparation ingredients. Cooking/proofing, four finished dishes and
remaining furniture are unfinished #410 work.

Runtime: `build/issue410-kitchen/current03/caelum_argenteum_dev.pk3`.
SHA256: `be54e94db05128edffa7df957e6405ce68739785f1d11ac80c745b463b1cb381`.
All 16,927 members match `src` exactly. Static validation passes with zero
errors, current indexes and a 2,497-word context. Native evidence: **174 newly executed
PASS / zero FAIL in 21 selected runs**, plus the paired digestion comparison.
Counts use actual executed log lines, not serialized cumulative counters.
**CA410-INGREDIENTS-01 passed author corroboration on 2026-10-26**, including
controls and painted sprites, without qualifications. The pending entry is
retired; no new native run is claimed for this acceptance-only update.

Coverage: exact grams, distinct nutrition, full-Hunger intake, Box and partial
portion rejection; native pickup/capped copy/toss/merge; coffer splits and hub
absence; oldest-first age and contamination; fresh commercial stock, actual
coin/stock purchase and contaminated-resale exclusion; additive/idempotent
catalogue; native journal actions; independent journey prediction; saved raw
items and generic clocks; original ration regression and old-save rollback.

The old-save seed uses the prior scenery package, SHA256
`55fd9270df6d696d22113496aa53fbc3d83fabb8f628fa34c2e6d35a28439ef2`.
The original save was loaded under the new package and again under its original
package; no user save was overwritten. Current01-to-current03 differences are
the final journal action, quick-use labels and localization only; the final
action/core/hub/save checks exercise current03. Earlier unaffected transfer,
clock, commerce, ration and timing evidence remains applicable.

Native Spanish/English captures were visually inspected. Five owned painted
sources, one retained unselected variant and exact imagegen prompts are stored
under `assets/art_source/cooking_ingredients`. Technical masking/cropping/resize
follows SPRITE_ART_DIRECTION. Two exports were byte-identical. Existing art and
map geometry are unchanged. The author reviewed the supplied terminal after
returning and accepted the ingredient check on 2026-10-26.

## Performance boundary

Same peaceful room, 500 native material stacks, one player, Vulkan 1280x720,
60 FPS cap, unpaused background, 5% audio, Ryzen 5950X/RTX3070Ti. The private
fixture hides stack sprites equally to isolate scheduling from overdraw.
Material ID 109 resolves to the prior catalogue's last material before this
patch and to raw beef afterward; food clocks therefore rise from 0 to 500.
Each package has 700 measured simulation tics and 1,199 frame callbacks.

| Package | Elapsed seconds | p95 callback ms | p99 ms | Worst ms |
| --- | ---: | ---: | ---: | ---: |
| Prior scenery | 20.046 | 16.9743 | 17.1968 | 17.6496 |
| Ingredient scheduling | 19.949 | 17.0481 | 17.2514 | 17.8219 |

Elapsed polling uncertainty is 100 ms. These callbacks are a rendering-cadence
proxy, not displayed-frame measurements or campaign-wide 60-FPS acceptance.
The final UI-only changes do not affect the timed fixture's food scheduling.
The additional global iteration is typed and load-only, owned by FoodWorld
for saved-item migration/rebinding. A native cold pass over 500 materials
initialized 500 clocks in **0.0859 ms**. Subsequent registration uses spawn/first
material update; one staggered clock belongs to each real stack. No recurring
global actor scan was added. Larger refrigerated inventories and complete
unloaded magical climate histories retain the limits documented in 5.8.14.

## Resolved probe findings

- The first saved-lot probe incorrectly demanded exactly 30 contamination after
  elapsed world time. The retained diagnostic shows 30.00020833 with the correct
  125 g. The corrected assertion permits that measured ageing interval.
- The extended fixture initially called protected TryPickup and dereferenced a
  vector return inline. It now uses native CallTryPickup and a local vector.
- Net Hunger includes natural regeneration/contamination-cleanup costs. A fresh
  matched control lost 0.30048254; the food run gained 5.36618413. Their difference
  is exactly the approved 5.66666667 points at the fixture's 100 kg body mass.
  No nutrition balance was changed to hide that distinction.
- The native journal originally routed materials to the Box. The new edible
  branch is covered by three native action checks; boxed retrieval stays intact.

Earlier failed probes remain in the private build directory. Selected raw logs,
run metadata, captures and `report.json` are retained here. Test PK3s, saves,
engine and development IWAD are not distributed.
