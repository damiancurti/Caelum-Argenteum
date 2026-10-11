# 5.2.2 / #178 time-skip performance

Baseline: 6c2b7895 (#177/PR179). Windows 11, GZDoom 4.14.2, Vulkan,
no autoload, isolated native saves/configs, RNG178, 5% master volume, unpaused
background execution. The author's unrelated game was left running; these are
same-session measurements, not a hardware-wide performance guarantee.

## Measured long task

The fixture starts the actual XL shotgun recipe for the maximum 200 kg body,
including its full 281,990.224339-second work requirement. Its read-only forecast
is followed by real per-tic task execution, digestion, thermal and sleep logic.
The runner timestamps phase markers as they reach the log (10 ms polling) and
stops only its own process after the completion marker. Thus reported phases
exclude startup and scripted idle waits. Recorded process termination after a
successful marker is intentional, not a native crash.

| Run | Forecast | Live execution | Combined |
| --- | ---: | ---: | ---: |
| base-01: original budgets/network scans | 13.339 s | 172.138 s | 185.478 s |
| fast-02: delivered 8,192 / 262,144 budgets | 1.944 s | 113.934 s | 115.878 s |

The forecast is 6.86 times faster; live execution takes 33.8% less time, and
combined processing takes 37.5% less time. The experiment fast-01 with 32,768
live tics took 110.544 s live. The delivered 8,192 limit returns control four
times more frequently for a small measured runtime difference. No strict
millisecond input-latency claim is made.

Both baseline and delivered runs forecast exactly 15,318,259 personal tics,
168 food portions and 127 water servings. Both finish real crafting, autoequip
the same recipe output, and log final hunger 97.456322/thirst 91.232969. Work
counters differ by normal crafting tics elapsed while forecasting (the old
forecast takes longer); no recipe duration or portion size was reduced.

## Correctness checks

- guards-02: 8,192 personal tics use exactly one native network scan. Cancel
  preserves the precise performed work. Reopening and changing required
  capabilities between batches stops before another personal tic.
- siege-01: MAP06 stops exactly 64 tics later at the scheduled siege stamp,
  does not overshoot, blocks restarting and deploys the ordinary 6,001 attackers
  plus 600 defenders. This uses the established #173 native fixture.
- save-old-02 / save-load-02: an active native skip saved with the baseline
  retains its real task/station, continues work under the new runtime, rebuilds
  the network and can be cancelled without discarding the unfinished task.
- #177's finite MAP02 table/chest checks and full provision transaction remain
  unchanged. No inventory/clock/survival implementation or save schema changes
  are introduced by #178. Ordinary crafting does not use the batch reuse path.

No engine, IWAD, generated package or save is committed. Original log hashes,
native arguments, phase marks and package hashes are in runs.json; logs are
whitespace-normalized. prepare.py and run_native.ps1 reproduce the fixtures.
static.json records final validator/build results and package-member comparison.

CA178-01 remains pending author acceptance, independently of CA147-01 and
CA177-01. Physical keyboard responsiveness and full player-route acceptance
are not inferred from scripted cancellation checks.

Fixture correction: save-old-01 quit before the queued native save reached disk;
save-load-01 therefore correctly failed to find it. Extending the post-save wait
produced the actual saved file and passing save-load-02; both logs are retained.
