# V5.5.1 / #310 — bounded combat dispatch extraction

Baseline: accepted #309, `ca8206bc98b2713c7ec5159df63c07a5276501ff`.
GZDoom 4.14.2, Windows 11, Vulkan, private fixtures, background unpaused,
5% audio and one engine at a time. FPS remains deferred.
Manifest `source_commit` identifies the checkout base before the #310 commit;
the frozen runtime/source hashes identify the actual candidate bytes tested.

## Responsibility map

| Previous source and callers | New implementation | Retained state/commit owner |
| --- | --- | --- |
| Player.PerformEquippedWeaponPrimaryAttack, called by native legacy/family/magic selectors | CombatDispatch.PerformEquippedWeaponPrimaryAttack(user) | Pawn physical/magic start; special bolas/utility services unchanged |
| Player.PerformEquippedWeaponSecondaryAttack, same adapters | CombatDispatch.PerformEquippedWeaponSecondaryAttack(user) | Pawn ADS/javelin latches, exact equipment and start paths |
| Player.PerformLargeWeaponSweep, native physical Zoom | CombatDispatch.PerformLargeWeaponSweep(user,type) | Pawn activation and BeginPhysicalAttackCycle; SupportsLargeWeaponSweep query remains |

All three pawn signatures remain adapters. No UI, NPC AI, native weapon state,
movement, physics, damage, ammunition, resource or exact-item wear implementation
moves. `BeginPhysicalAttackCycle`/`AdvancePhysicalAttackCycle`, physical/ranged/
javelin releases, `PerformDebugStaffAttack`/`CompletePendingStaffCast`, reload,
charge and existing inventory/resource services still own their mutations.
No fallback player lookup, second inventory, service instance or saved field.

`extraction.py` proves all 653 pawn field declarations, 562 signatures and 559
other bodies unchanged. Moved bodies normalize back to the original tokens,
including literals; only explicit `user` qualification and the established
`CanMutate` guard are added. The guard precedes clock refresh, so prediction or
a stale receiver cannot indirectly release a previously prepared attack.
Native state labels and serialized identities remain; no migration is required.

## Evidence and coverage

The fixture reuses `validation_550/prepare.py`, its native-input probe and its
strict runner. New paired observations use identical command scripts, random
seed and probe source on baseline/current packages; every recorded tic includes
animation starts, exact ItemId/wear, Air/Anima, magazine/reserve, pending states,
cooldowns, target impacts and HP loss. Special cases cover a three-target sweep,
javelin near/far, held utility streams, prepared bolas and the authored spear
secondary no-op. Empty-resource controls must not start or hit.

Authority controls directly invoke all three commands with null, detached,
stale and predicted receivers, including real mature physical/magic preparations.
Snapshots check resource, timer, latch, block, pending-state and projectile
counts. The native two-pawn control dispatches from the human pawn and verifies
the bot's resources/equipment remain untouched in that same call. It is a
one-process non-interference check, not symmetric bot input, network transport
or full multiplayer support.

All **31 required native executions pass**. `evidence.json` preserves 40 runs:
33 completed successfully (including two superseded cast setup controls), and
seven diagnostic failures explained below. `comparison.json` gates the final
required set, rather than treating every historical run as final evidence.

| Final control | Result |
| --- | --- |
| Baseline/current 20-case dispatch pair | 77 checks per run; all 1,793 recorded observations identical |
| Invalid receiver/mature-action guards | 31 checks |
| Actual normal-package three-target sweep | 5 checks |
| Human-to-bot non-interference | 6 checks |
| Four held-Fire automatic reload routes | 16 checks |
| Physical immobilization, baseline/current | 4 checks each; no target hit |
| Magical equipment cancellation, baseline/current | 6 checks each; no payment or target hit |
| Physical/magical native death, baseline/current | Four runs, 6 checks each; retained-state observations match |
| Sword/wand/carbine current save/load/hub/switch plus original #309 load | 15 runs; same ItemId, wear, ammo and active timer |
| Save/load with R held | 10 checks; no repeated request |
| Immobilization and empty ammunition reserve | 7 checks |

