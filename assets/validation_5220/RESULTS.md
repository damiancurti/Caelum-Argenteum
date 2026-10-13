# Issue #213 - Resource bar layout, 5.2.20

Baseline: main b4b7f49f / accepted 5.2.19. GZDoom 4.14.2 on Windows 11,
Vulkan with VSync. The author chose a 30% enlargement. CA213-01 remains
pending author visual acceptance; the following is isolated agent evidence.

## Reproduction

Run `python assets/validation_5220/prepare.py`, then `run_native.ps1` with a
unique Label, Fixture contract, Script visual.cfg, Language es/enu and desired
Width/Height. Native settings are disposable, unpaused in the background and
at 5% volume. Build packages, user INIs, saves, executable and IWAD are excluded
from source control. The thread-scoped keep-awake request is temporary.

The fixture closes introduction menus, renders the actual production HUD,
cycles native HUD modes (factor1, factor0.5, adaptive legacy and manual legacy),
then exercises a long stun label and deliberately long reload presentation.
Only its test player forces those presentation fields after Tick; it is not
production weapon/combat coverage. Each run records engine/package hashes,
actual render dimensions, native scale and screenshots. Earlier local iterations
are retained in build/issue213; selected final evidence is retained here.

## Results

- Static: `python validate_project.py` passes; document index regenerated.
- Build: `build_dev.ps1` succeeds; all 16,052 official runtime members are
  byte-identical to the package used for the final visual runs.
- `visual-169-05`: 1280x720 Spanish, four native HUD modes; intact labels,
  above-bar placement and long reload shifted above both groups.
- `visual-43-04`: 960x720 Spanish, four modes and long labels/reload.
- `visual-wide-02`: 1600x675 English, four modes; long reload fits between
  groups and retains its original position. Journal retains native UI scale.
- `fullscreen-02`: official package at actual 1920x1080, copied user INI,
  native legacy HUD scale 1.0x1.2; resource scale becomes 1.3x1.56. Both groups
  hug the lower corners. The source user INI SHA256 remained unchanged.
- `fit-43-02`: narrow viewport with maximum tested native factor and long
  stun/reload strings; validates the measured-width cap and clearance.

The retained earlier fit-43-01 image exposed weapon artwork covering the long
label. Final fit-43-02 confirms the restored text-after-weapon draw order;
all aspect-ratio sequences were repeated after that correction.

All listed final native sequences complete without script/VM errors. Captures were
visually inspected; these are render smoke/visual checks, not assertions of
combat correctness. Local baseline-169-01 provides the old centered layout.
Initial local iterations preceded the long-reload fixture override and are
not final evidence. Independent agent review found no remaining blockers.
The Windows window snapshot helper lost the short-lived final window after it
exited; the engine's full-resolution screenshots supply the visual evidence.
The temporary keep-awake request was released; the power plan is unchanged.

The native HUD mode names are intentionally preserved: visual.cfg's historical
small/large screenshot names refer to its test stages, not GZDoom scale ordering.
CA213-01 remains the sole author check. No merge/closure is claimed here.

## Author size amendment

The author requested an additional 50% over the first 1.30 result:
RESOURCE_ENLARGEMENT is now 1.95. Earlier captures above document the first
iteration; amended-size captures use the size195 prefix. Viewport fitting,
edge anchoring, label placement and weapon clearance remain in effect.

Amended native checks pass: fullscreen1920x1080 uses scale1.95x2.34;
960x720 long-label stress reaches the viewport cap without clipping.
