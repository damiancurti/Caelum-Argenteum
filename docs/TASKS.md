# TASKS.md — Active tasks

Documentation version: **4.37.16** — 2026-10-04.

## Issue #87 - Compass and project menu pointers (4.37.16)

- Implemented view-driven compass, north +Y, eight bilingual directions,
  bounded native HUD scaling and reserved message space.
- Author refinement: corrected visible letter alignment; added silver laurels
  and a subdued Sun of May behind the needle. Native evidence under
  assets/validation_43716/compass_refinement; visual acceptance pending.
- Sun of May replaces both skull frames; C moon supplies the native cursor.
  Immutable generated art inputs and deterministic vector integration retained.
- Evidence: assets/validation_43716. Next: CA-43716-UI-01/02/03, including
  physical mouse click/drag after the user stopped Computer Use with Escape.

## Issue #101 - Traditional ranked Truco (4.37.15)

- Separate Argentine Truco against Argento: 30 points, optional Flor, no
  RPG damage or future rating service. Author's confirmed variants: SYSTEMS.
- Preserve accepted practice, deck/quest rules and saved matches. Additive
  revision-1 inventory, existing card art and native pause/save/load.
- Evidence: assets/validation_43715. Author checks passed 2026-10-04; closure/merge authorized.

## Issue #99 - Argento practice choice order (4.37.14a)

- Practice is the final ordinary reply before goodbye in all existing pages.
- Preserve page identity and every other reply/action/condition; native verify
  the displayed order and entry into the already accepted match.
- Evidence: assets/validation_43714a. Author checks passed 2026-10-04; closure/merge authorized.

## Issue #97 - Palomo's first upstairs deck handoff (4.37.14)

- Grant the physical deck upon successful conversation opening after following
  Palomo upstairs, before choosing equipment or receiving the later Box.
- Reuse the existing grant record/capacity guards; preserve repeated dialogue,
  saves, essences, route and USDF page indexes. Explain the new timing in EN/ES.
- Evidence: assets/validation_43714. Author checks passed 2026-10-04; closure/merge authorized.
- Focused PR follows #95; #81 is accepted/merged, #93 is author-accepted.

## Issue #93 - Crafting time help (4.37.13a)

- Show keyboard Y time skip next to T acceleration in the lower EN/ES help and
  active-task status; preserve existing controls, mechanics and saves.
- Agent evidence: assets/validation_43713a. Author checks passed 2026-10-04; closure/merge authorized.
- Based on accepted #81, merged via PR #94. Author acceptance passed 2026-10-04.

## Issue #81 — Trucazo against Argento (4.37.13)

- Requested 2026-10-04: one complete single-player match against Argento in
  MAP01, with native validation, commit and push.
- Isolated branch `issue-81-trucazo-argento` starts from #80 commit c7fe3fe9;
  #80 is now author-accepted and merged via PR #92. Its original build stays
  available while the author tests it.
- The contract in SYSTEMS incorporates the author's original Trucazo
  v2.0 document and 2026-10-04 decisions: traditional Truco base, ties to mano,
  no Majors or Magic Senses in this practice, no wagers, abandonment is defeat.
  Patience-squared health and row-based damage come from the source. The author
  resolved both source contradictions: one shared 56-Minor deck, first-row
  nonplayables from the initial five, second-row nonplayables from replacements
  up to three playable cards; Intelligence uses Type 1. The exact deal was
  confirmed separately. Native menu/network probing verifies actions can run
  while the world remains paused.
- Implemented: ordinary Argento challenge, bilingual card/menu presentation,
  complete hands/calls/damage/result loop, legal NPC policy with no hidden-hand
  inputs, abandonment confirmation and native save/load. Additive revision-1
  Inventory and static UI restoration preserve old saves and current matches.
- Evidence: assets/validation_43713; native rules, 100 automatic matches,
  ordinary dialogue entry, screenshots and save/restore/rollback checks.
- Accepted 2026-10-04: CA-43713-TRUCAZO-01/02 passed; closure/merge authorized.
  Next: #99 reorders the practice choice. Multiplayer, teams and broader
  services/full Major expansion stay deferred.

## Issue #80 — Campaign Tarot activation (4.37.12)

- Implemented: up to three selected captured essences; shared User3 activation,
  1000 Anima once, 60-second effects and 600-second cooldown from activation.
- Powers: Fool flight; fixed Minor bonuses double. Permanent collection,
  acquisition rewards and the authored mansion transition are preserved.
- Deck: Palomo's once-only 78 cards, 780 grams and one slot; protected against
  sale/drop/breakage. Capture requires it inside the player's own Box. Captured
  essences and powers remain personal.
- Compatibility: additive revisions, idempotent legacy recovery, saved selection,
  active set and timers. Changing selection never changes a running effect.
- Evidence: assets/validation_43712. The author confirmed CA-43712-TAROT-01/02
  passed on 2026-10-04 and authorized #80 closure and PR #92 merge.
  Normal validator/build, nine static and 171 native assertions pass, plus two
  baseline/rollback checks.
- Follow-up implemented: HUD duration/cooldown above the side Seal indicator;
  rest and committed journeys advance the shared timers.
- #81 supplies the first Trucazo practice; remaining Major powers/acquisition/
  awakening belong to V5. #80 author checks passed on 2026-10-04.
  No design values remain pending for this implementation.


## Issue #79 — The amnesiac guard captain (4.37.11)

- Implemented: captain canon, first/repeat local guard recognition, amnesiac
  responses and one persistent main Journal clue, independent of prisoner rescues.
- Reconciled: active wanderer/intact-memory biography and prologue Journal;
  original wording retained in HISTORY. Limbo/Unknown Voice mystery remains.
- Preserved: player customization, factions, class, stats, rewards, army control,
  prisoner briefing, siege objectives and narrator queue.
- Compatibility: quest revision 3 initializes reserved slot 9 once; existing
  USDF page indexes and 32-slot persistent quest arrays remain unchanged.
- Evidence: `assets/validation_43711`; nine static and 149 current-version native
  assertions pass, plus fourteen baseline/rollback checks. Controlled native
  victory is not a full normal battle.
- Accepted 2026-10-04: the author confirmed CA-43711-CAPTAIN-01 and
  CA-43711-CAPTAIN-02 passed without reported exceptions and authorized PR #90
  merge / #79 closure. HISTORY records both results; `pending_test.txt` has no remaining #79 checks.
  Acceptance retains version 4.37.11.
- Pending design: unspecified prior biography and future siege scheduling;
  performance remains #86. No additional story facts or mechanics are inferred.

## Issue #78 — Prisoner siege intelligence (4.37.10)

- Implemented: successful payment gates every prisoner briefing; repeat access,
  paid-rescue Journal details and the port quest use common bilingual information.
- Preserved: 25 gold/+10 own-faction rewards, Selene's event queue, page indexes,
  existing save schemas, current siege trigger and both victory requirements.
- Canon: concealed Selene service and anti-demon motive; implanted souls and
  bodily identity; amnesia and Limbo denial; Zupay retreats now, death in Chapter II.
- Evidence: `assets/validation_43710/RESULTS.json`; the author confirmed
  CA-43710-BRIEFING-01 and CA-43710-BRIEFING-02 passed on 2026-10-04 without
  reported exceptions and authorized PR #88 merge / #78 closure. HISTORY records
  both results; no #78 author checks remain. Acceptance retained version 4.37.10.
