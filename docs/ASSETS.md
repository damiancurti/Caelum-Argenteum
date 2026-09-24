# Caelum Argenteum — Audio and art

Documentation version: **4.36.3** — 2026-09-23.

## 4.36.3 — Additional flail-handle rotation

Issue #9 changes the shared native first-person handle offset from -39.5 to
-29.5 degrees: another 10 degrees counterclockwise, verified in GZDoom g4.14.2
on Windows 11 for T1–T3. `FLAIL_HANDLE_ANGLE` in `CaelumFirstPersonLayers.zs`
is the single current offset. The grip (235,158), joint (213,61), half-shaft
insertion, handle/chain/hand layers 50/46/52, scales and palette are unchanged.
The joint follows the handle transform; the chain retains its own vertical
rest orientation and 360-degree counterclockwise attack revolution.

No artwork, native crop declaration or generator output needs regeneration.
The -39.5-degree manifest in `assets/first_person_v7/COMPOSITION.json`, its
`generate_fp_native_0i.py` provenance output and the original native captures
describe 4.36.0i and remain historical evidence, not the current handle offset.
Current native comparisons and conditions are in
`assets/validation_4363/RESULTS.json`; HISTORY records verification separately
from pending author acceptance CA-4360I-VISUAL-01.

## 4.36.2 — Deterministic bow crop caches

Issue #8 derives six 512 x 1024 RGBA caches in
`src/graphics/caelum/first_person/bow_cache/` from the existing original
`v3/standard_bow.png` and `v3/longbow.png`. The maintained generator is
`assets/generators/generate_fp_native_0i.py` (Pillow required only to regenerate).
It applies the same column clipping, alpha-derived row shifts and integer
crops as 0i, copying alpha without multiplying it. Source artwork is unchanged;
the caches inherit its provenance and attribution. TEXTURES retains native
desaturation and tint, all sprite names, scales and offsets. Flail output and
other resources are unchanged. The generator is not needed at runtime.

Native before/after evidence is in HISTORY and `assets/validation_4362/`.
The original 0i captures and composition manifest remain historical evidence.

## 4.36.1 — Documentation and provenance