Persistence logs include restored probe counters, so their reported checks are
not summed as new unique assertions. #309 accepted balance metadata and unchanged
damage formulas are reused; this patch does not rerun every tier/essence case.
Validation and normal packaging pass. All **16,380 members** of the normal
PK3 equal the tested frozen source byte-for-byte. The normal package hash is
`5cdc6bb297c70e0ca6f8571d60e973499b94749dc53a39d2f4fe9b0da27a50d1`;
the deterministic frozen runtime is
`4c09ed116ce56b7bb55d382033356cde4aa9950dfe1f2efdce375f5e7750efd5`.
Independent read-only review found no production blocker; its stricter execution,
hash, completeness and coverage requirements are incorporated in the collector.

## Preserved diagnostic corrections

- `issue310-current01/authority-01`: probe used `RangedAimActive` instead of
  the actual field `RangedAimModeActive`; engine compilation rejected the probe.
- `issue310-current02/guards-01`: all negative guards passed, but the positive
  control wrongly expected a sweep with only a wand equipped. The restored
  magical receiver now requests its primary attack.
- `issue310-baseline02/paired-01`: bolas correctly transfer the real item to
  their native flight actor. The fixture incorrectly expected it to stay in
  the hand; its assertion now checks the authored transfer. The same revision
  makes sweep targets eligible monsters and holds utility input long enough
  to exercise its stream, rather than counting a one-tic request as delivery.
- `issue310-final02/paired-02`: the secondary sweep targets' surface distance
  exceeded the authored 84-MU reach. They were moved within reach; no production
  range or target filter was changed.
- `issue310-final03/death-0-current` and the matched original-runtime control:
  the dead pawn retains an inert physical-pending field because personal time
  returns before combat updates. Neither runtime produces a hit. The corrected
  death control measures the required observable contract (no subsequent attack,
  projectile, payment or wear), records the retained fields and compares both
  runtimes. It does not silently impose a new death-field cleanup rule.
- `issue310-final03/stun-1-current`: assigning lucidity immobilization does not
  cancel an already accepted magical cast under the existing rules; the spell
  completed once. The final magical cancellation scenario uses an actual
  equipped-item change. Its first `cast01` fixtures refilled reserves as part
  of generic setup; `cast02` disables that refill so the no-payment assertion
  observes the actual unchanged Anima value. Earlier passing setup observations
  are retained but are not the final resource-interruption evidence.

These are fixture corrections; production extraction remains unchanged.

## Reproduction

Run `python -X utf8 assets/validation_551/prepare.py --directory <fresh-name>`;
add `--runtime <frozen-old-production.pk3>` for a matched baseline. Use the
existing `validation_550/run_native.ps1` with the prepared directory and a fresh
label. `paired.cfg` chains bounded single-line scripts explicitly. `guards.cfg`
requires `-Fixture guards.pk3` and the current runtime. Keep private IWADs,
executables, generated maps, saves and screenshots out of distribution.

`run_suite.ps1` accepts separate current/baseline, death and cast directories;
its resume switches preserve failed observations without reusing run labels.
The two-pawn run uses a private copy of the installed GZDoom root files under
`build/issue310-engine` and `zcajun/bots.cfg` with one test bot definition.
The installed engine is not modified. Legacy controls copy the preserved #309
saves; their source and destination SHA256 must match. To reproduce from a new
checkout, recreate those #309 saves using its committed fixture first.

The collector rejects missing runs, missing invocation records, nonzero exits,
wrong runtime/fixture hashes, mismatched paired engines/scripts/probes, altered
old-save copies and any observation difference. The normal PK3 may have a
different ZIP byte hash; that explicit exception requires both its actual tested
hash and byte-for-byte equality of every package member with the frozen runtime.

Author acceptance **CA310-01** (origin 5.5.1 / #310) is pending. The prepared
`issue310-preview01` uses the same production runtime with three visible dummies
and Spanish on-screen/terminal controls. Opening it is not author acceptance.
