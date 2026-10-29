# 5.8.28 / #502 - Natural weather history for physical objects

Status: 71 executed native PASS, zero final failures/static errors. Author
corroboration remains pending as CA502-WEATHER-HISTORY-01. This does not complete
#502 or V5.8. Manual questions/checks are deferred at the author's request.

Baseline: ecdea2b97753e48fd3461b620a38084426e27f08 (5.8.27).
Official package: build/issue502-weather/final28b/caelum_argenteum_dev.pk3.
SHA256: 4defc45874b4e3a9e5ac6e50cf1f2e07cd5f6a91b7508678dfcca79f08f67d1e.
All16,980 members match src byte-for-byte; all14,034 previous map/art members
remain unchanged. Native tests used GZDoom4.14.2/Windows11/Vulkan/1280x720,
60-FPS cap, active unpaused background and5% audio; runs were serialized.
Run records contain engine/IWAD/package hashes, commands and machine details.

## Behavior and persistence

Revision3 records region, seed, civil-time offset, shelter/roof, environmental
reference and physical area. Existing weather is reconstructed at its normal
civil-minute cadence, including partial endpoints. The existing nonlinear
exposure/rain solver handles each object's own concentration and area.

Native checks compare one-square-meter history with the existing surface ledger
and independently integrate one-second steps, including rain and small weapon
areas. Covered objects exclude rain. Repeated reads do not double-charge;
cleaning closes both unloaded and pending loaded exposure before replacing dirt.
Geometry samples retain their staggered cadence; querying concentration does
not trigger new geometric scans. Native pickup, storage, toss and destruction
ownership pass. Current save/reload, actual hub absence, revision1/2 migration,
backward-clock guards and original-runtime rollback pass. Existing constant
Limbo ten-year catch-up stays analytical (0.014ms in the selected run).

The old exterior save was created and reopened by the unchanged official5.8.27
package, then loaded by final28b without saving over the original. Revision2
exterior history begins at migration; existing concentration is retained.
Revision2 constant Limbo intervals remain valid. No new actor census is added.

## Performance

An uncached prototype replayed one day for1,000 receivers in9,868.688ms. Final28b
took86.9435ms with the identical checksum19,610.572520. Source for that prototype
is retained as uncached-prototype.zs; reproduce from the baseline by replacing
CaelumContaminationObject.zs. Its log/package hash are preserved separately.
This batch timing is not a frame-rate measurement.

The transient cache holds at most32 date/location pages; its keys include region,
seed, profile, shelter, roof and environmental reference. It contains weather,
not receiver concentrations. Eviction/recomputation is tested and does not
discard historical time. Replay cost still grows with elapsed civil minutes;
the one-day measurement is not evidence for arbitrary years of city absence.

Matched peaceful1,000-object scene,700 tics, same diagnostic/package settings:

| Measurement | Official5.8.27 | Final5.8.28 |
| --- | ---: | ---: |
| Mean renderer-callback interval, ms | 16.6664 | 16.6670 |
| P95, ms | 17.0629 | 17.0365 |
| P99, ms | 17.4808 | 17.4962 |
| Worst, ms | 18.0083 | 17.8921 |
| 700-tic elapsed phase, s | 19.9344 | 20.0332 |
| Existing initialization census, ms | 1.0204 | 1.1128 |

Phase boundary polling uncertainty is±100ms. All1,000 objects receive exposure.
PresentMon access was denied; renderer callbacks are not displayed frames/GPU
time. This supports the narrow regression comparison, not campaign/siege FPS
acceptance. No retired6,000-attacker scenario was run.

## Reproduction and resolved development failures

Run prepare.py and prepare_regressions.py, build the current runtime, then
run_suite.ps1 and run_regressions.ps1 with a fresh label prefix. The latter
adapts old injected constant samples by explicitly disabling their natural
history for that injected interval; the old Limbo assertions now expect schema3.
The original fixtures remain unchanged. Use run_native.ps1 with legacy/checks.pk3
and the original package to create/reopen the old save; the current checks.pk3
forward-loads it using the same serialized diagnostic handler identity.
Run the existing validation_5812/object_performance.py against both runtimes.
collect.py checks literal PASS lines rather than restored cumulative counters.

Exploratory logs remain in the local build directory. The initial diagnostic
used reserved state as an identifier; it was renamed. The first storage
regression exposed pending pre-cleaning time being applied after cleaning;
SettleNow now closes that interval without resampling geometry. Both are fixed
and rerun against final28b. Intermediate final28/probe results are not counted
as final acceptance. The failed shell wrapper was replaced by the checked-in
run_regressions.ps1; all four final regression runs completed successfully.

Temporary climate-seal history, NPC physiology, unloaded household work and
remaining stackable/non-collision contact coverage stay open. No new balance,
maps, art, recipes or shop values were introduced.
