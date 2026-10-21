# #385 — Calendar shop replenishment, 5.6.11

Static validation passes. Fourteen final GZDoom 4.14.2 runs pass **2,278
assertions, zero failures**. CA385-01 passed author review on 2026-10-21.
The frozen package has 16,433 source members and SHA-256
`b4d75590e5f16edaccfb3e05377d6c2e633b59a8e04f3553030e520e90a0fd69`.
The collector compares every packaged member to the final runtime source.

## Scope and evidence

The author approved manufacturing the entire product/component chain from raw
materials, with Technical attributes zero and fully mastered efficiency. The
native blueprint supplies quantities, batch rounding and time. Product schedules
are sequential per product and simultaneous across products; quantities and exact
instances remain in Actor.Inv. Serialized deadlines are civil game-calendar
timestamps. Old vendors initialize revision 1 without retroactive production.

| Final scenario | Assertions / result |
| --- | --- |
| All eight catalogues, 843 products; full-chain quotes; before/at/after deadlines; concurrent/serial production; fresh equipment and lock pairs; books, resales, exclusions | 1,701 PASS |
| Unmodified #377 merchant and #383 catalogue regressions | 62 + 463 PASS |
| Native WorldTick, open trade without input | 2 PASS |
| Native pause: wall time passes without civil production time | 1 PASS |
| Current save; reload; hub round trip; resumed partial production; completed reload | 1 + 5 + 10 + 6 + 5 PASS |
| Real 5.5.8a save with depleted stock, extracted fractional node, recovery agenda, finite salvage and used tutorial quota | 2 PASS |
| Revised load / repeated revised load | 9 + 7 PASS |
| Original package/original save rollback | 4 PASS |
| Worst authored library catalogue and render sampling | Completed, no assertions or VM errors |

Book production uses the whole represented batch, without a study multiplier.
Cartridge unit production is 16 clock tics; its ten-output recipe book is 160.
Garment quotes include component operations and are independent of player
Technical attributes or reading/practice progress. Only the eleven provision
variants and two prepared kits have no manufacturing recipe. Wallets do not
replenish. Returned worn items retain identity and wear; unsupported trade-ins
never acquire a production entry. Bought padlocks replenish as new matched pairs.

Current save/reload preserves the fractional next deadline, period, stock and
both wallets. Resuming after three elapsed deadlines adds exactly three units;
completed output is not applied twice. Hub return preserves the same vendor and
agenda. Old stock starts at first revised synchronization plus one full period.
Original saves/packages are retained privately for reversible rollback.
Natural capacity/fraction/calendar state, finite gold and tutorial issuance keep
their existing independent rules. No global actor traversal was introduced.

Read-only cross-review found no additional P1/P2 runtime issues after correcting
ammunition output normalization. Review is static evidence, not author acceptance.

## Performance

Windows 11 build 26200, Ryzen 9 5950X, RTX 3070 Ti, Vulkan, 1280x720, 60-FPS cap,
unpaused background execution, 5% master audio. Exact environment/configuration
and hashes are in report.json. For the 392-product library: initial creation and
registration 5.3387 ms; arming every depleted product's first full-chain quote
18.2631 ms; bounded 30-day catch-up 0.0146 ms; idle active-shop check mean
0.000086 ms over 1,000 calls. The artificial all-products-depleted arming case is
not a routine per-tic operation; ordinary transactions arm only new deficits.

Ten seconds of open-library RenderOverlay samples: 597 intervals, mean 60.019 FPS,
p50 16.660 ms, p95 16.792 ms, p99 17.069 ms, worst 29.173 ms. These are isolated
application callbacks, not OS presentation or large-city/mansion acceptance.
The existing large-map policy and >=500 living-combatant threshold are unchanged.

## Retained diagnostic failures

The initial smoke run rejected a ZScript boolean constant; it now uses integer
1. The first suite rejected the private fixture parameter `native`, reported by
the author; it was renamed `nativeClassName`. The next timing failures came from
reusing a merchant helper that marked shotgun initialization complete while
creating no shotgun stock: the second purchase selected the preceding carbine
row. A debugging print also dereferenced that missing fixture stock. Fresh385
now starts from revision zero; the complete catalogue coverage checks every
initial stock identity. These diagnostic runs do not count as passing.

The first migration attempt used a different private addon filename, which
GZDoom refused to load; the following run consequently lacked its save. The
revised fixture now retains the required `legacy-checks.pk3` filename under
build/issue385/upgrade. The runner and collector reject missing-save/package
messages and missing test summaries instead of interpreting exit zero as a pass.
Both corrected migration runs pass. All diagnostic logs remain in native/.

## Reproduce and author handoff

Run `python assets/validation_5611/prepare.py`, build the normal runtime with
`build_dev.ps1 -Destination build/issue385/current/caelum_argenteum_dev.pk3`, then
use run_native.ps1 with a fresh Label and the scripts generated by prepare.py.
Current runs use checks.pk3; baseline runs use legacy-checks.pk3; revised loads
of baseline saves use `-Addon upgrade/legacy-checks.pk3`. See each recorded command
and expected assertions in report.json. Native tests must run sequentially.
The exact historical baseline package and saves stay private in build/issue385;
no IWAD, engine, PK3 or save is distributed in this patch.

`python assets/validation_5611/collect.py` verifies logs, hashes, every packaged
source member, deterministic catalogue generation and project validation. The
supplied interactive room has coins, Box, ranged/library/clothing/tool vendors,
a reading shelf and **F6** to advance one civil day for this fixture only.
The author confirmed the supplied CA385-01 test passed on 2026-10-21; its
pending_test.txt entry was cleared, with the result recorded in HISTORY. Worn/preview/first-person
garment art remains the separate unfinished #387 scope.
