# #383 city catalogues — 5.6.10

Static validation passes. Thirteen final native runs on GZDoom 4.14.2 / Windows
11 record **576 PASS, zero FAIL**. CA383-01 author acceptance is pending.
`report.json` records commands, configurations, environment and hashes;
`native/` preserves sanitized complete logs, including failed diagnostics.

The final package has 16,432 members, matching `src/` exactly after text newline
normalization. SHA-256: `cef3dd1ccd26488168511c41b8c6b731cc2bb1c7ffc389ee23bcb3b9b140bf92`.
Both new signs and generated category anchors reproduce byte-for-byte. All six
previous sign PNGs remain identical to the preceding commit.

Coverage includes all 392 valid recipe/tier offers, positive approved values,
ten-book stock, filters, XL equipment references, lock/key-inclusive book prices,
correct lock/tool names, 125 garment/size instances, all eleven provision types,
both sealed kits and three matched lock/key pairs. Transactions cover first
binder/pages, overlapping pages, duplicate rejection, no instant knowledge,
personal/Box destination, capacity/money rejection, foreign session rejection,
split material identity/tier, pair atomicity/missing key, exact worn/wet/sized
garment resale and the unchanged 62-check city/Palomo regression suite.

Current save/reload preserves notebook pages, money and depleted books. Hub
return preserves the same merchant, while non-hub travel preserves the player's
notebook. An actual **5.5.8a** MAP03 save has both replacement shops initialized,
partly depleted stock, a worn exact item and reduced wallets. Loading the final
runtime migrates categories/signs automatically (the verification fixture never
calls Prepare), adds only new catalogue entries once and retains old merchandise,
wallets and item identity. Reloading the upgraded save is idempotent. The original
save/original runtime pair also passes recovery checks; private saves/packages
remain under `build/issue383` and are not distributed.

Spanish and English library screenshots are `library-es.png` / `library-en.png`.
A ten-second isolated open-library diagnostic records 598 RenderOverlay frame
intervals: 60.05 mean frames/s, p95 17.168 ms, p99 17.659 ms, maximum 23.357 ms.
Seeding 392 offers took 2.034 ms; opening 0.957 ms; mean refresh over twenty calls
0.549 ms on the recorded machine. These are scoped engine frame intervals,
not OS presentation measurements or city/siege performance acceptance. Catalogue
migration is one bounded typed merchant/sign pass, not a new per-tic scan.

Reproduce: `python assets/validation_5610/prepare.py`, build to
`build/issue383/current/caelum_argenteum_dev.pk3`, then use `run_native.ps1` with
a unique `-Label`, `-Checks`, `-StartMap CLTHQA` and the desired `-Script`:
`suite`, `regression`, `save`, `verify`, `travel`, `ui-es`, `ui-en`, or `perf`.
`verify`/`travel` load `ca383-current.zds`. `city` starts MAP03. `legacy-save`
uses the preserved 5.5.8a `-Runtime baseline -StartMap MAP03`; `upgrade` loads
`ca383-legacy.zds` with the current runtime, and `upgrade-verify` loads the
resulting `ca383-upgraded.zds`. `rollback` loads the original save under baseline.
All native runs are sequential, unpaused in the background and at 5% audio.

Diagnostics excluded from passing totals: the initial runtime ternary returned
different Inventory subtypes and failed compilation; it now uses explicit
branches. An early fixture lacked enough currency for a T3 book, then attempted
to inspect an absent binder; a tier test also used a deliberately single-tier
kit. The first travel fixture omitted the hub cluster, so the engine correctly
discarded its test-only room's merchant. The corrected fixture declares cluster
434 and separately tests non-hub player persistence. These errors remain visible
in diagnostic logs. Cross-review additionally found and resolved lock-book
pricing/names and the visited-city migration hook before final validation.

Automatic replenishment is #385. Worn/preview/first-person clothing is #387.
Neither is claimed by this catalogue delivery.
