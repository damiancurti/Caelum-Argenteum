# Issue #415 - Regional discovery, 5.8.5 (partial issue)

This production change separates actual scheduled outcomes from the character's
observed results. It does not implement the approved unloaded siege simulation,
new theft events or the remaining world catch-up adapters.

## Native evidence

GZDoom 4.14.2: **39 PASS across seven selected final/migration runs**, including
the original-save baseline and rollback. `report.json` lists each run rather
than adding cumulative counters printed by restored handlers.

- Remote actual outcomes, hidden/known event visibility, exactly-once local
  notices and discovery on regional return.
- A 100-day skip reconciles 144,001 rental occurrences arithmetically, without
  revealing the resulting debt. Payment cannot silently charge unknown periods.
- Reverse-inserted quest deadlines resolve in timestamp order. Actual quest
  failure prevents rewards immediately; journal refresh preserves prior
  knowledge until the causal region is visited.
- Native save/load and two-way hub travel preserve actual and observed counts.
- An original 5.8.4 save migrates to known outcomes without resetting counts;
  reloading migrated state is idempotent. The original remains loadable by its
  original package. Original save hash is recorded; saves remain private.
- Sorting 2,048 records preserves timestamp/stable-ID order. One native sample
  measured **0.967 ms**, excluding fixture allocation. This is not a frame-time
  distribution, render presentation measurement or FPS acceptance claim.

The earlier discovery-core/load/hub and legacy-load diagnostics are preserved
separately; the selected final runs use the final source-matched package.

## Static and scope checks

Project validation is clean; dialogue/localization and document indexes are
fresh. All **16,836 PK3 entries** match final `src/` membership and bytes.
Package SHA-256: `c004425c61625ea8f02c816ca95e0b813e50e933f0ddc5beb0313d48727fac10`.

No routine global actor scan or additional event handler was added to production.
The existing clock owns synchronization. Cached calls return without scanning
event records. Migration runs once; due reconciliation and regional disclosure
inspect at most 2,048 schedule definitions. Due-series sorting is O(n log n).
Recurrence counters remain arithmetic, not a claim of interleaved battle rounds.

No map geometry, artwork, sound, battle content, random theft or real-world
offline advancement changes. The upstream #496 documentation correction was
integrated; its source/audio scope remains in that issue. Generated-index
conflicts were regenerated, and exact tested source bytes were verified after
restoring required line endings. The temporary autostash remains preserved.

## Author acceptance

**CA415-DISCOVERY-01 fully accepted on 2026-10-24** (origin 5.8.5/#415).
The author explicitly confirmed all checks in both supplied terminals passed,
without qualifications. The tested runtime/package remain unchanged.
Battle simulation is outside this manual check and remains open under #415.
