# Changelog

## 4.29.0m — Live AI controls, lightweight stress actors and straight balcony corridor

- Confirmed from all three V4.29.0l logs that contacts stayed at zero,
  projectiles stayed between zero and two and the global Chase peak never
  exceeded 40. The stops remained abrupt and occurred after different run
  lengths, with no monitored counter growing toward the failure.
- Corrected the A/B controls: the first two logs issued `false` after the
  actors had already cached `true`, so all three sessions actually ran Look,
  Chase and attacks. The sole coordinator now reads settings once per tic;
  changes are live and the next telemetry report displays their effective value.
- Added independent Look enablement and a default hard ceiling of 20 native
  `A_Look` calls per tic, alongside the existing 40-call Chase ceiling.
- Added a diagnostic-only lightweight path. The 16,500 mass/passive stress
  actors no longer allocate permanent anatomy, armor and elemental-status
  helpers or recalculate full RPG/contact state every tic. Native state
  progression and scheduled Look/Chase/attacks remain active. Normal maps,
  isolated physics rooms and gameplay NPCs keep the complete simulation.
- Expanded telemetry with effective Look controls, phase/budget/pause
  deferrals, per-tic Look peak, lightweight actor count and allocated helper
  object counts.
- Rebuilt both MAP01 first-floor façades at Y=±368. Each repeated staircase
  ends at Y=±272, leaving one uninterrupted 96-MU landing corridor. Removed
  the former stair-shaped wall returns, aligned the four balcony door pairs
  and moved the accepted middle doors to the centers of the shallower rooms.
- Changed the top face of tag-511 walls to the roof texture so wall caps no
  longer form panel-textured strips above the façade. All flights remain
  119 MU wide and lateral room connections remain closed for acceptance.
- Recorded manual acceptance of the corrected colored HUD resource bars.

## 4.29.0l — Bounded chase coordinator and continuous first-floor rows

- Separated MAP02 mass-field perception and chase settings. `A_Look` keeps its
  seven-phase cadence while `A_Chase` defaults to thirteen coprime phases,
  approximately one update every 1.5--2 seconds for the current state loops.
- Added one deterministic per-game coordinator with a hard default ceiling of
  40 native `A_Chase` calls per tic. Actors cache its reference once at spawn;
  no actor search or CVar lookup was added to the hot path.
- Added an A/B switch that keeps acquired targets but pauses `A_Chase`, plus
  telemetry for phase/budget/paused deferrals, peak updates per tic, family
  execution totals and target distance bands.
- Rebuilt MAP01's complete north and south first-floor rows from the accepted
  tag-510/tag-511 controls. The eight rooms now meet behind the repeated stair
  landings, preserve the 96-MU balcony setback and all three 119-MU flights,
  and contain no coincident repair lines.
- Removed the four former central side leaves that would float inside the
  enlarged rooms. The four balcony-facing double doors and the two accepted
  middle doors remain; lateral room connections stay closed for the next gate.
- Drew resource fills inside and after the opaque HUD-01 frame centers so the
  authored health/resource colors remain visible without covering metal caps.
- Increased only `CaelumText` and its small-menu aliases from six to eight
  pixels of word spacing. Letter kerning and `CaelumMono` remain unchanged.

## 4.29.0i — Cached perception scheduling and permanent UI foundation

- Extended the MAP02 mass-field budget from `A_Chase` to `A_Look`. Perception,
  chase and attack settings are captured once per actor at map load, and both
  AI phase keys are derived once from stable spawn coordinates instead of
  performing CVar lookups and hash work in the hot state-action path.
- Added separate attempted/executed/deferred perception telemetry. The default
  seven-phase budget lets dormant actors perform a native sight check roughly
  once every two seconds while preserving ordinary timing outside the mass
  diagnostic field.
- Preserved pass-through, bounded straight projectiles, friendly-fire
  prevention and the 64-phase diagnostic attack gate from 4.29.0h. This patch
  does not claim a final formation controller or stealth scheduler.
- Added four native first-floor divider sectors around the accepted middle
  doors of MAP01. They reuse the existing tag-511 wall target and the shared
  3D-floor controls instead of overlaying finite actor panels.
- Added two sliding door pairs to the rear first-floor rooms without moving or
  enlarging those rooms. MAP01 now contains 398 vertices, 489 linedefs, 948
  sidedefs, 99 sectors and 210 Things.
- Integrated the 94-file HUD/UI-01 runtime pack: modular bar and panel pieces,
  resource/combat/status icons, reticles, Journal controls, navigation,
  categories, equipment slots and action icons.
- Removed the inherited Doom status bar and face through a custom
  `BaseStatusBar`; applied HUD-01 frames/icons to the existing live resource
  display and added the first six-section Journal on Tab. Inventory and
  Character read real state; unimplemented pages are visible but never invent
  placeholder world, quest or reputation data. The native automap moves to M.


## 4.29.0h — Canonical room sectors and budgeted mass AI

- Corrected the geometric sidedef ownership of all eight edges in each new
  MAP01 central module. Twelve edges required reversal; sector 510 now occupies
  the actual 336×336 interior, sector 511 occupies the wall ring and the
  existing 128–136/256–264 controls remain the only slabs.
- Kept MAP01 at 382 vertices, 473 linedefs, 916 sidedefs and 99 sectors. No
  extra plane, patch sector, door or divider was added.
- Recorded the author's stagger-3 freeze with 958 targets, zero custom physics
  callbacks and only 16 live projectiles. This excludes contact retention,
  projectile accumulation and diagnostic infighting as necessary triggers.
- Added deterministic budgeting to main-field `A_Chase` calls with
  `ca_diag_mass_ai_stagger 7`, plus executed/deferred chase telemetry.
- Raised the MAP02-only attack phase count from 3 to 64 so the 634 target-bearing
  rats cannot all deliver their first melee action within one expensive tic.
- Main-field actors now pass through every actor rather than forming a native
  collision ring around the player. Quintaesencia rooms and every normal map
  retain their authored collision rules.

## 4.29.0g — Clean central-room modules and staggered mass combat

- Removed all 60 lines, 120 sidedefs and three sectors from the superseded
  MAP01 central-room rebuild instead of applying another surface repair.
- Rebuilt each central first-floor room as one 336×336-MU interior with one
  continuous 8-MU wall ring. This candidate deliberately has no divider,
  threshold or door; those elements remain deferred until the clean shell is
  accepted from above, below, inside and outside.
- Reduced MAP01 to 382 vertices, 473 linedefs and 916 sidedefs. No coincident
  linedefs remain, every line has a valid front side and the shared 510/511
  3D-floor controls used by the working end rooms remain unchanged.
- Added deterministic three-tic staggering to main-field attacks in MAP02.
  `ca_diag_mass_attack_stagger 1` reproduces the original synchronized rate;
  the default `3` admits one position-derived phase per tic.
- Assigned the 15,000-body main field one diagnostic species with
  `THRUSPECIES`, while the separate Quintessence rooms retain full physical
  collisions. Straight projectiles and melee attacks also suppress friendly
  damage inside that field, preventing impact-driven infighting cascades.
- Extended combat telemetry with the stagger value, deferred attempts and
  prevented friendly-fire events.
- Added a six-exercise Ultimate Doom Builder guide for UDMF rooms, 3D floors,
  upper walls, roofs, doors, modular repetition and structural validation.


## 4.29.0f — Continuous central slabs and isolated mass-AI combat

- Replaced the separate MAP01 room/threshold 3D-floor targets with one shared
  tag 510 surface. The three former tag-512 sectors now receive exactly the
  same lower and upper slabs as the adjoining central rooms, covering the
  reported interior and exterior bands without another overlapping repair.
- Removed the redundant lower tag-512 control sector, its four lines/sides and
  four vertices, cleared the second upper link and removed one inherited empty
  sector. MAP01 now contains 510 vertices, 517 linedefs, 1,004 sidedefs, 98
  sectors and 206 Things; no tag or 3D-floor target 512 remains.
- Registered the mansion wood, ceiling, interior-wall and door resources
  explicitly as map flats/textures. Their sprite aliases remain available,
  but 3D floors no longer depend on sprite-namespace lookup for visible planes.
- Closed MAP02's spawn side from the 1,875-AI field with one native two-sided,
  sight-blocking monster wall. The population loads unchanged, but starts with
  zero main-field targets until the player explicitly enters the test.
- Added `ca_diag_mass_attacks`, a MAP02-only server diagnostic gate. `false`
  keeps perception/chase active in the main field while suppressing melee,
  charge and projectile actions; the nine smaller rooms remain unaffected.
- Added once-per-second attack and projectile telemetry: attempts, suppressed
  attempts, successful/failed spawns, impacts, range expiry and destruction,
  plus target/active counts for every main-field actor family.
- Added an idempotent source-map reconstruction script and validated the
  resulting PK3, MAP01 and MAP02 with the GZDoom 4.14.2 executable. Visual and
  traversal acceptance of the rebuilt central slabs remains a manual test.

## 4.29.0e — Traversable MAP01 doors and in-range MAP02 tests

- Corrected the four exterior leaves in MAP01's rebuilt central pairs: their
  visible plane was vertical but their blockers and opening displacement used
  the perpendicular X axis. All six leaves now move along Y, parallel to the
  authored vertical wall, instead of projecting into or out of the room.
- Added a second tag-512 3D-floor control using the existing 256–264-MU roof
  slab. The six 64-MU door sectors now receive both the 128–136-MU first-floor
  slab and continuous upper roof, removing the reported holes without changing
  room footprints, sector tags or door TIDs `900–905`.
- Corrected the MAP02 load failure shown by GZDoom 4.14.2. Room 7 had been
  placed near X=-50,000 even though the valid UDMF coordinate range ends at
  -32,768; Room 8 geometry also extended 32 MU beyond that boundary.
- Moved the three 500-Rat Quintessence matrices to `(-24000,-18000)`,
  `(-24000,0)` and `(-24000,18000)`. Adjacent tests remain 18,000 MU apart,
  the main 1,875-AI field is unchanged, and no diagnostic population overlaps.
- Extended the PK3 UDMF gate to reject every vertex or Thing whose X/Y lies
  outside `-32768..32768`. The gate reproduces the former MAP02 failure at
  vertex 56 and now accepts both corrected maps.
- Updated the MAP02 startup instructions and telemetry commands. Physics,
  projectile rules, active/passive counts and validated Seal formulas are
  unchanged.

## 4.29.0d — Canonical MAP01 sidedefs and two-sided flags

- Corrected the reported MAP01 linedef range instead of layering another wall
  or visual patch over the central first-floor reconstruction.
- Removed 316 orphaned sidedefs retained from superseded room geometries and
  remapped every live `sidefront`/`sideback` reference to one continuous table.
- Reduced MAP01 from 1,324 to 1,008 sidedefs without changing its 514 vertices,
  521 linedefs, 100 sectors, 206 Things or authored room coordinates.
- Added the missing `twosided = true` field to linedefs 461–520, all of which
  already carried a valid `sideback`. Every bilateral line now declares the
  matching UDMF flag and every unilateral line omits it.
- Extended the PK3 builder with a read-only UDMF gate that rejects missing or
  out-of-range front sides, invalid vertices/sectors, zero-length lines, shared
  or orphaned sidedefs and disagreement between `sideback` and `twosided`.
- Verified that the new gate rejects the V4.29.0c MAP01 and accepts both current
  MAP01 and MAP02. MAP02, AI staging, projectiles, physics and Seal behavior are
  unchanged.

## 4.29.0c — Native central rooms and staged 1,875-AI return

- Reconstructed both mirrored central first-floor pairs in MAP01 from clean
  native UDMF topology instead of applying another finite-wall correction.
- Removed the complete former pair geometry, its fourteen accumulated bridge
  lines and all four `CaelumFiniteWallPanel` Things before creating the new
  sectors. No old wall or coincident visual patch remains underneath.
- Made each pair one continuous 352×352-MU exterior volume, then added one
  native 8-MU central divider with a centered 64-MU doorway. The two room
  interiors remain separate while sharing a single exterior footprint.
- Moved the four exterior door leaves to the west/east side walls and retained
  the two existing internal leaves in the dividers. All six keep their TIDs,
  access rules and 136-MU first-floor height.
- Reduced MAP01 from 619 to 521 linedefs, but retained 316 sidedefs belonging
  to removed geometry and omitted `twosided` on the final 60 bilateral lines.
  V4.29.0d supersedes this incomplete structural validation.
- Recorded the supplied V4.29.0b sequential telemetry: Room 5 remained at four
  targets with at most 18 straight projectiles and one isolated callback;
  Room 6 raised target-bearing actors from four to 199 without generating
  contact callbacks, isolating explosion-driven target propagation/infighting.
- Confirmed that the former Quintessence rooms were not spatially isolated:
  Room 7 reported 1,103 affected actors and Room 8 reported 1,755 instead of
  500. The attempted X centers `-50000`, `-32000` and `-14000` left 18,000 MU
  between tests but exceeded GZDoom's coordinate range; V4.29.0e supersedes
  those invalid positions.
- Restored exactly 1,875 active actors inside MAP02's existing 15,000-body main
  field: 125 Rulo, 125 Argento, 125 Caella, 125 Ronnie, 125 Bulls and 1,250
  Giant Rats. The closest bodies to the field center are selected so the test
  enters targeting range as one reproducible stress population.
- Kept the other 13,125 main-field bodies passive. This reproduces the former
  1,875-actor failure before attempting 3,750, 7,500 or 15,000 simultaneous AI.
- Added `ia` and `ia_objetivos` telemetry. `objetivos` remains the total and can
  therefore reveal passive bodies that received a target through damage.
- Kept validated Seal behavior, mass formulas, crafting and the permanent
  straight-projectile policy unchanged.

## 4.29.0b — Simple mass projectiles, bounded pair work and mansion wall closure

- Replaced the homing elemental projectile used by Rulo, Caella, Ronnie and
  Argento with a bounded straight-impact projectile. It performs no target
  search, seeker steering or radial explosion and keeps prepared damage,
  critical result, elemental payload, push multiplier and Eloquence-derived
  range.
- Limited the straight projectile through lifetime multiplied by its constant
  speed, avoiding a per-tic position vector and square root. The explosive
  variant remains available only where an authored weapon or the MAP02 A/B
  diagnostic explicitly requests it.
- Reused one source body, target body and result object per player or combat
  actor instead of allocating all three on every custom collision.
- Allowed each shared contact edge to resolve at most once per tic. Duplicate
  engine callbacks still refresh edge liveness but no longer repeat the
  impulse calculation.
- Rejected coincident, separating and below-threshold resting callbacks before
  constructing physics bodies; the square root and normal calculation now run
  only for a genuinely closing pair.
- Expanded MAP02 telemetry with unique pair-tics, duplicate callbacks, resting
  callbacks and the current Seal-affected count. This distinguishes high
  native callback volume from actual custom physics work.
- Replaced the former unequal Quintessence rooms with three equal groups of
  500 passive Rats: native collision without Caelum contacts, complete Caelum
  contacts, and native collision with same-species pass-through. The original
  15,000 passive stress population remains available outside the rooms.
- Preserved the simple-versus-explosive shooter comparison in Rooms 5 and 6;
  the explosive room continues to expose radial damage and infighting cost.
- Closed the four finite first-floor central wall spans in MAP01 at 72 MU and
  changed the reverse visual face offset from a global X/Y shift to a local
  wall-normal shift. This prevents the reverse face from exposing an endpoint
  gap when viewed from inside the middle rooms.
- Kept validated Seal formulas/effects and crafting behavior unchanged.

## 4.29.0a — Bounded contact pressure and MAP02 A/B diagnostics

- Removed `THRUSPECIES` from Giant Rats. Rat-to-Rat contact can now transmit
  displacement and pressure instead of allowing a Quintessence cluster to
  overlap without forming collision edges.
- Added a collision-callback timestamp to every shared contact edge. An edge
  now expires after five complete tics without a new collision callback, in
  addition to the existing distance/separation test, preventing historical
  neighbor lists from growing indefinitely after a crowd disperses.
- Replaced the nominal walking-speed crush pulse with the real impulse summed
  once per tic over the existing 35-tic interval. Duplicate callbacks in one
  tic contribute only their maximum impulse sample.
- Kept pairwise inelastic action/reaction and mass resistance unchanged. This
  is a bounded contact graph and pressure-transfer correction, not yet a
  simultaneous connected-component island solver.
- Replaced the square-root radius test used by Seal target scans with an exact
  squared-distance comparison, reducing per-tic Quintessence/Air scan cost
  without changing the authored radius or force.
- Expanded MAP02 with eight independently sight-blocked test rooms while
  preserving the original 15,000 passive stress actors:
  1. 25 perception-only Giant Rats;
  2. 25 chase-only Rats using native collision without Caelum contacts;
  3. 25 otherwise identical chase-only Rats using Caelum contacts;
  4. 25 complete active Giant Rats;
  5. four stationary Argento shooters whose projectiles do not explode;
  6. four otherwise identical shooters with the normal explosion;
  7. 100 passive Rats for Quintessence;
  8. 500 passive Rats for Quintessence.
- Added a MAP02-only one-second console monitor for acquired targets, live
  projectiles, approximate contact edges, maximum contacts per actor,
  collision callbacks, created references and removed references.
- Rebuilt MAP02 as valid UDMF with 64 linedefs and 120 sidedefs; every linedef
  has a front side. MAP01, validated Seal behavior and crafting rules are
  unchanged.

## 4.28.0bp — MAP01 safe rollback and V4.29 authorization

- Rejected the V4.28.0bo MAP01 room consolidation after GZDoom reported
  linedefs 569–590 without usable front sides during node construction.
- Restored MAP01 byte-for-byte from the last loadable V4.28.0bn package; its
  future room reconstruction continues as a non-blocking parallel track.
- Preserved the material/special-item native inventory-bar exclusion from
  V4.28.0bo.
- Recorded author validation of all current non-weather Seal effects and
  mechanics, closing the functional V4.28 Seal gate.
- Authorized the start of V4.29 Crafting Completion and Persistent Recipe
  Book while MAP01 continues independently.
- Deferred the complete V4.27 combat-input matrix until the crafting system
  is complete.

## 4.28.0bo — Geometry-native first-floor rooms and material HUD isolation

