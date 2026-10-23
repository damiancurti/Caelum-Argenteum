# Water boiling draft — issue #409

This is agent evidence for 5.7.9, not author acceptance. Bottle cooling remains
incomplete: the approved mass-derived glass wall requires a density that was
omitted from the proposal. `GLASS_DENSITY_KG_M3=0` deliberately marks that
unresolved datum. Do not present this draft as the completed #409 delivery.

The native fixture checks thermal work/fuel/evaporation, all eight contamination
combinations, all six vessel capacities, reservation and cancellation guards,
hot drinking, normal ticking, actual waiting and save/load. A preserved 5.7.8
save checks additive migration and original-runtime rollback. The fixture uses
an explicit climate marker; it does not alter campaign maps or distribute an
IWAD/executable. Test PK3s and saves remain under `build/issue409`.

Reproduce with `python assets/validation_579/prepare.py`, rebuild the complete
production PK3, then invoke `run_native.ps1` with a new label and the requested
script (`smoke`, `live`, `wait`, `save`, `load`, `ui`, `old-save`, `old-load`).
Runs are sequential, unpaused in the background, with audio at 5%. `ui` uses a
visible window and engine screenshots. The development `fixture-dev.pk3`
contains source overrides; it is not the final-package evidence.

`report.json` records the exact full-package and fixture hashes, individual
runs, assertion counts and source/package identity. Native logs/launch records
are retained under `native/`; initial failures remain under `diagnostics/`.
Earlier parser errors were corrected. The first clock-gap assertion incorrectly
expected a 6 mm leather canteen to cool below 85 C after only twenty world
minutes; the approved model's slower cooling was retained and the integration
test interval corrected. An inventory button overlap was found by inspecting
the rendered UI and corrected before the final captures.

The final presentation correction restores the fuel/time estimate and replaces
characters damaged by a Windows PowerShell text pipe. Process/wait/save checks
are reused only after the collector proves that server logic and thermal data
are byte-identical between packages; only the two inspected HUD files, LANGUAGE
and generated localization indexes differ. Final UI and legacy migration run on
the corrected complete package. An initial legacy-load attempt was rejected
because the fixture filename differed from the original save's required name;
the successful run retains `legacy.pk3` in a separate directory and leaves the
original save/package untouched.

Limits: glass cooling awaits its design datum; automatic end-time forecasting
is unavailable when an unreserved hot supply would change drinkability during
the forecast. Manual dated waiting continues to simulate cooling and checks
temperature at every actual sip. Unloaded clock gaps use the current sampled
environment, not reconstructed past weather. No performance-scale claim or
author approval is inferred from these isolated runs. Author checks are
deferred while the author is away and will be queued only when actionable.
