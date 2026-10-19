# V5.5.0 / #309 — authored weapon/input audit

Baseline: main `1da6beb7946cd2d9d710d597916a1684e64c8f4f` (5.4.47).
GZDoom 4.14.2, Windows 11, Vulkan; isolated private maps, one engine at a time,
background unpaused, 5% audio. FPS is not measured or claimed.

## Changes and scope

The author chose one Reload action per press. Native Ready repeats Reload while
the button is held; both physical and magic callbacks previously reset the
timer. Check native `player.oldbuttons` before accepting a new manual request.
Empty-magazine Fire also repeatedly requests reload; keep a current same-weapon
reload idempotent. Existing player fields, resources and save format remain.

The giant-gauntlet uppercut had `CATALOGUE_ACTION_BLOCK` damage classification;
the approved blunt attack now uses `CATALOGUE_DAMAGE_BLUNT`. Neutral damage,
Air, reach and upward push are retained. Catalogue consumers include player
thermal/harvest delivery and resident tools; no NPC receives new equipment.

`matrix.json` records all 111 configurations and 444 Fire/AltFire/Reload/Zoom
routes with rule owners, target/range, cadence, costs, wear, interruptions and
evidence. This is **not** a claim of 444 newly performed keyboard tests.
The native catalogue checks the selector identities and metadata. Its numeric
model fields are base values; final actor/tier/cost rules are explicitly mapped.
The canonical matrix reconciles Bell's twelve accepted #192 projectiles, adds
Pickaxe/Bolas and retains spear AltFire as intentionally unauthored.

## Completed native controls

| Frozen local run | Result | Meaning |
| --- | --- | --- |
| issue309-baseline01/reload-baseline01 | 42 checks | Six held-R routes fail to complete as expected; all pulse controls complete. |
| issue309-baseline02/auto-baseline01 | 12 checks | All four empty-magazine held-Fire routes stall as expected. |
| issue309-input01/reload-current01 | 48 checks | All six held/pulse routes complete once, including held R beyond charge expiry. |
| issue309-gauntlet02/gauntlet-baseline02 | 8 checks | Native uppercut is wrongly non-blunt; primary is blunt. |
| issue309-verify01/gauntlet-current01 | 8 checks | Both native attacks are blunt, neutral and cold. |
| issue309-verify01/auto-current02 | 16 checks | All four held-Fire routes reload and actually fire. |
| issue309-persist01/catalogue | 112 checks | All 111 native selector configurations; totals verified. |
| issue309-magic03/magic-current03 | 440 checks | 40 T1 casts (four implements, five essences, both faces) plus four charged Bell/Statuette casts. |

Cold controlled receiver, same 306 raw hit: primary loses 477 HP both before and
after; uppercut changes from 316 to 477. Neutral uppercut remains 156 HP loss.
The first neutral primary rolls a critical (613 raw / 413 HP); it is not used
as a false equal-damage comparison with the noncritical uppercut. The target
freezes AI/motion and initializes a valid thermal state, while retaining the
production damage receiver. This isolates classification, not whole-encounter
balance. Metadata checks use native selector construction; input cases use
native `+reload`, `+attack` and `+altattack`.

The fresh magic cases verify native selector/item identity, explicit requested
charged state, sufficient resources, completed cast and projectile count. At
every projectile Spawn, the observed reserve reduction equals one authored
cast cost; Bell does not pay twelve times. This observation occurs immediately
after payment, before inter-tic regeneration. All 44 ordered cases and the final
440/0 marker are checked by the collector. These empty-room casts verify
delivery/count/payment; they do not claim new victim-effect or all-tier damage
coverage. Existing source/accepted tests cover those unchanged rules.

Final persistence controls use `issue309-persist03` for catalogue and the sword
save/load/hub, then `issue309-persist04` for the corrected switch fixture and
remaining cases. Each of three mid-action saves passes; each current load,
round-trip hub and switch-back case passes 10 reported checks. The boundary
case passes 7 checks (physical/magical/ranged immobilization plus four empty
reserves). The held-R save/load case passes 10: buttons/oldbuttons are 64/64
before and after loading, the timer advances from 1.540703014 to 1.483560157 s,
and one charge completes without restart while R remains held.

`issue309-legacy01` creates three genuine 5.4.47 saves mid-charge/reload with
the frozen baseline runtime. All three load in the final runtime and pass 10
checks each, preserving exact equipment identity, durability and ammunition.
`normal-package-gauntlet` passes 8 checks using the actual `build_dev.ps1` PK3
(SHA256 `07c388704f1bfb0377744f99b3532c1d056a53d804ed16c65afeab324370eeff`).
All 16,379 package entries match the final frozen source manifest byte-for-byte.

