# Fermentation Barrel — #487 / 5.7.12

Infrastructure scope: a fixed wooden barrel with metal hoops at the two approved
workshops, requiring the existing Workbench/Chemistry network. The model, fallback
sprite and capacity share a deterministic source. Interior volume is approximately
4,252.967 L; the approved 20% headspace leaves 3,402 whole usable litres. This is
a large tun scaled using the project's 32 units/metre, not a 200 L cask.

New fermentation batches, their unattended world-time storage and recipes remain
#471. This patch does not claim those pending processes are implemented. Heating
and distillation belong to Chemistry; fermentation will be anchored to the barrel.

Project validation and source/package identity pass for all 16,728 entries.
The completed package passes 93 native assertions: real Use, transitive network,
missing/remote/different-group Chemistry, live disconnection, both placements,
old-save installation, repeated reload, obstacle retries, removal persistence and
real forward-input collision. The original save remains byte-identical and passes
one additional Use assertion after rollback to its original 5.7.10 runtime.
Six final native captures and the generated sprite were inspected. Exact package,
engine and fixture hashes, environment and launch commands are in report.json
and native/. Native runs are unpaused at 5% audio; no rendering-performance
claim is made from these functional checks.

Two deterministic generator runs agree. The 1,458-face mesh stays inside its
approved collision bounds, with only native-compatible triangles/quads. Independent
numerical integration gives 4,252.967366663 L versus the analytic 4,252.967366561 L.
Both produce 3,402 whole usable litres. The new barrel explicitly sets SOLID;
the inherited station base did not, and existing station flags remain unchanged.

An initial collision-input script quit before the queued assertion event could
run. collision03 adds the required final wait and passes two assertions; the
incomplete collision02 probe is retained and excluded from the total. No production
workaround was introduced for that test-script issue.

CA487-01 remains pending; author checks are deferred while away. It covers this
finished infrastructure and its visuals separately from #471 recipes/batches.

Tracked log text normalizes line endings and trailing whitespace. Raw logs stay
in build/issue487 (rollback: build/issue486 in its worktree); messages are retained.
