# 5.2.0 / #147 — Character identity and native settings

Date: 2026-10-11. Baseline: `f7c4a0dd167ac863e3604b69385784c246ced8c8`.
Agent evidence; **CA147-01 remains pending author acceptance**.

## Result

Twenty retained native runs completed with exit code 0: **552 passing
assertions, zero failing assertions**. This includes repeated checks after
loads/travel; it is not a claim of 328 distinct behaviors. Two rollback runs
produce pre-tick state snapshots rather than assertion lines. Fourteen focused
preservation checks pass in `static.json`; eight binding import/restart checks
pass in `bindings.json`. The normal build contains 6,315 files
and matches every member of the final native production package byte for byte.

GZDoom **4.14.2**, Windows 11, Vulkan, isolated configurations/save directory,
fixed RNG seed 147, background simulation enabled, master volume 5%. No temporary
keep-awake request was acquired. `*-run.json` retains arguments, configuration,
engine/package/fixture hashes, timestamps and exit codes. Native maps and
runtime source are packaged separately from the test code. Neither dependencies,
packages nor saves are included in this evidence directory or the runtime PK3.
Retained log text normalizes line endings and trailing whitespace only; original
logs remain in build/issue147 and passing-run originals are hashed in native.json.
JSON retains initial config text without PowerShell's attached provider metadata.

Final production SHA-256:
`52cbd4301411b2f2afa779c9b2c9c6d0987bee7dc1aa6b9baf2ac0163e17cc55`.
The first fourteen runs establish identity/creation/hub behavior. Final review
then found that deleting KEYCONF's section declaration would orphan old remaps;
the final package retains an empty import section and hides its heading. Six
additional runs exercise that exact package: two language captures, alternating
old/current identities and legacy binding import/restart. Records distinguish
all tested package hashes; `static.json` compares both original saves against
the final alternating-load snapshots. The identity/travel code is unchanged by
the final binding compatibility correction.

## Native coverage

| Retained run(s) | Evidence |
| --- | --- |
| `legacy-a-04`, `legacy-b-01` | Original 5.1.20 runtime; two different five-field identities, all eight creator pages, incomplete confirmation rejection, allocation caps, back/forward preservation, localized profession and one-time bridge consumption. Eight assertions each. |
| `current-a-01`, `current-b-01` | Same creation cases plus close/reopen draft recovery and proof that draft editing leaves the loaded character unchanged. Ten assertions each. |
| `rollback-a-02`, `rollback-b-01` | Original saves reopened with the original runtime after the creation processes exited; full pre-tick identity/allocation/attribute/resource/equipment snapshots. Originals are retained locally and fingerprinted. |
| `migration-a-01`, `migration-b-01` | Old saves loaded with new runtime; exact original snapshot equality, revision initialization, shared references, idempotence, ownership rejection, forged-draft rejection, native skin protection and saved-sex pain/breathing. Sixteen assertions each. |
| `menus-es-captures`, `menus-en-final` | Spanish 1280×720 and English 1024×768; both setup entry points, native Actions/Weapons/Inventory/Other and clean controls root. Descriptor checks, localized race/class/family/attribute contexts and all 16 ordered profession choices. Twenty assertions each. |
| `migration-a-final` | Final runtime alternates old A → B → A despite native gender/color/class and `ca_newchar_*` changes, saves/reloads migrated A, then travels MAP01 → MAP03 → MAP01. Ninety assertions. |
| `truehub-final` | Final runtime crosses MAP01 → MAP03 → MAP02 → MAP03, including an actual revisit within hub 434. Identity, allocations, attribute totals, quest stage, Tarot card and item ID/size/wear remain intact. Sixty-two assertions. |
| `current-reload-final` | Current A → B → A after engine restart and changed gender/draft preferences; saves a current-format copy. Forty-eight assertions. |
| `migrated-restart-final` | Migrated current-format save loaded after another engine restart. Twenty assertions. |
| `bindings-import`, `bindings-restart` | Final delivery runtime imports eleven customized normal bindings and one double binding from a copied legacy INI, then reloads its saved configuration in another process. Twenty-one assertions each, plus eight explicit active-binding/configuration checks in bindings.json. |
| `menus-es-delivery`, `menus-en-delivery` | Final delivery captures and the additional assertion that the compatibility section leaves no heading in Customize Controls. Twenty-one assertions each. |
| `migration-a-delivery`, `current-reload-delivery` | Old A → B → A and current A → B → A repeated with the final delivery package; migrated save/reload and MAP01 → MAP03 → MAP01 also repeated. Ninety-one and forty-nine assertions. |

The two profiles are A: Human/Priest+Priest/female/short, and B:
Beastman/Warrior+Explorer/male/tall. Both spend the existing four family and
thirty individual points. The isolated seed adds one existing sword with item
ID 1, size 3 and wear 37, one Tarot ownership flag/deck and an active quest
stage. It lowers health/Air/Anima so an unintended refill would be visible.
This is a test setup, not a new recipe, grant or balance choice.

