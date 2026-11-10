# V5.15.3 / #450 validation

Implemented: existing west exterior and stair/wallwalk entry discovery, one-time
pre-battle prisoner intelligence and intact original-machine reporting. Geometry,
main victory, faction operation and previous machine behavior are unchanged.
CA450-01 is pending author acceptance; PR delivery is not that acceptance.

Native engine: GZDoom4.14.2 on this Windows11 machine, isolated configuration,
unpaused background execution and5% audio. Two real native lockstep peers are
checked with the existing non-mutating native inconsistency observer. No Internet
or monitor-scanout claim is made. Exact commands, hashes, results, unsuccessful
attempts and compressed native logs accompany this document.

| Check | Evidence and result |
| --- | --- |
| Final functional run | `delivery-checks`:19 assertions on each of2 peers; unknown intelligence, one100-member reserve reduction, repetition, old reserve revision, actual100-body arrival, late preparation, capture/condition/ownership exclusions, individual+50 rewards, replaced-slot identity and undisclosed routes pass. |
| Native reload | `delivery-restored`:6 assertions per peer; original machine, remaining6200 after committed arrivals and100 withheld, discovery and paid identities persist. |
| Native hub travel | `delivery-travel`:initial19 plus6 return checks per peer pass; no regenerated reserves or duplicate rewards. The isolated scene explicitly stops further arrivals while its100 bodies remain real. |
| Old save | `legacy-migration`:untouched final #449 save loads with6 migration checks. New schema initializes without invented preparation, visits or eligibility; old damage, ownership and interrupted native work/reservations are preserved. |
| Real city movement | `routes02`:8 checks, native `+forward` through the west staircase, wallwalk, return descent and west exterior segment. No noclip or per-frame teleport. Stairs0?256MU?ground and both visited markers pass; a remote stair remains unknown. Fixed initial placement and orientation are diagnostic harness controls. |
| Real dialogue | `dialogue-spanish` and `dialogue-english`:actual native guard conversation and inventory delivery action pass with2 peers; repetition does not pay again. Both native screenshots were visually inspected: wrapped choices fit above the HUD. |
| Deterministic data | Two independent generator renders match the checked-in37 entry regions byte-for-byte. Read-only project validation rejects stale route data; LF checkout rules preserve hashes. |
| Static | Project validation:0 errors, CONTEXT2484 words. Dialogue/localization assembly and document index are current; diff whitespace check passes. |

Final package: `build/v515/issue450-final.pk3`, SHA-256
`d7d0e99825d4682f2850f5c7c58b163bc13b3a771277d140c84ccbc9ab7d2727`.
The functional package `issue450-delivery.pk3` has SHA-256
`ea3337ecaf9455087958982a163d726a8b88385d25363b0e079a31d299556d79`.
A complete ZIP member comparison proves the only final differences are a trailing
blank line removed from LANGUAGE and its two generated localization indexes.
All gameplay/geometry members are byte-identical. Final native presentation runs
also compile and execute the final package. `routes02` uses the same gameplay
before the diagnostic version banners changed; no geometry or route logic differs.

The original #449 package/save are retained unchanged for rollback. Its already
passing original-package reload evidence is reused from validation_v5_15_2 rather
than treating a new-schema save as an old-runtime rollback. No production save,
profile or user configuration is replaced by these isolated tests.

Retained unsuccessful attempts:

- `checks01`:ZScript reserved local name `state` caused a compile error; renamed
  to `tactics`, then all subsequent functional/native runs compiled and passed.
- `routes01`:the harness allowed only650 tics for the complete out-and-back walk
  and its `mode` parameter shadowed the saved `Mode` field. Both harness defects
  were corrected; `routes02` completes both paths with ordinary native movement.
- `travel03`:the intentionally incomplete fixture enabled absent reinforcement
  admission without installing its six exit nodes. The fixture now installs the
  real exit data, checks one real100-body arrival, then stops further arrivals for
  its persistence check. `delivery-travel` passes. This was not a production map
  failure or a change to accepted absent-battle rules.

Native logs retain failed assertions and full fatal stacks. Screenshots are
validation evidence; private development WADs/PK3s/saves and engine/IWAD resources
are not packaged or distributed as game content. The route screenshot named
`route-stairs.png` is the view after returning to the street; waypoint logs are
its climb/descent evidence. Representative formation/cannon traversal remains
covered by the unchanged #448/#449 native geometry evidence. Full author play,
all37 stair entries and Internet sessions remain outside this isolated coverage.

Final native performance observations (same recorded machine/observer as #449):

| Scene | Application presents/s | Present interval p95 / p99 / max (ms) | Simulation mean / p95 / p99 / max (ms) |
| --- | --- | --- | --- |
| Active siege |1.4434|752.5932 /756.9568 /756.9568|40.7391 /71.0722 /77.5267 /90.2477|
| Peaceful ground control |77.1021|16.8983 /18.4375 /19.8767|28.5820 /38.3298 /41.9721 /46.6488|

The siege census retains601 defenders and797?898 attackers. The previous #449
reference is1.4160 presents/s and p95/p99/max776.6806/833.3624/833.3624ms;
its ground control is75.7877 presents/s. These are limited observations, not a
claimed speedup. Severe pre-existing active-siege rendering remains unacceptable;
35 simulation tics/s or a successful functional assertion cannot establish60FPS.
New runtime work is bounded to37 geometric entry checks per active city character,
one owned campaign record, at most8 cooperative identities and the original12
machine roster only on explicit reporting. No new global actor census is added.


## Author acceptance ? 2026-11-10

CA450-01 (origin5.15.3, #450) passed by explicit author confirmation of
all V5.15 tests. The author requested merge/closure; PR638 is merged and
#450 is closed. HISTORY records the acceptance separately from the original
native evidence above. Earlier pending labels describe the delivery state.
This documentation-only acceptance update adds no native/performance measurement;
recorded limitations and the shared laboratory contamination follow-up remain.
