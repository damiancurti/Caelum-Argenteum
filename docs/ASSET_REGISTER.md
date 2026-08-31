# Asset register

## V4.29.0aq Palomo, Mandinga and Zupay character package

The author supplied a 398-file package containing 380 individual runtime
frames, ten review atlases and eight README/manifest documents. Only the 380
individual frames enter `src`; the atlases remain outside the PK3 and the
instructions remain under `docs/assets/characters`. The archive itself does
not state authorship or a redistribution license, so public redistribution is
blocked until Damian Curti confirms that it is project-owned original art or
records another compatible license.

| Asset family | Files | Author/direction | Source | License | Final use allowed? | Notes |
|---|---|---|---|---|---|---|
| Palomo | `sprites/caelum/actors/palomo/*.png` (224) | Pending confirmation | Author-supplied `Caelum_Argenteum_Ultimos_3_Personajes_v1` package, 2026-08-31 | Pending | Pending confirmation | 32 base frames plus 192 emotion frames; 256×256 RGBA. |
| Mandinga de la Salamanca | `sprites/caelum/actors/mandinga/*.png` (54) | Pending confirmation | Same package | Pending | Pending confirmation | 48 directional frames plus six shared death frames; 256×256 RGBA. |
| Zupay Colossus | `sprites/caelum/actors/zupay_colossus/*.png` (102) | Pending confirmation | Same package | Pending | Pending confirmation | 96 directional frames plus six shared death frames; 416×416 RGBA. No independent rock projectile is supplied. |

Runtime aliases, offsets, localization and ZScript definitions are original
project code; they do not alter the supplied pixels or establish rights over
the source artwork.

## V4.29.0am–0ap separated mansion grass and selected audio

The author supplied the three standalone 128×128 grass variants previously
represented as horizontal bands inside `CMGR01.png`. They enter the project as
new project-owned files; the historical masters remain untouched. MAP01 uses
the cared dark-green `CMGR01A` variant for the mansion grounds. `CMGR01B` and
`CMGR01C` remain available for separately bounded worn and dry terrain sectors.

The same patch integrates eight external sound effects through stable SNDINFO
logical names. Seven came from the author-supplied selected-audio package; the
requested pickup effect is the public OGG preview of Freesound #332629. Full
provenance, required attribution text and the pre-release original-download
requirement ship inside [`src/licenses/AUDIO_CREDITS.md`](../src/licenses/AUDIO_CREDITS.md).
V4.29.0an applies the final menu roles: daddo22's Metal Tssht is the
movement asset `ca_menu_move.ogg`; dodrio's clack is the acceptance asset
`ca_menu_select.ogg`. The source works and licenses are unchanged. V4.29.0ao
and 0ap change only MAP01 geometry/documentation and add no audiovisual asset.

| Asset family | Files | Author/direction | Source | License | Final use allowed? | Notes |
|---|---|---|---|---|---|---|
| Separated mansion grass | `CMGR01A.png`, `CMGR01B.png`, `CMGR01C.png` | Damian Curti / project-directed separation | Author-supplied grass package, 2026-08-30 | `LicenseRef-Caelum-Argenteum-Project` | Yes, within project | Three independent seamless 128×128 RGB flats; no runtime use of the three-band `CMGR01` composite. |
| Menu, doors and carbine | Five OGG files under `sounds/caelum` | dodrio, daddo22, CoolKT11 and Wenpire | Freesound #554021, #442313, #553427, #574810 and #574818 | CC0 1.0 | Yes | Metadata retained despite optional attribution. Spatial previews should be replaced by original downloads before final release. |
| Critical-health heartbeat | `ca_low_health_heartbeat.ogg` | ibm5155 | Freesound #174917 | CC BY 4.0 | Yes, with attribution | Public OGG preview, unaltered except project filename. |
| Recipe learned | `ca_recipe_learned.ogg` | Frostnox | Freesound #849821 | CC BY 4.0 | Yes, with attribution | Public OGG preview, unaltered except project filename. |
| Item pickup | `ca_item_pickup.ogg` | TreasureSounds | Freesound #332629 | CC BY 4.0 | Yes, with attribution | Public low-quality OGG preview, unaltered except project filename. |

## V4.29.0aj exterior grass activation

No new artwork is introduced. The already registered project-owned
`CMGR01.png` 128×128 mansion-terrain master is now declared as the native
`CMGR01` flat and assigned to MAP01's exterior world sector. Interior mansion
floors retain their established materials; MAP02 remains all sewer surfaces.

