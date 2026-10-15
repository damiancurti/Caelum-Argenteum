# Arcane Cloud — 5.4.20 / #251

Implemented on `feat/issue251-rain-cloud-model`, based on accepted #250 commit
`e9c79de8`. **CA251-01 passed author gameplay/visual review on 2026-10-15**; see
[acceptance.json](acceptance.json). PR281 is ready. No merge or closure is claimed.

## Focused evidence

Exact successful checks, package hashes, launch commands and qualifications are
recorded in [evidence.json](evidence.json). Native runs use GZDoom 4.14.2 on Windows
with Vulkan, one engine at a time, unpaused background simulation and 5% audio.
**144 qualified assertions pass in 22 native runs**, including three copied-save
compatibility runs. Project validation, normal package/source parity and
deterministic runtime/fixture reproduction also pass.

- Native User4 progressive payment, cancellation, three-second release/reuse,
  preparation save/reload and ordinary expiry.
- Cart width, distinct attribute consumers, 12/12/11-tic lightning cadence,
  delayed one-second rain, current maximum Anima and phase-preserving renewal.
- Ally-only downward rain, above/outside exclusions, interposed bodies and a real
  solid 3D floor; caster recovery; two native players confirm strongest-only and
  equal-power tie handling. The second participant uses the existing isolated
  engine copy with `zcajun/bots.cfg`; its executable hash matches the installation.
- Visible enemy anchors, divided Air-seal damage, protected allies/neutrals,
  staff stun only after Health loss, and new strikes from an existing cloud while
  its caster is under War Cry. New offensive casting remains prohibited.
- Seated world presentation without rest mechanics; native horizontal/vertical
  movement multipliers, wall/ceiling collision, both real cloud/Tarot removal
  orders, water/sleep/stun/immobilization interruption, owner death and journey
  transactions.
- Active save reload, hub departure/return and non-hub travel preserve effect
  state with one cloud visual. The original failing saved scenario passes after
  replacing manual visual-actor travel with destination recreation.
- Copied neutral 5.4.19 save upgrades and roundtrips to 5.4.19 without resource
  changes or free activation. Active cloud saves are supported by 5.4.20; loading
  an active cloud into an unsupported older runtime is not claimed. Original
  pre-upgrade snapshots remain the rollback source.

The earlier gameplay suite is reused only for unchanged behavior: the production
difference consists solely of the cloud's `PreTravelled`/`Travelled` presentation
handling. Final native tests exercise that changed path and reload the original
crashing save. Test fixture revisions fix overlap ordering, use a real second
participant, skip intermission on non-hub transfer and add assertions/cameras.
Failed development runs never count as successful evidence.

The author's crash report matches `build/issue251-gameplay-03/load2`: a native
access violation writing `0xbeefcafe` on MAP98. The original ZIP, dump and failed
logs remain local, outside the package. CA-KP-106 records the scoped lesson.
The mesh/material is unchanged from the original 5.4.5 asset; known concave
surface bands remain documented. Visual review does not claim volumetric weather.
Campaign-wide, network multiplayer and large-map performance acceptance are not
implied by these focused fixtures.

## Reproduce

Use fresh names to preserve earlier evidence:

```powershell
python assets/validation_5420/prepare.py --directory issue251-recheck
powershell -NoProfile -ExecutionPolicy Bypass -File assets/validation_5420/run_native.ps1 -Directory issue251-recheck -Label rain -Script rain.cfg
```

The generator writes separate timing, rain, roof, casting, preparation, overlap,
collision, interruption, coexistence, journey, death, save/load, water and visual
scripts. Use `-Map MAP97` for the roof fixture and savedir-relative `-LoadGame`
names for reloads. The overlap test needs a native test engine with a bot entry;
do not alter the installed engine configuration. `prepare_compat.py` freezes
separate baseline/upgrade/rollback packages and copied saves. Neither fixtures,
test IWAD resources, binaries nor generated PK3s are packaged into `src/`.
