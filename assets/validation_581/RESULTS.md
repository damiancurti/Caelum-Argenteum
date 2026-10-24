# #413 / 5.8.1 - Altitude validation

The approved altitude/Air implementation passes **67 native assertions** in five
focused runs: the 47-assertion behavior suite, four pre-feature migration checks,
two saved player/NPC seed checks, four reload checks and ten hub checks. Two
baseline controls confirm creation and rollback of the preserved original save.
Static validation passes. All **16,809** final PK3 entries equal src byte for byte.
**CA413-01 passed author acceptance on 2026-10-23**, without qualifications.
The author confirmed the handed-off altitude/adaptation/race/save check. This
does not accept #414, establish presentation/FPS results or complete V5.8.

## Scope and source identity

Base: #414 feasibility commit d89e34156fc7f4fbe233845c6fe1738d5690ea4d.
The delivery also includes #414's later documentation-only calibration commit
f2806180 as its parent; this rebase changes no tested runtime entry.
Runtime: GZDoom 4.14.2, Windows 11 build 26200, Ryzen 9 5950X / RTX 3070 Ti,
1280x720 Vulkan, 60 FPS cap, background simulation/rendering enabled and 5%
master volume. Per-run configuration, hashes and environment are in native/.
Final package SHA256: `68620122293cbc7b37cfcfc1486692750fe74fafc9007ea3838e69d59c46986d`.

Core tests cover normalized pressure at 0/2,000/4,000 m; physical height plus
geographical datum; Caelith and reference races; linear acquisition, cap, descent
and Resilience; player/NPC affordability, expenditure and recovery; underwater
recovery debt and Anima substitution; independent forecasts, actual accelerated
personal time, accepted-travel commit, repeated stamps and stopped clocks.
Revision-1 state starts without retroactive exposure in a real baseline save.
Player and NPC adaptation survive native save/reload and an unloaded hub interval.
The original save is retained and loads with its original baseline runtime.

Migration/save/hub evidence preceded only a correction to Spanish source
comments. The final full rebuild passed the complete 47-assertion suite again;
all final timing runs use that final rebuild. The exact runtime hashes distinguish
these cases in report.json. No runtime change is hidden by reusing earlier checks.

## Performance evidence and limits

Eight matched, ten-second measurement windows compare the previous/current
runtime at fixed cameras. The city probe adds 600 peaceful native defenders;
its authoritative census reports **601 living combatants and high_density=1**,
including offscreen bodies. The mansion has six and the sewer 294. No retired
6,000-attacker case was used, and no population/gameplay rule was changed.

These are UI render-callback intervals in milliseconds, **not presentation or
GPU measurements**. Windows denied PresentMon's ETW session; preserve its error
and command records. Means are close under the cap, with mixed tail changes;
this short comparison does not establish whole-map, siege or author FPS acceptance.

| Scene/runtime | Living | Mean ms | p95 ms | p99 ms | Worst ms |
| --- | ---: | ---: | ---: | ---: | ---: |
| baseline-city600-02 | 601 | 16.669 | 18.357 | 19.833 | 20.783 |
| current-city600-02 | 601 | 16.667 | 17.597 | 19.029 | 22.305 |
| baseline-city600-down | 601 | 16.681 | 17.999 | 19.792 | 25.573 |
| current-city600-down | 601 | 16.758 | 18.710 | 19.926 | 22.577 |
| baseline-mansion | 6 | 16.736 | 18.852 | 20.153 | 27.759 |
| current-mansion | 6 | 16.691 | 19.200 | 20.847 | 21.772 |
| baseline-sewer | 294 | 16.666 | 17.182 | 17.651 | 18.763 |
| current-sewer | 294 | 16.665 | 17.650 | 18.277 | 19.282 |

Simulation remained approximately 35 tics/s; exact values are in report.json.
The altitude service introduces no actor census. It reuses the existing typed
one-map-marker initialization lookup and shared clock, samples pressure only
when height changes and caches racial/attribute data between scheduled samples.
The accepted >=500 population policy and unrelated subsystem scans remain intact.

## Failed experiments and corrections

Diagnostics retain reserved-name/unsupported-power-function compile failures,
the UDMF +/-32,768-coordinate bound, a case-insensitive local/field shadowing
mistake in the first forecast adapter, and fixture expectations corrected to
match the current climate curve and racial activation cycle. High elevations use
an authored geographical datum instead of out-of-range physical coordinates.

The genuine old save exposed absence of the newly registered map handler. The
final implementation reuses the existing WorldClockTicker and saved physics
marker with an independent altitude revision. The incremental compile updater
then left a reverted MAPINFO entry stale, causing the author's reported
`CaelumAltitudeWorld is not derived from StaticEventHandler` fatal. The full
rebuild removed it and final old-save loading passed. See
[author report](author-reported-error.txt) and CA-KP-007/107. The compile updater
now retains previously touched paths; complete packaging/byte comparison remains
the delivery gate. Test-only addon filenames must also match native save headers.

## Reproduction and author check

1. Run `python assets/validation_581/prepare.py`.
2. Build with `powershell.exe -NoProfile -ExecutionPolicy Bypass -File build_dev.ps1
   -Destination build/issue413/current/caelum_argenteum_dev.pk3`.
3. Use `assets/validation_581/run_native.ps1 -Label a-unique-label -Checks -Script suite`
   in a PowerShell process with its normal per-process execution-policy bypass.
4. For author review run `assets/validation_581/author_terminal.ps1`; follow
   the accepted CA413-01 controls printed by the script. The visible terminal
   stays open; the confirmation is recorded in docs/HISTORY.md.

Never overlap native runs or replace a package in use. Baseline migration needs
the exact base package and private legacy fixture; original saves remain private.
Generators are deterministic. No engine, IWAD, generated PK3 or save is committed.
The private room references existing project textures and adds no artwork.
