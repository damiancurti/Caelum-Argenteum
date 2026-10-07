# Caelum Argenteum — Audio and art

Documentation version: **5.1.0** — 2026-10-07.

## 5.1.0 — Thermal validation sources (#130)

`assets/validation_510` contains deterministic isolated map/PK3 generators,
native test sources, raw logs/settings, source/package fingerprints, drying
calibration, migration/rollback tooling and English/Spanish UI captures.
Generated maps, gameplay packages and saves stay in ignored `build/issue130`;
neither development IWAD nor engine is distributed. No new art/audio is added
and no recipe material is reinterpreted from appearance. Physical references
and authored calibration are distinguished in SYSTEMS. Optional fire markers
require explicit power and physical dimensions; existing decorative sprites
do not imply a rating. Unrelated local source-art deletion is excluded.

## 5.0.6 — Normal high-density AI evidence (#128)

`assets/validation_506` contains deterministic isolated trial generators,
native runners, raw logs/configuration, summaries and source/package records.
Fixtures, generated packages and saves remain under ignored `build/issue128`;
they are not game assets. No IWAD or engine is distributed. The patch changes
normal AI code and records the author's policy in the existing port data notes;
it changes no map, artwork, sound, attribution or asset license.

## 5.0.5 — Siege profiling evidence (#121)

`assets/validation_505` contains diagnostic ZScript, deterministic package
preparation, native launch/collection scripts, source verification, timing
summaries, logs/configurations and captured game views. These are development
evidence and remain outside `src/`. Engine-source references are pinned to
GZDoom `g4.14.2`; locally inspected source copies, generated PK3s and saves stay
under ignored `build/issue121`. No engine, IWAD, art/audio source or extracted
Doom asset is added to the distribution. Existing asset provenance is retained.

## 4.37.24 — Reproducible closing export (#82)

No new artwork or redistributed development dependency is introduced. The
closing export uses build_playtest.py and committed blobs, fixed ZIP metadata,
stored entries and complete SHA-256 coverage. assets/playtest/EXPORT.json records
the current issue, three-map route and first-start configuration; the launcher
and default_controls.cfg are included beside the PK3. The engine, IWAD, saves,
QA fixtures, personal INIs and optional source generators remain excluded.

The accepted #17 / 4.36.28 archive and its provenance remain historical evidence.
The new source revision, package/archive hashes, native captures and exact-content
verification belong to assets/validation_43724. Local export is authorized;
external Release/tag publication is not part of this delivery.

## 4.37.23 - Character-creation text and layout (#112)

The existing native ListMenu and project fonts use a two-column layout on the
accepted 600-high adaptive canvas. Content is capped at 1040 logical pixels,
with 32-pixel outer margins; the left portion holds choices/point rows and the
right portion wraps contextual text. Font fitting uses actual font metrics,
keeps descriptions inside the panel and leaves separate help/navigation rows.
All twelve attributes remain visible while navigating and allocating points.
The menu retains the existing background and adds no raster asset.

LANGUAGE is the authoritative text source: 37 new contextual keys have English
and Spanish equivalents. Base-class and profession labels reuse existing
localized names. A single profile combination function drives the second-step
labels, descriptions and summary. The author allowed general, concrete wording
consistent with implemented rules; planned abilities remain visibly qualified.
Native captures, wrapping checks, inputs and qualifications are retained in
assets/validation_43723. No development IWAD or test fixture enters the PK3.

## 4.37.22 - Equipped first-person shield artwork (#106)

Kite, tower and magic shields now use their own inward-facing artwork in the
shared native presentation. The round shield's DSHD and LHND source PNGs remain
byte-identical. Its accepted rest (82,45), block (160,100), three-tic H and held
I framing is retained. The old sword rig remains available for saved states;
its methods are no longer the active playable renderer. Before this patch the
shared weapon controller cleared that rig and the HUD displayed world icons
only during block; adding states to the old sword alone would not implement #106.

The three original 1536 x 1024 RGBA sheets live in
`src/graphics/caelum/first_person/shields/`. Each has two inward-facing poses:
three-quarter idle and frontal block, with a left forearm strap and right grip.
They reference the existing type-specific icons and the accepted round shield.
The original left glove/bracer is reused independently, never painted twice.
Kite retains its tapered blue-edged wood, tower its broad rectangular iron/wood
back, and magic its faceted blue crystal and aged gold rim.

On 2026-10-05 the author explicitly accepted the sprites and their positions,
then requested slightly muted colors. Native TEXTURES applies the existing
greatsword palette (Desaturate 20, multiply RGB 205/198/188) to these three sheets;
it does not repaint their silhouettes, grips or alpha, or recolor the broquel.
`assets/first_person_shields/COMPOSITION.json` holds sheet coordinates, grip
registration, source references, timing and palette. Its deterministic generator
`assets/generators/generate_first_person_shields.py` updates only its marked
TEXTURES fragment. The source sheets are generated artwork, not reproducible AI
outputs; deterministic regeneration concerns their fixed native registration.
PROMPTS.json and PROVENANCE.json retain the built-in image_gen instructions,
reference/source hashes and rights. Only runtime sheets, generated TEXTURES entries and shared code enter the PK3.

The author extended #106 on 2026-10-05 with giant-gauntlet blocking artwork: a
boxer guard with the elbows closed and both hand edges protecting the front.
Three original guard PNGs in `src/graphics/caelum/first_person/gauntlet_guards/`
reference the existing T1-T3 gauntlets, retaining their bronze/orange, iron/red
and brass/pale-rune identities. They use the same muted treatment. Native
GGB1-GGB3 states replace only the held-block pose on layer 50; original rest
and attack images and gameplay remain untouched. The guard follows actual
block-source validity, survives loading and ends on cancellation/breakage.
Composition, source hashes and GAUNTLET_PROMPTS.json preserve this extension.

Author revision, 2026-10-05: the initial guard was too thin. Its three source
PNGs were revised using the original B/C attack fists as proportion references.
The inventory icon also appeared to have three hands; new T1-T3 sources in
`src/graphics/caelum/gauntlet_icons/` show exactly two detached closed fists.
Native TEXTURES replaces the existing icon names at the same logical 128x128
size, with the same muted palette, and updates the shared CGAUA0 pickup image.
Original small icon PNGs remain available; no unrelated asset is deleted.
GAUNTLET_REVISION_PROMPTS.json records this correction. Initial gauntlet
captures remain historical evidence; gallery_revised.html shows the revision.

Native layers 44/45 hold body/left hand. Existing 46-53 weapon layers are cleared
only during real shield block, then restored by their normal controller. The
type comes from FindActiveNativeShield, with existing compatibility and model
durability checks; giant gauntlets remain their own block source. Unequipping,
broken/boxed/missing items and incompatible weapons clear the accessory. The
unarmed renderer replaces its free left fist when holding a usable shield.
Raising/lowering follows the native weapon position, idle A/B loops every eight
tics, attack accompaniment lasts eight, and H transitions in three to indefinite
I. Switching types refreshes both layers together. Menus, rest and death use
the existing view-visibility conditions. Transient caches rebuild on load.

All T1-T3/XS-XL items share one set per type. Shield proportions express shape,
not new coverage or physical size statistics. Lower edges intentionally continue
below the viewport like the accepted round shield; top edges and the grip remain
visible at 4:3, 16:9 and 21:9. Evidence and qualifications:
`assets/validation_43722/RESULTS.json`. The author accepted CA-43722-SHIELD-ART-01 on 2026-10-05: sprites, positions
and final muted palette, based on the comparison captures. Aspect-ratio and
transition checks remain agent engine evidence. CA-43722-SHIELD-PLAY-01 also passed by explicit author confirmation on
2026-10-05; no #106 author check remains pending.