## V4.29.0aa raw-material processing set

The author supplied `Caelum_Argenteum_materiales_nuevos(1).zip` with explicit
runtime names and use instructions. Seventeen 128×128 RGBA masters are
integrated directly; no generated substitute or third-party asset is added.

| Asset family | Files | Author/direction | Source | License | Final use allowed? | Notes |
|---|---|---|---|---|---|---|
| Raw metals | `ca_material_raw_copper.png`, `raw_tin`, `raw_iron`, `raw_silver`, `raw_gold` | Damian Curti / project-directed generation | Author-supplied materials pack, 2026-08-29 | `LicenseRef-Caelum-Argenteum-Project` | Yes, within project | Inputs for the five 50%-yield ore recipes. |
| Refined metals | `ca_material_bronze_ingot.png`, `steel_ingot`, `silver_ingot`, `gold_ingot` | Same | Same pack | `LicenseRef-Caelum-Argenteum-Project` | Yes, within project | Copper, tin and iron ingot masters already existed and are not duplicated. |
| Fibers and rope | `ca_material_wool.png`, `cotton`, `raw_silk`, `plant_fiber`, `rope` | Same | Same pack | `LicenseRef-Caelum-Argenteum-Project` | Yes, within project | Inputs/outputs for Sewing Machine processing. |
| Hides | `ca_material_cow_hide.png`, `predator_hide`, `monster_hide` | Same | Same pack | `LicenseRef-Caelum-Argenteum-Project` | Yes, within project | Produce leather grades 1, 2 and 3 respectively. |

All files retain their supplied 128×128 canvas and transparent margin. Runtime
aliases `M062A0`–`M078A0` use alpha-derived floor offsets; the inventory keeps
the full-resolution masters.

## V4.29.0s canonical pickups and Domingo runtime appearance

V4.29.0s does not create alternate item art. It makes the already registered
128×128 icon masters the source for both interface presentation and world
pickup aliases, then excludes the superseded 64×64 source copies from runtime
packaging. The files remain in the working tree as historical source until a
separate authorized cleanup; they are not shipped or loaded by the PK3.

The same author-supplied recomposition pack includes Domingo. Thirty-nine core
frames are accepted as the player's world appearance. The eighteen files in
`Extras`—banner, blood, face references, weapon cutouts and slash effects—are
not actor-state frames and remain excluded.

| Asset family | Files | Author/direction | Source | License | Final use allowed? | Notes |
|---|---|---|---|---|---|---|
| Domingo playable set | `sprites/caelum/domingo/DOMI*.png` (39) | Damian Curti / project-directed generation and recomposition | Author-supplied recomposed graphics pack, 2026-08-27 | `LicenseRef-Caelum-Argenteum-Project` | Yes, within project | 16 directional standing/movement frames, 15 attack frames and 8 death frames; 256×256, baseline 244. |
| Canonical pickup aliases | 123 `TEXTURES` aliases backed by registered `graphics/caelum/icons` masters | Same registered art | Same pack | `LicenseRef-Caelum-Argenteum-Project` | Yes, within project | No duplicate pixels are introduced; only runtime names, alpha baselines and world scale are defined. |

## V4.29.0r recomposed runtime graphics

The author supplied `Caelum_Argenteum_graphics_recompuesto - 3.zip` together
with the project sizing guide. The bundle report's 255-file delta is measured
against an earlier art bundle, not against the game source. Independent runtime
comparison accepts 353 replacements: all 137 inventory/crafting icons and 216
actor frames. The unchanged preservation copy, preview sheets, manifests,
unused sewer/Domingo art and the package's Doom-compatible `STF*` copies are
not imported by this patch. Pre-existing compatibility lumps are unaffected.

