# Issue #449 - Siege machines

Author rules are consolidated in SYSTEMS5.15.2. CA449-01 remains outstanding;
this evidence does not authorize merging V5.15 or substitute for author tests.

Text review follow-up: both CA_PRISONER_SIEGE_ACTIVE translations now describe
capture/destruction instead of the retired guard-death rule. The localized source
and generated indexes pass their freshness check; document index generation and
git diff --check pass. Gameplay files and the functional evidence below are
unchanged. This correction does not claim a new author acceptance.

The isolated harness reuses validation_v5_15_0 and the native sync observer from
validation_v5_12_7. GZDoom4.14.2 runs unpaused in the background at5% audio with
isolated configurations/saves. Private engine/IWAD, generated fixture maps, saves
and packages are retained under build/v515/issue449 and are not distributed.
Each run records runtime/engine/fixture hashes and commands. Local lockstep peers
are real native processes; Internet multiplayer is not established.

Final functional evidence (issue449-work08.pk3):

- delivery-checks:32 checks per peer, including real collision proxy damage,
  ownership/capture, one-worker reservation, proportional repair cost/time,
  interruption without free extra healing,25/50/100% construction inputs,
  both workshop recipes and persistent world outputs.
- delivery-travel: the same checks plus native two-peer hub return; work/reservations,
  original machine references, constructed identities and damage remain intact.
- delivery-timed:18 checks per peer with native thirty-second sabotage/capture, ten-percent
  sabotage repair, real console Attack/alternate Attack and a complete cannon cycle
  using the existing one-operator loading rate. Native sync remains clean.

Intermediate failed attempts are retained. Reserved names/scope errors were caught
by native compilation. A local `repair` shadowed enum `REPAIR`, skipping costs and
using the default thirty seconds; `missingHealth` plus explicit initial reservation/
duration checks corrected it. Hub traversal cleared inventory references to world
parts; work schema2 adds a serial-owned map anchor to restore the same references.
Local prediction must never release a persisted operator bond or emit a shot:
prediction now filters input only. The final timed harness sends native console
input instead of editing `player.cmd` from WorldTick. One-operator cannon checks
must allow the existing doubled loading time; the fixture also explicitly enables
the scenario's existing unlimited ammunition rule.

The delivery runtime SHA256 is
`764f2cd1be3d90d4b9de608b7f50c7441081006181bb70d90fdaf693a51f806b`.
Additional final evidence:

- delivery-restored:5 further checks per peer preserve saved interrupted work,
  structural damage, component identity and idempotent destruction.
- ram01:13 checks with real allied guards, native movement and collision. All six
  operators follow the captured ram; its head reaches and damages the wooden gate.
- legacy-migration01:6 checks loading the untouched pre-449 package save; original
  pieces are rebound once, guard-death neutralization is replaced, actual destruction
  and won outcomes remain. legacy-rollback01 passes with original package/save.
- delivery-spanish/delivery-english pass the32-check fixture and produce native
  screenshots. The owned barricade and both panels were visually inspected; text
  and controls fit. Fixtures use private development IWAD textures, not new game art.
- Generator output is byte-identical across two reruns; original ram moving/frame
  masses remain2874.9907009909484/2250.645505735003kg. Static validator and diff checks pass.

work-restored03 terminated in NVIDIA nvoglv64.dll with Windows exception0xc0000409;
its Windows event is retained. Exact retry work-restored04 and delivery-restored
both pass on two peers. Early timed attempts and direct-input fixture failures
are retained separately rather than silently discarded.

Paired application presentation measurements: base#448 siege1.37967FPS,
p95/p99/max821.17/1340.57/1340.57ms; delivery#449 siege1.41598FPS,
776.68/833.36/833.36ms. Simulation mean/p95/p99/max is42.75/74.21/86.81/417.21ms
for the base and41.57/73.59/82.40/95.31ms for delivery. The original601-defender,
797-to898-attacker census is retained. These samples show no clear regression;
they do not establish a general speedup or playable siege rendering. The existing
severe siege presentation limitation remains, and performance acceptance is false.


The ground-facing control measures75.78768FPS with p95/p99/max17.61/18.67/20.69ms; simulation mean/p95/p99/max28.58/38.62/42.91/46.46ms. Application presentation requests are not monitor scanout.


## Author acceptance ? 2026-11-10

CA449-01 (origin5.15.2, #449) passed by explicit author confirmation of
all V5.15 tests. The author requested merge/closure; PR637 is merged and
#449 is closed. HISTORY records the acceptance separately from the original
native evidence above. Earlier pending labels describe the delivery state.
This documentation-only acceptance update adds no native/performance measurement;
recorded limitations and the shared laboratory contamination follow-up remain.