The final source changes pass `validate_project.py` and normal packaging.
The independent read-only reviewer found no production blocker and identified
probe/evidence corrections incorporated here. The author accepted CA309-01
(origin 5.5.0 / #309) on 2026-10-18: "La prueba dio bien."
`evidence.json` preserves every completed and failed run, command text, log and
package hashes, engine invocation and individual observations. Previously saved
probe counters are not presented as a count of new unique assertions.

## Preserved diagnostic failures

- `issue309-input01/auto-current01`: shotgun fired then began another reload;
  checking only the final `LastCarbineFired` gave one false negative. Observe
  all ticks, clearing that field at each Begin to exclude a previous weapon.
- `issue309-catalogue01/gauntlet-baseline01`: the artificial generic actor has
  no automatic thermal body. Explicit valid fixture state fixes the null
  reference; production was not changed for that diagnostic failure.
- `issue309-persist01/load-0`: GZDoom prepended savedir to an absolute loadgame
  argument. The runner now uses a save basename; `load-0retry01` passed 10 checks.
- `issue309-persist01/hub-0retry01`: returning to a cached map invalidates the
  map handler's old reference to travelling inventory. The actual item retained
  ID, ammo, durability and advancing timer. The probe now rebinds by stable ID
  from the actual owner; it never recreates equipment when loading/travelling.
- `issue309-persist02/03/switch-0`: the fixture returned to an item whose native
  selector it had removed when unequipping. It now waits for the intermediate
  selection, recreates selectors through the normal helper and then selects
  the retained original item. This did not require a production change.
- `issue309-magic01`: an oversized single-line console script did not execute
  the initial setup, causing a null probe reference. The multiline retry
  `issue309-magic02` scheduled independent wait continuations and quit early
  without a completion marker. The final script chains short single-line exec
  files sequentially, with every chunk hashed. No gameplay adjustment.
- The first local suite shell invocation was blocked by PowerShell execution
  policy before any engine started. The explicit process-local Bypass launch
  matches the existing development workflow; no machine policy was changed.

## Reused accepted evidence

- `validation_541` / #259: 677 assertions covering physical families, all magic
  types/tiers with Fire essence on both sides, release dispersion and relevant NPC releases. These
  direct release cases are not held-Reload evidence.
- `validation_529` / #192: Bell normal/charged primary/secondary, twelve native
  projectiles and per-projectile critical/payload; its cost check is a base
  constant check, not a native button-driven resource-payment measurement;
  personality/mitigation controls.
- `validation_5210` / #192: 1,028 ranged penetration assertions, native shotgun
  selector/reload and save/load checks.
- `validation_5115` / #162 and `validation_5212` / #195: held continuous staff,
  contact wear/heat, resident tools, bolas and player/native save regressions.
- `validation_5424` / #284 and `validation_5432` / #320: accepted demon profiles
  and direct projectile aim. This patch changes no demon ability ownership.

These sources remain applicable to unchanged rules. New tests cover the changed
native input paths and classification. No new ammunition balance or melee
energy conversion is included. Unarmed User2 dispatch is a separately identified
follow-up [#363](https://github.com/damiancurti/Caelum-Argenteum/issues/363),
outside the four-input matrix (source-verified, not yet reproduced natively).

## Reproduction and author preview

Use a fresh lowercase directory with `prepare.py --directory <name>`. Run the
PowerShell scripts with `-NoProfile -ExecutionPolicy Bypass`; `run_suite.ps1`
executes ordered persistence/boundary controls, while `run_native.ps1 -Directory
<name> -Label <fresh-label> -Script reload.cfg` runs a specific case. Preserve
all logs, frozen manifests and source hashes. `--baseline --runtime <frozen
old-production.pk3>` reproduces pre-patch behavior. Rebuild the matrix with
`matrix.py build/<name>/catalogue.txt` after its complete successful run.

For the author, run `run_native.ps1` with `-Script manual.cfg -Interactive` in
a visible PowerShell terminal. F6 sword, F7 wand, F8 empty shotgun, F9 gauntlets;
R charges/reloads, mouse buttons attack. Visible practice dummies and on-screen
instructions explain the task. F10 restarts the private room. Saves stay in the
private build directory. **CA309-01** passed explicit author acceptance on
2026-10-18 and has been removed from `pending_test.txt`. Launching the preview
alone is not acceptance; the author's confirmation supplies that evidence.