The author accepted the revised gauntlet guard and two-glove icons on 2026-10-05
(CA-43722-GAUNTLET-ART-01). Manual gameplay confirmation also passed on 2026-10-05.

## 4.37.21 - Approved narrative artwork sources and presentation (#103)

The author supplied assets/art_source/Caelum Argenteum.png for the README
banner on 2026-10-04. Its exact bytes are retained there and copied to
assets/branding/github_banner.png. This title-bearing variant supersedes
the plain first illustration in the issue's original banner mapping.

Both unmodified 1672 x 941 embedded originals are also retained: slide 1,
ppt/media/image.png, becomes assets/branding/cover_original.png; slide 3,
ppt/media/image2.png, becomes assets/branding/intermission_exit.png. Slide 2
has no illustration. The local source is
Caelum_Argenteum_Biblia_Narrativa_v1_0.pptx in the author's Documentación folder;
PROVENANCE.json records its hash and the individual image hashes. Extraction
copies ZIP member bytes, without rendering slide text, cropping or re-encoding.
The deck is an art source only and supplies no new narrative canon.

The artwork belongs to Damián Curti's project under LICENSE.md. The sole runtime
copy is src/graphics/caelum/narrative/intermission_exit.png, byte-identical to the
second original. GZDoom draws it centered with uniform fit and letter/pillarbox
bars, never stretching or cropping. Existing Caelum fonts, silver framing and a
dark overlay keep text legible; type scales to fit one page in both languages.

The author's final request supersedes the initial reservation for future scenes:
show one typewriter page only after the creator, with manual reveal/advance,
approved welcome/awakening and current controls/survival. Play the former MAP01
track CA_MUS01 there; preserve MAP01's CA_MUS02 and the port's completion cue.
There is no fixed presentation duration, new track, audio edit or sound default.

The same illustration is used for the native quit question and confirmed
farewell. MessageBoxClass delegates every unrelated message box to its base.
The retained handler owns QuitSound and shutdown; CaelumExitMenu still starts
the existing 4.0222-second unmodified strings cue when opening the main-menu
question. TitlePage/CreditPage and all licenses remain unchanged. Native ENDOOM
requires exactly 4000 bytes of text/attributes, so GameInfo Endoom is empty and
the full-color farewell runs before shutdown. See CA-KP-038 and validation_43721.
Direct native quit/quick exit can bypass the picture; no Doom text follows.
The author accepted artwork/intro/exit and save checks on 2026-10-04 without
reported qualifications; the three test IDs and results are recorded in HISTORY.

## 4.37.20 - Original training mannequin model (#98)

Inspected the project's existing 48 x 72 CDMYA0 sprite before modeling. The
new volume preserves its articulated chestnut/oxblood body, aged brass joints,
colored concentric targets on head/chest/wrists/shins and round plinth. The
original sprite and TEXTURES declaration remain intact as provenance and the
native fallback when models are disabled. No external art or Doom asset is used.

Editable part coordinates, material palette, target colors, seed and native
bindings live in assets/training_dummy/DESIGN.json. The deterministic Python
generator assets/generators/generate_training_dummy_model.py is the editable
mesh/texture source, using the established environment Mesh container. Its OBJ
and PNG outputs are also directly editable. PROVENANCE.json records ownership,
source hashes, tool version and reproduction. Pillow 12.1.0 is an optional
editing dependency; neither Pillow nor a generator is needed to build or play.

Runtime assets: src/models/caelum/actors/training/ca_training_dummy.obj and
ca_training_dummy.png. One 512 x 256 RGB atlas, one material surface, 3,384
triangles and 8,152 exported position/UV entries; no animation or extra actors.
Continuous spherical UVs and restrained painted relief make the parts readable
under sector lighting. Target discs sit outside the curved body without
coplanar overlap. The material surface stays below the native limit (CA-KP-020).

OBJ axes are X width, Y height, positive Z front. Geometry reaches Y=0..70,
with a maximum horizontal radius of 18.65. Scale 1 / 1 / 1.2 with
CorrectPixelStretch compensates MAP01's native height transform (CA-KP-023),
inside the unchanged Radius 21 / Height 72. Native front is map south at actor
angle zero. MODELDEF explicitly binds CaelumTrainingDummy and its practice
subclass CaelumM00TrainingDummy to CDMY A; Spawn and Death already use that
same frame. There is no camera-facing flag and no new hit/recovery animation.

Run `python assets/generators/generate_training_dummy_model.py` from the root;
`--runtime-root` selects an isolated src copy. Only the generated MODELDEF block
and the two model resources are rewritten. Two runs reproduce identical bytes.
Native views, impact/state tests and old-save evidence: assets/validation_43720.
The author accepted art, practice and save checks on 2026-10-04; see HISTORY.

## 4.37.19 - Existing necklace assets and shield localization (#96)

The reward uses the existing CaelumAmuletPickup catalogue and sprites for
Ruby, Sapphire, Emerald and Topaz T1. Existing Caelum fonts, native conversation
panels and acquired-item feedback present its choice, delivery and recipe
lesson. Shield dialogue labels use CA_SHIELD_TYPE_* directly; names in preview,
confirmation and summary share FormatShieldName with inventory. No external
art, audio, new item sprite or attribution is added. Native presentation and
bilingual evidence are recorded under assets/validation_43719.

## 4.37.18 - Journal subsection presentation (#91)

Craft, Repair and Dismantle reuse the existing `ca_ui_action_craft.png`,
`ca_ui_action_repair.png` and `ca_ui_action_dismantle.png` in the Journal icon
set. Their silver/gold frames, laurel selection, Caelum fonts and native C moon
pointer come from the accepted UI assets; no new external art or attribution
is introduced. All seven main sections retain their icons. Selected rows,
bounded wrapping/scrolling and distinct Tarot effect labels use those fonts.
Native bilingual resolution/scale captures: assets/validation_43718.

## 4.37.17 - Pickaxe art and gathering audio (#89)

The author's updated reference ZIP, all seven verified source files and its
credits/SHA-256 list are retained under assets/issue89_pickaxe/reference_package.
[PROVENANCE.json](../assets/issue89_pickaxe/PROVENANCE.json) records the package
URL/hash, built-in imagegen prompt, selected transparent image and processing.
The isolated hybrid tool preserves the left axe blade, opposite mining point,
wooden shaft and wrapped grips. Deterministic Windows sprite preparation creates
the inventory/pickup icon and first-person body; native textures turn the head
for mining. The existing project hand rig and attack clock provide ready,
wind-up, strike and recovery without introducing independent attack timing.
Author refinement: the resting tool tilts 20 degrees clockwise around the
existing grip; the hand remains aligned and the native swing uses that pose.

Audio: Joseph SARDIN / BigSoundBank **Ax on log (0705)** and NoisyRedFox /
Freesound **760565/760566/760567**, all supplied as CC0. Chopping uses only the
first 0.120–0.900 s impact with 4 ms endpoint fades; original gain/rate retained.
The three mining OGGs are copied byte-for-byte for stone/coal, crystal/gems and
metal ore. Packaged credits: src/licenses/AUDIO_GATHERING_ISSUE89_CREDITS.md.
The superseded HerrParadox/Pixabay MP3 is not included. The image's OpenAI
provenance is separate from the audio licenses; no CC0 image dedication is made.
Generators are optional; native assets are already under src. Native playback,
waveform checks and subjective author audio acceptance are recorded separately.

## 4.37.16 - Compass, Sun of May and C moon (#87)

Sources, exact generator inputs and generation prompts are preserved under
[assets/ui_compass_cursors](../assets/ui_compass_cursors/PROVENANCE.json).
The built-in image-generation tool adapted the project's TITLEPIC moon and
generated a Sun face. The final Sun uses only that face: deterministic SVG
geometry supplies exactly 32 alternating rays (16 straight, 16 wavy). The
compass rose uses original vector geometry and reuses the project's Sun.
No Doom imagery was copied.

