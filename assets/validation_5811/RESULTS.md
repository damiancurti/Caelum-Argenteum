# Domestic bathrooms — #410 /5.8.11

The160 existing house interiors now install one sink, bathtub and toilet each.
Sink and bathtub share a saved200-L potable household reserve; different houses
remain independent. Refill is1L/world-minute, evaluated lazily across absence.
Use shows available water; collect into the selected inventory container while
facing the fixture. Capacity, carried weight, Box placement, boiling locks,
contamination mixing and residence permission retain their existing guards.

Revision1 state and a transient load check install missing fixtures in old saves
without resetting water or duplicating objects. All169 map files, including160
houses, remain byte-identical. Static validation and repeated art generation
pass;220 executed native checks cover selected houses, shared/partial collection,
blocked placement, save/hub, old-save migration and rollback. Final package has
16,884 source-matched members; evidence: assets/validation_5811.

CA410-BATH-01 passed author review on 2026-10-25 without qualifications. The toilet is installed visually; its
metabolic action, soap bathing and resident cleaning remain#502. Mansion kitchen,
remaining furniture/crafting and food integration remain unfinished#410 work.
V5.8 is not complete.

Acceptance-only documentation update: the originating 5.8.11 / #410 check
was confirmed on 2026-10-25 and removed from pending_test.txt. Runtime, art
and the final07 package are unchanged; previous native evidence still applies.
Inherited CA502-TREATMENT-01 remains pending.

Reproduction: prepare.py; run_native.ps1 with the label/runtime/scripts in report.json.
verify.py requires Pillow and the retained final07/baseline packages; it verifies
all source bytes, unchanged maps, repeated generation and project validation.
Generated packages, engine/IWAD and saves stay under ignored build/. Native
record JSON captures commands, configuration, hashes and hardware. Failed probes
remain alongside corrected logs. Pass counts are executed lines rather than
cumulative summaries. The final03→final07 code differs only in diagnostic release
labels and line endings; art/notice changes have their own captures. No frame-time
or campaign-wide performance claim follows from these functional checks.