Issue [#6](https://github.com/damiancurti/Caelum-Argenteum/issues/6) translates
maintained documentation and project-authored attribution notices into English.
Authors, source URLs, license terms, original prompts, evidence logs, hashes,
resource paths and external source material are preserved. Art, audio, maps,
generators and game localization retain their existing bytes. Ancillary guides
without a current-version header inherit README's release; versions in their
provenance identify the resource's original integration.

Resource-specific historical installation/test guides remain reference records.
Use [README](../README.md) for the current checkout workflow and
[pending_test.txt](../pending_test.txt) for outstanding author acceptance.
Historical captures are not new 4.36.1 engine or visual acceptance results.

## 4.36.0i — native composition and MAP02

No source PNG was edited. generate_fp_native_0i.py analyzes alpha and writes TEXTURES: the
flail is separated into handle GFS1/2/3 and chain/ball GFC1/2/3 using native crops of the
original art. Handle on layer 50, chain on 46, hand on 52. Pivots: grip (235,158), joint
(213,61). Rotation −62°+22,5°=−39,5°; half the exposed length is hidden inside the hand.
The ring-to-ball-center line is vertical; the chain does not inherit the handle rotation.
AttackFrame travels 360° counterclockwise during the actual attack; it returns to vertical
rest afterward.

Bows: 18 states D16/D17 (three tiers × three phases × two families) reduce XScale in half.
Row crops correct the center to maintain curvature and length. Horizontal pivots
compensated; YScale, muted palette, hands, string and arrow are preserved. Floor sprites and
icons are not modified. Pillow is optional dependency on the generator for reading the
alpha, not the game.

The ENGINE_FLAIL/ENGINE_STANDARD_BOW/ENGINE_LONGBOW.png captures come from GZDoom 4.14.2
(Linux, OpenGL llvmpipe, 1280×720). They are not reconstructions. COMPOSITION.json records
the factors used. ENGINE_FLAIL_SPIN.txt retains the native angles of the attack. The final
aesthetic acceptance corresponds to the author. On 2026-09-23 the author
accepted the bow appearance and requested approximately 10 degrees more
counterclockwise flail rotation from this pose (#9, planned 4.36.3).
CA-4360I-VISUAL-01 remains partial for that flail correction. The separate
empty-bow equip stall (#8) is a runtime defect, not a rejection of the
accepted bow art; its 4.36.2 correction and evidence are described above.
The correction is implemented in 4.36.3 above; final author approval remains pending.

MAP02.wad is generated with generate_map02_maze.py, only Python standard library.
MAP02_MANIFEST.json describes geometry, keys, traps, enemies and all the loot. It reuses
CASWRFLR/CASWRWAL/CAPOOL01 textures, chest models, traps and project actors. Ace (1) of
Cups uses the existing Tarot card back: there is no approved front of that card on the
recovered base. Its name and bonus are specific, and the Journal does not present it as El
Loco.

0i verification is saved in assets/validation_0i. Generators are optional utilities; src
already contains the results ready to build. GZDoom, Freedoom and local automation harness
are not included.


## History 4.36.0h — adjustment to the capture marked by the author

The accepted 0g art and palette is preserved. The flail turns 90° clockwise in respect of
its previous pose on the three sets; its grip moves 35 MU to the left to keep chain and
head inside the frame.

The reference No Title(2).png marks in red the upper segment of the index that must be
left behind the bow and in blue the wood that must remain under the thumb and other
phalanges. DH12 retains scale/pivot/canvas and modifies only the front mask: thumb in
y120–134, base in y135–138; the other phalanges retain their cuts. The complete hand
remains in 49, bow in 50, mask in 51, right in 52 and arrow in 53.

PNG is not edited and no illustrations are generated. The initial meal reuses the tabletop
system plate/container, linked to real servings.

assets/first_person_v6/COMPOSITION.json identifies the reference and recipes.
PREVIEW_FLAILS.png and PREVIEW_BOW.png are inspection reconstructions, not engine
captures. VALIDATION.json and LOGIC_VALIDATION.json separate local checks from the pending
native tests.

## 4.36.0g — parts, fingers and muted colors

The correction is native to src/TEXTURES and CaelumFirstPersonLayers.zs. Pixels of
existing PNGs are not modified or other people's art is introduced.
assets/first_person_v5/COMPOSITION.json records the cuts, layers, scales, palettes and
hashes of the three copies of unprocessed icons.

- D061–D063: axe heads; GAX1–GAX3: separate handles.
- D111–D113: Halberd blades/strips; GHB1–GHB3: shafts for axial extension.
- D071–D073: flail with +28° rest twist applied by its controller.
- D091–D093: atlas v4 of the greatsword, the same shape and a more muted palette.
- D161–D173, A/B/C phases: v3 bow atlas with a new muted palette.
- DH12: selected FH03 glove thumb and phalanges; index excluded.
- Graphics of the three ca_greatsword*.png routes: common palette of the greatsword.
  CGRSA0 explicitly uses the same result T1 for the ground object.

PNGs under src/graphics/caelum/first_person/v5 are exact copies of v4 icons; independent
names are needed for native recipes. Originals and previous masters remain available.

PREVIEW_COMPARISON.png and PREVIEW_BOW_GRIP.png are reconstructions for inspection; they
are NOT engine captures. The three tiers and all phases of the bow were also reviewed.

## 4.36.0f — broad blade and corrected native composition

Four new original PNGs, edited with imagegen from the project's greatsword: a first-person
1536×1024 and three RGBA 1254×1254 icons. They are copied without processing their pixels.
Prompts and hashes in assets/first_person_v4; the runtime atlas is in
src/graphics/caelum/first_person/v4/greatsword.png.

The main width of the atlas blade measures between 1,59 and 1,68 times that of the previous
master in the samples Y=200,300,400,500,600, for the three tiers. D091–D093 use native
512×1024, XScale/YScale 5,91 and anchors on the handle. CGRSA0 retains presentation
dimensions 128×128 using XScale/YScale 9,796875. Existing icons are replaced in their
original routes; the UI retains its links and destination dimensions.

In the two bows, Blend 92,86,78,0.48 reduces the vibrancy of the atlas tones by means of
TEXTURES. DH03 is the complete hand behind the bow limb; DH11 is the clipping of the
original thumb (118,113,27,26) located in front, with the same scale/anchor. No other hand
is generated or the glove enlarged.

String: 1×1 EBST transforms into quadrilaterals between tips and nock with the native
fields Coord0–Coord3. EBAN arrow in 53 layer, removed when shooting or emptying and
changing family. 46–53 layers are cleaned together when hiding the weapon. NoTrim and
pivots in texture units prevent an alpha trim from displacing the grip.

Proven technical reference: [GZDoom renderer
4.14.2](https://github.com/ZDoom/gzdoom/blob/g4.14.2/src/rendering/hwrenderer/scene/hw_weapon.cpp),
HUDSprite::GetWeaponRect. On screen: x'=cx+sx(x cos a+y sin a), y'=cy+sy(−x sin a+y cos a). The scale is applied after rotation. QA views reconstruct that transformation;
they are not engine captures.


## 4.36.0e — corrections requested after testing 0d

[PROGRAMMED] Fists with continuous forearms and the same glove of the other weapons; left
and right come from the same original PNG, reflected by TEXTURES. The original set of
hands is also used for both bows. The left is in a layer anterior to the right. Glove
sizes independent of the size of the weapon.

[PROGRAMMED] Hatchet, axe, war axe and halberd tilted to the right with the handle seated
on the grip. +20% sword and greatsword +15% relative to 0d. Recurved standard bow and
continuous-limb longbow, both in T1–T3, with a string between the tips and hand, and visible
arrow only if loaded.

[PROGRAMMED] MAP01's trimmed chord at the first revelation of the Arcanum. Original level-up
sound by confirming its capture and applying the bonus. [CONFIRMED BY THE AUTHOR] Correct
0d transitions; its logic is preserved.

[PROGRAMMED] Carriage with front axle and two front wheels: four wheels in total. On the
boat, volume of Use not solid in front of the hull, in addition to the sign; the warning
remains centered and retains the requirements of boarding. New parts are added once when
preparing vehicles, also when loading.

[VERIFIED LOCALLY] Structure of changed sources and resources, references, layers, OBJ
geometry and reconstructed weapon/model views. GZDoom was not run for 0e: the complete
baseline had not been recovered and no engine was installed. Changed files start from
their latest recovered versions. [PENDING] Compilation and gameplay/visual testing in
GZDoom 4.14.2 / Windows 11. Instructions: PRUEBAS_4_36_0e.txt. The following sections are
historical.

## Revised first-person view — 4.36.0d

All previous PNGs and all audio are maintained byte for byte. TEXTURES reuses original
handless weapons as Dxxx layers, with FlipX only in hatchet, machete, axe, war axe and
halberd. The grips and scales belong to the controller, not to the image file; grAb
offsets of the package are preserved. The sword now activates the variants supplied with
small hands. The old rig remains a resource compatible with saves.

| New original resource | RGBA resolution | Use |
| --- | --- | --- |
| closed_fists.png | 1774×887 | Independent left and right fist |
| bow_left_grip.png | 1448×1086 | Back of the left hand on the bow |

The two PNGs are generated with imagegen using hands_grips.png as a glove, bracer, metal and
red cloth reference. The second uses also the photograph of the author's hand. They are
integrated unchanged into src/graphics/caelum/first_person/v2; these originals are runtime sources for TEXTURES and enter the PK3. The clipping and scaling are native, without
redrawing the pixels by script. DH08 uses XScale/YScale=16; DH09/DH10, 8,5. They do not
contain Doom art.

assets/first_person_v2 retains README, work prompts, provenance, hashes, pivots and final
layer placement. It does not duplicate large PNGs. TEXTURES_4_36_0d.txt is the integrated
fragment; it should not be loaded a second time. The new arrival rune reuses CMNQ; the
restart reuses column and CLVR lever to 0,045 scale. No additional sounds are
incorporated.

The views are inspected in the native renderer to 1024×768 and 960×540. The author retains
the final review of grips/proportions in Windows 11. The descriptions of 0c that retained
the swordrig are historical; the application for this patch authorizes replacing its
active presentation.

## Resources contributed and integrated — 4.36.0c

Author Packages: Caelum_Argenteum_Primera_Persona_v1(1).zip and
Caelum_Argenteum_Audio_Eventos_v1.zip (audio revision 1.4). Sources, masters,
manifests, instructions and source data under assets/first_person_v1 and
assets/audio_eventos_v1. are preserved. VALIDACION.json describes the original validation
of the package, prior to integration; INTEGRACION_4_36_0c.txt records the subsequent
connection. Masters do not enter the PK3.

First person: 101 original game PNGs (93 weapon/phase and eight hands), 20 families in
three tiers and 93 virtual TEXTURES compositions. 19 new families are activated and the
approved modular sword is preserved. New sword variants are recorded as resources. All
supplied PNGs retain their bytes, alpha and grAb. No extra images are generated and DSWD,
RHND, RFNG, DSHD or LHND are not replaced. Code uses the manifest pivots and one
composition per grip, including the palm behind the book.

Runtime audio: six OGG Vorbis, 48 kHz, with five active assignments and a registered but
unselected boat alternative. Byte for byte is retained.

| Use | Duration | Source/Edit |
| --- | --- | --- |
| Lever | 0,154 s | Full mono click |
| Carriage | 6 s | Hooves, segment 2–8 s |
| Ship | 6 s | Waves, segment 3–9 s |
| Tarot capture | 3,309 s | CA_MUS01, 30,358146–33,667042 s |
| Rolling | 3,80 s, mono loop | Stone, 38,30–42,40 s with 0,30 s crossfade |
| Alternative ship | 6 s | Home 0–6 s, available as resource |

The tarot retains 2 ms/20 ms fades and +200 ms offset of the 1.4 revision. It is not an
isolated guitar track. It corrects only the outdated interval of the integrated credit; it
does not re-edit the audio. The four external effects retain its CC0 credits and the HQ
preview traceability of Freesound. WAVs are edited, not original lossless masters
downloaded from Freesound. CA_MUS01 maintains the project rights.

Lever: the same CLVR atlas is reused up/down; its game scale passes to 0,045. Existing
models, textures, bull, maps and PNG are not regenerated. The package incorporates art
supplied and not Doom resources.

## 4.36.0b — lever, sphere and bull scale

New original atlas generated with imagegen: src/graphics/caelum/world/
ca_lever_states.png, 1774 RGBA × 887, real alpha background, lever up/down. TEXTURES
records CLVRA0 and CLVRB0 trimming two windows of 320 × 887 of the same PNG: X -375/-1080
and Offset 160,480. No pixels were edited. Plate and pivot are recorded; drawing is
mounted with WALLSPRITE to 16.5 MU on the side of a column and with pivot to 47 MU on
height. Scale 0.09; both positions free the capitals.

assets/generators/generate_hazard_models.py generates two own OBJs: square column of 96 MU
high and nearly spherical rock with radius 48, without flat base. The UV of the rock is
continuous and the pivot is in its center. CASWRWAL and rock_granite.png are reused. New
models compensate for level.pixelstretch on the vertical scale of the visual actor with
CorrectPixelStretch, aligning rendering, ground and collision. The visual actor of the rock
follows its center; UseActorRoll rotates around it. Accepted environmental rock models are
not modified.

TEXTURES expands a 25% all BULL/BUID sprites; BURN also uses a constant factor per view
obtained from the median of its silhouette relative to rest. Running frames no longer shrink
by the transparent margin. Bull PNGs and their existing states remain identical to 0a; the
change is drawing.

The magic plates reuse their own seals of fire, quintessence, and earth, centered as
horizontal sprites. The scintillation uses XFIR. The new events are aliases of own sounds:
iron_gate for lever, thunder_heavy for mine, palomo_disappear for teleportation and
door_large_open for crusher. Travels reuse ca_map_transition. No Doom resources or other
audio are incorporated. The prompts and cutting record are in
assets/source/art/lever_4_36_0b.txt.

## 4.36.0a — physical gallery resources

No extraneous images or audio are incorporated. The trapdoor uses CSUFA0 and CMWD01 wood. The
walls/floors use CASWRWAL/CASWRFLR; the mechanisms reuse CSGT and the sound itself
caelum/world/door_open. The rock uses ca_rock_granite.obj, CARK A and the 0.5 scale of
small granite; MODELDEF adds its specific association with UseActorRoll. The approved
visual package v4 is not altered bytes.

assets/generators/generate_sewer_trials.py generates MAP03–05 and adds MAP08, with the
gallery, pit and stairs. MAP01–07 WADs are identical to the base; only MAP08.wad is
added. This avoids invalidating saves by checksum. The generator remains as an optional
source: run_dev.bat does not need Python. Visual revision is done in the native renderer
with the lid closed and open.

## 4.35.0q — author v4 sprites and icons

Source: Caelum_Argenteum_Sprites_Iconos_v4(1).zip, received the 17/09/2026. It
incorporates exactly its runtime PNG, without recoloring, trimming, changing offsets
grAb or altering the physical scales of the actors. The assets/manifests/sprites_v4.json
manifest retains provenance, ZIP footprint and 1006 PNG footprints. Masters, prompts and
references remain in the original package provided by the author.

750 sprites: 514 new and 236 replacements. Of its 256 icons, 152 replace 0p icons, one is
new and 103 were already identical; the patch only includes the new/modified 903 PNG. It
is a match with 0p, different from the count of drawings retouched from the artistic base
described in the package.

| Character | Rest | Run | Separate walk |
| --- | --- | --- | --- |
| Rulo | RUID | RURN | — |
| Ronnie | ROID | RORN | — |
| Argento | ARID | ARRN | — |
| Caella | CAID | CARN | — |
| Domingo | DOID | DORN | DOWK |
| Palomo | PAID | PARN | PAWK |
| Toro | BUID | BURN | — |
| Mandinga | MIID | MIRN | MIWK |
| Zupay | ZUID | ZURN | ZUWK |

Each phase has eight rotations; 514 definitions Sprite are added to TEXTURES. Palomo uses
RSPA A/B sitting without chair/crouching. The bag uses its own icon and CSBG/CSBO as backup
sprites; MODELDEF retains meshes and scales and links those names. The existing
RSDO/RSRU/RSRO/RSAR/RSCA poses and their approved guidance aliases are preserved
unchanged.

The integration is adapted to the current code: Palomo is already moving and Mandinga and
Zupay already have AI. The installer example, which presupposes previous states, is not
used automatically. New states are attached to keep the serialized indexes. New/modified
files are ready for run_dev.bat; Python is not required or install the package for the
second time.

## 4.35.0p — original carriage and merchant ship

Four new OBJs in src/models/caelum/vehicles, reproducible using
assets/generators/generate_travel_vehicles.py: two-wheeled carriage, coastal merchant ship,
ranch and dock. Original Box wood textures and station materials are reused; no external
images are copied. OBJ surfaces are grouped by material and use native engine render. The
generator imports Mesh from stations and environments, without regenerating them.

Base scale: 32 MU/m. Carriage: body approximately 3,6 × 1,7 m, two 1,8 m wheels, arched
canvas up to 3 m above ground and shaft/yoke; total volume approximately 5,7 × 2,56 × 3 m
including shaft and wheels. Includes a bench and crates. Merchant ship: nominal hull 12 ×
3,5 m, depth 2 m and mast top 9 m above the waterline; gaff sail, jib, rudder, rigging,
hatch, crates, four stowed oars and boarding sign. Rudder and sign extend beyond the hull.
Rancho: wall footprint 8 × 6 m; pier: deck 18 × 4 m with piles. MODELDEF compensates these
maps' pixel stretch to preserve height/MU.

Historical references consulted (not built-in art licenses):
- NPS, Wagons on the Emigrant Trails: variation among nineteenth-century covered wagons;
  Murphy wagon with a twelve-foot body and nine-foot height; larger freight wagons.
  https://www.nps.gov/articles/000/wagons-on-the-trails.htm
- NPS, Traveling the Emigrant Trails: days with pauses and animal traction.
  https://www.nps.gov/articles/000/traveling-emigrant-trails.htm
- Thames sailing barge: coastal sailing trade and antecedents with long oars.
  https://en.wikipedia.org/wiki/Thames_sailing_barge
- Watchkeeping, traditional system: watches allow you to navigate the 24 hours while the
  other crew members rest. https://en.wikipedia.org/wiki/Watchkeeping

They are comparative references; they do not document a concrete Argentine piece of 1889
nor a universal speed. The carriage and the merchant are representative own designs; 3
km/h and 5 knots are nominal initial estimates with normal load and favorable conditions.
The 16/8 rule of the carriage retains the requested day for the game; it does not state
that the same draft team always works 16 hours without reliefs. The ship involves active watches,
not neglected navigation.

## 4.35.0o — monthly calendar

Reuse original Journal panels and fonts. The tester reuses Ronnie sprite as a separate
actor; it does not replace the resident. It does not include generated art, new maps,
IWAD, binary or Doom resources. Validation captures are intermediate and are not packaged
with sources.

## 4.35.0n — travel budget

The confirmation reuses original panels and fonts. It does not add art, maps, sounds or
dependencies; the maps and textures of 0m are approved by the author. Distances are
assigned to catalog connections; geometry is not stretched. Native capture of the forecast
checks path reading, step, journey, provisions, final reservations and buttons in
1024×768.

## 4.35.0m — author materials and coastal maps

Input: Caelum_Texturas_Ciudad_Puerto_Playa_v1(1).zip, provided by the author. 18 PNG
city/port/beach is integrated without changing its bytes, under
src/graphics/caelum/textures/entornos_v1. TEXTURES incorporates its fragment by
combination: 4 pixels/MU, WorldPanning, 128×128 MU surfaces, 128×64 and 64×128 door sheet.
The package is already included in the sources; the same environment add-on is not
required.

assets/coastal_textures/integration.json records SHA-256 of the ZIP input and each
integrated PNG. PROMPTS.json and EXPORT_CROPS.json retain artistic provenance and recorded
cuts of the package; the masters remain in the original ZIP of the author. The
eight optional mansion remasters are not installed in this installment; the existing
images of those IDs continue.

MAP06/07 use its own UDMF geometry with physical surfaces and volumes: piers, warehouse,
office, eaves, load covered with burlap/iron, coast, water, trees and existing furniture.
The standard Python generator assets/generators/generate_coastal_trials.py reproduces both
WAD included, without reconstructing the previous maps and without dependent on Python
when playing.

CABASKY is a uniform grey color composed of native TEXTURES; it does not contain images
inherited from Doom. It is a static background for testing. Lighting, water texture and
sky do not yet represent the visual weather/hour by animation; the Journal reading does use
date/hour and shelters. Population, historical billboard or exact reproduction of the 1889
port are not included.

Revised native captures: port, interiors, coast, shelter and Journal with seven visits.
Proven coverage materials along with geometric ceiling. They are areas to tour/test
systems; artistic expansion is separated from functional completion of the clock, trips and events of
4.35.

## 4.35.0l — attributed climate data and furniture

Existing models, sprites, textures, maps and sounds are preserved. Eastern tables change
position and angle by means of the persistent controller. Native captures confirm two
visible chairs per room. The Journal uses current sources for region, temperature/RH and
coverage on its two lines.

New data resource: assets/climate/smn_1991_2020.json, transcription of numerical values of
nine stations, with identifiers, coordinates, PDF/print pages, variables and units.
Source: Servicio Meteorológico Nacional (2023), Climatological Normals, Republic of Argentina,
1991–2020, 847 pp. Wind 2011–2020. CC BY 2.5 Argentina, with attribution:
https://repositorio.smn.gob.ar/handle/20.500.12160/2506 Pages and images of the original
report are not redistributed.

Generator: assets/generators/generate_climate_normals.py, Python 3 standard, no external
dependencies. Produces src/caelum/world/CaelumClimateNormals.zs, already included. It does
not run during build/gameplay and does not require network.

Vapor pressure: Relationship Published by National Weather Service:
https://www.weather.gov/media/epz/wxcalc/vaporPressure.pdf The weather-front/shelter synthesis
coefficients are simulation design; they are not attributed to SMN or NWS. There are no
new meteorological visual resources.

## 4.35.0k — Journal environmental reading

No binary resources, maps, sprites, textures, models or sounds are created. Journal >
World uses existing fonts and frames; adds two environmental lines in y=176/188 on canvas
640×360. Location/connection headers pass to y=206, with lists from y=220; space is
preserved for five places, three connections, last trip, return and lower aids.

LANGUAGE incorporates 19 equivalent keys in English/Spanish: local profile,
temperature/humidity, wind/precipitation, calmness, eight directions and absence of
profile. The variant "Campaign Environment" distinguishes an active diagnostic date. The
external test profile is consulted by console, without changing the presentation of the
real map. The particles of rain, sound, sky and light remain for its audiovisual block;
this patch offers the common environmental data.

Journal test captures in 16:9 and 4:3 verify distribution and labels. Fixtures complete
the list only to review their most loaded case; neither those discovery marks nor the
captures are distributed. The ZIP contains only modified sources/documentation and
PRUEBAS_4_35_0k.txt.

## 4.35.0j — Limbo clock, station scale and text

The twelve station models and their MODELDEF associations remain. The actor uses 0,75
scale versus 1 in 0i and 0,5 before 0h; its three dimensions pass to 75% in 0i. The
collision adjusts to 30 radius/72 height. OBJ, textures, sprites or WAD are not
regenerated. The plate/cup support is preserved fixed in 0i.

LANGUAGE updates the clock and acceleration aids in English/Spanish: Limbo 1:1, with
clock/calendar active. CA_DLG_M01_PALOMO_FOYER compares its rhythm to another place known
by Palomo. It maintains the native structure of CAPALOMO, its responses, milestones and
audio. Revised native captures of that greeting and the reduced posts; the captures of QA
are not distributed.

generate_environment_models.py incorporates the same local time as the runtime for daily
regeneration; regenerate it does not reinstall the previous Limbo rate. This delivery
contains modified sources/documentation and test TXT, without new binary resources,
engine, IWAD, saves or fixtures. The sizes/texts described by previous versions are
historical references.

## 4.35.0i — serving placement on tabletops

The approved designs of ca_food_plate.obj and ca_water_cup.obj are preserved. They are not
regenerated or retouched PNG. The problem was the difference between 34 MU of model
co-ordinate and its global height when applying CorrectPixelStretch.
CaelumDiningTable.SurfaceHeight uses the same vertical correction to place the figures;
CaelumDiningDisplay also applies it to 0h saved figures.

The placement of the furniture changes in ZScript, preserving models and WAD. The eastern
tables remain in the previous area of the beds, with 16 MU margin for their chairs. The
normal table moves 100 MU towards the false wall. The doll uses CDMY, the existing own
resource, without any other design.

Crafting help shows T to speed up. Limbo's rest panel indicates progress status and
schedule stopped in English/Spanish. Native captures check support of plates/cups,
bedrooms, workshop door, practice target and advance panel. Captures and fixtures are only QA.

## 4.35.0h — MAP01 plates, cups and furniture

generate_dining_servings.py generates ca_food_plate.obj and ca_water_cup.obj in
src/models/caelum/props/rest. They are original meshes: ceramic plate, bread and portions
of stew; cup with open handle. Reusing paper/wood/wax/leather/iron from stations. They do
not require new PNGs or modify character images. MODELDEF links
CaelumDiningFoodPlate/CaelumDiningWaterCup with CAHC A transparent.

The visual grid is 2×2, 6×3 or 10×6 for 4/18/60 objects. The plate occupies a diameter of
21 MU and the figures are supported by 34,1 MU, on the board. The previous game
presentations are reconstructed with these models. A cup also represents a real container
with its own liters.

The three table models and chair/bed models are reused in six sets of MAP01. The twelve
station models maintain their MODELDEF and scale with the 0,5 actor to 1: double width,
length and height against 0g. Textures and WAD are maintained; the new distribution is
prepared from ZScript.

LANGUAGE updates workshops/directions and consumption aids in both languages. CAPALOMO
adds the no-duration menus 43515/43516. The panel displays active F/G channels and, in
MAP01, the clock stopped. Native captures verify plates, tables, workshops and
orientation; the QA material is not part of the ZIP.

## 4.35.0g — tables and view-direction mapping

assets/generators/generate_dining_tables.py generates three original OBJs: ca_table_small
(80 diameter), ca_table_normal (192×96) and ca_table_large (384×192), in
models/caelum/props/rest. They use wood/metal of the project and board to 34 MU. MODELDEF
associates them with table actors; new PNG textures are not incorporated. The placement of
sets creates existing chairs and rectangular collision by 48 MU blocks. In 0g the visible
consumables reused their sprite and scale; 0h substitutes them for the plate/cup mesh
described above.

The orientation corrects two causes: in front of the model to 180° of the inverse pose and
lateral order of the RSDO A/B atlas. TEXTURES adds alias 2↔8, 3↔7, 4↔6 pointing to the
original PNGs. C–G, crouched locomotion and the rest of characters retain their frames.
Front/back and side were verified in engine captures.

The panel (16,12,608,116) adds T for advance and F/G for table or indication of Lucidez
−10/s when sleeping. LANGUAGE contains new supports and answers in English and Spanish;
CAPALOMO provides USDF 43514. QA material, external sources, engine, IWAD and the full PK3
are not included.

## 4.35.0f — portable sleeping bag and comfort reading

The existing generate_rest_furniture.py generator adds two original meshes:
ca_rest_bag_roll.obj (wrapped bag when released) and ca_rest_bag_open.obj (canvas, folds and
pillow unfolded). They are stored in models/caelum/props/rest and linked from MODELDEF to
CaelumSleepingBag/CaelumRestBag. They reuse the tank's own materials, without new PNGs.
The provisional inventory icon reuses the fabric one; the name identifies "Sleeping bag".
The previous chair/cot meshes are regenerated with identical bytes.

CaelumSleepingBag.zs contains the Inventory, the temporary support and the invisible space
probe. CAPALOMO adds 43513 and an optional preparation to receive it. LANGUAGE
incorporates nine keys per language and updates chair/cot explanations to inform its
factors. The USDF route of four durations and the approved character art is preserved.

The panel occupies (16,12,608,108) over 640×360. It includes the Health/Air recovery line
and Hunger/Thirst loss, between the reserves and controls, leaving the bag and posture
visible. It was inspected in a native capture of GZDoom 4.14.2. Journal navigation
controls are not changed: only your view is closed before opening the selected bag dialog.

There are no altered maps, audio, fonts, sprites, textures or previous models. The patch
includes only new or modified sources/models/documentation, no engine, IWAD, full PK3,
test captures and QA fixtures.

## 4.35.0e — original furniture and rest view

Two original OBJs are generated with assets/generators/generate_rest_furniture.py, using
only the standard library and Mesh of the tank generator:

- src/models/caelum/props/rest/ca_rest_chair.obj: wooden chair with backrest.
- src/models/caelum/props/rest/ca_rest_bed.obj: low cot with frame, canvas and pillow.

They reuse wood, metal and interior materials from the tank. They are not created or
modified PNG. MODELDEF links both models to CAHC A, the transparent control sprite already
available; it applies 1 scale, AngleOffset -90 and pixel ratio correction. Actors have
their own collision. The eight RestSeated/RestLying rotations on Domingo are reused,
without altering those sprites. WorldOffset settings on the session are only graphics and
are undone when standing up.

The rest panel moves to (16,12,608,102) in 640×360 and 0,12 darkening. It groups date and
duration, resources and controls above to make the character visible. LANGUAGE
incorporates seven new keys per language: titles, descriptions, out of reach/lack of space and
camera support. CAPALOMO adds two conversations with the same four durations and approved
menu. Arrows, filters, Missions, Page Up/Page Down and Use release retain its implementation.

Native captures of GZDoom 4.14.2 were inspected on Linux, adjusting scale, orientation and
placement of both poses. They are simple test models with eight-view sprites; animated
character models are not incorporated. Windows test allows you to review the presentation
with the usual author resolution and renderer.

They do not change MAPINFO, WAD geometries, audio, textures, sprites or previous models.
The ZIP includes the new/modified generator and fonts, without engine, IWAD, PK3 complete
and QA material. ca_debug_rest_report identifies 4.35.0e.

## 4.35.0d1 — resolution of existing poses

The hotfix only fixes the rest state searches and re-includes the required Limbo catalog.
RestLying/RestSeated retains sprites, collision and presentation of 0d; no audiovisual
resource is added or changed. The rest report identifies 4.35.0d1; the other reports
retain 0d. It was compiled with GZDoom 4.14.2; no playable visual check is declared.

## 4.35.0d — interface and rest poses

New CaelumRest.zs and CaelumRestTrial.zs sources, included at the end of ZSCRIPT. CAPALOMO
adds the 43510 conversation on the approved common menu, with explicit modes, durations
and preparations. LANGUAGE adds the corresponding English and Spanish keys; World support
includes D/X along with C/Y and Use.

Domingo RestLying/RestSeated (RSDO B/A) is reused. No sprites, beds, chairs, maps or
models are created. The world pose does not change height, radius, or collision. The view
remains the usual for the player, with a 0,30 background resting and darkening panel; the
camera is pending.

The panel occupies (56,88,528,184) in 640×360. Shows mode, campaign date, remaining
minutes, Sleep/Hunger/Thirst with two decimals and controls. The conservative metrics of
new lines fit in 504 MU; it is not considered a native capture of GZDoom. UI retains
arrows, extremes and Page Up/Page Down; World X is resolved before the drop-out latch to not
retain Mission input.

MAPINFO, WAD of the six maps, fonts, audio, sprites, models, generators and existing
conversation menus keep their bytes. Reports carry the 4.35.0d identifier. No engine,
IWAD, PK3 complete nor QA fixtures.

## 4.35.0c — Presentation of Stopped Time

World reuses its two time lines, fonts and coordinates. In MAP01, the top line shows ‘Time
is stopped in the Limbo’; the bottom shows the canonical date or test view expressly
identified. LANGUAGE adds CA_WORLD_CLOCK_TIMELESS in English/Spanish and changes the
uninitialized-calendar message. The panel does not expand or change the
keyboard/command input. The metric revision is done over existing sources; the visual
inspection within GZDoom is left in the 0c tests.

WorldCatalogue, WorldClock, Calendar and World Presentation are modified; the headers of
the existing reports identify 4.35.0c. MAPINFO is preserved, approved uninterrupted
conversations, geometries, arrivals, accesses, posts, sprites, fonts, models, sounds and
generators. No assets are created.

## 4.35.0b — schedule on the existing presentation

New source src/caelum/world/CaelumCalendar.zs and include in ZSCRIPT. LANGUAGE adds eight
English/Spanish keys for date, boundaries and seasons. World adds one line in (48,160),
adjusts both columns and retains navigation. The five visited places and the three outputs
fit in the previewed panel; the author later confirmed all 0b tests, including their
presentation.

MAPINFO activates non-stop conversations in MAP01–MAP05 and CADEV02. Ticker from the
common menu is modified in CaelumPalomoDialogue.zs; USDF trees, formatting, voices, harp,
sprites, sources, and capture effects are not replaced. No new audio-visual resources,
regenerated maps, or modified generators. The newly defined skills icons/effects are not
delivered in 0b.

## 4.35.0a — presentation of the recorded time

No audio-visual resources or maps are added or regenerated. CaelumSmall and the existing
World panel are used for a timeline in (48,148), before the visit and output columns.
LANGUAGE adds two keys in English and Spanish: recorded time/scale and registration start
with confirmed profile.

New src/caelum/world/CaelumWorldClock.zs source included from ZSCRIPT. MAPINFO records
CaelumWorldClockTicker as a static observer for it to be activated with previous saves as
well. WAD, geometry, arrivals, accesses, test stalls, sprites, models, fonts, audio and
generators are preserved. Brands of the last trip are consulted in the existing travel
report.


## 4.34.0e — test sites in sewers

They are reused without modifying the models, sprites and sounds of workbench, sawmill and
forge, together with the seal of quintessence and native materials. No assets or maps are
generated. CaelumSewerTrialSupport.zs is added and includes ZSCRIPT; CAPALOMO retains the
pages 43410–43413 and adds two responses localized in English/Spanish. Infrastructure uses
its specific classes, so it retains existing MODELDEF associations.

MAP02: workbench (-320,64,0), sawmill (-320,120,0), forge (-264,120,0). MAP03–MAP05: bank
(-80,384,0), sawmill (-80,440,0), forge (-24,440,0). Nodes form a separate network by
proximity and are kept in the hub. They are stage objects; resources are only granted when
testing.


## 4.34.0d — travel service resources

No maps, images, sprites, models or sounds are added or regenerated. MAP01, MAP02,
MAP03–05, CADEV02, MAPINFO, TEXTURES and generators retain their 0c bytes. The test uses
the USDF dialog and the already integrated sources.

New sources: src/caelum/world/CaelumJourney.zs and CaelumCaravanTrial.zs, registered in
ZSCRIPT. CAPALOMO contains the four native offers 43410–43413 and their confirmations,
with English/Spanish keys in LANGUAGE. The test guide is invisible, temporary and without
own assets. The name and identity of a resident is not reused to represent a caravan.

The dialogue, common service, world registration, presentation and resumption of
conversation are the integrations played by 0d. The above diagnostic headers are updated
to 0d, without changing its logic. Private resources used to run QA in GZDoom are not
distributed.


4.34.0c adds MAP03.wad, MAP04.wad and MAP05.wad, generated as native UDMF by
assets/generators/generate_sewer_trials.py. Use only your own library: CASWRWAL for
masonry/vaulting, CASWRFLR for dry floor and CAPOOL01 for low visual channels. The CSGTA0
gate refers to the existing CMGT01.png; it is not edited or created another image.
MAP01/MAP02/CADEV02 geometries remain unchanged.

The generator is standard Python, without external dependencies. It runs with
assets/generators/generate_sewer_trials.py Python and supports --output for an alternative
output. Just type MAP03–05; it is not necessary to play for either run_dev.bat, as the
ready WADs are included. It is checked that regenerating the three maps produces exactly
the same bytes.

It does not change audio, images, models or typography. MAP03–05 reuse CA_MUS02 and the
journey retains the native sound of the player. World and access signs have
Spanish/English texts. Catches of gates, warehouse, cameras, stairs and the full Journal
are reviewed in both languages. Test maps do not incorporate enemies, items or cards
automatically. Engine, IWAD, QA markers and private captures are left out of delivery.

4.34.0b retains maps, sprites, models, graphics, typography, music and audio from 0a. The
optional presentation reuses CaelumSlidingDoorLeaf and its blockers; the native key uses
the existing key icon and is a test marker without an Inventory row. LANGUAGE adds
Spanish/English messages.

The LOCKDEFS 200, 201 and 202 locks use the ca_door_locked.ogg locked door OGG itself
using its existing alias; no audio is added. CheckKeys issues a single native feedback
limited by the timer, without overlapping manual playback. The native scenes and messages
of the test are reviewed in MAP01/MAP02 and both languages. The private resources of QA
are outside the ZIP.

4.34.0a retains all maps, models, graphics, fonts, music and audio from 0ao. World reuses
panel, icon and sources from the Journal and the names of MAP01/MAP02 already located;
LANGUAGE adds location, visits, connection, status, hidden destination and Spanish/English
aids. No new resources. The native render is reviewed before return, with known connection
and upon arrival, including Spanish and English texts. Credits and resource inventories
remain in place; the test export will be prepared after 4.37, before the
inherited/transversal range of V5.

0ao retains byte all 0an maps, models, graphics, fonts, music, audio and LANGUAGE. The new
diagnosis only writes on console upon request; it does not incorporate images, voices or
permanent elements of HUD. Reopening saved conversations reuses the existing native menu
and sound. The integration check uses the already accepted conversations and output.
Assets are not regenerated or the engine or IWAD used in QA is redistributed.

0an retains byte for byte maps, models, graphics, fonts, music and audio from 0am.
Reputation test uses the sliding door sheet and existing native menus; guide and enabler
marker are invisible. LANGUAGE incorporates Spanish/English for requirements, states,
Journal support and test trade. This trade shows title and generic labels, with a
different indication for temporary reduction by reputation. It is not presented as a new
NPC of history nor needs new art or voices. Native renders of both languages are
inspected; evidence in PROJECT.md.

0am retains all the graphic resources, maps, models, fonts and audio of 0al. Journal aids
in English and Spanish add a second line to explain the tab change at the ends. Its
fit is reviewed in the native render of Inventory and Missions. Capture and return change
their dialog checks, without retouching sprites, music or animations.

0al retains all the resources of 0ak. The Inventory aids and the case of a single mission,
in Spanish and English, are reviewed with the art and existing sources. The capture
diagnosis prints text on the console on request; it does not add elements to the HUD or
change the image of the essence or card.

0ak retains maps, images, audio, models and sources of 0aj. Position repair occurs on
existing MAP01 actors; it does not add or retouch models or geometry. Journal aids are
updated in English and Spanish and reuse current sources and art. The visual review covers
list of missions, Detail and Inventory; evidence in PROJECT.md.

0aj retains images, maps, audio, models and sources of 0ai. Diagnostic record uses
invisible Inventory and does not require new sprites. The interface reuses the art and
existing sources of the Journal.

## New containers — 4.33.0af

Six original illustrations generated with the integrated image tool, one by model; without
Doom resources. Source RGBA PNGs in
assets/art_source/water_0af/{bottle_small,bottle_normal,bottle_large,canteen_small,canteen_normal,canteen_large}.png.
RGBA 128x128 icons with alpha preserved in src/graphics/caelum/icons/water/, same six
names. src/sprites/CW0XA0.png floor sprites to CW5XA0.png, order small/normal/large
bottles, small/normal/large canteens; grAb offsets (64,128), world scale 0,25 inherited
from the consumable. Existing images are not replaced. Audio, models and preserved maps.

Shared generation prompt: "One game inventory sprite. Nineteenth-century Argentina dark
fantasy, semi-realistic hand-painted pixel art matching Darkest Dungeon and Blasphemous;
dark warm brown outlines, aged materials, top-left light; single upright centered object,
three-quarter frontal view, readable at 96 pixels, 15% transparent padding, genuine RGBA
transparency. No text, numbers, plastic, weapons, cups, scenery or grid." Variants: small
narrow olive-green corked glass bottle with neck twine; normal broad amber corked glass
bottle with leather base sleeve; large green corked demijohn with wicker basket and
handle; small round leather-covered tin canteen; normal oval stitched leather-covered tin
canteen with looped strap; large rounded rectangular reinforced leather-covered tin
canteen, brass cap and folded strap. Capacities 1/2,5/5 L respectively for each family.
Technical adaptation: downscaling to 128x128 and GZDoom PNG offsets; no repainting.


## 4.33.0ae Review

The five seal icons, their world actors, the HUD side indicator and the existing
Channel effects are reused. Recipes appear in Crafts with those resources. The dialog uses
the same harp sound and fonts. WAD, art, sprites, models, music, sounds or assets files
are not added or modified to 0ad approved. Visual review in PROJECT.md.

## 4.33.0ad Review

The T1 icons of the four armor families, station models, drawers, trees, shrubs and
existing veins are reused. No visual or sound resources are added. MAP01/MAP02/CADEV02 and
all audiovisuals keep 0ac bytes approved. The collection limitation does not change the
physical masses or hardness of its actors. Visual and technical evidence in PROJECT.md.

## 4.33.0ac Review

The bolt recipe uses ca_bolt_ammo.png and the CaelumBoltAmmo/CBOL actor that already
existed. Arrows retain their own icon and actor. Interface, fonts, sounds and stations are
reused; there are no new assets. The three WADs, art, models and audio keep 0ab bytes
approved. Maps are not expanded.

## 4.33.0ab Review

The pool and its sixteen steps, the native Ronnie dialog, harp sound and Detail fonts are
reused. No icons or markers are created. The three WADs, models, sprites, music, audio and
art sources retain the bytes of the 0aa approved base. The location indication is in the
dialog and Journal. Visual testing and review documented in PROJECT.md.

## 4.33.0aa Review

No art, sound, music, model or map files are added or modified. The Journal reuses El Loco
and the existing reverse; it displays text of minor passives with current sources. The
sweep uses the native selector of large weapons and their provisional presentation; the
first-person art of those weapons remains planned. No illustrations of cards are generated
even without playable content. Journal visual review in PROJECT.md.

## 4.33.0z Review

Maps, audio, art, models and generators identical to 0y approved. Load practice uses
leftovers and existing inventory controls. It does not add tutorial objects or construct
maps. Deferred sewers.

## 4.33.0y Review

No changes from WAD, art, models, audio or generators to 0x approved. Practice uses
existing corridors and the usual Ronnie dialog. It does not add markers, consumables or a
map path. Sewers are still delayed.

## 4.33.0x Review

No changes in the three WADs, art, audio, models or generators. Practice reuses existing
rations, icons and dialogues. No new maps are built. Cumulative 0w delivery was approved by
the author.

This cumulative over 0u includes MAP02, CADEV02 and 0v generator. MAP01 remains identical
to 0u.

## 4.33.0w Review

No art, audio, models or maps are added or modified. The Ronnie lesson reuses the native
dialog and accepted harp phrase. 74 audios, twelve stations and their sources are
preserved. All three WADs maintain their hashes.

## Return and arrival gate to sewers (4.33.0v)

MAP01.wad retains exactly the approved file. When loading, the controller visually
replaces the SW1EXIT panel by the CMDR03 itself and, after capturing El Loco, places the
existing CTAR marker. No sprites, textures, models or accepted sounds are modified.

MAP02 reuses CASWRWAL (brick), CASWRFLR (stone), CAPOOL01 (water, dyed by sector) and
CMGT02 (bottom rail).The arrival has 84 sectors, 187 lines and a player start, no enemies
or diagnostic objects. The reproducible generator is
assets/generators/build_sewer_arrival.py; just rewrite src/maps/MAP02.wad. The complete
setting is then extended.

CADEV02 retains the previous TEXTMAP of MAP02 with its 16.508 things: it only changes the
WAD name marker. MAP02 and CADEV02 reuse CA_MUS02. 74 audio files, 12 station models and
their fonts remain unchanged.

## Sword view (4.33.0u)

All approved art is preserved. DSHD and LHND are independent layers of shield/left hand;
they are not part of the sword sprite DSWD. Correction removes 10/20 layers when there is
no equipped usable shield and restores them for a real object. Sprites, models, sounds,
map or fonts are not retouched. The visual prototype console remains separate from the
weapon selector using the Ronnie loan.

## Pampas El Loco (4.33.0t)

0s accepted by the author. The original approved illustration “El Loco de las Pampas.png”,
1024×1536, is reused without changing pixels. Runtime:
src/graphics/caelum/tarot/ca_tarot_fool.png. TEXTURES registers CFLFA0 with XScale/YScale
8 and Offset 512,1536; the essence uses Scale 0.25 (32×48 MU). The Journal fits the same
file within 104×156 virtual units, preserving the illustration ratio in 16:9 and 4:3.
There is no additional copy in assets because the original and runtime version are
identical.

Before examining it ca_tarot_back.png/CTARA0 is reused. The capture generates a
collisionless CFLF image that approaches and reduces during 35 tics. reveal_sting and
player/level_up are reused, in addition to the native harp of the dialogue. Music is
attenuated during disclosure and restored when closing. No audios or models are added.
MAP01.wad remains identical to 0s; the controller reconstructs the appearance from the
mission state.

## Reuse in 4.33.0s

0r accepted by the author. Palomo retains sprites, scale, states and route. The new dialog
uses ConversationMenu/USDF, LANGUAGE in English and Spanish and the existing native harp
when opening/advancing. Delivery reuses pickup sound. The Box retains the current
interface/icon; its new identity instance is invisible in the world and does not add a
duplicate row or drawing. There are no new sprites, models, music or textures; MAP01.wad
remains identical. The representation of El Loco is incorporated into 0t, described above.

## Reuse in 4.33.0r

0q approved with the exception of post-combat interaction. Sprites, voices, models, music
and MAP01.wad are maintained. CrouchIdle is reused by the protected drop; Spawn is used
for recovery and restores physical height if a save reduces it. Status indices are not
altered or assets added. Rulo text changes in English and Spanish. El Loco appears/card in
the cave will be prepared with the Palomo/Box block; there is no new essence sprite in
this delta.

## Reuse in 4.33.0q

The four residents retain their actors, sprites, scale, attack animations and sounds. The
temporary drop in the test reuses CrouchIdle and the bent poses delivered by the author;
the recovery returns to Spawn/See. The leather uses CaelumMaterialPickup and its current
icon. No assets are created or replaced; the WAD and the 38 stations remain the same. 0p
rest approved.

## Reuse in 4.33.0p

The Rulo target reuses CaelumTrainingDummy and its CDMY sprite, 21 radius and 72 height; it
is placed in (-290,480,0), under the character's bedroom. The Bull reuses BULL and its
windup/gore/death frames; it extends anticipation and adds fainting to the body.
There are no new designs, models, textures, poses or audio. The dialogues keep the native
harp and the warnings use the existing interface. Assets are not distributed in the delta.

## 4.33.0o Review

0n approved by the author. The MAP01 external manual is removed from the world; its CBOO
sprite and the ca_book.png icon are still used by books and other objects. No visual,
model or audio resources are deleted or modified.

## Resources reused in 4.33.0n

Five 3D CaelumVeinRuby, Sapphire, Emerald, Topaz and Opal veins are placed at the bottom
of the cave; they retain masses, hardness and abundances. The existing drawer remains for
leather and maintains model/animation. The ammunition reuses CaelumArrowAmmo and its icon.
The Bull retains its art; Palomo runs with PALM B/C and waits with A. No art, audio,
models or poses are generated or modified. Stations only change placement and interaction
saves. There are no files of assets in this delta because their contents maintain 0m
footprints.

## Fiber shrub 2D (4.33.0l)

Actor CaelumFiberBush; twenty copies around the entrance of MAP01. Billboard with real
transparency, without MODELDEF. In 0m: 0,05 scale, radius 20 MU, height 48 MU, estimated
aerial mass 10 kg (SYSTEMS.md). PNGs are not retouched. CaelumTreeEnvironmentProp
extraction is reused, with fiber as output.

- Source: `assets/source/art/ca_fiber_bush.png`. PNG RGBA 1430×1100, generated with the
  integrated image generation tool of OpenAI, new image mode from text.
- Runtime: `src/sprites/caelum/world/CFBHA0.png`. Keep exactly the pixels in the source and
  add only the PNG grAb (715,1018) chunk to support the stem on the ground.
- Creation prompt: a single fibrous wild shrub, frontal view for a dark-fantasy RPG/FPS
  sprite set in nineteenth-century Argentina; dense muted olive-green foliage with narrow
  leaves and pale straw stems, complete shrub, neutral lighting from upper left,
  semi-realistic painting consistent with the game trees/rocks, true transparent
  background, no text, no additional objects, no ground or rectangular shadow.
- The chosen version is the first generation with authentic alpha. The two subsequent
  tests with simulated transparency were discarded and not delivered.
- SHA-256 source: `efe14e3da2f2789c00cdf6cfdde9ae10655a75911b78570f239358d36ae936d0`.
- SHA-256 runtime: `83e902028d41dc5ba922489b831b311a85800f62ba98d63c1fddb67eecfc7b7a`.

The capture in GZDoom confirms readable silhouette, transparent background and support on
the floor. The supply chest inherits the model and animation of the existing stash; it
does not duplicate mesh, texture or sound. Station models remain accepted.

## Poses delivered by the author (4.33.0m)

Caelum_Argenteum_Poses_Agachados_v3.zip and Caelum_Argenteum_Poses_Descanso_v2.zip lying B
frames are integrated, which v3 maintained as a dependency. 280 PNG runtime are byte-for-byte
copies of deliveries: 256×256 RGBA, eight directions, offset grAb (128,244). A sitting
without a chair; B lying; C crouching idle; D/E/F/G crouching locomotion. No art is generated or
redrawn.

| Character | Prefix | Actor |
| --- | --- | --- |
| Rulo | RSRU | CaelumRulo |
| Ronnie | RSRO | CaelumRonnie |
| Argento | RSAR | CaelumArgento |
| Caella | RSCA | CaelumCaella |
| Domingo | RSDO | CaelumPlayer |

- Runtime: `src/sprites/caelum/rest/` with the five characters subfolders.
- Sources v3: `assets/source/art/poses_v3/`; masters and atlases of 15 set.
- Sources v2: `assets/source/art/rest_poses_v2/`; masters/atlases for the lying poses. A
  frames with v2 chair are replaced by A without v3 chair.
- PROMPTS, EXPORT, MANIFIESTO and VALIDATION originals are preserved as the source of each
  delivery. Describe your original exports; they are not the validation of this
  integration nor change the root assets/source/art.
- The general views and GIF review are left in the original artistic ZIPs; they are not
  duplicated within the runtime. README or TXT art is not added to docs.

States and game connection: SYSTEMS.md. The code retains the scales of each actor.
Sitting/crouching does not itself activate healing, camera or calendar.

## Current interface audio

| Action | Resource or alias | Treatment |
| --- | --- | --- |
| Open and progress dialogue | `caelum/ui/dialogue_open` → `sounds/caelum/ui/ca_dialogue_open.ogg` | `ca_stock_tarot_harp_loop.ogg` first phrase: 113.400 samples to 44.100 Hz (2,571429 s), stereo, Vorbis q5; drop of 450 ms to silence. GameInfo.ChatSound is the only emitter; singular avoid stacking phrases as you move fast. |
| Title / menu before starting | `sounds/caelum/stock/music/ca_stock_war_drums.ogg` | Full stock of 6 s; one playback, no loop, per front page entry. |
| Open/Close/Back/confirmation prompt | `caelum/ui/menu_open` | Native redirects activate, backup, prompt, dismiss and clear. |
| Move/Change Option | `caelum/ui/menu_move` | cursor, change and invalid. |
| Confirm/advance | `caelum/ui/menu_select` | Choose and advance. |
| Quit the game | `caelum/stock/menu_strings_start` | CaelumExitMenu plays the piece when opening the native confirmation. QuitSound and aliases remain as output coverage; singular avoids overlap. 4,0222 s stock is uncut. |
| Map Switch | `caelum/ui/menu_select` | switches/normbutn. |
| Map Exit button | `caelum/stock/menu_strings_start` | switches/exitbutn. |

MAP01 music retains CA_MUS01 and MAP02 CA_MUS02 music. Open the pause menu during a game
retains the music from that map. The original harp is preserved in its entirety; the
clipping is another file. Doom sounds are not imported.

### Current designations and emblems (4.33.0j)

At the author's request, TitleMusic points to the full War Drums of 6 s. The observer now
asks for loopless reproduction; the maps retain CA_MUS01/02. QuitSound and menu/quit1,
menu/quit2, switches/exitbutn use menu_strings_start. These files are not recoded or
trimmed. 2,571 s harp phrase and singular conversation protection remain as in 0h.

The four Caella runes reuse the Seals SLWA, SLFI, SLEA and SLAI emblems at 0,20 scale,
with state opacity. Their presentation of the riddle was accepted with the 0k tests. In 0m
the four remain lit after solving them and the wall retains its CMIN01 texture by enabling
the step.

## Simple station models (4.33.0j)

Accepted by the author in 0j. The 0m review retains all its files, textures and
associations; it also does not modify the accepted HUD or audio. Room cleaning removes
instances from the assortment, not graphic resources.


Twelve original OBJs, with eleven shared textures of 128×128, derived by procedural
geometry from the features of the twelve existing sprites. No external models or flat
sprites are used as a substitute for 3D tools. `src/models/caelum/props/stations/`
contains only runtime resources. `assets/generators/generate_station_models.py` retains
the source and reuses the primitives of environmental and chest generators (Python +
Pillow).

| Station | Silhouette and elements |
| --- | --- |
| Workbench | Table, bench vise, hammer, chisel and candle. |
| Forge | Masonry hearth with coal, fireplace and shovel; without table. |
| Anvil | An anvil of iron, horn and hammer upon stump; without table. |
| Ranged workshop | Table, bows, arrows, tool and template. |
| Sawmill | Bench with circular saw manual, handle, trunk and planks. |
| Armor workshop | Table, breastplate on a stand, leather and hammer. |
| Sewing machine | Table with machine, steering wheel, needle, reel and fabric. |
| Altar of essences | Stone pedestal, glass, hoop, candles and book. |
| Terrestrial globe | Globe on its own stand with brass rings and schematic map. |
| Jeweler's bench | Table, gems, mounted magnifying glass, tools and candle. |
| Fine tools | Table with cloth, open case, magnifying glass and tools. |
| Master bench | Table with drawers, tool panel, plans, book and vise. |

MODELDEF contains twelve models and an additional link from the old alias
CaelumBowWorkshopStation to the ranged-workshop model. It maintains sprites as an alternative if
the engine disables models. The scale compensates for the existing Scale 0.5; all meshes
fit in Radius 20 / Height 48. It does not change actors, recipes, capabilities, network
proximity or crafting times.

To regenerate from the root: `python assets/generators/generate_station_models.py`.
MODELDEF's generated block is replaced idempotently. Textures are the generator's own;
reference sprites retain their files and their source. No dependencies are added to the
builder or game.

The Seal indicator reuses its existing icon, including the tier, and applies native
desaturation when drawing it. It does not save another copy of the icon or modify its
pixels. It is verified with the OpenGL modern GZDoom 4.14.2 renderer.

## Terms of reference for interface resources

- Simple Harp Loop: Roloxi, Freesound #639113, CC BY 4.0. The musical excerpt, fade and re-encoding are documented in the redistribution record.
- lovelyboot1.ogg / menu_strings_start: pizzaiolo, Freesound #320664; also retain the
  attribution to humphreyswill, KorgStrings001.aif #61109, CC BY 4.0. The already approved
  file is used without modifying its bytes.

The full attribution, URLs and licenses remain in
[AUDIO_PACK_04_CREDITS.md](../src/licenses/AUDIO_PACK_04_CREDITS.md),
[AUDIO_CREDITS.md](../src/licenses/AUDIO_CREDITS.md) and
[AUDIO_PACK_05_CREDITS.md](../src/licenses/AUDIO_PACK_05_CREDITS.md). The license of a
third party is not rewritten when reorganizing documents.

## Physical audio inventory

The fully audited project contains 80 runtime files: 78 OGG and 2 MP3, including the new
cropping. The 05 package retains 10 external backup files that are not added to src. Total
catalogued: 84 files. A copy by another name does not imply another recording: menu_move
and menu_select continue to share content. 14 native interface/interruptors alias also do
not add files.

The following paths are related to src. The table records resources; the existence of a
file does not imply that there is already a climate or scene emitter.

| File | Allocation |
| --- | --- |
| `music/CA_MUS01.mp3` | MAP01 music. |
| `music/CA_MUS02.mp3` | MAP02 music. |
| `sounds/caelum/ambience/ca_ambience_blacksmith_loop.ogg` | Registered; use according to calls of actor, system or TERRAIN. |
| `sounds/caelum/ambience/ca_ambience_crowd_murmur_loop.ogg` | Registered; use according to calls of actor, system or TERRAIN. |
| `sounds/caelum/ambience/ca_ambience_fire_loop.ogg` | Registered; use according to calls of actor, system or TERRAIN. |
| `sounds/caelum/ambience/ca_ambience_fountain_loop.ogg` | Registered; use according to calls of actor, system or TERRAIN. |
| `sounds/caelum/ambience/ca_ambience_rio_waves_loop.ogg` | Registered; use according to calls of actor, system or TERRAIN. |
| `sounds/caelum/ambience/ca_ambience_sewer_water_loop.ogg` | Registered; use according to calls of actor, system or TERRAIN. |
| `sounds/caelum/enemies/mandinga/ca_mandinga_alert.ogg` | Registered; use according to calls of actor, system or TERRAIN. |
| `sounds/caelum/enemies/zupay/ca_zupay_alert.ogg` | Registered; use according to calls of actor, system or TERRAIN. |
| `sounds/caelum/enemies/zupay/ca_zupay_walk.ogg` | Registered; use according to calls of actor, system or TERRAIN. |
| `sounds/caelum/items/ca_item_pickup.ogg` | Registered; use according to calls of actor, system or TERRAIN. |
| `sounds/caelum/items/ca_weapon_pickup.ogg` | Registered; use according to calls of actor, system or TERRAIN. |
| `sounds/caelum/items/currency/ca_coin_pickup_01.ogg` | Registered; use according to calls of actor, system or TERRAIN. |
| `sounds/caelum/items/currency/ca_coin_pickup_02.ogg` | Registered; use according to calls of actor, system or TERRAIN. |
| `sounds/caelum/items/currency/ca_coin_pickup_03.ogg` | Registered; use according to calls of actor, system or TERRAIN. |
| `sounds/caelum/items/currency/ca_coin_pickup_04.ogg` | Registered; use according to calls of actor, system or TERRAIN. |
| `sounds/caelum/items/currency/ca_coin_pickup_05.ogg` | Registered; use according to calls of actor, system or TERRAIN. |
| `sounds/caelum/items/currency/ca_coin_pickup_06.ogg` | Registered; use according to calls of actor, system or TERRAIN. |
| `sounds/caelum/items/currency/ca_coin_pickup_07.ogg` | Registered; use according to calls of actor, system or TERRAIN. |
| `sounds/caelum/items/currency/ca_coin_pickup_08.ogg` | Registered; use according to calls of actor, system or TERRAIN. |
| `sounds/caelum/items/currency/ca_coin_pickup_09.ogg` | Registered; use according to calls of actor, system or TERRAIN. |
| `sounds/caelum/items/currency/ca_coin_pickup_10.ogg` | Registered; use according to calls of actor, system or TERRAIN. |
| `sounds/caelum/items/currency/ca_coin_pickup_11.ogg` | Registered; use according to calls of actor, system or TERRAIN. |
| `sounds/caelum/items/currency/ca_coin_pickup_12.ogg` | Registered; use according to calls of actor, system or TERRAIN. |
| `sounds/caelum/npcs/palomo/ca_palomo_disappear.ogg` | Registered; use according to calls of actor, system or TERRAIN. |
| `sounds/caelum/npcs/rulo/ca_rulo_alert.ogg` | Registered; use according to calls of actor, system or TERRAIN. |
| `sounds/caelum/player/anima/ca_anima_restored.ogg` | Registered; use according to calls of actor, system or TERRAIN. |
| `sounds/caelum/player/ca_low_health_heartbeat.ogg` | Registered; use according to calls of actor, system or TERRAIN. |
| `sounds/caelum/player/footsteps/ca_footstep_grass.ogg` | Registered; use according to calls of actor, system or TERRAIN. |
| `sounds/caelum/player/footsteps/wood/ca_footstep_wood_01.ogg` | Registered; use according to calls of actor, system or TERRAIN. |
| `sounds/caelum/player/footsteps/wood/ca_footstep_wood_02.ogg` | Registered; use according to calls of actor, system or TERRAIN. |
| `sounds/caelum/player/footsteps/wood/ca_footstep_wood_03.ogg` | Registered; use according to calls of actor, system or TERRAIN. |
| `sounds/caelum/player/footsteps/wood/ca_footstep_wood_04.ogg` | Registered; use according to calls of actor, system or TERRAIN. |
| `sounds/caelum/player/footsteps/wood/ca_footstep_wood_05.ogg` | Registered; use according to calls of actor, system or TERRAIN. |
| `sounds/caelum/player/footsteps/wood/ca_footstep_wood_06.ogg` | Registered; use according to calls of actor, system or TERRAIN. |
| `sounds/caelum/player/footsteps/wood/ca_footstep_wood_07.ogg` | Registered; use according to calls of actor, system or TERRAIN. |
| `sounds/caelum/player/footsteps/wood/ca_footstep_wood_08.ogg` | Registered; use according to calls of actor, system or TERRAIN. |
| `sounds/caelum/player/movement/ca_swim_loop.ogg` | Registered; use according to calls of actor, system or TERRAIN. |
| `sounds/caelum/player/progression/ca_level_up.ogg` | Registered; use according to calls of actor, system or TERRAIN. |
| `sounds/caelum/player/status/ca_player_cough.ogg` | Registered; use according to calls of actor, system or TERRAIN. |
| `sounds/caelum/stock/ambient/ca_stock_cricket.ogg` | Reserve without an assigned narrative event. |
| `sounds/caelum/stock/music/ca_stock_piano_progression.ogg` | Reserve without an assigned narrative event. |
| `sounds/caelum/stock/music/ca_stock_tarot_harp_loop.ogg` | Original conserved harp; source of the trimming. |
| `sounds/caelum/stock/music/ca_stock_war_drums.ogg` | Cover music, single playback (6 s). |
| `sounds/caelum/stock/ui/ca_stock_menu_strings_start.ogg` | Exit the game and Exit Map button (4,022 s). |
| `sounds/caelum/stock/ui/ca_stock_reveal_sting.ogg` | Reserve without an assigned narrative event. |
| `sounds/caelum/stock/voices/ca_stock_evil_laugh.ogg` | Reserve without an assigned narrative event. |
| `sounds/caelum/stock/voices/ca_stock_ghoul_laugh.ogg` | Reserve without an assigned narrative event. |
| `sounds/caelum/stock/voices/ca_stock_npc_mumble_male.ogg` | Reserve without an assigned narrative event. |
| `sounds/caelum/stock/world/ca_stock_iron_gate.ogg` | Reserve without an assigned narrative event. |
| `sounds/caelum/ui/ca_crafting_page_turn.ogg` | Registered; use according to calls of actor, system or TERRAIN. |
| `sounds/caelum/ui/ca_dialogue_open.ogg` | Opening and advancing conversations, first phrase of 2,571429 s. |
| `sounds/caelum/ui/ca_map_transition.ogg` | Prologue, transition and Exit. |
| `sounds/caelum/ui/ca_menu_move.ogg` | Movement/change of options. |
| `sounds/caelum/ui/ca_menu_open.ogg` | Opening/closing and return navigation. |
| `sounds/caelum/ui/ca_menu_select.ogg` | Confirm/advance and normal switches. |
| `sounds/caelum/ui/ca_recipe_learned.ogg` | Registered; use according to calls of actor, system or TERRAIN. |
| `sounds/caelum/weapons/ca_carabine_fire.ogg` | Registered; use according to calls of actor, system or TERRAIN. |
| `sounds/caelum/weather/ca_weather_rain_heavy_loop.ogg` | Registered; use according to calls of actor, system or TERRAIN. |
| `sounds/caelum/weather/ca_weather_rain_light_loop.ogg` | Registered; use according to calls of actor, system or TERRAIN. |
| `sounds/caelum/weather/ca_weather_rain_soft_loop.ogg` | Registered; use according to calls of actor, system or TERRAIN. |
| `sounds/caelum/weather/ca_weather_rain_steady_loop.ogg` | Registered; use according to calls of actor, system or TERRAIN. |
| `sounds/caelum/weather/ca_weather_thunder_distant_01.ogg` | Registered; use according to calls of actor, system or TERRAIN. |
| `sounds/caelum/weather/ca_weather_thunder_heavy_01.ogg` | Registered; use according to calls of actor, system or TERRAIN. |
| `sounds/caelum/weather/ca_weather_thunder_roomy_01.ogg` | Registered; use according to calls of actor, system or TERRAIN. |
| `sounds/caelum/weather/ca_weather_wind_loop.ogg` | Registered; use according to calls of actor, system or TERRAIN. |
| `sounds/caelum/world/doors/ca_door_large_open.ogg` | Registered; use according to calls of actor, system or TERRAIN. |
| `sounds/caelum/world/doors/ca_door_locked.ogg` | Registered; use according to calls of actor, system or TERRAIN. |
| `sounds/caelum/world/doors/ca_door_open.ogg` | Registered; use according to calls of actor, system or TERRAIN. |
| `sounds/caelum/world/fire/ca_fire_loop.ogg` | Registered; use according to calls of actor, system or TERRAIN. |
| `sounds/caelum/world/seals/ca_quintessence_seal_activate.ogg` | Registered; use according to calls of actor, system or TERRAIN. |
| `sounds/caelum/world/seals/ca_quintessence_seal_deactivate.ogg` | Registered; use according to calls of actor, system or TERRAIN. |
| `sounds/caelum/world/weather/ca_rain_loop.ogg` | Registered; use according to calls of actor, system or TERRAIN. |

### External 05 package reserve

External audio reserve that **does not enter the PK3**: 10 files live in
`assets/audio_stock/pack05/` until they are assigned an approved event. The following
routes are related to `assets/audio_stock/pack05/`.

| File | Work/author | Proposed use, not yet allocated |
| --- | --- | --- |
| `sounds/music/ca_stock_piano_short_loop_01.ogg` | Piano short loop — Roloxi | Diegetic piano of living room, fonda or mansion; confirm tonal fit before assigning. |
| `sounds/horror/ca_stock_breath_stinger_01.ogg` | breath stinger1 — Tissman | Spectral proximity, curse or drain of anima; does not substitute for the already chosen low-health signal. |
| `sounds/reactions/ca_stock_slow_clap_01.ogg` | man claping slow — Wicopee | Slow theatrical applause for Palomo, Mandinga, an audience or a cinematic. |
| `sounds/voices_en/ca_stock_demonic_you_died_en.ogg` | you died.ogg — nfsmaster821 | Demonic voice in English; reserved for a prototype or creature who canonically speaks English. |
| `sounds/props/ca_stock_toilet_flush_01.ogg` | Toilet Flush — andersmmg | Discharge or tank; use only if the sanitary device is consistent with location and time. |
| `sounds/music/ca_stock_piano_loop_02.ogg` | Piano loop — Roloxi | Piano of living room or mansion; keep as diegetic music until defining the scene. |
| `sounds/music/ca_stock_creepy_piano_stinger_01.ogg` | Terrible Piano — TheFlakesMaster | Disturbing piano for haunted mansion, omen or discovery. |
| `sounds/creatures/ca_stock_monster_scream_01.ogg` | Monster Scream - V2 — Roloxi (adaptation); Thanra (source CC0) | Screaming of generic monster or elite; not assigning a named creature without proving identity and mixture. |
| `sounds/ui/ca_stock_triumph_jingle_01.ogg` | Triumph (jingle) — lightbulbafagd | Achievement, completed mission or increased reputation; does not replace the recipe sound already chosen. |
| `sounds/music/ca_stock_dark_chords_01.ogg` | Dark Chords — Scrampunk | Omen, ritual or dark transition. It is synthesized, so it is not automatically integrated with the instrumental preference of the project. |


## First person: accepted sword reference

### Scope

The modular view continues to be connected exclusively to `CaelumSwordSelectorWeapon`, the
real sword equipped from the Inventory. There is no special test weapon or a second damage
or lock path.

The author successfully completed the entire `PRUEBAS_4_32_0o.txt` matrix; this
composition is therefore closed as a reference. Later, the same modular approach will be
applied to all weapons, with art and movement specific to each family. The extension to
the other weapons remains pending and does not reopen the already accepted proofs of the
sword.

V4.32.0o retains the height, full thumb, and trajectory of V4.32.0n, but corrects the box
showing two fists. The above code calculated the pivots with the full size of the PNG;
GZDoom applies `PSPF_PIVOTPERCENT` to the visible box of each texture. As `RHND`, `DSWD`
and `RFNG` have different alpha boxes, the two complementary representations of the same
hand were separated when turning. The new percentages compensate those boxes and cause the
three transformations to solve the actual pivot already used by the sword. It does not
modify sprites, damage, Air, cooldown, durability, sounds, persistence, equipment, HUD,
maps, economy, Palomo or dialogues.

### Framing by state

| State | Shield (10) | Left hand (20) | Right hand/fingers (25/40) | Sword (30) |
| --- | ---: | ---: | ---: | ---: |
| Rest | X=82, Y=45 | X=82, Y=45 | X=282, Y=32 | X=260, Y=0 |
| Held Block | X=160, Y=100 | X=160, Y=100 | Hidden | Hidden |

At rest, shield and left hand continue together in the accepted lower left mark. Right
palm and thumb remain in (282,32). The blade passes from (260,4) to (260,0), so it goes up
slightly without changing its approved horizontal record.

### Frontal block, close and held

The Block does not change with respect to V4.32.0m. H remains a short transition of three
tics and I uses `-1` duration, fixed until the actual status of Block ends. The shield and
its correct hand remain in the 10 and 20 layers to (160,100); the right-hand layers
25/30/40 are cleaned to avoid a second hand. When Block is released, the right set is
rebuilt immediately.

`DSHDI0` Export retains 450×300, `grAb (225,48)` and a visible 293×244 box. `LHNDI0`
shares canvas and origin and retains its visible 213×169 box. No change in perspective,
size, height or equipment condition.

### Full Thumb in front of Handle

`RFNGA0` and `RFNGB0` keep RGBA 320×200 and `grAb (160,32)` canvas, but the front mask now
includes all the visible thumb that already exists in the `RHND` hand layer. The A
extension adds exactly 443 pixels visible with the original Domingo color: 413 also
retains its exact alpha and 30 reduce only the alpha on the smoothed edge of the mask. Do
not repaint or displace any pixel that already belonged to `RFNG`. B is the same exactly
displaced pose (+1,+1), as it happens between `RHNDA0` and `RHNDB0`.

The inclusive alpha box passes to (148,92)–(210,151) in A and (149,93)–(211,152) in B.
Thus, the handle is behind the entire thumb and no longer appears to cut the finger.

### Synchronised turn without duplication

The sword retains exactly its accepted pivot and movement. For hand and thumb, the
percentages are calculated on its actual alpha boxes, not on the transparent canvas. The
result of each row, after compensating `grAb` and the hand-sword displacement (-22,-32),
is the same display point (56.64375,84.57):

| Layer | Box alpha A / size | Percentage pivot | Effective PNG point | Common screen point |
| ---: | --- | ---: | ---: | ---: |
| 25 `RHND` | (147,128)–(479,239) / 333×112 | (0.2091403904, 0.2550892857) | (216.64375,156.57) | (56.64375,84.57) |
| 30 `DSWD` | (168,0)–(294,178) / 127×179 | (0.55625, 0.83) | (238.64375,148.57) | (56.64375,84.57) |
| 40 `RFNG` | (148,92)–(210,151) / 63×60 | (1.0895833333, 0.4095) | (216.64375,116.57) | (56.64375,84.57) |

The `RFNG` X exceeds 1 because the shared point is just outside its visible box; the
engine allows percentage pivots outside the 0–1 range. The compensation keeps the three
matching anchor pixels to the maximum turn and eliminates the duplicate fist silhouette.

The blade retains its absolute angles. The hand and thumb receive only the variation with
respect to rest: `rotación_mano = rotación_espada - 18°`. Thus, the art of the hand does
not change at rest and during the attack accompanies both the position and the turning of
the sword without losing the grip. The total delta of the hand goes from 0→25° between
rest and impact.

| Moment | Absolute blade angle | Hand/thumb | Approximate visual angle |
| --- | ---: | ---: | ---: |
| Rest | 18° | 0° | 79° |
| Outward 1 | 21° | 3° | 82° |
| Apex | 24° | 6° | 85° |
| Sweep 1 | 31° | 13° | 92° |
| Sweep 2 | 38° | 20° | 99° |
| Impact | 43° | 25° | 104° |
| Return 1 | 39° | 21° | 100° |
| Return 2 | 31° | 13° | 92° |
| Return 3 | 24° | 6° | 85° |
| Rest restored | 18° | 0° | 79° |

Each value is absolute and reapplies during synchronization; it does not accumulate
between tics.

### Attack curve and straight return

The eight tics continue to reuse pose A. Five points carry the hand through the approved
curve to impact and three colinear points return it in a straight line. The sword keeps
the constant record (-22,-32) at all times with respect to palm and thumb translation:

| Tic | Phase | Hand/fingers X,Y | Sword X,Y | Blade / hand |
| ---: | --- | ---: | ---: | ---: |
| 1 | Outward | (300,15) | (278,-17) | 21° / 3° |
| 2 | Right apex | (318,-4) | (296,-36) | 24° / 6° |
| 3 | High sweep | (287,-1) | (265,-33) | 31° / 13° |
| 4 | Approximation | (236,11) | (214,-21) | 38° / 20° |
| 5 | Left impact | (201,21) | (179,-11) | 43° / 25° |
| 6 | Return 1 | (228,25) | (206,-7) | 39° / 21° |
| 7 | Return 2 | (255,28) | (233,-4) | 31° / 13° |
| 8 | Return 3 | (275,31) | (253,-1) | 24° / 6° |
| — | Rest | (282,32) | (260,0) | 18° / 0° |

The uniform four-unit rise affects only the blade; it does not alter the curve of the hand
or the straight return already accepted.

### Panoramic sleeve, depth and equipment

`RHNDA0` and `RHNDB0` retain the RGBA 480×240 canvases with `grAb (160,72)` accepted in
V4.32.0h. The sleeve reaches the right end of the canvas and does not reveal an internal
cut in 16:9.

| Layer | Prefix | Content | Rule |
| ---: | --- | --- | --- |
| 10 | `DSHD` | Back of the shield | Only with valid shield equipped |
| 20 | `LHND` | Shield hand/arm | Visible with shield, including Block |
| 25 | `RHND` | Forearm, palm and base of the fist | Hidden in Block; behind the sword outside Block |
| 30 | `DSWD` | Sword | Hidden in Block; passes through the grip outside Block |
| 40 | `RFNG` | Thumbs and closing fingers | Hidden in Block; in front of the handle outside it |

`HasActiveBlockSource()` remains the only visual condition on the shield. If it is
unequipped, broken or no longer supported, `DSHD` and `LHND` disappear in the next tick.
Without a valid shield, neither the shield nor Block is enabled.

### State of evidence

The automatic audit checks ZScript structure, narrowed delta, RGBA dimensions, `grAb`
offsets, alpha boxes, hashes, exact thumb enlargement, A→B scrolling, common screen pivot,
synchronized rotation, record (-22, -32), correct block and reproducible ZIP source
content. The visual matrix of `PRUEBAS_4_32_0o.txt` was successfully completed by the
author. This composition is accepted as closed reference. The 0h delta does not change its
art files, states, trajectory, damage or Block.

## Equipment icons

Author-provided source: `Caelum_Argenteum_tiers_2_3_argentinos_REHECHOS.zip`.

4.33.0d incorporated its 99 PNG without modifying its bytes, dimensions, proportions,
transparency or names: 49 variants T2, 49 variants T3 and `ca_giant_gauntlets.png`
corrected. Includes weapons, armor, gloves, boots, helmets, shields, amulets and seals.

Destination: `src/graphics/caelum/icons/`, preserving `jewelry/`. The existing icon solver
selects `_t2` and `_t3`; the files replace their previous versions in the inventory,
equipment, trade and menus that use that resolve. They are not first-person hands/sword
rig frames.

Each PNG is RGBA 128×128 and has transparent alpha and visible content. The audit compares
99 files against attachment bytes and against full runtime. The manifest and author
instructions are preserved in `assets/source/art/tiers_2_3_rehechos_4_33_0d/`.

The T2/T3 Argentine ornaments and the corrected pair of gauntlets replace the previous
icons. Statistics, values, recipes, weights and mechanics do not depend on this graphic
import.

## Typography and artistic direction

Nineteenth-century Argentina, semi-realistic dark fantasy, earthy and metallic tones.
Preserve ornament perspective, the Sol de Mayo and the insignia according to the equipment
location. First-person expansion requires dedicated art and movement for every family;
icons do not replace those animations.

The typographical functions are CaelumDisplay (titles), CaelumText (reading), CaelumSmall
(helps) and CaelumMono (containers/debugging). Keep cells with common baseline, Spanish
coverage and DejaVu license where applicable. The main menu uses real text. GZDoom 4.14.2
sets NewSmallFont from OptionMenu from gzdoom.pk3: the current MENUDEF improves spacing,
but this font should not be declared substituted just by including an alias.

## Traceability and Next Assets

The old ASSET_REGISTER and the typographical records are complete in HISTORY.md. They are
dated inventories, not proof that all old assets are still in use. Current distribution
notices are still in src/licenses. The T2/T3 icons incorporated in 0d are accepted; the
remaining first-person views and visual content of future sewers are still pending. Do not
recover placeholders Doom when rebuilding packages.

## Historical source material

Sources that are not packaged in the PK3 and that are preserved only as historical origin,
to audit decisions and allow re-editing art if the author so requests. They come from the
`assets/` audit registered in `archive/audits/assets-audit.md`.

### `assets/source/art/domingo_fp_4_32_0h|0i|0j|0n/`

- **Route:**`assets/source/art/domingo_fp_4_32_0h/`, `..._4_32_0i/`, `..._4_32_0j/` and
  `..._4_32_0n/`.
- **Content:**First person origins of Domingo (hands, grips and generation prompts), moved
  to `source/art/` in the 4.33.0h review.
- **Associated review:**4.33.0h (see `docs/HISTORY.md`, 4.33.0h input).
- **Note:** 16 files, ~1,32 MB. They are preserved as historical origin; they do not enter
  the PK3.

### `assets/first_person_v3/`

- **Path:** `assets/first_person_v3/`.
- **Content:** origin of first-person corrections of 4.36.0e (`README.md`, `PROMPTS.json`,
  `PROVENANCE.json` and `SPRITES.json`); their internal README describes them.
- **Associated review:**4.36.0e.
- **Note:** 4 files, ~0,01 MB. The v1 series, v2, v4, v5, v6 and v7 is cited in
  `ASSETS.md`; v3 was omitted by mistake. It remains as historical source; it does not
  enter the PK3.

## Sources and generators after the 4.33.0h audit

20 files from `art_source/` pass in full to `assets/source/art/`. Names, subfolders and
fingerprints are preserved: original hands/shields, prompts and icon inventory document
decisions and allow re-editing art. Rejected iterations are not therefore converted into
current resources. `assets/source/world/` retains the environmental master atlas;
`assets/audio_stock/` retains the 05 package, its checksums and its source. It does not
load that reservation into the PK3 without assigning it a use.

Three reusable generators move from tools to `assets/generators/`:

| Generator | Utility and Dependency |
| --- | --- |
| generate_environment_models.py | Models/textures of rocks and trees and their records; Python 3 and Pillow. |
| generate_mineral_veins.py | Models/textures and vein logs; Python 3, Pillow and the environmental generator of the same directory. |
| generate_stash_models.py | Models and textures of caches; standard Python 3 library. |

Their default paths are resolved from the project, even if they are invoked from another
folder. `--help` displays configurable destinations. Generating resources is a deliberate
editing operation, independent of compiling or playing; generators are not executed when
applying the patch. The build packages only src. The previous patch-specific utilities
are left in the historical backup.
