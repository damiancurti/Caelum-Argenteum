# 5.2.15 / #150 - Native readability and comfort evidence

Technical implementation on `issue150-accessibility-comfort`, based on accepted
merge `b36ef830` (#149/PR202). Target: GZDoom 4.14.2, Windows 11, Vulkan, local
development Doom II IWAD. No IWAD, executable, package, INI or save is distributed.
The author approved recent complete HUD notices plus last-20 Journal history.
Author visual/comfort acceptance is **pending CA150-01**, separate from this QA.

## Reproduction and retained evidence

`python assets/validation_5215/prepare.py` creates deterministic fixture and
production PK3s in `build/issue150`. `run_native.ps1` accepts a unique label,
fixture, console script, language and window dimensions. It launches isolated
configs, background simulation and 5% audio. Runs are sequential; package
replacement refuses a running engine. One-line console wait chains avoid the
engine's independent multiline execution queues. Native screenshots wait before
changing their scene. Each retained run record contains arguments and config/
package/engine hashes; raw INI contents stay local. `verify.py` checks retained
logs, dimensions and combat traces.

| Evidence | Result and scope |
| --- | --- |
| official-01 | Official build compiles and starts in GZDoom; all 13,559 packaged members are byte-identical to the tested production package |
| visual-169-01 | 1280x720 English: small/large UI and messages, HUD/thermal, Journal, creator, history, options and full-automap reticle gate |
| visual-43-02; panels-43-01 | 960x720 Spanish, small/max scales; inventory, character, crafting and appearance, creator click dispatch, history and L-remap priority |
| visual-wide-04 | Actual 1600x675 ultrawide Spanish, small/large UI/HUD/message scales and history; requested and rendered sizes verified |
| extras-03 | Ultrawide introduction and time skip, Truco/Trucazo at small/large scales; actual Begin action dispatch and native card pause preserved |
| crosshair-01 | Native red/original-pixel and blue/large reticles; off, None and chasecam captures; no custom duplicate reticle |
| combat-base-01 / combat-final-01 / combat-zero-01 / combat-high-01 | Exact same 474 per-tic state records and seven projectile records: movement, angles, health, air, Anima, adrenaline, charge/cast/cooldown and spawn position/velocity/angle. Fists, spear normal/charged and staff firing use native console input. Minimum/maximum bob visibly change the first-person scene without changing those records |
| persist-01; restart-02 | Human male/tone1 and Caelith female/tone2 retain their identities. UI/message scale, reticle type/visibility/size/color, move/idle bob, bob speed/fire and quake preference survive both character loads and process restart. Twenty complete notices retain order |
| legacy-before-01 / legacy-after-01 | An actual b36ef830 save loads on the changed build; the original active message is copied once into history revision1 and remains unchanged over repeated checks. Original save is retained for rollback; no destructive conversion |
| live-01 | Agent used the Computer Use skill on the native 1280x720 Spanish window: clicked Notices, scrolled its complete long text with the wheel, returned, clicked Crafts, then opened Notices there. All observed outcomes passed. Normal Alt+F4 closure returned engine exit0; the automated completion marker was intentionally not reached |

The 4:3 final panel capture uses independent X/Y inverse projection to obtain
uniform native pixel scale. Matrix bounds, scaled Journal/creator button
dispatch, scroll reachability, native pause and remap priority are asserted in
the engine. More general gameplay/controller/platform coverage is not claimed.
Accepted damage/wound/Lucidity feedback source is unchanged. No live damage or
large-siege revalidation was required by these presentation-only changes.

## Corrections and failed attempts retained

- compile-01: ZScript cannot dereference `.X` directly on this Vector2-returning
  call; storing the returned vector fixed the compile error. compile-02 passed.
- visual-wide-03 requested 2560x1080, but Windows constrained the window to
  1924x1061. It is **not** ultrawide evidence. visual-wide-04 uses the verified
  1600x675 viewport instead.
- restart-01 used an absolute load filename that this launch path prefixed with
  savedir again. The relative save filename in restart-02 loaded and passed.
- extras-01 incorrectly called a play-only helper from its UI fixture check;
  changed to read-only FindInventory. extras-02 correctly rejected card opening
  because the fixture lacked its physical Tarot deck and left incorrect time-
  skip prerequisites. extras-03 supplies the real deck, cancels the previous
  panel through its existing operation and preserves the workshop session for
  time skip. Production entry requirements were not bypassed or weakened.
- Independent read-only review found a crafting pointer dispatch conflict and
  a contextual L shortcut stealing remapped Journal/time input. Both were fixed
  and the final native cases plus physical clicks above cover them.

## Support boundaries

Custom full-frame menus/HUD stop enlarging when the complete layout reaches the
viewport. Message text remains independently scalable and scrollable in history.
History stores the latest 20 messages per character, including after temporary
HUD expiry; it is not an unlimited log. Fixed native color works with health
color off. Native health-color normalization uses actor default health rather
than Caelum derived maximum; no exposed hook exists in this engine version.
Native Save/Load Clean scaling is retained. Attack/charge/block poses, ADS,
recoil, spread, resource costs and #137 feedback have no new comfort multiplier.

Keep-awake is thread-scoped, with no power-plan changes; its request/release
record is retained. The final summary records static validation, official build
membership comparison and cleanup. No author acceptance is inferred from it.

Final static checks: project validator passes at version 5.2.15, with 2,483
context words; generated dialogue/localization/document indexes are current.
Independent final review found no remaining blocker. Its crosshair=0 caveat
(weapon-specific override versus the global crosshairon toggle) is documented.
