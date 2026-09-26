# Caelum Argenteum — Current systems and rules

Documentation version: **4.36.14a** — 2026-09-26.

## 4.36.14a — Distinct siege materials and visual states (#18 correction)

Gate material and gate state are independent: wood, reinforced wood and
iron-clad armor each have intact, damaged and open previews. MODELDEF no longer
overlays the closed model on the open pose. Preview actors remain nonblocking
in every state; usable/damageable campaign doors remain #19. The issue already
specifies hardness 0.3/0.5/0.7; this art correction does not assign those values,
infer health or invent mass, damage, reload timing or resistance multipliers.

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

    P = max(0, S·E − T)
    W = suma_i [ wi · Vi · (1−Ai) ]
    Daño = floor(Hmax · P · W / 100 + 0,5)

S is the surface multiplier (rock: 1); T is effective Hardness in percentage points;
Hmax is maximum health, not remaining health. wi weights anatomical overlap; Vi is
vulnerability after reinforcement and Ai is the defense of the corresponding piece,
between 0 and 1. Vi can be 2, 1,6, 1,3, 1, 0,8, 0,6 or 0,4. The vertical impact of the
rock has contact in relative height 1,0. The final damage uses CaelumImpact and avoids a
second armor application.

Calculated example, not an in-game test: ms=38170 kg, mt=75 kg, Hmax=1780, T=13, S=1,
W=1, without damping. The receiver is initially stationary.

| Closing speed (MU/tic) | Received Δv | E (%) | Rounded damage |
| --- | --- | --- | --- |
| 8 | 7.984 | 8.06 | 0 |
| 16 | 15.969 | 32.47 | 347 |
| 24 | 23.953 | 73.16 | 1071 |
| 32 | 31.937 | 130.13 | 2085 |

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
Constitution, sleep per Resilience, ten pulses per serving, real digestion /4, natural
regeneration of Health/Air with its costs, critical reserve damage, Anima, Adrenaline
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
along with thermal exposure and skills not yet implemented. The safe advance was
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
status continue in V4.35; thermal exposure of the character preserves V5.1.

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

## Survival consumption and regeneration — current in 4.33.0ai

Constitution controls the passive consumption of Hunger and Thirst and their expense by
regenerating health/Air. Resilience controls the loss of Sleep: the author corrected the
attribution to Patience of 0ah. The division by Type 4 is retained.

    A = máximo(0, atributo efectivo)
    divisor D(A) = 1 + 2 * A * (A + 1) / 10100
    factor de Hambre/Sed = (masa corporal / 100 kg) / D(Constitución)
    factor de Sueño = 1 / D(Resiliencia)
    factor de coste de Hambre/Sed al regenerar = 1 / D(Constitución)

| Attribute | Divisor | Consumption with respect to 0 attribute, same mass |
| --- | ---: | ---: |
| 0 | 1 | 100% |
| 50 | 1,5049505 | 66,4474% |
| 100 | 3 | 33,3333% |

Type 4 is not linear. Fractional levels and growth above 100 are preserved without zero
consumption. The formula uses effective attributes, with its current bonuses; the weight
of the equipment is not body mass.

Base times to empty a full reserve, without other consumption: Hunger 24 hours of play,
Thirst 12, Sleep 16; one hour of play is 180 real seconds. At 100 kg and attribute 0,
these equal 72/36/48 real minutes. At attribute 100, they become 216/108/144 minutes.
Other masses only modify Hunger/Thirst.

Regeneration cost is calculated from the fraction of maximum health/Air actually
recovered. Constitution now also divides that cost; the body mass factor of passive
consumption is not applied again.

| Natural recovery | Base cost of Hunger | Thirst base cost | With Constitution 100 |
| --- | ---: | ---: | --- |
| Maximum health 1% | 1 point | 0,5 points | 0,3333 / 0,1667 points |
| Maximum Air 1% | 0,1 points | 0,2 points | 0,0333 / 0,0667 points |

Each cost is divided by D(Constitución), also when calculating how much can be recovered
with the available reserves. Only the recovered amount is charged, with non-negative
reserves. Speeds and regeneration requirements do not change. Resilience continues to
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

## Audit of the twelve attributes — current code 4.33.0ai

Comparison with the table provided by the author. The calculations and their consumers
in play were reviewed: a calculated field or an isolated timer does not amount to a
finished mechanic. The four families and their three members agree. The following
differences separate implementation from intent; they do not themselves authorize new
combat changes in this patch.

