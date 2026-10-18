# 5.4.38 / #321 - Complete top-aligned legend

Five native runs pass 28 assertions on GZDoom 4.14.2, Windows 11, Vulkan,
background unpaused, 5% audio, one engine at a time. Spanish/English 1280x720
and Spanish 640x360 captures were inspected: the collapsed cartography draws
only its localized show hint; expansion begins at its existing 8-pixel top
margin and the small view wraps above the bottom HUD. Other HUD widgets and
native notifications are independent and remain visible.

Real console commands exercise default/rebound/shadowed/unbound keys, map
close/reopen, save/load and a hub transition. The actual saved game is loaded;
its hash is archived, not the private save. Discovery and tracking data are not
mutated by the rendering-only change.

Author acceptance: CA321-02 (origin 5.4.38 / #321) passed on 2026-10-18, with no
reported qualifications, after the current 5.4.40 preview. This confirmation
does not change the original native run counts or tested-runtime hashes.

Reproduce with prepare.py --directory issue321-panel-recheck, then the shared
assets/validation_5422/run_native.ps1 using distinct labels for ui.cfg in es/enu
and small resolution, save.cfg, and load.cfg -LoadGame legend.zds. manual.cfg
is an interactive preview. Preserve manifest/configurations and completion
markers; archive.py checks all tested/source/normal package members.

The evidence contains frozen probe sources, commands, launch/config hashes,
compressed logs and inspected PNGs. Runtime packages, IWAD, engine and private
saves remain local. Validation and the normal build passed; all 16,375 package
members agree with the tested source. No gameplay or geometry change.
