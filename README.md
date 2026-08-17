# Caelum Argenteum — Development Project

This is the **4.0 development prototype** for **Caelum Argenteum**.

It is a GZDoom mod project that currently uses `DOOM2.WAD` only as a legal,
local development dependency. The IWAD is never copied into this project.

## First run on Damian's computer

1. Copy this complete `CaelumArgenteum` folder to:

   `C:\GZDoomProjects\CaelumArgenteum`

2. Double-click `run_dev.bat`.
3. A blue Windows PowerShell window may appear briefly while the PK3 is built.
4. GZDoom should start with Doom II selected automatically.
5. Start a new game.

If Windows asks whether the batch file is trusted, choose to run it only after
checking its contents. It contains ordinary commands to package the `src`
folder and launch GZDoom.

## What exists in the current prototype

- A reproducible PK3 build process.
- A custom `CaelumPlayer` class derived from GZDoom's `DoomPlayer`.
- English as the default game language.
- Spanish localization support.
- A project structure ready for modular ZScript systems.
- An eight-page character creator with race, two classes/profession, sex,
  height, and validated family/individual point limits.
- New characters enter that creator automatically. Gameplay remains paused and
  protected until confirmation, with direct keyboard and gamepad navigation.
- New characters own no equipment before confirmation. After confirming race,
  classes, body, and attributes, the development loadout is spawned on the
  floor in front of the player for native pickup testing.
- Derived health, Anima, air, carry-capacity, mass-tier, and size-tier values.
- Carry capacity equal to base mass at Strength 0, scaled directly by Strength
  Type 4 up to three times base mass at Strength 100.
- Authoritative per-piece armor tier weights, shield, weapon, and personal-
  inventory weight plus separate debug-added weight and XS/S/M/L/XL scaling.
- A right-side load bar showing all carried weight, capacity, percentage, and
  green/yellow/orange/red load states.
- Native GZDoom inventory equipment persistence across saves and map travel,
  including independent armor/shield/weapon instances, durability, equipped
  state, and Magic Box state.
- Configurable equipment pickups and a compact localized interface for
  filtering, equipping, removing, breaking, dropping, and preserving each
  owned object's size, durability, and personal-inventory/Magic-Box location.
- An unlimited-slot native personal inventory limited by carried weight.
  Pickups that would exceed capacity are marked as stored in the slot-limited
  Magic Box; when it is full, the object remains in the world.
- Eight compact inventory filters, including 41 active native materials whose
  stacks are separated by type and tier, non-stackable `Key` objects backed by
  `LOCKDEFS`, and unique key items. The old iron-ingot prototype remains hidden
  solely so earlier saves can still deserialize it.
- A direct `ca_debug_test_silver_lock` command that exercises native lock 200
  without requiring a purpose-built test map.
- Five native stackable consumables with real weight and Magic Box support:
  life and Anima potions, energy drinks, food rations, and water rations. Each
  applies a one-percent-per-second regeneration Powerup for ten seconds.
- The test loadout spawns a tier-one sword, staff, carbine, profession armor,
  shield, and 100 bullets on the floor. Each bullet weighs 0.003. A complete
  ammunition stack uses one Magic Box slot and has zero weight while boxed.
- Starting armor and shield follow profession: warrior uses heavy/tower;
  mercenary, cleric, and battle mage use medium/kite; explorer, pilgrim, and
  investigator use light/buckler; priest, mage, and arcanist use magic
  armor/magic shield.
- Persistent sword, staff, and carbine equipment with independent tier, size,
  weight, durability, pickups, Magic Box ownership, and map/save continuity.
- Native Fire uses the equipped main-hand weapon; AltFire controls the equipped
  secondary-hand shield. The carbine has a live 60 m projectile and bullets.
- Multiple weapons can remain equipped simultaneously. Their family buttons
  choose only the active weapon: `3` sword, `5` carbine, and `6` staff.
- Resilience as the definitive name of the technical recovery attribute.
- Eloquence casting speed, Anima-cost reduction, ability range, and dialogue
  values, with the live staff consuming the adjusted cost and duration.
- Seven-grade localized vulnerability and four-slot armor test controls.
- True per-slot unequipped clothing labels with zero defense, weight, and
  durability, separate from the equippable magic-armor set.
- Multi-region explosions that independently resolve every anatomy volume
  touched by the blast, with both arms treated as one logical region.
- A live dizzy-lucidity accuracy penalty, sword dispersion, and
  code-drawn visual distortion for testing without external art.
- A live 25%-accuracy running penalty on the sword, while walking
  and standing retain their complete post-lucidity accuracy.
- Live x2 crouching factors for accuracy, critical chance, and future stealth.
- An original immobile one-million-health training dummy that can be spawned
  from a localized development control for repeatable combat tests.
- A four-type, three-tier shield blocking test with air cost, physical/magical
  absorption, durability loss, and successful-block adrenaline.
- Four predefined hostile character tests: Argento, Caella, Rulo the Beast
  Warrior, and Ronnie the Caelith Explorer, each with independent
  eight-direction idle, melee, stride, ranged, pain, and death art.
- Localized armor on all four actors, with per-region reinforcement,
  percentage absorption, durability wear, and live equipment bonuses.
- Shared actor lucidity: naturally critical regions cause mitigated loss,
  Mareado halves offensive accuracy, Aturdido immobilizes for two seconds,
  and the resource regenerates over one minute.
- Shared actor offense: each predefined character now uses its own effective
  Dexterity/Insight accuracy and critical chance, while health, Patience, and
  adrenaline alter real damage and movement speed.
- Real actor criticals now add localized damage only and traverse the player's
  shield, armor, Dureza, lucidity, pain, adrenaline, and durability pipeline.
- A sixth compact diagnostic page and two actor-state controls expose the full
  offensive calculation for repeatable development testing.
- Ordinary directed attacks against the player now automatically traverse
  real-angle shield coverage and the complete custom armor/health pipeline.
- Blue/violet and golden magic bolts plus Rulo's thrown axe for ranged tests.
- A playable tier-one carbine replacing the short bow, with 360 damage,
  48-tic cadence, 30°/200° spread, 20-air reload, and size-M weight 12.
- An authoritative 16-weapon physical catalogue for families 2–5, including
  primary/secondary statistics, damage types, shield behavior, recipes, and
  tier-source materials. Every active material is referenced by a recipe.
- `ca_debug_audit_crafting_catalogue` reports the recipe/material totals and
  lists any active material left without a use; the expected unused count is 0.
- A shared combat base with attribute-based evasion, pain, adrenaline,
  wounded-state rules, and ordered reusable anatomy profiles.

No Doom assets are included in the project.

## Important folders

- `src`: files that will be packed into the PK3.
- `src/caelum`: ZScript source code grouped by game system.
- `build`: generated PK3 files; safe to recreate.
- `docs`: development notes and licensing records.

## Basic development cycle

1. Edit a file inside `src`.
2. Save the file.
3. Close the currently running GZDoom instance.
4. Double-click `run_dev.bat` again.
5. Read any startup error shown by GZDoom before changing more code.
