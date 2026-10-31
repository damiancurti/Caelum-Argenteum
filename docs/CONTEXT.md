# CONTEXT.md — Caelum Argenteum

Documentation version: **5.11.8** - 2026-10-30.

**V5.12 in progress:** #434-438 open. #435 baseline passes2/4/8 real loopback
peers; startup/ownership only. Evidence: validation_v5_12_1/baseline-results.json.
Decisions: GitHub issues. Profiles/transactions/consent/recovery/PvP remain;
no author test ready.
**V5.11 accepted/integrated:**5.11.8; HISTORY records all checks. Siege stalls
persist; distant-search candidate not adopted. Keep-awake released.
**V5.10 accepted:** #425-428/PR570-573, CA425-01..CA428-01; HISTORY.
Siege stalls persist. Keep-awake released.

**V5.9 accepted/merged:** #418-424 closed, PR561-569; CA418-01..CA424-01
confirmed 2026-10-30 in HISTORY. validation_590-597; pending_test.txt empty.

**V5.8 accepted/integrated:** #410-417/#496/#502, 5.8.56, 2026-10-29.
Acceptance IDs/dates: HISTORY. No outstanding author checks at that closure.
Final corrections/evidence: validation_5854-56. Multiplayer rest authority and
verification stay deferred to V5.12 (#435-437). Long-absence loading remains
expensive; render callbacks improved 1125.93 to28.34ms, not a60FPS claim.
No routine global scans; preserve local queries and shared typed registries.

**V5.7:**complete;HISTORY.

**5.7.0/#408:**water-quality;validation_570;CA408-01:accepted2026-10-21.

**5.6.11/#385:**restock;validation_5611;CA385-01 accepted2026-10-21.
**5.6.10/#383:**library/clothing/kits/locks;validation_5610;CA383-01accepted2026-10-21.
**5.6.9/#380:** accepted2026-10-21; validation_569:15runs/1259PASS.
**5.6.5/#382:** validation_565; CA382-01 accepted2026-10-21.
**5.6.7/#387:**25 object sprites; validation_567; CA387-01 accepted2026-10-21. Worn/preview/first-person deferred→3D.
**5.6.6/#386:** accepted/merged PR396; validation_566. Shops:#383.
**5.6.3/#378:** sheets/study/practice; validation_563; CA378-01 accepted2026-10-20. Library:#383.
**5.6.2/#381:** chest storage; validation_562; CA381-01 accepted2026-10-20.
**5.6.1/#377:** merchants; validation_561; CA377-01 accepted2026-10-20.
**5.6.0/#376:** crafting; validation_560; CA376-01 accepted2026-10-20.

**5.5.6/#314:** ice−40/lava1000 C, private room; validation_556. CA314-01 accepted.
**5.5.8/#369:** accepted; validation_558; CA369-01 passed.
**5.5.8a/#316:** closed/unimplemented; #315 conversion deferred; batch merged.

**5.5.4/#313:** cartridge40/45g approximations; validation_554:12runs/1323checks.
CA313-01 accepted Oct19; oldsave/rollback verified.
V5.6 uses sealed kits.
#309–312 accepted; validation_550–553; older evidence/acceptance: HISTORY.

**5.4.34/#324:** five active minutes; arrival saves retained.36runs/138checks.
CA324-01 accepted Oct18. validation_5434.

**5.4.33/#323:** revision-5 MAP02 isolates western crusher43921 after corridors.
Only sixteen cells change. Static/native/save checks pass; CA323-01 accepted 2026-10-17.
Revision-4 recovery: -LegacyMap02Revision4 retains old geometry/defect.

**5.4.32/#320:** #259 spread replaced by direct aim for Mandinga fire/Zupay stone.
Other attacks unchanged. validation_5432;
CA320-01 passed 2026-10-17. Shared #325 decision: 32m plus line of sight.

**#319/#321:** accepted Oct17.5.4.38 collapses the map
panel at the top; validation_5438:5runs/28checks, CA321-02 accepted Oct18.

**5.4.29/#327:** campaign MAP01 -> MAP02 -> MAP03; city has 184-MU district/
1024-MU exterior sky, original footprints and private CAH interiors. IDs remain. Normal siege:
100/group/350tics,1000-living admission cap,6600 cumulative+Zupay,600 defenders.
Resurrection may exceed cap; new groups wait; victory stops reserves. Evidence
validation_5429. Old catalogue recovery requires complete b9fd71ce runtime.
**5.4.45/#357:** excludes route markers from breath;41 checks;20/20 saved
artillery bodies resume. CA353-01 fully accepted Oct18, including group retest.
**5.4.43/#353:** caches/resources/target100 automatic >=500; validation_5443.
**5.4.44/#354:** retain structural guards; inconsistent extra FPS benefit.
validation_5444; thermal35 retained. **5.4.47/#361:** siege NPC/monster adrenaline;
player/seals unchanged. validation_5447; CA361-01 accepted Oct18.
CA318-01..05/CA327-01 accepted; FPS deferred; no6000tests.

**5.4.27/#307:** resolved prisoner Speed; retained recovery teleport. Native:
334 current/14 legacy checks;
validation/build pass. PR317, validation_5427; CA307-01 accepted 2026-10-16.

**5.4.26/#305:** active-seal registry preserves thermal rules; lifecycle/save/
performance and 16,193-member equivalence pass. PR308 (83f79cc1), validation_5426.
#304 archive delivered in PR306 (41b40476), validation_5425; CA304-01 accepted
2026-10-16. All #304/#305/#307 tests accepted; merge/closure authorized that day.
At that acceptance pending_test.txt was empty; 5.4.27's runtime was unchanged.
**5.4.0-24 accepted:** all 24 issues #237-254/#259-261/#282-284 merged/closed via
PR303 (351b949a); per-release evidence in HISTORY and validation_540 through
validation_5424. CA284-01 passed 2026-10-15. #283 is an accepted opt-in prototype;
modular migration remains V5.17. Earlier map/Journal
batch #231-236/#255-258 is accepted/merged/closed.

**5.2.8-27 accepted:** author confirmations, merged PRs, validation folders and
individual checks remain in HISTORY. Rules include automatic rest
provisions/x105, the1-g empty Box, modular appearance, comfort controls and
protected MAP01 life. SYSTEMS retains authoritative balance and behavior.

**5.2.7 / #189 and 5.2.6 / #184 accepted:** native menus/clicks preserve art;
live panels/NPCs, paused cards/settings, right-drag rest orbit. Evidence:
validation_527/526. CA184-01/CA189-01 passed 2026-10-11; PR190/191 merged.

**5.2.5 / #185:** per-NPC sources: src/dialogues/INDEX.md; text keys:
src/localization/INDEX.md. Regenerate with `python build_dialogue_index.py build`;
validation rejects stale output. Node/ID order preserved. Evidence: validation_525.
Accepted 2026-10-11; PR187 merge/closure authorized.

**5.2.4/#183 accepted:** creator/tutorial kits and finite MAP02 supplies; PR186
merged/closed, CA183-01 passed 2026-10-11. HISTORY/validation_524 retain details.

**Accepted on 2026-10-11:** CA147-01 (5.2.0/#147), CA177-01 (5.2.1/#177),
CA178-01 (5.2.2/#178) and CA180-01 (5.2.3/#180), without qualifications.
Identity/native controls, tutorial equipment/supplies/bag, faster time skip and
allied Mandinga retaliation are accepted; evidence: validation_520/521/522/523.
PR176/179/181 are merged; #147/#177/#178 closed. #180 delivery: PR182.
**#164/#172/#173 accepted/closed/merged:** PR171/174/175; baseline f7c4a0dd.

**#165/#158/#160 accepted/merged:** validation_5114/5112/5113; HISTORY records acceptance.
**#156/PR157 and #154/PR155 accepted, closed, merged** on 2026-10-10.
Time-skip and SI/growth contracts: SYSTEMS/HISTORY; validation_5111/5110.
**#152, #137, #136 accepted:** evidence validation_519/518/517; historical thermal
follow-up stays in SYSTEMS/TASKS. #135/PR144 merged; soldiers: validation_516.
#133 accepted; #140 merged. #132 closed/PR139 merged; CA132-01 accepted.
#132 opt-in MAP06 reinforcement groups are 100/350 tics, 2,000 alive, 6,000 total;
old/full armies remain. Evidence: validation_512; geometry and 10 km route: SYSTEMS.
**#131/#130/#128 accepted.** Fluency/multiplayer remain pending.


**Accepted #79/#78 (2026-10-04):** guards recognize the amnesiac captain; one
Journal clue. Paid prisoners share siege/calendar guidance; future timing pending.
Selene service/implanted souls stay concealed. Zupay retreats in Chapter I,
dies in II. Evidence: assets/validation_43711 and validation_43710.

**#77 accepted historically:** original city/army design, now superseded by
5.4.29; provenance and performance evidence remain in HISTORY/SYSTEMS.

**Accepted #73/#74/#75:** maze, supplies and returns; HISTORY retains acceptance
and the specific old-save waiver.

**Accepted base:** #64/#65 (time/tables), #63 (loadout), #68 (magic), #62 (dummy),
#61 (landscape), #17 (export). #61 geometry needs fresh MAP01. Rights: LICENSE.md.

## Premise

Caelum Argenteum: independent Argentine dark-fantasy FPS-RPG, nineteenth century,
GZDoom 4.14.2/ZScript.

The first invasion is external: the Caelith, original inhabitants of the Moon,
descend upon the Earth under the command of Queen Selene. The second is
internal: the Tarot, a power from Hell, infiltrates people, creatures, objects,
places, and conflicts; the Cult of the Tarot uses that influence to sharpen
the existing divisions and weaken the resistance. Both threats come from the
plan of an infernal prince who, after repeatedly failing to conquer the Earth
by force, decided to corrupt the Moon and break the Earth from within.

Barracas al Sud's guard captain awakens unknowingly in Limbo's mansion.
Returning guards recognize him despite his amnesia.
Captaincy leaves customization, class and faction unchanged.
The main species are allegorical of nineteenth-century Argentina: the Beast Men
represent the native peoples, the Caelith European colonialism, the duendes
the gauchos and rural culture, and the humans the urban porteño society.

## Implemented systems

- **Combat:** physical melee weapons, ranged weapons, and magical implements in
  three tiers; blocking, aim/ADS, charged attacks, sweeping heavy weapons, and
  the equipped-Seal Channel.
- **Survival:** Hunger, Thirst, Sleep, Air, and health; regeneration, needs by
  body mass, digestion, rest, and wait.
- **Attributes and abilities:** twelve attributes, agreed racial and class
  abilities (only the Arcanist Sleep is implemented), runes, and seals.
- **Crafting and equipment:** recipes, repair, disassembly, stations, armor,
  ammunition (arrows and bolts), and material allowances.
- **Economy and Magic Box:** physical currency, transactions, and a persistent
  Box with weight reduction and restricted contents.
- **Quests, reputation, and factions:** optional quest base, states, reusable
  dialogue/access/trade conditions, and faction conditions.
- **Tarot:** collection/capture of Fool, Ace of Cups and Knight of Wands;
  56 Minor passives, physical deck and three-card powers described above.
- **World and travel:** world Journal, visited locations, connections, grouped
  doors, caravans, coastal vehicles (carriage and merchant ship), and measured
  routes with provisions.
- **Time, calendar, and climate:** persistent global clock, civil and campaign
  calendar (epoch 1889-11-03 09:00), monthly event agenda, SMN regional
  climate, and position-dependent shelter.
- **Physics and hazards:** Impact Physics core, trapdoor, pit, rocks, explosive
  mines, teleport, ceiling crusher, resting weight, and levers.
- **MAP01 (mansion/tutorial):** prologue, Unknown Voice, Palomo, Argento,
  Caella, Ronnie, and Rulo; first weapon, Box, and exit to MAP02.
- **MAP02 (maze):** four sections, 100 junction rooms, 96 Mandingas, 45 traps,
  four progression/arena and four cell keys, 39 chests, 65 unique T1 pieces,
  four cell beds/refuges, final Zupay retreat, Ace of Cups and the workshop exit.
- **Presentation:** modular first-person view, event audio, Spanish/English
  localization, project typography, and hub transitions.


**4.36.26 / #37:** common 14-tic attack duration scales with effective
Dexterity/Eloquence and weapon-plus-glove mass over maximum capacity; 100%
blocks attacks. Full-cycle animations include the author's five grip-centered
thrusts (30 down, 60 advance, 16/16/48/20% phases). Weapon durability ×10 migrates
proportional wear once; projectile wear follows the exact item. Authored enemies
spend shared resources, idle/recover when exhausted, and retain the 80-tic Zupay
slam exception. Native rules/cycles, persistence and visual evidence:
assets/validation_43626. Author checks passed 2026-09-30; merge authorized.

## Current status

**4.36.25 / #36:** mansion enclosure, guards, shutters, finishes and hinged
doors passed native traversal/access checks and author acceptance
CA-43625-MANSION-01 on 2026-09-29. Start fresh. Architecture: ASSETS/MAP01;
evidence: assets/validation_43625/caella. Startup model-surface failure is fixed.

**4.36.24 / #35:** Journal filters retain main/side and active/completed records,
including separate rescue/extraction and payment status. Native legacy/reload/hub
and UI checks pass (assets/validation_43624). CA-43624-JOURNAL-01 passed author
acceptance on 2026-09-28; merge/closure authorized. Controls/classification and
legacy limits: SYSTEMS. Port and #17 export are author-accepted.

**4.36.23 / #52 accepted:** former Toughness rules and native evidence are
preserved in HISTORY/SYSTEMS and validation_43623; #188 supersedes that balance.

**4.36.22 / #34:** revised Palomo/Voice/companion narrative, secondary-wind
sprite freeze fix and legacy dialogue migration passed author acceptance
CA-43622-NARRATIVE-01 on 2026-09-27. Evidence: assets/validation_43622;
details retained in SYSTEMS/HISTORY. Siege deployment is now implemented in #16.

**4.36.21 / #49:** environmental contacts retain accepted absorption and no
longer grant combat adrenaline. SYSTEMS/HISTORY retain the complete rules.
Evidence: assets/validation_43621. The author confirmed CA-43621-IMPACT-01
passed on 2026-09-27. PR #50 targets main.

4.36.20 (#33) unifies Arcana capture and routes MAP02 through MAP03 to MAP06.
The Zupay flees at 50% health at triple speed; escape confirms defeat and unlocks
the Ace. The former rescue-payment Knight condition is superseded by #16
for current MAP06 and preserved only for legacy geometry. The Ace rendering freeze was corrected.
The author confirmed CA-43620-ARCANA-01 and CA-43620-ROUTE-01 passed 2026-09-27.

The preceding **4.36.19** applies the author-approved final #21 balance:
new cannon shots 500 m/s; gate Toughness/Constitution 50/100/200; Type 4 division
for player/NPC/gate collisions. SYSTEMS holds the damage matrix. Versioned
gate migration preserves remaining-health ratio and passage state with explicit
rollback; saved projectiles retain velocity. Evidence: assets/validation_43619.
Merged; #21 closed. Author confirmed CA-43619-BALANCE-01 passed 2026-09-27.

4.36.18 (#43, closed) adds walking-only wall absorption;
author confirmed CA-43618-WALK-01 passed 2026-09-27. No manual checks remain pending.
Native traversal and loaded self-jump pass. 4.36.17 implemented #21 controlled
cannons, approximate 4.3 kg ammunition, 30/60-second crews and bounded saved
projectiles; its original CA-43613-CATAPULT-01 passed 2026-09-27. Those native
mechanics and sources remain in assets/validation_43617; final balance supersedes
the original 400 m/s /zero-gate-damage result. Port and export are now author-accepted.

**4.36.16 / #20:** operational rams passed CA-43612-RAM-01 on 2026-09-26;
merge/closure authorized. Mechanics, debug commands and evidence remain in
SYSTEMS/HISTORY and assets/validation_43616. Port and export are now author-accepted.

**4.36.15 / #19:** breakable gates and persistence accepted CA-43611-GATES-01
on 2026-09-26. Subsequent #21/#188/#194 balance supersedes the original defense
formulas; SYSTEMS owns current rules and HISTORY preserves the original evidence.

**4.36.14a / #18:** author accepted the corrected gate/cannon/ram forms and
independent MODELDEF states on 2026-09-26 (CA-43614A-SIEGE-ART-01). MAP03
furniture/stations and saved instances were retired, retaining table contents
as pickups. Other maps/save schemas were unchanged. Details: ASSETS/HISTORY;
historical cannon scale remains unverified.

**4.36.14 / #31:** author-selected combat pain, dialogue-opening cue and
sewer/port/coast music are integrated. Sources, unused backups and the former
mansion track remain preserved; ASSETS retains exact bindings and HISTORY
records CA-43614-AUDIO-01, passed 2026-09-25.

Issue **#18** supplies the accepted deterministic siege art and cleared MAP03
gallery. ASSETS retains its models, sprite/state bindings and generator details;
#19-#21 own the subsequent mechanics and balance.

**4.36.9 / #15:** all 78 approved Tarot fronts use persistent card IDs and
the shared back. Journal selection shows owned fronts; the separate development
preview grants no progress. Ace remains ID 36; no powers/rewards added.
CA-4369-TAROT-ART-01 passed 2026-09-25; ASSETS/HISTORY retain full evidence.

The preceding **4.36.8** implements #14: the four MAP02 prisoners can be
released, then follow and fight alongside the player with their source combat
profiles while staying back from the northern Zupay. Each prisoner is extracted
only by reaching the pre-boss reservation alive before that fight (killing the
boss is not required); a follower that dies earlier is not rescued. At the
MAP06 port, each extracted prisoner grants +10 reputation with its own faction
and 25 gold coins (1,000,000 copper) once, independent of character size, with
no duplicate payout across retry, save/load or travel. The provisional social
domains are replaced by six canonical factions: Unitarians, Federals, Free
Peoples, Caelith, Cult of the Tarot and Sun Warriors. GZDoom 4.14.2 compiles the
complete package and loads MAP01/MAP02/MAP06 without script errors; author
confirmed CA-4368-RESCUE-01 passed on 2026-09-25.

**4.36.7 / #13 and 4.36.6 / #12:** reused prisoner appearances and 192 sewer
rats are author-accepted; provenance and results remain in ASSETS/HISTORY.

The preceding **4.36.5** implements #11: wider four-section sewers, keyed
barred gates/cells, beds, repair refuges, pre-boss extraction reservation and
240 arrows/120 bolts/120 bullets. Only known weapon recipes permit repair;
no materials or recipes are added. The author confirmed CA-4365-MAZE-01 passed
on 2026-09-24.

The merged **4.36.5a** documentation patch records the selective file-reading
workflow for agents (#29) without changing gameplay, balance, maps, saves or
assets.
Saved campaigns that visited old MAP02 use `run_dev.bat --legacy-map02` to
continue byte-identical legacy geometry; normal builds use the new layout.
The accepted **4.36.4** implements #10: the complete T1 maze catalogue,
recipient-sized natural equipment/rewards, explicit chest previews/collection
and a bounded recent-message feed. The author confirmed CA-4364-T1-LOOT-01 passed
on 2026-09-23; its acceptance remains recorded separately in HISTORY.
The retained 4.36.3 issue #9 flail-handle rotation adds 10 degrees
further counterclockwise across T1–T3. Native before/after, full spin, return
and re-equip checks passed; the author confirmed CA-4360I-VISUAL-01 passed
on 2026-09-23. The
4.36.2 bow crop cache and author-approved environmental scope are retained. Native Windows evidence is
recorded in HISTORY; the author confirmed CA-4362-BOW-EMPTY-01 passed on
2026-09-23. Gameplay
rules, accepted bow art and saves are unchanged. The engineering guides/index
from #22 and English documentation/acceptance workflow from #6 remain in force.

The **4.36.0i gameplay baseline** was compiled and tested on GZDoom g4.14.2
on Linux with development Freedoom. Working: the 4.36 base (trapdoor, rocks,
approved traps, ceiling), the MAP02 maze, the approved resting-weight formula,
rations, and MAP01 tables at full capacity.

Pending:

- #8–#16, #18–#21, #33–#37, #43 and #49 are author-accepted within their recorded
  scope. #17 exported-package acceptance passed on 2026-10-01.
- Extract Impact Physics only after its separate integration/save/reset closure. Per the author's 2026-09-23 #8 decision,
  existing ceiling/elevator cover moving sectors; avalanches await additional
  campaign surfaces await placement; #314 permits private ice/lava tests.
  Those three items do not block closed 4.36; remaining expansion stays in V5.

On 2026-09-23 the author accepted the 4.36.0i maze, save/load and table checks
and bow appearance. The author also confirmed the complete 4.36.1 Windows
validator/launcher/header check. The bow stall and final flail pose are now accepted;
detailed results are in HISTORY. PR #7 and the #22 integration PR #23 are merged.

Historical exports remain archived; remaining powers/missions, teams/network play
and campaign expansion stay in V5, starting with V5.0 architecture. Current route: mansion MAP01 -> maze MAP02 -> port MAP06. The accepted
port siege replaces the Knight of Wands' provisional #33 appearance condition.
Prisoners match their source character's combat stats, follow/fight alongside
the player and extract alive through an exit before the MAP02 boss; they do
not fight that boss. At the port, each grants +10 reputation with its own
faction and a fixed 25 gold coins once, independent of character size.
The latest #10/#14 author decision supersedes the former weapon-price formula.
The #15 fronts and #80 powers are integrated; Tarot author checks passed 2026-10-04.
Siege rules retain their separate acceptance.
Prisoner source/faction mapping: Caella/Unitarians, Ronnie/Federals,
Rulo/Free Peoples, Argento/Cult of the Tarot; do not reassign mansion NPCs.
PROJECT owns scope/dependencies; HISTORY preserves earlier evidence.

Layout/reading: AGENTS.md.

## Critical premises

Checks:
[pending_test.txt](../pending_test.txt); remove only after explicit acceptance, recording ID/origin/date/qualifications in [HISTORY.md](HISTORY.md).
Unconfirmed/failed checks remain.
