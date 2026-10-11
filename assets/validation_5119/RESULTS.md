# #172 — NPC information history (5.1.19)

Agent checks on GZDoom 4.14.2 / Windows 11; CA172-01 remains author-pending.
73 passing assertion records; zero failures in the retained runs. See summary.json.
Seven static checks pass; project validator reports zero errors, and the standard
build matches the tested package member for member.

Native tests use actual conversation menus, networked reply selection and native
save/load. Travel, selected conversation IDs and the test guard are fixture
setup; this is not a complete campaign playthrough. Audio 5%, hidden/unpaused.

The Palomo flow reads an answer, returns, checks hidden information and retained
actions, replays without a Box grant or duplicate record, closes/reopens, and
selects a paginated action by its original reply index. A real save reload retains
history, then opens the guard's conversation to verify shared behavior and
speaker isolation. A save produced with baseline 4248dfce migrates from absent
history fields and repeats the flow without resetting the character. Spanish
16:9 and English 4:3 captures are inspected for complete options and labels.

Complete passing logs and per-run hashes accompany this report. Earlier test
setup corrections (BOM in console cfg, prologue timing, one-based versus native
zero-based fixture index) were rerun; only passing runs are retained as evidence.
The production compiler caught reserved identifier/cast syntax during development;
those were corrected before the passing gameplay runs.

Static checks cover unchanged native USDF, every menu's shared inheritance,
unique catalogue keys and bilingual answer references, deterministic generation,
package/source identity, and the standard project validator/build. New saves
store stable strings, not generated catalogue indices. Earlier saves retain
native quest exclusions and start with empty new history.

Reproduce with `python assets/validation_5119/prepare.py` and run_native.ps1,
using unique Labels. Flow: `-Fixture flow -Script flow.cfg -Language es` (or enu).
Reload: add `-LoadGame dialogue-history.zds -Script reload.cfg`.
Legacy: `-Baseline -Fixture compile -Script legacy.cfg`, then
`-Fixture migration-runtime/compile -RuntimeAlias migration-runtime/baseline.pk3
-LoadGame legacy-before-history.zds -Script flow.cfg`.
Engine, IWAD, PK3 and native saves are development dependencies, not distributed.

Final whitespace cleanup was followed by flow-final (21 passes) and a rebuilt
package/static verification. Older retained runs differ only in final blank lines.
