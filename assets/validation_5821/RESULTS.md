# Camp cooking — 5.8.21 / #411

The campfire uses the existing learned beef/fish/puchero food recipes and native
inventory reservations, with actual wood burning instead of mineral coal.
Fuel interruption preserves progress through refill, relighting and save/load.
Cancellation retains original aged ingredients and carried water; spent wood
stays spent. The pot and fire remain locked only while they own the batch.

`report.json` records the exact official package, source-member comparison,
selected executed assertion counts, original run hashes and approved probe
differences. Counts are PASS lines executed in each run, never the cumulative
handler total restored from a save. No author save was changed.

## Selected checks

- All three recipes: learned access, food/water reservation, no coal, real wood
  burn, approved time and ten portions, inherited food contamination, exact
  final water consumption and prevention of duplicate output.
- Fuel exhaustion credits only its actual burning seconds. Native controls load
  wood and start the one-minute ignition; that minute gives no cooking progress.
  Saved references, remaining heat time, ignition phase and reservations survive.
- Missing/carried/boxed/nonempty pot and dirty water reject puchero. Beef/fish
  need no pot. Bread is rejected. A mounted water pot receives no additional
  heat while cooking; cancelling restores normal heating. Leaving reach spends
  burning wood but gives no unattended progress. Map travel frees the fire and
  preserves ingredients, with no off-map meal or unburned-wood loss.
- The full thirty-minute fish acceleration uses the actual world clock, without
  setting task time or backdating fuel. Its measured elapsed1805.714286 seconds
  includes ordinary post-completion burning; wood matches that elapsed time
  once. Existing automatic eating consumed one of ten portions after completion.
- The focused integration probes separately backdate a fire stamp to inject
  elapsed burning. They establish integration/guards, not full-clock throughput.
- Original5.8.20 active stove-task save loads and finishes under the new runtime;
  the untouched original also loads with its original package. The four stove/
  oven recipe core checks pass after the shared reservation refactor.
- Live Windows UI: mouse opened Cook; C also opened it;2 selected fish. The timed
  native audit confirmed the selected active recipe, reopened it through native
  Use, and captured readable Spanish progress/cancel/refuel controls. The private
  helper's first F2 binding did not provide evidence, so it is not claimed as a
  passed input check. Author scenarios now reuse the accepted default controls.

All native runs use GZDoom4.14.2, unpaused at5% audio. These functional results
are not a frame-presentation benchmark or author acceptance. The final hub runs
cover the reservation-release correction; older non-hub probes differ only in
the listed locale/index/version fields and that unload hook. The helper rejects
unexpected source differences. Existing scene artwork and maps are unchanged.

Development failures remain private: wrong new Spanish locale/accents; one
missing space in the diagnostic MAPINFO cluster; and the busy fire left in the
departing hub snapshot, now covered by CA-KP-177. Author check
CA411-COOKING-01 and the two prior #410 checks remain pending.

Reproduce with `prepare.py`, `run_native.ps1` and each retained run JSON. The
original stove checks reuse validation_5819; its prior package is retained in
the private `previous20` directory. Run `author_terminal.ps1` for the three
manual camp scenarios; it leaves the terminal available until Q is chosen.
