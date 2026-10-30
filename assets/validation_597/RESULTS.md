# 5.9.7 / issue #423

Guard uniforms now share authored body/cap modules and existing face/hair
patches. Four semantic faces persist independently of actual equipment and
statistics. Prisoner cloth palettes preserve existing identities and poses.
Bandit subclasses are excluded. There are no new actor layers or world scans.

## Scope and assets

- 160 shared guard modules; 544 native compositions, seventeen poses/eight views.
- 632 finite prisoner cloth variants, exact original alpha in every frame.
- Original artwork and rejected candidates preserved; exact prompts, palette
  data, registration boxes and SHA256 records in assets/source/art/port_597.
- Both generators reproduce identical bytes. Eight-view review includes idle,
  carbine, fallen and crouching attachment. Profile collars were corrected after
  this review detected a displacement caused by weapon bounding-box alignment.
- No new item, recipe, balance, affiliation disclosure or garment ownership.
  Worn/3D player garments remain the separate V5.17 scope.

## Native and static verification

GZDoom4.14.2, Windows11, Ryzen9 5950X/RTX3070Ti Vulkan, background unpaused,
5% audio, 60-frame cap. Requested1280x720; engine logs report1520x825 on this
desktop. Commands and package hashes are retained in evidence.json. Log copies
normalize line endings and trailing whitespace; original engine output remains
in the corresponding local build folders.

- legacy-01: original5.9.6 save with four real guards/four prisoner classes.
- final-package-migration: 28 PASS; old actors migrate idempotently, semantic
  faces, poses, equipment and physical stats remain correct; bandits excluded.
- final-package-persistence: five new PASS checks after final-package save/reload,
  actual hub return and native lethal damage/fallen identity. Original save
  remains separate.
- rollback-final: original save loads the preserved5.9.6 package.
- house-final: four actual CAH000 residents use their stable wardrobe identity.
- City fixtures preserve all600 deferred household slots; the peaceful city
  starts with no deployed guard bodies. A separate600-body diagnostic is used
  for the renderer comparison, without attackers or the retired6000-body cases.
- Project validation has zero errors; generated document/dialogue indexes and
  git diff whitespace checks pass. No production combat state/action changed.

The guard restore/apply microbenchmark measured53.875ms/10000 before caching
sprite identifiers,0.2365ms on the final cached implementation. Native indices
are transient and rebuilt per body/load; only face/revision are semantic state.

## Rendering limits

Matched600-guard peaceful diagnostics (dormant AI in both builds, live physics
and maintenance) give these render-callback intervals in milliseconds:

| View | Build | Mean | p95 | p99 | Maximum |
| --- | --- | ---: | ---: | ---: | ---: |
| Forward | 5.9.6 |16.6734|19.4148|20.8503|23.1082|
| Forward | 5.9.7 |16.6642|21.0984|22.9880|25.8001|
| Ground75 degrees | 5.9.6 |16.6637|21.4260|23.1751|27.8363|
| Ground75 degrees | 5.9.7 |16.6546|22.6173|24.2159|25.5096|

The means remain near the60-frame cap; tails vary and some final percentiles
are higher. These short callbacks are not monitor-presented FPS or a guarantee
of siege fluency. Earlier forward repeats are also retained. PresentMon2.6.0
could not start ETW: access denied; no elevation/security change was attempted.
Its failure output is preserved. Actual city traversal remains an author check.

## Fixture corrections and author handoff

Initial failures are preserved locally: clearscope incorrectly called the play
GetSpriteIndex API; direct Die() did not set health in the death fixture; the
city fixture mistook deferred slots for instantiated bodies; the grouped #418
fixture needed a native tic after its legacy seed; a case-insensitive Mode/mode
shadow and an out-of-use-range caretaker were corrected in the manual fixture.
These were resolved without weakening production rules or hiding failures.

The numbered launcher verifies each issue separately and offers rank variants
7a-7e without relying on function keys. Windows Computer Use could not connect
its native pipe after retry/reset; physical key injection was not verified.
All sixteen numbered/lettered scenario setups passed; their log copies and
commands are in manual-evidence.json and manual-*.log. Native menus and captures
were checked. No PK3, IWAD, engine,
external measurement binary or save is committed.

Author checks CA418-01 through CA424-01 are in the single pending_test.txt.
AllV5.9 issues/PRs remain open and unmerged. Agent-only evidence does not count
as author acceptance.

To regenerate the local review after checkout:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File ./build_dev.ps1 -Destination build/issue423/current/caelum_argenteum_dev.pk3
powershell -NoExit -NoProfile -ExecutionPolicy Bypass -File ./assets/validation_597/open_review.ps1
```
