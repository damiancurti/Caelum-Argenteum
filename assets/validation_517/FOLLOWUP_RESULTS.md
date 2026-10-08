# #136 author-inspection follow-up (5.1.7)

The author reports hyperthermia despite entering the MAP01 pool and requests
smaller, muted shotgun gloves with aimed placement matching the other weapons.
Both author-supplied calor-136 checkpoints are copied locally before testing;
the first retains its matching original delivered package for rollback.
The agent never overwrites the author save; no save/IWAD/engine is
distributed. Original implementation evidence remains in RESULTS.md/MANIFEST.json;
FOLLOWUP_MANIFEST.json identifies the final follow-up sources and checks.

## Thermal diagnosis and final contract

The checkpoint is a 100 kg male human, 33.576 kg carried load, no equipped armor,
20 C Limbo air, 17.549125 C pool fallback temperature, 1092/2710 HP and exposure
+24.268683. Clothing is 99.785891% wet. Stored continuous activity is 6393.362475 W;
activity history is 462893.088391 J versus 5262.984741 J from discrete/firearm
actions. Actual preceding commands cannot be reconstructed from a snapshot.

The old model immediately held an activity peak and then decayed it with a
120-world-second half-life. One second at 5000 W could create approximately
865617 additional joules after the action. Native stationary shooting does not
reproduce this accumulation; brief movement/pushing/swimming reproduces the
failure mechanism. Immersion is detected and water removes heat, but the old
peak overwhelms that cooling. The pool is not ignoring the actor.

**Final author decision:** effort heats only while the action occurs. A proposed
conservative recovery filter was superseded by this explicit correction. Runtime
uses current power times real action duration, or the existing explicit logical
travel effort duration. No post-action heat is produced. Accumulated exposure
still exchanges heat normally; resting metabolism and shivering are unchanged.
Thermal revision 7 clears the obsolete activity peak once, preserving accumulated
exposure, damage fractions/history, hydration, moisture and pending measured work.
It does not heal a save or invent the missing historical command sequence.

The author then overwrites his own checkpoint after swimming with all twelve
attributes at 100. This second snapshot has E +95.462143 and ActivityWatts zero,
but its enhanced-jump reference is 350485.240927 J. The old swimming/pushing
proxy converts that to approximately 140194 W while acting. Removing the tail
alone therefore does not correct this separate active-effort amplification.
The approved replacement is **6 MET total for normal swimming, 10 MET for fast
swimming, and 6 MET for blocked pushing**. Each subtracts the existing 1 MET
resting contribution and scales by actual surface area at 58.2 W/m2/MET.
This 100 kg, 1.80 m body receives 637.260389 / 1147.068701 extra W, independent
of enhanced jumping. Actual Air consumption and movement rules are unchanged.

| Native run | Result and boundary |
| --- | --- |
| heat-baseline-a | Original checkpoint: E +24.268683 -> +37.364630 in 50 simulated seconds. Full native WaterLevel 3 is detected during seconds 10-30. |
| heat-delivery | Same checkpoint and sequence: E +24.268683 -> +19.465894. No additional activity joules while idle; underwater flux is negative. HP/exposure are preserved on load. |
| heat-motion-a | Original runtime, controlled 6-second input periods against a wall, swimming and leaving the pool: final E +13.821077, 364 cumulative thermal HP lost. |
| motion-delivery | Same controls and initial normalized state: final E -0.946539; cumulative thermal damage zero. Activity power becomes zero on release. 2696/2710 final HP includes contact/impact and regeneration, not thermal damage. |
| heat-fire-a / fire-delivery | Stationary shotgun fire/reload requests: 3690.430 action J, zero movement J, final E +0.070803, 2710 HP, zero thermal damage. |
| swim-normal-delivery / swim-high-delivery | Ten seconds normal swimming, ten fast, then rest in actual pool geometry: 637.260389 / 1147.068701 W with either normal or all-100 attributes. Final E +0.219241 / +0.219547; zero thermal damage and zero activity after release. |
| push-high-delivery | Ten seconds blocked pushing with each speed command, then rest: 637.260389 W in both, final E +0.352947, 51500 HP, zero thermal damage and zero activity after release. Normal-stat pushing is included in motion-delivery. |
| activity-delivery | 36 native assertions: one-tic/one-second exact heat, no post-action production, 1:1 and 20:1 clocks, personal/zero-world steps, approved swimming/pushing values, isolated logical travel, four racial comfort profiles x five materials, preserved migration fields and idempotence. These are service-level engine checks, not twenty played campaigns. |
| activity-reload-delivery | Mid-push save restores E -0.068114, activity 637.260389 W and 1820.744 activity J. The next idle update sets activity to zero without adding history. No normalization is applied. |
| calor-rollback-final | Untouched first save plus original 0dfa718e runtime restores E +24.268683, activity 6393.362475 W, 1092 HP and revision 6. |
| catalogue-followup | All 49 existing native shotgun mechanics assertions pass on the final runtime. |

The original-checkpoint flux observer replenishes HP below 500 to measure the
whole interval: twice in the old run and once in the corrected run. It never
changes exposure. Those runs are **not survival passes**. Movement controls reset
initial HP/exposure/history for comparison, retain wet clothing, and require no
subsequent HP rescue. Fire controls also begin dry; they require no rescue.
Dedicated swimming controls normalize starting HP/exposure, retain wet clothes,
pin depth within the real pool and refill Air to isolate heat from drowning.
The dry high-stat pushing control normalizes starting HP/exposure. These controls
need no HP rescue; they do not establish indefinite exercise or drowning safety.

## First-person appearance

hands_muted.png is a built-in image_gen color/style edit referencing the existing
Domingo glove, preserving the original separate atlas as source history.
HAND_STYLE_FOLLOWUP.json records its prompt/provenance. The generator only measures
alpha and clips native textures. Ready/reload scale is 0.68; aiming uses the
carbine's existing DH05/DH06 hands, 0.88 scale and under-stock anchors. Weapon and
hands remain independent. Gameplay timing, ammunition, spread and damage do not
change in this appearance correction.

fp-final compares native shotgun/carbine aim and ready, opening, full,
single and partial reloads. A preliminary run exposed repeated recreation of
aimed overlays and an equip-test timing mistake; both were corrected before the
selected captures. Original source artwork and failed/preliminary local evidence
are retained. Author appearance acceptance remains separate.

## Reproduction and qualifications

With no engine running, prepare with `python assets/validation_517/prepare_followup.py`.
The copied author save is a local prerequisite for the reported-state runs;
activity-budget.pk3 needs no private save. Native launch arguments/configs and
exact scripts are in each selected `*-run.json`. `run_check.ps1` requires a fresh
label, asserts native exit zero and rejects script errors. Audio is 5%, background
simulation remains unpaused, and no mass performance test is claimed.

Intermediate finite-recovery runs are superseded, retained locally and excluded
from final mechanic claims. A preliminary reload observer restored the saved
server cvar and unintentionally re-entered its setup mode; it failed its expected
marker and is not passing evidence. The selected reload uses an explicit observer
variant that cannot normalize the saved state. The final manifest records save/reload, static gates,
source/payload equality, deterministic generators and released temporary power
request. CA136-01, CA136-02 and the carried CA143-01 await author acceptance.