| Asset family | Files | Author/direction | Source | License | Final use allowed? | Notes |
|---|---|---|---|---|---|---|
| Recomposition of item icons | 137 PNGs under `graphics/caelum/icons` | Damian Curti / project-directed generation and recomposition | Author-supplied recomposed graphics pack, 2026-08-27 | `LicenseRef-Caelum-Argenteum-Project` | Yes, within project | 128×128 RGBA, real transparency, visible content kept at least eight pixels from every edge. |
| Rulo animation set | `sprites/caelum/rulo/RULOA1.png`–`RULOL0.png` (54) | Damian Curti / project-directed generation and recomposition | Same pack | `LicenseRef-Caelum-Argenteum-Project` | Yes, within project | 48 directional frames plus six common death stages; 256×256, baseline 244. |
| Ronnie animation set | `sprites/caelum/ronnie/RONIA1.png`–`RONIL0.png` (54) | Damian Curti / project-directed generation and recomposition | Same pack | `LicenseRef-Caelum-Argenteum-Project` | Yes, within project | Source prefix `RONN` is mapped to the established runtime prefix `RONI`. |
| Argento animation set | `sprites/caelum/argento/ARGOA1.png`–`ARGOL0.png` (54) | Damian Curti / project-directed generation and recomposition | Same pack | `LicenseRef-Caelum-Argenteum-Project` | Yes, within project | Source prefix `ARGE` is mapped to the established runtime prefix `ARGO`. |
| Caella animation set | `sprites/caelum/caella/CAELA1.png`–`CAELL0.png` (54) | Damian Curti / project-directed generation and recomposition | Same pack | `LicenseRef-Caelum-Argenteum-Project` | Yes, within project | 48 directional frames plus six common death stages; 256×256, baseline 244. |

Validation confirms 256×256 RGBA canvases, complete alpha margins and 54
correctly named frames per character. Of the 216 frames, 215 end on the common
ground line at Y=244. Source `RONNA8` ends at Y=235; runtime `RONIA8` preserves
the original PNG and compensates only its origin with `Offset 128, 235`.
Runtime offsets and actor scales are explicit in code. See
[`GRAPHICS_SIZE_GUIDE.md`](GRAPHICS_SIZE_GUIDE.md).

## V4.29.0i HUD/UI-01 runtime kit

The author supplied `caelum_argenteum_hud_ui_01` as the first permanent visual
system for the HUD and Journal. The project integrates the 94 individual PNG
exports, not the mockup composites or layered masters. The pack records Damian
Curti's art direction, project-directed OpenAI Codex/ImageGen assistance and a
creation date of 2026-08-26. It declares no Doom, GZDoom or third-party art.
Rights remain reserved under `LicenseRef-Caelum-Argenteum-Project` until the
project selects its public license.

| Asset family | Files | Author/direction | Source | License | Final use allowed? | Notes |
|---|---|---|---|---|---|---|
| HUD modular components | `graphics/caelum/ui/hud/components/*.png` (17) | Damian Curti / project-directed generation | Author-supplied HUD/UI-01 pack | `LicenseRef-Caelum-Argenteum-Project` | Yes, within project | Three-piece bars, 9-slice panels, frames, selector and tintable vignette. |
| HUD resource/combat/status icons | `graphics/caelum/ui/hud/icons/*.png` (27) | Damian Curti / project-directed generation | Author-supplied HUD/UI-01 pack | `LicenseRef-Caelum-Argenteum-Project` | Yes, within project | Nine resources, five combat cues, five reticles and eight conditions. |
| Journal controls | `graphics/caelum/ui/journal/components/*.png` (14) | Damian Curti / project-directed generation | Author-supplied HUD/UI-01 pack | `LicenseRef-Caelum-Argenteum-Project` | Yes, within project | Buttons, arrows, scroll controls, cursor and state marks. |
| Journal navigation/action icons | `graphics/caelum/ui/journal/icons/*.png` (36) | Damian Curti / project-directed generation | Author-supplied HUD/UI-01 pack | `LicenseRef-Caelum-Argenteum-Project` | Yes, within project | Navigation, categories, equipment slots and actions. |


## 4.28.0af compatibility note

V4.28.0af changes ZScript invocation and documentation only. It introduces no artwork or external release dependency beyond the assets registered for V4.28.0ae.

## 4.28.0ae elemental effects and Giant Rat

The author-supplied elemental-effects atlas is divided into 60 original in-game sprites: twelve frames each for vertical lightning, horizontal lightning, burn, poison and freeze. The effects are presentation layers attached to the authoritative gameplay status; they do not add an independent damage tick.

The author-supplied Giant Rat sheet contributes 48 original eight-direction quadruped frames covering idle, walk, run, bite, Pain and Death. These files remain project-source assets supplied by the author. Final public release still requires the normal asset/licensing audit.

## V4.27.0g weathered cobblestone and Windows-safe resource layout

`CMWV01` is a deterministic crop of the large cobblestone sample in the author-supplied atlas section **Variantes de tiempo / daño**. It is normalized to 128×128 and assigned to the four MAP01 perimeter walls. All 82 mansion resources now reside in `graphics/caelum/textures/mansion`, avoiding the Windows filename collision between the root `TEXTURES` lump and the former `textures` directory.

