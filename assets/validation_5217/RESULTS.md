# 5.2.17 / #207 - MAP01 player health floor

The author requested that the MAP01 player cannot die and remains at 1 HP after
reporting appearance reverting on death. This patch preserves the living pawn,
profile and modular appearance. It does not repair general respawn appearance
outside MAP01 or revive already-dead saves. CA207-01 author gameplay acceptance
is pending in the root pending_test.txt.

## Implementation and boundaries

CaelumTutorialSafety derives protection from the current MAP01, current player
pawn and PST_LIVE, without a saved flag. Seven final native damage calls share a
wrapper that temporarily adds CF_BUDDHA2, then removes only the introduced bit.
Existing custom defenses/wear precede it; native armor resolves before the floor.
The wrapper reports at most its native result and observed HP loss. Direct
survival/thermal losses and journey commits use the same floor. Die supplies a
last fallback for direct script calls, before death cleanup/profile snapshots.
Accumulated integer damage is consumed even when blocked; thermal accounting
includes only HP lost. Resource costs and status/control effects still apply.

GZDoom 4.14.2's ordinary actor Buddha flag does not protect forced/telefrag death.
Buddha2 does, but clears DMG_FORCED after early bypasses and before late native
armor/invulnerability. That native exception is intentional and tested; do not
claim identical forced-damage semantics. Native WorldThingDamaged payloads still
use calculated damage; only the wrapper's returned HP loss is limited. NPC and
other-map behavior remains outside this rule. No global cheat or user INI changes.

Native source audit: [g4.14.2 p_interaction.cpp](https://raw.githubusercontent.com/ZDoom/gzdoom/g4.14.2/src/playsim/p_interaction.cpp),
SHA-256 `f0c74354f99b8a38c595c6e01dc4ad9dff7331dce14ed4b026469b3b2d6b7235`.
The repository retains this pointer, not a vendored engine source file.

## Native evidence

Baseline: 1bf5087e (5.2.16). GZDoom g4.14.2, Windows 11, Vulkan, isolated 960x540
window, VSync, deterministic RNG seed 207 and skill 2. Local development Doom II
IWAD/engine support dependencies are not distributed. Background simulation is
unpaused at 5% audio. Each run records and releases its keep-awake request in a
finally block; no power-plan setting changes.

The fixture is loaded separately from src. runs.json records engine/runtime/
fixture hashes, config hash, result and keep-awake release. Logs preserve full
engine output with installation paths replaced and LF normalization; raw and
retained log hashes are separate. hashes.json records exact fixture/source bytes
and verifies official build membership/content against the tested package.

| Run | Result and scope |
| --- | --- |
| baseline-regression | Expected failure: old MAP01 lethal impact kills the player; death also changes cheats. Two negative assertions establish the regression. |
| contract-final | 48 passed assertions: ordinary/repeated impacts, telefrag/forced damage, drowning, pressure, DOT, native crush, directed/explosion defenses, native armor order, preexisting/nested Buddha2, survival/thermal accumulators, journey commit, direct Die, unchanged appearance actor/profile identities and NPC mortality. |
| persistence-final | 9 passed assertions: save/load at 1 HP, cosmetic identity, no persisted protection, MAP02 travel and lethal native damage outside MAP01. |
| outside-survival / outside-thermal | Each passes MAP02 death from the direct health-loss route. Before the final nested-return correction; these unprotected routes were unchanged by it. |
| legacy-save / legacy-upgrade-final | Create a nondefault living profile on the baseline, load with final runtime under the original package filename; identity and MAP01 floor pass (5 assertions). |
| rollback-current-save | Current save loads with the original baseline package under the saved filename; identity/living state/no persisted bit pass (3 assertions). No migration or schema changes. |
| contract-03 / persistence-01 / legacy-upgrade | Earlier passing implementation checks, superseded by final runs after cross-review and release labels. |

The contract's nested test covers both an already-lethal outer hit and a
nonlethal outer hit whose callback is lethal. Cross-review identified the latter
return-value attribution bug; the final test ensures the outer result remains 7
instead of including the nested loss. Static source review found no other
blocking issue. Native tests verify identity fields and actor references, not an
author's physical-display appearance judgment or a full manual Bull encounter.

Static validation passed: validate_project.py reports version 5.2.17, 2,467
CONTEXT words and no errors. The official build completed with 13,560 members,
all byte-for-byte equal to the final tested runtime's members. Git diff checks
and generated document/dialogue index validation passed.

## Retained unsuccessful fixture attempts

- contract-01 compiled and passed initial damage routes, then the fixture tried
  to write through the null result of GiveInventoryType("BasicArmor"). BasicArmor
  is already present and is not a pickup. Fixed the fixture to find it or attach
  one explicitly. The runner stopped its own process and released keep-awake;
  the complete VM-abort log remains. This was not a production null dereference.
- contract-02 passed all 46 then-current assertions but quit before the queued
  c207_done network event executed. Added a wait before quit in fixture configs;
  this incomplete run is not counted as a completed pass.
- Initial preparation used Get-Process in a way that returned exit 1 with no
  engine process. Changed the preparation probe to Get-CimInstance before runs.

## Reproduction

1. Run `python assets/validation_5217/prepare.py` with no engine process open.
   It packages current src and the isolated fixture; preserves baseline.pk3
   from `git archive 1bf5087e:src`. Fixed ZIP timestamps/order make fixture and
   production packaging deterministic.
2. Run `powershell -NoProfile -ExecutionPolicy Bypass -File
   assets/validation_5217/run_native.ps1 -Label <fresh-label>` for the contract.
   Override Engine/Iwad parameters for local installations. A label is never
   reused. The runner owns only its test process and fails on native errors.
3. Choose `-Script persistence.cfg`, or the outside-*.cfg scripts with `-Map
   MAP02`. Use regression.cfg with `-Runtime baseline.pk3 -ExpectRegression`
   for the expected old failure; legacy.cfg creates the old save.
4. For upgrade, copy production.pk3 to current-runtime/baseline.pk3 and run
   upgrade.cfg with `-Runtime current-runtime/baseline.pk3 -LoadGame
   ca207-legacy.zds`. For rollback, copy baseline.pk3 to
   rollback-runtime/production.pk3 and load ca207-current.zds with identity.cfg.
   These isolated filename aliases satisfy native save package identity while
   preserving both originals. Do not substitute packages in the real save folder.
5. Build with build_dev.ps1, run validate_project.py, and retain sanitized evidence
   with retain_evidence.py. No configs, saves, generated packages, engine source
   copies, executables or IWADs belong in this evidence directory.

The prior fullscreen/VSync setting and automatic HUD/menu scale remain unchanged.
