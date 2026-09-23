# TASKS.md — Active tasks

Documentation version: **4.36.1** — 2026-09-23.

List of the project's active tasks. It is updated with every task.

Format of each entry: ID, title, status, reference documents, and acceptance
criteria. If a datum is not defined in the canonical documents, write
`PENDING`; do not invent it.

## Issue #6 — Documentation and validation workflow (4.36.1)

- **Issue:** https://github.com/damiancurti/Caelum-Argenteum/issues/6
- **Status:** Implemented and statically verified; PR #7 is open. On 2026-09-23
  the author confirmed zero validator errors, successful rebuild/launch and both
  4.36.1 diagnostic headers. CA-4361-WINDOWS-01 is passed and recorded in HISTORY;
  its pending entry is removed. Merge approval remains pending.
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

- **Issue #8 / planned 4.36.2:** [Empty-bow equip stall](https://github.com/damiancurti/Caelum-Argenteum/issues/8).
  Reported by the author, not independently reproduced; diagnose first-use and
  repeated empty/loaded transitions, then apply the smallest verified correction.
  Preserve accepted bow appearance, ammunition rules and save compatibility.
- **Issue #9 / planned 4.36.3:** [Additional flail rotation](https://github.com/damiancurti/Caelum-Argenteum/issues/9).
  Rotate the current first-person handle approximately 10 degrees further
  counterclockwise while preserving grip, rear chain, vertical rest and attack spin.
  Retain CA-4360I-VISUAL-01 until the author accepts the corrected pose.
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
| 4.36.4 | [#10](https://github.com/damiancurti/Caelum-Argenteum/issues/10) | Restrict maze equipment to T1, preserving the complete starter catalogue. After #9. |
| 4.36.5 | [#11](https://github.com/damiancurti/Caelum-Argenteum/issues/11) | Four sections, keys/cells/beds, functional repair refuges, sewer channels/decor, northern locked boss room. After #10. |
| 4.36.6 | [#12](https://github.com/damiancurti/Caelum-Argenteum/issues/12) | Existing hostile rats at 2:1 per section: 192 rats/96 Mandingas. After #11. |
| 4.36.7 | [#13](https://github.com/damiancurti/Caelum-Argenteum/issues/13) | Four reused NPC appearances with distinct palettes. After #12. |
| 4.36.8 | [#14](https://github.com/damiancurti/Caelum-Argenteum/issues/14) | Follow/fight with source-character stats; extract alive before MAP02 boss; port thanks, +10 own-faction reputation and coins worth two average size-M weapons once per rescue. Reward reference tiers (T1 or T1–T3) pending. |
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

## Pending in 4.36

These original physics gates remain necessary alongside the new batch to
close the V4.36 block (mobile environment and physical hazards).
According to `docs/PROJECT.md`, 4.36 already includes the trapdoor, the pit,
the rocks, the approved traps, the ceiling crusher, and the resting-weight
formula; what remains is to complete the planned bases and validate their
integration before extracting Impact Physics.

### CA-436-01 — Damaging surfaces

- **Status:** Pending.
- **Reference documents:** `docs/PROJECT.md` (V4.36 roadmap),
  `docs/SYSTEMS.md` (physical hazards section).
- **Acceptance criteria:** PENDING. The current documentation only states it
  as a planned base; the concrete criteria are set by the author.

### CA-436-02 — Avalanches

- **Status:** Pending.
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

- **Status:** Pending.
- **Reference documents:** `docs/PROJECT.md` (V4.36 roadmap).
- **Acceptance criteria:** PENDING.

## Integration and closing of 4.36

- **Status:** Pending.
- **Reference documents:** `docs/PROJECT.md` (V4.36 roadmap and "What remains
  to close 4.36").
- **Acceptance criteria:** validate the integration of the mechanisms in the
  gallery, persistence, and reset; extract Impact Physics only after
  validating its use in Caelum. Numerical criteria remain PENDING.
