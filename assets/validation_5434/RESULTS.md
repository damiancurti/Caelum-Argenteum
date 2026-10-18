# 5.4.34 / #324 - Five active minutes since the latest autosave

The author clarified on 2026-10-18 that the timer starts after the latest
autosave, including map transitions; those arrival saves must remain. Native
file creation and slot rotation still follow the user's settings. Manual saves
do not restart the timer. Author acceptance CA324-01 is pending.

## Implementation and boundaries

CaelumAutosaveEvents measures monotonic real milliseconds in UI scope, excluding
pause, menus, console, loading and dead/uninitialized play. Accelerated calendar
ticks do not advance this clock. New games and save loads start fresh intervals;
travel without an enabled arrival save retains accumulated active time. One due
request waits for a valid body/map, without accumulating missed intervals.

Rulo's prepared encounter and native arrivals use the same request owner.
CHECK and DO are asynchronous native network stages. Ordered acknowledgements
track both; PostUiTick observes the final native action after commands and
simulation. Its following network message runs after the write action, including
while paused. ChangeLevel's immediate WorldUnloaded notification distinguishes
a cancelled pending action from a save already written before a later journey.
Logical request serials preserve a new invalid-body checkpoint that arrives
after a previous file but before its acknowledgement. No character schema or
saved-actor migration is added.

The native arrival Autosaver has no ZScript type. One STAT_DEFAULT traversal per
map arrival adopts its request, respecting disableautosave=1; that statistic can
contain actors. There is no recurring global census. Requests destined for the
same new map coalesce. A completed old-map checkpoint and the subsequent arrival
remain two legitimate saves. Native DO retains the engine's behavior after
eligibility, including death before the eventual write.

An acknowledgement proves action dispatch/execution, not successful disk IO.
Actual rotating files, hashes, map identities and successful reloads provide
separate evidence. Disk-full/failure behavior and multiplayer are not validated.

## Reproduction

Use prepare.py --directory issue324-<fresh-name> to freeze runtime and fixtures.
Run run_matrix.py with that directory in three sequential phases: --regressions,
the default core phase with --legacy-save pointing to the #323 before.zds local
fixture, then --long. One engine runs at a time with background simulation and
5% audio, GZDoom 4.14.2 / Vulkan / 1280x720. The full interval is not shortened;
short timer/preview fixtures explicitly seed the remaining interval.

archive.py requires every final case, zero native failures and successful exits,
then verifies every normal-package member against the frozen runtime and source.
It preserves compressed raw logs, exact scripts, launch metadata and source
snapshots. Packages, IWADs, engines and private saves stay local. Runtime/fixture
hashes and individual save hashes/maps are recorded in evidence.json and the
final directory's files.json. Functional runs are not FPS measurements.

## Final verification

The final frozen runtime passes 36 runs and 138 assertions, with zero assertion
failures and all processes exiting successfully. The full observation lasts
320.043685 seconds and produces one periodic autosave; its reload preserves all
four recorded state categories. The normal build and all 16,373 source/package
members match. Project validation and independent review pass. Author acceptance
remains pending, separate from the automated/native results.

The seven final ordering regressions pass 25 assertions with expected native
file counts: direct travel, paused external save with a pending request, cancelled
travel with arrival disabled, completed old-map save with arrival disabled,
travel ahead of the write acknowledgement, a later invalid-body checkpoint,
and consecutive external autosaves. The core suite also passes pause/menu/console
timing, actual accelerated rest (2,080 extra personal tics without a save burst),
disabled autosaves/zero slots, repeated one-slot saves, two-slot rotation with an
unchanged manual-save hash, fresh and same-process reloads, both hub directions,
checkpoint/arrival separation at five scheduling offsets, real Rulo preparation
and its loaded party/grace, and a #323 prior-runtime save.

Earlier fixtures are retained as development evidence, not final passes. Fast
rest originally used an unsupported 30-minute duration and a conversation closed
with Menu.Close, which left its gameplay flag active. Use the supported 60-minute
duration and ConversationMenu.MenuEvent(Back). A fixture variable named native
was reserved; the subsequent typed Autosaver iterator also failed compilation.
Initial queue versions duplicated destination files or reset a cancelled request.
One delay-2 fixture expected one request although the native file count correctly
remained one after cancellation and retry. Failed logs and exact snapshots remain
available; successful request assertions alone were never treated as IO proof.
