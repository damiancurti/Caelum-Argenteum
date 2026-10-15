# Redemption — 5.4.19 / #250

Implemented on `feat/issue250-redemption`, based on accepted #249 commit
`6578c8b7`. Exact packages, commands, successful assertions and qualifications
are recorded in [evidence.json](evidence.json). Author acceptance **CA250-01 is
pending**; there is no merge or issue closure.

## Focused results

- **150 qualified assertions in 23 native runs pass**, including the separate
  compatibility and #249 placement regression checks listed below.
- Project validation, normal packaging/member parity and two deterministic
  runtime/fixture freezes are verified by `record_evidence.py`.
- Native GZDoom 4.14.2, Windows/Vulkan, one engine at a time, background simulation
  unpaused and master audio 5%. Native User4 preparation/payment/cancellation,
  release/cooldown and preparation save/load are exercised through engine input.
- Immediate and one-second resurrection; original enemies, allies, neutral
  corpses and the current player; stale player-body rejection; full four-resource
  restoration, negative-status removal and preservation of beneficial doses.
- Final fixed Toughness reduction for caster/living allies, excluding that cast's
  raised bodies. Physical/magical player/NPC damage and collision paths are tested,
  along with current range/sight, full-factor potency, strongest overlap and renewal.
- Real converted Mandinga following/combat; allied damage and breath protection;
  captured projectile policy survives conversion expiry. Own collisions remain
  harmful. Original predefined loot appears once; later deaths do not repeat loot
  or Adrenaline rewards. Native kill totals remain unchanged by resurrection.
- Expiry and caster death; same-tic revival cannot retain owner-death class effects.
  Saved identity, resources, per-cast history and duration survive reload and hub
  return. Low-ceiling arrival waits without interaction while time continues.
  Actual journey transactions consume duration and end temporary conversion.
- A copied neutral 5.4.18 save upgrades and roundtrips to 5.4.18 without changing
  the player or charging/refunding Anima. Active effects are tested in 5.4.19;
  loading an active Redemption save in an unsupported older runtime is not claimed.
  Original pre-upgrade snapshots remain the rollback source.
- #249 placement regression covers the extended shared full-body placement helper.
  Agent visual review checks before/active/expired Spanish scene controls and
  existing corpse, living-body, hands and HUD art. Physical author input is pending.

Qualified reuse avoids repeating unchanged tests. The earlier final gameplay
suite differs only by added same-tic player-death cleanup in `CaelumResurrection`;
that addition and the final package's player/corpse/save/travel paths were tested
separately. Fixture refinements add assertions/diagnostics, exercise the actual
journey transaction and display dead Health as zero. Failed development runs are
preserved locally and do not count as successful evidence. Broad campaign,
network multiplayer and large-map performance acceptance are not implied.

## Reproduce

From the repository root, using fresh directory names:

```powershell
python assets/validation_5418/prepare.py --directory issue250-mapdata
python assets/validation_5419/prepare.py --directory issue250-release --maps build/issue250-mapdata/summoning.pk3
powershell -NoProfile -ExecutionPolicy Bypass -File assets/validation_5419/run_native.ps1 -Directory issue250-release -Label contract -Script contract.cfg
powershell -NoProfile -ExecutionPolicy Bypass -File assets/validation_5419/launch.ps1
```

Other generated scripts cover the individual cases listed in `evidence.json`.
Use savedir-relative `-LoadGame redemption.zds`, `pending.zds` or `preparation.zds`
with the corresponding load script. `prepare_compat.py` copies rather than edits
an original save. The launch tool refuses a second simultaneous engine.
Fixtures, generated PK3s, development IWADs, local logs and screenshots are not
runtime/distribution assets. Test values are laboratory controls, not new balance.

## Author check

The sole outstanding check is `CA250-01` in root `pending_test.txt`. `F` prepares
or cancels; `F6` resets; `F7` refills Anima/clears reuse; `F8` creates/kills the late
body; `F9` crosses maps with temporary allies; `F10` advances one journey hour.
Only explicit author confirmation will move this check into HISTORY.