- Rebuilt both mirrored central first-floor modules in MAP01 as large rooms
  using map geometry rather than finite wall actors.
- Merged each former pair of small rooms and its narrow connector into one
  large rectangular room.
- Moved the two former front doors to the left and right side walls, centered
  on the same axis.
- Closed the former front door openings with the normal wall sector.
- Consolidated the former inner walls into one central dividing wall and
  retained a single centered door through it.
- Removed all remaining `CaelumFiniteWallPanel` things from MAP01.
- Excluded materials and other special inventory items from GZDoom's native
  inventory bar, preventing their icons from replacing the player face.
- Left the Bull, Seals and MAP02 unchanged after their successful validation.

## 4.28.0bn — MAP01 wall orientation, equipment HUD isolation and Bull sprites

- Restored only the four valid angle-90 first-floor wall panels in MAP01 and
  kept the four connected perpendicular angle-0 panels removed.
- Removed every custom equipment instance from GZDoom's native inventory bar,
  preventing weapons, armor, shields, amulets and Seals from replacing the
  player face; native-bar consumables remain unchanged.
- Replaced the Bull's two rear Charge frames with the authored back-facing
  source frames.
- Rebuilt all six Bull Death frames with real alpha transparency and repaired
  the cropped head in the final frame.
- Left MAP02 and its 15,000 passive stress actors unchanged.

## 4.28.0bm — Mass-resisted Seals and elevated Quintessence epicenter

- Raised the Quintessence channel epicenter exactly five development-scale
  meters (160 map units) above the owner, pulling targets away from the
  player's collision volume.
- Applied force-over-mass acceleration to the continuous Air tornado and
  Quintessence attraction. Giant Rats and Bulls no longer receive identical
  velocity from the same force; the authored Quintessence release formula of
  `10 × trapped mass / expelled mass` remains unchanged.
- Removed Freeze and Dazzle application from the Earth Seal. It now applies
  Poison plus a dedicated non-Ice radial statistic penalty, retaining the
  authored 100%/50%/0% curve without creating a Freeze visual.
- Removed Seals from GZDoom's native inventory bar because Caelum's equipment
  interface already manages them. Picking up a Seal can no longer replace the
  native player face with the most recently collected Seal icon.
- Preserved MAP01 and MAP02 byte-for-byte from `4.28.0bl` and changed no
  Impact Physics or passive-AI code.

## 4.28.0bl — MAP01 panel rollback and authoritative Seal binding

- Reverted the `4.28.0bk` rear-leaf additions for finite walls and sliding
  doors, removing the duplicated door texture reported in MAP01.
- Deleted all eight `CaelumFiniteWallPanel` things from MAP01. These are the
  first-floor actor walls called out from inside the room and beside its
  entrances; the openings are now intentionally left empty for reconstruction.
- Bound each channel-effect actor to the exact equipped Seal inventory item.
  Its gameplay type is refreshed from that item and the channel is destroyed
  if it is unequipped or replaced, preventing a Fire actor from surviving a
  change to another displayed Seal.
- Preserved MAP02 byte-for-byte with its 15,000 passive actors and changed no
  Impact Physics, passive-AI, tornado, gravity or radial-falloff behavior.

## 4.28.0bk — Rebuilt bilateral walls/doors and passive 15,000-actor test

- Deleted the orientation-independent diagonal backing logic from finite walls
  and rebuilt every rear face at the correct local wall normal, opposite the
  master panel and separated by 0.5 MU.
- Rebuilt sliding doors as synchronized front/rear visual leaves. The reverse
  leaf follows movement, angle and scale but adds no solidity, blockers,
  contact mass or Impact Physics participation.
- Added passive stress subclasses for Rulo, Argento, Caella, Ronnie, Bull and
  Giant Rat. They retain normal stats, rendering, solid collision, damage,
  Pain and Death while omitting A_Look, A_Chase, facing and attacks.
- Replaced every MAP02 combatant with its passive counterpart: 1,000 of each
  non-rat type and 10,000 Giant Rats. Actor positions and geometry are
  unchanged.
- Preserved the 4.28.0bj Seal mechanics and changed no physics formulas,
  projectile behavior, typography, menu or Debug-profile values.

## 4.28.0bj — Southern tornado Seal and first-floor seam closure

- Changed the Air Seal from radial expulsion to clockwise tangential rotation
  plus vertical lift, using the same existing combined push power for both
  components.
- Made Air and Quintessence preserve and disable each affected actor's gravity
  flag while it remains inside the channel, restoring the original flag upon
  exit, interruption or release.
- Replaced the Earth Seal's uniform Freeze/Dazzle penalties with a continuous
  squared radial curve: 100% at the center, 50% at half radius and 0% at the
  boundary. Poison damage and all existing durations remain unchanged.
- Extended the mirrored MAP01 first-floor terminal closures from 64 to 72 MU,
  covering the remaining visible interior seam with a controlled 4-MU overlap
  at each endpoint and without modifying ground-floor geometry.
- Kept MAP02 at 15,000 combatants and changed no Impact Physics, NPC AI,
  projectile, typography, menu or Debug-profile code.

## 4.28.0bi — Full 15,000-actor post-island stress population

- Increased MAP02 from 1,874 to exactly 15,000 combatants without changing
  its enclosure, entrance or geometry.
- Placed 1,000 Rulo, 1,000 Caella, 1,000 Ronnie, 1,000 Argento, 1,000 Bulls
  and 10,000 Giant Rats at unique positions on the existing 96 MU grid.
- Changed no physics, projectile, menu, typography or Debug-profile code so
  this patch isolates the full-scale population test.

## 4.28.0bh — Doubled post-island stress population

- Doubled MAP02 from the validated 937-actor population to exactly 1,874
  combatants without changing its enclosure, entrance or geometry.
- Placed 126 Rulo, 126 Caella, 124 Ronnie, 124 Argento, 124 Bulls and 1,250
  Giant Rats, preserving the deterministic proportional distribution.
- Changed no physics, projectile, menu, typography or Debug-profile code so
  this test isolates the load difference under the 4.28.0bf/4.28.0bg systems.

## 4.28.0bf — Range-bounded projectiles and UI-safe contact telemetry

- Supersedes the unloadable 4.28.0be draft. The debug HUD now reads a contact
  count cached during player `Tick` instead of calling a play-scope function
  from UI scope.
- Connected NPC magical range to the same authoritative rule as the player:
  3,200 MU base multiplied by Eloquence Type 4 `AbilityRangePercent`.
- Applied that distance both to `MaxTargetRange` and to projectile travel.
  Explosive missiles destroy themselves when they exhaust the caster's range;
  the ten-second lifetime remains an independent absolute safeguard.

## 4.28.0be — Contact islands, crushing and explosive NPC projectiles

- Supersedes the unloadable 4.28.0bd draft. Renamed every contact-local
  `state` identifier because `state` is reserved by the ZScript parser.

- Restored MAP02 to its validated 937-actor population after the doubled
  1,874-actor field froze during combined combat.
- Replaced the single `ImpactContactActor` latch with a shared multi-contact
  graph. Every touching pair owns one persistent `ImpactContactState`, and
  both bodies reference the same state until five true separation tics pass.
- Made connected contact graphs act as implicit physical islands: bodies can
  retain every simultaneous neighbour instead of overwriting an older pair.
- Added allocation-free sustained momentum transfer for already-latched
  contacts. Continued pressure propagates through a crowd without repeating
  impact trauma or recreating `ImpactBody` and `ImpactResult` every tic.
- Added one crushing evaluation per 35 sustained-contact tics. Its damage is
  exactly the existing collision result at the pusher's current walking speed,
  with both effective masses and the receiver's biological absorption applied.
- Replaced the four NPC homing elemental missiles with the existing explosive
  projectile model: straight flight, Statuette radius/direct-damage rules and
  the same absolute ten-second lifetime.
- Updated the physics debug line to report the player's active contact count.
- Kept the ten-second NPC-projectile lifetime unchanged.

## 4.28.0az — Render-linked wall backs and zero-size texture packaging fix

- Replaced `NOINTERACTION` on finite-wall reverse panels with non-solid `NOBLOCKMAP`, keeping the actor linked to its sector so GZDoom can render it from the rear.
- Preserved the 0.25-MU separation between the two visual faces and retained one collision owner.
- Tightened direct font families to kerning `-4`, added one more pixel to every word space and reduced each glyph canvas by one transparent right-hand column.
- Updated `FONTDEFS` word-space values so modern menu aliases no longer ignore the spacing configured by the font directories.
- Replaced the five classic Doom main-menu label patches with Spanish labels composed from `CaelumText`; those items were images and could not respond to font metrics.
- Added a deterministic PK3 builder that never emits directory entries, rejects empty files, validates non-zero PNG dimensions and verifies the resulting ZIP.
- Audited 3,166 PNG resources: every decoded successfully and every declared texture has positive dimensions; the concrete invalid resource in the supplied log was the zero-byte directory entry `sprites/caelum/weapons/`.
- Kept MAP02 at 937 actors because the reported fatal error is now an actionable texture/package failure rather than a non-diagnostic freeze.

## 4.28.0ay — Closed central connector ends, wider spaces and 937-actor step

- Preserved kerning `-3` and increased every bitmap family's `SpaceWidth` by two pixels.
- Identified the visible black strip as the open 64-MU ends of the obsolete central connector band, not the previously adjusted dividing-wall endpoints.
- Added one continuous 64-MU finite wall panel to the front and rear end of each central wing, closing all four openings only at first-floor height.
- Avoided infinitely tall blocking linedefs, preserving ground-floor traversal and keeping collision limited to the upper rooms.
- Reduced MAP02 from 1,875 to exactly 937 stress actors while preserving its complete enclosure and geometry.
- Kept the validated Debug profile at 90 and made no push/contact-island physics changes.

## 4.28.0ax — Exact central wall spans, tighter kerning and 1,875-actor step

- Tightened all Caelum bitmap families from kerning `-2` to `-3`, preserving every word-space width.
- Replaced the four 136-MU central first-floor wall segments with exact 140-MU spans, covering each boundary continuously from its exterior edge to the internal doorway.
- Repositioned the four segment centers by 2 MU so their endpoints meet the mansion geometry exactly without overlapping the 64-MU door openings.
- Reduced MAP02 from 3,750 to 1,875 stress actors without changing its vertices, linedefs, sidedefs, sector or enclosure size.
- Changed the Debug creation profile from 30 to 90 in all twelve attributes through the central creation constant.
- Made no change to push/contact-island physics and did not update the private/personal design document.

## 4.28.0aw — Direct transition, tighter type and 3,750-actor limit search

- Disabled MAP01's inherited Doom intermission; Exit now transitions directly to MAP02.
- Tightened every Caelum bitmap family from kerning `-1` to `-2` while preserving word-space widths.
- Separated the reverse visual face of finite first-floor walls by 0.25 MU on each horizontal axis, preventing coplanar depth rejection without adding collision.
- Added the existing 210×103 `CAMLOGO` project resource as a high-resolution `M_DOOM` replacement, preserving the menu's 132×65 logical layout.
- Preserved MAP02's complete 16,384×16,384 MU room and reduced its population from 7,500 to 3,750 actors: 250 of each NPC and Bull plus 2,500 Giant Rats.
- Made no change to push/contact-island physics and did not update the private/personal design document.

## 4.28.0av — Restored native menus and contrast-safe typography

- Removed the empty `MainMenu` override introduced in 4.28.0au; it replaced the native menu without declaring any selectable items.
- Preserved the Caelum logo through the `M_DOOM` replacement while restoring every native main-menu action.
- Kept a non-destructive `DefaultListMenu` style so project typography can apply without replacing menu contents or behavior.
- Increased ordinary text and console families by one point and added a one-pixel dark outline around bright glyphs for stable contrast.
- Reduced the large/intermission families from 15 to 12 points so the MAP01 completion screen remains proportionate.
- Produced a source-only patch and did not update the private/personal design document.

## 4.28.0au — Explicit Caelum menu, mirrored central rooms and reduced stress population

- Added explicit `MENUDEF` and `FONTDEFS` mappings so the main and configuration menus request Caelum typography instead of inheriting Doom II patches/fonts.
- Replaced the main-menu Doom II logo with the supplied Caelum Argenteum emblem after extracting a true transparent background.
- Assigned the official `TITLEPIC` as the credit page too, preventing the title loop from showing Doom II credits.
- Activated the reserved south-central 3D-floor sectors and mirrored the validated two-equal-room topology, including two exterior doors and one internal dividing door.
- Preserved the remote coordinate-30,000 geometry because it consists of required 3D-floor control sectors, not misplaced playable rooms.
- Kept MAP02's titanic enclosure unchanged while halving every population: 500 each of Rulo, Caella, Ronnie, Argento and Bull, plus 5,000 Giant Rats (7,500 actors total).
- Deferred every contact-island, continuous-push and crushing-damage change to the next physics patch.

## 4.28.0at — Two-sided finite walls and titanic MAP02 stress field

- Added a non-solid synchronized reverse face to finite first-floor wall panels, removing the interior transparency without duplicating blockers, contacts or collision mass.
- Increased all Caelum font roles moderately, changed compact/interface families to bold variants and enabled a standard shadow on gameplay HUD text.
- Replaced MAP02's seven small populations with one remote 16,384×16,384 MU enclosure reached through a two-turn sight-breaking corridor.
- Distributed 1,000 Rulo, 1,000 Caella, 1,000 Ronnie, 1,000 Argento, 1,000 Bulls and 10,000 Giant Rats at unique positions: 15,000 test actors plus the player start.
- Kept every test actor in ambush mode so neither sight nor remote sound activates the population from the initial chamber.
- Produced a source-only patch; no complete development PK3 or private/personal document update is part of this revision.

## 4.28.0as — Corrected room entrances and baseline-safe typography

- Closed the erroneous exterior opening placed on the same axis as the north-central dividing wall.
- Restored the two original 64-MU exterior doorways, one per room, and added one lateral sliding leaf to each.
- Preserved the separate internal 64-MU door in the midpoint wall; the pair now has two exterior entrances and one internal connection.
- Regenerated every Caelum glyph on a fixed-height transparent cell with a shared typographic baseline instead of top-aligning tightly cropped images.
- Reduced classic HUD font height from 18 to 10 pixels and assigned `CaelumMono` explicitly to the gameplay HUD and debug overlay.
- Added the GZDoom 4.14.2 modern aliases `NewSmallFont`, `NewConsoleFont`, `AlternativeSmallFont` and `AlternativeBigFont`, allowing menus and the modern console to use the supplied family.

## 4.28.0ar — Contiguous north-central room pair and global typography

- Rejected the 4.28.0aq central-room interpretation: the two rooms may not be joined by a third corridor-shaped space.
- Rebuilt only the north-central pair as a single 336×336 MU exterior volume divided into two equal 168×336 MU rooms.
- Added one finite internal dividing wall with a single 64-MU lateral door; the former narrow connector no longer exists as a room or passage.
- Kept the south-central and lateral rooms neutral for the next two-room validation patches.
- Integrated the supplied Unicode bitmap font family globally: `BigFont`, `SmallFont`, `ConsoleFont`, `IndexFont`, `CaelumDisplay`, `CaelumText`, `CaelumSmall` and `CaelumMono`.
- Added the supplied typography guide and the bundled DejaVu copyright/license notice.
- Recorded a successful full MAP02 stress test: every actor group converged and fought in the center, rats were killed through impacts, and no freeze occurred.

## 4.28.0aq — Central first-floor repair, authored music and isolated actor diagnostics

- Restored the native 3D floor, roof and wall controls for the four central MAP01 first-floor rooms, including the two missing 64×64 floor links; no finite actor-wall grid was reintroduced.
- Assigned `01` to the title screen and MAP01, and `02` to MAP02. Both files identify `marjaja197` as artist in their embedded metadata and carry the title `The Argentine Omen`.
- Marked all MAP02 test actors as ambush/deaf so a remote pistol shot cannot wake every room through the shared sound region before its individual test begins.
- Added a ten-second lifetime to NPC homing elemental projectiles. Previously their `Spawn` state looped indefinitely, allowing lost projectiles to accumulate after mass awakening.
- Preserved the seven isolated populations of twenty actors each and made no change to Impact Physics collision formulas or the current one-reference contact latch.

## 4.28.0ap — Restored rat test room and official title screen

- Restored twenty Giant Rats in a seventh isolated MAP02 room reached through its own sight-breaking zigzag corridor.
- Preserved the six 20-actor rooms from 4.28.0ao; MAP02 now contains 140 test actors plus the player start.
- Added the author-supplied 1920×1080 Caelum Argenteum image as the explicit `TITLEPIC` presentation screen.
- Recorded the strongest current freeze hypothesis: the one-reference contact latch loses pair state when dense moving bodies repeatedly overwrite both ends, causing unresolved pairs to allocate and resolve again without true separation.
- Changed no collision or Impact Physics behavior so the isolated rooms remain a controlled reproduction environment for the future multi-contact/island implementation.

## 4.28.0ao — Compartmentalized large-scale MAP02

- Superseded the unapplied 4.28.0an package and restored the Windows-safe source order under `src/graphics/caelum/textures/sewer`; no `src/textures` directory is created.
- Expanded MAP02 into a large connected test field with a central safe start and six distant rooms reached through sight-breaking dogleg corridors.
- Removed every Giant Rat from MAP02.
- Added twenty Training Dummies, twenty Rulo, twenty Argento, twenty Caella, twenty Ronnie and twenty Bulls: 120 test actors plus one player start.
- Confirmed geometrically that every actor starts on valid floor and that no room has direct line of sight to the player start.
- Connected MAP01's existing Exit to MAP02 through MAPINFO while preserving MAP01.wad byte-for-byte.
- Kept the native `CAF*` and `STF*` status-face lumps in the graphics namespace; their location cannot register them as equipment, so the reported face/equipment symptom remains a separate diagnostic item.

## 4.28.0am — Separate architecture and actor test maps

- Reserved MAP01 exclusively for mansion architecture and preserved its validated 4.28.0al actor-free state byte-for-byte.
- Added MAP02 as a single-sector flat actor test arena without 3D floors, doors, stations, pickups, finite panels or mansion geometry.
- Placed one player start, four Training Dummies, Rulo, Argento, Caella, Ronnie, one Bull and twenty active Giant Rats in separated test zones.
- Registered descriptive MAP01 and MAP02 names in MAPINFO; both remain directly accessible through the console.
- Established that architecture and actor systems must pass independent validation before they are recombined.

