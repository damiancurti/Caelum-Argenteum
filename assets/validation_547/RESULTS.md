# Telekinesis — #241 / 5.4.7

The focused branch builds on #242 acceptance commit `a7f213f0`. User1 now captures
one living Caelum body or already movable scenery prop. The approved force is
1,000 N times magical power, with actual mass determining acceleration and the
1 Anima/kg/s base cost. Holding disables voluntary action, retains native physics
and ends on another press, lost sight/range, interruption, target loss, exhaustion
or map travel. No inventory ownership or permanent gravity/collision flag changes.

## Native evidence

GZDoom 4.14.2, Windows 11, Vulkan, isolated MAP99/MAP98 hub, 1,280×720. Runs use
5% master volume, background simulation and one engine process at a time.
`evidence.json` records runtime/fixture hashes, selected results and exit codes.

Static validation passes with no errors and CONTEXT at 2,486 words. Normal
packaging succeeds; all 16,157 members equal the final frozen runtime. The first
documentation validation ran before this RESULTS file existed and correctly
reported its missing README link; the completed delivery resolves that check.

| Preserved run | Result |
| --- | --- |
| issue241-final / contract-01 | 40 checks: actual User1 press/hold/release, paid admission, cost modifiers and live mass, F/m and inverse mass, moving anchor, suppressed native state actions, target loss, range/obstruction, caster interruption, exhaustion and scenery |
| issue241-final / real-01 | 22 checks using actual Mandinga, rat, Bull and granite rock; physical/magical attack suppression, breath interruption, voluntary movement and Bull charge guards, real carried mass |
| issue241-final / gravity-01 | 10 checks: native 1,000 kg body falls under insufficient force; 66 kg body rises; solid/gravity flags remain intact |
| issue241-v4 / save-01, load-01, hub-01 | 3 / 4 / 5 checks: active binding resumes payment without resetting resources or duplicating the target; native hub travel releases the body and its actions resume |
| issue241-upgrade / upgrade-01 | Existing neutral 5.4.3 save loads through the shared compatibility observer; new ability state remains inactive |
| issue241-rollback / rollback-01 | 3 checks: copied active save returns to the specific 5.4.6 baseline via an optional bridge, preserving Anima and resuming target actions |
| issue241-final / return-01 | 2 checks: rollback copy returns to 5.4.7 inactive, with the original mobile target |
| issue241-breathing-regression / reload-01 | 3 #242 checks: an active Caelith save retains its reserves/effect and native User1 stops it |

The v4 save/hub runtime predates two diagnostic release-label changes and limiting
the new pre-collision velocity resnapshot to held actors only. Held behavior is
unchanged; final contract/real/gravity runs exercise the final collision path and
the final runtime also reloads the rollback save. All other gameplay members are
byte-identical. Initial compile failures (data/play scope and fixture TID assignment)
and the subsequent Caster-field shadowing failure remain under issue241-v1/v2.
They are not counted as passing tests. The corrected v3/v4 contracts pass.

The installed 4.14.2 `gzdoom.pk3` declarations in `zscript/actors/actor.zs` and
`zscript/constants.zs` verified LineTrace, FLineTraceData and TRF flags before use.
The force controller applies a bounded velocity increment; no unverified movement
API, teleport or fixed-speed balance value is introduced.

## Reproduction and rollback

Run `python assets/validation_547/prepare.py --directory <fresh-name>`, then:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File assets/validation_547/run_native.ps1 -Directory <fresh-name> -Label contract-01 -Fixture telekinesis.pk3 -Script contract.cfg -Map MAP99
```

Other scripts: real.cfg, gravity.cfg, save.cfg, load.cfg (with
`-LoadGame telekinesis.zds`), hub.cfg and preview.cfg. Distinct labels/directories
preserve prior evidence. Fixtures and development IWADs are not packaged in src.

`prepare_rollback.py --directory <fresh-name> --source <saved-test-directory>
--runtime <preserved-5.4.6-production.pk3>` copies the save and supplies the old
runtime with the missing serialized effect type. Run rollback.cfg with that
copy. The bridge is only for 5.4.6; do not load it alongside the current runtime.
Keep original saves/packages. This is a verified return to that specific baseline,
not arbitrary compatibility with every past release.

## Author check

CA241-01 is pending in the root pending_test.txt. The manual fixture uses actual
actors, normal body mass and collision, fixed 1,700/8,000 N reference forces,
a visible 10,000 Anima test reserve, no regeneration and protected player health.
It offers lighter/heavier
targets and exhaustion/reset controls. Agent checks do not establish author,
campaign-wide or multiplayer acceptance. No merge or issue closure is claimed.

The first preview exited normally and produced its screenshot, but omitted the
runner's completion marker. The handoff fixture adds a manual-seed-only marker
and aligns its displayed maximum with the extended test reserve; neither is
author acceptance. The production runtime is unchanged.