## V4.27.0f mansion texture atlas

The source atlas was supplied by Damian Curti as an original Caelum Argenteum project asset. This patch performs deterministic crop and normalization only; no third-party artwork is introduced.

| Asset family | Files | Author | Source | License | Final use allowed? | Notes |
|---|---|---|---|---|---|---|
| Mansion exterior walls | `CMEX01`–`CMEX06` | Damian Curti / project-directed generation | Author-supplied mansion atlas | Project-owned original | Yes | Plaster, brick, stone and vegetation variants. |
| Mansion interior walls | `CMIN01`–`CMIN05` | Damian Curti / project-directed generation | Author-supplied mansion atlas | Project-owned original | Yes | Wainscot and wallpaper variants. |
| Foundations, damaged and basement walls | `CMFD01`–`CMFD04`, `CMDM01`–`CMDM07`, `CMBS01`–`CMBS05` | Damian Curti / project-directed generation | Author-supplied mansion atlas | Project-owned original | Yes | Structural, wet and damaged variants. |
| Ceilings and door leaves | `CMCL01`–`CMCL06`, `CMDR01`–`CMDR05` | Damian Curti / project-directed generation | Author-supplied mansion atlas | Project-owned original | Yes | Door leaves remain separate from map-built frames. |
| Stone and wood floors | `CMST01`–`CMST08`, `CMWD01`–`CMWD08` | Damian Curti / project-directed generation | Author-supplied mansion atlas | Project-owned original | Yes | Normalized 128×128 map textures. |
| Carpets, roofs and terrain | `CMCR01`–`CMCR06`, `CMRF01`–`CMRF04`, `CMGR01`–`CMGR04` | Damian Curti / project-directed generation | Author-supplied mansion atlas | Project-owned original | Yes | Carpet, tile/slate roof and terrain families. |
| Modular pool | `CMPC01`, `CMPW01`, `CMPF01`–`CMPF02`, `CMWA01`–`CMWA03` | Damian Curti / project-directed generation | Author-supplied mansion atlas | Project-owned original | Yes | Separate coping, repeating wall, submerged floor and water flats. |
| Mansion trim | `CMTR01`–`CMTR06` | Damian Curti / project-directed generation | Author-supplied mansion atlas | Project-owned original | Yes | Horizontal 128×32 molding bands. |

## V4.27.0b asset note

V4.27.0b restores the earlier V4.26.5r MAP01 binary and updates public documentation only. It introduces no new artwork or external release dependency.

## V4.27.0a asset note

V4.27.0a changes native input routing, localized control labels and MAP01 sector geometry only. It reuses existing Doom development-placeholder textures and introduces no new external artwork or release dependency.

## V4.26.5w asset note

V4.26.5w restores internal MAP01 room divisions, adds four trap-door connections and seals the entrance frame. It reuses existing Doom development-placeholder textures and introduces no new external artwork or release dependency.

## V4.26.5v asset note

V4.26.5v closes terrace/wall topology and rebuilds the entrance frame with opaque structural sectors. It reuses existing Doom development-placeholder textures and introduces no new external artwork or release dependency.

## V4.26.5n asset note

V4.26.5n rebuilds and replicates existing MAP01 room, door, roof and staircase geometry and updates public documentation. It reuses current Doom development-placeholder textures and introduces no new external artwork or release dependency.

## V4.26.5m asset note

V4.26.5m removes invalid MAP01 partition texture assignments and updates public documentation only. It introduces no new external artwork or release dependency.

## V4.26.5l asset note

V4.26.5l changes MAP01 door-sector motion, texture placement and public documentation only. It reuses existing Doom development-placeholder textures and introduces no new external artwork or release dependency.

## V4.26.5k asset note

V4.26.5k changes MAP01 door-frame sector geometry and public documentation only. It reuses existing Doom development-placeholder textures and introduces no new external artwork or release dependency.

## V4.26.5j asset note

V4.26.5j changes existing shield render placement, MAP01 sector/control geometry and documentation only. It reuses the registered shield sprites and Doom development-placeholder textures; no new external asset or release dependency is introduced.

## V4.26.5i asset note

V4.26.5i reuses the already registered `CBUCA0`, `CSHKA0`, `CSHTA0` and `CSHMA0` project shield sprites as provisional first-person Block layers. No new external artwork or license dependency is introduced.

