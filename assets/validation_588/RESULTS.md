# 5.8.8 / #411 - Safe placement of carried chests

The existing carried-chest placement action now checks the complete native
collision volume and dry, stable support before mutating the real chest. Local
solid actors, steps, low ceilings, liquid terrain, 3D water, open door lines and
map transitions reject placement. A retracted sliding door retains its closed
access area. Native door clearance uses the player's existing collision radius;
support tolerance reuses the sleeping-bag check's 1 MU tolerance.

This report records the initial geometry stage at c27d813e and its original
complete package. Subsequent tent deployment/artwork has separate evidence in
the tent and deploy subfolders. The geometry stage itself adds no ownership
policy, rest bonus, art, map geometry or item balance.

## Evidence

46 PASS in nine selected native runs on Windows 11 / GZDoom 4.14.2, Ryzen 9
5950X, RTX 3070 Ti, Vulkan, 1280x720, background/unpaused at 5% audio:

| Run | PASS | Scope |
| --- | ---: | --- |
| core07 | 26 | Native support/volume/actor/access checks, narrow water strip, 3D water, dry 3D support above water, sliding door, segment geometry and probe cleanup |
| storage02 | 7 | Real chest carry/place, atomic rejection, preserved exact cargo and contents |
| save02 | 1 | Original carried chest and contents saved |
| load02 | 2 | Native restoration of chest/cargo/content references |
| hub02 | 6 | Actual chest and contents preserved before travel, at destination and on return |
| legacy-seed02 | 1 | Original 5.8.7 package creates the carried-chest save |
| legacy-load02 | 1 | Unmodified original save loads; new placement rejects a step without losing contents |
| legacy-rollback02 | 1 | Original save still loads with the original package |
| handoff03 | 1 | Final package/author controls: three rejected sites, dry-ground placement and three retained items; log outcomes also checked by collector |

core01/core02/strip03 retain the failed narrow-strip probe. A native
TestMobjLocation inside a live BlockLinesIterator caused subsequent local lines
to be skipped. Finishing the iterator into a bounded local snapshot before
collision queries fixes it (core04: 23 PASS, then core05 adds both 3D cases).
The intermediate point-sector terrain guard alone did not fix that failure.
See CA-KP-159 for the verified constraint; no failed run counts as acceptance.
handoff01 is also retained: its private console message mixed Name/String
conditional operands; matching the types fixes compilation in handoff03.

bridge06 additionally exposed a false rejection above a basement step: the
continuous solid 3D support is authoritative, not its lower base-sector plane.
The final service uses native FloorZ on both sides; core07 includes that
regression. Earlier private fixture/save variants are retained as experiments;
the selected final save/hub/legacy runs use the final fixture geometry and
fresh save filenames. The runner preserves each final addon alongside its log.

collect.py checks every final package member/byte against src and verifies that
all runtime bytes match the tested probe04. Full commands/configuration, engine/IWAD
hashes and raw logs remain under native/. Private PK3s, fixture WADs and saves
remain under build/ and are not distributed. No recurring global scan is added:
queries run locally on an explicit placement attempt. No frame-rate claim is
inferred from successful geometry assertions.

## Reproduce / author handoff

prepare.py builds the deterministic private addon; an optional fresh directory
argument also packages a complete source probe without overwriting older
evidence. The final build uses build_dev.ps1 and
build/issue411-placement/current/caelum_argenteum_dev.pk3. run_native.ps1 accepts
core/storage/save/load/hub scripts; load/hub use ca411p-final.zds.
Legacy runs require the full preserved 5.8.7 package bf9cb340 and the generated
baseline/bridge/rollback legacy-checks.pk3 variants with ca411p-legacy-final.zds.

CA411-PLACEMENT-01 is pending. author_terminal.ps1 is prepared but was not
launched during the requested absence. It offers an interactive private chest
room and the isolated checks. This does not replace the accepted housing tests
or the separately pending camp-equipment artwork/acquisition checks.
