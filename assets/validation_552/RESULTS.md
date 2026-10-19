# V5.5.2 / #311 — persistent contact identity and anatomical armor

**Technical gate: PASS — 24 required native runs; 37 runs preserved.**
GZDoom 4.14.2, Windows 11, 2026-10-18. Implementation base: accepted #310 at
15da9704. Manifest source_commit names that checkout base, not a committed copy
of the later working tree; frozen package hashes identify the actual tested code.

The native audit reproduced a zero release distance caused by
case-insensitive parameter shadowing in ImpactContactState.Initialize. The
minimal production fix assigns the field explicitly and introduces local
revision-1 repair before each player/NPC contact-latch update.

The migration preserves shared identity, pending work/geometry and timestamps.
Only defective nonpositive distances and their invalid geometric separation
count are repaired. Positive legacy distances remain; repeat repair is inert.
Original saves and runtimes are retained for reversible testing. Existing damage
and already-expired edges are not reconstructed. One new serialized integer,
ReleaseDistanceRevision, defaults to zero in older saves; initialized/repaired
edges carry revision 1. No map, weapon, anatomy or damage balance changes.

The definitive reproduction is issue311-explore05: ReleaseDistance remains 0,
SeparatedTics rises 1..4 despite fresh LastCollisionTick, then the edge expires.
The corrected trace has distance 48 MU and zero geometric separation at 32 MU
center spacing. This is the existing 16+16+56/4+2 rule, not a new tolerance.
Both player and NPC update paths repair locally; there is no global actor scan.

| Required native coverage | Evidence |
| --- | --- |
| SI energy, initiator/frame invariance, approach/separation, tangent/oblique, clipping/orientation/crouch | Reused energy/combat source runs; 68/47 checks |
| Real falling body/floor/rock/gate/cannon and pressure contacts | motion-final01, 15 checks |
| Gate proxies/serials, ram and cannon defenses | siege-final01, 63 checks |
| Same-tic distinct sources, player receives exactly two events, three-body chain/stack, independent gate sources, armor broken between events | multiple-current, 21 checks |
| New revision, local NPC/player repair, shared identity, pending work/geometry, no damage, repeat repair, valid legacy distance | migration, 14 checks |
| Pending contact/work persistence | contacts-final01 / contacts-reload, 2/11 checks |
| New save, genuine 5.5.1 upgrade, upgraded reload, partial-separation save/load, native recontact | Named current/upgrade/separation runs in evidence.json |
| Reversibility | Original runtime loads original save (known zero-distance defect retained), and also loads the converted save |
| Bounded CPU cost | Six 350-sample runs below |
| Interactive preview | Native visible smoke run; screenshot inspected locally, three bodies/counters/instructions visible. Zero numeric assertions; not author acceptance. |

The old checkpoint contains an active zero-distance edge; the converted save
contains ReleaseDistance=48 and revision 1. The separated save retains a partial
1..4-tic countdown. collect.py checks the actual serialized objects and copied
save hashes. Pending-work retention is tested in the native migration unit and
the separate work-persistence fixture; the old multiple-contact checkpoint itself
contains zero pending work. Original saves are never overwritten.

Reused #194 tests remain in validation_5211. Only the player's obsolete landing
expectations are adapted to accepted #211's 150% capacity: 160 J and 68 HP replace
360 J and 253 HP for that fixture. No #211 production rule is changed. #195's
accepted species/recipient cushioning and bull-mass checks remain referenced in
validation_5212. New coverage includes simultaneous native sources, a three-body
chain/stack, player contacts, independent gate sources using the same serial,
and armor broken by one event before another event in the same tic.

The dense fixture measures instrumented CPU time for Super.Tick and nested
CollidedWith in 64/512 generic combatants. The paired scenes isolate pairs; the
compact grid has 688 live edge references across 512 bodies at the final sample:
344 shared pairs, counted at both endpoints, including bodies with more than one
neighbor. The diagnostic unique counter counts accumulated pair-tic resolutions,
not distinct pairs. All bodies survive. After 105
warm-up tics, each run records 350 per-tic samples. One run per configuration:
these are observed samples, not confidence intervals or universal subsystem costs.

| Layout / population | Caelum contacts | Body mean ms/tic | Body p95 ms/tic | Nested contact mean ms/tic | Native callbacks/tic |
| --- | --- | ---: | ---: | ---: | ---: |
| Pairs / 64 | Off | 0.355 | 0.587 | 0.025 | 128 |
| Pairs / 64 | On | 1.590 | 2.387 | 1.280 | 64 |
| Pairs / 512 | Off | 2.342 | 3.496 | 0.154 | 1024 |
| Pairs / 512 | On | 10.481 | 13.251 | 8.213 | 512 |
| Compact grid / 512 | Off | 2.788 | 4.171 | 0.152 | 1024 |
| Compact grid / 512 | On | 13.139 | 17.340 | 9.463 | 830 |

Contact time is included in body time: **do not add them**. Forced restoration of
positions/velocities lies outside the timers. Off bypasses Caelum impact contacts
while retaining native solid-body motion; this changes subsequent resolution,
pressure, damage and callback counts. The difference therefore includes their
combined consequences. It is not a pure lookup benchmark. No siege AI, frame
presentation, city renderer or FPS claim follows. Campaign FPS remains postponed.

The normal built package SHA256 is
47d92bb8a03cc46aa7b57cec18a5694b290f89c0bc4ea37558aab092ca1a603b.
All 16,380 members match the final frozen runtime. Earlier component runs have
identical members after normalizing only two diagnostic version labels and those
files' CRLF/LF endings; gameplay source is byte-identical. Compared with accepted
5.5.1, only the four contact implementation files and those two labels change.
Static validation and normal build_dev.ps1 packaging pass. No assets, executable,
IWAD, generated fixture PK3 or save file are distributed by this patch.

Evidence is gated by collect.py against exit codes, completion/failure markers,
actual runtime/fixture hashes, immutable script manifests, one engine identity,
package membership and serialized saves. Text logs/run records and manifests are
retained under evidence/; evidence.json includes all 37 runs. Five pre-fix runs
retain the contact defect. Other excluded attempts preserve the obsolete #211
oracle, a preview exec-line parser error, an exit before a queued rollback event,
and a rollback assertion made after the old contact had already expired. Three
earlier successful controls are superseded. A fourth early control completed
assertions but exited before its save was written; it is not migration evidence.
Collector development also corrected hash case normalization and recognized the
two diagnostic files' line endings; no native failure was waived as a pass.

Use fresh build directories and run labels. prepare.py reuses validation_5211
sources and freezes the runtime, fixture and script hashes. run_native.ps1 rejects
a second engine. run_suite.ps1 requires the named legacy/current checkpoints;
their creation/copy provenance and exact invocations are in evidence.json and
the run records. Local frozen packages/saves remain in build for reproduction
and rollback. The read-only cross-review found no production/migration blocker.

Author acceptance CA311-01 (origin 5.5.2 / #311) passed on 2026-10-18:
"Si, las pruebas dieron bien." The author confirmed the explained interactive
collision/separation/stack/save-load preview. Numeric native checks remain a
separate evidence level; campaign FPS remains postponed.
