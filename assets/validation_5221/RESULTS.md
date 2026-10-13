# Tutorial gold visibility - issue #216 / 5.2.21

Baseline: 7f801d41, GZDoom 4.14.2, Windows 11. Isolated INIs and saves;
background simulation unpaused, 5% master audio, temporary thread-scoped
keep-awake request. No user configuration or save is changed.

The fresh MAP01 actor exists at (1780, 640, -384), on floor -384 with ceiling
-64, alpha 1 and 2000 resource units. Its radius/height are 46/56. The only
solid actor in the scanned basement bounds apart from the player is that rock;
the legacy CaelumMainM00SupplyChest is absent. The author confirmed that the
reported obstruction is at this same rock position. This identifies the same
visibility defect; it is not yet author acceptance of the corrected build.

MODELDEF registered CaelumVeinGold but not its finite tutorial subclass. Paired
native captures from the same camera show an invisible rock before the change
and the reused gold OBJ after it. No art generation or gameplay data changes.

Native resource checks invoke the existing Pickaxe extraction resolver, collect
exactly 2000 one-gram units, observe depletion, and save/reload in a new engine
process. The rock and legacy chest remain absent and exactly 2 kg remain in
inventory. This is an isolated engine check, not author acceptance of physical
mouse input or the corrected visible passage.

Reproduce: python assets/validation_5221/prepare.py; use run_native.ps1 with
probe.cfg and -Baseline for the prior view, harvest.cfg for the corrected view
and extraction, then reload.cfg -LoadGame depleted.zds. The runner checks the
CA216 completion/failure markers. Generated PK3/INI/save data stays in build.

Early camera attempts south of the cave geometry were not valid visual evidence;
the final camera is north of the rock, looking south. An initial load command
with an absolute save path failed because GZDoom prefixed -savedir; the repeated
load uses the saved filename. These fixture setup errors did not require game
changes. Only selected final captures/logs are retained here.

Final evidence: final-before-gold.png, final-harvest-visible.png and
final-harvest-depleted.png; the three final logs and launch records provide
package/engine hashes. Final harvesting and new-process reload share the same
production and fixture hashes. Static project validation passes. Read-only
cross-review found no implementation blocker; generators preserve the model
registration outside their owned blocks. Author acceptance remains pending.
