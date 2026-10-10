"""Apply the reviewed #154 documentation changes once, preserving history."""
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[2]


def add_section(path, text):
    source = path.read_text(encoding='utf-8')
    if text.splitlines()[0] in source:
        return
    parts = source.split('\n', 4)
    path.write_text('\n'.join(parts[:4]) + '\n' + text.strip() + '\n\n' + parts[4], encoding='utf-8')


def main():
    current = ['AGENTS.md', 'README.md'] + ['docs/' + name for name in
        ('CONTEXT.md','PROJECT.md','SYSTEMS.md','MAP01.txt','ASSETS.md','HISTORY.md','TASKS.md')]
    for name in current:
        p=ROOT/name;s=p.read_text(encoding='utf-8')
        s=re.sub(r'(Documentation version:\s*\*\*)5\.1\.9',r'\g<1>5.1.10',s,count=1)
        s=s.replace('Current release: 5.1.9.','Current release: 5.1.10.',1)
        p.write_text(s,encoding='utf-8')

    add_section(ROOT/'docs/SYSTEMS.md', '''## SI physics and attribute growth — 5.1.10 / #154

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
attributes, quests, Tarot and accrued thermal exposure persist. Thermal revision
9 discards only an old in-progress reload's future budget and re-evaluates it;
already measured heat remains. World/projectile gravity revisions are separate
from growth revisions, so future curve changes cannot reapply gravity.
Rollback uses the untouched pre-upgrade save and matching old package; downgrading
a newly written save is not promised. Evidence is in assets/validation_5110;
native checks do not replace the author's outstanding tests in pending_test.txt.
''')

    p=ROOT/'docs/SYSTEMS.md';s=p.read_text(encoding='utf-8')
    replacements={
        '`CaelumThermalState` revision 8':'`CaelumThermalState` revision 9',
        'and the base +/-5 C displacement limit by an additive Type-2 factor (#136):\n`M=1+A*(A+1)/10100`.':'and the base +/-5 C displacement limit by a Type-1 multiplier (#154):\n`M=1+(A*A+25*A)/12500`.',
        'the existing Type-2 `R=D*(D+1)/101`':'the current Type-1 `R=(D*D+25*D)/125`',
        'metabolic energy `W/0.25=4W` and retained muscular heat `Q=3W`.':'metabolic energy `W/eta` and retained muscular heat `Q=W*(1/eta-1)` (#154).',
        'Heat is therefore\n1.5075/3.015 J/kg/m.':'At the 25% baseline, heat is\n1.5075/3.015 J/kg/m; current efficiency changes heat, not this work budget.',
        'three times work. For the 100 kg / 1.80 m body these are':'`W*(1/eta-1)`. At 25% efficiency, the 100 kg / 1.80 m body produces',
        'sweeps by 3, once each. A primary greatsword attack emits 900 J heat at either\nnormal or high attributes.':'sweeps by 3, once each. A primary greatsword attack emits 900 J at 25%\nefficiency and 300 J at 50% efficiency (#154).',
        'attacks 75 J, and Zupay\'s ground slam 850 J; heat is again three times work.':'attacks 75 J, and Zupay\'s ground slam 850 J; heat uses each actor\'s efficiency.',
        'At 100 kg / 1.80 m this emits 477.945/860.302 W heat.\nThe running command selects intensity; jump height and attributes do not.':'At 100 kg / 1.80 m and 25% efficiency this emits 477.945/860.302 W heat.\nThe running command selects work intensity; attributes affect efficiency, not the work profile.',
        'the existing Type 4 divisor; this is division, not a subtractive percentage.':'the new Type 2 divisor (#154); this is division, not a subtractive percentage.',
        '`F(E) = 1 + 2 * max(0,E) * (max(0,E) + 1) / 10100`':'`F(E) = 1 + 3 * (E*E + 25*E) / 12500`, with E=max(0,E)',
        '| Staff | 500 | 50 | 16.666666... |':'| Staff | 500 | 50 | 12.5 |',
        '| Book | 700 | 70 | 23.333333... |':'| Book | 700 | 70 | 17.5 |',
        '| Bell | 1000 | 100 | 33.333333... |':'| Bell | 1000 | 100 | 25 |',
        '| Statuette | 1000 | 100 | 33.333333... |':'| Statuette | 1000 | 100 | 25 |',
        '100 gives F=3 and one third of the base.':'100 gives F=4 and one quarter of the base.',
        '`F(A)=1+2*A*(A+1)/10100`':'`F(A)=1+3*(A*A+25*A)/12500`',
        '`R(L)=max(0,L)*(max(0,L)+1)/101`':'`R(L)=(L*L+25*L)/125`, with L=max(0,L),',
        'R = max(0, Toughness) * (max(0, Toughness) + 1) / 101':'R = (T*T + 25*T) / 125, where T=max(0,Toughness)',
        'P = max(0, S·E - T*(T+1)/101)':'P = max(0, S·E - (T*T+25*T)/125)',
        'from Resilience in #131; the Type-4 divisor':'from Resilience in #131; the new Type-2 divisor (#154)',
        'divisor D(A) = 1 + 2 * A * (A + 1) / 10100':'divisor D(A) = 1 + 3 * (A*A + 25*A) / 12500',
        '| 50 | 1,5049505 | 66,4474% |':'| 50 | 1.9 | 52.631579% |',
        '| 100 | 3 | 33,3333% |':'| 100 | 4 | 25% |',
        'At attribute 100, they become 216/108/144 minutes.':'At attribute 100, they become 288/144/192 minutes.',
        'Author confirmed Type 1: multiply by 1 + I*(I+1)/200':'Author confirmed the former Type 1, mapped by #154 to Type 3: multiply by 1 + 7*(I*I+25*I)/12500',
        'before Type 1/2/4.':'before the three current growth families.',
        'Charisma. Both use Type 4 and 120 difficulty':'Charisma. Both use new Type 2 and 120 difficulty',
        'capacidad Tipo 4 = 100 + 2 × atributo × (atributo + 1) / 101':'Type 2 capacity = 100 + 3 * (attribute*attribute + 25*attribute) / 125',
        'Labia Tipo 2 = Elocuencia × (Elocuencia + 1) / 101':'Type 1 dialogue bonus = (Eloquence*Eloquence + 25*Eloquence) / 125',
        'Eloquence 9 gives approximately 0,891 and does not reach; Eloquence 10 gives 1,089 and\nenables the option.':'Eloquence 4 gives 0.928 and does not reach; Eloquence 5 gives 1.2 and\nenables the option.',
    }
    for old,new in replacements.items():
        if old not in s: print('Review replacement absent:',old[:70])
        s=s.replace(old,new)
    old='Every accepted player jump pays the work of raising total moved mass by 0.5 m'
    start=s.index(old);end=s.index('\n\nPhysical weapon work',start)
    s=s[:start]+'''Every accepted player jump now charges its delivered kinetic energy under the
#154 contract above. The former 0.5 m / fixed-efficiency calibration is historical
(#136) and remains in HISTORY and the old validation records. New jump heat uses
effective Agility, biological versus moved mass, retained velocity penalties and
current muscular efficiency once at takeoff. Jump-derived proxies do not set the
work of other actions.'''+s[end:]
    # Update the active attribute matrix without changing historical release labels.
    start=s.index('## Audit of the twelve attributes');end=s.index('\n## ',start+4)
    section=s[start:end]
    section=re.sub(r'Type ([1234])',lambda m:'Type '+{'1':'3','2':'1','3':'1 complement','4':'2'}[m[1]],section)
    section=section.replace('Tipo1(Inteligencia)','Type3(Intelligence)').replace('Tipo4(A)','Type2(A)')
    section=section.replace('current code 4.33.0ai','current code 5.1.10 (#154)')
    begin=section.index('| Scale |');finish=section.index('\n\nProbabilities',begin)
    section=section[:begin]+'''| Scale | Formula | N=0 | N=100 |
| --- | --- | ---: | ---: |
| Type 1 bonus | B=(N*N+25*N)/125 | 0% | 100% |
| Type 2 multiplier | 1+3B/100 | 1 | 4 |
| Type 3 multiplier | 1+7B/100 | 1 | 8 |
| Harmful complement | clamp(1-B/100,0,1) | 1 | 0 |
| Division by Type 2 | base/(1+3B/100) | base | base/4 |'''+section[finish:]
    section=section.replace('R(T)=T(T+1)/101','R(T)=(T*T+25*T)/125')
    section=section.replace('Launch speed and range Type 2','Casting speed and ability range Type 2 (not projectile muzzle velocity)')
    section=section.replace('JumpZ scales with the square root of Type 3, so that the ideal ballistic height scales with Type 3 at equal gravity, before load/state modifiers.','Jump energy uses Type 3 and biological mass; native velocity follows total moved mass, then the retained state modifiers.')
    section=section.replace('Author\'s later decision, after approving 0ai: maintain attributes as they are. Further\naudit is postponed and does not block V4.34.','Historical 0ai deferred further changes. The author has now authorized the #154 curve mapping and physics contract; unrelated missing systems in this matrix remain pending.')
    s=s[:start]+section+s[end:]
    # Recompute the social examples, preserving difficulty and RNG policy.
    start=s.index('| Difficulty | Attribute 10');end=s.index('\n\nRonnie does not roll',start)
    table='| Difficulty | Attribute 10 | Attribute 30 | Attribute 50 |\n| ---: | ---: | ---: | ---: |\n'
    for difficulty in (50,100,120,150,200,300):
        values=[min(100,int((100+3*(n*n+25*n)/125)*100/difficulty+0.5)) for n in (10,30,50)]
        table+=f'| {difficulty} | '+ ' | '.join(f'{v}%' for v in values)+' |\n'
    s=s[:start]+table+'''\nAt difficulty 120: attribute 0 -> 83%, 3 -> 85%, 10 -> 90%, 15 -> 95%,
19 -> 100% after rounding. Difficulty <=100 succeeds automatically even at
attribute 0 because Type 2 includes its 100% base. Difficulty and RNG rules
are unchanged; the probabilities follow the newly approved curve.'''+s[end:]
    s=s.replace('Type 4 is not linear. Fractional levels','New Type 2 is not linear. Fractional levels')
    p.write_text(s,encoding='utf-8')

    sections={
        'PROJECT.md':'''## 5.1.10 — SI physics and growth migration (#154)

Three shared growth families replace the old curves, with per-consumer operations
preserved. Mechanical units stay 32 MU/m and 35 tics/s; ordinary gravity is 9.81
m/s2. Unpenalized player walk/run is 4/8 m/s at Agility 0 and 16/32 at 100.
Jump uses biological-mass/Agility energy and total moved mass. Muscular efficiency
is 25–99%, reaching 50% at Agility/Dexterity 100. Physical projectiles fall and NPC
shots compensate drop once at launch; elemental flight stays authored.

One-time migration preserves resource percentages, attributes, inventory and
accrued thermal state. Map geometry is unchanged. Detailed rules: SYSTEMS;
reproducible native/static evidence: assets/validation_5110. Author acceptance
is pending in pending_test.txt. Commit/push and linked PR are requested; closure
and merge are not authorized for this issue yet.''',
        'TASKS.md':'''## Issue #154 — SI physics and growth (5.1.10)

Implemented: shared Type 1/2/3 consumers, SI gravity, calibrated movement,
energy-based jumps, fall-threshold conversion, physical projectile gravity and
launch-time ballistic aiming, attribute-dependent muscular efficiency, explicit
save migration. Existing acceleration, combat equations and fixed work data remain.

Native evidence covers numeric consumers, actual input/movement/jumps, real
projectile collisions, falls/traps, map traversal and protected-save migration.
Static/final-build results and limitations are recorded in validation_5110.
Outstanding author checks: CA154-01 and CA154-02 in pending_test.txt.
No mass-siege benchmark or unapproved force/power acceleration redesign is included.''',
        'CONTEXT.md':'''**5.1.10/#154 implemented, author acceptance pending:** new growth families,
Earth gravity, 4/8 m/s base movement, energy jumps and 25–99% muscular efficiency.
Physical projectiles fall; NPC ballistic aim is solved at launch. Save migration
preserves percentages once; equipment recalculation still grants no free healing.
Rules: SYSTEMS. Evidence: validation_5110. Pending: CA154-01/02.
Branch issue-154-si-growth; commit/push and PR delivery, no merge authorization.''',
        'MAP01.txt':'''## 5.1.10 — Physics and traversal integration (#154)

Geometry, stairs, pool, doors and narrative routes are unchanged. Earth gravity,
new attribute curves, energy-based jumps and muscular efficiency apply to MAP01
and the sewer hub. Native forward input traversed both mansion stair flights to
Z=264 (8.25 m), with measured work/heat matching the route and no damage. The
protected author Prueba save loaded with its 37 inventory actors and weapon ID
preserved. Further route and save evidence: assets/validation_5110. These checks
do not replace author acceptance or assert that every possible jump shortcut was tested.''',
        'ASSETS.md':'''## 5.1.10 — Physics validation assets (#154)

No artwork, sprite, model, sound, geometry or attribution change is required.
Existing physical projectile models now follow gravitational flight; elemental
art retains its authored behavior. assets/validation_5110 contains deterministic
isolated fixture sources, native logs/configs, result summaries and package/source
hashes. Runtime fixtures, saves, development IWAD and engine stay out of src and
out of delivery. The author's unrelated deleted art source is excluded from this patch.''',
        'HISTORY.md':'''## 5.1.10 — SI physics, growth curves and migration (#154, 2026-10-09)

Author-approved contract: B=(N*N+25*N)/125 percentage points; families B/3B/7B,
mapping old Types 1/2/3/4 to new 3/1/1/2 while retaining each operation. 32 MU/m
and 35 tics/s remain; ordinary gravity becomes 9.81 m/s2. Walk/run is 4/8 m/s
at Agility 0. Jump useful energy is 800*(biologicalMass/80)^0.75*M3(Agility),
and total moved mass determines velocity. Fall thresholds follow the approved
gravity ratio. Physical projectile gravity and bounded launch-time ballistic aim
preserve muzzle speed, dispersion, collision and elemental exceptions.

Efficiency averages Agility/Dexterity before Type 1, starts at 25%, reaches 50%
at 100/100 and caps at 99%. Existing fixed action/distance work remains; jump's
former fixed 0.5 m budget is superseded by actual accepted takeoff energy. No new
Air/Hunger debit, no heat tail and no acceleration redesign are inferred.

Author decision 2026-10-09: one-time migration preserves Health, Anima, Air and
Adrenaline percentages; ordinary equipment recalculation keeps its previous
no-free-heal rule. Explicit player/NPC/gate/traveler and map/projectile revisions
preserve ownership and accrued state. Original saves/packages remain the rollback
pair. Static/native results and rejected fixture attempts: validation_5110.
CA154-01/02 remain unconfirmed. Commit/push and a linked PR are authorized;
author acceptance, issue closure and merge have not been claimed.'''
    }
    for name,text in sections.items():add_section(ROOT/'docs'/name,text)
    p=ROOT/'README.md';s=p.read_text(encoding='utf-8');anchor='**5.1.9 / [#152]'
    if '**5.1.10 / [#154]' not in s:
        at=s.index(anchor)
        s=s[:at]+'''**5.1.10 / [#154](https://github.com/damiancurti/Caelum-Argenteum/issues/154):**
Shared attribute curves, Earth gravity, calibrated walking/running, energy-based
jumps and muscular efficiency now use the approved SI contract. Physical
projectiles fall; NPC shots compensate drop at launch. Older saves migrate resource
percentages once, preserving attributes and ownership. Keep an original save and
its matching package for rollback; save the upgraded game under a new name.
Rules: [SYSTEMS](docs/SYSTEMS.md). Evidence: [validation_5110](assets/validation_5110/RESULTS.md).
Native checks passed; author checks CA154-01/02 remain in [pending_test.txt](pending_test.txt).
This delivery is for review; #154 has not been merged or closed.

'''+s[at:]
    s=s.replace('[pending_test.txt](pending_test.txt) is empty; acceptance is recorded in HISTORY.',
                'The #152 author queue was cleared; acceptance is recorded in HISTORY.')
    p.write_text(s,encoding='utf-8')


if __name__=='__main__':main()
