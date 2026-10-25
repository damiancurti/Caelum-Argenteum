# Calendar sleep preparation - #502 / 5.8.12

On2026-10-25 the author approved pausing crafting/reading, cleaning equipped gear
before automatic sleep during calendar waiting, and resuming the same work after
waking. If equipment cleaning is already active, finish it first and exclude its
completed pieces from the new queue. Costs, order and missing-supply skips reuse
the accepted equipment-cleaning rules; no new balance was introduced.

160 executed native assertions pass across22 serial GZDoom4.14.2 runs:157 on
calendar-final01 and3 on the accepted prior runtime for genuine save creation and
rollback. Count executed PASS lines, not the cumulative counters stored in saves.
Tests cover original station/book/recipe/reservation identity, paused progress,
exact water/soap spending, existing partial cleanup, repeated sleep cycles,
missing/late supplies, movement/damage/cancellation, ordinary and accelerated
world clocks, current/previous saves, hub departure and prior cleaning behavior.
The final suite includes voluntary sleep, repair, sleeping bags and exhaustion
wake regressions. Static validation passes; no unresolved native failure remains
in this scope. Native Spanish captures of preparation/sleep/resumption were inspected.

Calendar hygiene revision1 stores its own bounded queue of at most nine equipped
pieces without replacing the original craft. Previous sleeping saves continue
without retroactive washing; their next cycle uses preparation. A saved calendar
waiting for an existing manual wash also resumes without duplicating charges.
Forecast revision18 invalidates old caches and explicitly refuses an exact-date
estimate when its model cannot represent pre-sleep cleaning. Manual destinations
and ordinary progression remain available. This is a documented forecast limit.

The ordinary-clock probe exposed a real integration defect: critical fatigue
directly subtracts health, which the calendar interpreted as external damage.
During preparation only, fatigue loss now uses the existing periodic-loss
accounting if neither Hunger nor Thirst is critical. Damage still occurs; attacks,
critical needs and death retain their safety stops. Final live and edge tests pass.
Other probe corrections concerned diagnostic types, native inventory removal and
observing work at the exact calendar completion boundary. Details are in report.json;
earlier failed logs remain under ignored build/issue502-hygiene. A capture needed
five render tics after its last screenshot command before quitting.

Package calendar-final01 SHA256:
`2d5337795cec9f1d35c43a4bc29f337dace8219a09501d08e6f76b8ee689c8b4`.
All16,893 members match source bytes. All169 maps and13,826 art members match the
accepted wake-final01 baseline. No artwork changed. The diagnostic generator is
deterministic. Reproduction commands, hashes, configuration and hardware are in
native/*-run.json. Run prepare_calendar.py, then run_native.ps1 with fresh labels
and the recorded script/addon/save names. Old-save seed/rollback use wake-final01.
collect_calendar.py retains evidence without distributing engine/IWAD/test PK3s
or saved games.

The manual fixture holds acceleration to make phases observable; the accelerated
path has its own independent test. Crafting/reading tasks are seeded native tasks,
so this suite does not claim end-to-end recipe acquisition UI validation.
Real exposure and automatic drinking continue. F1/F4/F5/F7 reset supplies for
each author scenario; F2 reports them without resetting. Functional checks and
captures do not establish multiplayer or campaign-wide FPS/presentation acceptance.
No new global actor scan was added.

CA502-CALENDAR-01 awaits author confirmation in author_calendar_terminal.ps1.
CA502-WAKE-01 is explicitly accepted in26e1327d. Toilet/treatment author checks
remain separate. Other-actor/combat transfer and NPC housekeeping are unfinished;
this continuation does not complete #502 or V5.8.
