# 5.2.8 / issue #188 - Toughness validation

Author acceptance, 2026-10-11: CA188-01 passed without qualifications.
The author authorized the #188/#192 merges and closures on the combined 5.2.9
build. HISTORY records the confirmation. The agent report below preserves its
original test scope and delivery-time pending status.

Branch `issue188-toughness`, baseline `d4f11ea9`, GZDoom 4.14.2 on Windows 11.
Tests use isolated configs, unpaused background simulation, 5% master volume
and one engine process at a time. This is agent-run native evidence; author
gameplay acceptance is outstanding as CA188-01.

## Native evidence

- `official-final` and `matrix-08`: 249 checks passed in each. Exact mass fixtures, natural versus carried/
  artificial mass, independent maximum Health, physical versus half magical R,
  player/NPC parity, anatomy and firearm armor bypass, direct Fire, native
  crushing/weight and forced-damage sentinel, sustained bypass, owned partial/
  full shields and fractional remainder, wear with zero final damage, aggregate
  explosion mitigation and physical floor/actor/crush impact adapters.
- Burn/poison/disease at N=0/20/50/99/100/101/150 on both recipients: exact
  durations, original rate, immunity, healing, cap, dynamic attribute changes,
  noncompounding refresh, independent visuals, stronger/equal/weak reapplication,
  expired legacy clocks, subsecond and fractional repeated doses, original
  one-second pain pulse and actual unpaused world ticking. Disease tests use a
  controlled source; no gameplay disease source is added.
- All three gates use structural masses, authored armor and new final R.
- `save-upgrade-03`: an active burn/poison save produced by 5.2.7 loads and
  converts once. `save-repeat-01` loads the resulting save without another
  conversion. `save-rollback-01` loads the untouched original on 5.2.7.
  Runtime filename aliases preserve GZDoom's save-package identity.
- Healing save/reload and MAP03-to-MAP02 travel are checked separately; the
  latter recalculates the remaining normalized dose at the destination's
  effective Toughness. Final labels and exact hashes are in AUDIT.json.

Fixtures execute production receivers/status processing. They set controlled
attributes, inventory and positions; they are not a claim that every character
combination was entered through the creator or every combat animation was
manually exercised. Existing thermal environmental behavior is unchanged by
source inspection; thermal resistance/energy regression testing is outside
this patch. Projectile payload activation/DPS remain based on actual HP lost.

## Corrections and limitations

Initial fixture compile failures came from ZScript ternary types, string
concatenation and readonly native properties. The Bull needed initialization
before immediate inspection; the armor assertion needed the actual hit piece;
a forced-kill target was correctly destroyed and required a null-safe check.
Save setup first needed the existing runtime basename and a post-load CVar
assignment. Those exploratory runs are not passing evidence.

Cross-review identified expired legacy clock import, per-tic changes to pain
probability and forced native damage semantics. All three were corrected and
covered by the final matrix. One-second pulses now include the proportional
last fraction; old inactive effects import no banked damage. Shield precision
is retained until final HP rounding. Existing pain/lucidity formulas remain.

Status schema revision 1 is idempotent. Reversibility means preserving the
original save and previous package; downgrading a newly written save is not
supported. No user save, engine, IWAD or generated PK3 is committed.

## Reproduction

Run `python assets/validation_528/prepare.py`, then run_native.ps1 with a new
label and the desired fixture/cfg. `native` performs the matrix; `persistence`
is baseline-compatible. Create the legacy save with `-Baseline`, copy the
current package under an isolated `upgrade/baseline.pk3` alias and use that
alias for upgrading/reloading. Save files stay under build/issue188.

Official build: 6,346 package members match source byte-for-byte. Document and
localization indexes are current; project validation reports zero errors and
patch whitespace passes. AUDIT.json records source/package/evidence hashes.
The keep-awake request was released successfully; the before/after power plan
is identical. No persistent power setting was changed.