## V4.26.5h asset note

V4.26.5h changes Zoom input handling, native Fly movement compatibility and documentation only. It introduces no new external art assets.

## V4.26.5g asset note

V4.26.5g changes MAP01 texture/special fields, ranged Reload timing code and documentation only. It introduces no new external art assets.

## V4.26.5f asset note

V4.26.5f changes MAP01 line behavior, ranged HUD/control code and documentation only. It introduces no new external art assets.

## V4.26.5e asset note

V4.26.5e changes MAP01 wall presentation, ranged-ammunition logic and documentation only. It reuses existing project textures and projectile sprites; no new external art assets are introduced.

## V4.26.5d asset note

V4.26.5d changes MAP01 geometry, environmental-impact response code and documentation only. No new external art assets are introduced.

## V4.26.5c asset note

V4.26.5c corrects MAP01 sidedef ownership and roadmap documentation only. No new external art assets are introduced.

## V4.26.5b asset note

V4.26.5b corrects MAP01 topology and adds roadmap/documentation updates only. No new external art assets are introduced.

## V4.26.5a asset note

V4.26.5a corrects MAP01 topology and updates documentation only. No new external art assets are introduced.

## V4.26.5 asset note

V4.26.5 adds only MAP01 geometry and documentation. No new external art assets are introduced.

## V4.26.4 asset note

V4.26.4 changes movement physics, stealth/noise logic, MAP01 geometry and documentation only. No new external art assets are introduced.

## V4.26.3b asset note

V4.26.3b changes physics calibration, inventory-drop behavior, MAP01 geometry and documentation only. No new external art assets are introduced.

## V4.26.3 asset note

V4.26.3 changes physics, MAP01 geometry and documentation only. No new external art assets are introduced.

## V4.26.2 asset note

V4.26.2 changes generic impact geometry, Caelum anatomy response and documentation only. No new external art assets are introduced.

## V4.26.1 asset note

V4.26.1 changes physics response, combat integration and documentation only. No new external art assets are introduced.

## V4.26.0 asset note

V4.26.0 is an architecture/physics/documentation refactor and introduces no new external art assets.

## V4.25.4 asset note

V4.25.4 changes physics/balance code and documentation only. No new external art assets are introduced.

## V4.25.3 asset note

V4.25.3 changes movement/physics code and documentation only. No new external art assets are introduced.

## V4.25.1 asset note

V4.25.1 is a physics/code/documentation patch and introduces no new external art assets.

## V4.25.0 asset note

V4.25.0 introduces no new external artwork. The ranged refactor reuses the already registered arrow, bolt, carbine-ammunition, projectile, weapon, shield, and UI assets. This entry exists so code-only balance patches remain traceable in the public asset audit.

Every external asset must be recorded here before it can enter a public build.

