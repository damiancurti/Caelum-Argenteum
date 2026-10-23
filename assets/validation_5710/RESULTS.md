# Cartridge station migration — issue #471

Version 5.7.10 moves only the two existing kit-to-cartridge recipes to Workbench
+ Alchemy. No ingredient quantities, new recipes, economy, art or firearm behavior
are changed. The independent #409 draft remains incomplete for glass cooling.
All 186 native assertions pass; final source/package identity and static project
validation pass. The two UI captures were inspected by the agent.

`report.json` ties every native run to its production-package and fixture hashes.
The collector verifies every packaged file against src and deterministic fixture
generation. Static validation and native evidence are separate from outstanding
author acceptance (CA471-AMMO-01). Tests use GZDoom 4.14.2 on the recorded Windows
11/RTX 3070 Ti environment, sequentially, unpaused, with audio at 5%.

Coverage reuses the accepted #380 native cartridge tests with only the station
and current recipe-book expectation adapted: both kits, all efficiencies,
weights, exact input/output counts, learning, capacity, pause/cancel/retry and
unchanged arrow/bolt assembly. Focused checks reject ranged-only cartridge starts,
require a Workbench, pause on loss of Alchemy after the existing network refresh,
and verify ordinary ticking completes the task. Two rendered UI captures compare
available Alchemy with disabled crafting and its infrastructure warning at a
ranged-only network.

An actual full 5.7.9 package creates the original paused task/save. The new runtime
migrates it once, preserves kits/knowledge/progress, saves and reloads it, then
finishes the old task at Ranged Workshop without allowing a new task there. A
native map transition checks the travelling record. A new Alchemy task is also
saved/reloaded/completed. Original-runtime rollback uses the untouched original
save. No schema revision resets recipe knowledge, quantities or elapsed work.

Failed/incomplete harness attempts remain under `diagnostics/`: station01 assumed
immediate station invalidation instead of the existing one-second refresh;
travel01 entered the fixture's ordinary intermission and never reached the
destination. The corrected check explicitly verifies the destination after a
native no-intermission transition. These corrections changed only private
fixtures; all production checks use one unchanged complete package.

Reproduction: `python assets/validation_5710/prepare.py`, rebuild the full package
to `build/issue471-ammo/current/caelum_argenteum_dev.pk3`, then run the native
launcher with distinct labels and scripts from prepare.py. Preserve the original
5.7.9 package/save for the baseline/upgrade/rollback sequence. The fixture uses
the CA380 assertion prefix because it extends the accepted suite; logs belong
only to this #471 stage. Test PK3s, IWAD and executables are not distributed.

Author launch: open `launch_author.ps1` with PowerShell `-NoExit -File`. It waits
for Enter before starting the scene. F2 switches the station so the author can
compare the two network requirements. Questions and author tests are deferred
until the author returns; no manual acceptance is inferred from these runs.