Author refinement, 2026-10-04: silver laurel branches surround a beveled
dark-metal dial; the same 32-ray Sun sits behind the needle at 42% opacity.
The laurels are mirrored SVG paths with silver relief gradients. Editing the
existing vector generator introduces no new image-generation input. SPEC.json
also records measured CaelumMono glyph bounds used to center the letters.
Updated captures: assets/validation_43716/compass_refinement. Previous captures
remain as evidence of the original delivery, superseded for compass appearance.

Run assets/generators/generate_ui_compass_cursors.py with resvg-py==0.5.0 to
reproduce the SVG/PNG outputs. The pinned rasterizer is an optional editing
dependency; packaged outputs require no Python library. The two 24px fallback
selector frames and their 128px TEXTURES overrides share one Sun. The moon
uses a transparent 32x32 PNG with grAb hotspot (31,7), respecting GZDoom
4.14.2's native Windows cursor size limit. Its source silhouette is an AI
adaptation of the logo, not a pixel-identical crop. Ownership/provenance stays
with the project; reference and output hashes are recorded in PROVENANCE.

Native captures and limitations: assets/validation_43716. Physical mouse
click/drag was initially interrupted by Escape; the author confirmed all
checks passed on 2026-10-04.

## 4.37.15 - Traditional Truco card reuse (#101)

Traditional Truco reuses the existing Tarot front/back resources without new
or edited art. Its 40-card subset maps Page/Sota to Spanish 10, Knight to 11,
and King to 12. Physical deck ownership and original art provenance remain
unchanged. The runtime mapping excludes 8/9/10/Queen Tarot ranks and all Majors.

## 4.37.13 — Trucazo source and existing card presentation (#81)

The practice menu reuses the approved 78-card Tarot fronts/back and Caelum
fonts. No card art, models, maps, audio, attribution or generators change.
Minor identities remain Sword/Cup/Wand/Coin blocks of 14, with Knight before
Page in stored indices; displayed strength follows the approved Truco ranking.

The author's supplied `DOCUMENTO 12 - trucazo.docx`, headed Trucazo v2.0, is
preserved byte-for-byte at
[assets/design_sources/trucazo_v2_original.docx](../assets/design_sources/trucazo_v2_original.docx).
Original local source: the author's `Caelum Argenteum/Documentación` directory;
SHA-256 `a326583696714f4dad6938b1ba85b7e09f60f6096012e413d8353ce0fbc8b4d9`.
This is historical author design evidence, including unresolved future Major
effects; the corrected current contract is in SYSTEMS and HISTORY. The source
contains 416 body paragraphs, no actual Word tables/media or tracked edits.
It was read without modifying its contents or producing a replacement Word file.
Native screenshots/log excerpts are in assets/validation_43713. Engines, IWADs,
saves and isolated QA fixtures stay local and are not distributed.

## 4.37.11 — Existing guard presentation and bilingual recognition (#79)

Guard recognition reuses the existing Barracas al Sud defender appearance,
localized soldier name and native conversation menu. No art, audio, model,
map, attribution or generator changes. New dialogue/Journal text lives in
LANGUAGE; four USDF pages are appended without shifting earlier saved pages.
Focused native captures and evidence are in `assets/validation_43711`.
Development IWADs, executable files, saves and isolated fixtures are not distributed.

## 4.37.10 — Existing prisoner dialogue presentation (#78)

No visual/audio assets, models, sprites, maps, fonts or attributions change.
The existing CAPALOMO pages keep their ordering and IDs; added presentation tags
select shared bilingual briefing text from `src/LANGUAGE`. Existing menu metrics,
prisoner appearances and Unknown Voice audio/presentation are reused. Native
captures and focused test records live in `assets/validation_43710`; development
IWADs, binaries, saves and isolated test fixtures are not distributed there.

## 4.37.9 — Expanded urban geometry and save-layout provenance (#77)

assets/map06_port/CITY.json owns the 960 × 960 m city, 288 classified
constructions, fortified passages, wall walk, access stairs and four towers.
SOUTH.json owns the sixfold populations, gun/ram/formation placements, southern
retreat and physical crew routes. LAYOUT.json retains the accepted shared
parameters and original northern deployment for legacy layouts; generated
CaelumPortData resolves the current map marker without rewriting saved armies.
The #77 author-approved command_group_limit of 100 lives in LAYOUT.json and is
emitted as COMMAND_GROUP_LIMIT; it changes neither map geometry nor population.
The subsequent combat follow-up retires enemy_attack_resource_trial (0) and
adds no art or map changes. COMBAT_RECOVERY.json in the same south evidence
directory records source/package hashes, native checks and three live runs.

generate_port_city.py builds houses with native roofs/windows, shop awnings and
counters, factory halls/chimneys, and four stages of exposed foundations,
brickwork, stored materials and timber staging. generate_map06_port.py packages
the authored map and shared data. Existing CMST/CVCI/CVPO/CASWR materials and
native 3D floors are reused; no new third-party art, engine asset or license is
introduced. The original harbor buildings, props, prisoners and piers remain.
MAP07 and the other map WADs are unchanged by this follow-up.

The compact coastal writer omits identical-cell internal edges before allocating
them and places control sectors in a separate bounded grid. This keeps the
larger MAP06 deterministic without changing the default MAP07 generation path.
Control sectors never overlap the southern battlefield or playable city.

legacy_4378 preserves the exact previous siege port from f4429c543db89062376a9f620deba4ba4439d989.
legacy_4379_north preserves the first published city from 83b6b115e7456c585c142a91144c229175cfc999,
including its byte-identical MAP06 hash 8b88438a0905d0f42665c47e5793dfaa79fd2b824e810a987d1f4eeae7e1fadf.
Both directories retain SHA-256 provenance. The builder replaces only the chosen
MAP06 WAD and rejects conflicting port modes before replacing the package.
No engine, IWAD or diagnostic fixture enters src or the development PK3.

validate_map06_city.py checks final dimensions/counts, real cannon floors,
control-sector separation, original port contents, exact legacy hashes and
two byte-identical generations. Available static evidence and failed live-run
records are in assets/validation_4379/south. Original first-iteration evidence
is preserved separately. The author confirmed all expanded-layout/manual checks
passed on 2026-10-03, including visual acceptance; performance testing continues
in #86 without changing the previous measured results.

## 4.37.8 — Supply ledger provenance and verification (#75)

No art or geometry changes; diagnostic release labels advance to 4.37.8.
Preserve the original
assets/validation_4376/MATERIAL_LEDGER.json as historical evidence.
assets/validation_4378/MATERIAL_LEDGER.json corrects its material-to-instance
join by stable catalogue ID, retaining original positions, quantities, size
policy and aggregate totals. Original and current native inputs match.

assets/generators/validate_map02_supplies.py checks WAD/manifest assignments and
the corrected ledger; optional native logs also verify crafting completion and
persistence. Reproduce the submitted audit with:

    python assets/generators/validate_map02_supplies.py --recipe-log assets/validation_4378/native_recipes.log --route-log assets/validation_4378/native_supplies_persistence.log

validation_4378 retains SUPPLIES.json, MUTATIONS.json, DETERMINISM.json,
RESULTS.json and two sanitized successful native logs. Eleven negative cases
include the historical positional join despite its correct aggregate.
Two isolated generator runs reproduce all four current files exactly; all
6,141 tested PK3 members match the pre-label source; final startup checks
validate the release-label update. No development IWADs, engine binaries,
saves or test fixtures are distributed. Earlier local fixture failures and
their diagnosed limits are listed in RESULTS; author acceptance stays separate.

## 4.37.7 — Layered sewer return geometry (#74)

