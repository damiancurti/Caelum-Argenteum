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
- Derived health, Anima, air, carry-capacity, mass-tier, and size-tier values.
- Real per-piece armor and shield weight plus separate debug-added weight.
- Survival as the current name for the former Resilience attribute.
- Eloquence casting speed, Anima-cost reduction, ability range, and dialogue
  values, with the live staff consuming the adjusted cost and duration.
- Seven-grade localized vulnerability and four-slot armor test controls.
- A live dizzy-lucidity accuracy penalty, provisional sword dispersion, and
  code-drawn visual distortion for testing without external art.
- A live 25%-accuracy running penalty on the provisional sword, while walking
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
