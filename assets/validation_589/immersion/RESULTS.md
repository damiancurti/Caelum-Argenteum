# Immersion continuation — #502 / 5.8.9

Native GZDoom 4.14.2: **71 PASS in 11 selected runs**. Separate from prior
92 severe, 30 state and 66 environmental assertions. Static validation is stored
alongside this report. Author CA502-IMMERSION-01 is pending until return.

The immutable immersion02 package contains 16,862 source-identical members,
SHA-256 7b767e5cc6a74a9d86426213ae2b980f906e36a01f6d94d62abb4b1bb34b051e.
Production code runs in the personal thermal/world update, reusing its existing
16 vertical samples and four anatomical zones. No whole-map actor scan is added.
Additional water-quality sampling is limited to the player; no NPC exposure is
claimed. These tests do not establish frame-presentation or frame-time results.

Coverage: salt/potable versus biological/chemical water, partial/full immersion,
actual worn area, loose sword fraction, protected Box, inverse body-mass dose,
joint airborne/water integration, independent predictions, real waiting, travel
departure, current save/hub, existing save load and original-package rollback.
The actual MAP01 reservoirs read their current quality and reject exact waiting
forecasts while their changing levels lack an independent projection. Native
waiting still runs their real calendar; this is an explicit forecast limitation.

The waiting case predicts and executes C=21.180438728835 after 35 personal tics.
It exposed a stale/different shelter classification in the forecast. Both paths
now share the thermal shelter rule at the current location. Forecast schema 9
invalidates old projections; body/equipment contamination values remain intact.
Water coverage is derived/transient and rebuilt after save/load. Abstract travel
clears departure immersion before sampling its own route atmosphere.

Retained failed probes:
- core01: fixture's hand-calculated two-source expectation was rounded incorrectly;
  corrected exact square-root value. Its dry check also sampled before native
  WaterLevel update and without regional weather initialization.
- core02: WaterLevel is read-only in ZScript; the fixture now waits for native
  movement and uses the shared water sampler for the isolated geometry check.
- core03/core04: full environment sampling correctly refused unknown weather;
  the isolated dry geometry check now samples geometry directly.
- wait01..03: diagnosed and corrected the production forecast shelter mismatch;
  do not treat those failures as harmless tolerance differences.
- hub01: native hub arrival uses the map start, not the prior water position.
  The revised test checks dry arrival and then re-entry into the actual volume.

Source: prepare.py/checks.zs, shared ../run_native.ps1. Tests use hidden/unpaused
sessions, five-percent master audio, and never overlap another GZDoom instance.
No user save is modified; retained legacy copies verify reversible loading.
