# TASKS.md — Active tasks

Documentation version: **4.36.6** — 2026-09-24.

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
| 4.36.6 | [#12](https://github.com/damiancurti/Caelum-Argenteum/issues/12) | Implemented on 2026-09-24; static passed, native and author check CA-4366-RATS-01 pending. 192 fixed rats/96 Mandingas at 2:1, no respawn. |
| 4.36.7 | [#13](https://github.com/damiancurti/Caelum-Argenteum/issues/13) | Four reused NPC appearances with distinct palettes. After #12. |
| 4.36.8 | [#14](https://github.com/damiancurti/Caelum-Argenteum/issues/14) | Follow/fight with source-character stats; extract alive before MAP02 boss; port thanks, +10 own-faction reputation and a fixed 25 gold coins independent of character size once per rescue. |
| 4.36.9 | [#15](https://github.com/damiancurti/Caelum-Argenteum/issues/15) | Tarot fronts and correct collection bindings. Blocked on approved downloadable source pack/manifest. |
| 4.36.10 | [#18](https://github.com/damiancurti/Caelum-Argenteum/issues/18) | Siege assets: catapult, ram and breakable gate. After #15. |
| 4.36.11 | [#19](https://github.com/damiancurti/Caelum-Argenteum/issues/19) | Damageable actor gates. Structural parameter table needs approval. After #18. |
| 4.36.12 | [#20](https://github.com/damiancurti/Caelum-Argenteum/issues/20) | Physical ram strikes; approved parameter table and native evidence required. After #19. |
| 4.36.13 | [#21](https://github.com/damiancurti/Caelum-Argenteum/issues/21) | Native catapult launch/impact; approved parameter table and native evidence required. After #20. |
| V4 content | [#16](https://github.com/damiancurti/Caelum-Argenteum/issues/16) | Third map is MAP06 port: stop demon siege; its Zupay holds second Minor. Card identity and detailed encounter conditions/balance pending. Requires siege foundations; numeric patch assigned when scheduled. |
| V4 export | [#17](https://github.com/damiancurti/Caelum-Argenteum/issues/17) | Three-map acceptance, reproducible package and batch usage report. Requires #16 and retained 4.36/4.37 gates. |

The source/faction mapping is Caella/Unitarians, Ronnie/Federals,
Rulo/Wild Beast Men and Argento/Cult of the Tarot. These are new prisoners;
do not alter the mansion residents or reuse unrelated saved faction IDs.
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
