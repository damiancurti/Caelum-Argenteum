# Issue 135 / 5.1.5 validation

Baseline: `5f9202ad42f3dd0750f5368e2e15b28d98fac4a5` (#140 / PR #142).
Implemented on the focused issue-135-demon-breath-potions branch. Author
acceptance and merge/closure remain pending; see CA135-01/02 in pending_test.txt.

## Environment and boundaries

Native GZDoom 4.14.2, Windows 11, Vulkan 1280x720, seed 116, 5% audio,
background unpaused. Every final native run requires exit code 0 as well as
passing script markers. Engine/IWAD hashes and exact commands are in each
run JSON. Fixtures stay outside src; packages, saves, executable, IWAD and the
reported minidump remain local and are not distributed. No mass siege test
or presented-FPS claim is included.

## Mechanics and persistence

| Final run | Result and scope |
| --- | --- |
| potions-final-a | 37 checks: native use of nine typed doses, finite 6/6/6 stocks, idempotence, weighted partitions, actual death/drop priority, one-unit loot, player pickup, trade eligibility, weight/prices and player Energy Air plus Sleep. |
| potions-reload-final-a | 38 checks, including partial native powers and spent stocks across save/load, then correct ten-second totals. |
| consumption-b | 6 checks: native Box store/retrieve, typed stack drop, early cancellation without expiry bonus, all six doses of every family exhausted after more than 60 seconds, no refill on repeated initialization. |
| breath-art-b | 18 checks: strict half-resource boundary, concurrent families and waiting; reduced real-tic cost exactly once; contact burn versus radiation beyond range/outside cone; actual self-energy, unaffordable stop, cold activation/stop, sleep, resource retreat, death and restoration from a later animation phase. |
| integration-art-a | 8 checks using ordinary AI: both cold emitters, unfunded control, living boss retreat without loot, native wall obstruction, actual warming and concurrent natural Anima regeneration. |
| ability-reload-art-a | Native active-source reload retains emitter ownership and paid residual; subsequent eight integration checks pass and engine exits cleanly. |
| ability-hub-art-a | Native map change/reopen retains the active source, paid residual and empty spent stock; clean exit. |
| migration-seed-final / migration-upgrade-final | Original 5.1.4 save and ongoing legacy power load into current runtime. Revision 1 supplies once; two initialization calls retain stocks and original resource/thermal state. |
| migration-hub-final | Current save and hub reopen keep 2/0/6 stocks; no refill or duplicate initialization. |
| migration-rollback-final | Reload original save with original 5.1.4 package; resource/thermal/effect state retained, exit 0. |

The original save/runtime pair is the reversible rollback checkpoint. Progress
made in new saves is not converted back into classes absent from 5.1.4; do not
claim that a 5.1.5 save can be directly loaded into the old runtime.

Health restoration loses less than one indivisible HP per complete dose:
79/179/399 against exact 79.8/179.55/399 on a 798-HP actor. Anima totals on a
1210-point bar are exactly 121/272.25/605. Energy uses the NPC's actual Air max;
player large Energy restores half Air plus 50 Sleep. Native Powerup expiration
previously skipped the tenth pulse: new metadata completes it only at natural
expiry after nine delivered pulses. Older saved effects keep their old behavior.

In the final normal-AI cold comparison, breath raised exposure by 0.295474036
relative to the unfunded matched control over ten seconds. Mandinga received
314.342955524 J and Zupay 1283.479881551 J through the authoritative thermal
pipeline; 29.339619048 Anima regenerated while emission was being paid.
These values prove actual heat and concurrent regeneration in this control,
not immunity to arbitrary cold or a calibrated universal safe temperature.

## Visual review and the reported direction defect

`visuals-art-c` shows all nine distinct world items and both dedicated
four-phase/eight-direction exhalation atlases. Native observed frame mask 15
for each proves that all four body phases advance. Retained potion-tiers.png,
mandinga-breath.png and zupay-breath.png show the current presentation.
Original ImageGen PNGs, references/prompts and registrations are in
assets/art_source/potions_515 and demon_breath_515. No Doom artwork is added.

The initial eight-direction idle orbit was correct. The author's specific
ground-slam report exposed reversed source order in ZUPY D/E/F/M..R, including
pain and rock casting. Only these native texture mappings are reversed:
2/3/4/6/7/8 use source 8/7/6/4/3/2. Source PNGs, idle/run/walk, front/back,
attack timing and AI angles are unchanged. `orientation-fixed-a` produced
24 fixed-angle captures across three groups of four poses; representative
cardinal captures are retained as zupay-actions-*.png. Idle orbit captures
remain as zupay-orientation-*.png. This corrects the identified registration
error; final subjective animation/direction acceptance is still the author's.

## Reported native shutdown crash

The supplied archive corresponds to integration-b: assertions passed, then
shutdown crashed. CRASH_ANALYSIS.json records report/PDB hashes and the exact
symbolized chain: ClearLevelData -> DestroyAllThinkers -> SetState -> A_Look ->
P_LookForPlayers -> isTargetablePlayer. The breath destructor incorrectly
restored Spawn, executing AI after player teardown. Destruction now detaches
owned flame/visuals without AI state actions or heat integration. Ordinary
interruption still settles paid thermal energy.

integration-art-a, ability-reload-art-a and ability-hub-art-a verify normal
quit, active-source reload and map teardown/reopen with exit 0. The old
integration-b and ability-reload-a records are explicitly rejected as clean
runs. A passing gameplay marker is not proof of a clean native exit.

## Bounded incremental cost

Sixteen normal NPCs, 0/4/16 simultaneously emitting, 1050 scheduled measurement
tics, sources behind the camera. Same production hash for all three runs:
9844ACE941F5A4082A1F421FE885D5937283F6A21472A447F8F9A111B983E2DE.
The only later runtime edit is Zupay action texture registration; this control
uses Mandingas and its code/art/geometry are unchanged.

| Active sources | Process CPU seconds | Observed wall window, seconds |
| --- | ---: | ---: |
| 0 | 4.000000 | 30.3136 |
| 4 | 5.312500 | 29.3626 |
| 16 | 5.890625 | 30.3730 |

This is aggregate GZDoom process CPU sampled at roughly one-second boundaries,
not isolated VM function cost or presented FPS. Window granularity and Windows
background activity prevent precise per-emitter or linear scaling conclusions.
It records incremental work; it is not evidence of dense-battle fluency.
Individual potion inventories/resources/contact remain intact in normal AI,
including accepted automatic mass-combat mode. Diagnostic-only passive actors
are excluded explicitly; no population or targeting rules were changed.

## Static, deterministic and packaging gates

STATIC.json: validator passes, release markers 5.1.5, 2491 context words,
no errors. Document index regenerated. Git diff whitespace check passes.
ART_DETERMINISM.json: two byte-identical potion exports and native atlas/direction
registrations, source pixels unchanged. GENERATOR.json: two byte-identical
MAP02 generator runs; existing WAD, catalogue and layout manifest unchanged.
BUILD.json and MANIFEST.json bind final runtime files, packages and evidence.
Earlier dose controls retain exact run hashes; subsequent runtime changes
only affect breath/visual registration, with their own focused final checks.

Fixture-development failures remain local: deferred PostBeginPlay/counters,
protected pickup API, deferred predefined death-animation drop, lost tenth
pulse, case-insensitive local/member shadow, invalid early reload-CVar timing,
native empty inventory object after drop, and a hub fixture ticking the wrong
map. Native failures are never relabeled as passes. The first visual orbit
allowed AI to change pose/yaw; the frozen orientation fixture replaces that
portion of the evidence. A temporary missing RenderStyle semicolon and fixture
GetSpriteIndex receiver were corrected before passing runs.

Reproduce: prepare.py builds isolated addons and production.pk3; prepare_persistence.py
builds the original/current same-name runtime pair. Use run_check.ps1 with the
exact command fields from run JSONs and fresh labels. No concurrent engine runs.
The temporary thread-scoped keep-awake request does not alter a power plan.
The first request was released (power-request.json); a second request continues
through authorized follow-up #143 and its final release is recorded there.
