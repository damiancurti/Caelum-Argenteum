# Summoning — 5.4.18 / #249

Implemented on `feat/issue249-summoning`, based on accepted #248 commit
`b87f977b`. The final runtime is identified in [evidence.json](evidence.json).
Author acceptance **CA249-01 is pending**; native evidence is separate.

## Results

- Project validation passes with zero errors; normal `build_dev.ps1` packaging
  matches every member of `src/` and the frozen native runtime.
- **132 assertions in 19 native GZDoom 4.14.2 runs pass.** Windows/Vulkan,
  one engine at a time, unpaused background simulation, master audio 5%.
- Aimed placement and collision/visibility fallback; one owned body; all twelve
  base attributes scale; successful recast replaces, failed recast preserves.
- Real User4 progressive preparation, cancellation, successful/blocked release,
  cooldown, expiry and save/load during preparation.
- Actual following and enemy combat; native area damage and breath protection;
  a real projectile passes caster/ally and hits the enemy after summon removal.
- Summon/caster death, finite inventory, body identity and Health/resources through
  reload and hub return. Low-ceiling arrival remains noninteractive, retains
  resources and loses time; it reappears when space returns or expires pending.
- The real journey transaction subtracts elapsed simulation time and removes an
  expired summon. Copied-save 5.4.17 upgrade, bridged rollback and return pass.
- Two independent freezes produce identical runtime and fixture bytes. Agent
  visual inspection confirms readable Spanish controls/status and reused art.

The final package only normalizes LANGUAGE to LF and refreshes its generated
localization indexes after the gameplay suite. Every gameplay ZScript and other
asset remains byte-identical; final native preview and static validation pass.
The final fixture adds preparation/flight/manual helpers to the earlier tested
fixture. Qualified evidence is reused, not counted twice. Exact commands, checks, hashes, failed
development approaches and limits are retained in `evidence.json`. Native runs do
not establish broad campaign, multiplayer or large-map performance acceptance.

## Reproduce

Run from the repository root with the locally installed engine and development
IWAD. Both package preparation and run labels require fresh destinations.

```powershell
python assets/validation_5418/prepare.py --directory issue249-fresh
powershell -NoProfile -ExecutionPolicy Bypass -File assets/validation_5418/run_native.ps1 -Directory issue249-fresh -Label contract -Script contract.cfg
```

Other scripts: placement, casting, combat, flight, journey, death, save/load,
save-prep/load-prep, pending/pending-load and failure. `failure.cfg` uses MAP97.
Load pairs use `-LoadGame summon.zds`, `preparation.zds` or `pending.zds` in the
same savedir. `preview.cfg` captures the isolated scene and exits; `manual.cfg`
leaves it open. `launch.ps1` opens the ready scene with physical controls.
The fixture's empty room uses local development IWAD textures. No IWAD, engine,
generated map/package, save or screenshot is distributed in the product.

## Copied-save compatibility

`prepare_compat.py --mode seed|upgrade|rollback|return` packages the optional
bridge and copies its input save. The old 5.4.17 runtime has no Summoning classes;
the rollback bridge supplies inert declarations, then removes the unsupported
temporary body/effect and cancels preparation without refund. Saving that copy
and returning to 5.4.18 remains inactive with unchanged Anima. It does not recreate
the cancelled summon. The untouched original save is the reversal path.

No live campaign save is edited. The bridge and diagnostic classes remain outside
`src/`. Current effect revision is 1; old saves without it stay inactive. Existing
projectiles default the new summon policy to false, retaining previous behavior.

## Pending author check

CA249-01 in root `pending_test.txt`: physical casting/cancellation, follow/combat,
recast, lifetime and the supplied map/journey controls. F6 resets; F7 refills Anima
and clears cooldown for repeated checks. These controls affect only this fixture.
