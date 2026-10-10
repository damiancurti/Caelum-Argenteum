# 5.1.10 / issue #154 — SI physics and growth validation

Implemented on `issue-154-si-growth` from main
`f8addb685022a867dd76071826304860ea97baa9`. Tests ran on 2026-10-09 local time
(2026-10-10 UTC), GZDoom 4.14.2 / Windows 11, Vulkan, 1280 x 720. Native runs
used separate configs, 5% master volume, unpaused background simulation and one
engine process at a time. This is controlled native evidence, not author acceptance
or a siege FPS benchmark. At initial delivery, author checks `CA154-01` and
`CA154-02` remained outstanding. The author accepted both without reported
qualifications on 2026-10-10 and requested #154 closure / PR155 merge; see HISTORY.

## Native results

| Final run | Result and boundary covered |
| --- | --- |
| `official-final-b` | 327 passed, 0 failed on the official `build_dev.ps1` package: curve levels 0/1/10/25/50/75/100/150/200, player/NPC adapters and derived consumers, caps/complements/divisors/integer capacity, Toughness operations, movement/jump/work equations, efficiency averaging/cap, isometric effort, firearm reload progress, charged/sweep factors, traveler migration, pending-cast cost/progress, ordinary equipment no-free-heal and foot-journey speed. |
| `movement-final-a` | Four native steady forward speeds passed: approximately 4/8 m/s at Agility 0 and 16/32 at 100. Six accepted native jump cases passed, including added load, 50/80/200 kg bodies, high Agility and fatigued Air. Actual input commands drive the motion; the fixture does not assign flight velocity or replenish Health in flight. |
| `projectiles-final-a` | 165 passed, 0 failed. 54 physical shots: arrow, bolt, bullet, pellet, javelin and cannon at three ranges and three elevations. Launch speed, single gravity integration and native target collision pass; unreachable fallback, elemental no-gravity and retained dispersion pass. Cannon contacts are recorded by its contact ledger, so its target damage callback may show zero in this isolated trajectory fixture. |
| `launchers-final` | 9 passed, 0 failed. Actual cannon controller fires at 100/200/300 m, including raised targets; one round per shot, 500 m/s and target damage. Actual soldier attack retains crouched aim, magazine/Air spending and the new falling trajectory at 80 MU/tic. Crew assignment is controlled setup; siege recruitment is not retested. |
| `hazards-b` | 16 passed, 0 failed. Native 10 m falls for 50/80/200 kg actors at ordinary and half actor gravity; biological absorption is subtracted once and floor severity follows the gravity ratio. Trapdoor opens once, a falling rock releases/lands and deliberate no-gravity support stays in place. |
| `stairs-a` | Actual MAP01 collision route reaches both stair flights, Z=264 MU (8.25 m), without losing Health. 74.135972 m of path at 100 kg and efficiency 0.25792 produces 34,004.085615 J of effort heat, matching the independent distance-plus-ascent calculation. Only the initial placement is teleported; no vertical motion is scripted. |
| `pool-b` | Submerged character surfaces, crosses the western steps and reaches dry ground, water level 0; Health remains 1248. This checks the exit with normal collision and native swim/forward input. Continued input at the mansion wall subsequently registers the preserved isometric effort. |
| `elevator-b` | MAP02 return platform carries the player down to -160 MU and back to 0. Both checks pass, Health unchanged, zero locomotion heat from passive elevator travel. |
| `save-upgrade-b`, `save-repeat-b` | 18 passed each. Partial Health/Anima/Air/Adrenaline survive the one-time player and NPC migration; repeat loading and recalculation do not rescale twice. Damaged/open gate, owned items and weapon identity persist. |
| `author-save-b` | 12 passed on a protected copy of the author's Prueba save. Health/Anima/Air/Adrenaline maxima change from 103000/51500/3000/3000 to 16000/8000/4000/4000 while preserving percentages; 37 owned inventory entries and weapon ID 3 remain. |
| `author-rollback-a` | 12 passed loading the untouched protected original with the previous package: old maxima, balance revision 3, gravity 800, inventory and weapon remain available. Downgrading a newly written save is not promised. |
| `hub-upgrade-final` | Three passes across old MAP03, previously visited MAP02, then MAP03 again. Exactly one physics marker per map, level gravity 205.008979591837, player balance revision 4; no repeated scaling. |

The initial `gravity-baseline-a` probe verified native semantics rather than
assuming that `level.gravity` is measured in MU/tic²: ordinary level value 800
gives Actor acceleration 1 MU/tic². Multiplying that level value by
9.81*32/1225 yields the approved Earth acceleration. An actor's 0.5 gravity
modifier then gives 4.905 m/s². Actor movement precedes gravity; the existing
cannon FastProjectile applies gravity before movement.

### Jump measurements

