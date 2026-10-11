# Issue #185 — 5.2.5 validation

Validated on 2026-10-11 against the completed #183 commit `0894d41d`
([PR186](https://github.com/damiancurti/Caelum-Argenteum/pull/186)). This focused
source-organization patch changes no dialogue content, conditions or gameplay.
CA183-01 remains pending author gameplay acceptance.

## Source and index checks

`python assets/validation_525/check.py`: **19 checks, zero failures**.

- All 20,945 non-comment USDF tokens match the baseline in exactly the same order:
  53 conversations, 422 pages, 19 authoritative NPC/shared files.
- Original source is preserved in `archive/dialogues/5.2.4-CAPALOMO.usdf`.
  LANGUAGE content is unchanged apart from LF normalization.
- All 2,369 localization keys have exact source ranges. The index covers shared
  UI/system text as well as dialogue, including English `default` fallback.
- Generation is deterministic; committed runtime/index files match it.
- Native IDs, named page references and English/Spanish dialogue keys resolve.
  History generation retains the existing reviewed catalogue and verifies its
  key/page references coexist in the appropriate conversation.
- Negative cases reject edited source/localization without regeneration, stale
  runtime, duplicate IDs, missing keys/pages, wrong MAPINFO entry point, broken
  history references and an unlisted NPC source. Comments containing syntax and
  legal identifier case do not change the compiled dialogue.

The main source manifest is `src/dialogues/index.json`; edit the NPC/shared
files it references, then regenerate with `python build_dialogue_index.py build`.
`check`, `npc`, `find` and `read` refuse stale indexes. Project validation and
`build_dev.ps1` apply the same check before packaging.

Delivery gates pass: `validate_project.py` reports version 5.2.5 and zero errors;
the document index is current; `build_dev.ps1` produces a package containing
6,342 files; diff whitespace checks pass.

## Native GZDoom 4.14.2

| Runs | Result |
| --- | --- |
| `map01-es-final`, `map01-en-final` | All 53 conversation IDs resolve; native conversations open for Palomo, Argento, Rulo, Ronnie and Caella. Screenshots show both languages. |
| `map02-es-final`, `map02-en-final` | All 53 IDs resolve on MAP02; all four prisoners open their native conversations in both languages. |
| `reload-524-final` | The #183 MAP02 save loads in the new runtime; all four existing fixture checks pass for crafted item identity, water, boxed ammunition/Fool and depleted chests. |
| `compatibility-final` | The inactive CAPALOMO compatibility alias loads the same runtime via native full-path `include`; all 53 IDs and five resident conversation openings pass. |

Every run reaches its completion marker with zero assertion failures or native
script errors. The first `map01-es-01` run also passed and is preserved. Logs and
package/engine hashes are in `logs/`, `runs.json` and `manifest.json`. Earlier
MAP01 and final MAP02 packages differ only by source comments and the compact
formatting of the generated localization index. Runtime dialogue tokens and
localized text are unchanged across all of these packages.

Fixtures invoke native conversation assignment/opening and use controlled
positions/progress so the affected UI can be inspected. They do not complete
the entire tutorial or prove every dialogue branch by human interaction. Static
token/order equivalence covers preservation of the unchanged branches.
Engine runs remain unpaused in the background at 5% audio; local engine, IWAD,
PK3 and save files are excluded from the delivery.

## Loading decision and reproduction

GZDoom 4.14.2 supports both full-path AddDialogues and USDF `include`, verified
in the native runs and upstream `src/maploader/strifedialogue.cpp` /
`src/maploader/usdf.cpp` at tag `g4.14.2`. Direct per-NPC includes would group
interleaved conversations differently and shift global node offsets. Ordered
assembly retains the existing offsets; MAPINFO loads `dialogues/runtime.usdf`
exactly once. The small root CAPALOMO file is an inactive compatibility alias.

Run `python assets/validation_525/prepare.py` and `run_native.ps1` with a unique
label, `-Fixture native`, `-Script map01.cfg` or `map02.cfg`, matching `-Map`
and `-Language es` or `enu`. Supply local engine/IWAD paths if needed.
For the compatibility run add `-RuntimeAlias compatibility.pk3`.

For the reload check, first reproduce the #183 journey as documented in
validation_524, then copy its local `ca183-journey.zds` into `build/issue185`.
Use `-Fixture journey -Script reload.cfg -LoadGame ca183-journey.zds`.
The preparer reuses the committed #183 fixture source; saves are not published.
`archive.py` preserves logs and metadata. `check.py` retains its negative cases
under `build/issue185/check-cases` without changing production sources.
