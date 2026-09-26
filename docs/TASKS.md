# TASKS.md — Active tasks

Documentation version: **4.36.15** — 2026-09-26.

## Issue #19 — Breakable actor gates (4.36.15; planned label 4.36.11)

- **Issue:** https://github.com/damiancurti/Caelum-Argenteum/issues/19
- **Delivered:** explicit gate controllers, three approved material profiles,
  finite collision, damage/Use/key/faction groups, idempotent destruction and
  an assembly-mass/contact-velocity API for #20/#21. Optional MAP03 trial reuses
  accepted positions. MAP01/MAP02 doors and existing save schemas are unchanged.
- **Validation:** native fresh suite and actual save/load/hub-return chain pass;
  legacy 4.36.14a save and repeat trial activation pass. See assets/validation_43615.
- **Acceptance:** author confirmed the other checks on 2026-09-26 but reported
  missing reciprocal damage when running into gates. That native contact path
  is corrected; 13 focused assertions and the 37-check gate regression pass.
  CA-43611-GATES-01 now contains only the pending body-collision retest.
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
| 4.36.10 | [#18](https://github.com/damiancurti/Caelum-Argenteum/issues/18) | Siege assets: catapult, ram and breakable gate. After #15. |
| 4.36.11 | [#19](https://github.com/damiancurti/Caelum-Argenteum/issues/19) | Damageable actor gates. Structural parameter table needs approval. After #18. |
| 4.36.12 | [#20](https://github.com/damiancurti/Caelum-Argenteum/issues/20) | Physical ram strikes; approved parameter table and native evidence required. After #19. |
| 4.36.13 | [#21](https://github.com/damiancurti/Caelum-Argenteum/issues/21) | Native catapult launch/impact; approved parameter table and native evidence required. After #20. |
| V4 content | [#16](https://github.com/damiancurti/Caelum-Argenteum/issues/16) | Third map is MAP06 port: stop demon siege; its Zupay holds second Minor. Card identity and detailed encounter conditions/balance pending. Requires siege foundations; numeric patch assigned when scheduled. |
| V4 export | [#17](https://github.com/damiancurti/Caelum-Argenteum/issues/17) | Three-map acceptance, reproducible package and batch usage report. Requires #16 and retained 4.36/4.37 gates. |

The source/faction mapping is Caella/Unitarians, Ronnie/Federals,
Rulo/Free Peoples (Pueblos Libres) and Argento/Cult of the Tarot. These are new
prisoners; do not alter the mansion residents or reuse unrelated saved faction IDs.
The confirmed three-map route uses MAP06 for the existing port, not a
renumbered MAP03. Issue #16 must replace the current player exit to MAP07
with the approved route. El Loco is the first Major; Ace of Cups remains MAP02.

Record Usage evidence per #8, including correction sessions through acceptance.
The author confirms 75% weekly allowance remaining at the initial baseline;
reset time is unknown. It is not a measured token count. Account for
Work, desktop, resets, concurrent work and missing measurements separately.
Only add actionable author checks to pending_test.txt after implementation;
missing design/assets belong here and in issues, not in that queue.

## Environmental scope and remaining 4.36 work

The author's 2026-09-23 clarification in #8 distinguishes covered, deferred
and still-pending mechanisms. Covered/deferred entries below are not 4.36
release blockers; rams/catapults and remaining integration checks still are.
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

- **Status:** Pending implementation in [#20](https://github.com/damiancurti/Caelum-Argenteum/issues/20), planned 4.36.12.
- **Reference documents:** `docs/PROJECT.md` (V4.36 roadmap).
- **Acceptance criteria:** Native visible strike/contact/recovery with one
  physical impact per strike, gate interaction and save/reset persistence.
  Mass/speed/cadence parameters require canonical reuse or author approval;
  render-only assets do not close this gate.

### CA-436-04 — Catapults

- **Status:** Pending implementation in [#21](https://github.com/damiancurti/Caelum-Argenteum/issues/21), planned 4.36.13.
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
