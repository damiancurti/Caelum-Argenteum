# Issue #451 - Persistent siege consequences

Author-approved rules are consolidated in SYSTEMS5.15.4. CA451-01 and the four
earlier V5.15 checks remain pending. Native evidence is not author acceptance,
Internet multiplayer evidence or permission to merge these PRs.

The native harness reuses validation_v5_15_0 and validation_v5_12_7's sync
observer. GZDoom4.14.2 runs unpaused in the background at5% audio, using isolated
configurations and saves. Private engine/IWAD, fixture maps, packages and saves
remain under build/v515 and are not distributed. Exact commands and hashes are
recorded per run in results.json; unsuccessful attempts remain distinguishable.

Functional checks with two native peers pass for occupation after the last real
defender dies, open-session merchant rejection, blocked departures, continued
native walking, no defeat penalty, finite reserves, real merchant-death identity,
and historical closure boundaries. Native save/reload retains those consequences.
Liberation requires the original twelve plus confirmed living Zupay retreat;
eleven do not suffice. Recovery uses the exact24-world-hour deadline, reopens the
same surviving merchant and transport, excludes closed hours from waiting-ticket
distance, records the date in the Journal and never pays another reward.

Normal victory keeps services open and pays+100 once to each eligible identity.
An unrelated new identity in the same player slot does not inherit eligibility;
an equivalent reimported identity cannot collect twice. Other faction reputation
is unchanged. An unloaded hub visit across recovery preserves the survivor's
TID/wallet, absent dead merchant, spent reserves and each participant's award.

Migration reads the untouched #450 delivery save and preserves preparation,
withheld/spent reserves, captured-machine ownership and its prior+50 reward.
The new revision initializes idempotently without invented outcomes. A separately
constructed legacy victory with unknown date preserves availability without
inventing participants or retrospective rewards. Original #450 saves/packages
remain untouched for rollback; #450's recorded original-package reload remains
the rollback evidence, not a claim that a new #451 save loads under old code.

Actual ES/EN transport and Journal views were visually inspected. The Journal
uses its existing second page for the longer occupation explanation; both
languages remain readable. Early captures obscured by the fixture's queued
introduction are retained as unsuccessful visual attempts. The fixture now marks
that diagnostic narration delivered instead of altering production dialogue.

Intermediate functional failures were in fixture preparation: initializing the
director before its deferred native registry entry, an undisposed introductory
conversation, accessing a merchant after native death had already destroyed it,
assuming a retired inter-map foot connection remained valid, and comparing a
map-local reference with a travelling merchant after hub restoration. The final
checks use actual native walking and the merchant's persistent TID/wallet. No new
walking inter-map connection is claimed or introduced.

The author terminal offers separate director, command, machine, report and
consequence laboratories, plus existing real city routes and the production city.
Its F5-F10 controls prepare explicitly labelled test conditions; they are not
gameplay controls or automatic author acceptance. Fresh isolated profiles include
the required test membership, recognition, recipes and materials. Full-city
scenes retain production population/performance; laboratories do not represent
the production army or replace its separate native evidence.

All seven menu choices pass their two-peer native startup checks. The five
laboratories additionally verify their prepared state. The final consequence
scene passes a real hub return and common-save reconnect under the delivery
package, preserving the prepared merchant casualty and once-only reward.
The final package is issue451-release.pk3; only diagnostic version print labels
changed after the presentation observations. The byte comparison in results.json
separates those labels and localized text/index changes from unchanged gameplay
and geometry. The original saves and packages were not overwritten.

Final native observations use the actual packaged city, one player, the approved
finite-wave population and the existing Vulkan presentation observer. The siege
records1.4065 presents/s, with interval p95/p99/max770.2164/805.2248/805.2248ms.
The ground-facing control records76.5401 presents/s with17.0894/18.9109/20.4302ms.
Simulation means are41.7135/28.5878ms respectively; their p95/p99/max values are
73.5215/80.2227/89.3031ms and38.8038/42.4747/44.9243ms. This agrees with the
previous severe siege limitation; it establishes neither a general speedup nor
60-FPS gameplay. Presentation requests are not a scanout measurement. No retired
6000-simultaneous-attacker case was run. The measurement's temporary wake request
was released, independently of the author's still-active timed keep-awake request.

Project validation passes with zero errors and2484 context words; generated
dialogue/localization/document indexes and git diff --check pass. An initial
static failure identified two diagnostic release labels still saying5.15.3;
both now say5.15.4. The final delivery package's equivalence record identifies
those two print-only changes separately from gameplay and geometry evidence.