## 4.28.0al — Actor-free MAP01 architecture diagnostic

- Removed every MAP01 combatant and character: twenty Giant Rats, the Bull, Rulo, Argento, Caella, Ronnie and four Training Dummies.
- Removed the two now-unused barred diagnostic enclosures from 4.28.0ak, restoring the prior 498-vertex, 611-linedef and 1188-sidedef architecture.
- Preserved the player start, pickups, ammunition, consumables, crafting stations, sliding doors and all current first-floor architecture.
- Changed no Impact Physics, AI, Seal, inventory or first-floor implementation code.
- Establishes a clean architectural test after the freeze also occurred while `noclip` was active.

## 4.28.0ak — Isolated bull and rat collision enclosures

- Added two completely separate barred diagnostic enclosures to MAP01: one retains all twenty active Giant Rats and the other contains the Bull.
- Moved the Bull out of the rat crowd so its charge and mass displacement cannot create rat/rat or bull/rat contacts during the crowd test.
- Made every enclosure boundary player- and monster-blocking while keeping direct visibility through the bars.
- Preserved rat AI, bite damage 60, mass 10, `THRUSPECIES`, Bull behavior, Impact Physics and the current two-room first-floor construction state.
- Recorded that approaching with `noclip` did not initially reproduce the freeze, making physical contact the current diagnostic boundary without yet treating that observation as a final root cause.

## 4.28.0aj — Bilateral Impact Physics contact latch

- Rejected actor count and pursuit AI as the freeze cause after the stationary twenty-rat group still locked up following physical contact.
- Made player/actor and actor/actor contact checks bilateral: a pair is already resolved when either body retains the other as its active contact.
- Prevented repeated per-tic allocation of two `ImpactBody` objects and one `ImpactResult` for older simultaneous contacts whose player-side pointer had been replaced.
- Restored all twenty MAP01 actors to the normal active Giant Rat with pursuit and base bite damage 60.
- Removed the temporary stationary test subclass and DoomEdNum 18030.
- Preserved `THRUSPECIES`, mass 10, anatomy, collision rearm and all current mansion geometry.

## 4.28.0ai — Stable twenty-rat area-test subclass

- Identified the freeze boundary as simultaneous acquisition/chase by the complete twenty-rat group, independent of inventory opening.
- Added `CaelumGiantRatAreaTest`, a stationary but fully damageable Giant Rat subclass for deterministic mass-effect tests.
- Converted all twenty MAP01 crowd actors to DoomEdNum 18030 and left normal `CaelumGiantRat` registered at 18029.
- Preserved mass 10, approximately 40 cm height, all attributes at 1, quadruped anatomy, elemental status handling, Pain and Death.
- Normal Giant Rats retain pursuit and base bite damage 60; only the MAP01 stress-test crowd omits AI and melee.
- Added no first-floor rooms or architectural changes relative to 4.28.0ah.

## 4.28.0ah — Ground-floor ceilings and Giant Rat crowd stability

- Restored native 3D-floor slabs over all eight room footprints, returning the missing ground-floor ceilings without constructing additional upper rooms.
- Excluded both obsolete 64×64 central connector polygons so the corridor remains completely clear above and below.
- Added `THRUSPECIES` to Giant Rats to prevent the approximately twenty-rat test group from forming an expensive same-species collision pile while menus immobilize the player.
- Preserved rat/player collision, bite damage 60, mass 10, AI and area-effect eligibility.
- Kept upper walls and sliding doors restricted to the validated western pair; no second room pair is added.

## 4.28.0ag — Incremental first-floor rebuild, pair 1

- Rejected and removed the complete actor-surface first-floor reconstruction after the reported freeze beneath its central elevated span.
- Removed every upper finite floor, roof and wall panel and every upper sliding leaf except the two exterior double doors of the first room pair.
- Restricted the native 3D-floor targets to the two western rooms, one in each wing; the remaining upper polygons use untagged neutral sectors and produce no volume.
- Left the central corridor and stair landing completely free of upper actor bridges and blocker grids.
- Preserved the ground floor, Seal functionality, elemental effects and Giant Rat test group.
- Establishes the four-patch construction rule: exactly two rooms per manually validated patch.

## 4.28.0af — GZDoom 4.14.2 elemental-visual parser correction

- Changed the status-visual class parameter to `class<Actor>` and invoked the native static actor factory as `Actor.Spawn`.
- Corrects the `Call to unknown function 'Spawn'` parser failure reported at `CaelumElementalStatus.zs:192`.
- Preserves all 4.28.0ae gameplay, map, rat, effect-art and balance behavior.
- Updated README, public implementation/roadmap/asset documentation and the private design document.

## 4.28.0ae — Seal Channel effects, Giant Rat test group and first-floor rebuild

- Replaced the User2 reservation hook with an interruptible channel driven by the equipped Seal.
- Added exact T1/T2/T3 Adrenaline costs of 3/6/9 per tic (105/210/315 per second) and a 60-second cooldown after every completed or interrupted use.
- Channeling immobilizes the player and cancels Block, Aim, Reload, weapon charge and pending spell casts; ordinary attacks, movement, Tarot, racial/class hooks and inventory actions are suppressed.
- Added a channel-area actor with a base radius ten times the statuette explosion radius, scaled by the existing ability-range statistic.
- Fire continuously renews burn; Earth renews poison, 25% remaining movement and 50% remaining accuracy; Air pushes continuously with combined physical and magical power; Water calls one random lightning strike per second; Quintessence attracts continuously and expels on release.
- Water uses a 10,000-point total damage pool, modified by magical damage and divided between every valid actor inside an impact radius twice the base statuette explosion radius.
- Quintessence release uses `10 × (trapped total mass / expelled actor mass)` as radial launch speed.
- Target filtering includes living combatants, allies, neutral NPCs, corpses and projectiles, while excluding the channeler, inventory/pickups, stations, doors and architecture.
- Weather-dependent tier additions remain deferred to the Version 5 weather integration.
- Added Seal HUD feedback for equipped element/tier, active use and cooldown; the debug Adrenaline action now adds 100 and removes 10 seconds of Seal cooldown.
- Added the Giant Rat with quadruped anatomy, mass 10, approximately 40 cm height, all attributes at 1 and base bite damage 60; MAP01 contains an approximately twenty-rat group for area-effect tests.
- Added attached twelve-frame burn, poison, freeze and lightning visuals plus vertical and horizontal lightning sequences from the author-supplied atlas; visuals do not duplicate damage.
- Rebuilt the mansion first floor as two four-room wings around a clear stair landing, restored real 3D-floor floor/roof controls and corrected sliding-door axes; manual architectural validation remains pending.

## 4.27.0g — Intermediate stair closures, charged Block dash and gauntlet uppercut

- Closed the four gaps behind the intermediate staircase pairs with ordinary 8-MU-deep elevated sectors aligned to the room backs at `y=±640`.
- Replaced the four outer arena wall faces with the author-supplied large weathered cobblestone variant `CMWV01`.
- Moved the mansion atlas resources from the Windows-conflicting `src/textures` directory to `src/graphics/caelum/textures/mansion`; the root `TEXTURES` lump remains a file.
- Stopped the equipment menu from forcing the Armor/head category whenever it opens, so crafted Seals and Amulets remain selected and visible as their actual native item classes.
- Added a Giant Gauntlets secondary uppercut with exactly the primary attack's damage, range and Air cost, plus an equal vertical physical impulse on a successful damaging hit.
- Starting shield Block with a compatible weapon while the charged state is active now produces a forward dash at 150% of the character's current maximum run speed without consuming the charged attack.
- Restored the charged damage multiplier after localized hit recalculation so melee charge remains doubled at the final damage application stage.
- MAP01 now contains 198 vertices, 264 linedefs, 520 sidedefs, 76 sectors and 186 things.

## 4.27.0f — Charge HUD, jewelry selection, finite rear walls and mansion textures

- Added a centered HUD countdown while a melee/magical weapon is charging and during the remaining charged-potentiator window.
- After crafting an amulet or seal, the inventory selection now points to that exact jewelry item instead of retaining the default helmet category.
- Removed middle textures from the six rear-wall closure linedefs, preserving the validated lower wall faces without rendering duplicate wall patches in the air.
- Extracted 81 original mansion texture resources from the author-supplied atlas: exterior/interior/damaged/basement walls, foundations, ceilings, doors, stone/wood floors, carpets, exterior roofs, terrain, moldings and modular pool surfaces.
- Added the Version 5 transition to the roadmap: V5.0.0 begins with incremental modular source reorganization only after all pending Version 4 work is completed.
- MAP01 remains at 190 vertices, 248 linedefs, 488 sidedefs, 72 sectors and 186 things.

## 4.27.0e — Static charged-projectile classes for GZDoom 4.14.2

- Replaced the unavailable Actor `SetSize` call with three charged projectile subclasses whose collision dimensions and visual scale are defined in `Default`.
- Added charged variants for the standard, homing-book and explosive-statuette projectiles while preserving their inherited behavior.
- Corrects the `Unknown function SetSize` parser failure reported at `CaelumPlayer.zs:9061`.
- Preserves the intended `sqrt(2)` linear multiplier and doubled projectile area.
- Added no balance, map or external-asset changes relative to 4.27.0d.

## 4.27.0d — GZDoom 4.14.2 charged-projectile compatibility

- Replaced direct writes to the read-only Actor `Radius` and `Height` properties with native `SetSize` when scaling charged magical projectiles.
- Replaced component writes to `Scale.X` and `Scale.Y` with one complete vector assignment.
- Corrects the `GExpression must be a modifiable value` parser failure reported at `CaelumPlayer.zs:9057`.
- Added no balance, map or asset changes relative to 4.27.0c.

## 4.27.0c — Rear-wall restoration and contextual charged Reload

- Restored only the two finite structural wall strips beside the rear-room door, using the accepted V4.26.5r MAP01 baseline and leaving the rejected main gate and terrace experiments absent.
- Moved the four training dummies from the corridor center to the lateral test line at `y=-900`.
- Extended native Reload contextually: ranged weapons retain magazine reload; melee and essence weapons charge their next attack.
- Added a 2-second base charge modified by the live physical attack-speed or magical casting-speed duration multiplier, followed by a 3-second charged window.
- Charged attacks consume twice the normal Air or Anima and deal twice the normal damage. Charged magical projectiles and explosions use `sqrt(2)` linear dimensions, producing twice the area rather than four times the area.
- Movement during ranged Reload or weapon charging halves movement speed and halves reload/charge progress; standing still restores the live full rate.
- Pain and weapon switching cancel charging and the charged state. Starting an attack cancels shield Block.
- Ranged Fire with an empty magazine now requests Reload automatically when compatible ammunition remains in inventory.
- Rebuilt MAP01 as 190 vertices, 248 linedefs, 488 sidedefs, 72 sectors and 186 things.
- Added no external assets.

## 4.27.0b — MAP01 rollback to the pre-gate baseline

- Restored MAP01 byte-for-byte from V4.26.5r, the last version before any standalone or integrated main corridor gate.
- Removed the entrance gate, rear terrace connectors, three-room terrace partitions and every map-sector experiment added in V4.26.5s through V4.27.0a.
- Preserved the eight validated trap-door rooms, the locked NPC-room variant, three aligned staircase pairs, room/item placement and 186 things from V4.26.5r.
- Preserved all V4.27.0a input work, including ranged-only Reload, User1–User4 routing and the confirmed magic-weapon Zoom latch.
- Diagnosed the supplied GZDoom crash as a runtime access violation after successful script parsing and map startup, at player coordinates inside the new western terrace connector; no ZScript parse error was reported.
- Restored MAP01 to 186 vertices, 242 linedefs, 476 sidedefs, 70 sectors and 186 things with no invalid references or open conventional-sector boundaries.
- Added no external assets.

## 4.27.0a — Native input contract and conventional terrace partitions

- Began V4.27 by connecting native User1 to the racial-ability reservation hook and User2 to the Seal Channel reservation hook across physical, ranged and magic selector weapons.
- Kept Reload exclusive to ranged magazine reload; melee and magic weapons no longer reinterpret Reload as Channel.
- Preserved User3 for the equipped Tarot card and User4 for the class ability without inventing gameplay effects or balance values.
- Added localized Customize Controls entries for all four native User inputs.
- Applied the existing Zoom release latch to magic weapons as well, preventing held Zoom from toggling shield Block repeatedly.
- Removed all four self-referencing 3D-middle-texture terrace partitions introduced in 4.26.5w.
- Rebuilt each terrace connector from seven conventional closed sectors: two room extensions, two structural wall spans, two jambs and one finite retracting panel.
- Replaced the segmented western entrance frame with one closed continuous jamb sector on each side, removing its internal seam and transparent section.
- Rebuilt MAP01 as 252 vertices, 350 linedefs, 692 sidedefs, 103 sectors and 186 things; 26 bilateral platform-door activators and 63 roof targets remain intentional.
- Validated every sector as a closed degree-2 contour with no invalid references, duplicate segments, collinear overlap or non-vertex crossing.
- Added no external assets.

## 4.26.5w — Three-room terrace divisions and sealed entrance frame

- Restored four internal cross-walls across the north and south terrace connectors, dividing each formerly merged large zone into three similarly sized rooms.
- Added one centered 128-MU reusable trap door to every cross-wall, for four new bilateral repeatable connections between the rooms.
- Built the opaque wall spans as finite 3D middle textures under the 128-MU roof underside, without adding roof sectors or blocking traversal above the terrace.
- Rebuilt the two entrance-frame extensions at the same 128-MU floor height and roof-control ID as their jambs, closing the transparent frame sections without lengthening the gate.
- Preserved the uncovered central corridor, six staircase flights, existing room doors, locked NPC room, item positions and all 186 things.
- Rebuilt MAP01 as 256 vertices, 340 linedefs, 672 sidedefs, 93 sectors and 186 things.
- Validated all non-self-referencing sector contours as closed degree-2 boundaries, with no invalid references, duplicate segments, collinear overlaps or non-vertex crossings; deterministic regeneration produces the same SHA-256.
- Added no external assets or gameplay changes.

## 4.26.5v — Closed terrace topology and opaque entrance frame

- Fixed two open rear structural-wall contours whose dangling jamb connections allowed 3D-floor geometry to leak toward the Player Start.
- Restored the rear jamb connections to the correct adjacent stair sectors, closing both the stair polygons and the independent room-wall strips.
- Rebuilt the integrated corridor entrance frame as exact 16-MU jamb sectors plus separate 16-MU solid wall extensions instead of stretched 32-MU jambs.
- Added finite lower faces to every side of the jamb and extension polygons, eliminating the transparent frame section.
- Preserved the four rear terrace connectors, uncovered central corridor, door mechanisms, dummy row and all 186 things.
- Rebuilt MAP01 as 208 vertices, 284 linedefs, 560 sidedefs, 81 sectors and 186 things.
- Validated every one of the 80 non-exterior sectors as a closed degree-2 boundary, with no collinear overlap or non-vertex crossing.
- Added no external assets or gameplay changes.

## 4.26.5u — Integrated corridor entrance and continuous rear terrace

- Removed the isolated trap-door structure beside the Player Start.
- Rebuilt the unkeyed panel and frame directly into the true western corridor entrance at x=-593…-569, joining the two nearest rooms across the complete 192-MU passage width.
- Preserved the validated 128-MU retracting panel, 24-MU depth, bilateral repeatable USE and finite frame/roof behavior.
- Added four roofed connector sectors behind the two intermediate north/south staircase pairs, extending from y=±272 to the room backs at y=±640.
- Shared connector side boundaries with the existing rooms and shared their fronts with the 136-MU final steps, avoiding duplicate linedefs and closing the former small gaps.
- Kept the central corridor, all stair flights and their approach zones without a roof.
- Rebuilt MAP01 as 204 vertices, 278 linedefs, 548 sidedefs, 79 sectors and 186 things with 39 roof targets and no overlap or non-vertex crossing.
- Added no external assets or gameplay changes.

## 4.26.5t — Structural rear walls, compact entry gate and debug creation

- Replaced all stair-owned rear middle textures with two real 8-MU-thick room-wall sectors at floor height 136.
- Made the restored room walls visible from both interior and exterior, flush with the roof and traversable from the 136-MU final steps.
- Moved the standalone entry gate to 32 MU ahead of the Player Start while retaining only its 24-MU panel/frame depth.
- Moved all four training dummies off the central corridor into one southern test row at y=-900 without changing their x spacing.
- Added `Depuración` / `Debug` as a fifth race-page creation option that jumps directly to summary.
- Made the debug creation profile set all twelve attributes exactly to 30, body height to 1.8 m and base body mass to 100 kg.
- Rebuilt MAP01 as 198 vertices, 258 linedefs, 508 sidedefs, 75 sectors and 186 things with no scaled stair middle textures, overlap or non-vertex crossing.
- Added no external assets.

## 4.26.5s — Visible stepped rear walls and corridor trap door

- Replaced the invisible lower faces beside the rear stairs with individually scaled finite 3D middle walls from each tread to the 128-MU roof underside.
- Left both 136-MU final-step boundaries open so roof access remains unobstructed.
- Added a standalone reusable trap-door gate 104 MU in front of the Player Start at the beginning of the test corridor.
- Reused the validated 128-MU retracting floor panel, bilateral repeatable USE, 16-MU solid jambs and 128–136-MU finite roof slab.
- Kept the silver-key NPC-room door, training dummies and all 186 thing positions unchanged.
- Rebuilt MAP01 as 194 vertices, 252 linedefs, 496 sidedefs, 73 sectors and 186 things with 18 platform-door activators and no overlap or non-vertex crossing.
- Added no external assets or gameplay balance changes.

## 4.26.5r — Aligned staircase modules and restored rear walls

