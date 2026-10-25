# Equipment cleaning - #502 / 5.8.12

The inventory's Clean/J action washes weapons, shields, armor and garments with
real carried potable water, soap and a reusable cloth. Approved item surfaces set
the full-piece budget: 1 L/m2, 5 g/L and 60 world seconds/m2. The active target is
locked against transfer. Progressive spending and cleansing survive cancellation;
late shortages keep only affordable progress. Clean items spend nothing, the cloth
is retained, and the shared opened-soap remainder keeps its weight/save identity.

Successful repair starts cleaning its own repaired item. Voluntary sleep queues
the selected weapon followed by equipped armor/clothing in slot order. Missing
supplies skip a piece without blocking repair/sleep; explicit cancellation discards
pending sleep. Sleeping-bag support remains until the queue finishes, then the same
bag is used. No station, new balance, artwork or geometry is introduced.

134 executed native assertions pass across 13 selected runs. Coverage includes
native inventory selection, exact progressive budgets, cancellations, shortages,
opened-credit-only soap, missing cloth, disease/external damage, Box identity,
world-clock completion, single-piece forecast/native parity, repaired-item hook,
sleep order and clothing, missing/late supplies, bag identity, save/load, hub
departure and an accepted pre-cleaning bath save. Bath/toilet regressions pass. Native inventory H retains boiling for selected
water and bathing otherwise; J opens cleaning. This fixes the preceding bath
shortcut intercepting the existing boiling action.
The repair fixture seeds the native repair-completion state, so it validates the
new hook rather than claiming a new end-to-end test of the existing recipe UI.

The final clean-final06 package contains 16,892 source-identical members; 169 maps
and 13,826 art members match bath-final05 byte for byte. SHA256:
`3d6c680f2efdff12b384c0922b04f695b8ea659a07b32560cf7861c59426780f`.
The report records every tested package hash. Reused runs differ only by the final
missing-cloth forecast guard and the independently tested H shortcut routing.
The collector verifies the exact guard and the pre-shortcut UI source bytes. Earlier failed fixture
probes remain in ignored build/ and their corrections are recorded in report.json.
Native Spanish UI captures were inspected. Static project/localization/document
validation passes. CA502-CLEAN-01 remains pending author review.

Reproduce with prepare_clean.py and run_native.ps1 using report.json's run metadata;
collect_clean.py retains selected raw evidence. author_clean_terminal.ps1 offers
manual checks and serial automatic checks. Its manual XL shield takes long enough
to try cancellation at the ordinary world-clock rate without changing balance.

Limits: this stage covers voluntary pre-sleep cleaning. Calendar-triggered and
exhaustion sleep scheduling remain follow-up work. Exact-date projection supports
a single piece; the multi-piece sleep queue keeps the explicit unsupported-effect
guard, with ordinary/accelerated live time still available. Persistent dirty map
surfaces, combat contact, rain washing and NPC housekeeping remain unfinished.
No global actor scan was added: queries use the owner's inventory and existing
support references. These functional checks do not establish multiplayer behavior
or campaign-wide frame-presentation performance. No issue/release closure is implied.
