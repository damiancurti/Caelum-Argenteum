# #136 mechanical-work correction (5.1.7)

Author-approved follow-up to [FOLLOWUP_RESULTS.md](FOLLOWUP_RESULTS.md), whose
earlier swimming, jump, attack and firearm profiles are superseded here.
GZDoom 4.14.2, Windows 11/Vulkan, 2026-10-08 local time. Native results below are
agent evidence. The author subsequently confirmed CA136-01, CA136-02 and carried
CA143-01 passed on 2026-10-08, without reported qualifications; HISTORY records
their original releases/issues. The manifests retain their delivery-time status.

## Approved contract

Positive mechanical work W consumes an equivalent 4W of metabolic energy at
25% efficiency and releases Q=3W as body heat. This energy accounting adds no
new Air or Hunger cost. Actual motion, weapon timing, damage and resource costs
are unchanged. SYSTEMS and CaelumThermalData contain the authoritative table.

| Activity | Work | Heat |
| --- | --- | --- |
| Jump, 133.576 kg total moved mass | 655.190 J, fixed 0.5 m at 9.81 m/s2 | 1,965.571 J |
| Dagger primary / secondary | 50 / 75 J | 150 / 225 J |
| Sword primary / secondary | 125 / 200 J | 375 / 600 J |
| Greatsword primary / secondary | 300 / 450 J | 900 / 1,350 J |
| Natural NPC bite/horn | 25 J | 75 J |
| NPC machete equivalent | 75 J | 225 J |
| Zupay ground slam | 850 J | 2,550 J |
| Firearm shot, 100 kg / 1.80 m body | 12.745 J | 38.236 J |
| Complete firearm reload, same body | 238.973 J | 716.918 J |
| Walking / running, flat | 0.5025 / 1.005 J/kg/m | 1.5075 / 3.015 J/kg/m |
| Swimming normal / fast, same body | 159.315 / 286.767 W | 477.945 / 860.302 W |

Enhanced jump height is outside the fixed human effort budget. Melee work has
no attribute multiplier; charged attacks and sweeps retain their independent
approved x2/x3 work factors. Shooting pays once; reload pays the fraction of
completed progress, so Dexterity/movement changes duration, not the full budget.
Faster characters can still produce more heat per second by completing more
attacks or metres. Isometric pushing remains 6 MET total, 637.260 extra W for
the reference body. Blocking is 0.2943 W per kg moved mass per kg held: 235.869 W
with 133.576 kg and a 6 kg shield. These are calibrated game approximations.

Resilience adaptation now uses 1+A(A+1)/10100, base plus Type 2. At 100:
+/-10 C and 2 C/world day, five days from base comfort to either limit under a
sufficiently different climate. Old offsets return gradually. Toughness's
thermal thresholds already used this Type-2 widening and remain unchanged.

## Native evidence

The final suite (`energy-checks-c`) passes **76 assertions**. It covers fixed
work, distance partition invariance, uphill/downhill, swimming, blocking,
Type-2 factors and five-day limits, gradual reduction of a saved +15 C offset,
idempotent revision-8 migration, isolated travel energy, actual melee and firearm
entry points at normal/all-100 attributes, moving/stationary and cancelled
reloads, charged javelins, and five initialized NPC species: bull, giant rat,
Mandinga, Zupay and soldier. Calling the shared ground-slam budget on each
specimen tests the service; it does not add slam attacks to those species.
Reload loops in this suite call the real method directly for energy accounting;
the save tests below additionally exercise elapsed engine tics.

Four copied-MAP01 controls issue a native one-tic jump, hold ordinary greatsword
attack for six seconds, then rest. They normalize the starting state only:
no ongoing HP, Air, Hunger or Thirst rescue. At 25 seconds:

| Character / armor | Jump heat J | Ordinary attacks | Melee heat J | Exposure E | Thermal HP loss |
| --- | ---: | ---: | ---: | ---: | ---: |
| Normal human / heavy | 2,819.041 | 12 | 10,800 | +0.721276 | 0 |
| All-100 human / same heavy armor | 2,819.041 | 35 | 31,500 | +2.151082 | 0 |
| All-100 Caelith / light | 2,671.891 | 42 | 37,800 | +2.362311 | 0 |
| All-100 goblin / magic | 2,009.716 | 35 | 31,500 | +2.717527 | 0 |

