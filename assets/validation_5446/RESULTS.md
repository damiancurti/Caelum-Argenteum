# Symmetric house-door Melt — #334 / 5.4.46

The author replaced the no-animation contract with Melt on both entry and exit.
Global wipetype, native loading icons, arrival autosaves and hub residents remain.
The source view belongs to the current door, independently of ship/cart overlays.
No geometry, combat or balance values change. CA334-02 is pending author review.

## Author-reported double Melt: follow-up in the same release

On 2026-10-18 the author rejected two visible wipes on house exit and approved
the other preview checks. CA334-02 now contains only the exit retest; CA353-01
acceptance is recorded separately under #357. The original 13-run evidence below
is retained as evidence of the initial implementation, not final visual approval.

Native Wiper_Melt shifts source columns even when both images are identical.
The original uncapped controls with globalwipe3 (Fade) missed the default-Melt
failure. The follow-up sets Fade3 only for the possible initial house pass on
the held source, then keeps the final Melt1. Fade blends corresponding pixels
without shifting columns. The global CVar, vehicle transition and native loading
icon are unchanged. Relevant g4.14.2 source: wipe.cpp274–295/324–367,
g_level.cpp1346–1347 and d_main.cpp3015–3017. RenderUnderlay/RenderOverlay both
run before WipeEndScreen; moving between those events would not fix this defect.

Five focused native runs pass25 assertions, recorded in single_melt_evidence.json/zip
and verified by single_melt_evidence.py. They include capped/uncapped default-Melt roundtrips,
actual generated inside/outside save reloads with the normal package, and house
entry during ship arrival with a different global setting. Traces distinguish
the initial Fade3 from the final Melt1; they establish selections, not a complete
visual sequence. The source/package check is single_melt_delivery.json.

The screenshot service's native pipe remained unavailable. A target-only fallback
captured84 samples in23.26seconds, but included black frames even outside wipes.
Those samples cannot prove the animation; no pixels or personal INI are archived.
The new native run records omit initial_config and retain the original record
hash. Author visual acceptance remains pending; no FPS benefit is claimed.

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

## Initial implementation checks (before the double-Melt correction)

Thirteen initial native runs pass 82 assertions, listed in evidence.json and
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