To avoid r/l/lx2 ambiguity, explicit types of code are used:

| Scale | Native formula for attribute A | A=0 | A=100 |
| --- | --- | ---: | ---: |
| Type 1, percentage of a base | 100 + A(A+1)/2 | 100% | 5150% |
| Type 2, percentage points | A(A+1)/101 | 0 | 100 |
| Type 3, remaining harmful fraction | limitar(1 - A(A+1)/10100, 0, 1) | 1 | 0 |
| Type 4, percentage of a base | 100 + 2A(A+1)/101 | 100% | 300% |
| Division by Type 4 | coste base / (Tipo4(A)/100) | coste base | coste base / 3 |

Probabilities add their base when it corresponds to and is limited to the permitted
range; equipment, mass, states and vulnerability can add modifiers. "Type 4" does not
mean linear. Each "l" in the table is not automatically replaced: damage, pain,
lucidity, Dialogue skill and durations do not share a single curve today.

| Attribute / family | Implemented combat use | Implemented noncombat use | Differences from the table |
| --- | --- | --- | --- |
| Strength / Physical | Melee damage and physical thrust Type 1, with body mass. | Load Type 4; object thrust and launch power use Strength. | It matches the main thing. "Physical power" is not another independent universal effect: it is expressed in the routes of damage, thrust and launch. |
| Hardness / Physical | Ordinary physical/magic damage after armor divided by Type 4. Pain and loss of Lucidity use Type 3. | The kinematic impacts retain their subtraction of percentage damage points per Hardness. | Scales must be updated and the scope of “environmental damage” must be narrowed: it is not universal resistance to drowning, drainage for needs or any damage outside the classified system. |
| Constitution / Physical | Maximum health Type 1, with body mass. | Passive Hunger/Thirst and natural health regeneration costs/Air divided by Type 4. | It is not connected to shortening debuffs or incoming poisons. There is no disease system implemented that applies that duration. |
| Dexterity / Technical | Attack speed Type 4, physical precision Type 1 and physical critical chance Type 2. It also reduces the ranged-weapon reload time by Type 4. | Type 1 reduces the working time of materials in manufacture. | The ammunition reload belongs here; it is appropriate to distinguish it from the cooldown of skills when updating the table. Crafting covers a specific manual use, not a general system of accuracy rolls. |
| Resilience / Technical | Maximum Adrenaline, Health Regeneration Factor and Air Capacity Type 4. | Sleep loss divided by Type 4, restored to 0ai. | Matches in association. Explain the Sleep divider; health regeneration is calculated over its maximum. |
| Agility / Technical | Type 4 movement using shared ground/swimming/flight factors; Type 2 evasion; jump uses another curve. | Type 2 stealth applied to concealment/noise, with crouching rules. | The jump does not use Type 4: JumpZ scales with the square root of Type 1, so that the ideal ballistic height scales with Type 1 at equal gravity, before load/state modifiers. |
| Charisma / Social | Its Type 4 modifies the duration/power of elemental payloads received by the player; not all effects/actors consume it. | Type 4 Persuasion on MAP01 social rolls. | The area does not use Charisma: current blast radii and Channel use the range of Eloquence. Channel also has fixed power/duration states. The set of debuffs is partial. |
| Empathy / Social | BuffPowerPercent Type 4 is available and an illumination timer is prepared; there is no general system of buffs/healing that applies all the duration/power/area indicated. | Emotion Type 4 in the MAP01 dialogs. | Emotion works. The stored factor and timer are not enough to mark buffs, cures or playable lighting as complete. Support areas based on Empathy remain pending. |
| Eloquence / Social | Launch speed and range Type 4; this range also scales current radii. Anima cost divided by Type 4. | Dialogue skill Type 2, used by Ronnie; also intervenes in social discount of Palomo. | The ammunition reload uses Dexterity; the Channel Seal Cooldown is fixed to 60 s and does not use Eloquence. The table should specify which recharge is intended to reduce and add the cost of Anima already implemented. |
| Intelligence / Mental | Magical Damage and Push Type 1. | Box capacity = 2 + entero(Tipo1(Inteligencia)/50). | Academic tasks pending. Add the Box; "magic power" does not appear as the third separate universal effect of damage/push. |
| Patience / Mental | Maximum Anima Type 1; regeneration = maximum/base time multiplied by Type 4; interrupt resistance Type 2. It mitigates effects of being injured by Type 3. | Type 3 mitigates low/critical sleep aggravation of Lucidity loss and stunning duration. | It does not mitigate general performance penalties by Hunger/Thirst/Sleep: that combination uses Adrenaline. The intended function is only partial. It does not control Sleep loss. |
| Insight / Mental | Magical precision Type 1 and magical critical chance Type 2. | There is no player detection of hidden objects/sounds or dark attenuation linked to this attribute. | Magical senses and hidden detection are still pending. The debugging perception observer does not implement the senses of the player. |

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
  uses the Dexterity Type 1.
