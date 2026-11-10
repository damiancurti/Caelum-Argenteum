# Issue #448 - Military command

Author rules and the two follow-up reserve/return decisions were approved on
2026-11-09. CA448-01 remains pending; no V5.15 merge is requested by this report.
This evidence is separate from #447 and the later #449-451 deliveries.

Native environment and sync instrumentation reuse validation_v5_15_0 and
validation_v5_12_7: installed GZDoom4.14.2, Windows/Vulkan, isolated saves and
configuration, background simulation unpaused,5% audio. Private engine/IWAD,
fixture WADs and saves are not distributed. Every run retains package/engine/
fixture hashes, commands and logs under build/v515/issue448.

Native results:

- compile-01 caught reserved ZScript identifiers; compile-02 caught
  case-insensitive parameter shadowing. Both failed logs remain available.
- checkpoint-03/restored-03 passed25 checks per actual lockstep peer, including
  access conjunction, known points,101-body capacity, succession and saved orders.
- Final checkpoint/reload passed34 checks per actual lockstep peer: access,
  bounded receipt, known destinations, group capacity, succession, saved identity,
  real native movement and same-tic resurrection. delivery-spanish and
  delivery-restored repeat these on the delivery package, including the actual
  Crouch+Use interaction. The Spanish panel was visually inspected without clipping.
- final-legacy passed5 checks loading the original #447 save. final-prototype
  migrated the saved schema1 command into schema2 on two peers. final-travel
  retained exact orders, commander,101 bodies and finite reserves across a real
  hub round trip on both peers. final-original-rollback passed2 checks with the
  original #447 package and original save.
- real-routes used the actual packaged MAP03 geometry, cannon and native soldiers:
  the elevated operator descended the authored stairs; the guard returned to the
  original barracks entrance. Both remained visible, solid, alive and counted.
  No teleport or healing was used. Private interiors remain separate hubs.
- reviewed-restored failed because the fixture allowed140 tics for movement whose
  native See state advances every4 tics, and the guest exited too early. The
  retained motion-diagnostic confirms actual displacement. A distance/speed/state
  deadline and longer guest lifetime fixed the harness; no production speed boost.

results.json and deterministic native-logs.txt.gz retain successful and failed
runs, exact hashes, commands and native sync evidence. Delivery package SHA256:
2749a49409add6f16f6c1a2a8f905964282442001bfc37b9da4d241220a39ef2.
Earlier migration/travel checks retain their original package hashes: subsequent
runtime differences are the return entrance/door correction and Crouch+Use text
and input, covered by real-routes and the delivery checkpoint/reload.

Presentation and simulation (application requests, not display scanout):

| Scene/package | Mean presents/s | p95 / p99 / worst interval, ms | Mean simulation tic, ms |
| --- | ---: | --- | ---: |
| Ground, #447 baseline | 62.71 | 18.71 / 20.44 / 23.41 | 28.58 |
| Ground, #448 final | 72.20 | 18.09 / 19.35 / 20.95 | 28.57 |
| Siege, #448 initial final | 1.256 | 898.98 / 905.93 / 905.93 | 47.02 |
| Siege, fresh paired #447 | 1.351 | 812.79 / 823.72 / 823.72 | 43.53 |
| Siege, fresh paired #448 delivery | 1.418 | 780.88 / 797.79 / 797.79 | 41.65 |

The initial slower siege observation prompted the fresh paired comparison.
Both paired runs start with601 defenders/797 attackers and end with601/898,
matching registered health and total population. No repeatable command-patch
regression is established; these measurements do not establish a performance
improvement either. The existing active siege remains far below playable frame
rates. It is not performance-accepted. Mansion/sewer evidence belongs to #447;
no new60FPS claim is made. Temporary keep-awake ownership was released.

Use run_native.py with a fresh label, --runtime and --players1/2. The shared
harness supplies --load-directory, --legacy-fixture, --runtime-name and
--suite travel. Final reporting must distinguish static checks, native evidence,
presentation/frame-time measurements and explicit author acceptance.
