# 5.2.16 / #204 - Native fullscreen cursor workaround

The author approved **Vulkan with native VSync enabled** after two successful
fullscreen startups, MainMenu/Options/creator clicks and gameplay/menu capture
transitions. CA204-01 passed on 2026-10-12 for the recorded installation.
The author then requested commit, push, issue closure and PR merge.

Only `vid_vsync=false` -> `vid_vsync=true` changed in the existing local
`build/gzdoom.ini`; every other byte was preserved. The original remains in
`build/issue204/user-settings-before.ini`. The tracked patch documents this
native setting and evidence; it does not change launcher defaults, ship a user
config or patch the engine. Required diagnostic strings carry the new release.
VSync can add presentation latency; the author chose it with this explained.

## Environment and evidence boundaries

Accepted baseline cd712377 (#150/PR203), GZDoom 4.14.2, Windows 11, NVIDIA
GeForce RTX 3070 Ti, OpenGL driver string 576.88; fullscreen 1920x1080.
The local development Doom II IWAD and installed engine support files were used.
The original production PK3 contains 13,559 entries. Runs retain package/engine
hashes in runs.json; initial-config hashes are retained where recorded. Retained
logs replace installation paths with placeholders and use UTF-8 LF; both raw
and retained log hashes are recorded. The
first baseline lacks a timestamp/config hash; null is not inferred evidence.

Tests used disposable INIs copied from the actual run_dev.bat configuration,
5% audio and unpaused background simulation. Menus retain their native pause.
No power-plan change or keep-awake request was made for #204. No INIs, saves,
executables, engine source copies, IWADs or generated PK3s are distributed.

Physical cursor visibility and click/capture results are explicit author
observations in author-observations.json. Fullscreen Computer Use captures
unreliably showed other desktop windows, so they were not used to assert those
results. Native engine screenshots do not include the OS cursor. CVar queries
establish requested settings, not that an unfocused display transition was
presented. The author stopped Computer Use with physical Escape twice; input
work stopped each time and resumed only after further user instruction.

## Probe results

| Run | Changed preference / action | Physical result |
| --- | --- | --- |
| baseline-01 | Original Vulkan fullscreen, VSync off | Cursor invisible |
| refresh-01 | Reassign vid_cursor None after ten seconds | Still invisible |
| display-cycle-01 | Request window/fullscreen cycle; later manual Alt+Enter | Still invisible in both reports |
| system-arrow-01 | Unknown cursor texture selects the native Windows arrow | Arrow also invisible; missing-texture warning is intentional |
| window-first-01 | -window flag, INI still fullscreen=true | Invalid windowed trial; retained as failed setup |
| window-first-02 | Explicit copied INI fullscreen=false, then true | Author corrected the first answer: visible windowed, invisible fullscreen |
| opengl-01 | OpenGL fullscreen | Visible |
| exclusive-01 | Vulkan exclusive preference on | Invisible initially; appeared after Alt+Tab, not a startup pass |
| vsync-01 | Vulkan, exclusive preference off, VSync on | Visible from startup before focus/mode changes |
| vsync-02 | Fresh process with the same VSync preference | Visible from startup; three menu click routes and gameplay capture transitions pass |
| persist-01 / persist-02 | Copy approved real INI; second run reads the first engine-written INI | Native queries retain VSync=true, Vulkan, fullscreen, cursor and mouse settings; no VSync-setting command in either probe |
| official-01 | Final rebuilt 5.2.16 package, same approved config copy | Native compilation/startup and preference queries pass, then normal scripted exit |

Clicking outside a native ListMenu item clears its keyboard selection. The
disappearing Sun selector reported during a failed probe is consistent with
that native behavior, not evidence of a missing sprite.

## Reproduce the focused workaround

1. Keep the existing launcher INI and a local backup. For isolated comparisons,
   copy it to a unique path under build/issue204; never reuse the user's saves.
2. Enable **Vertical sync** in the engine's video options (**Set video mode**
   in the full options menu), or change only `vid_vsync` to `true` with GZDoom
   closed. Keep Vulkan (`vid_preferbackend=1`), the fullscreen preference,
   native cursor and existing input bindings.
3. Launch the installed engine with the project PK3, local IWAD and that INI
   through `-config`; `+exec assets/validation_5216/probes/vsync.cfg` queries
   the settings and opens MainMenu without changing VSync. The normal launcher
   reads build/gzdoom.ini. Apply the recorded audio/background test overrides
   only to disposable configs.
4. Before Alt+Tab or mode changes, check the physical cursor, Options and
   Create Character clicks. Enter play, check camera input/cursor capture,
   reopen/close the menu, then exit normally and repeat from a fresh process.
5. probes/persistence.cfg queries settings and exits automatically; it tests
   native config persistence, not physical visibility. Run a second time using
   the first process's saved INI. For the windowed comparison, explicitly set
   vid_fullscreen=false in the copied INI rather than relying on -window alone.

Restore the preference by disabling native VSync; this may restore the reproduced
fullscreen symptom on this machine. Do not restore an old entire INI over later
custom controls or other deliberate preference changes.

## Source inspection and scope

engine-sources.json records official g4.14.2 source URLs/hashes. VulkanSwapChain
selects IMMEDIATE presentation when available with VSync off, and FIFO or
FIFO_RELAXED with VSync on. The native Windows cursor uses the same existing
32x32 moon resource and hotspot (31,7); its source is unchanged. No per-frame
cursor reset or forced backend is added. These facts do not establish the
precise engine/driver root cause or guarantee the workaround on other hardware.

The local setting delta is recorded in applied-setting.json. Final build/static
verification and the diagnostic-only runtime delta are recorded in summary.json.
Author acceptance is the explicit CA204-01 record, not inferred from those checks.

Final checks: project validation passes with no errors and 2,486 context words;
the official build contains 13,559 members. Compared with the author-tested
package, only two required diagnostic release strings differ. Native compilation
and persistence checks pass on that final build. Independent read-only review
found no blocker and confirmed the one-preference local delta and retained log
hashes. All test engine processes exited; the original user audio/background
preferences remain intact in build/gzdoom.ini.
