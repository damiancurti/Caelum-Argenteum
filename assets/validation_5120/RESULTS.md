# #173 — MAP06 doors and peaceful time skip (5.1.20)

Agent verification on GZDoom 4.14.2, Windows 11. CA173-01 was author-pending at
delivery; explicit author acceptance on 2026-10-10 is recorded in docs/HISTORY.md.
40 passing native assertion records; eight static checks pass and the ordinary
project validator reports zero errors. Complete logs and per-run hashes accompany
this report.

Runs are hidden/unpaused at 5% audio. No keep-awake request was used.

## Scope and results

- 320 existing interior openings gain 640 native hinged leaves; 160 existing
  entrance pairs and the 600 peaceful defenders remain. Both internal door
  orientations block native movement when closed, open through the native Use
  hook and permit collision-checked crossing after the hinge animation.
- Peaceful city streets permit native time skip. A home's bed is available to
  its own rooms; other houses do not share supplies/furniture. Actual simulated
  time/resources advance and cancellation preserves elapsed time.
- A fixture anchors the existing calendar 64 tics before the approved siege
  date (15 November 1889, 13:00), then starts a real time skip with a later target.
  It stops after exactly 64 tics at absolute stamp 104312357100, with reason
  CA_EVENT_SIEGE_INTERRUPT. No accelerated time overshoots the boundary; restart
  is blocked. The ordinary 6,000 Mandingas, commander, 600 defenders and twelve
  hostile machines deploy afterward. Siege counts/date/balance are unchanged.
- A native save produced by baseline 1c620037 contains the player in an old open
  doorway. Migration preserves actual soldier and entrance references, defers
  that pair (638 new leaves), then completes it once the player leaves (640).
  Repeated migration and native reload do not duplicate doors.
- Closed/open native captures are visually inspected. Static checks verify
  source/package/build identity, unchanged WAD geometry, deterministic generated
  data and all opening coordinates/groups. The ordinary validator also passes.

## Evidence boundary

Fixtures move the player to authored openings, call the real Use/collision and
time-skip APIs, and accelerate the calendar setup to the siege boundary. No
combat performance benchmark or full city playthrough is claimed. The full army
is checked on its ordinary spawn tick, not simulated through an entire battle.
Legacy fixtures preserve original saves/packages under ignored build/issue173.

The first live door check caught an initialization bug: calling PlaceAtProgress
before deferred PostBeginPlay fixed the doors at zero coordinates. Removing that
premature call resolved both orientations. city-04 is retained as the diagnostic
reproducer; only the later passing runs count toward results. Fixture corrections
included vector-component access and diagnostic formatting. See CA-KP-075.

## Reproduction

Run `python assets/validation_5120/prepare.py`. Use run_native.ps1 with a unique
Label and `-Map MAP06`. City: `-Fixture city -Script city.cfg`; siege:
`-Fixture siege -Script siege.cfg`. Door views: `-Fixture view -Script view-0.cfg`
or view-1.cfg. Reload city-doors.zds with the city fixture and reload.cfg.
Legacy: `-Baseline -Fixture legacy -Script legacy.cfg`; migration:
`-RuntimeAlias migration-runtime/baseline.pk3 -Fixture migration-runtime/legacy
-LoadGame legacy-occupied.zds -Script migration.cfg`.

Only authored fixture sources, text logs, screenshots and manifests are tracked.
Engine, development IWAD, generated packages and saves are not distributed.
