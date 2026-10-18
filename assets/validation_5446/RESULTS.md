# Symmetric house-door Melt — #334 / 5.4.46

The author replaced the no-animation contract with Melt on both entry and exit.
Global wipetype, native loading icons, arrival autosaves and hub residents remain.
The source view belongs to the current door, independently of ship/cart overlays.
No geometry, combat or balance values change. CA334-02 is pending author review.

## Native cause and implementation

The private CAH008 autosave SHA-256 is
`96631010f735e3d3466c6e0de162afe2dad2c81f4e7b0977035025656653dba8`.
Its uncapped exit control emits 28 presentations in 28.27 ms before PreTravelled;
the capped control emits one. GZDoom g4.14.2 decrements hub NoWipe in D_Display,
not the simulation tick. A queued ChangeLevel can therefore outlast protection.
setTransition(0) does not cancel a native wipe, and no global setting is changed.

A valid door Use starts two presentations of a private source capture. Its ACK
is serial-scoped and consumed once before committing ChangeLevel. The source is
held through the existing 35-presentation arrival path, followed by explicit
Melt. Load, new game, death before commitment or unrelated travel cancel ownership.
Capture starts on Use; there is no new per-tic scan for portals.

The player supplies the camera to exclude their own body. The renderer binding
is retired with an immediately destroyed harmless helper, including after hub
restoration; null is unsafe in the native API. Source inspection and independent
review cover native TObjPtr retirement and saved canvas bindings. Native source
and held-arrival screenshots show the same detailed door after reaching MAP03.
The snapshot contains the world view, not first-person weapon sprites; other UI
and the native loading icon retain their own drawing paths.

There is one explicit Melt request per ordinary door arrival. This does **not**
prove that GZDoom skips its earlier native wipe: identical source overlays aim
to make that extra engine pass visually neutral. Screenshots prove source-image
preservation, not the complete animation or absence of a perceptible second wipe.
The author checks that sequence in CA334-02. No FPS improvement is claimed.

## Scope of checks

Thirteen final native runs pass 82 assertions, listed in evidence.json and
verified with 128 archived text members by verify_evidence.py. They cover real
Use in both visited-hub directions, capped
and uncapped rendering with another global wipetype, old/new save loads, pending
capture, duplicate/stale acknowledgements, death, new game, interrupted arrival,
ordinary ship/cart travel, and early house entry during both vehicle overlays.
Runtime/fixture/engine hashes and full logs identify each run. Normal-source
packaging and the diagnostic-only runtime differences are in delivery_checks.json.

## Failed and limited drafts

- melt01's next Use occurred before the previous arrival completed: its wait was
  extended. melt03 admitted physical input and made an unexpected fourth travel;
  later automatic trace fixtures consume physical input. Neither is a pass.
- Auxiliary-camera drafts passed event checks but displayed an almost uniform
  dark source. Native source01 screenshots exposed the actual defect. The final
  player camera and retired binding replace that candidate.
- arrival01/02 asked their arrival assertion after console load had already
  replaced the world. The observer now retains that it saw the real active
  arrival. newgame03 then overwrote that observation at the second arrival;
  the sticky observer in newgame04 corrects the fixture. Failed logs are retained.
- An initial window-capture attempt failed to select the target and is excluded
  entirely. Later target-only PrintWindow samples were inconclusive during the
  wipe. They are not animation proof. Only inspected native screenshots support
  the source-image finding; no capture pixels are distributed.
- Early manifests' cap/wipe fields record requested CLI values. The actual cfg
  overrides them for lifecycle/held/vehicle cases; newer manifests additionally
  state effective_cap/effective_wipe. The archived executed cfg is authoritative.

The archive contains text evidence only. Private saves, runtime/fixture PK3s,
engine, IWAD and screenshots remain local. Their hashes do not license assets.
Reproduce with prepare.py and the sequential run_controls.py, using the existing
assets/validation_5422/run_native.ps1 wrapper. A real private save is required
for replay; do not silently substitute a fresh campaign or run two engines.
