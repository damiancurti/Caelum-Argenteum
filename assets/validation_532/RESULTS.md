# Issue #257 / 5.3.2 — automatic provisions

GZDoom 4.14.2, Windows 11, Vulkan, fixed RNG seed 184, native background
simulation, 5% master audio. Tests are isolated from personal saves; only
`src/` is packaged for production. Baseline: 5.3.1 commit `359009f0`.

Implementation and author decisions: SYSTEMS, section 5.3.2. The saved owner
is the existing InterHub RestState, additive provision revision 1; forecast
revision 2 invalidates old copied predictions. Existing native powers and
inventory remain authoritative. Original slots are retained for rollback.

Native probe coverage: exact 50 / 49.9, independent and simultaneous channels,
in-flight exclusion, natural overshoot and repeated threshold crossings;
chairs, beds, owned bag, ground rest and spell sleep; rest pauses and repeated
input; full resources; posture exit; table/carried/owned Box priority, unowned
Box rejection, empty container and final partial sip, finite table stack and
inaccessible table. MAP01 native authored furniture and refill are checked
separately, including explicit time-skip start/completion.

Forecast checks compare actual quantities and effect cadence over 1,200 shared
personal steps for standing/seated/sleeping states. A separate isolated
digestion comparison verifies exact resource and Sleep-cost equality. The full
cold-map simulation has a **pre-existing limitation**: evolving thermal costs
are not included in the time-skip supply model. Its hunger/Sleep differences
are retained in the logs; matching portion counts do not prove an exact
thermal/calendar forecast. Thermal behavior is unchanged by this patch.

Direct API probes are engine integration checks, not ordinary player input.
Native keyboard/mouse observations and author acceptance are recorded separately.
The live user activated x105 and orbited the camera; the reviewed Spanish
capture shows both channels ON and both resources at 100%. The agent's F/G
input was not delivered after the user-input guard fired. Native F/G/click
acceptance remains an explicit part of CA257-01; direct toggle integration
checks passed. The same game remains available to the author.
CA257-01 remains pending in `pending_test.txt`; #258 exhaustion induction is a
separate issue, beyond the ground-rest eligibility tested here.

Eight completed runs passed **74 native assertions**. Static validation returned
`errors: []`; normal packaging succeeded with 16,054 files. Old/current saves,
idempotent migration, paused-state reload, MAP03/MAP04 hub travel and reopening
the unchanged original in 5.3.1 are included. The original save SHA-256 is
verified against both migration input and rollback input.

Final command results, run fingerprints, retained logs and the reviewed capture
are listed in `evidence.json`. Fixtures/PK3s and save files remain
local under `build/issue257`; no engine, IWAD or save is distributed.
