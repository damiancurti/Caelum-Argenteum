# TASKS.md — Active tasks

Documentation version: **4.36.1** — 2026-09-23.

List of the project's active tasks. It is updated with every task.

Format of each entry: ID, title, status, reference documents, and acceptance
criteria. If a datum is not defined in the canonical documents, write
`PENDING`; do not invent it.

## Issue #6 — Documentation and validation workflow (4.36.1)

- **Issue:** https://github.com/damiancurti/Caelum-Argenteum/issues/6
- **Status:** Implemented and statically verified; PR review and author acceptance
  remain separate. No new author confirmation has been recorded.
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

## Pending in 4.36

These tasks close the V4.36 block (mobile environment and physical hazards).
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

- **Status:** Pending.
- **Reference documents:** `docs/PROJECT.md` (V4.36 roadmap).
- **Acceptance criteria:** PENDING.

### CA-436-04 — Catapults

- **Status:** Pending.
- **Reference documents:** `docs/PROJECT.md` (V4.36 roadmap).
- **Acceptance criteria:** PENDING.

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