- Standardized all three north/south staircase pairs to exactly 119 MU wide, with starts separated by exactly 665 MU.
- Aligned every low step to the common corridor boundaries at y=±80 and every high step to y=±272.
- Centered the rear room on y=0 so its two front corners coincide with the final north and south steps.
- Restored the six rear-room staircase walls as finite lower wall faces that stop at each step height instead of projecting above it.
- Moved the western room pair 71 MU east and its contained pickups by the same translation, leaving a 1-MU conventional clearance beside the first staircase.
- Moved the eastern pair and its pickups 1 additional MU east; shifted the rear room 1 MU east to preserve the repeated 119/665-MU layout.
- Preserved 186 vertices, 242 linedefs, 476 sidedefs, 70 sectors and 186 things with deterministic regeneration and no invalid overlap or crossing.
- Added no external assets or gameplay balance changes.

## 4.26.5q — Complete NPC attributes and uniform corridor stairs

- Expanded `CaelumCombatActor` from eight combat attributes to the same twelve primary attributes used by player characters.
- Added current and maximum Anima to Caelum NPCs, using the player formula `10 × Type1(effective Patience)` after equipment and full initialization without changing the formula to Intelligence.
- Assigned complete authored layer values to Rulo, Ronnie, Argento and Caella; Caella's helmet adds +5 effective Intelligence while her separate +5 Patience gloves correctly raise maximum Anima to 3760.
- Added three complete north/south staircase pairs at uniformly separated x centers across the intermediate room corridors.
- Moved both eastern rooms and the rear room 24 MU east; moved every pickup inside the eastern pair by the same 24 MU.
- Removed the protruding wall middle textures from all six rear-room stair boundaries, not only the roof landing.
- Rebuilt MAP01 as 186 vertices, 242 linedefs, 476 sidedefs, 70 sectors and 186 things with no collinear overlap or non-vertex crossing.
- Added no external assets.

## 4.26.5p — Clear rear roof access and NPC-archetype audit

- Removed the finite wall face from the two 136-MU rear-stair landing boundaries, clearing both routes onto the rear-room roof while retaining the closed lower staircase sides.
- Registered the corrected solid jamb frame, retracting panel, continuous roof and sight-blocking doorway together as the definitive `habitación con puerta trampa` template.
- Audited the shared Caelum NPC combat model: eight primary combat attributes, health, lucidity, adrenaline, accuracy, critical chance, evasion, armor, pain, anatomy and impact physics are active.
- Recorded Constitution, Charisma, Empathy, Eloquence and Anima as required gaps before the combat actor can serve as the complete non-survival NPC archetype.
- Added no external assets and changed no NPC balance values.

## 4.26.5o — Solid door frames, flush stairs and mounted exit

- Converted all sixteen auxiliary jamb sectors into solid finite 128-MU frame pillars.
- Added finite lower wall faces to the frames, closing lateral sight around every trap door without introducing middle-texture strips.
- Shared the rear staircases' eastern edges directly with the rear-room wall and reduced their western clearance to 1 MU.
- Integrated the NPC exit switch into a 128-MU segment of the room's western wall at x=-2464 instead of leaving a freestanding line at x=-2448.
- Preserved all eight trap-door mechanisms, the NPC silver lock, all roof targets, items and shifted dummy positions.
- Updated MAP01 to 130 vertices, 166 linedefs, 324 sidedefs, 46 sectors and 186 things with no overlaps or non-vertex crossings.
- Added no external assets or balance values.

## 4.26.5n — Reusable one-trap-door room replication

- Registered the validated architecture as the reusable `habitación con 1 puerta trampa` / one-trap-door room template.
- Rebuilt all eight MAP01 rooms with finite walls, independent retracting floor doors and solid walkable 3D-floor roofs.
- Oriented the four central, two eastern and rear-room doors toward their corresponding corridors.
- Preserved the NPC-room silver lock through UDMF `locknumber = 200` on both platform-door thresholds.
- Removed the provisional east staircase and raised block.
- Added two lateral six-step staircases beside the rear room's west-facing front, reusing heights 24/48/72/96/120/136 MU.
- Preserved all item positions and shifted the four training dummies 128 MU toward the player start.
- Rebuilt MAP01 as 132 vertices, 167 linedefs, 326 sidedefs, 46 sectors and 186 things with no collinear overlaps or non-vertex crossings.
- Added no new external assets or balance values.

## 4.26.5m — Door partition texture cleanup

- Removed the sixteen middle-texture assignments from the auxiliary jamb partitions and their exterior counterparts.
- Removed 3D-middle-texture flags from the two moving-door side boundaries.
- Retained `BIGDOOR2` only as finite lower textures generated by the 0–128 MU door-floor difference.
- Preserved the validated retracting door, continuous walkable roof, topology and gameplay behavior.
- Added no external assets or balance values.

## 4.26.5l — Independent finite door and continuous roof

- Replaced the door ceiling action with a finite 128-MU raised-floor panel using `Plat_DownWaitUpStay`.
- Kept the doorway's base ceiling at 512 MU so the roof slab retains valid playable space above it in every door state.
- Applied the roof target to the door and both jamb sectors, keeping the upper surface continuous across the complete entrance.
- Moved the visible `BIGDOOR2` panel from upper textures to the correct lower textures for raised-floor geometry.
- Preserved bilateral repeatable USE, speed 16, the 150-tic wait and the existing room dimensions.
- Superseded the 4.26.5k ceiling-limiter solution, which still coupled the moving door ceiling to the roof space.

## 4.26.5k — Finite framed template door

- Added two narrow structural jamb sectors beside the template-room door.
- Set their ceiling reference to 132 MU so the existing `Door_Raise` four-unit clearance opens exactly to the 128-MU roof underside.
- Prevented the door from deriving its raised position from the 512-MU outdoor sky and appearing infinitely tall.
- Preserved the existing 128-MU doorway, two-sided manual USE, repeat-special behavior, speed, delay and walkable roof.
- Added no scripts, gameplay balance values or external assets.

## 4.26.5j — Unified shield framing and true walkable room roof

- Standardized Buckler, Kite, Tower and Magic Shield Block layers on the validated medium Kite framing: left-offset, 210×230 virtual pixels.
- Preserved the Magic Shield's translucent halo without returning it to the center of the screen.
- Replaced the template room's low conventional sector ceiling with a solid `Sector_3DFloor` slab from 128 to 136 MU.
- Raised the room's base ceiling to the 512-MU outdoor sky so the upper side of the slab is a real playable space.
- Applied the roof target to both the room interior and door recess, covering the complete module footprint.
- Added a closed off-map control sector and one initialization special without external scripts or assets.
- Preserved finite wall midtextures, the six-step 136-MU access platform and repeatable two-sided `Door_Raise` activation.

## 4.26.5i — Equipped shield first-person Block layer

- Added a first-person HUD shield layer that appears only while contextual Zoom Block is active.
- Reused the equipped Buckler, Kite, Tower and Magic Shield project sprites; no new external assets were added.
- Differentiated provisional shield framing: Buckler centered/lower, Kite left and broad, Tower very large on the far left, and Magic Shield centered with a translucent halo layer.
- Kept the active weapon visible underneath the modular shield layer.
- Recorded Fly lateral control, ranged visual Zoom and Dexterity-scaled Reload as user-validated.

## 4.26.5h — Zoom input latch, Fly lateral movement and roof diagnosis

- Added one-action-per-press latching to the contextual Zoom input.
- Prevented a held Zoom key from repeatedly toggling ADS or Block.
- Rearmed Zoom only after the native `BT_ZOOM` button is released.
- Allowed the movement-acceleration layer to treat native `NOGRAVITY` Fly as continuously supported movement.
- Preserved airborne momentum rules for ordinary jumps.
- Documented why the adjacent stair block is walkable while the current room ceiling is not: the block is a raised floor sector, whereas a normal sector ceiling has no walkable upper surface.
- Deferred the room roof conversion to a true solid 3D-floor slab so it can retain both an interior and a walkable roof.

## 4.26.5g — Upper-wall removal, true repeatable door and live Dexterity reload

- Removed the upper `STARTAN3` textures that continued above the finite room-wall middle textures.
- Corrected both door thresholds from the ignored custom field `repeatable` to the valid UDMF field `repeatspecial`.
- Preserved front/back USE support and the existing `Door_Raise` speed and delay.
- Confirmed ranged Aim/ADS multiplies effective physical accuracy by ×2 and continues to stack with crouching ×2.
- Recalculated ranged Reload duration from current effective Dexterity whenever Reload begins: `base seconds × 100 / Type-4 attack-speed percent`.
- Preserved the 3/3/5/5-second base durations and introduced no new balance values.

## 4.26.5f — Finite room walls, repeatable door and contextual ranged Zoom

- Replaced the template room's infinitely wrapped middle textures with bottom-pegged finite 3D middle textures.
- Removed the permanent full-height blocking flag from those seven finite wall/jamb textures.
- Enabled back-side USE activation on both repeatable `Door_Raise` thresholds.
- Made Zoom contextual: ranged weapons toggle real ×2 ADS/FOV zoom, while only shield-compatible weapons can enter Block.
- Prevented ranged and other two-handed physical weapons from blocking through an equipped shield.
- Preserved ranged AltFire as an alternate Aim input.
- Added a live HUD line for loaded magazine, capacity, reserve ammunition and Reload countdown.
- Added no new assets or balance values.

## 4.26.5e — Bilateral wall rendering, dual-use door and ranged ammunition

- Added explicit wrapped middle textures to both sides of the five template-room walls and two jambs.
- Preserved bilateral room/exterior sector ownership and solid wall collision.
- Added the manual `Door_Raise` special to the inner threshold, allowing USE from inside and outside.
- Added an explicit pickup amount of 20 to carbine ammunition, arrows and bolts.
- Made the loaded magazine the immediate ranged-fire ammunition source.
- Prevented reserve-stack location/exhaustion from invalidating an already loaded projectile.
- Preserved manual Reload, magazine capacities, Reload durations, Air costs, damage, spread and critical formulas.

## 4.26.5d — Visible room, usable door and environmental Adrenaline correction

- Converted the five template-room perimeter walls into bilateral room/exterior lines.
- Added exterior sidedefs and finite upper textures so the room renders from the field.
- Converted both door jambs into bilateral door/exterior boundaries.
- Reversed the outer door line so exterior sector 0 is its front and door sector 5 is its back.
- Removed the door line's permanent blocking flag so `Door_Raise` can create a passable opening.
- Preserved room, door, stairs and platform dimensions.
- Added an explicit Pain-Adrenaline permission to player and Caelum NPC pain processing.
- Disabled Pain Adrenaline for wall and floor impacts while preserving health loss, Pain/stun and actor-impact Adrenaline.
- Changed no impact-energy, Toughness, armor, anatomy or acceleration formulas.

## 4.26.5c — Final stair front side and input-roadmap audit

- Removed the two orphan sidedefs left by the template-door correction.
- Remapped all subsequent sidedef references into a compact 154-sidedef map.
- Reversed linedef 82 together with its side assignments, preserving geometry while exposing exterior sector 0 as the explicit front.
- Preserved the sixth stair's sector 12, height, dimensions and textures.
- Corrected the roadmap to preserve the implemented Zoom Block, ranged AltFire Aim and ranged Reload systems.
- Reserved User1 for racial ability, User2 for Seal Channel, User3 for Tarot and User4 for class ability.
- Reframed V4.27 as completion/validation of the existing input architecture rather than a destructive remapping.

## 4.26.5b — Canonical MAP01 topology and roadmap reconciliation

- Removed four provisional appended sidedefs from the architectural template experiment.
- Removed explicit negative back-side placeholders from the one-sided door lines.
- Reconnected the door to its canonical sidedef indices and consistently oriented the three one-sided door boundaries.
- Restored the original room-front/door-back threshold sidedef pair.
- Addressed the engine-reported front-sector/front-sidedef failures on lines 53, 54 and 82 and the disconnected right edge on line 52.
- Added `docs/ROADMAP.md`, reconciling the old crafting/economy/NPC roadmap with the current partial implementations.
- Added the initial V4.27 input-remapping draft; V4.26.5c supersedes that draft after auditing the already implemented Zoom Block, ranged AltFire Aim and ranged Reload behavior.
- Initially proposed a dedicated racial-action key; V4.26.5c supersedes it by reserving the actually available User1 input for racial ability.
- Changed no combat physics, balance values, crafting formulas, room dimensions or external assets.

## 4.26.5a — Architectural template topology correction

- Removed invalid room-sector back sides from the two template door jambs.
- Restored the outer manual door line as a one-sided boundary of the door sector.
- Reoriented the jamb and outer door linedefs into one continuous clockwise door-sector loop.
- Corrected the inner threshold orientation so its front faces the room and its back faces the door sector.
- Restored closed directed boundaries for the room and door sectors.
- Removed the structural cause of the node-builder `line 54 has no front side` error.
- Preserved the existing `Door_Raise` special, dimensions, textures, stair geometry, physics and gameplay systems unchanged.

## 4.26.5 — Architectural template room

- Returned MAP01 structural experimentation to the last known loadable safe map.
- Added one isolated building template for controlled validation instead of modifying all seven structures at once.
- Added a standard room sector with a 136-MU ceiling.
- Added a 128-MU-wide doorway with side jamb geometry.
- Added an unlocked classic vertical door using manual `Door_Raise` on player USE.
- Added a separate 136-MU raised roof-access platform.
- Added six isolated stair sectors at 24, 48, 72, 96, 120 and 136 MU.
- Kept V4.26.4 crouch wall damping, Stealth movement-noise and buckler behavior unchanged.

## 4.26.4 — Crouched impact damping, movement noise and finite test buildings

- Crouching now enables Agility-derived biological damping for wall collisions.
- Crouched wall damping uses the calibrated horizontal Agility-bonus fraction; it does not subtract raw JumpZ units.
- Buckler and crouch wall damping do not stack: the larger active fraction is used.
- Physical/Lucidity stun disables crouched and buckler Agility damping.
- Added `StealthPercent` as the documented Type-2 derivative of Agility.
- Existing crouch x2 Stealth bonus now applies to the effective Stealth percentage, capped at 100%.
- Movement-hearing noise is multiplied by `(1 - EffectiveStealth/100)`; 100% Stealth produces no movement SoundAlert.
- Walking uses the 20 m reference hearing range; running x1.5; crouching x0.5, before Stealth reduction.
- Rebuilt all six test rooms and the NPC room using finite raised-floor wall sectors rather than infinitely blocking middle textures.
- Added a shared solid 3D-floor roof slab at 128–136 MU to all room interiors.
- Added two lateral six-step staircases reaching 136 MU for roof access.
- Preserved 512-MU exterior height, categorized item distribution and reduced shield duplicates.

## 4.26.3b — Buckler calibration and MAP01 structural rebuild

- Fixed buckler horizontal damping producing `Delta-v = 0` and effectively infinite equivalent tics.
- Horizontal buckler damping now uses the Agility-derived jump **bonus**, doubled by the buckler, as a fraction of horizontal trauma rather than subtracting raw JumpZ units.
- Capped buckler horizontal acrobatic damping at 50% of physical Delta-v; momentum/displacement remain unchanged.
- Floor damping remains direct JumpZ-based and still doubles with active buckler block.
- Debug overlay now separates physical `RawDV`, post-acrobatics `TraumaDV` and absorbed amount.
- Fixed seals and amulets being tossed upward when dropped; horizontal toss remains, vertical velocity begins downward.
- Rebuilt MAP01 rooms from the clean pre-roof geometry.
- Replaced infinitely wrapped blocking room walls with finite `midtex3d` walls.
- Added genuine solid 3D-floor roof slabs (128–136 MU), making the roof top physically walkable.
- Added a six-step exterior roof-access staircase.
- Corrected both new room entrances to face the central corridor.
- Preserved the 512-MU outdoor ceiling/exterior wall height.
- Redistributed pickups into six rooms by type and removed 16 redundant shield pickups.
- Kept the west NPC room on the same finite-wall/3D-roof system while preserving its existing door assembly.

## 4.26.3 — Buckler acrobatics and fall-test map

- Buckler block doubles collision Toughness.
- Buckler block doubles Agility/JumpZ impact absorption and extends it to horizontal actor/wall trauma.
- Stun disables the Agility absorption, including the buckler bonus.
- Momentum, 0.5× buckler effective mass and displacement remain unchanged.
- Added two equal MAP01 test rooms.
- Roofed the four original rooms, two new rooms and west NPC room at 128 MU.
- Raised outdoor ceiling/exterior wall height from 256 to 512 MU for fall testing.

## 4.26.2 — Universal impact scale and weighted anatomical response

- Replaced actor-height-dependent equivalent-time severity with a universal 28-map-unit reference distance.
- Individual height no longer directly reduces/increases kinetic severity; mass continues to affect impulse and Delta-v.
- Kept `ImpactBody.Height` as neutral geometry metadata rather than an energy multiplier.
- Extended generic `ImpactResult` with source/target normalized vertical contact intervals.
- `ResolveBodies` derives those intervals from the vertical overlap of the two generic bodies.
- Caelum integration converts contact intervals into normalized anatomy-region weights.
- Collision vulnerability is now weighted by contacted-region proportion.
- Collision armor defense is now localized and weighted by the same proportions instead of using global average armor.
- Collision Lucidity loss is weighted by critical/head contact share and localized head armor.
- Floor impacts use bottom-point contact; vertical static geometry uses full-height contact until the engine can provide more precise Z contact data.
- Player biological landing damping remains based on current JumpZ/Agility.
- NPC biological landing damping now derives from CombatAgility Type-1 jump scaling rather than body height.
- Updated debug telemetry with contact band, weighted vulnerability, weighted armor, head-contact share and collision Lucidity loss.

## 4.26.1 — Impact response refinement

- Changed collision Toughness from multiplicative mitigation to subtractive maximum-HP percentage-point tolerance.
- New impact order: energy severity × surface multiplier -> subtract Toughness percentage points -> convert remaining percentage to HP -> apply global armor defense.
- Toughness 100 is no longer absolute immunity: a 200% raw collision still leaves 100% max-HP severity before armor.
- Added a 25% minimum lost-horizontal-speed fraction for static geometry impacts; lower values are treated as grazing/sliding contact.
- Added a five-clear-tic static-contact rearm latch to prevent repeated wall damage from collision-state flicker in narrow spaces.
- Removed generic damage Adrenaline gain from wall and floor impacts.
- Actor-to-actor collision damage still grants the normal received-damage Adrenaline response.
- Updated impact debug telemetry to display Toughness in percentage points and post-Toughness severity.

## 4.26.0 — Impact Physics Core API

