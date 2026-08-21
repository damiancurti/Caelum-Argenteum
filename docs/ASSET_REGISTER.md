# Asset register

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