Immediate original and migrated snapshots match exactly, including all twelve
attribute values, four family/twelve individual bonuses and survival meters.
Resources then evolve normally during unpaused travel; subsequent snapshots
are not expected to remain numerically frozen. The probe separately asserts
that repeated binding and reconstruction of an inventory-only revision-0
record neither recompute attributes nor refill resources in the same tick.
It checks rejection of an unowned record, invalid player endpoints and null
readers. No single-client test establishes full multiplayer support.

## UI and fixture boundaries

`flow.zs` drives the actual creator's menu events and confirmation validation.
For repeatable unattended creation runs it closes the introduction and starts
MAP01 with the validated per-player bridge; it does **not** pretend to press a
physical key through the full introduction. A separate visible baseline run,
`diagnostics/legacy-a-03`, exercised real native introduction confirmation and
observed the matching five-field profile and allocation. That process was
intentionally stopped before the isolated save, so it is not counted among the
20 completed runs. Final interactive author confirmation remains CA147-01.

The final captures in `captures/es` and `captures/enu` were visually inspected:
saved identity selectors and the misleading native Doom preview are absent;
network name/team and handling preferences remain; abilities occur in Weapons,
flight in Actions, Journal in Inventory and time skip in Other. The root has no
Caelum debug section. Both legacy and new setup entry points lead to the same
screen. Captures are ordinary native frames, with the existing gameplay HUD
still visible behind the menus. This patch does not change the general UI art,
HUD, fonts, hints, focus handling or all binding defaults (#149 and later work).

GZDoom loads old bindings only when KEYCONF declares their INI section. Keeping
that declaration without addmenukey rows imports normal and double bindings,
then native shutdown writes them to the general sections and empties the old
ones. Runtime code never rewrites the INI. The fixture copies an isolated
baseline config, changes twelve test bindings, checks their live console values,
verifies their new storage and repeats after restart. Gameplay and diagnostic
commands both survive; the user's own configuration was not used or edited.

The probe checks sound selection and actual native sound-channel playback; it
does not claim a new voice catalogue or author auditory approval. Existing
custom pain/breathing follow the saved sex. Existing world/hand assets remain;
new appearance options and preview rendering belong to #148.

## Static evidence and audit

`identity-audit.json` lists the source locations for profile/allocation fields,
the transfer CVars, native presentation hooks and identity service. The ownership
and writer/reader contract is in SYSTEMS, section 5.2.0. `static.py` verifies:

- Approved profile/allocation/attribute/growth/constant rules are unchanged.
- Existing creation description keys and text, aliases and default binds are
  unchanged; the custom debug binding rows are gone.
- Legacy saved fields and the sole native player class remain.
- Original/migrated A and B pre-tick snapshots match, including the final build.
- The standard PK3 matches all final tested runtime members.

`python validate_project.py` passes with zero errors, matching 5.2.0 headers,
a fresh document index and 2,482 context words (`validate-project.json`).
`git diff --check` passes. These are delivery gates in addition to the focused
checks above.

## Diagnostics retained, excluded from passing counts

- `compile-01`: incompatible stock PlayerMenu replacement warning; replaced
  with the supported descriptor redirect/AddOptionMenu integration (CA-KP-076).
- `legacy-a-01`: fixture dispatched a console event through the wrong handler;
  it did not open the creator. Corrected to ConsoleProcess.
- `legacy-a-02`: fixture called StartGameDirect indirectly from UiTick and hit
  the engine's menu-code guard. Repeated fixtures use the documented map bridge.
- `legacy-a-03`: visible native confirmation succeeded, then intentionally
  terminated; the incomplete run is not counted as a full test pass.
- `menus-es-01`: fixture used reserved identifier `action`; renamed it.
- `rollback-a-01`: absolute load path was prepended by the engine's savedir;
  relative basenames corrected the fixture without altering the original save.

No unresolved runtime error from those iterations remains in retained passing
runs. No author tests are removed by this evidence.

## Reproduction

Run `python assets/validation_520/prepare.py` with no GZDoom process active.
Use `powershell -NoProfile -ExecutionPolicy Bypass -File
assets/validation_520/run_native.ps1` with a **new** label and the arguments
recorded for each case (override Engine/Iwad for the local installation).
Generate original A/B with Baseline and the legacy scripts; keep those original
save/package pairs for rollback. Migration aliases retain the basenames required
by GZDoom saves. Current-runtime aliases do the same for new-format saves.

Run the menu fixture per language and copy its seven PNGs before the next run;
the engine writes the same screenshot names for both languages. Each screenshot
has a subsequent wait so the deferred frame finishes before changing menus.
For binding compatibility, run `bindings.py --prepare`, then the import run
with ConfigSource build/issue147/legacy-bindings.ini and the restart run with
ConfigSource build/issue147/bindings-import.ini. Run `bindings.py` to validate
both active console queries and saved normal/double bindings.
Use the ordinary build script, then `static.py`; `collect.py` retains only the
listed completed evidence and explicitly labelled diagnostic records.