| Asset | File | Author | Source | License | Final use allowed? | Notes |
|---|---|---|---|---|---|---|
| Training dummy sprite | `sprites/caelum/CDMYA0.png` | OpenAI image generation, directed by Damian Curti | Original project generation | Project-owned original | Yes | Opaque humanoid test target. |
| Argento idle rotations | `sprites/caelum/argento/ARGOA1.png`–`ARGOA8.png` | OpenAI image generation, directed by Damian Curti | Based on Damian Curti's supplied character sheet | Project-owned original adaptation | Yes | Eight transparent rotations normalized to 72 units. |
| Argento melee rotations | `sprites/caelum/argento/ARGOB1.png`–`ARGOB8.png` | OpenAI image generation, directed by Damian Curti | Based on Damian Curti's supplied character sheet | Project-owned original adaptation | Yes | Eight transparent sword-attack rotations. |
| Caella idle rotations | `sprites/caelum/caella/CAELA1.png`–`CAELA8.png` | OpenAI image generation, directed by Damian Curti | Based on Damian Curti's supplied female character sheet | Project-owned original adaptation | Yes | Eight transparent rotations normalized to 72 units. |
| Caella melee rotations | `sprites/caelum/caella/CAELB1.png`–`CAELB8.png` | OpenAI image generation, directed by Damian Curti | Based on Damian Curti's supplied female character sheet | Project-owned original adaptation | Yes | Eight transparent sword-attack rotations. |
| Argento extended states | `sprites/caelum/argento/ARGOC1.png`–`ARGOF8.png` | OpenAI image generation, directed by Damian Curti | Based on Damian Curti's supplied character sheet | Project-owned original adaptation | Yes | Eight rotations each for stride, ranged cast, pain, and death. |
| Caella extended states | `sprites/caelum/caella/CAELC1.png`–`CAELF8.png` | OpenAI image generation, directed by Damian Curti | Based on Damian Curti's supplied female character sheet | Project-owned original adaptation | Yes | Eight rotations each for stride, ranged cast, pain, and death. |
| Test magic bolts | `sprites/caelum/projectiles/CAMGA0.png`, `CAMGB0.png` | OpenAI image generation, directed by Damian Curti | Original project generation matching the supplied character sheets | Project-owned original | Yes | Compact transparent blue and violet bolts. |
| Rulo complete state set | `sprites/caelum/rulo/RULOA1.png`–`RULOF8.png` | OpenAI image generation, directed by Damian Curti | Based on Damian Curti's supplied bear-warrior character sheet | Project-owned original adaptation | Yes | Forty-eight transparent sprites: eight rotations each for idle, stride, axe melee, axe throw, pain, and death. |
| Ronnie complete state set | `sprites/caelum/ronnie/RONIA1.png`–`RONIF8.png` | OpenAI image generation, directed by Damian Curti | Based on Damian Curti's supplied Caelith character sheet | Project-owned original adaptation | Yes | Forty-eight transparent sprites: eight rotations each for idle, stride, sword melee, golden cast, pain, and death. |
| Rulo/Ronnie projectiles | `sprites/caelum/projectiles/CARUA0.png`, `CAROB0.png` | OpenAI image generation, directed by Damian Curti | Extracted from the project-owned ranged state atlases | Project-owned original adaptation | Yes | Thrown axe and straight golden Caelith bolt. |

## Rules

- Never copy assets from `DOOM2.WAD` into this project.
- A download being free does not mean it is copyright-free.
- Preserve the original license file for every third-party asset pack.
- Record modifications without removing the original author's credit.
- Prefer original work, commissioned work with written rights, or CC0 assets.
## Version 0.58.0 generation notes

- `sprites/caelum/argento/ARGOC1.png` through `ARGOF8.png`: thirty-two
  transparent eight-direction frames covering stride, blue ranged cast, pain,
  and death. Generated from the user-provided Argento visual reference and
  normalized to a common 128×80 canvas with baseline 78.
- `sprites/caelum/caella/CAELC1.png` through `CAELF8.png`: thirty-two
  transparent eight-direction frames covering stride, violet ranged cast,
  pain, and death. Generated from the user-provided Caella visual reference and
  normalized to the same canvas and baseline.
- `sprites/caelum/projectiles/CAMGA0.png` and `CAMGB0.png`: compact blue and
  violet magic-bolt visuals on transparent 64×32 canvases.
- Source-generation mode: built-in image generation, followed by deterministic
  atlas extraction, alpha preservation, baseline normalization, and visual
  inspection of every resulting state/direction.

## Version 0.59.0 generation notes

- Rulo was generated as a seven-row six-state atlas plus a dedicated missing
  northwest row; the final authored set contains all eight unique directions.
- Ronnie was generated as two four-row six-state atlases to preserve all eight
  directions and consistent state order.
- Light neutral generated backgrounds were removed deterministically. Cell-edge
  debris was discarded, alpha preserved, and every final frame normalized to a
  common baseline before visual inspection.
- Source-generation mode: built-in image generation based on the two supplied
  character sheets, followed by project-local atlas extraction and validation.

## Crafting stations — V4.23.2

The following station sprites are original project assets supplied by the
author from ChatGPT-generated source images and processed for in-game use.
The title plaques were removed, baked checkerboard backgrounds were cleaned
where necessary, and the objects were normalized to transparent 128×128
sprites without redrawing the station artwork.

| Sprite | Asset |
| --- | --- |
| `CWBKA0` | Workbench |
| `CFRGA0` | Forge |
| `CANVA0` | Anvil |
| `CRNGA0` | Ranged Weapons Workshop |
| `CSAWA0` | Sawmill |
| `CARMA0` | Armor Workshop |
| `CSEWA0` | Sewing Machine |
| `CESAA0` | Essence Altar |
| `CGLBA0` | Globe |
| `CJWLA0` | Jeweler Bench |
| `CFINA0` | Fine-tools Bench |
| `CMSTA0` | Master Bench |

Source/status: author-supplied AI-generated artwork; project-local asset.
Final product policy remains independent of Doom copyrighted art.