| Body / load kg | Agility | Native takeoff MU/tic | Apex MU above start | Effort heat J |
| --- | ---: | ---: | ---: | ---: |
| 80 / 0 | 0 | 4.088810 | 34.669613 | 2400 |
| 80 / 80 | 0 | 2.891225 | 17.781463 | 2400 |
| 80 / 0 | 100 | 11.564901 | 266.755086 | 6400 |
| 50 / 20 | 100 | 10.365563 | 214.853888 | 4498.730602 |
| 80 / 0, fatigued | 0 | 3.066608 | 19.886049 | 1350 |
| 200 / 80 | 100 | 8.716365 | 152.597345 | 12724.331660 |

The controlled fixture sets effective body/attribute/load inputs and retains a
common native Health reference; it is not a claim to have created every race and
equipment permutation through the character-creation UI. Efficiency is 25% in
the low-attribute cases and 50% in the high-attribute cases. Apex exceeds the
continuous ideal slightly because of the verified discrete integration order.
The ideal A0/A100 unloaded heights are 1.019368/8.154944 m. Status penalties reduce
delivered velocity and therefore square into the energy actually charged.

## Static audit and reproducibility

`AUDIT.json` records source hashes, every current growth adapter/direct consumer,
the remaining legacy formula isolated in the old-save migration, fixture hashes,
official PK3 hash, original-save hash and all run hashes. The official package
matches all 6,299 source members exactly; map, art and audio source files are
unchanged. Rebuilding fixtures twice produces identical bytes. No engine, IWAD,
save or generated PK3 is distributed. `POWER.json` verifies release of the temporary
execution-state request and an unchanged Windows power plan.

The consumer audit includes untouched callers of the migrated adapters:
equipment/Tarot effective attributes, crafting, dialogue, Box, NPC initialization,
combat/resources/survival, thermal thresholds/acclimatization and HUD. Historical
method names stay as compatibility adapters; their names are not new family IDs.
Ordinary Toughness damage subtraction, thermal resistance and thermal widening
retain different operations. Animal native chase cadence/base behavior is
preserved; a chase state's Speed field is not a measured per-tic travel speed.

Reproduce locally with `python assets/validation_5110/prepare.py --production`,
then `run_native.ps1` using a fresh Label, `production.pk3`, the appropriate addon
and CFG. MAP01 traversal uses `-Map MAP01`; the elevator uses `-Map MAP02`.
Persistence tests require local protected old-package/save fixtures; preserve the
package basename required by the save in separate directories. Do not replace
the original backup to satisfy that basename. Finish with the official builder,
`official-final-b` equivalent, `finalize.py`, document-index regeneration and
`validate_project.py`. The runner records exact commands, config, engine/hardware
and hashes in each run JSON. It does not modify the user's normal config.

Earlier successful subsystem runs precede the final shared muzzle-direction
normalization, which removes a roughly 0.000009 MU/tic trigonometric rounding
error without changing the authored speed. `launchers-final` covers that change;
`official-final-b` covers the final official package, including the later correction
to a saved pending spell's cost. That correction updates its new curve once,
preserves charge/tier/progress and spends no Anima during migration; six additional
checks pass. Other later differences are comment corrections.

## Rejected or superseded attempts retained in raw evidence

All run logs/metadata are retained, including failed setup attempts. They are not
counted as passing validation. Native exit code 0 alone is insufficient: GZDoom
can exit normally after a VM abort or after rejecting a missing save dependency.

- Early compile fixtures used invalid vector-array/function-result syntax or
  referenced a new class in the old package; corrected fixtures compile natively.
- `movement-a` had its direct load assignment overwritten by the normal load
  service; the final fixture uses the supported debug-load route. `movement-b`
  replenished Health each tic and is superseded by the non-refilling final run.
- Initial persistence setup let an open gate auto-close and set NPC attributes
  before deferred PostBeginPlay reset them. Corrected seeding tests the intended
  old saved state; final migration/reload checks pass.
- First author/hub reloads lacked the exact required package basename. Separate
  candidate and rollback aliases fixed the harness without touching the backups.
  An old-save CVAR also overwrote the hub test mode; a one-tic delayed setup yields
  the final three-map migration sequence.
- `launchers-a` attempted to use an uninitialized test soldier carbine and aborted
  the VM. Explicit fixture initialization fixes it. The next precision failures
  identified the tiny shared direction-length error corrected above.
- `projectiles-c` target contacts passed but strict launch-speed assertions found
  native trigonometric rounding; normalizing the solved direction fixes the check.
- `elevator-a` expected the opposite initial platform direction; the corrected
  assertion covers both directions. `pool-a` stopped before reaching the western
  edge (still water level 1); extending native travel reaches dry ground.
- Intermediate compile/core checks, `consumers-b`, `hazards-a` and partial hub
  checks are superseded by the stronger final runs named above.

## Remaining review boundary

New formulas and SI targets are implemented, not a newly approved force/power
acceleration model. Ballistic solving is bounded to launch and has no measured
mass-siege FPS claim. Unreachable targets retain direct-shot fallback. User feel,
HUD readability and the combined playthrough were separate author checks,
subsequently accepted on 2026-10-10. The native evidence itself does not assert
author acceptance or expand the approved scope.
