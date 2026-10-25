# Exhaustion-wake equipment cleaning - #502 / 5.8.12

The author approved cleaning after waking from involuntary exhaustion sleep on
2026-10-25. Collapse remains immediate and the existing recovery lock remains in
force. Safe awakening starts the accepted ordered queue: selected weapon, then
worn armor/clothing. Completion leaves the character awake. Missing supplies do
not prevent awakening; external damage/combat awakening does not start cleaning.
Progressive costs, cancellation, late shortages and map departure reuse the
accepted equipment-cleaning implementation without new balance.

97 executed native assertions pass across 15 serial GZDoom 4.14.2 runs: 94 on the
final production package and three on the accepted previous runtime for genuine
save creation/rollback. Count executed PASS lines, not cumulative saved counters.
Core checks cover the wake lock, no immediate charge, exact water/soap spending,
queue order, repeated completion, missing/late supplies, combat/damage, cancellation
and idempotent cleaning-task revision1-to2 migration. Current partial saves,
genuine old exhausted/cleaning saves, hub departure and ordinary unpaused world
clock progression pass. Voluntary sleep, repair, sleeping bags and single-piece
cleaning regressions pass. No unresolved native failure remains in this scope.

The first load assertion incorrectly treated a multi-piece queue as one piece;
real ambient exposure had dirtied the clothing before load. Corrected checks
finish each remaining piece and independently sum its exact remaining budget.
Other fixture corrections and retained failed probes are listed in report.json;
none required a production change. Old logs remain in ignored build/. Native
Spanish console captures were inspected. Automatic drinking while asleep can
spend water independently of cleaning; exposure can contaminate cleaned gear
again. The author terminal explains both ongoing mechanics.

Final package wake-final01 SHA256:
`5805e49874ba5f1af82de9d674963f4c867dee59ccfabc2af4b9746479b1dbb5`.
All 16,893 members match src byte for byte. Exactly three production source files
differ from accepted surface-final05; all 169 maps and 13,826 art members match.
The diagnostic generator is deterministic. Static project, localization and
fresh document-index validation pass; see static.json. No artwork was edited.

Reproduce with prepare_wake.py, then run_native.ps1 using report.json's labels,
scripts and save names. collect_wake.py retains raw logs, environment/configuration,
package hashes and captures. The old seed/rollback uses surface-final05 and the
legacy addon; the revision1 task save was retained from the accepted cleaning
suite. No engine, IWAD, save or generated fixture package is distributed here.

CA502-WAKE-01 is pending author review through author_wake_terminal.ps1.
CA502-SURFACE-01 is accepted separately. Calendar-triggered sleep cleaning,
other-actor/combat transfer and NPC housekeeping remain unfinished #502 work.
Forecast revision17 retains the explicit unsupported exact-date guard for
multi-piece queues; ordinary world-clock/accelerated work remains available.
This patch adds no global actor scan: the wake hook visits only the owner's
existing equipment references and at most nine queued pieces. Functional tests
do not establish multiplayer behavior or campaign-wide presentation/FPS acceptance.

Manual-laboratory correction (2026-10-25): the author's session later exhausted its
water through automatic drinking before F2. The corrected manual scenario pauses
the existing rest top-up to100, retaining the ordinary50 threshold. Seven focused
native assertions pass after30 real seconds of waiting; the bottle still contains
5L and post-wake cleanup completes. Baseline observation, author log and inspected
capture are retained in water/. This replaces the earlier manual instruction that
only warned about automatic drinking. Production package/hash and the97 gameplay
checks remain unchanged. CA502-WAKE-01 is still pending corrected author review.