- PENDING author design: a future siege date/hour or scheduling change. Current
  data only records actual entry/deployment and victory; no deadline was invented.
- Captain recognition is implemented separately in #79 / 4.37.11 above;
  #86 still owns full-city performance. Neither belongs to the #78 patch.

## Issue #77 — Expanded southern Barracas al Sud (4.37.9)

- Author approved PR #85 merge and #77 closure on 2026-10-03, explicitly
  deferring performance work to issue #86, then explicitly confirmed all manual
  tests passed. HISTORY records the three accepted IDs; pending_test.txt is empty.
- Final author-approved scope: 960 × 960 m; 160 houses, 64 shops, 24 factories,
  40 construction sites; four accessible cannon towers and a connected wall walk.
- South assault integrated into six city gates; north/west fortified exits,
  eastern docks. All four directions remain inside MAP06.
- Forces: 6,000 Mandingas plus one commander, 600 defenders, six hostile guns
  and six rams. Thirty-six defensive guns are installed; eight southern wall
  guns plus four tower guns are active, with 24 staffed reserve emplacements.
- Physical stairs and saved crew routes retain existing actors and resources.
  Twelve hostile objectives plus commander defeat still gate victory/rewards.
- Author follow-up: at most 100 enemies per attacking command group, including
  its leader. Preserve Zupay priority, stable ties, sight links and the full army.
- Direct MAP02 → MAP06 uses the accepted Ace/Zupay and 10 km journey contract;
  the legacy MAP03 onward route remains for existing workshop saves.
- Exact prior layouts are selectable with --legacy-map06-north-city,
  --legacy-map06-siege or --legacy-map06. Current code preserves their state;
  the saved geometry/population is not converted into the expanded city.
- Evidence: assets/validation_4379/south. Original validation_4379 results
  describe the superseded 96 m northern iteration, not the final battle scale.
- Combat follow-up implemented: nearest visible player/guard, shared attack
  ranges/costs, retreat then idle until both resources fill, Pain interruption,
  double idle/chair Anima and player projectile limits. Ninety native checks pass;
  save/reload retains recovery, projectile budget and old crew identities.
