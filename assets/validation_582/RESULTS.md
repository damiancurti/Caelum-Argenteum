# #414 / 5.8.2 - Connected mansion water

The approved mansion installation is implemented. **171 native assertions in
11 focused runs pass**, including repeated numerical partitions; this is not
171 distinct gameplay behaviors. **CA414-01 passed all author terminal checks
on 2026-10-24**, without qualifications. The earlier isolated
**CA414-PROTOTYPE-01** remains pending. No merge or completed V5.8 is claimed.

## Identity and coverage

Base: accepted altitude branch commit bc668677. GZDoom 4.14.2, Windows 11 build
26200, Ryzen 9 5950X / RTX 3070 Ti, Vulkan 1280x720, 60 FPS cap, 5% audio,
unpaused background simulation/rendering. Run configurations and logs are in
[native](native); package identities and assertion counts are in [report.json](report.json).
Both full builds have 16,812 entries, verified byte for byte against source.
The compatibility build substitutes only the preserved old MAP01.

- Current SHA256: b4f366652fe71f8131b21baf71fe54518e39162638ef5b25e7425df805ee5b31.
- Compatibility SHA256: 35e7a5926b16fc4d0d78fb084188e9e32bfd42e3c050d33c445059419e32e144.
- Old MAP01 SHA256: 866a25a3adad62a742f3a1e65fa9c029852450b99e372b63caf57321b15f408a.

| Run | PASS | Scope |
| --- | ---: | --- |
| final-numeric-01 | 81 | Analytic Torricelli reference, conservation, partitioned intervals, bounded catch-up, partial opening, contamination direction, withdrawals |
| final-world-01 | 27 | Saved controller, real calendar/planes, gate aim/hint, immersion, finite bottle/direct hydration, full/boxed guards |
| final-mansion-03 | 11 | Final campaign map, room catalogue, initial heights, reachable gate, native gate planes, both service paths, original pool |
| save-01 / load-01 / hub-01 | 7 / 5 / 16 | Closed-state save/load, independent hub installation and return |
| final-flow-save-01 / final-flow-load-01 / final-flow-hub-01 | 7 / 4 / 8 | Open-state save/load, unloaded hour versus independent numerical reference, contamination |
| final-compat-active-02 / final-compat-hub-02 | 2 / 3 | Real old active-map/hub saves with current compatibility code, original geometry and room discovery |

The original runtime separately creates two old saves (legacy-save-01) and
restores them (final-rollback-active-03, rollback-hub-02). Private originals
remain unchanged for rollback; no saves, packages, engine or IWAD are distributed.

Numeric/world/persistence checks precede only the final lever facing and
cartography compatibility correction. Their affected hydraulic runtime bytes
are unchanged. The final full builds rerun mansion and old-save compatibility;
each run records its actual package hash. Final room discovery accepts both
reviewed checksums; existing room bounds/IDs are unchanged. Map reconstruction
is byte-identical and preserves original geometry records except added sector
zero metadata. Geometry source/report: assets/map01_mansion/CONNECTED_WATER.json.

Native step checks query TryMove along both stairs and raise the diagnostic
pawn to its reported floor. They establish collision clearance; actual walking,
appearance and usability were separately accepted by the author under CA414-01. [Final view](mansion-water.png)
shows the reused lever face and both basins. No new artwork was generated.

## Performance and scan review

Two matched ten-second windows use the peaceful mansion at the same exterior
camera. Current opens the new gate; baseline has no installation. These are
UI render-callback intervals, **not frame presentation or GPU measurements**.
PresentMon ETW was denied; errors and commands are retained.

| Runtime | Samples | Mean ms | p95 ms | p99 ms | Worst ms | Tics/s |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| Baseline 5.8.1 | 599 | 16.667 | 17.577 | 18.051 | 20.707 | 35.000 |
| Connected water | 599 | 16.668 | 17.562 | 18.036 | 18.484 | 34.997 |

These windows precede only the catalogue checksum/matcher change; hydraulic
runtime and rendered installation are identical. They do not establish full-map
60-FPS acceptance, siege performance or a statistically significant speedup.
The existing altitude mansion/sewer/city references remain in validation_581;
unaffected large-population cases were not repeated. No retired 6,000 test ran.

No new routine global actor scan: marked-map initialization reads sector
metadata once (7,749 sectors in this mansion) and performs a typed lookup for
one controller. The existing world ticker caches it and updates two water
planes plus the gate. Saved pointers rebind on world load. Local water lookup
examines only the character's sector 3D floors. No NPC/census policy changes.

## Failed experiments retained

Early compilation exposed reserved identifiers, a sound Name/String mismatch
and access to a component of a returned vector; corrected before native runs.
Two numeric trials exposed steady-state roundoff during long catch-up; bounded
settling now completes without dropping pending time. The world fixture was
expanded to cover full hydration and empty sources. An early rollback
script dispatched before save loading finished; later waits execute the checks.
Early screenshots had the introduction overlay; only private diagnostics suppress
that overlay. Production introduction behavior remains unchanged.

## Reproduce and author review

Run python assets/validation_582/prepare.py, build_dev.ps1 with destination
build/issue414-runtime/current/caelum_argenteum_dev.pk3, then build the same
filename under compatibility with -LegacyMap01. Preserve baseline 5.8.1 under
baseline for old-save controls. run_native.ps1 accepts fresh labels and refuses
overlapping engines; use scripts numeric/world/mansion/save/load/hub/flow-*.
Original-save controls use legacy-checks.pk3 and legacy-* scripts.
collect.py verifies all package bytes and retains evidence without distributing
private fixtures. Project validation passes with no errors, generated indexes
are current, and git diff --check passes.

Open assets/validation_582/author_terminal.ps1 in a visible PowerShell with
-NoExit. Select 1 for a fresh private mansion, 2 to reload a private save.
Use the lever normally; F1 returns to the path, F2/F3 enter each basin,
F4 advances one game minute, F5 reports volume/height, F6 gives an overview.
The single root pending_test.txt contains complete outstanding author checks.
