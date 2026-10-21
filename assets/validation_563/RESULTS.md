# Issue #378 validation - release 5.6.3

The final recipe runtime passes **15 native runs, 170
assertions and zero failures**. CA378-01 passed author review on 2026-10-20; see HISTORY for the initial fixture-setup qualification.

| Run | Runtime | Passing assertions |
| --- | --- | ---: |
| legacy-save-05 | baseline | 1 |
| final-rollback | baseline | 1 |
| verified-time | current | 12 |
| verified-mansion-time | current | 12 |
| verified-suite | current | 48 |
| verified-craft | current | 16 |
| verified-save | current | 48 |
| verified-reload | current | 3 |
| verified-travel | current | 9 |
| verified-mansion | current | 4 |
| verified-upgrade | current | 4 |
| verified-upgraded-reload | current | 4 |
| verified-ui-02 | current | 0 |
| verified-smoke | current | 0 |
| verified-sources | current | 8 |

## Scope and evidence

GZDoom 4.14.2 / Windows 11, Vulkan, 1280x720, 60-FPS limit, unpaused background
simulation and 5% master audio. Runs are sequential. Each run JSON records the
hardware, driver, engine/IWAD/package/addon hashes, arguments and configuration.
No engine, IWAD, fixture PK3 or save is distributed. The comparison against 5.6.2
records every changed package member with no removal; changed bytes match source
after newline normalization. The bookshelf generator reproduces both outputs
byte for byte on two runs. Static validation is in project-validation.json.

The suite covers the exact time formula/caps, independent tiers, unknown previews,
fixed-batch and rounded proportional alloy normalization, deferred source delivery
and capacity retry, first-book/page mass, duplicate sources, Intelligence M3,
first learning/component closure, reread progress and faster rereads, retained
pages, chest deposit/withdrawal, native reusable Use, lost-book cleanup and
preservation of the crafting selection and frozen task duration. Personal time
steps advance reading once, pause closed reading and reject simultaneous work.

Actual native crafts cover equipment, ammunition batches and partial component
stock with recursively made bronze/points. Successful outputs alone grant practice;
cancel/repeated completion do not. Tests exercise existing x105 and date skip,
sleep pauses, thermal forecast rejection and a valid forecast's real execution.
Both TMAINT and MAP01 reach the rounded target date with CA_SKIP_COMPLETE after
reading finishes; the Limbo anchor is retained through the final partial minute.

A real 5.5.8a synthetic save preserves known/unknown recipes, gains sheets and
zero progress through revision 1, then reloads idempotently. A revised paused
reading retains book identity/pages/mass and frozen duration through reload and
TMAINT -> THAZARD -> TMAINT -> MAP02. Original-package/original-save rollback is
verified; backward loading a revised save into 5.5.8a is not claimed. Original
and revised pairs remain local, with save hashes in report.json.

Native checks establish one fitting bookshelf at the authored opposite-room
position and idempotent installation. English/Spanish menu and shelf captures
are retained for visual review. Manual mouse/keyboard feel and campaign NPC
interaction have separate author acceptance (CA378-01, 2026-10-20);
automated checks alone did not establish it.
Native source checks exercise Ronnie/Caella eligibility rejection, confirmed
sheet receipt, duplicate handling and no premature learning/quest progress.
These call existing helpers with a controlled speaker context; no broad tutorial replay or
multiplayer synchronization claim is made. Library commercial integration is #383.

## Review and exploratory failures

Independent review found and corrected processing-tier canonicalization, lost-book
task cleanup, duplicate-book pickup, chosen-node restoration, rounded alloy time,
reading/crafting arbitration and the Limbo post-completion skip anchor. The
final checks include those regressions. Early suite-02 failed to compile the
fixture's nested generic spelling; corrected spacing is used in all final runs.
Early time-advance assertions expected a forecast while the fixture still had
thermal exposure. The corrected fixture explicitly tests that rejection and
clears only its synthetic exposure before testing successful execution. Earlier
logs remain under build/issue378 and are excluded from passing totals. No failed
production test is silently counted as a pass.

The native checks establish behavior, not sustained performance or campaign
playability. No retired large-battle stress scenario was run. Temporary keep-awake
was released after each author return, most recently on 2026-10-20.
No power plan was modified.
