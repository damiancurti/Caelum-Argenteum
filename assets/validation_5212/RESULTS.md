# Issue #195 native evidence - 5.2.12

GZDoom 4.14.2, Windows 11, Vulkan, deterministic seed 184. Runs use native
simulation at 35 tics/s, continue unpaused in the background and keep master
audio at 5%. Each run records exact arguments, configuration and engine/runtime/
fixture hashes. The temporary thread-scoped keep-awake request and its release
are recorded separately; the system power plan is not changed.

These are agent checks. **The author accepted CA195-01 on 2026-10-11 without
qualifications**, then requested PR200 merge and #195 closure. Native evidence
remains distinct from this explicit author acceptance.
Test sources are excluded from the shipped PK3. Generated maps/packages, saves,
the installed engine and development IWAD remain in the local build directory.

## Passing native runs

| Run | Checks | Scope |
| --- | ---: | --- |
| bull-07 | 114 | All eight functional profiles, magic/critical/evasion/adrenaline, idempotence, prisoner exclusions; 900 kg, cushioning, impairment/cap, old charge initialization; real 1/17/35/40-tic motion, tracking, Pain/binding; ordinary physical/magical/sustained damage remains independent of charge |
| contacts-03 | 216 | 48 cases: four residents, stationary/fleeing/approaching, neutral/real anatomy and both initiator orders; equal raw joules, separate bull cushion, native armor/Toughness and actual load |
| tools-08 | 71 | Native owned counts/load, preparation, actual flight/binding, Air/Anima, ice, fire rejection, same-item recovery/destruction, no replacement, charge then normal timing, interruption, real normal/charged/critical War Axe damage and adrenaline |
| residents-02 | 34 | Each resident uses its own bolas and paid ice; correct owned melee, prepared expiry, broken-item rejection, native chase and Argento's actual Light projectile |
| staff-regression-02 | 35 | Accepted player staff identity, heat/contact/occlusion, freeze, costs and exact-item wear through the shared service |
| bolas-regression-01 | 40 | Accepted player bolas lifecycle, repeated contacts, expiry, fire, cutting, recovery, owner removal and interruption |
| legacy-create-01 / legacy-load-02 | 1 / 8 | Real baseline dbf449cd (5.2.11) save with an active x2-mass charge; current code restores normal mass/cap and profiles/tools without healing or refilling Air |
| persistence-create-01 / persistence-load-01 | 1 / 8 | Current saved charge selection/remaining time, wear/contact fraction, exact binding/item references, no regrant and carried mass excluding the thrown item |
| encounter-02 | 14 | Production MAP01 assisted encounter, pre-fight autosave/grace, native residents/bull, no resident Fire, victory flag after corpse dissipation and protected residents |
| downing-02 | 7 | MAP01 grace protection, lethal-hit downing, action cancellation, victory recovery, native quest completion and departure enablement |

Total: **549 passing assertions**. Native compilation is an additional gate.
`verification.json` records final static/build/source-member checks and evidence
hashes. The final compile run uses the official development package.

## Observed results and limits

- Healthy bull: f = 0.2263767773; retained horizontal energy = 0.5984928906 E.
  Motion reaches 10 m/s displacement at tic 35. Native post-tic friction reports
  9.0625 m/s velocity; that value is not the actual distance traveled per tic.
- Initial collision masses including armor and the owned tools: Rulo 315.527 kg,
  Ronnie 183.018 kg, Argento 147.018 kg and Caella 102.018 kg. Natural mass and
  Toughness remain separate. Real-anatomy contact traces retain raw and final HP
  for all 48 scenarios instead of treating a neutral fixture as a gameplay result.
- Rulo's isolated charged attack has 60 tics of preparation followed by a
  13.858144-tic normal cycle; the swing releases seven tics into that cycle.
  Native War Axe raw damage is 1324 charged / 662 normal at the tested profile.
  The controlled accuracy test forces a critical to verify actual delivery;
  ordinary spread can miss and still costs Air.
- The full MAP01 observation uses an invulnerable, non-attacking player so the
  resident/bull interaction can finish uninterrupted. The bull dies before the
  35-second sample after 27 health-loss events. Ronnie uses 20 melee cycles,
  including eight charged; all residents throw one bolas, and ice and non-fire
  magic are active. This is one deterministic observation, not a guarantee of
  player survival, an exhaustive balance sweep or author acceptance.
- Native `DamageMobj` probes and explicit setup of quest prerequisites isolate
  downing/progression. They do not claim manual dialogue traversal. Original
  player-gift and MAP01 no-leather code is unchanged; CA195-01 includes those
  end-to-end checks. The live screenshot was inspected for renderer/startup
  integrity; existing sprites are reused and no new weapon artwork is claimed.
- Current save fixtures preserve active preparation and a real restrained item;
  the baseline save is newly created with the previous committed runtime. No
  author's original save is overwritten. Native tests keep saves local.

## Failed attempts retained and resolved

Early compile runs exposed ZScript scope requirements for the UI-readable staff
cost function. Separate player read-only cost from the actor play-scope cost.
Tool preparation initially shadowed the saved `Charged`/`Secondary` fields;
distinct parameter names fixed actual charged selection. Static cross-review
also closed legacy unowned melee fallback, moved payment to release, restored
successful-hit adrenaline and stopped ice after loss of range/sight. Binding
now exits the charge loop.

Fixture corrections include deferred PostBeginPlay initialization, native format
arguments, reserved identifiers, virtual-override defaults, exact stat/quest
field names, relative save basenames and avoiding dereferencing a dissipated
corpse. A prepared-window probe originally observed the immediately selected
next attack; moving its target out of range isolates expiry correctly. The
reused #162 fixture's exact recipe revision 6 assertion was updated to >=6 to
accept intervening committed recipe additions; its knowledge assertions remain.
All original logs are preserved beside the corrected final evidence.

Exported log copies normalize UTF-8/LF and trailing whitespace only. Exact raw
engine bytes remain in build/issue195; verification.json hashes both originals
and exported evidence. No diagnostic or failed assertion is removed.

Run `python assets/validation_5212/prepare.py`, then the PowerShell runner with
the fixture/config/map shown in each run record. Legacy creation requires
`-Baseline`; loading uses the recorded save basename. Do not overlap engine
instances. The player regressions reuse their original fixture sources and map
from validation_5115/5116, with explicit handler/marker adaptation in prepare.py.
