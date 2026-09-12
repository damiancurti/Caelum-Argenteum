# Caelum Argenteum

An independent dark fantasy FPS-RPG inspired by nineteenth-century Argentina.
Author and game designer: **Damian Curti**. Development target: **GZDoom 4.14.2**
on Windows 11. The final game is intended to be independent of Doom assets.


**Current release: 4.33.0t.** Apply over the complete **4.33.0s** project.
Documentation reviewed: 2026-09-11. The author accepted every 0s check.
This patch manifests The Fool in the mansion cave and adds its explicit capture,
persistent Tarot collection and fractional attribute bonus, advancing phase 80
to 90. The roadmap and validation record are in [PROJECT.md](docs/PROJECT.md).

## Implemented

- After receiving the Magic Box, an apparition appears in the centre of the
  underground cave, in front of the back-wall veins. Use reveals the original
  Fool of the Pampas artwork; the player explicitly confirms capture.
  Leaving or losing the Box during the animation interrupts safely and allows
  a retry. The essence disappears only after the persistent reward is recorded.
- The Journal has a Tarot page with the card, collection count and bonus.
  Each Major adds 2%, each Minor 1%, additively, to all twelve primary attribute
  levels before derived formulas. Fractions are retained: 15 becomes 15.30.
  Recalculation starts from creation/equipment; loading cannot compound bonuses.
- Quest Detail tracks finding, revealing and capturing the essence. Palomo and
  the four residents react to the capture. The quest stays active at phase 90;
  the narrative exit and return to the body remain the next implementation.

- Palomo's original actor speaks on the second floor after all four trials.
  His final dialogue keeps the author's mysterious tone, optional questions,
  and explicit acceptance of the Magic Box. Leaving before acceptance gives
  no reward; reopening after acceptance offers storage help and cave directions.
- The Box now has one native Inventory instance, an owner and a stable ItemId.
  Existing storage/weight rules remain authoritative: 10 kg for the Box plus
  reduced content weight. It cannot be dropped, sold or stored inside itself.
  Old owned Boxes migrate without a second weight charge or lost contents.
- Quest Detail and Argento's guidance reflect phase 80. Palomo remains upstairs,
  and its location is correctly listed already at phase 75. An early upstairs
  visit gives current-stage guidance and cannot award the Box.

- The Bull party uses the four original residents. Lethal damage leaves them
  resting at 1 Health until the attempt ends. Victory/retry restores them.
  The native combat flag that blocked Argento/Caella dialogue is cleared after
  combat, including existing saves. A surviving corpse instance from an old
  save is repaired in place; progress and loot are preserved.
- Rulo's victory, repeat dialogue and Quest Detail recognize innate strength
  and the ability to unite and lead the group.

- The obsolete processing manual outside MAP01 is retired. Ronnie continues
  to teach the selected weapon and its recipe dependencies.

- Ronnie offers all 16 physical and 20 magical T1 weapons, with explanations
  before confirmation. He teaches the chosen recipe and its component recipes.
- Twenty 2D shrubs and four ceibos surround the entrance. Each shrub represents
  an estimated 10 kg of aboveground biomass, with the same hardness as wood.
  Slashing yields fiber; the cave contains copper, tin, five gemstone veins
  and a finite leather chest.
  Ronnie lends the gathering sword and takes it back after the first craft.
- Each resident's room supports its equipment family through T2, including
  components. The indoor second-floor room contains all twelve stations;
  all twelve form one row against the back wall. Bedroom stations occupy
  corners. Use checks height and visibility; saved tasks/reservations persist.
- Argento shares the journal's current-stage guidance. All residents can
  explain the new resource and workshop locations.
- The five characters have 280 supplied pose sprites and native states.
  Domingo uses crouch idle/walk art; seated/lying states prepare future furniture
  interactions. They do not implement rest or calendar simulation yet.
- The basement chest holds only cow leather, enough for giant gauntlets at
  the character's size and 25% efficiency in every layer: **96 kg for size M**.
  Withdrawals respect carrying capacity; unused leather can be returned.
  Reopening/loading does not refill it. Gems come from the five cave veins.
- Bow and longbow choices also teach a native recipe for ten arrows and all
  its dependencies. Arrows enter personal inventory and do not replace the
  first crafted weapon. Tab closes Trades; G changes its recipe filter.
- Argento holds the silver key; the Bull is placed in the locked starting room.
  Delivery requires Caella/Ronnie completion and Rulo's combat practices.
  Rulo now offers six tracked exercises with native actions for all 36 starter
  options, including movement alternatives for unsupported actions. His target
  is in the ground-floor north room directly below his bedroom. The silver key
  requires all six checks. Entry starts the Bull fight and locks the room.
  A defeat restores Health/Air/Anima and restarts the same Bull, preserving
  progress and the first weapon. Victory opens the room and drops the finite
  leather budget once; speaking with Rulo completes phase 75.
  The 900 kg Bull yields 12.5 kg of usable leather, following the documented
  hide/processing estimate. It no longer guarantees a complete T1 armor set
  at minimum efficiency. The gauntlet chest remains; supply coverage will be
  audited before tutorial closure. T2 workshop infrastructure stays.
- Ranged trainees receive 24 borrowed rounds, replenished when exhausted in
  the arena. Unused rounds return at turn-in; pre-existing ammunition remains.
  Rulo restores the first weapon for practice. Javelin practice cannot yield
  materials from that restoration; its close-range AltFire fallback now uses
  its existing primary reach instead of zero.
- Palomo remains visible and solid during his fifteen-waypoint departure to
  the second floor, using stairs, doors and normal movement. Save/load resumes
  the route. His final conversation and unique Magic Box reward are now playable.
