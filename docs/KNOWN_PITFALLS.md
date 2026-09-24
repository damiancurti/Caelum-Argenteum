# Known pitfalls and verified lessons — Caelum Argenteum

Status: integrated engineering register (issue #22, patch 4.36.1b).
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

CA-KP-003 records the focused 4.36.2 native runtime verification. CA-KP-001
is a resolved tooling contract. Author acceptance remains explicitly separate.

## CA-KP-001 — Adding a guide to docs breaks the current exact-file check

Status/evidence: RESOLVED-VERIFIED tooling contract (issue #22, patch 4.36.1b).

Observation: the validator used to require exactly the five canonical plus two working documents under docs/ and current-version headers in those registered documents. Copying these two guides into docs/ therefore failed that exact-set check.

Cause: an explicit exact-set validation contract, not invalid Markdown.

Resolution: issue #22 registers `GZDOOM_DEVELOPMENT.md`, `KNOWN_PITFALLS.md` and the generated `DOCUMENT_INDEX.md` as the explicit allowed docs set. The seven canonical/working documents and AGENTS remain subject to current-version checks; the ancillary guides inherit README's release. The unexpected-doc-file check stays active against the extended allowed set, and the guides' existence, UTF-8 readability and repository-relative links are validated.

Verification: before the patch, a disposable copy with the two guides failed the exact-set check; after the patch, `python validate_project.py` exits 0 with ten docs and an empty error list. Disposable negative cases still fail for a missing guide, a broken guide link, an unexpected docs file and a version mismatch.

Author acceptance: recorded separately for the 4.36.1b documentation patch; this entry describes the tooling fix, not a runtime defect.

## CA-KP-002 — Default equipment size is not the character's raw body tier

Status/evidence: ENGINE-VERIFIED in 4.36.4 (#10), GZDoom g4.14.2. Scope: shared recipient-size policy, native equipment acquisition and legacy MAP02 chest migration; author acceptance: CA-4364-T1-LOOT-01 passed on 2026-09-23.

Observation: a shared mapping converts character tiers into equipment-size constants; its current default selection does not select every possible equipment size. Do not infer a linear or one-to-one mapping, or change it as incidental cleanup.

Cause/fix: the former pickup path could initialize size and reserve ItemId before
capacity rejection. Treating those fields as proof of acquisition bound rejected
shared loot to its first viewer. Resolve a nonmutating projection, check capacity
before allocating identity, and commit only on transfer. Preserve genuine owned
or dropped equipment. A container's temporary BecomePickup/bDROPPED flag is not
evidence of previous ownership. Revisioned migration retains unclaimed higher-tier
objects separately without refilling looted slots; RestoreLegacyLootForMigration
reverses that storage change. Explicit CHARACTER_DEFAULT is distinct from legacy
editor argument 0 (M) and resolved size enum 0 (XS).

Prevention: reuse the mapping for the actual recipient, including multiplayer;
inspect fit, weight, durability, value and capacity. Preview and cancellation must
never assign identity or change size, wear, loot counts or stock state.

Verification: 232 native sizing checks passed across all seven body tiers; actual two-client small/large collection and stale confirmation passed. Fresh and baseline-save chest probes cover rejected legacy pickups, preservation of acquired T3 and looted holes, and reversible/idempotent migration. See assets/validation_4364/RESULTS.json for persistence and presentation evidence. These isolated checks do not constitute author acceptance.

## CA-KP-003 — Nested bow crop composition stalls on first presentation

Status/evidence: RESOLVED-VERIFIED in 4.36.2 (#8, fix commit `abdae0d`, PR #24).
Author acceptance: CA-4362-BOW-EMPTY-01 passed, explicitly confirmed on
2026-09-23 (America/Buenos_Aires), with no reported exceptions; see HISTORY.
Baseline: merged main `3b75054`.
Source: https://github.com/damiancurti/Caelum-Argenteum/issues/8

Native GZDoom g4.14.2 / Windows 11 / Vulkan / RTX 3070 Ti / development Doom II
reproduced a 10,442.647 ms inter-tick gap on first empty standard-bow presentation
and 5,210.706 ms when its loaded pose was first shown. Repeated equips were
responsive; the equip callback itself returned in 0.055 ms. The original
author's exact bow/tier remains unknown.

Cause: TEXTURES nested 167–173 row crops per tier through a full recolored
sheet. This is first-use resource work, not evidence of an infinite state loop.
The generator now writes six deterministic crop-only RGBA caches, retaining
native palette operations and the existing sprite declarations. No gameplay,
state table, save schema or original art changes. Do not reintroduce the nested
crop graph or hide the cost by delaying it to another gameplay action.

Evidence: [4.36.2 native results](../assets/validation_4362/RESULTS.json), adjacent
filtered logs and six native original/optimized captures; zero differing RGB
pixels on black, independently verified original crop/alpha equivalence, and
byte-identical repeated generation. HISTORY gives the cause/fix and scope.
Regression: cold and repeated empty/loaded equips for both bows, real one-arrow
reload/fire, arrow overlay visibility, aim and switch-away/back. Callback
automation does not replace physical-binding/normal-route author acceptance
or establish results on untested renderers.

## CA-KP-004 — Flail rotation must be judged around the rendered grip

Status/evidence: ENGINE-VERIFIED transform correction in 4.36.3 (#9).
Author acceptance: CA-4360I-VISUAL-01 (origin 4.36.0i) passed after the
4.36.3 correction, explicitly confirmed on 2026-09-23 (America/Buenos_Aires),
with no reported exceptions; see HISTORY.
Source: https://github.com/damiancurti/Caelum-Argenteum/issues/9

Baseline: merged 4.36.2 (`772f622`) used `handleAngle=rotation-39.5` in
`src/caelum/equipment/CaelumFirstPersonLayers.zs`. The author requested another
approximately 10 degrees counterclockwise. Native before/after captures verify
that increasing the offset to -29.5 produces this direction. The shared
`FLAIL_HANDLE_ANGLE` is the current source for both references; historical 0i
composition manifests and their generator output retain -39.5 as provenance.

Prevention: preserve the grip reference and connected layers. The handle still
hides half of its exposed shaft under the glove; the chain's position follows
the transformed joint, but its resting angle must not inherit the handle's
angle. Keep layer 46 behind handle 50 and hand 52. A plausible numeric sign or
a rotated screenshot is not proof of native screen-space direction.

Verification: GZDoom g4.14.2 / Windows 11 / Vulkan / RTX 3070 Ti / development
Doom II, fresh isolated MAP03 games. T1–T3 native before/after rest captures,
grip/joint checks, 45-degree attack increments through 360 degrees, return and
holster/re-equip passed with zero failures. The chain's 17.424612-degree native
rest offset stayed unchanged. [Evidence and conditions](../assets/validation_4363/RESULTS.json)
include filtered native logs; capture-only HUD suppression reveals the layers.
Automated native callbacks do not replace final author aesthetic approval or
prove untested renderers. No save field/state schema or combat timing changes.

## CA-KP-005 — A green validator or a built PK3 is not a gameplay pass

Status/evidence: CODE-VERIFIED tool scope. Baseline validate_project.py and build_dev.ps1.

Observation: Python checks selected project contracts; the builder packages source files and checks archive/PNG properties. Neither tool executes a normal player route or proves that ZScript compiles in GZDoom.

Prevention: report static validation, packaging, engine load, scenario behavior and author acceptance separately. Do not reuse an old engine success as evidence for a changed commit. State limitations of Linux/Freedoom fixtures and preserve target Windows verification.

Resolution: this is a workflow safeguard, not a bug awaiting a code fix. Each PR supplies the levels relevant to its change.

## CA-KP-006 — Planned state can drift between issues and canonical documents

Status/evidence: CODE/DOCUMENT-VERIFIED discrepancy plus explicit author clarification.

At the inspected PR #7 commit, its reward clarification still describes size-M prices with tiers pending. The author's later instruction and updated issues #10/#14 specify T1 and the recipient's equipment size. Local edited documents can be newer than their Git HEAD; they must not be cited as committed evidence.

Prevention: compare the exact commit and dirty-tree status, distinguish author-approved design from shipped implementation, and reconcile the current canonical sections during formal integration. Do not silently revert a later author decision because an older document says otherwise.

Acceptance: issue #22 reconciled the then-confirmed T1/recipient-size rule. The later #10/#14 author decision supersedes that reward formula with fixed 25 gold plus 10 own-faction reputation, implemented in future #14. Issue #10 reconciles current references and preserves the displaced formula in HISTORY. Historical fixed-M and price-average discussions remain historical.

## CA-KP-007 — New serialized event handlers are absent from older saves

Status/evidence: ENGINE-VERIFIED in 4.36.4 (#10), GZDoom g4.14.2.

Symptom/cause: a pre-4.36.4 MAP02 save restored its saved EventHandler list.
The new chest preview inventory correctly contained five real entries, but the
new map handler was absent (`open=1`, `count=5`, `handler=0`), so neither its
input nor its renderer was available. A fresh game did not expose the problem.

Fix/prevention: the stateless input/network controller is a StaticEventHandler,
independent of the saved map-handler list. Serializable preview state stays on
the recipient's inventory. Static render events precede map render events even
with a larger SetOrder value; draw the modal through the end of the existing HUD
instead, so bars and gameplay notices cannot cover its contents or actions.
Call EventHandler.SendNetworkEvent explicitly from the static controller.
Collection confirmation closes the modal so actual receipts/capacity notices are
visible before they expire; reopening reads the current remaining inventory.

Verification: the same old save, its migrated reload and five-entry 1024x768
native capture; fresh-save and hub-return probes. See validation_4364 evidence.
Author acceptance: CA-4364-T1-LOOT-01 passed on 2026-09-23. Preserve this separation when adding another
UI to an established save schema.

## CA-KP-008 — Changed map geometry prevents old saves from loading

Status/evidence: ENGINE-VERIFIED in 4.36.5 (#11), GZDoom g4.14.2.
Baseline: integrated 4.36.4, `3f3fa0c`; implementation evidence uses the #11
working tree. Author acceptance: PENDING, CA-4365-MAZE-01.

GZDoom checks saved map geometry counts and checksum before restoring ZScript
objects (`p_saveg.cpp`, geometry validation). An inventory revision or a
WorldLoaded migration cannot repair that earlier rejection. A hub save on a
different active map can still contain the old MAP02 snapshot; testing only
fresh games or the active map misses this dependency.

Keep the original WAD and its provenance. The explicit `build_dev.ps1
-LegacyMap02` / `run_dev.bat --legacy-map02` mode packages that exact MAP02
under the established package name, with current code and unchanged map IDs.
The builder verifies SHA-256 before replacing its output. Current runtime
coordinates branch on the new layout marker, so restored old geometry keeps
its original travel/furniture positions. Compatibility is continuation of
the old layout, not conversion to the new layout or permission to reset saves.

Native regression: load a pre-patch save inside MAP02 and another in MAP03
with a saved MAP02 hub, return, and compare keys, chest ownership, identity,
size, wear and position. Both pass (49 and 48 checks respectively). Builder
verification also rejects missing/wrong legacy data without replacing the
previous package. See [validation evidence](../assets/validation_4365/RESULTS.json).
Keep compatibility mode for that campaign; normal builds provide the rebuilt
map for new campaigns. No external save rewriting is required.

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
