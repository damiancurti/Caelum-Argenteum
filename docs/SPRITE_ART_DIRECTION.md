# Caelum Argenteum - Sprite art direction

Documentation version: **5.4.41** — 2026-10-18.

This is the artistic brief for generating and reviewing sprite artwork. Damián
Curti requested this dedicated canonical document during issue
[#148](https://github.com/damiancurti/Caelum-Argenteum/issues/148). Read the relevant
section before commissioning, generating or editing sprites. A prompt is an
execution of this brief, not a new source of canon.

Author decisions take precedence. [ASSETS](ASSETS.md) owns resource inventories,
provenance and technical integration evidence; [SYSTEMS](SYSTEMS.md) owns gameplay;
[MAP01](MAP01.txt) owns story and character canon. This document owns the visual
requirements and reusable generation brief. Keep those responsibilities separate.

## Navigation

| Need | Section |
| --- | --- |
| Overall appearance and reference selection | [Style and setting](#style-and-setting) |
| Approved customization | [Characters and choices](#characters-and-choices) |
| Reusable body, head and hair artwork | [Modular construction](#modular-construction) |
| Directions and movement | [Views and poses](#views-and-poses) |
| Hands and held equipment | [First-person artwork](#first-person-artwork) |
| A generation-ready specification | [Asset brief template](#asset-brief-template) |
| What must pass before delivery | [Visual review](#visual-review) |
| Current work versus accepted artwork | [Status and open details](#status-and-open-details) |

## Style and setting

The setting is independent dark fantasy inspired by nineteenth-century Argentina.
Characters should belong to that setting through practical clothing, materials
and restrained presentation. Existing project-owned sprites establish a painted,
pixel-oriented game style: readable silhouettes, modeled volumes and material
shading that remains legible at the actual game size. Do not switch an isolated
asset to glossy modern 3D, anime, comic outlines or photographic portraiture.

Use consistent, soft lighting for reusable modules. A head and its body must not
appear lit from opposite directions; avoid dramatic cast shadows that presume a
particular scene. Character identity comes from anatomy and silhouette as well
as color. Fine decoration that vanishes after downsampling cannot be the only
difference between choices.

Every reference has a declared role: style, species/anatomy, attachment geometry,
pose, equipment, or exact edit target. An armored Domingo reference does not
authorize painting its armor and weapons onto the unequipped player. Caella can
establish goblin features without making every goblin the same individual.
Do not introduce Doom artwork or assume that a development IWAD licenses its art.

For #209 the author specifically selects Domingo's poses and anatomical forms
as references, except his rear attack. The rear punch should follow the clear
forward extension/recovery idea of the Revenant without copying Doom pixels.
Preserve the player's simple clothing and the modular identity choices.

For the #283 3D pilot, the author subsequently requested polished human 3D
models as anatomy/hair references rather than close adherence to Domingo's
sprite proportions. Keep his identity/materials/equipment while improving the
volumetric head and hair. This does not retroactively revise #209 sprite work;
ASSETS and the pilot DESIGN.json record reference roles and CC0 provenance.

## Characters and choices

The following requirements record the author's #148 decisions, including the
2026-10-11 face/hair amendment. They are requirements, not a claim that every
requested option has already been integrated or visually accepted.

| Character family | Body and skin/fur | Face and hair choices |
| --- | --- | --- |
| Human, male/female | Separate sex variants; natural skin tones appropriate to the setting | At least four distinct faces and four hairstyles per sex; six hair colors |
| Goblin, male/female | Separate sex variants; preserve the established pointed-ear species silhouette; natural skin tones | At least four distinct faces and four hairstyles per sex; six hair colors |
| Caelith, male/female | Separate sex variants; established Caelith anatomy; red, green or blue skin | At least four distinct faces and four hairstyles per sex; the same six hair colors |
| Beast Man, male/female | Wolf, bear, puma or jaguar; typical natural colors of that animal; sex body variants | Existing animal heads; this amendment does not request human hairstyles or four faces for each beast form |

The current implementation briefs translate the requested length/curl variety
as short straight, long straight, short curly and long curly. They still require
visual review. Length and curl must remain distinguishable from front, profile and
back. Long hair should be a separate reusable component; do not paint a new
torso for each hairstyle. Keep the ear silhouette readable where the hairstyle
permits it. No unrequested accessory or hat is part of a hairstyle choice.

Approved hair colors for humans, goblins and Caelith are **black, brown, blonde,
redhead, gray and white**. Gray and white must be distinguishable, and color
changes must preserve the hair's shading and alpha. The Caelith RGB choice
applies to skin, not a restriction to RGB hair. Exact processed swatches belong
to the shared asset catalog, not separate constants in UI or gameplay code.

Four faces must represent four recognizably different individuals, not one face
with different expressions. Different jaw width, cheek volume, nose shape and
facial proportions are useful art directions. Maintain the same attachment
envelope so the hair and body remain reusable. Exact face designs are subject to
visual review; these examples do not create named characters or biographies.

The player's base outfit is simple clothing with no fixed armor or weapons
painted into the body. Preserve the approved plain shirt, trousers and boots
while changing face/hair modules. Cosmetic choices do not grant equipment or
change attributes. After creation, the editor may change tone, beast form where
applicable, face, hairstyle and hair color. Race, sex and profession remain fixed.
Pain and breathing voices follow saved sex automatically.

## Modular construction

The author accepted the Domingo 3D prototype (#283) on 2026-10-15 and deferred
sprite-to-model migration to the V5.17 presentation roadmap in PROJECT. Future
3D characters must retain this modular principle: interchangeable weapon, shield,
armor, hair and face, compatible attachment points and reusable animation.
The fixed-surface pilot is a reference, not the final modular architecture.

Separate the reusable body/clothing, head/face, hair, exposed hands and equipment
where their variations are independent. Skin/fur masks and hair color masks must
not recolor clothing, eyes, weapons or other protected regions. Use transparent
modules with common attachment landmarks; inspect the assembled result as well
as each isolated part.

Do not generate the full product of race, sex, tone, face, hairstyle, hair color,
pose and equipment as complete character images. Reuse compatible modules and
apply finite palettes deterministically. Native composition metadata also has a
cost: validate registration count, loading and rendering before expanding it.
An efficient source catalog must not conceal an untested explosion in runtime
resources.

The current technical reference is
[`appearance_catalog.json`](../assets/generators/appearance_catalog.json).
It defines the world canvas, pivot, neck anchor, head sizes, poses and palette
data. Those are current integration parameters, not a universal resolution for
all future characters. Preserve physical-height agreement between the preview
and world; hair length must not change a character's physical height or stats.

Head sources should include a complete scalp and a short clean neck attachment.
Bald source heads are construction modules, not automatically an extra selectable
hairstyle. Hair sources must fit those scalp landmarks and contain only the
required hair pixels. If rear hair needs separate layering around the neck or
shoulders, specify front/rear modules explicitly before generation.

Keep original atlases, reference boards, exact prompts and output hashes in
`assets/`. Only runtime resources belong in `src/`. Preserve provenance for
retained and derived art. Python cutting, registration, masks, resizing and
packing are authorized technical processing; generators must be deterministic.
Use imagegen for newly painted artwork. Never silently replace approved source
art while preparing a candidate variant.

## Views and poses

World characters use eight consistent directions. The order for new turnaround
briefs is front, front-left 45 degrees, left profile, rear-left 135 degrees,
back, rear-right 225 degrees, right profile, front-right 315 degrees. Match the
actual native rotation registration before packaging; an atlas label alone is
not proof that the engine displays the correct side.

Specify rows, columns, cell dimensions and the meaning of each cell in every
atlas brief. Existing eight-view sources use four columns by two rows. The new
face candidate atlases use eight columns by four rows: each row is one face,
each column one direction. These are separate layouts; do not feed one to the
other's cropping code. Keep common scale, neck/foot baselines and transparent
gutters. Rotate the entire identity; do not repeat front views in side cells.

Preserve anatomical left/right, hand ownership of equipment, face identity,
haircut, clothing, material and proportions across views and frames. A pose must
not acquire an extra hand, duplicate a weapon, flip a shield between arms or
change the visible race. New faces and hairstyles must fit the existing idle,
walk, run, crouch, attack, pain, fall, death, rest and firearm pose families.

The initial #148 implementation has shared and rigged poses; it is not a fully
new animation catalog. Sitting/kneeling and held-firearm locomotion retain the
limitations documented in ASSETS until separately improved. Inspect those poses
when adding modules rather than describing them as newly authored animation.

The #209 revision replaces run/punch/death/sleep with authored pose sources.
Sleep is **supine**, with relaxed limbs, a supported head and consistent world
direction as the rest camera orbits. A side-rolled upright figure is not a
sleep or corpse pose. Death must visibly buckle and settle into an actual
fallen body. Four-phase running must alternate support/flight; punching must
articulate shoulder/elbow/forearm without moving neighboring trouser pixels.
Check the neck joint in every direction and posture, not only the standing
front. Seat contact follows character height and the furniture surface.

## First-person artwork

Hands belong to the selected character. Exposed skin/fur must agree with the
world and preview, including the animal-specific hand family for Beast Men.
Visible gloves depend on the actual equipped Hands-slot item. Broken gloves
remain worn; unequipped or boxed gloves must not hide the bare hand appearance.
The current shared brown glove presentation is not a new material-specific
wardrobe.

The author requires anatomically distinct female first-person hands (#209),
including humanoid skin, every beast form and worn gloves. Use proportion,
knuckle/wrist shape and silhouette; a recolor of a male hand is insufficient.
Keep hands functionally capable and consistent with the painted world body;
do not introduce jewelry, nail polish or decorative accessories.

Keep the accepted weapon shapes, sleeve framing, handedness, grip and shared
pivots when replacing hand components. Preserve the thumb/fingers in front of
the handle and the palm behind it. Blocking must show the appropriate held
shield and hand without duplicate fists. A face or hair selection does not
require new weapon sprites or a different first-person attack trajectory.

Use the accepted sword composition and equipment-specific source assets as
geometry references; exact layer coordinates, timing and alpha-bound pivot
rules remain in ASSETS and the integration catalog. Validate rest, attacks,
block transitions, reloads and returning to rest at runtime. Do not infer that
a pleasing standalone hand image will align with a held weapon.

## Asset brief template

Fill this brief before each generation batch. Link to this document and the
relevant catalog entries rather than repeating an entire history in a prompt.

```text
Issue and asset ID:
Status: candidate / integrated / author accepted
Purpose: world body / face / hair / first-person hand / equipment
Character family, sex and supported choices:
Reference paths and role of each reference:
Art direction: painted pixel-oriented dark fantasy, nineteenth-century Argentina
Identity/features to generate:
Invariants from the reference:
Module boundary and protected neighboring regions:
Views/poses, exact atlas grid and per-cell order:
Scalp/neck/wrist/grip/foot landmarks and alignment reference:
Palette target and protected colors:
Lighting and material:
Output: real transparent alpha, complete silhouettes, clear gutters
Exclude: labels, grid lines, scene background, cut-off parts, unrequested equipment
Planned deterministic processing and destination:
Visual checks and acceptance still required:
```

For an edit, name exactly what changes and what must remain untouched. For a
new component, describe its interface with existing art. Do not use labels or
painted checkerboards as a substitute for transparency. Record the prompt that
was actually sent, the tool used, reference hashes and the selected output.

## Visual review

1. Inspect every atlas cell for complete silhouettes, genuine alpha, correct
   direction, consistent scale and identity. Reject overlaps between cells and
   unexpected extra components.
2. Assemble representative combinations before multiplying outputs. Check scalp,
   ear, neck, hair/shoulder and wrist seams, including profile and rear views.
3. Compare faces and hairstyles at actual sprite scale. Four source portraits
   are insufficient if their differences disappear in the game. Check all six
   hair colors against each supported skin tone.
4. Compare creator preview, in-game cosmetic editor and world sprite through
   movement, crouch, attacks, rest and death. First-person hands retain their
   equipment-dependent appearance. Hair/face must not alter character scale.
5. Verify choices persist through cancel/confirm, save/load, restart, travel and
   another character's creation. These are engine checks, distinct from whether
   the author likes and accepts the artwork.

Static hashes and texture lookup checks establish integrity, not visual quality.
Keep outstanding author checks in `pending_test.txt`, and record confirmed
acceptance in HISTORY. Generated candidates are never automatically accepted.

## Status and open details

#209 repairs the subsequently reported attachment/animation defects and adds
female hand anatomy. The author accepted CA209-01 and CA209-02 on 2026-10-12
without qualifications. Source hashes and exact prompts are retained in
assets/source/art/appearance_5218/PROVENANCE.json; native checks and limitations
are in assets/validation_5218/RESULTS.md. The older #148 acceptance below remains
historical evidence, not automatic acceptance of this revision.

The #148 modular body/skin/fur/hands integration is delivered in
[PR201](https://github.com/damiancurti/Caelum-Argenteum/pull/201); CA148-01 passed
author acceptance on 2026-10-12, with merge and issue closure authorized. The author-requested four-face/four-hairstyle/six-color extension is
integrated through reusable face/hair modules and native eight-view
head registration. Agent inspection and engine evidence are recorded in ASSETS;
author approval is recorded in HISTORY. Further source generation must follow this brief.

The delivered face designs, hair silhouettes, attachment quality and processed
colors are included in that acceptance. Additional beard, eye-color, clothing
color or accessory selectors are not currently requested. A full new animation
set and a complete visible armor/weapon wardrobe remain outside #148's scope.
The earlier intermittent fullscreen cursor report is preserved in the diagnostic
record. Final author tests passed, without establishing a runtime cursor fix.
