# #419 / 5.9.2 private port dialogue

Implemented native post-rescue conversations, private per-character/per-stage
Empathy results, private membership/aid declarations and separate explicit
faction reports. Existing tutorial rules and original USDF node indices remain
unchanged. No new membership acquisition or story revelation belongs to this
patch. Joining is the next focused #420 integration; story and quests are #421/422.

## Verification

- Static: validator zero errors, fresh dialogue/localization/document indexes,
  diff whitespace check. Original runtime.usdf remains an exact byte prefix of
  the appended runtime, preserving saved native conversation node indices.
- Native: GZDoom 4.14.2, Windows 11, Ryzen 9 5950X, RTX 3070 Ti, Vulkan;
  unpaused background, 5% audio; requested 1280x720, desktop-scaled 1520x825.
- legacy-dialogue-01: 3 PASS; saved a real open representative conversation
  under the preserved 5.9.1 runtime.
- final-migration: 39 PASS, no FAIL; loads that original save, checks unchanged
  tutorial probability, four stages, cached rolls despite attribute changes,
  private witness/character separation, true membership declarations, explicit
  reports, one-time sanctions, interruption by hostility and actual hub travel.
  Its final map-local counter is 38 because hub restoration restores that counter;
  evidence counts all 39 emitted assertions.
- final-reload: 4 PASS; current save retains results, knowledge and sanctions.
- final-ui-es: 4 PASS through native menu replies, not only direct helper calls.
- final-ui-preview: 3 PASS; inspected the native Spanish chance and result pages.
  The visible 83% replaces the placeholder; accents and choices remain readable.
  Screenshots are diagnostic evidence, not a new appearance approval.
- final-rollback: the untouched original open-dialogue save still opens with
  its preserved 5.9.1 package/fixture. No new assertions; saved counter is 3.
- Author acceptance remains pending the complete V5.9 manual handoff.

The runtime only checks the active participant and fixed faction/prisoner
slots. It adds no actor-population scan. These isolated scenarios do not measure
frame presentation or establish a displayed-FPS claim.

## Reproduction and failed probes

Build to build/issue419/current/caelum_argenteum_dev.pk3, run prepare.py, then
run_native.py using the exact commands/load basename in evidence.json and new
labels. Original saves, packages and failed logs remain local under build/issue419.
No engine, IWAD or diagnostic PK3 is distributed.

The first UI fixture used an unqualified menu constant and did not compile;
Menu.MKEY_Enter corrects it. A hub assertion initially stored its expected roll
in a map-local handler; a traveling diagnostic receipt now supplies the reference.
An interruption assertion initially mistook the subsequent queued narrative
voice for the representative; it now verifies the specific participant and
rejects stale actions. A deferred screenshot initially ran after the next menu
action; final-ui-preview waits for capture before proceeding. All final cases
above use the final runtime hash recorded in evidence.json.
