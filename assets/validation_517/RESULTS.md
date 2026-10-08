# Issue #136 - Shotgun, armor bypass and modular first-person layers

Release 5.1.7, GZDoom 4.14.2 Windows/Vulkan. Base: abd4f578 (#143).
The author's final target is the shortbow; longbow/crossbow remain.
These are agent checks. CA136-01 and carried CA143-01 await author acceptance.

## Reproduction

Run `python -X utf8 assets/validation_517/prepare.py`, then use run_check.ps1
with a fresh label, `-Map CA136` and the desired checks.pk3/integration.pk3
or visual.pk3 fixture. Visual uses `-Script visual.cfg -Interactive -Controlled`.
The same integration fixture on MAP02 verifies actual enemy death supplies.
prepare_persistence.py creates the exact 5.1.6 baseline from the recorded git
commit and old/current fixture packages with compatible saved fixture classes.
The seed creates ca136-old-shortbow.zds; current upgrade/seed.pk3 loads it and
saves ca136-migrated.zds. reload.cfg/hub.cfg test current persistence; the old
package with rollback/seed.pk3 loads the untouched original checkpoint.
Saved fixture class package names remain seed.pk3 as required by native saves.
No PK3, IWAD, executable or test save is distributed.

## Coverage

- T1/T2/T3 catalogue damage, mass, condition, recipe, costs, spread and range.
- Twelve actual launched projectiles and 4320 unmitigated T1 damage on 12 hits.
- Non-divisible 120.6 budget rounds to 121: native two-target loss 60/61.
  Four misses leave two targets with 40/40; zero-rounded pellets cause zero loss.
- Separate shell/bullet native pickup in both directions; retained arrows.
- Two chamber bits; actual right/left firing; empty, partial, one-shell and
  interrupted reloads; equipment-change cancellation; insufficient Air.
- Player/NPC tier matrix preserves Toughness/innate defense; cannon contact
  solvers use innate armor only. In-flight metadata survives equipment changes.
- One-time armory stock and constructor revision stamps; no automatic restock.
- Actual MAP02 deaths at six eligible TIDs create six stacks totaling 120,
  including repeated death-call protection. Original supplies remain unchanged.
- Old equipped/boxed shortbows retain 37% condition, identities, Box state,
  arrows and recipe knowledge. Repeated migration and native save/hub retain
  a single loaded chamber and nine cartridges. Original-pair rollback passes.
- Native first-person ready/aim/recoil/open/loading/completion and T1/T2/T3;
  separate complete weapon and foreground hand layers, one set of hands shared
  across tiers. World gallery exercises all six poses in eight directions.

## Limits and rejected setup runs

This is no mass-siege benchmark or multiplayer-session acceptance. Presentation
was reviewed by the agent; the author's taste/gameplay check stays pending.
No direct downgrade of a new-format save is claimed: rollback restores the
original save and matching runtime without overwriting that checkpoint.

Local rejected trials remain under build/issue136. Initial failures included
case-insensitive PELLETS shadowing, a fixture accuracy value overwritten before
fire, native Ammo parent merging, wrong saved fixture package name, unstamped
synthetic merchant equipment, absent Box ownership, and stale observer pointers
after hub travel. The successful observer resolves saved ItemIds on the current
owner. An early visual loading state was invisible with state-pointer arithmetic;
explicit state labels corrected it. Only final clean-exit runs count as delivery
evidence; script markers do not override a native crash or failed assertion.

The final MANIFEST.json records selected run/config/source/package hashes,
static gates, deterministic generator checks and the released keep-awake record.
All native runs use independent INIs, 5% volume and unpaused background execution.
The temporary keep-awake request changes no power plan and is released afterward.

Selected clean runs: delivery-catalogue (49 checks, including Spanish tutorial
name), delivery-integration (18), final-map02 (7), final-visual (2 plus captures),
delivery-upgrade (8), delivery-hub (8 on load and 8 on hub return), rollback-a (1)
and migration-seed-b (old-runtime setup). Visual and MAP02 evidence precede the
final correction of unrelated grouped melee catalogue cases; their exercised
behavior/assets are unchanged. Delivery checks explicitly preserve those melee
Air/critical values. The generator check preserves all 224 original drop records
and byte-identical MAP02 geometry through two repeated rebuilds.