- Extracted generic impact mathematics into `impactphysics/ImpactPhysics.zs`.
- Added project-neutral `ImpactBody` and `ImpactResult` data structures.
- Added `ResolveBodies` for two finite-mass moving bodies.
- Added `ResolveStatic` for the infinite-mass static-geometry limit.
- Added `ResolveExternal` as an integration point for moving hazards that are not conventional Caelum actors.
- Refactored CaelumPlayer and CaelumCombatActor actor collisions to use the shared core solver.
- Removed the provisional V4.25.2 player-wall severity calibration based on EffectiveMovementPercent.
- Walls and doors now derive a normal from the velocity actually lost during the engine movement step and use the same static-impact core path.
- Delegated equivalent-tic and kinetic-energy severity calculations to the core, removing duplicated Caelum implementations.
- Preserved V4.25.4 energy curve, acceleration, contact rearm, biological damping, Toughness and armor response unchanged.
- Prepared the architecture for future standalone `ImpactPhysics.pk3`, rolling rocks, avalanches, rams, catapults and moving-map hazards.

## 4.25.4 — Energy impact curve and robust contact rearm

- Replaced the discrete 3%-per-equivalent-tic collision damage staircase with a continuous kinetic-energy-shaped curve.
- The new curve uses specific kinetic energy (`E/m ∝ Delta-v²`) so mass remains in the impulse/momentum solution and is not double-counted in injury severity.
- Normalization points: 35 equivalent tics = 0% raw max-HP damage; 1 tic = 100%.
- The curve continues naturally below one tic: ~156% at 0.8 tics, ~400% at 0.5 tics, ~1600% at 0.25 tics, before biological/Toughness/armor mitigation.
- Removed the previous 105% hard cap from the active impact-damage calculation.
- Strengthened actor-contact rearm: separation must exceed combined radii plus 25% of the smaller reference height.
- Required that separation to persist for 5 consecutive tics before the pair can generate a new collision impact.
- Added debug display for contact separation progress and the active `v²` energy curve.

## 4.25.3 — Acceleration, contact latch and biological damping

- Added exponential player acceleration. Continuous grounded movement reaches exactly 95% of its currently available maximum after 3.0 seconds.
- The acceleration factor multiplies the existing Caelum movement result instead of replacing Agility/load/status/shield calculations.
- Wall-impact severity now includes the current acceleration factor, so a half-step approach and a long run no longer carry the same self-powered wall momentum.
- Added actor-pair contact latching: one confirmed collision produces one impulse/impact until the bodies physically separate.
- Added biological landing damping before Toughness and armor.
- Player biological landing absorption equals the current normal `JumpZ`, making ordinary controlled jumps naturally safe.
- Physical stun/immobilization removes player landing absorption, so a stunned body lands rigidly and can take substantially more floor-impact damage.
- Caelum NPC biological landing absorption scales as `8 × sqrt(Height / 56)` and becomes zero while lucidity-stunned.
- Added debug telemetry for acceleration, contact latch, raw delta-v and biological absorption.

## 4.25.2 — Impact mitigation and calibration

- Added Toughness mitigation to `CaelumImpact` using the existing Caelum body-resistance curve.
- Added global impact armor defense as the mean defense of all four functional armor slots.
- Kept impact trauma non-localized: no evasion and no shield Block interception.
- Switched player impact-height normalization to stable `DerivedStats.ActorHeight`.
- Reworked landing detection to preserve the last falling vertical speed across tics and detect airborne-to-grounded transitions reliably.
- Normalized self-powered player wall impacts against `EffectiveMovementPercent`; a complete stop at 100% movement maps to the 35-tic threshold.
- Added wall-contact latching so holding forward against a wall does not repeatedly deal impact damage.
- Made the training dummy movable, set its mass to 10000, and added it to the Caelum momentum collision whitelist.
- Documented the exact Rulo/Caella/Ronnie/Argento combat profiles and their current T1 armor.
- Ordinary Doom actors remain outside the Caelum collision adapter pending a generic-actor design.

## 4.25.1 — Momentum collision and impact physics

- Corrected Carbine base Reload from 10 s to 5 s; ranged Reload bases are now 3/3/5/5 s.
- Added action/reaction actor collisions through GZDoom `CollidedWith()`.
- Added effective-mass two-body impulse resolution using a coefficient of restitution of 0.0.
- Added independent `Delta-v` impact evaluation for both collision participants.
- Added the universal half-height equivalent-time damage rule: over 35 tics = 0 damage; each step down to 1 tic adds 3% max-HP damage, capped at 105%.
- Added experimental wall-impact detection from before/after horizontal velocity on blocked world movement.
- Added landing/fall impact detection from before/after vertical velocity.
- Added a future-facing `CollisionDamageMultiplier` surface parameter for spikes and similar contact effects.
- Added compact impact telemetry to the debug overlay.
- Added `docs/PHYSICS_COLLISION_SYSTEM.md` with the full real-physics basis, gameplay conventions, formulas, engine integration and planned extensions.

## 4.25.0 — Ranged weapon architecture and balance

- Added dedicated magazines: 50 rounds for Standard Bow and Longbow, 20 for Crossbow, 10 for Carbine; capacities are identical across tiers.
- Added timed Reload for the ranged family. Base times are 3 s for both bows, 5 s for Crossbow, and 10 s for Carbine, divided by Dexterity Type-4 attack speed.
- Changed ranged AltFire to a persistent Aim toggle. Aim grants ×2 physical accuracy and stacks multiplicatively with crouching ×2.
- Kept native Zoom as the independent shield Block input, avoiding the previous input conflict.
- Rebalanced ranged damage to a dedicated T1/T2/T3 scale of 100% / 160% / 250%, then increased all four ranged T1 base damages ×10: Standard Bow 1200, Longbow 1800, Crossbow 1400, Carbine 3600.
- Ranged base critical chance now follows the same tier scale. T1 bases are Standard Bow 10%, Longbow 12%, Crossbow 8%, Carbine 6%.
- Restored the authoritative seven-level spread ladder (10/30/50/70/90/110/130° maximum; minimum = 10%). Standard Bow moved two tiers to Very High (110°), Longbow to Medium (70°), Crossbow to High (90°), and Carbine remains Maximum (130°).
- Audited documentation against executable equipment data, including all physical-weapon values and definitive shield T1 weights (Magic 4, Buckler 8, Kite 12, Tower 16).
- Updated README, implementation status, asset register, and private design documentation to preserve these balance values as authoritative project data.

## 4.23.4 — Jewelry and seals

- Added universal amulets and seals, jewelry crafting, bonuses, sprites, and MAP01 test objects.
- Added raw ruby, sapphire, emerald, topaz, opal, copper ingot, tin ingot, and coal as reserved future materials; they currently have no recipe function.


## 4.23.3a — Unified recipe field declaration fix

- Added the five missing `CaelumPlayer` fields used by the 4.23.3 unified
  recipe system: recipe kind, armor type, armor slot, essence weapon type,
  and essence type.
- No recipe formulas, material ratios, infrastructure requirements, MAP01,
  sprites, or input behavior changed.


## 4.23.3 — Armor and essence crafting recipes

- Expanded the unified Workbench list from 16 to 52 recipes:
  16 physical weapons, 16 armor pieces, and 20 imbued essence weapons.
- Added armor recipes for Magic, Light, Medium, and Heavy armor across Head,
  Body, Hands, and Feet.
- Armor always uses Strap as the base material. Magic uses Fabric, Light uses
  Leather, Medium uses Chainmail, and Heavy uses Plate as the tier material.
- Head and Body recipes use 20% base / 80% tier material by final weight.
  Hands and Feet use 60% base / 40% tier material.
- Magic and Light armor use Armor Workshop + Sewing Machine; Medium and Heavy
  use Forge + Anvil. Tier 3 additionally requires the Master Bench.
- Added twenty essence recipes: Staff, Bell, Book, and Statuette, each with
  Fire, Water, Earth, Wind, or Quintessence.
- Essence recipes retain the documented 90% weapon-base / 10% essence weight
  split. Their infrastructure is Essence Altar at tier 1, plus Globe at tier
  2, plus Master Bench at tier 3.
- Existing material spawning, transactional consumption, Magic Box routing,
  tier/size weight scaling, and the validated station-use latch are reused
  rather than duplicated.


## 4.23.2j — Self-contained station activation hotfix

- Repackaged the station activation fix with both required source files:
  `CaelumPlayer.zs` now includes the `CraftingStationUseLatched` field and
  rearm logic, while `CaelumCraftingStation.zs` contains the real-`BT_USE`
  activation guard.
- This removes the hidden dependency on having applied 4.23.2h before
  4.23.2i.
- No MAP01, TEXTURES, sprite, recipe, or crafting-network changes.


## 4.23.2i — Require real Use for station activation

- Confirmed from menu-state behavior that `Q` was closing crafting and the
  focused station was immediately reopening it. Reopening resets only the
  recipe index to Dagger while preserving tier and size, matching the observed
  regression exactly.
- `CaelumCraftingStation.OpenForActivator()` now requires the activator's
  current command to contain `BT_USE`. Activate/Deactivate reentries caused
  while pressing `Q` are therefore ignored.
- The existing per-player Use latch remains as protection against repeated
  activation during one physical Use press.
- No cooldown or arbitrary timing value was introduced.


## 4.23.2h — Crafting station Use latch

- Added a station-specific Use latch. The station that opens crafting consumes
  that activation and ignores further `+USESPECIAL` activations from the same
  player while crafting remains open.
- The latch rearms only after crafting has closed and the player command shows
  `BT_USE` released. This prevents a station under the crosshair from reopening
  immediately after `Q` closes the menu.
- The fix is local to crafting interaction and does not use a global UI
  processor or change MAP01, sprites, TEXTURES, or crafting-network rules.


## 4.23.2g — UserCmd field-write parser fix

- Replaced the unsupported whole-structure assignment
  `player.cmd = creationCommand` with direct writes to the native UserCmd
  fields (`forwardmove`, `sidemove`, `upmove`, and `buttons`).
- The intent remains unchanged: suppress residual `BT_USE` while custom menus
  are open so a station cannot immediately reopen after `Q`.
- No crafting rules, MAP01, sprites, TEXTURES, or station-network logic changed.


## 4.23.2f — Station reactivation fix

- Fixed `CaelumPlayer.PlayerThink()` menu command suppression. The sanitized
  `UserCmd` was previously modified only as a local copy and never assigned
  back to `player.cmd`.
- While character creation, equipment, or crafting UI is open, the cleared
  command is now written back before `Super.PlayerThink()`.
- This prevents the original held `BT_USE` from immediately reactivating the
  station after `Q` closes crafting while the player is still looking at it.
- No crafting rules, network distances, MAP01, sprites, or TEXTURES changed.


## 4.23.2e — Crafting Q input fallback

- Added `InputEvent.KeyString` as a fallback for the crafting close key.
  `KeyChar` may be empty or unstable immediately after station interaction;
  `KeyString` is derived from the key scan and avoids requiring Escape or a
  successful craft before `Q` is recognized.
- No UI processor, MAP01, crafting-network, sprite, or TEXTURES changes.


## 4.23.2d — UI processor rollback

- Removed `CaelumCraftingUIInput` and its global `IsUiProcessor` registration.
  The processor interfered with the character-creation UI from map start and
  could leave the game without responsive controls.
- Restored the stable 4.23.2 `CaelumDebugOverlay` input path.
- Kept the complete MAP01 DoomEdNum restoration, validated sprite offsets,
  station artwork, crafting-network logic, and ranged-workshop changes.
- The post-station `Q` close issue is reopened and will be solved without a
  global UI processor.


## 4.23.2c — GZDoom 4.14.2 UI override parser fix

- Fixed `CaelumCraftingUIInput.UiProcess` overriding syntax. The inherited
  virtual already carries UI scope, so the override now uses
  `override bool UiProcess(UiEvent e)` instead of attempting to redeclare
  the scope.
- No crafting rules, MAP01 geometry, sprite alignment, or network logic changed.


## 4.23.2b — Regression fix for gallery sprites and crafting close input

- Restored the complete validated `TEXTURES` alignment set from 4.22.4c,
  including the corrected training-dummy path and explicit offsets for world
  weapons, armor, shields, materials, ammunition, consumables, and key items.
- Preserved the twelve dedicated crafting-station sprite definitions from
  4.23.2.
- Added `CaelumCraftingUIInput`, a dedicated UI event processor that receives
  `UiProcess` events while GZDoom routes keyboard input to its GUI. Pressing
  `Q` now sends the normal crafting close network event even when
  `menuactive` is non-zero.
- Kept the full MAP01 `DoomEdNums` restored in 4.23.2a.


## 4.23.2 — Crafting station art and menu-input fix

- Added dedicated project sprites for all twelve crafting infrastructure
  actors and removed their temporary weapon/equipment visual placeholders.
- Processed the author-supplied source cards into transparent 128×128
  in-world sprites, removing title plaques and baked checkerboard backgrounds
  where present.
- Added station sprite definitions and offsets to `TEXTURES`.
- Fixed crafting input capture so `Q` can close the crafting interface
  immediately after interacting with a station even when GZDoom still reports
  `menuactive`.
- Kept the 4.23.1 connected-network rules, two-metre links, cumulative tier
  requirements, and sixteen physical recipes unchanged.


## 4.23.1 — Crafting network parser fix and ranged workshop

- Fixed the missing `CaelumPlayer` declarations for crafting-network
  capabilities, scan token, selected infrastructure availability, and missing
  station state. These omissions prevented 4.23.0 from parsing.
- Moved the `hasPrimaryStation` local declaration to the start of
  `OpenCraftingNetwork()` for GZDoom 4.14.2 compatibility.
- Renamed Bow Workshop to Ranged Weapons Workshop in code, localization,
  editor mapping, UI, and collaborator documentation.
- Added the carbine as the fourth Ranged Weapons Workshop recipe. The unified
  Workbench menu now exposes all sixteen authoritative physical weapons.
- Ranged-weapons tier requirements are cumulative: Workbench + Ranged Weapons
  Workshop at tier 1, plus Sawmill at tier 2, plus Master Bench at tier 3.


## 4.23.0 — Connected crafting infrastructure

- Reworked crafting stations into a proximity network with an exact maximum
  link distance of 64 map units (2 development metres). Connectivity is
  transitive: stations do not need to be within two metres of the workbench
  itself as long as every link in the chain remains within the limit.
- Made the Workbench the logical root of the crafting interface. Interacting
  with any station in a connected network resolves the same workbench menu;
  an isolated auxiliary station reports that a workbench is missing.
- Added seven infrastructure actors: Anvil, Sawmill, Sewing Machine, Globe,
  Jeweler Bench, Fine-tools Bench, and Master Bench. Together with Forge,
  Bow Workshop, Armor Workshop, Essence Altar, and Workbench this produces
  twelve physical crafting actors.
- Made every crafting station inherit `CaelumMovableProp`. Mobility remains
  intentionally disabled because station mass and physical-power requirements
  have not yet been authored; this keeps the actors compatible with the future
  movable-world-object system without inventing balance values.
- Added cumulative tier requirements. Current metal recipes need Workbench +
  Forge at tier 1, add Anvil at tier 2, and add Master Bench at tier 3.
  Current bow/crossbow recipes use Workbench + Bow Workshop, add Sawmill at
  tier 2, and add Master Bench at tier 3.
- Prepared the same infrastructure model for Armor Workshop + Sewing Machine,
  Essence Altar + Globe, and Jeweler Bench + Fine-tools Bench. Their recipe
  families remain pending rather than receiving invented recipes.
- Unified the fifteen currently playable physical recipes in the Workbench
  menu and added a visible infrastructure-ready/missing requirement line.
- Expanded MAP01 with a complete connected network, a tier-1 metal test
  cluster, a tier-2 metal test cluster, and an isolated forge for missing-
  workbench validation.
- Kept the carbine crafting station unresolved; no station assignment was
  invented.


## 4.12.0

- Added an authoritative data catalogue for the sixteen definitive physical
  weapons across families 2–5, including both attack profiles, damage types,
  cadence, range, spread, critical chance, air cost, and shield behavior.
- Added structural recipes and tier-source rules for every physical weapon.
- Added small weapon head for the hatchet and a generic tierless chain for the
  flail; every one of the 41 active materials now has at least one recipe use.
- Replaced the one-handed mace with the flail and removed the saber and
  two-handed mace from the definitive roster. The large family is greatsword,
  war axe, halberd, and giant gauntlets.
- Made the point determine both spear and javelin tier, and normalized all
  weapon-component terminology from stick to handle/long handle.
- Hid the legacy iron-ingot prototype from the active material selector while
  preserving its original identifier and class for old-save compatibility.
- Updated the v66 design document with matching recipes, disassembly entries,
  material uses, and obsolete-reference corrections while retaining its
  typography and highlighting changed passages.
- Left material quantities and inventory consumption pending instead of
  inventing a crafting-cost formula that has not yet been specified.
- Added `ca_debug_audit_crafting_catalogue`; its expected result is 16 recipes,
  41 active materials, and zero unused entries.

## 4.11.0

- Expanded the native material prototype into a 40-entry data-driven catalogue
  covering weapon parts, shield plates, armor resources, elemental essences,
  secondary components, and magical-item bases.
- Added material families and three grade labels for metal, wood, essence,
  leather, and fabric. Generic secondary components remain tier-independent.
- Made material stack identity depend on both type and tier. Matching instances
  stack natively; different materials or grades remain separate inventory items.
- Preserved the validated 0.1 unit weight, carried-load overflow, one Magic Box
  slot per complete stack, retrieval, and dropping behavior for every material.
- Added `ca_debug_test_silver_lock`, which invokes GZDoom's native lock-200
  check and therefore tests the real `LOCKDEFS` rule without a custom map door.
- Corrected the old crafting-table weights for the kite and tower shields from
  14/18 to their definitive tier-one values of 12/16.
- Marked the manually tested 4.10 inventory categories, weight, stacking, and
  Magic Box behavior as validated.

## 4.10.0

- Added native Materials, Keys, and Key Items inventory categories. The compact
  inventory now exposes eight separate filters instead of mixing special items
  with equipment or consumables.
- Added a stackable iron-ingot prototype, a non-stackable native silver key,
  and a unique sealed-letter key item. Each uses the default 0.1 unit weight.
