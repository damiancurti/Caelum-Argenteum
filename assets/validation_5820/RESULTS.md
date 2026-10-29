# Kitchen sink and wall cupboard — 5.8.20 / #410

The mansion kitchen gains a fixed finite-water sink and an overhead native
storage cupboard. This is a focused furniture slice; other #410 furniture,
portable acquisition and separate #411 camp cooking remain unfinished.

Official build: `build/issue410-cooking/final20b/caelum_argenteum_dev.pk3`.
The delivery correction changes only the sink/cupboard Spanish locale header;
two added native assertions resolve their Spanish names. Prior gameplay/art
evidence remains applicable, with its original hashes preserved.
`report.json` records the exact SHA256, source-member comparison and executed
assertion counts. The collector rejects any static error, failed assertion,
VM error or nonzero native exit. Counts are newly executed PASS lines, not
cumulative totals restored from saved test handlers.

## Coverage

- Sink: independent mansion/city reserves; finite200L, actual5-L large-canteen
  filling, partial supply, empty/Box rejection, retained receiving contamination,
  one-litre world-minute refill and no repeated-lookup reset.
- Cupboard: native ten stacks/100kg, accepted exact weight and rejected overflow,
  unchanged item ownership on rejection, real food quantity/contamination,
  original padlock/key installation, inaccessible/matching key checks and removal.
  Fixed wall carry is blocked while the original portable chest still works.
- Save and hub travel: cupboard contents/food age, source identity and only
  elapsed refill. Existing city bathroom placement, source and permission checks
  pass in CAH000. An original5.8.19 proofing save retains its batch/ingredients
  under the new runtime; its untouched copy also loads with the original package.
  No author save is edited. Older runtimes need the preserved original save.
- Actual mansion: both actors fit unchanged geometry, approaches remain clear,
  sink resolves through inventory-source lookup, aimed native Use opens the
  elevated cupboard. Installation is idempotent. Captures include models and
  painted fallback sprites, explicitly displayed by private actors with the
  production sprite aliases and no MODELDEF. The initial r_models toggle did
  not visibly change this scene, so it is not used as fallback evidence.
  Ordinary player collision remains active.
- Export: seven deterministic outputs;176 accepted map/bathroom files unchanged.
  Original cupboard source and delegated nominal stock calculation are retained.

Selected persistence/regression runs use probe fixtures05. The collector checks
that its differences from final20 are limited to a generated comment, diagnostic
version labels, physical fallback-sprite scale and the visible locked padlock.
Core/mansion runs exercise final20; final20b adds only the language correction
and has its own native locale run. Reproduction: prepare.py,
run_native.ps1 with the scripts/addons recorded in each run JSON, then collect_evidence.py.
Original-save fixture uses the unchanged validation_5819 preparation scripts.

Native GZDoom4.14.2 checks run unpaused at5% audio; the final capture pass uses
a visible window. These results
are functional evidence, not frame-time/60-FPS evidence or author acceptance.
CA410-FIXTURES-01 and inherited CA410-COOKING-01 remain pending. Earlier failed
probes are retained privately and their corrections are recorded in HISTORY.