- Deferred performance (#86): the final 300.5-second run reaches about 13.5 tics/s
  instead of 35. Windows responds in all 248 observations. The comparison gives
  3.9 before targeting and 14.3 with targeting alone; RNG differs between runs.
  COMBAT_RECOVERY.json records current evidence; GROUP100.json/LIVE_FREEZE.json
  retain the prior failures. No permanent deadlock or performance fix is claimed.
- Accepted on 2026-10-03: CA-4379-CITY-01 / CA-4379-ROUTE-01 /
  CA-4379-COMBAT-01 (all originating in 4.37.9 / #77).
- Next: reproduce/profile the measured live-performance failure in #86.
  Captain identity/intelligence and later V4.37 work remain separate.

## Issue #75 — Material supplies and corrected audit (4.37.8)

- Gameplay delivered and accepted with #73, retained by #74: 65 equipment
  equivalents in 39 material chests; finite enemy supplies and local keys.
- Correct the positional ledger join using catalogue_index: 63 instances /
  315 size rows. Original evidence preserved; totals/runtime unchanged.
- Auditor passes 866 checks, rejects 11 invalid variants and verifies new native
  evidence. Two generator runs match all four current outputs byte for byte.
- GZDoom: 325 recipe completions, 3,848-step keyed route, exact death supplies,
  partial/capacity collection, real save/load and hub return. Evidence and fixture
  limits: assets/validation_4378. Existing stations/knowledge remain required.
- CA-MAP02-MATERIALS-DROPS-01 was accepted 2026-10-02 (4.37.6 / #73 and #75).
  Preserve that acceptance and the old-save waiver; no unchanged test reopened.
  On 2026-10-02 the author also accepted this corrected report and #75 delivery
  without reported exceptions, authorizing PR #84 merge and #75 closure.
  HISTORY records this approval; pending_test.txt remains empty.

## Issue #74 — Flooded pit returns (4.37.7)

- Implemented: six stairless pits, one connected shallow-water network, four
  exterior-only independent grates, central native elevator and safe calls
  from either landing, including descending while all grates remain closed.
- Author decisions: previous-save compatibility waived; closed blocks keep
  their trap covers shut until their normal entrance opens.
- Population, other hazards, #75 supplies, surface locks and extraction retained.
- Static/native evidence: assets/validation_4377. New-layout save/load, hub return,
  all sizes, key recovery and four followers tested. The author confirmed all
  CA-MAP02-PIT-RETURN-01 checks passed on 2026-10-02 without reported exceptions
  and authorized PR #83 merge / #74 closure. Acceptance is recorded in HISTORY;
  the author-test queue is empty. Release 4.37.7 remains unchanged.

## Issue #73 — Cardinal MAP02 (4.37.6)

- Implements central arrival, south/west/east/north blocks and local carriers
  for all eight keys; includes the #75 supply changes explicitly required by #73.
- Author confirmed retaining current stations and waived old-save compatibility.
- This patch reserved the central footprint only; #74 implements the lower
  water tunnels/four return grates/elevator in 4.37.7 above.
- Evidence: assets/validation_4376. The author confirmed both CA-MAP02 checks
  passed on 2026-10-02 and authorized merge and closure of #73. HISTORY records
  acceptance separately from static/native evidence. #74 was also accepted on 2026-10-02.


## Issue #65 — Daily mansion food/water (4.37.5)

- Authorized by the author as a separate implementation/PR alongside #64.
- Implemented on issue-65-daily-tables, stacked on issue-64-time-skip / PR #71.
  Authored 2/2, 9/9 and 30/30 targets share the local midnight event and forecast.
- Per-table revision/day guards prevent duplicate stock. Deposited items and
  legacy rations remain; full old tables normalize only through consumption and
  later refills. Palomo explains daily timing in both languages.
- Evidence: assets/validation_4375/RESULTS.json. The author accepted
  CA-4375-TABLES-01 and CA-4375-SAVES-01 on 2026-10-02 without reported exceptions
  and authorized PR #72 merge / #65 closure. HISTORY records the results.
- PR #71 is merged and #64 closed; its acceptance is integrated before delivering
  #65 to main. All five confirmed pending entries are removed. Runtime and release
  4.37.5 remain unchanged; author acceptance is distinct from native evidence.

## Issue #64 — Date/time skip and automatic care (4.37.4)

- Implemented on issue-64-time-skip with Y destination selection, current T mode,
  native provisions/rest/work substeps and a nonmutating task-completion forecast.
- Author confirmed 10%/100% sleep policy and access throughout the safe location.
  Clock revision 1 preserves legacy counters/dates while freezing future exterior
  progression in Limbo. Original-save/package rollback remains available.
- Static/build and isolated GZDoom evidence: assets/validation_4374/RESULTS.json.
  The author accepted CA-4374-TIME-01, CA-4374-CARE-01 and CA-4374-SAVE-01 on
  2026-10-02 without reported exceptions; HISTORY records the results. Their
  pending entries are removed. Runtime and release 4.37.4 remain unchanged.
- The author also authorized #65 in another branch/PR. Its daily 50/50 table
  policy consumes #64's midnight and forecast contracts; combined multi-day
  verification belongs to that dependent patch. PR #71 merge and #64 closure
  are explicitly authorized; #65 is delivered separately through PR #72.

## Issue #63 — Move equipment guidance to Palomo (4.37.3)

- Implemented on issue-63-palomo-loadout: physical follow invitation, reviewable
  weapon/armor/Seal/shield plan and existing Ronnie recipe/material/task flow.
- Shield allowance uses current recipes and existing sources; no missing supply
  decision. Caella retains the amulet, and #65 food-source dialogue is coordinated.
- All own equipment survives departure; loans return and supplies are removed
  according to the author's explicit clarification. Revision-1 migration keeps
  old choices, quotas and progress; original-save/package rollback is tested.
- Static/build and isolated native evidence: assets/validation_4373/RESULTS.json.
  Native checks cover 49 choices, menu callbacks, physical route, all four shield
  recipes, cancellation, pending tasks, old saves and narrative exit/reload.
- Author accepted CA-4373-LOADOUT-01, CA-4373-SAVES-01 and CA-4373-EXIT-01 on
  2026-10-01 without reported exceptions and authorized PR #70 merge and #63
  closure. HISTORY records the results; the confirmed entries are removed from
  pending_test.txt. Runtime and release 4.37.3 remain unchanged.

## Issue #68 — Magic-weapon Anima base costs divided by ten (4.37.2)

- Author request after accepting #62; focused branch issue-68-anima-costs.
- Bases staff/book/bell/statuette: 50/70/100/100. Existing Eloquence Type 4
  division gives one third at 100; tiers/charge, damage and other costs remain.
- Shared constants cover player and authored NPC magic. Attribute revision 3
  updates saved derived costs and pending unpaid casts once, preserving state.
- Static/build, 240 native quotes, 48 live payments and save migration/reload
  checks pass. Evidence: assets/validation_4372/RESULTS.json. The author accepted
  CA-4372-ANIMA-01 on 2026-10-01 and authorized PR #69 merge and #68 closure.
  HISTORY records acceptance; no #68 author checks remain outstanding.

## Issue #62 — Caella's exercises against the training dummy (4.37.1)

- Implemented on issue-62-caella-dummy: offensive completion comes from a valid
  player magic projectile received by the shared mansion dummy. Projectile
  metadata identifies primary/secondary even after an equipment change.
- Actual Anima spending/recovery and Seal Channel retain independent checks;
  runes, return conversation, loans, passage and Rulo rules retain their gates.
- Reuses the existing target recovery path during Caella equipment preparation;
  adds no target class, placement, balance values or persistent schema revision.
- English/Spanish Caella and Journal instructions identify the target and room.
- Static validation, forty native spell combinations, negative/resource/rune/loan
  checks and active/completed save continuity pass. Evidence:
  assets/validation_4371/RESULTS.json. Native fixtures are isolated from
  the package. The author accepted all tests on 2026-10-01 without exceptions;
  CA-4371-CAELLA-01 is recorded in HISTORY and removed from pending_test.txt.
  Issue #62 / PR #67 is accepted; the new Anima-cost balance is a separate patch.

## Issue #61 — MAP01 terrain, vegetation and filled tympana (4.37.0)

- Implemented on issue-61-mansion-terrain: continuous native hills, mixed gentle
  and marked relief, sixteen decorative trees/twenty-four decorative shrubs,
  and filled triangular/arched tympana across all 32 original door groups.
- Author selected mixed relief and decorative-only additions on 2026-10-01;
  existing gathering resources remain unchanged. Old-save work is explicitly
  waived; use fresh MAP01/new game.
- Deterministic sources/manifests and read-only geometric preservation/continuity
  checks are included. Native traversal/resource/Palomo checks and 429 door
  regressions pass; the native tour captured 128 door views. Detailed evidence
  and scoped FPS observations belong in assets/validation_4370.
- Author correction: vegetation stays outside the pool, including underwater.
  Corrected three placements (two in the pool, one in a cave opening); generation
  now enforces dry exterior ground and a margin around the water.
- Author follow-up 2026-10-01: the other tests passed; distant ground at
  (17455,7394,0) was transparent and Prueba identified a roof-front gap above the
  top doorway. Both are corrected in the same 4.37.0 patch and PR #66.
- The author subsequently confirmed both repairs and all remaining original
  checks: CA-4370-MANSION-01 is accepted, recorded in HISTORY.
- New same-issue scope: Prueba at (23268,23285,0) identified another transparent
  area. Add the selected small mound cave, gentle descent, short bent tunnel
  and decorative rocks of all five gems. Native roof, passage, damage/resource
  and expanded distant-ground views are covered by the cave evidence.
- Author confirmed CA-4370-CAVE-01 on 2026-10-01; the original tutorial cave,
  gathering reserves and progression stay unchanged.
- Latest Prueba position (25630,29408,0): corrected invisible boundary/dark area
  by relocating 69 detached auxiliary rooms outside the playable horizon while
  preserving their control data. Static isolation and native surface, boundary,
  traversal and door regressions are in assets/validation_4370/CONTROLS.json.
  CA-4370-EXTERIOR-01 was accepted on 2026-10-01.
- Northern stations: six original actors at Y=1040 escaped relocation when hills
  raised their absolute Z above the old filter. Floor-relative recognition fixes
  selection and the spare fallback. The 38-station/five-room layout and original
  instances are retained; evidence: assets/validation_4370/STATIONS.json.
  Author confirmed CA-4370-STATIONS-01 and all remaining tests on 2026-10-01,
  authorizing PR #66 merge/issue #61 closure. No pending author checks remain;
  HISTORY records acceptance. Tested runtime and version 4.37.0 are preserved.
- Deferred Tarot/Trucazo remains separate final V4 scope before V5.

## Issue #17 — Verify and export the complete three-map test build (4.36.28)

- Author authorized export of current content on 2026-10-01 and explicitly
  deferred 4.37 Tarot/Trucazo until afterward. The accepted #16 content is frozen.
- Implemented commit-based deterministic export, SHA-256 manifest, portable
  clean-profile launcher, license notices and README-owned player instructions.
- Author reported an installation failure with engine/IWAD beside the package.
  Same-patch correction detects both locally and handles relative/quoted paths
  and folders; six process-level checks pass. Author accepted the retry.
- Static/build, exact blob identity, byte-identical reproduction and four-map
  native load/save/reload checks pass. Clean-install engine evidence is in
  assets/validation_43628/RESULTS.json; prior acceptance links and measured
  performance retain their original conditions and scope there.
- Author confirmed all tests passed on 2026-10-01 and authorized PR #60 merge
  and issue #17 closure. CA-43628-EXPORT-01 (corrected installation, ordinary
  campaign, cross-map saves and reward/resource continuity) is recorded as PASS
  in HISTORY without reported exceptions and removed from the pending queue.
- The accepted ZIP retains source commit 8415f225 and its recorded checksums.
  No GitHub Release/tag publication is requested; 4.37 remains the next work.
- Usage report retains the 75% baseline, unknown reset, separate Work/desktop
  evidence and unmeasured stages. On 2026-10-01 the author discontinued further
  weekly-allowance measurement; no additional quota tests/final balance are
  required. Missing counters do not become token or quota estimates.

## Issue #16 — Complete port siege (4.36.27)

- Implemented on `issue-16-port-siege`: full concurrent deployment, connected
  command groups, machine crews/gates, automatic unlimited cannons, 10/20-second
  reload, 100 equipped Domingo-appearance soldiers and half-health Zupay retreat.
- Victory requires twelve neutralized attacking machines plus commander defeat;
  surviving attackers physically retreat. Knight capture, prisoner rewards,
  calendar state and the explicit port endpoint use the existing shared systems.
- Native checks cover both objective orders, current save/load, original-save
  migration and rollback, exact reload times, targeting, reward/capture and the
  full 1,001-attacker/100-defender/24-machine scene. See assets/validation_43627.
- Author confirmed CA-43627-PORT-01 and CA-43627-SAVE-01 passed on 2026-09-30
  without reported exceptions and authorized PR #59 merge and issue #16 closure.
- Author reported missing crew relief and mostly stationary attackers during
  the initial port playtest. Follow-up implements nearest available same-side
  replacements and physical pursuit while magic resources recover. These
  follow-ups are included in the author's acceptance.
- Current author-requested trial enables attacks despite insufficient Air/Anima
  for registered hostile port enemies. Player/allied limits remain. The data
  switch remains reversible; the author accepted the current setting.
- #17 export passed author acceptance on 2026-10-01. Next: deferred 4.37;
  final independent distribution remains future work.

## Issue #37 — Attack cadence, durability and thrusts (4.36.26)

- Implemented: approved common duration/weight/attribute formula, full-cycle
  animations, the author's five thrusts, ×10 weapon durability and proportional
  migration, exact projectile source identity, authored enemy resource spending,
  idle recovery and the 80-tic Zupay slam.
- Verified: native shared-rule matrix, twenty weapon cycles, held Fire, cancelled
  casts/swings, exhaustion/recovery, cumulative magic phases at Eloquence
  0/33/100/1000, legacy migration/reload/rollback, pending-attack save/load and poses.
- Evidence: assets/validation_43626. Independent same-model review found and
  corrected state-index, bull recovery, encoded-pickup, phase rounding, charge
  overlap and input-deadline risks; DeepSeek was not available in this session.
- Author accepted CA-43626-COMBAT-01 and CA-43626-THRUST-01 on 2026-09-30
  and authorized PR #58 merge and issue closure. No author checks remain pending.
- Resident/companion weapon-resource assignments remain outside the authored
  hostile mappings; no guessed costs or equivalent equipment were added.


## Issue #36 — Mansion enclosure and architectural detail (4.36.25)

- Implemented: upper-storey roof/gable closure, native balcony guards,
  interior/exterior wall finishes, closed shutters, stone trim, two reliefs
  and an invisible but blocking outer horizon.
  Author follow-up: flat upper ceiling, raised finite shutters, east-wing
  interior materials and hinged wooden leaves. Latest clarification: remove four
  unwanted side doors at Z=136 and centre four independent front singles.
  Corrected the door exporter's excessive surface count behind the reproduced
  "Trying to create zero size texture" startup failure; see CA-KP-020.
- Author-approved visual proposal: aged render, wood, iron and discreet reliefs,
  2026-09-28. Historical rationale and source attribution are in ASSETS.
- Verified: preserved unaffected placements/actions/planes, deterministic output,
  focused native geometry traversal for body tiers 1/4/7, railing collision,
  roof closure and native views. Evidence: assets/validation_43625.
  Follow-up evidence covers both opening directions, three body sizes, access
  locks, swept-body obstruction and the flat ceiling; see followup and layout.
- Author confirmed the remaining prior work correct on 2026-09-29. Latest
  request: Rulo/Ronnie/Argento side doors open toward central rooms, away from
  beds; target moves to the empty north-central ground-floor room. Direction,
  placement, practice detection and bilingual guidance are implemented.
- Author confirmed those door/target tests passed on 2026-09-29, then requested
  Caella's bedside connection (908) also open toward the corridor. Implemented.
- Accepted: CA-43625-MANSION-01 fully passed on 2026-09-29, including Caella's
  last door change. The author authorized PR #57 merge and #36 closure. No
  #36 author checks remain. Evidence: assets/validation_43625/caella; #17 is separate.
- Author explicitly prioritized rebuilding over old MAP01 saves. Use a fresh
  MAP01/new game; the preserved source baseline is not an automatic migration.

## Issue #55 — Proprietary rights notice (4.36.24a)

Implemented: root LICENSE.md, README link, scoped reservation of the author's
rights and explicit preservation of third-party terms. Validate documentation
markers, index freshness and changed paths before the authorized merge/closure.
No gameplay acceptance check is added.

## Issue #35 — Quest journal (4.36.24)

- Implemented: stable main/side catalogue, independent type/status filters,
  completed records, sewer progress and four separate optional rescue records.
- Author-approved categories: mansion main; sewers/port/rescues side. Live
  extraction completes each rescue; port payment remains separate.
- Verified: validator/build and focused native state, navigation, bilingual
  layouts, legacy load, reload and hub persistence. Evidence: assets/validation_43624.
- Accepted: the author confirmed all CA-43624-JOURNAL-01 checks passed on
  2026-09-28 and authorized PR #54 merge and issue #35 closure.
- Subsequent #16 port deployment and #17 export are now author-accepted.

## Issue #52 — Final armor absorption (4.36.23)

Author revision, 2026-09-28: attacks and collisions now subtract Toughness
through its historical growth R(L)=L(L+1)/101 as percentage points of maximum
health, uncapped and with no minimum-damage floor. This supersedes the initial
direct-level subtraction. An
incoming 101% at Toughness 100 leaves 1% before armor; <=100% is still negated.
Final gate revision, also approved on 2026-09-28: Constitution 0 for all gates;
Toughness 25/50/75 and maximum resistance 5,500/6,500/11,000. Armor remains
10/20/30%. Small rams break common/reinforced/armored gates in 2/2/7 hits;
large rams in 1/2/2. Cannons retain Toughness reduction and deal zero gate damage.
Gate balance revision 2 preserves remaining-health ratio, open/broken states
and contact serials; repeated loads are idempotent. See SYSTEMS.
Current native evidence supersedes the previous matrices, retained as
DIVISOR_RESULTS.json, TOUGHNESS_RESULTS.json and GATE_RESULTS.json in
assets/validation_43623. The curve revision changes no saved levels or maxima. Release remains 4.36.23 because
all author revisions and acceptance belong to the same issue/PR patch.

- Implemented: shield/anatomy/Toughness/armor order; additive racial and equipped
  physical/magical defenses; approved tier values; Palomo 77%; gate 10/20/30%.
- Magical armor no longer grants mental attributes; other armor bonuses and
  shield rules remain. Fractional UI values use the same balance data.
- Legacy player/NPC derived statistics migrate idempotently; gate state and
  equipment are preserved. Original saves permit rollback with the previous build.
- Validation: native numerical/combat/impact/siege checks and save migration;
  evidence in assets/validation_43623/RESULTS.json. The author confirmed
  CA-43623-ARMOR-01, CA-43623-SAVE-01 and CA-43623-TOUGHNESS-01 passed on
  2026-09-28 and authorized PR #53 merge. No author checks remain pending.
- Scope: no siege penetration/explosion, new recipes, shield rebalance, map
  geometry or redesign of the existing player/NPC elemental-DOT asymmetry.

## Issue #34 — Demo quest narrative (4.36.22)

- **Implemented:** Palomo quest activation/survival/material guidance, Ronnie
  crafting/calendar, per-NPC peak Bull injury reactions, persistent queued rescue
  and paid-reward guidance, sewer death/escape line, actual-controller port quest.
- **Preserved:** main quest and item IDs, saved survival progress, crafting supplies,
  payouts, factions, combat balance, world pause rules and the single Tarot path.
- **Validation:** assets/validation_43622/RESULTS.json and STATIC.json; static,
  focused native behavior, old-save migration and rendered-menu checks pass.
- **MAP02 followup:** secondary-wind CELH sprite registration fixes the reproduced
  native rendering hang; both projectile variants/older-save checks pass.
  Author retest of the second rescue and rats passed 2026-09-27; see wind_render_fix.json
  in assets/validation_43622.
- **Legacy dialogue followup:** reproduced Palomo needs after old MAP02 reload;
  versioned Voice rebinding and safe closure/reopen of other old dialogues pass
  native checks. New saves preserve their exact page; original saves permit
  rollback. Author death/reload retest passed 2026-09-27.
- **Author acceptance:** CA-43622-NARRATIVE-01 passed on 2026-09-27; the author
  confirmed all tests and authorized merge/issue closure.
- **Dependency boundary:** #16 must deploy the complete MAP06 army/routes. The
  port quest stays hidden in the present pre-siege port; registered encounter
  integration is tested in isolation. After deployment, accept the full port
  narrative and retreat in campaign before #17 export. No fake victory is inferred.

## Issue #49 — Scenery collisions and running (4.36.21)

- **Issue:** https://github.com/damiancurti/Caelum-Argenteum/issues/49
- **Implemented:** environmental collision provenance without adrenaline or
  combat refresh; existing absorption extended to running and stationary scenery.
- **Preserved:** impact formulas, shield/landing/crush rules, genuine combat,
  saved fields, states and approved artwork/geometry.
- **Validation:** isolated native before/after and save checks plus static
  validation; assets/validation_43621/RESULTS.json.
- **Author acceptance:** CA-43621-IMPACT-01 passed on 2026-09-27.
- **Delivery:** PR #50 targets main after #48 merged; author approved merge on 2026-09-27.

## Issue #33 — Arcana capture, wounded Zupay and forward route (4.36.20)

- **Issue:** https://github.com/damiancurti/Caelum-Argenteum/issues/33
- **Implemented:** shared capture for IDs 0/36/60, El loco naming, confirmed
  boss-defeat reveal, provisional actual-reward gate for the Knight, wounded
  sewer-boss retreat at triple speed, MAP02 -> MAP03 -> MAP06 only forward route.
- **Preserved:** accepted extraction/rewards, siege test room cleanup, artwork,
  card effects, map geometry and old ownership/IDs.
- **Evidence:** assets/validation_43620 distinguishes static checks, native
  scenarios, saved-game migration and review from author acceptance.
- **Author acceptance:** CA-43620-ARCANA-01 and CA-43620-ROUTE-01 passed on 2026-09-27.
- **Author-reported failure corrected:** Ace Use froze before confirmation.
  Registered both Minor front sprites; native rendered dialogue/capture
  retests pass. Author retest passed; see capture_render_fix.json and HISTORY.
- **Next:** review the linked PR; #16/#17 replace the Knight's provisional
  appearance rule when the complete port siege is implemented.

## Issue #43 — Walking wall-impact absorption (4.36.18)

- **Issue:** https://github.com/damiancurti/Caelum-Argenteum/issues/43
- **Implemented:** existing crouched wall fraction also applies to grounded
  directional walking, using native effective run state. Walls only, no new balance.
- **Evidence:** 24 isolated native checks, including real wall traversal and a
  same-height jump with 80 kg body /20 kg equipment; assets/validation_43618.
- **Accepted:** author confirmed CA-43618-WALK-01 passed on 2026-09-27;
  merged and #43 closed. Final collision balancing is in 4.36.19 under #21.

## Issue #21 — Controlled cannon ballistics (4.36.17, final balance 4.36.19)

- **Issue:** https://github.com/damiancurti/Caelum-Argenteum/issues/21
- **Implemented:** physical 500 m/s inert projectiles, native gravity/collision,
  muzzle checks, load/fire/recovery, two/one/zero-operator behavior, separate
  faction ownership and persistent hostile-machine neutralization.
- **Decisions:** approximate reconstruction approved; 4.3 kg /75 x 185 mm inert
  rounds; 30/60-second cycles; Type 4 collision mitigation and 50/100/200 gate
  Toughness/Constitution. Final matrix approved 2026-09-27; merged and #21 closed.
- **Evidence:** assets/validation_43617; 41 cannon and 53 ram/shared-siege checks,
  plus save/hub/legacy checks passed. Manual CA-43613-CATAPULT-01 passed by author confirmation on 2026-09-27.
- **Final evidence:** assets/validation_43619; reversible gate balance migration,
  native damage matrix and affected regressions. The author confirmed
  CA-43619-BALANCE-01 passed on 2026-09-27; no manual checks remain pending.
- **Next:** #16 authors campaign placement, operators, ammunition/aim and rewards;
  #17 verifies the complete encounter. No full army is instantiated by #21.

## Issue #20 — Operational demonic rams (4.36.16; planned label 4.36.12)

- **Issue:** https://github.com/damiancurti/Caelum-Argenteum/issues/20
- **Implemented:** native approach/alignment, separate moving assembly,
  single-contact strike/recovery, full 6/32 staffing, persistent local death
  records, one-time neutralization, twelve-objective-plus-boss victory hook
  and authored-route withdrawal without kill rewards.
- **Author decisions:** 2026-09-26 full crew required; small rams affect wood
  and reinforced gates, large also armored; demonic contact velocity permitted.
- **Evidence:** assets/validation_43616. Static validation/build passed; 53
  native ram checks, 50 gate/body regression checks and save/hub/legacy
  persistence checks passed. The author confirmed CA-43612-RAM-01 passed on
  2026-09-26 and requested merge/closure; its result is recorded in HISTORY.
- **Next:** #21 cannon operation; #16 authors port routes/operator choreography,
  placements and victory rewards; #17 verifies complete encounter integration.

## Issue #19 — Breakable actor gates (4.36.15; planned label 4.36.11)

- **Issue:** https://github.com/damiancurti/Caelum-Argenteum/issues/19
- **Delivered:** explicit gate controllers, three approved material profiles,
  finite collision, damage/Use/key/faction groups, idempotent destruction and
  an assembly-mass/contact-velocity API for #20/#21. Optional MAP03 trial reuses
  accepted positions. MAP01/MAP02 doors and existing save schemas are unchanged.
- **Validation:** native fresh suite and actual save/load/hub-return chain pass;
  legacy 4.36.14a save and repeat trial activation pass. See assets/validation_43615.
- **Acceptance:** CA-43611-GATES-01 passed on 2026-09-26. The author confirmed
  every test after the reciprocal body-collision correction df4c668b and asked
  to close #19. HISTORY records the result; the pending entry is removed.
  Native evidence remains 13 focused assertions and 37 gate regression checks.
- **Next:** #20 ram strikes, #21 cannon ballistics/contact at approved speed,
  #16/#17 authored port placements and complete encounter. No provisional cannon
  projectile mass or forced gate destruction is introduced.

## Issue #18 follow-up — Siege art correction (4.36.14a)

- **Request:** author correction on 2026-09-26; linked to closed issue #18.
- **Scope:** defined cannon/ram forms, continuous two-leaf doors, wood/metal
  material variants and one visible model per state; fresh MAP03 preview.
- **Validation:** native state views and open-passage checks; deterministic
  generation, resource references, validator and normal package build.
- **Acceptance:** author confirmed all visual tests passed on 2026-09-26
  (`CA-43614A-SIEGE-ART-01`); transferred to HISTORY and removed from the queue.
- **Follow-up:** remove all remaining MAP03 tables, chairs, beds and crafting
  stations, prevent respawn and cover existing saves; native evidence in
  `assets/validation_43614a/cleanup`. Historical cannon scale/breech verification
  remains separate from this visual correction.
- **Next:** #19 damageable gates, #20 ram physics and #21 cannon physics;
  retain the authored hardness values in #18 without inventing new data.

## Issue #31 — Pain sounds, dialogue cue, map music and story intermissions (4.36.14)

- **Issue:** https://github.com/damiancurti/Caelum-Argenteum/issues/31
- **Scope:** integrate the author-selected pain sounds for Mandinga, Zupay,
  Bull, Argento, Ronnie, Caella and the applicable player voice profile;
  replace the dialogue-opening cue with the supplied Suno WAV; reassign MAP01
  to the former MAP02 music, MAP02 to the local sewer track, MAP06 to the local
  port track and MAP07 to the local coast track; reserve the former MAP01 music
  for future chapter-end intermissions.
- **Author contract:** no new Suno generation, no death/chase assignments, no
  activation of unused stock or MP3 backups, no invented lore or chapter text.
  Rulo remains silent for combat pain. External pain-source licenses remain to
  be verified; source URLs and local files are preserved.
- **Status:** implemented on the focused branch; static validation, build and
  native ZScript compile pass. Author-accepted on 2026-09-25
  (CA-43614-AUDIO-01 passed).
- **Next:** #18 / 4.36.10 owns siege assets after this delivery.

## Issue #18 — Reusable siege preview assets (4.36.10)

- **Issue:** https://github.com/damiancurti/Caelum-Argenteum/issues/18
- **Scope:** add reusable cannon, battering-ram and destructible-gate assets as
  verified-rendering content. Generate deterministic OBJ meshes under
  `src/models/caelum/siege`, transparent `CSGN A-D`/`CRAM A-C`/`CAGT A-C`
  frames, guarded `MODELDEF` bindings and the three runtime actor classes. On
  MAP03, retire the trial chairs, dining tables and cots and show every state
  in the open tank for author review.
- **Author contract:** no siege mechanics, mass, damage, reload time or gate
  hardness in this patch; those values remain #19-#21. Scale/orientation are
  provisional until the live preview is accepted.
- **Acceptance:** `CA-43610-SIEGE-ART-01` passed on 2026-09-26, as
  recorded in HISTORY. The 4.36.14a follow-up has its own pending author check.
- **Next:** #19 / 4.36.11 owns damageable gates and persistent opening.

## Issue #15 — Approved Tarot fronts and collection bindings (4.36.9)

- **Issue:** https://github.com/damiancurti/Caelum-Argenteum/issues/15
- **Scope:** integrate the author-supplied 78 PNG Tarot fronts under
  `src/graphics/caelum/tarot`, preserve the shared card back, map every source
  filename to its persistent card ID, and bind the Ace of Cups front in the
  Journal instead of showing a back. The Marseille court order is preserved:
  within each suit, Ace, 2–10, Knight, Page, Queen, King.
- **Author contract:** no new powers, rewards or campaign grants; unobtained
  cards are not granted by importing art; the Ace of Cups remains card 36; the
  Knight of Wands (`Tarot/61 - Caballero de basto.png`) is bound but its
  campaign reward stays in #16.
- **Acceptance:** CA-4369-TAROT-ART-01 passed on 2026-09-25; the author confirmed
  the imported fronts, persistent-ID bindings and Journal preview. The pending
  entry is removed and the author-test queue is empty.
- **Next:** #18 / 4.36.10 owns siege assets after this delivery.

## Issue #14 — Prisoner rescue, escort and port rewards (4.36.8)

- **Issue:** https://github.com/damiancurti/Caelum-Argenteum/issues/14
- **Scope:** release the four MAP02 prisoners through cell dialogue; freed
  prisoners follow and fight with the source character's stats while staying
  back from the northern Zupay; extract each alive at the pre-boss reservation
  before that fight (killing the boss is not required); persist outcomes and
  spawn rescued prisoners once at the MAP06 port, granting +10 own-faction
  reputation and 25 gold coins (1,000,000 copper) once per rescued prisoner,
  independent of character size, with no duplicate payout and retryable coin
  delivery. Replace the provisional social domains with six canonical factions:
  Unitarians=0, Federals=1, Free Peoples=2, Caelith=3, Cult of the Tarot=4 and
  Sun Warriors=5.
- **Author contract:** a follower that dies before extraction is not rescued;
  zero, one or four rescues are valid; no death respawn; do not reopen other
  cells; no broad companion formations. The Tarot remains the next issue.
- **Acceptance:** CA-4368-RESCUE-01 passed on 2026-09-25; the author confirmed
  the full release/follow/extraction/port-reward route and requested closure of
  issue #14. The pending entry is removed and the author-test queue is empty.
- **Next:** delivered through #15 / 4.36.9.

## Issue #13 — Recolored prisoner appearances (4.36.7)

- **Issue:** https://github.com/damiancurti/Caelum-Argenteum/issues/13
- **Scope:** add four distinct prisoner appearances that reuse Caella, Ronnie,
  Rulo and Argento with deterministic per-material muted palettes (hair/fur/cloak/cloth
  changed, skin and accessories kept); place one inert variant
  in each reserved MAP02 endpoint cell; keep the source combat profile and the
  original mansion NPCs unchanged.
- **Author contract:** provisional display names Leonor Benítez (Unitarians),
  Rufino Acosta (Federals), Santos Barrera (Free Peoples) and Leandro Farías
  (Cult of the Tarot); stable persistent IDs independent of names; no inherited
  anchoring, quest, inventory or story-protection logic; no rescue/reward logic
  in this visual patch.
- **Acceptance:** CA-4367-PRISONER-ART-01 passed on 2026-09-24; the author confirmed
  the four variants, visual-source/faction mapping and per-material recolors.
- **Next:** #14 / 4.36.8 owns escort, combat, dialogue and rewards.

## Issue #12 — Hostile sewer rats (4.36.6)

- **Issue:** https://github.com/damiancurti/Caelum-Argenteum/issues/12
- **Scope:** add two hostile sewer rats per Mandinga across the four MAP02
  sections, reusing the existing accepted `CaelumGiantRat` actor (DoomEdNum
  18029, RATG sprites) with no new art, damage, health or AI. Preserve 96
  Mandingas and one Zupay; place exactly 192 rats at fixed dry-walkway
  positions (two per Mandinga junction), recorded in the per-section manifest.
- **Determinism:** the MAP02 generator and layout validator are updated
  together; rats are initial placements only (no death respawn/resurrection),
  preserving the 2:1 ratio per section (24 Mandingas / 48 rats each).
- **Acceptance:** CA-4366-RATS-01 passed, explicitly confirmed by the author on
  2026-09-24 without qualifications; the confirmed entry is removed and the
  author-test queue is empty. Static/native evidence remains separate from that
  confirmation.
- **Next:** #13 / 4.36.7 after this delivery; #14 owns live escort AI.
## Issue #29 — Selective file reading for agents (4.36.5a)

- **Issue:** https://github.com/damiancurti/Caelum-Argenteum/issues/29
- **Status:** Implemented and statically verified; documentation/workflow only.
- **References:** `AGENTS.md`, `README.md`, `docs/CONTEXT.md`,
  `docs/GZDOOM_DEVELOPMENT.md`, `docs/DOCUMENT_INDEX.md` and
  `validate_project.py`.
- **Scope:** make selective file reading explicit in the agent workflow,
  reconcile it with the existing task/document mapping and index rules, and
  add practical search and range-reading examples in the engineering guide.
- **Acceptance:** `python validate_project.py` exits 0 with version `4.36.5a`,
  ten documents and no errors; `python build_document_index.py` regenerates
  `docs/DOCUMENT_INDEX.md` byte-for-byte; `git diff --check` passes. No
  gameplay, balance, asset, map, localization or save change is introduced.
- **Next:** #12 / 4.36.6 remains the next gameplay delivery.

## Issue #11 — Four-section sewer, cells and repair refuges (4.36.5)

- **Issue:** https://github.com/damiancurti/Caelum-Argenteum/issues/11
- **Scope:** four keyed sections/cells, beds and refuges; wider walkways and
  transparent barred gates; exact approved ammunition and retained population/loot.
- **Author decision:** repair known weapon recipes only; no new recipe/material
  allowance. Preserve finite salvage, costs, time and normal breakage.
- **Compatibility:** explicit legacy build continues already-visited MAP02 saves
  without map-ID changes, reset, lost loot or rewritten save data.
- **Acceptance:** CA-4365-MAZE-01 passed, explicitly confirmed by the author on
  2026-09-24 without qualifications; delivered through PR #28. HISTORY and
  validation_4365 keep author evidence separate from static/native checks.
  The confirmed entry is removed; the author-test queue is empty.
- **Next:** #12 rat population after this delivery; #14 owns live escort AI,
  extraction and rewards. #16 owns the MAP06 player-route reconciliation.

## Issue #10 — T1 loot, default sizing and pickup feedback (4.36.4)

- **Issue:** https://github.com/damiancurti/Caelum-Argenteum/issues/10
- **Scope:** complete 65-entry T1 MAP02 catalogue, reusable recipient sizing for
  natural/reward weapons/armor/shields, nonmutating chest previews with explicit
  collection, and actual acquisition names in a bounded 20-entry message feed.
- **Compatibility:** preserve owned/imported gear, old looted slots, existing
  size mapping and balance; revisioned unclaimed-loot migration, no replenishment.
- **Evidence:** HISTORY and `assets/validation_4364/` separate static/native
  results from author acceptance. The author confirmed CA-4364-T1-LOOT-01 passed
  on 2026-09-23; its entry is removed and the author-test queue is empty.
- **Status:** implemented and author-accepted; delivered through PR #27.
- **Next:** #11 / 4.36.5; no unrelated MAP01
  replay or implementation of the future rescue rewards belongs to this patch.

List of the project's active tasks. It is updated with every task.

Format of each entry: ID, title, status, reference documents, and acceptance
criteria. If a datum is not defined in the canonical documents, write
`PENDING`; do not invent it.

## Issue #22 — Engineering guides and document index (4.36.1b)

- **Issue:** https://github.com/damiancurti/Caelum-Argenteum/issues/22
- **Status:** Implemented and merged in PR #23; static verification is recorded
  in HISTORY. Documentation/tooling only.
- **References:** AGENTS, README, the canonical documents,
  `GZDOOM_DEVELOPMENT.md`, `KNOWN_PITFALLS.md`, `build_document_index.py` and the
  generated `DOCUMENT_INDEX.md`.
- **Scope:** integrate the two development handoff guides into `docs/`, generate a
  deterministic index for every maintained document over 5,000 words, extend the
  validator to cover guide/index metadata, hashes, links and word counts, and
  reconcile the prisoner coin reward to the confirmed T1/recipient-size rule.
- **Acceptance:** `python validate_project.py` exits 0 with version `4.36.1b`,
  ten documents and no errors; `python build_document_index.py` regenerates
  `docs/DOCUMENT_INDEX.md` byte-for-byte; `git diff --check` passes. No gameplay,
  balance, asset, map, localization or save change is introduced.
- **Regenerate/verify:** from the repo root run `python build_document_index.py`,
  then `python validate_project.py`.

## Issue #6 — Documentation and validation workflow (4.36.1)

- **Issue:** https://github.com/damiancurti/Caelum-Argenteum/issues/6
- **Status:** Implemented and statically verified; PR #7 is merged. On 2026-09-23
  the author confirmed zero validator errors, successful rebuild/launch and both
  4.36.1 diagnostic headers. CA-4361-WINDOWS-01 is passed and recorded in HISTORY;
  its pending entry is removed.
- **References:** AGENTS, README and the five canonical documents; validator,
  builder, launcher and issue template.
- **Scope:** English maintained documentation; numeric versions; repository-first
  delivery; a persistent root author-test queue; related validator/tooling updates.
- **Acceptance:** preserve canonical content, formulas, provenance and historical
  labels; synchronize 4.36.1 current markers; pass full-tree validation and focused
  positive/negative cases; demonstrate the queue lifecycle on disposable records;
  deliver a PR linked to #6 with executed evidence and outstanding author tests.
- **Evidence:** record actual commands, environment, exit codes and results in
  the PR and the 4.36.1 entry of HISTORY. Author checks live in
  [pending_test.txt](../pending_test.txt); confirmed outcomes move to the originating
  release's history entry only after explicit author confirmation.
- **Excluded:** gameplay, balance, map geometry, assets, localization and saves,
  apart from current-version diagnostic labels.

One issue defines one patch; its GitHub number is independent of the version.
Plan in Work, implement/test in desktop Codex on a focused branch, review the
linked PR, then record author acceptance when required. Multiple implementation
commits and later acceptance retain the same patch version. Outstanding tests
from earlier releases stay in the same queue. The queue may be empty; it must
remain tracked. Backlog tasks below are not executable author tests.

## Focused corrections after the author's 4.36.0i tests

- **Issue #8 / 4.36.2:** [Empty-bow equip stall](https://github.com/damiancurti/Caelum-Argenteum/issues/8).
  First-use texture-composition stalls reproduced in native GZDoom 4.14.2
  on Windows. Deterministic bow crop caches remove repeated composition;
  native evidence is in HISTORY. The author confirmed CA-4362-BOW-EMPTY-01
  passed on 2026-09-23; its entry is removed from the pending queue. Bow
  appearance, ammunition rules and save compatibility are retained.
- **Issue #9 / 4.36.3:** [Additional flail rotation](https://github.com/damiancurti/Caelum-Argenteum/issues/9).
  Implemented: shared handle offset -39.5 -> -29.5 degrees. Native Windows
  before/after T1–T3 captures and grip/joint, rest, full spin, return and re-equip
  checks passed; evidence is in HISTORY and `assets/validation_4363/`.
  The author confirmed CA-4360I-VISUAL-01 passed on 2026-09-23, with no
  reported exceptions, and requested issue closure. The pending entry is
  removed; PR #26 includes the implementation and acceptance record.
- Start each patch from the preceding merged version. These two issues are not
  implemented by the 4.36.1 acceptance-record update. Accepted maze, save/load,
  table and bow-art checks are recorded in HISTORY and are not reopened.

## Author-requested sewer and playtest batch — 2026-09-23

Planned only. Read the current author-roadmap section of PROJECT for the
canonical scope; each linked issue contains focused entry points and tests.
Implement one patch per issue after the previous merged version. PR #7's
documentation update does not implement these features or reset accepted tests.

| Patch / stage | Issue | Work and current blocker |
| --- | --- | --- |
| 4.36.4 | [#10](https://github.com/damiancurti/Caelum-Argenteum/issues/10) | Implemented and author-accepted on 2026-09-23. Complete T1 catalogue, recipient sizing, chest preview and feedback. |
| 4.36.5 | [#11](https://github.com/damiancurti/Caelum-Argenteum/issues/11) | Implemented and author-accepted on 2026-09-24; CA-4365-MAZE-01 passed (PR #28). Four sections, keys/cells/beds, recipe-gated repair refuges, widened channels and northern boss room. |
| 4.36.6 | [#12](https://github.com/damiancurti/Caelum-Argenteum/issues/12) | Implemented and author-accepted on 2026-09-24; CA-4366-RATS-01 passed. 192 fixed rats/96 Mandingas at 2:1, no respawn. |
| 4.36.7 | [#13](https://github.com/damiancurti/Caelum-Argenteum/issues/13) | Implemented and author-accepted on 2026-09-24; CA-4367-PRISONER-ART-01 passed. Four per-material recolored prisoner appearances in the reserved cells. |
| 4.36.8 | [#14](https://github.com/damiancurti/Caelum-Argenteum/issues/14) | Implemented and author-accepted on 2026-09-25; CA-4368-RESCUE-01 passed. Follow/fight with source-character stats; extract alive before MAP02 boss; port thanks, +10 own-faction reputation and a fixed 25 gold coins independent of character size once per rescue. |
| 4.36.9 | [#15](https://github.com/damiancurti/Caelum-Argenteum/issues/15) | Tarot fronts and correct collection bindings. Implemented from the verified local source archive; author-accepted on 2026-09-25 (CA-4369-TAROT-ART-01 passed). |
| 4.36.14 | [#31](https://github.com/damiancurti/Caelum-Argenteum/issues/31) | Author-selected pain sounds, supplied dialogue-opening cue, local sewer/port/coast music and the reserved chapter-end story intermission. Implemented and author-accepted on 2026-09-25 (CA-43614-AUDIO-01 passed). |
| 4.36.10 | [#18](https://github.com/damiancurti/Caelum-Argenteum/issues/18) | Siege assets: cannon (replacing catapult), ram and breakable gate. After #15. |
| 4.36.11 | [#19](https://github.com/damiancurti/Caelum-Argenteum/issues/19) | Damageable actor gates. Structural parameter table needs approval. After #18. |
| 4.36.12 | [#20](https://github.com/damiancurti/Caelum-Argenteum/issues/20) | Physical ram strikes; approved parameter table and native evidence required. After #19. |
| 4.36.13 | [#21](https://github.com/damiancurti/Caelum-Argenteum/issues/21) | Native cannon launch/impact at approved 400 m/s; approved parameter table and native evidence required. After #20. |
| 4.36.27 | [#16](https://github.com/damiancurti/Caelum-Argenteum/issues/16) | Complete MAP06 port siege and Knight of Wands. All author tests passed on 2026-09-30; PR #59 merge and issue closure authorized. |
| 4.36.28 | [#17](https://github.com/damiancurti/Caelum-Argenteum/issues/17) | Reproducible three-map package and corrected launcher accepted on 2026-10-01; PR #60 merge/closure authorized. Further weekly quota measurement discontinued; 4.37 remains next. |

The source/faction mapping is Caella/Unitarians, Ronnie/Federals,
Rulo/Free Peoples (Pueblos Libres) and Argento/Cult of the Tarot. These are new
prisoners; do not alter the mansion residents or reuse unrelated saved faction IDs.
The confirmed three-map route uses MAP06 for the existing port, not a
renumbered MAP03. Issue #16 replaces the former player exit to MAP07
with the approved route. El Loco is the first Major; Ace of Cups remains MAP02.

Preserve the historical #8–#21 Usage evidence and correction records. The author
discontinued further weekly-allowance measurements on 2026-10-01. The initial
75% remaining baseline has an unknown reset and is not a token count. Existing
Work/desktop, resets, concurrent-work and missing-measurement distinctions remain.
Only add actionable author checks to pending_test.txt after implementation;
missing design/assets belong here and in issues, not in that queue.

## Environmental scope and remaining 4.36 work

The author's 2026-09-23 clarification in #8 distinguishes covered, deferred
and still-pending mechanisms. Covered/deferred entries below are not 4.36
release blockers; remaining integration checks still are.
According to `docs/PROJECT.md`, 4.36 already includes the trapdoor, the pit,
the rocks, the approved traps, the ceiling crusher, and the resting-weight
formula; what remains is to complete the planned bases and validate their
integration before extracting Impact Physics.

### CA-436-01 — Damaging surfaces

- **Status:** Deferred until environmental temperature effects are implemented
  (author confirmation in #8, 2026-09-23). Future backlog, not a 4.36 blocker;
  no acid or lava is requested now. Not implemented.
- **Reference documents:** `docs/PROJECT.md` (V4.36 roadmap),
  `docs/SYSTEMS.md` (physical hazards section).
- **Acceptance criteria:** PENDING. The current documentation only states it
  as a planned base; the concrete criteria are set by the author.

### CA-436-02 — Avalanches

- **Status:** Deferred until additional maps are developed (author confirmation
  in #8, 2026-09-23). Future backlog, not a 4.36 blocker. Not implemented.
- **Reference documents:** `docs/PROJECT.md` (V4.36 roadmap).
- **Acceptance criteria:** PENDING.

### CA-436-03 — Rams

- **Status:** Implemented in #20 / 4.36.16 (planned label 4.36.12), with native evidence in assets/validation_43616. Author acceptance CA-43612-RAM-01 passed on 2026-09-26.
- **Reference documents:** `docs/PROJECT.md` (V4.36 roadmap).
- **Acceptance criteria:** Native visible strike/contact/recovery with one
  physical impact per strike, gate interaction and save/reset persistence.
  Mass/speed/cadence parameters require canonical reuse or author approval;
  render-only assets do not close this gate.

### CA-436-04 — Cannons (historical catapult task ID)

- **Status:** Implemented in #21 /4.36.17 (planned 4.36.13); native evidence in assets/validation_43617. CA-43613-CATAPULT-01 author acceptance passed on 2026-09-27.
- **Reference documents:** `docs/PROJECT.md` (V4.36 roadmap).
- **Acceptance criteria:** One physical projectile per synchronized launch,
  native trajectory/collision, approved impact rules and loaded/in-flight
  save persistence. Projectile/launch/reload parameters need canonical reuse
  or author approval; final encounter integration belongs to #16.

### CA-436-05 — Moving sectors

- **Status:** Covered by the existing crushing ceiling and native elevator,
  per the author's 2026-09-23 confirmation in #8. No longer a 4.36 blocker.
- **Reference documents:** `docs/PROJECT.md` (current 4.36.4 scope).
- **Acceptance:** Scope confirmation only; no new engine test or replay is
  claimed. No rotating/translating rooms or additional platforms are requested.

## Integration and closing of 4.36

- **Status:** Pending.
- **Reference documents:** `docs/PROJECT.md` (V4.36 roadmap and "What remains
  to close 4.36").
- **Acceptance criteria:** validate the integration of the mechanisms in the
  gallery, persistence, and reset; extract Impact Physics only after
  validating its use in Caelum. Numerical criteria remain PENDING.