- Integrated materials and key items into carried load, automatic overweight
  routing, one-slot-per-stack Magic Box storage, retrieval, and dropping.
- Kept native keys in personal inventory because `LOCKDEFS` checks possession,
  not Caelum's internal Magic Box state. Their weight still contributes to load.
- Added lock 200 for `CaelumSilverKey`, including localized door and remote
  action messages. It is ready for native locked doors and ACS locked actions.
- Marked the complete 4.9 consumable pass as manually validated.

## 4.9.0

- Added native, stackable life and Anima potions, energy drinks, food rations,
  and water rations with unit weights 0.25/0.25/0.25/0.10/0.10.
- Added ten-second native Powerup effects with one 1%-of-maximum pulse per
  second. Energy drinks restore both air and sleep; using another item of the
  same type refreshes duration rather than stacking intensity.
- Integrated consumable stacks into authoritative carried load and the Magic
  Box. A whole stack uses one box slot and weighs zero while stored there.
- Added a Consumables filter to the compact test interface with create, use,
  box/unbox, and drop actions.
- Exposed GZDoom's native previous, next, and use-inventory commands in the
  Caelum Argenteum control section.
- Marked the 4.8.0/4.8.1 native inventory and weight behavior as previously
  validated after the complete manual collection, equipment, and Magic Box
  test pass.

## 4.8.1

- Fixed ZScript's case-insensitive parameter shadowing in the native equipment
  matcher. One armor instance now matches only its real slot, type, tier, and
  size instead of appearing owned in every tier.
- Fixed the same shadowing in every carried-load setter. Native inventory,
  equipped, ammunition, and total item weights now reach the derived-stat
  fields, permanent HUD, total mass, and load penalties instead of being
  written back into temporary parameters.

## 4.8.0

- Replaced simulated armor, shield, and weapon ownership with real native
  GZDoom inventory instances. `printinv` can now report every collected
  equipment pickup instead of only native weapon selectors and ammunition.
- Made `Actor.Inv` the single source for carried weight: each non-boxed item
  contributes its stored unit weight whether equipped or unequipped.
- Added persistent equipped and Magic Box states to each native equipment
  instance without deleting the object when either state changes.
- Made carbine ammunition a native stack whose weight is `Amount × 0.003`.
  The whole stack occupies one Magic Box slot and weighs zero while boxed.
- Changed the initial development loadout to spawn nine pickups on the floor
  in front of the newly confirmed character instead of granting hidden data.
- Added an Ammunition category and a Magic Box toggle to the equipment menu.
- Updated the v62 design document while preserving its typography and
  highlighting only the changed inventory passages.

## 4.7.8

- Made persistent ownership outside the Magic Box the authoritative source for
  carried item weight, so equipped and unequipped objects cannot disappear
  from load because of a stale category transition.
- Rebuilt armor, shield, weapon, inventory, ammunition, and total item weight
  in one atomic pass on every load refresh.
- Added the localized `normal`, `overload`, or `capacity exceeded` state to the
  permanent load HUD, including the exact 75% and 100% boundaries.

## 4.7.7

- Replaced the provisional armor weights with the authoritative per-piece
  table. Size-M full sets now weigh 5/7/10 for magic armor, 10/15/20 for
  light armor, 20/30/40 for medium armor, and 40/60/80 for heavy armor at
  tiers 1/2/3.
- Preserved the confirmed XS/S/M/L/XL size multipliers after applying the
  exact armor table.
- Added a player-owned load snapshot synchronized every tic and after every
  profile recalculation; the permanent HUD and debug overlay now read this
  stable value instead of traversing the derived-stat object from UI scope.
- Confirmed that tier-one shield weights already match the final table:
  magic 4, buckler 8, kite 12, and tower 16.

## 4.7.6

- Fixed stale carried load by making every equipment, inventory, ammunition,
  and development-weight setter refresh totals atomically.
- Separated equipped weapons from the single active weapon; equipping one
  family no longer unequips another.
- Added native family selectors: sword on slot 3, carbine on slot 5, and staff
  on slot 6.
- Added persistent per-weapon equipped flags and migration of the previous
  single active weapon into the new multi-weapon loadout.
- Included every simultaneously equipped weapon in equipped weight while
  keeping inventory-to-equipment changes neutral to total carried load.
- Changed the pure priest starting loadout to magic armor and magic shield.

## 4.7.5

- Removed all provisional armor, shield, weapon, and carbine ammunition from
  unconfirmed characters.
- Added a one-time post-creation development loadout with sword, staff,
  carbine, and 100 bullets at 0.003 weight each.
- Added profession-based tier-one starting armor and shields using the
  character's compatible equipment size.
- Included live ammunition quantity in personal-inventory weight, carried
  load, the HUD bar, total mass, and every existing load penalty.
- Corrected armor weight so its tier multiplier applies both while equipped
  and while stored in personal inventory.
- Changed the visible ammunition term from cartridges/cartuchos to
  bullets/balas.

## 4.7.4

- Fixed the GZDoom 4.14.2 parser error caused by using reserved identifier
  `action` as an equipment-overlay parameter.
- Added an unlimited-slot personal inventory whose contents contribute weight.
- Redirected pickups to the Magic Box only when adding their weight would
  exceed carry capacity; a full box now rejects only those overflow pickups.
- Added persistent per-object storage location and migration of 4.7.3
  unequipped equipment into the Magic Box.
- Made equipment, personal inventory, and development weight combine into the
  carried load used by the HUD and all mass/load penalties.
- Added storage location, inventory count, box usage, and full carried-weight
  diagnostics to the compact equipment menu.
- Updated the main v58 design document with the corrected inventory rule while
  preserving typography and highlighting the changed passages in yellow.

## 4.7.3

- Clarified the implemented inventory rule: unequipped objects live in the
  Magic Box, while equipped objects occupy one of the six current equipment
  slots and no longer count against the box.
- Added explicit success and rejection feedback for create, equip, remove,
  break, and drop actions, including incompatible-size and full-box causes.
- Added reliable `E`/`U` shortcuts alongside Enter/Backspace and gamepad input.
- Added an equipped-slot counter and a live armor + shield + weapon weight
  breakdown to make every load change directly verifiable.
- Corrected Magic Box accounting so only owned objects that are actually
  equipped are excluded from its used-slot total.

## 4.7.2

- Replaced unreliable equipment-menu letter checks with `InputEvent.KeyChar`
  handling compatible with GZDoom 4.14.2.
- Changed `P` development creation to add the selected object directly to the
  Magic Box instead of hiding a world pickup behind the open menu.
- Changed the menu close key from Escape to `Q`, avoiding the native options
  menu, and allowed `D` to unequip and drop an equipped object in one action.
- Added automatic equipped-weight synchronization so armor, shield, and weapon
  changes immediately update load, total mass, movement, evasion, and air use.

## 4.7.1

- Added a source-compatibility alias from the retired
  `ARMOR_TYPE_UNARMORED` identifier to `ARMOR_TYPE_MAGIC`. This keeps mixed
  incremental 4.6/4.7 source trees compilable without restoring the old UI
  terminology or changing saved numeric equipment data.
- Made both weapon-state actions resolve their owner explicitly through
  `invoker`, removing GZDoom 4.14.2's ambiguous `self` parsing error.

## 4.7.0

- Confirmed carry capacity as `BaseMass × Type4Percent(Strength) / 100`:
  mass 200 produces 200 at Strength 0 and 600 at Strength 100.
- Added a persistent main-hand weapon model for sword, staff, and carbine.
- Added weapon tier, XS–XL size, weight, durability, ownership, migration,
  Magic Box accounting, pickups, equip/remove, break, and drop actions.
- Added a Weapons filter to the compact equipment menu with damage, attack
  time, costs, weight, durability, compatibility, and cartridge data.
- Connected native Fire to sword, staff, or carbine according to the equipped
  item; AltFire now toggles the equipped secondary-hand shield.
- Added the 60 m carbine projectile, accuracy-scaled 30°/200° spread, 48-tic
  cadence, 360 base damage, physical push, cartridge use, and 20-air reload.
- Added automatic migration from the old provisional weapon-weight record.

## 4.6.2 — Mass-scaled load, magic armor terminology, and equipment testing

- Set the tier-one carbine weight to 12 at size M.
- Multiplied Strength Type 4 carry capacity by `BaseMass / 100`, so characters
  with greater body mass can carry proportionally more equipment.
- Renamed the complete basic equippable category to “magic armor” without
  changing its numeric identity, defense, durability, weight, or bonuses.
- Added `P` inside the equipment interface to spawn the selected armor or shield
  pickup directly, completing the collect/equip/remove/drop test loop without
  closing the menu.

## 4.6.1 — GZDoom compatibility, load HUD, and base clothing

- Removed unsupported ZScript method overloads that made GZDoom 4.14.2 report
  duplicate `GetMaximumDurabilityFor` definitions.
- Replaced the short bow catalogue entry with the tier-one carbine: 360 damage,
  48-tic fire time, 60 m range, 30°/200° spread, 0% base critical chance, and
  -20 air. Its size-M tier-one weight is 12.
- Added a right-side load bar showing equipped weight, carry capacity, and load
  percentage, with green/yellow/orange/red states.
- Added a true unequipped state per armor slot: nothing, nothing, shirt, and
  pants. These entries have zero defense, zero weight, no durability, and do
  not occupy Magic Box slots.
- Corrected Magic Box counting so genuinely unequipped armor slots are not
  subtracted as if they still held owned equipment.

## 4.6.0 — Equipment sizes, tiered weights, and Magic Box actions

- Added XS/S/M/L/XL equipment sizes with the confirmed 50%/75%/100%/125%/150%
  weight and durability factors and exact character-size compatibility ranges.
- Added automatic migration of all pre-size owned equipment and current loadouts
  to size M without deleting the previous persistence fields.
- Changed weapon and shield weight scaling to 100%/150%/200% at tiers 1/2/3;
  the provisional sword now contributes its confirmed base weight of 6.
- Corrected tier-1 shield bases to magic 4, buckler 8, kite 12, and tower 16.
- Aligned armor piece weights with the documented per-slot table and applied
  size scaling without adding an armor-tier weight multiplier.
- Changed Strength carry capacity to Type 4 and Agility jump scaling to Type 1;
  the Magic Box keeps its original Intelligence Type 1 slot formula.
- Expanded the equipment interface with a size selector, compatibility result,
  three-decimal weight, Magic Box usage/capacity, filters, break, and drop.
- Full Magic Box pickups now remain in the world; dropped equipment preserves
  its size and current durability.

## 4.5.1 — Documentation terminology correction

- Restored `Resilience` as the definitive attribute name throughout the main
  design document while retaining “survival” only for hunger, thirst, and
  sleep as a collective resource system.
- Replaced obsolete origin/identity creation references and legacy tables with
  the current Race + two Class selections and resulting profession model.
- Preserved the document's existing typography and highlighted the corrected
  passages in yellow as changes from the previous version.

## 4.5.0 — Persistent equipment inventory and world pickups

- Added configurable armor and shield world pickups without duplicating one
  actor class for every slot/type/tier combination.
- Expanded ownership persistence so all 48 armor and 12 shield combinations
  retain independent durability while unequipped.
- Added automatic migration for ownership records and shield state created by
  versions 4.3 and 4.4.
- Added a compact localized equipment interface with keyboard/gamepad controls
  for category, slot, type, tier, equip, remove, and close.
- Made shield removal affect defense, coverage, blocking, air cost, and weight;
  removing armor returns that slot to its base clothing state.
- Added a development control that spawns the currently previewed pickup for
  collection, duplicate-repair, save/load, and map-travel tests.
- Preserved each outgoing equipped item's current durability before switching
  and immediately recalculated mass and attribute-derived statistics.

## 4.4.0 — Multi-region area damage

- Fixed the ZScript parser failure caused by using the reserved `state` token
  as the local name of the travelling character record.
- Added spherical explosion/anatomy intersection for players and original
  Caelum actors.
- Applied the distance-adjusted explosion base independently to every touched
  region, including its own vulnerability, reinforcement, defense, Toughness,
  and armor durability calculation.
- Unified both arms as one explosion region while preserving separate authored
  heads and other future anatomy entries.
- Evaluated pain and damage adrenaline once from the combined health loss and
  retained critical-region lucidity loss and Caelum projectile push.
- Added the last explosion's touched-region count and resolved radius to the
  compact armor diagnostics.

## 4.3.0 — Travelling profile and persistent equipment foundation

- Added an invisible GZDoom inventory record that preserves the confirmed
  profile, allocations, resources, armor, shield, durability, and ownership
  across ordinary map travel.
- Restored the travelling record after a level transition so the mandatory
  creator does not reopen for an already-confirmed character. Normal save/load
  continues to preserve the same state.
- Made debug-selected armor and shields enter a persistent owned-equipment
  registry and displayed the number of owned pieces on the armor page.
- Extended mass-based push to magical attacks. Physical push uses Strength and
  body mass; magical push uses Intelligence; both use the receiver's total-mass
  knockback multiplier.
- Connected the staff and the magical projectiles of Argento, Caella, and
  Ronnie to the same confirmed-damage push rule.
- Documented the current area-damage inconsistency: players use GZDoom's
  non-localized route, while original Caelum actors fall back to sensitive
  torso/body armor when no authored impact metadata exists.

## 4.2.0 — Mass-based physical push

- Connected physical push to the player sword, Caelum actor melee attacks,
  and physical Caelum projectiles.
- Applied push only after positive health damage; misses, evasion, full damage
  prevention, and magical attacks do not produce it.
- Scaled outgoing force from body mass and incoming knockback from total mass,
  including the player's armor, shield, and development weight.
- Mirrored total player mass into GZDoom's native actor mass so external engine
  interactions use the equipped value too.
- Added the last applied sword-push force to compact combat diagnostics.
- Added a separate, mutually exclusive development option for setting every
  attribute to 100 while retaining the existing level-75 option.

## 4.1.0 — Initial character-creation flow

- Opened the eight-page creator automatically for every new character and
  prevented cancelling the mandatory first pass.
- Added direct keyboard and gamepad input, independent from custom bindings.
- Blocked movement, attacks, resource simulation, and incoming damage until
  the initial profile is confirmed.
- Initialized health, Anima, air, lucidity, adrenaline, hunger, thirst, and
  sleep from the final confirmed profile without granting free refills on edits.
- Preserved the completion flag and profile fields through ordinary saves.
- Corrected Rulo to 20/18/9/3 and Ronnie to 20/18/5/7. Ronnie's Intelligence
  correction raises his magical projectile base damage from 132 to 154.

## 4.0.1 — GZDoom 4.14.2 parser repair

- Replaced the incompatible explicit actor action scope with state-compatible
  actions that cast `self` to `CaelumCombatActor` before using custom members.
- Replaced direct assignment to readonly `Radius` with GZDoom's `A_SetSize`,
  which safely updates player radius and height in the world.
- Restored Resilience as the definitive attribute name in code and localization.

## 4.0.0 — Character creation, mass, size, and Anima overhaul

- Fixed the GZDoom 4.14.2 actor-action scope and UI/play-context parse errors.
- Replaced Origin + Identity + Class with Race + two Classes/Profession + Sex
  + Height, expanding character creation from six to eight pages.
- Added all ten order-independent professions and the documented family and
  individual point limits.
- Added ten mass tiers and seven size tiers, including live player/actor
  collision dimensions and body-mass scaling for health, physical power, air,
  hunger, and thirst.
- Added exact per-piece armor weights and included armor plus shield weight in
  equipped load while preserving separate debug-added weight.
- Renamed Mana to Anima and retained Resilience as the technical recovery
  attribute throughout current code and localization.
- Connected Eloquence to staff casting time and Anima cost, and prepared its
  ability-range and dialogue values.
- Rebuilt Rulo, Ronnie, Argento, and Caella from the authoritative final 4.0
  table, including independent profiles, armor, dimensions, health, and damage.
- Updated the main design document, README, implementation status, controls,
  English localization, and Spanish localization for version 4.0.

## 0.63.0 — Complete offensive state for the four predefined actors

- Gave Argento, Caella, Rulo, and Ronnie their own Dexterity and Insight,
  including live armor bonuses, Type-1 physical/magical accuracy, and
  `5% + Type2` physical/magical critical chance.
- Made melee and ranged damage use each actor's real wounded-state performance:
  healthy x1, wounded x0.75, and badly wounded x0.25 before Patience and
  adrenaline progressively mitigate the harmful portion.
- Applied the same health performance to actual actor movement speed and kept
  the documented x2/x4 pain and earned-adrenaline intensity.
- Connected Mareado to the actor's own attack accuracy and made the two-second
  Aturdido interval stop horizontal movement and offensive attempts.
- Made real actor criticals add damage only. Melee attacks transfer a
  single-use critical result; projectiles retain their own result until impact.
- Routed those criticals through the player's real shield, selected anatomy
  region, armor, Dureza, health, lucidity, pain, adrenaline, and durability
  pipeline. The effective region multiplier also governs critical head
  lucidity loss after armor reinforcement.
- Added a sixth compact actor page with current/base speed, health performance,
  pain/adrenaline intensity, evasion, effective offensive attributes,
  accuracy, critical chances, last attack damage, and both attack rolls.
- Added localized controls to cycle the last inspected actor through health and
  lucidity test states without inventing actor air, hunger, thirst, or sleep.

## 0.62.0 — Shared lucidity for all predefined combat actors

- Added a 100-point lucidity resource to Argento, Caella, Rulo, and Ronnie,
  with complete regeneration over one real minute.
- Made damage to a naturally critical anatomy region remove 25 base lucidity
  even when armor reinforcement lowers its effective vulnerability grade.
- Applied armor defense and the actor's Toughness Type-3 multiplier to that
  loss, matching the player rule's mitigation order.
- Made critical sword and staff hits transmit their real critical result to the
  actor and multiply lucidity loss from the reinforced effective grade.
- Added Mareado at 50% or less, represented by half of actor offensive attempts
  failing until final actor aim cones exist.
- Added Aturdido at 10% or less: entering the state from above immobilizes the
  actor and prevents attacks for two seconds without restarting the timer while
  it remains in critical lucidity.
- Extended compact actor diagnostics with current lucidity, state, accuracy
  factor, last localized loss, and remaining physical-stun time.

