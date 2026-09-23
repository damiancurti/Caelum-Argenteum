# Caelum Argenteum — perspective and gauntlet revision

Historical art-package integration guide. The resources are already integrated.
The steps below preserve the original package procedure; do not repeat them on
the current checkout. The root README.md governs current setup, and
pending_test.txt tracks outstanding author checks.

This patch contains 99 PNG: 49 Tier 2 variants, 49 Tier 3 variants and the
`ca_giant_gauntlets.png` fixed base icon. It retains the names and subfolders of the
previous patch.

## Changes in this revision

The giant gauntlets show a complete pair. Each hand has four consecutive fingers in the
knuckle row and one side thumb. The little finger occupies the outer edge, next to the
ring finger, and is shorter; the thumbs point to the space between both hands. This anatomy
applies to the base icon and to T2/T3.

The ornaments on the 98 tier icons were redrawn as integrated fittings, clasps or
engravings. Their tilt, curvature, relief, occlusion and lighting follow the object
surface. Bands wrap around handles, wrists and ankles; plates on torso armor,
helmets, ranged weapons and books follow their respective planes.

| Equipment | Location of the ornament |
| --- | --- |
| Torso armor | Left breast of the carrier; right side when looking at the icon |
| Boots | One ornament per ankle |
| Gloves and gauntlets | One ornament per wrist |
| Helmets | Front plate above the face opening |
| Bladed weapons and polearms | Handle or fitting immediately beside the blade, tip or head |
| Ranged weapons | Side of the stock, body, grip or support |
| Magic objects | Secondary support that makes the focus and main detail visible |
| Shields | Heraldry integrated into the shield face |
| Amulets and Seals | Metal frame surrounding the gemstone or emblem |

T2 retains aged silver, Pampean border patterns, laurels and sky-blue/white accents. T3 adds more
silver work, selective gold and Sol de Mayo motifs. It maintains the dark and
semi-realistic aesthetics of the project.

## Historical package installation

1. Decompress the ZIP.
2. Copy `Caelum_Argenteum_tiers_2_3_argentinos_PATCH/icons/` content into
   `graphics/caelum/icons/`.
3. Keep the `jewelry/` subfolder and replace the PNGs with the same names.
4. Keep those same names and routes if you work within a PK3.

The existing code should continue to target `ca_nombre_t2.png` and `ca_nombre_t3.png`.
This package is a graphical update; it does not include changes in statistics, recipes or
classes.

## Format and use

| Property | Value and purpose |
| --- | --- |
| File | PNG RGBA, 8 bits per channel; color and real transparency |
| Canvas | 128 × 128 px per icon |
| Visible area | Up to 112 × 112 px, maintaining the original ratio |
| Margin | Approximately 8 px to protect ends and edges when scaling |
| Use | Inventory icons, equipment, trade and menus |
| Background | Transparent; working green is not part of the final PNG |

128 × 128 is the agreed delivery size for this inventory. It preserves texture
and ornaments at a moderate cost: 64 KiB per uncompressed RGBA icon, before additional
engine structures. The 112 px area maintains a uniform visual scale and leaves margin for
tips, ribbons and edges.

The size of the file alone does not determine the physical dimensions of an object in the
world or the drawing size of the HUD. The programmer must retain the presentation scale
already used by the inventory and avoid deforming the icon when drawing it. These PNGs are
not hand animations or directional sprites of characters.

## Reference files

- `MANIFEST_TIERS.csv`: names, installation paths, tiers, placement and formatting.
- `CHECKSUMS_SHA256.txt`: file integrity.
- `VALIDACION.txt`: scope of the check performed.
- `REGISTRO_GENERACION.json`: instructions for edits and working references.
- `previews/preview_tier2.png` and `preview_tier3.png`: full views of each tier.
- `previews/preview_comparacion_t1_t2_t3.png`: examples sorted from left to right.
- `previews/preview_guanteletes.png`: Base, T2 and T3 enlarged.

`previews/` sheets are for review and should not be copied as game icons. Package validation covers the images and the ZIP; it does not include an execution within the engine.

