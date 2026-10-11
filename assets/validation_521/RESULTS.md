# 5.2.1 / #177 native and static evidence

Base: 90bcc35870db67c3c099a67aa094ea5b4aedf5d2 (#147 / PR176), Windows 11,
GZDoom 4.14.2, Vulkan, isolated configs/saves, no autoload, RNG 177, 5% master
volume, unpaused background execution. Engine, runtime, fixture hashes and
commands: runs.json. Log files are whitespace-normalized; original hashes remain
in the run records. No engine, IWAD, package or save is distributed.

## Native results

- equipment-03: actual ranged Rulo preparation preserves 24 cartridges and
  leaves new bolas active; extra crafting output selects its exact instance;
  owned Box, incompatible size, wear and repeated-grant/manual-choice guards pass.
- route-02: mandatory tutorial actions and native weapon attacks, gifts and
  crafting payment/output pass; initial fight staging, wounded resources,
  four helpers, native autosave and hostility grace survive. All four physical
  walls and a jump beyond the old vertical bound retain the player position.
- route-baseline-01 reproduces missing autoequip and arena recentering on the
  base package. route-migration-02 loads that older active fight with exact
  equipment IDs, tests every edge, completes the real Rulo/Palomo transactions,
  and preserves the same sleeping bag through the actual departure cleanup.
  The unrelated Fool prerequisites are seeded; this is not a full campaign run.
- chest-03: native loot preview before Ronnie, complete recipe graph, progressive
  optional stock, one-time ledger, capacity and aim checks pass. A shield chosen
  before the weapon uses the current character size. chest-es.png shows the UI.
- provisions-live-01: real 200 kg body, repeated water beyond the old daily
  quota, bounded/idempotent stock and read-only forecasting pass. The actual XL
  shotgun task requires 281,990.224339 seconds. The forecast covers 15,318,259
  personal tics (168 food portions, 127 canteen sips); live execution completes
  and autoequips the shotgun, ending at hunger 97.456322/thirst 91.232969.
  No task duration is shortened in this check. Runtime took 216.86 s including
  startup, forecasting and scripted idle waits; this is not a pure benchmark.
- palomo-es-01 and palomo-en-01 exercise native reply navigation and shotgun
  labels; English preview text is populated. Both captures are retained.
- table-04: upper table uses existing 5 L canteens; native presentation captured.
- maze-01: MAP02 opens/collects through its original typed chest endpoint;
  stock remains finite, Close works, and mansion restocking creates no supplies.
- rest-fresh-01: no fixed MAP02 beds; one bag deploys/folds through native safe
  rest. rest-baseline-01 saves a real occupied bed on the base package;
  rest-migration-01 preserves that session, health and issued-material ledger,
  grants one bag, then retires the bed only after standing. Other empty beds
  retire immediately. Original and migrated saves remain local for reversal.

Final source changes after provisions-live-01 are limited to departure bag
preservation and shield-first sizing, separately covered above. Resource/time
simulation in that full-duration run matches the delivered code.

## Diagnostic corrections and limits

Earlier equipment fixtures omitted Ronnie's preceding Pickaxe gift and the
actual Box owner; fixed setup produces equipment-03. route-01 measured the jump
only after its peak; route-02 tracks maximum height. The first chest capture
had an unrelated queued introduction; its corrected capture suppresses that
fixture-only notice. Table capture setup likewise waits for character initialization and uses an actual chair position. route-migration-01 attempted to use the return door in the
same tic that it seeded exit readiness, before presentation created it; the
corrected fixture explicitly runs normal door presentation before departure.
Failures and the VM diagnostic remain in logs/runs.json; none are hidden as
successful checks. Map travel and full combat are not inferred from teleporting
fixtures; author acceptance remains CA177-01, independently of pending CA147-01.

## Reproduce

Run prepare.py, then run_native.ps1 with a unique Label and the recorded Fixture,
Script, Map, Baseline or RuntimeAlias/LoadGame arguments. The helper uses a hidden
isolated native process and refuses overlapping #177 tests. It does not stop
the author's game. Old-save fixtures need their baseline runtime basename;
prepare.py supplies the current code under that alias for migration checks.

Static validation and the normal builder are recorded in static.json after the
final documentation/index update. The normal build must have the same unpacked
members as the native tested production package. CA177-01 is still outstanding.
