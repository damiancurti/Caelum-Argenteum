# 5.8.7 / #410 - Illness in travel and waiting forecasts

Journey and task-wait forecasts previously omitted the character's already
implemented food contamination. They now copy its persistent value and damage
fraction, apply the shared damage arithmetic, and pay the existing natural
regeneration costs while depurating, including at full Life. Native journey
commit installs an independent copy of the forecast result. Wait forecast
schema 6 makes the existing menu rebuild pre-change previews.

This is an integration correction within ongoing #410. It does not activate
food-inventory ageing, ingredient consumption, cooking, new commerce or mansion
furniture. Those dependencies remain open. No map, balance, art or save layout
is replaced, and #411 deployment/#412 shelter work remains separate.

## Native checks

GZDoom 4.14.2 / Windows 11, Ryzen 9 5950X, RTX 3070 Ti, Vulkan, 1280x720.
Checks run unpaused in the background, one engine at a time, at 5% audio.
Complete commands, configuration, engine/IWAD hashes and logs are in native/;
report.json verifies every packaged member against src. After probe01, the
two required diagnostic version labels changed from 5.8.6 to 5.8.7. collect.py
verifies that these are the only runtime differences: all gameplay bytes match
the tested probe. Static validation passes after updating those labels and a
relative documentation link; the initial validation report is also retained.

| Run | PASS | Coverage |
| --- | ---: | --- |
| core02 | 53 | Forecast isolation; native damage/depuration/cost/fraction parity at full, wounded and over-maximum Life; critical Hunger; tiny residue; Toughness 50/100/150; lethal damage; wait forecasting |
| commit01 | 3 | Actual journey Apply commits Life and illness without model aliasing |
| save01 | 1 | Independent live and forecast records saved |
| load01 | 2 | Native restoration of both values/fractions |
| hub01 | 6 | Original map, destination and return retain independent state |
| legacy-seed01 | 1 | Original 5.8.6 package saves illness and a revision-5 waiting forecast |
| legacy-load01 | 1 | Original save loads unchanged; new captures preserve illness and rebuild revision 6 |
| legacy-rollback01 | 1 | Original save still loads with the original package |

Total: 68 PASS in eight selected runs. core01 is retained: a private diagnostic
variable used the reserved ZScript identifier `native`; renaming that variable
resolved compilation without a production change. No failed run is counted.

The test compares each simulated interval with the native disease and recovery
functions using identical resources and captured attributes. Passive losses and
other recovery channels are isolated in that comparison; the suite does not
claim new end-to-end travel-event, thermal-performance or campaign acceptance.
Existing production time scales, periodic damage semantics and comfort factors
are retained. No global actor/inventory scans are introduced.

## Reproduction and pending work

Run prepare.py, build_dev.ps1 with destination
build/issue410-food/current/caelum_argenteum_dev.pk3, then run_native.ps1
with a fresh label and the core/commit/save/load/hub script. Save/load use
ca410j-original.zds; hub uses that same original save. Legacy reproduction
requires the preserved full 5.8.6 package e3516c6e, the generated baseline,
bridge and rollback legacy-checks.pk3 variants, and ca410j-legacy.zds. Never
edit or overwrite the original save to make the migration pass.

No author terminal was launched during the requested absence. Broader food
interaction and cooking tests will be queued with their actual integration.
