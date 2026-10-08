# Issue 143 / 5.1.6 validation

Baseline: `5e550484f1a6c9cc7101dae37e8daaa8e47d03c2` (#135 / PR #144).
The author requests completion, commit/push and integration/closure if verified.
CA143-01 remains separate manual visual/gameplay confirmation, not inferred from
this engine suite or merge authorization.

## Environment and scope

GZDoom 4.14.2, Windows 11, Vulkan 1280x720, seed 116, 5% master volume,
background unpaused. Exact arguments, engine/IWAD/package hashes and native
exit codes are retained per run. Local test packages, saves, IWAD, executable
and debugging process data are not distributed. No mass siege retest or FPS
claim is part of this patch. Engine fixtures contain diagnostic-only setup,
fixed targets and counters outside src; ordinary production rules remain active.

## Final engine checks

| Run | Result |
| --- | --- |
| checks-final | 23 checks: valid native sprite registration; actual half-height collision and lowered projectile origin; one round/Air payment; crouch and aim accuracy factors, critical cap and spread; invariant physiological height/area; correct firing sprite; independent player camera; stationary/moving reload progress; movement, pain, sleep, stun, resource recovery, melee, low-ceiling clearance, walls and death. |
| checks-release | The same 23 checks compile and pass on the final standard development PK3 after the required diagnostic release labels are updated to 5.1.6. |
| checks-reload-final-b | Current crouched/aimed state, actual height, holder, magazine and partial reload survive native loading; 23 checks finish successfully. |
| checks-hub-final | Native map departure/return retains crouched collision, original height, holder and partial reload. |
| live-final | Four checks using the normal CaelumPortDefender Tick/See and siege Pulse: successive crouched/aimed shots with existing cadence, repeated magazines, real hits, wear, virtual reserve and standing after target loss. |
| visual-gallery | Six checks: every direction of all four poses reaches the scene; real player crouch/zoom/fire input spends finite ammunition, uses CAGC without double compression and restores standing CAGN. 32 gallery captures (16 cardinal views retained) plus crouched/standing player captures. |
| migration-seed | Original 5.1.5 runtime creates a revision-1 soldier with three rounds, partial reload, wear and distinct resource/thermal state. |
| migration-upgrade | Native original save loads into 5.1.6. Repeated initialization advances revision once, preserving magazine, reload, condition, timers and resources; then saves an actual crouched state. |
| migration-reload | The migrated save retains posture, holder, original height and all recorded resource/equipment values. |
| migration-hub | Native hub reopen preserves the same state without refill or duplicate migration. |
| migration-rollback | Original save reloads with its original 5.1.5 runtime and retains its snapshot. New saves are not promised to load directly into 5.1.5. |

All final runs require exit code 0 and reject native errors or any nonzero
failure marker, including persistence markers. The diagnostic runner bounds
focused runs to three minutes and retains raw output rather than treating a
passing script marker as proof of clean shutdown.

The default 80-kg soldier uses its unchanged attribute-18 profile and medium
armor. Over approximately 41 seconds of the isolated engagement it fires
50 shots, completes four reloads and lands 31 impacts on the stationary target.
It retains 2168/2168 HP, Air 1033.048781 and exposure +0.507586 at the endpoint.
The target does not retaliate; this is a bounded action/physiology regression,
not a survival or balance guarantee for an entire battle. `live-c` was an earlier
attribute-100 stress control, not evidence for the ordinary profile.

## Visual findings and rejected trials

The original 32-frame PNG is copied unchanged into src. Native TEXTURES clips
it using measured alpha gaps, foot pivots and common scale 1.909090909; no pixel
editing or Doom artwork is introduced. Source specification and attribution
are retained in assets/source/art/carbine_crouch_516. ART_DETERMINISM.json records
two identical exports, unchanged native registration and matching source/runtime
atlas hashes. Gameplay muzzle geometry uses the measured firing barrel height.

`live-a` was interrupted by the session restart. `live-b` and `visual-a` froze
while rendering CAGC, which initially had no native state registration. Local
thread-stack candidates resolved with the official engine PDB include
HWDrawInfo::RenderBSP, RenderThings and sprite processing; this is not a full
exception backtrace. Appending CAGC A-D to the existing registration actor fixes
the observed issue, consistent with CA-KP-016/017. Early equality-only sprite
checks could compare the same invalid index; final checks also require >= 0.

`visual-b` failed its aim check: the short zoom input ended before the newly
equipped weapon was ready. Holding it through readiness produces real aimed
shots (effective player accuracy 664, magazine 3 after seven shots). Early rapid
gallery captures could repeat interpolated views; the final fixture clears
interpolation, waits 15 tics per view and records all 32 angle/frame selections.
The earlier `checks-reload-final` command used an absolute save path that the
engine incorrectly prefixed with its savedir; final calls use save filenames.
These failures remain local and are not included in the passing manifest.

## Static and delivery gates

STATIC.json records the read-only project validator, synchronized 5.1.6 headers
and regenerated document index. BUILD.json and MANIFEST.json bind the final
runtime payload, normal development package and exact passing native evidence.
No map geometry changes, population rules or new balance values are introduced.
The earlier native runtime differs only in two diagnostic release strings and
their line endings; MANIFEST.json verifies that exact difference. Gameplay and
art are byte-identical to the final standard package tested by checks-release.
The temporary keep-awake request is released after verification; retained power
records show the same original Balanced power plan before and after.

To reproduce, run prepare.py and prepare_persistence.py with no engine running,
then run_check.ps1 using the respective package/addon/script and a fresh label.
Use the saved-game filename, not an absolute path, for LoadGame. Each retained
run JSON records its complete invocation and command script. CA143-01 provides
the separate interactive author inspection procedure.
