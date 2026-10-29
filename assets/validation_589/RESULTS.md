# 5.8.9 / #502 - Severe contamination

The C90 boundary doubles existing disease damage and displays Sick. Toughness
100+ remains immune without healing; depuration below 90 removes the multiplier.
Native current-Life and forecast comparisons use the same production damage.
Wait cache revision 7 invalidates old forecasts, while original illness values
and fractional damage are preserved. No new map or body illness schema is needed.

92 native PASS in nine selected runs. Only individual PASS lines are counted, not persistent RESULT counters.

| Run | PASS |
| --- | ---: |
| rules-01 | 34 |
| runtime-01 | 23 |
| save-01 | 1 |
| load-01 | 2 |
| hub-01 | 6 |
| legacy-seed01 | 1 |
| legacy-bridge01 | 1 |
| legacy-rollback01 | 1 |
| final-runtime02 | 23 |

Windows 11, GZDoom 4.14.2, Ryzen 9 5950X, RTX 3070 Ti, Vulkan 1280x720;
unpaused in the background, audio 5%. Final-runtime02 recompiles and executes
the final package after incorporating the isolated #411 tent correction.
Earlier checks test the identical #502 source on the original camp base.
Original saves load forward and roll back with their original package/addon.
Private IWAD, addon PK3 and saves are not distributed.

All 16,859 final package members match src byte-for-byte. Hashes and commands are retained in report.json and native/.

The contact integral, environment index and water/soap quotes are pure rules
only. They do not yet expose actors/equipment or perform resource transactions.
No whole-map scan is introduced. No FPS claim is made by these functional tests.
CA502-SEVERE-01 is pending; use author_terminal.ps1 for the independent private
room. This evidence does not accept the unfinished hygiene/contact scope.

## Persistent actor/equipment state continuation

30 further native PASS in seven selected runs, recorded in storage/report.json:
storage-core04 (17), save01 (1), load01 (3), hub01 (6), legacy-seed01 (1),
legacy-load01 (1), legacy-rollback01 (1). The environment and engine settings
remain recorded per run; only new individual assertions count after loading.
Native pickup/deposit/withdrawal/toss preserve contamination; closed storage and
the Box shield contact. The original player resource receives mass-scaled doses.
Migration begins old equipment/actors at zero and preserves existing body values.
Current saves and hub return retain all three; original-package rollback passes.
All 16,860 storage-final package members match current src byte-for-byte.

Storage-core01/02 fail compilation: Protected is reserved, and a local variable
named state is parsed as a State statement at the start of an assignment. The
names are changed to IsShielded and entry. Storage-core03 correctly rejects
deposit of an automatically equipped weapon; the fixture now unequips it before
testing storage. The production restriction is preserved. All failed logs remain
under storage/native; core04 and the six subsequent persistence runs pass.

No automatic environmental or combat caller is connected yet. No periodic actor
scan is introduced. The author's severe-illness package remains unchanged.
These are functional engine checks, not manual acceptance or FPS measurements.

## Player and carried-equipment environmental exposure continuation

66 additional native PASS in nine selected runs, listed in exposure/report.json:
finalcore01 (20), wait01 (3), journey01 (3), worn01 (4), save02 (1), hub02 (8),
mansion02 (3), legacy01 (1), severe01 (23). Counts are new individual assertions,
not cumulative saved RESULT totals. The final exposure-final2 package has 16,862
members, each byte-equal to src; its hash and per-run hashes are retained.
Final UI changes affect only localization/layout; prior selected probe4/probe5
runs exercise the identical exposure gameplay. Finalcore/severe/legacy run after
that gameplay was fixed, mansion02 and the inspected capture03 use final2.

Checks cover approved garment areas, jointly integrated bare-body sources,
layered exposure, mass scaling, Box exclusion and the production thermal hook.
Actual waiting for 350 personal tics (200 world seconds) matches the independent
forecast exactly, including minute changes and worn clothing. The native travel
forecast leaves live state untouched and its confirmation applies the result.
Save/load and hub return preserve separate body/equipment forecast values linked
to the original owned item. Old equipment starts clean while old body values
survive; the unchanged original-save/package rollback evidence above still applies.

Private native microcosts on the recorded Ryzen 5950X environment: 1,000 player
updates averaged 0.0001502 ms bare / 0.0002355 ms with one garment, maxima 0.0009 /
0.0006 ms. On actual MAP01, 100 typed workshop-load callbacks averaged 0.004991 ms,
maximum 0.0291 ms, with eight industrial stations. This is a load-only typed census;
runtime sector lookup is O(1), equipment loops are limited to the player's cached
inventory. No routine global actor scan was added. No frame presentation or
frame-time tail measurement was made here; these numbers establish neither FPS
nor large-scene acceptance.

Retained failures: exposure-core01 used reserved identifier `until`; changing it
to `timeToBoundary` fixes native compilation. Exposure-hub01 kept a level-handler
pointer to a traveling inventory item; that fixture pointer becomes null on hub
return. The production projection retained the correct item. The fixture now
resolves its stable equipment ID (CA-KP-160); hub02 passes. Journal captures 01/02
exposed layout overlap and a non-ASCII PowerShell-to-Python encoding loss. UTF-8
patching and compact layout fix both; capture03/journal-es.png is the inspected
final Spanish journal image. Earlier images remain under descriptive names.
Capturefull01 was obscured by MAP01's native introduction; it is retained as
fixture interference, not journal evidence. Capturefull02 uses the private room
and verifies all eight visited-location rows plus the footer without overlap.

CA502-EXPOSURE-01 is queued while the author is away. The prepared terminal is
exposure/author_terminal.ps1; no manual test window was opened during the absence.
NPC/furniture exposure, surface/combat contacts, immersion and hygiene transactions
remain pending. This continuation does not accept or complete those features.
