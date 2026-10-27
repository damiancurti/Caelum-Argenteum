# #410 cooking and proofing - 5.8.19

The four existing meals can now be made through native attended cooking.
Bread first uses a shared, unattended counter batch and a portable 1.141-kg
proofed-dough ingredient. Dough and meals retain actual food-lot contamination;
cancelled cooking releases reserved inputs with their accumulated age.
Three fixed kitchen stations use existing mansion geometry. This delivery does
not complete the wider furniture catalogue or the separate campfire adapter.

The official final package is build/issue410-cooking/final19b/caelum_argenteum_dev.pk3.
report.json records its SHA256, all 16,951 matching source members and selected
run counts: 160 newly executed PASS / zero FAIL across 13 native runs.
The static validator passes; localization and document indexes are current.
Native GZDoom 4.14.2 checks run unpaused in the background at 5% audio. They are
not a campaign frame-presentation benchmark or author visual acceptance.
CA410-COOKING-01 remains pending; the author is away.

## Coverage

- All four recipes: exact approved native quantities, fixed world durations,
  no Workbench requirement, ten portions, food-mass-weighted contamination,
  preserved water container, cancellation/ongoing age and no duplicate completion.
- Water reservations reject contaminated water and block unrelated water actions;
  loss of water before completion cannot partially consume food or create output.
  Leaving the station stops attended progress.
- One counter batch: exact 420mL/721g inputs, no duplicate/early collection,
  1,141g nonedible dough, exact retained contamination and free vessel after collection.
  Saves and hub absence retain the batch; advancing two hours on another map makes
  it ready on return. The visible menu updates readiness without reopening.
- Active cooking save/resume preserves task kind, exact duration and water
  references. Existing pre-5.8.19 saves load with the new runtime; the untouched
  original save also loads again under its original 5.8.18 package. No author save
  is modified; older runtimes are not promised to read newly added classes.
- Recipe-book migration preserves older learned recipes, initializes only appended
  slots and is idempotent. Four books have ten copies each; repeated synchronization
  does not refill sold copies.
- A full thirty-world-minute accelerated fish cook uses the normal dispatcher,
  world clock and automatic food service. Ten portions are produced; one is
  immediately eaten because Hunger fell during the wait. The nine remaining plus
  active digestion are verified separately from the ten-output completion checks.
- Actual mansion geometry: one of each actor at the declared positions, clear
  approach, usable interface and idempotent installation. Native Spanish menu and
  final painted-iron mesh captures were inspected. Author review remains pending.

## Evidence applicability and resolved failures

process05 establishes cooking, water guards, recipe migration and saved tasks.
process07 adds proofing-menu clock refresh and the mansion kitchen's existing
Limbo wait exemption; the full accelerated run, hub absence and visible readiness
pass on that build. process08 changes only kitchen artwork. final19b adds current
release diagnostics and uses the normal builder; the complete cooking core passes
again. collect_evidence.py verifies every final archive member against src.
Earlier checks apply to unchanged final behavior; report.json does not add saved
cumulative counters to literal newly executed PASS lines.

Development-only failures were corrected before final evidence: a reserved local
identifier, play-scope data access, an incompatible Inventory ternary, a fixture
outside its private room, and a runner that did not recognize its new log prefix.
The first fast test found a real missing kitchen-group wait exemption; production
safety now recognizes kitchen stations and native acceleration passes. The first
successful fast run expected ten inventory portions but existing automatic eating
legitimately consumed one; its assertion now verifies that consumption explicitly.

No recurring global actor scan is introduced. Installation uses bounded local
queries; shared proofing lookup is bounded by MAXPLAYERS and saved counter records.
Only an open counter menu refreshes its clock, once per visible second, including
accelerated loops. Storage retains the existing captured-climate limitations;
complete unloaded magical modifier history remains separate #415/#502 work.

Original imagegen sources, prompts and historical construction references remain
under assets/art_source. The generated source manifests and exports.json verify
15 repeated new output files and 11 unchanged accepted ingredient/meal files.
The source iron image is new; no accepted artwork is replaced. Private test PK3s,
saves, engine and development IWAD are not distributed. Failed probes remain in
the private build folder for diagnosis.
