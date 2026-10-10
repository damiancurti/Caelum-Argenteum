# Caelum Argenteum — Current systems and rules

Documentation version: **5.1.12** — 2026-10-10.

## SI physics and attribute growth — 5.1.10 / #154

This section is the current contract. It supersedes the curve, gravity, movement,
jump and efficiency numbers in earlier release notes retained below. Those older
numeric examples describe their original release, not an alternative live rule.
The three new families are shared by player, NPC, gear-derived statistics, Tarot,
crafting, dialogue, Trucazo, the Box, combat, survival and thermal consumers.

For the effective attribute N, `B=(N*N+25*N)/125` percentage points. Types 1/2/3
have bonuses `B/3B/7B`; their multipliers are `1+bonus/100`. At N=100 these are
x2/x4/x8. Old Types 1/2/3/4 map to new Types 3/1/1/2, respectively; old Type 3
keeps its decreasing complement. Historical adapter method names remain for
save/API continuity. Attributes above 100 remain valid; probability caps,
integer truncation, base bonuses and operation order remain consumer-specific.

| N | B, percentage points | Type 2 bonus | Type 3 bonus |
| ---: | ---: | ---: | ---: |
| 0 | 0 | 0 | 0 |
| 1 | 0.208 | 0.624 | 1.456 |
| 10 | 2.8 | 8.4 | 19.6 |
| 25 | 10 | 30 | 70 |
| 50 | 30 | 90 | 210 |
| 75 | 60 | 180 | 420 |
| 100 | 100 | 300 | 700 |
| 150 | 210 | 630 | 1470 |

Health/Anima maxima, damage, push and precision use Type 3. Air/Adrenaline,
capacity, attack/cast speed, regeneration factors and the Constitution needs
divisor use Type 2. Critical/evasion/dialogue bonuses use Type 1. Toughness
still subtracts B percentage points of maximum Health from ordinary damage;
thermal resistance clamps B/100 to [0,1], whereas thermal thresholds use 1+B/100.
Resilience adaptation uses 1+B/100: at 100, +/-10 C at 2 C/world day, still five
days from the racial base. The Box uses `2+int((100+7B)/50)`, hence 4/18 slots
at Intelligence 0/100. Tarot modifies attributes before these curves.

Spatial/time constants are centralized in CaelumPhysicsUnits: 32 MU/m, 35 tics/s,
velocity `MU/tic*35/32`, acceleration `MU/tic²*1225/32`. Ordinary effective gravity
is 9.81 m/s², or 0.25626122449 MU/tic². GZDoom's ordinary level gravity 800 becomes
205.008979591837, once per map, through a serialized marker. Actor/sector gravity
modifiers and deliberate no-gravity states remain native. World/calendar time,
map geometry, body dimensions and projectile muzzle-speed data are not rescaled.

Unpenalized steady forward walk/run at Agility 0 is 4/8 m/s, multiplied by Type 2:
16/32 m/s at 100. Native input and friction remain in control. The existing
per-tic acceleration envelope `f+=(1-f)*0.028127624` remains; 95% of input after
three seconds is not a constant-force or constant-power acceleration model.
Existing load, health, survival, Air, elemental, shield and reload modifiers remain.
Foot journeys use steady walking speed: 14.4 km/h at Agility 0 and 57.6 at 100
before penalties, with the existing 16-hour walking / 8-hour sleeping schedule.
NPC native chase-step schedules and animal base speeds are preserved; a Speed
field is not a promise that an NPC moves that distance every tic. Folklore actors
reuse the shared walk reference, and saved bull charge speed is recalculated.

For biological mass mb, moved mass mt and effective Agility A:
`Ejump=800*(mb/80)^0.75*M3(A)` J;
`v=sqrt(2*Ejump/mt)` m/s; `JumpZ=v*32/35`; ideal rise `Ejump/(mt*g)`.
At 80 kg without load: A0 gives 800 J, JumpZ 4.088810, ideal rise 1.019368 m;
A100 gives 6400 J, JumpZ 11.564901, ideal rise 8.154944 m. Native discrete apex
is slightly higher (observed 1.083425/8.336096 m). Load enters mt once; there is
no second load multiplier on JumpZ. Retained state/elemental velocity factors
square into delivered energy. Immobilization still prevents jumping.
Thermal impulse uses the accepted native increase in vertical kinetic energy
once, not the old fixed 0.5 m reference, and adds no new resource debit.

Only fall damage's reference velocity threshold scales by sqrt(0.25626122449),
equivalently its squared-speed threshold by 0.25626122449. Biological landing
absorption uses the new jump contract. Wall/actor/environmental collision laws,
restitution, anatomy and material factors remain. Real total carried mass is
used in NPC collision inertia, including weapons and supplies; biological mass
still owns health scaling and thermal inertia. Local reduced gravity is not
cancelled by a second per-sector threshold adjustment.

| Projectile | Actual launch MU/tic | m/s | Flight and NPC aiming |
| --- | ---: | ---: | --- |
| Arrow / bolt | 60 | 65.625 | Native Actor gravity; class defaults 35/45 are overridden by the shared firing path |
| Carbine / shotgun pellet | 80 | 87.5 | Native Actor gravity; player aim remains manual |
| Javelin | 15 times sqrt(physical push multiplier) | 16.40625 times that factor | Native Actor gravity; retained Strength/body-mass launch equation |
| Cannon | 457.142857143 | 500 | FastProjectile integrates GetGravity once before movement |
| Elemental | Existing 15/20/40 or authored NPC speed | Converted with the same units | Authored straight/seeking behavior retained |

Soldiers and cannon crews solve a low ballistic arc at launch, toward the current
target center, with no target-motion prediction or homing. Six bounded Newton
corrections account for Actor's move-then-gravity versus FastProjectile's
gravity-then-move order. The existing angular dispersion is applied afterward.
No solution retains the previous direct-shot policy. Collision and range limits
remain native. This is a bounded launch calculation, not an every-tic AI solver;
no mass-siege performance improvement is claimed by this issue.
Dispersion categories become k–10k degrees for k=1..7, retaining assignments:
book 1, longbow/statuette 2, crossbow/dagger 5, ordinary melee 6,
carbine/shotgun/bell and the existing maximum-category heavy weapons 7.
Physical and magical precision use Type 3; crouch, aim and random sampling remain.

Muscular efficiency is `eta=min(0.99,0.25*M1((Agility+Dexterity)/2))`: average the
attributes first. It is 25% at 0/0, 32.5% at 0/100 and 50% at 100/100. Positive
work W costs W/eta metabolic joules and yields `Q=W*(1/eta-1)` heat. Existing
distance/action work budgets remain: 0.5025/1.005 J/kg/m for walking/running,
m*g*h for ascent, fixed weapon work, shot/reload work and swimming work rates.
Greatsword primary 300 J therefore gives 900/300 J heat at 25/50% efficiency;
the 80 kg A100 jump gives 6400 J heat at 50%, versus 2400 J for A0 at 25%.
More actions or metres per second still increase watts. Isometric pushing and
blocking retain their separate metabolic cost; braking never becomes cooling.
Basal heat, sweat, shivering, breathing, external magic and calendar exchange
are separate. Stopping produces no new effort heat and no post-effort tail.

Player balance revision 4 and NPC/gate growth revision 1 preserve each resource's
percentage during the one-time curve migration (author decision 2026-10-09).
Health rounds to the nearest native integer, keeping a living character at least
1 HP. Ordinary equipment recalculation still clamps without free healing. Air
recovery debt preserves its fraction. Legacy traveler records reconstruct old
maxima from the retained profile because they did not store maxima. Ownership,
attributes, quests, Tarot and accrued thermal exposure persist. A saved pending
spell recalculates its new cost once, retaining tier/charge and remaining cast
time without spending Anima during migration. Thermal revision
9 discards only an old in-progress reload's future budget and re-evaluates it;
already measured heat remains. World/projectile gravity revisions are separate
from growth revisions, so future curve changes cannot reapply gravity.
Rollback uses the untouched pre-upgrade save and matching old package; downgrading
a newly written save is not promised. Evidence is in assets/validation_5110;
native checks do not replace the author's outstanding tests in pending_test.txt.

## Shotgun follow-up: ownership, presentation and aim (#152)

A successful distinct-ammunition transfer uses native AttachToOwner (including
BecomeItem), so owned cartridges have no world-sector/blockmap presence or pickup
flag. A carried stack saved with those flags still set is normalized on its next
Tick, without changing amount, owner or Box placement. This is an idempotent
repair of an invalid native state, not a new serialized inventory schema.
Failed capacity checks leave the source available for a later attempt.

Alternate fire on any ranged weapon is edge-triggered like Zoom: holding it
keeps the resulting aim state; release/repress toggles again. Its transient latch
is independent of the Zoom latch and does not change melee/magic secondary actions.
Ready/open shotgun grips use one complete hand pair below the weapon, retaining
the accepted under-gun support hand without a second foreground copy. Loading
hands/cartridges remain foreground; aiming retains the canonical carbine hands.
The pickup atlas now uses the author-approved 6 cm world-height reference from
editable art data, accepted natively by the author on 2026-10-09. Inventory icon size, collision, ammunition
mass/price/count, damage, cadence and reload timing retain their accepted values.

Thermal review boundary: the author's test body is 200 kg plus 285.428 kg carried.
At native gravity 38.28125 m/s2, raising that mass by 8.25 m adds 459,924.068 J
of vertical-work heat before horizontal work/losses; its fixed-reference jump
adds 7,143.073 J. This follows two different approved calibrations and is not an
energy-equivalent comparison. Sweat already starts at positive exposure, inside
the Normal band; exposure is not body temperature and need not settle at zero.
Furred races have a different comfort value but no separate fur-water reservoir.
The author is considering metabolic-power budgets, including zero-net-work effort
and the jump boundary. No new thermal coefficients or changes are approved here.

## Elemental presentation and proportional damage feedback (#137)

This pass changes presentation only. Fire/light, water/ice, earth/poison,
air/lightning and quintessence share four-phase projectile materials between
player and NPC paths. Charged size, homing, multishot, explosion, speed, collision,
range and status rules retain their existing data. The Federal prisoner keeps
his air/electric alternation; the electric shot renders the same travelling ray
as the staff. The ray extends behind its collision origin. Arrows, bolts,
carbine bullets, shotgun pellets and ballistic javelins use original meshes;
MODELDEF momentum pitch does not change their physical velocity or gravity.
Javelin impact still uses its existing breakage/material recovery.
Domingo (including soldiers) and giant-rat deaths use repaired complete poses
under their existing sprite names. Death timing, actions and corpse behavior
are unchanged; the old damaged PNGs remain available for rollback. Original
Domingo art uses eight poses; the rat's seven source poses repeat the last corpse
over its last two timed states. Nine rat movement/pain border repairs preserve
their original source-relative anchors. All bull cuts were audited unchanged.

Attached burn, poison, frost and lightning art follows owner height and width,
keeps the central silhouette open, and ends on real status expiry/death/removal.
Demon breath's animated cone follows the authoritative mouth/direction and four
existing visibility samples. Its visuals emit no damage, contact or thermal
energy; those remain in CaelumDemonBreath. The existing mine burst reuses fire
material without changing its explosion or twenty-tic lifetime.

Fullbright materials remain visible without dynamic lights. Nearby effects use
named native lights. Native trail particles live nine tics; impact actors live
at most twelve. The existing whole-map living-combatant service controls cosmetic
density: below 500, detail distance is 1024 MU and trail interval two tics; at
500 or more, 512 MU and eight tics, with only the first breath segment retaining
its light. The electric ray does not add a separate dot trail. Projectile bodies
and all individual combat/resources/collision remain active. These are visual
settings, not new gameplay ranges or a claimed performance budget.

Player damage feedback measures actual post-defense Health loss / maximum Health.
The approved colors are physical/bleeding red, fire/heat orange, ice/cold cyan,
poison green and electricity violet; other unspecified types retain red.
Successive hits add their remaining visual intensity, with an 18-tic linear fade
and 0.40 alpha cap (alpha gain = 0.80 * Health fraction). A 50-point loss from
2000 maximum produces 0.02 alpha, identical to five from 200. Prevented damage
has no flash. Burn/poison share the existing DOT damage type while carrying only
a temporary presentation context; this does not modify defenses or damage.
The Doom absolute-point damage palette counter is cleared after damage handling.

The existing Health thresholds drive peripheral red gradients: <=50% uses 0.12
outer opacity; <=10% uses 0.30. Lucidity retains its own existing 50%/10%
thresholds and all accuracy/stun rules, with a stronger animated violet gradient
and cyan/magenta peripheral motion. HUD text/bars render afterward; camera angle,
aiming, controls and central visibility are unchanged. Feedback state belongs
to the affected player, including viewed-player HUDs. New cosmetic fields start
at zero in old saves; cosmetic revision 1 is applied idempotently without
resetting saved ages. Serialized classes/state indices and all gameplay fields
remain available, with native old-save/current-save/hub verification.

## Double-barrel shotgun and equipped-armor bypass (#136)

The author's final contract replaces the **shortbow/standard bow**, not the
longbow. Playable ID 14 and catalogue/recipe ID 12 now identify the two-handed
side-by-side shotgun at T1/T2/T3. The old selector class and numeric IDs remain
serialized aliases. Longbow and crossbow retain their current behavior.

One shot spends one cartridge and one carbine-equivalent Air cost, launching
12 independently colliding pellets. Each nominal pellet is one tenth of the
same-tier carbine damage; full pre-mitigation totals are 4320/6912/10800 before
shared modifiers. Differences of rounded cumulative pellet budgets preserve
the nearest integer total, including non-divisible values; zero stays zero.
Misses lose their share, and hits on multiple targets distribute one budget.
Critical, anatomy, Toughness, shields, push and successful-damage wear use the
existing projectile pipeline. Defenses resolve per pellet, so post-defense
damage need not equal 1.2 times a single carbine impact.

Capacity is two cartridges, one per barrel. A two-bit chamber mask persists;
ordinary shots fire right then left. Reload fills available chambers up to
the inventory's total quantity, without spending ammunition again. Empty,
single-cartridge and partial reloads use the same carbine five-second base and
Dexterity/movement modifiers. Interruption grants no cartridge. Fire costs the
same base 2 Air; reload retains the carbine's existing resource rules. Calibrated
firearm muscular heat, rather than the generic melee Air-to-heat conversion,
also applies. Mass (T1 12 kg), durability, critical chance, recipe components,
material quantities and manufacturing complexity copy the corresponding carbine.

Range is 30 m, half the carbine's 60 m. Both use **Maximum dispersion: 13–130°**
before the shared accuracy, aim, crouch and movement adjustments. The author's
final correction supersedes the intermediate double-dispersion approval.
Dispersion categories are separate from T1/T2/T3 equipment tiers: maximums are
10/30/50/70/90/110/130°, with minimums one tenth of maximums. Existing longbow
code remains 3–30°; the historical 70° note in HISTORY is not a new balance
change. Ranged tiers still affect damage/critical chance, not spread category.

| Weapon | Equipped armor bypass T1 / T2 / T3 |
| --- | --- |
| Shotgun | 60% / 70% / 80% |
| Carbine | 70% / 80% / 90% |
| Cannon | 100% at every supported tier |

Defense is innate racial defense plus equipped defense times the retained
fraction. Toughness, armor reinforcement/vulnerability grades and shields
remain separate. Only the equipped absorption contributes to equipment wear.
Projectile metadata freezes the fired weapon's type/tier; changing equipment
in flight cannot change penetration. Player and NPC damage/contact solvers
share this rule, including armor's contribution to contact lucidity protection.

Shotgun cartridges are independent ammunition ID 6; arrow, bolt, bullet and
javelin IDs are unchanged. Their mass is 0.003 kg and base price equals carbine
cartridges. Armories receive 100 once, including an idempotent old-stock upgrade;
reopening does not replenish stock. MAP02 adds six 20-cartridge drops to previously
unassigned living enemy slots: 2/1/2/1 per section. Existing supplies and keys
remain assigned to the same enemies; map geometry is unchanged.

Shotgun revision 1 migrates old shortbow items, current models and persistent
records once. Tier, identity, ownership, Box placement and proportional condition
survive; durability scales 1200/1000. Recipe ID 12 retains knowledge and learns
its replacement dependencies. Shared arrows and known arrow recipes remain for
the longbow; no arrows become cartridges. The migrated shotgun starts empty.
New constructors stamp revisions before inventory synchronization. Native
old-save/current-save/hub tests cover these boundaries. Keep the original
5.1.6 save and matching package for tested checkpoint rollback; direct downgrade
of a newly saved 5.1.7 game is not promised.

First-person presentation uses separate complete weapon and separate hand
layers for ready, aim, recoil and reload. Ready/reload hands have the author's
requested smaller scale and muted colors; aiming reuses the carbine's existing
hand poses, scale and under-stock placement. The three weapon tiers share the
same hand set. Hand-style selection is a future feature; adding
it will not require redrawing the weapon. Equip/holster uses the existing
lowering motion and shot/reload timing remains controlled by gameplay.

## Soldier crouched carbine aim (#143)

Stationary city infantry uses the existing crouch and ranged-aim rules for actual
carbine shots: accuracy x2 from crouch and x2 from aim, critical chance x2 from
crouch with the existing 100% cap. Each factor applies once. NPC aiming affects
its own spread; it never zooms a player's camera. Firing still stops horizontal
velocity and retains individual target, resource, cadence, damage, wear and reload.

Physical crouch is the native player's half-height floor: a 57.6-MU soldier
uses 28.8 MU. `A_SetSize(..., true)` tests clearance before restoring height;
a blocked attempt retains the shorter body and removes aim. Movement, melee
selection, resource recovery, pain, sleep, physical stun and death interrupt
crouched aim. Losing the valid visible target releases it. Reload movement and
progress retain their existing half-speed rule. No crouch walking speed or
new accuracy balance is introduced.

CAGC provides original directional aim/fire/reload poses. Its registered scale
is 1.909090909; the firing barrel is measured 116 source pixels above the foot
pivot. Both player and soldier carbine projectiles use this lowered muzzle
geometry when crouched. Physiology instead uses stored standing height, so
bending the body does not reduce biological surface area or heat exchange.
The player's stationary carbine uses CAGC without a second native sprite
compression; moving crouched retains its existing compressed walking cycle.

`CaelumCityCarbine` revision 2 records holder, standing height and posture.
Revision-1 initialization captures the full height once, without refilling or
resetting magazine, reload, weapon condition, resources or timers. Repeated
initialization is idempotent. Native save/load and hub reopen retain the shorter
collision box and original height. Keep the original 5.1.5 save/runtime pair for
checkpoint rollback; a newer save's direct downgrade is not promised. Legacy
sword-only defenders remain unchanged.

## Demon racial ability and finite supplies (#135)

Approved issue scope: Mandingas carry six small potions of each family; Zupay
carries six large ones. Small/medium/large restore 10%/22.5%/50% of the respective
maximum over ten real seconds. Existing potion classes are small; IDs 11..16
append the six new variants, keeping container and legacy IDs unchanged.
Native inventory stacks own quantities; an idempotent supply revision initializes
old living demons once. Dead bodies do not receive retroactive supplies.

On actual death, an existing map/native predefined drop has priority. Otherwise
one remaining unit is chosen uniformly across all remaining units, retaining
its exact family/size. No remaining units means no potion; a persistent death
latch prevents duplicate callbacks. Scripted retreat remains distinct from death.
The shared regeneration effect records the dose, fractional Health and delivered
pulses. Natural expiry completes the tenth pulse otherwise lost to native
Powerup ordering; cancellation/death/refresh do not grant a completion bonus.
Older active effects with no dose metadata retain their historical behavior.

Automatic use starts strictly below 50%. Each family waits until its own active
ten-second effect ends; Health, Anima and Energy may run concurrently. NPC Energy
restores Air; player Energy retains Air plus Sleep. No NPC Sleep is introduced.
All sizes weigh 0.25 kg. Medium and large prices are 2.25 and 5 times the small
base price, respectively. Carried native stacks contribute their actual weight.
Medium items have silver details, large items silver and gold, including medikits.

The approved sustained breath costs 10 Anima per real simulation second before
the existing Eloquence/armor pipeline, applied once. Natural regeneration remains
active. Cold means negative exposure in an authoritative cold severity state.
Both demons also use it against their current combat target within reach. Normal
sleep, stun, pain, retreat, death and inability to pay interrupt the ability; no
additional activation charge or cooldown is introduced. An already-paid ordinary
attack is allowed to finish before starting the racial ability.

Each demon has its own four-phase exhalation loop in eight directions. Mouth
anchors are measured in the new atlas: Mandinga 160 pixels above the foot pivot
and 60 forward; Zupay 147 above and 70 forward, divided by the registered texture
scale and multiplied by individual actor scale. A native trace prevents a
forward mouth anchor from crossing a wall. These are art geometry, not new
combat balance. Animation advances every three tics without delaying payment
or contact. Interruption restores AI from any phase. Contact extends
4 m (128 MU), within a 60-degree cone, with native wall traces. Contact refreshes
the existing T1 fire burn: shared base duration times Charisma's Type-4 factor,
and the shared DOT ratio of T1 staff damage times that factor. There is no
additional direct-hit damage; refreshing contact preserves the burn pulse clock.
Radiation alone never adds the burn status and has no distance cutoff.

Total emitted flame power is 20 kW, the existing campfire profile. Four cone
samples reuse the thermal fire projection, distance attenuation, 35% radiative
fraction, 0.95 surface absorption and wall visibility. Combined absorption is
capped to the emitted radiative budget before shared magical armor retention.
The emitter can receive its own radiation but not its own direct flame burn.
Cost/contact run each real tic; radiation integrates only paid real seconds in
staggered one-second samples, with the residual interval settled on stopping.
Moving sources use the sampled pose at interval end, matching the thermal
scheduler's temporal approximation; this is not sub-tic fluid/fire simulation.
The owned source, paid residual time, potion units and ongoing powers serialize.
Native evidence and outstanding acceptance are recorded separately in HISTORY.

## Functional port city contract (#133)

The campaign siege begins **15 November 1889 at 13:00**. New MAP06 starts
with the same 600 soldiers housed; the surviving actors walk through doors to
their assigned formations. Attackers start at the calendar boundary without
waiting for the defenders. Legacy already active sieges are not rewound.
Unloaded hub maps do not simulate movement: on return, the current civil date
triggers the still-unstarted event once. No teleport or offline casualty is implied.

Street deployment follows walkable ground and keeps artillery stair routes as a
separate phase. Soldiers can fight during deployment, wait for blocked doors and
resume after obstacles clear. Assigned positions retain their original identities;
front rows temporarily make an access column for deeper posts and then return.
Local detours use native collision and movement, with a bounded fair query queue;
they do not ignore bodies or reset resources. A retained harbor bed is avoided
by an explicit road-point override, not removed. Deployment and carbine state
remain attached to the individual actor across saves and hub reopen.

Each of 160 homes has a medium table, six native chairs, a native bed and an
empty bathroom. The 64-MU grid gives 123/62/20 usable cells: **60.000% living,
30.244% bedroom, 9.756% bathroom**. Wall cells and raised window sills are
excluded; entrance/internal doorway circulation belongs to the living/bedroom
areas. INTERIORS.json owns geometry, occupants, factory profiles and coordinates.
The west tower reserve formation is translated 256 MU east as a group in the
new revision: the old 14-position grid crossed the wall and exterior. Its
40-MU spacing, identities and formation role are retained; legacy data stay exact.

Shop equipment is **T1 only**, with one unit per matching equipment variant,
20 per food/drink type, 100 per ammunition type, and 200 copper per independent
vendor; **no automatic restocking**. The six specializations are provisions,
melee, ranged/ammunition, jewelry, physical armor, and magic weapons/armor.
Existing purchase/sale margins remain 150%/50%, rounded per lot as before.
Author clarification: medikit/life potion, Anima potion and energy drink each
have base value **3 x food ration = 12 copper**. A carbine cartridge has base
value **4 x one arrow**; arrows/bolts use their existing material recipe and
T1 manufacturing markup, divided by batch size. Prices are not inferred from
Doom assets. Factories grant no inputs, recipe knowledge or efficiency changes.

Vendors are static, non-combat actors for this patch, as chosen by the author.
Their native inventories and 200-copper wallets belong to the individual map
actor, not to Palomo or a visiting player. Initial stock is materialized once
when first opened; sold equipment remains the same instance with its size,
identity, durability and water content. Purchases/sales preflight money, load,
Box slots and all needed native instances before committing. Equipped, reserved
and flagged equipment cannot be sold. Arrows/bolts retain their existing personal
inventory storage; the trade service does not invent Box storage for those stacks.
Catalogue rows per specialization: 5 provision types, 65 melee variants,
20 ranged weapon variants plus 3 ammunition stacks, 9 jewelry variants,
75 physical armor/shield variants, and 125 magical weapon/armor/shield variants.
Sized equipment covers XS through XL; essence weapons cover all five essences.
Magic shields belong to the magical specialization. Basic clothing is not a
manufactured stock item. Tiers 2/3, filled water containers and javelin ammunition
outside the three-type ammunition catalogue are not added to shop stock.

New-city soldiers carry their existing sword/shield and a normal T1/M carbine.
`CaelumCityCarbine` (revision 1 in #133, revision 2 posture migration in #143)
owns that weapon's condition, magazine, reload and
shot timing. Only reserve availability is infinite: ten-shot magazines, the
existing Dexterity-scaled five-second base reload, Air/thermal cost, 60-metre
range, spread, critical chance, damage, projectiles and wear remain authoritative.
There is no physical infinite ammo stack or added ammunition loot. Melee selection,
pain, physical stun and death cancel reload without creating rounds. Holding the
carbine does not simultaneously enable the shield. Legacy defenders retain the
accepted sword behavior for matched #132 comparison and compatibility.

## Thermal exposure and energy transfer (#130)

V5.1.0 implements the author's 2026-10-07 contract. These are provisional game
coefficients, not a clinical body-temperature model. The signed personal value
`E` measures accumulated **equivalent exposure degrees**; negative means cold.
`CaelumThermalState` revision 9 belongs to the player's persistent character
record, or to each supported NPC. Shared services under `caelum/survival` own
the calculations; environment caches never own another character's exposure.

Humans and duendes have a 22 C comfort center; Beast Men and Caelith have 17 C.
Furry bulls and giant rats share the 17 C category without another fur bonus,
while retaining their own biological mass, size and attributes. Animal surface
uses a collision-cylinder approximation, not a humanoid height formula.
Mandingas and Zupay use 32 C. In 5.1.1/#131, effective Resilience
`A=max(0,Resilience)` multiplies both the base 1 C/world-day adaptation rate
and the base +/-5 C displacement limit by a Type-1 multiplier (#154):
`M=1+(A*A+25*A)/12500`. At A=100 this is 200% of the base: 2 C/day and +/-10 C.
This supersedes #131's Type-4 factor. Growth remains uncapped above 100.
Reaching either
limit from original racial comfort takes five world days under a sufficiently
distant sustained climate; traversing opposite limits takes ten. Nearby climates
stop at their actual offset. If effective Resilience decreases below an acquired
offset, adaptation returns gradually at the new rate, never by an instant clamp.
Players and supported NPCs use current effective attributes including equipment.
Acclimatization never also shifts stored E. Transient fire, drinks and magic are not acclimatization targets.
Players, anchored residents, folklore combatants, bulls and giant rats are
supported; unrelated actors without an approved physiology remain outside it.

For effective Toughness `D=max(0,D)`, the current Type-1 `R=(D*D+25*D)/125` percentage points and
`s=1+R/100`. Harmful thresholds are `10s`, `20s`, and **past** `30s`: exactly
`30s` remains tier 2. Numerical boundary tolerance is 1e-9. Threshold widening
is uncapped; HP mitigation alone clamps `R/100` to [0,1]. Tier 1/2/3 costs
1/2/3% maximum HP per **real simulation second**, multiplied by `1-R/100`.
Fractions persist. This direct environmental loss bypasses ordinary subtractive
Toughness, equipment, shields, native armor and adrenaline/reward paths.
At D=100, thresholds are 20/40/60 and thermal HP damage is zero.

| Consequence | Tier 1 | Tier 2 | Tier 3 |
| --- | ---: | ---: | ---: |
| Heat: qualifying Air costs | x2 | x3 | x4 |
| Cold: blunt incoming attacks | x1.5 | x2.25 | x3.375 |
| Cold: other incoming attacks | x1.25 | x1.625 | x2.1875 |
| Cold: movement and attack speed | /1.25 | /1.625 | /2.1875 |

Cold vulnerability enters once before existing defensive resolution, including
localized attacks; it does not increase hazard damage or thermal joules. Natural
NPC attack frames use the same slowdown. Weapon charge preparation keeps its
existing contract. Heat affects existing physical Air expenditure; it creates no
resting Air drain and does not multiply Anima or hypoxia into exertion heat.
The author-approved #133 sweat extension replaces the former thermal Thirst
multiplier with actual secreted water. The later #140 recovery rule charges
player Air and Anima the quarter-Health costs defined below.

### Regulated sweating (#133, 2026-10-08)

All supported humanoids, including Mandingas and Zupay, share the initial sweat
profile while retaining their racial comfort. In #140 the author also approved
that same surface-scaled profile provisionally for bulls and giant rats, retaining
their 17 C comfort and individual hydration. This is gameplay calibration, not
a claim that rodent or bovine physiology is identical to human physiology.
The 80 kg / 1.75 m reference produces at most 2 kg (approximately 2 L) per world
hour. Scale by actual surface area / 1.951493905 m², not carried load. Production
is `2*A/Aref*clamp(E/5,0,1)*clamp(Hydration/20,0,1)` kg/world-hour: zero at E<=0,
full thermal response at E>=5, full hydration response at >=20 Thirst points and
linear reduction to zero below 20. These E thresholds and the hydration curve
are explicitly approved game calibration, not clinical core temperatures.
The reference sweat ceiling is consistent with the 1.5-2 L/hour endurance-work
range described by [NIOSH](https://www.cdc.gov/niosh/docs/2016-106/pdfs/2016-106.pdf),
but is not claimed to be a universal human maximum.

Charge all secreted water using the inverse of the existing drinking rule:
`points/kg = 400*10/bodyMassKg`, or 10 Thirst points for 200 mL at 80 kg.
Constitution and rest do not make a measured litre of sweat cost less water.
The player's authoritative reserve remains CurrentThirst; thermal hydration is
a working projection. Each supported NPC owns a finite persistent reserve,
initially 100, without automatic refills or newly invented drinking AI. Zero is
an exhausted gameplay reserve, not absence of all water in the body.

Sweat is distributed by anatomical coverage into the existing worn/base-layer
moisture balance. Only actual evaporation removes the existing 2.45 MJ/kg latent
heat, once; runoff and submerged secretion still cost hydration but do not give
evaporative cooling. Humidity, relative wind, insulation, permeability and exposed
area constrain evaporation. Wet clothing can continue cooling after secretion
stops, including after entry into a cold place. Numerical substeps of at most
two world seconds resolve the coupled response; they add no simulation time.
Metabolic/action heat, signed environmental exchange and evaporation jointly
determine the energy balance. Equilibrium does not mean a living body must equal
air temperature. Since #140, carbine muscular heat has its own approved
action-duration profile below; other physical attacks retain the nominal-Air
and jump-reference conversion.

Revision 3 initializes only the new NPC reserve once, preserving exposure,
acclimatization, damage fractions and clothing moisture. Player migration reads
existing Thirst instead of refilling it. Journey previews advance their own
supplies and sweat together, including consumed water and the reduced cooling
of a depleted reserve; applying the thermal projection does not charge water
again. They retain changing regional weather, passenger shelter and zero invented
real-time thermal damage.

### Breathing and thermal coefficient cache (#140)

Ventilation uses the larger fatigue/heat factor, never their product. Air strictly
below 50% gives 1.5; strictly below 10% gives 2. Exactly 50% remains normal and
exactly 10% remains 1.5. Heat severity 1 gives 1.5 and severity 2 or higher gives 2,
using existing Toughness-scaled thresholds. Player and supported NPC natural Air
recovery is multiplied by that factor, preserving existing recovery exclusions.
Anima has no panting speed bonus. Dead or fully submerged actors receive no
breathing bonus or panting sound; hypoxia and its recovery debt stay separate.

The approved approximation adds only the extra respiratory sensible exchange:
`G_extra = (factor-1)*(6/1000/60)*1.2*1005*(bodyMassKg/80)` W/K. Six L/min is
reference ventilation; density is 1.2 kg/m3 and specific heat 1005 J/kg/K. The
80-kg reference gains 0.0603 W/K at 150% or 0.1206 W/K at 200%. Flow exchanges
against the existing equivalent thermal node, not a newly invented clinical
core temperature: `P_into_body = G_extra*(T_air-T_node)`. It cools only when the
inhaled air is cooler; hotter ambient air warms. Integrate it with the existing
world-time energy equation and retain signed RespirationJoules. No extra latent
respiratory water term is invented, and existing neutral metabolism is not
charged a second time. This small sensible term does not guarantee safe sustained
firearm or heavy-melee use; it does not eliminate wet-clothing cold.

Humanoid moderate/high male/female recordings play on CHAN_BODY. Player sex and
existing NPC voice profiles select the recording. Intensity changes replace the
loop; death, recovery and full submersion stop it. Voice/weapon/heartbeat channels
remain separate; an unrelated brief body sound can finish before panting resumes.
Audio bookkeeping is transient and reconstructed after loading. Animal ventilation
and sweat work physically; no supplied human voice is used as an animal recording.

The per-actor transient CaelumThermalCoefficients caches stable area/mass,
material/coverage/immersion, wind-film, ambient vapor and anatomical row weights.
Temperature, moisture, water temperatures, fire and activity still update energy
flux; wetness never becomes stale constant wattage. Anatomy constructor generation,
material/coverage keys and environmental inputs invalidate affected projections.
Existing bounded environmental sampling still detects shelter/fire changes.
Revision 4 preserves primary state and discards the cache on loading; revision 5
adds only a persistent pending-firearm-energy queue. Both migrations are
idempotent and preserve existing exposure, water and reserves. Independent
journey copies build their own caches and couple recovery costs with sweat/water.
The original issue's proposed core/skin and exact Stefan-Boltzmann replacement
were explicitly declined in favor of preserving the approved equivalent exposure,
linear 4.7 W/m2/K radiation and calibrated inertia. No new contact physics is added.
These safe per-actor coefficient savings apply to normal physiology at all counts;
#128's separate 500-living-combatant AI activation rule remains unchanged.

### Carbine muscular effort (#140, author decision 2026-10-08)

Primary carbine fire costs the same base Air as a dagger: **2**, previously 20.
The shared catalogue governs player and soldier costs; ordinary modifiers,
affordability, magazine consumption and recovery funding still apply.
The #136 energy-budget correction converts the approved 2/2.5-MET reference
profiles into fixed mechanical work. Subtract the resting MET, assign 25% of
the remaining metabolic energy to work, and use reference cycles of 0.4 seconds
for firing and 5 seconds for a complete reload. The authoritative budgets are
5.82 J/m2 per shot and 109.125 J/m2 per complete reload; resulting body heat is
`W*(1/eta-1)`. At 25% efficiency, the 100 kg / 1.80 m body produces 12.745/238.973 J work
and 38.236/716.918 J heat. They are approved equivalent-work calibrations, not
measurements of the gun animation or energy supplied to the projectile.

A successful shot pays once, when fired. Reload pays its fixed budget in
proportion to completed progress; Dexterity and moving while reloading alter
duration, not total energy. Partial-magazine reloads retain the game's complete
reload cycle budget. Interruption pays only completed progress. Idle aim and
failed shots add nothing. Player and NPC paths share the same work data.
NPCs queue completed joules until their bounded thermal update without forcing
the solver every tic. Save/load retains measured work and a reload's budget;
an old in-progress reload adopts the new rate for its remaining progress only.

### Cold regulation by shivering (#140, author decision 2026-10-08)

All supported physiological actors, including bulls and giant rats, provisionally
share `MET_total = 1 + 4*clamp(-E/5,0,1)`: no shivering at E>=0, a gradual
response below neutral, and at most 5 total MET at E<=-5. Extra production is
`surfaceArea*58.2*(MET_total-1)` watts integrated in world seconds alongside
resting metabolism. Recompute within the existing bounded thermal substeps;
there is no invented action-Air cost or post-shivering activity tail. This is
an approved equivalent-exposure calibration, not clinical core temperature.

Player extra Hunger loss equals the existing passive Hunger rate multiplied by
`MET_total-1`, retaining Constitution, body-mass and rest modifiers. Baseline
passive loss is charged separately once, so full shivering costs five times
the baseline overall. The remaining food fraction limits paid additional heat;
zero player Hunger funds no extra heat. NPCs retain the author's exclusion from
Hunger reserves and feeding AI. They receive the provisional shivering response
without a new food resource. No sweat or shivering water is reabsorbed as Thirst.

Travel forecasts use independent food/thermal projections and the same sleeping
comfort factor as journey supplies. Commit does not charge shivering twice.
Revision 6 initializes shivering metadata without resetting prior physiology or
pending firearm work. Accumulated shivering energy survives save/load.

Metal itself does not store absorbed water: the current metal-cloth material
stores moisture in its underlying light fabric (0.192336119 kg per square metre).
The model already evaporates retained water according to surface temperature,
humidity, wind and permeability; excess above capacity runs off. It does not
have a separate free-droplet film or an approved movement-shedding coefficient.
Fire already contributes declared, distance/occlusion-limited absorbed energy;
it can increase evaporation indirectly, not by an arbitrary drying percentage.
There is no independent garment-temperature node in this retained model.

### Clothing, water and shelter

Author-approved thermal mapping does **not** change leather-based recipes:

| Current equipment | Whole-outfit clo | Evaporation accessibility |
| --- | ---: | ---: |
| Base clothing: light cloth | 0.5 | 0.90 |
| Magical armor: thick cloth | 1.0 | 0.75 |
| Light armor: ordinary leather | 1.2 | 0.45 |
| Medium/heavy: metal over light cloth | 0.6 | 0.60 |
| Thick/demon leather calibration, no new assigned item | 1.8 | 0.30 |

One clo is 0.155 m² K/W. These include underclothes and are apportioned by a
16x16 sample of actual anatomical regions. They are parallel regional paths,
not a full outfit bonus per item. Broken equipped pieces retain physical
insulation; their ordinary magical defense remains zero. Wet outer pieces own
their water mass through equipment identity and copy/drop paths. The character
owns base-layer water. Unequipped pieces retain their moisture without passive
drying; Box contents remain sealed. This is an explicit first-model storage
rule, not a new waterproof treatment. Metal's outer moisture capacity is zero;
its included cloth retains water.

Air exchange uses `Fwet=1+0.02*wetnessPercent`; it already includes the approved
wet insulation loss. There is no second loss multiplier. Rain adds 2 percentage
points/minute per mm/hour on uncovered worn surfaces, bounded by capacity, while
evaporation continues. No extra treated-leather coefficient is invented.
Submerged anatomical rows saturate and exchange with water at 100 W/m² K,
replacing their air path without multiplying water exchange by Fwet. Native
height sectors and stacked swimmable 3D floors are sampled separately, including
volumes above dry feet. A volume/model sector may declare
`user_ca_water_temperature_defined=1` and `user_ca_water_temperature_c`, including
zero. Otherwise the explicit fallback is climate **ground** temperature.

Evaporation uses positive vapor-pressure gradient, permeability, a Lewis factor
16.5013576 K/kPa, available water, and 2,450,000 J/kg latent heat once. Runoff
does not cool. Clothing surface temperature follows its coupled resistance and
exposure, rather than staying fixed at 22 C. Saturation capacities derived by
`assets/validation_510/calibrate_drying.py` are 0.1923361193, 0.3323679408,
0.3469835350 and 0.4208696971 kg/m² for light cloth, thick cloth, leather and
thick leather. At 22 C / RH 50% / wind 1 m/s, an initially neutral 80 kg,
1.75 m reference dries from saturation to <=0.0001% in 60/120/180/300 world
minutes. These are calibrated capacities, not measured fabric properties.
The bare-animal surface uses the light-cloth moisture-capacity reference without
adding clo; species-specific water storage remains a refinement.

Air convection is `max(3 approximately,8.6*v^0.53)` W/m² K, with a 0.137 m/s
natural-convection velocity floor and 4.7 W/m² K radiation. Relative motion
contributes to convection. Exchange follows the temperature gradient: wind can
warm a colder body. Eight local traces within 1024 map units identify at least
three connected wall planes, blocking exterior wind; two walls do not. Roof
testing is independent and stops rain. Authored ranch roofs are also supported.
This finite geometry sampler is an approximation for irregular/segmented rooms.

### Energy, effort and clocks

Humanoid area is `0.202*m^0.425*height^0.725` m². The 80 kg / 1.75 m reference
area is 1.951493905 m². Reference clothed conductance is approximately
9.409829238 W/K and exposure inertia is 11,291.795086 J/equivalent degree,
calibrated to a 1,200-world-second response. Inertia scales with biological
mass alone, not height or carried load. Equal absorbed 100 J gives E changes
0.01771198 / 0.00885599 / 0.00442799 at 40/80/160 kg. At equal height, changing
area gives response times approximately 13.43/20/29.79 world minutes.
Resting 58.2 W/m² is balanced in the neutral reference; it creates no neutral
drift. The constant-coefficient solver integrates exchange and threshold dose
analytically: `C*dE=(B-G*E)*dt_world + P_real*dt_real + Q`.

Author-approved #136 budgets now distinguish positive mechanical work `W`,
metabolic energy `W/eta` and retained muscular heat `Q=W*(1/eta-1)` (#154). No new Hunger or
Air charge is inferred from that energy ledger. Performing the same action
faster does not change its budget; completing more actions or metres per second
still increases the rate of production. These are calibrated gameplay profiles.

Walking/running use 0.5025/1.005 J of equivalent work per kg of moved mass per
metre, derived from 25% of the former flat ACSM metabolic cost. At the 25% baseline, heat is
1.5075/3.015 J/kg/m; current efficiency changes heat, not this work budget. The same path has the same energy regardless of traversal
speed or integration partition. Positive ascent adds `mass*localGravity*height`
of mechanical work once. Descents retain the approved normalized Minetti braking
curve, bounded at -0.45 grade; negative work never becomes cooling. Ground paths
subtract moving-support translation. Teleports, falls, passive impulses and
platform transport create no walking heat. The existing 32 map units/m and
native movement/collision rules remain; mixed propulsion and knockback remain an
approximation. Journey forecasting converts actual distance to the same work.

Every accepted player jump now charges its delivered kinetic energy under the
#154 contract above. The former 0.5 m / fixed-efficiency calibration is historical
(#136) and remains in HISTORY and the old validation records. New jump heat uses
effective Agility, biological versus moved mass, retained velocity penalties and
current muscular efficiency once at takeoff. Jump-derived proxies do not set the
work of other actions.

Physical weapon work is a fixed, independent table, not a runtime Air or jump
conversion. Values are J per successful action, shared across actors and tiers:

| Weapon | Primary work J | Secondary work J |
| --- | ---: | ---: |
| Dagger | 50 | 75 |
| Hatchet | 75 | 100 |
| Machete | 75 | 125 |
| Javelin | 100 | 150 |
| Sword | 125 | 200 |
| Axe / pickaxe | 150 | 225 |
| Flail | 150 | 250 |
| Spear | 175 | No physical secondary |
| Halberd | 250 | 375 |
| Greatsword | 300 | 450 |
| War axe | 350 | 500 |
| Giant gauntlets | 375 | 375 |
| Longbow | 250 | No physical secondary |
| Crossbow | 150 | 150 where applicable |

These preserve the approved old relative attack-cost proportions once as data;
later Air tuning must not change heat. Charged attacks multiply work by 2 and
sweeps by 3, once each. A primary greatsword attack emits 900 J at 25%
efficiency and 300 J at 50% efficiency (#154). NPC natural bites/horns use 25 J, machete-equivalent
attacks 75 J, and Zupay's ground slam 850 J; heat uses each actor's efficiency.
Firearms use their separate fixed budgets above. Magic remains external energy.

Active player swimming uses 72.75/130.95 W of equivalent mechanical work per m2,
normal/fast, derived from the approved 6/10-MET profiles after subtracting rest
and assigning 25% to work. At 100 kg / 1.80 m and 25% efficiency this emits 477.945/860.302 W heat.
The running command selects work intensity; attributes affect efficiency, not the work profile.
Isometric effort retains metabolic heat despite zero external displacement:
pushing uses the approved 6-MET total profile (637.260 extra W for that body),
and blocking uses `0.2943*totalMovedMassKg*heldWeaponOrShieldKg` W (235.869 W at
133.576 kg with a 6 kg shield). Neither reads Air or jump energy. Resting heat,
shivering, sweat, respiration and environmental/magical transfer remain separate.
Since the author's #136 follow-up, continuous effort produces heat only during
the action: `Q=P*(real action seconds + explicit logical travel effort seconds)`.
Stopping, loading a stationary save or advancing personal time without further
work produces no additional activity heat. Exposure already accumulated remains
and exchanges heat through the existing environment/sweat/shivering model.
The earlier 120-world-second peak/recovery tail is removed; there is no 8-met cap.
Actual actions use the work and isometric profiles above. No Air, sweat or
water-transfer values change in the energy-budget correction.

Thermal revision 7 clears only the old saved activity-power peak. It preserves
exposure, damage history/fractions, hydration, acclimatization, gear/base moisture,
and pending measured work. The migration is idempotent. It cannot reconstruct
and undo erroneous historical heat from an old peak, so a previously overheated
save can remain dangerous while cooling. Keep the original save and matching
package for checkpoint rollback; do not interpret the fix as a health refill.
Revision 8 adds only a reload budget. Measured pending joules, prior exposure,
moisture, resources and acclimatization survive unchanged. Refresh recomputes
the Type-2 adaptation factor; offsets above the new limit return gradually,
using the existing approved rule. Original save/package pairs remain rollback
checkpoints; never overwrite the author's saves during testing.

Fire-primary and ice-secondary projectiles carry the existing Type-1 snapshot,
`100+Intelligence*(Intelligence+1)/2` joules. Only actual intercepted shield and
contacted gear magical defenses determine absorption once; final HP damage,
innate defenses, cold vulnerability and subtractive Toughness do not convert
joules. Explosions use weighted contacted coverage once per recipient. Existing
continuous fire-seal recipients receive power per real second. Projectile
recipient latches prevent repeated callbacks from repeating energy.

Optional `CaelumThermalFireSource` map actors require args[0] profile 1..4
(1/5/20/80 kW), args[1] physical flame radius and args[2] height in map units.
Unspecified sources emit no invented thermal power. Flux is `0.35*P/(4*pi*r²)`
times visible projected body area and author-approved provisional absorptivity
0.95; physical source dimensions bound near-field distance. A 4x4 visibility
sample checks obstruction. This is a point-source approximation, not a fire
fluid model. Existing decorative fires receive no guessed profile.
No existing hot/cold consumable had approved metadata: the tested service hook
applies +/-10 C forcing for ten real seconds, refreshing rather than stacking;
it does not invent new items or instantly change E by ten degrees.

Climate response, moisture and acclimatization follow world time. Real HP,
continuous spell energy and drink expiry follow simulation ticks. Extra personal
time steps advance world response with zero extra real damage or action energy.
Paused simulation advances neither. Limbo retains local 1:1 time and a frozen
civil calendar; ordinary maps retain 20:1. Harmful thermal states interrupt
safe accelerated rest/crafting/sleep. Unloaded hub maps do not simulate NPC
physiology; reopening resets local sampling clocks while preserving E, water,
acclimatization and damage fractions. Offscreen actors on a loaded map remain
fully supported, with staggered one-second updates and actual elapsed time.

Journey previews integrate minute-sized weather/activity steps on an isolated
copy. In #131, each step samples both endpoint regions at the same advancing
civil date/hour and seed, then linearly blends air temperature, humidity, wind
speed, rain, regional means, ground temperature and cloud by distance travelled.
Foot/caravan/cart distance stops during the eight-hour sleeping interval; ships
continue sailing through passenger sleep. Climate still evolves with the clock
while stopped. Apply vehicle shelter after blending, and feed the resulting
climate to both exposure and Resilience-scaled acclimatization. Unknown destination
regions fail explicitly. `CaelumWeatherRules.RegionForLocation` is the shared
catalogue for unloaded destinations and default loaded-map weather; current
shipped destinations are all Buenos Aires (region 1). A new regional destination
must define its region there and keep its map marker consistent. Standalone map
markers still define uncatalogued local climates. The route is an approved
endpoint interpolation, not a claim to model intermediate geography. Foot/caravan uses actual speed/load and the existing 16 hours walking /
8 hours sleeping cycle. Cart/ship passengers rest inside four walls and a roof,
using the existing indoor microclimate, zero exterior wind/rain and no invented
heating. Nearby parked vehicles do not confer this journey shelter. Reject any
forecast reaching harmful cold/heat, explain the cause, and consume no provisions.
Successful travel commits exposure/moisture/acclimatization and logical activity
without inventing real HP damage. Active drinks prevent instantaneous travel.

### Persistence, presentation and evidence

Missing state initializes idempotently without resetting old records. Revision 2
adds only a derived acclimatization multiplier and preserves every revision-1
primary thermal value. Effective attributes reconstruct the multiplier after
load and before forecasts. A 5.1.1 save can return directly to accepted 5.1.0
and later reload in 5.1.1; keep original saves and write distinct slots. This
restores the old gameplay rules while away, so ongoing simulation can naturally
change E, water and adaptation. The separate bridge below is still required
when returning further to 5.0.6, which predates thermal classes.
GZDoom cannot load new class instances in an unmodified old executable package:
`python assets/validation_510/prepare_rollback.py` reproducibly builds
`build/issue130/rollback-506.pk3` from accepted commit `45f1637`. Use it in place
of the gameplay PK3 to return to 5.0.6 behavior while retaining inert thermal
serialization for a later 5.1 reload. Keep original saves and the same map-addon
basenames; save to a new slot. This bridge changes no original save file.
Generated packages, development IWADs, engine and saves are not distributed.

Journal > World > **T** displays air, adapted comfort, signed exposure, first
harmful threshold, wetness, humidity, acclimatization and current penalties in
English/Spanish. The 5.1.1/#131 HUD adds a read-only bar directly above Load:
a grey icon with snowflake upper left and flame lower right, a neutral center, cold/hot bands and
ticks at the actual Toughness-scaled
thresholds, a signed value and localized severity. The #140 follow-up colors
the exposure label with the same cold/hot band palette as its marker position,
including Toughness scaling and overflow; black glyph outlines remain visible.
Its visual span is +/-30*s;
overflow pins the marker and prints < or > with the extreme state, without
clamping stored E. Large numbers use scientific notation. The same 640x360
projection, typography, frame/laurels, aspect handling and visibility policy
as the existing resource bars apply. Shared native coordinate conversion also
corrects the prior frame/fill mismatch at 4:3 and ultrawide (CA-KP-051).
It follows a valid viewed live player,
falling back to the local pawn for non-player cameras; this is not new network
multiplayer support. Draw calls never sample climate/geometry or mutate state.
Air temperature, wetness and comfort remain separate Journal details. This is
not core temperature. #131 gameplay and final revised-icon checks are author-accepted on 2026-10-07.
No #131 author checks remain in pending_test.txt.
Native evidence, exact package/config hashes, migration comparisons, drying fit
and bilingual captures are in [5.1.0 results](../assets/validation_510/RESULTS.json).
The author accepted CA130-01/02/03 on 2026-10-07; HISTORY records the results
separately from native evidence. No author checks remain for this patch.

Physical sources: [EnergyPlus thermal comfort](https://energyplus.readthedocs.io/en/latest/guides/engineering-reference/19.1-occupant-thermal-comfort.html),
[NIOSH heat guidance](https://www.cdc.gov/niosh/docs/2016-106/),
[NIST wet clothing](https://www.nist.gov/publications/thermal-performance-fire-fighters-protective-clothing-1-numerical-study-transient-heat),
[NIST fire radiation SP1169](https://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.1169.pdf),
[ACSM walking](https://pmc.ncbi.nlm.nih.gov/articles/PMC7896743/),
[ACSM running](https://pmc.ncbi.nlm.nih.gov/articles/PMC3743617/),
[Minetti downhill](https://pubmed.ncbi.nlm.nih.gov/12183501/),
[muscle work efficiency](https://pmc.ncbi.nlm.nih.gov/articles/PMC2269891/),
[load carriage](https://pmc.ncbi.nlm.nih.gov/articles/PMC3922835/),
[oxygen conversion](https://pmc.ncbi.nlm.nih.gov/articles/PMC5504009/).
The author's outfit profiles, response times, consequences, racial shifts and
action proxies are game calibration, distinct from those physical sources.

## Staged siege reinforcement test (#132)

The author requests a separate playable MAP06 performance experiment. The
accepted full army remains the default. Set server CVar
`ca_test_siege_reinforcements true` **before a fresh MAP06**; false reproduces the
original deployment. The southern city layout is supported; legacy port layouts
retain their populations. This is not permanent adoption of a new encounter.

`CaelumSiegeReinforcements`, owned and saved by `CaelumPortSiege`, holds revision 1,
successful spawns, living registered Mandingas, unspawned remaining budget, the
pending group's placed-slot bitmap, formation cursor and next opportunity tic.
`CaelumReinforcementData` supplies 100/group, 2,000 living, 6,000 total and 350 tics.
The commander, 600 defenders, 12 hostile machines and all 42 guns retain their
authored populations; none consumes the Mandinga cap. The 74 attacking operators
are part of the first 100, not an extra initial population.

The first opportunity is immediate at deployment. Each later opportunity is
350 simulation tics after the previous one, independent of accelerated calendar
time. Pauses do not advance `level.time`. At most one group starts per opportunity;
99 vacancies do not suffice, 100 do. Missed opportunities are not banked. A partial
group retains its missing members and retries at a later opportunity before any
new group starts. Only registered, successfully placed native bodies consume the
budget. Deaths do not undo cumulative spawns; corpses keep their existing lifecycle.

Initial crews try their authored stations, falling back to the existing infantry
formation if occupied; they walk to their assigned machines normally. Infantry
uses the authored 200-column southern formation positions with a saved rolling
cursor. Native `TestMobjLocation` checks walls, solid actors and vertical fit;
an additional body-overlap check avoids non-solid combatant corpses. A failed
candidate is discarded before registration, leaves its slot pending and consumes
no budget or native total-monster statistic (`ClearCounters` before rejection).
At most one formation position per missing member is tried per
opportunity (plus the original station for an initial crew member). Successful
members of partial groups immediately participate in normal combat. No living
registered attacker is deleted or teleported to free a reinforcement slot.

The current population is refreshed from owned bodies each simulation tic in
staged mode. The separate #128 map-wide 500-living-combatant census remains
unchanged, including offscreen combatants and defenders. Existing dynamic
command membership/leader targets, collision, resources, statuses, individual
attack validation, crew replacement and machine neutralization remain in force.
A group becoming eligible does not force it into one permanent command group.

Victory still requires commander defeat/confirmed retreat and all twelve hostile
machines neutralized. Empty current Mandinga ranks alone never win, even with
reserves pending. A legitimate victory stops reinforcements before that tic's
opportunity; the unspawned budget remains recorded as stopped, not consumed.
Thus a natural battle can finish before all 6,000 enter. A separate complete-budget
diagnostic gives the commander ordinary damage invulnerability and applies
explicit native-damage casualties (thermal health loss still follows its service);
it is never used as evidence of an unmodified natural battle or distributed as AI.

Existing full-army saves initialize a disabled revision-1 controller once,
retaining the complete saved roster, identities, crews, deaths and victory state.
Changing the CVar cannot convert an already deployed encounter. Saved staged
encounters resume the same bitmap, counters and deadline without redeployment,
including hub returns. Rollback means loading the untouched original full-army
save with its original package; preserve both. A staged save requires this schema
and is not promised to open in the old package.

## Automatic high-density AI (#128)

Author decision, 2026-10-07: activate the applicable normal AI optimizations
at **500 living combatants in the entire map**, including those offscreen.
`CaelumPopulationState` counts living, shootable `CaelumCombatActor` NPCs and
active players' living, shootable pawns. Projectiles, props, helpers, corpses
and inactive/non-player pawn copies do not contribute. The existing map event
handler refreshes this derived snapshot before thinkers each simulation tic;
spawn, death, removal, revival and shootability changes appear by the next tic.
Exactly 500 enables it; 499 disables it. Camera movement does not affect it.

The mode is automatic, with no player setting or diagnostic CVar. Existing
siege command groups still contain at most 100 members, use the authored
connectivity/rank rules and retain the full army. In high-density mode each
member **adopts the leader's target**, even if another target is closer to the
member. This explicitly supersedes #77's individual-nearest rule only while
the threshold is met. Leaders select the nearest visible living player or
port defender; absent a visible opponent they retain their lane approach goal.
Actual attack preparation/release still checks each member's own range, line
of sight and resource costs. Sharing an order does not authorize attacks
through a wall or disable recovery, individual movement, collision or status.

Perception reuses a group decision for the existing eight-tic period. The
first active member queries immediately; after expiry, the next requesting
member refreshes it once for the group. Groups with no requests do no background
perception work. Visibility/position changes can remain cached until that
refresh; individual attacks still validate their own current conditions.
Dead or destroyed targets are never returned by the selector and are reacquired
on the next expired query. The tested background staggering alternative is
not shipped because it worsened congestion frame-time tails.
An inactive leader falls back to the live member until ordinary regrouping.
The roster of living target candidates is reused among leaders in the same
tic; positions, health, shootability and visibility remain live query inputs.

Armed hostile machines use a native blockmap broad phase followed by the same
exact 3D guard predicate. A once-per-tic list covers guards flagged NOBLOCKMAP.
New NOBLOCKMAP guards registered after that census enter the fallback list
immediately, before a machine can observe or neutralize. Other flag changes
are reflected by the next census; current production combatants do not toggle
NOBLOCKMAP during a tic. Previously remembered guards, confirmed deaths, retreat and one-time
neutralization remain authoritative. A loaded cannon with no eligible target
retries after the existing eight-tic perception interval. Its target search
skips sight only when a normal visible candidate cannot beat the already
selected crew-priority/nearest target. Ties retain roster order. Invisible,
zero-alpha and special-render-style candidates retain native sight calls,
including their random-stream effects. Successful shots, crew priority,
ammunition, ballistics and reload timing are unchanged.

Below the threshold, per-member targeting and full guard scans resume and
negative cannon searches have no added retry delay. Mode transitions clear
only derived perception/deadline caches. Targeting revision 2 initializes the
new caches idempotently; population revision 1 is rebuilt from native actors
on load/travel and each tic. Rosters, identities, casualties, crews, resources
and saved inventory/Tarot state are not reconstructed. The population gate is
map-wide; group targeting applies to existing port command groups and spatial
guard queries to siege machines. This does not invent command groups for
unrelated civilian/faction AI or activate CADEV02's reduced actor simulation.

## Siege profiling and group experiment boundary (#121)

Historical boundary of 5.0.5; #128's production policy above supersedes it.

The accepted siege retains 6,000 Mandingas, its commander and 600 defenders.
Production command groups already contain at most 100 members. Membership and
leadership do not replace each member's nearest-visible-target search, native
movement, individual combat, resources, collision or damage.

`assets/validation_505` builds isolated diagnostic copies. Its formation test
places all 6,000 Mandingas into sixty 10-by-10 blocks on the existing 200-column
formation footprint, recalculates their lanes, synchronizes their initial run
animation and issues movement through native `TryMove` every four tics. Mode 1
chooses a target/direction independently for every soldier; mode 100 chooses
once per group and applies that direction to its surviving members. Native
collision can block individual members and break the formation; the probe
records successful moves and deviation from initial relative positions.

This is a march experiment. It relocates machine crews and replaces Mandinga
attack/chase actions. The commander, defenders, machines, body Ticks, health,
resources and native collisions continue. A separate shared-target diagnostic
keeps the original placement and native combat/movement but gives followers
their command leader's cached perception for the current tic. That changes
individual visibility and nearest-target semantics. Both interventions change
the workload; their timing differences cannot be added together or adopted as
accepted combat rules. Production populations, geometry, hierarchy, victory,
balance and save fields retain their existing contract.

The combined diagnostics also test a native spatial broad phase for machine
guards, retaining the existing exact 3D radius, remembered guards and death
predicate. A separate full-scan oracle checks omitted eligible guards. Another
test caches failed cannon target searches for the existing eight-tic target
update period; this can delay acquisition by seven tics and is a deliberate
behavior change. These factors are measured alone and together, including
shared perception plus spatial guards and the three-factor combination.
No diagnostic field, cache, formation controller or altered targeting rule is
included by production ZSCRIPT. The author's comparison target is stable native
35 tics/s with at least 30 displayed frames/s at the current resolution/population.
On 2026-10-07 the author accepts the demonstrated fluency as sufficiently close
for this diagnostic stage and defers further tests. The numeric reference and
production contract remain unchanged; acceptance does not install the prototypes.

## Per-player authority and modular migration boundary (#120)

`player/CaelumPlayerAuthority` defines the common receiver contract without
owning state. Reads require an explicit pawn whose native `player.mo` still
points to that pawn. Commands additionally reject `CF_PREDICTING`. Native play
execution and event transport remain GZDoom's responsibility; this helper is
not a new server or a complete multiplayer authorization layer.

| Boundary | Authoritative state and supported operation |
| --- | --- |
| Player/profile/resources | Existing pawn fields and profile/allocation objects. Character/resource/presentation operations take that pawn explicitly; null, detached and stale receivers cannot mutate them. Read-only inventory lookup remains available during prediction. |
| Inventory/equipment | Native `Inv` chain and item `Owner`. Numeric IDs are scoped to the owner; two players may have the same ID. Mutation rejects foreign owned items. A legitimate native drop releases ownership; pickup by another player applies that player's existing collision/reassignment rules without transferring unrelated wear or selection. |
| Tarot/persistence | The requesting pawn's canonical `CaelumPersistentCharacterState`, found in its inventory, owns cards, selected/paid-active sets and clocks. Record writes require that identity and owner. A foreign record cannot initialize revisions or overwrite the requester's Journal projection. Essence commit also requires its recorded capture user to own the destination record. Pure record queries add no owner or mutation. |
| Crafting projections | A non-null preview must be the exact `user.CraftingBrowser` object. It is a pawn-held projection, not a second inventory. Repair/dismantle targets retain owned-item preconditions. Legacy capacity/recipe queries that refresh state route through mutation guards. |
| UI and requests | Journal page, cursor, scroll and menu selection remain local UI state. Commands cross `SendNetworkEvent`; Journal, Trucazo and Truco handlers resolve the event's player through `FromNetworkPlayer`, checking bounds, participation and current pawn before indexing/mutation. They never fall back to `consoleplayer` or player zero. Menus retain their own match serial/action validation. |
| Shared world | MAP06 siege roster, actors, command groups, gates and physics contacts remain map-local shared state. Per-player records contain personal discovery/reward progress. This patch does not clone world controllers per player or assign one player's inventory authority over another. |
| Campaign time/session | Existing clock/calendar/weather/journey inventories still belong to a pawn; the clock ticker runs only with one participant. There is no supported shared campaign-time, joint rest/travel, reward distribution or networked card-match lifecycle. Join/leave/reconnect/respawn and ownership transfer policies require their own design and native multi-client tests. |

The source manifest records 203 entry guards and their read/command distinction.
All retained statements, serialized fields, signatures, input bindings, selectors,
maps and assets remain. `CaelumTarotPowers.REVISION` aliases the service's revision
instead of duplicating the value. No new schema, migration counter or service
instance is introduced. Existing adapters and migration gates are retained;
completion of #116–#120 is not authorization to delete them.

Validation uses original 5.0.3/current saves for each domain and a preserved
5.0.0 Architecture 1 save. Original-save upgrades, separate re-saves, repeat
loads and original-package/original-save rollback are recorded in
`assets/validation_504/RESULTS.json`. Two native player pawns (human plus bot)
exercise owner isolation in one process. This does not establish two-client
transport, full co-op/PvP or networked Trucazo. Ordinary author acceptance stays
in `pending_test.txt`; unsupported network lifecycle is a development task.

## Tarot service and retained save contract (#119)

`core/CaelumTarotService` is the stateless domain implementation. The travelling
`CaelumPersistentCharacterState` remains the sole saved owner of collection,
selected/activated arrays, revisions and remaining tics. No fields, IDs, array
sizes or native class names move. Existing record, power, essence and rule
methods remain compatible adapters; they do not maintain a second collection.

| Boundary | Contract |
| --- | --- |
| Collection and bonuses | One implementation counts owned cards and derives integer-tenths Minor contributions and collection percentage. Card suit/rank belongs to Tarot; Trucazo retains its separate ranking/scoring rules. Character rebuilds consume these queries without accumulating bonuses. |
| Selection and activation | Player input and Journal requests enter the service with the requesting pawn. Owned/implemented cards, the three-card limit, activity, Anima and cooldown checks precede payment. Selected cards describe the next activation; active cards are the paid snapshot. |
| Time and native effect | Existing personal-time/journey calls advance the saved clock once. HUD, Journal and flight read it without advancing it. Expiry clears only active contributions. A missing native flight instance is restored after travel or the next personal tic only while the saved Fool effect remains active; restoration neither pays nor resets either timer. |
| Capture commit | The service rechecks live context, map/progress, range/sight, animation completion, same Box identity, physical deck in that Box, revelation and absence of the essence. Only then does it write collection/quest progress and refresh/persist projections. Low-level record adapters retain their coordinator preconditions; callers must use the commit entry point for an acquisition transaction. |
| Physical inventory | The existing deck/Box rules and `CaelumInventoryService` retain native ownership and storage authority. A physical deck grants no essence. Activation requires captured essences, not a deck stored in the Box. |
| Presentation and matches | Tarot descriptions, selectors and timers consume domain queries. Existing pawn snapshots remain UI projections. Trucazo copies captured-Minor ownership into its own match-start awakening snapshot; ordinary Truco has separate match state and no new powers. Both match entry points check the physical deck through the inventory contract. |

Native 5.0.2 evidence exposed a retained timer with missing flight after crossing
from MAP01 into the hub: native `PowerFlight` is a hub power. The idempotent
restoration above fixes that existing contract violation without a save-schema
migration. Old saves missing the instance recover from the already-paid record.
Revision 1 initialization and physical-deck recovery retain their existing rules.

Rollback uses the original **5.0.2 package and original save together**, baseline
`135ae0f9`, with matching map geometry. Keep upgraded saves separate. Reproducible
before/after, old/new reload, hub return, original-pair rollback and bilingual
menu evidence is recorded in `assets/validation_503/RESULTS.json`. These isolated
engine fixtures do not replace author acceptance or establish multiplayer support.

## Inventory and equipment service (#118)

`equipment/CaelumInventoryService` is a stateless `Object play` service taking
the requesting `CaelumPlayer`. The pawn's 157 compatible adapters and the Box/deck
entry points delegate to it. All 604 pawn field declarations and 544 signatures
remain; native serialization, lifecycle ordering and class identities are intact.
The service adds no fields, singleton, global player lookup or second inventory.

| Boundary | Authority and operation contract |
| --- | --- |
| Identity and queries | `Actor.Inv` and each item's native `Owner` own instances. `FindNativeEquipmentItemById` searches that pawn only; `EnsureEquipmentItemId` observes/allocates the existing record counter and resolves collisions. Detached incoming items may obtain identity; foreign owned items cannot. Type/tier/size remain catalogue attributes, never substitutes for an instance ID. |
| Equipment and wear | Equip/unequip, exact activation and active-reference repair operate on owned instances. `SyncActiveModelsToNativeInventory` writes working-model wear to the exact IDs. Native weapon selectors, attacks and engine inventory copy/toss callbacks retain their roles. Foreign activation is rejected before changing selectors, models or the pawn. |
| Box and physical deck | Entitlement and migration revisions remain in `CaelumPersistentCharacterState`. `CaelumMagicBox.EnsureOwned` and deck `Owned`/`Grant` forward to the service. `InMagicBox` is location on a native item; weight reduction and slot counts are projections. The deck remains one protected physical item; stored essences and power/capture rules are not moved. |
| Capacity and acquisition | Shared weight-transition, Box-slot and prepared-output checks include existing reservations. Native pickup callbacks still perform the engine transfer/copy after service preflight, then notify the service. New pickups must be detached or owned by the requester; stack growth requires that requester's existing stack. A rejected capacity preflight allocates no equipment ID. |
| UI and previews | Formal rows and selection fields remain compatible cached projections. Play events resolve the selected ID/native entry and call the same service operations. Drawing consumes these projections; it has no independent mutable item collection. Foreign selection entries are ignored. Projection refresh retains its existing identity-reconciliation calls; it is not a pure serialization-free function. |
| Crafting, repair and dismantle | Reservation/count/consume helpers, prepared-output checks and existing output/repair/dismantle commits share the service. Recipe planning, station/session checks, recipe knowledge and time coordination remain with their existing owners and call pawn adapters. Complete reservations are checked before repair consumption. Task completion clears the active task, so repeating completion cannot grant another output. Exact target IDs and per-instance condition survive travel. |
| Commerce and rewards | Currency plans, weight/slot checks and product add/remove commit operations share the service. Merchant sessions/prices/stock and the prisoner's claimed flag remain their existing coordinators' responsibility. They validate before invoking internal commit helpers and mark reward completion only after payment succeeds. Calling a low-level commit without its coordinator's preconditions is not a new public transaction API. |
| Authored loans and native I/O | Quest-specific temporary grants/removal and engine `AttachToOwner`/copy/toss remain specialized existing lifecycle operations, not replacement ownership stores. Their existing inventory refresh/identity/capacity adapters now reach the service. This patch does not rewrite tutorial loan rules, native actor callbacks or recipe/catalogue data. |

Ownership guards precede mutation in ID allocation, exact activation, pickup and
stack preflight, selection and recovered-material merge. The full method/guard
manifest and token-equivalence proof are in `assets/validation_502/EXTRACTION.json`.
Apart from those explicit guards, moved statements, literals and call order are
unchanged. Existing native-equipment/weapon/Box/deck migration gates stay intact;
there is no new migration revision or parallel owner.

Rollback uses the preserved **original 5.0.1 package and original save together**
(source baseline `da7d33b8`), with matching historical map layout. Upgraded saves
are separate files. Native checks load an original save under 5.0.2, reload fresh
and upgraded saves, traverse MAP03/MAP02/MAP06 and return, and replay the original
pair. A newer save's downgrade or conversion of obsolete map layouts is not claimed.
Recorded evidence and limitations are in `assets/validation_502/RESULTS.json`;
ordinary author acceptance remains separate from these isolated fixtures.

## Player character and resource adapters (#117)

The pawn remains the serialized/native identity. `CaelumPlayerCharacter` and
`CaelumPlayerResources` are stateless `Object play` classes with static operations
taking the requesting pawn. They require the same live pawn/preconditions as the
original methods; they neither find `consoleplayer` nor allocate service instances.
The original signatures, defaults and return values remain callable on the pawn.

| Service / operations | State read or written / contract |
| --- | --- |
| Character: `ReadNewCharacter*`, `NewCharacterDraftIsReady`, `ClearNewCharacterDraftReady`, `ValidateLoadedNewCharacterDraft`, `ConsumeNewCharacterDraft`, `InitializeDirectMapCharacter` | Native per-player CVar draft and the pawn's existing profile/allocation objects. Invalid draft is cleared; valid draft is consumed once. Startup alone chooses restore versus creation; service loading never creates a character. Starting equipment uses the existing pawn adapter. |
| Character: `EnsureCurrentAttributeBalance`, `ApplyCharacterProfile` | Existing profile, attributes and derived models; same jewelry/Tarot/inventory calls and balance revision 3. Recalculation clamps reduced capacities without free health/Anima/Air. Native size/mass updates remain at the same point. No new migration revision. |
| Resources: adrenaline gain/decay/combat activity; consumable pulse; localized lucidity loss, accuracy, stun and pain timers | Live pawn fields. Shared constants and existing rest/dining/record operations remain authoritative. Existing events restart the combat timer, and the lucidity stun starts only on crossing its threshold. |
| Resources: survival state/consumption, health penalties, critical damage and natural regeneration | Existing hunger/thirst/sleep and fractional damage/healing accumulators. Rest/sleep, potable water, Constitution costs and native death path retain their ordering. Native health and `player.health` remain synchronized. |
| Resources: air regeneration, underwater cost/debt/recovery, jump cost and air performance | Existing Air and debt/timer fields; the same water-level/exemption checks and lesson callbacks. The pawn's native `CheckAirSupply` override still suppresses the parallel engine breath counter. |

`PostBeginPlay`, `PlayerThink`, `Tick`, `PreTravelled`, `Travelled`, `DamageMobj`,
`CheckAirSupply` and `AdvancePersonalTimeTic` retained their bodies in #117. #119
routes Tarot calls to its service and restores the native effect after travel. In
particular, personal time still orders Tarot/elemental state, resource operations,
combat timers and rest/time pumps once; the extracted methods add no extra tick.
Inventory, Tarot, attack dispatch, input latches and native selectors remain behind
their existing adapters for #118/#119 and later focused work. UI still reads the
existing projections and does not call resource operations while drawing.

All pawn fields, class names, method signatures and array identities are retained.
Native serialization and the explicit live-to-record/record-to-live copies below
continue to own persistence. The #116 old-save waiver is not used as #117 evidence:
the #117 harness creates a save with the accepted 5.0.0 package and loads it with
5.0.1, alongside fresh/reloaded saves and hub travel. Scope and actual outcomes
are recorded in `assets/validation_501/RESULTS.json`; this does not promise every
historical map layout is compatible.

Rollback: preserve the original 5.0.0 package and original save copies together;
restore both (or rebuild commit `6e8f0d66` with the matching map layout). Keep
5.0.1 saves separate. The native original-package/original-save replay is recorded
in the evidence; downgrading a 5.0.1 save is not a supported migration claim.

## V5.0 state ownership and compatibility contract (#116)

The architecture audit starts from #82 / 4.37.24 (`20143c31`). The author expanded
#116 on 2026-10-06 to begin refactoring without requiring compatibility with older
saves. This patch introduces no schema migration: `CaelumPlayerPresentation` is
stateless and the existing pawn fields/classes/method signatures are retained.
Earlier-save compatibility is not an acceptance claim. Fresh saves made by the
current implementation must still save/load correctly; the waiver does not
authorize lost items, duplicated rewards or divergent owners during ordinary play.

### Single-owner state table

Paths use `src/caelum/` unless stated otherwise. All symbols and declared field
identities are indexed by `assets/validation_500/SOURCE_AUDIT.json`. The table
distinguishes live authority from travel copies and presentation, including objects
that the engine serializes even when they are semantically caches.

| State / concrete class and fields | Authoritative owner and lifetime | Readers, copies and mutation boundary |
| --- | --- | --- |
| Player identity: `player/CaelumPlayer.CharacterProfile`, `CharacterAllocation`; `CaelumCharacterProfile.Race/FirstClass/SecondClass/Sex/HeightChoice` | Confirmed pawn's live objects | `CaelumCharacterCreationMenu` is a draft. `ConsumeNewCharacterDraft` consumes new-character CVars; `PersistCharacterState` copies into record `Race`, classes, `LayerBonus`, `AttributeBonus`; restoration is explicit. Never reapply global preferences to a loaded character. |
| `Attributes`, `DerivedStats`, `ArmorModel`, `ShieldModel`, `WeaponModel` | Pawn-owned calculated/equipped working models | Catalogue/rule data computes values. Equipped durability is synchronized with exact native items by `SyncActiveModelsToNativeInventory`; models are not additional item ownership. |
| Physical equipment: `equipment/CaelumEquipmentItem.ItemId`, `EquipmentKind`, `ItemType`, `Tier`, `EquipmentSize`, `Durability`, `Equipped`, `InMagicBox` | Exact native item attached through `Actor.Inv` | `EnsureEquipmentItemId` allocates from record `NextEquipmentItemId`; IDs and `EquippedArmorItemId[]`, `EquippedShieldItemId`, `ActiveWeaponItemId`, amulet/seal IDs identify instances, not catalogue rows. |
| Materials, ammo, currency, consumables, deck: `CaelumSpecialInventoryItem`, `CaelumCurrencyItem`, `CaelumTarotDeck`, `Amount`, `InMagicBox` | Native inventory stacks/items owned by the specific pawn | Weight, counts and HUD money are projections. Box content stays in native inventory with routing flags; it is not a second container database. |
| Box ownership and legacy equipment: `CaelumPersistentCharacterState.MagicBoxOwned`, `MagicBoxItemId`, `NativeEquipmentMigrationComplete`, `SizedOwnedWeaponDurability[]` | Character record owns entitlement, stable ID counter and legacy migration ledger | Pawn `MagicBoxOwned` is a live synchronized value. Historical arrays must not recreate discarded items after native migration completes. Preserve copy direction when moving methods. |
| Resources: `CaelumPlayer.health`, `CurrentAnima`, `CurrentAir`, `CurrentAdrenaline`, `CurrentLucidity`, `CurrentHunger/Thirst/Sleep`, underwater debt fields | Live pawn / native health | Record `StoredHealth`, `StoredAnima`, `StoredAir`, remaining stored resources and debt are travel snapshots. `AdvancePersonalTimeTic` advances the live resources; HUD refresh must not consume time. |
| Crafting: pawn `CraftingTaskActive`, task kind/recipe/tier/size, `CraftingTaskTargetItemId`, reservations/output arrays and remaining seconds | Pawn owns active live task; `CaelumPersistentCharacterState` carries explicit travel snapshot | `StoreCraftingTaskState`/`LoadCraftingTaskState` define the handoff. `transient CraftingBrowser` is reconstructed. Selection/preview does not reserve materials twice. |
| Merchant: record `PalomoMerchantStock[]`, `PalomoMerchantWalletCopper`, `PalomoDiscountGranted` | Persistent character merchant relationship | Pawn session/visible-list/currency-plan fields are mirrors or temporary transaction plans. Relocating Palomo must not reset stock/wallet or negotiations. |
| Quests/factions/prisoners: record `QuestState[]`, `QuestStage[]`, `QuestObjective*[]`, `QuestRewardClaimed[]`, `MainM00Flag[]`, `FactionMember[]`, `FactionReputation[]`, `PrisonerRescueState[]`, `PrisonerRewardClaimed[]` | `CaelumPersistentCharacterState` attached to the requesting character | Controllers and dialogue transitions mutate the record; `CaelumQuestCatalogue` derives status, NPCs/tokens and `Journal*` display it. Rescue/extraction/payment remain distinct and idempotent. |
| Tarot: record `TarotOwned[]`, `TarotSelected[]`, `TarotActive[]`, `TarotEffectTics`, `TarotCooldownTics`, `TarotPowerRevision`, `TarotDeckRevision` | One canonical character record; `CaelumTarotService` implements powers behind retained adapters; physical deck ownership uses `CaelumInventoryService` | `Tarot*Snapshot` and Journal cursor do not own cards or selected powers. Array IDs remain 0–77; Fool 0, Ace 36, Knight 60. Capture, select and activate remain separate operations. |
| World discovery: record `WorldLocationVisited[]`, `WorldConnectionKnown[]`, `WorldConnectionTraversed[]`, `WorldPendingConnection` | Character record | `CaelumWorldProgress` and world catalogue use stable IDs. The Journal world page is a view, not shared campaign authority. |
| Clock/calendar/weather/schedule: `world/CaelumWorldClock.CompletedDays/DayTics`, Limbo counters; `CaelumCalendarState`, `CaelumWeatherState`, `CaelumScheduleState` | Separate inventory states on the character | `CaelumWorldClockTicker` runs only with one participant; accelerated time, travel and schedule synchronization call the same existing operations. Shared time across players is unimplemented. |
| Journey/rest/time skip: `CaelumJourneyState.Sequence/Status/ConnectionId`, `CaelumJourneyPlan`, `CaelumRestState`, `CaelumTimeAdvanceState`, `CaelumTimeSkipState` | Pawn-owned inventory state with map/session references | Begin/confirm/cancel/arrive operations own transitions; UI and temporary camera/freeze state are reconstructed or validated at their existing hooks. |
| Trucazo/Truco: `trucazo/CaelumTrucazoMatch`, `CaelumTrucoMatch`, deck/hands/phase/score and opponent reference | Match inventory attached to the player | Menus dispatch actions; `CaelumTrucoRules`/`CaelumTrucazoRules` define rules. Do not confuse match decks with owned campaign essences. |
| MAP06: `CaelumPortSiege.SetupRevision`, `Attackers`, `Defenders`, `Guns`, `Gates`, `Groups`, `CommandDirty`; `CaelumSiegeCombatant.Body/StableIdentity/CommandLeader/CombatTarget`; gate/ram/cannon instance fields | Map-local controller and actual actor instances | Hub revisit/save retains roster, deployment and casualties. `TargetingRevision` rebuilds derived perception; `SetupRevision` prevents redeployment. Character narrative/rewards remain in character state. |
| Physics contacts: `src/impactphysics/ImpactPhysics.zs: ImpactContactState.FirstActor/SecondActor/LastResolutionTick`; pawn/actor `ImpactContacts` | One shared contact object referenced by both bodies | Impact adapters apply game-specific damage; generic math must not gain dependencies on player, quest or UI classes. Never duplicate a contact's per-tic resolution. |
| Presentation: pawn `HUD*`, `Journal*`, `Tarot*Snapshot`, lesson snapshots; Journal user CVars | Derived play-scope snapshots plus local UI navigation | New `CaelumPlayerPresentation` fills the existing fields. It retains legacy ensure/init calls in the social refresh; no timer advancement, card grant or independent saved service instance is added. |

### Lifecycle and input/selector boundary

`PostBeginPlay` allocates missing pawn models, attempts record restoration, and only
then consumes the new-character draft or initializes the direct-map test profile.
It is not a substitute for save-load handling. `PreTravelled` closes sessions,
persists the live state, then calls the native hook; `Travelled` calls its native
hook and restores the record. Normal save/load is native object serialization;
`WorldLoaded(IsSaveGame/IsReopen)` handlers and per-tic revision guards have their
own roles. Do not rerun new-character initialization on load or deploy a new siege
on hub return. `PlayerThink` handles input/latches before normal movement;
`Tick` retains initialization/migration, native tick, contacts, sessions,
presentation, resources and time-pump ordering. Moving a method must not reorder it.

Input is part of the public contract:

- `KEYCONF` bindings and aliases, existing `ca_*` event names/arguments and
  `CVARINFO` user selectors retain their meaning and player ownership. Defaults
  stay Tab Journal, M automap, B User2/Seal, R Reload, F Zoom, T User3/Tarot;
  remapped controls remain valid. Fire/AltFire, Use and User1/User4 retain behavior.
- `CaelumJournalOverlay`/`CaelumJournalInput` own local navigation and send
  `SendNetworkEvent` requests. `CaelumDebugOverlay.NetworkProcess(ConsoleEvent)`
  resolves the event's current pawn through `CaelumPlayerAuthority.FromNetworkPlayer`;
  domain operations must receive that pawn,
  never substitute `consoleplayer` in authoritative play logic. This routing
  pattern alone does not establish complete multiplayer safety.
- Native `CaelumEquippedWeapon`, family/physical/magic selector classes in
  `CaelumPlayableWeapons.zs` use `invoker.Owner`, then the pawn adapters
  (`ActivateEquippedWeaponFamily`, `PerformFamilyPrimaryAttack`, etc.). Preserve
  their class names, slot numbers, Ready/Select/Fire/AltFire/reload/zoom states,
  action signatures, pending/ready-weapon transitions and exact item references.
- `FormalInventorySelectionIndex` selects a presentation row;
  `FormalInventoryRowItemId[]` and equipment/crafting target IDs identify exact
  instances. Journal cursors and filters select presentation rows. Preserve
  ordering, stable catalogue/faction/quest IDs, page count, English/Spanish keys,
  press/hold/release latches and session-close behavior. The HUD cannot mutate
  authoritative gameplay while rendering.

### Migration, reversibility and rollback

This slice keeps existing class/field identities, array sizes, revision fields and
public signatures; no new migration revision is appropriate for a stateless
method move. Future schema-changing slices must state what is retained, rebuilt
or transformed and whether the author's save waiver applies to that specific work.
Outside that waiver, migrations require a version, idempotent repeat-load tests,
explicit reverse/backup strategy and affected current/legacy map variants.

Keep the original package and save copies. For a future field move, prefer an old
serialized field plus a forwarding adapter until migration is validated; do not
copy ownership into two active registries. For rollback of #116, rebuild commit
`20143c31` or revert the focused runtime extraction and use the matching original
package/save copies. Do not downgrade by overwriting the only current save, and do
not mix regenerated maps with saves that already visited another layout. No
automatic conversion of legacy MAP02/MAP06 geometry is introduced. The current
author waiver removes old-save compatibility as this issue's gate, not the need
to state the rollback boundary honestly.

## 4.37.24 — Export defaults and final integration contract (#82)

The portable export initializes its own user/gzdoom.ini once. Before that file
exists, the launcher executes default_controls.cfg after loading the package:
Tab -> ca_journal_toggle; M -> togglemap; B -> +user2 (equipped Seal); R -> +reload;
F -> +zoom; T -> +user3 (selected captured Tarot essences). T was explicitly
chosen by the author. Later launches preserve the user's INI and customized
bindings. KEYCONF also advertises the same defaults for unassigned keys when
the package is used directly. Native defaultbind does not guarantee overriding
an existing binding; the portable first-start configuration supplies that role.

These are remappable inputs, not new abilities. Reload retains its ranged reload
or melee/magic charge behavior; Zoom retains block, eligible sweep or ranged ADS.
Rest/crafting and Journal contextual input retain their existing dispatch and
ability restrictions. No allocation, balance, cost/cooldown, save schema or
campaign geometry changes are made by the closing delivery.

The scope remains MAP01 -> MAP02 -> MAP06; MAP03 is diagnostic. All 78 physical
cards are distinct from captured essences. The current campaign grants El Loco,
Ace of Cups and Knight of Wands, with the accepted Box-gated capture and shared
activation contract. Physical deck ownership permits NPC Trucazo and grants no
unearned passive bonus, collection percentage or power. Prisoner intelligence
follows successful payment; siege victory requires both original objectives.

The empty Tarot Journal now describes the accepted early upstairs deck handoff
and the later Box requirement in both languages; it no longer claims those
separate handoffs happen together. This corrects help text, not reward timing.

## 4.37.23 - Creation descriptions and authoritative preview (#112)

Creation now explains the highlighted choice before confirmation. Spanish
headings are "¿Qué quieres ser?" and "Tus opciones son"; second-class options
and the final summary show the profession returned by the profile mapping.
Repeated classes retain specialization, and pair order remains irrelevant.

Descriptions follow the implemented attribute audit, current derived-stat
consumers and the abilities catalog. Sleep is the implemented Arcanist ability;
the other profession and racial abilities are explicitly marked planned.
Empathy does not promise a working general healing system, and Insight does
not promise implemented hidden-object detection. No new restrictions or
penalties are invented as weaknesses; smaller contributions are relative.

The issue text mentioned Engineering and Wisdom, but the game's technical
family is Agility, Dexterity and Resilience. These real attributes and the
existing Physical/Technical/Social/Mental order are preserved. There are no
attribute renames or added mechanics.

A pre-existing creator-only copy of distribution pattern 2 used Social 3 /
Mental 5; the actual profile and canonical rules use Social 5 / Mental 3.
The author explicitly authorized the fix on 2026-10-05 after the discrepancy
was reported. Both paths now use CaelumCharacterProfile.DistributionFor.
For a Human/Priest/Priest profile the preview correctly shows Social 15 and
Mental 9, and refuses a family point at the existing cap of 15. This corrects
the preview and its existing cap check; it does not rebalance the actual
profile. Four family points, thirty individual points, refunds, individual
caps and mandatory completion keep their rules. Existing saves are unchanged.

## 4.37.22 - Shield presentation follows the equipped item (#106)

The shared first-person renderer resolves BUCKLER/KITE/TOWER/MAGIC from the
actual native equipped shield. All three tiers and five equipment sizes use the
same art family per type. Existing shield usability, durability and weapon
compatibility determine visibility; giant gauntlets do not display an external
shield. Their dedicated T1-T3 boxer guard follows the existing native block
source, with no new protection or attack rule. The native block toggle still owns entry, continuation and cancellation.
Holding block keeps the frontal pose and left grip fixed until that state ends;
the right-hand/weapon presentation resumes on release. Unarmed compatible
equipment uses the same shield controller, replacing the free left fist.

This patch changes presentation only. Coverage, defense, weight, durability,
Air, damage, attack cadence, recipes and inventory/progression schemas retain
their definitions. New presentation caches are transient and rebuilt from
existing equipped-item state after loading. Existing weapon state indices and
the original shield/hand PNGs are preserved. ASSETS holds registration and
provenance; validation_43722 records static and native evidence separately from
author acceptance.

## 4.37.21 - New-character introduction and exit (#103)

Author decisions, 2026-10-04: show the welcome only after a valid character
creation; one page writes its text gradually, using the native GZDoom text-screen
defaults (10 initial tics, 2 tics per Unicode character). One key or left click
reveals the whole page without starting play; a subsequent press begins MAP01.
Keyboard repeat is ignored. Controller A/B follow the same two-stage action;
repeating controller direction axes do not skip the reading. There is no timed
advance and no replay on save load, hub return or direct development map load.
CA_MUS01 plays during the page; MAPINFO restores CA_MUS02 on MAP01 entry.
A save loaded by console while the page is open discards its pending menu chain
and unconsumed creation draft; other menus are unaffected. This interface-only
cleanup is not a saved-state migration.

The text reads up to two current bindings for each basic action, explicitly
showing unbound actions. Movement, looking, jump, run/walk, Use, weapon actions,
Journal/inventory and time skip are explained alongside hunger, thirst, sleep,
Air and journey provisions. These are descriptions of existing rules, not new
costs or controls. Strings are bilingual; exact author-supplied Spanish opening
and ending remain in LANGUAGE. No text is imported from the narrative slides.

Main-menu Quit and F10 use the native confirmation with a project prompt.
No/Escape cancels normally. Yes opens the approved farewell image; the next
key/left click invokes the retained native callback, QuitSound and shutdown.
ENDOOM is disabled per game because that legacy surface accepts text, not PNG.
Direct console quit, m_quickexit and Windows Alt+F4 bypass the presentation; those native paths
remain available. No global user sound/ENDOOM settings are overwritten.
The requested 15% master volume, with music/effects enabled, is test configuration
only. CreditPage/TitlePage, port completion and saved progression are preserved.

## 4.37.20 - Training target presentation (#98)

The shared Caella/Rulo dummy now renders as a textured 3D model. Its actor
collision remains Radius 21 / Height 72, independent of the visible mesh.
The base actor retains Health 1000000 and its original Spawn/Death frame;
the MAP01 practice subclass still ignores damage, movement and wear.
There are no new hit, recovery, destruction or reward mechanics. Actual valid
impacts still determine practice credit; misses and unrelated targets do not.
Existing quest flags, loan IDs, completion gates and save fields are unchanged.
Old saved actors acquire the model through MODELDEF without respawn, migration
or a new schema revision. Original saves/packages remain the rollback path.

## 4.37.19 - Palomo's necklace and canonical shield names (#96)

Author decision, 2026-10-04: choose and receive the T1 amulet with Palomo;
Caella teaches its existing recipe. This supersedes the amulet role assignment
in #63 and older sections. The other four equipment choices still require
their established crafting flow; the necklace adds no progression gate.

After following Palomo upstairs, his equipment menu offers the four existing
T1 amulets: Ruby, Sapphire, Emerald and Topaz. Review the canonical name,
catalogue weight and equipped attribute bonuses before confirming. Confirmation
fixes MainM00AmuletChoice and delivers the matching actual CaelumAmuletPickup
once, without equipping it or replacing another accessory. No new recipe,
bonus, weight, art or item type is introduced. Later Palomo final/Box/Fool
pages also expose this choice so a still-unchosen MAP01 character can return.

Native capacity checks prefer carried inventory and then an accessible owned
Box with both slot and weight capacity. If neither fits, the choice remains
saved while delivery is pending; the dialogue states that nothing was delivered.
The pending grant retries on confirmation or the periodic migration check once
there is room. The normal acquired-item notification occurs only for a newly
attached item. Selling, dropping, transferring or losing an already settled
gift never creates a replacement. Existing owned equipment survives departure
under #63, including this gift; the first weapon must still be crafted.

Caella's post-trial amulet page teaches only the selected existing recipe and
its component dependencies. Before selection it refers to Palomo; afterward it
reports learned/pending knowledge. She cannot pick or change the amulet. A new
gift already owned when learning requires no extra tutorial raw-material quota.
Already learned recipes, issued supplies and active task reservations retain
their previous state. Repeated teaching is idempotent.

Save migration: MainM00NecklaceRevision defaults to 0 and reaches 1 only after
successful delivery or recognition; MainM00NecklaceItemId stores the settled
native identity. An existing selected T1 owned by the player is recognized in
carried inventory, equipped or in the Box without changing its ID, condition or
placement. A different type, a T2 or a loan does not substitute for it. Old
selected saves without that T1 receive it when capacity allows, including an
already completed tutorial. Unchosen saves remain unchosen. An active task for
that same T1 defers creation until completion (recognize its output) or cancel
(retry the pending grant); no task or reservation is cancelled by migration.
All old USDF page slots remain at their original indices; new conversation
43633 is appended. Legacy Caella preview slots become recipe/referral pages.
The handoff between Palomo menus is transient. Rollback uses the preserved
original save with its original package, not a newly saved file downgraded to
the old build.

Shield options 0-3 use the same localization keys as inventory: buckler / kite
shield / tower shield / magic shield; Spanish: rodela / escudo de lagrima /
escudo de torre / escudo magico (accented in game). Preview, confirmation and
plan summary use FormatShieldName. Type IDs, stats and crafting are unchanged.
Evidence: assets/validation_43719. All three author checks passed 2026-10-04;
HISTORY records their IDs and qualifications.

## 4.37.18 - Craft, Repair, Dismantle and Tarot details (#91)

Oficios / Crafts has three icon subsections: **Craftear / Craft**,
**Reparar / Repair**, **Desarmar / Dismantle**. Craft contains only learned
recipes matching the category filter. Missing ingredients or infrastructure
disable starting, not visibility. It can be browsed outside a station.
An empty category explains that there are no learned matching recipes.

Repair and Dismantle list accessible weapon instances in the player's native
inventory, including equipped weapons and the owned Magic Box. Nearby drops,
NPC inventory and inaccessible Box contents are excluded. Each copy has its
stable item ID, tier, size, wear, location and applicable essence. Equipped,
temporary/protected, undamaged or unknown-recipe items remain visible with
their applicable reason. Repair recognizes the learned Pickaxe recipe.
Armor/shield task APIs remain available to their existing consumers; this
weapon browser does not widen the issue's ownership scope.

The existing material, proportional wear/recovery, rounding, efficiency,
station-network, carrying-capacity and time rules remain authoritative.
Repair previews required components and, when ready, the actual input
reservation after processing. Dismantle previews recovery. A blocked operation
does not promise a completion time. Confirm rechecks mode, exact identity,
ownership and current requirements; a stale row cannot select a different copy.
Browsing never creates reservations or changes an active task's outputs.
Lists refresh after learning, ownership changes and completion. Closing or
leaving the workbench still pauses; cancellation releases the reservation.

Controls: **1/2/3** select the operation; **F/D** also open Repair/Dismantle
without starting it. **Left/Right** or the wheel over the list selects entries;
**Up/Down** or the wheel over details scrolls text. **Enter/E** confirms the
selected operation. **G** filters Craft; **Space/R/B** change its tier, size
and batch. **X** adjusts craft/repair efficiency. **C** cancels a task,
**T** retains x60 and **Y** opens the time-skip selector. **Tab/Q** closes
Oficios; **PgUp/PgDn** changes the main Journal section. Native controller
direction/confirm/back bindings remain. Mouse clicks select main section
icons, operation icons, list rows and the bottom confirmation/status area.

Tarot exposes three labeled fields for the selected card: passive fixed and
collection bonuses; active world power with the existing shared 1000-Anima,
60-second/600-second-from-use rules; and the current Trucazo effect. The latter
explains captured Minor awakening, trick strength, Envido/row contribution or
Major exclusion, independently of world power selection. Traditional Truco
has no essence effects. No undefined power is invented. Uncaptured artwork
previews do not reveal powers or grant ownership. Physical deck possession
and captured essences remain separate. Up/Down or the wheel scrolls all three
fields; selection, remaining effect time and recharge stay visible.

## 4.37.17 - Pickaxe, gathering sounds and success notice (#89)

Author decisions, 2026-10-04: English/code **Pickaxe**, Spanish **Pico**;
weapon family/key **1**, alongside unarmed; **T1 only**. Primary is slashing for
chopping and secondary is piercing for mining. All numeric weapon statistics,
size-scaled weight and maximum durability use the actual T1 **axe**, not the
hatchet. At M, the existing axe weighs 8 kg, primary/secondary base damage is
140/160, and current maximum durability is 10,000. Shield compatibility, costs,
reach and the attack clock follow the axe. The mining pose turns the same
hybrid head while retaining the native grip, recovery and hand rig.
The author's rest-pose refinement tilts the tool 20 degrees clockwise around
that grip, with the native swing continuing from the same resting angle.

One learned recipe reuses the axe's ingredient types, ratios, rounding, size,
efficiency and station rules. At M/T1/100%, it consumes 5,600 Handle and 2,400
Weapon Head units. No T2/T3 recipe, vendor stock or enemy-drop source is added.
The output uses the existing inventory, repair, disassembly, weight and Box
rules. New physical crafting outputs explicitly carry the current durability
revision, preventing a new item from being scaled as an old save.

An eligible hit by the actual equipped Pickaxe multiplies the normal released
quantity by **10 for chopping** or **100 for mining**, once, before the existing
finite source and tutorial allowance caps. Remove only the released amount.
Fractional carry, resource type, renewal, spawn failure and pickup capacity
retain their shared behavior. Owning a Pickaxe while using another tool adds
no bonus; misses, wrong damage type, ordinary non-resource rocks and exhausted
sources yield nothing.

After a successful extraction, **every eligible weapon** plays one positional
material sound: wood/fiber chopping, stone/coal, metal ore, or crystal/gems.
The same confirmed event shows **Material extracted: <material>** / **Material
extraído: <material>** at screen center in **CaelumText**. The latest success
replaces the previous one; duration follows the existing notification setting.
Menus hide the notice. It confirms extraction, not an inventory pickup. Zero
extraction emits neither sound nor message. Mining OGGs remain unchanged; tala
uses an isolated one-shot from the approved long recording.

Ronnie gives the owned tool plus its recipe/component knowledge when the
lesson starts. It replaces the former sword loan. Palomo's four choices remain
intact and the selected weapon must still be crafted and shown to Ronnie;
the gift never completes that objective and no duplicate Pickaxe is required.
Equipping it again neither repairs nor replaces it. Selling, transferring or
breaking the gift does not replay the reward; its recipe remains learned.
The owned Pickaxe survives completion and narrative departure with other owned
equipment. Old temporary sword instances follow their original return rules;
owned swords are never removed by the new grant.

Save contract: playable type 20, catalogue type 16, recipe 131, recipe book
revision 5 and gift revision 1 are additive. Existing recipe indices 0–130 and
ownership indices 0–299 retain their meanings. Started/completed old saves
receive one gift through the normal capacity rules, even outside MAP01; a full
inventory defers delivery. Repeated loads/updates do not replenish quotas,
reset progress or heal the gift. Keep the original save and matching old PK3
for rollback; migration tests never overwrite those originals. Earlier Ronnie
loan/return wording below describes the pre-#89 flow; this section supersedes it.

## 4.37.16 - Compass and menu pointers (#87)

The top-left compass follows the rendered camera angle, including stationary
turning. Strafing and walking backward do not change its heading. World north
is +Y, east +X; this matches MAP02's cardinal blocks and MAP06's city exits.
The needle and 000-359 bearing update continuously; the nearest of eight
directions appears below it. West is O/SO/NO in Spanish and W/SW/NW in English.
The cardinal letters are centered by visible glyph bounds, compensating for
CaelumMono's trailing kerning and padding. The dial shares their center and
uses silver laurels, a dark-metal rim and a subdued Sun of May background.

The compass uses the native hud_scale and hud_scalefactor controls, with
resolution-based bounds. It hides in menus, dialogue, crafting, Journal and
after death. The existing twenty-message feed reserves a left strip whose
width follows the compass; its entry count and right column stay unchanged.
The standard four native console-notification rows are reserved when enabled.
It introduces no saved fields, character migration or gameplay changes.

Both native skull selector frames resolve to the same transparent Sun of May,
with a face and 16 straight/16 wavy alternating rays. Native navigation and
selection behavior are retained. GameInfo selects the 32-pixel silver C moon
cursor, with hotspot (31,7) at its upper horn. An explicit user vid_cursor
override still takes precedence. Physical click/drag passed author acceptance on 2026-10-04.

## 4.37.15 - Traditional Truco ranked mode (#101)

Author decisions, 2026-10-04: alongside the accepted Trucazo practice, Argento
offers traditional Argentine Truco, called ranked. The author confirmed a
30-point match (15 malas / 15 buenas), optional Flor, and no rating service yet.
No health, row damage, character attributes, essences, powers, wagers, prizes
or campaign transactions apply. Palomo's physical deck is still required.
The same 40 equivalent cards already used as playable Minors provide the art:
1-7, Page/Sota = Spanish 10, Knight/Caballero = 11, King = 12, in four suits.
Only those 40 enter the shared shuffle; deal three each, without replenishment.

- Hierarchy: Sword Ace, Wand Ace, Sword 7, Coin 7, 3, 2, other Aces,
  Kings, Knights, Pages, other 7s, 6, 5, 4. Equal strengths are parda.
  A won trick plus a parda wins the hand after two; split wins require the
  third. A tied third favors the first winner; three pardas favor mano.
  A trick winner leads next; a parda preserves the previous lead. Mano
  alternates between hands; the first mano is randomly selected.
- Truco/Retruco/Vale 4 are worth 2/3/4; refusal awards the previous stake,
  initially 1. The accepting side owns the next raise. Irme al mazo folds
  the hand at its current stake; before the player's first card, unsettled
  Envido additionally awards the opponent 1 (explicitly confirmed).
- Envido uses the best same-suit pair +20, figures 0, otherwise the highest
  number. Ties favor mano. Envido adds 2, up to twice; Real Envido adds 3;
  after Real only Falta may raise. Refusal awards the previous call, or 1
  for the first. Calls occur before the caller's first card in the first
  trick; responding Envido suspends a pending Truco and then restores it.
- Falta Envido and Contra Flor al Resto award the leader's distance to 15
  while both are in malas, otherwise to 30. This replaces, rather than adds
  to, the current side-game bid. The author explicitly confirmed this variant.
- When enabled, Flor is mandatory for three same-suit cards, valued as their
  sum +20 (figures 0), with ties to mano. It must be declared before playing
  the first card and cancels Envido. Unopposed Flor gives 3; two declared
  Flors without a raise or accepted Contra Flor give the winner 6. Declining
  with Flor gives the caller 4, also for Contra Flor al Resto; without Flor
  gives 3. These refusal variants were explicitly confirmed by the author.
- Points are awarded immediately; reaching or exceeding 30 ends the match,
  including an Envido/Flor resolved before the hand. Abandoning the match
  requires confirmation and is defeat. Save/load remains available.

The NPC policy receives its own hand and public cards/calls, never the hidden
opposing hand/deck. The traditional inventory starts at revision 1 only when
needed; old saves need no mutation of their existing match or character schema.
Original saves and their original package remain the rollback route. Flor can
change only before beginning; saved live matches keep their option and exact
pending calls. Traditional and practice menus use separate state/event names.

## 4.37.14a - Argento dialogue order (#99)

Argento offers Trucazo practice after the available story/service replies
and before goodbye. This applies to the early, offer, progress and completed
conversation pages; a page with no other reply still has practice and goodbye.
No new page, condition, action or match rule is introduced.

## 4.37.14 - Early physical deck delivery (#97)

After Palomo completes his existing route upstairs, successfully opening his
conversation grants the protected 78-card physical Tarot deck immediately,
before selecting any reply or equipment plan. His foyer conversation and
interaction during the route grant nothing. The Box keeps its later quest
requirements and acceptance choice; accepting it can still retry a blocked
handoff but never duplicates a granted deck.

The original 780 g/one-slot capacity rules and TarotDeckGranted/revision-1
record remain authoritative. If the deck cannot fit, Palomo explains that the
player must make room and speak again. Closing immediately, revisiting and
save/load retain the grant. A pre-change save with no deck can receive it on
its next eligible conversation; previously granted decks and essences remain
unchanged. Store the carried deck in the owned Box before capturing an essence.
This supersedes #80's original Box-linked delivery timing only.

## 4.37.13a - Crafting time help (#93)

Crafting shows Y (keyboard) for the existing time-skip selector and T for
acceleration in its lower help and active-task status. Recipe/step/family/tier/
batch/size/efficiency navigation shares the first help row; actions, time and
closing share the second. Y on a controller retains its existing filter action.
The #64 time-skip rules and controls below remain authoritative and unchanged.

## 4.37.11 — Guard recognition as a persistent Journal clue (#79)

Use a living local guard in MAP06, within the existing Use reach and line of
sight. The native USDF menu identifies the protagonist as captain and offers an
amnesiac response. The first successfully opened greeting records clue 9,
`QUEST_GUARD_CAPTAIN`, as completed; closing without selecting a response still
preserves the information already heard. Later guards and repeat visits use the
repeat greeting/response. No action grants money, reputation, items, membership,
class changes, command abilities or memories, and no prisoner count gates it.
The Journal lists "They call me captain" under main/completed records: completion
means the clue was heard, not that the protagonist recovered his past.

`CaelumGuardCaptainDialogue` delegates the actual conversation to the existing
faction/dialogue opener with no faction condition. Native fighting, dead,
sleeping/stunned, out-of-range, blocked-sight, already-speaking and unfinished
character creation conditions cannot grant the clue. A stale INCOMBAT flag is
ignored only when there is no living hostile target or the siege is over. The
guard's route pauses during its own non-pausing conversation and resumes afterward;
protection, combat stats, cannon ownership and army control are unchanged.

Persistent quest arrays retain their 32-slot schema. QuestStateVersion 3 clears
only previously unused slot 9 for revision-2 saves, once; it never guesses knowledge
from port visits, rewards or siege completion. Older revision-1 migration remains
intact. The Journal's derived arrays expand from 9 to 10 entries, and rescue
classification remains explicitly bounded to four prisoners. Dialogue IDs 43631/32
and their four pages are appended to CAPALOMO, preserving all existing page indexes.
Original saves/package remain the rollback path; no save rewriting is required.

## 4.37.10 — Prisoner siege intelligence after payment (#78)

The existing port payment confirmation now also gives the siege briefing in
English/Spanish. Each survivor must first be extracted alive and actually deliver
the accepted 25 gold / +10 own-faction reward. Failed capacity checks, captive or
following prisoners and unpaid port conversations do not unlock this information.
The existing claimed flag gates repeat access; re-reading never grants anything.
The paid rescue's Journal detail and the port siege quest share the same text.

`CaelumSiegeIntelligence` reads the existing quest snapshot: stage 0 means no
observed encounter yet, stage 1 active, stage 2 completed. Successful payment
discovers the existing quest at stage 0 if necessary. The ordinary encounter still
discovers/updates it for zero rescues. The controller's sealed twelve-machine
roster and confirmed victory remain authoritative; both stopping the commander
and neutralizing all twelve hostile machines are required. Defender cannons do
not count. No four-prisoner requirement or new siege trigger was introduced.

Location comes from `CaelumWorldCatalogue.LOCATION_PORT`. During/after the assault,
the briefing displays the recorded `port16_siege_start` / `port16_siege_end` date
from the same calendar events created by `CaelumPortSiege.Calendar`. Current MAP06
deploys on entry and records that event; it does not schedule a future attack.
**PENDING author decision:** a future date/hour, countdown or rescheduling rule.
Before an encounter the text explicitly says the date/hour is unconfirmed; a
legacy save without a dated event does not fabricate a historical timestamp.

Native conversation pages and their global indexes are unchanged. `userstring`
tags format existing paid pages and the two existing port voice pages. Text
updates while the non-pausing conversation remains open, including victory.
Delayed start narration also reflects completion instead of describing an ended
siege as still active. Payment and completion events retain their original
pending/delivered bits; the normal queue waits until the prisoner dialogue closes.

No new serialized field, schema or event handler is added. Existing paid saves
recover Journal access idempotently from the accepted claimed flags without
replaying rewards or modifying the narration queue. Existing quest progress is
preserved. Original saves/packages remain the rollback path; use the matching
legacy map option for saves that visited older geometry. #78 changes no maps.
Static/native results are in `assets/validation_43710/RESULTS.json`; author
acceptance remains separate in `pending_test.txt`.

## 4.37.9 — Expanded city, southern siege and campaign route (#77)

The final city footprint is 960 × 960 m at 32 MU/m, with 288 constructions:
160 houses, 64 shops, 24 factories and 40 construction sites. Streets connect
their entrances, the preserved harbor and the fortified perimeter. North/west
and six southern gates retain the accepted 96-MU breakable gate actors in
128-MU-wide masonry passages; arches have 96 MU clear height. The eastern dock
arch is open. Native character collision tiers 1–7 remain supported.

The wall walk stands at 256 MU and tower gun decks at 384 MU; 16-MU risers
provide physical access. The four towers project beyond the wall corners so
their artillery has real exterior firing lines. Movement and projectiles retain
native collision and gravity. The northern tower guns can engage the two
southern flank gun crews without a range or wall-penetration exemption.

The author's sixfold population change means 6,000 Mandingas, one commander
and 600 defenders. Five small rams, one large ram and six attacking cannons
remain the twelve hostile objectives. There are 36 defending cannons: eight
per wall and one on each tower. The eight southern wall guns and four tower
guns are active; 24 staffed guns remain in reserve for this southern assault.
All 72 defensive operators belong to the 600 soldiers, leaving 528 reserves.
Existing defender attributes/equipment, cannon loading/ballistics, ram crews,
and gate materials remain unchanged. The later author direction below retires
the port enemy zero-resource attack trial.

Author follow-up, 2026-10-03: each attacking command group has at most 100
members, including its leader. LAYOUT.json owns command_group_limit. The bounded
neighbor traversal leaves excess actors for subsequent groups instead of joining
an unlimited connected component. Every queued member participates in leader
election: Zupay priority 1, Mandinga priority 2, stable roster identity for ties.
The 1,024-MU visibility links and 35-tic/death-triggered refresh remain. All
6,001 attackers stay simulated. Existing port saves regroup on the next ordinary
refresh; no roster, geometry or save-schema replacement is required.

Further author decisions, 2026-10-03, apply to the shared combat actors:

- Below #128's high-density threshold, Mandingas in the siege choose the nearest visible living player or guard.
  A leader's candidate cannot hide a closer opponent. Perception uses the
  existing eight-tic data cadence, staggered by identity; death or lost sight
  invalidates the cached target. Hidden lane goals remain approach destinations.
- NPC melee attacks require native melee reach; magic checks the actual muzzle
  and target center against the caster's derived range and line of sight. Release
  checks repeat the preparation check, so a target can escape during wind-up.
  Existing natural-melee and T1 staff costs cover legacy NPC attacks without
  an explicit cost. Profiled weapons, slam and bull running keep their own costs.
- An unaffordable attack triggers physical retreat, then idle once beyond the
  current opponent's horizontal attack envelope plus the retreating actor's
  radius. Armed opponents use their weapon/ability range; bulls retain charge
  range. Melee vertical overlap cannot prematurely count as safe distance.
  Native collision can obstruct retreat. Both full Air and full Anima are
  required to resume; neither resource is granted by entering recovery.
- Actual Pain interrupts recovery immediately. The next attempted attack still
  pays its cost and can trigger retreat again. Scripted boss flight, withdrawal
  and prisoner extraction retain priority. All living idle combat actors recover
  health, Air and Anima at twice their normal rates, using the chair factor.
- Seated players now also recover Anima at twice its normal rate, including
  time advancement and its forecast. Leaving the chair restores the normal rate;
  beds' Anima behavior remains unchanged. Existing needs checks still apply.
- Player bows, carbine and crossbow use catalogue range converted from meters
  to map units; player magic uses derived ability range, including charged,
  homing and multi-projectile casts. NPC and player projectiles share a native
  movement-distance budget clamped before collision. Blast radius remains a
  separate authored effect; javelin throwing retains its existing gravity and
  ballistic trajectory because it has no separately authored flight-range cap.

Recovery revision 1 and target-cache revision 1 initialize derived state once,
without replacing actors, restoring resources or resetting deaths/crew identities.
New recovery phases and remaining projectile distance serialize normally. Old
limited NPC flights retain recorded distance/age; old uncapped player shots
already in flight retain their original behavior until they end. Preserve the
original save/package for rollback; loading a newly saved recovery state into
an older executable package is not promised.

In the expanded city, a vacant defensive post selects the nearest eligible
reserve to its stair entrance. That same actor follows saved waypoints using
native TryMove at its existing See-state speed/cadence, with native A_Chase
obstacle avoidance. It climbs every level, approaches beside the carriage and
must be physically near the cannon to operate it. There is no teleport or new
soldier. Reserve positions keep access points free. Saved route progress is
idempotent; layout/setup revision 2 activates this behavior only on the new map.

Victory still requires all twelve hostile machines neutralized AND the commander
defeated, in either order. Half-health flight and survivor withdrawal use real
southern exit zones; withdrawal awards no kills. Knight capture and the endpoint
at (128,1856,0) retain their shared rules. Rescued prisoners still pay independent
25-gold/+10-own-faction rewards once, with no new supplies or shops' trading rules.

Connection 16/network revision 4 provides direct MAP02 → MAP06 without renumbering
old IDs/history. It retains the maze exit, Ace/Zupay prerequisites and 10 km
journey planner, calendar, provisions and caravan confirmation. Connection 2 is
inactive; legacy connection 8 remains for saves already in MAP03. Arrival and
prisoner/resource positions are preserved. No cardinal exit enters a diagnostic map.

Use a fresh/unvisited MAP06 for the expanded southern city. For a previously
visited port, select its exact geometry: --legacy-map06-north-city for the first
4.37.9 northern city, --legacy-map06-siege for 4.36.27–4.37.8, or --legacy-map06
for the pre-siege 4.36.26 port. These three alternatives are mutually exclusive;
each can accompany --legacy-map02. Existing populations, positions, casualties
and rewards stay in those saved layouts. Keep original saves/packages for
rollback; no old MAP06 geometry or army is reset or transplanted.
Current native/static evidence: assets/validation_4379/south. The author confirmed
all three #77 checks passed on 2026-10-03; HISTORY records acceptance separately
from the native results. Performance follow-up remains in #86.

## 4.37.8 — Corrected MAP02 material accounting (#75)

The #73/#75 supply contract below is unchanged. Its current per-instance ledger
is assets/validation_4378/MATERIAL_LEDGER.json, keyed by catalogue_index.
The archived 4.37.6 table accidentally joined recipe output to the chest-ordered
array position. For example, catalogue 39 is an Earth Bell, not the armor whose
hide budget occupied that row. At equipment size 0 its whole-batch reference is
252 raw emerald, 2,036 raw copper and 228 raw tin units. The correction affects
315 item/size rows across 63 instances; aggregate quantities and runtime stock
remain unchanged.

All 65 existing recipes produce one equipment instance at each of five sizes
from their allocated basics in isolated native completion tests. 100% remains
a budget reference. Ordinary crafting retains its selected efficiency, knowledge,
time, station and Box requirements. The fixture supplies those prerequisites
and skips task elapsed time; it does not establish that every crafting route is
available at MAP02's retained workshops. Existing author approval of the workshops
and the old-save waiver remains in force.

## 4.37.7 — Floor traps, flooded return and central lift (#74)

This revision replaces the former six pit stair exits and the #73 elevator
reservation. Upper progression, all other trap types, 100 junctions, 96 Mandingas,
192 rats, 39 material chests, prisoners, extraction and the boss route remain.

The six 128-by-128 apertures join one interconnected lower network. Its floor is
at -160 MU, water surface at -144 and ceiling at -32: 16 MU of native swimmable
water and 128 MU of clear height. These reuse the existing channel depth and
32-MU mapping grid; the maximum supported collision height is 74.67 MU. Water
uses established movement/Air rules, with no added damage, current or drowning
balance. Native tests observe water level 1 for the return route.

Exactly four permanent, keyless grates surround the 512-by-512 central platform:
south 44910, west 44911, east 44912 and north 44913. A closed grate opens only
from its exterior tunnel side. Opening any one calls the elevator to the lower
landing; it does not require opening the other three. Stand near that platform
edge and press Use again from inside to travel up to the original central start
at height 0. Use from a landing calls the lift to that landing; Use from inside
requests the other level. Descending from the start with all grates closed still
allows an upward return, without opening a grate from inside. Calls during an
existing movement do not create another mover; call again after it stops.

On the author's explicit #74 follow-up, a block whose normal entrance is closed
keeps its trapdoor covers solid and inactive, including for enemies. Opening
that entrance restores ordinary trap activation. The initially open south block
needs no additional condition. Native underside collision prevents jumping into
unopened blocks; the continuous upper slab separates every other lower passage.
No new keys, cell access, extraction condition or companion rule is introduced.
Followers retain their existing collision movement and distant catch-up behavior.

Enemy death supplies still appear once at their assigned original dry upper
anchors, including after deaths in water/pits; keys remain recoverable by the
normal surface route. This does not restore preplaced ground loot. Trap/grate
fields and native moving floors persist through current-layout saves and hub
travel. Old-layout save compatibility was explicitly waived by the author;
the preserved revision-3 source is provenance, not an automatic migration mode.

## 4.37.6 — Central hub, cardinal keys and finite supplies (#73/#75)

This revision supersedes the revision-2 coordinates and finished-equipment/ration
counts in the historical #10/#11 sections below. Ordinary arrival is `(0,0,0)`.
The initial open block is south. At the author's follow-up request, all four
entries are 2,208 MU from the center: minimum symmetric separation with one
32-MU wall strip between block footprints, including cells/refuges.
Return to the hub after each block:

`hub -> south [203 + cell 207] -> hub -> west [204 + cell 208] -> hub -> east
[205 + cell 209] -> hub -> north [206 + cell 210] -> extraction -> arena 206
-> Zupay defeat/confirmed retreat -> Ace of Cups -> MAP03 -> MAP06`.

Each progression key opens the next block entrance; 206 opens the northern arena.
Each key has one guaranteed Mandinga carrier inside its own accessible block,
outside the matching locked cell. Native locks, permanent openings, beds,
refuges, escort/extraction and boss/card/campaign rules are retained.
The author's follow-up requires the Zupay to remain inactive until its own
keyed gate opens. Closed native lines block AI sight; the sewer boss also skips
its actor tick, clears target/enemy references and zeroes velocity while that
gate is closed. Sound alerts or retained See states cannot start movement or
attacks early. Opening with key 206 resumes the existing boss/retreat behavior.
There are 100 junctions, 96 Mandingas (24/block), 192 rats (48/block), 45 traps,
39 chests, four prisoners/beds and the separate northern Zupay.

The 65 actual former equipment instances become their existing recipes' basic
inputs at 100% efficiency, including processed materials and component recipes.
Minimum recipe batches round upward at each layer; this is a material budget,
not free crafting or a change to player efficiency. The per-instance ledger
includes all five equipment sizes and summed basic-material quantities.
Preview follows recipient size without reserving stock. The first successful
withdrawal fixes that chest's shared size and budget; partial withdrawal, failed
capacity, other recipients, reload and hub travel cannot resize or refill it.
Material previews paginate with N. No recipe is learned by inspecting/collecting.
The author confirmed retaining existing stations: sewing/leather, jewelry and
shield-anvil routes may require another workshop and known recipes.

Exactly eight Mandingas carry one key each; 24 others carry one same-type
20-unit ammunition stack: 240 arrows, 120 bolts and 120 bullets in total.
Other Mandingas carry no assigned object. Each rat carries one ration:
96 food and 96 water map-wide. These supplies are not preplaced on the floor.
Death releases each assignment once at its original dry, reachable map position,
so pit/crush/companion kills cannot destroy keys or leave them below the map.
The generated manifest publishes each carrier, stack, recovery anchor and lock.

The central `[-256,-256]..[256,256]` footprint is reserved for #74's elevator.
No lower tunnel, return grate or elevator is implemented here; current pit escape
geometry remains until #74. The reservation cannot bypass any surface gate.
The author's 2026-10-02 save waiver means fresh-map testing; no old snapshot
migration is claimed. Existing legacy-4.36.4 build selection remains available
for its original purpose, not as compatibility with the retired 4.37.5 geometry.


## 4.37.5 — Daily mansion provisions (#65)

This policy supersedes the historical one-time all-food allocation below.
Only MAP01 mansion tables receive automatic stock. Each existing provision slot
holds one established ration: small 4 = 2 food / 2 water; normal 18 = 9 / 9;
large 60 = 30 / 30. The six tables have 94 slots, with fresh totals of 47 food
and 47 water. Serving mass, water volume, digestion and recovery are unchanged.

Fresh tables receive their initial targets once. Every Limbo-local midnight,
SyncLocalDay fills only empty slots toward each target, food then water. Normal
play, T and Y use the same boundary. A multi-day skip consumes real portions
between refills; its numeric task forecast applies the same per-slot policy.
The exterior calendar remains frozen, and no wall-clock/offline catch-up occurs.

MansionProvisionRevision 1 and LastMansionRestockDay persist per table. Repeated
or older day notifications do nothing; missing several days supplies only one
current target, never a daily backlog. A full or obstructed table records the
day too, so withdrawing an item cannot claim its missed portion later that day.
Displays follow actual inventory ownership and preserve the existing models.

Deposited items and containers are never replaced to make room. Containers keep
their class and liters and occupy a slot; their water is not a new ration slot.
Consequently an occupied table can remain below a target. Saved all-food tables
have no reliable item provenance: migration keeps every ration and belonging,
retires only the old pending allocation, and fills available holes. Such tables
converge to the new ratio as excess old food is consumed and later days refill
the vacancies. Migration neither discards food nor invents overflow storage.
Keep the original save/package for rollback; upgraded saves are not claimed to
load in an older version. No map geometry or authored return route changes.

Palomo's bilingual food-source explanation now identifies local midnight and
states that removing a serving does not refill it immediately. Tables outside
MAP01 receive no automatic initial or daily supplies.

## 4.37.4 — Explicit time skipping and separate Limbo clock (#64)

Y opens a destination day/hour/minute selector in an existing safe rest or work
context (or an authored safe zone outside MAP01). Left/Right select the field,
Up/Down change it, Enter confirms, R recalculates the task default, and Q closes
or interrupts. Escape retains native pause. T remains the existing x105
fast-forward, with 104 extra integrated personal steps per normal engine step.
Neither mode simulates arbitrary world AI or physics. The skip yields between
batches, supports save/reload and retains actual partial progress on interruption.
The technical planning horizon is 30 local days, inherited from the journey
planner; destinations are expressed in whole minutes.

Input repair 5.1.11/#156: Q/R recognize the native character code as well as the
text fallback. Tab/controller B also cancel. During an active skip cancellation
stops it and keeps the result panel; a second cancellation closes it. Idle,
completed or pending-confirmation panels close without discarding completed work.
Enter still rejects a destination that is now in the past; select a future time
or reopen Y for a new default. A completed crafting task is not started again.

Author decisions, 2026-10-01: automatic sleep begins at the existing critical
10% Sleep threshold and wakes at 100%. Recovery remains 100 points per eight
local hours. Sleeping pauses all crafting ticks, including forced sleep;
reservations remain until the native task completes or is explicitly cancelled.
The skip resumes work at its original valid station after waking. On completion
or interruption the automatic session ends with its actual resource values.

Automatic care may use the whole safe location. MAP01 uses its actual available
tables and unoccupied furniture; other maps use the authored safe zone containing
the player and the support. Existing threat guards also cover the remote supports,
so a distant unrelated encounter does not make all of MAP01 one safe region.
No teleportation or additional travel-time balance is introduced. Work remains
standing. Waiting uses an available chair; sleep prefers the best available real
support, then an accessible owned sleeping bag with room, then existing ground
rest. Existing comfort factors and seated meal duration apply.

Provisions are real inventory transactions: accessible tables first, then carried
items, then the owned Box reserve. Partial water containers preserve their identity,
remaining volume and storage location. Automatic servings reuse the journey
trigger: wait until the whole dose fits, and never refresh an active food/water
effect. No new portion begins while asleep. Critical needs, damage, movement,
combat, invalid stations, unsupported effects or hazards interrupt safely.

With an active crafting task, the numeric preview accounts for real stock, food
effects, needs, healing/Air costs and sleep interruptions. Confirmation recalculates
from current state before starting. The preview never mutates inventory or awards
work; the runtime uses the native per-tic effects and task transaction. The final
completion minute rounds forward. Unsustainable needs, an upcoming siege, unsupported
forecast effects or the planning horizon report a blocker rather than a completion
date. A manually chosen destination still stops if its actual conditions become
unsafe. Daily table notifications and matching forecast hooks are provided here;
the 50/50 replenishment policy is the separate dependent issue #65.

CaelumWorldClock revision 1 adds persistent LimboDays/LimboDayTics while retaining
the legacy monotonic CompletedDays/DayTics and LimboSubTics for existing consumers.
126000 active-play personal tics equal one local hour in MAP01 (1:1). Normal play,
T and Y advance this same local clock; its midnight dispatches the daily hook.
The civil calendar anchors advance alongside the legacy counter only in Limbo,
keeping both campaign and diagnostic civil dates frozen. Outside time retains
the existing 20:1 pace and does not advance the Limbo counter. No computer-clock
or offline catch-up is used.

Older MAP01 saves seed local time once from their previously displayed counter;
outside saves start the new unused Limbo counter at zero. Existing civil dates,
quests, inventory, reservations and aggregate timestamps are preserved. Old
versions did not record which elapsed days belonged to Limbo, so the migration
does not guess or undo their already accumulated civil time. Keep the original
save and original package for rollback; new sessions freeze the campaign start
at 03/11/1889 09:00 until departure. This section supersedes contradictory historical
descriptions of the Limbo/global clock below.

## 4.37.3 — Palomo choices, Ronnie crafting and Limbo departure (#63)

This section supersedes older role assignments and the Box-plus-first-weapon
departure restriction recorded below; historical release labels remain evidence.

After his exterior introduction, Palomo explicitly invites the player to follow
him inside. Once he finishes the existing physical route, he offers 36 T1
weapon options, four armor families, five Seals and four shields. Each option
has an actions/effects page, a current stats/costs page and an explicit confirm
or back choice. Confirmations remain fixed per category and survive reopening
and saves. There are no new class restrictions or balance values. Weapon/armor
sizes use the existing character-size policy; previous confirmed sizes remain.
Weight, absorption, coverage, Air and Anima quotes come from native catalogue,
equipment models and derived stats. Charge and other existing multipliers still
apply. Seal Channel keeps its actual Adrenaline cost and cooldown.

The existing persistent weapon, armor and Seal fields remain authoritative;
the shield adds MainM00ShieldChoice and MainM00ShieldCrafted. Palomo only records
these four choices. They grant no equipment, recipes or supplies and do not advance
Caella or Ronnie. After Caella's trial and the four confirmations, Ronnie starts
the existing crafting stage, teaches the selected recipes/dependencies, and
opens the finite raw-material allowance. A legacy already-started tutorial can
continue without filling new choices or repeating its start. Adding a missing
choice to that legacy plan teaches its dependencies without resetting issued
stock, existing tasks or progress. At #63 Caella chose/taught the amulet;
#96 supersedes that assignment: Palomo gives it, Caella teaches its recipe.

Crafting-size correction 5.1.12/#158: the selected equipment size belongs to the
artisan's menu state. Browsing Seals, amulets or ammunition must not replace it
with their fixed size; their size control is a no-op. Sized task completion uses
its snapshotted size, while fixed-size completion preserves the current equipment
size. Fixed-size display/output metadata remains canonical M. This does not
increase Palomo's allowance: the tutorial's recorded size, T1 and 100% efficiency
still determine its finite stock. Existing saves keep their explicit menu size;
if it was changed to M by the old preview, select the planned size once.

Shield materials expand from established plate/strap recipes at the same 100%
layer efficiency and recorded size as the starter plan. All four T1 shields
require existing raw copper, raw tin and tanned leather; no new supply source
or unresolved authored quantity is needed. Shield tasks use the shared recursive
material solver/reservations and selected T1 shields enter personal inventory
before the Box reward. Cancel, pause, payment and save/load retain native rules.
Crafting armor, a Seal or a shield remains optional preparation; the first
weapon remains an actual crafting task. Reopening dialogues does not replenish
allowances or create extra output. Palomo says he replenishes mansion tables,
which always supply food and water; this dialogue coordinates with #65.

On narrative departure, retain every actual owned equipment instance and the
Magic Box: weapons, armor, shields, Seals and amulets, whether equipped, carried
or boxed. Preserve ItemId, type, essence, size, condition, weight and placement.
Return the magic practice implement/Seal and any legacy gathering sword through
their loan lifecycle; the owned #89 Pickaxe is retained. Remove all ammunition (including loaded magazines),
materials, currencies, consumables and tutorial keys; this supply cleanup was
explicitly confirmed by the author on 2026-10-01. Never grant a merely selected
piece, replace an item, or reconstruct a destroyed first weapon. The existing
recovery of the actual dropped first-weapon instance remains. No healing or
new equipment is awarded by this change. Active crafting still blocks departure
until the player finishes or cancels it.

Loadout revision 1 clears the legacy temporary flag on currently owned equipment
once, excluding explicit loan classes. New own crafted pieces are not marked
temporary. Existing choice fields, recipe knowledge, reservations, issued stock
and completed stages are preserved; missing shield state defaults to unchosen.
Old native conversation page indices are retained by appending the new Palomo
conversation and keeping old page slots as referrals. Migration is idempotent.
Rollback uses the preserved original save and original package, not a downgraded
new save. Equipment already removed by an earlier completed exit is not invented.

## 4.37.2 — Magic-weapon Anima bases divided by ten (#68)

Author decision, 2026-10-01: launching with every magical implement costs one
tenth of its former base. Eloquence remains the corresponding attribute, using
the new Type 2 divisor (#154); this is division, not a subtractive percentage.

`F(E) = 1 + 3 * (E*E + 25*E) / 12500`, with E=max(0,E)
`Anima per cast = base * tier multiplier * charge multiplier / F(Eloquence)`

| Implement | Former T1 base | Current T1 base | T1 at Eloquence 100 |
| --- | --- | --- | --- |
| Staff | 500 | 50 | 12.5 |
| Book | 700 | 70 | 17.5 |
| Bell | 1000 | 100 | 25 |
| Statuette | 1000 | 100 | 25 |

Eloquence 0 retains the base; 100 gives F=4 and one quarter of the base. Values
above 100 continue along the same curve. T1/T2/T3 multipliers remain 1/1.6/2.5;
a prepared charge remains x2. Primary/secondary and all five essences use their
implement's cost. A bell volley pays once, not once per projectile. Authored NPC
staff/statuette attacks share the reduced constants and their existing divisor.
Damage, duration, regeneration, Seal Channel, physical costs and the Arcanist
Sleep/class-ability base are unchanged. Runtime resources retain fractional costs.

Attribute-balance revision 3 recalculates saved derived costs and any pending
cast once, before payment, retaining elapsed casting time, current resources,
equipment IDs and quest progress. It uses the existing revision field; no new
saved fields or map conversion. Already paid casts receive no retroactive refund.
For rollback, retain and load the original save with its original 4.37.1 package;
do not treat a newly saved revision-3 state as an original-price rollback save.

## 4.37.0 — MAP01 exterior and door presentation (#61)

The new scenery is decorative only, as requested by the author on 2026-10-01.
Its Actor-only classes have no gathering, renewable resource, inventory, damage
or reward behavior. Tree trunks are stationary solid scenery; shrubs are
nonblocking. Existing resource actors and their reserves remain authoritative:
four tutorial ceibos and twenty fiber bushes, including 200,000 fiber capacity.

Native continuous floor planes supply walkable exterior relief. The terrain
meets the retained flat ground with no steps at its boundaries. Original map
objects, architectural sectors/actions, door groups/keys/swing sides and tutorial
logic remain. The distant flat exterior is partitioned solely to correct a
rendering defect; the original outer limit and blocking horizon are retained.
Fixed opaque tympanum meshes cover the visible gap over each hinged door without
adding passage collision. Existing door blockers and architectural slabs retain
their accepted collision. All supported body tiers remain below the visible
100-MU leaf top; no headroom restriction is added.
The additional top-door roof-front closure begins at Z=400, above the existing
ceiling slab. It has no actor collision and changes no access or combat rule.

The author-requested northeast cave is scenery, separate from the tutorial's
resource cave. Its five gemstone rocks are plain, nonblocking Actors, neither
shootable nor inventory/resource nodes. They cannot be extracted, depleted,
picked up or converted into rewards. The tunnel has a gentle native floor
descent, one bend and a closed end; solid 3D floors provide its roof and the
walkable mound above. No quest, enemy, loot or gathering quota is introduced.

The later invisible-boundary repair relocates detached auxiliary model rooms
outside the playable horizon. Only their polygon positions change; sector
planes, control actions/tags and the mansion's physical floors remain intact.
Paired native height samples and door regressions verify the retained behavior.

The northern-station correction compares original exterior stations with their
native FloorZ, rather than absolute zero, before relocating them. Both station
selection and the spare-station fallback use this condition. Existing room
groups, positions, recipes, dimensions and capabilities remain; eighteen original
actors are reused within 38 total stations. Repeated preparation preserves those
instances and creates no duplicates. This correction applies to fresh MAP01;
already prepared older worlds are not migrated under the existing waiver.

The author accepted all #61 tests, including CA-4370-STATIONS-01, on 2026-10-01
and authorized PR #66 merge/issue #61 closure. This acceptance update changes
no runtime behavior, crafting rule or save state.

The author explicitly waived old-save compatibility work for #61 on 2026-10-01.
Start a fresh MAP01/new campaign; no old-MAP01 migration is claimed. The accepted
baseline is preserved for recovery, and existing MAP02/MAP06 launcher options
remain unchanged. Author acceptance is distinct from the isolated native checks.

## 4.36.27 — Complete port siege (#16)

MAP06 deploys 1,000 Mandingas and one distinct commanding Zupay concurrently,
five small rams (six operators each), one large ram (32), six attacking cannons
and twelve defending cannons. The 74 attacking operators belong to the same
1,000-Mandinga roster; they are not extra enemies. One hundred friendly soldiers
reuse Domingo's appearance: all twelve attributes 18, height 1.8 m, body mass
80 kg, existing campaign T1 sword, kite shield and medium armor. Twenty-four
operate the defensive guns; the remaining 76 defend the ram gates. Their
equipment uses the shared damage, defense, resource, timing and wear models.

Author decisions of 2026-09-30 supersede the former cannon cycle: both sides
fire automatically with unlimited ammunition and prefer eligible visible enemy
siege operators, then other enemies. Two operators complete a cycle in 10 seconds
(350 native tics), one in 20; zero stops progress. Aim is selected when loaded,
with native-gravity elevation compensation. Accepted 500 m/s projectiles and
physical impacts remain. Saved revision 0 work migrates proportionally from
the old 1,050-tic cycle to 350 once. The scenario explicitly enables unlimited
ammunition; old finite-ammunition actors retain their stored rounds and mode.

Connected compatible attackers share command across species. Zupay priority is
1 and every Mandinga priority is 2; saved roster identity breaks equal-priority
ties. The #77 follow-up limits each group to 100 members including its leader.
Local links use sight and the layout's 1,024-MU radius; groups are rebuilt
every 35 tics or upon a confirmed death. Split groups elect their own leader
and reconnect deterministically. Operators follow their moving machine posts;
availability controls operation separately from death-backed neutralization.

Author follow-up, 2026-09-30: a dead crew member is replaced by the nearest
living, unassigned combatant of the same side (stable roster order breaks ties).
Both ram sizes and both cannon sides reuse the vacated slot. A living operator
who temporarily leaves keeps the assignment. Recruits must walk to the moving
post/platform before counting as present; no teleport, extra spawn or remote
operation. Guard death memory remains separate; neutralized machines never
recruit or reactivate. If no eligible reserve remains, the vacancy stays open.
Allied replacements come from the original gate defenders, so their distribution
changes with losses while the original 100-person roster remains fixed.

The author subsequently requested a trial in which port enemies may execute
physical and magical attacks even with insufficient Air/Anima. This trial is
enabled by `enemy_attack_resource_trial: 1` in assets/map06_port/LAYOUT.json.
Only hostile Mandingas and the commander registered to CaelumPortSiege qualify;
the player, defenders, friendly conversions and other encounters keep their
normal costs/limits. Spending still drains available resources, clamped at zero;
it does not refill or increase them. Existing saved resource waits can resume.
Attack cadence, weapon-load limits, damage, range, sleep/stun and half-health
retreat remain. Set the data flag to 0, regenerate generate_map06_port.py and
rebuild to restore the preceding port behavior: suppress unaffordable magic and
continue physical pursuit while Air permits. No serialized field/schema changes
are required. The author accepted this playtest setting on 2026-09-30 along with
all issue #16 tests; the data switch remains available for later balance changes.

The port commander inherits the ordinary Zupay profile: twelve attributes at
33, maximum health 44,022, Anima 6,610, Air approximately 1,222.18, mass 666 kg,
physical height 93.333333 MU (2.9167 m). Its displayed art is about 120 MU tall
(3.75 m); collision height and sprite height are distinct. The half-health
retreat threshold is 22,011. Ground slam uses base damage 66, radius 192 MU
(6 m) and the accepted 80-tic cycle; the earth statuette uses the existing T1
damage/cost formulas. These are existing statistics, not a balance revision.

The port Zupay flees at 50% maximum health, at triple base speed, using the
accepted sewer movement states. Starting flight is not defeat: it must reach
the final authored exit with sight and compatible floor height. Death also
counts; escape does not award a kill or write the sewer/Ace flag. Victory
requires this defeat AND all twelve attacking machines neutralized, in either
order. Each machine remembers its local guards; temporary absence is not death.
An escaped commander no longer blocks remembered guard clearance. Neutralization
is permanent and cancels further operation without deleting released shots.

Victory occurs once, enables the distinct Knight of Wands through shared Box
capture, ends the calendar siege and orders living attackers to withdraw.
Survivors navigate to actual northern exits and are removed only upon arrival,
without awarding kills. Gate passages open for the withdrawal. Zero, some or
all rescued prisoners remain valid outcomes; existing 25-gold/+10-own-faction
payments stay independent and once-only. Use the marked port endpoint after
capturing the Knight to acknowledge the playtest ending and its reserved music.
There is no automatic diagnostic-map exit or arbitrary time-limit failure.

Deployment revision 1, command identity, crews, guard memory, retreat, victory,
card and reward state persist. Additive defeat revision 1 never infers escape
from a missing actor. Saves that already visited the former MAP06 require
`run_dev.bat --legacy-map06` (or `build_dev.ps1 -LegacyMap06`) for the exact old
geometry; this continues that map, not the new siege. Combine with
`--legacy-map02` when needed. Keep the original save and package for rollback.
Old owned cards remain owned; the provisional reward-only Knight rule applies
only to the preserved old port. Fresh/unvisited MAP06 uses the new deployment.

Native integration, both objective orders, persistence, reward/capture and
concurrent population evidence are in assets/validation_43627. Full ordinary
campaign play and visual/balance acceptance remain author checks in pending_test.txt.

## 4.36.26 — Shared attack clock and durability (#37)

All T1–T3 weapon bases are now 14 tics. Effective duration is
`14 / (F(attribute) * (1 - p))`, with `F(A)=1+3*(A*A+25*A)/12500` and
`p=(equipped weapon mass + equipped glove/arm armor mass)/maximum carry capacity`.
Physical/ranged weapons use effective Dexterity; magic uses effective Eloquence.
The denominator is neither remaining capacity nor the overload threshold.
At `p>=1`, an attack cannot start: no cost, impact, projectile or attack animation.
At 50% load, duration doubles for the same attribute state. A gauntlet weapon is
counted once as its weapon item; a separate equipped arm-armor item contributes
its own physical mass. Total inventory load does not enter this speed ratio.

The shared calculation retains fractional tics; native state changes occur at
the next simulation tic, normally `ceil(duration)`. Rendering FPS does not set
cadence. Native held-Fire verification measured seven consecutive 15-tic
intervals for a weapon whose effective duration rounds to 15. NPC magical pose
boundaries round cumulatively, allowing poses to be skipped at extreme speed.
AI decision/chase delays between distinct enemy attacks remain separate.

An accepted player attack records its item, side, starting map/tic and duration.
Its animation reads that same clock throughout the cycle, including recovery.
Ordinary melee/sweeps strike at the existing swing's middle; authored thrusts
strike at 80%. Ranged release and recoil begin together. Magic prepares and
releases at the end of its effective duration; there is no additional eight-tic
animation after release. All paths preserve one actual resource deduction.
Changing equipment, opening Inventory/Crafting, death, immobilization, blocking
or channeling cancels a pending physical impact. Its prepared charge is already
consumed, as for an accepted magic preparation; no new charge starts during a
pending physical impact. Charge preparation remains `2/F(attribute)` seconds,
with the same three-second prepared window; ranged reload rules are unchanged.

The author's 2026-09-30 thrust presentation applies to dagger Fire and machete,
sword, greatsword and halberd AltFire. In the 320×200 weapon plane, the assembly
lowers 30 units, rotates counterclockwise around the grip to aim at screen center,
advances 60 units in a straight line toward that center, then returns to its
original grip pose. The confirmed total-cycle allocation is 16% lower, 16% turn,
48% advance and 20% return. The arm, weapon and supporting hand share the turn.
Other spear/javelin attacks retain their existing presentation.

Weapon maximum durability is ten times its previous value, applied after the
existing tier/size calculation. Armor/shield durability is unchanged. Revision 1
migrates weapon models, native items, persistent ownership/starter snapshots and
encoded damaged world/chest pickups once, multiplying remaining durability by ten
to preserve proportional wear. Native save/reload and original-save rollback
were tested. Keep the original save with its original build for lossless rollback;
the migration helpers also expose revision 0 for controlled diagnostic reversal.
Repair uses the existing missing-durability fraction, so proportional repair
materials/time do not increase. Melee damage-based wear and one durability per
successful javelin throw remain unchanged. Bows, crossbow, carbine and magic
already had durability and damage-based wear; they receive the same increase.

New projectiles retain the exact source item through weapon switching, Box moves,
drop/pickup copies and save/load. Their existing direct/explosive/multiple-projectile
damage callbacks retain the prior wear basis (prepared projectile damage, successful
melee damage); they no longer debit another identical equipped copy. Legacy
in-flight projectiles without a saved source identity cannot safely reconstruct
that identity and do not debit an unrelated current weapon.

Enemy resource changes cover the authored Mandinga, Zupay, giant-rat and bull
profiles. Mandinga melee uses the shared machete base Air (3). Punches, rat bites
and bull gores use dagger minimum minus one (1 base Air). The Zupay slam uses
`2*(greatsword primary Air + jump Air)=34`, with exactly 48 preparation and 32
recovery tics. Its damage/radius/push are preserved. Effective enemy Air reuses
`base*(body mass/100)*CalculateLoadAirMultiplier(actual carried mass/capacity)`;
the existing load curve and its 0.75 threshold are unchanged. Without carried
load the respective costs are 1.98, 226.44, 0.10 and 9.00 for Mandinga, Zupay,
rat and bull. Existing actual armor/inventory mass contributes; no fictitious
extra inventory is assigned. Mandinga/Zupay spells retain shared implement Anima
costs, budgets and regeneration. An unaffordable intended attack enters idle,
continues regenerating and resumes when its effective cost is affordable. The
bull's charge retains its separate per-tic spending; a waiting prepared gore
resumes without paying for another charge. These states survive saving/loading.
Resident/companion legacy combat profiles are not assigned guessed weapon costs.

Evidence: `assets/validation_43626`. Static checks, isolated engine tests and
author acceptance are distinct. The author confirmed CA-43626-COMBAT-01 and
CA-43626-THRUST-01 passed on 2026-09-30 and authorized merge/closure.


## 4.36.25 — Rebuilt MAP01 geometry (#36)

The mansion's roof closure and balcony guards use native solid 3D floors and
3D middle-texture collision. Guards retain the existing 48-MU height. Stairs,
conversations, rewards, Bull rules and travel semantics do not change.
The invisible outer boundary remains impassable; decorative shutter panels
are closed wall surfaces and the two reliefs have no collision or interaction.

MAP01's 48 leaves now inherit the original grouped-door access rules but use
solid 3D wooden leaves and hinged movement. Use normally opens away from the user;
opposing leaves use their outer jambs. The opening angle is 90 degrees for
clearance; the original 16-tic movement, 105-tic hold, keys, faction condition,
group prevalidation and Rulo arena lock remain. Moving blockers follow the
visible leaf. Swept solid-body checks stop opening and reopen an obstructed
closure without pushing/crushing actors. These doors are not breakable siege
gates: no combat statistics or destruction mechanics are added. Other maps
retain CaelumSlidingDoorLeaf. New-game door fields serialize normally; old
MAP01 reconstruction compatibility remains waived below. The central front
entrances at Z=136 are four independent singles (groups 910/922 and 911/923);
the four unwanted side connectors are removed at the author's request.
Groups 906/907/908/909 instead have a fixed swing toward the central rooms,
avoiding the resident beds regardless of the caller's side. Reopening a
partially open leaf retains its current direction until it closes.

The author moved Rulo's target into the empty north-central ground-floor room
on 2026-09-29. PRACTICE.json supplies its position and practice bounds through
generated CaelumMansionPracticeData. The old workshop no longer records the
six practice flags; their requirements and persistent IDs are unchanged.
Rulo's instructions and Journal Detail name the new room in both languages.

Author acceptance, 2026-09-29: all CA-43625-MANSION-01 checks passed, including
the final Caella door adjustment. Merge and issue closure are authorized.

Author decision, 2026-09-28: prioritize reconstruction over old MAP01 saves.
Use a fresh MAP01/new game; this patch does not promise geometry migration or
loading old MAP01 saves. Existing MAP02 compatibility guidance remains separate.

## 4.36.24 — Persistent quest journal (#35)

Author classification confirmed 2026-09-28: the mansion/El Loco quest is main;
the sewers/As de Copas and port/Caballero de Bastos quests are side quests.
Each prisoner rescue is a separate optional side quest, completed on live
extraction before the boss; collection of its existing port reward is separate.
This follows the Major/main and Minor/side rule, without making rescues mandatory.

The single `CaelumQuestCatalogue` identifies presentation records by stable ID:

| ID | Record | Classification and authoritative source |
| --- | --- | --- |
| 0 | Mansion / Where the Lost Awaken | Main; existing `QuestState[0]` and stage/objectives. |
| 1–2 | Development route/wait trials | Side; existing opt-in quest slots; never offered automatically. |
| 3 | The port under siege | Side; existing #34 `QuestState[3]`, driven by the registered #16 encounter. |
| 4 | Through the sewers | Side; recorded sewer visit starts it; confirmed Zupay defeat/escape completes it. An owned Ace is existing #33 legacy evidence of defeat. |
| 5–8 | Leonor, Rufino, Santos, Leandro rescues | Side; following = active, extracted alive = completed. Existing successful payment also proves historical rescue. Captive = hidden. |

IDs 4–8 are read-only catalogue identities over existing world/rescue fields,
not new mutable quest slots. No rewards, mechanics, objectives or map markers
are introduced. The already-recorded death before extraction uses the existing
Failed display under Other, with explanatory text; no new failure rule runs.
A completed rescue states whether its port payment was actually collected.
Optional mentor practices stay in the existing mansion detail, not duplicated
as independently rewarded quests. The provisional Knight capture is not evidence
of siege victory: quest 3 stays hidden until a real registered port encounter.

C/right trigger cycles All/Main/Side. V/left trigger independently cycles
All/Active/Completed/Other. Other preserves existing offered/failed/abandoned
entries. Arrows select only matching records; Left/Right still crosses journal
sections at a boundary, including an empty category. PgUp/PgDn and shoulders
always change sections; F/Y opens detail, Up/Down reads it, Tab/B returns/closes.
The title, classification and actual status remain visible; counters count only
matching records. Filter changes reset detail scrolling and abandonment prompts.
Completed entries stay selectable. No undiscovered title appears in empty views.
The completed mansion summary no longer prompts further Palomo/Fool actions.

Compatibility: the authoritative save schema and all stored IDs remain unchanged.
Existing snapshot refresh reconstructs the larger disposable UI arrays from
recorded facts; the existing saved controller also refreshes changed observations.
No migration writes, new progress flags or revision are necessary. Repeated
refresh, load and travel cannot grant rewards or reset tasks. Old saves without
visit/defeat/card/rescue evidence do not gain invented historical entries; later
maps or the provisional Knight alone do not prove sewer/siege completion.
Native pre-#35 PK3 load, same-version reload and hub travel pass. Keep original
saves as recovery copies. The author confirmed CA-43624-JOURNAL-01 passed
on 2026-09-28; its result is recorded in HISTORY.

## 4.36.23 — Armor last, body absorption and gate defense (#52)

Author-approved design, 2026-09-27. For ordinary physical/magical attacks the
order is (1) existing shield blocking, (2) anatomical vulnerability, reinforcement
and critical, (3) Toughness, (4) additive innate and equipped armor absorption.
Author revisions on 2026-09-28 replace the Type 4 divisor with subtractive
maximum-health damage and restore the historical attribute growth curve.
The earlier direct-level subtraction was superseded: level L is converted to
`R(L)=(L*L+25*L)/125`, with L=max(0,L), percentage points, without a 100% cap.
No minimum-damage floor is added. For an attack after shield and anatomy/critical:

```
P = 100 * postAnatomyDamage / maximumHealth
R = (T*T + 25*T) / 125, where T=max(0,Toughness)
remainingPercent = max(0, P - R)
preArmorDamage = maximumHealth * remainingPercent / 100
finalDamage = round(preArmorDamage * (1 - innateFraction - equippedFraction))
```

The shared helper is `max(0, damage - maximumHealth*R(Toughness)/100)`.
It uses maximum health, never remaining health, and preserves fractional values.
At maximum health 1,000 and Toughness 100, incoming 999 or 1,000 becomes zero;
1,010 (101%) leaves 10 (1%) before armor. Human light T1 absorption of 22.5%
then absorbs 2.25 and leaves 7.75, rounded to 8. Toughness 100 therefore still
negates attacks at or below 100%; larger hits pass their excess. There is no
universal immunity to arbitrary damage. Neither the level nor its derived
reduction is capped at 100. Level 50 subtracts 25.247525%; level 200 subtracts
398.019802%. Historical pain/lucidity curves retain their separate existing caps.
Equipped wear uses only its absorbed share after Toughness (1.5 in this example).
A zero remainder causes neither armor absorption nor armor wear.
The existing shield step can still absorb/wear before that threshold is reached.
Existing durability constants and reinforcement grades are unchanged.

| Recipient | Innate physical | Innate magical |
| --- | ---: | ---: |
| Beast Men and animals (Bull, Giant Rat) | 12.5% | 2.5% |
| Caelith | 10% | 5% |
| Human | 7.5% | 7.5% |
| Duendes and demons (Mandinga, Zupay) | 5% | 10% |
| Palomo (author-specified exception) | 77% | 77% |

The author explicitly confirmed Leonor=duende, Rufino=Caelith,
Santos=Beast Man and Leandro=Human. Their base NPC counterparts are Caella,
Ronnie, Rulo and Argento respectively. The noncanonical quick/debug profile
uses the Human defense fallback. NPCs inherit their class's racial defense;
Palomo overrides only innate absorption. Innate defense survives absent/broken
equipment. Only the contacted region's piece contributes equipped absorption.

| Armor | T1 physical/magical | T2 physical/magical | T3 physical/magical |
| --- | ---: | ---: | ---: |
| Magical | 10% / 30% | 15% / 45% | 20% / 60% |
| Light | 15% / 15% | 22.5% / 22.5% | 30% / 30% |
| Medium | 22.5% / 22.5% | 33.75% / 33.75% | 45% / 45% |
| Heavy | 35% / 35% | 52.5% / 52.5% | 70% / 70% |

T2/T3 multiply T1 by 1.5/2.0. Magical armor grants no Intelligence, Patience
or Insight. Other equipment bonuses, mass, fit, reinforcement and recipes stay
unchanged. `CaelumArmorRules` is authoritative for both gameplay and the
physical/magical equipment display; there is no separate UI balance table.

Classified magical damage includes magical actor projectiles, `CaelumMagicTest`,
the `CaelumTrapMagic` mine, and the channel's `Electric` discharge. The latter
now receives armor defense on players as on NPCs, while keeping its previous
shield bypass. Other shield defenses, coverage and wear are unchanged. Physical
ground slams remain physical even when their source can also cast magic.
Explosions retain region sampling and per-region health rounding: each reached
region applies its anatomy/critical first, then subtracts Toughness using the
whole recipient maximum health. The diagnostic multiplier is the actual
post/pre fraction for this hit (an aggregate for explosions), not a fixed stat.
Kinematic impacts use `max(0, severityPercent*surface - R(effectiveToughness))`
after movement amortization, before weighted anatomy and final physical armor.
The buckler/gauntlet acrobatic bonus doubles the effective attribute level before
evaluating R: level 25 becomes level 50, giving 25.247525%, not twice R(25).
Collision diagnostics display the derived reduction percentage, not the level.
No second Toughness or native armor pass is applied.
Survival drains, native crushing and other existing bypasses are not broadened.
The pre-existing elemental-DOT asymmetry remains: player DOT bypasses the
ordinary defense path; NPC DOT enters that path as physical. This patch does
not claim universal DOT parity or redesign that separate rule.

Gate defense is structural, not racial: common/reinforced/armored gates absorb
10/20/30% after Toughness. Final author revision on 2026-09-28 sets Constitution
to 0 for every material and Toughness to 25/50/75. Masses remain 550/650/1100 kg.
Maximum resistance is therefore 5,500/6,500/11,000, using
`H = int(10 * (100 + Constitution*(Constitution+1)/2) * mass/100)`.
The proposed cannon bypass of Toughness was explicitly excluded.
For frontal stationary contacts at existing ram speed 37.780229 m/s and cannon
contact speed 500 m/s, each cell is final damage / hits to break an intact gate:

| Attack | Common | Reinforced | Armored |
| --- | ---: | ---: | ---: |
| Small ram | 4,990 / 2 | 3,951 / 2 | 1,783 / 7 |
| Large ram | 5,500 / 1 | 5,972 / 2 | 5,859 / 2 |
| Cannon (4.3 kg inert round) | 0 / cannot break | 0 / cannot break | 0 / cannot break |

Absorption multiplies the unrounded post-Toughness damage; round once at the
end. The whole-gate impulse model remains, without penetration or explosion.
The large ram calculates 6,704 damage against common gates, but actual health
loss is capped at their remaining 5,500. All other listed first-hit values are
below the intact maximum. Repeated hit counts use the same contact conditions.
Gate levels 25/50/75 now subtract 6.435644/25.247525/56.435644 percentage points.
These values supersede the direct-level #52 tables and historical 4.36.19 damage.
The cannon does not exceed any gate threshold; masses and speeds remain unchanged.
Gate `BalanceRevision=2` migrates remaining-health ratio to the lower maximum,
rounded once with minimum 1 for living gates, without closing opened gates,
reviving broken gates, or resetting timers and duplicate-contact serials.
Repeated refresh/load does not rescale again. Explicit legacy-recovery revision
0 keeps its former attributes; original saves and the previous PK3 permit rollback.
Defense is read from data, not stored in each gate.

Player `AttributeBalanceVersion=2` and NPC `ArmorBalanceRevision=1` recalculate
derived values from preserved base data once on load. Attribute bonuses are
never repeatedly subtracted; equipment IDs, tiers and wear are retained.
Resource maxima may decrease and existing clamping prevents free resources.
Keep original pre-upgrade saves and the prior PK3 for reversible rollback;
do not overwrite the original with a migrated save. Old-save, migrated-reload
and original-save rollback are distinct checks in validation_43623.
This formula revision introduces no new serialized fields or reset: legacy
`DamageResistanceMultiplier` and gate `RetainedDamage` remain for compatibility
but no receiving path reads them. Existing 4.36.22 and initial 4.36.23 saves
use the new rule immediately; the final gate revision separately migrates gate
maximum/remaining health as described above. Character maxima and equipment are
unchanged by the gate revision. Initial evidence is preserved in
DIVISOR_RESULTS.json, TOUGHNESS_RESULTS.json and GATE_RESULTS.json; current
results are in RESULTS.json and curve_revision/. Restoring attribute growth adds
no serialized fields or gate revision: existing levels use R immediately without
rescaling health or resetting saved state.

## 4.36.22 — Quest ownership and persistent narrative events (#34)

Save compatibility for #34's USDF layout: saves store global page indices.
An open legacy Unknown Voice (speaker layout revision 0) rebinds the established
MAP01/MAP02 conversation ID, restarts that brief conversation once, and records
revision 1. New saves preserve the exact page. Other conversations open in a
pre-#34 save close once without executing a reply; interact again to reopen
through the speaker's canonical ID. Quest progress, items and rewards persist.
Loading never invokes Use or a reply as part of this presentation migration.
Keep original saves for rollback to the pre-#34 dialogue layout.

The awakening/Unknown Voice remains the prologue. In new games quest 1 stays
undiscovered until Palomo's existing guidance choice activates it. Its stage,
flags, objective IDs and rewards retain their existing identities; an already
active/completed old quest is not reset. Palomo offers the existing optional
needs, Air, load, swimming and canteen actions after his introductory guidance.
Legacy `MainM00*` fields and action names are retained for compatibility, even
where they contain `Ronnie`. Crafting, gathering-sword loans and repair remain
with Ronnie. He directs material-location questions to Palomo and explains the
calendar through his workshop menu. This supersedes older current-role wording.

Palomo's optional bed practice observes a real active MAP01 bed/rest session.
The mansion's existing untimed rest is preserved: no invented waiting interval,
Sleep drain, reward or main-quest gate. Food/water grants remain individually
idempotent. Air/swimming observations now test `HasActiveConversation()` rather
than a possibly stale `ConversationNPC` pointer after closing USDF.

Each of Rulo, Ronnie, Caella and Argento stores the worst state reached from
Bull damage during the active attempt: normal (0), the existing Herido (1),
Malherido (2), or incapacitated/seated at 1 HP (3). Incapacitation wins over
the others. A retry clears that attempt's peaks; healing and the end-of-fight
restoration do not. Unrelated damage and player health never select the branch.
Existing ordinary closing text and later Tarot reactions remain, with the
character-specific injury reaction when applicable. No reputation/stat changes.

Eleven event slots use native non-pausing USDF: four distinct releases, sewer
Zupay defeat (death or completed escape), four actual successful reward deliveries,
port siege start and port siege completion. Each character's persistent Inventory
owns pending/delivered masks. A failed or capacity-blocked payment does not queue
a completion. Events wait for the current conversation, inventory/crafting/merchant
menu and rest session; a line is acknowledged after its native conversation closes.
Several close events are drained in deterministic slot order, one conversation at
a time. Pending/delivered bits survive saves and travel; opening alone does not
consume a line. Selene remains labelled Unknown Voice.

Port quest ID 3 uses previously unused persistent quest storage. It becomes
visible only for a sealed MAP06 `CaelumSiegeEncounter` with twelve registered
hostile machines and its own commander. Its two objectives mirror the existing
neutralized count and confirmed commander defeat, in either order. Completion
mirrors `Victory`; surviving attackers remain the controller's retreat responsibility.
No all-Mandinga requirement, failure condition, new payout or separate card spawn
is added. The single #33 Knight path switches from provisional rescue-payment
readiness to actual siege victory when that encounter is registered. Existing owned
cards and rewards are never revoked. Zero rescued companions remain valid.

Additive narrative revision 1 baselines historical release/payment/boss events as
already delivered; it never invents past Bull injuries. It leaves existing quest,
survival, item, faction and Tarot state intact. `RestoreLegacyProgress` clears only
the new narrative fields and unused-before-#34 port quest slot; reapplying the
migration is idempotent. A native pre-patch PK3 save, same-version queue save/load
and hub travel have been checked. Keep a recovery copy before rollback.

## 4.36.21 — Environmental collisions and running absorption (#49)

The author's 2026-09-27 instruction supersedes the wall-only and walking-only
limits of 4.36.18. Grounded directional running now shares walking's existing
biological fraction: clamp(max(0, JumpZ /8 -1), 0, 0.5). Crouching retains its
existing eligibility, and immobilization still disables absorption. Active
acrobatic shield defense remains the maximum of its fraction and this movement
fraction; neither stacks. Existing landing/crushing absorption is unchanged.

The author explicitly includes walls, rooted trees and rocks at rest. A movable
rock's complete velocity must be zero before the collision solver transmits
impulse; the newly imparted velocity must not revoke that contact's benefit.
Rocks already rolling or falling do not qualify for this locomotion fraction.
Idle/airborne movement and genuine character/projectile collisions do not
gain the new benefit. Mass, material, contact geometry, energy severity and
the Type 4 damage divisor remain unchanged.

Tree/rock actor collisions now carry environmental provenance, using the
existing environmental damage path without extra native thrust. They grant
neither damage nor pain adrenaline, and do not start or refresh combat time.
Damage, pain, cast interruption and rest interruption still occur. Genuine
combat-body hits retain their adrenaline/activity behavior. No serialized
fields or state indices change; the extra contact classification is ephemeral.

## 4.36.20 — Arcana availability and sewer retreat (#33)

The author on 2026-09-27 specified that the sewer Zupay starts fleeing at
health <= 50% of CombatMaximumHealth (the existing wounded threshold). Only
MAP02's boss, TID 43799, receives this behavior. Its movement Speed becomes
three times its uninjured CombatBaseSpeed, using the normal four-tic chase
cadence and native navigation without attacks. Retreat remains latched if
health later increases. Reaching within one native movement step of the
workshop gate's contact volume, with sight and matching floor height, removes
the boss and confirms defeat. Starting retreat alone does not confirm defeat.
A lethal hit also confirms defeat. Other Zupays and siege rules are unchanged.

The Ace of Cups (persistent ID 36) is invisible, nonblocking and unusable
until confirmed sewer-boss defeat. Defeat makes the apparition available; it
does not grant ownership. Absence of an actor is never sufficient evidence.
The Spanish Fool name is **El loco**; its ID 0, quest flags and effects remain.

The Knight of Wands (**Caballero de basto**, ID 60) appears at MAP06 beside
the survivors after all extracted prisoners' rewards have actually been
delivered. Zero extracted survivors permits immediate appearance on arrival;
dead or unrescued prisoners do not block it. The existing transaction's
PrisonerRewardClaimed flag is the authority: dialogue entry/exit, partial
claims and a failed capacity check do not count as delivery. The existing
25 gold and +10 own-faction reputation rewards remain once-only. **Historical pre-siege condition: 4.36.27 replaces it with siege victory
in current MAP06; preserved legacy MAP06 retains this rule.**

All three cards share the original Fool's Use/Box identity checks, native
confirmation dialogue, 35-tic image-to-player animation, cancellation and
commit. Each supplies its own approved front, localized name and ID. Leaving
range, dying or losing/changing the Box cancels without granting or consuming
the card. Capture and revelation persist; owned cards cannot be captured
again. Existing Minor passives and collection percentages apply; no new power
is introduced.

Additive Arcana revision 1 preserves TarotOwned, MainM00FoolRevealed, quests,
Box IDs and prisoner rewards. An already owned Ace or a retained dead sewer
boss supplies legacy defeat evidence. New serialized fields retain defeat,
Minor revelation and port availability. RestoreLegacyProgress clears only
the added traveler fields for recovery on a copied save; reapplication is
idempotent and never revokes owned cards. Keep the original pre-upgrade save
for full rollback. WAD geometry and original actor state indexes are retained.

## 4.36.19 — Final siege impact balance (#21)

Author-approved on 2026-09-27 after the numerical comparison: cannon muzzle
speed is 500 m/s (457.142857143 MU/tic), inert projectile mass remains 4.3 kg,
and gate Toughness and Constitution are 50/100/200. All Caelum physical
collision reception (player, combat NPC and gate) now divides severity by
Type 4 rather than subtracting Toughness points:
D(T)=1+T*(T+1)/5050; P=max(0,S*E)/D(T).
Biological absorption precedes E; anatomy and armor follow P on biological
targets. The player preserves the existing active buckler/giant-gauntlet
effective-Toughness bonus. No second Type 4 or native armor pass is added.
Ordinary weapon reduction uses the same divisor. Pain/Lucidity curves,
native crusher damage, restitution, contact normals and momentum stay unchanged.

| Gate | Mass kg | Toughness / Constitution | Maximum resistance | Divisor |
| --- | --- | --- | --- | --- |
| Normal wood | 550 | 50 /50 | 75,625 | 1.504950495 |
| Reinforced | 650 | 100 /100 | 334,750 | 3 |
| Armored | 1,100 | 200 /200 | 2,222,000 | 8.960396040 |

Frontal stationary-target impacts; small/large ram moving masses remain
2,874.990701 /15,333.283739 kg and contact speed remains 37.780229 m/s.
Each cell is damage /percent maximum /hits to break an intact independent gate.
Integer hit counts include the existing nearest-integer damage rounding.

| Attack | Normal | Reinforced | Armored |
| --- | --- | --- | --- |
| Small ram | 53,889 /71.2579% /2 | 112,963 /33.7456% /3 | 197,380 /8.8830% /12 |
| Large ram | 71,288 /94.2647% /2 | 156,321 /46.6977% /3 | 328,626 /14.7897% /7 |
| Cannon 500 m/s | 766 /1.0125% /99 | 1,194 /0.3568% /281 | 800 /0.0360% /2,778 |

This supersedes the original small-ram immunity of armored gates and the
initial cannon zero-gate-damage result. The retained whole-body impulse rule
still makes the cannon weak against heavy gates. No penetration or explosion
is introduced. Kinetic energy at release is 537,500 J; the ideal same-height
vacuum range under default native gravity is 6,530.612 m, not a historical claim.

Gate save balance revision 1 reconciles initialized old gates on Tick or first
use/contact. It retains the fraction of resistance remaining, rounds to the
nearest health point, keeps a positive intact remainder at least 1, and preserves
opened/broken state, components, timers and contact serials. New intact gates
start at their new maximum. SetLegacyBalanceForRecovery(true) is an explicit
recovery hook that restores the old attribute/maximum-health scale proportionally;
its saved flag prevents automatic reapplication. Passing false reapplies revision 1.
It does not revert the global collision formula. Intact/partial/open/broken
old saves, repeated reconciliation, reverse/forward conversion and save/load
are validated. Previously released projectiles retain saved velocity/ownership;
500 m/s applies to new launches.

The 80 kg body plus 20 kg equipment calculation and walking-only wall
amortization remain as documented below. The changes are merged and #21/#43
closed. On 2026-09-27 the author confirmed CA-43619-BALANCE-01 and
CA-43618-WALK-01 passed; HISTORY records acceptance separately from native checks.

## 4.36.18 — Walking wall-impact absorption (#43)

The author explicitly limited the new walking benefit to walls. Grounded,
live, non-immobilized players with directional input and no native BT_RUN flag
now receive the existing careful-movement fraction, just like crouched wall
contacts: clamp(max(0, JumpZ /8 -1), 0, 0.5). Always Run is already folded into
BT_RUN by GZDoom. No input or airborne movement is not walking; existing
crouched eligibility and active buckler/giant-gauntlet behavior are preserved.
This fraction reduces impact delta-speed before energy severity. It does not
extend walking absorption to characters, rams or cannon rounds. Landing and
crushing absorption still use JumpZ, doubled by active acrobatic shield defense,
and zero when physically immobilized. No persistent fields or save schema change.

Requested calculation: 80 kg body, all attributes 20, and equipment weighing
the full medium T1 size M set (head 4 + torso 10 + arms 2 + legs 4 =20 kg).
Collision mass is 100 kg; maximum health is 2,480 because health uses body mass.
Capacity is 86.653465 kg and load ratio 0.230804388. With normal health, air and
survival states, JumpZ =8*sqrt(3.1)*(1-load ratio) =10.834469 MU/tic
(11.850200 m/s at 32 MU/m and 35 tics/s). Ordinary walking-wall absorption is
35.430863% of delta-speed at this load. These weights do not silently replace
the earlier comparison's 20% armor defense/no-reinforcement assumptions.

An isolated native same-height jump reached 64.179159 MU above its floor and
registered 11.165531 MU/tic downward before landing. Subtracting JumpZ leaves
0.331062 MU/tic, below the canonical 0.8 MU/tic severity threshold: zero damage,
with 2,480 health retained. The prediction assumes unchanged load/state through
flight and the same floor height; falling to a lower floor is a different test.
The 500 m/s cannon and Type 4 collision proposal was subsequently approved
and implemented in 4.36.19 above.

## 4.36.17 — Controlled cannon fire (#21; planned label 4.36.13)

Historical delivery baseline: speed, attributes and impact mitigation below
are superseded by 4.36.19; the 30/60-second cycle and scenario targeting
are superseded by 4.36.27 above. Other shared mechanics remain current.

The author confirmed an approximate documented reconstruction, an inert
elongated 75 mm /185 mm /4.3 kg round, two operators (load/fire), and a 30-second
complete cycle with both present, 60 seconds with one, stopped with none.
Loading and recovery accumulate work at the current staffing rate; losing an
operator preserves partial progress. Nearby crew availability is separate from
the accepted death-backed neutralization policy. Attacking operators must come
from the existing registered force; defenders use living friendly combatants.
One actor cannot serve two machines. In the eventual 18-cannon deployment,
#16 allocates 12 attacking operators from the existing 1,000 Mandingas and
24 defensive operators from its authored defending force.

`cannon_physics.json` is the authoritative input to `generate_cannon_runtime.py`.
400 m/s *32 MU/m /35 native tics/s = **365.714285714 MU/tic** for both sides.
Initial kinetic energy is 344,000 J for the approved 4.3 kg round. Calendar
acceleration does not enter ballistics. The projectile changes velocity under
native level/sector/actor gravity. GZDoom's FastProjectile supplies adaptive
collision substeps but no gravity integration; this subclass subtracts native
`GetGravity()` once per tic before native movement. At default native gravity
1 MU/tic², this is 38.28125 m/s², not Earth's standard gravity. Ideal same-height
vacuum maximum range is v²/g = 4,179.592 m at 45 degrees under that default;
actual level gravity, obstacles and firing elevation govern travel. No drag or
historical range claim is implied. The scenario supplies aim points; this is
not an autonomous target selector or automatic ballistic firing solution.

The native collision cylinder has the true 75 mm diameter (radius 1.2 MU,
height 2.4 MU); the 185 mm visual body trails its contact nose. No enlargement
or speed reduction makes the projectile easier to see. A swept bore-to-muzzle
check prevents spawning beyond an obstructing wall. At clear release, one
projectile and one brief muzzle flash appear at the pitched tube's muzzle.
The rigid carriage has a brief recoil presentation, followed by recovery and
an open sliding wedge while loading; there is no modern sliding recoil cradle.

The author initially requested defining penetration, then explicitly directed
using the same implemented collisions as characters and confirmed structural
damage with the projectile stopping. Therefore no new penetration, explosion,
energy-deposition multiplier or damage constant was introduced. Actual contact
velocity and **projectile** mass enter ImpactPhysics.ResolveBodies or the gate's
ApplySiegeImpact; neither the 850 kg approximate machine nor its carriage mass
enters impact damage. The shared solver retains its horizontal contact normal
and existing Toughness/armor/anatomy behavior. Vertical flight is native, while
character damage retains the canonical horizontal impulse semantics; this
patch does not replace the general impact or crushing solver.

For a stationary gate and a frontal 400 m/s shot, the unchanged impulse rule
produces 0.945772/0.655705/0.177173% severity for wood/reinforced/armored,
below their 46.024571/70.565111/108.052215 Toughness. Thus all three receive
**zero damage**, despite a real contact and a consumed round. Characters use
their own effective mass, Toughness, armor and contacted anatomical region.
Native missile damage is suppressed after the shared callback; one spent
flag and the gate's existing impact serial prevent duplicate contact damage.
Allied bodies obstruct a shot without taking friendly damage.

Integration API: spawn CaelumCannon and call InitializeCannon(defending) once;
register only attackers in CaelumSiegeEncounter, assign two existing actors
with AssignOperator, seal the roster, then ActivateCannon(rounds). Ammunition
is explicitly supplied by the scenario, never auto-refilled on load. Queue a
shot with RequestShot(point, intendedActor); reissuing while queued does not
overwrite the accepted aim. CancelShot clears that request before retargeting.
Defenders reject players/friendly bodies/gates as
targets; attackers reject their own combatants. Direct aim points are available
for authored scenarios. Immutable per-shot side and launcher ownership survive
operator death. Defenders cannot register as hostile objectives. Attackers
reuse #20 proximity/death tracking, victory and withdrawal unchanged.

The provisional guard radius is twice the reconstructed trail-to-muzzle span,
182.4 MU = 5.7 m, configurable per gun for playtesting. Initial empty areas,
temporary departure and missing actors do not imply enemy deaths. Neutralized
guns stop permanently without deleting released projectiles. Loaded, launch,
recovery, partial loading, staffing, ammunition, shot serial, references and
spent contacts serialize natively. One live projectile per launcher, four
spent-state tics with no debris and a 120-second abnormal-flight lifetime
bound accumulation. These are implementation bounds, not ammunition grants
or historical range measurements. Pre-feature saves opt in only when a cannon
is explicitly created; no saved actor or map is replaced.

## 4.36.16 — Mobile demonic rams (#20; planned label 4.36.12)

Historical balance: the armored immunity and subtractive mitigation below are
superseded by 4.36.19. Moving masses, contact speed and operation are retained.

The author confirmed on 2026-09-26 that operation requires all 6 small-ram or
32 large-ram operators. Partial staffing stops advance, striking and recovery;
it never awards neutralization. The author also explicitly authorized demonic
strike velocities: small rams damage wood/reinforced wood but not armored gates;
the large ram can damage all three. Historical mechanical velocities would
produce zero damage under the accepted subtractive structural Toughness rule.
No gate, player/NPC impact, crushing or resistance formula has changed.

Physical inputs are generated by `assets/generators/generate_ram_runtime.py`
from the accepted #18 geometry and `ram_physics.json`. ASSETS records sources,
construction assumptions and uncertainty. Frame/transport mass never enters a
strike. The log, solid iron head/plate, bands and wooden handles do.

| Input | Small ram | Large ram |
| --- | --- | --- |
| Operators | 6 | 32 |
| Moving assembly | 2,874.990701 kg | 15,333.283739 kg |
| Approximate machine mass, excluding crew | 5,125.636207 kg | 27,336.726436 kg |
| Geometry scale relative to #18 | 1 | (32/6)^(1/3) = 1.747160929 |
| Powered contact speed | 34.541923779 MU/tic = 37.780229133 m/s | same |
| Local guard radius, provisional | 300 MU = 9.375 m | 524.148279 MU = 16.379634 m |
| Approach speed, provisional | 0.5 m/s = 0.457142857 MU/tic | same |
| Stroke, retracted to extended | 44 MU = 1.375 m | 76.875081 MU = 2.402346 m |
| Recovery | 75 native tics = 2.142857 s | same control interval |

Metres convert at the existing 32 MU/m; physical time is 35 native tics/s,
never accelerated calendar time. The demonic velocity is the midpoint between
the small assembly's reinforced/armored onset thresholds, using the existing
Impact Physics and approved gate masses. It is not a historical measurement.
Recovery rounds up one pendulum period for the small model's 36 MU suspension
span, at standard g = 9.80665 m/s²; using that interval for both powered machines
is a reconstruction/control assumption, not a sourced historical firing rate.
Guard radius is twice each frame's length, follows its current position, and
is configurable for playtesting; it is not an author-approved radius.

The finite chassis uses native collision queries. Authored waypoints lead to
the gate, then the frame aligns to its final angle; operation requires the
full crew. Current transport supports level lanes and rejects floor-height
changes and obstacles rather than teleporting through them. #16 supplies
reachable routes, placement and operator choreography. The visible head and
its thin contact proxies advance in <=0.5 MU native TryMove substeps. Each step
uses dt = distance/contact speed, so a shorter final step does not invent a
slower impact. The front plate, not a large enclosing radius, supplies contact.
The controller serializes READY / APPROACH / STRIKE / CONTACT / RECOVERY,
stroke, component references, monotonically increasing serial and spent flag.
One physical obstruction consumes one strike, even if it causes zero damage;
the recovery stroke cannot cause another strike. Actual Head.Vel at contact
and moving-assembly mass enter the shared physics path. Gate normal components
are resolved against its plane; biological targets receive the canonical
transmitted impulse and retain their existing defenses. Save/load and repeated
initialization do not recreate components.

Observed first-impact damage against fresh stationary gates: small wood
39,800; small reinforced 52,334; small armored 0; large armored 161,271.
These are engine observations under the listed inputs, not fixed damage data.
Changing transport mass to 1,000,000 kg retained the same small-wood result.

### Encounter/control contract for #16 and #21

Create an opt-in `CaelumSiegeEncounter`. Register the existing attacking
Mandingas/Zupay through `RegisterAttacker`, each hostile machine through
`RegisterMachine`, and retain the returned records. Register the boss record
as `Boss`; defenders, player, corpses, projectiles and unrelated actors are
rejected or excluded. #16 must supply the existing 1,000 Mandingas, not spawn
62 additional campaign operators. `AssignCrew` reserves unique Mandinga records
for one machine. Set Large before the first InitializeRam call (false for a small ram), call `SetRoute(gate, finalAngle)`, append
`AddRoutePoint(position)`, then `SealRoster` and `ActivateRam`. Repeat registration
of the same actor is idempotent. Set `Enabled=false` for a reversible command
stop. Target/routing changes are rejected while striking or recovering.

Sealing a smaller roster permits an isolated lane but cannot grant port victory.
Only twelve neutralized hostile machines plus a confirmed dead registered Zupay
set `Victory` once. Cannon mechanics remain #21;
the port contract is six attacking and twelve defending cannons. Only the six
attackers register as objectives. #16 consumes the one-time victory hook and
owns rewards; this patch does not grant campaign rewards or create a director.

An armed machine remembers every registered live attacker entering its local
3D radius, with no line-of-sight condition. Overlapping areas may remember the
same enemy. A native death event is required for every remembered guard;
absence, unloading/destruction of a live actor, distance, missing operators,
or an initially empty area cannot stand in for a kill. Nearby death events
also capture enemies killed between scans. Once neutralized, the machine stops
and cannot reactivate; completed impacts/projectiles are not undone. New enemies
arriving later do not reopen that completed objective. Missing unresolved
records conservatively remain pending. A mapper must register the complete
attacking encounter roster before sealing it.

For withdrawal, assign each combatant record an `ExitNode` chain of
`CaelumSiegeRouteNode` actors, and mark its final node `IsExit=true`. Native
movement, at the actor's existing speed, follows the reachable authored route.
An obstruction stops progress; an absent route leaves the survivor in place
without attacks. Neither condition revokes earned victory. Only reaching the
exit radius at the route's height removes the survivor, without Die, a kill,
loot or kill-dependent reward. Fleeing, exited, dead, neutralized and victory
records use native serialization. Existing saves default to no encounter and
no actor conversion; there is no destructive migration. Pre-feature saves can
retain their old EventHandler list, so registered actors also confirm death
after native Die through the same idempotent receiver. This preserves old-save
neutralization without polling health or treating missing actors as deaths.

## 4.36.15 — Breakable actor gates (#19; planned label 4.36.11)

Historical delivery baseline: speed, attributes and impact mitigation below
are superseded by 4.36.19; the 30/60-second cycle and scenario targeting
are superseded by 4.36.27 above. Other shared mechanics remain current.

The author's 2026-09-26 clarification defines the issue's 0.3/0.5/0.7 as
ordinary weapon damage reductions of 30%/50%/70%. Invert the existing Type 4
curve rather than assigning attributes 30/50/70. Constitution equals the
resulting Toughness, including fractional levels and the armored value above
100. The author approved the proposed moving masses; each health pool covers
both leaves together. The accepted 3 x 3 m visual opening remains 96 x 96 MU,
with an 80 mm wood core (2.56 MU); this is the #18 reference geometry.

| Material | Reduction | Toughness = Constitution (approximate) | Moving mass, both leaves | Maximum health |
| --- | --- | --- | --- | --- |
| Plain wood | 30% | 46.024571081 | 550 kg | 65,017 |
| Reinforced wood | 50% | 70.565110990 | 650 kg | 170,625 |
| Armored wood | 70% | 108.052214779 | 1,100 kg | 659,083 |

The attributes are computed without rounding: D = (sqrt(1 + 20200*r/(1-r))-1)/2.
Health reuses floor(10 * [100 + C*(C+1)/2] * mass/100), with the existing
minimum of 1. Weapon hits round retained damage using the existing minimum
positive damage rule. Native projectile DoSpecialDamage runs before this
reduction. Gate blockers represent one shared health pool; large weapon
sweeps hit that pool once, and one explosion uses its strongest blocker
sample rather than summing samples. Gates have no humanoid anatomical weak
points, armor layers, regeneration, loot or additional material multipliers.

Physical siege impacts retain the separate canonical Impact Physics path:
ResolveExternal uses moving-assembly mass, actual contact velocity in MU/tic
and the contact normal. Damage is round(Hmax * max(0, E - D)/100), with neutral
surface/contact factors. Type 4 is not applied again. The caller supplies a
nonnegative monotonically increasing impact serial per moving source; repeated
or older serials cannot deal damage again. Neither frame mass nor a fixed
damage/forced-destruction shortcut replaces that calculation. #20/#21 still
own actual ram/cannon operation and high-speed projectile contact detection.

The author's 2026-09-26 follow-up identified a missing native body-collision
connection. CaelumGateBlocker.CollidedWith now forwards player/NPC contact to
the whole gate. ResolveBodies uses the character's effective mass and actual
velocity, the complete gate mass, and the gate plane normal. The character
receives SourceDeltaSpeed through its existing ReceiveCaelumImpact defenses;
the gate receives TargetEnergyPercent through the same structural conversion
used by siege impacts, including the existing body surface multiplier. The gate
remains anchored. A shared whole-gate ImpactContactState rejects repeated block
callbacks until canonical separation/rearm, and survives save/load. Opening or
destruction disables this route. Low-energy contact can still cause zero damage;
no new damage floor, mass, resistance, speed or threshold was introduced.

CaelumBreakableGate is explicitly opted into by spawning it; no old door is
converted. args[0] is a positive linked group (zero means independent),
args[1] selects material 0/1/2, args[2] enables ordinary Use, and args[3]
selects an existing LOCKDEFS key. AccessCondition reuses faction requirements.
Every group member must allow access. Use opens both visible leaves and all
linked blockers; the existing 105-tic door hold is reused. A solid actor in
any member's passage prevents group closure. The first actual health loss
selects Damaged; zero health selects Broken and clears every linked blocker
once. Repeated damage/death is inert. The open visual is the accepted Broken
pose, reused for temporary opening; closing restores intact/damaged appearance.

Health, group state, counters, blocker references and impact identities use
native actor serialization and hub snapshots. Existing schemas and WADs are
unchanged; an old 4.36.14a save loaded and activated the optional trial without
duplication. Native evidence: assets/validation_43615. The author confirmed all tests passed
on 2026-09-26 (CA-43611-GATES-01), including the corrected body-collision path.
HISTORY records acceptance; the historical test ID is intentionally preserved.

## 4.36.14a — Distinct siege materials and visual states (#18 correction)

Gate material and gate state are independent: wood, reinforced wood and
iron-clad armor each have intact, damaged and open previews. MODELDEF no longer
overlays the closed model on the open pose. Preview actors remain nonblocking
in every state; usable/damageable campaign doors remain #19. The issue already
specifies hardness 0.3/0.5/0.7; this art correction does not assign those values,
infer health or invent mass, damage, reload timing or resistance multipliers.
The author-approved gallery cleanup disables table/chair/bed/station trial
placement only in MAP03 and removes saved instances there. Tables release their
stored consumables as pickups; portable sleeping bags and unrelated travel,
storage and hazard actors are outside this cleanup. MAP02/MAP06 facilities are
preserved. No crafting recipe or siege combat rule changes.

## 4.36.10 — Siege assets are visual-only (#18)

Issue #18 introduces reusable cannon, battering-ram and destructible-gate
models and their MAP03 preview gallery. These are rendering assets only: no
cannon damage, ram strike, gate hardness, mass, reload time, ammunition, recipe,
economy rule or player interaction is added. The preview actors do not block the
player and cannot be used, damaged or opened. The future siege rules remain
owned by issues #19-#21 and will be documented here when their values are
defined.
## 4.36.8 — Prisoner rescue, escort and port rewards (#14)

Each reserved MAP02 cell now offers release through a prisoner conversation; the
freed actor becomes friendly, stops counting as a kill, follows the player and
fights using the source mansion character's exact combat profile. It stays back
from the northern Zupay and is extracted alive only at the pre-boss reservation
before that fight; killing the boss is not required, and a follower that dies
before extraction is not rescued. Persistent per-prisoner state survives save,
load and travel; extracted prisoners appear once at the MAP06 port, where their
own-faction thanks grant +10 reputation and 25 gold coins (1,000,000 copper)
exactly once, independent of character size. A failed coin delivery is retryable
without duplicate money or reputation. The six canonical factions replace the
former provisional domains: Unitarians=0, Federals=1, Free Peoples=2,
Caelith=3, Cult of the Tarot=4 and Sun Warriors=5.

## 4.36.7 — Inert prisoner appearances (#13)

The four reserved MAP02 cells now contain one prisoner actor each. These actors
are visual/identity placeholders for #14: they use the source character's exact
combat profile and recolored poses, but in the cell they are friendly,
invulnerable, do not count as kills, keep the accepted A/B idle breathing
poses without entering the walking/chase animation, and do not chase or
inherit mansion anchoring/quest behavior. Their persistent identity is the map thing/class,
not the provisional display name.

The MAP01 mansion residents and Palomo keep their story anchoring and separate
walk/run states, and their idle alternates the accepted monster idle A and B
poses. Conversations remain unpaused: MAPINFO keeps
`UnFreezeSinglePlayerConversations` and the common menu omits the delayed pause
of `ConversationMenu.Ticker`.

The display names are author-authorized working names: Leonor Benítez
(Caella/Unitarians), Rufino Acosta (Ronnie/Federals), Santos Barrera
(Rulo/Free Peoples) and Leandro Farías (Argento/Cult of the Tarot). These are
fictional names, not historical people; no military rank, army size, combat
bonus, formal alliance, betrayal detail or capture sequence is established here.
Rescue, escort, dialogue and rewards remain #14.

## 4.36.6 — Hostile sewer rats (#12)

Revision-2 MAP02 keeps its four keyed sections and existing contents, and adds
two hostile rats per Mandinga: 192 rats against the retained 96 Mandingas and
one Zupay (a fixed 2:1 ratio, 24 Mandingas / 48 rats per section). Rats reuse
the accepted `CaelumGiantRat` actor (DoomEdNum 18029) and RATG sprites; no new
damage, health, AI, art or balance value is introduced.

Each Mandinga junction gains two fixed dry-walkway placements, written
deterministically by the generator and recorded per section in the manifest.
Rats are initial placements only and never respawn or resurrect, preserving the
ratio throughout the map. The historical 0i `MAP02 and rewards` table below is
unchanged and continues to describe that release.

## 4.36.5 — Sewer gates, refuges and known-recipe repair (#11)

Revision-2 MAP02 uses four 5×5 junction networks. Section keys retain native
locks 203/204/205; the northern arena uses 206. Independent cell keys use
207–210. Keys are not consumed. Barred gates retain native movement, Use,
hitscan and projectile blocking while closed, but permit sight through their
transparent existing texture. Unlocking permanently removes the barrier; there
is no auto-close collision with future followers. Refuge gates need no key.

Each cell contains an existing usable bed and a reserved prisoner marker.
Routes from all cells join the extraction marker before the northern boss
door. This marker grants no rescue, reward or player travel shortcut. #14 owns
live escort/four-companion combat and backtracking tests; width alone is not
evidence that its future AI works.

The minimum T1 repair network comprises workbench, forge, ranged workshop and
essence altar, connected using the existing station-range rules. Four alcoves
contain that network; original entrance infrastructure is preserved/repositioned.
The alcoves contain no placed enemies or traps, but do not grant invulnerability
or suppress normal combat/rest guards. Existing time-advance zones cover the
relocated arrival furniture/workshops, four refuges and four cell beds; all
normal threat, rest and fast-time restrictions remain. Existing materials come from finite
salvage; no new allowance, raw-material spawn or recipe source is introduced.

The author clarified during implementation that only a known final weapon recipe
permits repair. Physical type and magical essence must match the known recipe.
Possessing components alone does not bypass that requirement. Rejection occurs
before reservation, wear or inventory changes; existing paid repair times/costs
and dismantling rules remain. Other weapons can wear out and break normally.

Geometry changes cannot load into an old GZDoom snapshot: the engine verifies
map geometry before restoring ZScript. `-LegacyMap02` selects the checksum-verified
original WAD under the same MAP02 and package names. This revisioned compatibility
mode preserves old progression exactly and is reversible by rebuilding the normal
package; retain it whenever loading a campaign that visited the old maze. It does
not reset/repopulate or silently convert an old map into the new four sections.

### Key dependency graph and ordinary-player route

Start → southern key 203 → western key 204 → eastern key 205 → northern
key 206 → Zupay arena → defeat boss → Ace of Cups → existing player exits.
Cell keys 207–210 are reachable in their own sections, outside the cells.
All four cell branches return to the same pre-boss extraction point; none
requires crossing the boss door. Refuge gates are unkeyed branches.

| Section | Progression key (x,y) | Cell key (x,y) | Cell/bed center |
| --- | --- | --- | --- |
| south | (1280, 1536) | (1792, 2304) | (2560, 3840) / (2464, 3680) |
| west | (1280, 4864) | (1792, 5632) | (2560, 7936) / (2464, 7776) |
| east | (-1792, 12032) | (1792, 11264) | (2560, 12032) / (2464, 11872) |
| north | (-1024, 13824) | (-512, 13056) | (2560, 16128) / (2464, 15968) |

Extraction reservation: `(896, 16896)`; northern boss center: `(1536, 18304)`.
Walk the maze branches to obtain each key, open its corresponding gate with Use,
and return from cells along the opened route. No debug command, jump shortcut
or sewage-damage exception is part of this route. The manifest records every
edge, chest, provision/ammunition bundle, trap and gate; the independent validator
searches actual generated floor cells with maximum-body clearance and closed
barriers, rather than trusting the logical generator graph.

## 4.36.4 — Acquisition and chest contract (issue #10)

MAP02 supplies only Tier 1 equipment: exactly 65 distinct combinations, retaining
all four armor types in all four slots, all 20 weapon families and their existing
essence variants (36 weapon entries), four shields, four amulets and five seals.
Fresh maps distribute 26 two-item and 13 one-item chests over the existing 39
locations. The accepted 120 food/120 water rations, repair rules and other map
contents remain unchanged. The historical 0i table below describes that release.

New natural world equipment and equipment rewards use CHARACTER_DEFAULT for
weapons, armor and shields. The recipient's CharacterProfile is mapped by
GetDefaultSizeForCharacterTier: body tiers 1–2 -> XS, 3–5 -> M, 6 -> L, 7 -> XL.
The existing mapping intentionally has no default S branch. Amulets, seals,
provisions, keys and money retain their existing nonsized rules. The policy is
separate from resolved EquipmentSize: editor size argument zero still defaults
to M; the resolved EquipmentSize enum is unchanged (its zero value means XS).
Weight, maximum durability and economy valuation use the existing rules for
the resolved tier/size; no balance formula or crafting/merchant sizing changes.

Resolution commits only with successful transfer. A preview or capacity failure
cannot reserve a shared item for one character. The actual recipient is checked
again at collection. Once acquired, identity, size and condition persist through
drop/re-pickup, transfer, saves and travel; imported/owned T2/T3 remain intact.
Migration is revisioned and idempotent. Old saved chests retain their original
T1 slots and looted gaps, without replenishment; unclaimed T2/T3 are retained in
a separate migration backup rather than offered as loot. Fresh-map distribution
does not retroactively fill an existing map.

First Use opens a Spanish preview of actual remaining chest entries, including
names/quantities and applicable tier, recipient size and essence. Explicit
collection uses the same inventory references, revalidates current contents and
capacity, and shows what remains; cancel transfers nothing. Empty chests say so.
Concurrent users share one stock and do not receive per-player duplicates.
Confirming collection returns to the HUD so acquisition/capacity notices remain
readable; Use again previews the current remaining contents or explicit empty state.

Successful acquisition notices identify the actual item and received quantity.
Failed transfers announce no success; a chest identifies each successful item.
The top-left gameplay feed holds at most 20 entries in chronological order;
the 21st evicts the oldest. Each expires independently. The initial duration is
eight seconds, configurable through one project CVar for author adjustment.
Debug reports and full NPC conversations remain outside this feed.
Native evidence and the exact authoring API are recorded with this delivery;
The author confirmed CA-4364-T1-LOOT-01 passed on 2026-09-23; HISTORY records
the acceptance separately from native/static verification.

## 4.36.2 — Bow presentation performance

Issue #8 caches the existing crop-only bow-stave composition; native color
effects and A/B/C presentation remain unchanged. This changes no ammunition,
magazine capacity, reload time, damage, controls or persistent schema. Empty
bows still hide the arrow; loaded bows show it. Evidence and the author's
2026-09-23 pass confirmation for CA-4362-BOW-EMPTY-01 are in HISTORY. Environmental scope follows PROJECT: the existing
ceiling/elevator cover moving sectors; avalanches and damaging surfaces are
future work and no longer block 4.36. No new hazard is implemented here.

## 4.36.1 — Documentation scope

Issue [#6](https://github.com/damiancurti/Caelum-Argenteum/issues/6) translates
the maintained specification into English. All rules, formulas, constants,
units and accepted decisions retain their prior meaning. Formula identifiers,
code examples, proper names and literal localized game text retain their
original spelling; game localization and runtime behavior are unchanged.

Release-specific sections preserve the state at their original date. Current
author checks live in [pending_test.txt](../pending_test.txt); recorded results
are in [HISTORY](HISTORY.md). This documentation patch does not constitute a
new engine test or automatic author acceptance of the retained 4.36.0i systems.
Actual author confirmation received on 2026-09-23 is recorded in HISTORY:
maze, save/load and tables passed; flail pose remains partial and an empty-bow
equip stall is reported. Corrections #8/#9 are planned, not implemented here.

## 4.36.0i — active rules and maze

### Resting weight: approved and active formula

    exceso = max(0, (M_encima + M_carga) / C - 1)
    daño_por_segundo = H_max * 0.10 * exceso

M_encima is the actual mass transmitted by bodies on the victim, including the bodies
stacked above them. For players it includes body mass and inventory; for NPCs, Mass and
their armor. M_carga is the victim’s own load. C is the current capacity (player:
CarryCapacity; NPC: Mass × Tipo4(Fuerza)/100). All masses are expressed in kg. Without
external mass or a positive capacity, the system causes no damage.

Solids without noclip, vertical contact ±0,5 MU, XY overlap, near zero vertical speed
and native bOnMobj are required. A body with NOGRAVITY does not transmit weight. The
search uses the local blockmap and strictly increasing Z. Each level distributes its
weight and that received between its supports; it does not duplicate mass through
stacking. Loads at 150%, 200% and 300% of capacity produce 5%, 10% and 20% of Hmax/s.
The first support tic only records contact to separate the initial impact. From the next
tic, daño/35 accumulates, retaining the fractional remainder. Removing the mass stops
the damage. CaelumWeight passes through DamageMobj with DMG_NO_ARMOR, with environmental
pain/interruptions and without Adrenaline gain. The existing kinematic impact and the
ceiling’s percentage conversion retain their own paths.

### Food, water and tables

The mass used for needs is body mass, excluding load. Each food ration weighs 0,2 kg.
Water: 0,2 L =0,2 kg per ration, also in inventory, the Box and purchases. Per pulse:
food =80/M; water =400×L/M percentage points. There are ten pulses per serving.
Therefore, 2 kg or 2 L produce 100 points for 80 kg; a different body mass requires
2×M/80 kg or liters. This is gross recovery: needs consumed between portions are
calculated separately. The bottles use the same factor; normal sip M/400 L and real
fractions. Digestion preserves Sleep -= hunger effectively recovered/4.

SeedMansionFood uses Capacity, not SeatCount. Six tables, 94 slots: 4×4+18+60.
MansionFullFoodPrepared records a one-time allocation. Existing food is counted and
other belongings are preserved; if there are no free slots, the remaining allocation is
cancelled. Removing food, eating it or returning to the map does not replenish the
allocation. The objects are real CaelumFoodRation instances owned by the table and
represented by plates.

### MAP02 and rewards

Reproducible UDMF geometry: three 7×7 mazes with branches and loops, native doors
203/204/205 and gate/crypt/sanctuary keys. Each key precedes its door; no connection
between sectors bypasses it. Pits 96 MU deep have six 16 MU steps for walking out.

| Initial contents | Count |
| --- | ---: |
| Labyrinth rooms | 147 |
| Mandingas / Zupay | 96 / 1 |
| Mines / teleports / ceilings | 12 / 6 / 9 |
| Rolling rocks / vertical rocks / pits | 6 / 6 / 6 |
| Chests / equipment items | 39 / 195 |
| Armor / weapons / shields / necklaces / seals | 48 / 108 / 12 / 12 / 15 |
| Food/water rations | 120 / 120 |

Equipment: all four pieces of the four armor families, the 20 families of weapons (five
essences for each of the four magical families), four shields, four necklaces and five
seals, in T1/T2/T3. Size M, initial native durability. Each sector contains its tier.
Supplies are in 24 pairs of five-unit stacks. Enemy profiles and equipment balance are
unchanged. Rolling rocks use 32 MU/tic and existing physics; ceilings retain 10% of Hmax
by native pulse and 8 MU/tic speed, each in its own sector.

CaelumMazeChest retains five real Inventory instances. First Use opens; second removes
by CallTryPickup. What does not fit remains in the chest. Its pointers, opening state
and allocation are serialized; it does not replenish or regenerate delivered items. Keys
follow the native inventory/weight rules and are not consumed.

Zupay: CaelumZupayColossus, TID 43799. The Ace (1) of Cups is TarotOwned[36]: +1 to
Charisma/Empathy/Eloquence before the +1% collection. It is only captured after beating
the Zupay and a second capture does not accumulate anything. It uses the CTAR back, the
existing reveal/capture audio and the Journal; no frontal art is added. The essence
disappears only after joining the collection.

CanDepart validates Zupay and card for every MAP02 exit. Connection 14 leads to the
MAP07 coast; 15 returns to the final chamber (PlayerStart 1). Arrival from MAP01 uses
PlayerStart 0 in the southern lobby and retains the Voice of the prologue. The journey
reuses the hub without reset of equipment, health or content. Old accesses to
MAP03/04/05 are located in the final chamber, under the same condition.
Furniture/provisions from old tests are not injected into the maze.

### Check

The GZDoom 4.14.2 report validates ZScript, actual opening/withdrawal, keys, door
movement, card, shared masses, dose and 94 rations in MAP01. The harness explicitly
advances food pulses and damage tics; the bOnMobj support was also observed during real
simulation. The animation test recorded 17,424612° →377,424612° in eight steps, complete
turn. The content validator checks 207 catalog conditions, connectivity, keys, pits and
FP layers. It does not replace a human playthrough or validate Windows.

## History 4.36.0h — percentage ceiling, starting meal and weight proposal

### Native ceiling: implemented in source

P_DoCrunch in GZDoom g4.14.2 calls damage with type Crush and null source/inflictor. It
applies a pulse when (maptime & 3)==0, while crushing exists. CaelumPlayer and
CaelumCombatActor convert that value once:

    D_pulso = redondear(H_max × valor_nativo / 100)

The current value of MAP08 is 10: it is equivalent to 10% maximum health per pulse, not
per second. Examples without native modifiers: Hmax=100 → 10; Hmax=1780 → 178;
Hmax=107060 → 10706. The rhythm of four tics is kept by the engine; no one-second timer
is introduced.

The damage continues by Super.DamageMobj with DMG_NO_ARMOR and retains pain,
interruptions and absence of environmental Adrenaline gain. Native modifiers and immunities
continue to apply. Drowning and CaelumImpact are not scaled; the Crush sources with
explicit actor retain their previous units.

CaelumCrushingDamage.FromNativePercent preserves non-positive values and special
commands >=1000000. Normal pulses are limited to 999999 points so as not to accidentally
activate the GZDoom telefrag semantics when scaling extreme health values. This limit of
interoperability is not reached in the example of the character in the screenshot. The
value of the trap or its map is not changed.

### Supported mass: proposal pending the author's decision

The search recovered an impact formula and a contact formula with sustained impulse. The
latter requires positive closing speed; it does not represent the weight of an already
still body. No approved static formula was found.

Game rule proposal, NOT implemented in 4.36.0h:

    r = max(0, (M_encima + M_carga) / C - 1)
    daño_por_segundo = H_max × k × r
    k propuesto = 0.10

M_encima: mass effectively transmitted by bodies resting on the victim, including those
resting on them. M_carga: own load already calculated by inventory/equipment and the
Box. C: current carrying capacity, using the same units of mass. Hmax: maximum health,
to maintain relative severity across characters with different health. Positive C is
needed.

| Total external mass / capacity | Excess r | Proposed damage / second |
| --- | --- | --- |
| 100% or less | 0 | 0% of Hmax |
| 150% | 0.5 | 5% of Hmax |
| 200% | 1 | 10% of Hmax |
| 300% | 2 | 20% of Hmax |

The proposal requires real support contact: a rock hanging on the head does not count.
Removing it stops the damage. Stacked masses accumulate only once; if a body has
multiple supports, its load is distributed without multiplying. Landing retains its
single impact, separately from subsequent static damage. The application uses simulation
time and retains fractions to prevent truncation of small damage. It is not activated
until the formula/coefficient is approved.

The selection of capacity as a threshold and k=0.10 is a new proposal, not a value
recovered from previous decisions. It is subject to the authorial premise of not
incorporating balance numbers without agreeing on them with the creator.

### Table food: persistent initialization

Each MAP01 CaelumDiningTable calculates SeatCount minus existing rations once and
records MansionFoodPrepared/MansionFoodToSeed. It creates that amount as actual
CaelumFoodRation, Count=1 and Owner=table. RefreshDisplays uses existing dishes. Current
tables add up to 4×2 + 6 + 12 = 26 seats.

The state per actor covers tables already saved, even if the furniture controller is
already prepared. Consuming/removing food does not increase the remaining allocation. A
creation failure tries only the outstanding balance. A full table preserves all its
objects and cancels the assignment that does not fit: it does not wait for a free slot
to replenish it later. It delivers no food outside MAP01.

Inventory/Box deposit, withdrawal, digestion and reservation routes do not change. No
periodic replacement or initial drink is added.

Technical references: official sources g4.14.2 of
[P_DoCrunch](https://github.com/ZDoom/gzdoom/blob/g4.14.2/src/playsim/p_map.cpp) and
[DamageMobj](https://github.com/ZDoom/gzdoom/blob/g4.14.2/src/playsim/p_interaction.cpp).
Local test models do not replace actual start-up, inventory and save in GZDoom.

## 4.36.0g — segmented presentation and axe attack

The documented catalog defines the axe with a slashing primary attack and a stronger
blunt secondary attack with shorter range. CaelumAxeSelectorWeapon retains the shared
physical path and the player consults GetSecondaryDamage and GetSecondaryDamageType.
This delta does not alter those callbacks or introduce damage or reach values. The full
catalog source is not among the recovered files; the documentation is not presented as
an executed damage test in GZDoom.

The visual dimensions are independent of the impact range. In CaelumFirstPersonLayers,
the new parts use 48 (handle/shaft), 50 (head), 51 (left hand) and 52 (right). The axe
head scales ×1.5 at its junction (77,118), while the handle retains its scale. In the
halberd:

    g = (85,150); j = (76,104); a = (j-g)/|j-g|; k = 1.8
    delta(p) = (k-1) * dot(p-g,a) * a
    headPosition = weaponGrip + Turn((j-g) * size * k, rotation)

Coord0–Coord3 receive delta in the four corners of the canvas of the handle. This
retains the transverse width and grip position. The blade and its ribbons are moved as a
rigid piece, without the axial stretching. Narrow cuts exclude the straps of the
extended handle. The halberd’s resting rotation remains at −28°; the flail’s changes to
+28°.

Bows: 46/47 string, 49 full hand and index finger, 50 wood, 51 DH12 (thumb +
middle/ring/little finger phalanges), 52 right hand, 53 arrow. DH12 shares canvas,
offset, pivot and scale with DH03; cuts return to their original coordinates. Cleanup is
preserved when changing weapons.

The palettes use two nested native Graphics. Translation Desaturate mixes gray at n/31
(greatsword 20; bows 24). Then Blend without alpha modulates RGB by (205,198,188)/255 in
the greatsword and (194,186,174)/255 in the bows. Two steps prevent Blend from replacing
Translation within the same Patch. The icons of the greatsword are displayed with
Graphics that preserve public routes; identical sources with different names avoid
self-reference.

The implementation and assumptions were checked against the source code of the renderer,
texturemanager, multipatchtexturebuilder and bitmap of GZDoom g4.14.2. The
VALIDATION.json report separates local verifications from the engine tests, which are
still pending.

## 4.36.0f — audit of crushing and impact

There are three different mechanisms. The rock applies kinetic damage when colliding,
including vertical reception by landing. The character contact graph can apply periodic
damage when it continues to transmit momentum. The CaelumCrusherTrap ceiling uses native
GZDoom crushing. There is no continuous damage due to the mere weight of a rock that was
already immobile above a character. This latter limitation is still pending; it is not a
mass failure or instant death rule.

### 1. Rock collision: mass, impulse and speed received

Implementation: src/impactphysics/ImpactPhysics.zs, ResolveBodies and
ResolveVerticalBodies; reception in CaelumPlayer and CaelumCombatActor.

- Horizontal closing speed: v=max(0,(vs−vt)·n), with n unit.
- During a fall: v=max(0,vt.z−vs.z).
- J=(1+e)v/(1/ms+1/mt); e=0 in Caelum.
- Δvt=J/mt=ms/(ms+mt)·v. Δvs=J/ms.

ms is the effective mass of the source; mt that of the receiver. The expanded rock uses
radius 48 MU, height 96 MU and mass 38170 kg, calculated as a granite sphere 3 m in
diameter at 2700 kg/m³ and 32 MU/m. The large mass makes Δvt approach v; does not
multiply damage indefinitely by 38170.

### 2. Damage conversion

u is Δv after applicable damping. In an environmental player collision without active
acrobatic defense, u=Δv. The buckler/gauntlets can reduce it; damping for a fall onto
the ground follows another path. Do not confuse a rock falling onto the head with the
character's own landing.

t=28/u; if u≈0, a very large time is used. E=0 if t≥35. Otherwise:

    E = 100 · ((35/t)² − 1) / (35² − 1)
      = 100 · (u² − 0,64) / 783,36

E is a reference percentage, not physical energy in joules. Its undamaged threshold is
u≤0,8 MU/tic; u=28 produces E=100%. It is not limited to 100%. The height of the
character no longer alters the reference of 28 MU.

    P = max(0, S·E - (T*T+25*T)/125)  [uncapped growth restored in #52, 2026-09-28]
    W = suma_i [ wi · Vi · (1−Ai) ]
    Daño = floor(Hmax · P · W / 100 + 0,5)

S is the surface multiplier (rock: 1); T is the effective Toughness attribute level;
Hmax is maximum health, not remaining health. wi weights anatomical overlap; Vi is
vulnerability after reinforcement and Ai is the defense of the corresponding piece,
between 0 and 1. Vi can be 2, 1,6, 1,3, 1, 0,8, 0,6 or 0,4. The vertical impact of the
rock has contact in relative height 1,0. The final damage uses CaelumImpact and avoids a
second armor application.

Calculated example, not an in-game test: ms=38170 kg, mt=75 kg, Hmax=1780, T=13, S=1,
W=1, without damping. The receiver is initially stationary.

| Closing speed (MU/tic) | Received Δv | E (%) | Rounded damage |
| --- | --- | --- | --- |
| 8 | 7.984 | 8.06 | 138 |
| 16 | 15.969 | 32.47 | 558 |
| 24 | 23.953 | 73.16 | 1257 |
| 32 | 31.937 | 130.13 | 2236 |

Actual health, armor, anatomy, relative motion, and acrobatic defense can change the
result. It is not guaranteed to kill any character.

### 3. Sustained contact and native ceiling

The graph uses Jp=v/(1/ms+1/mt) to transmit the inelastic impulse and avoid duplicating
it in callbacks of the same pair/tic. RegisterSustainedTransfer triggers reception every
35 tics with a recorded transfer. The pulse uses the last Jp, not a sum of 35 impulses:

    veq=Jp·(1/ms+1/mt)

ResolveBodies retrieves Δv; IMPACT_KIND_CRUSH subtracts biological landing damping and
uses the same curve E, hardness and anatomy. Without positive closing speed, no new
pressure is recorded. This mechanism does not calculate static force mg, contact area or
pressure F/A.

CaelumCrusherTrap calls Level.CreateCeiling with ceilCrushRaiseAndStay and crushDoom. In
MAP08: speed 8 MU/tic, minimum height 8 MU and native damage args[0]=10 per pulse. That
damage is NOT obtained from the previous impulse formulas; it enters as Crush by the
native environmental path.

### 4. MAP08 fast rock in 0f

TID 43602 changes its horizontal initial thrust from 8 to 32 MU/tic: 1120 MU/s,
equivalent to 35 m/s with the 32 MU/m scale of the resource. It is a test value of this
trap, not a global impact modification. It has no motor that replenishes speed, telefrag
or minimal lethal damage.

The WAD and its generator contain 32. GetReleaseSpeed recognizes the 8 value of the
original TID in an old save and uses 32 in the next release. It does not change the
speed of an already released rock. Other explicit maps/TIDs/values are preserved. The
vertical rock TID 43603 keeps falling.

The ca_debug_hazards_report report shows the configured release speed, current speed, mass,
impulse and damage of the player. It allows to distinguish no contact, E cancelled by
Hardness and subsequent reduction from anatomy/armor.

### 5. Presentation of weapons

Turn corrected with 4.14.2 renderer; NoTrim and absolute pivots. The string is drawn by
vertices and the arrow uses 53 layer. Bow order: 46–47 string, fingers 49, limb 50, 51
thumb, right 52 and 53 arrow. The state of ammunition and shooting callbacks continue to
determine the presence of the arrow. See ASSETS.md and PRUEBAS_4_36_0f.txt. GZDoom was
not executed in this session.

## 4.36.0e — corrections requested after testing 0d

[IMPLEMENTED] Fists with continuous forearms and the same glove of the other weapons;
left and right come from the same original PNG, reflected by TEXTURES. The original set
of hands is also used for both bows. The left is in a layer in front of the right. Glove
sizes independent of the size of the weapon.

[IMPLEMENTED] Hatchet, axe, war axe and halberd tilted to the right with the handle
seated on the grip. +20% sword and greatsword +15% relative to 0d. Standard recurve bow
and longbow with continuous limbs, both in T1–T3, with a string between the tips and
hand, and visible arrow only if loaded.

[IMPLEMENTED] MAP01's trimmed chord at the first revelation of the arcane. An original
level-up sound plays on confirming capture and applying the bonus. [CONFIRMED BY THE
AUTHOR] Correct 0d transitions; its logic is preserved.

[IMPLEMENTED] Cart with front axle and two front wheels: four wheels in total. On the
boat, volume of Use not solid in front of the hull, in addition to the sign; the warning
remains centered and retains the requirements of boarding. New parts are added once when
preparing vehicles, also when loading.

[VERIFIED LOCALLY] Structure of changed sources and resources, references, layers, OBJ
geometry and reconstructed weapon/model views. GZDoom was not run for 0e: the complete
baseline had not been recovered and no engine was installed. Changed files start from
their latest recovered versions. [PENDING] Compilation and gameplay/visual testing in
GZDoom 4.14.2 / Windows 11. Instructions: PRUEBAS_4_36_0e.txt. The following sections
are historical.

## Current corrections 4.36.0d

First person: Corrected families use CaelumFirstPersonLayerFrames, new class with
Weapon/Overlay states, and 48–52 layers. TEXTURES reverses the weapon and defines its
grip point without inverting the hands. crossbow/carbine support layers go behind the
weapon; in bows, the dorsal left passes in front. A common transformation holds together
weapon and grips during the attack. Creating a layer initializes its previous position
to prevent interpolation from the source; bow hands are not recreated each tic.

The sword now uses the same view of small hands as the other families. Its old states
remain in the same order to load saves; its visual callbacks remove the old rig and the
HUD uses the common blocking presentation. They do not alter callbacks of damage,
shield, Air, Anima, durability, ammunition or times. Dagger and magic retain their
compositions.

Holstering applies X = -0,85 × native descent, in addition to the Y descent. During the
descent the outgoing family is retained even if the selection of the HUD changes. The
carbine displays B only during real recoil, C during reload and A at rest, also empty.
This supersedes the historical 0c row that assigned B to the empty weapon.

Fists: CaelumUnarmedWeapon derives from Weapon and has its own TNT1 states and layers of
two closed fists. It alternates right/left; retains the previous 22-tic fallback, random
native 2–20 damage, range and PowerStrength factor. It does not use sprites, visible
puffs or Doom sounds; does not add new impact sound. It is not a new piece of RPG
inventory nor does it change its catalog. EnsureUnarmedFallback supplies the fallback
when missing, removes legacy Fist and selects it if there is no usable equipped weapon.
The Limbo narrative cleanup retains its reach and restores the fists upon arrival at
MAP02.

Interaction hints: CaelumInteractionHint calculates a reading label in the world using
reach, orientation and CheckSight. It resolves the auxiliary collider to the actual
vehicle or table and respects CanBoard/CanReach. HUDInteractionHint draws it without
activating Use or opening menus. Tables, chairs/beds and vehicles use 'Use:'; pressure
plates indicate “Step on”. Looking away or moving out of reach hides the hint. Falling
carbine ammunition normalizes its scale to 0,10 in Tick, without changing mass, units or
inventory icons.

| Confirmed travel | Effect | Existing clip |
| --- | --- | --- |
| MODE_CART and MODE_CARAVAN | Native crossfade, 3 | caelum/travel/carriage |
| MODE_SHIP | Native melt, 1 | caelum/travel/ship |
| El Loco | Native burn, 2 | caelum/ui/map_transition |

Hub transitions: NoWipe in g4.14.2 blocks 35 frames after ChangeLevel. CaelumMenuAudio
prepares CAJVIEW near boarding and during the quotation/dialogue, suspends capture on
departure and preserves that view during the first 35 arrival frames. It then requests
the native wipe to blend distinct departure and arrival views. CAJVIEW uses 960×540 with
aspect adjustment for the screen. The camera is invisible and non-interactive. Audio
starts after channel cleanup. Neither wipetype, hub membership, clock, consumption nor
travel confirmation is modified. Saving/loading discards the pending presentation. A
console map change is not equivalent to confirming a trip. Local verification is
single-player; it does not establish additional co-op validation.

MAP08 Gallery: CaelumHazardGallery.Prepare adds a reset lever to (1088,1088,0), TID
43620, and an arrival rune to (1152,1664,0.5). MagicHazardRevision=2 allows you to
incorporate them into previous saves without duplicating actors or automatically
rearming what was already used. Mechanism 4 remains the reusable plate in
(2048,640,0.5), TID 43611; preserves free destination, rejection without telefrag and 35
tics protection. A correct activation confirms the arrival with message and blue flash
of 12 tics.

CaelumHazardResetSwitch first checks occupancy and moving ceilings. If it fails, explain
the cause without partially modifying the gallery. If applicable, closes the pit lid,
restores its cover, stops and repositions the rocks in their initial positions, rearms
the mine/plates/crusher and raises its levers. The lever itself lowers a second and
becomes available again. The lid and the queried mechanism's own rocks are excluded from
the occupancy query to allow repeated cycles. Historical counters are retained and
ResetCount is added. The large mass of 38170 kg and the damage formulas remain
unchanged.

The sections by lower versions retain the previous record; the grips, visual states and
travel described above replace their equivalents.

## Integration and fixes 4.36.0c

Pressure: IsPressedBy demands real support to the level of the plate, living and solid
character, without flight/noclip or ascent. The XY distance is compared to the sum of
the plate and receiver radii, including the part of the feet that treads on the edge.
Before it was compared only to the radius of the plate. A blocked destination does not
consume the trap; it is retried at the existing cadence. The diagnosis numbers
rejections: 1 without marker, 2 insufficient height, 3 solid occupant, 4 35 tics
protection, 5 collision rejected by TeleportMove(false).

Lever: CaelumLeverFace moves from 0,09 to 0,045. Tick also normalizes a previous
serialized scale and retains the up/down frame. The new click is only issued if Use
activated at least one mechanism.

First person: CaelumFirstPersonView receives PSpriteTick from the physical and magical
selectors and occupies exclusively the 50 layer. CaelumFirstPersonFrames contains new
Weapon/Overlay states, avoiding inserting states into classes that are already saved.
The sword retains its previous modular rig. The HUD omits the provisional icon when a
selector controls a native view; the gauntlets show their fists and not a second
blocking icon.

The 93 compositions retain the hand/weapon order of the manifest. Its canvas is 320×200
and its offset (160,32); the percentage pivots are calculated by visible box. The melee
curve moves the complete composition and uses only the approved relative twist, without
adding again the 18° of the ancient sword. The movement only begins when recovery grows
after an accepted attack. Magic observes the conclusion of the real callback. Nothing in
this controller takes resources, applies damage, fires projectiles or modifies combat
times.

| Family | Phases linked to the game |
| --- | --- |
| Short/long bows | A with arrow; B when aiming with ammo; C empty or after firing |
| Crossbow | A loaded; B fired/empty; C while reloading |
| Carbine | A prepared; B recoil/empty; C reloading the chamber |
| Book | A open and casting; B closed when lowering/raising or blocking |
| Gauntlets | A guard; B right punch; C left punch |
| Other new weapons | A with displacement and joint twist when attacking |

Changing equipment, dying, breaking the weapon, opening Inventory/Crafting or resting
clears the corresponding view. Lowering/raising accompanies the native position of the
weapon; changing map restarts presentation. The engine removes layers whose selector is
no longer active. Two-hand sets respect existing shield rules and do not incorporate an
additional hand.

Audio: The rock mono loop starts only when moving in XY with contact and without
falling. IsActorPlayingSound avoids restarting each tic and restores it on loading. It
stops when immobilizing, staying in the air or being destroyed. CHAN_5 is unique to its
friction; it does not add force or damage. Visual rotation follows the rolling path.
Tarot capture sends an interface event only after RecordMainM00FoolCapture; it is
independent of the dialog camera and does not play when inspecting a card or rejecting a
capture. The musical attenuation of the dialog and its restoration is still in charge of
the existing native menu.

| Confirmed crossing | Native transition | Local sound |
| --- | --- | --- |
| Cart, MODE_CART | 3, crossfade | caelum/travel/carriage |
| Ship, MODE_SHIP | 1, melt | caelum/travel/ship |
| El Loco, including MAP01→MAP02 exit | 2, burn | caelum/ui/map_transition |
| Other exits | wipetype preference | caelum/ui/map_transition |

PreTravelled consumes PendingTravelWipe or confirmed travel mode and sends wipe/cue to
CaelumMenuAudio. WorldLoaded selects a transition and reproduces the clip after cleaning
channels from the previous map. Requesting a quote/cancelling does not initiate
departure. Loading a save discards the pending presentation. The El Loco narrative
crossover leaves both scenes visible: its old black fades, which concealed the burn, are
removed. It retains validations, maintenance of the initial weapon, inventory cleaning
and arrival conversation.

Mass/impacts: 4π/3 × (48 MU / 32 MU/m)³ × 2700 kg/m³ = 38170 kg rounded. A_SetSize
enlarges an old block only when it fits; the report shows radius, height and
enlargement, as well as effective mass. The last impact shows origin, closing velocity,
initial percentage, Hardness, resulting percentage, armor and final damage. Damage is
not inferred from tonnage alone.

## Mines, teleport, crushing and presentation (4.36.0b)

CaelumPressureTrap consults the local blockmap. It demands living and solid body, feet
to plate height and real support; excludes noclip, flight, ascent and incomplete
creation. Activations interrupt rest/fast advance.

| Class / editor | Mapper Settings | Behavior |
| --- | --- | --- |
| CaelumMagicMine / 30963 | args[0] base damage; args[1] radius MU | It explodes once when you step on; zero disables. |
| CaelumTeleportTrap / 30964 | args[0] Target TID | Reusable local teleport, no telefrag. |
| CaelumTrapDestination / 30965 | TID, position and Angle | Explicit destination; does not grant objects or modify the clock. |
| CaelumCrusherTrap / 30966 | args[0] damage/pulse; args[1] speed MU/tic; args[2] sampling distance | Native ceiling: descends, crushes, rises again and stops. |

Mine: A_Explode with a real radius, passed through the existing anatomical defense.
CaelumTrapMagic identifies environmental provenance, no combat adrenaline or additional
Doom thrust. It retains vulnerabilities, armor parts and hardness. The XFIR re-uses the
flames. MAP08 is tested in 100 base points and 128 MU; they are not definitive campaign
values. The spent mark remains dim when saved.

Teleport: Validates marker existence, floor/ceiling, solid bodies and objects occupying
the destination before TeleportMove(false). An invalid or busy destination retains the
character in origin and does not count activation. It stops speed, clears interpolation
and tracking fall. An inventory per receiver prevents chaining another plate during 35
tics; then it can be reused. There is no general invulnerability, telefrag, travel
between maps or delivery of resources.

Crusher: Level.CreateCeiling with ceilCrushRaiseAndStay and crushDoom. Each panel
retains its original top height. args[2]=0 selects only its sector; MAP08 uses 32 to
choose four sectors of 64 MU, a square of 128 × 128. Use 8 MU/tic, lower separation of 8
MU and 10 points per native pulse test. Crush damage follows the native environmental
path of pain, without combat adrenaline; it does not replace the calculation of rock
impacts. It can be activated by pressure or by a lever directed at the same TID. Only
one cycle; no moves are superimposed. Moving ceilings block the nearby rapid advance and
keep its movement.

Levers: CaelumHazardReleaseSwitch accepts the TID of a rock or crusher. The transparent
CLVR sprite overlaps with an OBJ column and switches from top to bottom. args[1]=1 omits
the column to place it on a wall; the actor should be placed a little in front of the
face, with Angle facing the wall. The SF_IGNOREVISIBILITY check ignores only the
invisible support, keeping the actual occlusion of the walls. Switches with no activated
target are not consumed.

Native transitions verified in GZDoom g4.14.2:

| wipetype | Effect |
| --- | --- |
| 0 | No transition |
| 1 | Melt |
| 2 | Burn |
| 3 | Crossfade |

PreTravelled announces CaelumMenuAudio mode, which is already StaticEventHandler.
WorldLoaded applies ScreenJobRunner.setTransition(1) only to a pending boat trip and
emits caelum/ui/map_transition after cleaning the previous audio. It is a native
selection of a single crossing, without changing the cvar wipetype. Other trips retain
the user preference; loading a game does not repeat the sound or impose the effect.
Travel logic, resources and clock is preserved. Engine source:
https://github.com/ZDoom/gzdoom/blob/g4.14.2/src/d_main.cpp (System_SetTransition and
D_Display), along with menudef.txt/screenjob.zs of gzdoom.pk3.

MAP08 adds by saved revision: mine (1728,640,0.5), teleport (2048,640,0.5), destination
(1152,1664,0), crusher (2240,1216,0.5) and lever (2240,1088,0). TID
43610/43611/43612/43613 respectively. It does not change the WAD. An immobilization rune
is proposed for revision, without implementation.

## Physical hazards and traps (4.36.0a, updated in 0b)

CaelumTrapdoor (30960 editor) is a native support ACTLIKEBRIDGE of 256 × 256 MU, 8 MU
thick. Its origin is 8 MU below the walkable surface. It requires a pit modeled in UDMF;
it cannot create a hole in a solid floor. CaelumTrapdoorCover reuses CSUF/CMWD01 and
matches the physical cover.

It is activated when the center of a live, already created and supported player is
inside the square, his feet match the lid and is not going up, flying or in noclip. It
also supports CaelumCombatActor actors supported. The query is local to the blockmap.
Stepping on it removes solidity and rendering once; gravity and landing follow the
existing rules. It does not teleport, does not add fixed damage, does not rearm and does
not close on who fell. Opened, ActivationCount and references are saved.

CaelumHazardRock (30961) passes to radius 48 MU, height 96 MU and mass 38170 kg: 4/3 ×
pi × (48/32)^3 × 2700, rounded. When loading an old rock in contact with obstacles it
retains its small dimensions first and only expands when A_SetSize confirms that it
fits. It does not move or re-launch by migration. It starts suspended; args[0] is the
horizontal impulse in MU/tic according to Angle, or zero for a vertical drop. It
releases that impulse only once. The rolling test omits friction; does not apply a
continuous motor. Visible rotation depends on the distance travelled. It does not
support manual thrust while it is retained. The native collision stops movement against
a wall.

CaelumHazardReleaseSwitch (30962): args[0] is the positive TID of rocks or crushers.
Using requires vertical reach, visibility and overlap with a live player. The operation
passes to Spent after releasing a destination; does not create new blocks. There is no
rearmament timer. Without a valid target, the switch is not consumed.

ImpactPhysics.ResolveVerticalBodies adds downward contact without changing
ResolveBodies/ResolveStatic. Use J = (1 + e) × Closing Speed / (1/m1 + 1/m2) and Δv =
J/m. Native geometry confirms landing on the body before applying biological reception,
located at its top end. The same support does not cause damage to each tic. Separating
allows a subsequent physical contact. Hardness, vulnerability, protection, lucidity and
health retain its rules.

IMPACT_KIND_ENVIRONMENT = 5 identifies the origin of these mechanisms. CaelumImpact is
maintained as a route of damage; DMG_THRUSTLESS avoids adding a native thrust alien to
the calculated impulse. There is no combat evasion or combat Adrenaline gain.
Protection is still pending implementation in V5. Fast advance is blocked if there is a
free rock moving in the already inspected safety radius. Opening the trapdoor interrupts
the rest of the character that activated it. Hazards are resolved at normal tic speed.

MAP08: eastern lobby access x=768, y=640–896. Cover centered at (1408, 896, 0), bottom
at -192 MU; twelve steps of 16 MU lead east. Rolling rock at (1280, 1344, 0), test
impulse 8 MU/tic, TID 43602; mechanism at (1152, 1344, 0). Suspended rock at (2048,
1600, 256), TID 43603; mechanism at (2048, 1536, 0). These are test-gallery dimensions
and settings, not new balance values for the whole campaign.

ca_debug_hazards_report identifies 4.36.0b and shows activation, solidity, lid, masses,
speeds, vertical contacts and used mechanisms. MAP05's WAD retains its original
checksum. MAP08 is incorporated as a 8 location, with 12/13 connections; no id is reused
and no records are resized. The MAP05 access appears at (640,704,0), also when loading a
previous save: SewerNetworkRevision moves from 1 to 2 and the placement is idempotent.
The MAP08 return uses lobby access in (0,96,0). Both directions use the existing local
travel service, no fare or supply consumption. Traps belong to the hub and retain their
status when going and returning. For an isolated test you can use map MAP08; that
command restarts the character.

## Animations and sitting consumption (4.35.0q)

SEATED_MEAL_TIC_DIVISOR = 3 is the only divisor of food/water advance while there is a
valid chair session. Full portion: ten pulses, one each 105 tics, duration 1050 tics =
30 s simulation to 35 Hz. Outside the chair 350 tics = 10 s are preserved. Fast advance
uses the same rule. Menu pauses do not count as simulation. Food and water are not
multiplied: the ration, dose per body mass, digestion and caps remain the same.
Inventory, table and Box use the common effect; automatic repetition waits for it to
end. A 3–9 partial counter from 0p continues without restarting the portion or spending
another. Medicines retain its previous rhythm.

Two-phase breathing in eight views; four-phase running and two-step walking where
separate resources exist. AI callbacks retain their intervals and the stunning guards
are repeated every two phases in the actors who already used that interval. Changing the
drawing does not change Speed. New states go to the end of each class, preserving the
indices of attack, death, crouching and rest from previous games. Domingo's old infinite
idle state is reactivated on loading to allow breathing. Palomo uses rest when standing
still, walking while wandering and running when departing or returning; emotions and
conversations retain priority. RestSeated and RestLying expose the new poses to the
controllers, without assigning a sleep routine to their agenda. Sitting/lying down stops
their wandering.

netevent ca_debug_rest_report identifies 4.35.0q and displays the current divisor.

## Reserves, controls and vehicles (4.35.0p)

Seat consumption: table priority → personal inventory → own magic box. Only FoodRation,
WaterRation and container water; does not use medicine. Starting another portion is rejected while its regeneration remains active or the corresponding need is full. Supplies are consumed directly without removing the entire stack or requiring capacity to move it.
Only an accepted use consumes a ration; Drink loses liters, preserves the container
and restores InMagicBox before the final result persists. Access requires sitting and
next to a valid table. Recovery is three times slower while seated from 0q with
identical portion; digestion = hunger actually recovered / 4.

Q/B: cancel trip; detail → month → World; Q in World closes Journal. Escape/Start is
left to the native menu and does not cancel those states. The release of +use is
preserved so the button does not remain held. The console is still accessible.

MODE_FOOT=1 and MODE_CARAVAN=2 preserve saves and the old walking trial. MODE_CART=3 and
MODE_SHIP=4 require a physical vehicle and only connections 10/11 (MAP06↔MAP07, 500 km).
They do not authorize sailing to the sewers. Walking portals remain available. Walking
speed and the 10 km MAP03↔MAP06 remain approved and unchanged.

CaelumJourneyRules.CART_KMH=3; SHIP_KNOTS=5; KM_PER_NAUTICAL_MILE=1.852. Carriage: 1 050
000 travel tics + 504 000 sleeping tics = 10 d 6 h 40 min. Ship: 340 173 sailing tics =
approximately 2 d 5 h 59 min 45 s; 100 800 of those tics are sleep aboard (16 h). The
screen rounds up to the minute: 2 d 6 h. The outside-world clock retains 6 300 tics/h of
campaign time. Sleep aboard is distributed within each 16–24 h interval of the passenger
cycle and allows a final partial rest. The ship also advances during those tics.

The numerical forecast applies hunger, thirst, sleep, digestion, regeneration, lucidity,
stunning and survival damage.The inventory and schedule are only modified when
confirming. Sleep uses the player's sleeping bag if carried; otherwise, the ground/deck.
The trip provisions are those carried outside the Box, as in 0n; the new access to the
Box requested here corresponds to the table.

SourceVehicle links the quote to the specific actor. Confirmation revalidates its presence, map, type, distance, route, action blocks and reserves. If the
forecast is changed materially, it is requested to review it again. Cancel, confirm or
finish removes the link. The transition reuses departure/arrival records, inventory
transaction and AdvanceTics from the existing agenda.

CaelumVehicleWorld installs a rancho shelter and a cart in (-640,192,0) MAP06 and
(-512,384,0) MAP07. The boats remain in (1536,768,-24) and (1280,1440,-24). The new dock
of MAP07 focuses on (1120,1312,0); its cover connects with the sand and uses 4 MU bridge
collisions, with a stop in Z=0. The rancho provides awning-type weather shelter and has
three walls/roof with collision. The boarding sign visible on the dock receives Use at
normal height. Repeated preparation/loading does not duplicate models, colliders or
vehicles.

## Scheduled agenda and events (4.35.0o)

The calendar uses the civil campaign anchor, not the operating system clock or TrialDate
of the debugger. TAB → World → F/RT. Arrow keys/D-pad: day; PgUp/PgDn or LB/RB: month;
H/Home: today; E/R or Y/X: event of that day; Enter/A: detail; Q/B: return; TAB: close.
In detail, P/RT pays debt or withdraw cargo. Navigation is local: it does not re-anchor,
advance or pause the game clock.

CaelumScheduleState is a hidden, persistent Inventory between maps. It contains up to
2048 series, with stable ID/key, type, localizable title, subject, map, initial date,
minute interval, limit, counter and status. Keys prevent duplicate records. Zero
interval is a unique event. Zero limit supports indefinite recurrence, up to the civil
limit and the 2147483646 counter. Intervals accepted: up to 525600 minutes. Gregorian
dates of years 1–9999. Each cell counts series, not a copy of each repetition within the
day.

CaelumWorldClock calls Sync after moving forward. The amount expired arithmetically per
series is calculated and saved once; a cache of the next date avoids reviewing all
series in each tic. Long jumps do not go through all occurrences. For routines/sieges
the phase with last effective date is chosen, regardless of the order of registration;
ties are resolved by the higher ID. The native inventory serializes objects, their
progress and the load. There are no operating system tasks.

0n trips keep your needs forecast and unique clock. The budget does not change the
agenda. Confirmation credits deadlines crossed, and destination consults the final
state. It does not physically execute armies or repeat inactive map routines. No event
retroactively simulates looting, interception of cargoes or damage to the traveler:
those consequences need your explicit contract on future systems.

| Type | Integrated effect |
| --- | --- |
| Siege | Value > 0 activates the subject/map phase; 0 completes it. Interrupts rest and acceleration, closes workshop session while retaining the task. The complete battle is not generated automatically. |
| Routine | CaelumScheduledWorker adopts WorkSpot or RestSpot according to the last phase; native movement, without passing through obstacles. Upon return to the map it does not reproduce the lost turns. |
| Rent | CaelumScheduleContracts.Rent records value in coppers, start and period. Each maturity adds debt. P pays all debt with real coins/change and capacity control, without automatic debit, eviction or forced lock. RentCurrent is available for a future access condition. |
| Shipping | DispatchCargo withdraws actual CaelumMaterialPickup units outside the Box and not linked to a Limbo quest. It retains type/level/quantity/origin/destination. CollectCargo requires time, correct map, capacity and valid inventory; a failure retains cargo, a success sets Claimed before allowing another withdrawal. It does not transport assembled equipment or add freight charges. |
| Resource | When extracting a natural node it records its complete recovery; another extraction recalculates that same input. Capacity and fraction are preserved in the hub actor. It counts the clock passed while its map is absent. |
| Mission | QuestDeadline links a defined active secondary mission. On expiry, it fails only if its objectives remain incomplete; it does not remove a reward pending targets already achieved. |
| Notice | Date and status available without transaction or additional consequence. |

The payment prepares all the change before modifying the previous coins. Collecting a
paid series does not discount again. The shipment cannot be cancelled leaving lost
merchandise; after withdrawing it retains the history, with zero balance. Inventory
transactions require a living player, free of rest, combat, conversation, trade,
manufacture and open budget. The cooperative game does not receive economic contracts
shared in this block.

Regeneration uses capacity × 0,001 per campaign day. An empty node takes 1000 days; one
to 90 % takes 100 days to complete. It is the existing rhythm, not a new value approved
by the author. The first tick of an old save initializes its time mark without granting
retroactive years. Its next extraction adds it to the agenda. One entry per node informs
map/material; there is no minimap or coordinate marker yet. The history of previous
cycles of the same node is replaced when extracting again to not create an input per
hit.

Tests (outside MAP01 at a clear location): - netevent ca_debug_events_trial: one-time
registration, with physical worker. Work +1 min and rest +6 min, repeated each 24 h.
Siege +4 to +10 min. Rent 1 copper to +8, +20 and +32 min (three maturities, no
automatic expense). - netevent ca_debug_cargo_trial: dispatches 100 units of level 1
wood that are carried outside the Box. From MAP06 goes to MAP07; from another outside,
to MAP06. Delays 30 min. Each order is a different shipment and consumes actual stocks.
- netevent ca_debug_events_report: 4.35.0o version and registration of each series.

The trials do not alter the four routines of the mansion or invent canonical contracts.
A copy of the game is recommended to test them. Programmatic cancellation prevents
future repetitions, keeping occurrences and debts already registered. Hidden events are
executed but do not appear in the calendar.

## Travel with duration and provisions (4.35.0n)

| Route | Connections | Distance in each direction |
| --- | --- | ---: |
| MAP03 reservoir ↔ MAP06 port | 8 / 9 | 10 km |
| MAP06 port ↔ MAP07 coast | 10 / 11 | 500 km |

CaelumJourneyRules calculates the native sustained displacement: normal forward input ×
effective multiplier × Speed × ORIG_FRICTION_FACTOR / (1 − ORIG_FRICTION). Includes
inventory speed; uses normal soil and standing body. Run, diagonals, combat posture and
initial acceleration are excluded. 32 MU = 1 m; km/h = MU/tic × 35 × 3,6 / 32. The
calendar's 20:1 scale does not multiply that physical conversion. Test with native
displacement at a steady walking pace.

The speed captured on departure is fixed for the forecast. Weight lost by eating and
reserve fluctuations do not solve the speed again during that same route. The current
state is used for the next trip. Travel hours = km / km/h; is rounded up to the tic of
the outer clock. Number of nights = (travel tics − 1) / (16 × tics per hour), whole
division. Each night adds 8 hours; the last arrival does not add free sleep. Example to
5 km/h: 10 km = 2 hours; 500 km = 100 + 48 = 148 hours.

Using a measured access opens CaelumJourneyPlan. The UI only reads saved data; Enter/A
sends ca_journey_confirm, Q/B ca_journey_cancel. The query does not change needs,
belongings or clock. While reading it follows the ordinary simulation, with
actions/movement blocked as in the other interfaces of the character. Confirm valid
context, map, proximity, profile, inventory and conditions; recalculates and requires
revision if time, expense, inventory or mortal risk changes. It is not charged when
cancelling, updating, re-clicking Enter or loading a save.

CaelumJourneyModel copies numerical values and goes through steps of a tic. The Needed
model uses unlimited rations to calculate what is necessary without container water;
Available uses actual stocks. It accounts for passive consumption by body mass and
Constitution (including Sleep since #131), ten pulses per serving, real digestion /4,
natural Health/Air/Anima recovery with its current #140 costs, critical reserve damage, Adrenaline
and Lucidity. Sleeping drains 10 Lucidity/s, without recovery from it, and recovers
Sleep in 8 hours; stunned by Lucidity does not interrupt camping. Compatible personal
timers advance by the same interval.

A portion begins when it fits its contribution without exceeding 100. During sleep no
other begins; a portion already begun ends its pulses. The ration contribution is
800/masa. Water rations first; then sips up to masa/500 liters of containers, with ten
pulses proportional to the actual volume. The empty container is preserved. Box and
supplies on tables outside the inventory do not participate. A sleeping bag outside the
Box applies comfort 3 during the night; floor applies 1. No beds or seated benefits are
added while travelling.

Apply deducts items/liters, retains incomplete portions as native Powerup, applies
reserves and final timers and adds the interval with CaelumWorldClock.AdvanceTics. The
calendar and weather consult that same date; does not change the seed.
CaelumJourneyState records km, km/h, actual travel/sleep tics and consumed supplies, in
addition to existing departure/arrival data. New fields start at zero in old records,
without inventing past expenses.

If provisions are missing, the expected arrival with its consequences is presented. If
death would occur first, it shows the lethal risk and estimated time; confirm consumes
only until death, uses native Die and leaves the trip interrupted in origin. There is no
arrival or credit of destination. Execution is an atomic transition; you can save the
budget or arrival, not a fictitious position in the middle of a journey. The plan is
revalidated after loading.

The planner supports up to 30 days of walking per route; it explicitly rejects longer
durations. It requires dry ground, a player, without combat, immobilization, work, rest,
conversation, elemental effects or active Powerup. It does not erase an effect by
traveling: it asks to wait for its end. The diagnostic Caravan uses walking speed; there
is no invented vehicle speed. Previous local routes remain without measure. There is no
AI replay, intermediate terrain or incidents. The scheduled narrative events remain open
to definition and explicit integration.

## Food by body mass and riverside expansion (4.35.0m)

Common Reference RATION_REFERENCE_MASS = 80 kg, body M base. Food portion of 0,10 kg:
800/masa Hunger points; water ration of 0,16 L/kg: 800/masa Thirst points. The clothing
size does not replace the actual body mass.

| Body mass | Hunger restored by food | Thirst restored by water | Sleep lost after a full portion |
| ---: | ---: | ---: | ---: |
| 50 kg | 16 points | 16 points | 4 points |
| 80 kg | 10 points | 10 points | 2,5 points |
| 100 kg | 8 points | 8 points | 2 points |
| 200 kg | 4 points | 4 points | 1 point |

The values represent sufficient deficit; Hunger/Thirst are limited to 100 and Sleep to
0. Digestion depends on the actual increase. Passive and regeneration spending continues
to be discounted during the meal, so net HUD can go up less. It does not depend on the
weight of inventory, clothing or having additional rations.

CaelumRegenerationPower serializes FoodRecoveryPerPulse when accepting native use. Each
pulse recovers 80/masa; the dose is fixed until the portion is explicitly finished or
refreshed. A missing/zero field in old effects retains one point per pulse. Loading does
not recalculate an old meal or consume another unit for migration. The partial
accumulator is retained sitting and the ten pulses in 10/30 simulation seconds.
Inventory, table and x105 share the same hunger/digestion behavior; the repetition
expects the current effect.

### Identities and routes

| Connection | Origin → destination | Access at source (MU) |
| ---: | --- | --- |
| 8 | MAP03 → MAP06 | (0, 3424, 0), north end of the reservoir |
| 9 | MAP06 → MAP03 | (0, 96, 0), southern port entrance |
| 10 | MAP06 → MAP07 | (0, 2080, 0), north end of the promenade |
| 11 | MAP07 → MAP06 | (0, 96, 0), south coast entrance |

Locations 6/7 expand the catalog without changing previous IDs or their 32 arrays
positions. The historical name IsSewerConnection includes this entire network.
SewerNetworkRevision=1 prepares new routes once in previous snapshots; PrepareWorld
checks door identity before adding another. The WAD geometry of MAP01–05 is not changed.
New maps belong to the 434 hub.

Travel retains its occupancy, state, inventory, route and single-player checks. The
pedestrian exits use Native Use. 43411/43414/43415 caravan conversations offer the
corresponding destinations with confirmation. No fictitious duration or transfer fee is
still assigned. Arrival and departure are recorded with the common clock; no route to
the mansion is created.

Both maps carry CaelumClimateRegion, arg0=1/arg1=0: Buenos Aires, surface. The catalog
also knows that habitat. Solid roofs of 24 MU and submersible water use native
Sector_Set3dFloor; water does not have user_ca_potable_water. The coast offers 16 MU
rungs to get out of the river. Water materials are static.

Small tables: 601 slot in (-800,800,0), port warehouse; 701 slot in (-256,1280,0),
coastal shelter. Each has two chairs and four belongings. Its safe areas allow T only
during valid rest; standing up stops x105. No free consumer objects or mission NPCs are
added. The caravan remains an optional diagnostic interface, not a new narrative
transport.

The Journal reduces the passage between rows of visits from 12 to 9 when there are more
than five, leaving the seven within y=220..274 and the last trip in y=286.

## Regional climate, shelter, water and chairs (4.35.0l)

Replaces the numeric test profiles of 0k. Author approves 0j/0k. The reported
temperature is air temperature; HR is relative humidity, not humidity of clothing or
thermal sensation. Wind in km/h, direction of origin (0=N/90=E), precipitation in mm/h
of equivalent water. No body damage or adjustment is added.

### Contemporary data and geographical reference

Source: [SMN, Normal Climate Statistics 1991–2020
(2023)](https://repositorio.smn.gob.ar/handle/20.500.12160/2506), 847 pp., CC BY 2.5
Argentina. Wind speed: 2011–2020 subseries of the same publication. The transcription of
numerical data, pages and units is in assets/climate/smn_1991_2020.json;
generate_climate_normals.py produces the included ZScript, without downloading anything
or depending on Python at runtime.

The twelve monthly values of average temperature, mean maximum, mean minimum, mean HR,
monthly precipitation, days with ≥0,1 mm, cloud cover in oktas and average wind speed
are incorporated. The values are modern climate reference, not daily 1889 data nor a
current forecast.

| ID | Reference station | Region represented | Mean temperature January / July | RH January / July |
| ---: | --- | --- | ---: | ---: |
| 1 | Buenos Aires Observatorio | Humid Pampas | 24.9 / 11.0 °C | 64.6 / 77.0% |
| 2 | Córdoba Aero | Central region | 23.5 / 9.8 °C | 68.1 / 63.5% |
| 3 | San Rafael Aero | Cuyo | 23.8 / 6.8 °C | 50.0 / 60.4% |
| 4 | Salta Aero | NOA, valleys | 21.5 / 10.1 °C | 77.2 / 69.3% |
| 5 | Posadas Aero | NEA | 27.2 / 16.3 °C | 68.1 / 73.9% |
| 6 | Trelew Aero | Patagonia, plateau | 21.6 / 5.9 °C | 42.1 / 66.3% |
| 7 | Bariloche Aero | Andean Patagonia | 15.4 / 2.1 °C | 51.9 / 78.0% |
| 8 | La Quiaca Observatorio | Puna | 13.2 / 4.5 °C | 62.6 / 25.7% |
| 9 | Río Gallegos Aero | Southern Patagonia | 13.6 / 1.5 °C | 51.9 / 77.7% |

The stations are local references; not a single average is applied to all of Argentina,
nor is it assumed that a station covers each height of its region. MAP02/MAP04 conserves
sewer habitat; MAP03, reservoir; MAP05, gallery. The location of the four and the
following maps is confirmed by the author in Buenos Aires (0m): use 1 region. MAP06–07
incorporate surface habitat. MAP01 retains 20 °C/55% and absence of wind/precipitation.

CaelumClimateRegion (DoomEdNum 30950) allows a marker per map: arg0 = Region ID 1..9;
arg1 = 0 for surface, 2 sewer, 3 reservoir, 4 gallery. Coverage is resolved in each
position. Limbo prevails over markers. An unknown map without marker, or with invalid
region, shows missing profile; it does not inherit values from the last location. No
published WAD is modified.

### Temporal synthesis

Normals are interpolated between centers of months using real lengths and leap years.
Campaign date/time, region and seed determine each sample. Daily thermal cycle
approaches sunrise by latitude/time of year and solar noon by longitude, using Argentine
civil clock UTC-3; maximum near solar noon+3 h. Minimum and monthly maximums scale the
cycle. It does not change map lighting.

Six-hour fronts interpolated with f²(3−2f) add thermal anomalies of ±6 °C and
humidity/cloud-cover variation. Wet days are chosen deterministically from rainy
days/month length. Each episode lasts 6..12 h, centered between 06..18 h, with a cosine
bell and volume linked to monthly mm/wet days; intensity varies by 0,5..1,5 of the
reference value. It starts/ends without a jump and reaches zero at midnight. It does not
reproduce a specific historical storm.

Cloud cover reduces thermal amplitude; active precipitation cools by up to 2,5 °C and
brings HR toward 95..100%. Initial vapor uses monthly HR and mean temperature, modulated
by the front. HR = 100·e/es(T), limited to 0..100, with es(T)=6,11·10^(7,5·T/(237,3+T))
hPa according to [NWS, Vapor
Pressure](https://www.weather.gov/media/epz/wxcalc/vaporPressure.pdf). Wind speed starts
from its monthly normal; vectors are interpolated to cross north without
discontinuities. Directions are synthetic, with a western component in Patagonian
references 6/7/9; they are not presented as an observed wind rose.

These factors are a playable model anchored to observations, not a validated weather
simulator or guarantee to reproduce exactly every monthly average. It does not model
accumulation of snow, hail, flood or particles yet. The weather phenomena represented
are fronts, cloudiness, wind and precipitation.

### Shelter and local microclimate

A vertical trace from the body ignores actors and skies (TRF_NOSKY), but respects roofs,
slopes, walls and floors 3D. No roof: exterior. In habitats 2..4, a roof implies an
underground location. On the surface four cardinal rays of 1024 MU (32 m) are consulted;
three or four blocked rays indicate an interior; otherwise, open shelter. It is a
geometric approach, not a ventilation simulation.

| Shelter | Air temperature | Wind | Direct precipitation |
| --- | --- | ---: | ---: |
| Outdoors | Full regional sample | 100% | Regional |
| Open shelter | Monthly average + 95% of the external deviation | 65% | 0 |
| Interior | Monthly average + 45% of the external deviation | 10% | 0 |
| Underground | Annual average + 15% monthly anomaly with delay of 30 days + 5% external anomaly | 0 | 0 |
| Limbo | 20 °C | 0 | 0 |

Open shelter/interior retains vapor pressure when changing temperature: HR can go up or
down; the roof does not magically remove vapor from the air. In the subsoil, the
exchange with wet surfaces approaches HR at least to 95%, with 65% mix for sewers, 85%
for reservoir and 25% for maintenance. They are ambient coefficients, not an
energy/material balance of the building. The wind does not subtract degrees from the air
temperature as if it were a thermal sensation.

### Status, saves and consultations

CaelumWeatherState retains Seed, region, habitat, coverage, SourceMap,
SampleDate/Minute, position and two reused samples: Outside and Current. The region is
resolved from catalog or marker; the marker is searched for at most once per native
second, or when changing map/revision. The outside is recalculated per minute of play.
Coverage is updated when moving and at least once per native second while stationary, to
respond to mobile geometry. Each change reapplies the microclimate from Outside, without
accumulating attenuations.

Revision 2 migrates 0k keeping seed, date, objects and progress. The same date/seed
produces the same exterior with normal clock, x105 or return from a journey; no offline
time is used. The 0k clock adapter is retained. Test dates do not alter campaign.
Invalid queries clear values, with Available=false.

    netevent ca_debug_weather_report
    netevent ca_debug_weather_sample PERFIL DIAS_RELATIVOS HORA
    netevent ca_debug_climate_sample REGION DIAS_RELATIVOS HORA

report displays local and external data. weather_sample maintains compatibility with profiles 1..5, with regional reference 1; climate_sample accepts 1..9 and displays
external and three coverages without moving the player or changing campaign. Hour:
0..23; date within years 1..9999. Journal > World reports region and coverage.

### Water by volume and chair repair

Water ration = 0,16 L = 0,16 kg, approximating density as 1 kg/L. Tier 5 base mass is
used: 80 kg, central body size 4 compatible with M clothing. Clothing size M covers
several masses: recovery remains proportional to the body, 800/masa Thirst points per
ration (80 kg → 10; 100 kg → 8). Ten pulses, each 80/masa; while seated they are
distributed over 100 s of simulation, and standing over 10 s. A save with an
already-started serving retains its previous dose. Containers retain actual liters and
tare; food retains 0,10 kg/dose. The shared rule supplies native weight, load, Box and
purchase checks.

102/104 Tables: (1072, ±480, 136), angle 0°. Chairs in X=988 and 1156, Y=±480, Z=136.
Beds continue (944, ±392, 136). The persistent mansion revision retries until occupied
sessions end; moves the same instances and recovers missing chairs. Verification
includes a line of sight unobstructed by walls, native entry into both seats, save/load
and preservation of content.

## Current Time, Consumption, Use and Area Rules (4.35.0j)

This section replaces the previous Limbo clock values, sitting consumption, station size
and Sleep radius. The sections by later version in the document retain the context of
each addition.

### Local time and sleep

SecondsPerGameHour returns 3600 in Limbo and 180 out. The clock retains its previous
unit of 6300 tics per hour; LimboSubTics saves the integer remainder 0..19 between
steps. Thus, 126000 personal steps are one hour of Limbo and 6300 are an outside hour.
Save, load or change map retains the remainder; does not change the campaign anchor of
03/11/1889 09:00 nor reconstruct previously frozen time. It counts only active
simulation, without synchronizing with the system clock or recovering time while the
game was closed. Escape retains native pause.

The cost of hourly needs, recovery while sleeping and daily regeneration of
environmental resources use the local time. Sleep recovers 100 points in 8 hours of
play, confirmed value: 8 real hours in Limbo or 24 real minutes out at normal speed.
Comfort does not multiply this recovery. The effects expressed per second retain their
simulation seconds: sleep drain 10 Lucidity/s without regeneration; the stunning does
not wake up. Costs, reuse of skills, consumables and manufacturing do not become hours.
Tx105 applies the same local scale by subpass and previous guards. MAP01 keeps furniture
without duration; timed ground/sleeping-bag sessions remain outside.

### Food and water while sitting

CaelumRegenerationPower retains its ten pulses and adds SeatedMealSubTics. Only
food/water, during a valid chair session, process an effect tic every three personal
steps (0q revision). It compensates EffectTics in the other two steps. The complete
portion lasts 30 seconds instead of 10. A ration of food recovers 10 points to 80 kg; a
ration of water or a sip retains its performance and volume according to body mass. It
does not increase gross performance or spend extra portions to compensate for slowness.

Standing up processes the remainder at ordinary speed, without restarting the effect.
Sitting back recovers the slow pace; pulses, fraction and duration are saved. Potions
and energy drink retain their duration. F/G continues to satiety, waiting for each
effect; reaching full satiety prevents another ration even if there is passive expense.
Eating continues to discount Sleep = Hunger effectively restored / 4.
Passive/regeneration rates are calculated separately with accepted comfort.

### Interaction and station size

USESPECIAL caused a station to stop Use even when it refused to open because it was out
of reach or on another floor. That indicator is removed and the result of Used is used;
rejection allows to follow the native search. Express routes Activate/Deactivate
maintain compatibility with your calls. CaelumUseGeometry intersects the beam of look
with the physical cylinder of the actor within UseRange. Beds, chairs, table blocks,
residents and stations consult it before opening. Native reach, visibility, walls and
collision are maintained; UseRange is not expanded or the player's body is changed.

DimensionsRevision=2 migrates stations to 0,75 scale, 30 radius and 72 height, also when
loading 0h/0i saves. These are 75% of the three 0i dimensions and 150% of the previous
0h dimensions. The saved USESPECIAL flag is cleared; absolute and idempotent allocation,
without losing networks, capacities, recipes or reserves.

### Approved base radii

Base before AbilityRangePercent; 32 MU development scale per metre.

| Effect | Base radius (MU) | Meters |
| --- | ---: | ---: |
| Channeling of Seals | 1280 | 40 |
| Class skills; currently Arcanist Sleep | 1280 | 40 |
| Impact of lightning seal | 256 | 8 |
| Zupay ground slam | 192 | 6 |
| Statuette explosion | 128 | 4 |

SEAL_CHANNEL_BASE_RADIUS maintains 128 × 10. CLASS_ABILITY_BASE_RADIUS reference that
same base; Sleep and seals multiply by AbilityRangePercent/100. to 150%, both reach 1920
MU. The selection of Sleep by distance and vision is retained: it includes visible
allies, excludes the launcher and targets behind walls. Duration 10 s, wake up by
impact, reuse 60 s and confirmed base cost of 1000 Anima with its usual reduction. The
base is applied to new casts; it does not cast or extend already-saved effects.

Axe/two-handed sword/halberd sweeps use their weapon ranges of 76/80/84 MU; these are
not ability radii. The charged statuette retains radius ×√2, approximately 181,02 MU
base. Other effects do not change and V5 abilities are not implemented. The sleeping
bag's own weight, 2 kg, is confirmed.

## Access and personal advancement corrections in Limbo (4.35.0i)

SurfaceHeight uses 34,1 × Scale.Y / level.pixelstretch: the height of the actor
representing a ration matches the board mesh with CorrectPixelStretch. Each presentation
fixes its Z also after loading; does not change meshes, quantities, liters, digestion or
capabilities 4/18/60.

MoveLayout and Align move the same tables, collision blocks, chairs and figures. The bed
is moved together with the bedroom table. The set is validated and reversed if it does
not fit. An active occupation postpones the operation; the controller tries again. New
access markers migrate the 0h saves even if their previous preparations were marked as
finished.

The height of the bed allows native passage. The eastern tables receive an additional
margin of 16 MU towards the bottom to support the two chairs on the floor. The lateral
branch of three stations of Ronnie passes west of its workshop, without losing
instances, types, net or reserved works. The cave table moves 100 MU to the east,
perpendicular to the plane of its door and towards the false wall.

CaelumMainM00RuloTrial.EnsurePracticeTarget consults the actual existence of the target
in MAP01. It creates it if it is missing and fits; a failed preparation is retryed. The
found actor is retained, without duplication. IsActive/NearPractice continues to limit
the exercise record to the time and place of the test; it does not change its progress.

The rapid advance ceases to reject MAP01. Rest furniture and workshop networks of the
mansion are enabled contexts; combat, dangers and other exclusions continue to apply.
Pump uses AdvanceOnMap, so the clock remains held in Limbo. PersonalStepSerial advances
once by subpass; the durationless rest compares that serial and level.maptime to recover
Sleep/count steps exactly once. The serial is saved and is not restarted when
alternating T. Outside the clock continues to advance along with simulation.
ground/sleeping-bag sessions for duration are still available outside of Limbo; MAP01
uses furniture without duration.

T is processed only as ca_time_fast. The T branch that issued
ca_debug_advance_crafting_time is removed and Crafts help is updated. The debug command
continues to be explicitly accessible from the console.

## Automatic meals and furniture of Limbo (4.35.0h)

Food regeneration deducts Sleep = Hunger actually recovered / 4. Example: 4 recovered
points cost 1 of Sleep; from 99,5 to 100 costs 0,125. With Full Hunger there is no
digestive cost. Sleep is limited to zero and drinking does not apply this rule. The same
route attends inventory, table and fast advance substeps.

F/G toggles AutoEating/AutoDrinking in CaelumRestState and retains a reference to the
table. Each channel waits for the expiration of the native effect before ordering
another real portion. Reaching the maximum turns off the channel in the regenerative
pulse itself, before the passive expense: it cannot restart an already completed meal.
Without stock, when rising, losing reach or sleeping, the repetition ends. Deactivate
does not reverse the pulses of a consumed portion. The state is native and persistent;
no provisions are granted and inventory and table are not mixed.

Capacity is independent of SeatCount: small 4, normal 18, large 60. Items/Displays have
60 references; 0g saves with 24 positions load their existing belongings. A change of
presentation reconstructs old sprites like plates/cups. Each figure refers to the real
object; disappears when consumed or removed. An empty container continues to occupy its
space until removed. The CANPASS collision distinguishes the furniture from overlapping
plants.

On timeless maps, only furniture offers Untimed sessions with zero duration.
CaelumRestTrial uses USDF 43515/43516; LastUntimedTic limits rest to one personal step
per engine tic. The clock/calendar remains motionless. From 0i T accelerates personal
furniture simulation; ground/sleeping-bag rest for duration is kept out of MAP01.
Sleeping recovers Sleep at its usual rate and drains 10 Lucidity/s, even stunned.

CaelumCraftingStation sets 40 radius, 96 height and 1 scale against 20/48/0,5.
EnsureDimensions migrates once to absolute values, without duplicating when loading.
Actors are reused when moving stations; jobs maintain their references and reservations.
The open session is revalidated and paused if you lose reach. The network link moves
from 64 to 128 MU for the new separation of 112 MU; CraftingRoomGroup keeps the five
MAP01 networks independent.

## Fast advance, tables and sleep (4.35.0g)

T alternates an optional advance only during a Sleep/Wait session or a real
manufacturing task with its open and valid station. Standing still is insufficient, open
the menu without task or have a job booked in pause. Closing the station cuts
acceleration and retains the task/reservations according to existing rules. The state is
linked to the current session or station; another activity requires T again. When
completing it is returned to ordinary speed.

### Common time for substeps

CaelumTimeAdvanceState processes up to 104 tics additional after each ordinary tic:
x105, one campaign minute per engine tic and 8 hours in 13,7 s if it maintains 35
tics/s. Each subpass uses AdvanceOneTic of the clock, the shared functions of personal
resources/timers, the effect and expiration of consumables, UpdateCraftingTask and the
rest session. The limits of reservations, states, expirations and terminations are
resolved at the precision of a tic, without accrediting twice the ordinary tic. It does
not directly add a number of hours to the clock. The calendar derives from the same
clock. Between batches it returns control to the engine; T disables, Q/actions cancels
the rest and Escape retains the native pause.

The initial scope requires an enabled zone, dry ground, rest and a player. It rejects
combat, projectiles, nearby hostile monsters (1024 MU), burn/poison/cut, water,
incompatible actions and Powerup without adapter. It also rejects a nearby actor with
induced Sleep, so as not to omit the remaining time of that effect. A chair or bag alone
does not convert another place into a safe zone. Initial zones cover arrival
points/furniture/workbench of MAP02–MAP05 and the MAP03 tables. Outside of them the
normal rest remains available. From 0i MAP01 allows personal advancement in
furniture/workshops; it keeps schedule stopped and furniture sessions without duration.

i_timescale is not used. The service accelerates the project systems integrated into it,
not AI, physics, doors, scripts or arbitrary Thinkers. Climate, routes and scheduled
events remain pending: their adapters must be integrated before allowing them to consume
these intervals. The general world state is not invented or claimed to be resolved
during a time jump. 0f comfort rates remain in place. Lucidity/consumables/cooldowns
seconds are simulation, not the minutes of the accelerated calendar 20:1; T advances
them only once with the rest.

### Tables and belongings

| Table | Table dimensions in MU | Chairs |
| --- | --- | --- |
| Small Round | Diameter 80 | 2, facing each other. |
| Rectangular normal | 192 × 96 | 2 per long side and 1 at each end: 6. |
| Large rectangular | 384 × 192 | 4 per long side and 2 at each end: 12. |

CaelumDiningWorld.Place builds and validates together model, collision and chairs. It is
the input to place new sets; invoke only the rectangular actor does not build its
composite collision. The table keeps references to chairs; HasSeatLayout offers the
future base for Trucazo without starting the minigame. MAP03 receives all three sets
also from previous saves. Creation is idempotent and retry if space is occupied. It does
not deliver food.

Use opens USDF 43514. Choosing to place/remove food or drink executes after closing the
dialogue and revalidating range. A personal unit is taken, outside the Box, by
operation. From 0h each table offers 4, 18 or 60 positions, depending on its size.
Objects are real Inventory owned by the table; the figures on the model only represent
them. Containers retain class, liters and weight. Withdrawal uses native pickup and
rolls back if the item does not fit; save/load retains references.

F/G activates repetition from an adjacent chair occupied in Wait. It is not consumed
while standing, sleeping, out of reach or with full reserve. While there is an active
regeneration effect is expected before another portion. Native consumables are reused:
rations are spent and containers lose drinking water without disappearing. Improvement
occurs in their usual pulses; T also processes those pulses and their expiration. Since
0h there is explicit repetition per channel; never free replacement.

### Lucidity, Sleep Skill and Orientation

Sleeping drains exactly 10 of Lucidity per second simulation, minimum zero, and suspends
all natural recovery of Lucidity. Comfort and attributes do not reduce this drainage.
Stunning caused by low Lucidity does not end sleep; damage and other current
interruptions continue to apply. Upon awakening normal recovery returns, without
restoring Lucidity at a stroke. The usual visual illumination/distortion from low
Lucidity remains visible during rest.

Arcanist user4 (Mage + Priest) implements Sleep: 10 s in area, 60 s reuse since launch,
cost trial base 1000 Anima with existing modifier. It affects Caelum combat actors and
live players with vision, including allies, excluding the launcher. Provisional radius:
magic base area 128 MU by AbilityRangePercent/100. The actor remains motionless until
the effect expires or they receive a hit; uses the same 10/s drainage and does not
regenerate Lucidity. The duration does not depend on the stunning. The other skills of
class/racial are still pending. This radius is documented as trial value, not final
balance.

PoseAngle fixes 180° with respect to the chair/cot/bag model. In addition, TEXTURES
reassigns RSDO A/B 2↔8, 3↔7 and 4↔6: The lateral views of the atlas had the reverse
order to the native. Both corrections are necessary for front, back and sides. PNG and
C–G crouching boxes are not retouched. An old session corrects its orientation once and
retains accumulated duration and recovery.

## Sleep bag and rest factors (4.35.0f)

CaelumSleepingBag derives from CaelumSpecialInventoryItem. Use the added type
KEY_ITEM_SLEEPING_BAG=2; the above maintain its values. Amount/MaxAmount are 1,
InterHubAmount=1 and GetUnitWeight returns 2 kg provisional. The bag uses the existing
routes of weight, capacity, Box, snapshots, released and collected. It does not
duplicate the content in a parallel inventory. Its current category is displayed in the
key Keys/key items filter and in All.

Enter/A on personal bag closes Journal view and sends native inventory activation.
CaelumRestTrial retains Bag/UsesBag and opens conversation 43513. Enter on the stored
bag retains the existing operation of removing it from the Box. The duration response
first closes the conversation and revalidates ownership, status, mode and space. If the
object was removed or passed to the Box, it does not deploy.

HasRoom checks the native volume and eight ground samples around a conservative radius
of 46 MU; checks external solids separately. It does not modify the player’s body. Only
then is CaelumRestBag created, as a temporary nonblocking support, and Sleep begins. The
Inventory bag remains the player’s, with its same weight. Release destroys only the
support and leaves the player where it was. Validation checks ownership/access; loss of
furniture or the item, movement, damage, water, critical reserves or map change
interrupt according to the existing contract. The Tick cleans obsolete supports from
previous hubs.

ComfortFactor is a virtual query of each support. ResourceFactor requires a valid active
session, on the source map, with its occupant and correct references; without support or
out of session returns 1. Critical reserves and death also remove the factor
immediately. Attributes and derived statistics are not modified permanently.

| Support during session | Natural Health/Air | Hunger/Thirst loss over time | Sleep |
| --- | --- | --- | --- |
| Ground | ×1 | ÷1 | Recover only when sleeping, previous rate. |
| Chair (Wait) | ×2 | ÷2 | Continues to decrease; does not recover. |
| Sleeping bag (Sleep) | ×3 | ÷3 | Recovers at the previous rate. |
| Bed/cot (Sleep) | ×4 | ÷4 | Recovers at the previous rate. |

For F = support factor:

    pérdida pasiva nueva = pérdida pasiva anterior / F
    regeneración natural nueva = regeneración natural anterior × F
    coste por punto recuperado nuevo = coste anterior / (F × F)

The last expression applies to the expenses of Hunger/Thirst associated with Health and
Air. By recovering F times more for time and paying each point to 1/F², the expense for
that time remains in 1/F. Divide only the cost per point per F would have left the
regeneration expense for time equal to the previous one, contradicting the requested
reduction. Close to the maximum is paid exclusively the recovered. The available
reserves also limit the whole cure; the accumulators retain fractions and no resource
can exceed their maximum or be negative.

The penalty of fatigue, the lock of healing by Sleep/Hunger/ Thirst critical and the
preconditions of breathing are maintained. The comfort does not apply to Anima/Lucidity,
medicine or hydration by drinking water. The air debt after immersion recovers also at
×F rate: its meter is reduced F tics base by real tic, without exceeding the outstanding
debt or maximum Air. When interrupting it resumes ×1 with what remains; no extra air is
restarted or credited at the last pulse. Outside the rest it retains the three base
seconds. Sleeping keeps 100% of Sleep by 8 hours of play as provisional value, with the
same real duration as in 0e.

Preparation 3 in CaelumRestTrial and ca_debug_rest_bag are optional and only for
MAP02–MAP05. They deliver the object by native collection if it was not in the
inventory; if capacity failure, they destroy the attempt and report. They do not fill in
resources. The ca_debug_rest_report report remains query and displays 4.35.0i/factor.
The panel displays the current multiplier and divider.

## Furniture and rest camera (4.35.0e)

CaelumRestFurniture is a fixed, invulnerable, non-pushable Actor without monster,
projectile, corpse or mobile prop flags. The existing filter of the quintessence seal
excludes it. CaelumRestChair offers Wait; CaelumRestBed offers Sleep. Its native Used
requires the actual pulse of Use, scope and vision. The guide retains the reference to
the furniture; 43511/43512 conversations offer the four durations of 0d. The answer
closes before Begin; the guide validates the context again and never replaces a lost
furniture with a session on the ground.

Begin receives an optional piece of furniture. On the ground it maintains the previous
route. With furniture, it validates mode/range, saves position and entry direction and
lends the collision of the furniture to the player. SetOrigin places the player at its
center; TestMobjLocation checks its actual volume, dry ground and compatible level. If
it fails, it returns to the input and restores the collision. Neither height nor radius
changes, and no telefrag is used.

The posture uses a temporary graphic WorldOffset adjusted to RSDO. It retains the
previous value and is only restored if it is still the one applied by the session.
Occupant identifies the user. Validate interrupts in the event of disappearance,
movement of the furniture or loss of that occupation. Finish returns the player to their
entry position if it is free, or tests eight nearby exits using the actual volume and
line of sight. If none serves, it releases the session and keeps the furniture without
collision until the player can walk out. It does not reverse external displacements,
falls, deaths or trips. The furniture tick clean obsolete occupants and replenishes the
collision only when the volume is free.

CaelumRestCamera derives from SpectatorCamera and uses its native clipping with the
player’s position as a reference. Begin/Advance initializes a single view, also for
previous sessions without camera. It does not take a camera from another system. After
the native PlayerThink, UpdateViewInput applies the twist to the orbit and keeps the
body oriented. The vertical angle is limited between -5 and 60 degrees. When exiting it
normally returns the player’s camera and the previous facing direction; if another
system changed the camera, its view is respected. Neither chasecam nor the user’s
configuration is modified. Death/map change does not restore positions or views from a
previous scenario.

Inventory saves Furniture/UsesFurniture, EntryPosition/Angle/Pitch, HasEntryView,
OriginalWorldOffset/AppliedWorldOffset and camera status. The missing fields of previous
saves start from scratch: no furniture or occupation is invented. The native save/load
test during a session retains progress and references, completes only once and allows to
reuse the cot.

The world controller prepares a pair by MAP02–MAP05. TrialSlot 1/2 identifies chair/cot
and avoids duplicates. A new field initialized as pending in previous saves allows you
to incorporate them without restarting. If the place is occupied it is repeated once per
second. No things are added to MAP01, clocks, inventory weight, resources, recipes,
rewards or dialogue breaks.

0f applies the supporting factors described above to the 0d/0d1. Pending rates in V4.35:
Accelerate simulation consistently and integrate programmed climate and events/routes.

## Rest Compatibility (4.35.0d1)

FindState receives separate literal tags for RestLying and RestSeated, both when
entering the session and when updating its pose. This prevents the String conversion to
StateLabel that GZDoom 4.14.2 rejected in the conditional expression. Full
CaelumWorldCatalogue accompanies the hotfix: IsTimelessMap remains the only common Limbo
classification for clock, calendar, Journal, and rest. It does not change saves fields,
formulas, controls, or time scale. The native compilation passed in 0d1 and the author
approved its playable tests before 0e.

## Rest and wait: normal scale session (4.35.0d)

CaelumRestRules defines two modes (Wait/Sleep) and the states no session, active,
complete, cancelled and interrupted. Supported durations: 5, 60, 240 and 480 minutes of
play, equivalent to 525, 6300, 25200 and 50400 tics. Non-catalogue entries are rejected
before multiplying. The global clock does not receive jumps or a different scale: each
map system follows its normal simulation.

The provisional net recovery for Sleep is:

    Sueño por tic = 100 / (8 × TicsPerHour)

It applies only when sleeping and once per clock-pending pulse; it replaces the passive
loss of Sleep. The result is limited to 100. Waiting retains ordinary consumption.
Hunger/Thirst, healing, anima, lucidity, air and cooldowns maintain their base rules,
with 0f supporting factors for natural regeneration and Hunger/Thirst; no gifts at the
beginning or at the end. The numerical selection of 8 hours is a test value of 0d; it is
not presented as a historical decision of the author nor as a final balance.

While the character sleeps, ApplyCriticalSurvivalDamage excludes only damage by Critical
Sleep. Hunger and Thirst continue to count, and fatigue penalties are not removed and
healing is not enabled if normal conditions block it. By stopping sleeping ordinary
fatigue rules are resumed. Hunger or Thirst <=10% block/interrupt the session; items are
not consumed automatically.

CaelumRestState is Inventory hidden, unique, non-throwable, non-deleteable by
ClearInventory and with InterHubAmount=1. It retains Status, Mode, RequestedTics,
ElapsedTics, OriginMap/Position, LastHealth, ResultKey, InputArmed and
LastClockDays/DayTics. It does not participate in the weight or the Box. The absence of
this Inventory in a previous save is equivalent to no session; only Begin creates it.

Begin validates duration/mode and context, anchors the last pulse and puts the pose.
HandleInput validates before the native logic of movement; first expects to release the
confirmation input, then Q/B, movement or action cancel. PlayerThink blocks commands
while the session is active, following the existing path of activities. Do not modify
usedown or freeze flags. Use continues by the engine when cancelling; the Journal
preserves the actual release. UpdateCrouchVisual keeps RestLying for Sleep and
RestSeated to Wait. Finish restores the standing pose only if there was still a rest
pose, without replacing death or pain. The variant on floor does not move the character;
the occupancy and output of the furniture is detailed in the 0e block.

Validate checks context, position, damage and temporal continuity. Advance, at the end
of the player's Tick, consumes at most a new pulse. A callback repeated with the same
clock does not advance; an external jump greater than a tic or regression interrupt
without granting retroactive recovery. Crossing midnight is normal. The UI shows the
campaign calendar, although the World test view has another anchor. There are no session
mutations during prediction.

Blocks/interruptions: invalid character, multiplayer, Limbo, combat, conversations/shop,
fabrication even paused, equipment, seal, pending launch, charging/reloading/blocking,
immobilization, water, movement, lack of ground, critical reserves or pending journey.
Effective damage and death pass through the player's hooks; they do not depend on
obtaining pain state. A change of map or external displacement stops the rest.
CaelumTravelService refuses to travel with active session. Cancelling/interrupting
retains only what has already happened.

The voluntary pause stops clock and session. The native save retains both inventories
and player fields; when loading they are validated without rebooting. It does not add
loading time or operating-system time. In 0d the field copy was checked off the engine;
0e adds a native save/load test during rest.

World > D/X opens CaelumRestTrial, with invisible guide and conversation 43510 from the
USDF menu without any existing pause. Actions are queued, conversation closes and guide
validated again before Begin. Close or return does not start a session. The explicit
preparations put Hunger/Thirst to 100% and Sleep to 50% or 5%, without healing or granting items. Opening/loading/travelling never applies that preset.
ca_debug_rest_report is consulted; ca_debug_rest_hit, only during one session, requests
DamageMobj from 1 with type CaelumImpact to test the interruption.

Pending items of this V4.35 block: consistent temporal acceleration and integration with
the future climate state and events. Furniture and camera have their first deployable
implementation in 0e. The engine's CVar API restricts its setters to mod variables;
i_timescale is not modified by that API or altered the player's settings. Technical
Reference: [GZDoom CVar](https://zdoom-docs.github.io/staging/Api/Base/CVar.html).Camps,
properties, broader quality factors and automatic eating away from tables remain in V5,
along with skills not yet implemented. Thermal exposure is now implemented in
5.1.0/#130 above. The safe advance was
incorporated into 0g and the repeat on tables in 0h.

## Civil calendar, campaign and Limbo (4.35.0b–0c)

Canonical start: 03/11/1889 to 09:00, fixed by the author the 2026-09-15. The campaign
uses a unique CaelumWorldClock; the calendar projects its value only.
CaelumWorldCatalogue.IsTimelessMap identifies MAP01 as Limbo by its mansion location.
AdvanceOnMap does not add any tic there. All other location, including CADEV02 and
uncategorized maps, uses exactly the common rhythm. There is no reboot when changing
map, hub clocks or time recovery of the operating system. An unexpected input into MAP01
freezes the instant reached, does not reverse it to the start. There is no playable path
back to the Limbo.

The suspension affects the global chronology. The local simulation is still active:
movement, Use, dialogue, capture, waiting and manufacturing missions retain their rules.
Hunger, thirst, sleep, healing, air, damage and cooldowns continue to use accepted
personal timers. An engine pause is not activated. Dialogues continue without pause from
0b; only outside the Limbo advance the date. Voluntary pauses maintain native behavior
on all maps.

CaelumCalendarRules is a stateless resolver. Serial zero = 01/01/0001; serial maximum
3.652.058 = 31/12/9999. The years divisible by four are leap years except those
divisible by one hundred which are not by four hundred. Invalid dates are rejected
before creating/modifying the Inventory. CAMPAIGN_START_YEAR/MONTH/DAY/HOUR centralize
the initial date and time.

CaelumCalendarState preserves Configured, TrialDate, AnchorSerial, AnchorClockDays,
AnchorClockTics and AnchorCivilTics. Since 0c adds CampaignRevision and
TrialAnchorSerial/ClockDays/ClockTics/CivilTics. The main anchor always represents the
campaign; the four TrialAnchor fields are a diagnostic view. Both use the same clock,
without another ticker or duplicate time consumption. It is native Inventory hidden,
unique, non-thrownable, not deleteable by ClearInventory and traveler between hubs. It
is not part of equipment, weight, Box or inventory rows. Cleaning the return does not
remove this state.

    deltaDays = clock.CompletedDays - AnchorClockDays
    localTics = clock.DayTics - AnchorClockTics + AnchorCivilTics
    fecha     = AnchorSerial + deltaDays + acarreo de localTics
    hora      = localTics normalizados dentro del día

The DateSerial(clock), CivilDayTics(clock) and FormatDate(clock) queries return the
campaign. The optional argument trial=true explicitly requests the active test. This
query does not write status. Check limits before adding and does not wrap a date out of
the year 9999. A clock prior to anchoring is invalid. The initial date is also created
in MAP01, before deciding whether the tic should move forward. The individual confirmed
profile requirement is maintained.

CampaignRevision=0 identifies the previous or newly created state. EnsureCampaign
anchors 03/11/1889 09:00 to the current clock and marks 1 revision. Discards the
inherited test date, preserving the clock and character records. It is a migration
without reconstruction of the past: 0a/0b also counted the time of the Limbo and do not
allow to separate that interval. In 0c save/load restores clock and both anchors, and
travel retains the same Inventory. Reinitialize does not modify an already established
revision.

Optional test commands:

    netevent ca_debug_calendar_set AÑO MES DÍA
    netevent ca_debug_calendar_edge
    netevent ca_debug_calendar_report
    netevent ca_debug_calendar_clear

set assigns the date to the test anchor and takes the current campaign time. edge
changes only the test to 23:56, 12 s real simulated before midnight. Both stop at MAP01;
edge warns that the change is checked outside the Limbo. They do not advance clock,
needs, cooldowns, manufacture, missions or travel timestamps. report is read only and
displays the campaign even if World is showing the test. clear disables the diagnostic
view and lets see the campaign date reached, without restarting, removing or anchoring
it. Tests created and saved in 0c are preserved when loading; a new game does not
inherit them. Modify requires individual and unpredicted live character. Future events
should consult the campaign, no trial=true.

World shows southern date and monthly season: summer December–February; autumn
March–May; winter June–August; spring September–November. This convention remains a
test; November 1889 is shown as spring, without determining equinoxes, climate,
temperature, light or thermal exposure. Rest, temporary advancement and environmental
status were added in V4.35; character thermal exposure is implemented in
5.1.0/#130 above.

## Class and racial abilities: agreed design; Sleep implemented in 0g

4.35.0g update: Arcanist Sleep is implemented above with the requested Lucidity drain.
The rest of this catalog retains its design status.

The decisions from the discussion on 2026-09-14 are recorded here. There are no new
playable User1/User4 effects in 0b or 0c. The roadmap assigns these abilities to V5
after the playtest export. User2 remains dedicated to Seals and User3 to Tarot.
Attributes, existing costs and accepted controls are unchanged.

Class abilities last 10 seconds, with 60 seconds of cooldown. Initial base cost for testing: 1000 Anima per activation; it is not a final balance. Reuse is the wait
until you can activate again, like seals. The application of cost modifiers and the
precise time when that wait begins will be integrated with your activation contract; no
additional formula is invented in this patch. The aura radii remain to be defined.

| Class | Ability | Agreed effect for 10 seconds |
| --- | --- | --- |
| Warrior | Battle Cry | Intimidates within the area. Terrified targets cannot perform physical attacks or attacks with ranged weapons. |
| Explorer | Survival Instinct | Blocks all negative states and loss of survival resources. |
| Priest | Miracle | Restores 1% of Lucidity, Health, Anima and Air per second. |
| Mage | Brainstorm | For each distinct cast, the next three within the window receive reductions of 100%, 50% and 25%. Fire and AltFire count for each weapon, and an attack charged with R counts as a separate spell. |
| Mercenary | Killer Instinct | Triples critical chance and Adrenaline gain. |
| Cleric | Rally | Restores 1% Adrenaline per second to nearby allies. |
| Battle Mage | Deafening Cry | Prevents nearby enemies from casting spells, abilities and seals. |
| Pilgrim | Pilgrim’s Protection | The character and nearby allies receive 50% less environmental damage. |
| Investigator | Levitation | Allows flight for approximately 10 seconds. |
| Arcanist | Sleep | Targets remain motionless and wake when hit. |

Protection replaces Bless Food. It does not grant healing, food, drink or reduction of
combat damage. Classification depends on the origin of the damage: an environmental
flame is reduced; a fire spell in combat retains its damage. The system of dangers must
retain that origin, including persistent effects; it is not enough to deduce
"environment" from a null attacker.

Races: toggles that consume Anima while active, with costs awaiting balance decisions. The
author's initial indication of a minute of cooldown and 10 seconds of duration is
retained; "toggle" does not authorize unlimited duration alone. It must be able to
switch off manually or by exhaustion, releasing interaction. The cost of 1000
corresponds to class skills, not to racial consumption per second.

| Race | Ability | Agreed effect while active |
| --- | --- | --- |
| Beast Man | Hunter’s Instinct | Triples stealth and critical chance from behind. Does not triple critical damage. |
| Human | Socialization | Doubles Dialogue skill and Persuasion. Anima consumption continues during unpaused conversation. |
| Duende | Telekinesis | Moves objects remotely, with Anima cost based on weight. |
| Caelith | Name pending | Consumes Anima instead of Air. |

Mage + Explorer = Investigator; Mage + Priest = Arcanist. Unapproved proposals on new
immunities, food cure or changes of attributes do not replace these definitions.
Cleaning of previous states of Survival Instinct, racial costs, radii and accumulation
between effects need to be concrete when implementing; they are not simulated with false
bonuses.

## Global clock and travel timestamps (4.35.0a)

Authority: CaelumWorldClock, Inventory native hidden, non-throwable, not deleteable by
ClearInventory and with InterHubAmount=1. It is not equipment, material or a second Box;
it does not participate in the weight or rows of the inventory. It retains two int:
CompletedDays and DayTics. It does not copy operating system time or Level.Time.

CaelumWorldClockTicker is StaticEventHandler and does not serialize a copy of the
counter. WorldTick only acts with one participant, Caelum character, confirmed profile,
closed and unpredicted creator. From 0c initializes the calendar and each native tic
adds one to the counter only outside the Limbo. The controller also exists when loading
old saves: create the Inventory if missing. A new game replaces the character and its
record; a hub transports the same Inventory. No persistent global CVar is used.

    TicsPerHour = REAL_SECONDS_PER_GAME_HOUR × TICRATE = 180 × 35 = 6300
    TicsPerDay  = TicsPerHour × GAME_HOURS_PER_DAY = 6300 × 24 = 151200
    Hora       = DayTics / TicsPerHour                       (entero)
    Minuto     = (DayTics % TicsPerHour) × 60 / TicsPerHour    (entero)

When the day is completed, CompletedDays is increased and DayTics is reset to zero. The
integer limit saturates to prevent overflow and time reversal. Three simulated real
seconds represent a minute of play; a full day represents 72 real minutes. These are the
constants already used for survival. No double consumptions or formula changes when the
clock is incorporated.

World consults directly the Inventory. Outside the Limbo shows recorded time; inside
indicates that it is stopped. The bottom line shows the campaign calendar of 0c or its
explicit diagnostic view. The zero of a previous save is the beginning of the new
record, not a statement about how long the previous game lasted. The pause is inherited
from WorldTick. From 0b the Caelum conversations continue to simulate, just like the
Journal. The voluntary engine pause stops the clock; the dialogues themselves no longer
stop it. Death does not impose an additional pause on the world if the engine continues
to simulate.

CaelumJourneyState adds HasDepartureTime, DepartureDays, DepartureDayTics,
HasArrivalTime, ArrivalDays and ArrivalDayTics. Begin records departure after validation
and before ChangeLevel; deletes the marks of the previous journey. Update records the
arrival only once at the expected destination, with compatible pending connection and
timestamped departure. An interruption is not presented as arrival. New fields in 0e
saves start without known timestamps; they are not refilled retroactively upon
consultation of an already resolved arrival.

FormatStamp is a common query. netevent ca_debug_time_report does not create or modify
the clock, and ca_debug_travel_report includes the available timestamps. A time jump per
console is not enabled in 0a: rest, journeys with duration, events and integration of
the affected systems are subsequently implemented on this same temporary authority.

## Activity testing support (4.34.0e)

CaelumSewerTrialSupport installs the native classes CaelumWorkbenchStation,
CaelumSawmillStation and CaelumForgeStation with 43414 network group. Each link measures
56 MU within the current limit of 64. It only acts on MAP02–MAP05. The new
SewerSupportPrepared field of the controller starts false in the 0d; FindStation avoids
recreating nodes that already exist. It does not modify WAD. Forging meets the existing
requirement for the Handle component; it does not alter the catalog to pass the test.
args[0]=0 retains immobility.

The two new actions share the USDF session checks: self-guide, interlocutor player,
current origin, unique action and no prediction. They are queued and executed after
closing the conversation. Prepare to re-check CanDepart and only then grant the help,
without creating JourneyState. The USDF pages and ids of 0d are preserved; responses are
added at the end of the offer, before the native "Cancel". Open, look or cancel does not
grant anything.

Seal: A T1 quintessence possessed instance is sought and the
ApplyFormalInventorySelection/EquipSelectedNativeEquipment. route is used If missing, a
native instance is created with ItemId. Only the explicit option adds adrenaline to the
maximum derivative and sets the cooldown to zero. It does not change
CombatTimeRemaining, attributes, weapons, consumption or the start/cancellation of the
channel. If there was another seal, it is saved without equipping. The channeling uses
the usual seal control of the equipped weapon; use or travel never reload this help.

Crafting: learns Recipe() from the catalog and complete the native wood stack up to
GetComponentInputUnits(BATCH_INDEX=1): 40 units. Keep its personal/Box location and
check your weight. It does not grant Box, finished products or artificial reservations.
FocusRecipe only acts on this network, with a known recipe and no task in progress: T1,
x10 batch, efficiency index 2 (100%). The player starts, pauses, resumes, cancels and
completes by the actual controls. Close Crafts leaves the task reserved pending; that
state blocks the journey. Time and production are calculated with the current functions.

When opening Crafts with Use, the Journal lets the KeyUp event pass to the engine from
the natively linked key to +use. Before it was consumed; the internal button was
retained and the next press after Q could not reopen the station. KeyDown, arrow keys,
Home/End, tabs and PgUp/PgDn. are retained.

## Test caravans and movement cycle (4.34.0d)

TAB > World > C opens a USDF offer in MAP02–MAP05. MAP02 offers MAP03, MAP04 and MAP05;
each module offers MAP02. The existing 2–7 ids are retained. The destination selection
and "Back to Destinations" only change the native page. "Cancel" closes the service
without recording a departure. "Confirm departure" delivers an ephemeral action that
only accepts the interlocutor, player, origin and session itself, with a single queue
connection. The invisible guide is removed when the session is over; it does not occupy
the map or modify narrative NPC.

CaelumCaravanGuide waits for the native closing of the conversation and then calls
CaelumTravelService.Begin. It revalidates the entire departure. CaelumSewerTravel.Begin
retains range/height/visibility/placed-actor checks and uses the same service with foot
mode. Only sewer paths, confirmed profile, live player outside the creator, no
prediction, incompatible session, active channel, active manufacturing, total freezing
or other player are allowed. The destination must exist and cannot be MAP01. One pending
departure prevents another. Failures prior to commit do not create history or charge.

The new CaelumJourneyState is Native Inventory, hidden and non-throwable. It does not
change the fields or capabilities of CaelumPersistentCharacterState. It is created by
starting the first new trip, never by reading World or opening the offer.

| Field | Meaning |
| --- | --- |
| Sequence | Departure number; increases once per Begin accepted. |
| ConnectionId | Points to the existing catalog. |
| TravelMode | 1: on foot; 2: test caravan. |
| Status | 0: no trip; 1: pending departure; 2: arrival; 3: interrupted. |
| Arrivals / Interruptions | Amounts resolved once; saturated in INT_MAX. |

Departure is recorded alongside WorldPendingConnection before ChangeLevel. Update runs
before WorldProgress consumes that brand. It only credits the destination that matches
the ID and pending departure; another location interrupts. A save loaded while still at
the origin interrupts and releases its own marker, without traveling by surprise or
erasing another system’s marker. A resolved departure is not counted again. The existing
load observer performs this reconciliation before reopening, if applicable, the native
conversation saved. 0c saves keep visits and connections; they are not credited with
previous trips without evidence.

The test does not apply tariff, additional consumption or temporary advance. The normal
consumption that already occurs during active play is preserved. It does not fill
resources, heal the player or copy inventory and does not execute the prizes or cleaning
of the prologue. The mode/status/sequence form the base of integration of the clock and
subsequent events; there is not yet a planner or transport simulation. World shows the
last trip on a line. Its history of places/routes and the controls of Inventory/Quests,
arrows and PgUp/PgDn are preserved.

## Sewer and test travel network (4.34.0c)

The current authorization allows new sewer maps for testing. MAP01 is the prologue
without reverse access. MAP02 maintains its WAD and PlayerStart. MAP03–05 are new maps
generated from UDMF modules, without ACS or Doom assets. Native cluster/hub 434 is used
for MAP02, MAP03, MAP04 and MAP05 only.

| Connection ID | Origin | Destination | Activation |
| --- | --- | --- | --- |
| 1 | MAP01 | MAP02 | Existing narrative return, with confirmation and cleanup. |
| 2 | MAP02 | MAP03 | Reservoir gate, Use. |
| 3 | MAP03 | MAP02 | Gate back, Use. |
| 4 | MAP02 | MAP04 | Tarot chamber gate, use. |
| 5 | MAP04 | MAP02 | Gate back, Use. |
| 6 | MAP02 | MAP05 | Maintenance gate, Use. |
| 7 | MAP05 | MAP02 | Gate back, Use. |

1/2 location ids are preserved; 3/4/5 identify new maps. LOCATION_CAPACITY and
CONNECTION_CAPACITY are still in 32 and WorldStateVersion in 1. New array positions are
born false in previous saves. origin/destination of the 1 connection and migration from
0 version remain unchanged. The pending arrival 1 needs proof of return; 2–7 connections
need to reach their respective destination. Another destination discards the attempt.

CaelumSewerTravel prepares reconstructable accesses from the existing controller; its
new preparation flag initializes to false when loading 0b. Before placing an access it
looks for an instance with the same id. It does not modify the MAP02 WAD or add a
missing handler to its save. The gates are fixed, not Shootable, without gravity, with
CANNOTPUSH/DONTTHRUST and its own wall sprite. Its destination is shown by looking at
them at a short distance with a line of view.

Begin requires live and confirmed character, valid map/origin, gate placed, Use range
plus its radius, vertical difference <=64 and direct view. Reject creator, prediction,
conversation, trade, menu/task of crafting, Journal, active channeling, freezing and
other players in session. MapExists is checked before modifying inventory or marking departure. A pending request prevents doubling the trip. Refuse does not cancel tasks or
lift freezes. Accept leaves the combat controls ready, saves the character and requests
ChangeLevel with NOINTERMISSION, without resetting health or inventory.
PreTravelled/Travelled native hooks remain in charge of the same authority; do not
create copies of equipment or cleanings of the Limbo.

Arrival uses PlayerStart 0: (-236,32,0) in MAP02 and (0,320,0) in MAP03–05, looking
north. Reverse gates are in (0,96,0), behind arrival. No contact trip is activated;
Sustained use does not reach the gate from the appearance position. Inactive map states
are serialized by the GZDoom Hub, also inside the session save. No actors are saved in a
second structure of their own nor are the collected objects rebuilt.

World shows five possible visits and up to three departures from the current location.
Discovering requires approaching 256 MU and having valid visibility/height; it does not
mark visited destination until entering. Outbound and return routes are independent. The
UI reads the Inventory; for the label of the gate reads the visibility that your Tick
calculated, avoiding gameplay queries from the UI. Arrows and PgUp/PgDn retain its
functions and do not execute trips.

The generator uses native sectors and collisions. MAP05 has two wide 256 MU stairs,
eight treads of 64 MU and 12 MU risers, up to +96 MU. Visual channels are reduced only
12 MU and do not declare damage, immersion or new water rules. MAP03 does not create
large numbers of actors automatically; MAP04 does not grant cards; MAP05 reserves hazard
tests for its block. Cooperative, costs, caravans or simulated travel duration are not
accredited.

## Grouped doors and accesses (4.34.0b)

CaelumSlidingDoorLeaf preserves ClosedPosition, SlideProgress, HoldTimer, DoorRequested,
LockedSoundCooldown, RuloArenaLocked and AccessCondition. It does not change its
serialized scheme. args[0] > 0 links leaves; zero or negative ids are considered
individual doors. args[1] retains a sense of displacement, args[2] the X/Y axis, and
args[3] the LOCKDEFS lock number.

RequestDoorGroup maintains sight checks and vertical overlap on the used leaf; it
rejects dead or predicting player requests. It accepts NPC requests on free doors, such
as the existing Palomo route. It runs through the group and checks arena lock, native
key and reputational status of all its leaves before activating any. A rejection leaves
requests and timers unchanged. The key does not satisfy membership/reputation nor arena
lock, and an unlocked leaf does not avoid the requirements of its companion.

CheckKeys(lock, false, true) query without issuing feedback. Upon rejection and with the
available timer, CheckKeys(lock, false) presents the native motif and sound; it does not
consume the key. 200/201 and 202 locks solve caelum/world/door_locked, the existing OGG.
Dual manual reproduction is removed and the seven tics timer is retained.

PlayerOccupiesDoorway uses ClosedPosition: half-width 32 MU and half-depth 4 MU of the
leaf/blockers, expanded by the player's real radius, with vertical overlap according to
its height. It measures the doorway even when the leaf has moved aside by 64 MU.
GroupDoorwayOccupied checks the leaves of the same group and HoldOccupiedGroup
holds/reopens the set with 18 tics waiting. It is consulted when the wait is exhausted
or during closing; without occupation it maintains 64 MU route, 4 MU steps by tic and
normal 105 tics wait.

The presence only reopens a door that already has SlideProgress > 0. It does not open a
locked door without a key. If the key is lost during the pass, it allows to leave; once
closed it again demands it. RuloArenaLocked maintains the previous forced closure and
the priority of the Bull test. Occupation protection is for players; do not redefine the
general physics of NPCs/objects.

### Access test

CaelumDoorAccessTrial is an optional Inventory without weight or visible row. It saves
references of two leaves and PresentationMap, using the native save. It does not add
fields to the persistent profile or change the locations/connections record.
CaelumDebugDoorTrial creates it 128 MU in front of the user, with native space checks in
the closed/open positions. If there is no place, it does not install half door. It uses
a free positive id above the existing ones; one leaf has zero lock and the other 202.
Repeating action does not recreate a valid presentation.

CaelumDebugDoorKey delivers CaelumDoorTrialKey only with the test enabled. It is an
independent native Key, reusable, without weight or row of equipment; it does not
replace CaelumSilverKey, it does not count for the mission or enable 200/201.
CaelumDebugDoorTrialOff removes the marker, its leaves and that key; the small blockers
remove its orphan reference in the next tick. It retains the silver key and the other
items/records. On another map, the presentation can be requested again; it is not
automatically reconstructed in the campaign. The narrative cleanup of the Limbo
continues to remove the physical Keys that correspond.

The test requires created/living character, out of prediction, no dialogue, trade,
station/task manufacturing or active channeling. It does not change those states to be
able to open. The three commands are detailed in PRUEBAS_4_34_0b.txt. netevent
ca_debug_door_report reads only the presentation of the applicant and its keys; it does
not evaluate opening actions, grants objects or repairs the save.

## World and persistent journey (4.34.0a)

CaelumWorldCatalogue assigns 1 location to MAP01, 2 to MAP02 and 0 to "unregistered".
The 1 connection goes from MAP01 to MAP02 and represents the existing return. There is
no reverse connection. ids are independent of translated names and visual order; CADEV02
and undefined names return 0, with no usable destination. Reserved capacity: 32
locations and 32 connections; booking slots does not create content or convert those
limits into the final campaign size.

CaelumPersistentCharacterState retains WorldStateVersion (1), the Booleans
WorldLocationVisited, WorldConnectionKnown and WorldConnectionTraversed, and
WorldPendingConnection (0 = none). Previous saves start those fields at zero. Authority
is the native traveller record, without duplicating it in CaelumPlayer, map actors,
CVars or interface.

CaelumWorldProgress.Update runs from the existing controller after updating the
prologue, before scheduling and departure. It only acts with confirmed character, alive,
outside the creator and prediction, and an existing ProfileCommitted record. It marks
the current valid location; it does not create a character record by opening a screen.
The exit’s IsReady reveals the connection, preserving the undiscovered destination until
you visit it.

The first update migrates WorldStateVersion 0. Only if the player is already in MAP02
and MAIN_M00 retains final state/stage, COMPLETE, INVENTORY_SANITIZED and
STARTER_WEAPON_PRESERVED does it reconstruct the mansion visit and return route. Those
facts are read and no commit is executed again. On a direct start of MAP02 without that
closure, only the current visit is recorded.

After satisfactory commit and just before the existing ChangeLevel the pending
connection is marked. The observer does not validate or initiate an alternative trip. If
you arrive at the destination with the closing evidence, the route is recorded and the
mark is consumed. Another arrival or invalid id discards the mark without granting a
tour. As long as it remains in origin, the mark does not count as arrival. Native
controls and checks of the door are maintained.

TAB > World reads FindInventory (native consultation clearscope), without setters or
status copy. Displays current location, known visits and return: status Known/Traversed,
destination by undiscovered/visited and indication of one way. It is not a travel
selector. Left/Right changes to Character/Crafting; PgUp/PgDn or LB/RB retains direct
tab change. Inventory and Missions retain their filters/selection and output to adjacent
tabs at the ends.

`netevent ca_debug_world_report` uses the player’s network request and only consult
existing fields. Repeat it does not discover places, advance a mission, grants a
card/reward nor changes health, reputation or merchandise. The names of maps are reused
from LANGUAGE; Spanish and English aids of World are added. Time, weather, map layouts
and travel services remain pending from its numbered V4 blocks. The inherited and
cross-system pending work are developed in V5 after export testing.

## Integration and consultation contract (4.33.0ao)

The static observer CaelumConversationResume receives the load of saves, including those
prior to 0ao. WorldLoaded marks only IsSaveGame and the first WorldTick consumes that
mark. For a living/created character, out of prediction, only the active native
interlocutor whose ConversationPC is that same player reopens. StartConversation retains
the available tree and uses ConversationFaceTalker with saveAngle=false. It does not
execute Used or replies. An inactive reference remains inactive; the normal map entry
does not reopen. The observer does not serialize references or progress and does not
replace native conversation closures. The need is reproduced with the MAP02 Voice
self-saved: the actor remains active when loading even if his menu has disappeared.

netevent ca_debug_integration_report uses NetworkProcess from the Journal and consults
the player at that event. CaelumIntegrationDiagnostics reads the persistent Inventory
with create=false and travels through only the two diagnostic missions defined. It does
not use setters, Sync, Ensure, Persist or reward actions; it does not create saves
fields. The resume observer described above is independent of this query. The service
classes continue to validate your requests by their existing authoritative routes.

The query shows separate states, objectives, delivery and possession of a receipt:
Losing a receipt after receiving it does not erase delivery. An active mission with full
objective still requires confirmation for complete/claim. Shows faction requirements and
its current result without closing sessions or recomposing a quote. A transitory result
of the diagnosis does not replace validation in the commercial or door operation.

The narrative exit retains its rules: explicit confirmation, own box, El Loco and
identified first weapon; manufacturing task must be resolved. The fade closes trade and
activities; cleaning removes temporary physical equipment/items, including coins and
products purchased in the test. CaelumQuestRouteReceipt, CaelumQuestWaitReceipt and
CaelumReputationTrialState are Inventory markers independent of those physical classes
and survive, along with the quest/faction. registry The first weapon remains in the Box.
membership/reputation is not derived from the equipment being removed.

Wait uses active game tics and its progress save, without delivering a receipt until
confirmed. The narrative arrival takes priority over opening the reputation test; then
its guide is rebuilt for the owner in MAP02. It does not change the travel failure
policy or create missions automatically.

## Reputation and service conditions (4.33.0an)

CaelumFactionCondition is a serializable Object with Configured, FactionId,
MinimumReputation and RequireMembership. Create retains even an invalid configuration
for it to fail closed; does not convert it to null. null means the service does not
declare requirement and maintains previous behavior. Valid ids are Unitarians=0,
Federals=1, Free Peoples=2, Caelith=3, Cult of the Tarot=4 and Sun Warriors=5.
A minimum outside -1000..1000 or an
unconfigured condition is invalid.

Check consults the persistent registration of the applicant player, alive and created,
outside the wizard and prediction. It does not create records or modify values. The
minimum is inclusive; RequireMembership also requires true membership. Requires the
localized motif. It does not derive a narrative rank or apply reputation of another
faction or local player to a foreign request.

OpenDialogue checks interlocutor, health, active conversation, distance from 160 MU,
line of view and condition before starting USDF. The caller can pass view flags; only
the invisible diagnostic guide uses SF_IGNOREVISIBILITY, preserving the geometric
occlusion. The condition protects the input: does not retroactively interrupt a dialog
already displayed.

CaelumSlidingDoorLeaf.AccessCondition is optional. RequestDoorGroup retains keys, arena
lock, height, view and movement above; before changing any leaf, check the conditions of
all leaves with the same args[0]. Using a leaf without condition does not prevent the
requirement of another in the group.

OpenPalomoMerchant receives optional access and discount requirements and a title key.
The above callers are without condition. The session checks access when opening, every
four tics and confirming, before moving goods/money. If you change the price shown,
update the quote and request another confirmation. The existing validation of distance,
stock, funds, capacity and quantity continues in the authoritative transaction.

PalomoMerchantReputationDiscount is a temporary view of the active condition; it is not
written in PalomoDiscountGranted. The persistent negotiated discount is retained. Either
activates once the existing margins: the player buys at 140% and sells at 60%, versus
normal 150% and 50%. No new economic curve is added and no currency is created. Closing the session clears its conditions and temporary view. The test shares the prototype's catalog, inventory and
commercial box; it does not implement separate inventories per merchant.

CaelumReputationTrialState is a hidden Inventory, without weight or reward, enabled only
by giving CaelumDebugReputationTrial. Activation does not change reputation. Journal >
Reputation > F/Y only opens it if it is already enabled. The USDF 43322 menu provides
information (43323), door, trade and five explicit states. Actions are supported only
from the active dialogue of your own guide; they are executed when you close it. Presets
Unitarians: 0/no, 25/no, 25/yes, -25/yes, 0/yes. The other factions are preserved
and the changes are saved by the existing APIs.

Information requires 25; door requires 25 and membership; trade requires 0 plus the
usual own Box; reduction requires 25. They are diagnostic conditions. They are not assigned to residents and do not create ranks, relationships or campaign benefits. The door
reuses a native leaf; it requires free space in front and in its sliding, with its own
group to avoid affecting map doors. It does not create a closed room. The guide
is invisible and exists only after the test is enabled.

The status and its references are saved natively. By changing the map it is kept enabled
and guide/door is recreated when needed again; the presentation is not duplicated when
re-opening. give CaelumDebugReputationTrialOff, with its closed menus, removes the
wizard and its actors, without restoring reputation values or used goods. Previous saves
do not activate this test, and their shops/doors without condition remain the same.

## Seals and interaction (0ak), conversation and navigation (0am)

HasActiveConversation checks that ConversationNPC exists and that that actor has
bInConversation. The reference can survive the closure and must not block by itself. The
essence uses this criterion in Used and in the wait before its animation. BeginCapture
retains the requirement of the correct interlocutor, its active dialogue, its own Box,
phase and revelation. Only CommitCapture with the finished animation records the unique
card and its current bonus.

The return door applies the same criteria when opening, waiting for closing and
confirming the transfer; the MAP02 Voice also expects a real active dialogue. No
conversation references are removed or serialized fields are altered to apply the
arrangement. An inactive referenced save can interact when loading, but loading never
captures or confirms departure.

Adrenaline exhaustion calls StopSealChannel(true); after that closure the cooldown only
prevents restarting the seal and does not block Use. The 0al log indicates another
condition: present conversation reference with inactive NPC. netevent
ca_debug_fool_report retains explicit query of requirements, Box,
menus/channel/conversation and proximity/visibility, without mutating the state.

The channeling selects fighters, corpses and projectiles, excluding Inventory and
CaelumMovableProp. Trees, resource nodes and stations can be SHOOTABLE due to their
interactions, but they are not targets of the seal: they are not attracted, rotated,
ejected or added to captured mass. The formulas of force, radius, mass, elemental
effects, drain and cooldown are preserved for combat.

A new push of Use during the channeling ends it with StopSealChannel(true), with valid
target ejection and the normal cooldown. That same press continues until the engine
interaction. Keeping Use already pulsed does not generate another interruption. Catching
El Loco uses its existing native path: valid phase, own box, conversation and
confirmation. Interrupting the seal or loading a save never grants a card by itself.

MAP01 serializes ChannelInfrastructureRecovered. If missing in a save, after preparing
the current arrangement the position of the plants is restored only once from SpawnPoint
and from the stations by class/room group. The actors are reused, preserving remaining
resources, fractional yields, tasks and reservations. Undue speed and gravity are
cancelled and the active station is revalidated. Workbenches do not use their old
outdoor SpawnPoint. The garden is not regenerated or geometry modified. Releasing
GravityTargets from a save also clears the unintended suspension of fixed
infrastructure; the rest recovers its previous gravity mark.

| Journal context | Left/Right | Other control |
| --- | --- | --- |
| Inventory | Previous/next filter; at the ends, Tarot/Character tab | F/Y advances filter; Up/Down chooses object; PgUp/PgDn changes tab |
| Missions, List or Detail | Previous/next known quest; at the ends, Crafting/Reputation tab | Up/Down select from list or scroll Detail |
| Crafts with open station | Preserves recipe/contextual option | PgUp/PgDn or LB/RB comes out of the tab and closes the session |
| Rest of tabs | Previous/next tab | PgUp/PgDn or LB/RB does the same |

PgUp/PgDn (PgUp/PgDn) and LB/RB change from tab across all sections, including Missions.
Change mission, hide Detail or change tab cancels a pending abandonment confirmation.
Navigate does not accept missions. With a single registered mission, Left leaves to
Crafts and Right exits to Reputation. With several, undiscovered entries are skipped; it
does not return to the opposite end when the horizontal list is exhausted. Upon return
the selection is retained. Up/Down retains the circular path of the list and the Detail
scroll; F/Y retains the filter cycle of the inventory. The four resident tests are
MAIN_M00 stages, not four independent inputs. Navigate does not discover the optional
diagnostic missions.

## Optional missions — current in 4.33.0aj

Status per character in CaelumPersistentCharacterState, retaining its 32 slots and eight
objectives per mission. Indexes: MAIN_M00=0, test Tour=1, test Wait=2. The Journal only
expands its snapshot to three entries.

| State | Stable value | Transitions allowed |
| --- | ---: | --- |
| Unknown | 0 | Offered by explicitly discovering it |
| Active | 1 | Completed with completed objectives, failed by its controller or abandoned if allowed |
| Completed | 2 | None; outstanding delivery is managed separately |
| Failed | 3 | None |
| Offered | 4 | Activates by accepting and complying with the requirement |
| Abandoned | 5 | None |

The above 0–3 values remain unchanged. MAIN_M00 retains its own activation; legacy
setters are limited to that mission and do not allow for changing an end or its
objectives afterwards. New missions use CaelumSideQuestRules:
requirement/objectives/reward/abandonment metadata and life-cycle operations. An event
cannot progress a offered or completed mission, change the goal or exceed it. Completing
requires all its known and achieved objectives. The base demonstrates a complete mission
dependency; composite conditions, various prerequisites and economic/Tarot rewards are
not added to this block. The MAIN_M00 narrative controller is not migrated to another
architecture.

Each current reward is a unique native Inventory. QuestRewardClaimed[32] records the
delivery, regardless of whether it retains the object. A rejected receipt does not mark the reward as claimed and allows a retry; completion and claiming are separate operations. The
two test receipts are different classes, with MaxAmount/InterHubAmount 1, without
weight, price, attributes or consumption. It is reported to be delivered in the Journal;
they do not appear among the usable equipment. XP, cards, coins, recipes or campaign
materials are not awarded.

Test enabled only by giving CaelumDebugQuestTrial. Repeat only discovers offers that are
still unknown: do not restart orders or rewards. - Tour: Acceptance records
position/map. Moving at least 128 MU in XY, with a Z difference below 32 MU, completes
the objective. Change map before you achieve it, or die before, produces failure. Enter
completes the quest and claims the reward. - Wait: it requires completed Tour. OK starts
five seconds of tics of the game. An observed decrease in health or death before
achieving it produces failure. The counter and its progress persist through saving and
travel; no real clock is used nor global time is accelerated. With the goal ready, Enter
completes the quest and claims the reward. give CaelumDebugFailQuestTrial allows to
cause that end directly for diagnosis, without causing damage.

Both tests allow abandonment and cannot be restarted in the same playthrough. To compare
outcomes, load a save from before acceptance. Times/distances are diagnostic parameters,
not campaign balance. Health observation compares health between tics; it does not yet
represent a universal system of conditions based on all damage events.

Journal → Missions: Left/Right selects; Up/Down also in list. F/Y opens the selected
Detail; Enter/A accepts or completes/claims; G/X requests abandonment and another
separate click confirms it. Keeping the key does not confirm. Close, change
quest/section or hide Detail cancels the confirmation. In detail, Up/Down retains its
pagination. MAIN_M00 cannot be abandoned by these controls. The UI sends the selected
index by event and the authoritative handler validates state/requirement.

The new fields start empty in 0ai: loading does not enable the test or reset the
profile, attributes, previous quests, containers or choices. Persistence uses native
save and the same Traveler Inventory. Automated test modes remain out of delivery.

## Survival consumption and regeneration - current in 5.1.4 (#131/#133/#140)

Constitution controls passive Hunger, Thirst and Sleep consumption, as well as
Hunger and Thirst expense from player health, Air and Anima regeneration.
The #140 quarter-Health rule supersedes #133's water-free Air recovery.
The author reassigned Sleep
from Resilience in #131; the new Type-2 divisor (#154) and original mass rules remain.
Resilience now controls climate adaptation rate/range and retains its existing
combat benefits (maximum Air/Adrenaline and health regeneration).

    A = máximo(0, atributo efectivo)
    divisor D(A) = 1 + 3 * (A*A + 25*A) / 12500
    factor de Hambre/Sed = (masa corporal / 100 kg) / D(Constitución)
    factor de Sueño = 1 / D(Constitución)
    factor de coste de Hambre/Sed al regenerar = 1 / D(Constitución)

| Attribute | Divisor | Consumption with respect to 0 attribute, same mass |
| --- | ---: | ---: |
| 0 | 1 | 100% |
| 50 | 1.9 | 52.631579% |
| 100 | 4 | 25% |

New Type 2 is not linear. Fractional levels and growth above 100 are preserved without zero
consumption. The formula uses effective attributes, with its current bonuses; the weight
of the equipment is not body mass.

Base times to empty a full reserve, without other consumption: Hunger 24 hours of play,
Thirst 12, Sleep 16; one hour of play is 180 real seconds. At 100 kg and attribute 0,
these equal 72/36/48 real minutes. At attribute 100, they become 288/144/192 minutes.
Other masses only modify Hunger/Thirst.

Regeneration cost is calculated from the fraction of maximum health/Air/Anima actually
recovered. Constitution now also divides that cost; the body mass factor of passive
consumption is not applied again.

| Natural recovery | Base cost of Hunger | Thirst base cost | With Constitution 100 |
| --- | ---: | ---: | --- |
| Maximum health 1% | 1 point | 0,5 points | 0,3333 / 0,1667 points |
| Maximum Air 1% | 0.25 points | 0.125 points | 0.08333 / 0.04167 points |
| Maximum Anima 1% | 0.25 points | 0.125 points | 0.08333 / 0.04167 points |

Each cost is divided by D(Constitución), also when calculating how much can be recovered
with the available reserves. Only the recovered amount is charged, with non-negative
reserves. Full Air or Anima recovery therefore costs 25 Hunger / 12.5 Thirst before
modifiers, one quarter of complete Health recovery (100 / 50), regardless of each
bar's maximum. Existing rest divides cost per recovered unit by comfort squared;
its speed bonus remains, and panting adds the specified Air speed factor. These
food/water costs are player-only; NPC recovery gains the breathing factor without
new Hunger, feeding behavior or recovery water charges. Passive Hunger/Thirst
have no abstract cold/heat multiplier; sweat is charged by secreted water mass.
Resilience continues to
accelerate health recovery and increase the maximum Air. The return in three seconds of
the Underwater Air debt keeps its route separate, which no longer consumed
Hunger/Thirst.

This explains the previous observation: the cost of regenerating did not receive the
reduction of Constitution and could hide its effect on passive consumption. The drinking
pool maintains its recovery of Thirst from one point per second; the sips and their
volumes retain the approved rules of 0ag.

When a previous save is resumed, only both factors are recalculated before the next
consumption, without restarting reserves, attributes, missions or inventory. The stored
value is not re-divided: it is reconstructed from the attribute and mass, avoiding
accumulation and correcting old serialized zeros.

Hunger, Thirst and Sleep to 10% or less are critical: each adds health drain at the unmodified base regeneration rate and blocks natural regeneration. The rule prior
to 0ag is restored at the author's request. To regenerate health again, all three
reserves must be above the 10%. Performance penalties and regeneration costs remain in
place.

## Audit of the twelve attributes — current code 5.1.10 (#154)

Comparison with the table provided by the author. The calculations and their consumers
in play were reviewed: a calculated field or an isolated timer does not amount to a
finished mechanic. The four families and their three members agree. The following
differences separate implementation from intent; they do not themselves authorize new
combat changes in this patch.

To avoid r/l/lx2 ambiguity, explicit types of code are used:

| Scale | Formula | N=0 | N=100 |
| --- | --- | ---: | ---: |
| Type 1 bonus | B=(N*N+25*N)/125 | 0% | 100% |
| Type 2 multiplier | 1+3B/100 | 1 | 4 |
| Type 3 multiplier | 1+7B/100 | 1 | 8 |
| Harmful complement | clamp(1-B/100,0,1) | 1 | 0 |
| Division by Type 2 | base/(1+3B/100) | base | base/4 |

Probabilities add their base when it corresponds to and is limited to the permitted
range; equipment, mass, states and vulnerability can add modifiers. "Type 2" does not
mean linear. Each "l" in the table is not automatically replaced: damage, pain,
lucidity, Dialogue skill and durations do not share a single curve today.

| Attribute / family | Implemented combat use | Implemented noncombat use | Differences from the table |
| --- | --- | --- | --- |
| Strength / Physical | Melee damage and physical thrust Type 3, with body mass. | Load Type 2; object thrust and launch power use Strength. | It matches the main thing. "Physical power" is not another independent universal effect: it is expressed in the routes of damage, thrust and launch. |
| Hardness / Physical | Ordinary physical/magic damage subtracts uncapped R(T)=(T*T+25*T)/125 percentage points of maximum health after anatomy and before final armor (#52, 2026-09-28). Pain and loss of Lucidity use Type 1 complement. | Since the #52 revision, kinematic impacts subtract R(T) after biological absorption/surface and before anatomy/armor. | Scales must be updated and the scope of “environmental damage” must be narrowed: it is not universal resistance to drowning, drainage for needs or any damage outside the classified system. |
| Constitution / Physical | Maximum health Type 3, with body mass. | Passive Hunger/Thirst/Sleep and natural health regeneration costs/Air divided by Type 2. | It is not connected to shortening debuffs or incoming poisons. There is no disease system implemented that applies that duration. |
| Dexterity / Technical | Attack speed Type 2, physical precision Type 3 and physical critical chance Type 1. It also reduces the ranged-weapon reload time by Type 2. | Type 3 reduces the working time of materials in manufacture. | The ammunition reload belongs here; it is appropriate to distinguish it from the cooldown of skills when updating the table. Crafting covers a specific manual use, not a general system of accuracy rolls. |
| Resilience / Technical | Maximum Adrenaline, Health Regeneration Factor and Air Capacity Type 2. | Acclimatization rate and displacement limit use base plus Type 1 (#136). | At 100: 2 C/world day, +/-10 C; five days from the racial base. Sleep depletion belongs to Constitution. |
| Agility / Technical | Type 2 movement using shared ground/swimming/flight factors; Type 1 evasion; jump uses another curve. | Type 1 stealth applied to concealment/noise, with crouching rules. | The jump does not use Type 2: Jump energy uses Type 3 and biological mass; native velocity follows total moved mass, then the retained state modifiers. |
| Charisma / Social | Its Type 2 modifies the duration/power of elemental payloads received by the player; not all effects/actors consume it. | Type 2 Persuasion on MAP01 social rolls. | The area does not use Charisma: current blast radii and Channel use the range of Eloquence. Channel also has fixed power/duration states. The set of debuffs is partial. |
| Empathy / Social | BuffPowerPercent Type 2 is available and an illumination timer is prepared; there is no general system of buffs/healing that applies all the duration/power/area indicated. | Emotion Type 2 in the MAP01 dialogs. | Emotion works. The stored factor and timer are not enough to mark buffs, cures or playable lighting as complete. Support areas based on Empathy remain pending. |
| Eloquence / Social | Casting speed and ability range Type 2 (not projectile muzzle velocity); this range also scales current radii. Anima cost divided by Type 2. | Dialogue skill Type 1, used by Ronnie; also intervenes in social discount of Palomo. | The ammunition reload uses Dexterity; the Channel Seal Cooldown is fixed to 60 s and does not use Eloquence. The table should specify which recharge is intended to reduce and add the cost of Anima already implemented. |
| Intelligence / Mental | Magical Damage and Push Type 3. | Box capacity = 2 + entero(Type3(Intelligence)/50). | Academic tasks pending. Add the Box; "magic power" does not appear as the third separate universal effect of damage/push. |
| Patience / Mental | Maximum Anima Type 3; regeneration = maximum/base time multiplied by Type 2; interrupt resistance Type 1. It mitigates effects of being injured by Type 1 complement. | Type 1 complement mitigates low/critical sleep aggravation of Lucidity loss and stunning duration. | It does not mitigate general performance penalties by Hunger/Thirst/Sleep: that combination uses Adrenaline. The intended function is only partial. It does not control Sleep loss. |
| Insight / Mental | Magical precision Type 3 and magical critical chance Type 1. | There is no player detection of hidden objects/sounds or dark attenuation linked to this attribute. | Magical senses and hidden detection are still pending. The debugging perception observer does not implement the senses of the player. |

"Recharge time" needs that distinction: ammunition, wait between attacks and cooldown
skills are not a single route. StaffCastCooldownRemaining names launch preparation time,
which does use Eloquence; StopSealChannel assigns 60 seconds fixed to
CombatChannelCooldownRemaining. There is no overall reduction of all cooldowns by
Eloquence.

References to verify or continue implementation:

- [CaelumAttributes](../src/caelum/attributes/CaelumAttributes.zs): families and formation
  of effective attributes.
- [CaelumDerivedStats](../src/caelum/statistics/CaelumDerivedStats.zs): Recalculate,
  curves, capabilities and RefreshSurvivalLossMultipliers.
- [CaelumPlayer](../src/caelum/player/CaelumPlayer.zs): Harm/pain/lucidity consumers,
  GetRangedEffectiveReloadSeconds, GetCraftingDexterityPercent,
  ApplyIncomingElementalPayload, ReleasePendingStaffAttack, UpdateAirStateEffects,
  ApplyPhysicalMovement, UpdateSurvivalStates, UpdateHealthStateEffects and regenerations.
- [MAP01 Social Dialogue](../src/caelum/dialogue/CaelumMainM00SocialDialogue.zs):
  Persuasion/Emotion and Dialogue skill requirement.
- [Elemental States](../src/caelum/actors/CaelumElementalStatus.zs),
  [projectiles](../src/caelum/actors/CaelumActorProjectile.zs) and
  [Channel](../src/caelum/actors/CaelumChannelEffect.zs): application of duration, power
  and radii.
- [Manufacturing](../src/caelum/equipment/CaelumCraftingRules.zs): GetMaterialWorkSeconds
  uses the Dexterity Type 3.
- [Diagnosis of perception](../src/caelum/debug/CaelumPhysicsDiagnostics.zs): experimental
  observer, different from the senses of the player.

Historical 0ai deferred further changes. The author has now authorized the #154 curve mapping and physics contract; unrelated missing systems in this matrix remain pending.

Design status: keep the author's table as intent and this matrix as proven state. It is
left to decide/implement the logical differences in the attribute, magic/state and
roadmap perception blocks; it is not enough to change the scale letters. 0ai only
modifies the Sleep association and expressly ordered regeneration costs.

## Water containers and accessories chosen — valid in 4.33.0ai

The author's correction preserves the direct hydration of the pool and allows to
complete partially filled containers. Six models: small 1 L, normal 2,5 L and large 5 L,
both bottle and canteen. They are preserved when emptied.

Each sip uses water to recover ten Thirst points in the ten native seconds (one point
per second). The amount is adjusted to body mass:

    litros para 100% = masa corporal en kg / 50
    litros por sorbo de 10 puntos = masa corporal en kg / 500
    agua usada = mínimo(litros por sorbo, litros restantes)
    recuperación en puntos = 100 * agua usada / (masa corporal / 50)
    por pulso (diez pulsos) = recuperación / 10

BaseMass is the body mass, determined by the character; it does not include equipment.
Examples: 50/100/200 kg use 0,1/0,2/0,4 L per sip. All recover ten points if there is
enough water left. The last smaller sip recovers only its part. The amount of uses per
filling depends on mass and capacity; 10/25/50 Full uses corresponds only to 50 kg. A
100 kg: small bottle = 5 sips, normal = 12 Complete sips and one of 5 points, large = 25
sips.

The reserve is capped at 100. Drinking is rejected when already full or from the Box.
Repeating a dose restarts the effect without stacking it; waiting for ten seconds allows
you to take full advantage of it. The previous water ration preserves its 100 ml and its
mass recovery; it does not change its weight or create extra water.

Each vessel is Inventory native with its own volume. Provisional tare: 0,10 kg, reusing
SPECIAL_ITEM_DEFAULT_WEIGHT (the author did not fix tare weights per model); contents to
1 kg/L. One copy of each model per character in this delivery; liquids are not merged or
duplicated. The inventory shows remaining liters. Weight, Box, drop/pick and save retain
that volume. The Limbo exit retains its item cleanup.

A new entry with WaterLevel >= 3 and user_ca_potable_water fills or tops up containers
outside the Box. Only missing volume adds weight: to top up a 2,5 L canteen containing
1,25 L, capacity for another 1,25 kg plus the 1 g margin is sufficient. If the whole
amount does not fit, current contents remain; free some load, leave and submerge again.
It does not continually refill while drinking underwater. Pool geometry and Air rules do
not change.

Immerse your head in the drinking pool again Thirst recovers directly to one point per
second, replacing passive loss while the dive lasts, even without a container. The
container allows to store water to carry; it is only filled in water marked as potable,
never by stepping on earth.

The critical state of the three reserves and their drainage of health are governed by
the previous section. Thirst's positive exception introduced in 0ag was withdrawn by the
author in 0ah. Drinking recovers the reserve, without giving immunity to damage or free
recovery of health.

Ronnie, after returning the sword, offers an empty normal canteen for its workshop talk.
Confirm delivery only one; insufficient carrying capacity allows a retry. Detail records
filled and actual use, without blocking other missions. The potabilization of
contaminated/salt water is not defined or implemented: the current scope is to collect
water already marked as potable.

Caella offers to choose and confirm a T1 seal (five elements) and a T1 amulet (ruby,
sapphire, emerald or topaz). Each choice is fixed per character; consult or return does
not assign an option. It teaches only the chosen recipe and its components, preserving
any previous knowledge. Recursive native manufacture, reservations, pause/cancellation,
personal output and existing equipment. Detail shows choices and independent preparation
0/1 for each piece.

100% raw materials in each layer, using existing recipes: - Seal: 360 g raw copper + 40
g raw tin + 600 g of the chosen gemstone. - Amulet: 200 g raw silver + 800 g of the
chosen gem. - If the gemstones match, the quota totals 1400 g. No other gemstones are
added. The chest provides raw silver and the chosen equipment leather, limited by the
amount already issued and available carrying capacity. Gems, copper and tin are still on
the veins. Silver reuses the chest’s previously inactive slot 0; its array does not
grow.

0ae Compatibility: No recipes, materials or pre-made Seals are deleted. The Seals
already manufactured keep their expense accounted for; unused quotas for unselected
items are removed. An earlier seal task already initiated maintains its personal output.
New flags/fields use empty initial values and do not restart missions or issued quotas.
A piece already owned when learning does not grant another set of materials for that
piece.

## T1 seals: instruction and supply — 4.33.0ae

After completing the Caella test, you can ask for "Do you teach me how to make Seals?",
directly or through its workshop section. Read/postpone does not teach. Accept shows the
five existing recipes (56–60 indexes) and native dependencies: seal bases, gems/crushed
gems and metal processing. Do not change 131 indexes, the recipe version or its costs.
T1 is the supplied coverage; no physical components or objects are granted when
learning.

| For the five T1 seals to the 100% in each layer | Quota added |
| --- | ---: |
| Raw copper | 1.800  units = 1,8 kg |
| Raw tin | 200  units = 0,2 kg |
| Raw ruby | 600  units = 0,6 kg |
| Raw sapphire | 600  units = 0,6 kg |
| Raw emerald | 600  units = 0,6 kg |
| Raw topaz | 600  units = 0,6 kg |
| Raw opal | 600  units = 0,6 kg |

Each T1 seal weighs 1 kg, of universal size. Its base occupies 40% and its elemental
component 60%; the above amounts arise from native expansion to 100%. Copper/tin
accumulates with the chosen weapon and ammunition. It does not modify leather. The veins
of the cave provide the material; the drawer continues to provide only leather.

The quota is enabled by accepting the teaching and choosing the weapon with Ronnie, in
any order. It retains the 0ad issued counter: accept again, manufacture, change the vein
or save/load do not restart it. If a T1 seal is already in place, one piece per item is
recorded and only the new expansion is deducted; its cost is not charged again to the
previous counter. The CA_LimboMagicSeal borrowed seal is excluded. That initial list is
fixed after learning. The prepared Seals count from 0/5 to 5/5; they do not impose a
mission requirement.

The Seals use the recursive plan, the reserves and the native transaction, as well as
weapons/armor. They can be manufactured from raw materials in the Caella Workbench or
the second floor. Before having Box, the T1 result learned goes to personal inventory.
Equipping changes the unique Seal slot and retains the effects, Adrenaline, blocking and
cooldown current Channel. The narrative exit continues to remove temporary equipment
other than the first weapon.

If the Ronnie sword has already been returned, your workshop section offers "I need to
collect for Seals." It provides the same kind of tool while a useful quota is left for
an unprepared seal; it checks load and does not require a pending repair. It is returned
from the same page. The repair branch retains its conditions and its independent
proportional quota. An active prior task retains recipe, efficiency, time and reserves
even if another seal is learned or selected. It does not cancel or change its result.

## Choice of MAP01 armor and quotas (4.33.0ad)

Ronnie offers magic, light, medium or heavy after the weapon. Read/back does not choose;
confirm fix one family per character. The four existing recipes (head, torso, hands,
feet) and components are taught. The catalog and version of the book do not change. In a
selected weapon save is accessed from your workshop dialogue. Detail shows choice and
0/4–4/4, without new lock.

Armours now share the recursive weapons solver: they can be made from leather without
making straps separately. The chosen T1 parts are delivered to the personal inventory
without a mandatory Box; they are equipped by Inventory. They are temporary equipment of
Limbo. The exit preserves only the Box/first weapon; choosing armor does not replace ItemId of
weapon or complete its target.

Quota = raw materials of a chosen weapon + four pieces of the chosen family + a batch of
ten arrows/bolts if the weapon uses that ammunition. The 100% is calculated in ALL
layers, at the chosen size, using the existing recipe functions. The parameter that
concealed the Efficiency field in the supply solver is corrected. New choices prepare
100% and clean options from previous layers only if there is no active task. The costs
and times 25/50/100% general do not change; lower efficiency can exhaust the quota
before.

| Already-tanned leather, size M | Set | With chosen giant gauntlets |
| --- | ---: | ---: |
| Magic | 5 kg | 11 kg |
| Light | 10 kg | 16 kg |
| Medium | 20 kg | 26 kg |
| Heavy | 40 kg | 46 kg |

The leather includes the necessary straps. Other sizes use the current multiplier and
native roundings. Each unit of material continues to weigh one gram. Armor uses the
leather of the current catalog, also heavy ones; this patch does not change composition,
defense, attributes or mass of any recipe/armor.

MainM00SupplyLimit/MainM00SupplyIssued reside in the traveling Inventory. Quota is
reserved when generating a pickup or withdrawing from the drawer. Another source,
consumption, loading the save again or regeneration of the node does not replace it.
Resources outside the chosen quota are not extracted. The mass/hardness/physical
capacity of trees, bushes and veins remain; the amount delivered before discounting the
node is limited.

The drawer and the Toro share the leather quota. The Toro produces its maximum physical
performance of 12,5 kg in 900 kg mass, limited to the unissued quota. If it is already
removed from the drawer, it does not add leather. If it first generates 12,5 kg for a
heavy set M, the drawer offers 27,5 kg remaining. It is not two reserves. Return leather
without spending removes those units from the player and releases its quota.

New pickups identify the player and the quota already reserved. They are not counted
again when picking up. Old stacks request quota on pickup and do not admit excess. If
the load capacity is missing, a portion is collected and the usable remainder stays on
the ground. A gram of margin is left to not reach the immobility to the 100% load; the
general rules of speed are not altered.

0ac migration: preserve recipes, attributes, tasks, equipment and progress. Count
existing raw materials/components to the 100%, first weapon already manufactured and
initial ammunition present against the quota. Do not erase inventory when loading.
"Leave leftover materials here" in the drawer removes only excess raw materials without
reservation; retains the useful quota. Do not recover what has already been spent.

The accepted optional repair retains access: when you consult Ronnie with the first
damaged weapon, only the cost proportional to the 100% of the damage observed is
enabled. Repeating the query uses the maximum already enabled, does not add it again. It
does not restore durability, does not give materials and does not replace equipment. If
the chosen weapon does not serve to extract those resources, the repair conversation
allows you to ask again the sword and return it to Ronnie. Damage, practice pending and
load space is verified; the same loan is reused. 0ae expands this quota with the learned
Seals, according to the previous section. Bullets and supply T2 remain outside the
initial quota.

## Bolts and ammunition knowledge (4.33.0ac)

CRAFTING_BOLT_RECIPE = 130 is attached; the catalogue has 131 recipes. Arrows retain
index 129; 0..128 maintains its meaning. KnownCraftingRecipe grows in the end to 131
bools. The version of the book is kept in 4 so as not to trigger a migration that erases
old components; the new bool is born false.

Choosing the crossbow with Ronnie teaches the required bolts, shafts, tips and
processing steps. Bow and long bow retain arrows; the other choices do not receive this
recipe. TeachStarterAmmunition also incorporates the knowledge pending to previous
saves, inside or outside MAP01. Repeating does not duplicate anything. Not all recipes
in the catalog are taught nor equipment or ammunition are awarded.

Each batch produces ten CaelumBoltAmmo, 50 g each, fixed tier 1 and fixed size M of the
catalog. Bolts adopt the same T1 structure as arrows: 350 units of shaft and 150 of
bronze tip, incorporating 0,5 kg. The native mass of bolts is unchanged. Assembly inputs
with ready-made components:

| Efficiency | Shaft | Bronze tip | Output |
| --- | ---: | ---: | ---: |
| 25% | 1400  units | 600  units | 10 bolts |
| 50% | 700  units | 300  units | 10 bolts |
| 100% | 350  units | 150  units | 10 bolts |

One unit = 0,001 kg. Each previous transformation applies its own efficiency and time;
the table is not the total raw material in multilayer manufacturing. The shaft comes
from wood; T1 tip, bronze from copper/tin. The Workbench, Sawmill, Ranged Workshop and
Forge from the Ronnie network or second floor cover the process. The Crafts Tree shows
each layer and its efficiency.

Direct plan, reservations, unique task and native time are reused. Closing or moving
away pauses; only cancel free without consuming. Completion consumes the reservations
once and adds the batch to the correct stack. It does not require Box, does not occupy a
slot of it and respects loading capacity and maximum stack size. B,tier and size do not
multiply the lot. Ammunition does not register or replace ItemId from the first weapon.
The arrow recipe uses the same executor and keeps its stack. Bolts are loaded/spent by
the native crossbow, without parallel combat.

Detail guides the one who chose crossbow; does not add a mandatory target. The
ammunition guide is in the Ronnie workshop dialogue, without expanding its seven main
options. The narrative exit retains the rule of removing physical objects except
Box/first weapon; knowing recipes is preserved.

Carbine bullets: current mass 0,003 kg; composition, raw materials and process to
manufacture yet undefined. No inferred recipe for that mass is introduced.

## Breathing: optional Ronnie practice (4.33.0ab)

After returning the sword, “How can I breathe when swimming?” proposes the practice.
Confirm with Ronnie brand MainM00SwimLessonStarted; accept again preserves the phases.
The dialogue indicates swimming pool behind the mansion to the east and wide steps on
the side of the mansion. Prepare Air, cover the head one second next to them and go back
up. It does not require crossing the entire pool or exhaust Air.

UpdateUnderwaterAirForState reports only the amount actually spent. The observer
requires MAP01, live game without prediction/dialogue, acceptance, WaterLevel >=3,
potable pool sector, no underwater exemption and UnderwaterNoBreathTics >=TICRATE (35).
Sets Submerged. No counter added: a dive less than a second does not accumulate separate
dive time. The first interval retains base cost 5 Air/s for the current multiplier;
subsequent increase and drowning damage do not change.

RecoverUnderwaterAirDebt reports positive recovery after updating its debt and tics.
With out-of-water head, Submerged and zero end debt mark Complete. Use existing
three-second return; re-enter pause and resume according to native rule. Do not add
regeneration or spend Hunger/Thirst for this return. Filling Air by another way does not
trigger breathing observation. Underwater Air recovery also does not prove the separate
practice of running.

Three bools in CaelumPersistentCharacterState retain Started/Submerged/Complete;
underwater counters and debt were already saved. In previous games the new bools start
false. Snapshots feed Detail and dialogue. No modifications are made to recipes, rewards
or mission blocks. When you leave you keep the completed and hide the pending practice,
just like the other practices. The lesson does not implement water collection or
potabilization.

## Load: optional Ronnie practice (4.33.0z)

After returning the sword, "How do I organize my load?" shows the current snapshots of
CarriedWeight, CarryCapacity and the CalculateLoadAirMultiplier multiplier. Read does
not start; accept Started brand without giving objects or changing weight. Body mass
participates separately in the final cost of Air; the dialog value represents only the
load factor.

The current rule is preserved: for ratio r <= 0,75, factor = 1 + r; above that, factor =
1,75 + 2 * (r - 0,75). HasOverload activates at r >= 0,75. The entire cost does not
double at the threshold: the slope of the excess increases. Pickup capacity and the
desirability of carrying a load are distinct.

ToggleSelectedMagicBox retains its logic in ToggleSelectedMagicBoxNative and observes
before/after CarriedItemWeight mass. DropSelectedEquipment observes its native drop
call. Only a confirmed action STORED_IN_MAGIC_BOX or DROPPED with a reduction higher
than 0,000001 kg can be credited. The first weapon’s ItemId is excluded.
CarriedItemWeight does not include DebugWeight: attribute changes, removal of debug
load, consumptions or manufacture are not these actions. Retrieving from the Box or
storing without reducing weight does not count either.

MainM00LoadLessonStarted and Complete are serialized with the Persistent Inventory;
their initial values in previous games are false. Dialogue and Detail use snapshots. It
does not add costs, rewards or requirements to Rulo/exit. The surplus can be collected
again: the lesson records the decision made. After exiting, the pending optional
practice is hidden and the completed one is preserved. It does not add testable
materials: reuses excesses typical of the route. Without excess, it is allowed to
continue without doing the practice.

## Air and motion: optional practice (4.33.0y)

After returning the loan, Ronnie offers "How do I manage my Air?" Read does not start.
Confirmation fixes MainM00AirLessonTarget = MaximumAir * 0.01, once. Do not refill or
reduce Air, needs or health. The target is retained even if it changes the maximum; it
is not an additional cost.

ConsumeRunningAir reports the actual difference between Air before and after
consumption. It only credits with active practice, without dialogue, running on ground
and with horizontal speed not null. MainM00AirLessonSpent accumulates and is limited to
the target. Reaching it sets Ran. Short runs count; does not ask for exhaustion.
ApplyAirRegeneration then informs the Air effectively recovered, retains its native
requirements and costs of Hunger/Thirst, and accumulates Recovered. Reaching the target
sets Complete. Recover before finishing the first step does not count. An energy drink,
attack, jump or debug adjustment does not invoke those observers. Regeneration may
require replenishing reserves if they are empty.

Three flags Started/Ran/Complete and three doubles Target/Spent/Recovered live in the
serialized Inventory record. The new fields are zero in previous saves. Dialogue and
Detail use snapshots; when crossing retains the completed and hides the pending optional
practice. There is no reward or new mission requirement. The same native logic of BT_RUN
respects Always Run and the speed key. Mobility is not modified or immobility, rest or
calendar is incorporated.

## Needs: optional Ronnie practice (4.33.0x)

After the Ronnie loan is offered "How do I feed and drink?". Read the proposal does not
start the practice. Confirm it once applies Min(current, 90) to Hunger and Thirst: it
does not reduce already low reserves or cure previous states. One CaelumFoodRation and
one CaelumWaterRation are delivered through the native inventory.
MainM00NeedsFoodGiven/WaterGiven register each successful delivery separately; one
failed delivery per load can be retrieved, without duplicating the other. The rations
weigh 0,10 kg each. They keep stacking/Box rules.

Use from Inventory consumes one unit and activates ten pulses of one point, one per
second. Observer only marks food/water if Use was accepted, practice began and the
corresponding reserve was below 100. Collecting, speaking, refusing use from Box or
consuming 100 does not credit. Accreditation records consumption; recovery remains
gradual. A second unit restarts effect, never adds intensities or durations.
bAlwaysPickup is enabled only during Super.Use to allow that native refresh before
expiry; the flag is restored to avoid alter collection.

MainM00NeedsLessonStarted, FoodUsed, WaterUsed and the two delivery flags travel in the
persistent record; previous saves initialize them to false. Detail reflects the two
consumptions. The complete practice is preserved on exit; a pending optional practice
is hidden outside the Limbo. There is no mission requirement, extra recipe or reward to
return. The remaining rations are removed with the other physical objects on the
approved exit: they are not exported to MAP02.

This delivery teaches consumption. It does not implement collection or potabilization:
the pool is not a water dispenser. It does not alter the rhythms of needs, regeneration,
rest or calendar. It does not expand maps.

## Optional maintenance with Ronnie (4.33.0w)

After returning the loan, "How do I keep my weapon?" records that the lesson was
offered. The steps are in that dialogue and in Quests > Detail (F). Select the first
weapon in Inventory and unequip it; use the Workbench on the second floor and press F in
Crafts. Keep selected piece.

BeginRepairSelectedEquipment/CompleteRepairTask is reused. The observer only credits a
finished native repair that increased the durability of the initial ItemId, owned by the
player, after receiving the lesson and closing Ronnie’s conversation. Speak, repair
another object, use a debug restore or cancel does not credit this practice. The save
stores MainM00RepairLessonOffered and MainM00RepairLessonComplete; two snapshots feed
dialog and Journal.

It does not add recipes, rewards, tutorial damage or a parallel task. It does not change
either Rulo or exit requirements. Completed status travels with character; pending
optional practice ceases to be displayed after leaving the mansion. A real task that
remains active does retain 0v exit restriction: the player must finish it or cancel it
personally before crossing.

## T1 Material Coverage — 4.33.0w Audit

Calculation with engine recipe functions, size M, no previous stock, one piece per slot
and even efficiencies in all layers. Figures are leather already tanned: 1 material unit
= 0,001 kg. These are not new balance costs.

| Complete T1 set | 25% | 50% | 100% |
| --- | ---: | ---: | ---: |
| Magic | 41,6 kg | 13,6 kg | 5 kg |
| Light | 78,4 kg | 26,4 kg | 10 kg |
| Medium | 156,8 kg | 52,8 kg | 20 kg |
| Heavy | 313,6 kg | 105,6 kg | 40 kg |
| The four sets | 590,4 kg | 198,4 kg | 75 kg |

The current code also uses leather and straps for these four types of armor; the table
reflects this catalogue, without replacing it with metals or fabrics. The
appearance/weight/stations of the type do not change their material in recipes.

The historical offer up to 0ac was 96 kg of drawer M plus 12,5 kg of Toro. From 0ad the
quota to 100% of the choice indicated at the beginning; the comparative costs of the
table remain valid, but are not the stock available. The four sets are not supplied
simultaneously nor to 25%.

To manufacture once each of the five T1 seals:

| Raw material | 25% | 50% | 100% |
| --- | ---: | ---: | ---: |
| Total raw copper | 460,8 kg | 28,8 kg | 1,8 kg |
| Total raw tin | 51,2 kg | 3,2 kg | 0,2 kg |
| Each raw gem: ruby, sapphire, emerald, topaz and opal | 9,6 kg | 2,4 kg | 0,6 kg |

The initial veins of the map exceed these requirements: copper 6.470,5 kg, tin 5.176,4
kg; ruby 1.022,34 kg, sapphire 1.363,12 kg, emerald 681,56 kg, topaz 1.703,9 kg and opal
2.555,85 kg. They are capacities calculated from the actors; neither extraction time was
measured here nor guaranteed that an already exploited save retains those reserves. The
nodes maintain their regeneration, but from 0ad the delivery quota is independent: these
physical masses do not allow collection of surplus.

Material availability, infrastructure and knowledge are separate requirements. The
twelve stations on the second floor cover the infrastructure; Ronnie teaches the first
weapon and, from 0ad, a family of armor with its components. From 0ae Caella it teaches
Seals and enables its quota when accepting. Do not use "there are veins" as synonymous
with "everything can be made now".

## Narrative exit, inventory and arrival (4.33.0v)

The rear door of the Bull room requires 90 phase, complete testing, El Loco and the
player's native Box itself. Use checks visibility, distance up to 112 MU and vertical
difference up to 48 MU. The old Direct Exit and its panel are removed in runtime, also
in 0u saves.

USDF 43320 presents the warning and two decisions. Cancel does not change anything.
Accept initiate phase 95 and 18 tics of fade after closing the dialogue. An active task
prevents start; it does not automatically cancel or touch your reservations. Blocking,
aiming, reloading, charging and Channel is interrupted. The temporary input lock is
removed only if this transition added it. Distance, health, property and requirements
are revalidated before cleaning.

The first weapon is resolved by MainM00StarterWeaponId, first in inventory, then as a
dropped instance. Only if it disappeared will the T1 choice be reconstructed, with
original size/essence and last known durability. It does not return materials or replace
a valid instance. Durability is recorded when the character persists; in an old save
without the item or a snapshot the maximum durability of the recipe is used as
exceptional recovery.

Confirmed the crossing, that piece is placed in the Box, without equipping, and the
other personal and stored physical objects are removed. The historical cleaning of
portions of mission does not replace this narrative rule: only the Box and first weapon
travel as physical items. Tarot, knowledge and the character record remain. There is no
additional loadout defined. Health and needs are preserved with the maximum in force
after removing equipment; they are not restarted for travel.

Before ChangeLevel phase 100 is saved, completed quest, exit objective,
cleaning/preservation flags and consistent models without equipment. GZDoom carries the
native inventory, without RESETINVENTORY or RESETHEALTH. MAP02 starts on the dry
gateway; USDF 43321 presents once the Voice and a closing/help page. The weapon can be
recovered from Inventory and used normally. The actors test field is now CADEV02 and its
objects do not appear on arrival.

MainM00ReturnTics, MainM00ReturnOwnsFreeze and MainM00SewerVoiceHeard are saved next to
the traveller log. Previous indexes are preserved. The presentation is reconstructed
when loading and does not re-grant cards or objects. Arrival does not offer normal
return to MAP01. With more than one player the crossing is rejected before mutating the
state; the cooperative variant needs joint design.

## Trucazo — Argento practice (4.37.13 / #81)

The author selected Argento in MAP01 for the first human-versus-NPC match on
2026-10-04. Issue [#81](https://github.com/damiancurti/Caelum-Argenteum/issues/81)
requires explicit rules before implementing the match. The author supplied
`DOCUMENTO 12 - trucazo.docx` (TCG/Trucazo v2.0) from the original project's
Documentation folder and explicitly confirmed traditional Argentine Truco as
the base, with the additions in that document. Source SHA-256:
`a326583696714f4dad6938b1ba85b7e09f60f6096012e413d8353ce0fbc8b4d9`.
The source is preserved in assets/design_sources/trucazo_v2_original.docx.
The author resolved the source contradictions before match implementation.
The following table is the implemented contract; author playtest acceptance
remains separate and pending.

| Area | Confirmed contract | Decision still required |
| --- | --- | --- |
| Opponent/location | One human against Argento in MAP01. | None for the initial opponent/location. |
| Physical source | The complete 78-card physical deck supplied by Palomo in #80; separate from captured essences. The 40 playable cards are Minor Aces through 7, Pages, Knights and Kings, in all four suits. | None for identities/playability. |
| Dealing | Author correction: one shared shuffled deck of all 56 Minors. Each player receives five cards; their nonplayable 8/9/10/Queens enter their first row. Draw replacements from the remaining shared deck until each has at least three playable cards; replacement nonplayables enter their second row. Replenish only during the deal, never after playing a card. | None; the author confirmed this exact interpretation on 2026-10-04. |
| Card strength | Sword Ace; Wand Ace; Sword 7; Coin 7; all 3s; all 2s; Cup/Coin Aces; Kings; Knights; Pages; Cup/Wand 7s; all 6s; all 5s; all 4s. The author's current tie rule is mano (the participant who plays first). | None for ordinary strength/ties. The latest tie decision takes precedence over the source's awakened-card tie priority. |
| Turns/hand outcome | Traditional Truco: up to three tricks, first to win two wins the hand; trick winner leads next. The source's damage/health extension determines the complete match. | None for the hand structure. |
| Calls | Ordinary Truco scoring: unraised hand 1; accepted Truco/Retruco/Vale 4 worth 2/3/4; refused raises worth 1/2/3. Envido uses the best same-suit pair, 20 plus numeric values, figures 0; ties go to mano. No same-suit pair uses the highest individual value. Envido adds 2, at most twice; Real Envido adds 3, once. Refusal awards the previous call total, or 1 for an initial call. | None. Traditional scoring/timing, explicitly authorized by the author, supersedes contradictory source terminology about rounds and accepted-call raises. |
| Match ending | Trucazo health is Patience squared. Repeat hands until a participant reaches zero; a double knockout goes to mano. This practice cannot damage world health. | None for the health-based end condition. |
| Major modifiers | Explicitly excluded from this practice by the author on 2026-10-04. World Tarot powers remain separate. | None for this slice. |
| Health/damage | First-row value: (5 + sum of numeric cards) times (1 + Queen count). Second-row value uses the same formula. Damage before Intelligence: max(0, attacker's first-row value times points won minus defender's second-row value). Source's worked match uses the defender's second row. Author confirmed the former Type 1, mapped by #154 to Type 3: multiply by 1 + 7*(I*I+25*I)/12500, then round to the nearest whole health point as in the source example. | None; this supersedes the source's contradictory linear formula. |
| Magic Senses | Explicitly deferred by the author on 2026-10-04. Ordinary decisions/UI must not leak private hands. | None for this slice. |
| Stakes/consequences | Explicitly a practice with no wagers, prizes, item/card transfer or reputation changes. | None for this slice. |
| Leaving/interruption | Voluntary abandonment is an automatic match defeat. Restore ordinary controls; never strand the player seated. The source requires a dedicated screen that pauses the world. | None for voluntary abandonment. Native interruptions must preserve a valid state. |
| Save/load | Native persistence retains the exact dealt cards, used cards, rows, health, pending/suspended calls, result and action revision. Loading restores the menu and pause; it does not begin another hand or replay damage. | None. |
| Furniture | Existing 2/6/12-seat capacities and dining/rest behavior remain authoritative. | No capacity changes proposed. |
| Deferred scope | Human multiplayer, teams, network synchronization, broader ranked/casual services and full Major expansion are outside #81. The author additionally excludes Majors, Magic Senses and wagers from this practice. | None for this slice. |

The initial mano is randomly selected; subsequent hands alternate. Every trick
tie uses that hand's mano, including when the other participant led the trick.
After a trick, Continue exposes the result before the next lead. Completed
hands apply both damage totals simultaneously and offer the next deal if both
participants still have health. Trucazo uses separate health, never world HP.
Attributes and awakened Minor ownership are snapshotted at match start.
The source's casual awakened-Minor rule doubles numeric Envido/row contributions
and Queen counts; an awakened figure copies its same-suit numeric partner for
Envido (two figures remain zero before the suit bonus). Physical ownership
alone never awakens a card. No campaign Major effect runs in this practice.

Envido is available before one's first card in the first trick, including as a
response to a pending Truco; the suspended Truco resumes after Envido resolves.
Calls may be raised while responding. After accepting Truco, only its recipient
may raise it on their turn. No playing a card while a response is pending, no
late Envido, no third Envido, no second Real Envido or raise above Vale 4. The
original hand supplies Envido values; remaining cards supply legal plays.

Argento leads with his strongest available card, responds with his weakest
winning card if possible, otherwise saves strength by discarding his weakest.
He calls/accepts Envido above the source threshold of 25, raises an eligible
Envido response, and uses premium Aces/sevens or a won trick to support Truco.
The policy receives only his own cards and public state, never the player's
hand or future deck. A refused Envido does not reveal either private value.

Challenge choices are added to existing Argento pages without adding/reordering
USDF pages. The physical deck may be inside or outside the owned Box. The
match's revision-1 native Inventory is created on first valid challenge;
repeated interaction cannot reset an active match. The static input/controller
exists on old saves, and only validated play-scope messages mutate state. A
serial rejects stale actions. The view is reconstructed once on native load,
which includes the engine's ordinary one-tic resume before the menu pauses.
Loading original pre-patch saves with their original package is the reversible
rollback path; original saves/packages must be retained. This patch never
claims old engines can load a new save containing the new match class.

Left/Right or 1-5 selects a card, Up/Down chooses a legal action, Enter/A
confirms it. Esc/B returns from rules/rows or opens abandonment confirmation.
Save/Load opens the normal native menus. A finished result has an explicit
return-to-mansion action. Leaving MAP01, death or losing the valid opponent
invalidates an active session as defeat and releases its presentation; there
are no seat, world-freeze flags, resources or stakes to restore. Existing
furniture, dining/rest and Tarot ownership/powers are not modified.

## Tarot: collection and capture of El Loco (4.33.0t)

### Issue #80 approved power contract — author decision, 2026-10-04

Implemented in 4.37.12; both author playtests passed on 2026-10-04. The author
defines a shared activation of up to three selected, captured essences: **1000
Anima total**, **60 seconds** of effect and **600 seconds** of cooldown.
The Fool's flight is additional to its existing authored world transition.

| Contract | The Fool (0) | Ace of Cups (36) | Knight of Wands (60) |
| --- | --- | --- | --- |
| Existing passive | +2% collection | +1 each to Charisma, Empathy and Eloquence; +1% collection | +0.6 Strength; +1% collection |
| Approved active effect | Flight | Double this card's fixed contribution to +2 each | Double this card's fixed contribution to +1.2 Strength |
| Target/context | Self; ordinary live-player ability context | Self; ordinary live-player ability context | Self; ordinary live-player ability context |
| Payment | Shared 1000 Anima for the selected set, once | Same activation | Same activation |
| Duration | 60 seconds | 60 seconds | 60 seconds |
| Cooldown | Shared 600 seconds from activation | Same activation | Same activation |
| Cancellation/refund | No manual cancellation or Anima refund | Same activation | Same activation |
| Feedback | Selected/active/unavailable, remaining time and flight controls | Selected/active/unavailable and actual bonus | Selected/active/unavailable and actual bonus |
| Persistence | Selected set, activated set and remaining timers survive save/load/travel | Same; derive bonuses without accumulation | Same; derive bonuses without accumulation |

Changing a selection must never grant an essence or replay acquisition rewards.
Physical-deck possession is distinct from captured-essence ownership. Palomo's
once-only complete deck and capture-commit requirement come from #80; its
weight is 780 grams and it occupies one slot. The author's final clarification
makes it unsellable, undroppable and unbreakable. Essences stay with the
character. No deck-in-Box requirement gates power activation.
The existing MAP01 return-door confirmation, quest/Box checks, 18-tic fade,
inventory preservation and one-way MAP02 transition remain authoritative.

Enter/A toggles cards in the Journal, up to three. User3 activates the complete
selection once. A held input cannot pay again; empty selection, unowned or
unsupported cards, invalid activities, insufficient Anima and cooldown reject
without payment. Selection changes affect the next activation. All 56 Minors
reuse the existing suit/rank contribution; other Major powers remain unavailable.
This patch adds no new acquisition content beyond the existing campaign.

The persistent record owns revisioned selection and activated-card arrays plus
remaining effect/cooldown tics. Personal time advances them, including existing
rest/travel simulation. Loading or map entry never resets them. Flight uses
native PowerFlight with the saved timer as authority, including infinite-flight
maps. Fly/swim up/down are exposed in Controls. Expiry removes flight and only
the temporary Minor contribution, without healing or Anima refund.
The HUD shows remaining effect duration in cyan and shared cooldown in white,
with the Tarot icon above the existing side Seal indicator. The Journal also
shows both timers. The author's follow-up explicitly requests this HUD feedback.
Planned journeys retain the existing temporary-effect restriction for every
active Tarot set; after effects end, journey application advances the remaining
cooldown by its simulated duration, just as it does for Seals and class abilities.

The native physical deck grants no TarotOwned flags. Standard C storage and
capacity rules apply to its one slot and 0.780 kg. Failed delivery can be retried
after reorganizing inventory. Capture revalidates Box identity and deck location
at commit, preserving boss/quest availability on failure. Legacy Box-handoff or
earned-essence evidence enables one deck recovery; capacity failure retries.
Power revision 1 starts unselected; deck revision 1 never grants missing
essences. Preserve the original save/package for rollback. No map is rewritten.


### Existing collection rules

Rule in force since 0aa: each Minor exclusively contributes a base passive, in addition
to its +1% per collection. Major: +2% per card. The 22 Major and 56 Minor add up +100%
collection, in an additive way, before the three current growth families. Do not round the level or alter
creation points. Combat awards no XP. The active rule above supersedes the reservation hook; Trucazo remains #81.
The campaign obtains The Fool, Ace of Cups and Knight of Wands. The other 75
essences still require their acquisition content.

| Suit | Family | First / second / third attribute |
| --- | --- | --- |
| Swords | Mental | Intelligence / Patience / Insight |
| Cups | Social | Charisma / Empathy / Eloquence |
| Wands | Physical | Strength / Hardness / Constitution |
| Coins | Technical | Agility / Dexterity / Resilience |

| Card from each suit | Base bonus per card |
| --- | --- |
| 2, 3, 4 | +0,3 to the first attribute |
| 5, 6, 7 | +0,3 to the second |
| 8, 9, 10 | +0,3 to the third |
| Knight | +0,6 to the first |
| Page | +0,6 to the second |
| Queen | +0,6 to the third |
| King | +0,5 at all three |
| Ace | +1 at all three |

Each full suit gives +3 passive to its three attributes. While a Minor power is
active, its fixed contribution is added once more before collection multiplication. Order: creation + minor passive +
equipment, then multiplication by (1 + collection percentage/100). Armorless example: 20
creation +18 amulet T3 +9 seal T3 +3 minor =50; with 78 cards it turns out 100 in the
attributes that receive those bonuses. It is not a cap imposed on the attribute nor are
passive Majors invented.

TarotOwned[78] lives in CaelumPersistentCharacterState, Inventory traveler. Stable
indexes 0–21: Marseille Major Arcana; El Loco =0. Minor Arcana: Swords 22–35, Cups
36–49, Wands 50–63, Coins 64–77. Within each suit: Ace, 2..10, Knight, Page, Queen,
King. The code adds integer tenths and rejects duplicate delivery. Counter, passives and
percentages are derived from property; they are not accumulators. ApplyCharacterProfile
rebuilds creation/equipment, adds Minors, multiplies collection and recalculates
statistics/load. The debug profiles follow the same order after its forced base.
Re-equipping, loading or travelling does not duplicate bonuses. The Journal separates
Minor Arcana base bonuses and percentage bonuses using attributes in the same order as
Character. Load 0z also reconstructs serialized derivative values and the cost of a
pending spell, maintaining resources/progress.

The controller spawns CaelumM00FoolEssence in (1420,1050,-370), on the floor Z=-384.
Check the 80 phase, the four finished branches and delivery/ownership of the Box. Reuse
the StoryPlaced instance when loading; do not put actors in the WAD. MainM00FoolRevealed
retains individual revelation. The world render shows CTAR reverse and then the CFLF
resource, also used in the Journal.

Using requires player created/live in MAP01, distance <=128, difference Z <=48 and
CheckSight, plus native box with Owner and ItemId matching. The effective scope of Use
also respects the native layout of the player. USDF 43318 lets you confirm or leave it
there. The music drops during dialogue and the native destructor restores
Level.MusicVolume; the selected volume is not changed.

The acceptance starts 35 animation tics after closing the conversation. The original
actor remains still; a non-collisional image approaches the player. Each tic revalidates
distance, health, mission, image and the same Box. An interruption erases only the image
and restores the essence. At the end, RecordMainM00FoolCapture changes 80 -> 90,
registers the card, 40 flag, 6 target to 1/1 and EXIT_READY, which from 0v enables the
final door. It persists before removing the essence. Repeat does not reward again. The
native save also retains the animation and its references.

Tarot is the seventh page of the Journal. Counts cards, shows the illustration obtained
and the percentage; Character shows decimals. Detail distinguishes
search/reveal/capture. Palomo uses USDF 43319 after obtaining it; the four residents
adapt their completion pages. USDF nodes are attached to maintain existing indexes.
There is no map change in this patch.

## Palomo final and single box (4.33.0s)

The final conversation uses USDF 43316; an early visit above uses 43317. Pages are
attached to preserve the indexes of the saves dialogs. DepartureDone enables to speak
with the same instance, without moving it. Delivery requires MAP01, live/created player,
active conversation with Palomo, range/height/visibility and active registration in
phase 75 with the four branches completed.

Only CaelumMainM00AcceptMagicBoxAction confirms the narrative reward.
CanReceiveMainM00MagicBox validates the requirements; RecordMainM00MagicBoxGranted
advances 75 -> 80 and fixes the 39 flag after confirming property and identity. Asking,
going back or closing does not grant anything. A second attempt retains the Box and the
stage. USDF tokens reflect the record, do not replace it.

CaelumMagicBox is a native Inventory without duplicate entry in the list; the existing
interface of the Box is still its presentation. It has ItemId and Owner,
MaxAmount/InterHubAmount 1, UNDROPPABLE and UNCLEARABLE. It does not enter the sales
catalogues or storeable content classes. Weight continues to be added only to
CalculateMagicBoxTotalWeight: 10 kg plus the overall reduced weight of the content, with
current divisor/rounding rule. It does not add another slot.

EnsureOwned recovers the instance if missing and assigns identity to the old property
without duplicating contents. Use the existing ID counter and protect the Box identity
against imported equipment with the same number. It does not advance a mission for
possessing an inherited Box: it is necessary to accept to Palomo. The Box travels with
Inventory. 0t added El Loco capture and its attribute bonus. The later mansion
departure and #80 powers are implemented; the current contract appears above.

In Inventory, C saves/withdraws the selected object. Slots/load limits and restrictions
are retained for equipment placed, loans, mission reserves and crafting. Delivery allows
the player to reorganise its content even if the initial 10 kg temporarily increase its
load. Text gives instructions and the path of the passage/lift/cave. From 0t indicates
where to examine the appearance.

## Essential residents and post-combat dialogue (4.33.0r)

In MAP01, the four CaelumAnchoredResident with StoryAnchored activate the native BUDDHA
flag before DamageMobj and on loading. The engine limits normal damage to leave 1 health
before entering death. In the test, reach that active minimum CrouchIdle and temporarily
remove collision, attacks and damage reception. Retrying or winning restores resources,
armor, posture and interaction. Die maintains a fallback for forced damage/telefrag,
which ignores native BUDDHA. Unanchored diagnostic instances retain its normal rules.

A_Chase can leave INCOMBAT after a projectile attack. StartConversation rejects that
flag even if the actor is in full health. The flag is cleared out of combat and in the
waiting/house state, along with Target/LastEnemy and attack flags. A conversation that
still belongs to a player is not interrupted. 0q saves recover the interaction without
repeating the test.

A saved narrative instance with health <= 0, CORPSE or KILLED is repaired through Revive
and restoration of size, resources and protection; it retains identity, home
coordinates, references and quest state. If the trial remains active, it stays out of
combat with 1 health until the trial ends. Do not respawn copies, alter loot, advance
stages or increase the monster total during repair. An already-destroyed actor is not a
recoverable instance.

Rulo recognizes leadership and innate strength in victory, repetition and detail. There
is no new statistical bonus or exposure of the Limbo secret. 0t adds El Loco in the
cave, capture and bonus of Major Arcana. That reward belongs to the card, not to the
practice of Rulo.

## Accompanied combat and Bull performance (4.33.0q)

The Bull retains 900 kg and its offensive profile. Upon entering, the four existing
residents are placed in the formation during the two seconds of preparation: Rulo
(-2010,-155,0), Ronnie (-2010,155,0), Argento (-1900,-220,0), Caella (-1900,220,0).
Rulo/Ronnie use melee; Argento/Caella retain melee and its native elemental projectiles.
No statistics or weapons are added. The Bull retains a valid target of the group and
seeks another if it falls.

RuloPartyMode and references to player/Toro live in each resident and are serialized by
the engine. Mode 1 prepares, 2 fights and 3 waits for closure. A lethal gore leaves the
resident with 1 health, crouching, no blocking or attacks. Retrying and victory restore
health, Air, Anima, Lucidity and armor. The group does not inflict damage on the player
or on each other: their projectiles cross allies and the receivers filter the damage.
The player’s defeat also removes the projectiles from the comrades before reboot. The
narrative NPC is not lost. After winning, Rulo receives the return there. When
completing and leaving the view of all, the same instances recover their bedrooms. This
meeting does not add a travel route or change the physical route of Palomo.

Reference yield, not exact weight deductible only from the live mass:

| Concept | Model for the Bull 900 kg |
| --- | ---: |
| Fresh, wet and unprocessed skin | 54 kg: design assumption of 6 % live mass. |
| Usable finished leather | 54 × 255 / 1100 = 12,518 kg. |
| Native loot | 12,5 kg; 12.500 units, five 2,5 kg stacks. |

The 6 % is an explicit estimate for this fictitious animal; it is not a universally
validated measurement or percentage for a known breed/age bull. The tanning approach
with the UNIDO balance of bovine skins: 1100 kg of fresh skin produce 195 kg of grain
leather and 60 kg of split leather. It is a case of manufacturing leather for footwear,
not a constant for all tannings. Source: Buljan, Reich and Ludvik, *Mass Balance in
Leather Processing*, 2000, page 4,
https://leatherpanel.org/sites/default/files/publications-attachments/mass_balance.pdf

The automatic delivery of finished leather maintains the abstraction of loot already
used. It does not modify the overall tanning recipe or apply another decrease when
collecting. GetLeatherYieldUnits uses Mass and rounds to 100 g; the size does not
influence that physical ceiling. From 0ad is delivered Min(physical roof, unissued
leather quota). The old LeatherBudgetUnits is preserved to read saves, but recalculates
when dying; LeatherDropped continues to guarantee a single delivery. Leather
produced/picked in a previous victory is not removed.

Argento uses the same stages of the Journal; the instructions that named it are resolved
to own texts in the first person, in Spanish and English.

## Real Shield and Sword View (4.33.0u)

Ronnie lends exclusively a sword. FindActiveNativeShield demands a native instance
equipped, outside the Box and matching in type/tier/size. RepairActiveShieldReference
recovers its ItemId if applicable; without valid instance cleans the model. It runs
before the View Tick and syncing inventory/save; old migration occurs before repairing
references. HasActiveBlockSource also requires durability and compatibility with the
weapon. Giant gauntlets retain their own Block.

The modular sword view always removes the 10/20 layers without a valid shield, even if
the visual display saves already says that there is no shield. Equipping a real one
restores those layers. The rules of hand, costs and defense do not change.
HUDHasActiveBlockSource is a reading for the instructions of the UI; it does not grant
equipment nor is combat authority.

## Rulo combat test (4.33.0p; updated 0u guide)

Authority: Inventory traveler and existing 30–38 flags; 59–60 for spent/recovered air
without expanding the 64 array or renumbering flags. 60 phase + Argento/Caella/Ronnie
complete enables the start to Rulo (70). The defeat of the bull marks 36; return to Rulo
brand 37/38 and advance to 75.

| Practice | Actual confirmation |
| --- | --- |
| Primary | Impact on the target with Fire, melee or projectile. |
| Secondary | AltFire hit; ranged Aim; for a spear without a secondary attack, strike while moving forward. |
| Defense | Blocking with actual compatible equipment/gauntlets, ranged ADS or 48 MU of lateral movement inside the ground-floor room. Greatsword uses dodge; Zoom does not block. |
| Advanced | Charged hit, magical impact thrown in lateral displacement or completed reload. |
| Air spent | Actual resource decrease inside the practice room. |
| Air recovered | Post-expenditure increase. |

Rulo and Detail choose the indication from the active equipment: aim, block or dodge.
The greatsword receives an explicit explanation. Moving the camera without walking does
not count; lateral scroll controls must be used in front of the target. The brand is
updated when you pass the route and persists when loading. No dodge button or new
defense is added to the greatsword.

The magic in motion avoids demanding a loaded attack whose cost exceeds the maximum
Anima of some characters. No changes are made to costs, damage or attributes. Brands are
not restarted when re-opening the dialogue or charging. The key requires all six
practices. The target gives no experience, adrenaline, loot or wear by impact; it
retains the art and volume of the existing TrainingDummy.

Rulo refurbishes the initial weapon on its same ItemId and lends 24 units of the
necessary native ammunition. The loan is spent first, is replenished if it runs out
inside the enclosure and when preparing a new attempt, and cannot be released by
inventory while the ammunition is borrowed. The return removes only the remainder and
adjusts the magazines; it retains its own units. It checks load capacity before
delivering. The javelin does not produce recovered materials while this test is active:
it cannot convert the reconditioning into raw materials. Its AltFire melee now reuses
the existing main range, correcting the old zero value of the fallback.

The tutorial bull retains profile, mass, anatomy and native damage. Adjustments of this
delivery to check in game: 18 tics of gore anticipation, 2 seconds of initial
preparation/retry. The entry starts the test; the key alone does not wake the bull. The
two leaves of door 806 are blocked and the bull is contained in its room. The player’s
death is intercepted before native Die and the restart is completed to the next
WorldTick: positions, Health/Air/Lucidity, elemental states and initial weapon. The
projectiles of the attempt are removed; no leather is generated or increased. The
defeated bull opens the enclosure, delivers once the leather within the current quota
(up to 12,5 kg from 0q) and dissipates. It is spoken with Rulo within the enclosure to
close.

## Knowledge of recipes and manual removal (4.33.0o)

The Ronnie test shows the chosen recipe and its components/processings. The MAP01
External Processing Manual (LORE-0001) is removed; loading a previous game also removes
that copy from the world. Learned recipes are not revoked or objects removed from the
inventory. The manual class remains for compatibility and other uses; learning rules are
not modified. 0n was approved by the author the 2026-09-11.

## Historical cost and supply reference (4.33.0n–0ac)

The stock described in this section was replaced by 0ad quotas. Cost formulas do not
change; only the delivery of raw materials.

Source: GZDoom native blueprint 4.14.2, size M, efficiency 25 % in each layer, empty
inventory. Each set includes head, torso, hands and feet; "seals" comprise all five
elements. Current recipes are not changed.

| T1 family | Cow leather already tanned for set M |
| --- | ---: |
| Magic | 41,6 kg |
| Light | 78,4 kg |
| Medium | 156,8 kg |
| Heavy | 313,6 kg |

They are 590,4 kg for all four sets. If you are split from raw skin and cured to 25 %,
those quantities multiply by four. Do not confuse units of material (0,001 kg) with
whole objects. These values describe the manufacturing cost, not the current bull loot.
Since 0q, its 12,5 kg no longer covers a complete set to 25 % per layer. The drawer
retains 96 kg in M for the first gauntlets. Gun + any complete set is not guaranteed
simultaneously: for example, M gauntlets consume the reserve and an M heavy armor needs
another 313,6 kg; 301,1 kg would be missing after the new loot.

Seals T1: 460,8 kg raw copper, 51,2 kg raw tin and 9,6 kg each gem. The five veins cover
those types and quantities. By decision of the author, the supply of MAP01 is limited to
T1. As a reference outside that range, T2 seals: 256 kg raw iron, 16 kg raw silver and
19,2 kg of each gem; iron/silver sources are missing. T2 armors use predator leather, as
well as cow leather for straps and silver for details. T3 sum monster leather for armor
and gold; T3 seals also require steel (iron/coal), silver and gold. Available
infrastructure does not imply any knowledge or materials.

Giant gauntlets T1/M to 25 %: 96 kg of leather already tanned for your straps. It is the
only initial choice with leather. The drawer retains a reservation for that recipe
before the Toro, calculated on the size chosen. The recipe is not modified. The
migration removes only the stock of gems from the drawer, retains what has already been
collected and discountes the leather removed before updating. It does not replace
consumptions.

This reference consolidates implemented rules. Narrative scope is in
[MAP01.txt](MAP01.txt), acceptance status in [PROJECT.md](PROJECT.md) and historical
variants in [HISTORY.md](HISTORY.md).

## Caella test (4.33.0i–0m; impact checks updated in 4.37.1 / #62)

It is enabled when closing Argento in phase 35. Fire and AltFire each require a
valid player magic projectile impact on the shared mansion training dummy in the
north-central ground-floor room, off the central hall. The projectile's stored
mode determines primary/secondary; casting, missing, hitting another target or
using a physical attack does not satisfy either offensive objective. Staff,
book, bell and statuette retain their native attacks, including actual explosive
damage reaching the dummy. The target stays indestructible and reusable by Rulo.

User2 retains Seal Channel with actual Adrenaline expense and needs no impact.
Anima is spent on completed release, even a miss; recovery is observed in the
actual reserve independently of offensive hits. The old MAP01 Reload/Channel
display remains replaced by User2. Existing combat costs and dispersion remain.
Caella preparation reuses the existing missing-target recovery path without
duplicating a present target. Existing active/completed 4.37.0 save flags, rune
progress and loan IDs are preserved, including offensive flags earned under the
former cast-based rule. There are no new saved fields or conversion/reset steps.

The practice requires five actions followed by four runes; the Journal counts from 0/9
to 9/9. Use on a rune with an active implement channels its element. Earth → Air → Fire
→ Water records 4/4 and asks the player to return to Caella. It remains at stage 40,
with borrowed equipment and a solid wall. The return response to Caella removes only
CA_LimboMagicImplement/Seal, advances to stage 45 and enables passage. The wall retains
CMIN01 on both sides and the runes remain lit: the player walks through it. Owned
equipment is not removed. An error resets only the runes; hints appear after 2 and 4
errors. A save already completed in 0l retains its stage and returns; the texture is
restored without blocking passage again.

The two temporary instances reuse T1 from the catalog. They retain ItemId and the
CA_ITEMFLAG_LIMBO_TEMP brand; they are not sold, released, disarmed or stored in the
Box. There is no duplication when preparing again. To show Channel without attacking
anyone, the first User2 can top up the reserve up to a second of its native cost,
limited by MaximumAdrenaline. The assistance ends when recording actual consumption.
Cooldowns, general combat and attributes do not change.

Persistence adds sequence index, errors, Anima reference and previous equipment IDs;
uses 57–58 free flags. Do not shift accepted fields/indices. Placement, compatibility,
testing and limits are in PROJECT.md.

## Ronnie: choice, materials and first weapon (4.33.0l)

Historical baseline: the 4.37.3 section above supersedes the choice speaker,
shield scope, temporary-equipment classification and final departure restriction.
The existing recipes, task flow and other supply rules continue to apply.

After Caella, Ronnie offers 36 T1 choices: 16 physical weapons and four magic shapes for
five essences. The class does not restrict the choice. It can be read and returned
before confirming; confirming sets the character's choice and size. You learn the final
recipe and all its processing steps/components. The quantities are calculated using
CaelumCraftingRules; there is no other recipe table within the mission. Since 0ad the
reference plan uses 100% on each layer.

| Weapons | T1 catalogue raw materials |
| --- | --- |
| Dagger, hatchet, machete, javelin, sword, axe, spear, greatsword, war axe, halberd | Wood, raw copper and raw tin. |
| Flail and carbine | Raw copper and raw tin. |
| Giant gauntlets | Raw copper, raw tin and already tanned cow leather. |
| Common bow, long bow and crossbow | Wood and vegetable fiber. |
| Staff and statuette | Raw wood and gem of the chosen essence. |
| Bell | Raw copper, raw tin and raw gem. |
| Book | Vegetable fiber and raw gem. |

Gems: ruby/Fire, sapphire/Water, emerald/Earth, topaz/Air and opal/Quintessence. The
five gems are extracted from veins at the bottom of the cave. The drawer contains only
leather T1 already tanned. From 0ad covers the chosen set and, where appropriate, giant
gauntlets, to 100% by transformation: these use 6.000 units in M. Each unit weighs 0,001
kg. Only the unissued quota that fits in the current load is removed; it is not
necessary to carry it all at once.

The stock belongs to the character's record. Reopen/load does not replace it. Return
only amounts removed from that chest that remain unexpended and are not booked for a
task. Cancel releases reservations; closing the station pauses work. Materials can be
processed by stages; the supply of 0ad requires 100% in each layer to cover the entire
set. The Journal’s missing-materials display also accounts for components and processed
materials already owned by the player.

Twenty 2D shrubs surround the entrance along with four ceibos: cutting damage produces
bush fiber and tree wood; piercing/blunt damage does not. The vegetation is removed from
the cave. Each shrub has 10 kg and hardness 2,5, as well as wood, and retains general
regeneration. The borrowed T1 sword uses main cutting and piercing secondary attack for
copper/tin veins. If there is already the old cave sword in stock, your ItemId is
adopted. Requesting it again restores/equips the same piece. Caella removes only her
loaned items.

The first T1 manufacturing within this test delivers a personal instance with
CA_ITEMFLAG_LIMBO_PRESERVABLE. It does not require Magic Box, retains its efficiencies
and moves to 60 phase. The loan is returned when talking to Ronnie. Before leaving the
Limbo the initial weapon is not sold, discarded or disarmed. The weapons manufactured
afterwards are temporary and do not replace your ItemId. Technical cleanup of
development trips removes those instances and amounts of mission, preserving previous
portions of its own. The 0v narrative exit applies the strictest final rule: only Box
and first weapon, including cleaning of the other stored objects. Upon arrival, the
weapon can be recovered and used as ordinary equipment.

The stacks use LimboQuestUnits and LimboSupplyUnits; consumption first deducts the
tutorial portion. The crafting retains that origin in their intermediate results and in
the reservations when saving/loading. Stacks containing a tutorial portion cannot be
sold, dropped or sent to the Box. Narrative exit requires the player to finish or
cancel the task personally; it does not delete active reservations. Technical cleanup
of development trips does not eliminate own stocks by name matching or grant returned
loans again. Narrative confirmation does warn and remove all other physical objects.

0n incorporates arrows and 0w adds optional repair after closing Ronnie. Needs (0x),
Air/Movement (0y), Load (0z) and Pool Breathing (0ab) have optional practices. Bolts and
their teaching are added to 0ac. 0ad incorporates the chosen armor recipes and 0ae
seals. Bullets (composition/process) and water collection/potabilization are still
pending; no expansion is a new requirement to start to Rulo.

### Crafts arrows and controls (4.33.0n)

Choosing the longbow shows the recipe 129 and its dependencies. It also applies to
saves with those choices. Previous 129 recipes retain their indices and knowledge; the
catalog passes to 130 entries. Filter Munitions.

One batch produces ten CaelumArrowAmmo of 50 g each. Built-in composition: 350 units of
shaft and 150 of bronze tip per batch before material loss; to 25 % the assembly
consumes 1.400/600, and each component/processing step adds its own material loss. Use
bench, carpentry/forging and ranged workshop of Ronnie through the native system of
dependencies. The task reserves, pauses, cancels and persists like the others. It does
not require Box and does not record or replace the first weapon. The arrows have fixed
tier 1 and fixed lot of ten; B does not increase that lot.

Tab closes Crafts with or without station. G filters families during the session (the Y
control button retains that function). Q/Escape continues to close the session. Doors
and stations demand vertical overlap, foot difference <=64 MU and CheckSight before
performing the interaction. The station also checks range while maintaining the session;
changing floor closes it and pauses the task.

### Key, Bull and Palomo’s departure (4.33.0n)

Argento has a silver key instance; it is transferred to the player without recreating
another. It requires Argento/Caella/Ronnie complete and the six practices of Rulo (or
its already complete branch). Demanding the defeated Bull would be circular. The lesson
is connected from 0p. The Bull waits inactive until ENTERING the enclosure with the key
and preparation finished. From 0q the group meets before the first attack. Death records
the result and produces the mass-based leather described above. Save does not duplicate
key, actor or loot.

After the initial dialog is finished, Palomo keeps SOLID on and INVISIBLE disabled. He
runs using XY velocity, vertical physics, stairs and unlocked doors, then waits
upstairs. The path is saved. New states are added at the end to keep sprite indexes in
old saves. The final conversation is connected after Rulo.

## Mass of shrubs and garden migration (4.33.0m)

The shrub represents approximately 1,5 m in height and 2,2 m of crown width; the adopted
mass is **10 kg of fresh above-ground biomass**, an estimate for that specimen, not a
universal species weight or a weighing. Roots and soil are excluded. Foliage contains
air: it is not calculated as a solid wooden cylinder. As an indicative model of that
estimate, 0,012 m³ of stems/branches at an assumed density of 650 kg/m³ totals 7,8 kg,
plus 2,2 kg of leaves/thin stems. These are modeling assumptions, not botanical
measurements; a documented species/size would allow replacing them with a specific
allometric estimate.

The game system converts that mass to capacity with 1 unit = 0,001 kg: 10.000 units per
bush and 200.000 between twenty. It is an accumulated reserve, not the yield per stroke
nor a claim that a real plant will become entirely textile fiber. Each cutting impact
releases power × (1−2,5/10), limited by the remaining reserve, accumulating fractions.
The mass limits the total; hardness and power determine the extraction by impact. The
worst existing T1/XL plan needs 144.000 units of fiber to 25% in each layer, so the
initial garden is sufficient without increasing the mass of each plant.

When loading 0l the remaining proportion of the three old nodes is moved to the twenty
new ones. Its original capacity of 100 kg is used: GZDoom can omit Mass when it matches
the Default and apply the new Default when deserializing. The materials already
collected are not removed. Subsequent loads do not redistribute or refill anything;
native regeneration continues. Veins and chests are not moved.

## MAP01 workshops (4.33.0m–0n)

Each room has its own network; only neighbors to 64 MU or less and with the same
CraftingRoomGroup add up infrastructure. Group zero retains unrestricted networks on
other maps. There are no capacity loans between walls or floors.

| Room | Physical infrastructure | Coverage |
| --- | --- | --- |
| Rulo, north by the entrance, Z136 | Workbench, forge, anvil, armor workshop, sewing machine | T1–T2 heavy weapons and armor, with its components. |
| Ronnie, north by the stairs, Z136 | The previous five, ranged workshop and sawmill | T1–T2 medium weapons/armor and ranged weapons. |
| Argento, south by the stairs, Z136 | Workbench, forge, anvil, armor workshop, sewing machine | Lightweight weapons and armor T1–T2, with its components. |
| Caella, south by the entrance, Z136 | The five commons, altar, globe, jeweler’s bench and fine tools | T1–T2 magic weapons and armors, processing gems/essences/fabrics. |
| Second floor interior room, Z264 | The twelve stations, including the Master Workbench | Complete network; recipes and materials are still needed. |

In 0n the bedrooms use their corners; upstairs the twelve form a row against the back
wall, X=-336. The network of each room is conserved.

They are narrative specializations and infrastructure, not new restrictions by
class/family. Physical families share forging/sewing according to the catalog. There is
no Master Workbench in dormitories. 18 existing instances are retained when moved and 20
are added: total 38. A task that was in a transferred station is paused as it moves
away, preserving progress, materials and reserves; it is resumed from the right
infrastructure. T2 economy is not modified nor T2 materials are given as part of the
first T1 weapon.

## Character Poses (4.33.0m)

Rulo/RSRU, Ronnie/RSRO, Argento/RSAR, Caella/RSCA and Domingo/RSDO share: RestSeated=A,
RestLying=B, CrouchIdle=C, CrouchWalk=D–G (6 tics per phase), eight rotations per frame.
Domingo switches between C and D–G during crouched movement; native physical crouching,
attacks, pain, death and returning to standing are preserved. The renderer receives the
crouched sprite to avoid compressing it twice. New states are appended: they do not
shift saved state indices. In 0m, seated/lying poses were prepared graphical states.
Since 0d, Domingo uses them in the player session: Sleep restores Sleep and Wait
maintains its consumption. Other NPC poses remain available as art, without routine
scheduling. 0e adds player furniture and camera; NPC rest routines are outside that
implementation.

## Social probability

Rulo uses **Emotion**, derived from Empathy. Caella uses **Persuasion**, derived from
Charisma. Both use new Type 2 and 120 difficulty, according to the decision for 0f.
Residents have no assigned faction: reputation modifier is neutral.

```text
Type 2 capacity = 100 + 3 * (attribute*attribute + 25*attribute) / 125
probabilidad (%) = limitar(redondear(capacidad × 100 / dificultad), 0, 100)
```

The rounding is to the nearest integer (`Floor(x + 0.5)`). For 1 to 99 percentages a
uniform integer is thrown from 1 to 100; there is success if roll <= percentage. 0 fails
and 100 succeeds automatically, without consuming the random-number generator. The
difficulty is not a percentage alone: you have to know the attribute.

| Difficulty | Attribute 10 | Attribute 30 | Attribute 50 |
| ---: | ---: | ---: | ---: |
| 50 | 100% | 100% | 100% |
| 100 | 100% | 100% | 100% |
| 120 | 90% | 100% | 100% |
| 150 | 72% | 93% | 100% |
| 200 | 54% | 70% | 95% |
| 300 | 36% | 47% | 63% |

At difficulty 120: attribute 0 -> 83%, 3 -> 85%, 10 -> 90%, 15 -> 95%,
19 -> 100% after rounding. Difficulty <=100 succeeds automatically even at
attribute 0 because Type 2 includes its 100% base. Difficulty and RNG rules
are unchanged; the probabilities follow the newly approved curve.

Ronnie does not roll dice. His direct option requires **Dialogue skill >= 1**, with:

```text
Type 1 dialogue bonus = (Eloquence*Eloquence + 25*Eloquence) / 125
```

Eloquence 4 gives 0.928 and does not reach; Eloquence 5 gives 1.2 and
enables the option. Dialogue skill 1 does not mean Eloquence 1.

Rulo/Caella attempts save the result, probability and die roll. Reopening the dialog
does not reroll. Failure unlocks Argento’s hint and an alternative response without
chance. Rulo also requires a respectful response: reading his emotion does not mean
obtaining his cooperation. The advice also allows you to continue with Ronnie after
visiting it even if you lack Dialogue skill.

## Resources, persistence and physics

Health, Anima, Air, Adrenaline, Lucidity, Hunger, Thirst and Sleep belong to the
character; the calculations live in the modules of attributes, statistics and resources.
The scale **1 game hour = 3 real minutes** is conserved. The states and formulas are not
rebalanced in 0h.

`Actor.Inv` and `CaelumPersistentCharacterState` are authoritative sources. HUD/Journal
uses snapshots, and USDF tokens are derived conditions. Exit/changemap transfer to
character; `map MAP02` initiates another character. Shared cooperative progress is not
yet implemented.

Collisions use the project physics modules and native movement restrictions. Do not
convert impulse formulas into a second weapon damage route. Complete historical
calibrations are preserved in HISTORY.md; crowd testing remains separate in CADEV02.

## Mission detail (4.33.0k–0l)

From 0ak, Left/Right selects a known mission; Up/Down also selects from the list. In
Journal → Missions, F (Y on a controller) alternates summary and Detail of the selected
mission. The description explains what it is about and what it should be done in the
current stage. In Detail, Up/Down crosses the text; TAB returns to the list and another
press closes the Journal. PgUp/PgDn or LB/RB changes tab. Navigation is local, does not
change progress or grants objects. Undiscovered quests do not appear.

During Caella it lists primary, secondary, channeling, anima expense and recovery as
Done/Pending. A 5/5 changes to runes sequence and riddle. A 4/4 requests to return with
Caella; after the 45 phase return indicates to speak with Ronnie. Argento uses that same
selector when asked with whom to follow, including collection and return of Ronnie. The
source is persistent record, not independent menu counters. The same location indication
is used in the Caella conversation and in detail to avoid contradictions.

Path: entrance → central corridor → bottom staircase. Stay on the ground floor, surround
it on the right/south and look at the back wall behind that side, near the floor.
Accepting the test makes the marks appear; 5/5 practice allows you to use them.
Approaching with active staff, aim and press Use. The seal of fire is enough; it is not
fired to activate the runes.

During Ronnie, Detail shows the weapon chosen, the raw material plan to 25%, the missing
quantities and locations of chests, bushes, veins and Workbench. After manufacturing, it
asks to return the sword; then it shows the finished preparation. The list of missions
indicates initial ready weapon.

## Presentation of Seal and Runes (4.33.0j)

The equipped Seal is seen on the right side of the HUD. It retains its colors if User2
can start the channeling or if it is already channeling; it appears on gray scale if
there is cooldown, insufficient Adrenaline or there is another system block. The same
availability query feeds the action and the HUD; observing it does not grant or consume
resources. Caella's initial help counts as available.

The remaining seconds, rounded upwards, are shown below during cooldown until they
disappear at zero. The wait retains the existing 60 s. Without Adrenaline, it is grey
and without a counter: that resource has no guaranteed recovery time. User2 stops
generating the central state text and generic central skill warning. The other controls
retain their behavior.

Caella uses the Spanish section [en], as well as the previous conversations. Practice
requires primary, secondary, channeling, spending and recovery of Anima. Then, with
active magic implement, Use activates each rune. A single Seal and borrowed staff serve
for Earth → Air → Fire → Water. Seal does not determine the element of rune and it is
not required to shoot it. Progress and repayment of the loan continue in the existing
persistent record.

The stations receive 3D models without changing their infrastructure logic.

## Crafting and repair

The station network is cumulative. Workbench and main station enable T1; the specialist
adds T2 and Master Workbench adds T3. Forge uses Anvil, Ranged uses Sawmill, Armor uses
Sewing Machine, Essences uses Earth Globe and Jewellery uses Fine Tools. The particular
requirements of recipes, including the shield anvil, remain valid.

The efficiency is chosen by layer: 25/50/100% with time factors 1/10/100. Material loss
propagates through quantities and each operation applies its factor once. The old rule
"everything takes ten seconds" does not describe the current manufacturing. Complexity,
units, batches, technical attribute and sublayers intervene in time. Trade retains its
time of ten seconds per transaction.

The tasks reserve materials and progress only with active session, within the range of
the station (96 MU) and with available infrastructure. Closing or moving away pauses;
cancel explicitly frees up reserves. Multilayer assembly allows from primary resources.
Proportional repair and disassembly use recipe and durability; elemental equipment
returns its corresponding materials.

## Common controls

| Input | Current function |
| --- | --- |
| Fire | Primary attack of the weapon; cancel Block while attacking. |
| AltFire | Secondary weapon attack; for ranged weapons, alternative Aim. |
| Reload | Reload ranged weapons; charge the next melee/magical attack. |
| Zoom | Sweeping with greatsword/war axe/halberd; Block with compatible equipment (including giant gauntlets); ADS for ranged weapons. |
| User1 | Interface reserved for racial ability; pending content. |
| User2 | Channel the equipped Seal. |
| User3 | Activate up to three selected captured essences under the #80 shared contract. |
| User4 | Class ability interface; pending content. |
| Use | Native interaction with NPC, stations, doors, lift and El Loco appearance. |
| Tab | Journal/Inventory; Tarot displays the collection from 0t. |

Charging has a 2 s base duration adjusted by speed; the prepared window lasts 3 s. The
next attack doubles damage and cost, and explosions double area (radius × sqrt(2)).
Incompatible pain and changes interrupt charging. The sword uses slashing Fire and
piercing AltFire, so it serves for trees and veins of the tutorial. The special hatchet
removed in 0d is not needed.

## Damage and Anima cost: Type 4 divisor (4.33.0aa)

F(A) = 1 + 2 × A × (A + 1) / 10100. Historical general damage used post-vulnerability damage / F(Dureza).
The 2026-09-28 #52 revision supersedes that damage divisor with the subtractive
maximum-health formula above; this historical divisor table still documents
its original release and the unchanged Anima-cost rule. Magical cost = base cost ×tier modifier × charge / F(Elocuencia).
T2 retains ×1,6 and T3 ×2,5; a prepared charge preserves ×2. The bell and statuette
retain their relative bases, reduced tenfold in 4.37.2 / #68 as specified above.
Player and NPC use the same curve, also for explosions; the entire
rounding of Engine Health is preserved.

| Attribute | Divisor | Remaining percentage |
| --- | --- | --- |
| 0 | 1 | 100% |
| 25 | 1,128713 | 88,5965% |
| 50 | 1,504950 | 66,4474% |
| 100 | 4 | 25% |

The reduction percentage showing debugging is the equivalent 100 × (1 − 1/F), not the
old Type 2 curve. 100 hardness no longer cancels the general damage and Eloquence 100 no
longer allows to launch for free. Higher values continue to use the divisor without an
artificial cap at 100. Dialogue skill retains Type 2. Pain and Lucidity loss retain
their previous formulas, both in player and NPC; the actual damage change may indirectly
affect their entry.

Collisions: exactly max(0, impact percentage × surface − hardness), then contact
vulnerability, armor and maximum health. The acrobatic bonus of the buckler and crushing
rules is also maintained. The general damage divisor is not applied again to the
collision result.

## Heavy-weapon sweep (4.33.0aa)

Zoom executes a 360° sweep with greatsword, axe of war and halberd. Primary range: 80,
76 and 84 MU, respectively, to the surface of the target. Use primary damage from the
tier, Strength, vulnerability and critical by enemy; retains armor, thrust and wear on
the damage caused. It is not an explosion. Search is spatial; each nearby enemy receives
at most one hit. A layout checks walls and floors 3D; allies, residents, players and
resources are excluded. Practice targets are an explicit exception.

3 × the actual primary Air cost is paid once per execution, even without targets. It is
not paid for by enemy. Insufficient air or cooldown prevents attack without consuming
it. Recovery is primary. Keep Zoom does not repeat: release and re-press. An already
prepared charge is consumed and retained ×2 damage/cost, so a charged sweep costs 6
uncharged primary attacks. Giant gauntlets keep Zoom/Block; Rulo continues to count the
side dodge as defense of the greatsword. The sweep does not replace that test.

## Detailed matrix of weapons

Technical matrix of preserved inputs; the visual enlargement of first person does not
modify these combat routes.

### Physical melee weapons

| Weapon | Fire | AltFire | Reload | Zoom |
| --- | --- | --- | --- | --- |
| Dagger | Piercing primary stab. | Stronger slashing attack with shorter range. | Charge next melee attack. | Shield Block. |
| Hatchet | Slashing primary attack. | Stronger blunt attack with shorter range. | Charge next melee attack. | Shield Block. |
| Machete | Slashing primary attack. | Stronger piercing attack with longer range. | Charge next melee attack. | Shield Block. |
| Javelin | Piercing melee thrust. | Throws the javelin; if a valid melee target is close, automatically uses the melee fallback. A real throw costs Air and one durability. | Charge next melee attack. | Shield Block. |
| Sword | Slashing primary attack. | Stronger piercing attack with longer range. | Charge next melee attack. | Shield Block. |
| Axe | Slashing primary attack. | Stronger blunt attack with shorter range. | Charge next melee attack. | Shield Block. |
| Flail | Blunt primary attack. | Stronger blunt attack at the same range. | Charge next melee attack. | Shield Block. |
| Spear | Piercing primary thrust. | No authored secondary attack in the current catalogue. | Charge next melee attack. | Shield Block. |
| Greatsword | Slashing primary attack. | Stronger piercing attack with longer range. | Charge next melee attack. | Sweep 360°: damage, scope and recovery of the primary; triple Air. |
| War Axe | Slashing primary attack. | Stronger blunt attack with shorter range. | Charge next melee attack. | Sweep 360°: damage, scope and recovery of the primary; triple Air. |
| Halberd | Slashing primary attack. | Stronger piercing attack with longer range. | Charge next melee attack. | Sweep 360°: damage, scope and recovery of the primary; triple Air. |
| Giant Gauntlets | Blunt primary punch. | Same damage, range and Air cost as Fire, with additional upward push. | Charge next melee attack. | Weapon-based Block using Buckler coverage, defense and special rules. |

### Ranged weapons

| Weapon | Fire | AltFire | Reload | Zoom |
| --- | --- | --- | --- | --- |
| Double-barrel shotgun | Fires twelve pellets using one cartridge. | Toggles Aim/ADS. | Loads up to two cartridges with the shared carbine reload pipeline. | Toggles the same Aim/ADS mode, real FOV and doubled physical accuracy. |
| Longbow | Fires its native longbow arrow. | Toggles Aim/ADS. | Reloads its independent magazine. | Toggles Aim/ADS, real FOV and doubled physical accuracy. |
| Crossbow | Fires its native bolt. | Toggles Aim/ADS. | Reloads its independent magazine. | Toggles Aim/ADS, real FOV and doubled physical accuracy. |
| Carbine | Fires its native carbine projectile. | Toggles Aim/ADS. | Reloads its independent magazine. | Toggles Aim/ADS, real FOV and doubled physical accuracy. |

### Magical implements

Every magical variant below exists at T1, T2 and T3 for Fire/Light, Water/Ice,
Earth/Poison, Air/Lightning and Quintessence. `Fire` selects the primary side of the
equipped essence and `AltFire` selects its secondary side.

| Implement | Fire and AltFire delivery | Reload | Zoom |
| --- | --- | --- | --- |
| Staff | One normal-speed direct magical projectile. | Charge next magical attack. | Shield Block when a shield is equipped. |
| Bell | Seven slow projectiles in a broad cone; every projectile rolls its own critical. Uses the confirmed half-damage/double-Anima baseline. | Charge next magical attack. | Shield Block when a shield is equipped. |
| Book | One fast homing magical projectile. | Charge next magical attack. | Shield Block when a shield is equipped. |
| Statuette | One explosive magical projectile; charged attacks double explosion area. | Charge next magical attack. | Shield Block when a shield is equipped. |

### Essence function used by every magical implement

| Essence | Fire | AltFire |
| --- | --- | --- |
| Fire / Light | Fire damage with Burn damage-over-time. | Light effect with Dazzle control and player illumination. |
| Water / Ice | Water projectile with extreme physical push. | Ice effect with Freeze control. |
| Earth / Poison | Earth effect that reduces target Lucidity. | Poison damage-over-time. |
| Air / Lightning | Air effect with Cut damage-over-time and moderate push. | Lightning Stun control. |
| Quintessence | Double-damage primary projectile. | Independently rolls the available Fire, Light, Water, Earth, Poison, Air and Lightning secondary effects. |

### Complete magical variant list

The following twenty implement/essence combinations each have T1, T2 and T3 selectors,
totaling sixty magical weapons:

| Essence | Staff | Bell | Book | Statuette |
| --- | --- | --- | --- | --- |
| Fire / Light | Fire Staff T1–T3 | Fire Bell T1–T3 | Fire Book T1–T3 | Fire Statuette T1–T3 |
| Water / Ice | Water Staff T1–T3 | Water Bell T1–T3 | Water Book T1–T3 | Water Statuette T1–T3 |
| Earth / Poison | Earth Staff T1–T3 | Earth Bell T1–T3 | Earth Book T1–T3 | Earth Statuette T1–T3 |
| Air / Lightning | Air Staff T1–T3 | Air Bell T1–T3 | Air Book T1–T3 | Air Statuette T1–T3 |
| Quintessence | Quintessence Staff T1–T3 | Quintessence Bell T1–T3 | Quintessence Book T1–T3 | Quintessence Statuette T1–T3 |

## Economy

Current values, kept from the accepted base V4.32.0a-r4.

### 1. Monetary unit

The accounting unit is the **monetary copper**. All internal economic amounts are
first expressed in copper equivalents. A silver monetary unit is equivalent to 200
coppers and a gold monetary unit is equivalent to 200 silvers, i.e. 40.000 coppers.

Each metal has coin denominations of 1, 5, 20, 50 and 100:

| Metal | Denomination | Copper value | Weight per coin |
| --- | ---: | ---: | ---: |
| Copper | 1 | 1 | 0,001 kg |
| Copper | 5 | 5 | 0,001 kg |
| Copper | 20 | 20 | 0,001 kg |
| Copper | 50 | 50 | 0,001 kg |
| Copper | 100 | 100 | 0,001 kg |
| Silver | 1 | 200 | 0,001 kg |
| Silver | 5 | 1.000 | 0,001 kg |
| Silver | 20 | 4.000 | 0,001 kg |
| Silver | 50 | 10.000 | 0,001 kg |
| Silver | 100 | 20.000 | 0,001 kg |
| Gold | 1 | 40.000 | 0,001 kg |
| Gold | 5 | 200.000 | 0,001 kg |
| Gold | 20 | 800.000 | 0,001 kg |
| Gold | 50 | 2.000.000 | 0,001 kg |
| Gold | 100 | 4.000.000 | 0,001 kg |

Coins are stackable physical objects of `Actor.Inv`. They persist in saves and travels,
can be collected and released, and obey the same carrying-capacity and Magic Box rules
as all other objects. The Journal's total visible sum up all the coins possessed,
including those stored in the Magic Box. Those that are outside contribute their full
weight; those saved enter the total actual weight that the Box divides by its maximum slots and truncates to 0,001 kg.

They are currency with a nominal value: the player cannot melt or mint them and their face
value is not derived from the value of the silver or gold used as materials.

Native classes:

- Copper: `CaelumCopperCoin`, `CaelumCopperCoin5`, `CaelumCopperCoin20`,
  `CaelumCopperCoin50`, `CaelumCopperCoin100`.
- Silver: `CaelumSilverCoin`, `CaelumSilverCoin5`, `CaelumSilverCoin20`,
  `CaelumSilverCoin50`, `CaelumSilverCoin100`.
- Gold: `CaelumGoldCoin`, `CaelumGoldCoin5`, `CaelumGoldCoin20`, `CaelumGoldCoin50`,
  `CaelumGoldCoin100`.

### 2. Base values of raw materials and consumables

The following prices are authorized design anchors. The hardness and abundance accepted
in V4.31 continue to determine how much it costs to obtain a resource in time and
effort, but no longer automatically recalculate its monetary value.

| Raw material | Coppers per unit of 0,001 kg |
| --- | ---: |
| Common timber | 2 |
| Plant fiber | 3 |
| Cowhide | 3 |
| Mineral coal | 5 |
| Raw copper | 5 |
| Raw tin | 5 |
| Raw iron | 7 |
| Raw silver | 100 |
| Raw opal | 500 |
| Raw topaz | 500 |
| Raw emerald | 500 |
| Raw sapphire | 500 |
| Raw ruby | 500 |
| Raw gold | 1.000 |

Wool, cotton, raw silk, predator hide and monster hide retain their previous temporary
anchors for the time being:

| Family | Grade 1 | Grade 2 | Grade 3 |
| --- | ---: | ---: | ---: |
| Fiber: wool/cotton/raw silk | 2 | 4 | 8 |
| Hide: cow / predator / monster | 3 | 4 | 8 |

Changing those outstanding values will require an explicit design decision; the
abundance of the source will not overwrite them alone.

The following values correspond to a complete consumable item, not to a
gram of content:

| Consumable | Base value in copper |
| --- | ---: |
| Food ration | 4 |
| Water ration | 6 |

### 3. Recursive value of manufacture

The system calculates the value with the actual recipes and always takes as reference
the **material efficiency of 100 %**. The playable efficiencies of 25/50/100 % and its
times 1×/10×/100× remain intact; the material loss resulting from the player’s chosen efficiency does not redefine the
base price of the object.

#### 3.1 Basic processing

For ingots, alloys, fabric, string and leather:

```text
valor unitario de salida =
    suma(valor unitario de cada insumo × unidades requeridas)
    × 1,25
    / unidades de salida al 100 %
```

The surcharge for this stage is always **25 %**.

#### 3.2 Components

Each component takes the value of the material **already processed** it consumes, not
its original raw material. It then applies the surcharge corresponding to the network of
stations in its tier:

| Tier | Cumulative infrastructure | Added value |
| --- | --- | ---: |
| T1 | Workbench + main station | 25 % |
| T2 | Network T1 + specialized station | 50 % |
| T3 | T2 network + Master Workbench | 100 % |

Shields retain their additional anvil requirement; it does not change the tier or double
the surcharge.

#### 3.3 Final items

Physical weapons, essence weapons, armor, shields, amulets and seals add up to the
value of their already manufactured components, including the details of silver and gold
in the recipe. On this sum, the T1/T2/T3 surcharge in the table above applies again.
Therefore, each stage retains its own labor and the value accumulates recursively.

`CaelumEconomyRules` exposes the calculation by material, by object family and by native
inventory instance. Food and water rations already have authorized base value.
Ammunition, other consumables, keys and key objects do not yet enter the commercial
catalog because they lack a recipe or an authorized base value; returning an invented
price to them would violate this rule.

### 4. Trader Margins

The margin applies only once to the total lot:

```text
NPC compra al jugador = piso(valor base total × 0,50)
NPC vende al jugador  = techo(valor base total × 1,50)
```

The floor when paying and the ceiling when charging avoid creating copper by rounding.
Applying the margin after adding the lot allows, for example, that two units with base value 1 sell together for 1 copper even though a single unit produces an unrepresentable fraction.

Authoritative methods are:

- `CaelumEconomyRules.GetPricePaidByMerchant`
- `CaelumEconomyRules.GetPriceChargedByMerchant`

These are the normal margins of the commercial infrastructure. The subsequent discount test
retains the player's purchase to 140% and sale to 60%; it is not available from Palomo
canonical MAP01. 0an enables it to be activated by a reputational condition in services
that declare it, without making it permanent. Narrative assignments, personalities and
definitive regional prices remain pending.

### 5. Presentation in inventory

The Journal incorporates a coin filter and, together with **Load** and **MagicBox**,
shows:

- total value expressed in coppers;
- total physical number of copper coins, adding their five denominations;
- total physical quantity of silver coins, adding their five denominations;
- total physical number of gold coins, adding up their five denominations.

The Magic Box line also shows your used/maximum slots and their total weight: 10,000 kg
own plus the reduced contribution of all content. The formula, restrictions and cases of
change of Intelligence are documented in `SYSTEMS.md`.

The three RGBA 64×64 icons supplied for Caelum Argenteum are preserved unredrawn in
`graphics/caelum/icons/currency/`. The five denominations of the same metal share image
and are distinguished by their localized name and face value. Copies registered as
`CCOP`, `CSIL` and `CGOL` also allow each coin to exist as a visible pickup in the
world.

### 6. Prisoner coin reward

[IMPLEMENTED, AUTHOR ACCEPTANCE PENDING] Issue #14, 4.36.8. The
latest author decision, explicitly referenced by #10 and verified against #14,
supersedes the former average-weapon-price formula reconciled in #22.

Each successfully rescued prisoner grants **25 gold coins plus +10 reputation
with that prisoner's own faction**, once per entitled character at the port.
The payout is independent of size, weapon tier, prices, margins or discounts.
Use the existing physical currency helpers and denomination rules: 40,000
copper per gold, hence 1,000,000 copper per rescue; four rescues total 100 gold.
Preserve independent claims across saves/travel. Failed coin delivery remains
retryable without duplicate money or reputation. Keep one shared reward
definition; do not implement a price-averaging table for this reward.

The superseded 4.36.1b reference-set/price formula is preserved in HISTORY.
This documentation correction does not implement escort or reward gameplay.

### 1. Nature and Own Weight

The Magic Box has an Inventory instance with owner and ItemId from 0s; its content and
weight remain centralized in the character. It does not add a selectable entry to the
list: it cannot be dropped, sold, destroyed or stored within itself. Before receiving
it does not add weight, it does not offer slots and no pickup, crafting or interface
path can save objects in it. Upon receiving it, its structure contributes **10,000 kg**
to the load even when it is empty.

The maximum number of slots continues to derive from Intelligence. Each individual piece
of equipment and each supported stack occupies one slot, no matter how many units the
stack contains.

### 2. Weight reduction

The content does not lose all its weight. The load is calculated with a single aggregate operation:

```text
peso reducido del contenido =
    piso_a_0,001 kg(peso real total guardado / slots máximos actuales)

peso total de la Caja Mágica =
    10,000 kg + peso reducido del contenido
```

The maximum **slots** are used, not the occupied ones. The weight of all items and stacks is summed
before dividing and rounding. This prevents separating the same weight between multiple
stacks from removing load by individual roundings.

Example: with 20 maximum slots and 10,000 kg actually stored, the content provides 0,500
kg and the complete box provides 10,500 kg. With 0,380 kg stored, the content provides
0,019 kg.

### 3. Content and restrictions

Existing rules are preserved:

- equipment, consumables, materials, coins, key items admitted and custom ammunition stacks
  can be stored;
- common keys cannot be saved because GZDoom checks their native possession for doors and
  `LOCKDEFS`;
- Native arrows and bolts remain in the personal inventory;
- a complete stack still counts as a single slot, but all its units contribute to the
  actual weight prior to reduction;
- the stored coins retain their full value and share the reduced weight as any other stack.

### 4. Transactions and capacity changes

Collecting, depositing, recovering, equipping, crafting and disassembling evaluate the
complete final load. An operation is rejected if, after removing the weight from its
previous location and adding it to the new one, the load would exceed the character’s
capacity. Moving an item from personal inventory to the box continues to be allowed when
releasing load.

If an Intelligence change reduces maximum slots below the already occupied ones, the
content is retained: it is not removed or expelled. The divisor and load are
recalculated immediately, and new deposits are blocked until occupancy is back within the maximum. Recovering or releasing content remains the way to free slots.

### 5. Interface

The Inventory shows `slots usados/máximos` and the current total weight of the box,
including its own 10,000 kg. The general Load line incorporates exactly the same value.
The selected item’s weight continues to show the actual weight of the object or
stack before reduction. The 64×64 icon provided is displayed next to this line; before
the gift it is dimmed with the `No adquirida` text. Trying to store from Inventory
before the gift returns an explicit cause and does not change the object.

### 6. Acquisition and save compatibility

- A new profile is explicitly marked as a non-owner.
- The first canonical encounter with Palomo does not grant the Box or open commerce.
- Accepting Palomo’s offer, after closing the four branches in phase 75, advances to
  `MAIN_M00_STATE_BOX_RECEIVED`. Questions and closing the conversation deliver nothing.
- The gift adds its 10 kg and enables slots once by `MAIN_M00_FLAG_MAGIC_BOX_GRANTED`; an
  inherited Box retains its weight.
- `CaelumPersistentCharacterState` is the persistent source of ownership. It is saved to
  `PreTravelled` and restored to `Travelled`; the live field and technical marker are
  synchronized from that record.
- Ownership is independent of the physical location of Palomo.
- Confirmed profiles created before V4.32.0b retain the Box during migration. This avoids
  losing access to content that was already saved.
- A malformed intermediate save that does not have the reward but contains `InMagicBox` flags is repaired by moving those stacks to the personal inventory; no objects are removed.

### 7. Integration with Mission Log

`GrantMagicBoxFromPalomo()` does not alter the mission record on its own. In 0s,
AcceptMagicBox validates the conversation and RecordMainM00MagicBoxGranted confirms
phase/flag after checking property and identity. The canonical mission **Where the lost
awaken** begins on awakening and its first objective is to seek help. Owning a Box from
an earlier game does not skip the Voice, the presentation of Palomo or the orientation
to Argento.

When migrating V4.33.0a, only the discarded commercial quest is restarted. The existing
Box is not duplicated or removed, and retains exactly content, slots, weight and
reduction. This allows testing the new prologue without destroying development inventory
and keeps new characters in canonical progression without Box.

Palomo remains hidden before the Voice and is revealed in the hall. From 0n it visibly
travels the stairs after the initial dialogue; it is retained that same instance above.
The Journal solver indicates it on the second floor from phase 75. In 0s he can speak
there: he guides the player if trials remain incomplete, offers the Box once they are
complete, and helps the player use it after receipt.

The test of the mission is to use the final door after capturing El Loco and confirming
the crossing. `changemap MAP02` tests development journey, but omits narrative
transaction. `map MAP02` starts another character without Box and does not prove that
persistence. `map CADEV02` is used for independent actor testing.

## Native dialogues and audio

From 0b the conversations keep the simulation active. MAPINFO declares
UnFreezeSinglePlayerConversations and the common menu omits the delayed pause of
ConversationMenu.Ticker, also when loading previous snapshots.

`GameInfo.AddDialogues` load CAPALOMO; Thing_SetConversation and StartConversation open
native menus. Q equals Back; Escape and controller buttons retain their engine controls.
Prologue Voice retains its only exit option, Continue. In sewers, Look around opens the final
help and Continue allows closing. Probabilities appear before choosing; Ronnie
requirement remains visible and gray when blocked. Rulo emotion is private information.

The first phrase of Simple Harp Loop (2,571429 s, with 450 ms drop) is the
`GameInfo.ChatSound` of the project. GZDoom emits a single local signal when opening a
conversation and when displaying each next page: Voice, Palomo, Argento, Rulo, Ronnie
and Caella. There is no other manual call when opening. A blocked option does not go
over the page and does not produce another signal. Cursor navigation does not amount to
advancing the text. The singular mark lets the current phrase finish if it is advanced
very quickly; it avoids accumulating overlapping chords. ChatSound is also the native
notification of the engine chat; its local reach and authority are not modified. See
ASSETS.md for source and editing.

The title screen plays once the 6 s War Drums. CaelumMenuAudio requests unlooped
playback when entering; does not change volumes, map music, or personal lists. Pause
menus retain the music of the game. When choosing Exit/Salir in the main menu,
CaelumExitMenu opens native confirmation and plays menu_strings_start while the audio is
still active. Cancel returns to the parent menu. QuitSound and the Exit button of the
map retain the same resource; the singular mark avoids overlapping two instances of
strings.
