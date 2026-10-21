# Issue #384 validation - release 5.6.4

The required set passes **16 native runs, 113
assertions and zero unexpected failures**. CA384-01 passed author review on 2026-10-20; initial startup qualification is in HISTORY.
Old-code regression runs are separate and reproduce five expected failures.

| Run | Runtime | Passing assertions |
| --- | --- | ---: |
| legacy-save-01 | legacy | 6 |
| legacy-ice-save-01 | legacy | 4 |
| ice-upgrade-01 | current | 7 |
| final-probe | current | 7 |
| final-tables | current | 16 |
| final-tables-reload-02 | current | 4 |
| final-upgrade-02 | current | 14 |
| final-reload-02 | current | 6 |
| final-hub-02 | current | 12 |
| final-original-rollback | legacy | 6 |
| final-legacy-tables | legacy | 16 |
| final-legacy-tables-upgrade | current | 4 |
| final-legacy-tables-rollback | legacy | 4 |
| final-current-ice-save | current | 4 |
| final-current-ice-reload | current | 3 |
| final-smoke | current | 0 |

## Scope and coverage

The author retained current loot tables and narrowed #384 to one-time delivery.
Only CaelumCombatActor behavior changes; two other runtime members synchronize
release labels. The package comparison permits exactly those three members and
no addition/removal. Actual table, generator, pickup, preview, ownership and quest
sources are unchanged against a3e25502; normalized hashes are in report.json.
No map regeneration, new pool, chance, quantity, refill or property rule is added.

The native DropItem reproducer uses an isolated carrier/token: the campaign has
no current DropItem metadata. Baseline final-baseline-probe reproduces reentrant
OwnerDied/WorldThingDied, repeated Die and repeated unblock (four failures).
The revised probe passes all seven checks. Its pending initialization completes
before killing the actor. The native latch commits before callbacks, survives
resurrection and blocks repeats without replacing native inventory authority.

Actual MAP02 checks reuse #220's accepted carrier cases: potion fallback with
one-unit debit, assigned ammunition at its dry anchor, quest key precedence,
empty/last potion stock, rat ration and repeated callbacks. Current and actual
5.5.8a saves reload correctly; original-pair rollback is separately tested.

The synthetic 5.5.8a save contains a finished nonblocking corpse, a living carrier,
a pending solid corpse and a pending archived corpse. Revision 1 preserves those
distinct entitlements idempotently. A real resurrection/second death does not
refill native loot. Revised claims survive reload and TMAINT -> THAZARD -> TMAINT.
Fixture references are recovered by stable map-local TIDs after travel; carried
inventory pointers to the departed map are not expected to survive.

The old ice save contains both native frozen phases and a previously raised body.
The old package duplicates the raised body's native token; the revised package
preserves remaining tics, migrates each phase without replaying effects and
delivers only the two first-life entitlements. A new-package ice save/reload also
passes. Native chunks remain present; a plain Actor proxy reuses the engine's
visual routine without inventory, conversation or drop metadata. No engine
implementation is copied into the project. No pixel-identical effect claim is made.

Existing chest preview/cancel/capacity/partial collection, recipient sizing,
same-source competing requests, native locks, old looted gaps and non-hub item
travel retain the unchanged paths and applicable #381 evidence in
../validation_562/RESULTS.md. #378 separately checked book storage. This patch
does not claim those old runs were rerun on 5.6.4. Historical 65-entry T1 coverage
is preserved as legacy provenance; #183's material quotas are the current MAP02
budget. Existing Bull/no-leather and quest claim rules are source-reviewed,
unchanged, and are not claimed as a full new campaign replay.

## Reproduction and retained evidence

GZDoom 4.14.2 / Windows 11, Vulkan, 1280x720, 60-FPS cap, sequential sessions,
unpaused background simulation and 5% master audio. Each run JSON records hardware,
driver, hashes, arguments and configuration. These are correctness tests, not
frame-time measurements or author acceptance. No retired stress case was run.
Engine, IWAD, fixture PK3s and saves remain local; report.json records save hashes.

Run python assets/validation_564/prepare.py, then run_native.ps1 with a fresh
-Label and a -Script from prepare.py. Use -Checks for current or -LegacyChecks
with -Runtime legacy (5.5.8a) / baseline (5.6.3b). LoadGame is a filename relative
to build/issue384. Use -ExpectRegression only for the two recorded old-code
failures. Frozen packages are retained beside their synthetic saves. Rollback
means restoring the untouched original save/package pair; backward loading new
frozen-state indices into old code is not promised.

Static validation is recorded in project-validation.json; normal packaging in
build.log. collect.py checks package/source agreement and the exact allowed
runtime diff. Independent read-only review found the native ice bypass and
confirmed the final fix/migration with no remaining P1/P2 findings.

## Exploratory failures and limits

Early fixture kills preceded deferred PostBeginPlay, reinitializing a synthetic
carrier after death. A five-tic setup interval corrected the harness. An initial
action used an ambiguous self type and failed compilation; the explicit actor
cast corrected it. A short MAP02 reload script ended before its queued event;
the final longer script passes and the runner rejects missing completion.
The first hub probe dereferenced a carried pointer cleared on map travel; the
corrected fixture finds the retained local bodies by TID and asserts their claims.
Failed and superseded logs remain under build/issue384 and are excluded from
the required set. No failed production test is counted as passing.

The author returned on 2026-10-20 and the temporary system-awake request
was released without changing the Windows power plan.
New lock/ownership and clothing proposals remain unapproved and separate.