The different jump totals reflect each body's actual moved mass, including
test equipment. The matched humans jump at native JumpZ 1.519073 versus
39.885962 but pay identical heat. Each greatsword attack pays 900 J. All four
finish with zero continuous activity power. They are short controlled trials,
not proof of indefinite exercise safety, other climates or all equipment tiers.

Two 50-second native pool controls use the normal/high-stat author checkpoints.
Both record exactly 477.945292 / 860.301526 W for normal/fast swimming and zero
after releasing input, with zero thermal damage and zero HP rescues. Final E is
-0.076436 / -0.076163. The observer fixes swimming depth and refills Air to
isolate exercise from drowning; this is not an underwater survival claim.

Two native timed blocking controls equip a real dagger and kite shield, start
and stop the actual combat-block mode, then allow ordinary engine updates.
147.576 kg moved mass and the 12 kg shield produce **521.1794016 W**, identical
at normal/all-100 attributes. Stopping gives zero activity power. Both record
zero thermal damage without ongoing resource support. The 6 kg/235.869 W
approved reference is separately covered by the numerical native assertion.

## Persistence and scope of reused evidence

A preserved revision-7 package from commit 3366aba4 creates an old checkpoint
mid-reload with +15 C acclimatization. Revision 8 retains its exposure and
completed ActionJoules; the remaining reload adds **582.397768202 J**, exactly
the remaining fraction. Saving again mid-reload and loading on revision 8 adds
the remaining **494.118906688 J**, without doubling the already queued work.
Reloading the untouched original checkpoint with the original runtime passes
rollback. The short Limbo test preserves the old offset; gradual return over
world days is covered separately by the native numerical tests. No author save
is overwritten or distributed, and no retroactive health refill is applied.

The first 74-check run, 49-shotgun regression assertions, four jump/melee
controls and persistence runs preceded one final correction: passing the
charged flag to the javelin's heat event. The final 76-check suite covers that
specific event. `finalize_energy.py` reconstructs the preceding package
byte-for-byte from final source with only that call changed, and verifies its
SHA-256 against those run records. Unaffected evidence is reused explicitly;
the swim/block controls and 76-check suite use the final runtime.

Rejected fixture setups are retained locally in build/issue136 and excluded
from passing totals: energy-checks-a omitted forecast inertia and inspected NPCs
before PostBeginPlay; energy-live-normal-a used a nonexistent size helper;
energy-save-seed-a initialized the profile at map tic zero. They required
fixture corrections, not production workarounds. None is counted as a pass.

## Reproduction and delivery checks

Run `python assets/validation_517/prepare_energy.py`; use `run_check.ps1` with
fresh labels. Energy checks: energy-checks.pk3 / CA136 / energy-checks.cfg.
Live cases: energy-live-0 through -3 on copied checkpoints / energy-live.cfg.
Block cases: energy-block-0/-1 / energy-block.cfg. Swimming reuses the unchanged
heat-observer.pk3 and swim.cfg prepared by prepare_followup.py. Do not overwrite
old evidence packages while a run is active. Save variants retain the same
energy-persist.pk3 basename; modes 0/1/2 create, upgrade/reload and roll back.
Baseline reconstruction requires the recorded commit and preserved local saves;
private saves, generated fixtures, engine and IWAD are not distributed.

All **15 selected native runs** exit zero without runtime errors. Static
validation, normal PK3 build, source/member equality and diff whitespace checks
pass. ENERGY_MANIFEST.json records payloads, run/log hashes and saved checkpoints;
ENERGY_VALIDATOR.json contains the full static report. Existing art/map generator
evidence remains in FOLLOWUP_GENERATORS.json: this correction changes neither
generator nor generated art/maps, so those unrelated checks were not repeated.
The eight prior first-person captures remain applicable to unchanged artwork.

Tests use one engine process at a time, 5% audio and unpaused background
simulation. The temporary keep-awake request was released and the original
power plan verified unchanged (ENERGY_POWER.json). No mass-siege or multiplayer
acceptance is claimed. The author confirmed all outstanding tests passed and
authorized #136 closure and PR #146 merge on 2026-10-08. The acceptance-only
update changes no runtime files; the recorded native evidence remains applicable.