- The first crafted weapon goes to personal inventory without requiring the
  Magic Box. Its ItemId is preserved; extra crafted weapons and mission
  material quantities are removed on leaving MAP01. Quest Detail tracks
  requirements, missing materials, directions and returning the loan.

- Character creation, attributes, survival resources, inventory/equipment,
  crafting, repair/disassembly, physical currency and merchant infrastructure.
- Physical/ranged/magical combat, contextual Block/ADS, charged attacks and
  equipped-Seal Channel. Sword/hand/shield framing 4.32.0o remains accepted.
- MAP01 mansion, secret facade, native moving lift and resource cave.
- Prologue, Unknown Voice, Palomo and Argento's social task: recruit the three
  residents, persist results/failure alternatives, return at 3/3 to phase 35.
- Caella's magic trial: real primary/secondary casts, Seal Channel, Anima
  spending/recovery, four elemental runes, hints after mistakes and a persistent
  turn-in at phase 45. The fourth rune keeps the staff and wall intact; return
  to Caella, hand back her loan, then walk through the still-visible wall.
- Correct Spanish localization for Caella. The magic implement and one Seal
  suffice: complete practice, then press Use on Earth, Air, Fire and Water.
- Side HUD Seal icon: normal colors when available, grayscale when blocked,
  with remaining cooldown seconds below. No central Seal status message.
- Twelve simple 3D crafting stations, based on the original sprites, with
  characteristic tools and unchanged collision/crafting behavior.
- One native harp phrase on dialogue opening and every next page. War Drums
  plays once on the title screen; menu strings start with Quit confirmation
  and still accompany the map Exit.
- Quest Detail opens with F in Quests: current instructions, the five magic
  practice checks, rune directions and a description of the quest.
- The 250 old test items in the six first ground-floor rooms are retired on
  map load, including existing saves. Carried items and player drops remain.
- A single root Windows builder, source art and reusable generators in assets,
  five active documents and source patches installed by copying files.

## Planned

Next: implement the narrative exit and return to the body, with explicit
confirmation, preserving the selected starter weapon by ItemId inside the Box,
clearing temporary Limbo items, and completing the quest. The present playable
limit is phase 90: The Fool captured and post-capture conversations available.
Ronnie's additional survival lessons (food, water and a real repair)
remain a tutorial expansion, without a new gate on the accepted starter branch.
Arrow crafting is available; cartridge/bolt recipes remain planned, while
Rulo now supplies the ammunition needed by those starter weapons in his trial.
MAP02 is currently an actor test field; story sewers are still pending.

The established sequence continues through V4.34 world/travel foundations,
V4.35 calendar/weather/events, V4.36 physical hazards and V4.37 Tarot/Trucazo.
**V5.0 reorganizes programming modules**; V5.1 adds thermal exposure and later
V5 work expands persistent resources and marine biomes. Remaining weapon
art, loot, faction consequences, perception/formations, sieges, co-op/PvP,
world persistence and the complete campaign are tracked in PROJECT.md.

## Pending validation

All 0s checks were accepted by the author. The supplied PRUEBAS_4_33_0t.txt
covers cave access, reveal/decline/retry/capture, the Tarot bonus, conversations
and saves. Native engine evidence is recorded in PROJECT.md; the author's
playthrough of 0t remains pending. Card powers and narrative exit are separate
future work; the passive attribute bonus is already active.

## Build and run

Close GZDoom. Extract the 0t patch and copy its **src**, **docs** and
**README.md** into the full **4.33.0s** project, accepting replacement of matching files.
Merge folders without deleting their existing contents. Read the supplied
**PRUEBAS_4_33_0t.txt** for the required checks; keep patch instructions outside
the active documentation. Patches contain changed source files and that TXT.

Double-click **run_dev.bat** to build and play with the supplied machine's
existing engine/IWAD paths. To build independently, from any working directory:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\path\CaelumArgenteum\build_dev.ps1"
```

Only src enters build/caelum_argenteum_dev.pk3. The builder writes files-only
ZIP entries and replaces the previous build atomically after verification.
Python is not needed to build or play. Source generators in assets/generators
are optional editing utilities; their dependencies are listed in ASSETS.md.

## Documentation and project rules

**Update this README and the five canonical documents with every release.**
Keep implemented, planned and pending-validation status distinct. Integrate
new subjects into existing chapters; preserve superseded information in the
history and keep patch-specific utilities out of the active project.

| File | Purpose |
| --- | --- |
| [PROJECT.md](docs/PROJECT.md) | Principles, complete roadmap, folder audit and current validation. |
| [SYSTEMS.md](docs/SYSTEMS.md) | Controls, social odds, crafting, economy, storage and dialogue rules. |
| [MAP01.txt](docs/MAP01.txt) | Full authorial story/specification and implementation boundaries. |
| [ASSETS.md](docs/ASSETS.md) | Audio/art inventory, provenance, source generators and accepted framing. |
| [HISTORY.md](docs/HISTORY.md) | Consolidated previous records and superseded decisions. |

Use English code/identifiers and Spanish explanatory comments. Prefer native
engine features and shared authoritative systems; protect accepted gameplay
and author-owned lore/balance. Deliver changed files and report actual tests.
Keep useful source assets and required license notices. Deliver patches as
changed files to copy plus one test TXT; no patch installers. V5 source refactoring
must preserve save/input compatibility through incremental changes.

Run `python validate_project.py` before preparing a release to check version,
documentation, structure, Caella translations, station models and audio references. Development engine/IWAD files,
test observers and archives are not part of the playable PK3 or source delta.
