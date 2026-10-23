# #471 / 5.7.13 — Chemistry batches

Historical foundation checkpoint: the initial state model passes 53 assertions in
three isolated GZDoom 4.14.2 runs: capacity, one occupied lot, cancellation,
partial/final withdrawals, saved object identity and native map travel. An
absolute world-clock deadline completes the model after elapsed time without
updating an absent station. See [batch_report.json](batch_report.json) and
[raw evidence](native/).

The fixture uses synthetic data, not a production recipe. Inventory transactions,
learning, station interaction, commerce and multiplayer are not covered by this
checkpoint. There is no author-acceptance claim or pending author handoff yet.
No rendering-performance claim is made.

The first travel run did not reach CABAT2 and is retained but excluded. The
corrected run calls the native level transition and requires destination evidence;
passing the initial-map checks alone cannot validate travel.

The separate 5.7.8/#479 author acceptance remains fully recorded in its own patch.

## Final production integration

The final 5.7.13 package passes **267 assertions in 13 native GZDoom 4.14.2 runs**.
All 16,746 archive members match current src byte for byte. See
[integration_report.json](integration_report.json) and the final01 logs in native/.
Two deterministic generator runs preserve all 13 Chemistry data/art outputs;
[determinism.json](determinism.json) records hashes. The initial 53 assertions
above are separate historical evidence, not added to this final count.

Coverage: 22 recipes including all attended variants; atomic ingredient/water
reservations, cancellation and exact output; single shared barrel lot, capacity,
partial collection, disconnect, discarded contents, native return to a reconstructed
map; both barrel and active-water-task save/load; old foundation save loading;
recipe knowledge and additive merchant/catalogue migration; exact approved imports;
cheapest output price; full-chain calendar renewal without initial refill; and
native live-menu keyboard routing/held-discard protection. Water reservations
retain their exact native container after loading.

Five final captures were inspected: empty/active/ready barrel, Chemistry detail,
and all four new supply models. The missing M092 declaration is fixed in the
native sprite registry. New supplies retain at most 32 grouped OBJ material slots;
accepted 5.7.6 ingredient designs are unchanged. The preview01 failure was a
fixture null reference when requesting an already-owned canteen, corrected by
finding the existing object first; it is excluded from passing evidence.

The second-player check uses an in-process native bot; it validates shared
transactions, not two remote clients or a new multiplayer calendar. Clock gaps
retain the existing world-clock contract. No rendering-performance claim is made.
Regional mineral placements remain future authored content; MAP03 imports are
implemented. #472 is a separate patch.

Author check **CA471-BATCH-01** is pending in pending_test.txt. Launch
`assets/validation_5713/author_terminal.ps1` for reproducible manual checks;
this report does not imply author acceptance. The original cartridge migration
and ingredient artwork acceptances remain recorded in their own releases.

Author acceptance: CA471-BATCH-01 passed in full on 2026-10-23, without
qualifications, following the author's confirmation that every check in the latest
#471 terminal was correct. This supersedes the pending status above and does not
change runtime or version. #472 is not covered.
