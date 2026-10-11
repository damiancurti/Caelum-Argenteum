# 5.2.10 / #192 ranged amendment and shotgun naming

Baseline: `c8518c6e` (merged 5.2.9 acceptance/index correction).
Target: GZDoom 4.14.2, Windows, Vulkan, 1280x720. Native runs use isolated
configs, run unpaused in the background at 5% audio, and exit individually.
The official package contains 6,347 members and matches every source byte.
`STATIC.json`, run manifests and `AUDIT.json` identify the tested files.

## Results and limits

| Evidence | Result |
| --- | --- |
| Same ranged fixture on baseline | 332 expected failures / 696 passes; demonstrates missing bow/crossbow contract |
| Initial changed runtime | 1,028 assertions passed |
| Final official package, `final-ranged` | 1,028 assertions passed |
| Renamed native shotgun, `selector-02` | 16 assertions passed, actual equip/attack/reload, screenshot and new save |
| New save reload, `selector-reload-01` | 5 further assertions passed; cumulative saved counter 21 |
| Native creator, Spanish and English | 62 assertions each (60 UI + 2 authoritative profile), screenshots inspected |
| Static/package checks | No active former-bow names in runtime; 16 renamed artwork files byte-identical |
| Optional crop generator | Two isolated runs identical; 6 caches match baseline generator bytes and maintained pixels |
| Cross-review | No mitigation/naming blockers; confirmed exact-name serialization boundary |

The ranged matrix launches the real arrow, bolt, carbine and pellet classes for
all four families, T1/T2/T3 and Liberal/Center/Conservative. Independent expected
values check armor bypass, no ideology addition, immutable launch identity,
already-cached ideology and revision-zero fallback, unchanged prepared damage,
35% armor examples, racial defense and NPC native DamageMobj. Player checks
combine shield, armor, defensive ideology, physical/half-magical Toughness.
Actual flying arrow/bolt collisions exercise both NPC and player recipients.
Melee, spell, javelin and channel controls retain their ideology behavior.

The selector test equips a real item through the inventory flow, uses native
attack/reload inputs, resolves all nine renamed frame labels, and reloads the
new save with the renamed ready weapon and loaded barrels. Captures preserve
the accepted shotgun renderer. The author explicitly authorized rebuilding test
saves without migration; saves containing `CaelumStandardBowSelectorWeapon`
cannot load after the class rename. GZDoom resolves saved class names exactly;
`replaces` does not provide a serialization alias. Keep old save/package copies
for rollback. No compatibility migration is claimed for this naming cleanup.

CA192-02 remains pending for author gameplay acceptance. The earlier accepted
CA192-01 and CA188-01 remain recorded under their original releases; they do not
accept this amendment. Commit/push/issue closure do not substitute for that check.

## Reproduction

1. `python assets/validation_5210/prepare.py` builds deterministic local packages.
2. `powershell -File build_dev.ps1`; copy its output to
   `build/issue192-ranged/official.pk3`.
3. Use `run_native.ps1 -Label <fresh-label> -Fixture ranged -Script ranged.cfg
   -RuntimeAlias official.pk3`. Baseline reproduction adds `-Baseline
   -ExpectRegression` instead of `-RuntimeAlias`.
4. Run fixture `selector` with `selector.cfg`, then the same fixture with
   `selector_reload.cfg -LoadGame ca192-shotgun.zds`. Creator uses `creator.cfg`
   and `-Language esp` or `enu`; preserve each screenshot before the next run.
5. `verify.py` checks source/package parity and runs the modified generator in
   fresh isolated directories. Requires Pillow 11.3.0; delivery verification
   installed it only under `build/issue192-ranged/python-deps` and supplied that
   directory through process-local `PYTHONPATH`.
6. Regenerate both indexes and run `python validate_project.py` and
   `git diff --check`. Keep indexed source bytes identical to their Git blobs.

Test preparation corrections: the first selector fixture omitted required
lookup arguments and failed compilation; the corrected fixture passes both
new-game and reload runs. Initial generator verification lacked Pillow;
the isolated dependency installation resolved it. One maintained T2 cache has
different PNG compression from regeneration, with identical decoded pixels;
both the unchanged baseline generator and renamed generator produce identical
bytes for all six caches. The 16 delivered art files retain their original
bytes. None of these fixture corrections required runtime changes.
Raw local artifacts are retained; delivered logs normalize newlines
and trailing whitespace, with original hashes recorded in `AUDIT.json`.

The temporary thread-scoped keep-awake request was released at
2026-10-11 20:29:20 UTC. `power-request.json` confirms the same power plan before
and after. No engine, IWAD, save, package or third-party dependency is distributed.
