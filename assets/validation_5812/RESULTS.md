# Metabolic toilet sessions — #502 / 5.8.12

The accepted household fixture now runs a60-world-second session, with10L
and actual metabolic cleansing charged atomically at completion. Cancelling,
walking away, map departure or external damage before completion spends nothing.
Disease damage continues without interruption. Current access, capacity and
water are checked again at completion. Save/load preserves remaining work and
fixture identity. No new balance, map geometry or artwork was introduced.

Validation:55 executed native PASS across nine selected runs on Windows11 /
GZDoom4.14.2. Covers actual Use, world clock, cancellation, partial/no-capacity
cleansing, insufficient/late water, late cure, illness/external damage, repeat
completion, independent reserves, save/load, hub cancellation, pre-feature save
migration and original-package rollback. Waiting prediction includes same-tic
nutrition credit; the live and forecast results agree. Existing thermal-effect
forecast rejection remains intact; the focused prediction fixture neutralizes
its thermal exposure explicitly. Static validation passes.

final01 contains16,885 source-identical members; all169 maps match the accepted
bathroom baseline. SHA256:
`c959cddf819625bbd351db005d347bf460ee92a2fe6ee4f8fbd1b88b642c5a14`.
Native screenshots show the Spanish target hint, bound keys and remaining time.
CA502-TOILET-01 remains pending author acceptance. The inherited treatment test
is also pending; neither is inferred from agent checks.

Reproduction: build_dev.ps1 with Destination build/issue502-hygiene/final01/
caelum_argenteum_dev.pk3; prepare.py; run_native.ps1 using report.json labels and
native command records. Original saves/packages remain under ignored build/.
collect.py verifies package/source/maps and retains failed probes separately from
selected passing evidence. The test addon, engine and IWAD are not shipped.
No global actor scan was added; queries use the acting player's task and current
household state. These functional tests do not establish presentation FPS.

Soap baths, equipment cleaning, solid/combat contamination contacts, surface rain
washing and NPC domestic routines remain outside this delivered interaction.

Author confirmation, 2026-10-26: CA502-TOILET-01 and inherited
CA502-TREATMENT-01 both passed all supplied checks without qualifications.
Their originating releases/results are recorded in HISTORY. Runtime unchanged.