assets/map02_maze/LAYOUT.json revision 4 owns lower elevations, width, water
depth, path coordinates, four grate tags/sides, platform footprint and speed.
generate_map02_maze.py deterministically emits MAP02.wad, the manifest and
CaelumMazeLayout.zs together. The manifest separates upper and lower collision
cells and records exterior activation sides; LOWER_NETWORK.png in
assets/validation_4377 diagrams the six pits, connected ring and both landings.

Native solid 3D floors retain the surface above overlapping tunnels. Separate
swimmable controls provide the existing shallow water. Grates lift only the
lower face of their solid 3D floor, keeping the upper landing fixed. The lift
uses native Floor_MoveToValue at the existing MAP01 speed of 16. Detached control
polygons remain outside all playable geometry. Upper map-thing heights account
for the lowered base floor, preserving their original world coordinates.
Lower paths avoid every upper gate and all nine original crusher sectors,
including an explicit eastern detour around crusher 43923.

Existing CASWR stone/iron, CAPOOL01 water and CMGT02 barred materials are reused;
there are no new third-party resources or changed attributions. Revision-3 WAD
and manifest snapshots are preserved in assets/map02_maze/legacy_4376 from
baseline 5c55bb26; the author waived compatibility rather than requesting a new
launcher mode. Development fixtures, engine and IWAD are not packaged.

## 4.37.6 — Cardinal sewer data and supply ledger (#73/#75)

LAYOUT.json revision 3 is the source of the four block origins, entry nodes,
central start, furniture and reserved elevator footprint. The deterministic
generator writes MAP02.wad, MAP02_MANIFEST.json, CaelumMazeLayout.zs and the
equipment-to-recipe catalogue together. The manifest retains the 65 original
instance identities as conversion provenance, and publishes finite drop assignments.
No new art, sound, equipment balance or enemy combat profile is introduced.
assets/validation_4376/MATERIAL_LEDGER.json contains native per-instance/per-size
recipe expansion; LAYOUT.png labels the map and key graph. The old geometry is
recoverable from baseline commit 3f0b7cea; the author waived old-save migration.


## 4.37.5 — Existing food plates and water cups (#65)

Daily provisions reuse CaelumFoodRation, CaelumWaterRation and the existing table
plate/cup displays. There are no new assets, generators, geometry or attributions.
Palomo's existing LANGUAGE entries explain midnight replenishment. Isolated
fixtures, logs, screenshots and results live in assets/validation_4375; only
src/ is packaged. Local engine/IWAD dependencies, test saves and baseline PK3s
are excluded from delivery.

## 4.37.4 — Existing Journal assets for time skipping (#64)

The new bilingual destination panel reuses the existing Journal frame and fonts;
there are no new art, sound, map, generator or third-party resources. LANGUAGE
owns its English/Spanish text. assets/validation_4374 contains isolated native
fixtures, launch/verification tooling, filtered logs and screenshots. Only src/
is packaged. Development IWADs, executables, test saves and baseline packages
remain local and are excluded from delivery.

## 4.37.3 — Existing equipment catalogue and bilingual Palomo dialogue (#63)

No new art, audio, map geometry, generators or external resources. Palomo uses
the existing actor, route and native USDF presentation. LANGUAGE owns the new
English/Spanish explanations; native models supply numeric item quotes. The
new conversation is appended to CAPALOMO, preserving all original conversation
page indices for saves. Retired Ronnie choice page slots remain as referrals.
assets/validation_4373 contains isolated fixtures, filtered native logs, static
checks and GZDoom screenshots; it is not packaged. Development IWADs, engine
binaries, private saves and baseline packages are excluded from delivery.

## 4.37.2 — Magic-cost balance data and evidence (#68)

No art, audio, map or generated asset changes. Existing core constants own the
reduced 50/70/100/100 staff/book/bell/statuette bases. The existing Type 4 curve
and native combat assets remain. Isolated fixtures reuse the accepted #62
support fixture; assets/validation_4372 contains evidence, never runtime content.

## 4.37.1 — Reused practice target and bilingual directions (#62)

No new art, audio, model, map or generator output. Caella reuses the existing
CaelumM00TrainingDummy and its CDMY sprite in the mansion practice room; the
authoritative position/bounds remain assets/map01_mansion/PRACTICE.json and its
generated runtime data. English/Spanish LANGUAGE strings explain the two spell
hits and separate Seal/Anima demonstrations. Native fixtures and evidence live
in assets/validation_4371 and are never included in the runtime PK3.

## 4.37.0 — Mansion landscape and filled tympana (#61)

All materials are reused project assets; no external art or Doom asset is added.
Terrain reuses CMGR01A. The sixteen decorative ceibos reuse ca_tree_coast_ceibo,
ca_tree_coast_ceibo2 and ca_tree_coast_ceibo3 OBJ meshes with their existing
1/0.75/1.25 scales, bark/foliage textures and corresponding collision dimensions.
Twenty-four decorative shrubs reuse CFBHA0 at its accepted 0.05 scale.
Actor-only scenery classes keep these additions outside the harvesting system.
The placement manifest excludes the pool with a 128-MU margin and requires the
original exterior ground sector. Static and native checks cover dry placement
and the absence of vegetation throughout the pool, including its submerged area.

Four original deterministic tympanum meshes cover 64/128-MU widths and 20/28-MU
gaps. A closed six-face stone backing seals the entire opening; the filled
triangular/segmental field appears on both sides. CMST03 supplies the stone;
UV selection uses only the plaster portion of CMIN03. Original PNGs are unchanged.
Each mesh groups its faces into two material surfaces, retaining CA-KP-020's
engine limit. Fixed models add no collision, light, sound or interaction.
A fifth original mesh closes the top-door roof-front gap using the existing
CMEX01 material. mansion_door_gable.py derives its contour from the preserved
roof planes and starts above the ceiling slab to avoid overlapping its front.
mansion_exterior_partition.py bounds the large outer floor for correct rendering;
its flat sectors reuse the original grass and light without introducing art.

EXTERIOR.json owns authoring data. generate_map01_exterior.py reads the preserved,
hashed accepted MAP01_43628.wad and invokes mansion_tympana.py for mesh/model/editor
bindings. EXTERIOR_GENERATED.json records every terrain triangle, added plant,
door group and output hash. Regenerate this current map with the #61 generator;
repair_map01_mansion.py remains the historical #36 reconstruction source.
validate_map01_exterior.py is read-only. The normal builder packages existing
outputs without requiring generators. Evidence is in assets/validation_4370;
the author accepted CA-4370-MANSION-01 on 2026-10-01.

CAVE.json and mansion_decorative_cave.py add the requested northeast cave.
Native sloped sectors form its grassy mound; solid native 3D floors support
the walkable roof above the tunnel. Rock surfaces reuse CACVROCK, backed by
the project's rock_granite.png. Five Actor-only classes reuse existing ruby,
sapphire, emerald, topaz and opal vein models at half scale. They inherit no
resource behavior and add no external material, sound or story. The generated
report includes roof controls, cave sectors, placements and camera/route data.
The follow-up divides the distant exterior into 25 regions; no new art is used.
The author accepted CA-4370-CAVE-01 on 2026-10-01.

CONTROL_RELOCATION.json and mansion_control_relocation.py relocate 69 original
detached auxiliary polygons that intersected or touched the playable horizon.
Only their 276 vertex positions change, into an unused grid at (-8000,31000).
Sector planes, heights, tags, lighting, materials and control actions remain
byte-equivalent as parsed records; no visual asset is added. The independent
validator checks isolation, non-overlap and preservation. CONTROLS.json records
native evidence; CA-4370-EXTERIOR-01 is author-accepted on 2026-10-01.

