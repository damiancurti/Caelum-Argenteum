# 5.2.23 / #219 - Sleeping-bag acceleration in MAP02

Baseline: `2d3cac6e` (#215). Windows 11, GZDoom 4.14.2/Vulkan, 2026-10-13.
The author approved sleep in the existing bag outside marked sewer safe zones,
retaining combat, nearby hostile and hazard checks. MAP02 already used ordinary
exterior time; the initial Limbo-clock hypothesis was rejected by source and
native evidence. No clock/rate, map, inventory schema or art changes were needed.

## Isolated native evidence

- `baseline-save-01`: actual bag dialogue and five-minute reply enter sleep;
  the old runtime rejects T with CA_FAST_ZONE at dry (-320,-320,0), outside
  all authored safe zones. A native baseline save retains the active bag rest.
- `sleep-final`: T completes the five-minute rest, restores Sleep, advances
  normal exterior time and releases the mat/camera, retaining the single bag.
  Y opens from bag sleep, retains support after mat release, simulates actual
  sleeping tics and reaches the requested time. Ground wait/crafting gain no
  exception. Combat, critical thirst, nearby hostile and new obstacle guards
  remain. Boxing/removing the bag and waking stop Y before another substep;
  an authored safe zone still permits waiting after waking.
- `load-rest-03` / `load-y-01`: current active rest and open Y survive native
  save/load, retaining support, identity, comfort and real simulation progress.
- `load-baseline-01`: the active rest saved under baseline code loads under
  the patch and can accelerate outside the zone, without migration fields.
- `save-active-02` / `load-active-02`: the save contains Active=1, Sleeping=1,
  BagSupport=1 and real elapsed sleep tics. On restart it completes sleep and
  stops at waking outside a marked zone, preserving the bag.

Each selected run must end with `CA219 DONE failures=0`. The included capture
shows the ordinary native Y panel in MAP02. These are engine fixtures invoking
production entry points; they do not claim physical T/Y key acceptance.
CA219-01 remains in pending_test.txt alongside CA213-01, CA216-01 and CA215-01.

Early fixture attempts used a safe-zone point, mistook DetachFromOwner's
notification for actual inventory removal, or expected the zone error before
the incomplete-crafting activity guard. Those test assumptions were corrected.
Load commands require save basenames because this engine prefixes savedir;
active-skip loads also need enough startup frames before console events. These
failed attempts remain local and are not passing evidence.

## Reproduction and review

Run `python assets/validation_5223/prepare.py`, then `run_native.ps1` using
`-Map MAP02 -Fixture sleep -Script sleep.cfg` and a unique `-Label`. The scripts
save.cfg/load-rest.cfg/load-y.cfg and save-active.cfg/load-active.cfg cover
native persistence, with `-LoadGame c219-rest.zds`, `c219-y-open.zds` or
`c219-y-active.zds`. Baseline uses `-Baseline -Fixture contract -Script
baseline-save.cfg`. For the upgrade, copy production.pk3 to a separate
current/baseline.pk3 and use `-RuntimeAlias current/baseline.pk3
-AdditionalFixture contract -LoadGame c219-baseline-rest.zds` with load-rest.cfg.
This preserves the map-package basename required by GZDoom while loading only
the new production code. The original baseline package/save remain unchanged.

Independent read-only review found no blocking issue in the sleep permission,
transition, wake order or per-substep ownership checks. InSafeZone and remote
support accessibility remain unchanged. Tests use isolated INIs, background
simulation and 5% audio; generated packages/saves stay outside src. The separate
Mandinga loot regression is tracked in #220 and is not part of this patch.

## Delivery

Static validation, regenerated indexes and the normal package build are checked
with this delivery. Package comparison and selected run records retain hashes;
no development engine, IWAD or saves are distributed. Keep-awake uses a temporary
thread request without changing the power plan and is released after testing.

Final validation passed: 101 selected native assertions, zero failures; all
16,053 official package members match the tested runtime. The temporary
keep-awake request was released successfully with the power plan unchanged
(power-request.json). Author acceptance remains pending.
