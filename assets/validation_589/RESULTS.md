# 5.8.9 / #502 - Severe contamination

The C90 boundary doubles existing disease damage and displays Sick. Toughness
100+ remains immune without healing; depuration below 90 removes the multiplier.
Native current-Life and forecast comparisons use the same production damage.
Wait cache revision 7 invalidates old forecasts, while original illness values
and fractional damage are preserved. No new map or body illness schema is needed.

92 native PASS in nine selected runs. Only individual PASS lines are counted, not persistent RESULT counters.

| Run | PASS |
| --- | ---: |
| rules-01 | 34 |
| runtime-01 | 23 |
| save-01 | 1 |
| load-01 | 2 |
| hub-01 | 6 |
| legacy-seed01 | 1 |
| legacy-bridge01 | 1 |
| legacy-rollback01 | 1 |
| final-runtime02 | 23 |

Windows 11, GZDoom 4.14.2, Ryzen 9 5950X, RTX 3070 Ti, Vulkan 1280x720;
unpaused in the background, audio 5%. Final-runtime01 recompiles and executes
the final package after incorporating the isolated #411 tent correction.
Earlier checks test the identical #502 source on the original camp base.
Original saves load forward and roll back with their original package/addon.
Private IWAD, addon PK3 and saves are not distributed.

All 16,859 final package members match src byte-for-byte. Hashes and commands are retained in report.json and native/.

The contact integral, environment index and water/soap quotes are pure rules
only. They do not yet expose actors/equipment or perform resource transactions.
No whole-map scan is introduced. No FPS claim is made by these functional tests.
CA502-SEVERE-01 is pending; use author_terminal.ps1 for the independent private
room. This evidence does not accept the unfinished hygiene/contact scope.
