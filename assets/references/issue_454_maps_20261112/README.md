# Approved map redesign references for issue #454

The author approved these diagrams as programming references on 2026-11-12.
This commit stores reference assets only. It does not implement or release a map,
change game data, or establish native-engine or author-test acceptance.

## Authoritative files

- [MAP02_Alcantarillas_Propuesta_v2.png](MAP02_Alcantarillas_Propuesta_v2.png):
  enlarged sewer proposal, revision 2. This supersedes the first, simpler sewer sketch.
- [Barracas_al_Sud_Propuesta_v1.png](Barracas_al_Sud_Propuesta_v1.png):
  approved city layout. The city did not receive the sewer's revision.
- [Caelum_Argenteum_Propuesta_Mapas_v2.pdf](Caelum_Argenteum_Propuesta_Mapas_v2.pdf):
  three boards: expanded sewer; city; dimensions and implementation notes.

The original Spanish labels are retained from the author's review.
Issue [#454](https://github.com/damiancurti/Caelum-Argenteum/issues/454)
contains the implementation contract and acceptance criteria.

## Interpretation

These are conceptual spatial diagrams, not uniformly scaled UDMF plans.
Use their topology, districts, spatial hierarchy and dimensions as the approved
starting point; construct actual wall thicknesses, bends, doors, crossings and
clearances in the implementation. Keep the height targets while increasing sewer
extent. The approximate twofold sewer traversal target is relative to the first
concept sketch, not a measured factor against the current game map.

The sewer includes three principal circuits per sector (twelve total), plus four
internal maintenance shortcuts, branch dead ends, four cells, four repair refuges
and pre-boss prisoner extraction. Preserve existing key and boss progression.
The lower flooded recovery network remains required even though this plan focuses
on the main playable level.

The city uses a compressed interpretation of Avellaneda's river and road structure.
Its municipal building, neighborhood plazas and fortified perimeter are game
design placements, not claims of exact 1889 cadastral reconstruction.

## Provenance

Original proposal boards drawn for this conversation using ReportLab and rendered
to PNG. No third-party cartographic bitmap is included. Geographic/historical
inspiration:
- [Municipality of Avellaneda: history](https://www.mda.gob.ar/ciudad/avellaneda/)
- [Municipal historical circuit / Plaza Alsina](https://turismo.mda.gob.ar/descubri/avellaneda-historica/)
- [ACUMAR: Dock-Sud / Huergo 1889 map record](https://centrodocumental.acumar.gob.ar/items/show/872)

## Transfer checksums (SHA-256)

| File | SHA-256 |
| --- | --- |
| Caelum_Argenteum_Propuesta_Mapas_v2.pdf | d3fc6b6d94c80e07fac6e177bdc72685b52d8504d51a5ef2562914cbd5353532 |
| MAP02_Alcantarillas_Propuesta_v2.png | 45dac016aa4cfb3ac9e591612eada20ee4b75f04cf049875270c16a68123be21 |
| Barracas_al_Sud_Propuesta_v1.png | 44a0afdcae469e552a3f98bebf4271623e7928caf2951e9bfbf8b06901ee89b6 |

Carry these references into the focused implementation delivery as needed.
Apply the repository's branch-consolidation policy when that work is integrated,
preserving reference ancestry and the files.
