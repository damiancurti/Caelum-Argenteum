# Issue #321 - Collapsible automap legend

Release 5.4.31. Author CA321-01 pending.

Final native result: 28 assertions, no failures. Source review, validation and
build pass; all 16,371 normal package members match tested runtime/source bytes.
The large requested 1920x1080 window is fitted by Windows to 1920x1061 client
pixels; the captured result is identified by its actual size, not full HD.

The full-map help starts collapsed, retaining location/clock and independently
known POI/notes/objectives. The hint reads the actual native binding, including
AutomapBindings priority. ca_map_legend toggles locally; leaving automap,
save loading and map travel collapse it. L is a new-install/reset default only;
existing remappings and deliberately cleared bindings remain untouched.

Native checks use GZDoom 4.14.2, Windows 11, Vulkan, unpaused background and 5%
audio, one engine at a time. Commands exercise togglemap, ca_map_legend,
bind/unbind/mapbind/unmapbind, save/load and hub changes. Captures cover 1280x720,
1024x768 and 1920x1080 with larger UI scaling; actual recorded resolutions and
configurations are retained with results. No geometry or balance changes.

The first native run exposed use of EventHandler.Find for a static handler;
StaticEventHandler.Find fixes the production lookup. Early screenshots followed
by an immediate toggle captured the subsequent frame; final scripts wait after
each screenshot. Both attempts are retained, not counted as final validation.
Visual review also found the existing automap Spanish block used only `esp`,
while the user selects `es`. The affected block now declares both aliases;
final checks explicitly assert the configured hint language. Unrelated existing
notes text is not relocalized by this patch.

Reproduce using prepare.py --directory issue321-recheck, followed by
assets/validation_5422/run_native.ps1 -Directory issue321-recheck and -Script
ui.cfg, save.cfg, then load.cfg -LoadGame legend.zds with distinct -Label values.
For author testing, use manual.cfg -Interactive -Language es; M opens the map,
L toggles help. The preview's bindings do not alter the author's real config.

The controls generator is byte-deterministic across repeated calls and preserves
the independently maintained aliases after its generated block. Validation,
normal build, package/source equality and native assertions are recorded in
evidence.json. Packages, IWADs and saves are local fixtures, not distributed.
