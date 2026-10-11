# Issue #162 - utility staff, release 5.1.15

Original art, one-tier tool mechanics and save integration are implemented.
Author handling/art acceptance remains CA162-01. Caella's permanent grant and
full tutorial acceptance belong to dependent issue #164.

Static validation passes with zero errors (`static-validation.json`). The normal
`build_dev.ps1` package builds successfully: 6,304 members, valid ZIP, every member
byte-identical to the tested production package. The art registration generator
was run twice with identical hashes. Details: `build-verification.json`.

## Evidence

Windows 11, GZDoom 4.14.2, Vulkan, 1280x720, fixed RNG seed 162. Native runs used
unpaused background execution and 5% audio; no keep-awake request was acquired.
The local development IWAD, engine, PK3s and saves are not distributed.
Native logs and fixture bytes are preserved through .gitattributes; originals
also remain local under build/issue162.

| Native run | New assertions | Result |
| --- | ---: | --- |
| checks-final | 35 | Passed: identity/recipe, sizes/materials, geometry, fire burn clock, freeze, real signed heat, attenuation, wall occlusion, armor retention, cost and item wear |
| crafting-01 | 23 | Passed: five sizes by three efficiencies, station parity, real craft/repair/dismantle transactions |
| inputs-final | 21 | Passed: native held commands, both buttons, sustained heat/cooling and precise Anima/regen accounting, release/exhaustion/sleep/menu/switch/death |
| inputs-reload-final | 2 | Passed: save during fire preserves identity; released reload clears emission |
| checks-reload-final | 2 | Passed: partial contact wear 17 tics and durability 9,998 survive reload |
| lifecycle-03 | 7 | Passed: native pickup, one tier, Box storage/retrieval, drop/re-pickup, no duplication |
| travel-final | 8 | Passed: active departure, second map and hub return retain identity/wear and clear map-local emitters |
| legacy-load-01 / legacy-again-01 | 6 + 6 | Passed: a real 5.1.14 save migrates recipe revision 5 to 6, preserves wand identity/essence/size/durability and old knowledge, no duplicate/tool grant; repeat load is idempotent |
| demon-baseline / demon-final | 7 + 7 | Passed: shared-service regression against accepted 5.1.14 |

Total: 117 passing assertion executions on the new runtime, plus seven on the
accepted baseline. Final runs have zero assertion failures or VM/compile errors.
Native captures inspect ready/equip/fire/ice and inventory art. The wall captures
independently show engine illumination during emission and its removal on release.
The equip capture uses tic 45 during native raising; the earlier tic-25 capture
(`pre-equip.png`) still shows outgoing fists. The Spanish inventory capture shows the new icon/name, M durability and reduced
Anima cost per second. These images are engine captures, not mockups.

The native baseline and final demon measurements agree exactly: cost
9.572675754, self heat 3.603199723 J, distant heat 0.480063520 J, side heat
0.881439660 J and 11 burn HP. The original legacy save also loads with its
unchanged baseline package (`legacy-rollback-01`); migrated saves use a new name.

Held-mode tests include about 11 seconds each of fire and ice. At 9.714286 paid
seconds of the observed interval, the final native checks still match the
expected resource payment plus natural regeneration. Freeze and signed absorbed
energy are tested independently of visual effects. The internal thermal variable
is accumulated exposure, not a measured core temperature; the fixture's historic
`temperature` log label prints exposure.

## Scope and reproducibility

`prepare.py` creates deterministic isolated maps and fixture packages under
`build/issue162`. It preserves accepted source from commit `1fba4157` as a local
baseline and builds the current production source. Run each fixture using
`run_native.ps1`, with a unique label, corresponding `.cfg` and optional
`-LoadGame` or `-Baseline`. The scripts create `ca162-firing`, `ca162-checks`,
`ca162-legacy` and `ca162-migrated` locally. Saved assertions are reported separately
from new checks. Only `src/` is included in the development PK3.

Initial implementation production package SHA-256:
`897bad7273dcf9f3cf9465bfbd2e06cef43d32d1197ee2fc40643dc5b9ac2240`.
Earlier checks retain their original package/fixture hashes in run records.
After `inputs-final`/`travel-final`, production changes only updated two required
diagnostic version strings; final compile/mechanics and reload use the final hash.
Earlier crafting/lifecycle/migration evidence is unaffected by later visual tip
registration or those diagnostic labels. Final fixture additions only observe
reloads and take extra screenshots; their source hashes are retained separately.

The fixtures seed isolated resources/targets and invoke native input, inventory,
crafting and map travel paths. They do not constitute author acceptance, a full
campaign playthrough, multiplayer validation or Caella grant validation.

## Iterations retained locally

Initial compile iterations corrected reserved `Stop`, duplicate source packages
and the Actor flag required by the Ice frame label. Early fixture failures were
caused by deferred actor initialization, fixture tier/durability initialization,
case-insensitive stage shadowing, protected pickup calls, an absolute load path
being prefixed by the save directory, and a missing config. The Box/drop fixture
initially changed item durability without synchronizing its equipped live model;
both are now seeded consistently. The first hub fixture ran before player
initialization, then assumed console attack input persisted across native travel;
the final script presses again in the destination. These runs are not counted as
passing evidence. All final assertions above pass.

The pre-existing deletion of `assets/art_source/Caelum Argenteum.png` is excluded.

## Author-requested right-leaning pose, 2026-10-10

The author requested only that the staff lean right like the other weapons.
The shared clockwise rest pose now applies to the staff in ready, fire, ice and
equip frames; the world emission/light anchor follows the relocated tip. Original
art bytes, pickup and icon are retained. Release remains 5.1.15 in PR167.

`right-lean-final` and `right-lean-equip` inspect the corrected native poses and
light cleanup. `right-lean-checks` passes all 35 affected mechanics assertions,
including contacts, signed heat, wall occlusion, wear and cleanup. Existing
crafting and persistence evidence still applies. The first preview changed the
unused early-return grip branch; the final change is in the actual draw branch.
The corrected source also fixes the staff name's accent in maintained docs.

Current production SHA-256:
`ca9872d902ba3be27ff759cddbbf6ddaf42e2c637ca50df79fe4fab00d7f8ccc`.
Normal build/static results and package parity: `right-lean-build.json`.
The author's corrected-pose confirmation remains pending under CA162-01.