## 0.61.0 — Ordinary attacks use the complete player defense pipeline

- Routed directed melee, hitscan, bullet, physical-projectile, and magical-
  projectile damage through Caelum shield, armor, Dureza, health, lucidity,
  pain, and adrenaline rules automatically.
- Kept explosions, survival damage, floors, telefrags, and other unclassified
  hazards on GZDoom's native damage route.
- Made shield coverage use the attacker's real direction relative to the
  player's facing instead of the diagnostic angle control.
- Selected physical or magical shield defense from the incoming Caelum damage
  type, without adding any extra air cost when struck.
- Reused the currently selected armor region as the temporary incoming hit
  location until authored player hit volumes are implemented.
- Prevented successful evasion and invulnerability from damaging shield or
  armor durability.
- Kept the compact armor page as the diagnostic view for both debug hits and
  ordinary attacks.

## 0.60.1 — GZDoom 4.14.2 armor parser correction

- Renamed the uniform-loadout parameters that collided case-insensitively with
  the `ArmorType[]` and `Tier[]` fields in ZScript.
- Preserved every 0.60.0 armor value and behavior while allowing GZDoom 4.14.2
  to parse the shared actor armor initializer.

## 0.60.0 — Common actor armor, reinforcement, and durability

- Connected the existing four-slot armor model to every predefined Caelum
  actor instead of keeping it exclusive to the player diagnostic.
- Assigned light tier-1 armor to Argento, Caella, and Ronnie, and heavy tier-1
  armor to Rulo, matching their documented visual/equipment profiles.
- Made authored anatomy impacts select head, body, hands, or feet, apply that
  piece's reinforcement and percentage defense, and wear only its durability.
- Preserved natural and reinforced vulnerability separately in diagnostics.
- Applied armor-derived Agility and Patience bonuses to actor evasion and
  wounded-state penalty mitigation.
- Extended compact combat diagnostics with the last actor armor slot, defense,
  absorbed damage, remaining durability, and durability loss.

## 0.59.0 — Rulo and Ronnie predefined characters

- Added Rulo, the documented Southern Beast Warrior, with physical/technical/
  social/mental attributes 20/18/7/5, 3100 health, mass 95, and a wider
  28-radius/80-height body.
- Added Ronnie, the documented Northern Caelith Explorer, with attributes
  5/18/7/20, 1150 health, mass 60, and a 20-radius/72-height body.
- Added forty-eight original transparent frames per character: eight rotations
  each for idle, stride, melee, ranged attack, pain, and death.
- Gave Rulo a 372-damage axe strike and deterministic 372-damage thrown axe;
  his heavy movement speed is 8 and the projectile speed is 20.
- Gave Ronnie a 138-damage sword strike and deterministic 372-damage golden
  magic bolt; his movement speed is 12 and projectile speed is 28.
- Connected both actors to shared anatomy, evasion, pain, adrenaline, wounded
  state, enemy-kill reward, directional corpse, and compact diagnostics.
- Added independent localized spawn controls for Rulo and Ronnie, and corrected
  actor-name diagnostics so all four predefined characters identify properly.

## 0.58.0 — Anatomy profiles and complete test-enemy state art

- Added an ordered reusable anatomy profile with up to sixteen normalized
  regions, independently assigned locations and vulnerability grades.
- Connected sword and staff impact classification to original actors' anatomy
  without applying the location multiplier twice; ordinary actors retain the
  verified humanoid fallback.
- Added compact diagnostics for the last anatomy region, vulnerability grade,
  relative height, and lateral position struck on Argento or Caella.
- Added eight-direction walking, ranged-cast, pain, and death frames for both
  test enemies while preserving their 72-unit body and collision dimensions.
- Made actor pain use the new eight-tic hurt pose and death finish in the new
  direction-aware corpse pose.
- Added blue and violet magic-bolt actors and ranged monster states. Each bolt
  travels at 24 units per tic and deals a deterministic 138 base magical damage
  before the target's defenses, with no secondary effect.

## 0.57.0 — Shared defensive combat layer for original actors

- Added `CaelumCombatActor` as the reusable base class for original enemies
  and future non-player combatants.
- Gave Argento and Caella their documented Toughness 20, Resilience 16,
  Agility 16, and Patience 5 defensive profile instead of native Doom pain.
- Applied directed-attack evasion before damage, including the normal +8
  adrenaline reward and combat-timer restart on success.
- Applied post-damage pain chance from percentage health lost, Toughness,
  current adrenaline, and the wounded/badly-wounded intensity rules.
- Applied Toughness Type 3 to incoming health damage before the resulting
  health-loss percentage enters pain chance.
- Added actor-owned Type-4 maximum adrenaline, damage/pain/evasion gains,
  thirty-second combat timing, and unchanged ten-per-second decay.
- Added compact combat diagnostics for the last damaged Caelum actor: health,
  adrenaline, evasion roll, health-loss percentage, and pain result.

## 0.56.0 — Caella hostile test enemy

- Added Caella as a second independently invocable hostile humanoid test enemy.
- Created and normalized sixteen original transparent sprites from the supplied
  visual reference: eight idle rotations and eight sword-attack rotations.
- Made Caella inherit Argento's complete legal Southern Federal Warrior test
  profile, preserving 3100 health, 372 base melee damage, movement, mass,
  hitbox, pain, hostility, death, and enemy-kill adrenaline behavior.
- Added localized English and Spanish spawn controls and documented the new
  project-owned sprite assets.

## 0.55.0 — Argento hostile test enemy

- Added Argento as the first hostile humanoid test enemy, invocable from a new
  localized development control.
- Built original transparent eight-direction idle and melee sprite rotations
  from the user-supplied visual reference, with a 72-unit humanoid body.
- Based Argento on a legal newly-created Southern Federal Warrior: physical 15,
  technical 11, social 9, mental 5; combat allocation produces Strength,
  Toughness, and Constitution 20 plus Dexterity, Resilience, and Agility 16.
- Set 3100 health and 372 base melee damage from the same Type-1 formulas used
  by a starting player, before target mitigation or vulnerability.
- Recorded the completed staff and shield tests as user-confirmed.

## 0.54.0 — Unified debug resource restoration

- Expanded the existing debug healing control so one press restores health,
  mana, and air to their current calculated maximums.
- Updated the localized control name in English and Spanish to describe all
  three resources.
- Verified that shield blocking already consumes air continuously, independently
  of incoming hits, at `ShieldWeight × 10% × AirMultiplier` per second.
## 0.53.0 — Functional straight-line staff test

- Added a real long-range line attack for the staff with documented 120 base
  damage, 18-tic casting interval, and current-scale 500 mana cost.
- Made Intelligence Type 1 scale magical damage and Insight Type 1 control
  magical accuracy; crouching still doubles accuracy.
- Added staff critical chance from its 8% weapon base plus Insight Type 2,
  including crouching's x2 critical factor and localized critical damage only.
- Applied health/survival offensive penalties, spent mana at cast start, blocked
  recasting during the 18-tic interval, and granted +2 adrenaline on real damage.
- Added a fifth compact debug page for magical damage, mana, accuracy, aim
  offsets, critical roll, hit result, and remaining cast time.
- Corrected documented magical-weapon mana costs to the established x10 scale:
  staff/campana 500, book 700, and statuette 1000.

## 0.52.0 — Shield horizontal coverage angles

- Added a configurable horizontal incoming-attack angle to the shield test,
  cycling from 0° to 180° in ten-degree steps.
- Made blocking require the attack to fall within half of the shield's total
  frontal arc: ±60° rodela/magic, ±70° kite, and ±80° tower.
- Routed out-of-coverage hits past the shield with zero shield absorption,
  durability loss, or block adrenaline, while preserving the complete
  armor–Dureza–health pipeline.
- Added localized angle control and compact covered/bypassed diagnostics.

## 0.51.0 — Dureza damage-resistance stage

- Added Dureza Type 3 as the final retained-damage multiplier in the shared
  shield/armor test pipeline: `1 - Dureza × (Dureza + 1) / 10100`.
- Applied it after armor defense, so it changes real health loss without
  changing how much damage shield or armor absorbed for durability.
- Kept Dureza's existing pain-chance and localized-lucidity multipliers as
  independent calculations; they are not replaced by direct damage resistance.
- Added post-defense damage, Dureza multiplier, and final health damage to the
  compact armor diagnostic.

## 0.50.0 — Shield-to-armor damage routing

- Routed every point not absorbed by the debug shield into the selected
  humanoid armor region instead of stopping at a diagnostic value.
- Reused the complete armor pipeline: vulnerability and reinforcement,
  defense absorption, armor durability, real health loss, localized lucidity,
  pain chance, damage adrenaline, and combat timer.
- Made an inactive or broken shield pass the complete 1000-point test impact
  into armor, while a 100% block leaves armor, health, lucidity, and pain untouched.
- Preserved the shield's separate durability calculation and +5 base
  adrenaline reward whenever it absorbs positive damage.

## 0.49.1 — Corrected shield defense tiers

- Reclassified the original shield defenses as tier-2 values.
- Made tier 1 subtract ten percentage points and tier 3 add ten percentage
  points to both physical and magical defense for every shield.
- Preserved shield weight, coverage, adrenaline reward, air cost, and
  durability scaling x1/x3/x9.
- Updated compact diagnostics, test instructions, and design-document tables.

## 0.49.0 — Functional shield-blocking test

- Added rodela, kite, tower, and magic shield models with their documented
  weight, physical/magical defense, durability, and frontal coverage.
- Added all three tiers: defense scales x1/x2/x3, durability x1/x3/x9, and
  effective absorption is capped at 100% so values above 100% cannot heal.
- Added a blocking toggle that suspends air regeneration and consumes 10% of
  shield weight per second, adjusted by the existing equipment-load factor.
- Added a frontal 1000-damage physical/magical diagnostic hit, the armor
  durability-loss formula, shield repair, and +5 base adrenaline on a
  successful block.
- Added compact shield diagnostics and six localized test controls without
  expanding the panel horizontally.
- Recorded user confirmation that the corrected training dummy now aligns its
  visible body with its hit regions.

## 0.48.1 — Training-dummy visual and hitbox alignment

- Reduced the dummy sprite canvas from 96×128 to 48×72 so its displayed height
  exactly matches the actor's 72-unit collision height.
- Matched the 42-pixel-wide visible silhouette with a 21-unit actor radius.
- Converted the final small sprite to binary transparency: the dummy is fully
  opaque and only its exterior background is transparent.
- Preserved the one-million health, immobility, test control, and humanoid
  location thresholds from 0.48.0.

## 0.48.0 — Crouching bonuses and training dummy

- Made crouching multiply accuracy, critical chance, and stealth by x2.
- Applied the crouching accuracy and critical factors to the provisional sword;
  critical chance remains capped at 100%.
- Exposed the live crouching factors in compact resources/combat diagnostics.
- Added an original stationary training dummy with 1,000,000 health, maximum
  mass, no damage thrust, and a localized control that spawns it ahead.
- Corrected sword calculated-damage diagnostics so health/survival penalties
  update live even before a target is hit or when the latest attempt misses.
- Recorded user confirmation of the running-accuracy implementation.

## 0.47.0 — Running accuracy penalty

- Applied the documented running penalty to the provisional sword: attacks
  made while running retain 25% of physical accuracy.
- Kept standing and walking attacks at 100% of their post-lucidity accuracy.
- Applied movement after attribute and lucidity factors, so running while dizzy
  combines multiplicatively to retain 12.5% before the weapon's aim formula.
- Added the movement-accuracy factor to the compact combat diagnostic.
- Recorded user confirmation of survival penalties on offensive sword damage.

## 0.46.0 — Survival penalties on offensive damage

- Connected the existing cumulative hunger, thirst, and sleep performance
  factor to the provisional sword's real outgoing damage.
- Combined health-state and survival damage penalties multiplicatively through
  one stored offensive-damage factor for reuse by later weapons and spells.
- Preserved adrenaline's percentage-based restoration of survival penalties:
  full adrenaline restores the survival portion to x1.
- Added the combined offensive-damage factor to compact resource diagnostics.
- Recorded user confirmation of direct lucidity-state testing and 25-point loss.

## 0.45.0 — Direct lucidity-state test and 25-point base loss

- Raised localized critical-region lucidity loss from 15 to 25 base points.
- Added one localized control that cycles exact clear, dizzy, and stunned
  lucidity states so the accuracy penalty and visual distortion are immediately testable.
- Kept the ten-point incremental loss and refill controls for timing tests.
- Clarified where effective accuracy and sword aim offsets appear in the compact panel.
- Recorded user confirmation of the 0.44.0 implementation before this adjustment.

## 0.44.0 — Dizzy accuracy and visual distortion

- Made physical accuracy use Dexterity Type 1 and magical accuracy use Insight
  Type 1 through shared calculated values.
- Made dizzy and stunned lucidity states retain 50% of both effective accuracy
  values without changing damage or critical chance.
- Connected effective physical accuracy to the provisional sword as a small
  horizontal and vertical angular error; losing half accuracy doubles that error.
- Added a restrained full-screen violet tint with opposing cyan/red edge bands
  while dizzy or stunned, leaving HUD text crisp.
- Added effective accuracy, lucidity factor, and the sword's latest horizontal
  and vertical offsets to compact diagnostics.
- Recorded user confirmation of natural critical-region lucidity mitigation.

## 0.43.0 — Natural critical regions and lucidity mitigation

- Raised localized critical-region lucidity loss from 10 to 15 base points.
- Kept natural anatomy responsible for lucidity loss even when armor
  reinforcement lowers the effective vulnerability grade.
- Applied armor defense as equal percentage mitigation to health and localized
  lucidity loss.
- Made reinforcement reduce a critical hit's lucidity factor through the ratio
  between effective critical and normal vulnerability multipliers.
- Made low and critical sleep multiply lucidity loss and stun duration by x2
  and x4, with Patience Type 3 mitigating the harmful amount above x1.
- Added sleep factor to armor diagnostics and rendered armor defense as a percent.
- Recorded user confirmation of damage-only criticals and critical-region lucidity loss.

## 0.42.0 — Critical-point lucidity loss

- Made critical hits damage-only for every damage type; they no longer grant
  secondary bleeding, stun, penetration, or elemental effects.
- Added a shared localized lucidity-loss rule for confirmed damage of any type.
- Made only regions that remain critical points remove localized lucidity.
- Reused the ten-point lucidity test base, multiplied by the same localized
  damage multiplier and then by Toughness Type 3 resistance.
- Added critical-point lucidity loss to the armor hit test and its diagnostics.
- Recorded user confirmation of Type 2 JumpZ growth.

## 0.41.0 — Type 2 JumpZ growth

- Changed Agility's base JumpZ scale from Type 4 to `100% + Type 2`.
- Kept level 0 at 100% and set level 100 to exactly 200% JumpZ.
- Preserved the existing mass, air, survival, health, stun, and pain factors.
- Clarified that doubling vertical launch velocity produces approximately four
  times the geometric jump height under constant gravity.
- Recorded user confirmation of automatic physical critical rolls.

## 0.40.0 — Automatic physical critical rolls

- Added the documented 5% base physical critical chance plus Dexterity Type 2.
- Rolled critical chance once after each sword trace reaches a valid actor.
- Applied the existing localized critical formula `V × (V + 1)` instead of an
  unrelated global damage multiplier.
- Added chance, roll, and normal/critical result to compact combat diagnostics.
- Reserved magical critical chance as 5% plus Insight Type 2 for the future
  magical-attack stage, without rolling it prematurely.
- At this stage, secondary critical effects were still outside the prototype;
  version 0.42.0 later removed them from the final design entirely.

## 0.39.0 — Animation-matched pain immobilization

- Added a physical pain lock when the custom pain roll succeeds.
- Derived the lock duration from the actor's finite `Pain` state sequence; the
  current DoomPlayer sequence lasts eight tics, approximately 0.229 seconds.
- Disabled movement, jumping, running, and the sword test during that duration.
- Displayed remaining and total pain-animation duration in combat diagnostics.
- Documented that jump scaling modifies `JumpZ` linearly while approximate
  geometric height changes quadratically under constant gravity.

## 0.38.3 — Reliable kill credit and narrower debug pages

- Recorded the last player responsible for real damage to each actor and used
  that record first when awarding enemy-kill adrenaline.
- Kept monster target and death inflictor as compatible fallback attribution.
- Split every remaining wide diagnostic group into shorter stacked lines and
  shortened the panel heading so Spanish text stays inside the virtual screen.
- Preserved every confirmed gameplay system and design rule.

## 0.38.2 — GZDoom 4.14.2 monster-flag compatibility

- Replaced the invalid `bMonster` identifier with GZDoom 4.14.2's exposed
  ZScript actor flag `bIsMonster` in the enemy-kill adrenaline detector.
- Verified the other new death-event members against the g4.14.2 source.
- Preserved every gameplay and documentation rule from 0.38.0.

## 0.38.1 — Debug-overlay parser correction

- Moved the compact overlay method's closing brace outside the disabled legacy
  reference block so GZDoom 4.14.2 can parse the following `NetworkProcess`
  override correctly.
- Preserved every gameplay and documentation rule from 0.38.0.

## 0.38.0 — Compact diagnostics and adrenaline event rewards

- Split the development overlay into four compact pages: character,
  resources/states, combat, and armor.
- Added localized controls to change panel page and heal current health fully.
- Restored gameplay adrenaline gains to their original values: damage 10, pain
  20, melee 3, and evasion 8; post-combat decay remains 10 per second.
- Added 5 adrenaline for killing a hostile monster.
- Added 10 adrenaline to living allies within 10 development meters when an
  allied actor dies.
- Added last adrenaline source, base gain, and health-state-adjusted gain to
  combat diagnostics.
- Applied Patience Type 3 to detrimental wounded/badly-wounded penalties before
  existing adrenaline mitigation without weakening their beneficial gain bonus.
- Recorded user confirmation of health-bar interpolation and armor tests.

## 0.37.0 — Vulnerability grades and armor durability

- Replaced head/torso/arms/legs damage multipliers with seven fixed
  vulnerability grades: x2.00, x1.60, x1.30, x1.00, x0.80, x0.60, and x0.40.
