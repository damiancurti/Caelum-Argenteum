# 5.4.3 / #254 - MAP02 rat movement and audio

Baseline: `3d07bb87` (5.4.2 / #261). This patch restores rat movement and adds
four original procedural cues. It does not change populations, combat balance,
map geometry or other actors' melee sound defaults.

## Native evidence

Windows 11, GZDoom 4.14.2, Vulkan, isolated configuration, unpaused in background,
5% audio. Final `build/issue254-release/release-01` passes **11 assertions**,
exit 0, without script/VM errors. Production SHA-256:
`0aadf92c7b571e5a44542e784f8c2ac88943c749d91391b5dc84f29c1853358f`.
Probe SHA-256:
`fc934207e358abfea58ca142647e1e93f42299f9c8c5826310353841412c64e3`.

The unmodified 5.4.2 baseline had zero Speed and CombatBaseSpeed on all 192 rats.
Original rats 48000, 48048, 48096 and 48144 had sight/target, full Air and no
sleep/stun/recovery gate, but moved zero units. Package-only initialization
instrumentation observed an early health recalculation before PostBeginPlay
captured Speed. The final rat-only repair restores the class default before that
capture. All 192 now have positive speed, all 96 Mandingas remain, and each of the
four original rats moves 60 map units through ordinary detection/chase and bites.
No fixture creates replacement enemies or forces those pursuit states/targets.

The final probe observes actual recognition and bite sounds, checks the native
Pain-state cue and kills an original rat to check death audio. Peak alert voices
were 12 globally and 1 within the measured 256-unit neighborhood. Each alias uses
GZDoom's local three-instance/512-unit limit. This is not a global mix cap or an
author listening judgment. Distance attenuation uses the native positional path.

All four PCM outputs regenerate byte-for-byte, with peak 0.3199768 and zero
endpoints. Generator parameters, hashes, durations, RMS and original provenance
are in rat_audio.json and the referenced source/license files. No external
recording was downloaded or repackaged. The final Spanish manual preview was
inspected with the rat framed by a downward-looking camera.

## Save and travel evidence

The compatible session fixture creates a save on the old runtime using original
rats: 191 living, one dead body with its one-time water drop, one sleeping rat,
one reduced-Air rat and a positive custom base-speed sentinel of 7. No real
campaign save is used. `seed-old-02` passes on the old package. Final-runtime
`old-to-new-02` repairs the missing base to 10 while retaining 101 Health,
nonfull Air, sleep, body identities, the drop and the custom base. `reload-01`
passes on the resulting new save. `rollback-01` loads that new save on 5.4.2
and preserves the same properties. `hub-01` follows MAP02 -> MAP03 -> MAP02;
all body/drop/sleep/custom-base checks pass and Air regenerates normally.

Exact commands, engine/runtime/fixture/log hashes and completion markers are in
evidence.json. Paths are expressed relative to the repository or as local engine
inputs. New saved state is one revision field on the existing rat class; the
migration is idempotent and no class/geometry replacement is required.

## Earlier failures and limits

A Tick-only trial failed fresh spawns because PostBeginPlay had already marked
the revision; the final implementation separately covers new and saved rats.
An initial audio assertion wrongly treated the native limit as global and counted
distant/virtual voices. The corrected local assertion passes. Earlier packages
and logs remain preserved, not recategorized as successful final runs.

This is focused native evidence. Physical input, narrow-walkway pursuit and the
artistic quality/spatial mix of the sounds await **CA254-01**. The author is away;
no interactive handoff, manual pass, merge or closure is inferred. Final fixture
source includes only a manual-camera adjustment after the migration checks;
`preview-02` compiles and runs that fixture against the same final runtime.

## Reproduction

Use a fresh directory; engine/IWAD are configurable launcher parameters. Packages,
saves, executables and development IWAD remain outside tracked delivery.

```powershell
python assets/validation_543/prepare.py --directory issue254-recheck
powershell -NoProfile -ExecutionPolicy Bypass -File assets/validation_543/run_native.ps1 -Directory issue254-recheck -Label contract
```

After the author's return, run the launcher with `-Fixture session.pk3 -Script
manual.cfg -Interactive` and a fresh label. F6 cycles original MAP02 sections,
F7 applies a small test hit and F8 kills the selected rat. The fixture protects
the player and never respawns rats. pending_test.txt owns the author steps.

## Static validation and packaging

The documentation locator was regenerated after the canonical updates. `python validate_project.py` passed with `errors: []`, 2,480 CONTEXT
words and 111 audio files. Normal `build_dev.ps1` passed with 16,079 files and
zero directory entries; every member equals the final native-tested runtime.
`git diff --check` passed. No accepted manual
entry was removed, and unrelated local dirt remains untouched.
