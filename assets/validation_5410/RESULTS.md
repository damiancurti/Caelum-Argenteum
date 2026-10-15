# Battle Cry - #243 / 5.4.10

This focused patch builds on accepted #239 commit `891320f4`. Warrior User4
uses the shared three-second preparation, progressive fixed-cost debit and
release-time cooldown. Visible enemies receive a timed attack prohibition.
Movement and defense remain. Interrupting a continuous attack must not flush
its accumulated damage or release a final Quintessence burst; damage already
applied and projectiles already launched are preserved.

## Evidence and limits

GZDoom 4.14.2, Windows 11, Vulkan, one engine at a time, unpaused background
simulation and 5% master volume. `evidence.json` records exact runtime/fixture
hashes, command arguments, completion markers and exit codes. Fixtures and
development IWADs do not enter the production PK3. These are isolated engine
checks, not campaign or multiplayer acceptance.

`python validate_project.py` passes with no errors and CONTEXT at 2,414 words.
Normal `build_dev.ps1` packaging succeeds; all 16,160 members match the final
frozen production runtime byte for byte.

| Preserved directory / run | Passing checks and coverage |
| --- | --- |
| issue243-final-v2 / contract-01 | 19: Warrior admission, Arcanist-only Sleep query, actual wall/visibility, enemy/friendly/range selection, base duration, renewal, social scaling, native ticking and expiry |
| issue243-final-v2 / sleep-regression-01 | 1,021 existing #238 checks: native preparation input, payment, cancellation, release and weapon/power lockout; 3 starts, 2 releases, 1 cancellation |
| issue243-v2 / casting-01 | 3: native User4 partial payment, second-press cancellation without refund/reuse, complete release and cooldown |
| issue243-v3 / weapons-01 | 27: staff, book, statuette, bell, carbine, shotgun, bow, crossbow and javelin projectiles before/during/after intimidation |
| issue243-v6 / melee-01 | 6: native sword and bare-fist hits before/during/after intimidation |
| issue243-v6 / boundaries-01 | 9: pending attack/class cancellation, retained debit, channel stop without Quintessence burst, Telekinesis release, defense, Tarot flight, native movement and existing periodic damage |
| issue243-v6 / flight-01 | 1: native staff projectile launched before intimidation still impacts afterward |
| issue243-v5 / npcs-01 | 29: real rat, Bull, Mandinga and Zupay attack methods and resource debits before/during/after, demon channel and Bull charge interruption |
| issue243-v9 / siege-01 | 10: actual cannon requests/fire and existing shot, eligible one-operator minimum, ram complete crew and interrupted strike recovery even with an absent operator |
| issue243-v4 / save-01, load-01 | 1 / 5: player/NPC effects survive save/load, exact clock, native hub travel and return |
| issue243-v4 / save-prep-01, load-prep-01 | 1 / 2: saved partially paid Warrior preparation resumes to full release |
| issue243-v9 / preview-01 | 4: autonomous Mandinga receives native cast, leaves attack states, continues moving; caster death retains target status. Screenshot visually inspected |
| issue243-seed / seed-01 | 1: neutral old-runtime save |
| issue243-upgrade / upgrade-01 | 2: old save gains no invented effect and preserves Anima |
| issue243-rollback / rollback-01 | 2: copied active player/NPC save removes unsupported effects and preserves Anima |
| issue243-rollback-prep / rollback-01 | 2: copied paid preparation cancels without refund on 5.4.9 |
| issue243-return / return-01 | 2: migrated copy loads again in new runtime, remains inactive and preserves Anima |

The final package differs from the v2-v6 gameplay only in the reviewed ram
absent-crew cancellation, tested in v9. Final versus v9 changes restore original
comment encoding and update two diagnostic release labels; gameplay is identical.
The final contract compiles the final runtime. Existing #238 native lifecycle
coverage is reused as a focused regression because admission moved to the shared
class dispatcher; its outcome is recorded in evidence.json.

Earlier failures remain preserved and are not passing evidence: v1 casting
had no release tic between button presses; v5 boundaries selected a sword with
no shield and watched the wrong periodic DamageType. V6 corrects those fixtures
using real gauntlet defense and CaelumElementalDOT. V7/v8 preview compilation
failed on UI-scope access and Name/string mixing; v9 fixes only the overlay.
No production balance workaround was introduced for these fixture failures.

## Reproduction and saved games

Run `python assets/validation_5410/prepare.py --directory <fresh-name>` and then:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File assets/validation_5410/run_native.ps1 -Directory <fresh-name> -Label contract-01 -Fixture cry.pk3 -Script contract.cfg -Map MAP99
```

Other generated scripts are casting, weapons, melee, boundaries, flight, npcs,
siege, save/load, save_prep/load_prep, preview and manual. Load scripts use
`-LoadGame cry.zds` or `preparing.zds`. The native runner refuses an existing
GZDoom process instead of replacing a user's game.

The new recipient inventory carries revision 1; old saves contain no such
inventory. Save/load does not reapply or repay the cast. `prepare_compat.py`
accepts `--mode seed|upgrade|rollback|return`, a frozen runtime, fixture and an
optional source save. It copies all inputs into a fresh directory. Its rollback
stub is **only for 5.4.9**: unsupported Battle Cry effects and preparing casts are
cancelled, without returning spent Anima. Keep the original saves/runtime to
reverse that transition; the old runtime cannot maintain unsupported effects.
This evidence does not claim compatibility with every historical release.

## Author check

CA243-01 remains in root pending_test.txt. `launch.ps1` opens the isolated game.
F casts/cancels, F6 resets, F7 intimidates the player for ten seconds, F8 switches
gauntlets/staff, F9 cycles Mandinga/rat/Bull/Zupay, and B blocks with gauntlets.
The overlay shows preparation, resource, reuse and both intimidation clocks.
The fixture fixes 40 m/10 s/1000 Anima, disables regeneration, makes the player
invulnerable and creature immortal, and replenishes NPC resources. These are
test settings, not production balance. No physical author acceptance is claimed.
Automatic policy previously rejected persistent PowerShell `-NoExit`; the direct
reviewed launcher can open the game without creating a separate persistent terminal.
