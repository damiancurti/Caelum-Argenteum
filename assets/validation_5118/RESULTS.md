# Issue #164 validation — 5.1.18

Agent verification on 2026-10-10, GZDoom 4.14.2 / Windows 11. Author acceptance
CA164-01 remains in pending_test.txt. No author acceptance is inferred here.

## Results

181 passing assertion records across the retained runs (including repeated
reload/migration assertions); zero failing assertions. See summary.json and
individual complete logs/run manifests. Native tests run unpaused, hidden,
with audio at 5%. No keep-awake request was needed.

- Fresh route: Argento deck before Box; 78 physical cards without essences;
  real Trucazo deal; permanent Caella staff without a new Seal; held primary
  fire and secondary ice on the native dummy; four mandatory practice actions
  and all runes; Ronnie Pickaxe/recipe distinct from chosen-weapon crafting;
  real sword crafting cancellation/reopening/payment/output; Rulo bolas.
- Only the selected weapon was chosen/crafted before the Bull and final Box.
  Primary/secondary dummy exercises used native held input. All four existing
  helpers gather before saving and their AI fights after release.
- Actual native autosave requested at tic 1231; loaded snapshot tic 1234,
  TrialReleased=false, grace=67, health=624, Air=542.195863,
  Anima=624.648975. Hostility begins at tic 1301. No setup refill occurred.
  Forced lethal damage produces ordinary PST_DEAD, with no reset/respawn.
  Two manual loads restore the checkpoint, then exercise victory and Box
  turn-in without duplication. auto01.zds remains byte-identical after death
  and both reloads (SHA256 in summary.json).
- Armor, Seal, shield and necklace remain optional after victory. Native craft
  cancellation, reopening, payment and output pass after the ordinary combat
  timeout. The necklace gift stays idempotent. Actual departure cancellation,
  re-entry, commit and MAP02 travel preserve exact equipment/deck/Box instances.
- Five save fixtures made with baseline 6cae68bd cover before Argento, active
  Caella with old wand/Seal, Ronnie partial choices/issued allowances, active
  Rulo and completed MAP01. Migration retains stages, item IDs, wear, size,
  location, health, deck and Box, promotes old loans and is idempotent.
- Full inventory postpones gifts; clearing space delivers them. Revisits do
  not repair worn gifts or recreate dropped/lost gifts.
- Spanish Argento/Caella dialogue and Spanish/English plan menus inspected.
  An initial native-menu overflow was fixed by grouping optional choices on
  the existing summary page. All 405 conversation page slots retain order.

## Evidence boundaries

Fixtures accelerate travel and crafting elapsed work, inject exact recipe
materials, and call real dialogue/action services. Remaining unchanged Rulo
advanced/defense/Air practice flags are seeded for checkpoint coverage. The
player is temporarily invulnerable until the forced lethal-death check; Bull
victory is forced after separately observing live helper combat. The departure
fixture seeds the already-established captured-Fool prerequisite. These runs
verify affected transactions and persistence; they do not replace an unaided
playthrough or the author's combat/visual acceptance.

Earlier fixture-only corrections included native save basenames, a static
save-load observer, a case-insensitive field assignment, baseline allowance
seeding and waiting for the existing combat timeout. The resolved production
compile issue and menu overflow were rerun. No failed run is counted above.

## Build and reproduction

The final production package SHA256 is
c91faaa78ff6e2edefb9f8e529982f1fe16cbbb9966bedc4e9a6a30923822e32.
route-final, both final reloads and ui-caella-es4 use that source. Earlier
migration/optional/capacity evidence precedes only final menu/localization,
release markers and explicit new-profile field initialization; their tested
migration/transaction code is unchanged. Each manifest records its actual hash.
The standard build's 6,310 member bytes match the final tested package. Static
validation reports no errors; the generated document index is fresh.

Run `python assets/validation_5118/prepare.py`, then use run_native.ps1 with a
new Label for each run. Examples (PowerShell, ExecutionPolicy Bypass if needed):

```powershell
./assets/validation_5118/run_native.ps1 -Label route-repro -Fixture route -Script route.cfg
Copy-Item build/issue164/auto01.zds build/issue164/route-repro-checkpoint.zds
./assets/validation_5118/run_native.ps1 -Label reload-repro -Fixture route -Script reload.cfg -LoadGame route-repro-checkpoint.zds
./assets/validation_5118/run_native.ps1 -Label optional-repro -Fixture optional-runtime/route -Script optional.cfg -LoadGame route-victory.zds
./assets/validation_5118/run_native.ps1 -Label safety-repro -Fixture safety -Script safety.cfg
./assets/validation_5118/run_native.ps1 -Label baseline-repro -Baseline -Fixture legacy -Script legacy-b1.cfg
./assets/validation_5118/run_native.ps1 -Label migration-repro -Fixture migration-runtime/legacy -RuntimeAlias migration-runtime/baseline.pk3 -Script migration.cfg -LoadGame legacy-b1.zds
python assets/validation_5118/static.py
python validate_project.py
```

Other legacy scripts are b0, c2, c3 and c4. UI scripts 8/9/10/11 use
`-Fixture ui-runtime/route -LoadGame route-victory.zds -Language es` (or enu).
Prepared PK3s, saves, user configs, engine and development IWAD remain outside
the tracked evidence. Supply a legally available local IWAD to reproduce.
