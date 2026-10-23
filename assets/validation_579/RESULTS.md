# Water boiling and temperature — issue #409

Author acceptance: CA409-01 (origin 5.7.9 / #409) passed on 2026-10-23,
without qualifications. HISTORY records the separate combined author-test build.
The reports below retain their original agent-only evidence and dates.

This is agent evidence for 5.7.9, not author acceptance. The initial draft left
bottle cooling inactive because glass density was omitted from the proposal.
The author approved ordinary glass at 2,500 kg/m3 on 2026-10-23; the completed
model passes 117 native assertions on one full package, with all 16,724 entries
matching src. See `completion_report.json` and `collect_completion.py` for the
current hashes and checks. The original `report.json` and collector preserve the
earlier draft's 91 assertions and rollback evidence; do not treat its historical
incomplete status as the current implementation state.

New checks cover all three bottle capacities, an independent SI reference,
wind, warming/cooling without overshoot, mixing, Box contents, normal inventory
and dropped-item ticking, saved hot-water temperature and actual dated waiting.
Process/reservation checks, waiting through boiling and old-save migration were
rerun. Two final inventory/task captures were inspected. The only production
file changed since the preserved draft is CaelumWaterThermalData.zs.

The native fixture checks thermal work/fuel/evaporation, all eight contamination
combinations, all six vessel capacities, reservation and cancellation guards,
hot drinking, normal ticking, actual waiting and save/load. A preserved 5.7.8
save checks additive migration and original-runtime rollback. The fixture uses
an explicit climate marker; it does not alter campaign maps or distribute an
IWAD/executable. Test PK3s and saves remain under `build/issue409`.

Reproduce with `python assets/validation_579/prepare.py`, rebuild the complete
production PK3, then invoke `run_native.ps1` with a new label and the requested
script (`smoke`, `wait`, `glass`, `glass-live`, `glass-save`, `glass-load`,
`glass-wait`, `ui`, `old-load`). The other scripts retain the original draft's
reproduction routes.
Runs are sequential, unpaused in the background, with audio at 5%. `ui` uses a
visible window and engine screenshots. The development `fixture-dev.pk3`
contains source overrides; it is not the final-package evidence.

The original `report.json` records the draft's full-package and fixture hashes, individual
runs, assertion counts and source/package identity. Native logs/launch records
are retained under `native/`; initial failures remain under `diagnostics/`.
Earlier parser errors were corrected. The first clock-gap assertion incorrectly
expected a 6 mm leather canteen to cool below 85 C after only twenty world
minutes; the approved model's slower cooling was retained and the integration
test interval corrected. An inventory button overlap was found by inspecting
the rendered UI and corrected before the final captures.

The draft presentation correction restored the fuel/time estimate and replaced
characters damaged by a Windows PowerShell text pipe. Process/wait/save checks
are reused only after the collector proves that server logic and thermal data
are byte-identical between packages; only the two inspected HUD files, LANGUAGE
and generated localization indexes differ. Final UI and legacy migration run on
the corrected complete package. An initial legacy-load attempt was rejected
because the fixture filename differed from the original save's required name;
the successful run retains `legacy.pk3` in a separate directory and leaves the
original save/package untouched.

Limits: automatic end-time forecasting
is unavailable when an unreserved hot supply would change drinkability during
the forecast. Manual dated waiting continues to simulate cooling and checks
temperature at every actual sip. Unloaded clock gaps use the current sampled
environment, not reconstructed past weather. No performance-scale claim or
author approval is inferred from these isolated runs. Author checks are
deferred while the author is away; CA409-01 is now actionable and queued. Its
launcher waits for Enter before starting the private scene.
