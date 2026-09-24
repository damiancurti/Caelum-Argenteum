# Known pitfalls and verified lessons — Caelum Argenteum

Status: author-requested handoff draft; formal repository integration pending.
Prepared: 2026-09-23. Inherits the project's release after integration.
Inspected baseline: `1dc390576fa330d37ff543526fc7e69a397fc28f` (PR #7).

## How to read this register

This is a compact engineering memory, not a second bug tracker or a claim that every historical fix has been independently reproduced. Use the current issue for active scope and HISTORY for release chronology and author acceptance.

Evidence labels:
- CODE-VERIFIED: supported by inspected source at a named baseline; no runtime guarantee.
- AUTHOR-REPORTED: observed by the author; environment/reproduction may still be incomplete.
- ENGINE-VERIFIED: reproduced with retained engine evidence and conditions.
- RESOLVED-VERIFIED: cause and fix supported by before/after evidence, with acceptance stated separately.
- HYPOTHESIS: an unconfirmed explanation, explicitly not a verified lesson.
- SUPERSEDED: retained reference to advice no longer applicable.

None of the open defects below is labelled RESOLVED-VERIFIED. This handoff performed source inspection, not a new engine run.

## CA-KP-001 — Adding a guide to docs breaks the current exact-file check

Status/evidence: CODE-VERIFIED. Scope: baseline validate_project.py, validate(), CANONICAL/WORKING/DOCUMENTS.

Observation: the validator recursively enumerates every file in docs/ and requires equality with exactly five canonical plus two working documents. It also requires current-version headers in those registered documents. Simply copying these two guides into docs/ therefore fails that check.

Cause: an explicit exact-set validation contract, not invalid Markdown.

Action for the future integration issue: deliberately register both ancillary guides and decide their header policy; preserve validation of the existing seven versioned documents. Update AGENTS/CONTEXT navigation and the guide's links together. Do not disable the exact-set, version, localization or resource checks wholesale to obtain a green result.

Verification to add: clean integrated tree passes; missing required guide and broken guide link fail; an unrelated unexpected docs file still follows the explicitly selected policy; existing version mismatch still fails. Test negative cases in disposable copies.

Until integration: keep the supplied knowledge_handoff folder outside docs/ and src/. Formal fix: not implemented by this delivery.

## CA-KP-002 — Default equipment size is not the character's raw body tier

Status/evidence: CODE-VERIFIED. Scope: baseline src/caelum/equipment/CaelumEquipmentRules.zs, GetDefaultSizeForCharacterTier; real callers in CaelumMainM00RonnieTrial.zs and CaelumMainM00MagicTrial.zs.

Observation: a shared mapping converts character tiers into equipment-size constants; its current default selection does not select every possible equipment size. Do not infer a linear or one-to-one mapping, or change it as incidental cleanup.

Prevention: reuse the helper for the actual recipient and inspect fit, weight and durability consumers. Preserve acquired-item identity and size. Issue #10 defines the new MAP02 acquisition behavior; it is not already proven merely by finding the helper.

Verification: representative small, medium and large characters, actual recipient, capacity failure/retry, save/load and drop/re-pick. Record values through the actual APIs rather than a manually duplicated mapping.

## CA-KP-003 — An empty bow equip can stall; root cause remains unconfirmed

Status/evidence: AUTHOR-REPORTED; investigation open in issue #8.
Source: https://github.com/damiancurti/Caelum-Argenteum/issues/8

Symptom: the author reported a multi-second freeze equipping a bow without arrows; it worked when an arrow was available. Exact bow variant, timing and repeatability were not established by this handoff.

Candidate inspection points: CaelumFirstPersonView.zs, CaelumFirstPersonLayers.zs/BowPresentation, CaelumPlayableWeapons.zs and player equip/ammunition handling. These paths are not a diagnosis.

Do not record an infinite loop, texture loading or an ammunition bug as the cause without evidence. Compare fresh-engine and repeated equips, no magazine/reserve ammunition, an ammunition-present control and return to empty after firing. Check normal bow and longbow, relevant controls and timings.

Resolution field: pending. Promote only after a cause-based fix and retained before/after engine evidence; author Windows acceptance remains separate.

## CA-KP-004 — Flail rotation must be judged around the rendered grip

Status/evidence: CODE-VERIFIED presentation structure plus AUTHOR-REPORTED visual correction; issue #9 remains open.
Source: https://github.com/damiancurti/Caelum-Argenteum/issues/9

Baseline: src/caelum/equipment/CaelumFirstPersonLayers.zs uses handleAngle=rotation-39.5 and derives handle/chain positions through transformed joint coordinates. The author requests another approximately 10 degrees counterclockwise.

Prevention: preserve the grip reference and connected layers. A numerically plausible angle is not proof of the screen-space direction or a correct chain attachment. Do not rotate a flattened screenshot and call the engine change complete.

Verification: native before/after views at rest and relevant animation states, same configuration, grip/chain continuity and unchanged accepted behavior. Candidate offsets in the issue are proposals until engine-verified.

## CA-KP-005 — A green validator or a built PK3 is not a gameplay pass

Status/evidence: CODE-VERIFIED tool scope. Baseline validate_project.py and build_dev.ps1.

Observation: Python checks selected project contracts; the builder packages source files and checks archive/PNG properties. Neither tool executes a normal player route or proves that ZScript compiles in GZDoom.

Prevention: report static validation, packaging, engine load, scenario behavior and author acceptance separately. Do not reuse an old engine success as evidence for a changed commit. State limitations of Linux/Freedoom fixtures and preserve target Windows verification.

Resolution: this is a workflow safeguard, not a bug awaiting a code fix. Each PR supplies the levels relevant to its change.

## CA-KP-006 — Planned state can drift between issues and canonical documents

Status/evidence: CODE/DOCUMENT-VERIFIED discrepancy plus explicit author clarification.

At the inspected PR #7 commit, its reward clarification still describes size-M prices with tiers pending. The author's later instruction and updated issues #10/#14 specify T1 and the recipient's equipment size. Local edited documents can be newer than their Git HEAD; they must not be cited as committed evidence.

Prevention: compare the exact commit and dirty-tree status, distinguish author-approved design from shipped implementation, and reconcile the current canonical sections during formal integration. Do not silently revert a later author decision because an older document says otherwise.

Acceptance: issues and canonical current rules agree; historical fixed-M discussions remain historical. This delivery records the discrepancy but does not edit the repository or claim it has been resolved there.

## Rules for adding and updating entries

1. Add an entry only for reusable engineering knowledge: a recurring failure, a non-obvious project constraint, or a verified cause/fix likely to prevent future work. Ordinary progress belongs in the issue.
2. Search for an existing ID/symptom before adding. Keep stable CA-KP identifiers and update the original entry instead of creating duplicates.
3. Record facts, hypotheses and approved requirements separately. A user-observed failure can be recorded immediately as AUTHOR-REPORTED; missing reproduction does not mean it is disproven.
4. Include the engine version, affected commit(s), path/symbol, scope, reproducible steps, evidence and limitations where available. Mark unavailable fields explicitly; never fabricate logs or confirmation.
5. To mark a defect RESOLVED-VERIFIED, retain the reproducer, identified cause, fix commit, before/after results and any residual risk. State whether the author accepted it; engine success alone is not author acceptance.
6. Record failed approaches only when they explain a trap or prevent a likely repeat. Do not paste entire conversations, speculative reasoning or raw session logs.
7. Link to durable repository/PR artifacts. Temporary sandbox paths and expiring downloads are not permanent evidence. Never commit credentials or private installation paths.
8. Recheck an entry when its owning code or engine version changes. Mark obsolete advice SUPERSEDED with a replacement reference; preserve unique history in HISTORY.
9. Keep entries concise (normally 150–300 words excluding a necessary small reproducer). Link to canonical formulas rather than copying large tables.
10. Review only the touched entries and connected rules during a patch. Do not add a full historical audit or additional engine run solely to expand this register.

## Copyable entry template

```text
## CA-KP-NNN — Concrete symptom or constraint
Status/evidence: AUTHOR-REPORTED | CODE-VERIFIED | ENGINE-VERIFIED |
                 RESOLVED-VERIFIED | HYPOTHESIS | SUPERSEDED
First recorded / last checked: YYYY-MM-DD / YYYY-MM-DD
Issue / PR: repository links, or not recorded
Affected baseline: exact commit and dirty-tree qualification
Environment: engine version, OS, IWAD, renderer/config, save state as relevant
Scope: path, symbol, affected consumers
Symptom or constraint:
Reproduction: shortest steps and expected/observed behavior
Cause: verified explanation, or UNCONFIRMED
Fix / prevention: actual change and commit, or PROPOSED/PENDING
Evidence: commands, exit codes, durable artifact links and results
Regression check: smallest test that catches recurrence
Author acceptance: exact confirmed ID/date/qualifications, or PENDING/NOT REQUIRED
Limitations / superseded by:
```

For non-runtime constraints, mark engine reproduction not applicable and provide the static/source evidence. Empty template fields are not executed tests.
