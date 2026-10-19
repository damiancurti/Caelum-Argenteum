# V5.5.4 / #313 — ammunition mass

The author approved **40 g carbine / 45 g shotgun** complete-cartridge design
approximations, a 12-bore paper shotgun reference, and finished-component assembly
for V5.6. Exact constituent weights remain pending. These values are not claimed
as measured historical facts; no recipe or new material interaction is introduced.
The canonical contract and qualified historical references are in SYSTEMS,
"Ammunition composition and mass contract (#313, 2026-10-19)".

## Scope

Production changes the carbine mass constant and separates the shotgun constant,
native override and shared type lookup. The accepted 5.5.3 package has the same
16,380 member names; only these three sources and two diagnostic release labels
differ. Projectile classes, magazines, damage, shields, armor penetration,
ideology exclusions and native physics are byte-identical.

Normal final runtime SHA-256:
`faf4d3e0b391533316c0a0d68300758e73987a5959f4d30385ad0a02c9bc46a9`.
Accepted 5.5.3 baseline:
`4693f37eb27a0d3bd7502f8c6bb4f379ac697243dbd69e3d606b9040d329a5de`.

## Native evidence — GZDoom 4.14.2 / Windows 11, 2026-10-19

**12 required runs, 1,323 new PASS checks, zero FAIL.** report.json contains the
gate results, command/fixture/runtime fingerprints and serialized save extracts.
The collector counts newly emitted PASS lines, not cumulative saved-handler
counters. Runs use one engine at a time, unpaused in the background at 5% audio.

| Coverage | New checks | Result |
| --- | ---: | --- |
| Native/shared weights, selection, first/existing stack capacity, Box fallback and transfer, drop/repickup, arrow/bolt controls | 65 | Pass |
| Native R and Fire for carbine, shotgun, bow and crossbow | 32 | Pass; reload debits zero, shot debits exactly one unit; shotgun emits 12 pellets |
| Reused #192 launcher/impact/armor/shield/Toughness matrix | 1,028 | Pass; four ranged families, three tiers, ideology exclusions and actual arrow/bolt collisions |
| Current save creation and cold load | 35 | Pass |
| Genuine 5.5.3 save creation, upgrade, upgraded reload, original rollback and upgraded rollback | 134 | Pass |
| Hub return: ammunition counts, locations, summary and partial magazines | 29 | Pass |
| Visible preview setup and screenshot | 0 numerical checks | Separate visual check; not author acceptance |

Both save baselines contain 100 units of each of the four distinct ammunition
classes and partial carbine/shotgun magazines (7/1). Updating the old checkpoint
changes its carried summary from 22.600 to 30.500 kg, automatically in normal Tick,
without a fixture refresh before the assertion. No serialized field is added;
the original checkpoint is retained byte-for-byte. Upgraded saves also reopen
under the old runtime and recover its old weight rule.

The persistence fixture launches a real production missile and suspends it with
STAT_STATIC. Save/load checks retain its velocity, prepared damage, type, tier and
missile flag. **This verifies serialization, not resumed flight/impact.** The hub
test covers inventory/magazines only: the injected static missile is absent on
return and is not used as a hub-persistence oracle.

The ranged matrix reuses accepted validation_5210 fixtures; the inventory/input
setup reuses validation_550. Weight expectations and ammo debits are independent
literal test oracles. Independent AI review found no production blockers; the
collector also rejects duplicate required labels.

## Fixture corrections and limits

Exploratory failures remain in evidence and are excluded from passed gates:
protected TryPickup/UI-scope compile errors; selecting an old pickup-animation
object instead of the newly dropped stack; a duplicated absolute load path;
a stale fixture equipment ItemId selecting the weapon instead of ammunition;
the incorrect hub missile expectation; and preview scheduling/manual-mode fixes.
The final fixture calls CallTryPickup, identifies new world objects by identity,
clears the selected equipment ID, and keeps delayed CFG commands on one line.
The preview HUD uses a separate static handler; the manual-mode argument no longer
shadows its case-insensitive saved field. None required a production fix.

All required runs use the final production package except the explicitly pinned
old-save and rollback runs. Fixture revisions are frozen individually. No claim
about FPS, multiplayer, full metallurgy or unassigned component data is made.
Heavier ammunition can increase existing encumbrance; counts are never reduced
to force an old inventory under capacity. The existing loaded-magazine/Box rule
is retained, not redesigned into separate magazine storage.

## Reproduction and acceptance

Run `python -X utf8 assets/validation_554/prepare.py --directory <fresh-name>
--runtime build/caelum_argenteum_dev.pk3` from the repository root (one command).
Use the shared assets/validation_552/run_native.ps1 with the frozen directory,
fresh label and the matching qa.pk3/CFG. ranged.cfg uses ranged.pk3. For cold load,
pass a save basename relative to that directory. Preserve original runtime/save
pairs; do not overwrite them. collect.py validates the recorded delivery runs.
Only scripts, logs, configuration and hashes are tracked; no IWAD, executable,
runtime package or save fixture is distributed.

Normal packaging and project validation pass. CA313-01 remains in pending_test.txt
for author verification. preview.ps1 opens the game with F6 carbine, F7 shotgun,
F8 Box transfer and F10 reset; R reloads normally. Author acceptance is separate
from all agent checks above. #314–315 remain separate and #316 stays deferred.
