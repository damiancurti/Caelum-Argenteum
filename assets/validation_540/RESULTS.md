# 5.4.0 / #237 - Attribute source-to-consumer audit

Baseline: accepted main `5208cc921b9a80244164c8fc0a5afef16b58045a` (5.3.9).
The author confirmed the new batch starts at 5.4.0. This patch changes documentation
and isolated audit fixtures; two console release labels advance to 5.4.0 as
required by validation. No gameplay logic, balance, input or save schema changes.

## Focused native evidence

Windows 11, GZDoom 4.14.2, Vulkan, isolated configuration, background simulation
unpaused, master audio 5%. Final-source `release-01` passed **160 assertions**, engine exit 0,
without script/VM errors. Production archive SHA-256:
`36b2465ff773f48a2aa1851c202fc34f073d1b355993a0ac2639fa3dfcdd1cac`.
Fixture SHA-256:
`a6165ebbf8aa94984b1dd04e6bf0276fe127a6684380eb2aecdd126bbd1989a7`.

The fixture exercises the actual ZScript curve/derived-stat services at effective
levels 0, 100, 150 and 25.5, all twelve derived rows, physical/magical Toughness
and signed status response, current Box capacity, representative NPC precision/
critical/cost consumers, and the player's real attribute rebuild. The latter uses
T3 light armor, a T1 Seal, all 78 Tarot cards, repeated rebuild, removal and a
personality change. It proves additive equipment/minors precede collection scaling
and no permanent multiplication survives removal. It does not infer a playable
buff from a stored Empathy field, or prove all weapon/faction/input combinations.

The first run `audit-01` passed 158/160. Two removal expectations failed because
the fixture called the intentionally idempotent `ArmorModel.InitializeDefaults`
on an already initialized model. The fixture now uses a fresh base-clothing model.
No production code was changed. Both original packages/logs remain locally under
`build/issue237` and the corrected run under `build/issue237-final`. `audit-02`
passed 160/160 on unchanged 5.3.9 gameplay; `release-01` repeated that focused
matrix after updating the two required console release labels and passed 160/160.
The final run is preserved under `build/issue237-release`; no earlier evidence
was deleted or overwritten. `evidence.json` records hashes and exact commands.

## Source review and inherited acceptance

SYSTEMS owns the source-to-consumer matrix, formulas/units, player/NPC ownership,
caps and explicit design gaps. Inspection corrected two overbroad descriptions:
visual concealment is a diagnostic observer while movement noise calls native
SoundAlert; Charisma payload strength belongs to the attacker, with incomplete
receiver coverage. Empathy's illumination timer has no gameplay lighting consumer.
Player/NPC critical-clamp and equipment-path differences are reported, not changed.

Reuse accepted evidence only for its scope: #154 curves/physics (not its obsolete
Box/Toughness checks), #188 actual defense/status/persistence, #192 personality
and projectile receivers, #183 Box capacity, #229 tare/load and #256 actual critical
display/consumer queries. This audit does not rerun their campaigns or reopen
their author acceptance. No new manual author-input check is needed for unchanged
gameplay; `pending_test.txt` remains empty. New abilities remain separate issues.

## Static validation and packaging

`python build_document_index.py` regenerated the maintained locator.
`python validate_project.py` passed with `errors: []` and 2,498 CONTEXT words.
Normal `build_dev.ps1` packaging passed with 16,072 files and no directory entries.
All normal package members match the final native-tested production archive.
`git diff --check` passed. No unrelated local files were staged or removed.

## Reproduction

From the repository root, use a fresh directory to preserve existing evidence:

```powershell
python assets/validation_540/prepare.py --directory issue237-recheck
powershell -NoProfile -ExecutionPolicy Bypass -File assets/validation_540/run_native.ps1 -Directory issue237-recheck -Label audit-recheck
python build_document_index.py
python validate_project.py
powershell -NoProfile -ExecutionPolicy Bypass -File build_dev.ps1
```

The engine and development IWAD paths are configurable launcher arguments.
Packages, saves, logs, engine and IWAD are not distributed with this patch.

## Completion refresh on 5.4.21 - 2026-10-15

The accepted ability baseline bde4cd96 now supplies real social-attribute
consumers. SYSTEMS records their source/receiver paths, full-factor scaling,
fixed class preparation/reuse and continuous racial costs. Future academic,
production perception, broader Patience/needs and optional player/NPC parity
remain explicit design work; no missing effect is inferred from a stored field.

The original fixture was rerun against the current source in
build/issue237-completion-5421: 160 assertions passed, zero failures, native exit0.
completion_evidence.json records package/fixture/log hashes and source parity.
Per-ability native tests and explicit author acceptance are reused for their
unchanged scope and are not relabeled as reruns of the entire batch. This audit
changes documentation only, so there is no new manual author check. The current
release stays 5.4.21; the originating audit remains 5.4.0 / #237.

PR272 completion diff targets integration/v54-accepted-252. Original audit work
remains in its historical commits; the integration baseline already contains it.
No merge or closure is requested. Static validation, normal packaging and all
16,178 source members match the current tested archive.