The northern-station follow-up changes no map or art. Runtime relocation now
recognizes original stations resting on sloped ground, preserving all eighteen
original actors within the intended 38 interior stations. STATIONS.json holds
native evidence. The author accepted CA-4370-STATIONS-01 and all remaining
checks on 2026-10-01, authorizing #66 merge/#61 closure. Art and map bytes remain
unchanged in the acceptance update.

## 4.36.28 — Playtest resource packaging (#17)

The export preserves committed src bytes and all existing attribution notices.
assets/playtest/EXPORT.json reviews the runtime map allowlist; build_playtest.py
adds no visual/audio replacements. The ZIP contains no engine, IWAD, raw stock,
source archive or development test fixture. licenses/ is available both inside
the PK3 and beside it. Root LICENSE.md retains the project's reserved rights.

2026-10-01 author report: marjaja197 is a different person who authorized the
author to use The Argentine Omen in the project. This is author-reported
permission, not a CC0 grant or an assertion that Damián owns the track.
The author also confirmed that PhatPhrogStudio #503867 and 53439420 #451598 were
downloaded under the Pixabay Content License and authorized their inclusion
integrated into this playtest under that license. Source URLs and creator names
remain in AUDIO_ISSUE_31_CREDITS.md. This is author-confirmed provenance; an
independent automated query of the official page was blocked by its website.
Existing cannon overall dimensions remain historically unverified and the
sleeping-bag icon reuses fabric artwork. The current-content export does not
claim to resolve those inherited limitations or certify every visual.

## 4.36.27 — Port battlefield and reused defenders (#16)

The deterministic generate_map06_port.py extends the existing coastal port from
assets/map06_port/LAYOUT.json, emitting MAP06 and CaelumPortData.zs. Existing
buildings, docks and rescue placements are retained. Six ram gates and twelve
raised gun platforms use accepted textures/models and native stairs. The exporter
compacts shared sector edges and reindexes only used sides/vertices; MAP07 is not
regenerated. The exact 4.36.26 MAP06 is preserved under
assets/map06_port/legacy_43626/MAP06.wad for the explicit legacy build option.
Its SHA-256 is 5ae44d61f8d29342c16c6ef8a98308be98b92c02643e585c14cb986106d453b8.

All 100 defenders reuse Domingo's existing DOID/DOWK/DOMI sprites and scale;
there is no new character art or attribution change. Their combat equipment is
the existing T1 sword, kite shield and medium armor; the reused artwork is not
redrawn to depict that inventory. Gates, rams and cannons retain accepted sources
and the documented approximate cannon reconstruction, not a new historical claim.
generate_cannon_runtime.py --data-only regenerates the changed reload data without
requiring the optional Pillow art pipeline. Existing image/model generation remains.
Screenshots and native checks are under assets/validation_43627/integration.

## 4.36.26 — Grip-centered thrust motion (#37)

The author specified dagger Fire and machete/sword/greatsword/halberd AltFire:
30 units down, a counterclockwise grip rotation aimed at the center of the
320×200 weapon plane, 60 units forward along that line, then a return to rest.
Confirmed timing: 16/16/48/20 percent of the effective attack duration; impact
at 80%. Blade-axis metadata is measured from the existing art; runtime alignment
uses the existing 1.2 vertical aspect correction. Both hands and all weapon
segments retain their relative offsets while rotating. Dagger now uses native
modular bindings for its existing F011/F012/F013 art and existing hand layer.
No raster source, attribution, palette or externally owned asset is replaced.
First-person animations use the accepted attack's full clock instead of the old
eight-tic cap or a second magic animation after release. Existing charge/reload
presentation rules remain separate. Native poses for all five weapons are
recorded in assets/validation_43626. The author confirmed CA-43626-THRUST-01
passed on 2026-09-30, accepting the visual motion and framing.
Runtime sources: CaelumAttackRules, CaelumFirstPersonLayers, CaelumFirstPersonView
and TEXTURES. The pre-existing first_person_v1/v3/v4 sources remain preserved.


## 4.36.25 — Mansion architectural finishes (#36)