- Derived critical-hit multipliers with `V × (V + 1)`.
- Assigned humanoid head/body/hands/feet to critical/sensitive/weak/neutral.
- Added four independent armor slots with uniform defense by type/tier,
  slot-specific reinforcement, and live attribute bonuses.
- Added the new 5/10/15, 10/20/30, 20/40/60, and 30/60/90 defense tables.
- Preserved base durability and x3-per-tier scaling.
- Applied percentage defense after vulnerability and based durability loss on
  absorbed damage: one guaranteed point per 1000 plus 1% per ten remainder.
- Reserved a durability-damage multiplier for future mitigation and the same
  formula for future shield blocking.
- Added localized armor configuration, hit, critical-mode, repair controls, and diagnostics.

## 0.36.0 — Wounded and badly wounded health states

- Added wounded at 50% health or less and badly wounded at 10% or less.
- Set raw pain and combat-adrenaline gains to x2/x4 in those states.
- Set raw outgoing damage, air recovery, movement, evasion, and jump performance
  to x0.75/x0.25 respectively.
- Applied the existing percentage-based adrenaline relief to every new health penalty.
- Added localized health-state text and development-panel diagnostic factors.
- Added a no-impact control that cycles exact health thresholds for testing.
- Changed the health bar to interpolate green at 100%, gold at 50%, and red at 10%.
- Documented configurable anatomy profiles, multiple weak points, and contextual
  Tarot effects for players and enemies as future architecture.

## 0.35.0 — Sword attack air cost

- Connected the documented five-air sword primary cost to the live attack test.
- Multiplied attack cost by the existing equipped-load air-use factor.
- Charged the effort when a valid attack begins, including attacks that miss.
- Prevented the attack entirely when current air cannot pay its complete cost.
- Displayed final attack cost and insufficient-air result in the development panel.

## 0.34.1 — Reversible level-75 development attributes

- Added one localized control that toggles all twelve attributes to level 75.
- Kept the real character profile and point allocation untouched underneath.
- Recalculated all derived statistics and live limits immediately on each toggle.
- Restored the ordinary creation-derived attributes when the override is disabled.

## 0.34.0 — Passive evasion on directed attacks

- Connected effective evasion chance to incoming melee, hitscan, and missile damage.
- Rolled before GZDoom damage so a successful evasion prevents health loss,
  pain, armor interaction, and damage-derived adrenaline.
- Granted sixteen adrenaline and restarted combat time on successful evasion.
- Excluded explosions, environmental damage, telefrags, and unclassified damage.
- Added a localized directed-attack test and displayed the last roll, chance,
  applicability, and result in the development panel.

## 0.33.0 — Height-based localized melee damage

- Replaced the provisional fixed torso hit with crosshair-driven body location.
- Classified head at 80%-100%, torso at 40%-80%, lateral arms at 30%-50%,
  and legs at 0%-30% of the target's actor height.
- Applied the documented x2.0 head, x1.0 torso, x0.6 arms, and x0.5 legs
  multipliers before sending damage through GZDoom.
- Resolved the arms/torso height overlap by requiring an arms hit to pass
  through the outer half of the target cylinder; central hits remain torso.
- Displayed the selected body zone, multiplier, and relative impact height in
  the localized development panel.
- Kept armor by body part and temporary limb effects pending for Caelum actors.

## 0.32.0 — Base melee damage functional test

- Added an isolated sword torso attack with a base damage of 120 and a
  64-unit melee range.
- Applied Strength Type 1 directly to the weapon base damage and rounded the
  final engine damage to the nearest whole point.
- Used a provisional torso multiplier of x1, without location, critical,
  Caelum armor, survival-damage, or attack-air stages.
- Granted six adrenaline and restarted the combat timer only when the reached
  actor actually received positive damage.
- Displayed calculated damage, real damage, and hit or miss in the development
  panel, with localized English and Spanish controls.

## 0.31.0 — Type 4 adrenaline capacity and pain test damage

- Replaced maximum-adrenaline Type 1 growth with Resilience Type 4 growth.
- Defined maximum adrenaline as `1000 × Type4Percent / 100`, from 1000 to 3000.
- Preserved current adrenaline percentage effects, gains, decay, and clamping.
- Added a localized test action that removes 5% of maximum health, rounded to
  whole health and limited to leave at least one point.
- Routed test damage through the same pain chance and adrenaline logic as a
  real mitigated hit while deliberately bypassing provisional Doom armor.

## 0.30.0 — Health-percentage pain chance

- Disabled DoomPlayer's independent native pain roll for Caelum players.
- Calculated one custom pain chance after real mitigated health loss.
- Set base chance to ten times the percentage of maximum health lost.
- Applied Dureza Type 3 and the pre-hit adrenaline percentage multiplicatively.
- Made 100% pre-hit adrenaline grant complete pain immunity.
- Awarded 40 additional adrenaline when pain actually triggers, after the roll.
- Displayed the latest health-loss percentage, final chance, Dureza multiplier,
  and result in the development panel.

## 0.29.0 — Physical lucidity stun

- Triggered one two-second physical stun when lucidity crosses from above 10%
  to 10% or less.
- Prevented the stun from restarting merely because lucidity remains critical.
- Disabled movement and jumping and stopped horizontal sliding during the stun.
- Prevented stunned input from spending running or jumping air.
- Displayed the remaining stun time in the gameplay HUD and development panel.
- Preserved the remaining timer through ordinary saves.

## 0.28.0 — Adrenaline rescale and survival-funded air recovery

- Increased the complete adrenaline-capacity formula to ten times its prior scale.
- Doubled confirmed-damage and test gains from 10 to 20 points per event.
- Doubled post-combat decay from 5 to 10 points per second.
- Preserved every percentage-based adrenaline effect and the 30-second timeout.
- Made a complete air refill consume 10% hunger and 20% thirst.
- Limited air recovery proportionally when hunger or thirst cannot fund it.

## 0.27.0 — Ten-times combat scale and natural health recovery

- Increased base health and mana from 100 to 1000 without changing percentages.
- Increased the provisional mana cost from 10 to 100.
- Defined all final base damage and mana costs as ten times their former values.
- Added natural health recovery over one real hour at base speed.
- Applied Resilience Type 4 to natural recovery.
- Stopped natural recovery while any survival resource is critical.
- Spent hunger and thirst proportionally while naturally recovering health.
- Corrected critical survival damage to one real-hour base rate.

## 0.26.0 — Progressive adrenaline relief and survival damage

- Changed adrenaline relief from a fixed 100-point threshold to current percentage.
- Restored the same percentage of performance that adrenaline currently holds.
- Added cumulative critical health loss at the negative base health-regeneration rate.
- Kept survival damage independent from armor and ordinary damage adrenaline gains.
- Mixed each survival bar's base hue with gold or red instead of replacing it.

## 0.25.0 — Cumulative survival movement penalties

- Applied 75% retained movement and jump height for each low survival state.
- Applied 50% retained movement and jump height for each critical state.
- Multiplied simultaneous hunger, thirst, and sleep penalties together.
- Combined survival with the existing mass and air-state movement pipeline.
- Ignored survival performance penalties while adrenaline is at least 100.
- Displayed the final survival factor and adrenaline exception in the panel.

## 0.24.1 — Survival HUD parser correction

- Renamed the survival-bar local variable `color` to `barColor`.
- Fixed GZDoom 4.14.2's `Unexpected '='; Expecting identifier` errors because
  `color` is a reserved ZScript type name.
- Preserved every survival resource value, timer, state, and HUD position.

## 0.24.0 — Survival resources and definitive world-time scale

- Defined one game hour as three real minutes.
- Added hunger depletion over 24 game hours, thirst over 12, and sleep over 16.
- Applied Constitution Type 3 to hunger/thirst loss and Resilience Type 3 to sleep loss.
- Added persistent values and normal, low, and critical states for all three resources.
- Added localized test controls, HUD bars, and state labels.
- Kept accumulated penalties and progressive damage pending until state tests pass.

## 0.23.0 — Live lucidity resource and states

- Added a persistent 100-point lucidity resource that begins full.
- Added the documented one-minute empty-to-full recovery speed.
- Added normal, dizzy at 50% or less, and stunned at 10% or less states.
- Calculated Dureza's Type 3 future lucidity-loss multiplier.
- Added localized test controls to lose ten lucidity or refill the resource.
- Added a permanent cyan lucidity bar with gold and red critical colors.
- Kept accuracy penalties and physical stun pending for their real systems.

## 0.22.1 — Damage override declaration correction

- Removed repeated default parameter values from the `DamageMobj` override.
- Fixed GZDoom 4.14.2's `Default values for parameter of virtual override not
  allowed` compilation error.
- Preserved every adrenaline formula and gameplay behavior from version 0.22.0.

## 0.22.0 — Live adrenaline and combat timeout

- Added Resilience-derived maximum adrenaline using the documented formula.
- Started new players at zero adrenaline and preserved it in ordinary saves.
- Awarded ten adrenaline only when GZDoom confirms actual health loss.
- Added a thirty-second combat timeout that restarts on each confirmed event.
- Added five-adrenaline-per-second decay after the timeout reaches zero.
- Added localized test controls to add ten adrenaline or clear the resource.
- Added a permanent gold adrenaline bar, exact values, and visible timer.
- Updated the main design document to define the thirty-second rule.

## 0.21.0 — Live mana resource

- Added persistent current mana with a Patience-derived Type 1 maximum.
- Added Type 4 mana regeneration from Patience.
- Applied the documented eight-minute base refill time before the regeneration
  multiplier.
- Added localized debug controls to spend ten mana and refill the resource.
- Added a permanent violet mana bar and exact current/maximum values.
- Displayed mana regeneration speed and percentage in the development panel.
- Prevented profile recalculation from granting free mana.

## 0.20.0 — Constitution-based live health

- Connected Constitution's calculated maximum health to GZDoom's real player
  health resource.
- Overrode the engine maximum-health query so ordinary healing respects the
  current Caelum limit.
- Added a permanent localized health bar and exact current/maximum values.
- Preserved native GZDoom damage, death, and healing behavior.
- Prevented profile recalculation from granting free healing: a higher maximum
  keeps current health unchanged, while a lower maximum only clamps it.
- Drew the health display entirely through code without external artwork.

## 0.19.0 — Functional air bar

- Added a proportional bar to the permanent air HUD.
- Kept the exact current and maximum values below the bar.
- Matched the fill color to normal, tired, and breathless states.
- Drew the bar entirely through code without external graphical assets.
- Converted the virtual HUD position to real pixels for consistent widescreen
  placement.

## 0.18.0 — First permanent gameplay HUD element

- Added a permanent current-air display separate from the debug panel.
- Displayed current and maximum air together with the localized air state.
- Used light blue, gold, and red for normal, tired, and breathless states.
- Kept the HUD resolution-independent through a 640x360 virtual canvas.
- Used only GZDoom's temporary built-in font, without distributing Doom art.

## 0.17.0 — Larger air pool and correct Always Run detection

- Increased base air capacity from 100 to 1000.
- Preserved Type 4 Resilience growth, producing 1000 air at level 0 and 3000
  air at level 100.
- Preserved all action costs, load multipliers, thresholds, and the eight-minute
  full-refill duration.
- Replaced physical speed-key detection with GZDoom's effective run command.
- Supported running-air consumption with Always Run both enabled and disabled.

## 0.16.0 — Air cost while running

- Connected the documented running cost to real grounded running movement.
- Spent two base air units per second, adjusted by equipped load.
- Kept walking, standing, swimming, flying, falling, and airborne input free.
- Paused air regeneration while running so the displayed cost remains exact.
- Added localized running-cost and active-state information to the panel.
- Marked the two manual air-consumption controls clearly as debug tools.

## 0.15.0 — Air cost on physical jumps

- Detected successful grounded-to-rising jumps from the real jump control.
- Spent five base air units once per successful takeoff.
- Applied the existing equipment-load multiplier to the physical jump cost.
- Ignored falling, lifts, airborne input, held-button tics, and predicted tics.
- Retained the jump-cost debug control as an optional testing aid.

## 0.14.0 — Physical movement and jump application

- Applied effective movement to GZDoom's forward and sideways player fields.
- Applied effective jump height to GZDoom's `JumpZ` player field.
- Used fixed engine baselines to prevent multiplication accumulating per tic.
- Displayed applied movement and `JumpZ` in the localized debug panel.
- Kept jump air spending on its test control until valid physical jumps can be
  distinguished from failed jump input.

## 0.13.0 — Unified movement and jump model

- Confirmed that evasion uses the same total-mass formula as movement, with no
  separate overload penalty.
- Unified ground, swimming, and flight speed under one Agility movement stat.
- Replaced redundant swim/flight speed with Type 4 jump height.
- Applied the same mass and air-state factors to movement and jump height.
- Added a provisional five-unit base air cost for jumping.
- Added a localized jump-cost test control and displayed movement and jump
  calculations in the debug panel.
- Kept physical movement and jump-height changes data-only until verified.

## 0.12.0 — Evasion calculation pipeline

- Added Type 2 growth calculations for Agility-based base evasion.
- Applied the documented total-mass multiplier to base evasion.
- Applied 75% retained evasion while tired and 25% while breathless.
- Stored the current air state in play scope so UI rendering requires no
  cross-context function calls.
- Displayed base, mass-adjusted, and effective evasion in the debug panel.
- Applied mass to evasion through the same formula used by movement.
- Kept actual attack-evasion rolls pending for the combat system.

## 0.11.1 — UI context correction

- Marked the read-only air ratio and state helpers as UI-callable.
- Fixed GZDoom's `Can't call play function IsBreathless from ui context`
  startup error.
- No formulas, resource values, or gameplay behavior changed.

## 0.11.0 — Air regeneration and resource states

- Added automatic air regeneration based on the documented eight-minute full
  recovery time.
- Scaled regeneration per second with maximum air so larger pools still take
  eight minutes to refill completely.
- Added normal, tired, and breathless state detection.
- Set tired at 50% air or less and breathless at 10% or less.
- Displayed localized air state and regeneration rate in the debug panel.
- Kept movement and evasion penalties inactive until state detection is tested.

## 0.10.0 — Live air-resource test

- Corrected the overload threshold from above 80% to above 75% capacity.
- Distinguished overload from exceeding the absolute 100% capacity.
- Added persistent current air alongside calculated maximum air.
- Added provisional controls to consume one ten-unit base action and refill air.
- Applied the confirmed carry-load multiplier to the test action cost.
- Displayed current air and adjusted action cost in the localized debug panel.

## 0.9.0 — Carry-load air consumption

- Replaced the provisional mass-based air factor with the confirmed
  carry-load formula.
- Increased air use by the equipped-load percentage through 75% capacity.
- Doubled only the excess above 75% capacity.
- Confirmed test factors: 50% = x1.50, 75% = x1.75, 80% = x1.85, and
  100% = x2.25.
- Added a separate implementation-status guide for beginners.

## 0.8.0 — Mass and equipment-load calculations

- Added provisional equipped weight in five-unit test steps.
- Calculated total mass and equipped-load percentage.
- Added normal, heavy, and overloaded load states.
- Calculated push resistance, knockback, movement, air-consumption, and
  evasion mass multipliers from the documented formulas.
- Displayed localized mass values and states in the debug panel.
- Kept all effects data-only until their calculations are verified in GZDoom.

## 0.7.0 — First derived character statistics

- Added reusable Type 1 and Type 4 growth calculations.
- Calculated maximum health from Constitution.
- Calculated maximum mana from Patience.
- Calculated maximum air from Resilience.
- Calculated carry capacity from its confirmed base of 100 and Strength.
- Calculated base mass from identity and class.
- Displayed all five localized values in the debug panel.

## 0.6.0 — Complete six-page character creation wizard

- Connected layer allocation, individual allocation, and summary pages.
- Required all four layer points and all thirty individual points before advancing.
- Added a dedicated add-point action for allocation pages.
- Added transactional editing: cancelling restores the last confirmed profile and points.
- Added final confirmation state and localized six-page navigation.

## 0.5.0 — Character creation wizard, first three pages

- Added a localized step-by-step character creation overlay.
- Added origin, identity, and class selection pages.
- Added open, cycle, confirm, and back actions using synchronized events.
- Reused the previously validated profile and attribute calculation functions.
- Reserved the remaining three pages for layer points, individual points, and summary.

## 0.4.0 — Character point allocation rules

- Added four free points assignable among the four attribute layers.
- Enforced a maximum base value of 15 for every layer.
- Added thirty individual points assignable among twelve attributes.
- Enforced the +5 individual cap and the twice-base cap.
- Added localized debug selectors, point counters, allocation controls, and reset.
- Profile changes now reset allocations so an earlier bonus cannot invalidate a new base.

## 0.3.0 — Origin, identity, and class profiles

- Added the four documented origins, identities, and classes.
- Applied their 5/3/3/1 distribution patterns to the four attribute layers.
- Added multiplayer-aware debug commands for cycling each profile choice.
- Displayed the current profile in the localized attribute debug panel.
- Removed the conflicting provisional F7 default binding.

## 0.2.0 — Toggleable attribute debug panel

- Added a localized overlay displaying all twelve primary attributes.
- Added a user CVar that remembers whether the panel is visible.
- Added a provisional F7 control and a Customize Controls entry.
- Registered the debug overlay as a GZDoom event handler.

## 0.1.1 — ZScript constant syntax correction

- Removed the invalid explicit `int` type from class constants.
- No gameplay values or attribute behavior changed.

## 0.1.0 — Primary attribute data model

- Added the twelve documented primary attributes.
- Added a separate attribute container for each player.
- Added neutral test initialization at level 3 per attribute.
- Added a total-level calculation whose expected test result is 36.
- Added English and Spanish names for every primary attribute.

## 0.0.3 — Windows filename compatibility

- Renamed the ZScript source folder from `zscript` to `caelum`.
- Fixed a Windows case-insensitive filename collision between the root
  `ZSCRIPT` file and the former `zscript` folder.
- Corrected the player-class include path.

## 0.0.2 — Windows launcher correction

- Corrected batch parsing of paths containing parentheses, such as
  `C:\Program Files (x86)`.
- Kept explicit error messages for missing GZDoom and IWAD files.

## 0.0.1 — Initial scaffold

- Added a repeatable Windows development build.
- Added the custom `CaelumPlayer` ZScript class.
- Added English and Spanish localization.
- Added an asset-license register.