- [Diagnosis of perception](../src/caelum/debug/CaelumPhysicsDiagnostics.zs): experimental
  observer, different from the senses of the player.

Author's later decision, after approving 0ai: maintain attributes as they are. Further
audit is postponed and does not block V4.34.

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

## Tarot: collection and capture of El Loco (4.33.0t)

Rule in force since 0aa: each Minor exclusively contributes a base passive, in addition
to its +1% per collection. Major: +2% per card. The 22 Major and 56 Minor add up +100%
collection, in an additive way, before Type 1/2/4. Do not round the level or alter
creation points. Combat awards no XP. Active powers and Trucazos are still pending.
4.36.0i obtains El Loco and Ace (1) of Cups. The other 76 cards require their
missions/rewards.

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

Each full suit gives +3 to its three attributes. Order: creation + minor passive +
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
Inventory. 0t adds the capture of El Loco and the attribute bonus described above;
return between worlds and powers remain pending.

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

## Caella test (4.33.0i–0m)

It is enabled when closing Argento in phase 35. Fire/AltFire use its actual releases;
User2 retains Seal Channel with Adrenaline expense. The old MAP01 Reload/Channel display
is replaced by User2. The Anima is spent when completing a release and its recovery is
observed in the actual reserve.

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

Choosing bow or longbow shows the recipe 129 and its dependencies. It also applies to
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
Charisma. Both use Type 4 and 120 difficulty, according to the decision for 0f.
Residents have no assigned faction: reputation modifier is neutral.

```text
capacidad Tipo 4 = 100 + 2 × atributo × (atributo + 1) / 101
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
| 120 | 85% | 99% | 100% |
| 150 | 68% | 79% | 100% |
| 200 | 51% | 59% | 75% |
| 300 | 34% | 39% | 50% |

120: 0 attribute → 83%; 3 → 84%; 10 → 85%; 15 → 87%; 30 → 99%; 31 → 100%. The 31 already
reaches 100% by rounding; does not require the unrounded capacity to reach exactly 120.
A difficulty<=100 succeeds automatically even with a zero attribute due to the Type 4
floor. These data explain the existing balance; 0h does not change the formula or the
difficulties.

Ronnie does not roll dice. His direct option requires **Dialogue skill >= 1**, with:

```text
Labia Tipo 2 = Elocuencia × (Elocuencia + 1) / 101
```

Eloquence 9 gives approximately 0,891 and does not reach; Eloquence 10 gives 1,089 and
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
| User3 | Tarot interface active; full content pending. |
| User4 | Class ability interface; pending content. |
| Use | Native interaction with NPC, stations, doors, lift and El Loco appearance. |
| Tab | Journal/Inventory; Tarot displays the collection from 0t. |

Charging has a 2 s base duration adjusted by speed; the prepared window lasts 3 s. The
next attack doubles damage and cost, and explosions double area (radius × sqrt(2)).
Incompatible pain and changes interrupt charging. The sword uses slashing Fire and
piercing AltFire, so it serves for trees and veins of the tutorial. The special hatchet
removed in 0d is not needed.

## Damage and Anima cost: Type 4 divisor (4.33.0aa)

F(A) = 1 + 2 × A × (A + 1) / 10100. General damage received = post-vulnerability damage
and armor / F(Dureza). Magical cost = base cost ×tier modifier × charge / F(Elocuencia).
T2 retains ×1,6 and T3 ×2,5; a prepared charge preserves ×2. The bell and statuette
maintain its bases. Player and NPC use the same curve, also for explosions; the entire
rounding of Engine Health is preserved.

| Attribute | Divisor | Remaining percentage |
| --- | --- | --- |
| 0 | 1 | 100% |
| 25 | 1,128713 | 88,5965% |
| 50 | 1,504950 | 66,4474% |
| 100 | 3 | 33,3333% |

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
| Standard Bow | Fires its native arrow from the magazine. | Toggles Aim/ADS. | Reloads the bow magazine; duration uses the ranged reload-speed bonus. | Toggles the same Aim/ADS mode, real FOV and doubled physical accuracy. |
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
