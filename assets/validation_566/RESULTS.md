# V5.6.6 / #386 — ordinary native clothing

The 25 approved garments use native equipment identities, five fixed sizes and
one T1 recipe each. Material grade, rounded grams, price, crafting reservations,
study/practice and storage share existing authorities. Four separate clothing
regions coexist with armor; armor retains its complete thermal profile.

ClothingRevision 1 grants the approved CS/HC/GC/BS outfit once, retains equipped
armor and transfers implicit moisture to native garments. The approved initial
capacity exception shows the real load. Garments retain water when stored;
capacity overflow becomes runoff without latent cooling. No garment durability
loss, repair, dismantling, new vendor stock, NPC outfit or model is added.

**13 native runs / 410 passing assertions, zero failures.** Static validation,
normal packaging and byte-for-byte source/package comparison also pass.
`collect.py` records final package,
addon, source and engine hashes with per-run checks and sanitized logs. Native
fixtures cover all 25 paid recipes, five sizes, material-tier/third-input spends,
duplicate-completion guards, wet capacity rejection, chest and drop/pickup
identity, clothing/armor water conservation, initial entitlement, current
save/load, hub and non-hub travel, and actual wet armored 5.5.8a and 5.6.5 saves
upgraded to current code. Both original package/save pairs pass rollback and
remain private recovery inputs. Trade checks use the existing native wallet and
exact item transfer through an opt-in clothing capability; production vendors
remain disabled until #383 assigns them. Buyback retains ItemId, size, condition
and water, and worn garments cannot be sold.

Independent review of gameplay, legacy debug/UI paths and the trade extension
found no outstanding P1/P2. Both bilingual screenshots were visually reviewed;
the separate Clothing/Ropa filter and complete garment names are visible.
CA386-01 remains pending; isolated checks do not imply author acceptance.
Library and clothing stock are #383; original garment models/coverage are #387.

Reproduce from PowerShell: run `python assets/validation_566/prepare.py`, build
`build/issue386/current/caelum_argenteum_dev.pk3`, then use `run_native.ps1`
with a unique `-Label`, `-Checks` and `-Script suite`, `save`, `verify`, `travel`,
`ui-en` or `ui-es`. Load `ca386-current.zds` for `verify`/`travel`. The `legacy-save`
script uses `-Runtime legacy -LegacyChecks`; `upgrade` uses current `-Checks`
and `-LoadGame ca386-legacy.zds`. The runner rejects overlapping GZDoom sessions,
runs unpaused with 5% audio and records the exact command/configuration.
For 5.5.8a use `baseline-save` with `-Runtime baseline -BaselineChecks`, then
`baseline-upgrade -LoadGame ca386-baseline.zds -Checks`. `rollback` runs each
original save with its corresponding original package/addon. Private fixture
geometry references the local development IWAD; no IWAD, executable or test PK3
is included in the repository. These checks do not measure rendering performance
or approve a new NPC wardrobe, vendor allocation or garment model.

An early fixture revision (`suite-02`) failed to compile because the test used
a nonexistent small-chest class and a protected pickup method. The fixture now
sets the existing chest's small tier and calls its public pickup transaction.
Those failed fixture checks are not counted as passing evidence.
