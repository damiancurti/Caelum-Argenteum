# Caelum Argenteum campaign atlas

The illustrated atlas has 80 design sheets, six enlarged layouts, regional material samples and painted-model comparisons. The approved layouts for the MAP02 sewers and Barracas al Sud are reproduced from [issue #454](https://github.com/damiancurti/Caelum-Argenteum/issues/454).

## Campaign count for implementation

| Playable segment | Maps |
| --- | ---: |
| Prologue, MAP01–MAP03 | 3 |
| Chapters I–III between the prologue and the Moon | 75 |
| Lunar finale in Chapter III | 2 |
| Total | 80 |

The 78 maps before the Moon include the three prologue maps. [Issue #906](https://github.com/damiancurti/Caelum-Argenteum/issues/906) records this count. The PDF, CSV, JSON and Spanish handoff retain the chapter labels of the original proposal. The allocation of the 75 intervening playable maps across the chapters remains open. The Major Arcana allocation is one in the prologue and seven per chapter.

## Files

| Authoring task | Resource |
| --- | --- |
| Read the maps, routes, arcana and regional galleries | [Illustrated atlas](Atlas_Caelum_80_mapas.pdf) |
| Filter levels and routes | [Editable JSON](catalogo/mapas.json) and [CSV](catalogo/mapas.csv) |
| Choose environment textures | [Regional selections](catalogo/regiones.csv) and [48 material names, scales and uses](catalogo/texturas.csv) |
| Load all environment materials | [Combined environment PK3](entornos/Caelum_48_materiales.pk3) |
| Work in one biome | [30 individual regional PK3s](entornos/selecciones) |
| Preview painted models | [Model skin PK3](modelos/Caelum_pieles_pintadas.pk3), [17 replaced paths](catalogo/pieles.csv) and [16 source swatches](modelos/Muestras_16_materiales_UV.zip) |
| Compare the designs | [Four map layouts](referencias/Cuatro_recorridos_Caelum.png), [model comparison](referencias/Comparativa_modelos_Caelum.png) and [seven comparison pairs captured in GZDoom](referencias/comparativas_en_GZDoom) |

## Applying the resources

1. Load the Caelum base game. Add the combined environment PK3 and the painted-model PK3 afterwards. For a single biome, load its individual environment PK3 in place of the combined environment file.
2. In Ultimate Doom Builder, add the chosen environment PK3 as a resource for the GZDoom UDMF map. Use the `CX` aliases listed in the texture catalogue on walls, floors and ceilings. `CXESTROJ` is the red quebrada stratum. `CXREGLUN` is lunar regolith.
3. Match each design sheet to the project's [map registry](https://github.com/damiancurti/Caelum-Argenteum/blob/main/assets/map_catalogue/MAPS.json). Preserve MAP01–MAP03. For sheet 04, check the existing CABAIRES lump before reserving a new name. Check proposed essence assignments against [campaign progression](https://github.com/damiancurti/Caelum-Argenteum/blob/main/assets/campaign/PROGRESSION.json). The crater and palace are sheets 79 and 80.

The reference was prepared against [game source 5.17.123](https://github.com/damiancurti/Caelum-Argenteum/tree/0953a15e056d02ea65e24b62c7b3be4909b1451c). All 48 materials were loaded on walls, floors and ceilings in a GZDoom 4.14.2 test map. The seven model comparisons use matching cameras, poses and lighting. Level construction and in-campaign testing are tracked in [issue #906](https://github.com/damiancurti/Caelum-Argenteum/issues/906).

The [Spanish handoff](LEEME.txt) documents the original proposal. This PDF copy keeps the original page dimensions, vector drawings, selectable text, bookmarks and image dimensions. Embedded color images use high-quality JPEG compression for downloading. The issue also links to the original delivery for archival use.