The author approved aged render, wooden shutters, ornamental iron and discreet
interior reliefs after reviewing native proposal views on 2026-09-28.
The principal heritage reference is the official Museo y Monumento Historico
Nacional Justo Jose de Urquiza article,
[Historia del edificio](https://museourquiza.cultura.gob.ar/noticia/historia-del-edificio/),
consulted 2026-09-28. It documents the 1848-1860 stages of Palacio San Jose:
symmetrical fronts, galleries, wooden openings, iron grilles, classical cornices,
ornamental ironwork and decorative sculpture. These support the vocabulary;
the reference's courtyard plan and largely flat roofs are not claimed as a match
for MAP01's stepped storeys and pitched tiled roof. For an 1889 setting, this
is a plausible stylized historicist mansion, not an authenticated replica.

All image sources already belong to the project's mansion/environment catalogues.
CMEX01 supplies exterior render, CMIN01 interior wallpaper, CMIN03 upper plaster,
CMST03 stone fascia/lintels, CMRLBAL the existing iron guards and CMRF01 the
unchanged roof tiles. Native TEXTURES compositions add CMWIN36 (CMEX01 plus
CMDT04 closed wooden shutters), CMPLS36 (the plaster portion of CMIN03), CMPNL36
(CMDT02 ornamental relief at half scale) and CMLMSKY (the already used CVCI02
source with a uniform dark tint). Original PNGs are unchanged. Shutters are
decorative closed surfaces, not new traversable windows. The two reliefs are
wall-mounted, nonblocking decorative planes; no new statue or gameplay actor
is introduced. Website photographs/textures are not copied into the game.

The author follow-up replaces repeating CMWIN36 map faces with finite CMSHT36
panels (the same CMDT04 source, half scale) above explicit sills. CMWIN36 remains
defined for provenance. The flat upper ceiling uses the existing CMCL01 art.
The new ca_mansion_door.obj extracts the original left leaf from
ca_siege_gate_intact.obj, preserving its station wood/iron and stash-inside
materials and UVs, resized from 48x96 to the existing 64x120-MU mansion leaf.
The right leaf rotates the same model to put its hinges/handle on the correct
edges. generate_mansion_doors.py and assets/map01_mansion/DOORS.json reproduce
the adaptation using only the Python standard library. No new bitmap source,
external model, siege balance or destructibility is introduced.

The 2026-09-29 correction groups those 222 opaque faces into three material
surfaces. Emitting usemtl before every face exceeded GZDoom 4.14.2's 32-entry
surface-skin limit and could select invalid textures during rendering. All
vertices, face winding, material assignments and UVs are retained and checked
against the siege source. See CA-KP-020 for engine references and reproduction.

Geometry is generated deterministically by assets/generators/repair_map01_mansion.py
from assets/map01_mansion/REPAIR.json and the preserved, hashed 4.36.24 WAD.
GENERATED.json identifies every new guard, wall material assignment and relief.
The latest central-room layout uses the same wood model and interior wallpaper;
no new art is introduced. Native views and checks are in assets/validation_43625. Visual-direction
approval was followed by author acceptance of the remaining prior work on
2026-09-29. The latest fixed door directions and target relocation reuse all
existing art. DOORS.json contains the four authored swing sides (including Caella/908);
PRACTICE.json and generate_mansion_practice.py provide the new target placement
and detection bounds. Follow-up checks are in assets/validation_43625/furnishing; the latest Caella
door check is in assets/validation_43625/caella. No new art was added. The
author confirmed all #36 tests passed on 2026-09-29, including this final change.

## 4.36.24a — Rights and attribution (#55)

Root [LICENSE.md](../LICENSE.md) reserves the author's rights in original
project materials to the extent owned. It does not relicense external assets,
public-domain materials, GZDoom or development dependencies. Existing
`src/licenses/` notices and the provenance records below remain applicable;
previously pending external-license verification remains pending.

## 4.36.24 — Quest journal labels (#35)

No new art, audio, maps, fonts or generators. The existing Journal panel and
navigation present type/status filters and persistent completed records.
`src/LANGUAGE` adds English/Spanish category, empty-state, sewer and rescue
labels; `CaelumQuestCatalogue` supplies stable title keys and classifications.
Native 1280×720 and 1024×768 captures in assets/validation_43624 show the
existing fonts and layout. These are development evidence, not author acceptance.

## 4.36.23 — Armor presentation (#52)

No new art, audio, models, maps or generators. Gate attribute revision changes
only balance data and its existing proportional-save migration. Existing debug/equipment text
shows fractional physical/magical defense from shared runtime data. The
2026-09-28 revision reports a per-hit retained fraction for subtractive Toughness;
collision diagnostics show its uncapped L*(L+1)/101 percentage, not the raw level. English
and Spanish Ronnie guidance describes magical protection instead of removed
Intelligence/Patience/Insight bonuses. Existing attribution and licenses remain.

## 4.36.22 — Existing dialogue presentation (#34)

No new art, models, music or voice recording. The bilingual original script is
maintained in `src/LANGUAGE`, with native USDF pages in `src/CAPALOMO`. Existing
dialogue-opening audio, fonts and non-pausing menus are reused. Selene keeps
the established Unknown Voice label and has no visible actor representation.
The approved Tarot art and single capture/presentation path are unchanged.
An isolated native screenshot and rendered-menu evidence are retained in
assets/validation_43622; engine/IWAD binaries and disposable saves are not shipped.

The same-patch MAP02 correction registers existing elemental CELHA0 through
CELHL0 PNGs via appended native projectile states. There is no new art or changed
provenance: runtime lookup of an otherwise unregistered CELH returned -1.
Both NPC projectile variants share the resulting global registration.

## 4.36.20 — Shared Arcana presentation (#33)

The accepted #15 artwork is reused without raster edits: Fool ID 0 keeps
graphics/caelum/tarot/ca_tarot_fool.png, Ace ID 36 uses ca_tarot_36.png and
Knight ID 60 uses ca_tarot_60.png in that same directory. TEXTURES binds CACU
and CAWK using the existing CFLF front dimensions, offsets and scale.
Their essence actors also register those fronts in appended RevealedFront
states so the engine prepares the sprites before their first rendered use.
CaelumTarotArt supplies each front/name; the existing CTAR back and the Fool's
single animation, reveal cue and capture cue are shared. Attribution and the
78-card manifest remain intact. No new powers, art or siege assets are added.

## 4.36.17 — Approximate Argentine 1884 cannon reconstruction (#21)

The issue originally required corroborated exact dimensions of the Argentine
Krupp 75 mm field gun manufactured in 1884. Accessible evidence did not establish
a complete original technical specification. On 2026-09-26 the author explicitly
authorized an approximate documented reconstruction instead. This supersedes
the exact-scale requirement for this patch; it does not certify the estimates.
Existing accepted #18 gallery meshes remain intact as historical resources.
New separate carriage, closed/open wedge-breech tube, inert round and brief
muzzle-flash meshes are deterministic original project geometry generated by
generate_cannon_runtime.py, reusing the project's attributed station materials.

Sources and uncertainty:

- The [Landships discussion and museum photographs](https://landships.activeboard.com/t45639328/krupp-75mm-guns-in-argentina-and-other-ww1-pieces/?page=1)
  describe the original 1884 iron carriage and horizontal sliding wedge, with
  later breech alterations. L/25.6-before-shortening/L/23 claims conflict with
  other L/24 identifications; this is not an authoritative original drawing.
- The [Bulgarian Artillery technical compilation](https://www.bulgarianartillery.it/Bulgarian%20Artillery%201/Krupp%2075mm%201886.htm)
  describes a DIFFERENT Krupp M1886/L27: 300 kg tube, 550 kg carriage, 850 kg in
  action, 1.528 m track, and a 4.3 kg /185 mm common shell including a 100 g
  bursting charge. These are comparison values, not verified Argentine data.
  The author approved the game's inert 4.3 kg projectile using that dimensional
  comparison. It is not a claim that the referenced live shell was inert.
- The issue's Zona Militar page was inaccessible behind an interactive web
  challenge during this research. Its issue summary was not promoted into
  independently verified engineering data. No museum/archive specification
  matching all required inputs was located.

Reconstruction input table (32 MU/m):

| Quantity | Game model | Evidence level |
| --- | --- | --- |
| Bore/projectile diameter | 75 mm = 2.4 MU | Selected caliber; author-approved round |
| Inert round length/mass | 185 mm = 5.92 MU /4.3 kg | Author-approved approximation from comparison |
| Tube length | 1.8 m = 57.6 MU | Approximate reconstruction, not certified L/24 designation |
| Wheel diameter | 1.35 m = 43.2 MU | Approximate reconstruction |
| Wheel track | 1.528 m = 48.896 MU | Comparison-based estimate |
| Trunnion height | 1.05 m = 33.6 MU | Approximate reconstruction |
| Axle-to-trail/muzzle | 1.6 /1.25 m = 51.2 /40 MU | Approximate reconstruction |
| Machine/tube/carriage mass | 850 /300 /550 kg | Comparison-based estimates; excluded from projectile damage |
| Muzzle velocity | 500 m/s | Author final decision 2026-09-27, superseding 400 m/s; not historical measurement |
| Complete cycle | 30 s (two operators), 60 s (one) | Author game decision, not sourced historical cadence |

The carriage is iron with wooden wheels and a steel tube/wedge; precise alloy,
wall thickness and component density are not independently established here.
Render and collision use the same authoritative dimensions. The original
project meshes, transparent sprite bindings and existing project textures
require no imported museum photographs, Doom sprites or sound effects.
The flash is an original fullbright mesh, not explosive projectile damage.

## 4.36.16 — Ram components and reference-based estimates (#20)

The operational ram splits the accepted #18 construction into independent
frame, moving member and suspension meshes. `generate_ram_runtime.py` imports
the original generator without regenerating its gallery; `ram_state` retains
its previous complete-output default. New CRFR/CRHD/CRSP bindings move with
their native actors. Original preview meshes, sprites, materials and provenance
remain available, including old saves. The larger ram scales render and native
collision together; no cannon art is changed.

References consulted 2026-09-26:

- [Battering ram](https://en.wikipedia.org/wiki/Battering_ram): the historical
  wheeled wooden superstructure, suspended timber, metal head and bands;
  Vitruvius is cited there for the wheeled suspended construction. This is a
  secondary construction reference, not a measurement of a particular machine.
- [English oak, The Wood Database](https://www.wood-database.com/english-oak/):
  average dried weight 42 lb/ft³, reported as 675 kg/m³. The supplied SI value
  is used directly; moisture and species variation remain uncertainty.
- [Iron](https://en.wikipedia.org/wiki/Iron): density near room temperature
  7.874 g/cm³ = 7,874 kg/m³, approximating the historical iron fittings.

The small reconstruction retains #18's 112 MU (3.5 m) log, radius 11 MU
(0.34375 m), and sixteen-sided geometry. Its head is represented as a solid
iron frustum, a solid striking plate and three hollow strengthening bands;
the six handles are wood. This particular solid-head interpretation is a
reconstruction estimate, not a verified surviving ram. Polygon/frustum/box
volumes times the listed densities yield 888.265373 kg wood plus
1,986.725328 kg iron = 2,874.990701 kg moving mass. It is deliberately kept
distinct from the frame, wheels, suspension supports and operators.

The large machine scales lengths by (32/6)^(1/3), giving equal moving mass per
assigned operator; this is an explicit geometric estimate for the fictional
32-demon machine, not a historical crew-to-size law. Small frame envelope is
150 x 84 x 91.5 MU (4.6875 x 2.625 x 2.859375 m). Transport mass is a coarse
beam/wheel/axle estimate with overlapping members and filled wheel voids; it
is not an exact mesh integral and never affects strike damage. Suspension
inertia, timber moisture and joinery are not simulated. The demonic strike
speed is an author-approved game decision, separated from the real material
densities and historical construction reference. No historical cadence or
37.78 m/s mechanical performance is claimed.

`assets/generators/ram_physics.json` preserves assumptions/source URLs;
`assets/validation_43616/ram_inputs.json` records generated inputs, units and
estimates. Runtime constants are generated into CaelumRamData, shared by
render/collision/operation. SYSTEMS defines control, impact and proximity rules.

## 4.36.15 — Gate mechanics reuse accepted art (#19)

CaelumBreakableGate owns a separate CaelumSiegeGate/Reinforced/Armored visual
and finite hidden collision blocks. Existing meshes, textures, sprite frames,
MODELDEF mappings and provenance are unchanged. Intact, first-damage and broken
states select the accepted #18 models; temporary Use opening reuses the open
Broken pose. The optional MAP03 trial activates only the three intact gallery
examples. No new art, debris, sound or historical cannon-scale claim is added.
The author-approved gate masses and derived attributes are documented in SYSTEMS.

## 4.36.14a — Siege silhouettes and gate materials (#18 correction)

The author's 2026-09-26 correction replaces the fence-like gate with two solid
leaves, fixes the duplicated left jamb, and separates plain wood, iron-strapped
wood and exterior iron-clad armor. Every material has Intact/Damaged/Broken
states; Broken presents the two leaves open at 82 degrees. Damage is shown as
surface scars, retaining the closed silhouette. Opening remains a visual pose.

`assets/generators/siege_visuals.json` is the visual input manifest for
`generate_siege_models.py`. Outputs are 16 OBJ files, 16 transparent state
frames, the guarded MODELDEF block and the nine gate gallery placements.
The legacy `CaelumSiegeGate`/`CAGT` names remain plain wood; additions are
`CaelumSiegeGateReinforced`/`CAGR` and `CaelumSiegeGateArmored`/`CAGA`.
One independent MODELDEF block per frame binds one model slot: slots represent
simultaneous parts, so the old multiple-slot layout incorrectly overlaid states.

The gate opening uses #18's explicit proposed 3 m × 3 m reference, at 32 MU/m:
96 × 96 MU, two 48 MU leaves, 2.56 MU wood, and 0.192 MU outer iron cladding.
It is reference geometry, not a new final campaign dimension or mass approval.
OBJ X is width/forward, Y is up, Z is depth/lateral; actor angle zero retains
that placement with OBJ Y mapped to world Z. Gate hinges are (±48, 0, 0)
in OBJ coordinates; the frame bounds are X ±56, Y -2..104, Z ±6 MU. The sill
is flush with the floor. Open leaves swing toward positive OBJ Z and leave
the central passage clear. The solid actor collision for future mechanics is
not implemented; all gallery actors remain nonblocking, including intact ones.

The cannon gains hollow 75 mm bore geometry, a stepped steel barrel, trunnions,
open spoked wheels, a tapered trail and a visible sliding breech wedge. Recoil
translates the entire carriage, avoiding a modern sliding-barrel appearance.
The inherited overall cannon dimensions remain provisional: exact dimensions
for the selected Argentine 1884 Krupp are still unverified. A 75 mm bore does
not verify carriage scale, historical breech details, mass or ammunition type.

The ram gains A-frame supports, diagonal braces, paired iron suspension rods,
spoked wheels, log bands, handles and a broad iron striking face. Its log/head
assembly translates rigidly in the three poses instead of changing length.
OBJ contact center is (34 + travel, 44, 0) MU; travel is a preview pose offset,
not a physical velocity or gameplay reach. Suspension anchors and provisional
dimensions live in the manifest. This remains the small preview resource;
large-machine engineering and historical cannon verification belong to #20/#21.

All mesh work is original project geometry and reuses the existing station/stash
textures; no new raster art or external resources were imported. Existing class
names, state labels and sprite frames are retained for saved actors. New gallery
placements appear on fresh MAP03; an existing saved gallery is not respawned.
The author confirmed `CA-43614A-SIEGE-ART-01` passed on 2026-09-26; original
acceptance is retained. The same follow-up removes remaining MAP03 furniture
and crafting stations at runtime without deleting models or changing the
approved siege meshes. Existing saved galleries retain their siege layout.

## 4.36.10 — Reusable siege preview assets (#18)

Issue #18 adds project-owned, reusable siege preview meshes only; it adds no
gameplay, mass, damage, reload timing or gate hardness. The deterministic
generator `assets/generators/generate_siege_models.py` writes ten OBJ meshes to
`src/models/caelum/siege` and one transparent 1x1 frame each for `CSGN A-D`,
`CRAM A-C` and `CAGT A-C` in `src/sprites`. It reuses the muted station
materials (`ca_station_iron.png`, `ca_station_wood.png`, `ca_station_brass.png`,
`ca_station_cloth.png`, `ca_station_stone.png`) and the stash interior material
from the existing accepted prop sets, so no new external artwork is introduced.

`src/MODELDEF` gains a guarded, reproducible `CAELUM SIEGE MODELS` block with
three actors:

- `CaelumSiegeCannon` (`CSGN`): Ready/Loading/Firing/Recovery.
- `CaelumSiegeRam` (`CRAM`): Ready/Strike/Recovery.
- `CaelumSiegeGate` (`CAGT`): Intact/Damaged/Broken.

The runtime preview actors live in `src/caelum/world/CaelumSiegeAssets.zs`. On
MAP03 they are spawned as a visual gallery only, after the trial chairs, dining
tables and cots are retired. The generator's scale and orientation are
provisional until the author reviews the live preview and the physics/ammunition
data in issues #19-#21; the generated meshes and sprite frames are the current
source of truth and can be regenerated byte-for-byte by running the generator
from `assets/generators`.
## 4.36.8 — No new runtime assets (#14)

Issue #14 adds prisoner release/escort/port-reward logic and dialogue but no new
runtime art: the four MAP02 prisoner actors reuse the #13 recolored sprites and
the accepted mansion combat profiles. No source artwork, generator or TEXTURES
block changes in this patch.

## 4.36.7 — Recolored prisoner sprites (#13)

`assets/generators/generate_prisoner_sprites.py` deterministically reuses every
accepted mansion actor pose (idle, chase, combat and rest) for Caella, Ronnie,
Rulo and Argento. It recolours only the assigned hair/fur/cloak/cloth
materials and writes the four muted per-faction ramps to
`src/sprites/caelum/prisoners/{unitario,federal,bestia,tarot}/` and appends one
guarded `CAELUM_PRISONERS_V2` block to `src/TEXTURES`. No source artwork is
changed; every output preserves source alpha and shading while skin, metallic
accessories and explicitly kept cloth retain their RGB and only the assigned
materials map through the per-material ramps

The palette mapping and representative before/after sheet are in
`assets/validation_4367/` (`PALETTE_MAP.json`, `RESULTS.json`,
`before_after.png`); `PALETTE_MAP.json` records each faction's `material_policy` and `primary`/`secondary` ramps. Original Caella/Ronnie/Rulo/Argento sprite and TEXTURES
definitions remain untouched. Native GZDoom before/after views and the author
visual check remain separate.

## 4.36.5 — Wider sewer and barred gates (#11)

`assets/map02_maze/LAYOUT.json` supplies the deterministic layout dimensions,
counts and collision rationale to `assets/generators/generate_map02_maze.py`.
The generated WAD, manifest and `CaelumMazeLayout.zs` are maintained together.
The 4.36.4 T1 catalogue and stable chest IDs/assignments remain intact.

Barred gates reuse project-owned `graphics/caelum/textures/mansion/CMGT02.png`
through its existing TEXTURES definition; its transparency is real, and native
line flags provide the keyed collision. Existing masonry/posts remain visible.
Overhead service conduits reuse `models/caelum/props/stations/ca_station_iron.png`
through the new `CASWRPIP` texture alias. Bricks, stone and water retain CASWRWAL,
CASWRFLR and CAPOOL01. No image regeneration or external/Doom artwork is added.
Existing furniture and station assets are reused without balance changes.

`assets/map02_maze/legacy_4364/` preserves the original WAD and manifest for
explicit saved-campaign compatibility. The builder checks the original WAD's
SHA-256 before selecting it; normal src packaging remains the new map. No save,
IWAD, executable or test fixture is included. Before/after native views and
verification belong to `assets/validation_4365/`.

## 4.36.4 — T1 maze catalogue

Issue #10 updates the deterministic MAP02 generator, generated loot catalogue
and manifest together. The new 65-entry T1 catalogue declares recipient-based
size policy for size-bearing equipment; it is not a conversion of 195 entries
into duplicate T1 pieces. All existing chest locations, map geometry, traps,
enemies and provision quantities remain unchanged. No artwork is regenerated.
The expanded runtime chest preview and feedback use existing UI/font assets.
The original 0i evidence remains historical; current coverage and verification
belong to `assets/validation_4364/` and HISTORY.

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
from the author's 2026-09-23 pass confirmation for CA-4360I-VISUAL-01.

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
CA-4360I-VISUAL-01 was partial pending that flail correction. The separate
empty-bow equip stall (#8) is a runtime defect, not a rejection of the
accepted bow art; its 4.36.2 correction and evidence are described above.
The correction is implemented in 4.36.3 above and passed on the author's
explicit confirmation on 2026-09-23; the original partial result is in HISTORY.

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
| Open dialogue | `caelum/ui/dialogue_open` → `sounds/caelum/ui/ca_dialogue_open.ogg` | Issue #31 replaces the prior harp excerpt with the supplied Suno opening WAV: stereo 48 kHz, 134 400 samples (2,8 s). GameInfo.ChatSound is the only emitter; `$limit 1` and `$singular` keep it to one playback when a conversation opens, not on each line or redraw. |
| Title / menu before starting | `sounds/caelum/stock/music/ca_stock_war_drums.ogg` | Full stock of 6 s; one playback, no loop, per front page entry. |
| Open/Close/Back/confirmation prompt | `caelum/ui/menu_open` | Native redirects activate, backup, prompt, dismiss and clear. |
| Move/Change Option | `caelum/ui/menu_move` | cursor, change and invalid. |
| Confirm/advance | `caelum/ui/menu_select` | Choose and advance. |
| Quit the game | `caelum/stock/menu_strings_start` | CaelumExitMenu plays the piece when opening the native confirmation. QuitSound and aliases remain as output coverage; singular avoids overlap. 4,0222 s stock is uncut. |
| Map Switch | `caelum/ui/menu_select` | switches/normbutn. |
| Map Exit button | `caelum/stock/menu_strings_start` | switches/exitbutn. |

MAP01 now uses the former MAP02 track (`CA_MUS02`); MAP02 uses the new sewer track
`CA_MUS03_SEWER`, MAP06 uses `CA_MUS04_PORT` and MAP07 uses `CA_MUS05_COAST`.
The former MAP01 track (`CA_MUS01`) becomes the opening and reserved chapter-intermission
music. Opening the pause menu during a game retains that map's music. The original
dialogue harp remains in `ca_stock_tarot_harp_loop.ogg`; the new opening cue is another
file. Doom sounds are not imported.

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
[AUDIO_PACK_05_CREDITS.md](../src/licenses/AUDIO_PACK_05_CREDITS.md). Issue #31 provenance
and the pending external-license verification are recorded in
[AUDIO_ISSUE_31_CREDITS.md](../src/licenses/AUDIO_ISSUE_31_CREDITS.md). The license of a
third party is not rewritten when reorganizing documents.

## Physical audio inventory

The fully audited project contains 103 runtime files: 100 OGG, 2 MP3 and 1 WAV, including the
issue #31 pain cues, dialogue-opening cue and three new map-music tracks. `assets/audio_stock`
preserves 26 source/backup files outside `src`: 10 pack-05 backups and 16 issue-#31
music/sound masters. Issue #89 preserves four more audio originals under
assets/issue89_pickaxe/reference_package. Total catalogued: 133 files.
A copy by another name does not imply
another recording: menu_move and menu_select continue to share content. 14 native
interface/interruptors aliases also do not add files.

The following paths are related to src. The table records resources; the existence of a
file does not imply that there is already a climate or scene emitter.

| File | Allocation |
| --- | --- |
| `music/CA_MUS01.mp3` | Reserved chapter-end story intermissions. |
| `music/CA_MUS02.mp3` | MAP01 music. |
| `music/CA_MUS03_SEWER.ogg` | MAP02 sewer music. |
| `music/CA_MUS04_PORT.ogg` | MAP06 port music. |
| `music/CA_MUS05_COAST.ogg` | MAP07 coast music. |
| `sounds/caelum/gathering/chop.wav` | One confirmed wood/fiber extraction impact, any eligible weapon. |
| `sounds/caelum/gathering/stone.ogg` | Confirmed stone/coal extraction. |
| `sounds/caelum/gathering/metal.ogg` | Confirmed metal-ore extraction. |
| `sounds/caelum/gathering/crystal.ogg` | Confirmed crystal/gem extraction. |
| `sounds/caelum/ambience/ca_ambience_blacksmith_loop.ogg` | Registered; use according to calls of actor, system or TERRAIN. |
| `sounds/caelum/ambience/ca_ambience_crowd_murmur_loop.ogg` | Registered; use according to calls of actor, system or TERRAIN. |
| `sounds/caelum/ambience/ca_ambience_fire_loop.ogg` | Registered; use according to calls of actor, system or TERRAIN. |
| `sounds/caelum/ambience/ca_ambience_fountain_loop.ogg` | Registered; use according to calls of actor, system or TERRAIN. |
| `sounds/caelum/ambience/ca_ambience_rio_waves_loop.ogg` | Registered; use according to calls of actor, system or TERRAIN. |
| `sounds/caelum/ambience/ca_ambience_sewer_water_loop.ogg` | Registered; use according to calls of actor, system or TERRAIN. |
| `sounds/caelum/enemies/mandinga/ca_mandinga_alert.ogg` | Registered; use according to calls of actor, system or TERRAIN. |
| `sounds/caelum/enemies/mandinga/ca_mandinga_pain.ogg` | Mandinga combat pain, resolved by `CaelumMandinga.GetCombatPainSound()`. |
| `sounds/caelum/enemies/zupay/ca_zupay_alert.ogg` | Registered; use according to calls of actor, system or TERRAIN. |
| `sounds/caelum/enemies/zupay/ca_zupay_pain.ogg` | Zupay combat pain, resolved by `CaelumZupayColossus.GetCombatPainSound()`. |
| `sounds/caelum/enemies/zupay/ca_zupay_walk.ogg` | Registered; use according to calls of actor, system or TERRAIN. |
| `sounds/caelum/enemies/bull/ca_bull_pain_01.ogg` … `ca_bull_pain_12.ogg` | Bull combat-pain variants selected through `$random caelum/enemies/bull_pain`. |
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
| `sounds/caelum/player/pain/ca_player_pain_female.ogg` | Female human/Caelith pain for Caella and a female player profile. |
| `sounds/caelum/player/pain/ca_player_pain_male.ogg` | Male human/Caelith pain for Argento, Ronnie and a male player profile. |
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
| `sounds/caelum/ui/ca_dialogue_open.ogg` | Opening a conversation with the selected Suno WAV (2,8 s); singular playback. |
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
