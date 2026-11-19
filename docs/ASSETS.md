# Caelum Argenteum — Audio and art

Documentation version: **5.17.96** - 2026-11-19.

## 5.17.96 - Conservative shared-candidate reach rejection (#836, #454)

This engineering patch changes no art, source model, animation, skin, binding,
sound, map or license. Production retains MD3 as established by #834. All such
runtime members remain byte-identical to the parent package. The diagnostic
linked-room fixture is generated locally and depends on development IWAD
textures; no WAD, PK3, engine or save is distributed. Native fixture source,
logs, presentation traces, selected scenes and reproducible scripts remain in
assets/validation_v5_17_96. HISTORY and CA-KP-255 record the measured query change,
its limits and unchanged author-review status.

## 5.17.95 - Skeletal native-format assessment (#834, parent #458)

The isolated comparison does not support migrating production characters to
this IQM export. It reduces the seven model files from 32,510,864 to 2,024,448
bytes, but the matched 64-figure scene produces 236.24 queue presents/s versus
873.40 for MD3. A hybrid retaining the original cape occupies 2,354,400 bytes
and produces 246.13 queue presents/s. Production MD3 bindings remain unchanged.
These measurements do not isolate the cause of the regression or establish a
general engine-format ranking.

The deterministic exporter reads the unchanged accepted Domingo source and
preserves its seven module identities, owned material, 73 meshes, 26 bones,
10,689 vertices, 17,447 triangles and 24 actions/375 samples. Existing numeric
FrameIndex/state durations remain authoritative; no uniform clip rate is
invented for nonuniform source samples. Two complete exports repeat all ten
files byte for byte. Nine raw source/export files are retained under
assets/source/art/iqm_assessment_834/export; runners rebuild the local overlay.
Pinned IQM specification/engine references and existing art rights are recorded
in PROVENANCE.json. No engine, IWAD, private test package or save is distributed.

The cape applies thickness after nonrigid deformation. Rest-baking that modifier
introduces a maximum 0.511826-MU pipeline difference; combined encoding/source
difference reaches 0.523182 MU. The hybrid preserves every original MD3 cape
sample. The six other modules differ from the sampled Blender source by at
most 0.005551 MU after native weight/channel quantization. The independently
parsed IQM hierarchy, indices, UVs, weights, frame channels and bounds pass
4,008,375 sampled-vertex checks against retained MD3 geometry. Arithmetic
roundoff bounds are diagnostic calculations, not approved artistic tolerances.
The reconstruction does not establish exact fractional interpolation equality.

Final native04 uses the final package and passes 257 fresh plus six IQM-load
and six hybrid-load assertions (269 total). It records all 24 registered poses
from front/rear quarters, four additional rest directions, independent module
visibility, walking and retained selections after save/load. Both saved/reloaded
images match exactly. Twenty comparison views, six benchmark scenes and the
walking viewer were directly inspected; all 160 comparison capture hashes are
retained. The bounded viewer smoke adds six assertions. No author review has
occurred, and CA834-FORMAT-01 is reserved for the final consolidated session.

Sequential peaceful measurements use one or 64 identical figures, Vulkan,
1280x720, a fixed room/camera, uncapped presentation, background simulation and
5% audio. Each case records 700 simulation intervals; no heavy build/export
or full validator overlaps the captures. The recorded device is RTX 3070 Ti.

| Figures / format | Queue presents/s | Presentation p95 / p99 / max (ms) | Simulation p95 / p99 / max (ms) |
| --- | ---: | --- | --- |
| 1 / md3 | 1136.91 | 1.0356 / 1.2090 / 1.7343 | 29.1791 / 29.2800 / 29.6321 |
| 1 / iqm | 1099.76 | 1.0667 / 1.2369 / 2.0382 | 29.1655 / 29.3236 / 29.4318 |
| 1 / hybrid | 1126.14 | 1.0537 / 1.2517 / 2.1550 | 29.1726 / 29.3355 / 29.5755 |
| 64 / hybrid | 246.13 | 4.9619 / 5.5703 / 7.2589 | 31.7668 / 32.2385 / 33.4394 |
| 64 / iqm | 236.24 | 5.1944 / 6.1660 / 8.0092 | 31.9702 / 32.4096 / 33.9434 |
| 64 / md3 | 873.40 | 1.2921 / 1.4285 / 2.4734 | 29.3526 / 29.6561 / 29.9114 |

Queue intervals are not monitor latency or scene GPU execution time. These six
single-run comparisons do not establish campaign/siege fluency or arbitrary
population behavior. They give sufficient evidence to retain the production
format while investigating any future skeletal implementation separately.
CA-KP-254 records fidelity and cost lessons. Existing models, animation timing,
equipment/collision/save owners and original source art are unchanged; the
18,719-member package differs only in its two required diagnostic version
strings. Evidence and full project validation: assets/validation_v5_17_95/evidence.
Other body/species/sex variants, production garment integration and first-person
equipment remain separate work; no final batch completion is claimed.

## 5.17.94 - Historical release labels restored (#831)

The four retained #822 headings in ASSETS, TASKS, PROJECT and HISTORY again
identify their original release, 5.17.90. Comparison with the parent of
b2f86002 records the accidental #825 substitutions and audits retained
historical headings. Current headers advance only at their explicit marker.
Gameplay and asset bytes are preserved; the two required diagnostic
release strings follow 5.17.94. No author test is removed or added.
The audit covers 1,063 retained historical headings and 18,719 runtime
files. Only the two required diagnostic version strings differ. Scoped
documentation/header/link/index checks pass; unchanged art/gameplay tests
are retained from #829 rather than rerun. Evidence: assets/validation_v5_17_94.
The V5.16/V5.17 batch and its final author terminal remain unfinished.

## 5.17.93 - Fitted first-body wardrobe candidates (#829, parent #459)

The 25 approved garment identities now have editable worn candidates for the
first Domingo-compatible body: 11 body ensembles, five hats, four glove pairs
and five footwear pairs. Eighty-six native modules include five covered-body
regions, lower hair and 55 trouser hem variants; fifteen fixture slots select
the four garment regions independently without adding inventory identities.
The accepted Domingo source, old models, inventory artwork and production
character/equipment owners remain unchanged. Campaign equipment integration,
other bodies/species/sexes, item grips and first-person fitting remain unfinished.
Author acceptance is pending; no final consolidated terminal has been opened.

Source: assets/source/art/worn_clothing_829. The authoring/export/validation
utilities retain the 24 actions and 375 samples. The 473 editable components
have closed edges, positive rest volumes and normalized weights. Each of the
eleven anatomy-derived trousers is one connected surface. The native modules
contain 91,755 vertices/168,724 triangles in aggregate, with 5,625 frame/slot
declarations. All 89 repeated export files are byte-identical; intermediate
geometry repeats exactly. The .blend is a retained editable authoring checkpoint,
with 27 owned PNGs packed unchanged, rather than a deterministic Blender-save
claim. All 18,719 packaged entries match src, and 14 original source files remain
byte-identical. The runtime SHA-256 is b073da14f96bc9215a96c509e8c675fe43f2ded8622a2fb57fc3321b0362d7b3.

Fitting corrects inventory display offsets, unfolds trousers and maps sleeves
to the actual shoulder/elbow/wrist path. A complete ankle cut and a vertically
sampled anatomical envelope fit all shoe/boot uppers. Trousers have bare, low,
formal, ankle and tall hem variants, with a capped overlap below the selected
shoe/boot collar. The same fabrics, patches and garment IDs remain authoritative.
Independent skin regions keep exposed
forearms, neck and feet visible without drawing covered arms through sleeves.
Hats use lower hair; removing headwear restores the full original hair.
VISIBILITY.json is the explicit garment-mask authority for the isolated fixture.

Rejected iterations exposed disconnected trousers, sleeve/ankle gaps, coat
intersections, a buckle crossing the poncho and hand/shin-driven cloth distortion.
Native06/09 passed 208/240 assertions despite those visual faults. Source11 uses
a semantic torso/thigh weight field for 207 cloth/detail parts, continuous fitted
trousers and open-sided poncho panels. CA-KP-253 records the corrective method.
Extreme shoulder bends and skirt folds remain angular; horizontal cloth stays
rigid. These are rigged meshes without physical cloth simulation or item grips.

Final native23 passes 306 assertions: all four region selections and removals,
all 66 body/footwear combinations including bare feet, 24 action samples on
representative ensembles, stress poses on the remaining
ensembles, camera details, animation, saved masks and reload. The saved/reloaded
capture is byte-identical. Its 236 capture hashes are retained; 22 final
native/presentation views were directly inspected and 50 other final views
reuse exact pixels from inspected quick-run captures. The review manifest names
the actual inspected subset; other local captures are not claimed reviewed.
Earlier native11/12 exposed foot, heel and calf intersections; native13 exposed
tall boots crossing full trousers. Those passing logical tests were rejected
visually and corrected before final verification. Native15 exposed inner shirt
and long-coat intersections; native17/18 retained rejected layer-weight variants.
Source22 fits inner RW layers beneath the poncho, adds vertical long-coat
samples and confines F/FW/CW/PW thigh following below the waist. Lower inner layers
taper with their original torso weights, avoiding coarse abdominal deformation. Native21 exposed the same PW crossing,
and coloured diagnostics located a smaller CW crossing; both receive the same
correction in Source22 before final native verification.
The unchanged production pilot's earlier 22 save/rollback assertions are reused
only within the byte-preservation scope, not as new wardrobe integration proof.

Four sequential 700-tic peaceful runs compare the original seven modules with
the fitted wardrobe on 1/64 noninteractive figures. The 64-figure wardrobe cycles
all eleven ensembles. Environment: GZDoom 4.14.2/Vulkan, Ryzen 9 5950X, RTX 3070 Ti,
1280x720, uncapped presentation with vsync off, unpaused background, 5% audio.
No heavy builds/generators ran concurrently; temporary wake requests were released.

| Figures / modules | Queue presents/s | Present p95 / p99 / max ms | Tic p95 / p99 / max ms |
| --- | ---: | --- | --- |
| 1 / seven | 1221.6 | 0.95 / 1.06 / 1.62 | 29.12 / 29.27 / 29.42 |
| 1 / worn | 1208.0 | 0.96 / 1.06 / 2.08 | 29.16 / 29.34 / 29.50 |
| 64 / worn | 785.6 | 1.44 / 1.59 / 2.78 | 29.47 / 29.66 / 29.93 |
| 64 / seven | 888.9 | 1.26 / 1.39 / 2.27 | 29.33 / 29.55 / 29.66 |

These single-scene measurements report queue presentation and simulation tails,
not GPU/display latency, campaign population, siege fluency or author acceptance.
Evidence: assets/validation_v5_17_93/evidence/SUMMARY.json, including retained
rejected iterations and final validation. CA829-WARDROBE-01 remains pending.

## 5.17.92 - Reusable Domingo anatomy foundation (#827, parent #458)

Three independent native modules add a complete construction body and relaxed
left/right hands for garment fitting. The editable source derives from the
already retained CC0 MakeHuman base and uses Domingo's accepted rig, head and
24 actions/375 samples. The original .blend, skin, fixed model and seven old
modules remain byte-identical. The runtime contains the three new MD3 files and
attribution, but production bindings, equipment, collision and gameplay remain
unchanged. Ordinary campaign characters do not use this candidate yet.

Sources/provenance: assets/source/art/underbody_827. Authoring explicitly maps
MakeHuman axes to the accepted rig, transfers bone weights, closes neck/wrist
cuts and preserves shared wrist coordinates. The body has 2,221 vertices and
4,438 triangles; left hand 353/702; right hand 354/704. Each module is connected,
closed and positive-volume. Sixty-three shared wrist pairs remain identical
after native quantization across all 375 frames: 23,625 pair checks. Exported
normals agree at those seams. All UVs sample one existing skin-atlas pixel;
this uniform construction material does not introduce or approve new painted
skin. Relaxed hands do not establish item-specific finger grips.

Six files from final exports 07/08 repeat byte for byte. A final connectivity
audit removed a detached, opposing triangle pair at the neck cut: three vertices
and two zero-volume faces. All retained points/normals in 375 frames and both hand
files remain byte-identical; each final serialized module has one component.
The previous closed-edge check alone could not detect that island (CA-KP-252).
The static validator
checks source hashes, native counts and all 3,750 frame/slot bindings. GZDoom
snapshots retain other slots' current poses: declare all ten models first and
write every slot for each pose before advancing. An earlier slot-by-slot export
left 374 stale snapshots and visibly detached a seated hand/body. The corrected
native views and rejected earlier bindings are retained; see CA-KP-251.

The complete 18,632-entry runtime matches src exactly. Its only existing runtime
differences from #825 are the two required version diagnostics. The isolated
anatomy fixture passes 30 fresh and five reload assertions, including motion,
all 24 sampled poses and byte-identical saved hair/hand visibility captures.
Four production-pilot continuity phases pass 22 checks: parent save, forward
load, candidate save and rollback load. These exercise the unchanged production
owners, not integration of the new anatomy into gameplay.

All 59 final anatomy views, four presentation captures and one old-save capture
are covered by review: 15 changed anatomy views and the other five captures were
inspected directly; 44 anatomy views are byte-identical to inspected native07 views.
The neck/head and wrist attachments remain visually connected
in the sampled poses. Legacy clothing intersects hips, legs and toes and leaves
coverage gaps. Modes showing that raw overlay deliberately expose unfinished
#459 fitting work; they are not finished clothing or an accepted replacement.
Species/sex variants, skin artwork, named-character conversion and first-person
equipment remain outside this foundation patch.

Four sequential 700-tic final comparisons ran on 2026-11-18 with one/64 isolated figures,
seven versus ten simultaneously drawn modules. Windows 11 Pro 26200, Ryzen 9
5950X/32GB/RTX 3070 Ti driver 32.0.16.1088 and Parsec adapter; GZDoom 4.14.2
Vulkan, 1280x720, uncapped without VSync, unpaused background at 5% audio:

| Drawn slots / bodies | Queue presents/s | Present p95 / p99 / max (ms) | Simulation mean / p95 / p99 / max (ms) |
| --- | ---: | --- | --- |
| seven / 1 | 937.35 | 1.4112 / 1.8302 / 2.6051 | 28.5711 / 29.3022 / 29.5093 / 29.6483 |
| ten / 1 | 911.72 | 1.4469 / 1.8911 / 3.3709 | 28.5716 / 29.3815 / 30.0135 / 30.2377 |
| ten / 64 | 631.27 | 1.9255 / 2.4128 / 3.3204 | 28.5721 / 29.6391 / 30.0964 / 30.7502 |
| seven / 64 | 729.91 | 1.7455 / 2.2186 / 2.7723 | 28.5709 / 29.5261 / 29.9020 / 30.5321 |

Ten-slot scenes include overlapping old clothing and the new body. These are
additive geometry costs, not final fitted-character, GPU/display-latency,
campaign or siege results. Earlier Nov 16 measurements remain in evidence; the
Nov 18 environment snapshot accompanies the final complete-package runs. Earlier failed
authoring, binding and console scheduling attempts remain in evidence.
Evidence: assets/validation_v5_17_92/evidence/SUMMARY.json.
CA827-BODY-01 remains pending. Continue garment fitting and the larger batch
before the single consolidated author test terminal.

## 5.17.91 - Complete approved regional inspection coverage (#825)

A third isolated native gallery adds the 44 approved catalogue/region pairs
missing from galleries CA682G and CA709G. Its 30 existing candidate classes
cover Buenos Aires, Pampa, Litoral, Cuyo, Northwest Argentina, Chaco, Selva,
Patagonia and Supernatural domains. The three maintained galleries now cover
all 78 approved associations of the 56 provisional classes exactly once.
Protected identities 018/019 remain unchanged. Repeated unique identities are
diagnostic displays; neither population counts nor campaign placements follow.

CA825G uses six existing owned regional ground studies. Buenos Aires, Chaco
and Supernatural domains use explicitly labelled neutral inspection flooring;
no new biome artwork or mandatory habitat is implied. Existing models, animation,
collision, combat, identity, loot and saved production fields remain unchanged.
Passive friendly staging and silent observer steps exist only in this fixture.
Original idle states advance, with no forced subject position resets.

Editable gallery data and provenance live in assets/source/art/regional_gallery_825.
The validator checks approved coverage, eight original model exports, exact actor
bindings, source hashes, native collision/full-animation silhouette separation,
camera bounds and unique keys while preserving WASD. Ten sectors, 30 vertices
and 39 linedefs provide nine adjacent plots and a walkway. Four fixture files
repeat byte for byte. Both earlier gallery sources remain byte-identical.
The 18,628-entry package exactly matches src; only two version diagnostics
differ from #822. No production art or behavior changes accompany this gallery.

Native fresh/reload tests pass 547 assertions: 181 fresh and 366 after reload,
including all 44 saved actors, inherited catalogue identities, idle advancement,
silent observer movement and crossing all eight plot boundaries. All 55 camera
keys register and query correctly. This is not author keypress acceptance.
F1 shows the complete layout, F2 returns to walking, F3-F11 show regions, and
the remaining listed controls show individual figures. Labels use canonical
creature names and identify neutral flooring. The final 54 automatic views and
one reload capture were inspected. Ordered native VIEW markers verify the
capture sequence. Initial camera framing and aligned background silhouettes
were corrected in data; earlier controls and captures remain in evidence.

One sequential 700-tic neutral/regional-ground comparison ran with the same
44 native subjects on Windows 11 Pro 26200, Ryzen 9 5950X/32GB/RTX 3070 Ti
driver 32.0.16.1088 with the Parsec adapter, GZDoom 4.14.2 Vulkan 1280x720,
uncapped without VSync, unpaused in the background at 5% audio:

| Gallery floor | Queue presents/s | Present p95 / p99 / max (ms) | Simulation mean / p95 / p99 / max (ms) |
| --- | ---: | --- | --- |
| existing-material | 1093.73 | 1.1580 / 1.2897 / 1.6541 | 28.5719 / 29.2442 / 29.4114 / 29.6671 |
| regional-materials | 1061.60 | 1.2176 / 1.3874 / 2.2800 | 28.5715 / 29.2467 / 29.4152 / 29.6001 |

Queue intervals do not establish GPU/display latency, repeatability, optimization,
or campaign/siege performance. The two presentation captures were inspected.
Evidence: assets/validation_v5_17_91/evidence/SUMMARY.json.
CA825-REGIONS-01 remains pending. Diagnostic regional coverage is complete;
other characters, modular equipment, campaign authoring and siege rendering
still prevent the complete batch handoff and consolidated author terminal.

## 5.17.90 - Xalpen, Luz Mala, Anchimallen and Huayrapuca candidates (#822)

Four distinct owned references now have native candidates on their existing
provisional classes 021/027/034/056. Xalpen combines an adult gray woman,
rounded ears, dark braided hair and leather/bronze clothing with a four-legged
reptilian lower body, claws and long armored tail. Luz Mala has a pale green
skull orb and six curling flames. Anchimallen has a childlike amber body,
short dark hair, small pointed ears, bare feet and a ragged ivory tunic with
a rope belt. Huayrapuca has a female face, golden eyes, long neck and hair,
swept horns, an ivory throat, four reptilian legs, a long tail and two broad
feathered wings. These are separate reference identities; no shared taxonomy,
new cultural claims or modular inventory are adopted.

Editable anatomy, OBJ/MTL, animation, contact controls, original RGB 1122x1402
atlas, exact built-in ImageGen prompt and provenance are retained in
assets/source/art/distinct_forms_822. Atlas pixels remain unchanged.
Sixteen export files repeat byte for byte. Independent serialized checks verify
304 closed components, 300 rooted contacts, 2,400 posed attachments,
all 23 inherited frames, noncollapsed triangles and material-cell UV bounds.
Initial root/cap and child clothing witnesses failed; subsequent controls
corrected their locations. Native review then corrected Xalpen's inherited
pointed ears and coin-like chest patches, angular flames and a serrated orb
boundary, interrupted child cord and hair coverage, and edge-on throat/wing
surfaces. The quadrupeds fall onto a flank through data-owned visual pose
overrides. A visual model offset centers the skull orb without changing its
existing actor profile. Source iterations and failed diagnostics are retained.

The 18,628-entry runtime matches src exactly. Against #821, six new resources,
one MODELDEF include and two version diagnostics explain every runtime change.
All other bytes are identical. Provisional collision/scale, statistics, powers,
action timing, loot, identity and saved fields remain authoritative. No metric
reference dimensions, campaign placements or new abilities are adopted.

The final package passes 702 native assertions: 460 previous-package baseline,
old-save, fresh-model, reload and rollback assertions plus 242 actual action,
loot and loot-reload assertions. Forty final front/profile/rear, detail, extreme
stride, attack, pain, intermediate death and lying captures were inspected.
Each captured pose verifies ordered VIEW -> indexed pose PASS -> screenshot.

One sequential 700-tic sprite/model pair per form ran on Windows 11 Pro 26200,
Ryzen 9 5950X/32GB/RTX 3070 Ti driver 32.0.16.1088 with the Parsec adapter,
GZDoom 4.14.2 Vulkan 1280x720, uncapped without VSync, unpaused in the background
at 5% audio:

| Form / scene | Queue presents/s | Present p95 / p99 / max (ms) | Simulation mean / p95 / p99 / max (ms) |
| --- | ---: | --- | --- |
| xalpen / sprite | 1923.89 | 0.7093 / 0.7849 / 1.6111 | 28.5711 / 28.9390 / 29.0412 / 29.1892 |
| xalpen / model | 1908.68 | 0.7163 / 0.8093 / 1.6129 | 28.5718 / 28.9445 / 29.0583 / 29.3322 |
| luzmala / sprite | 1929.80 | 0.6990 / 0.7927 / 1.8588 | 28.5714 / 28.9378 / 29.0595 / 29.9257 |
| luzmala / model | 1865.26 | 0.7293 / 0.8332 / 1.6245 | 28.5710 / 28.9744 / 29.0729 / 29.2502 |
| anchimallen / sprite | 1826.63 | 0.7441 / 0.8522 / 1.4249 | 28.5717 / 28.9545 / 29.0914 / 29.4550 |
| anchimallen / model | 1982.62 | 0.6394 / 0.7601 / 1.1414 | 28.5714 / 28.9185 / 29.0181 / 29.2930 |
| huayrapuca / sprite | 1885.42 | 0.7152 / 0.8155 / 1.3400 | 28.5712 / 28.9471 / 29.0651 / 29.2464 |
| huayrapuca / model | 1802.36 | 0.7383 / 0.8286 / 1.5046 | 28.5714 / 28.9301 / 29.0288 / 29.2774 |

Queue intervals do not establish GPU/display latency, repeatability, optimization
or campaign/crowd performance. Sprite and model screen coverage differs.
Stylized component anatomy, painted faces, opaque flames/hair/feathers and rigid
fall/rest remain candidates. Broad silhouettes can exceed provisional collision.
The flame material does not add an illumination mechanic. CA822-FORMS-01 remains
pending. Evidence: assets/validation_v5_17_90/evidence/SUMMARY.json.

Coverage reaches 56/56 provisional classes; protected identities 018/019 remain
unchanged. Regional displays, other characters, modular fitting, campaign
authoring and siege rendering still prevent the complete batch handoff.

## 5.17.89 - Curupi, Gualicho, Uritu Orko and Maip candidates (#821)

Four distinct owned references now have native candidates on their existing
provisional classes008/036/040/042. Curupi has a stocky adult body, broad nose,
pointed ears, dark hair/braids, rough sleeveless clothing, leaf layers and short
trousers. Gualicho has an ash/bark body, long mask-like face, twig crest, ribs,
ragged geometric cloth and long claws. Uritu Orko has a human-avian face and
beak-like nose, swept crest, slate/ivory feathers, long arm wing-feathers and
talons. Maip has a bony/stone body, bird-like skull/beak, long hair, rib forms,
shoulder/forearm spikes, long claws and rough waist wrap. These are separate
reference identities; no shared taxonomy or new cultural claims are adopted.
Fixed clothing and ornaments do not create modular inventory.

Editable anatomy, OBJ/MTL, animation, contact controls, original RGB1122x1402
atlas, exact built-in ImageGen prompt and provenance are retained in
assets/source/art/bestiary_figures_821. Atlas pixels remain unchanged.
Sixteen export files repeat byte-for-byte. Independent serialized checks verify
321 closed components, 317 rooted contacts, 2,536 posed attachments,
all23 inherited frames, noncollapsed triangles and material-cell UV bounds.
Initial feather/spike witnesses on tube caps failed; interior overlap witnesses
and two outer attachment roots corrected those failures. Native review exposed
inherited flared wrists, isolated rib plaques and a parallel feather crest over
a bare scalp. Revised forearms taper toward their hands, ribs curve around the
flanks, Maip has pointed skull ears, and Uritu has a feather crown/nape and
varied swept crest. Source
iterations, failed diagnostics and superseded native captures are retained.

The18,622-entry runtime matches src exactly. Against #819, six new resources,
one MODELDEF include and two version diagnostics explain every runtime change.
All other bytes are identical. Provisional collision/scale, statistics, powers,
action timing, loot, identity and saved fields remain authoritative. No metric
reference dimensions, campaign placements or new abilities are adopted.

The final package passes 702 native assertions:460 previous-package baseline,
old-save, fresh-model, reload and rollback assertions plus 242 actual action,
loot and loot-reload assertions. Forty final front/profile/rear, detail, extreme
stride, attack, pain, intermediate death and lying captures were inspected.
Each captured pose verifies ordered VIEW -> indexed pose PASS -> screenshot.

One sequential700-tic sprite/model pair per figure ran on Windows11 Pro26200,
Ryzen9 5950X/32GB/RTX3070Ti driver32.0.16.1088 with the Parsec adapter,
GZDoom4.14.2 Vulkan1280x720, uncapped without VSync, unpaused in the background
at5% audio:

| Figure / scene | Queue presents/s | Present p95 / p99 / max (ms) | Simulation mean / p95 / p99 / max (ms) |
| --- | ---: | --- | --- |
| curupi / sprite | 1930.43 | 0.6955 / 0.7802 / 1.6689 | 28.5714 / 28.9328 / 29.0264 / 29.1544 |
| curupi / model | 1935.15 | 0.6655 / 0.7866 / 1.6080 | 28.5715 / 28.9442 / 29.0882 / 29.2237 |
| gualicho / sprite | 1986.59 | 0.6966 / 0.7594 / 1.4042 | 28.5710 / 28.9131 / 29.0300 / 29.1533 |
| gualicho / model | 1960.59 | 0.6966 / 0.7819 / 1.3101 | 28.5713 / 28.9309 / 29.0091 / 29.2819 |
| urituorko / sprite | 1954.27 | 0.6878 / 0.7715 / 1.8683 | 28.5717 / 28.9134 / 29.0628 / 29.1009 |
| urituorko / model | 1905.07 | 0.6848 / 0.8103 / 1.3685 | 28.5712 / 28.9694 / 29.0950 / 29.2339 |
| maip / sprite | 1939.68 | 0.6143 / 0.7709 / 1.0703 | 28.5716 / 28.9219 / 28.9955 / 29.1845 |
| maip / model | 1954.52 | 0.6793 / 0.8014 / 1.6093 | 28.5715 / 28.9406 / 29.0815 / 29.2985 |

Queue intervals do not establish GPU/display latency, repeatability, optimization
or campaign/crowd performance. Sprite and model screen coverage differs.
Stylized component anatomy, painted faces, opaque hair/feathers and rigid fall/rest
remain candidates. Broad silhouettes can exceed provisional collision.
CA821-FIGURES-01 remains pending. Evidence:
assets/validation_v5_17_89/evidence/SUMMARY.json.

Coverage reaches52/56 provisional classes. Xalpen, Luz Mala, Anchimallen and
Huayrapuca remain under #822. Regional displays, other characters, modular fitting,
campaign authoring and siege rendering still prevent the complete batch handoff.

## 5.17.88 - Five native land and river figure candidates (#819)

Noshtex 020, Pampayoj 037, Mayu Maman 038, Orko Maman 039 and Nowet 041
have distinct native candidates based on their owned references. Noshtex has
a broad gray stone body, dark hair/beard and rough loincloth. Pampayoj is lean,
with straw hair, ochre crossed poncho and ivory clothing. Mayu Maman has blue-gray
skin, dark flowing hair and ivory/teal layered clothing with gold leaves.
Orko Maman has warm stone skin, chestnut hair and stone/cloth layers. Nowet has
an older brown face, silver hair and pale/dark wraps with cords and bronze.
Fixed clothing and ornaments are art; no modular inventory is added.
Editable controls, OBJ/MTL, animations, contacts, original atlas, prompt and
provenance remain in assets/source/art/land_figures_819. Atlas pixels are unchanged.

Nineteen exports repeat byte-for-byte. Independent serialized checks verify
380 closed components, 375 rooted contacts, 3,000 posed attachment checks,
all 23 inherited frames, noncollapsed triangles and material-cell UV bounds.
Native review corrected pointed inherited ears, long beards, sparse shoulder
hair, leg volumes and incomplete front clothing. Failed contact diagnostics and
source/capture iterations are preserved. The garments have intentional front
openings and layered panels; this does not claim closed-skirt containment.

The 18,616-entry package matches src exactly. Against #817 it adds seven
model/material/binding resources and one MODELDEF include; two release diagnostics
change elsewhere. Every other runtime byte is unchanged. Collision, scale,
statistics, action timing, powers, loot, identity and saved fields are preserved.
No reference metric dimensions, campaign placement or new cultural claims are adopted.

The evidence totals 871 qualified native assertions: 575 previous-package
baseline, old-save, fresh-model, reload and rollback assertions plus 296
actual action, loot and loot-reload assertions. Of these, 460 continuity assertions
are reused only for four byte-identical models and regenerated fixtures from
land03; reuse01 proves that the sole final runtime change is Mayu Maman's MD3.
Her 115 continuity assertions, all 296 action assertions and every presentation
pair use final land04. Her torso/sash material assignment now makes the ivory
bodice continuous. Front/profile/rear, face/hair/clothing, both
extreme strides, attack, pain, intermediate death and lying captures were inspected.
Each captured frame verifies ordered VIEW -> indexed pose PASS -> screenshot.
Earlier visual01 runs are diagnostic iterations, not final evidence.

One sequential 700-tic sprite/model pair per figure ran on Windows 11 Pro 26200,
Ryzen 9 5950X / 32 GB / RTX 3070 Ti driver32.0.16.1088 with the Parsec adapter,
GZDoom 4.14.2 Vulkan1280x720, uncapped without VSync, unpaused in the background
at 5% audio:

| Figure / scene | Queue presents/s | Present p95 / p99 / max (ms) | Simulation mean / p95 / p99 / max (ms) |
| --- | ---: | --- | --- |
| noshtex / sprite | 1973.43 | 0.6627 / 0.7569 / 1.1323 | 28.5713 / 28.9332 / 29.0299 / 29.1626 |
| noshtex / model | 1920.59 | 0.6643 / 0.7990 / 1.8496 | 28.5710 / 28.9198 / 29.0242 / 29.1537 |
| pampayoj / sprite | 1913.33 | 0.7202 / 0.8134 / 1.4007 | 28.5719 / 28.9300 / 29.0672 / 29.2465 |
| pampayoj / model | 1988.40 | 0.6430 / 0.7589 / 1.0261 | 28.5718 / 28.9324 / 29.0121 / 29.1942 |
| mayumaman / sprite | 2035.17 | 0.6082 / 0.7379 / 1.0608 | 28.5715 / 28.9075 / 29.0018 / 29.1234 |
| mayumaman / model | 1927.40 | 0.6611 / 0.7923 / 1.6176 | 28.5716 / 28.9305 / 29.0361 / 29.2946 |
| orkomaman / sprite | 1910.02 | 0.7065 / 0.8306 / 2.1102 | 28.5715 / 28.9637 / 29.1209 / 29.7228 |
| orkomaman / model | 1941.71 | 0.6919 / 0.7823 / 1.3860 | 28.5718 / 28.9183 / 29.0521 / 29.1663 |
| nowet / sprite | 1929.31 | 0.6886 / 0.7878 / 1.5662 | 28.5710 / 28.9461 / 29.0518 / 29.1096 |
| nowet / model | 1579.04 | 0.8481 / 1.4233 / 296.5928 | 28.5711 / 29.0901 / 38.0471 / 221.4049 |

Nowet's first model run had a 296.5928 ms queue-presentation tail and a 221.4049 ms simulation interval. One bounded sequential sprite/model repeat, with no native or validation job in parallel, records a model maximum of 1.5232 ms and simulation maximum of 29.2955 ms. Both runs are retained. The repeat does not identify the cause or establish repeatability or a performance improvement.

| Repeat / scene | Queue presents/s | Present p95 / p99 / max (ms) | Simulation mean / p95 / p99 / max (ms) |
| --- | ---: | --- | --- |
| nowet02 / sprite | 2017.09 | 0.6271 / 0.7595 / 1.0623 | 28.5713 / 28.9134 / 29.0201 / 29.3273 |
| nowet02 / model | 1898.60 | 0.6987 / 0.8002 / 1.5232 | 28.5720 / 28.9356 / 29.0640 / 29.2955 |

These queue intervals do not establish GPU/display latency, repeatability, an
optimization or campaign/crowd performance. The sprite baseline occupies different
screen coverage. Stylized component anatomy, painted faces, opaque hair and rigid
fall/rest remain candidates; broad silhouettes can exceed provisional collision.
CA819-LAND-01 remains pending. Evidence:
assets/validation_v5_17_88/evidence/SUMMARY.json.

Coverage reaches48/56 provisional classes;8 remain. Regional displays, other
characters, modular fitting, campaign authoring and siege rendering keep the full
batch unfinished. The consolidated author terminal remains deferred until completion.

## 5.17.87 - Native witch and rural figure candidates (#817)

Brujas/Brujos 001, Salamanca 002, Pericana 016 and Solapa 017 have distinct
native candidates based on their owned references. The elderly witch has gray
braided hair, a dark shawl/dress, ivory sleeves, boots and an herb pouch.
Salamanca has a middle-aged face, short gray hair/beard, a striped brown poncho,
shirt, trousers and boots. Pericana has long gray hair, pointed ears, a hooked
face, ragged layered clothes and claws. Solapa adds two braids, an apron and a
broad uneven straw hat to her forward-bent silhouette. These fixed items do not
create modular equipment or inventory. Editable controls, OBJ/MTL, animation,
contacts and original generated atlas/prompt/provenance are retained in
assets/source/art/witch_figures_817; texture pixels remain unchanged.

Sixteen exported files repeat byte-for-byte. The four designs contain 274
closed components, 270 rooted witnesses and 2,160 independent posed attachment
checks. All 23 inherited frames have noncollapsed triangles and material-cell
UV bounds. Serialized native checks verify the three closed skirts at both
extreme strides. Native review corrected hidden eyes, a concealed boot hem,
sleeve-shaped bare wrists and Salamanca's hair length. Closed braided strands,
the uneven straw brim and a clearer hooked nose preserve recognizable features.
Earlier source revisions, captures and failures remain in the evidence archive.

The final 18,609-entry package matches src exactly. Against #815 it adds six
model/material/binding resources and one MODELDEF include. Only two release
diagnostics change elsewhere. Scale, collision, statistics, combat timing,
abilities, loot, identity and saved fields remain unchanged. Reference metric
dimensions, new powers, population and campaign placement are not adopted.

Qualified evidence contains 702 native assertions: 460 continuity assertions
across previous-package baseline, old save, fresh model, reload and rollback;
242 actual action/loot/reload assertions. Solapa and all action tests use the
final package. An exact ZIP comparison proves that only solapa.md3 changed after
the three other continuity runs; their art, bindings, actor code, maps and saved
fields are identical. Regenerated fixture hashes also match for those species.
Front, profile, rear, face/hair/
clothing details, extreme strides, attack, pain, intermediate death and lying
poses were inspected. Final captures verify VIEW -> indexed pose PASS ->
screenshot ordering for every frame. Earlier visual runs and Solapa's first continuity/camera captures are diagnostic
only. Her final fitted hat band and lower face cameras have repeated native evidence.

One sequential 700-tic sprite/model pair per species ran on Windows 11 Pro 26200,
Ryzen 9 5950X / 32 GB / RTX 3070 Ti, GZDoom 4.14.2 Vulkan at 1280x720, uncapped
without VSync, unpaused in the background at 5% audio:

- witch/sprite: 1292.07 queue presents/s; presentation p95/p99/max 0.9646/1.1770/2.0811 ms; simulation mean/p95/p99/max 28.5713/29.0690/29.2339/29.4063 ms.
- witch/model: 1396.50 queue presents/s; presentation p95/p99/max 0.8562/1.0428/1.9632 ms; simulation mean/p95/p99/max 28.5714/29.0502/29.1906/29.3116 ms.
- salamanca/sprite: 1312.54 queue presents/s; presentation p95/p99/max 0.9249/1.1474/2.0708 ms; simulation mean/p95/p99/max 28.5709/29.1035/29.2253/29.5325 ms.
- salamanca/model: 1259.60 queue presents/s; presentation p95/p99/max 1.0015/1.2394/2.1103 ms; simulation mean/p95/p99/max 28.5717/29.2348/29.6054/30.3949 ms.
- pericana/sprite: 1312.94 queue presents/s; presentation p95/p99/max 0.9535/1.1786/2.1009 ms; simulation mean/p95/p99/max 28.5710/29.1460/29.2539/29.7363 ms.
- pericana/model: 1293.63 queue presents/s; presentation p95/p99/max 0.9585/1.1640/2.0931 ms; simulation mean/p95/p99/max 28.5713/29.1141/29.2499/29.7169 ms.
- solapa/sprite: 1289.88 queue presents/s; presentation p95/p99/max 0.9654/1.2013/2.3953 ms; simulation mean/p95/p99/max 28.5717/29.1243/29.2250/29.9983 ms.
- solapa/model: 1230.72 queue presents/s; presentation p95/p99/max 1.0207/1.2803/2.9698 ms; simulation mean/p95/p99/max 28.5709/29.2158/29.6031/30.1685 ms.

These queue intervals do not measure GPU/display latency, establish repeatability
or an optimization, or certify campaign/crowd performance. Stylized component
anatomy, painted faces, opaque hair and rigid fall/rest poses remain candidates;
broad silhouettes can exceed provisional collision. CA817-WITCH-01 remains
pending for the consolidated handoff. Evidence:
assets/validation_v5_17_87/evidence/SUMMARY.json.

Coverage reaches 43/56 provisional classes; 13 remain. Regional views, other
characters, modular fitting, campaign authoring and siege rendering still need
work before the complete batch and final author terminal are ready.

## 5.17.86 - Native austral figure candidates (#815)

Shoort 022, Tanu 023, Halahaches 024, Matan 025 and Ulen 026 now have distinct
native candidates based on their owned references. Shoort has a swept crest,
forearm spurs and red/ivory paint; Tanu has a broad body, horizontal horns,
open hood/veil, clothed chest and ornaments; Halahaches has tall horns, long
dark hair and ivory/red bands. Matan has a long mask nose, head cords/feathers
and dark/ivory paint; Ulen has a slender body, seven swept spines and curved
red/ivory markings. Fixed cloth, claws and ornaments do not add inventory.
Editable anatomy, animation, contact controls, OBJ/MTL and the unchanged original
built-in image_gen atlas/prompt/provenance live in assets/source/art/austral_figures_815.

Nineteen exported files repeat byte-for-byte. The five designs contain 389 closed
components, 384 rooted witnesses and 3,072 independent posed attachment checks.
All 23 inherited frames have noncollapsed triangles and valid material cells.
Open wraps intentionally expose legs; no closed-skirt containment is claimed.
Native review corrected body-paint discontinuities, an obscured Tanu forehead
and chest, a detached-looking rear belt loop and Halahaches hair buried in the
back. Earlier sources, captures and failed checks remain evidence.

The final 18,603-entry package matches src exactly. Against #813 it adds seven
model/material/binding resources and one MODELDEF include; only the two release
diagnostics change elsewhere. Scale, collision, statistics, combat timing,
abilities, loot, identity and saved fields remain unchanged. Reference metric
dimensions, new powers, population and campaign placement are not adopted.

Qualified native evidence contains 871 assertions: 575 continuity checks
across baseline, old save, fresh model, reload and rollback; 296 actual
action/loot/reload checks. Halahaches continuity and all actions use the final
package. Four continuity runs are reused from the immediately preceding package:
an exact ZIP comparison proves that only halahaches.md3 changed, with their
models, material, bindings, actor code, maps and saved-state definitions identical.
The separate reuse audit also bounds earlier reviewed static captures to unchanged
art. Front, profile, rear, face/horn/hair/cloth details, extreme strides, attack,
pain, intermediate death and lying views were inspected. Superseded visual runs
and the first screenshot-order/parser failures are diagnostic evidence only.

One sequential 700-tic sprite/model pair per species ran on Windows 11 Pro 26200,
Ryzen 9 5950X / 32 GB / RTX 3070 Ti, GZDoom 4.14.2 Vulkan at 1280x720, uncapped
without VSync, unpaused in the background at 5% audio:

- shoort/sprite: 1335.69 queue presents/s; presentation p95/p99/max 0.9010/1.1183/2.2243 ms; simulation mean/p95/p99/max 28.5717/29.1210/29.2577/29.7217 ms.
- shoort/model: 1268.71 queue presents/s; presentation p95/p99/max 0.9839/1.2130/2.1259 ms; simulation mean/p95/p99/max 28.5718/29.1018/29.2642/29.3993 ms.
- tanu/sprite: 1252.70 queue presents/s; presentation p95/p99/max 1.0082/1.2608/2.1119 ms; simulation mean/p95/p99/max 28.5715/29.1416/29.3111/29.5737 ms.
- tanu/model: 1274.16 queue presents/s; presentation p95/p99/max 0.9762/1.2021/2.2306 ms; simulation mean/p95/p99/max 28.5712/29.0964/29.3116/29.4166 ms.
- halahaches/sprite: 1273.11 queue presents/s; presentation p95/p99/max 1.0018/1.2491/2.3789 ms; simulation mean/p95/p99/max 28.5715/29.1385/29.2936/29.4199 ms.
- halahaches/model: 1276.50 queue presents/s; presentation p95/p99/max 0.9915/1.2315/2.0934 ms; simulation mean/p95/p99/max 28.5708/29.1751/29.4002/29.5209 ms.
- matan/sprite: 1306.93 queue presents/s; presentation p95/p99/max 0.9400/1.1827/1.9921 ms; simulation mean/p95/p99/max 28.5716/29.1492/29.4494/29.7051 ms.
- matan/model: 1269.29 queue presents/s; presentation p95/p99/max 0.9820/1.2035/2.2137 ms; simulation mean/p95/p99/max 28.5714/29.1132/29.3013/29.5134 ms.
- ulen/sprite: 1229.12 queue presents/s; presentation p95/p99/max 1.0294/1.5815/18.2177 ms; simulation mean/p95/p99/max 28.5713/29.1892/29.9203/40.7944 ms.
- ulen/model: 1252.79 queue presents/s; presentation p95/p99/max 1.0138/1.2158/2.1053 ms; simulation mean/p95/p99/max 28.5714/29.1140/29.2636/29.4368 ms.

These queue intervals do not measure GPU/display latency, establish repeatability
or an optimization, or certify a campaign/crowd budget. Stylized component anatomy,
painted faces, opaque hair and rigid fall/rest poses remain candidates. Wide
silhouettes may exceed provisional collision. CA815-AUSTRAL-01 remains pending
for the consolidated handoff. Evidence: assets/validation_v5_17_86/evidence/SUMMARY.json.
Native coverage reaches 39/56 provisional classes; 17 remain, alongside regional
views, other characters, modular fitting, campaign authoring and siege rendering.

## 5.17.85 - Native forest guardian candidates (#813)

Sachayoj 012, Caa Pora 013, Caa Yari 014 and Zapam Zucum 015 now use distinct
native models derived from their owned concepts. Sachayoj has bark, moss, leaves
and a long green-gray beard; Caa Pora has a broad furred body, long dark beard,
hand and toe claws, and a leather wrap. Caa Yari has long hair, a leaf-green
open-front dress and bare feet. Zapam Zucum has a shawl, ivory blouse, bare arms,
layered green/ivory skirt and boots. Their pointed ears, hair, anatomy and fixed
clothing belong to species art, not modular equipment or new inventory.
Editable controls, closed meshes, animation, contacts, OBJ/MTL and the unchanged
built-in image_gen material atlas and exact prompt/provenance live in
assets/source/art/forest_guardians_813.

Sixteen exported files repeat byte-for-byte. The four meshes contain 290 closed
components with 286 rooted witnesses and 2,288 independent posed contact checks.
All 23 inherited frames have noncollapsed triangles and valid material cells.
Independent serialized triangle coverage contains all 332 above-hem leg samples
for Zapam Zucum's two extreme strides; the other three designs have deliberately
open wraps or a front slit. This sample check does not certify all interpolation.
Native review corrected thin male limbs, short hair, obscured beards and Zapam
Zucum's clothing/boot silhouette. Initial failed witnesses, actual shawl overlap
correction, source revisions and superseded captures remain evidence.

The final 18,596-entry package matches src exactly, adds six model/material/
binding resources and one MODELDEF include, and changes only the two required
release diagnostics elsewhere. Existing actor scale, collision, statistics,
timing, abilities, loot, identity and saved fields remain unchanged. Concept
metre dimensions, new powers, population and campaign placement are not adopted.

All final-package native tests pass: 460 continuity assertions across baseline,
old save, fresh model, reload and rollback; 242 actual action/loot/reload checks.
Front, profile, rear, face/ear/hair/beard/clothing details, extreme strides,
attack, pain, intermediate death and oblique lying captures were inspected.
The 408 assertions from earlier visual iterations remain diagnostic evidence
and are not counted in the final 702.

One sequential 700-tic sprite/model pair per species ran on Windows 11 Pro 26200,
Ryzen 9 5950X / 32 GB / RTX 3070 Ti, GZDoom 4.14.2 Vulkan at 1280x720, uncapped
without VSync, unpaused in the background at 5% audio:

- sachayoj/sprite: 1819.21 queue presents/s; presentation p95/p99/max 0.7383/0.8492/1.3365 ms; simulation mean/p95/p99/max 28.5705/28.9449/29.0633/29.1984 ms.
- sachayoj/model: 1825.51 queue presents/s; presentation p95/p99/max 0.7039/0.8233/1.2877 ms; simulation mean/p95/p99/max 28.5716/28.9670/29.0958/29.3134 ms.
- caapora/sprite: 1853.29 queue presents/s; presentation p95/p99/max 0.7254/0.8055/1.3537 ms; simulation mean/p95/p99/max 28.5719/28.9752/29.0734/29.2233 ms.
- caapora/model: 1946.53 queue presents/s; presentation p95/p99/max 0.6948/0.8259/1.5661 ms; simulation mean/p95/p99/max 28.5711/28.9445/29.0645/29.1669 ms.
- caayari/sprite: 1897.88 queue presents/s; presentation p95/p99/max 0.6732/0.7847/1.2942 ms; simulation mean/p95/p99/max 28.5714/28.9516/29.0723/29.4205 ms.
- caayari/model: 1788.50 queue presents/s; presentation p95/p99/max 0.7230/0.8064/1.1650 ms; simulation mean/p95/p99/max 28.5719/28.9498/29.0541/29.1773 ms.
- zapamzucum/sprite: 1894.75 queue presents/s; presentation p95/p99/max 0.6999/0.8125/1.7055 ms; simulation mean/p95/p99/max 28.5708/28.9240/29.0484/29.2496 ms.
- zapamzucum/model: 1854.33 queue presents/s; presentation p95/p99/max 0.7285/0.8410/2.3239 ms; simulation mean/p95/p99/max 28.5709/28.9560/29.0942/30.2353 ms.

These queue intervals do not measure GPU/display latency, establish repeatability
or an optimization, or certify a campaign/crowd budget. Simplified closed anatomy,
painted faces, opaque hair/foliage and rigid fall/rest poses remain candidates;
wide silhouettes may exceed provisional collision. CA813-FOREST-01 remains
pending for the consolidated handoff. Evidence:
assets/validation_v5_17_85/evidence/SUMMARY.json. Native coverage reaches 34/56
provisional classes; 22 remain, alongside regional views, other characters,
modular fitting, authored campaign acquisitions and siege rendering.

## 5.17.84 - Native period apparition candidates (#811)

Viuda 031, Llorona 032 and Futre 033 now use distinct closed native models based on
their owned apparition concepts. Viuda has dark mourning lace, veil, high collar
and boots; Llorona has distressed ivory cloth, a scooped neckline, flared sleeves,
long dark hair and bare feet with toes; Futre is headless with an open collar,
brocade coat, cravat, sash, gloves and boots. Clothing is fixed species art, not
new inventory or modular equipment. Editable anatomy, hierarchy, material cells,
animation, contact witnesses and portable OBJ/MTL live in
assets/source/art/period_apparitions_811. Built-in image_gen originals and exact
prompts/provenance are retained unchanged, including the unused first atlas.
The refined atlas and finer cloth strip are separate generated sources.

Fourteen exports repeat byte-for-byte. The three models contain 144 closed
components with 141 rooted witnesses and 1128 independent posed contact checks.
All 23 inherited native frames have noncollapsed triangles, valid material cells
and grounded mesh-local bounds. Static geometry checks alone missed legs emerging
through skirts. A waist-anchored lower-cloth expansion and gentler visual gait
correct the native capture defect; independent ray intersections against the
serialized clothing triangles now contain 1488 above-hem leg samples in the two
extreme strides. Earlier failed checks and superseded captures remain evidence.
This bounded check does not establish every interpolation or garment fit.

The 18,590-entry final package matches src exactly. It adds six model/material/
binding resources and one MODELDEF include; only two required current-version
diagnostics change elsewhere. Actor scale, collision, statistics, combat timing,
loot, identity and saved fields are unchanged. No metric-scale adoption,
apparition power, population or campaign placement is introduced.

Native continuity checks pass 345 assertions; actual actions/loot/reload 188;
final views 153. The 686 qualified assertions include 584 reused checks bounded by
an exact package/MD3 audit. Relative to the earlier women's continuity and action
packages, only their six walk/run frames differ: positions change in 3/5/6/7;
2/4 retain exact positions/bounds with a few encoded-normal differences after
floating-point transforms. The other 17 frames, topology, UVs, all bindings and
gameplay bytes are exact. Futre is unchanged from its continuity package.
The final women's captures add 102 assertions on the final package. All three
presentation pairs use that final package. Front, profile, rear, face/hair/collar,
extreme stride, attack, pain, intermediate death and lying views were inspected.

One sequential 700-tic sprite/model pair per species on Windows 11 Pro 26200,
Ryzen 9 5950X / 32 GB/RTX 3070 Ti, GZDoom 4.14.2 Vulkan 1280x720, uncapped/no VSync,
unpaused in the background at 5% audio records:

- viuda/sprite: 1888.62 queue presents/s; presentation p95/p99/max 0.6968/0.8216/1.5740 ms; simulation mean/p95/p99/max 28.5712/28.9200/29.0579/29.1479 ms
- viuda/model: 1824.66 queue presents/s; presentation p95/p99/max 0.7225/0.8210/1.8081 ms; simulation mean/p95/p99/max 28.5709/28.9482/29.0570/29.1643 ms
- llorona/sprite: 1845.87 queue presents/s; presentation p95/p99/max 0.6370/0.7772/1.2857 ms; simulation mean/p95/p99/max 28.5713/28.9428/29.0284/29.2496 ms
- llorona/model: 1898.48 queue presents/s; presentation p95/p99/max 0.6413/0.7825/1.1686 ms; simulation mean/p95/p99/max 28.5721/28.9198/29.0209/29.3610 ms
- futre/sprite: 1792.38 queue presents/s; presentation p95/p99/max 0.7206/0.8058/1.7149 ms; simulation mean/p95/p99/max 28.5710/28.9632/29.1179/29.4332 ms
- futre/model: 1766.86 queue presents/s; presentation p95/p99/max 0.7700/0.8383/1.6016 ms; simulation mean/p95/p99/max 28.5714/28.9539/29.0883/29.3095 ms

These queue intervals are not GPU/display latency or a campaign/crowd budget.
One pair does not establish repeatability or an optimization. Simplified anatomy,
painted facial detail, opaque hair and rigid fall/rest articulation remain
candidates. CA811-PERIOD-01 retains author review for the consolidated handoff.
Evidence: assets/validation_v5_17_84/evidence/SUMMARY.json. Native coverage is now
30/56 provisional classes; 26 remain alongside the character, modular, campaign
and performance work. The complete batch remains unfinished.

## 5.17.83 - Head apparition regional inspection (#809)

The optional CA682G gallery adds Umita on Northwest Argentina with keyL;
CA709G adds Chonchon on Patagonia with F10. The former now has nineteen
figures/fourteen species/five grounds/twenty-five controls; the latter has
fifteen figures/twelve species/four grounds/twenty-two controls. All32 previous
figures,45 controls,nine grounds and both crossing routes remain exact.
Sources remain regional_gallery_682/709/GALLERY.json. Both interactive runners
are in assets/validation_v5_17_83: run_gallery.py and run_native_gallery.py.

The shared head export contains species associated with different gallery
regions. CA682G now selects only Umita through optional model_species data;
unselected exports still default to their complete species list. CA709G uses
its existing explicit Chonchon binding. Approved regional allocations, native
body clearance and unique keys pass. Only required700/682 dependency pins and
709 provenance refresh; all production artwork/materials remain exact.

Eight fixture files repeat byte-for-byte. Native checks pass81 fresh/166 reload
in CA682G and65 fresh/134 reload in CA709G:446 assertions, including native idle,
saved references and crossing movement. Both engines register all47 keys.
The two new closeups, expanded/reloaded overviews and presentation scenes were
inspected. Native key queries do not substitute for author keypress review.
No production stats, combat, collision, loot, flight, campaign or save schema
change; only two required release diagnostics differ from #806. All18,584
runtime package entries match src exactly.

One700-tic distant-overview sample per gallery records:

CA682G: 1454.38 queue presents/s; presentation intervals p95 0.8347ms, p99 0.9777ms, maximum 1.3562ms. Simulation mean 28.5706ms, p95 29.0548ms, p99 29.1644ms, maximum 29.4185ms.

CA709G: 1463.02 queue presents/s; presentation intervals p95 0.8453ms, p99 0.9681ms, maximum 1.5702ms. Simulation mean 28.5714ms, p95 29.0593ms, p99 29.1777ms, maximum 29.3588ms.

Environment: Windows11 Pro26200, Ryzen9 5950X/32GB/RTX3070Ti, GZDoom4.14.2,
Vulkan1280x720, uncapped/no VSync, background unpaused with5% audio. These
queue measurements do not establish GPU/display timing, repeatability,
comparative gains, close-up cost or campaign/crowd performance.

Evidence: assets/validation_v5_17_83/evidence/SUMMARY.json and its scope proof.
CA809-HEAD-GALLERIES-01 retains framing, native walking and regional review;
CA803-HEADS-01 retains model/combat review. All previous checks remain pending.
27/56 creature candidates have models; the remaining29, named/modular characters,
equipment fitting, first-person work and V5.16 progression/performance remain
unfinished. The consolidated terminal is deferred until the full batch is ready.

## 5.17.82 - Restore the original apparition release label (#806)

The #797 section heading again identifies its original 5.17.77 release. The
#799 current-version update had also changed this historical heading to 5.17.78.
The original commit 0e9593b7 and its 5.17.77 evidence establish the correct label;
the recorded artwork, scope and test results are unchanged. Forty headings
across four documents and ten adjacent deliveries were compared with their
original commits; only the four #797 headings differed.

This correction changes no model, texture, binding or gameplay behavior. Only
the two required runtime release diagnostic strings advance. Existing native
evidence remains applicable; no new engine or author acceptance is claimed.
Evidence: assets/validation_v5_17_82/evidence/SUMMARY.json. All pending author
tests are retained, and the full batch still precedes the consolidated terminal.

## 5.17.81 - Correct descriptive model identities (#805)

Three ANIMATION.json identity_policy strings still described the earlier
Familiar/Ao Ao classes 043/050. Their actual configured/native classes and tested
art were already correct. The descriptions now name Teju Jagua (047)/Selva,
Kasogonaga (057)/Chaco, Mulanima (029)/Northwest Argentina and Chancho de Lata (030)/Pampa/
Litoral. REGION_PROPOSAL.json remains the regional authority. A shared text/class
check is applied only by these three affected validators; it rejects all three
original mismatches and accepts the corrected descriptions.

The three regenerated export reports change only their own ANIMATION source
hashes. All 27 outputs repeat across two generations; the 24 native/editable
artifacts match their preceding hashes and installed bytes. The optional regional fixture,
its ZScript and TEXTMAP also remain byte-identical. No dependent canonical pin
requires an update. The later heads_803 provenance retains its original inherited
animation snapshot rather than silently repinning historical evidence.

The package matches src, with only the two required diagnostic release strings
different from 5.17.80. All art, actor rules, bindings, state timing, collision,
save identity, loot and regional layout remain unchanged. The prior applicable
native evidence is reused; this metadata correction adds no engine or author
acceptance. Evidence: assets/validation_v5_17_81/evidence/SUMMARY.json.
Pending author tests are byte-identical. #806 and the wider batch remain pending.

## 5.17.80 - Native Umita and Chonchon head candidates (#803)

CaelumBestiary028/035 now use distinct closed head models based on their owned
concepts. Umita has a pale deformed face, clouded eyes, long gray hair and beard;
Chonchon has an aged face, hooked nose, short dark hair and membrane ear-wings.
Face colors follow the actual deformed cranium. Hair/beard locks, wing bones
and membranes have volume; these are not camera-facing pictures. Editable
shape/hierarchy/material/pose/contact data and portable OBJ/MTL live in
assets/source/art/heads_803. The original nine-cell built-in image_gen atlas is
copied unchanged; MATERIALS_PROMPT.json preserves the exact prompt and source.
Owned Peuchen wing topology and inherited animation mappings retain provenance.

- umita: 17,114 vertices, 27,552 triangles, 29 closed components, 28 rooted witnesses and 224 independently checked posed contacts
- chonchon: 14,466 vertices, 23,312 triangles, 36 closed components, 35 rooted witnesses and 280 independently checked posed contacts

Ten artifacts repeat byte-for-byte. All 23 inherited frames have noncollapsed
native triangles, and 28,414 native material UV vertices remain within their
assigned atlas cells/face rectangles. The serialized OBJ and neutral MD3
triangles agree. Sixty-three rooted joints pass 504 independent moved-witness
checks across idle, attack, final death and rest. The mesh-local floor is zero;
the authored MODELDEF offset is 16 model units and remains through fall/rest.
It is a visual hover, not flight or a physics change.

The initial clipped-pole facial primitive produced collapsed MD3 triangles.
True pole fans correct it, following CA-KP-242. The first export also exposed
material-cell overflow and wing witnesses unsuitable after transformation;
new facial UV mapping, extended thumb roots and rechecked overlap correct those
defects. One repeat per hair lock reduces the observed texture repetition.
Original image pixels remain exact. Earlier diagnostics stay in the evidence.

The 18,584-entry tested package matches src exactly. Four new
model assets/bindings and their MODELDEF include are the only art/runtime additions;
the two current-version diagnostics also advance. All unrelated runtime bytes
match 5.17.79. Native baseline/old-save/fresh/reload/rollback tests pass 230 assertions;
actual actions/loot/reload pass 134, including the unchanged Mandinga control:
364 native assertions, plus 51 after the final Chonchon pose refinement. Both
final 23-pose capture sets contain their model. Final
frontal, side, rear, face/hair/wing details and selected run/attack/pain/lying
captures were inspected. Existing provisional collision, scale policy, combat
timing, statistics, rewards, identity and saved fields remain unchanged.

A final visual correction folds Chonchon's wings progressively through death
and rest. The earlier pose perched on a wing tip despite a zero mesh-local
floor. A binary package/MD3 audit proves only frames 12-17/22 changed; all other
runtime/art bytes, topology, UVs and bindings are exact. Earlier 364 functional
assertions and idle presentation samples remain applicable to unchanged behavior
and frames; 51 additional native assertions and final captures verify the changed
model. Earlier Chonchon death/rest captures are superseded, not author-approved.

One sequential 700-tic sprite/model pair per species on Windows 11 Pro 26200,
Ryzen 9 5950X/32GB/RTX 3070 Ti, GZDoom 4.14.2 Vulkan 1280x720, uncapped/no VSync,
background unpaused and 5% audio observes:

- umita/sprite: 1818.41 queue presents/s, p95 0.7384ms, p99 0.8397ms, maximum 1.3782ms
- umita/model: 1848.67 queue presents/s, p95 0.6541ms, p99 0.7735ms, maximum 1.0516ms
- chonchon/sprite: 1849.85 queue presents/s, p95 0.6593ms, p99 0.7938ms, maximum 1.1076ms
- chonchon/model: 1789.75 queue presents/s, p95 0.7113ms, p99 0.7946ms, maximum 1.2404ms

These are queue intervals, not GPU/display latency or campaign/crowd budgets.
One pair does not establish repeatability or an optimization. Simplified closed
component anatomy, opaque hair, projected facial detail, broad wing silhouettes
and rigid fall/rest poses remain candidates. Conceptual metre sizes, flight,
apparition powers, new encounter rules and campaign placement are not implemented.
CA803-HEADS-01 retains author review in the final consolidated handoff. Evidence:
assets/validation_v5_17_80/evidence/SUMMARY.json. Native candidates cover 27 of 56
provisional classes; 29 remain, alongside other character/modular/campaign work.

## 5.17.79 - Apparition regional inspection (#801)

The optional CA682G gallery adds Mulanima on the existing Northwest Argentina
plot and Chancho de Lata on Pampa/Litoral, following REGION_PROPOSAL.json.
Eighteen figures cover thirteen species across five existing grounds. Key0
shows Mulanima; J and K show the Pampa/Litoral boar displays. All fifteen
previous figures, twenty-one controls, grounds and the four-boundary crossing
path remain exact. The diagnostic key validator now also admits J/K; GZDoom registration/query
checks all24 bindings. Interactive keypress acceptance remains pending.
Current source: assets/source/art/regional_gallery_682/
GALLERY.json; runner: assets/validation_v5_17_79/run_gallery.py.

No production model, image, material, balance, behavior, campaign placement or
saved field changes. Only source pins/manifests in regional_gallery_700/682
and CA709G provenance refresh. All native artwork and the CA709G layout remain
exact. Approved allocations and nonoverlapping native bodies pass. Four fixture
files repeat byte-for-byte. Fresh checks pass77 assertions and reload/native
idle/walking158. Three added closeups, the expanded overview, retained grounds,
reloaded overview and presentation scene were inspected. Diagnostic observer
silence does not change production perception or native motion speed.

One700-tic distant overview observes1452.86 queue presents/s,
p95 0.8448ms, p99 0.9950ms,
maximum 1.2845ms. Windows11 Pro26200,
Ryzen9 5950X/32GB/RTX3070Ti, GZDoom4.14.2 Vulkan1280x720, uncapped/no VSync,
background unpaused at5% audio. This single cohort does not establish display/
GPU timing, comparative gains, repeatability, close-up cost or campaign/crowd
performance. All18,580 package entries match src;
only two release diagnostics differ from #799.

Evidence: assets/validation_v5_17_79/evidence/SUMMARY.json.
CA801-APPARITIONS-GALLERY-01 retains framing, ground and walking review;
CA797-APPARITIONS-01 retains model/combat review. All prior author checks remain.
Thirty-one of56 provisional creature models, named/modular characters, fitting,
V5.16 progression and siege performance remain unfinished. The requested
consolidated terminal is deferred until the full batch is complete.

## 5.17.78 - Keep swept textures inside their material cells (#799)

Ao Ao's two curled horns now use66 samples for3 repeats and its short tail21
for3. Kasogonaga's six back locks use16 samples for2 repeats. This repairs the
nonintegral period that let texture coordinates cross into adjacent atlas cells.
Controls, original images, motion, actor rules, collision, state timing, rewards
and saved fields remain unchanged. Editable sources and affected exports were
regenerated; Familiar and all unrelated runtime resources remain byte-identical
apart from current diagnostic version strings.

The shared native model validator rejects nonpositive, noninteger or indivisible
sweep sample/repeat counts with an identified shape. The bounded active-source
audit checks186 sweeps in22 design files
and rejects all nine recorded old grids. Serialized MD3 UV inspection originally
found160 vertices outside their authored cells;
the final nine sweeps have zero. Twenty-one artifacts regenerate byte-identically,
and closed/posed geometry validation passes. Native continuity passes230 checks,
actual action/loot/reload134, and the existing regional gallery199:563 total.
The18,580-entry package matches src exactly.

Affected fur, horns/tail, selected combat poses and Ao Ao's regional view were
inspected. One sequential700-tic before/after native-model presentation pair per
species on the recorded Windows11/Ryzen5950X/RTX3070Ti environment, GZDoom4.14.2
Vulkan1280x720, uncapped/no VSync, background unpaused and5% audio observes:

- ao_ao/before: 1819.84 queue presents/s, p95 0.7730ms, p99 0.8336ms, maximum 1.5019ms
- ao_ao/after: 1814.62 queue presents/s, p95 0.6636ms, p99 0.7940ms, maximum 2.0635ms
- kasogonaga/before: 1894.81 queue presents/s, p95 0.6528ms, p99 0.7954ms, maximum 1.4449ms
- kasogonaga/after: 1826.18 queue presents/s, p95 0.6944ms, p99 0.8192ms, maximum 2.6078ms

The reused runner's sprite/model labels mean pre/post repair here; both are
native models. Queue and tic tails do not establish display latency, repeatability
or campaign/crowd budgets. Source/art quality remains pending CA799-UV-01 alongside
CA787-QUADRUPEDS-01 and CA795-KASOGONAGA-01. Evidence:
assets/validation_v5_17_78/evidence/SUMMARY.json; reusable lesson CA-KP-249.
No author test is removed. Remaining characters, modular fitting, progression
and siege performance still precede the requested consolidated terminal.

## 5.17.77 - Native mule and plated-boar apparitions (#797)

CaelumBestiary029/030 now use distinct editable native candidates from the owned
Mulanima and Chancho de Lata concepts. Mulanima has a dark equine torso/neck,
downward muzzle, upright long ears, four undivided hooves and mane/tail ember
forms. Chancho de Lata has a plated torso and snout, rivets, pointed ears,
upward tusks, cloven hooves and a curled metal tail. Closed radial shell patches
give the plates actual thickness. Geometry, hierarchy, materials, contacts,
animation controls and portable OBJ/MTL are in assets/source/art/apparitions_797.
The original built-in image_gen nine-cell atlas is unchanged; its exact prompt
and original path are in MATERIALS_PROMPT.json. Owned quadruped motion, Ao Ao
limb topology and iris/dark pixels retain provenance.

- mulanima: 11,862 vertices, 21,172 triangles, 48 closed components, 47 rooted witnesses and 376 independent posed contacts
- chancho_lata: 20,392 vertices, 32,184 triangles, 124 closed components, 123 rooted witnesses and 984 independent posed contacts

Both models cover23 inherited combat frames with floor support and no collapsed
native triangles. Twelve artifacts regenerate byte-identically. The existing
provisional Mandinga behavior, collision, state timing, scale policy, statistics,
loot, identity and save fields remain unchanged. Ember shapes add no flame/light
system or damage; metal panels add no armor bonus. Conceptual metre sizes are
not adopted, and no campaign encounter or apparition power is added.

The18,580-entry tested package matches src exactly; all
unrelated runtime bytes match5.17.76. Each species passes115 baseline/old-save/
fresh/reload/rollback assertions. Joint action/loot/reload passes134 more, with
nine actual cases including the existing Mandinga control:364 native assertions
total. All46 pose captures contain their model. Final fronts/sides/rears,
heads/tails, hooves/plates and selected locomotion, attack, pain and lying poses
were inspected. Source refinements followed the first native review.

An odd tessellation/repeat ratio initially put new flame-tail UVs beyond their
atlas cell. Integral sampling repaired these new curves; the final checks pass.
The bounded audit also found older Ao Ao/Kasogonaga curves requiring a separate
#799 correction and shared validation guard before the final author handoff.

One sequential700-tic sprite/model pair per species on Windows11 Pro26200,
Ryzen9 5950X/32GB/RTX3070Ti, GZDoom4.14.2 Vulkan1280x720, uncapped/no VSync,
background unpaused and5% audio observes:

- mulanima/sprite: 1898.07 queue presents/s, p95 0.6238ms, p99 0.7691ms, maximum 1.0883ms
- mulanima/model: 1832.79 queue presents/s, p95 0.6668ms, p99 0.7894ms, maximum 1.6027ms
- chancho_lata/sprite: 1887.80 queue presents/s, p95 0.6770ms, p99 0.7835ms, maximum 1.1447ms
- chancho_lata/model: 1817.32 queue presents/s, p95 0.6565ms, p99 0.7920ms, maximum 1.0833ms

Queue timing does not establish GPU/display latency, repeatability, campaign or
crowd budgets; sprite/model footprints differ. Siege performance is unresolved.
Evidence: assets/validation_v5_17_77/evidence/SUMMARY.json.
CA797-APPARITIONS-01 retains author review of anatomy, material readability,
opaque ember forms, plate/tusk silhouettes and rigid fall/rest articulation.
Native candidates cover25 of56 provisional classes;31 remain. Regional placement,
other characters, modular fitting and V5.16 progression remain unfinished.

## 5.17.76 - Native Kasogonaga candidate (#795)

CaelumBestiary057 now has an editable anteater-like native model from the owned
Kasogonaga reference: elongated tapered snout, small lateral eyes and ears,
arched grey body with ivory fur markings, four clawed limbs and a broad brush
tail. Geometry, hierarchy, contact witnesses, animation data and OBJ/MTL sources
live in assets/source/art/kasogonaga_795. The original built-in image_gen atlas
is unchanged; MATERIALS_PROMPT.json retains the exact prompt and original path.
Owned Familiar joint/limb topology and iris/dark pixels retain provenance.
Surface-marking rules live in the editable shape data; the generator assigns
existing material cells without image postprocessing or gameplay constants.

The model has17,063 vertices,29,036 triangles,
75 closed components,74 rooted witnesses and592 independent posed contacts.
All23 inherited combat frames are floor-supported with zero collapsed native
triangles. Nine artifacts repeat byte-for-byte. The new MODELDEF binds only
CaelumBestiary057; combat, collision, native timings, identity, loot and save
fields remain unchanged. Conceptual metres do not set runtime size, and the
reference's weather association does not introduce a new ability.

The18,574-entry package matches src exactly; all unrelated
runtime bytes match5.17.75. Native baseline/old-save/fresh/reload/rollback passes
115 assertions. Active actions/loot/reload passes80 more, including six cases
with the existing Mandinga control. All23 pose captures contain the model. A further51 native visual assertions
cover the final inspection cameras on identical runtime/model bytes.
Final front/side/rear, face/snout/tail, locomotion, attack, pain and lying views
were inspected. Initial ear contacts were repaired; native review reduced eye
size, restored grey face fur, added face markings and widened the front view.
Superseded reports remain evidence. Final cameras use an oblique pose view and
frame the long snout/tail; the prior continuity fixture remains qualified by its
recorded camera layout, with unchanged native model bytes.

One sequential700-tic sprite/model pair on Windows11 Pro26200, Ryzen9 5950X,
32GB/RTX3070Ti, GZDoom4.14.2 Vulkan1280x720, uncapped/no VSync, background unpaused
and5% audio observes:

- sprite: 1865.05 queue presents/s, p95 0.7349ms, p99 0.8049ms, maximum 1.5089ms
- model: 1843.93 queue presents/s, p95 0.6815ms, p99 0.8188ms, maximum 1.3091ms

These queue intervals do not establish GPU/display latency, repeatability or
campaign/crowd budgets. Footprints differ; siege performance remains unresolved.
Evidence: assets/validation_v5_17_76/evidence/SUMMARY.json.
CA795-KASOGONAGA-01 retains author review of rounded anatomy, coarse fur markings,
crest/brush locks and rigid fall/rest poses. Horizontal anatomy extends beyond
unchanged collision. Regional placement remains separate; no Chaco ground is
invented. Native candidates cover23 of56 provisional classes;33 remain. Other
characters, modular fitting and V5.16 progression remain unfinished, with the
test terminal deferred until the full requested batch is complete.

## 5.17.75 - Teju Jagua regional inspection (#793)

The optional CA682G gallery adds native Teju Jagua on its approved Selva plot.
Fifteen figures cover eleven species across five existing grounds. Key9 shows
all seven heads from the front; the fourteen previous positions, twenty controls
and four-boundary crossing path remain exact. The authoritative source remains
assets/source/art/regional_gallery_682/GALLERY.json; the current runner is
assets/validation_v5_17_75/run_gallery.py. No production model, ground, campaign
placement, balance, behavior or saved field changes.

The approved allocation and nonoverlapping native bodies pass. Four fixture
files repeat byte-for-byte. Only dependent source pins/manifests change in
regional_gallery_700/682 and CA709G provenance; all five native materials and
the CA709G layout remain exact. GZDoom passes65 fresh and134 reload/idle/walking
assertions. The added closeup, overview, Selva ground, reloaded overview and
presentation scene were inspected. Existing subjects retain their original
positions and passive native idle animations; the diagnostic observer remains
silent, with production perception and speed unchanged.

One700-tic distant overview observes 1507.33 queue presents/s,
p95 0.8117ms, p99 0.9661ms,
maximum 1.5062ms. Windows11 Pro26200,
Ryzen9 5950X/32GB/RTX3070Ti, GZDoom4.14.2 Vulkan1280x720, uncapped/no VSync,
background unpaused,5% audio. This single cohort does not establish display/GPU
timing, comparative gains, repeatability, close-up cost or campaign/crowd
performance. All18,569 package entries match src; only two release diagnostics
differ from the #791 package.

Evidence: assets/validation_v5_17_75/evidence/SUMMARY.json.
CA793-TEJU-GALLERY-01 awaits the consolidated author review of framing, ground
transitions and walking; CA791-TEJU-01 retains separate model/combat review.
No author check is removed. Thirty-four of56 provisional catalogue models,
other characters, modular conversion/fitting, remaining V5.16 progression and
siege performance remain unfinished. The final author terminal stays deferred
until the requested batch is complete.

## 5.17.74 - Native seven-headed Teju Jagua (#791)

CaelumBestiary047 now has an editable native candidate based on the supplied
Teju Jagua reference: seven distinct canine heads with articulated jaws, a
scaled quadruped body, four clawed feet, dorsal spines and a curved tapering
tail. Source geometry, hierarchy, attachment witnesses, poses and OBJ/MTL live
in assets/source/art/teju_791. The new built-in image_gen diffuse atlas remains
unchanged; MATERIALS_PROMPT.json preserves its exact prompt and original path.
Owned Familiar component topology and existing iris/dark pixels retain provenance.

The model has36,400 vertices,54,164 triangles,210 closed components and209 rooted
attachment witnesses. Independent native checks cover1,672 posed contacts,
all23 inherited combat frames, floor support and zero collapsed triangles.
Nine artifacts regenerate byte-identically. Only this class's MODELDEF and
model/material resources are added; behavior, state timings, collision, scale
policy, loot, identity and save fields remain unchanged. Seven heads do not
multiply attacks. Reference metre sizes do not set runtime size.

The18,569-entry package matches src exactly; all unrelated runtime bytes match
5.17.73. Native baseline/old-save/fresh/reload/rollback passes115 assertions;
attack/death/loot/reload passes80 more, including six actual action cases with
the existing Mandinga control. All23 pose captures contain the model. Selected
front, side, rear, head, tail, locomotion, attack, pain and lying captures were
inspected. Initial donor-tail, cap-witness and tiny-pupil defects were corrected
before final tests; superseded reports remain evidence.

One sequential700-tic sprite/model pair on Windows11 Pro26200, Ryzen9 5950X,
32GB/RTX3070Ti, GZDoom4.14.2 Vulkan1280x720, uncapped/no VSync, background unpaused
and5% audio observed:

- sprite: 1887.34 queue presents/s, p95 0.6788 ms, p99 0.7817 ms, maximum 1.1669 ms
- model: 1843.51 queue presents/s, p95 0.7080 ms, p99 0.7821 ms, maximum 1.0602 ms

These are queue intervals, not GPU/display latency, repeatability or a crowd
budget. Sprite/model footprints differ; siege performance remains unresolved.
Evidence: assets/validation_v5_17_74/evidence/SUMMARY.json. Candidate rounded
anatomy, elongated neck fan, broad scales and rigid fall/rest poses await
CA791-TEJU-01. Conceptual scale and species-specific behavior are not implemented.
Twenty-two of56 provisional catalogue classes now have models;34 remain.
Regional gallery placement is separate. Other characters, modular fitting and
unauthored V5.16 progression remain unfinished. The author's2026-11-15 request
retains one consolidated test handoff and defers acceptance until that review.

## 5.17.73 - Familiar and Ao Ao regional inspection (#790)

The optional CA682G gallery adds the native Familiar on the approved Northwest
Argentina plot and Ao Ao in Selva. Fourteen figures cover ten species across
five existing grounds. Keys7/8 inspect the new figures; the twelve prior positions,
eighteen controls and four-boundary crossing path remain exact. The source stays
assets/source/art/regional_gallery_682/GALLERY.json; regenerate with
assets/validation_v5_17_73/build_gallery.py. No production model, texture, map,
encounter, balance, saved field or actor behavior changes.

All approved associations and nonoverlapping native bodies pass. Four fixture
outputs repeat byte-for-byte. Source hash changes refresh Cuyo700 and Pampa/NOA682
INVENTORY/EXPORT metadata and two CA709G provenance pins. All five generated
material resources remain exact; the CA709G layout is unchanged. The native
engine passes61 fresh and126 reload/idle/walking assertions. Both added closeups,
overview, NOA/Selva ground repeats, reloaded overview and presentation scene were
inspected. Earlier unchanged artwork retains its evidence. Friendly/passive
native figures advance existing idle states; only this diagnostic observer's
footstep noise is suppressed. Production perception and speed remain unchanged.

One700-tic overview cohort observes 1576.72 queue presents/s,
p95 0.8202ms, p99 0.9466ms,
maximum 1.2676ms. Windows11 Pro26200,
Ryzen9 5950X/32GB/RTX3070Ti, GZDoom4.14.2 Vulkan1280x720, uncapped/no VSync,
background unpaused,5% audio. This distant-overview sample does not establish
comparison gains, close-up cost, repeatability, GPU/display timing or campaign
and crowded-map performance. All18,564 package entries match src; only two
release diagnostics differ from the #787 package.

Evidence: assets/validation_v5_17_73/evidence/SUMMARY.json.
CA790-QUADRUPED-GALLERY-01 retains author framing, ground-transition and walking
review. CA787-QUADRUPEDS-01 separately retains model art and ordinary combat
review. All earlier author checks remain pending. Thirty-five of56 provisional
catalogue models, other characters, modular style/fitting, unauthored V5.16
progression and siege performance remain unfinished.

## 5.17.72 - Familiar and Ao Ao quadruped candidates (#787)

CaelumBestiary043 and050 now use original native models based on the supplied
black mastiff and woolly ram references. Familiar has drooping ears, amber eyes,
jowls, four clawed paws and a swept tail. Ao Ao has paired curled horns, short
ears, horizontal pupils, wool locks, cloven hooves and a short tail. Editable
shape/pose data, OBJ/MTL and provenance live in assets/source/art/quadrupeds_787.
One new built-in image_gen diffuse atlas is copied unchanged; MATERIALS_PROMPT.json
records its exact prompt and original path. Iris/dark sources retain provenance.
Wool uses explicit UV repeats with seam vertices; nose width narrows below center.

The two models contain 36,800 vertices and 47,376 triangles in total, 113 closed
components and 111 rooted attachment witnesses. Independent checks cover 888
posed attachments, all 23 existing combat frames per creature, floor contact
and quantized triangles. Twelve generated artifacts repeat byte for byte;
installed output/source checks pass. Only exact MODELDEF aliases and owned model
resources are added. Existing Mandinga statistics, collision, movement, attacks,
state timings, loot, class identities and save fields remain unchanged. Visual
standing height follows that provisional profile, not conceptual metre sizes.
Horizontal silhouettes and lying poses extend beyond its unchanged collision.

The final 18,564-entry package matches src exactly. Five-phase native baseline,
old-save, fresh, reload and rollback checks pass 115 assertions per species;
action/death/loot/reload checks pass another 134, including nine action cases
with the unchanged Mandinga control. Thirty-six final captures were inspected:
eight views and ten representative action poses per species. Initial eye bulges,
contrasting muzzle, high horn coils and coarse wool mapping were refined before
the final build. Superseded geometry and visual evidence remain recorded.

One sequential 700-tic sprite/model pair per species, Windows11 Pro26200,
Ryzen9 5950X/32GB/RTX3070Ti, GZDoom4.14.2 Vulkan at1280x720, background unpaused,
5% audio, uncapped/no VSync: Familiar observed1906.14/1881.20 queue presents/s,
p95 0.6471/0.6648ms, p99 0.8224/0.7959ms, maximum1.2519/1.1987ms; Ao Ao observed
1791.59/1843.13, p95 0.7533/0.6764ms, p99 0.8949/0.8050ms, maximum1.3875/1.2546ms.
Mean simulation spacing was approximately28.571ms. All four scenes were inspected.
These bounded queue measurements do not establish GPU/display latency,
repeatability, crowd/campaign performance or resolution of the siege limitation.
Sprite and model silhouettes/projected footprints differ.

Evidence: assets/validation_v5_17_72/evidence/SUMMARY.json. Run
`python assets/validation_v5_17_72/run_quadrupeds.py --species familiar --runtime build/caelum_argenteum_dev.pk3 --output build/ca787-familiar-review --interactive`;
repeat with `--species ao_ao` and another new output directory. F1-F10 select
documented poses; 1-9 select views. CA787-QUADRUPEDS-01 awaits author review of
simplified rounded anatomy, broad/faceted noses and horns, repeated matte fur/wool,
simple joint rotations and rigid falling/rest poses. These are candidate art,
not exact concept reproduction or ordinary-gameplay acceptance. Twenty-one of
the56 provisional new catalogue classes now have native models;35 remain.
Regional gallery additions are separate. Named characters, player modular style
and fitting, unauthored V5.16 progression and siege performance remain unfinished.

## 5.17.71 - Exact inventory default-state bindings (#785)

The reproducible native audit reads recursively included ZSCRIPT/MODELDEF from
its supplied runtime. Of 597 project Inventory defaults, 87 visible droppable
states are inspected, alongside 315 legal weapon combinations, 342 material
inputs, 48 armor, 25 clothing, 12 shields, 12 amulets and 15 seals: 856 rows.
Some material-tier inputs normalize to one identity. All observed rows now have
direct class/sprite/frame bindings; fixture bytes, census and rows repeat.

Two ancestor-only candidates actually rendered sprites: CA_LimboMagicImplement
at CSWD A and CaelumJavelinAmmo at CCAA A. Explicit child aliases reuse the
current sword and carbine-ammunition models exactly. The base javelin class keeps
its existing carbine default; real tiered javelins retain their separate models.
No new pixels, geometry, gameplay, class identity or persistence data are added.
Twelve final detail captures and the overview were inspected beside the two
parent controls. The baseline/final view fixture is identical and passes 32
metadata/camera checks on each package. Its first strict scale comparison was
corrected for declared0.100000001 versus settled0.100000000; gameplay is unchanged.

Run `python assets/validation_v5_17_71/run_inventory_model_audit.py --runtime build/caelum_argenteum_dev.pk3 --output build/ca785-audit` and
`python assets/validation_v5_17_71/run_inherited_defaults.py --runtime build/caelum_argenteum_dev.pk3 --output build/ca785-views` using new output directories.
The alias checker is integrated into validate_project.py. Evidence:
assets/validation_v5_17_71/evidence/SUMMARY.json. CA-KP-248 records the diagnostic
pitfalls. Exact state association is bounded coverage, not certification of all
future/custom subclasses, ordinary handling or art acceptance. Existing author
checks remain pending. Other characters, modular fitting and V5.16 remain open.

## 5.17.70 - Native torso armor drops (#783)

Four original cuirasses replace only CAMA, CALI, CMAR and CAHV in the torso
slot of CaelumArmorPickup. Magic/light/medium/heavy retain three qualities each,
for twelve cases. The effective references remain ca_armor_magic.png,
ca_armor_light.png, ca_armor_medium.png and ca_armor_heavy.png. Inventory art,
protection, scale/collision, size, weight, durability, crafting and persistence
are unchanged. Earlier helmet/hand/foot models and the medium Anima potion's
separate CAMD identity are retained. These drops do not deliver worn fitting.

Editable DESIGN/OBJ/MTL and provenance: inventory_models_647/armor_torso.
Original closed, thin-walled cuirasses have real neck, waist and arm apertures;
fixed plates, shoulders, belts, trim, rivets, scarf and cape follow the owned
icon distinctions. Independent checks verify 135,452 vertices, 53,620 triangles,
119 closed components, 115 fixed attachments and 80 opening rays. Twenty-one
exports repeat byte-for-byte. No shared geometry generator changed.

One new opaque cream/beige fur material, fur.png, was generated with built-in
image_gen and copied unchanged to the source and runtime folders. FUR_BRIEF.json
and FUR_PROMPT.json record the brief, exact prompt, tool and original path.
Its SHA256 is e677512823f47e67853da3384d24be09fde84862066a35221da8632b2c1d2329.
All existing raster pixels remain unchanged. Red/navy icon samples retain their
original minimum alpha 253/252. The new fur is fully opaque.

Initial checks corrected shell-rim UV collapse and a cape witness on its boundary.
Native review improved plate/material separation, trim, rivets and the light strap;
rounded clumps and then pointed tufts were replaced with a continuous curved fur
mantle. Superseded evidence is retained. Twenty inspected detail/underside views
cover the final models: ten new medium/heavy views, and ten earlier magic/light
views reused only after their final MD3 bytes were proven identical. The final
overview was inspected. Shared simplified cuirass outlines, disc-like shoulders,
faceted trim, static cape/scarf, repeated matte materials, simplified fur patches,
interpreted backs and omitted ornament remain author-review qualifications.

GZDoom 4.14.2 passes 1,011 native pickup/equip/toss and old-save/reload/rollback
assertions, plus 236 visual/control assertions. A 157-assertion regression checks
the earlier medium armor slots and separate Anima potion; its overview was
inspected. Prepared API transactions do not prove ordinary menus, crafting,
manual handling or author acceptance.

Both twelve-object, 700-tic presentation scenes were inspected. Sprite/model
queue rates were 1129.21/1063.21 per second, p95 1.071/1.108ms
and p99 1.315/1.231ms. This single sequential pair measures queue
intervals, not GPU/display latency, repeatability or campaign performance.
Projected footprints differ. Evidence: assets/validation_v5_17_70/evidence/SUMMARY.json.
CA783-TORSO-ARMOR-01 remains pending. All sixteen regular armor states now have
model candidates; ancestor-only pickup bindings still need audit. Other characters,
modular equipment and the wider V5.16 request remain unfinished.

## 5.17.69 - Native foot armor drops (#781)

Four original boot pairs replace only CBOM, CBLT, CBMD and CBHV in the foot
slot of CaelumArmorPickup. Magic/light/medium/heavy retain three qualities each,
for twelve cases. Effective references are the unchanged ca_boots.png,
ca_boots_light.png, ca_boots_medium.png and ca_boots_heavy.png aliases.
Inventory art, protection, scale/collision, size, weight, durability, crafting
and persistence are unchanged. Clothing footwear retains its own models.
These world drops do not deliver worn modular fitting.

Editable DESIGN/OBJ/MTL and provenance: inventory_models_647/armor_feet.
The original owned hollow footwear anatomy supplies soles, heels and lining.
New fixed toe caps, straps, open buckle frames/pins, curved shin plates, gold
trim and blue cloth adapt the existing armor references. All raster pixels
remain unchanged; the blue sample comes from the original magic-boot icon.
Independent checks verify 121,020 vertices, 53,432 triangles, 120 closed
components, 112 fixed attachments, 40 opening rays, eight shaft-depth probes
and eight lining-visibility probes. Seventeen exports repeat byte-for-byte.

Initial geometry exceeded the magic reference width by 2.65 source-scale pixels;
a 3% horizontal fit corrected the envelope without changing actor scale/collision.
Native review replaced solid light buckles with open frames and improved curved
shin-plate subdivisions/clearance and raised gold attachment. Superseded evidence
is retained. All twenty final detail/underside views and the overview were inspected.
Simplified elongated profiles, rounded toe caps, understated leather straps,
faceted plate edges, static flat cloth, repeated materials, matte shading,
interpreted backs/soles and omitted fine ornament require author review.

GZDoom 4.14.2 passes 1,011 native pickup/equip/toss and old-save/reload/rollback
assertions, plus 236 visual/control assertions. Another 236-assertion hand-armor
regression preserves the earlier bindings in the same class; its overview was
inspected. These prepared API transactions do not prove ordinary menus,
crafting, manual handling or author acceptance.

Both twelve-object, 700-tic presentation scenes were inspected. Sprite/model
queue rates were 1157.23/1098.11 per second, p95 1.037/1.065 ms
and p99 1.288/1.163 ms. This single sequential pair measures queue
intervals, not GPU/display latency, repeatability or campaign performance.
Projected footprints differ. Evidence: assets/validation_v5_17_69/evidence/SUMMARY.json.
CA781-FOOT-ARMOR-01 remains pending. Four torso armor states, ancestor-only
pickup bindings, other characters, modular equipment and V5.16 remain unfinished.

## 5.17.68 - Native hand armor drops (#779)

Four original paired glove/gauntlet assemblies replace only the hand-slot states
CGMM, CGLT, CGMD and CGHV of CaelumArmorPickup. Magic, light, medium and heavy
retain all three qualities (twelve native cases). Effective references remain
the original ca_gloves.png, ca_gloves_light.png, ca_gloves_medium.png and
ca_gloves_heavy.png TEXTURES aliases, including their individual offsets.
Inventory art, protection, size, weight, durability, scale/collision, recipes
and persistence are unchanged. Clothing gloves and giant-gauntlet weapons retain
their own models. These candidates do not deliver worn modular hand fitting.

Editable DESIGN/OBJ/MTL and provenance: inventory_models_647/armor_hands.
Existing owned hollow-glove anatomy is adapted with separate fingers/thumbs,
open cuffs, fixed curved finger plates, knuckles, straps and simplified trim.
All leather/steel/gold pixels are reused unchanged; no raster generation/edit.
Independent serialized checks verify 65,840 vertices, 30,400 triangles, 164
closed components, 156 fixed attachments, 40 clear opening rays and eight cuff
depth probes. Sixteen exports repeat byte-for-byte; effective envelopes and UVs pass.

Initial export setup required the existing prism backend and correct ellipsoid
schema keys; those attempts stopped before installation. The first native front
review showed round finger pads resembling studs. Closed curved plate segments
now wrap the medium/heavy fingers; initial evidence remains as superseded.
All twenty final detail/underside views and the overview were inspected.
Shared simplified anatomy, fixed upright paired pose, understated leather straps,
flat matte shading, simplified plates/runes, repeated materials, interpreted palms
and omitted stitching/fine ornament remain subject to author review.

GZDoom 4.14.2 passes 1,011 native pickup/equip/toss and old-save/reload/rollback
assertions plus 236 visual/control assertions. A further 236-assertion helmet
regression checks the earlier head-state bindings after adding hand bindings
to the same class. Its overview was inspected. Prepared API transactions do not
establish ordinary menus, crafting, manual handling or author acceptance.

Both twelve-object, 700-tic presentation scenes were inspected. Sprite/model
queue rates were 1143.29/1117.61 per second, p95
1.054/1.071 ms and p99 1.279/1.260 ms.
This single sequential pair measures queue intervals, not GPU/display latency,
repeatability or campaign performance. Projected footprints differ. Evidence:
assets/validation_v5_17_68/evidence/SUMMARY.json.

CA779-HAND-ARMOR-01 remains pending. Eight torso/foot armor states, ancestor-only
pickup bindings, other characters, modular equipment and V5.16 remain unfinished.

## 5.17.67 - Native armor helmet drops (#777)

Four original hollow assemblies replace the head-slot states of CaelumArmorPickup:
magic CHMG, light CHLT, medium CHMD and heavy CHEH. Their three existing qualities
share each appearance, for twelve native cases. The effective references remain
ca_helmet_magic.png, ca_helmet_light.png, ca_helmet_medium.png and ca_helmet.png
through their original 128-pixel TEXTURES aliases. Icons, collision, actor scale,
equipment size, protection, weight, durability, recipes and persistence are unchanged.
These are world drops; worn modular fitting is not delivered by this patch.

Editable DESIGN/OBJ/MTL sources and provenance are in inventory_models_647/
armor_helmets. Independent serialized checks verify 46,746 vertices, 31,536
triangles, 130 closed components, 126 fixed contacts and 100 clear visor/neck
rays. Nineteen exports repeat byte-for-byte. Eighteen small medium-helmet mail
reliefs are closed rings fixed to the curtain, not interlinked simulated mail.
Original owned material pixels are reused; the purple and blue plume samples
retain their source alpha. Existing sprite artwork is unchanged.

One original opaque antique-gold material was generated with built-in image_gen
and copied byte-for-byte to source/runtime gold.png. GOLD_PROMPT.json records
the exact prompt and source. The 1254-square image has SHA-256
4e6123410914b56260ca5f406e873315063659043072852e2ebe433973be17dc.
Earlier engraved and cropped material trials produced stretched wood-like marks.
The final uniform material replaces those trials; superseded evidence is retained.
Visor slots were narrowed/lengthened, plumes smoothed/tapered and a rear liner added.

All twenty final detail/underside views and the overview were inspected. The
shared simplified visor shape, static ribbon-like plumes, fixed mail relief,
rust-toned medium/heavy metal, flat matte gold shading, small repeated color
samples, interpreted backs and omitted fine ornament require author review.
The current candidate is not a final fitted character accessory.

Isolated GZDoom 4.14.2 checks pass 1,011 continuity assertions across native
pickup/equip/toss, old saves, reload and rollback, plus 236 visual/control
assertions. An additional 157-assertion fresh regression and inspected capture
preserve medium torso armor art and the separate Anima potion after introducing
head-state MODELDEF bindings. Prepared transactions do not establish ordinary
menus, crafting, normal gameplay or author acceptance.

Both twelve-object, 700-tic presentation scenes were inspected. Sprite/model
queue rates were 1238.87/1004.22 per second, p95 1.014/1.247 ms and p99
1.217/1.434 ms. The model scene costs more in this single sequential pair.
These are queue intervals, not GPU/display latency, repeatability or campaign
performance; projected footprints differ. Evidence:
assets/validation_v5_17_67/evidence/SUMMARY.json.

CA777-ARMOR-HELMETS-01 remains pending. Twelve torso, hand and foot armor states,
ancestor-only pickup bindings, other characters, modular equipment and V5.16
still require work. No previous author check was accepted or removed.

## 5.17.66 - Separate medium armor and Anima potion aliases (#775)

The inventory audit found that both medium torso armor and the medium Anima
potion selected CAMDA0. The later potion TEXTURES definition replaced the older
armor alias, so the armor drop displayed a bottle. Medium torso armor now uses
the unused CMARA0 identifier and the same ca_armor_medium.png image, 128-square
canvas and Offset 64,120. CAMDA0 retains the potion image. A new registered state
is appended without renumbering existing registry states. Other armor slots,
qualities, inventory icons, statistics and native behavior are unchanged.

No new art or models. All packaged images, meshes and MODELDEF files are
byte-identical to #773. The existing owner-null Tick refresh selects the corrected
sprite after old-save load; the previous runtime restores its previous display
on rollback. No persistent field/schema or migration revision is introduced.
Shared source provenance in 32 metadata files is refreshed for the two affected
source hashes; their geometry, material and generated-resource hashes do not
change. The new bounded validator prevents this known duplicate alias and
checks the original owned reference images.

Fifteen armor cases (all medium slots/qualities and three other torso controls)
plus a split medium-Anima-potion stack pass 1,193 native assertions across fresh
pickup/drop, old-save load, equip/unequip, reload and rollback. All five phase
captures show the expected armor-versus-potion distinction. The initial fixture
shadowed the Potion field with a case-insensitive local variable; an intermediate
runner exited before its last queued verification. Both test defects are fixed
and superseded evidence is retained. Final runtime has 18,535 exact src entries;
only TEXTURES, the armor selector/registry and two version diagnostics differ.
Evidence: assets/validation_v5_17_66/evidence/SUMMARY.json. No rendering throughput
claim is made for this binding-only correction. CA775-ARMOR-ALIAS-01 awaits
ordinary author confirmation. All sixteen armor world states still need 3D
models; the inventory discovery is not proof of universal coverage or visibility.

## 5.17.65 - Native ranged-weapon drops (#773)

Four original assemblies replace CCAR, CSGN, CLBW and CCBW only in
CaelumWeaponPickup: carbine type 2, shotgun 14, longbow 15 and crossbow 16.
Each retains its three qualities and shared world appearance, for twelve
native cases. Original icons, held artwork, firing/reload/aim rules, ammo,
projectiles, recipes, weight, collision/scale, durability and saves are unchanged.
Cosmetic cartridges and quiver arrows neither grant nor consume ammunition.

CA-KP-247 effective references are icons/ca_carbine.png, ca_longbow.png and
ca_crossbow.png at scale 1, and the shotgun.textures CSGNA0 crop
[64,47,567,635] of shotgun/icons.png at scale 4.9. Existing source pixels remain
unchanged. The four native envelopes follow their effective scaled silhouettes.
Editable DESIGN/OBJ/MTL sources and provenance are in inventory_models_647/
ranged_weapons. Reused geometry supports hollow muzzles, trigger guards,
curved limbs, strings and the quiver. Independent serialized checks verify
22,476 vertices, 9,092 triangles, 61 closed components, 59 fixed attachment
witnesses and 65 clear opening rays. Eighteen exports repeat byte-for-byte;
installed geometry, scaled extents, floor contact, UVs and exact states pass.

One original opaque olive canvas material was generated with built-in image_gen,
then copied byte-for-byte to source and runtime canvas.png. CANVAS_PROMPT.json
records its exact prompt/source. The 1254-square image has opaque alpha and
SHA-256 ceeffb856bf899c087753f86164dfea1b84dfc084fd9c33fe6c1c91fda94b042.
Previously owned metal, wood, fabric and leather pixels remain unchanged.

Initial static checks caught boundary barrel-attachment witnesses and a wide
crossbow envelope. Corrected witnesses and assembly inclination pass independent
checks; superseded evidence is retained. All twenty final detail/underside
views and the overview were inspected. Simplified stock/barrel profiles,
static strings/accessories, interpreted backs, omitted fine ornament, repeated
grain, matte shading and standing pickup orientation require author review.
These world-drop assemblies do not complete held or character equipment models.

The isolated engine run passes 1,011 continuity assertions across native pickup,
equip/toss, old-save adoption, reload and rollback. Visual/control checks pass
236 assertions. Both twelve-object, 700-tic presentation scenes were inspected:
sprite/model queue rate 1125.62/1105.57 per second,
p95 1.066/1.077 ms and p99 1.298/1.287 ms.
This single sequential pair measures queue intervals, not GPU/display latency,
repeatability or campaign/crowd performance. Projected footprints differ.
Prepared transactions do not establish normal menus, firing, reload, crafting
or author acceptance. Evidence: assets/validation_v5_17_65/evidence/SUMMARY.json.

CA773-RANGED-DROPS-01 remains pending. Inventory-wide coverage still needs an
audit; remaining characters, modular equipment and V5.16 are unfinished.

## 5.17.64 - Flail, giant-gauntlet and bolas drops (#771)

Three native assemblies replace CFLA, CGAU and CBOL only in
CaelumWeaponPickup: flail type 8 and giant gauntlets type 13 retain three
qualities each; bolas type 22 retains its single quality. Seven native cases
preserve original icons, held artwork, projectile/restraint art, ammunition
identity, recipes, weight, collision/scale, durability, essence and save rules.
The actual bolas tool remains distinct from the #652 ammunition representation.

Effective references follow CA-KP-247: icons/ca_flail.png; the RGB-muted
gauntlet_icons/tier1.png at scale 10; and the last loaded bolas.textures
CBOLA0 alias, using atlas cell [0,640,426,1280] at scale 5. No source image is
edited. Display extents follow these scaled opaque envelopes. Shared quality
appearances remain as in the existing world states.

Editable DESIGN/OBJ/MTL sources and provenance are in inventory_models_647/
articulated_weapons. The flail has seven closed rings with six independently
verified links and native clearance. Both gauntlets have hollow cuffs and
closed dark liners. The bolas assembly has three covered weights, simplified
seams, a knot and separated coiled thongs. Across all three: 32,646 vertices,
21,792 triangles, 70 closed components, 60 fixed attachment witnesses, six
linked pairs and ten clear cuff rays. Serialized native triangles match the
editable geometry; scaled envelopes, floor contact and material UVs pass.
Sixteen generated outputs repeat byte-for-byte.

One original opaque dark-brown leather image was generated with built-in
image_gen, copied byte-for-byte to leather.png in the source folder and
models/caelum/inventory/articulated_weapons/leather.png at runtime. Exact prompt
and source location: LEATHER_PROMPT.json; SHA-256:
261976d27a229443bb17fb75ac73408523988d51777cf928179ec1aff31740df.
The 1254-square image has fully opaque alpha. Existing metal, wood, red fabric
and dark interior pixels remain unchanged. An earlier footwear leather sample
had partial alpha and is recorded as a superseded attempt, not the final skin.

Native review corrected hidden red ties, indistinct cuff interiors and overly
orange leather. Earlier static checks also caught reversed tassel winding,
boundary attachment witnesses, overlapping coil turns and a too-wide bolas
envelope. Superseded evidence is retained. All fifteen final detail/underside
views and the overview were inspected. Simplified chain/ties, finger shells,
non-emissive diamond plates, omitted fine rivets/runes and rope braid, repeated
grain, subdued shading and standing pickup orientation require author review.
These are world-drop meshes, not modular wearable character equipment.

The final isolated run passes 596 continuity assertions across fresh pickup,
old-save adoption, native equip/toss, reload and rollback. Visual/control checks
pass 141 assertions. Both seven-object, 700-tic presentation scenes were
inspected: sprite/model queue rate 1053.78/1165.86 per second,
p95 1.223/1.025 ms and p99 1.473/1.219 ms.
This single sequential pair measures queue intervals, not GPU/display latency,
repeatability or campaign/crowd performance. Projected footprints differ.
Prepared native transactions do not prove ordinary menus, combat, bolas throw/
restraint/recovery or author acceptance. Evidence:
assets/validation_v5_17_64/evidence/SUMMARY.json.

CA771-ARTICULATED-DROPS-01 remains pending. Four ranged weapon types, other
characters/modular equipment and the broader V5.16 campaign remain unfinished.

## 5.17.63 - Effective sword/axe world references (#769)

The first #763/#765 candidates used older physical sprite lumps that
TEXTURES overrides. Seven models now derive their display envelopes from
the effective sword, dagger, machete, greatsword, hatchet, axe and war-axe
aliases. The pickaxe already used the effective #89 reference and remains
byte-identical. Greatsword resolves through CA_GSICON1_M/CA_GSICON1_M_D to
first_person/v5/greatsword_icon_t1_source.png with 9.796875 sprite scale;
its RGB-only desaturation/blend leaves the alpha envelope unchanged.

Corrected source data and portable exports stay in inventory_models_647/
bladed_weapons and axes; effective_weapon_references/PROVENANCE.json records
the before/after source resolution. Existing generators remain unchanged.
Fifteen blade outputs and sixteen axe outputs repeat byte-for-byte. Eight
effective aliases/scales are checked independently; the seven changed models
total 5,816 vertices, 8,488 triangles, 60 closed parts and 53 attachment witnesses.
Scaled envelopes, floor contact, quantized topology, opaque/noncollapsed UVs
and exact existing class/state bindings pass. This art-data revision changes
no gameplay schema or save migration.

The sword gains blue grip/tassels, dagger a red grip, machete a blue grip,
and hatchet/war axe red tassels. Axe fittings use bronze; the plain axe has
wood/bronze grip bands. Shared quality appearances and all icons/held art
remain unchanged. Simplified profiles/guards, matte plain steel without the
reference's painted blade stains, omitted fine ornament/axe chain, static
tassels, repeated grain, standing orientation and interpreted backs require
author review. Source resolution is not a claim of exact painted-art fidelity.

Oblique native review exposed coincident shaft/socket upper caps on the
three axes. Their shaft ends now stop inside the cap. An independent test
on serialized, quantized geometry reproduces three failures before and zero
after correction; new native views show clean caps. One early tassel had
duplicate-height rows collapsing its UVs, and the initial machete lean exceeded
its effective width; both were corrected before final reviewed exports.

The existing issue-specific fixtures are reused unchanged. Blade continuity
passes 1,343 checks on runtime01; the final runtime02 differs from runtime01
only in the three corrected axe meshes, leaving that blade evidence applicable.
Axes pass 845 checks on runtime02. Old-save adoption, reload, rollback, original
metadata and native equipment transactions pass; final visual/control runs
pass 312 + 198 checks. All 35 views of the seven changed models and both overviews
were inspected. These checks do not establish ordinary gameplay acceptance.
Two separate 700-tic presentation pairs compare sixteen blade objects and ten
axe objects with their original sprite baselines. Queue rates, sprite/model:
blades 1084.54/937.20 per second, p95 1.125/1.315 ms and p99 1.390/1.571 ms;
axes 1100.28/1101.03, p95 1.093/1.081 ms and p99 1.323/1.311 ms. All four
scenes were inspected. These single pairs do not measure GPU/display timing,
repeatability or campaign/crowd performance; projected footprints differ.
The final package matches all 18,524 source entries. Against #767, only seven
meshes and two version diagnostics change; bindings remain byte-identical.
Evidence: assets/validation_v5_17_63/evidence/SUMMARY.json.

CA769-EFFECTIVE-WEAPON-REFERENCES-01 retains author review alongside the
unconfirmed #763/#765 checks. No prior author result is accepted or removed.
Other weapon drops, characters/modular equipment and V5.16 remain unfinished.

## 5.17.62 - Polearm and utility-staff drops (#767)

Four native models replace CJAV, CSPR, CHAL and CUST in CaelumWeaponPickup:
javelin6, spear9 and halberd12 retain three qualities each; utility staff21
retains its single quality. Existing icons, held artwork/effects, projectiles,
combat/tool rules, Anima costs, fractional contact wear, size, durability,
weight, collision/scale, recipes and saves remain unchanged.

Effective TEXTURES aliases, not superseded physical sprite lumps, define the
three polearm references: graphics/caelum/icons/ca_javelin.png, ca_spear.png
and ca_halberd.png. Javelin/halberd have red ties, spear blue ties, and the
shafts have bronze fittings. The initial prototype used the older images;
its retained results establish API continuity only, not current-art fidelity.
The corrected models include simplified static tassels and current display
envelopes. #769 separately corrects the affected prior sword/axe candidates.

The utility staff uses #162's accepted ready cell, the first627x627 crop of
graphics/caelum/utility_staff/atlas.png, divided by its4.8984375 TEXTURES scale.
Its bronze nozzle has a real open cavity and dark interior, attached to the
walnut shaft; the wrapped grip and lower bronze fitting remain separate
closed parts. An initial excessive lean was reduced to respect the scaled
width as well as height. Original2D acceptance does not accept this3D model.

Editable OBJ/MTL, reference resolution and provenance are in
assets/source/art/inventory_models_647/polearms. Unchanged owned #723 metals,
#761 wood, #647 leather and #755 red/blue pixels supply the materials. No
raster edits or generation. Regenerate with python
assets/generators/generate_inventory_polearms_models.py --output build/polearms
--install. Sixteen outputs repeat byte-for-byte. The final models total6,039
vertices and6,384 triangles,48 closed components,44 verified attachment
witnesses and five clear nozzle rays. Independent topology/winding, exact
quantized faces, noncollapsed UVs, opaque regions, scaled effective sprite
envelopes and floor contact pass. Planar UVs keep the nozzle rim triangles
noncollapsed without altering the shared generator or existing texture pixels.

Twenty final detail/underside views, the overview and nozzle close-up were
inspected. Simplified matte heads/fittings, static tassels, repeating grain,
warm grip colors, subdued bronze depth, standing orientation and interpreted
backs remain author-review qualifications. World footprints differ from
view-facing sprites. Small parts need ordinary in-game readability review.

Ten cases pass853 final installed continuity assertions:192 baseline,
161 old-save adoption,192 fresh,154 reload and154 rollback. The final visual
run passes199 checks. Native pickup/equip/unequip/toss, exact identity,
quality/essence, size, durability, weight, provenance and prepared Box/quest
guards pass. A nonzero utility contact remainder survives drops, repickup
and saves. This fixture does not establish ordinary menu operation, combat,
throwing or sustained fire/ice use. Evidence and bounded presentation timing:
assets/validation_v5_17_62/evidence/SUMMARY.json.

The bounded comparison uses ten objects and700 tics per scene. Queue
presentation rates are1148.55 sprites versus1158.85 models per second;
p95 intervals1.0314 versus1.0366 ms and p99 intervals1.2506 versus1.2660 ms.
This single sequential pair is neither GPU/display timing nor repeatability,
campaign/crowd performance or author acceptance. Both scenes were inspected;
projected footprints differ. The final package contains18,524 source entries
verified byte-for-byte; only four models, one binding file, MODELDEF and two
version diagnostics differ from the prior runtime.

CA767-POLEARM-DROPS-01 retains author visual and ordinary gameplay review.
Other physical drops, characters, modular equipment and V5.16 remain pending.

## 5.17.61 - Hatchet, axe, war axe and pickaxe drops (#765)

Four original native handle/head assemblies replace CHAT, CAXE, CWAX and CPIK
world drops in CaelumWeaponPickup. Ten cases retain the three existing
qualities of hatchet4, axe7 and war axe11, and the single-quality pickaxe20.
The #89 hybrid retains its left chopping blade, opposite curved mining point,
wooden shaft and wrapped grip. Existing icons, first-person art/rest pose,
shared quality appearance, item/tool rules, gathering behavior, durability,
size, weight, scale/collision, recipes and saves remain unchanged.

Editable sources and provenance: assets/source/art/inventory_models_647/axes.
Portable OBJ/MTL sources reuse unchanged owned #723 metal, #761 wood,
#647 leather and #755 red texture pixels. No raster editing or generation.
Regenerate with python assets/generators/generate_inventory_axes_models.py
--output build/axes --install. Sixteen outputs repeat byte-for-byte. The four
models total 3,399 vertices and 4,800 triangles, with 37 closed components and
33 independently verified attachment witnesses. Topology/winding, quantized
native faces, noncollapsed UV triangles, opaque texture regions, original
sprite envelopes and floor contact pass. The first mining-pick witness fell
outside the curved prong despite overlapping solids; only that test-data
point was moved into both volumes. Geometry and texture bytes did not change.

All twenty native front, side, rear and raised underside detail views and the
floor overview were inspected. Simplified heads/fittings, matte gray steel,
repeating grain, warm grip colors, static wraps, standing pickup orientation
and interpreted hidden surfaces remain author-review qualifications.
Prior 2D approval does not establish native3D acceptance.

Ten cases pass 845 installed continuity assertions: 191 baseline, 159 old-save
adoption, 191 fresh, 152 reload and 152 rollback. The visual/control run passes
198 checks. Native pickup/equip/unequip/toss, repickup, identity, essence,
size, weight, durability, provenance and prepared Box/quest guards pass.
Ordinary menus, combat, chopping/mining and crafting remain author checks.
Package parity and bounded presentation evidence are recorded in
assets/validation_v5_17_61/evidence/SUMMARY.json.

One sequential 700-tic ten-object sprite/model pair records
955.65/836.48 queue presents/s, p95
1.2665/2.0292 ms and p99
1.5576/2.4947 ms. Windows11, Ryzen9 5950X, RTX3070Ti, GZDoom4.14.2,
Vulkan1280x720, uncapped/vsync off, background unpaused/audio5%. Both scenes
were inspected. Unequal projected footprints and queue intervals do not prove
GPU/display timing, repeatability or campaign/crowd performance. All
18,519 packaged entries match src; only four new models, the binding
definition, MODELDEF and two diagnostic release strings differ from #763.

CA765-AXE-DROPS-01 retains author visual and ordinary gameplay review.
Other weapons, characters, modular equipment and V5.16 remain unfinished.

## 5.17.60 - Sword, dagger, machete and greatsword drops (#763)

Four original native blade/hilt assemblies replace CSWD, CDAG, CMAC and CGRS
world drops in CaelumWeaponPickup. The same sword model is explicitly bound
to CA_LimboRonnieSword and CaelumM01SwordPickup. Six exact bindings cover
sixteen native cases: twelve normal type/tier combinations, three Ronnie
sword qualities and the tutorial's enforced T1 sword. Existing shared quality
appearance, source icons, held/first-person art, essence rules, statistics,
size, durability, weight, scale/collision, recipes, quest acquisition and
persistence remain unchanged.

Sources: assets/source/art/inventory_models_647/bladed_weapons. Editable
OBJ/MTL sources include unchanged original texture copies: #723 steel/bronze,
#755 blue cloth and #761 wood. No raster edits or new image generation.
Regenerate with python assets/generators/generate_inventory_bladed_weapons_models.py
--output build/bladed-weapons --install. Fifteen outputs repeat byte-for-byte.
The four models total 2,420 vertices and 3,332 triangles, with 24 independently
closed components and 20 verified attachment witnesses. Topology/winding,
quantized native faces, opaque material regions, noncollapsed triangle UVs,
original icon envelopes and floor contact pass independent checks.

The first candidate passed 312 visual/control checks. Narrow blade edges/caps
then received per-face texture projection so they sample real texture areas.
All twenty final native front, side, rear and raised underside views plus the
overview were inspected. Simplified profiles/guards, matte gray steel,
repeating grain, diagonal standing pickup orientation and interpreted hidden
thickness/back surfaces remain explicit author-review qualifications. Native
models do not inherit acceptance from the old 2D sprites.

The initial visual scripts also requested unsupported detail indices4..15;
the fixture ignored them. Only valid0..3 sets are archived/reviewed. Capture
bounds were corrected before installed continuity tests, which request the
four actual designs. This changes test tooling only.

The first old-save run passed all 249 actual checks but failed an incorrect
259-count expectation. The runner now derives phase totals from the sixteen
cases; the full sequence was repeated. Raw failed-gate evidence is retained.

Sixteen cases pass 1,343 installed continuity assertions: 305 baseline,
249 old-save adoption, 305 fresh, 242 reload and 242 rollback. The final
visual/control run passes 312 checks. Native pickup/equip/unequip/toss,
repickup, identity, essence, size, weight, durability, provenance and prepared
Box/quest guards pass. The tutorial pickup overrides deliberately incorrect
pre-acquisition type/tier/essence to its authoritative sword T1 values.
Ordinary menus, combat, quest progression and crafting remain author checks.
Package parity and bounded presentation evidence are recorded in
assets/validation_v5_17_60/evidence/SUMMARY.json.

One sequential 700-tic sixteen-object sprite/model pair records
942.68/916.86 queue presents/s, p95
1.2811/1.3321 ms and p99
1.5559/1.6330 ms. Windows11, Ryzen9 5950X, RTX3070Ti, GZDoom4.14.2,
Vulkan1280x720, uncapped/vsync off, background unpaused/audio5%. Both scenes
were inspected. Unequal projected footprints and queue intervals do not prove
GPU/display timing, repeatability or campaign/crowd performance. All
18,514 packaged entries match src; only four new models, the binding
definition, MODELDEF and two diagnostic release strings differ from #761.

CA763-BLADED-WEAPON-DROPS-01 retains author visual and ordinary gameplay review.
Other physical weapons, characters, modular equipment and V5.16 campaign
remain unfinished.

## 5.17.59 - Hooded effigy quality drops (#761, parent #647)

Six exact S479 PQR bindings cover support effigy26 in CaelumWeaponPickup and
CA_LimboMagicImplement. Three original closed sculptures follow the owned
effigy-source.png: carved robe and pedestal/grip, actual hollow hood and
sleeves, blue crossing cords, belt, knot and hanging cords. Tier I uses plain
wood and blue cords; tiers II/III add silver-colored/gold medallions and trim.
The source icons, held art, quintessence rules, support behavior, statistics,
weight, durability, scale/collision, recipes and persistence are unchanged.
Rejected #479 procedural models remain inactive.

Editable sources and provenance: assets/source/art/inventory_models_647/effigies.
Existing blue/gold (#755) and silver-colored (#723) textures are reused
unchanged. A new opaque walnut/deep-recess wood.png was generated with the
built-in image_gen.imagegen tool, copied byte-for-byte, and recorded with its
full prompt, output provenance and SHA256 in MATERIALS_PROMPT.json. No raster
retouching was applied. Portable OBJ/MTL sources include their texture copies.
Regenerate with python assets/generators/generate_inventory_effigies_models.py
--output build/effigies --install. Fourteen outputs repeat byte-for-byte.
The three meshes total 15,240 vertices, 28,752 triangles, 44 closed components,
41 attachment witnesses and 45 cavity rays. Independent topology/winding,
quantized native faces, opaque UV regions, reference envelopes and floor
contact checks pass.

Visual01 passed 122 native/control checks, but front/side inspection showed
weak contrast inside the hood. The new two-region atlas distinguishes the
wood exterior from deep hood/sleeve recesses without changing geometry.
All fifteen final detail, side, rear and raised underside views plus the
floor overview were inspected. The profile is simplified and symmetric,
cords are static, medallions/base trim are plain, and matte wood remains dark.
Hidden surfaces are interpretations. These require author visual review;
accepted 2D source art does not establish acceptance of the native models.

Six class/tier cases pass 513 installed continuity assertions: 115 baseline,
99 old-save adoption, 115 fresh, 92 reload and 92 rollback. The final visual
run adds 122 passing checks. Native pickup/equip/unequip/toss, repickup,
identity, essence, weight, durability, provenance and prepared Box/quest
guards pass. Ordinary menus, support casting and crafting remain author
checks. The packaged source parity and bounded presentation measurements are
recorded in assets/validation_v5_17_59/evidence/SUMMARY.json.

One sequential 700-tic six-object sprite/model pair records 682.54/697.39
queue presents/s, p95 4.2601/4.2664 ms and p99
5.1642/5.4023 ms. Windows11, Ryzen9 5950X, RTX3070Ti, GZDoom4.14.2,
Vulkan1280x720, uncapped/vsync off, background unpaused/audio5%. Both scenes
were inspected. Unequal projected footprints and queue timing do not establish
GPU/display timing, repeatability or campaign/crowd performance. All
18,509 packaged entries match src; only three new models, one new
texture, the binding definition, MODELDEF and two diagnostic release strings
differ from #759.

CA761-EFFIGY-DROPS-01 retains author visual and ordinary gameplay review.
Physical weapons, characters, modular equipment and V5.16 campaign remain
unfinished.

## 5.17.58 - Scepter and censer quality models (#759, parent #647)

Twelve exact S479 ABC/JKL bindings cover scepter18 and support-censer24 in
CaelumWeaponPickup and CA_LimboMagicImplement. The tier-one meshes remain
byte-identical to #755; four new quality models follow the owned three-tier
references. Existing #755 and #723 atlases are reused without raster edits
or duplicate runtime textures. Scepter bands, ferrule, scrolls and crest
leaves use neutral silver-colored or gold trim. Higher-quality censers change
their equatorial rims and add the reference foot/knob bands. Original bronze
structures, wood, blue gem/cloth and all 48 real censer apertures remain.
Icons, held art, tier statistics, valid essences, weight, durability,
scale/collision, recipes and persistence remain unchanged. Rejected #479
procedural models stay inactive.

Sources: assets/source/art/inventory_models_647/magic_tiers, including portable
OBJ/MTL and original texture copies. Regenerate with python
assets/generators/generate_inventory_magic_tiers_models.py --output
build/magic-tiers --install. Sixteen outputs repeat byte-for-byte. The four
new meshes total 37,880 vertices and 56,464 triangles; all six quality models
total 55,092 vertices, 81,240 triangles, 72 closed components, 66 attachment
witnesses and 60 cavity rays. Independent topology/winding, quantized native
triangles, opaque material/UV regions, reference envelopes and floor contact
checks pass. The exact tier-one hashes and original gameplay sources are
verified separately.

Visual01 passed 236 native checks but showed little distinction between
censer tiers I and III. Closed reference bands were added to the higher-quality
feet and knob collars. All thirty final detail/side/rear/underside views and
the floor overview were inspected. Neutral silver is subdued; painted
ornament is strong; cloth remains static; profiles are simplified; bronze and
gold remain similar in warm distant views. These are author-review
qualifications, alongside #755's original hidden-surface review.

Twelve class/type/tier cases pass 1,011 installed continuity assertions:
229 baseline, 189 old-save adoption, 229 fresh, 182 reload and 182 rollback.
The final visual/control run adds 236 passing checks. Native pickup/equip/
unequip/toss, repickup, saved identity, valid essence, durability, weight,
provenance and prepared Box/quest guards pass. Ordinary menus, casting and
crafting remain author checks. All 18,504 packaged source
entries match src; only four new models, the binding definition, MODELDEF
and two release diagnostic strings differ from #757.

One sequential 700-tic twelve-object sprite/model pair records
770.55/732.46 queue presents/s, p95
2.5245/2.5745 ms and p99
4.7903/4.7842 ms.
Both scenes were inspected. Windows11, Ryzen9 5950X, RTX3070Ti, GZDoom4.14.2,
Vulkan1280x720, uncapped/vsync off, background unpaused/audio5%. Queue timing
and unequal projected footprints do not establish GPU/display timing,
repeatability or campaign/crowd performance.

Evidence: assets/validation_v5_17_58/evidence/SUMMARY.json.
CA759-MAGIC-QUALITY-DROPS-01 retains author visual and ordinary gameplay review.
Effigies, physical weapons, characters, modular equipment and V5.16 campaign
remain incomplete.

## 5.17.57 - Magical weapon drop bindings (#757, parent #647)

Six exact CSTF/CBEL/CSTA A bindings reuse the #755 staff, bell and statuette
meshes and material atlas byte-for-byte for CaelumWeaponPickup and
CA_LimboMagicImplement. Types1/17/25 retain all three qualities and their
existing shared world appearance. There is no duplicated geometry/texture,
broad actor replacement, saved-field change or activation of rejected #479
models. Original icons, scale/collision, weight, identity, durability, essence
rules, crafting and held art remain unchanged. Type19 remains an Orb.

Source manifests: assets/source/art/inventory_models_647/magic_weapons.
Regenerate with python assets/generators/generate_inventory_magic_weapon_bindings.py
--output build/magic-weapons --install. Three outputs repeat byte-for-byte;
static validation verifies all six bindings and their #755 source hashes.
The previous closed-geometry checks apply to these identical bytes. Twelve
native details/undersides and the floor overview were inspected here; the
remaining generated views were not reinspected. The simplified statuette
face, static ribbons, heavy painted ornament, subdued ambient depth and
new hidden surfaces retain #755's pending visual review.

All eighteen class/type/tier cases pass 1,509 installed native checks:
343 baseline, 279 old-save adoption, 343 fresh, 272 reload and 272 rollback.
Another 350 visual/control checks pass. Native pickup/equip/unequip/toss,
repickup, exact identity, valid essence, weight, durability, provenance and
prepared Box/quest guards pass. Ordinary menus, casting and crafting remain
author checks. All 18,499 packaged source entries match
src exactly; only the new binding definition, MODELDEF and two release
diagnostic strings differ from #755.

One sequential 700-tic six-object sprite/model pair records
645.36/654.32 queue presents/s, p95
4.0556/3.6831 ms and p99
5.5548/5.5969 ms.
Both scenes were inspected. Windows11, Ryzen9 5950X, RTX3070Ti, GZDoom4.14.2,
Vulkan1280x720, uncapped/vsync off, background unpaused/audio5%. This measures
queue intervals only, not GPU/display timing, repeatability or campaign/crowd
performance. The projected sprite/model footprints differ.

Evidence: assets/validation_v5_17_57/evidence/SUMMARY.json.
CA757-MAGIC-WEAPON-DROPS-01 retains author visual and ordinary gameplay checks.
Other weapons, characters, modular equipment and V5.16 campaign remain pending.

## 5.17.56 - Native magical crafting bases (#755, parent #647)

Six original meshes cover CaelumMaterialPickup states CSTF/CBEL/CSTA A and
M044/M089/M090 A: staff36, bell37, statuette39, seal44, censer89 and scepter90.
All eighteen existing material/tier cases keep their shared world appearance.
Icons, scale/collision, weights, quantities, recipes, provenance/contamination
and persistence are unchanged. This patch does not replace weapon or held
states or enable the rejected #479 procedural support models.

Editable sources and OBJ/MTL live in
assets/source/art/inventory_models_647/magic_bases. A new opaque 3x3 material
atlas is copied byte-for-byte from image_gen.imagegen with its exact prompt,
hash and provenance. Original painted designs remain unchanged. Shafts,
ornament, cloth, sculpted figure, blank seal face, bell cavity/clapper and the
censer's 48 apertures are volumetric. The export contains 31,309 vertices,
50,896 triangles and 72 closed components. Independent winding, volume, genus,
66 attachment witnesses, 30 cavity rays, quantized native/editable triangles,
floor contact, icon envelopes, opacity and per-triangle atlas-region checks
pass. Seventeen outputs, including the preview package, repeat byte-for-byte.
Regenerate with python assets/generators/generate_inventory_magic_bases_models.py
--output build/magic-bases --install.

Native review refined pointed crests, facial/robe detail and aperture size.
Dark cavity material separates the bell/censer interiors; duplicated lip
vertices prevent atlas interpolation through unrelated tiles. The seal's
radial cap seam was replaced with planar UVs. Thirty visual03 detail/underside
views were inspected; the five revised seal views and floor overview were
checked in the final installed continuity run. The other five mesh bytes are
unchanged. Simplified facial sculpture, static ribbons, strong painted ornament,
subdued depth in ambient lighting and newly interpreted hidden surfaces remain
author-review qualifications. Existing 2D approval is not native3D acceptance.

The installed package passes 2,604 native assertions: 487 baseline, 548 old-save
adoption, 487 fresh, 541 reload and 541 rollback. Pickup/toss, split/merge,
identity/tier, weight, metadata, original icon/scale and prepared Box/quest
guards pass. Visual03 also passes 494 fresh/control checks. Ordinary menus and
real crafting remain author checks. All 18,498 package
entries match src; only eight new resources, MODELDEF and two release diagnostic
strings differ from #753.

One sequential 700-tic six-object sprite/model pair records
686.29/676.16 queue presents/s, p95
3.1130/3.4596 ms and p99
5.2976/5.2405 ms.
Both scenes were inspected. Windows 11, Ryzen 9 5950X, RTX 3070 Ti, GZDoom 4.14.2,
Vulkan 1280x720, uncapped/vsync off, background unpaused/audio5%. Queue timing
and unequal projected footprints do not establish GPU/display timing,
repeatability or campaign/crowd performance.

Evidence: assets/validation_v5_17_56/evidence/SUMMARY.json.
CA755-MAGIC-BASE-DROPS-01 retains author art and ordinary gameplay acceptance.
Other weapons, characters, modular equipment and V5.16 campaign remain pending.

## 5.17.55 - Native baseless Orb drops (#753, parent #647)

The three Orb qualities gain exact S479 D/E/F bindings for CaelumWeaponPickup
and CA_LimboMagicImplement. M091 A reuses T1 for all three component tiers,
matching the existing material representation. Seven explicit bindings cover
nine runtime cases. Original IDs, icons, scale/collision, quantities, weight,
durability, contamination/provenance, magic, recipes, held art/hands and saves
remain unchanged. Rejected #479 procedural support models stay inactive.

The accepted baseless orb-floating-source.png is copied byte-for-byte as a
high-resolution shader atlas. Three fully closed spheres carry shallow radial
wood relief derived from its owned colors. No pedestal, billboard, raster edit
or new image generation is introduced. The meshes total 9,030 vertices and
18,048 triangles. Independent closure, winding, volume, genus, actual relief,
depth, quantized native/editable triangles, grounded origin, source hashes and
original icon envelopes pass. Eleven outputs repeat byte-for-byte. Editable
sources and portable OBJ/MTL are in assets/source/art/inventory_models_647/orbs.
Regenerate with python assets/generators/generate_inventory_orbs_models.py
--output build/orbs --install. The shared validator now recognizes explicit
frame letters while retaining A as its default for existing families.

The first fixture incorrectly copied the Book's quintessence. Existing
ValidEssence correctly rejects it for offensive Orbs; migration removed those
invalid test items and the incomplete fixture then dereferenced a null item.
The corrected fixture uses the already-supported water essence and guards
incomplete arrays. No production migration or magic rule changed. Visual02
showed excessive dark edge projection at the sides/top. Restricting UVs to the
interior painted disk and smoothing/lowering relief corrected that artifact.
Earlier evidence remains. Final visual03 passes 167 checks; all fifteen detail/
underside views and the floor overview were inspected. Candidate limitations
remain: repeated front/rear paint, stretched insets at grazing angles, low
painted bands in overhead views, shallow carving and baked highlights. The
2026-10-22 approval accepted the 2D design, not this native conversion.

The installed package passes 720 checks: 160 baseline, 138 old-save adoption,
160 fresh, 131 reload and 131 rollback. Native automatic equip, explicit
equip/unequip, toss/repickup, saved identity, durability, material split/merge,
provenance and prepared Box/quest guards pass. Ordinary menus, casting and real
crafting remain author checks. One sequential 700-tic nine-object sprite/model
pair records 646.91/653.02 queue presents/s,
p95 3.7310/3.7697 ms and
p99 4.6893/4.7163 ms.
Both scenes were inspected. Windows 11, Ryzen 9 5950X, RTX 3070 Ti, GZDoom 4.14.2,
Vulkan 1280x720, uncapped/vsync off, background unpaused/audio 5%. These queue
intervals and unequal projected footprints do not establish GPU/display timing,
repeatability or campaign/crowd performance. All 18,490 package entries match
src; only three meshes, the byte-exact atlas alias, their definition, MODELDEF
and two release diagnostic strings differ from #751.

Evidence: assets/validation_v5_17_55/evidence/SUMMARY.json.
CA753-ORB-DROPS-01 retains author visual and ordinary gameplay review.
Other inventory, characters, modular equipment and V5.16 campaign work remain.

## 5.17.54 - Native elemental crafting essence drops (#751, parent #647)

Fire, water, earth, wind and quintessence materials 20-24 gain exact M020-M024 A
native bindings. All fifteen type/tier cases keep their original icons, scale,
collision, quantities, weights, provenance, crafting/enchantment rules and saves.
These crafting materials are separate from the 78 Tarot essences. Original
128px PNGs are copied byte-for-byte to short shader aliases; no image generation
or raster editing occurred. sprites_v4.json retains their original provenance.

The five models contain 4,772 vertices and 8,312 triangles in
40 independently closed components, including a real toroidal orbit. Closed
edges, winding, volume, genus, quantized native/editable triangles, floor origin,
source hashes and original icon envelopes pass. Nineteen outputs repeat exactly.
Editable OBJ/MTL and portable original textures live in
assets/source/art/inventory_models_647/elemental_essences. Regenerate with python
assets/generators/generate_inventory_elemental_essences_models.py
--output build/elemental-essences --install.

Native visual01 exposed flat single-color surrounds and a white orbit. Mapping
opaque regions of the same icons corrected those materials. Visual02 prompted
thinner curved earth leaves joined into the root/vine depth. An initial copied
navigation expectation incorrectly named item 4 instead of item 1; the expected
index was corrected without removing any of the seven controls. Earlier sources,
logs and manifests remain as evidence. Final visual03 passes 413 checks; all
25 detail/underside views and the floor overview were inspected. Art remains a
candidate: projected low-resolution facets, repeated front/rear paint, saturated
tubular surrounds, pink/gold orbit and small satellites need author review.
The surrounds are static mesh decoration, with no new light, particle or attack.

The installed package passes 2,172 native checks: 406 baseline, 458 old-save
adoption, 406 fresh, 451 reload and 451 rollback. Native pickup/toss, split/merge,
contamination/provenance, saved identity and prepared Box/quest guards pass;
these API checks do not establish ordinary menus or actual crafting acceptance.
One sequential 700-tic five-object sprite/model pair records
700.88/669.60 queue presents/s,
p95 3.3748/3.9137 ms and
p99 4.7531/4.8327 ms.
Both scenes were inspected. Windows 11, Ryzen 9 5950X, RTX 3070 Ti, GZDoom 4.14.2,
Vulkan 1280x720, uncapped/vsync off, background unpaused/audio 5%. Queue-only
timing and unequal projected footprints do not establish GPU/display timing,
repeatability or campaign/crowd performance. All 18,485 package entries match
src; only five models, five unchanged-icon aliases, their definition, MODELDEF
and two release diagnostic strings differ from #749.

Evidence: assets/validation_v5_17_54/evidence/SUMMARY.json.
CA751-ELEMENTAL-DROPS-01 retains visual and ordinary inventory/crafting review.
Other inventory, characters, modular equipment and V5.16 campaign work remain.

## 5.17.53 - Restore hide assertion expectations (#749)

The shared runner accidentally inherited the kitchen fixture's seven extra
navigation assertions in its hide count branch under #743. Actual hide checks
remained163 for baseline/fresh/visual and181 for old-save/reload/rollback.
The native reproduction reports163 successes but falsely expects170 in visual
mode; old-save mode reports181 successes but falsely expects188. No native
Check fails. Restoring the hide-specific counts makes the same fixture/runtime
pass163 visual and869 continuity assertions across the five normal phases.
The native fixture and every other runner branch remain byte-identical.

All four before/after fixture checksums agree. No assertion was removed or
skipped; kitchen/kit navigation coverage remains. Native probes use the same
installed #747 kits01 package. The final #749 package matches all18,474 src
entries and differs from #747 kits02 only in two release diagnostic strings.
Compared with the tested kits01, MODELDEF also retains #747's documented CRLF
correction; normalized contents are identical. No art or performance change.
Evidence: assets/validation_v5_17_53/evidence/SUMMARY.json.
CA731-HIDE-DROPS-01 and all other author checks remain pending and unchanged.

## 5.17.52 - Native cartridge-kit drops (#747, parent #647)

The two untiered prepared kits79/80 gain exact M079/M080 A native bindings.
The owned #380 concepts guide bronze case/projectile versus paper case/shot,
sealed abstract packets and folded wrappers. CA380-01 accepted those icons on
2026-10-21; it does not accept these meshes. The kit remains one indivisible
input under #379. Visible pieces do not encode Amount, actual loading ratios,
new component products or the shotgun's gameplay pellet count. Icons, tier1,
weight, Actor.Scale0.25/collision, lots/provenance, workbench/chemistry recipes,
ammunition and save rules are unchanged.

Both meshes total13,421 vertices and13,440 triangles:18 independently closed
components,16 contact witnesses, ten clear case-mouth rays and2,592 projected
UV triangles pass. Eight outputs repeat byte-for-byte, including the local
preview package. Native/editable quantized triangles, floor bounds and original
icon envelopes pass. Sources and portable OBJ/MTL textures are in
assets/source/art/inventory_models_647/cartridge_kits. Regenerate with python
assets/generators/generate_inventory_cartridge_kits_models.py
--output build/cartridge-kits --install.

Existing opaque #743 paper and #652 bronze/iron pixels are reused unchanged.
Initial sampling found near-opaque alpha in the original kit concepts and the
earlier ammunition paper region, so those were not installed as new textures.
No image generation or raster editing occurred. Initial checks found out-of-
region recessed-case UVs and a wrapper obstructing mouth rays; both were
corrected. Native preview prompted less regular wrapper folds and gathered or
folded packet closures. Earlier logs, manifests and selected source iterations
are retained. The final ten detail views, floor overview and presentation scenes
were inspected. Visual qualifications remain: regular wrapper shape, pale paper
contrast, coarse bronze mottling, simple gray shot and projected/wrap seams.
Flat ambient light reduces the legibility of shallow mouths and paper folds.

The installed build passes300 native checks:55 baseline,68 old-save adoption
(including seven navigation probes),55 fresh,61 reload and61 rollback. The
final-byte visual run passes62. API pickup/toss, split/merge, lots/provenance
and prepared Box/quest guards do not establish ordinary menus or real crafting.
One sequential700-tic two-object sprite/model pair measures
1014.61/992.93 queue presents/s,
p95 1.1430/1.1611 ms and
p99 1.3558/1.3785 ms.
Windows11, Ryzen9 5950X, RTX3070Ti, GZDoom4.14.2 Vulkan1280x720,
uncapped/vsync off, background unpaused/audio5%. Queue-only timing, unequal
projected footprints and one pair do not establish GPU/display timing,
repeatability or crowd/campaign performance. All18,474 package entries match
src. Only two meshes, one definition, MODELDEF and two release diagnostic
strings differ from #745; no texture or gameplay bytes change.

Evidence: assets/validation_v5_17_52/evidence/SUMMARY.json.
Final packaging restores MODELDEF to its existing CRLF checkout policy.
Only those line endings differ from the tested package; normalized content
and every other entry are identical. Full validation preceded that correction;
package/source and filtered checkout bytes were verified afterward.

CA747-CARTRIDGE-KIT-DROPS-01 retains author art and ordinary inventory/crafting
review. Other inventory, characters, modular equipment and campaign work remain.

## 5.17.51 - Restore review-fixture underside controls (#745)

The F10 event chains for hides (#731), textiles (#733) and hygiene (#741)
used60,80 and30 instead of270 as their terminal rotation comparison. They
skipped the raised underside during interactive cycling. The three diagnostic
constants now use270; production art, gameplay and key bindings are unchanged.
Earlier explicit-angle captures remain valid.

One native regression probe preserves the original event code and injects
observation only. It cycles all13 designs through their actual F9/F10 events,
checking index, angle, active camera and raised/grounded state. The original
sources reproduce26 failures across78 checks; the corrected sources pass all78.
Representative before/after captures from each family were inspected, and all
13 underside captures per run are retained. This tests events used by the keys,
not physical keyboard input or author acceptance.

Both runs use the same #743 package. Every18,471 entry of the #745 package
matches src; only two required release diagnostic strings differ from #743.
No unchanged continuity or performance tests were repeated. Evidence:
assets/validation_v5_17_51/evidence/SUMMARY.json. The three existing author
checks retain their original IDs and versions, with corrected F10 instructions.
All visual and ordinary inventory/crafting/hygiene acceptance remains pending.

## 5.17.50 - Native kitchen ingredient drops (#743, parent #647)

Six untiered CaelumMaterialPickup identities gain exact M108–M113 A native
bindings: flour, raw beef, raw hake fillet, vegetable mix, culinary salt and
proofed dough. Owned #410 sources guide the fabric flour sack, fat-edged steak,
pale tapered hake with skin, potato/squash/carrot/sweetcorn, open paper salt
packet and flour-dusted dough. The five ingredient icons were accepted under
CA410-INGREDIENTS-01 on 2026-10-26; dough remains an existing candidate. Neither
constitutes acceptance of these models. All icons, recipes, cooking stations,
amounts, normalized tier1, weight, Actor.Scale0.25, collision, provenance,
contamination lots and save rules are unchanged. Containers are presentation.

The six models contain 56,580 vertices and 36,168 triangles, with97 closed
components and91 independently verified contact witnesses. Corn has70 joined
kernel volumes. Sack and paper have continuous outer/inner walls, real mouths
and full bases. Ten opening rays,15,080 projected UV triangles and radial/down
containment rays from1,483 serialized fill vertices pass. Seventeen exported
files repeat byte-for-byte; editable/native quantized triangles, original
sprite envelopes and floor bounds also pass.

Native iterations repaired stretched package UVs, flattened steak/fish forms,
the separated hake skin slab, powder leaking through the sack, a salt patch
under the packet and squash flesh crossing the rear rind. Earlier sources,
manifests, failure logs and selected inspected images remain evidence. A
cloned validator first read the wrong source family; its corrected check then
identified one inaccurate corn contact witness. A copied fixture's F4/F10
limits were corrected, and the final live fixture explicitly checks item
cycling, every rotation and the raised underside state. The separate #745
tracks the same rotation typo in earlier hide/textile/hygiene review fixtures.

Thirty recorded native detail views cover all six final-byte models, including
their undersides. Reused views are checked against the final mesh hashes in
INSPECTION.json; the final floor overview and both presentation scenes were
also inspected. Art remains provisional: coarse sack weave, regular paper
folds, a simple fat edge, visible projection/wrap seams, narrow hake skin,
thick squash rind, regular rounded corn kernels and dough underside swirl
need author review. Flat ambient lighting limits form readability.

Editable OBJ/MTL, data, owned reference hashes and portable texture:
assets/source/art/inventory_models_647/kitchen_ingredients. Built-in image_gen
produced the opaque4x4 materials.png atlas; MATERIALS_PROMPT.json keeps the
exact prompt and PROVENANCE.json the original path/hash. Pixels are copied
unchanged. Regenerate with python
assets/generators/generate_inventory_kitchen_ingredients_models.py
--output build/kitchen-ingredients --install.

The final installed build passes876 native checks:163 baseline,188 old-save
adoption including seven interactive-control checks,163 fresh,181 reload and
181 rollback. The isolated final visual run passes170. API pickup/toss,
split/merge, lots/provenance and prepared Box/quest guards do not establish
ordinary menus, real cooking/preparation or author acceptance.
One sequential700-tic six-object sprite/model pair records
942.59/918.26 queue presents/s,
p95 1.2237/1.2351 ms and
p99 1.4462/1.4739 ms.
Environment: Windows11, Ryzen9 5950X, RTX3070Ti, GZDoom4.14.2 Vulkan,
1280x720, uncapped/vsync off, background unpaused/audio5%. Queue-only timing,
unequal projected footprints and one pair do not establish GPU/display timing,
repeatability or crowd/campaign performance. All18,471 package entries match
src; six meshes, one atlas, one definition, MODELDEF and two release diagnostic
strings are the only runtime differences from #741.

Evidence: assets/validation_v5_17_50/evidence/SUMMARY.json.
CA743-KITCHEN-DROPS-01 retains author art and ordinary inventory/cooking checks.
Other materials, weapons, armor, characters, modular equipment and the original
V5.16 campaign remain unfinished.

## 5.17.49 - Native hygiene crafting drops (#741, parent #647)

Three existing untiered CaelumMaterialPickup identities gain exact native
M105/M106/M107 A bindings: animal fat, alkali and soap. Their owned #502
images, accepted under CA502-SUPPLIES-01 on 2026-10-25, guide the pale irregular
fat volume, open russet stoneware jar with white flakes and cream hand-cut
soap. The jar is presentation, not a recoverable container. Cloth already has
its own native model and remains unchanged. Recipes, tier normalization,
amounts, weight, collision, Actor.Scale0.25, provenance, contamination lots,
soap credit, hygiene tasks and save schema remain unchanged.

The three models contain 4,273 vertices, 7,804 triangles, fifteen closed
components and twelve independently verified contact witnesses. The jar has
a continuous outer/inner wall, rolled lip, real cavity and connected alkali
fill/flakes; five upward rays verify its open mouth. Serialized topology,
quantized OBJ/MD3 triangle equivalence, floor/original sprite envelopes and
all 92 soap UV triangles pass. Eleven exports repeat byte-for-byte.

Initial native inspection found bead-like fat lobes and stretched soap side
UVs. Model02 replaces fat with a single closed deformed volume and maps each
soap face in two dimensions. Model04 adds broader upper relief and a rounded
fat outline to distinguish it from soap. Earlier sources, manifests and
selected inspected captures are retained. A cloned validator initially read
the wrong source family; its failure and correction are recorded separately
from the passing geometry checks. All fifteen final front/edge/rear/underside
views, the three-case floor overview and both presentation cohorts were
inspected. Simplified raised fat lobes, a visible wrap seam, jar coloration
and underside UV swirl, flake shapes and regular soap bevels remain candidate
art requiring author review.

Editable geometry, contacts, OBJ/MTL and portable materials:
assets/source/art/inventory_models_647/hygiene. Built-in image_gen produced
materials.png; MATERIALS_PROMPT.json retains its exact prompt, and
PROVENANCE.json records the original output path/hash and owned references.
Pixels are unchanged copies. Regenerate with python
assets/generators/generate_inventory_hygiene_models.py --output build/hygiene
--install. No other accepted art or production behavior is replaced.

The installed package passes 437 native assertions (82/91/82/91/91) across
baseline, old-save adoption, fresh models, reload and rollback. All three
cases retain pickup/toss, split/merge, lot/provenance data and prepared
Box/quest guards. These API probes do not establish ordinary menus, actual
washing/crafting tasks or author acceptance. One sequential 700-tic
three-object sprite/model pair records 947.34/939.89 queue presents/s,
p95 1.2614/1.2732 ms and p99 1.5115/1.5215 ms.
Environment: Windows 11, Ryzen 9 5950X, RTX 3070 Ti, GZDoom 4.14.2 Vulkan,
1280x720, uncapped/vsync off, background unpaused/audio 5%. Queue-only timing,
one pair and unequal projected footprints do not establish GPU/display
timing, repeatability or campaign/crowd performance. All 18,463 package
entries match src; three meshes, one atlas, one definition, MODELDEF and two
required release diagnostics are the only runtime changes from #739.

Evidence: assets/validation_v5_17_49/evidence/SUMMARY.json.
CA741-HYGIENE-DROPS-01 retains author art and ordinary hygiene/inventory review.
Other materials, weapons, armor, characters, modular equipment and the V5.16
campaign remain unfinished.

## 5.17.48 - Basilisco regional inspection (#739, parent #463)

The optional CA682G gallery now displays the #738 Basilisco on both approved
Pampa and Litoral grounds. Its twelve figures cover eight species across the
existing five plots. New keys 5/6 inspect the two Basiliscos; all ten previous
positions, sixteen controls and the four-boundary walking path remain exact.
The source remains assets/source/art/regional_gallery_682/GALLERY.json.
No model, texture, campaign encounter, population rule or production behavior
changes. Regenerate through assets/validation_v5_17_48/build_gallery.py.

Complete approved associations, nonoverlapping native bodies and all existing
material contracts pass. Four fixture outputs repeat byte-for-byte. Cuyo700
and Pampa/NOA682 INVENTORY/EXPORT metadata refresh dependent source hashes;
all five native material files regenerate identically. CA709G provenance
refreshes two borrowed source pins, with its layout unchanged. The Cuyo
validator retains its five plots and original sixteen-control prefix while
allowing later displays; the shared gallery validator checks all associations.

The actual engine passes 53 fresh and 110 reload/idle/walking checks. Both
new closeups, overview, affected ground repeats, reloaded overview and the
presentation cohort were inspected. Prior identical art reuses its recorded
evidence. Native passive idle states continue while the protected observer
walks; only observer footstep noise is suppressed in the diagnostic fixture.
No forced subject position resets or production actor scans are introduced.

One 700-tic overview cohort records 1207.15 queue presents/s,
p95 0.9736 ms and p99 1.1507 ms on Windows 11,
Ryzen 9 5950X, RTX 3070 Ti, GZDoom 4.14.2 Vulkan, 1280x720, uncapped/vsync
off, background unpaused/audio 5%. Distant figures, queue-only timing and
one cohort do not establish close-up cost, GPU/display timing, repeatability,
a comparison gain or campaign/crowd performance. All 18,458 package entries
match src; only two required release diagnostics differ from the #738 package.

Evidence: assets/validation_v5_17_48/evidence/SUMMARY.json.
CA739-BASILISCO-GALLERY-01 retains author framing/ground/walking review;
CA738-BASILISCO-01 separately retains model art and ordinary gameplay review.
All earlier checks remain pending. Other characters, inventory, modular
equipment and the original V5.16 campaign remain unfinished.

## 5.17.47 - Basilisco native animated model (#738, parent #461)

The owned CA-FOLK-044 reference now has a native model bound only to
CaelumBestiary044: rooster head with a red comb and wattles, russet neck
and wing feathers, a green scaled torso, copper belly, taloned biped legs
and a curled scaled tail. Native art now covers nineteen of the 56 new
folklore classes. The approved repeatable Pampa/Litoral allocation remains;
campaign spawning and regional gallery placement are separate work.

The model contains 15,564 vertices, 27,336 triangles and 167 parts in 154
closed components. Independent serialized inspection verifies 153 rooted
contact witnesses, neutral OBJ/native triangle equivalence, zero collapsed
triangles and a grounded lowest vertex across all 23 inherited frames.
1,224 posed attachment checks transport witnesses from serialized geometry
at frames 0, 10, 17 and 22. They do not establish every interpolation or full
surface clearance. Nine exports repeat byte-for-byte. Editable geometry,
animation, contacts, OBJ/MTL and portable materials live in
assets/source/art/basilisco_738. Regenerate with python
assets/generators/generate_basilisco_model.py --output build/basilisco --install.

Built-in image_gen produced the six-tile materials.png atlas; its exact prompt
is MATERIALS_PROMPT.json, with original output path, owned references and
unchanged-copy SHA-256 in PROVENANCE.json. Iris/dark resources retain their
owned avian lineage. Model01 exposed eight detached hackle roots (40 contact
failures); Model02 extends the actual roots. Native inspection prompted a
rounded comb, smaller beak, fuller plumage and broader separated legs in
Model03. Detail views exposed stretched tail UVs and grain-like leg material.
Model05 uses the established continuous serpent sweep with repeated UV seams
and copper leg scutes; Model06 repeats its nine exports exactly. Earlier
sources, manifests, failures and selected captures remain retained.

Thirteen final front/side/rear/head/feet/tail and action/death/rest captures,
the original reference and atlas, seven earlier views and both presentation
cohorts were inspected. The stylized face/comb, regular feather layers, hard
belly material boundaries and visible tail UV repetition remain candidate
art for author review. Standing height fits the unchanged native profile;
tail/wing geometry can extend beyond collision Radius. This does not authorize
petrification, flight, new drops, metre-scale resizing or altered gameplay.
Inherited Mandinga statistics, attacks, loot, collision, Scale, identity and
save fields are unchanged; no actor scans or schema changes are introduced.

The installed package passes 115 continuity assertions (16/16/51/16/16)
across baseline, old-save adoption, fresh model, reload and rollback. Six
inherited combat scenarios including the Mandinga control, finite loot and
loot reload pass another 80 assertions (40/28/12). One sequential 700-tic
sprite/model pair records 1274.31/1311.73
queue presents/s, p95 1.0525/0.9726 ms and
p99 1.3875/1.2873 ms.
Environment: Windows 11, Ryzen 9 5950X, RTX 3070 Ti, GZDoom 4.14.2 Vulkan,
1280x720, uncapped/vsync off, background unpaused/audio 5%. Queue intervals,
different projected footprints and one pair do not establish GPU/display
timing, repeatability or campaign/crowd performance. All 18,458 package
entries match src; four model resources, one definition, MODELDEF and two
release diagnostics are the only changes from the #733 package.

Evidence: assets/validation_v5_17_47/evidence/SUMMARY.json.
CA738-BASILISCO-01 retains ordinary combat/save and visual acceptance.
Other characters, inventory, modular equipment and V5.16 remain unfinished.

## 5.17.46 - Modular anatomy/style proposals (#736, parent #458)

The author chose to review visual proposals before approving broad modular
conversion. Seven review-only boards cover human, goblin, Caelith and wolf,
bear, puma and jaguar Beast Man families, each with male/female front,
profile and back views. The source set and single review surface are
[modular_proposals_736/review.html](../assets/source/art/modular_proposals_736/review.html).
These are concept images, not native meshes or completed modular characters.

The plain cream shirt, charcoal trousers, brown belt/gloves/boots follow
owned appearance_5213 references. Heads retain natural goblin skin,
pointed goblin/Caelith ears and animal species identity. Green/white Caelith
is one skin/hair example, not a reduction of RGB skin or six hair colors.
The accepted Domingo pilot guides grounded materials and adult proportions.
Caelith v1 understated ear length; v2 restores longer pointed ears while
retaining the first image. No previous assets were replaced.

REVIEW.json records family-specific review notes, all seven pending
decisions and separate body, head/face, hair, hands, clothing and equipment
requirements. The boards show one face/hair example per humanoid sex;
the required four distinct faces and four hairstyles per sex remain
separate work. Clothing conceals body surfaces, hands and feet. Head size,
neck transitions, bear torso mass and sex silhouettes require author
review; no exact heights, stats, new tails or limb configurations are set.
Painted views are not projections from one geometric model.

Built-in image_gen created eight retained images. PROMPT.json and the
Caelith REVISION_PROMPT.json preserve exact generation/edit prompts.
PROVENANCE.json records every owned reference hash, original generated
path and unchanged-copy output hash. The saved artifacts are reproducible;
AI generation itself is not claimed deterministic. All eight outputs and
seven selected boards were visually inspected; static provenance, links,
version headers and document-index checks are recorded under
assets/validation_v5_17_46/evidence. Browser captures review the page layout.
No new engine test is claimed: the only src edits update the two mandated
diagnostic release labels. Runtime geometry, animation and behavior are
unchanged. CA736-MODULAR-STYLE-01 awaits the author's visual direction.

## 5.17.45 - Fabric, fibers and rope world models (#733, parent #647)

Six existing CaelumMaterialPickup designs gain native models: fabric18,
wool71, cotton72, raw silk73, plant fiber74 and rope75. Exact M018/071..075 A
bindings preserve three fabric tiers and five untiered materials, eight cases.
Owned icons guide folded cream cloth, fleece, cotton bolls/husks/stems, silk
cocoons, bound dry fibers and a coiled rope hank. Cloth has actual open folds;
fibers, bolls and coils have closed volumes and joined components. Rope reuses
the authored #725 strand construction with a new material and central binding.
Existing icons, recipes, tiers, amounts, weight, collision, Actor.Scale0.25,
provenance, quest behavior and save schema are unchanged.

The six models contain 48,666 vertices, 73,184 triangles, 114 closed solids
and 108 independently verified contact witnesses. Serialized topology,
noncollapsed quantized MD3 triangles, floor/original sprite envelopes and
five opening probes/50 rays pass. Seventeen exports repeat byte-for-byte.
Initial cotton witnesses on root caps prompted deeper branch/husk roots.
Native review then prompted arc-length cloth UV tiling, shallow oriented
fleece locks, finer silk threads and centered tapered plant fibers. Cloth
UV seam vertices retain exact shared positions. The triangulator explicitly
handles the opposite winding of the folded sheet's two end caps. Initial
sources, manifests and previews remain retained.

All 30 final detail/underside views, eight-case floor overview and both
presentation cohorts were inspected. Regular cloth folds, shallow fleece
locks, the upright cotton branch, silk winding and fiber/binding shapes remain
candidate art requiring author review. Editable OBJ/MTL and portable texture:
assets/source/art/inventory_models_647/textiles. Built-in image_gen produced
materials.png; MATERIALS_PROMPT.json preserves the exact prompt and
PROVENANCE.json its original path/hash. Pixels are unchanged copies.
Regenerate with python assets/generators/generate_inventory_textile_models.py
--output build/textile-models --install.

The installed package passes 1,157 native assertions (217/241/217/241/241)
across baseline, old-save adoption, fresh models, reload and rollback. All
eight cases retain pickup/split/merge, provenance, lots, Box weight and quest
guards. API checks do not establish ordinary menus/crafting acceptance.
One 700-tic six-object sprite/model pair records 876.74/852.02 queue presents/s,
p95 1.3865/1.3934 ms and p99 1.6478/1.6308 ms on Windows 11/Ryzen 9 5950X/RTX 3070 Ti,
GZDoom 4.14.2 Vulkan 1280x720, uncapped/vsync off, background unpaused/audio 5%.
These queue measurements and different projected footprints do not establish
GPU/display timing, repeatability or campaign/crowd acceptance. All 18,453
package entries match src; six models, one atlas, one definition, MODELDEF
and two release diagnostics are the only runtime changes from #731.
Evidence: assets/validation_v5_17_45/evidence/SUMMARY.json.
CA733-TEXTILE-DROPS-01 retains art and ordinary inventory/crafting acceptance.
Other inventory, characters, worn/first-person art and V5.16 remain unfinished.

## 5.17.44 - Leather and hide world models (#731, parent #647)

Four existing CaelumMaterialPickup designs gain native world models: leather19,
cow hide76, predator hide77 and monster hide78. Exact M019/076/077/078 A
bindings cover three leather tiers and three untiered hides, six cases total.
Owned icons guide russet leather, brown/cream cow hair, tawny predator fur and
dark plum/teal scales. Subdivided irregular sheets have geometric folds,
thickness, closed rims and leather reverse faces. Separate UV vertices share
exact positions along the material seams; no billboard cutouts are used.
Existing icons, recipes, tiers, amounts, weight, collision, Actor.Scale0.25,
provenance, quest behavior and save schema are unchanged.

Four closed solids contain 4,416 vertices and 4,784 triangles. Independent
serialized checks verify outward topology, exact noncollapsed quantized MD3
triangles, original sprite envelopes, floor contact and the intended atlas
region for every top, reverse and rim triangle. Thirteen exports repeat
byte-for-byte. The first model used its outer material on the reverse; native
review prompted separate leather reverse/rim UVs. Initial sources, manifests
and previews remain retained. All 20 final detail views, the six-case floor
overview and both presentation cohorts were inspected. Polygonal outlines,
folds, contrasting russet rims and large painted scales remain candidate art.

Editable OBJ/MTL and portable textures are in
assets/source/art/inventory_models_647/hides. Built-in image_gen generated
materials.png; MATERIALS_PROMPT.json retains the exact prompt and
PROVENANCE.json the original path/hash. Pixels were copied without raster
edits. Regenerate with python assets/generators/generate_inventory_hide_models.py
--output build/hide-models --install.

The final package passes 869 native assertions (163/181/163/181/181) across
baseline, old-save adoption, fresh models, reload and rollback. All six cases
retain pickup/split/merge, lots, provenance, Box weight and quest guards.
API probes do not establish ordinary menu/crafting acceptance.
One 700-tic four-object sprite/model pair records 1152.26/1132.35 queue presents/s,
p95 1.0432/1.0793 ms and p99 1.2830/1.3327 ms on Windows 11/Ryzen 9 5950X/RTX 3070 Ti,
GZDoom 4.14.2 Vulkan 1280x720, uncapped/vsync off, background unpaused/audio 5%.
Queue-only timing and different projected footprints establish no GPU/display,
repeatability or campaign/crowd acceptance. All 18,445 package entries match
src; four models, one atlas, one definition, MODELDEF and two release
diagnostics are the only runtime changes from #729.
Evidence: assets/validation_v5_17_44/evidence/SUMMARY.json.
CA731-HIDE-DROPS-01 retains author art and ordinary inventory/crafting review.
Other inventory, characters, worn/first-person art and V5.16 remain unfinished.

## 5.17.43 - Hybrid serpents in the regional gallery (#729, parent #463)

Optional CA709G adds Mbói Tu’ĩ in Litoral and Mbói Yaguá in both Litoral and
Selva, following the approved allocation. Fourteen displays cover eleven
native species on four existing regional grounds. The eleven earlier figure
positions, eighteen controls, all plots and the crossing route remain intact.
New diagnostic positions occupy the western/eastern Litoral columns and the
foreground Selva row. CA463G and CA682G remain unchanged. Data and provenance
live in assets/source/art/regional_gallery_709; the earlier layout is retained
in this issue's evidence. All production model and texture bytes are reused.

Run python assets/validation_v5_17_43/run_gallery.py --runtime
build/caelum_argenteum_dev.pk3 --output build/hybrid-regions-author-01 --interactive.
Keys 8, 9 and 0 inspect Tu’ĩ/Litoral, Yaguá/Litoral and Yaguá/Selva respectively.
F1 remains overview and F5 walking; all prior figure/ground controls remain.
Passive displays advance native idle animation. Only diagnostic observer
footsteps are silent; repeated appearances do not define campaign populations.

Four fixture files repeat byte-for-byte. Independent validation checks exact
model/texture reuse, complete approved associations, native-body separation,
camera bounds and unique controls. Native fresh/reload checks pass 61/126
assertions (187 total), including identity, position, idle advancement, silent
steps and the retained 630-tic crossing through three boundaries. Expanded
overview, three new closeups, affected Litoral/Selva ground views, reload and
presentation views were inspected. Unchanged earlier closeups reuse prior
gallery evidence; #727 combat/save evidence applies to identical model bytes.

One 700-tic distant-overview measurement records 1457.72 queue presents/s, p95 0.8706 ms, p99 1.0173 ms; mean simulation 28.5714 ms/tic.
Environment: Windows 11, Ryzen 9 5950X, RTX 3070 Ti, GZDoom 4.14.2 Vulkan,
1280x720, background unpaused/audio 5%, uncapped/vsync off. This measures queue
presentation for small distant figures, not GPU/display timing, comparative
cost, closeup performance, repeatability or campaign/crowd acceptance.
All 18,439 package entries match src; only two release diagnostics differ
from #727. Evidence: assets/validation_v5_17_43/evidence/SUMMARY.json.
CA729-HYBRID-GALLERY-01 and earlier model/gallery author checks remain pending.
Other characters, inventory, modular/worn and first-person equipment, and
the original V5.16 campaign remain unfinished.

## 5.17.42 - Mbói Tu’ĩ and Mbói Yaguá native models (#727, parent #461)

Two supplied concepts gain native models on their existing classes: unique
CA-FOLK-048 Mbói Tu’ĩ (Litoral) and repeatable 052 Mbói Yaguá (Litoral/Selva).
Both have continuous serpent bodies, ivory ventral scutes and attached dorsal
tufts. Tu’ĩ has a hooked parrot beak, red head and red/yellow/green plumage;
Yaguá has a canine muzzle, pointed ears, gray-brown fur and cream cheeks.
Editable spine, section radii, anatomy, materials and pose data accompany
portable OBJ/MTL sources. Native art now covers eighteen of 56 new folklore
classes; this does not certify author acceptance or campaign encounters.

| Model | Vertices | Triangles | Closed components | Neutral contacts | Independent posed checks |
| --- | ---: | ---: | ---: | ---: | ---: |
| Mbói Tu’ĩ | 10,444 | 17,064 | 43 | 42 | 336 |
| Mbói Yaguá | 10,574 | 17,472 | 43 | 42 | 336 |

All 23 inherited frame/action identities and provisional Mandinga rules stay
unchanged, including attacks, hostility, loot, actor Scale, collision and
saves. The neutral model fits the existing Height; its visual footprint can
extend beyond collision Radius. Catalogue metre ranges do not authorize
runtime resizing. No population, regional assignment or named actor changes.
Fixed-species anatomy is separate from modular humanoid/worn-equipment work.

Source: assets/source/art/hybrid_serpents_727. Built-in image_gen produced
materials.png; MATERIALS_PROMPT.json contains the exact final prompt, while
PROVENANCE.json retains its original output path and SHA-256. The owned
references and #720 iris/dark pixels remain unchanged. No raster editing.
Regenerate with python assets/generators/generate_hybrid_serpent_models.py
--output build/hybrid-serpents --install. Twelve exports repeat byte-for-byte.
The shared #720 independent inspector accepts optional source/model paths;
its original defaults and all prior native model bytes remain unchanged.

Independent serialized inspection verifies 86 closed outward solids, 84
rooted neutral witnesses and exact quantized OBJ/native triangle equivalence.
Every pose has zero collapsed triangles and a grounded lowest vertex, with
six distinct death stages. In frames 0, 10, 17 and 22, 672 checks transport
contact witnesses from actual serialized child vertices and test containment
in both child and parent. This does not prove every interpolation or complete
surface clearance. Model01 exposes 362 contact failures, primarily witnesses
on cap planes, plus shallow crown/mane/eye joins. Model02 deepens physical
roots, fixes those contacts, refines head/beak/ear proportions and adds a
canine muzzle bridge. Both iterations pass 51 native preview assertions per
species; the final geometry passes all independent checks. Model03 repeats
all bytes. Failed data and original candidates remain in the evidence.

Final front/side/rear and head views, selected movement/attack/pain/death and
lying poses, and both presentation cohorts per species were inspected.
Simplified facial surfaces, sparse regular dorsal tufts, belly UV transitions
and rigid jaw/crest animation remain candidate art for author review.

Native continuity passes 230 assertions (115 each: 16/16/51/16/16) covering
baseline, old-save adoption, fresh models, reload and rollback. Nine inherited
combat scenarios with a Mandinga control, finite loot and loot reload pass
136 assertions (66/50/20). One 700-tic sprite/model pair per species records:

| Species | Queue presents/s, sprite / model | p95 ms, sprite / model | p99 ms, sprite / model |
| --- | ---: | ---: | ---: |
| mboi_tui | 1805.01 / 1836.32 | 0.7514 / 0.6999 | 0.9147 / 0.8482 |
| mboi_yagua | 1824.34 / 1833.71 | 0.7401 / 0.6861 | 0.9362 / 0.8162 |

Environment: Windows 11, Ryzen 9 5950X, RTX 3070 Ti, GZDoom 4.14.2 Vulkan,
1280x720, background unpaused, audio 5%, uncapped presentation without vsync.
Queue intervals are not GPU/display timing. Unequal footprints and one pair
do not establish repeatability or campaign/crowd performance. All 18,439
package entries match src. Only six new native resources, MODELDEF and two
release diagnostics differ from #725. Full evidence:
assets/validation_v5_17_42/evidence/SUMMARY.json. CA727-HYBRID-SERPENTS-01 remains
pending. Regional-gallery placement is a separate issue. Other characters,
inventory, worn/first-person equipment and the V5.16 campaign are unfinished.

## 5.17.41 - Weapon assembly component world models (#725, parent #647)

Nine existing CaelumMaterialPickup designs gain native world models: hilt25,
long hilt26, point27, bowstring30, reinforced bowstring31, strap32, reinforced
strap33, barrel34 and mechanism35. Exact M025/026/027/030/031/032/033/034/035 A
bindings cover all27 type/tier cases. Owned icons guide wrapped red/brown grips,
a diamond-ridge point, twisted coiled cords/ferrules, leather loops/buckles,
reinforcement, a hollow tube and a connected mechanical assembly. This is
static world art: recipes, icons, quantities, tiers, weights, collision,
Actor.Scale0.25, provenance, quest behavior and save schema are unchanged.

83 closed solids contain34,364 vertices and61,776 triangles. The independent
serialized inspector verifies outward topology,75 rooted contact witnesses,
10 opening probes/75 rays, exact noncollapsed quantized MD3 triangles, sprite
envelopes and floor contact. Probes cover coil/strap space, buckle windows,
socket exits and the tube bore; they do not claim an unobstructed passage
through the complete pointed head. Twenty-three exports repeat byte-for-byte.
The shared #723 inspector now takes an optional source family; its original
default checks remain unchanged.

Model01 passes geometry and730 preview checks, but visual review finds smooth
cords, partly occluded buckle rails and a flat mechanical backing. Model02
adds actual twisted strands, mounting posts, a diamond ridge and open support
arms; geometry and730 preview checks pass. All45 final detail views, floor
overview and both presentation cohorts were inspected. Simplified grip
ornament, regular coils, strap tails and mechanical detail remain candidate
art requiring CA725-ASSEMBLY-COMPONENTS-01 author review.

Editable sources and portable textures are in
assets/source/art/inventory_models_647/assembly_components. The original
fibers.png atlas was generated with built-in image_gen; FIBERS_PROMPT.json
retains the exact prompt and PROVENANCE.json its origin/hash. #723 metal pixels
are reused exactly, with their prior provenance. Original icons are preserved;
no raster edits. Regenerate with python
assets/generators/generate_inventory_assembly_components_models.py --output
build/assembly-component-model --install.

The final package passes3,893 native assertions (730/811/730/811/811) across
baseline, old-save adoption, fresh models, reload and rollback. All27 cases
retain native pickup/split/merge, lots, provenance, Box weight and quest guards.
API probes do not establish ordinary menu/crafting acceptance.
One700-tic nine-object sprite/model pair records 1006.19/998.93 queue presents/s,
p95 1.1873/1.2344 ms and p99 1.4033/1.3956 ms on Windows11/Ryzen9 5950X/RTX3070Ti,
GZDoom4.14.2 Vulkan1280x720, uncapped/vsync off, background unpaused/audio5%.
Queue-only timing and different projected footprints establish no GPU/display,
repeatability or campaign/crowd acceptance. All18,433 package entries match src;
nine models, one atlas, one definition, MODELDEF and two release diagnostics
are the only runtime changes from #723.
Evidence: assets/validation_v5_17_41/evidence/SUMMARY.json. Other inventory,
characters, worn/first-person art and the V5.16 campaign remain unfinished.

## 5.17.40 - Metal weapon crafting component world models (#723, parent #647)

Eight existing CaelumMaterialPickup designs now have native world models:
blade1, small blade2, curved blade3, long blade4, broad blade5, weapon head9,
round head10 and small weapon head40. The exact M001/002/003/004/005/009/010/
040 A bindings cover all24 existing type/tier cases. Original owned icons
guide the separate blanks, crescent, double axe, spiked heads and spear point.
This delivery covers static crafting drops; equipped and first-person weapons
remain separate. Actor.Scale0.25, Radius12/Height8, tiers, recipes, quantities,
weight, provenance, contamination, quest behavior and save schema are unchanged.

The eight models contain4,328 vertices and7,672 triangles in57 closed solids.
Independent serialized OBJ checks verify outward closure, topology,49 rooted
attachment witnesses, four actual socket mouths with20 clearance rays, sprite
envelopes, floor contact and exact noncollapsed quantized MD3 triangle multisets.
Socket probes establish an open exit from inside each mouth, not an unobstructed
path through the complete assembled head. Beveled blade rings, genuine tips,
triangulated concave axe wings and closed annular socket walls provide volume.
Twenty-one final exports repeat byte-for-byte and installed output checks pass.

Initial ingot material crops failed the strict opacity check (alpha251..254);
opaque existing materials passed but native review found bland metal and an
S-shaped curved blade. A new original aged-metal atlas from built-in image_gen
and a reference-led crescent refine the candidate. A final UV adjustment maps
the socket interiors to darker metal. Existing icons and training-dummy wood
pixels are preserved. Earlier material copies, design snapshots, manifests,
failure logs and previews remain as evidence. No raster postprocessing.
Editable JSON/OBJ/MTL, portable materials, metals.png and the exact generation
prompt METALS_PROMPT.json are retained in
assets/source/art/inventory_models_647/weapon_components.
Regenerate with python assets/generators/generate_inventory_weapon_components_models.py
--output build/weapon-component-model --install.

The final preview passes649 checks. All40 front/edge/rear-oblique/rear/raised
underside detail views, ordinary floor overview and both presentation cohorts
were inspected. Simplified blade outlines, uniform wear, regular spike spacing
and the separate axe hub remain candidate art requiring author review.
The final package passes3,461 native assertions (649/721/649/721/721) across
baseline sprites, old-save adoption, fresh models, reload and rollback. All24
cases retain pickup/split/merge, lot boundaries, provenance, Box weight and
quest guards. API fixtures do not establish ordinary menu/crafting acceptance.

One sequential700-tic eight-object sprite/model pair records 1020.03/988.52 queue
presents/s, p95 1.2269/1.2361 ms and p99 1.4539/1.4849 ms on Windows11/Ryzen9
5950X/RTX3070Ti, GZDoom4.14.2 Vulkan1280x720, uncapped/vsync off,
background unpaused, audio5%. Different projected footprints and queue-only
timing establish no GPU/display, repeatability or campaign/crowd acceptance.
All18,422 package entries match src. Eight models, one atlas,
one definition, MODELDEF and two release diagnostics are the only runtime
changes from #721. Evidence: assets/validation_v5_17_40/evidence/SUMMARY.json.
CA723-WEAPON-COMPONENTS-01 remains pending. The broader inventory, character,
modular equipment and V5.16 campaign work remains unfinished.

## 5.17.39 - Serpent regional gallery extension (#721, parent #463)

Optional CA709G adds Moñái in Selva and Mbói Tatá in both Litoral and Selva,
following the approved associations. Eleven displays cover nine native species
on four reused regional grounds. All eight earlier positions, plots, crossing
path and controls remain; three rear-row diagnostic positions and inspection
cameras are added. CA463G and CA682G are unchanged. All native model/material
bytes are reused. Data and provenance remain in
assets/source/art/regional_gallery_709; the previous layout is archived.

Run python assets/validation_v5_17_39/run_gallery.py --runtime
build/caelum_argenteum_dev.pk3 --output build/serpent-regions-author-01 --interactive.
New keys: 5 Moñái/Selva, 6 Mbói Tatá/Litoral, 7 Mbói Tatá/Selva. Retained:
F1 overview, F2/F3 Litoral/Selva Pombero, F4 Patagonia, F5 walk, F6 Cuero,
F7 Nahuelito, F8 Cachiru, F9 Kakuy, F11 Peuchen, F12 Kelenken; number keys
1/2/3/4 inspect Litoral/Selva/Patagonia/NOA ground. Native idle animation
advances; only diagnostic observer footsteps are silent. Repeated displays
show approved associations without establishing campaign population rules.

Four fixture files repeat. Independent checks verify exact export hashes,
complete approved region associations, separated collision bodies and valid
cameras. Native fresh/reload passes 49/102 assertions, including eleven
identities/positions, advancing idle states, silent observer footsteps and
the existing 630-tic crossing of three boundaries at unchanged movement
speed. Added closeups, expanded/reloaded overview, affected ground views
and presentation were inspected. Unmodified art/combat evidence remains
applicable, including #720's 230 continuity and 136 combat/loot assertions.

One 700-tic eleven-display distant overview records 1491.67 queue presents/s, p95 0.8887 ms, p99 1.0917 ms; mean simulation 28.5718 ms/tic.
Environment: Windows 11 Pro26200, Ryzen9 5950X,32GB, RTX3070Ti;
GZDoom4.14.2 Vulkan1280x720, uncapped/vsync off, background unpaused, audio5%.
Queue intervals do not establish GPU/display timing, repeatability,
comparative cost, close-up budget or campaign/crowd acceptance. All
18,412 package entries match src; only two release diagnostics differ
from #720. Evidence: assets/validation_v5_17_39/evidence/SUMMARY.json.
CA721-SERPENT-GALLERY-01 and earlier gallery/art checks remain pending.
No campaign map, encounter, balance, production AI or save schema changes.
Use fresh isolated gallery saves; broader character/equipment work is unfinished.

## 5.17.38 - Moñái and Mbói Tatá native models (#720, parent #461)

Two owned serpent concepts now have actual volumetric native models on the
existing CA-FOLK-049 Moñái (unique, Selva) and 051 Mbói Tatá (repeatable,
Litoral/Selva) classes. Moñái retains olive scales, pale ventral scutes, two
horns and slit eyes. Mbói Tatá has bronze/charcoal scales with ember seams,
brass scutes and closed flame-shaped dorsal/tail crests and a five-part crown.
Each continuous limbless body has editable spine, section radii, anatomy,
materials and pose data. Native art covers sixteen of 56 new folklore classes.

| Model | Vertices | Triangles | Closed components | Neutral contacts | Independent posed checks |
| --- | ---: | ---: | ---: | ---: | ---: |
| Moñái | 11,379 | 20,576 | 13 | 12 | 96 |
| Mbói Tatá | 13,641 | 23,784 | 33 | 32 | 256 |

All 23 inherited sprite/frame/action identities and the approved provisional
Mandinga rules remain unchanged, including attacks, hostility, loot, actor
Scale, collision and saves. The neutral model fits the existing Height; its
coiled footprint can extend beyond collision Radius. Catalogue metre ranges
do not authorize gameplay resizing. No new fire effect, attack or population
is added. Rulo, Mandinga, Zupay and other native art remain unchanged. Fixed
creature anatomy is separate from modular humanoid/worn-equipment work.

Source: assets/source/art/serpents_720. Built-in image_gen produced the two
scale textures and a four-material belly/horn/crest atlas. Exact prompts,
original output paths, image hashes and owned reference provenance are
retained. Peuchen iris/dark textures are reused unchanged. Portable OBJ/MTL,
JSON anatomy and the original materials remain editable. Regenerate with
python assets/generators/generate_serpent_models.py --output build/serpents
--install. Fourteen final exported files repeat byte-for-byte.

Independent serialized checks verify 46 closed outward solids, 44 rooted
neutral contacts, exact quantized OBJ/native equivalence and no collapsed
triangle in any of the 23 poses per species. All poses have a grounded lowest
vertex and six distinct death stages. Four critical native frames (idle,
attack release, final death and rest) receive 352 attachment checks: witnesses
are transported from four actual serialized child vertices, independently
of generator deformation, then tested against both solids with two rays.
This does not prove every interpolation or full-surface clearance.

Initial geometry exposed collapsed tail/pupil/crest-tip triangles and invalid
attachment witnesses. Revised sampling and radii fixed them; extending the
falling neck removed a pinch. Native visual review then exposed accumulated
body-frame roll, corrected with world-up anatomical frames and reoriented
crest data. A later independent posed check found the jaw detached at attack
frame 10 despite valid neutral contacts. Enlarging the jaw around its existing
pivot fixed both species; Mbói Tatá also gained three crown flames. The final
ordinary-light previews pass 51 checks each. Front/side/rear, head details,
attack and selected run/pain/death/lying views were inspected. Simplified
heads, regular coil, belly UV transitions and rigid jaw/crest remain subject
to author review. All prior candidates and failure evidence are retained.
Final provenance-only regeneration preserves all thirteen nonmanifest files.

Final native continuity passes 230 assertions (115 each: 16/16/51/16/16),
covering old sprite saves, model adoption, fresh models, reload and rollback.
Nine inherited combat scenarios against a Mandinga control and finite loot
reload pass 136 assertions (66/50/20). One sequential 700-tic sprite/model
presentation comparison per species records:

| Species | Queue presents/s, sprite / model | p95 ms, sprite / model | p99 ms, sprite / model |
| --- | ---: | ---: | ---: |
| monai | 1801.50 / 1811.85 | 0.7418 / 0.7348 | 0.8872 / 0.8627 |
| mboi_tata | 1814.66 / 1815.26 | 0.7371 / 0.7091 | 0.9066 / 0.8224 |

Environment: Windows 11, Ryzen 9 5950X, RTX 3070 Ti, GZDoom 4.14.2 Vulkan,
1280x720, background unpaused, audio 5%, uncapped presentation without vsync.
Queue intervals are not GPU/display timing. Unequal footprints and one pair
do not establish repeatability or crowd/campaign performance. All 18,412
runtime entries match src; only eight new serpent resources, MODELDEF and
two release diagnostics differ from #717. Evidence is in
assets/validation_v5_17_38/evidence/SUMMARY.json. CA720-SERPENTS-01 is pending.
Regional-gallery placement is a separate issue. Other characters, worn and
first-person equipment, and the original campaign remain unfinished.

## 5.17.37 - Wooden crafting component world models (#717, parent #647)

Six existing CaelumMaterialPickup designs gain native world models: shaft6,
frame7, long frame8, handle28, long handle29 and wood42, using their M006/007/
008/028/029/042 A sprites. All eighteen existing type/tier cases retain the
same rules and icons. Owned rounded shafts, flared handle, distinct curved
bow frames with their visible strings, and cut timber guide the silhouettes.
Staff/support weapons remain separate. Actor.Scale0.25, Radius12/Height8,
recipes, quantities, weight, provenance, contamination and saves are unchanged.

Eight closed components contain5,219 vertices and10,000 triangles. Each bow
has one genuine opening, checked at two interior areas with ten rays per
area; four endpoint witnesses independently join the two strings to the limbs.
Serialized OBJ checks verify outward closure, solid topology, attachment depth,
all40 unobstructed rays, original sprite envelopes, floor contact and exact
noncollapsed quantized MD3 triangle multisets. Geometry reporting calls these
four sampled areas opening_probes, not four separate bow holes.
Owned training-dummy wood and existing painted strap pixels are reused exactly.
No new bitmap or icon edit. Editable JSON/OBJ/MTL and portable materials live in
assets/source/art/inventory_models_647/wood_components. Regenerate with python
assets/generators/generate_inventory_wood_components_models.py --output
build/wood-component-model --install. Sixteen final exports repeat byte-for-byte.

The preview passes487 checks. All thirty front/edge/rear-oblique/rear/raised
underside details, ordinary floor overview and both presentation cohorts were
inspected. Final generator cleanup changes metadata only; all fifteen other
exports remain identical to that preview. Uniform brown material, simplified
decoration and regular curves remain candidate art pending author review.
The final package passes2,597 native assertions (487/541/487/541/541) for
baseline sprites, old-save/model, fresh model, reload and rollback, including
all eighteen types/tiers, pickup/split/merge, lot boundaries, provenance,
Box weight and quest guards. API fixtures do not establish menu/crafting or
author acceptance.

One sequential700-tic six-object sprite/model pair records 1036.43/1046.24 queue
presents/s, p95 1.1954/1.1952 ms and p99 1.4774/1.4470 ms on the recorded Windows11/Ryzen9
5950X/RTX3070Ti system, GZDoom4.14.2 Vulkan1280x720, uncapped/vsync off,
background unpaused, audio5%. Different projected footprints and queue-only
timing establish no GPU/display, repeatability or campaign/crowd acceptance.
All18,404 package entries match src; six models, one definition,
MODELDEF and two release diagnostics are the only runtime changes from #716.
Evidence: assets/validation_v5_17_37/evidence/SUMMARY.json.
CA717-WOOD-COMPONENTS-01 remains pending. Other inventory, character, modular
equipment and campaign work remain unfinished.

## 5.17.36 - Chain and silver-chain material world models (#716, parent #647)

CaelumMaterialPickup now binds M041/A to a closed spiked head, eye and linked
chain, and M043/A to a coiled silver chain. The owned material icons guide
both shapes and remain unchanged. Type41 retains its three existing tiers;
type43 remains untiered and resolves requested tiers2/3 to1. These are four
real inventory cases sharing two static models. Icons, recipes, weight,
quantities, Scale0.25, collision, saves, provenance and contamination are
unchanged. Equipped weapons and first-person art remain separate.

The iron component contains18 closed parts, including nine interlaced rings,
a true-pole head and eight closed spikes:2,092 vertices and4,128 triangles.
The silver coil contains31 closed oval rings:5,952 vertices and11,904
triangles. All40 rings have real openings. The38 linked pairs and nine fixed
head/spike/eye witnesses connect all49 components. Opaque owned training-dummy
iron and the existing #647 painted silver atlas are reused byte-for-byte;
no image is generated. DESIGN/PROVENANCE/EXPORT and portable OBJ/MTL/textures
live in assets/source/art/inventory_models_647/chains. Regenerate with python
assets/generators/generate_inventory_chains_models.py --output build/chains-model
--install. Eight final exports repeat byte-for-byte.

Independent serialized checks verify closed outward solids, genus-one links,
positive wire-capsule clearance, the actual interlacing graph, two-ray fixed
attachment witnesses and exact quantized OBJ/MD3 triangle multisets. The first
graph is connected but two pairs fail clearance: the head eye/first link and
the inner silver terminal pair. Refitting the eye plane, using analytic
spiral tangents and widening silver link openings resolves both. Final minimum
capsule gaps are0.154620/0.813393 native model units, above the0.027065
quantization allowance. Original failed data and report remain evidence.
Both original sprite envelopes and portable opaque material pixels are checked.

The ordinary-light preview passes110 checks; front, edge, rear-oblique, rear,
raised underside and floor views were inspected for both designs. Uniform
metal, simplified spikes and the regular coil remain candidate art, with
rigid arrangements rather than chain simulation. Final packaged native checks
pass 586 assertions (110/122/110/122/122) across old sprites, old-save/model,
fresh model, reload and rollback. They cover four real cases, native split/merge,
ownership, original lot boundaries, provenance, Box weight, quest guard,
untiered silver resolution and unchanged sprite/icon/collision. Direct API
probes do not replace ordinary-menu/crafting or author acceptance.

One sequential700-tic two-object sprite/model pair records 1123.54/1167.32 queue
presents/s, p95 1.0844/1.0432 ms and p99 1.3922/1.2610 ms. Recorded Windows11/Ryzen9 5950X/
RTX3070Ti environment, GZDoom4.14.2 Vulkan1280x720, uncapped/vsync off,
background unpaused, audio5%. Queue timing and different projected footprints
establish no GPU/display, repeatability or campaign/crowd result. All
18,397 package entries match src. Three new resources, MODELDEF and two
release diagnostics are the only runtime changes from #713. Evidence:
assets/validation_v5_17_36/evidence/SUMMARY.json. CA716-CHAINS-01 remains
pending; other inventory categories and the broader character/campaign batch
remain unfinished.

## 5.17.35 - Avian regional gallery extension (#713, parent #463)

Optional CA709G now includes Cachiru and Kakuy on the existing NOA ground,
and Kelenken in Patagonia. Eight displays cover seven native species and four
approved regions. The original five display positions and three plots remain;
a contiguous NOA plot extends the room westward. CA463G and CA682G are unchanged.
All model/material bytes and source provenance are reused. No new bitmap or
model is generated. GALLERY.json and PROVENANCE.json under
assets/source/art/regional_gallery_709 retain the current inspection data;
the earlier layout is preserved with the new evidence.

Run python assets/validation_v5_17_35/run_gallery.py --runtime
build/caelum_argenteum_dev.pk3 --output build/avian-regions-author-01 --interactive.
F1 overview, F2/F3 Litoral/Selva Pombero, F4 Patagonia, F5 walk, F6 Cuero,
F7 Nahuelito, F8 Cachiru, F9 Kakuy, F11 Peuchen and F12 Kelenken. Number keys
1/2/3/4 show repeated Litoral/Selva/Patagonia/NOA ground. These current controls
supersede the earlier CA709G F8-F10 tiling bindings. Passive native figures
retain real idle states; only diagnostic observer footsteps are muted.

Four fixture files repeat. Independent checks verify exact exports and
approved regional associations, nonoverlapping collision bodies, contiguous
boundaries and cameras inside the room. Fresh/reload native phases pass
37/78 assertions, including all eight identities/positions, advancing idle
states and a 630-tic walk across three boundaries with unchanged movement
speed. New avian views, overview, NOA tiling, Patagonia framing, reload and
presentation were inspected. Existing unmodified model/combat and material
evidence remains applicable.

One700-tic eight-display distant overview records 1554.24 queue presents/s, p95 0.8553 ms, p99 1.0707 ms; mean simulation 28.5712 ms/tic.
Recorded environment: Windows11 Pro26200, Ryzen9 5950X,32GB, RTX3070Ti;
GZDoom4.14.2 Vulkan1280x720, uncapped/vsync off, background unpaused, audio5%.
This queue-only sample establishes no GPU/display timing, repeatability,
comparative cost, close-up budget or campaign/crowd acceptance. All
18,394 package entries match src; only two release diagnostics differ
from #711. Evidence: assets/validation_v5_17_35/evidence/SUMMARY.json.
CA713-AVIAN-GALLERY-01, CA709-NATIVE-GALLERY-01 and individual art checks remain
pending. Production encounters, population, flight, saves and broader 3D work
are unchanged. Use isolated gallery saves, not campaign saves.

## 5.17.34 - Cachiru, Kakuy and Kelenken native models (#711, parent #461)

Three owned avian concepts now have candidate volumetric native models on
their existing classes: CA-FOLK-045 Cachiru/Cachuru (repeatable), 046 Kakuy/Cacuy
(unique) and 058 Kelenken (unique). Native art covers fourteen of the 56 new
folklore combat classes. Cachiru retains its dark mottled plumage and swept
owl tufts; Kakuy has a rounded tuftless head, large round eyes, small beak and
lighter barred feathers. Kelenken follows the author's winged raptor concept,
with a long neck/head, hooked beak and charcoal/rust plumage. It is not recast
as a flightless reconstruction. Wings, tails, toes, curved talons and beaks
are actual closed volumes with editable hinges and anatomy data.

| Model | Vertices | Triangles | Hierarchy parts | Closed components | Neutral attachment witnesses |
| --- | ---: | ---: | ---: | ---: | ---: |
| Cachiru | 10,229 | 18,496 | 121 | 108 | 107 |
| Kakuy | 9,651 | 17,472 | 113 | 100 | 99 |
| Kelenken | 9,535 | 17,184 | 118 | 105 | 104 |

All 23 inherited sprite/frame/action identities remain. Art transforms use
species data; provisional Mandinga attacks, attributes, hostility, loot,
Scale, collision and save behavior are unchanged. Neutral Height fits that
existing profile. Catalogue metre ranges do not authorize runtime dimensions;
wings do not add flight. Rulo, Mandinga, Zupay and older model bytes remain
untouched. Regional galleries are a separate follow-up, with the existing
approved distributions preserved.

Source: assets/source/art/avian_711. Built-in image_gen produced coverts.png,
flight.png and the refined coverts-v2.png. Exact prompts and references are
in COVERTS_PROMPT.json, FLIGHT_PROMPT.json and COVERTS_V2_PROMPT.json. Both
coverts generations remain intact; the refined atlas and flight atlas are
active. Owned Peuchen iris/dark sources are reused unchanged; circular pupils
are modeled geometry. Editable OBJ/MTL and JSON remain alongside the native
exports. Fixed-creature anatomy is not interchangeable worn equipment.

Regenerate with python assets/generators/generate_avian_models.py --output
build/avian-model --install. Sixteen final exports repeat byte-for-byte.
Independent serialized checks verify 313 closed outward solids, a rooted
310-witness attachment graph with two-ray/quantization clearance, exact
class mappings and noncollapsed triangles in every quantized pose. Shared
backends remain unchanged. Neutral contacts do not prove all-pose clearance.

The first validator attempted a copied Peuchen OBJ path; its correction
exposed no avian geometry failures. Initial native previews passed 51 checks
per species, but visual review prompted denser feathers, shorter Cachiru
tufts/brows and a smaller Kakuy beak. The refined previews also pass 51 each.
Original sources and prior candidates remain evidence; inactive native
coverts.png was moved to local recovery, not deleted. Final provenance-only
changes affect manifest.json; the other fifteen exported files are identical
to the visually tested candidate. Front/side/rear, head, selected actions,
death and folded lying views were reviewed. Simplified facial disks/beaks,
feather layering, talons and rigid articulation still require author review.

Final native continuity passes 345 assertions: 115 per species across old
sprites, old-save/model, fresh model, reload and rollback (16/16/51/16/16).
Inherited action/loot checks pass 188 assertions (90/70/28), including
12 action scenarios against the Mandinga control and finite loot reload.
One sequential 700-tic sprite/model pair per species records:

| Species | Queue presents/s, sprite / model | p95 ms, sprite / model | p99 ms, sprite / model |
| --- | ---: | ---: | ---: |
| Cachiru | 1846.15 / 1846.30 | 0.6958 / 0.6916 | 0.8340 / 0.7883 |
| Kakuy | 1801.35 / 1810.53 | 0.7426 / 0.7291 | 0.8994 / 0.8541 |
| Kelenken | 1771.56 / 1828.96 | 0.7625 / 0.6922 | 0.9271 / 0.8069 |

Environment: Windows 11, Ryzen 9 5950X, RTX 3070 Ti, GZDoom 4.14.2 Vulkan,
1280x720, background unpaused, audio 5%, uncapped presentation without vsync.
Queue intervals are not GPU/display timing; unequal footprints and one pair
do not establish repeatability or campaign/crowd performance. All
18,394 runtime entries match src. Only eight new avian resources,
MODELDEF and two release diagnostics differ from #709. Evidence:
assets/validation_v5_17_34/evidence/SUMMARY.json. CA711-AVIAN-01 is pending;
other characters, worn/first-person equipment and the broad campaign remain
unfinished.

## 5.17.33 - Native Litoral, Selva and Patagonia gallery (#709, parent #463)

Optional CA709G shows the current native Pombero in Litoral and Selva, with
Cuero, Nahuelito and Peuchen in Patagonia. Five displays use the existing three
regional ground materials. The original CA463G pilot and CA682G extended
galleries remain intact. No model or raster bytes change. GALLERY.json under
assets/source/art/regional_gallery_709 owns positions, views and exact export
bindings; PROVENANCE.json fingerprints reused sources. The fixture reuses the
existing map/event geometry and silent-observer pattern (CA-KP-236).

Run python assets/validation_v5_17_33/run_gallery.py --runtime
build/caelum_argenteum_dev.pk3 --output build/native-regions-author-01 --interactive.
F1 overview, F2 Litoral, F3 Selva, F4 Patagonia, F5 walk, F6 Cuero, F7 Nahuelito,
F8-F10 regional ground tiling and F11 Peuchen. Friendly/passive diagnostic
figures retain native idle animation. The observer movement-noise timer alone
is muted; native speed, collision and production perception remain unchanged.

Four fixture files repeat byte-for-byte. Static validation checks approved
allocations, exact native model/material hashes, bound actor classes, plot
containment and nonoverlapping collision bodies. Native fresh/reload phases
pass 25/54 assertions, including saved identities/positions, idle advancement,
walking, silent-step serial and the 420-tic crossing of both boundaries.
The first room passes the same functional checks but its overview shows
a gray void because the camera is outside the map. The overview was moved
inside and the Cuero/Nahuelito views brought closer; final fresh/reload checks pass
again. Earlier captures/layout and timing remain evidence. Overview, regional
closeups, tiled grounds, reload and final presentation were inspected. Existing model/combat checks remain applicable to identical bytes.

One 700-tic five-display overview records 1723.07 queue presents/s, p95 0.8020 ms, p99 0.9610 ms; mean simulation 28.5709 ms/tic.
Windows 11 Pro 26200, Ryzen 9 5950X, 32 GB, RTX 3070 Ti; GZDoom 4.14.2,
Vulkan 1280x720,
uncapped/vsync off, background unpaused and audio 5%. Small projected figures
and one queue sample establish no comparative cost, close-up budget,
repeatability, GPU/display or city/siege acceptance. All
18,386 runtime entries match src; only two release
diagnostics differ from #708. Evidence: assets/validation_v5_17_33/evidence/SUMMARY.json.
CA709-NATIVE-GALLERY-01 and prior art checks remain pending. This fixture is
not a campaign destination or completion of the broader character/equipment batch.

## 5.17.32 - Reference-led Peuchen combat model (#708, parent #461)

CA-FOLK-054 Peuchen/Piuchen now has a candidate native model on
CaelumBestiary054. The owned bestiary concept guides its four clawed legs,
long neck and tail, horned head, dark scales, pale ventral scutes and paired
batlike wings. Eight closed membrane panels have actual thickness. Native
coverage reaches eleven of the 56 new folklore combat classes; the original
catalogue's import/planning flags are historical, not the runtime coverage list.
Regional gallery placement remains a separate issue.

The source has 86 closed anatomical components, 105 hierarchy parts, 14,130
vertices and 26,064 triangles across six native surfaces. All 23 inherited
sprite/frame/action identities remain intact; quadruped poses use independent
art data. The earlier strict shared validator remains the default for previous
families; an explicit mapping-only option permits these new poses while still
checking the original identities. Mandinga statistics, actions, hostility,
loot, collision, Scale and saves are unchanged. Neutral visual Height follows
that existing profile. Wings do not authorize flight, metre-based size changes,
new population or campaign placement. Rulo, Mandinga and Zupay are untouched.

Source: assets/source/art/peuchen_708, including editable OBJ/MTL, anatomy,
animation and contact data. Two original bitmap materials were generated using
built-in image_gen: materials.png and the denser scales.png, with exact prompts
in MATERIALS_PROMPT.json and SCALES_PROMPT.json. The first atlas remains intact;
owned Nahuelito iris/dark images are reused byte-for-byte. Regenerate using
python assets/generators/generate_peuchen_model.py --output build/peuchen-model
--install. Ten final exports repeat. Adding hashes for unchanged indirect
backends and original eye sources changes only the manifest; all nine earlier
art/container files and the tested runtime remain identical.

Independent checks read the serialized anatomy, verify closed outward solids
and 85 attachment witnesses with two rays and quantization clearance, then
reject collapsed triangles in every native pose. True pole fans replace tiny
clipped ellipsoid pole loops locally; lower pupil tessellation avoids native
collapse. Two wing roots required actual geometric refitting. Contact-search
boundary candidates were rejected by the stricter final checks. These neutral
attachment checks do not prove all-pose surface clearance or audit older models.

The first engine preview passed 51 functional assertions but failed its
distinct-pose gate: idle endpoints, attacks and death progression repeated.
Explicit pose data, denser scales and per-camera empty references corrected the
next preview (51 assertions, 20 distinct captures). A later native review found
wing tips lifting lying art; folding the wings and rolling the body flat fixed
the candidate, followed by another 51-assertion preview. Front, side, rear,
head detail, representative actions, all death stages and folded rest were
inspected. Simplified horns/muzzle, ventral boundaries, membrane folds and rigid
articulation remain candidate art requiring author review.

The final package passes 115 continuity assertions (16/16/51/16/16) across old
sprites, old-save/model, fresh model, reload and rollback, plus 80 inherited
action/loot assertions (40/28/12). One qualified 700-tic sprite/model sample
records 1760.26/1725.56 queue presents/s, p95 0.7686/0.7804 ms and p99 0.9615/0.9241 ms on the recorded
Windows 11/Ryzen 9 5950X/RTX 3070 Ti Vulkan environment, 1280x720, background
unpaused and audio 5%. Different footprints and queue-only timing prevent
equal-pixel, GPU/display, repeatability or campaign/crowd conclusions. All
18,386 runtime entries match src; six new resources,
MODELDEF and two release diagnostics are the only changes from #706.
Evidence: assets/validation_v5_17_32/evidence/SUMMARY.json. CA708-PEUCHEN-01 is
pending. Fixed-creature parts do not complete interchangeable playable/worn
equipment, first-person models or the broader campaign batch.

## 5.17.31 - Linked-ring chainmail material world prop (#706, parent #647)

Material ID 17 gains a candidate native model through the exact
CaelumMaterialPickup M017/A binding. All three tiers retain their original
shared appearance, icon, Scale 0.25, collision, quantities, stacking, recipes,
mass, provenance and contamination. This is a static crafting-material panel;
worn armor, spiked chain and silver chain are separate work.

The panel has 55 closed torus links, 10,560 source vertices, 21,120 triangles
and three native surfaces. An alternating interlaced layout connects all links
through 90 linked pairs. The original owned icon supplies the silhouette
reference; the unchanged training-dummy iron supplies opaque surface pixels.
DESIGN/PROVENANCE/EXPORT and portable OBJ/MTL plus its texture live in
assets/source/art/inventory_models_647/chainmail. Regenerate using python
assets/generators/generate_inventory_chainmail_models.py --output
build/chainmail-model --install. All six export files repeat byte-for-byte.

Independent serialized-OBJ checks verify closed edges, opposite winding,
positive volume, genus-one topology, open centers, the full link graph and
nonintersecting wire capsules. The minimum checked capsule gap is
0.574569 native model units, above the
0.027065 quantization allowance. Native MD3 triangles
match the checked quantized OBJ triangle multiset exactly. Both sprite
envelopes and unchanged original texture bytes are checked separately.

The first width-fitted candidate exceeded the original height; height fitting
corrected it. The first native preview showed flat texture bands despite 82
passing inventory assertions. Reorienting the iron UVs around wire thickness
improved the roundness cues; the second preview also passes 82. Geometry is
unchanged by that UV correction. Final front, edge, rear-oblique, rear,
raised underside and floor views were reviewed. The regular rigid weave and
uniform reused iron remain simplified candidate art, not a cloth simulation.

The packaged native fixture passes 437 checks across [82, 91, 82, 91, 91]: original
sprites, old-save/model, fresh model, reload and reverse load, covering all
three tiers, split/merge, ownership, contamination lots, provenance, Box weight,
quest guard and unchanged sprite/icon/collision. It calls native APIs;
ordinary menus/crafting and author acceptance remain separate. One qualified
700-tic single-object sprite/model comparison records 1185.57/1175.95 queue presents/s,
p95 1.0131/1.0381 ms and p99 1.2718/1.2694 ms on the recorded Windows 11/Ryzen 9 5950X/RTX
3070 Ti Vulkan environment at 1280x720, background unpaused, audio 5%.
Different footprints and queue-only timing prevent equal-pixel, GPU/display,
campaign or crowd conclusions. All 18,380 package entries
match src; only two new resources, MODELDEF and two release diagnostics differ
from #704. Evidence: assets/validation_v5_17_31/evidence/SUMMARY.json.
CA706-CHAINMAIL-01 retains author art and ordinary-use acceptance.

## 5.17.30 - Six metal plate crafting world props (#704, parent #647)

Material IDs 11-16 gain candidate closed 3D world props: plate, round plate,
kite plate, tower plate, magic plate and large plate. Exact CaelumMaterialPickup
M011..M016 frame-A bindings retain the original shared appearance across all
three tiers. Six original owned icon PNGs, native Scale 0.25, collision, stacking,
mass, contamination, provenance and inventory behavior remain unchanged.
Chainmail and the remaining crafting components are separate work.

The models have 27 closed components, 9,292 source vertices, 18,512 triangles
and 12 native surfaces. Curved metal backs, original painted faces and narrow
edges reuse the #702 geometry backend without changing it. The large plate
has four overlapping closed bands; its rear planes are slightly staggered to
avoid coplanar overlap. Independent checks verify 21 positive-volume assembly
witnesses, closed winding, native quantized triangle area and original sprite
envelopes. Original fractional alpha exposes solid iron/bronze backing; no
bitmap was repainted. Source softness, painted gaps and simplified curvature
remain visible in closeups and require author art review.

DESIGN/PROVENANCE/EXPORT, OBJ/MTL and byte-identical portable texture references
live at assets/source/art/inventory_models_647/plates. Regenerate with python
assets/generators/generate_inventory_plate_models.py --output build/plate-models
--install. All 24 final export files repeat exactly. Staggering the large
plate's back planes changes only that MD3/OBJ plus manifest/container; the other
five designs remain identical. Sources and all earlier runtime art are intact.

The first preview passes 469 assertions. A later redundant fixture collision
check redeclared a local variable and failed compilation before any assertion;
removing that duplicate restored the existing checks while retaining the new
explicit class/frame/sprite assertion. Final native tests pass 2,597 checks:
[487, 541, 487, 541, 541] across original sprites, old-save/model, fresh model, reload and
reverse load. All 18 type/tier cases preserve split/merged quantities, typed
ownership, contamination lot boundaries, provenance, Box-weight exclusion,
temporary quest guards, native sprite/icon and collision. The fixture calls
native APIs; ordinary menus, crafting and author acceptance remain separate.

All six fronts and final rear-oblique views, selected edge/underside views,
the floor overview and both presentation cohorts were inspected. Five unchanged
front views reuse the byte-identical preview art. One qualified
700-tic six-object sprite/model sample records 1126.92/1057.17 queue presents/s,
p95 1.0888/1.1330 ms and p99 1.3519/1.3477 ms on the recorded Windows 11/Ryzen 9 5950X/RTX
3070 Ti Vulkan environment at 1280x720, background unpaused and audio 5%.
Different model/billboard footprints prevent equal-pixel cost claims; these
queue intervals do not establish GPU/display timing or campaign/siege rendering.
All 18,378 runtime entries match src, with thirteen new resources,
MODELDEF and two release diagnostics as the only differences from #702.
Evidence: assets/validation_v5_17_30/evidence/SUMMARY.json. CA704-PLATES-01 stays
pending. Worn armor, recipes and balance are unchanged.

## 5.17.29 - Four native shield world models (#702, parent #647)

The existing buckler, kite, tower and magic shield world drops now use candidate
closed 3D props at exact CaelumShieldPickup CBUC/CSHK/CSHT/CSHM frame-A bindings.
Original icons, three tiers, five sizes, Scale 0.25, collision, balance and
equipment identity remain unchanged. Every tier already shares its type's
world sprite; one model per type preserves that policy. First-person #106 art
and worn-body fitting are unchanged and remain distinct from world inspection.

Four original 128-pixel owned PNGs remain byte-identical. Raised boss/crest/gem
profiles, a curved painted front, closed backing, rim and rear leather band(s)
provide volume. Reused owned training-dummy wood/iron and #647 leather/bronze
materials cover rear surfaces and edges. The front artwork contains internal
alpha cutouts; they expose the solid backing instead of defining holes in the
mesh. Close views retain original softness, visible paint gaps and simplified
relief. Author art review remains pending.

DESIGN/PROVENANCE/EXPORT and portable OBJ/MTL sources live at
assets/source/art/inventory_models_647/shields. Regenerate with python
assets/generators/generate_inventory_shield_models.py --output
build/shield-models --install. All 18 export files repeat exactly.
The four models have 19 closed components, 6,332 source vertices, 12,604 triangles
and 15 native surfaces. Independent checks cover serialized closure,
winding, positive volumes, 22 actual assembly witnesses, seven empty grip
clearance points, native quantized triangle area and both original sprite
envelopes. No shared exporter or older native art changes.
Final LF normalization refreshes only provenance after a staged-byte check;
17 final art/portable files remain byte-identical. The failed check and the
source compatibility proof are retained in the evidence.

Two previews each pass 1,141 native assertions. Native visual inspection still
required replacing an alpha-derived notched contour, wide flat rim and polar
back UVs with smooth hulls, thinner edges and planar opaque backing. Final
front/rear/edge/underside/rear-oblique views, the floor overview and both
presentation cohorts were inspected. Geometry alone did not certify appearance.

The complete runtime passes 5,888 native assertions across original sprites,
old-save/model, fresh-model, model reload and reverse load: [1141, 1202, 1141, 1202, 1202].
All 60 type/tier/size cases retain identity, provenance, condition, water and
native sprites. Native selection/equip, incompatible-size refusal, temporary
drop guard and Box-weight exclusion pass. The fixture invokes native APIs;
ordinary menus, crafting and author acceptance remain separate. All
18,365 packaged entries match src. Only nine new shield resources,
MODELDEF and two release diagnostics differ from #700.

One qualified 700-tic four-shield Vulkan comparison, sprites/models, records
1164.76/1216.96 queue presents/s, p95 1.0510/1.0164 ms, p99 1.3199/1.2224 ms and
28.5721/28.5711 simulation ms/tic on the recorded Windows 11/Ryzen 9 5950X/RTX 3070 Ti
environment at 1280x720, background unpaused, audio 5%. Different model/billboard
footprints prevent equal-pixel cost claims. These are queue intervals, not GPU
or display timing, campaign/crowd performance or author acceptance. Evidence:
assets/validation_v5_17_29/evidence/SUMMARY.json. CA702-SHIELDS-01 remains pending.

## 5.17.28 - Cuyo material and guardian regional gallery (#700, parent #463)

The optional CA682G inspection room now contains ten displays of seven native
species across Pampa, NOA, Litoral, Selva and Cuyo. Yasí Yateré stands in Litoral;
Yastay is shown in both Cuyo and NOA according to the approved #453 allocation.
These two Yastay copies compare one unique identity in an isolated catalogue
room; no campaign duplication or population rule changes. Seven earlier figure
positions and all F1-F12 functions remain; the overview now frames five plots.
Number keys 1-4 select Yasí/Litoral, Yastay/Cuyo, Yastay/NOA and Cuyo ground.
F5 retains ordinary walking. The single gallery source remains
assets/source/art/regional_gallery_682/GALLERY.json; original CA463G is intact.

One new owned 1254-square image, whose original bytes and exact prompt are under
assets/source/art/regional_gallery_700, supplies CRCUYGR: pale dry mineral earth
and irregular foothill gravel. PROVENANCE records the built-in image_gen source
and hashes. Native Texture/Flat definitions repeat it over 128x128 map units,
matching the existing study scale. This is a candidate material study, not
fixed campaign geography or a mandatory habitat. The other regional materials,
all creature models and original paintings remain byte-identical.

Regenerate the material with python assets/generators/generate_cuyo_regional_materials.py
--output build/cuyo-materials --install; build the optional room with
python assets/validation_v5_17_19/build_gallery.py --output build/cuyo-gallery.
Four material-export files and four gallery files each repeat byte-for-byte.
The shared regional validator can read an explicit authoritative gallery path;
the older #463/#682 checks still pass. Key validation rejects duplicates and
unsupported keys. Region coverage, native class identity and nonoverlapping
display bodies are checked against existing catalogue and model data.

The six-sector room has 18 vertices and 23 linedefs. Native fresh/reload checks
pass 45/94 assertions (139 total), including idle-state advancement, saved
references, silent observer steps and unchanged positions after walking.
A 630-tic strafe crosses all four regional boundaries, finishing at
(1426.110,-256,0) inside Cuyo. The existing CA-KP-236 observer-noise suppression
is retained; no forced figure-reset loop or production perception change is
introduced. Native review covers the new closeups, ground repeat, overview and
reload. All 18,356 package entries match src; only the
new PNG/definition, TEXTURES include and two release diagnostics differ from
#698. Prior #682 export metadata is refreshed for the new material dependency;
its runtime outputs remain unchanged. Ammunition, documents, ingots, books and
locks refresh only their dependent DESIGN/EXPORT hashes after the TEXTURES
include. Non-hash design data matches the parent; regenerated native bytes and
portable hashes remain identical. TEXTURES is explicitly LF for stable checkout
hashes. Both validator failures and the complete dependency proof are retained.

One 700-tic peaceful presentation sample with ten distant figures records
1533.75 queue presents/s, p95/p99
0.8503/1.0722 ms and
28.571142 mean simulation ms/tic. Environment: Windows 11
Pro 26200, Ryzen 9 5950X, 32 GB, RTX 3070 Ti, GZDoom 4.14.2, Vulkan 1280x720,
uncapped/vsync off, background unpaused at 5% audio. Queue intervals do not
establish GPU/display timing, repeatability, comparative gains or campaign/siege
acceptance. Evidence: assets/validation_v5_17_28/evidence/SUMMARY.json.
CA700-CUYO-GALLERY-01 retains author review; other regions and character/item
models remain unfinished.

## 5.17.27 - Yasí Yateré and Yastay combat models (#698, parent #461)

Unique CaelumBestiary007 Yasí Yateré and CaelumBestiary011 Yastay now have native
3D candidates based on the supplied #453 concepts. Yasí retains a youthful face,
golden hair with small flowers, pointed ears, ivory embroidered tunic, short
trousers, sash, bare feet and a gold-wrapped wooden staff. Yastay retains the
camelid face, tawny hair/fur, ivory shoulder mantle and clasp, layered waist wrap,
cropped trousers, leather leg bindings and bare feet. These additions bring
candidate native coverage to ten of #455's 56 new classes; the other 46 and the
protected named profiles remain outside this patch. Both catalogue identities
remain unique and unplaced in the campaign.

Sources are assets/source/art/guardians_698: JSON anatomy and pose hierarchy,
portable OBJ/material groups, PROVENANCE/GENERATED_IMAGES records and exact
*-PROMPT.json inputs. Four selected built-in image_gen outputs provide separate
faces, a fabric/hair atlas and limb/adult-torso materials. The rejected first
Yastay face has a feline nose and remains preserved alongside its corrected
camelid replacement. All reference and generated pixels remain unchanged;
material sampling and projection happen in UV data. New sources contain 143
closed components, 32,353 source vertices, 56,860 triangles, 39 articulated
groups and eleven MD3 surfaces. Fixed reference clothing is editable but does
not establish interchangeable playable wardrobe modules under #458/#459.

The wrapper uses sealed pole caps and consistently transported tube frames.
This fixes small open pole loops and inconsistent curved-tube winding in these
new models, without altering earlier shared generators or outputs (CA-KP-239).
Each component passes closure/winding/positive-volume checks; 86 contact
witnesses lie inside both serialized neutral OBJ solids with independent ray
directions and quantization clearance. Native review also corrected floating
leg bindings, shoulder forms, muzzle projection, repeated tunic embroidery and
hair flower mounting. Eight leg bands now fit actual limb triangles; upper
bands follow the thighs. Neutral contact checks do not prove all-pose cloth
clearance. Close-up seams, enlarged weave, simple hands/feet and rigid costume
motion remain explicit author-review concerns.

Regenerate with python assets/generators/generate_guardian_models.py --output
build/guardian-models --install. Thirteen final exports repeat byte-for-byte.
Checks cover exact unique classes, all 23 inherited frame pairs, portable/source
hashes, MD3 surface indices/UVs and every quantized pose bound. Neutral standing
art fits the existing provisional Mandinga Height/Scale; catalogue meter ranges
remain unauthorized for runtime scaling. Moving/lying poses may exceed Radius.
No saved field, actor state, combat action, hostility, loot or spawn rule changes.

The complete package passes 230 continuity checks (115 per creature: baseline,
old-save/model, fresh model, reload and reverse-load). All 23 posed captures per
figure are checked against their native state and visibility. A wider lying
camera fixes the initial crop; supplementary previews pass another 51 checks
per figure on the identical runtime. Separate native
attacks/deaths/finite-loot tests pass 136 assertions. All 18,354
packaged entries match src: two models, four textures and one binding are new;
only MODELDEF and two release diagnostics differ among earlier entries. No
earlier model, gameplay or shared exporter bytes change.

One sequential 700-tic sprite/model pair per figure records:

| Creature | Queue presents/s | p95 ms | p99 ms | Mean simulation ms/tic |
| --- | --- | --- | --- | --- |
| Yasi | 1793.60/1738.20 | 0.7495/0.7657 | 0.9084/0.9122 | 28.5716/28.5716 |
| Yastay | 1842.14/1814.85 | 0.6801/0.6733 | 0.8481/0.7992 | 28.5713/28.5713 |

Environment: Windows 11 Pro 26200, Ryzen 9 5950X, 32 GB, RTX 3070 Ti, GZDoom
4.14.2, Vulkan 1280x720, uncapped/vsync off, background unpaused at 5% audio.
Queue intervals do not establish GPU/display timing, repeatability or campaign/
crowd acceptance. The original billboard and height-fitted model occupy
different screen areas, so this is not an equal-pixel-cost comparison.
Evidence: assets/validation_v5_17_27/evidence/SUMMARY.json. Author visual/play
acceptance stays under CA698-GUARDIANS-01; regional gallery additions are separate.

## 5.17.26 - Eleven clothing-ensemble world props (#696, parent #647)

The existing #387 body outfits gain candidate native 3D world props at exact
CaelumClothingPickup WC00..10/A bindings: F/FW formal, CS/CE/CW casual,
RS/RE/RW country and PS/PE/PW patched poor clothing. One item remains one
complete ensemble. F/FW/CW/PW retain folded trousers beside the coat, while the
other seven show full trousers as in their actual source paintings. Eleven
original owned PNGs, icons, all five sizes, identity, condition, wetness,
equipment eligibility, native Scale 0.25, collision and all balance stay intact.
Combined with #686/#688/#694, all 25 native clothing designs have candidate
world models. Worn-body and first-person modular fitting remain under #459;
other inventory classes and characters remain unfinished.

Sources live at assets/source/art/inventory_models_647/clothing with
DESIGN/PROVENANCE/EXPORT, portable OBJ/MTL and unchanged PNG aliases. Regenerate
using python assets/generators/generate_inventory_clothing_models.py --output
build/clothing-models --install. All 37 final export files repeat exactly.
The eleven ensembles contain 338 closed outward parts,
85,992 source vertices, 143,656 triangles
and 53 native surfaces. Shirt, collar, sleeves, cuffs,
trousers, coat, waistcoat, belt, patches and poncho components are independently
editable where present; these fixed world assemblies are not worn modules.

A dedicated thin-wall garment primitive supports hollow sleeves/collars and
open-front coats. Independent serialized checks verify 155 solid assembly
witnesses, 47 opening rays, every vertex of 143 fitted details and their
solid attachment. Surface fitting uses actual parent triangles; lapels and
waistcoat fronts explicitly allow free edges. All parts have closed topology,
consistent winding and positive volume; both original sprite envelopes fit.
The shared writer accepts the dedicated geometry backend. Regenerating seven
previous families proves 55 native and 41 editable files unchanged against
existing outputs/hashes; only their shared-generator metadata hash changes.

Three preview runs each pass 1,046 functional assertions. Visual inspection
still required corrections to shirt/button crops, shoulder rims, visible leg
length, the poncho/fringe profile and patch/cloth material selection. Original
pixels were not repainted. Enlarged crops retain visible seams, texture
stretching and simplified silhouettes; author art acceptance remains pending.
Source crop margins retain alpha >=250/255, not full opacity.

The complete package passes 5,398 native checks: 1,046 original-sprite,
1,102 old-save/model, 1,046 fresh-model, 1,102 model-reload and 1,102 reverse-load.
All 55 type/size cases retain IDs, provenance, wear, water and icons. Native
selection/equip, size refusal, Box-weight exclusion and temporary-drop guards
pass. The fixture calls native APIs; ordinary menus/crafting remain separate.
All 18,347 package entries match src. Only eleven MD3s,
eleven source-PNG aliases, their binding/include and two release diagnostics
differ from #694. Earlier candidates and evidence remain in
assets/validation_v5_17_26/evidence/SUMMARY.json.

One sequential eleven-ensemble, 700-tic sprite/model comparison records 1174.66/1109.72
queue presents/s, p95 1.0227/1.0859 ms, p99 1.2329/1.3152 ms and simulation means 28.5716/28.5719 ms/tic.
Environment: Windows 11 Pro 26200, Ryzen 9 5950X, 32 GB, RTX 3070 Ti,
GZDoom 4.14.2 Vulkan 1280x720, uncapped/vsync off, background unpaused at 5%
audio. This is isolated queue timing, not GPU/display timing, repeatability or
campaign/crowd performance acceptance. CA696-CLOTHING-01 remains pending.

The first project validation also detected stale document-export provenance
pins in the existing book and lock reuse manifests. Both source pins were
refreshed, and their two native bindings and reused variant records regenerate
identically. The initial failure and metadata-only correction are preserved.

## 5.17.25 - Five paired footwear world props (#694, parent #647)

The accepted #387 BF/BC/BR/BS/BP artwork now supplies candidate native 3D
pairs: formal dark leather shoes, brown ankle lace-up boots, tall country
boots, ivory cotton alpargatas and patched brown wool alpargatas. Exact
CaelumClothingPickup WC20..24/A bindings preserve the original icons, five
sizes, identity, condition, wetness, equipment eligibility and one-item/one-pair
quantity. Native Scale 0.25, collision, prices, weights and recipes are unchanged.
This implements the later all-dropped-inventory-3D request for these five items;
eleven body garments and actual worn/first-person fitting remain separate.

DESIGN/PROVENANCE/EXPORT and portable OBJ/MTL sources live under
assets/source/art/inventory_models_647/footwear. Five original owned PNGs remain
byte-identical. Regenerate using python
assets/generators/generate_inventory_footwear_models.py --output
build/footwear-models --install. All 19 final export files repeat exactly.
There are 74 closed outward groups,
44,804 source vertices, 54,064 triangles
and 22 native surfaces. Upper/lining/sole pairs, modest
heels, lace volumes, rope bands and patches are separate editable components.
These fixed world props are not interchangeable worn modules.

Independent serialized-geometry checks cover 64 attachment witnesses, ten
foot-opening rays, ten lining-visibility rays, all patch vertices and every lining vertex against the
faceted outer shell. Both original sprite envelopes are respected; BR uses
height normalization. The shared glove diagnostic now supports that axis;
shared exporters, previous meshes and original pixels remain unchanged.
Initial witnesses and opening probes failed; the first native candidate exposed
lining/UV problems. The lining now remains visible from the cavity and follows the outer profile; upper UVs run
circumferentially, formal leather/cotton crops avoid unsuitable source areas, and planar sole/heel
caps use box projection after underside review exposed radial fan distortion.
Close-up crop stretching, seams and simplified shapes still need author review.

The final full package passes 2,458 native checks: 476 original-sprite, 502
old-save/model, 476 fresh-model, 502 model-reload and 502 reverse-load checks.
All 25 type/size cases retain IDs, provenance, wear, water and icons; native
selection/equip, size refusal, Box-weight exclusion and temporary-drop guards
pass. The fixture calls native APIs; ordinary menus/crafting are not certified.
All 18,324 package entries match src; only five models,
five texture aliases, their binding/include and two release diagnostics differ
from #692. Earlier attempts and hashes are retained in
assets/validation_v5_17_25/evidence/SUMMARY.json.

One sequential five-pair, 700-tic sprite/model comparison records 1195.42/1142.40
queue presents/s, p95 1.0161/1.0697 ms, p99 1.2497/1.3196 ms and simulation means 28.5715/28.5722 ms/tic.
Environment: Windows 11 Pro 26200, Ryzen 9 5950X, 32 GB, RTX 3070 Ti,
GZDoom 4.14.2 Vulkan 1280x720, uncapped/vsync off, background unpaused at 5%
audio. This is isolated queue timing, not GPU/display timing, repeatability,
campaign/crowd performance or author acceptance. CA694-FOOTWEAR-01 is pending.

## 5.17.24 - NOA gallery with Mikilo and Coquena (#692, parent #463)

The optional CA682G regional inspection map now places one native Mikilo and
one native Coquena beside Ucumar on the existing NOA ground. Their approved
#453 allocations remain authoritative; the unique Coquena display is not a
second campaign individual. All five earlier displays and four regional plots
remain. GALLERY.json owns the two added positions, group camera, closeups and
model-export list. The shared builder verifies every referenced native resource
and reuses the existing map/event template; no duplicate engine logic or raster
asset was introduced. All model, texture, combat and campaign bytes remain
unchanged from #690. Only two packaged release diagnostics differ.

Run python assets/validation_v5_17_19/run_gallery.py --runtime
build/caelum_argenteum_dev.pk3 --output build/noa-gallery-author-01 --interactive.
F1 overview; F2 Pampa; F3 the three NOA figures; F4 Litoral; F5 walk; F6 Selva;
F7-F10 repeated regional ground materials; F11 Mikilo; F12 Coquena. The closeups
and wider NOA camera keep native scale. Friendly/passive fixture staging and a silent observer retain
idle motion without a position-reset loop. The fixture alone mutes the one player
movement-noise timer using its native interval; native speed and production
hearing remain unchanged. This optional developer fixture is
not a campaign destination, new encounter or adopted biome design.

Four generated gallery files repeat byte-for-byte. Static checks cover all
approved class/region associations, plot containment, nonoverlapping collision
bodies and control bindings. Native fresh/reload phases pass 33/70 checks:
seven saved identities/positions before and after walking, a stable observer
movement-noise serial, advancement within native idle sequences,
normal player movement and the 420-tic crossing of all three plot boundaries.
The overview, regional views, duende closeups, tiling and reload were inspected.
Initial checks ran only before walking; its final capture exposed movement. A
stronger old-save diagnostic records 54 PASS/14 FAIL for changed positions and
non-idle states. Silencing observer steps fixes anonymous noise investigation
without changing production hearing or forcibly resetting bodies (CA-KP-236).
Existing #680/#690 model and combat evidence applies to identical runtime bytes;
the save test here covers this new isolated gallery, not older fixture saves.

One 700-tic seven-display run records 1590.01 queue presents/s, p95 0.8581 ms, p99 1.0526 ms; mean simulation 28.5720 ms/tic.
Environment: Windows 11 Pro 26200, Ryzen 9 5950X, 32 GB, RTX 3070 Ti, GZDoom
4.14.2, Vulkan 1280x720, uncapped/vsync off, background unpaused at 5% audio.
The distant overview renders small projected figures.
This single queue measurement establishes no comparative cost, close-up budget, repeatability,
GPU/display timing or city/siege acceptance. All 18,313
packaged entries match src. Evidence: assets/validation_v5_17_24/evidence/SUMMARY.json.
CA692-NOA-GALLERY-01 and prior art/play checks remain pending. Other creatures,
regions, worn modules and the campaign batch remain unfinished.

## 5.17.23 - Mikilo and Coquena combat models (#690, parent #461)

CaelumBestiary009 Mikilo and CaelumBestiary010 Coquena now have candidate native
models based on the verified #453 concepts. Distinct mature faces, pointed ears
and fixed costumes retain Mikilo's worn felt hat, gray hair, short shoulder
cloth, patched trousers and bare feet; Coquena's patterned chullo, ochre/red
poncho, sash, shoulder bag and wrapped sandals. Their repeatable/unique catalogue
identities and lack of campaign spawning remain intact. Eight of #455's 56 new
classes now have candidate native models; the other 48 and the protected named
profiles remain outside this delivery.

Editable sources are under assets/source/art/duendes_690. Two square face plates
and one material atlas were generated with built-in image_gen from the owned
references. Exact prompts are the three *-PROMPT.json files; PROVENANCE.json
records original output paths, dimensions and hashes. Original concept/output
pixels remain unchanged, without raster postprocessing. Each face is projected
onto a sculpted volumetric head. Source JSON retains articulated body, head,
limb, clothing and accessory groups: 20 for Mikilo and 22 for Coquena, totaling
38,428 source vertices, 62,160 triangles and twelve MD3 surfaces. These fixed
outfits do not complete runtime interchangeable inventory modules or playable
goblin customization under #458/#459.

The shared beast-men exporter now accepts explicit source/binding/texture inputs
and a mesh builder; all eight prior native beast-men resources and their editable
exports remain byte-identical. Only their generator-hash metadata changes.
The first project validation exposed a stale transitive regional-gallery pin;
its inventory/export metadata was refreshed, with all three runtime regional
resources byte-identical.
New closed garment profiles preserve open hems and necks. Initial native review
exposed high cameras, hidden bags and stretched radial cloth UVs; final camera,
garment, strap, collar and material mapping corrections are retained with earlier
iterations. Candidate material seams, coarse weave, simplified hands/feet and
costume articulation still need author review.

Regenerate with python assets/generators/generate_duende_models.py --output
build/duende-models --install. Twelve final export files repeat byte-for-byte.
Static checks cover exact actor/frame bindings, source/portable texture hashes,
closed garment winding, occupied acyclic groups and every quantized MD3 pose.
All 23 inherited frame pairs preserve native state functions, timing and rules.
Neutral art height fits the existing Mandinga Height/Scale; reference meter
ranges remain unapproved and moving/lying art can exceed collision Radius.
No saved field, actor state, combat, loot or population rule changes.

The complete package passes 230 continuity assertions: 115 per creature across
original, old-save/model, fresh model, reload and reverse-load phases. The
observer verifies every inherited frame and capture; manual art review covers
front/side/rear, facial detail and representative action poses. A separate
Mandinga/two-creature action/death/finite-loot test passes 136 checks. All
18,313 packaged entries match src; only two models,
three textures, their binding/include and two release diagnostics differ from
#688. Ordinary play and CA690-DUENDES-01 remain pending author acceptance.

One sequential 700-tic sprite/model pair per visible creature records:

| Creature | Queue presents/s | p95 ms | p99 ms | Mean simulation ms/tic |
| --- | --- | --- | --- | --- |
| Mikilo | 1819.31/1835.24 | 0.6862/0.6755 | 0.8502/0.7943 | 28.5716/28.5716 |
| Coquena | 1866.76/1852.77 | 0.7009/0.6950 | 0.8352/0.7986 | 28.5706/28.5715 |

Environment: Windows 11 Pro 26200, Ryzen 9 5950X, 32 GB, RTX 3070 Ti, GZDoom
4.14.2, Vulkan 1280x720, uncapped/vsync off, background unpaused at 5% audio.
Queue intervals do not establish GPU/display timing, repeatability or campaign/
crowd acceptance. Original billboard and fitted model have different projected
footprints, so this is not an equal-pixel benchmark. Evidence, hashes and limits:
assets/validation_v5_17_23/evidence/SUMMARY.json. Historical CATALOGUE/AUTHORING
art flags remain snapshots; these exact bindings document current coverage.

## 5.17.22 - Four native glove-pair props (#688, parent #647)

The accepted #387 formal cotton/silk-trim GF, thin work cotton GC, winter wool
GW and patched wool GP designs now have candidate world-drop models. Exact
CaelumClothingPickup WC16..WC19/A bindings preserve the original icons and
native sizes, IDs, weight, wetness, durability and equipment rules. One native
item remains one pair. The author's later all-dropped-inventory-3D instruction
supersedes #459's original billboard drop scope for these four props. Eleven
body garments, five footwear designs and actual worn/first-person fitting
remain separate; no body, species, wardrobe or balance decision is introduced.

Four original owned high-resolution PNGs remain byte-identical in short native
aliases and portable editable sources. Separate left/right palms and hollow
cuffs, four fingers and a thumb per hand retain the silk trim/buttons, folded
wool cuffs and sewn patches of their references. There are
58 closed outward OBJ groups,
78,028 source vertices, 26,912 triangles
and 27 MD3 surfaces. Source DESIGN/PROVENANCE/EXPORT files
are under assets/source/art/inventory_models_647/gloves. Regenerate with python
assets/generators/generate_inventory_gloves_models.py --output
build/glove-models --install. Sixteen final export files repeat byte-for-byte.
The shared geometry/export backend and all earlier runtime art remain unchanged.

The pair fits the original icon width and remains within its height envelope;
native Scale 0.25 and collision remain unchanged. Eight wrist rays reach inner
roofs rather than closing disks. Fifty attachment witnesses lie strictly inside
both adjoining components, checked against the serialized triangles. Every
patch/button vertex is also compared with the actual palm surface, extending
CA-KP-238. Proper rotations preserve winding; left/right finger ordering is
authored separately. No bitmap editing, image generation or external mesh is
involved. Fixed source crops and box-projected UVs retain visible close-up seams
and varying knit scale. Sampling margins retain source alpha >=250/255.

Final complete-package native continuity passes 1,968 checks: 381 each for
original sprites and fresh models, then 402 each for old-save/model loading,
model reload and reverse loading. Twenty type/size combinations retain IDs,
provenance, original icons/states, wet/dry weight, wear and water. Native
selection/equip accepts compatible sizes and refuses incompatible ones; direct
Box-weight and temporary quest-drop guards pass. The fixture invokes native
APIs. Ordinary menus, crafting and author art acceptance remain pending.
All five native sizes share each design's world prop; these are not worn modules.

One sequential four-visible-pair, 700-tic sprite/model comparison records
1222.62/1198.22 queue presents/s, p95 0.9638/0.9980 ms and p99 1.1720/1.2321 ms.
Simulation means are 28.5719/28.5716 ms/tic. Environment: Windows 11 Pro 26200,
Ryzen 9 5950X, 32 GB, RTX 3070 Ti, GZDoom 4.14.2, Vulkan 1280x720, uncapped,
vsync off, background unpaused at 5% audio. This is isolated queue timing, not
GPU/display timing, repeatability or campaign/crowd acceptance. All
18,307 package entries match src. Only four models,
four aliases, their binding/include and two release diagnostics differ from
#686. Evidence, earlier attempts and limits are in
assets/validation_v5_17_22/evidence/SUMMARY.json. CA688-GLOVES-01 remains pending.

## 5.17.21 - Five native headwear props (#686, parent #647)

The five accepted #387 headwear designs now have candidate world-drop models:
formal felt hat HF, urban cotton cap HC, country felt hat HR, winter wool cap HW
and patched cloth cap HP. Exact CaelumClothingPickup WC11..WC15/A bindings retain
the original inventory/crafting icons, all five existing sizes, identity,
physical properties, weight, equipment rules, wetness and durability. The later
all-dropped-inventory-3D instruction supersedes #459's original billboard-only
drop scope for these five props. Other twenty garments and actual worn fitting
remain separate; no body, species, wardrobe or balance decision is introduced.

Five original owned high-resolution PNGs remain byte-identical in short native
aliases and portable editable sources. Twenty-six closed outward OBJ groups
form hollow crowns, brims, bands, a bow, visors, seams, buttons and cloth patches
where appropriate. There are 33,934 source vertices, 12,936 triangles and 17 MD3
surfaces. Source DESIGN/PROVENANCE/EXPORT files are under
assets/source/art/inventory_models_647/headwear. Regenerate with python
assets/generators/generate_inventory_headwear_models.py --output
build/headwear-models --install. Final exports repeat 19 files byte-for-byte.

Both original sprite dimensions bound the artwork; native Scale 0.25 and
collision stay intact. Opening rays reach inner roofs rather than bottom disks.
The first underside review exposed raised cloth patches despite closed meshes;
the corrected patches follow the actual elliptical crown and their vertices
are checked against its triangles (CA-KP-238). The optional four-column prism
profile preserves all eight older families and 54 native outputs exactly;
their current generator hashes alone are refreshed. Two dependent book/key
binding manifests also refresh source hashes with identical native output.
Fixed source crops and
box-projected UVs can still show close-up material seams. Source sampling
margins retain alpha >=250/255, preserving fractional source alpha. No raster
editing, image generation or external mesh is involved.

Final native continuity passes 2,458 checks: 476 original-sprite and 476 fresh
model assertions, then 502 each for old-save/model, model reload and reverse
load. Twenty-five type/size cases retain individual IDs, provenance, original
icons/states, wet/dry weight, wear and water; native selection accepts compatible
sizes and refuses incompatible sizes. Direct Box-weight and temporary quest-drop
guards pass. The fixture calls native APIs; ordinary menus, crafting and author
art acceptance remain pending. Geometry is shared across sizes; wearable body
fitting is not implemented by these props.

One final sequential five-visible-object, 700-tic sprite/model pair records
1199.43/1192.72 queue presents/s, p95 1.0005/1.0258 ms and p99 1.2821/1.2845 ms.
Simulation means are 28.5723/28.5726 ms/tic. Windows 11 Pro 26200, Ryzen 9 5950X,
32 GB, RTX 3070 Ti, GZDoom 4.14.2, Vulkan 1280x720, uncapped/vsync off,
background unpaused at 5% audio. This is isolated queue timing, not GPU/display
timing, repeatability or campaign/crowd acceptance. All 18,298 package entries
match src; only five models, five aliases, their binding/include and two release
diagnostics differ from #684. Evidence and earlier candidates:
assets/validation_v5_17_21/evidence/SUMMARY.json. CA686-HEADWEAR-01 remains pending.

## 5.17.20 - Coal and raw-metal material drops (#684, parent #647)

Six candidate closed rock clusters replace only M061..M066/A world presentation
on CaelumMaterialPickup: coal, raw copper, tin, iron, silver and gold. Canonical single-tier stacks reuse each type's original icon, identity, native Scale 0.25,
Radius/Height, weight and rules. Coal red details remain painted, non-emissive
artwork and do not add heat or a fuel rule. Existing inventory icons are intact.

The six unchanged owned 128px PNGs are projected over separate closed faceted
pieces. Each protruding rock has an inset opaque undercoat sampled from the same
image; a recessed core joins the pieces and uses the largest opaque rectangular
source crop. No PNG pixel is edited. All 42 rock/core intersections have a
positive-area cross-section witness; all 90 parts are closed and outward. DESIGN.json retains art
coordinates, depth profiles and source hashes; each rock/undercoat has an editable
OBJ group. Portable MTL/PNG sources accompany the short native shader aliases.
No image generation, raster editing or external mesh is used in this slice.
These are prop components, not runtime interchangeable wearable equipment.

The shared gem exporter and validator now accept a separate family while their
default native gem output stays byte-identical (29 resources). New geometry uses
the existing closed-part builder and MD3 writer. Rebuild with python
assets/generators/generate_inventory_ores_models.py --output build/ore-models
--install. Source/provenance/export records are in
assets/source/art/inventory_models_647/ores. Final complete-package compatibility passes 875 native checks: 175 each for
original sprites, old-save/model load, fresh models, reload and reverse load
without models. Eighteen normalization probes and six canonical stacks retain
identity, native physical properties, floor contact, 2+3 split quantities,
merged 5-unit stacks, provenance and contamination-lot boundaries; direct
Box-weight and quest-drop guards remain intact. All 18,287 package entries
match src exactly. Only six models, six original-pixel aliases, their MODELDEF
binding and two release diagnostics differ from #682.

One sequential six-object 700-tic sprite/model pair records 916.75/902.12
queue presentations/s, p95 1.2602/1.2812 ms and p99 1.5619/1.5864 ms.
Simulation means are 28.5718/28.5726 ms per tic. Windows 11 Pro 26200, Ryzen 9
5950X, 32 GB, RTX 3070 Ti, GZDoom 4.14.2, Vulkan 1280x720, uncapped/vsync off,
background unpaused, 5% audio. Both cohorts visibly contain all six types.
This is isolated queue timing, not GPU/display timing, repeatability or a
campaign/crowd budget. Evidence: assets/validation_v5_17_20/evidence/SUMMARY.json.
Runtime SHA-256: 73f84eafbaf8c67d49948a1a9871ddb03df15a75f59b59e997846e658cbafdeb.
Static closed-volume/binding checks pass. Six models
contain 4,680 source vertices and 6,000 triangles on twelve native surfaces.
Two final exports reproduce 22 files. Front/oblique/rear review covers all six
materials; source resolution and UV seams remain art-review limitations.

An inherited gem fixture initially assumed distinct tiers and failed: these six
raw materials belong to no tiered family and normalize requested tiers to one.
The corrected fixture probes all eighteen requested type/tier combinations and
tests six canonical stacks. No production tier rule was changed (CA-KP-237).
The first geometry candidate also had disconnected fragments; preserved later
iterations refine a recessed connected core without covering the original faces.

Use python assets/validation_v5_17_20/run_ore_drops.py --runtime
build/caelum_argenteum_dev.pk3 --output build/ore-author-01 --interactive.
F1/F2/F3 overview/front/side; F5 player view, F8 rear; F9 selects the next type
and F10 rotates its close-up. CA684-ORES-01 retains author review of silhouette,
material projection, depth, floor contact and ordinary pickup/drop behavior.
Other inventory, character/modular equipment and campaign work remain open.

## 5.17.19 - Pampa/NOA materials and regional beast-men gallery (#682)

The author's small-map request now has a second isolated inspection fixture,
CA682G, with Pampa, Northwest Argentina, Litoral and Selva plots. Five native
bodies follow every approved allocation of the three #680 species: Lobizon
in Pampa/Litoral, Uturunco in Litoral/Selva and Ucumar in Northwest Argentina.
Their existing models, body profiles, saved identity and production AI remain
unchanged. Fixture-only Friendly staging, the diagnostic simplification flag
and protected observer keep this inspection separate from encounters. Named Rulo and the original CA463G with
its preserved Pombero/Cuero/Nahuelito pilots remain unchanged.

Two new owned 1254-square opaque PNG studies depict Pampean grassland soil and
northwestern wooded-foothill soil. Built-in image_gen outputs, exact prompts,
hashes and provenance are retained in assets/source/art/regional_gallery_682.
Runtime copies preserve every original byte; no raster postprocessing was used.
Both use an editable 128-MU native tile. These are ground-material studies,
not approval of campaign biomes or mandatory creature habitats. Existing
CRLITGR/CRSELVG materials are reused with their original tiling and source bytes.
New names CRPAMGR/CRNOAGR do not replace any existing map material.

The shared regional exporter/validator now accepts a separate source/namespace
while retaining old defaults. Original regional, ammunition, ingot, document,
book and lock outputs remain byte-identical (28 resources checked against the
parent commit). The new TEXTURES include requires refreshing ammunition/ingot
hashes and their transitive document/book/lock metadata in dependency order. All #680 models and production behavior remain
unchanged. Rebuild materials with python
assets/generators/generate_beast_regional_materials.py --output build/beast-regions
--install. The final two material exports reproduce five files; separate gallery
exports reproduce four. Source associations, opaque pixels, hashes, plot
containment and contiguous walking boundaries are checked statically.

assets/validation_v5_17_19/build_gallery.py reuses the original rectangular-map
builder and gallery event template. GALLERY.json owns four plots, one walkway,
five sectors, fifteen vertices and nineteen linedefs. The map is generated as
an optional development fixture; it adds no campaign destination or encounters.
The final native run passes 52 exact checks (24 fresh, 28 reload): all five
initialized native identities and positions persist; both animation snapshots
belong to the original idle states and advance over 11 tics. Native input walks
through all three regional boundaries and stays on the floor. Original native01
fails one saved-position check: the diagnostic flag does not disable perception.
Fixture-only Friendly staging fixes the inspection; no position-reset loop or
production AI edit hides movement (CA-KP-236). The failed evidence is preserved.
All four plots, repeated Pampa/NOA materials and creature views were inspected.

One sequential 700-tic material comparison keeps five native models and geometry
constant: existing/regional queue presents/s 1199.77/1211.24, p95 1.1432/1.1416 ms,
p99 1.5602/1.5217 ms. Simulation means are 28.5707/28.5707 ms per tic. Windows 11
Pro 26200, Ryzen 9 5950X, 32 GB, RTX 3070 Ti, GZDoom 4.14.2, Vulkan 1280x720,
uncapped/vsync off, background unpaused, 5% audio. These queue intervals are not
GPU/display timing, repeatability or city/siege acceptance. Evidence and exact
package/source proof are in assets/validation_v5_17_19/evidence/SUMMARY.json.

Use python assets/validation_v5_17_19/run_gallery.py --runtime
build/caelum_argenteum_dev.pk3 --output build/beast-regions-author-01 --interactive
for inspection. F1 overview, F2 Pampa, F3 NOA, F4 Litoral, F5 player control,
F6 Selva, F7-F10 repeated ground materials. CA682-REGIONS-01 remains pending
for author art/scale/walkthrough acceptance. Other regional materials, the full
bestiary, modular equipment and city/sewer/siege finish remain separate work.

## 5.17.18 - Lobizon, Uturunco and Ucumar combat art (#680, parent #461)

Three specific repeatable actors, CaelumBestiary003/004/005, receive distinct
articulated 3D models derived from the author's recovered reference images.
Lobizon retains gray wolf anatomy and torn rural trousers; Uturunco retains
jaguar markings, pale underside, tail and russet wraps; Ucumar retains brown
bear anatomy and a hide loincloth. Named Rulo and the existing Mandinga/Zupay
profiles remain unchanged. These creatures are still unplaced in the campaign.

Editable shape controls, hierarchy, fixed clothing and all 23 inherited frame
bindings live in assets/source/art/beast_men_680. OBJ groups distinguish body
parts and material regions, including cloth/wraps, with portable MTL/textures.
There are 15 articulated parts per wolf/bear and 16 for the jaguar including its
tail. These fixed reference outfits do not implement the separate player/NPC
interchangeable equipment catalogue. Existing modular-character requirements
remain owned by #458/#459; this patch does not complete those requirements.

Rebuild with python assets/generators/generate_beast_men_models.py --output
build/beast-men --install; --check verifies installed deterministic outputs.
The shared Pombero shape/pose and Nahuelito MD3 helpers remain unchanged.
Neutral art height fits the existing provisional Mandinga Height, dividing
out Actor.Scale. Posed bounds are reported; moving limbs and lying corpses may
extend beyond Radius. Collision, scale, state timing, native actions, finite
loot and save schema are unchanged. Catalogue metric sizes remain unapproved.

Original concepts are retained byte-for-byte and supply eye/pupil samples.
New companion diffuse atlases were made with built-in image_gen: materials-v1.png
and the finer final materials-v2.png, both 1448x1086 RGB, with exact prompts in
ATLAS-PROMPT.txt and ATLAS-V2-PROMPT.txt and hashes in PROVENANCE/ANIMATION.
No Python raster editing was used. Both generated originals remain preserved.
Early candidates exposed floating brows, rounded muzzles, disconnected shoulder
volumes and overly coarse fur. Later meshes replace them with sloped skulls,
inset eye sockets, tapered snouts, curved limb surfaces and coat regions on the
continuous torso. This is a simplified candidate interpretation, not an exact
sculpt of the reference or author art acceptance. Close-up anatomy, seams,
clothing fit and animated articulation still require CA680-BEAST-MEN-01 review.

The final models contain 30,620 native vertices, 55,482 triangles and twelve
MD3 surfaces; 704,260 quantized coordinate/bounds checks pass. Six descending
garment lofts had inward faces; the local adapter normalizes their row order.
All twelve closed body/skull/garment lofts now have positive signed volume
(CA-KP-235). The final jaguar tail follows a smooth version of its existing
curve with a tapered tip. Two final exports reproduce all sixteen files.

Five-phase native continuity passes 115 checks per species (345 total): baseline,
old-save/model, fresh model, reload and rollback. It covers solid-body/wall
collision, free movement, frame advancement, body/state identity and finite
inventory ownership. Final action/loot tests pass 190 checks, including twelve
actual melee/projectile/breath actions across Mandinga and all three species,
finite death drops, duplicate-death guards and loot reload. Exact keyframe
inspection covers all 23 frame pairs with ordinary ambient and separate studio
views. Body, face, side/rear and representative movement/attack/death views were
inspected; candidate art acceptance remains pending.

Only Uturunco's MD3 changed after the first complete-package suite. Binary
comparison proves all Lobizon/Ucumar and gameplay bytes identical. Their native
continuity/presentation evidence is reused; the final package reruns Uturunco's
five phases, all-species action/loot and its presentation pair. The final PK3
matches 18,271 src files exactly, adding eight art resources and one MODELDEF
include; two diagnostic strings carry the version, with all other bytes intact.

Three separate 700-tic sprite/model pairs use one visible species each and an
offscreen Mandinga control:

| Species | Sprite/model queue presents/s | Sprite/model p95 ms | Sprite/model p99 ms |
| --- | --- | --- | --- |
| Lobizon | 1373.62/1292.34 | 0.9496/0.9709 | 1.1453/1.1521 |
| Uturunco | 1318.83/1298.66 | 0.9900/0.9789 | 1.1687/1.1342 |
| Ucumar | 1344.64/1327.95 | 0.9620/0.9444 | 1.1426/1.1144 |

Environment: Windows 11 Pro 26200, Ryzen 9 5950X, 32 GB, RTX 3070 Ti, GZDoom
4.14.2, Vulkan 1280x720, uncapped/vsync off, unpaused background, 5% audio.
These are queue-present intervals, not GPU/display timing. Screen footprints
differ: the new models fit native standing Height while the inherited sprite
art is taller. This is not an equal-pixel-cost comparison. One pair per species
does not establish repeatability or campaign/crowd performance; siege rendering
remains unresolved. See assets/validation_v5_17_18/evidence/SUMMARY.json.
The older #453/#455 CATALOGUE/AUTHORING combat-art fields remain their original
snapshot; the explicit native MODELDEF and this delivery record current coverage.
The full #461 roster, named-character conversion and regional encounter maps
remain unfinished; this focused patch adds only these three species.

## 5.17.17 - Pendant, gem and opal-component drops (#678, parent #647)

Fourteen CaelumMaterialPickup states M045..M058/A now have distinct closed
models: four pendants, four gem components, an opal brooch and five raw gems.
Original individual 128-pixel PNGs, material IDs, three qualities, quantity,
recipes, mass, collision, Actor.Scale .25, icons and save rules remain intact.
Fourteen byte-identical texture aliases have short MD3-compatible paths;
the original icons are not replaced. Gem components and raw gems retain
their separate source images even where their silhouettes resemble each other.

The editable models contain 18,338 vertices, 28,260 triangles and 369 closed
outward components. Separate settings, stones, chain links, scrolls, crystal
facets and a connected rock matrix provide depth. Geometry fits uniformly
inside each original opaque width/height. Owned #647 metal tiles furnish
jewelry backs; original stone pixels also cover crystal/matrix backs.
No new bitmap, raster edit, third-party mesh or image generator is involved.
These are world props, not fitted character wearables.

Sources/provenance and portable OBJ/MTL/textures live in
assets/source/art/inventory_models_647/gems. Rebuild with python
assets/generators/generate_inventory_gems_models.py --output build/gem-models
--install. The existing #674 closed-component builder and MD3 exporter are
reused without modification. Two exports reproduce 46 files byte-for-byte.
The validator checks each closed component, winding, depth, source hashes,
native bindings and original sprite envelope. Source fractional alpha is
preserved: interior undercoat samples have alpha >=250/255 across a 3x3
neighborhood, not an invented claim that these PNGs are fully opaque.

Initial visual fixtures each passed 1,093 assertions over 42 material/quality
combinations. Visual review required textured crystal/rock reverses, thinner
brooch scrolls, a connected matrix base and explicit leaf-support stems; the first variants remain evidence.
Final complete-package native checks pass 5,843 assertions in five phases:
baseline 1,093, old-save load 1,219, fresh candidate 1,093, reload 1,219 and
reverse-load 1,219. The 42 material/quality cases preserve split 2+3 quantities,
merged 5-unit stacks, original IDs/icons, mass, floor contact, native physical
properties, provenance and contamination, with direct Box-weight/quest guards.
The final visual fixture also passes 1,093 checks; brooch ornaments now have
five closed support stems. All 18,263 package entries match src exactly;
only fourteen models, fourteen byte-identical texture aliases, their binding
include and the two release diagnostics differ from #676.

One isolated fourteen-object, 700-tic sprite/model pair on Windows 11 Pro
26200, Ryzen 9 5950X, 32 GB RAM, RTX 3070 Ti and GZDoom 4.14.2 Vulkan at
1280x720, uncapped/vsync off, background unpaused and 5% audio measured
965.08/942.89 queue presentations/s; p95 1.2898/1.3394 ms,
p99 1.5574/1.5846 ms. Both cohorts visibly contain all fourteen types.
This is neither GPU/display timing nor campaign/crowd/repeatability acceptance.
Source/export hashes, prior visual iterations, native logs, captures and traces:
assets/validation_v5_17_17/evidence/SUMMARY.json. Runtime SHA-256:
bfc644b9b05ae9887fb4d3761928d9800cf7b2351cfaf1ed3c9e032fb35787c7.
The original 128-pixel detail limits extreme close-ups; author appearance and
normal-menu acceptance remain CA678-GEMS-01. Other #647 categories remain open.

## 5.17.16 - Support-book and component model reuse (#676, parent #647)

Three explicit CBOO/A bindings reuse the unchanged #656 book.md3 for
CaelumWeaponPickup, CA_LimboMagicImplement and CaelumMaterialPickup. Current
support-book type 23 and book-base material 38 resolve the same original
ca_book.png blue/gold sun-covered art; all three qualities keep that shared
world representation. Ordinary/legacy weapon identity and material stack
identity remain distinct. No support ability, recipe, icon, mass, collision,
actor scale, ownership, saved field or first-person presentation changes.
Rejected #479 implement models remain inactive; old offensive IDs 18/19 retain
their current Scepter/Orb meaning. Invalid old trial equipment is not restored.

The reused model has 14,096 vertices, 5,120 triangles and 28 closed editable
components. Original parametric controls remain in the documents/DESIGN.json
under assets/source/art/inventory_models_647; the original document generator
recreates editable/book.obj and documents.mtl in its selected output directory.
Those generated OBJ/MTL files are not claimed as tracked original sources.
New reuse hashes/provenance live in assets/source/art/inventory_models_647/books.
Rebuild its binding with python assets/generators/generate_inventory_book_bindings.py
--output build/book-bindings --install. No mesh or bitmap is duplicated or edited.

The corrected isolated visual fixture passes 160 checks across three qualities
of each of the three classes. Native weapon pickup automatically equips a
compatible book; the first fixture bypassed unequip before direct CreateTossable
and incorrectly expected an unequipped world flag (142 passes, six failures).
The corrected fixture asserts automatic equip, invokes native unequip, then
tests drop; production behavior is unchanged. Final complete-package native
checks pass 713 assertions: 160/131/160/131/131 across baseline, previous-save/
new-binding, fresh/new-binding, reload and rollback. Native equip/unequip,
weapon identity/durability, material split/merge, provenance, contamination,
quest/Box guards and original physical properties remain intact. Three exports
repeat exactly; all 18,234 package entries match src. Only the new binding file,
root MODELDEF include and two release diagnostics differ from #674. Every
original mesh, PNG and gameplay byte is retained; project/focused validation pass.

One isolated 700-tic nine-book pair records 1172.29/1124.36 queue presents/s for
sprites/models, p95 1.0380/1.0902 ms and p99 1.2525/1.3244 ms. Both cohorts and final
front/side/oblique/rear/overview views were inspected. Environment: Windows 11
Pro 26200, Ryzen 9 5950X, 32 GB, RTX 3070 Ti, GZDoom 4.14.2, Vulkan 1280x720,
uncapped, vsync off, background unpaused, 5% audio. Queue intervals do not
establish GPU/display timing, repeatability or campaign/crowd acceptance.
Evidence: assets/validation_v5_17_16/evidence/SUMMARY.json. Author appearance and
ordinary-menu review remain pending as CA676-BOOKS-01. No new casting/crafting
acceptance is claimed; their production rules remain unchanged.

## 5.17.15 - Volumetric amulet and seal drops (#674, parent #647)

Four amulets and five elemental seals now have nine native MD3 models and
fourteen explicit class/sprite/A bindings, including all five CA_LimboMagicSeal
states. Existing world art uses the same tier-one image across the three
qualities; this patch preserves that behavior and all 27 original tier icons.
The isolated fixture covers 27 ordinary type/quality combinations plus the 15
legacy seal combinations. Channeling marks, worn character fitting and combat
effects are separate and unchanged.

Closed editable parts reproduce the painted pendants: backs, reliefs, raised
gem/emblem crowns, suspension rings and individual alternating chain links.
There are 145 closed components and 26,912 triangles across the nine models.
Each amulet has 5,244 triangles; Fire/Water/Earth/Air have 1,272 each and
Quintessence 848. Original 128-pixel jewelry PNGs project over the raised front
surfaces. The unchanged owned #647 bronze/silver/gold atlas supplies backs and
links. Separate opaque gem/emblem undercoats sample their own source images,
preventing semitransparent highlights from exposing a contrasting metal center.
The initial constant-color sides and incomplete facet mapping were rejected
during native review; original PNG bytes remain unchanged throughout.

Authoring controls, provenance, editable OBJ groups/materials and export hashes:
assets/source/art/inventory_models_647/jewelry/. Rebuild with
python assets/generators/generate_inventory_jewelry_models.py --output
build/jewelry-export --install. The validator independently checks component
closure/winding, real depth, all fourteen bindings, native surfaces/UVs/hashes,
portable materials and opaque metal tiles. Uniform fitting preserves the old
opaque width/height envelope; Actor.Scale 0.275, radius, height, mass, ownership,
equipment identity, quality, quest/Box rules and saved fields are unchanged.
No bitmap generation, image edit or third-party mesh is introduced. Reverse
engraving and character wearables remain unauthored.

Final complete-package checks pass 3,326 native assertions: exact phase counts
715/632/715/632/632 for baseline, previous-save/new-model, fresh/new-model,
reload and rollback. All 42 combinations retain native type, quality, identity,
icons, mass, collision, floor contact, metadata and quest/Box guards; direct
native equip/unequip and second drop also pass. No ordinary-menu, hub journey,
crafting or complete character-effect acceptance is implied. Initial art
iterations passed 715 fixture checks each while still needing visual correction;
successful gameplay checks alone did not qualify their appearance.

Twenty-two exported files repeat byte-for-byte. All 18,233 package entries
match src; nine new meshes and one model definition are added, with only the
root MODELDEF include and two release diagnostics changing existing resources.
All original PNG, model, gameplay and inventory bytes remain unchanged. Project
and focused static validation pass; all nine fronts and representative
side/oblique/rear views were inspected. No native errors remain in the final suite.

One isolated 700-tic nine-object pair records 1026.06/1007.60 queue presents/s for
sprites/models, p95 1.1880/1.2388 ms and p99 1.4289/1.4931 ms. Both cohorts were
visually checked. Environment: Windows 11 Pro 26200, Ryzen 9 5950X, 32 GB,
RTX 3070 Ti, GZDoom 4.14.2, Vulkan 1280x720, uncapped, vsync off, background
unpaused and 5% audio. These are queue intervals, not GPU/display timing,
repeatability or campaign/crowd acceptance. Evidence:
assets/validation_v5_17_15/evidence/SUMMARY.json. Author appearance and ordinary
menu acceptance remains pending as CA674-JEWELRY-01.

The read-only #647 native discovery resolved 856 default/catalogue rows before
this slice. It found 25 garment states, 16 armor states, four shields, nine
jewelry states, 35 weapon states and 86 material states without exact bindings.
These are presentation states, not unique item counts; weapon essences and
qualities can share art. A same-named sprite on another class is only a reuse
candidate: unrelated legacy classes also share sprite identifiers. The audit
does not establish complete gameplay coverage or authorize restoring rejected
#479 support-implement meshes. Broader inventory/character conversion continues.

## 5.17.14 - Native lock inventory model binding (#672, parent #647)

One explicit CaelumLockItem/CKEY/A binding reuses the unchanged original #656
key.md3 and materials. All eight native padlock/key/tool types already share
ca_key.png and CKEY/A; this patch retains that shared gold-key/blue-ribbon
representation. It does not introduce separate padlock or lockpick designs.
Native LockItemType, PairIdentity tokens, per-instance ownership, tier, weight,
Box/quest restrictions, recipes and saved fields remain unchanged. No installed
lock, chest-opening, theft or witness logic changes; #382 acceptance is retained.

CaelumLockItem keeps its original Actor.Scale 0.25 and collision; the existing
CaelumSilverKey retains its own 0.125 scale. Both consume the same original
image-fitted mesh without a new physical-size interpretation. The mesh has
2,974 vertices / 2,840 triangles. Geometric editing controls remain in the #656
documents/DESIGN.json; generate_inventory_document_models.py recreates key.obj
and documents.mtl under its selected output directory. No redundant mesh or PNG
copy is introduced. locks/DESIGN, PROVENANCE and EXPORT preserve exact reuse
hashes, the original bounds/surfaces and the new binding. The deterministic
generate_inventory_lock_model.py exports only that binding and its manifest;
readonly validation checks the original bytes, records and class/sprite/scale.

The isolated fixture sets up two independent copies of all eight types, with
six matching pair values. It checks native pickup/toss, distinct same-class
instances, metadata, mass, collision, icons, floor contact and Box/quest guards.
Load phases also check matching tokens in independently reconstructed objects,
wrong same-tier keys, Box exclusion and the existing picks/master-key access.
These are direct native inventory/access calls, not a new chest/theft test.

The final complete package passes 1,646 native checks, exact phase counts
349/316/349/316/316 across baseline, previous-save/new-binding, fresh/new-binding,
reload and rollback. All sixteen instances retain their original type and pair;
matching serialized values permit access, wrong same-tier pairs fail, and Box,
picks/master-key and temporary quest rules remain intact. The earlier visual
run passes 349 checks with the same reused art. The first load probe set Box
flags during successive pickups; native unowned-Box normalization cleared prior
flags and caused twelve fixture access failures. Set those direct probe flags
after the complete pickup batch, then repeat all five native phases. Production
logic and runtime bytes remain unchanged. No hub journey or
ordinary-menu acceptance is implied by reconstructed-token probes.

Three export files repeat byte-for-byte. All 18,223 package entries match src;
only the new binding, root MODELDEF include and two release diagnostics differ
from #670. All mesh, PNG, gameplay and existing key-model bytes are unchanged.
Project and focused validation pass. Final front/side/oblique/rear views and the
sixteen-object scene were inspected.

One isolated 700-tic sixteen-object pair records 1169.98/1127.44 queue presents/s
for sprites/models, p95 1.0351/1.0713 ms and p99 1.2384/1.3079 ms. Both cohorts were
visually checked. Environment: Windows 11 Pro 26200, Ryzen 9 5950X, 32 GB,
RTX 3070 Ti, GZDoom 4.14.2, Vulkan 1280x720, uncapped, vsync off, background
unpaused and 5% audio. Queue intervals are not GPU/display timing, repeatability
or campaign/crowd acceptance. Evidence: assets/validation_v5_17_14/evidence/SUMMARY.json.
Author appearance and ordinary-menu review remain pending as CA672-LOCKS-01.

## 5.17.13 - Closed mate drop models (#670, parent #647)

CaelumMateGourd, CaelumMateSilver and CaelumMateGold receive new 3D drop models
derived from the corrected, author-accepted #472 painted designs. Each contains
a closed porongo shell with a narrow rim, recessed interior walls/floor, a fixed
bronze bombilla and its recessed mouthpiece. The silver rosette and leafy scrolls,
gold floral panel/borders and plain dried-gourd surface reuse the exact accepted
paint. No rejected hemispherical mesh or old implement binding is reactivated.

Three original high-resolution PNGs from assets/art_source/mate_sprites are
copied byte-for-byte into src/models/caelum/inventory/mates. No raster editing or
new image generation is performed. The existing front motif repeats around the
rear; this does not invent separate reverse-side ornament. Closed, consistently
wound components are exported as MD3, with editable OBJ/MTL and portable original
textures under assets/source/art/inventory_models_647/mates. DESIGN, PROVENANCE
and EXPORT preserve source hashes, art coordinates, fitting and output hashes.
Geometry/export operations reuse the established owned mesh/MD3 functions.
The three meshes contain 2,720 / 2,848 / 2,848 triangles respectively.

A uniform fit keeps each complete vessel and bombilla inside both original
sprite dimensions, including the existing 5.333333 TEXTURES scaling. Native
Actor.Scale, collision, mass/capacity, icons, item classes, water/yerba/thermal
fields, uses, crafting and drinking logic stay unchanged. The approved physical
open-hemisphere approximation remains a gameplay calculation, independent of
the corrected visual shell. No save schema or migration is introduced.

The first candidate passed 133 native checks but exposed transparent pixels at
the gold foot and lateral texture compression. The second improves the wrap,
foot and mouthpiece; bilinear-margin validation also found the gold bombilla
crossing the source alpha edge. The final curve stays inside original painted
pixels. The readonly validator samples triangle edges/interiors with a bilinear
texel margin (alpha >=250), alongside source/portable hashes, bounds, MD3 frames,
shaders, indices and exact class/sprite bindings. Earlier candidates remain local
recovery evidence; no source PNG is repainted to conceal an invalid mapping.

The final complete package passes 617 native checks, with exact phase counts
133/117/133/117/117 across baseline, previous-save/new-model, fresh/new-model,
reload and rollback. Six independent filled/empty mates retain unique identity,
water, yerba, remaining uses, temperature/stamp, mass, contamination and provenance.
Duplicate-class pickup remains blocked; direct Box flags block drinking and mass.
Load phases exercise native cold drinking, retain the vessel and hot-use count,
and observe delayed thirst recovery after 40 tics. Setup and direct methods do
not establish ordinary menu, pouring/loading or hot-mate recovery acceptance.
Native front/side/oblique/rear views of all three final models were inspected.

Ten exported files repeat byte-for-byte, including the preview package; the
three original portable PNG copies also match exactly. The complete runtime's
18,222 entries match src. Only three new MD3s, three unchanged source PNG copies,
their model definitions, root MODELDEF include and two version diagnostics differ
from #668. Existing gameplay, rejected legacy art and all other native bytes are
unchanged. Project and focused validation pass.

One isolated 700-tic three-object pair records 1172.84/1194.33 queue presents/s
for sprites/models, p95 1.0619/1.0414 ms and p99 1.3183/1.2891 ms. Both floor-level
cohorts were visually checked. Environment: Windows 11 Pro 26200, Ryzen 9 5950X,
32 GB, RTX 3070 Ti, GZDoom 4.14.2, Vulkan 1280x720, uncapped, vsync off,
unpaused background and 5% audio. Queue-present intervals do not measure GPU or
display timing, repeatability, campaign performance or crowds. Evidence and
earlier candidates: assets/validation_v5_17_13/evidence/SUMMARY.json.
Author visual/menu acceptance remains separately pending as CA670-MATES-01.

## 5.17.12 - Water-ration waterskin model (#668, parent #647)

CaelumWaterRation and legacy CaelumMazeWater receive explicit CWAT/A bindings
to one original 3D assembly based on the approved ca_water_ration.png icon:
closed leather body, angled neck, carrying strap/loop, blue pendant and separate
drinking cup. The cup has an outer wall, lip, recessed inner wall and floor,
with a dark inner lining. These components remain one native consumable ration;
they do not introduce refillable containers, capacities, recipes or mechanics.
Original icons, item classes, collision, Actor.Scale, weight, stacking,
contamination, companion provenance and thirst-regeneration behavior are intact.

Six material roles reuse unchanged owned water/consumable atlases and original
station iron pixels. The final dark lining samples the approved icon's opaque
cup interior with a one-pixel UV inset. No bitmap is generated or edited. The earliest material
candidate used bright metallic neck bands; the revised candidate uses leather
bindings and cord, a dark pendant setting and an opaque iron cup with dark
interior. Width is the limiting fitting axis: the complete assembly fits inside
both original opaque CWATA0 dimensions without redefining physical capacity.
Sixteen closed components contain 2,680 triangles. Editable geometry/materials,
four original texture copies and exact source hashes live under
assets/source/art/inventory_models_647/waterskin, with DESIGN.json,
PROVENANCE.json and EXPORT.json. The model remains pending author visual review.

Rebuild with `python assets/generators/generate_inventory_waterskin_models.py
--output build/waterskin-models --install`; --check verifies the same generated
outputs. Preserve the adjacent portable OBJ/MTL and unchanged texture copies.
The shared exporter gains optional per-component UV normalization for folded
hollow profiles. Earlier parts do not enable it: all 22 native resources from
ammunition, documents and ingots remain byte-identical, with only their exporter
hash metadata refreshed. The readonly validator checks native quantized geometry,
UV rectangles, exact bindings, original material hashes, portable files and both
sprite envelope dimensions. A closed tube whose endpoints coincide is represented
by two closed semicircular parts, avoiding duplicate coincident end caps.

The native fixture checks both classes, split/merged quantities, ownership,
saved metadata, Box weight/use rules, exact original power identity, floor
contact and actual consumption/thirst restoration. The final package passes
220 assertions across baseline, old-save/model, fresh/model, reload and rollback
(47/42/47/42/42). Load phases consume exactly one ration per class and confirm
the first native thirst pulse after 40 tics. The final visual-only run passes
47 assertions with the same fixture and native art. Both identities were
inspected in front, oblique and rear close-ups, including the hollow cup.

Six exports repeat byte-for-byte. The mesh contains 1,461 vertices and 2,680
triangles in sixteen closed components. Native art bounds are 86 by 40.45 by
87.37 units before unchanged Actor.Scale, inside the original 86-by-112 opaque
sprite envelope. All 18,215 package entries match src. Only the new MD3, its
two-binding MODELDEF, root include and two release diagnostic strings differ
from #666. Earlier native resources, including all 22 exports using the shared
exporter, remain unchanged. Original material pixels and portable copies match.

One isolated 700-tic two-object pair records 992.72/982.58 queue presents/s
for sprites/models, p95 1.2888/1.3370 ms and p99 1.5651/1.7446 ms. Both floor-level
presentation subjects were inspected and visible; the original sprite has an
explicit bottom offset. Environment: Windows 11 Pro 26200, Ryzen 9 5950X,
32 GB, RTX 3070 Ti, GZDoom 4.14.2, Vulkan 1280x720, uncapped, vsync off,
unpaused background, 5% audio. These queue intervals are not GPU/display timing,
repeatability or campaign/crowd acceptance. Evidence and rejected art iterations:
assets/validation_v5_17_12/evidence/SUMMARY.json. The brown lining candidate was
rejected because it resembled brown contents; the final lining uses the approved
icon's dark cup interior. CA668-WATERSKIN-01 and all other author tests remain
outstanding. Ordinary inventory-menu acceptance is separate.
The earlier rejected hemispherical mate meshes remain unbound; their approved
corrected sprites are a separate future modeling task.

## 5.17.11 - Native unplaced furniture models (#666, parent #647)

Seventeen existing inventory classes receive world models: wardrobe, cupboard,
basic/luxury chair and bed, two/three-seat sofa, desk, bookcase, four complete
dining sets, small/large landscape painting and ornamental statue. Thirteen
reuse original placed OBJs directly. Four assembled OBJs reuse the original
table and every chair at the native 2/6/12/6-seat transforms. No new furniture
design, balance, physical body, material pixels or inventory icon is introduced.
Original body bindings, geometry, UVs and owned textures remain authoritative.

Uniform fitting preserves native Actor.Scale and fits both the original opaque
sprite width and height. Wardrobe/cupboard TEXTURES scaling is included; the
other fifteen use their raw sprite scale. These small inventory presentations
do not redefine the dimensions of placed furniture. Original MODELDEF rotation,
pixel-stretch and backface policy are retained. GZDoom 4.14.2's OBJ reader
negates OBJ Z before yaw; dining assembly transforms account for that reflection.
Native SeatPosition/SeatAngle and chair-class checks verify the source layout.

Portable OBJ/MTL sources and eleven unchanged textures live under
assets/source/art/inventory_models_647/furniture/editable. DESIGN.json records
source hashes and exact original body blocks; PROVENANCE.json records ownership
and scope; EXPORT.json records every part, transform, bound and output hash.
Rebuild with `python assets/generators/generate_inventory_furniture_models.py
--output build/furniture-models --install`; --check verifies installed outputs.
The project validator independently regenerates and compares every export.

The native fixture covers two independent copies of all seventeen classes,
pickup/toss, metadata, contamination, original mass, Box weight rules, quest
guards, body-link guards, icons, collision, floor contact and saved identities.
Sofas, desks, decor and dining sets have distinct native body references; the
bookcase instead becomes storage cargo when placed. This patch does not change
those paths, cargo contents, locks or existing placed-body rules. The fixture
does not certify ordinary menus or placement/cargo workflows. The exact final
package passes 2,920 assertions across baseline, old-save/model, fresh/model,
reload and rollback (743/478/743/478/478). The preceding visual run passes 743;
the final fixture also exposes angle 0 for front views. All seventeen designs
were inspected in isolated close-ups. Original details, including painted
canvas visible from both sides under the existing backface policy, are retained.

Thirty-six exports repeat byte-for-byte. There are 64,168 selected vertices and
30,464 triangles across the seventeen presentations, including repeated chair
parts. All 18,213 package entries match src. Only four assembled dining OBJs,
the seventeen-binding MODELDEF, root include and two release diagnostic strings
differ from #664; all other native bytes remain identical.

One isolated 700-tic pair with seventeen objects records 1107.14/1079.71 queue
presents/s for sprites/models, p95 1.1157/1.1655 ms and p99 1.3254/1.3817 ms.
Both cohorts and camera are raised 64 MU to show the original offsetless sprites;
floor contact is checked separately in the native continuity fixture. Both
presentation scenes were visually inspected. Environment: Windows 11 Pro 26200,
Ryzen 9 5950X, 32 GB, RTX 3070 Ti, GZDoom 4.14.2, Vulkan 1280x720, uncapped,
vsync off, unpaused background, 5% audio. Queue-present intervals do not measure
GPU/display time or establish repeatability, campaign or crowd performance.
Evidence: assets/validation_v5_17_11/evidence/SUMMARY.json.

Rejected fixture attempts are retained: an incompatible pointer ternary;
a 4512-character command line that lost its initial events and ran zero checks;
and incorrect sofa/desk/bookcase body-reference assumptions. Bounded chained
command files, native subclass dispatch and exact expected assertion counts
resolve these harness errors. No production gameplay change follows from them.

CA666-FURNITURE-01 remains an author check. Earlier furniture/placement author
checks and all remaining inventory classes remain separate and outstanding.

## 5.17.10 - Native camp inventory drop models (#664, parent #647)

CaelumCampTent and CaelumCampPot receive class-specific world model bindings.
The tent directly reuses the accepted enlarged deployed tent OBJ. The pot OBJ
contains only unchanged iron faces from the original mounted pot: bowl, two
handles and integral trivet. Wood and fire faces are excluded; the original
campfire and tent resources remain untouched. The sleeping bag already has a
world model and requires no replacement. Original painted icons remain intact.

Uniform fitting uses the smaller of the original opaque sprite width divided
by maximum horizontal mesh extent and sprite height divided by total mesh
height. The trivet makes width-only pot fitting too tall, so both dimensions
constrain the drop presentation. Native Actor.Scale, collision and ownership
stay unchanged. These inventory display dimensions do not replace the physical
dimensions of deployed camp structures. The pitched tent icon remains the
reference; no packed-tent design or deployment mechanic is invented.

The tent contains 1,705 selected vertices and 669 triangles; the pot/trivet has
3,188 vertices and 1,288 triangles. Original OBJ polygons/UVs and owned material
pixels are retained, including the existing canvas seams, iron texture and thin
trivet legs. Native bindings retain the original backface policy and rotation.
Portable OBJ/MTL sources and adjacent unchanged textures are available under
assets/source/art/inventory_models_647/camp/editable. Source hashes and decisions
live in DESIGN.json, PROVENANCE.json and EXPORT.json in the parent directory.
No new bitmap generation or editing occurs. Rebuild with
`python assets/generators/generate_inventory_camp_models.py --output build/camp-models --install`;
--check verifies the same outputs.

The final package passes 448 native checks across baseline, old-save/model,
fresh/model, reload and rollback (110/76/110/76/76). Two tents and two pots retain
separate identities, water/thermal state, provenance, surface contamination,
weight, Box weight treatment, quest/active-boiling guards and floor contact.
This invokes native pickup/toss and weight rules, not ordinary menu acceptance.
The earlier visual-only run passes 110 checks with the same fixture/model bytes.
Both models were inspected in front/oblique/rear detail and overview captures.

Twelve exports repeat byte-for-byte. The readonly validator confirms original
selected pot geometry/UV identity, bindings, fitting and owned pixel hashes.
All 18,208 package entries match src; only the extracted pot OBJ, two-binding
MODELDEF file, root include and two release diagnostic strings differ from #662.
All other runtime bytes, including deployed camp resources, remain identical.

The first presentation run had valid actor/timing counts but invisible baseline
sprites below the floor: the original camp PNGs contain no grAb offset chunk.
That comparison was rejected after capture inspection. The final diagnostic
raises both cohorts and the camera by 64 MU, with fixture-only no-gravity flags;
both sprites and models are visibly framed. Native floor contact is covered
separately by the unchanged continuity fixture. See CA-KP-233.

The final isolated 700-tic pair with two objects records 1194.11/1158.65 queue presents/s
for sprites/models, p95 1.0344/1.0690 ms and p99 1.2473/1.2862 ms. Environment:
Windows 11 Pro 26200, Ryzen 9 5950X, 32 GB, RTX 3070 Ti, GZDoom 4.14.2,
Vulkan 1280x720, uncapped, vsync off, unpaused background, 5% audio. These are
queue-present intervals, not GPU/display timing, repeatability or campaign/crowd
acceptance. Evidence: assets/validation_v5_17_10/evidence/SUMMARY.json.
CA664-CAMP-01 remains the author visual check; broader inventory coverage and
earlier deployed-pot/trivet visual acceptance remain separate.

## 5.17.9 - Nahuelito inherited combat model (#662, parent #461)

CaelumBestiary055 gains an explicit model for all 23 inherited idle, locomotion,
stun, preparation/release, pain, death, breath and lying-rest frame pairs. The
original #455 anatomy, topology, UVs and three owned textures remain unchanged.
Editable neck/tail bends, flipper pivots, jaw opening and body roll add combat
presentation; original wave cycles supply movement. No aquatic AI, new attack,
faction, loot, encounter or campaign population is introduced. Native state
identities, durations, action calls, physics and serialization remain intact.

Uniform fitting uses the smaller of Radius/all-pose radial extent and
Height/all-pose vertical extent, divided by unchanged Actor.Scale, with
CorrectPixelStretch. Every authored pose stays inside the provisional Mandinga
body envelope. This deliberately small combat presentation does not approve
final species dimensions or mesh/hitbox matching: empty collision space remains
above the model. The original 384-MU/12m preview and regional gallery retain
their original scale. Final size and body correspondence remain author decisions.

Editable controls, grouped neutral OBJ/MTL, adjacent owned texture copies and
export hashes live in assets/source/art/nahuelito_662. Rebuild with
`python assets/generators/generate_nahuelito_combat_model.py --output build/nahuelito-combat --install`;
--check verifies installed exports. Geometry has 5,174 vertices, 9,272 triangles
and three material surfaces. No raster generation or editing occurs.

The final package passes 115 continuity/state/body/inventory checks across
baseline, old-save/model, fresh/model, reload and rollback. Separate exact
keyframe inspection passes 51 checks with all 23 poses visible, using the
established CA-KP-230 fixture. Representative poses and front/side/rear captures
were inspected at closer framing after the initial distant review. Six actual
attacks (Mandinga control and Nahuelito melee/projectile/breath), finite stock,
death guards and loot reload pass 80 checks with ordinary gameplay actions.

Binary checks cover 119,002 native vertex/frame bounds and the fitted body
envelope. Twelve exported files repeat byte-for-byte. All 18,206 package entries
match src; only five new Nahuelito resources, the MODELDEF include and two release
diagnostic strings differ from the #660 baseline. Other creatures, original
Nahuelito preview/gallery and gameplay code retain identical runtime bytes.

One 700-tic sprite/model pair records 1727.77/1708.91 queue presents/s,
p95 0.7864/0.7870 ms and p99 0.9820/0.9680 ms. Environment: Windows 11 Pro 26200,
Ryzen 9 5950X, 32 GB, RTX 3070 Ti, GZDoom 4.14.2, Vulkan 1280x720, uncapped,
vsync off, unpaused background, 5% audio. A separate wide camera fully frames
both subjects, with an offscreen Mandinga control. The model is deliberately
smaller under temporary body fitting, so this is not an equal-silhouette cost
comparison. A single pair is not GPU/display timing, repeatable improvement or
campaign/crowd acceptance. Evidence: assets/validation_v5_17_9/evidence/SUMMARY.json.
CA662-NAHUELITO-01 remains pending; this creature does not complete the wider roster.

## 5.17.8 - Cuero Uñudo inherited combat model (#660, parent #461)

CaelumBestiary053 receives an explicit 3D model for all 23 inherited frame pairs:
idle, locomotion, stun, shared melee/magic preparation and release, pain, death,
breath and lying rest. Its original #455 sheet, rim, claws, eyes and owned skin
are preserved. Editable continuous deformation controls fold the same anatomy;
locomotion reuses the original wave cycles. This introduces no aquatic AI,
wrapped-victim mechanic, attack, faction, loot, encounter or campaign population.
Native class/state identities, durations, action calls and persistence stay intact.

The native body still uses the approved provisional Mandinga Radius, Height,
Scale and mass. Because this creature is flat, the neutral maximum horizontal
extent fits the existing body diameter: 2*Radius/(96*Actor.Scale), with
CorrectPixelStretch. That fitting is temporary combat presentation, not a final
species-size decision or acceptance of mesh/hitbox correspondence. In particular,
the inherited tall collision column remains above the flat visible creature.
The original 96-MU/3m preview and regional gallery remain unchanged and retain
their own presentation role. Author body-scale review remains outstanding.

ANIMATION.json in assets/source/art/cuero_660 owns the poses and inspection
views; the original geometry/UV source remains in assets/source/art/cuero_455.
Rebuild with `python assets/generators/generate_cuero_combat_model.py --output build/cuero-combat --install`;
--check verifies deterministic outputs. Neutral grouped OBJ/MTL and export hashes
are retained. No raster generation or editing occurs. The native model has 9,536
surface vertices (9,523 source vertices), 16,032 triangles and three surfaces.
The generalized readonly native validator retains its original Pombero defaults.

The final package passes 115 continuity/state/body/inventory checks across
baseline, old-save/model, fresh/model, model reload and rollback. Separate exact
keyframe inspection passes 51 checks with all 23 poses visible; representative
poses and front/side/rear views were inspected. The fixture reuses CA-KP-230's
post-Tick, nofunction and local still-interpolation rules. Six real attacks
(Mandinga control and Cuero melee/projectile/breath), finite stock debiting,
death guards and loot reload pass 80 checks with ordinary gameplay actions.

Binary checks cover 219,328 native vertex/frame bounds. Eight exported files
repeat byte-for-byte. The editable OBJ/MTL has an adjacent byte-identical source
skin, correcting material resolution without changing runtime bytes. All 18,201
package entries match src; only three new Cuero resources, the MODELDEF include
and two release diagnostic strings differ from the #658 baseline. Original
Cuero preview/gallery, Pombero and gameplay code retain identical bytes.

One 700-tic sprite/model pair records 1644.82/1702.87 queue presents/s,
p95 0.8262/0.7859 ms and p99 1.0152/0.9752 ms. Environment: Windows 11 Pro 26200,
Ryzen 9 5950X, 32 GB, RTX 3070 Ti, GZDoom 4.14.2, Vulkan 1280x720, uncapped,
vsync off, unpaused background, 5% audio. The camera frames the flat model;
the inherited tall sprite is partially clipped in that same view. This bounded
diagnostic is not an equal-silhouette comparison, GPU/display timing, repeatable
performance improvement or campaign/crowd budget. Evidence and source manifests:
assets/validation_v5_17_8/evidence/SUMMARY.json. CA660-CUERO-01 remains pending;
wider creature coverage, final species dimensions and author review are unfinished.

## 5.17.7 - Native metal-ingot material models (#658, parent #647)

The shared CaelumMaterialPickup now has explicit model bindings for iron,
copper, tin, bronze, steel, silver and gold (existing IDs 0,59,60,67,68,69,70).
Their original Mxxx/A pairs select seven closed beveled meshes; all three native
tiers keep their existing common appearance and distinct inventory identity.
The legacy CaelumIronIngot model from #656 is unchanged. No item class, saved
field, polling loop or gameplay mutation is added.

Editable sources are in assets/source/art/inventory_models_647/ingots. The
geometry reuses #656's closed ingot family. Each material samples a stored opaque
rectangle inside its existing 128px icon; original PNG pixels are untouched.
A one-pixel opaque margin keeps bilinear filtering inside the source material.
These reused small patches are deliberately limited in close-up resolution;
author art review remains required. No new image generation occurs. Rebuild with
`python assets/generators/generate_inventory_ingot_models.py --output build/ingot-models --install`;
--check verifies deterministic exports. Editable OBJ/MTL is emitted beside MD3.
Width is normalized to the original opaque sprite extent; native scale and
collision remain authoritative. Materials, recipes, value, unit weight, quality,
surface ledgers, provenance, Box and Limbo rules remain unchanged.

The native fixture exercises seven identities times three tiers. It verifies
native pickup, split/merge, distinct stacks, FIFO surface-lot markers, original
metadata and saved ownership without invoking ordinary inventory menus.
The complete package passes 2,924 native assertions across sprite baseline,
old save with models, fresh models, model save/reload and rollback. Checks cover
all 21 material/tier identities, quantities and ownership, original sprite/icon,
weight/collision/scale, floor contact, distinct native stacks, FIFO surface lots,
contamination/provenance, direct Box weight and Limbo quest guards. Menus and
author art review remain separate.

Static checks pass source hashes, seven unique class/sprite/A pairs, opaque
bilinear margins, MD3 headers/surfaces/UVs/quantized bounds and triangle indices.
Seven closed components total 5,376 source vertices and 1,792 triangles. Eighteen
repeated exports are identical. All 18,198 packaged entries match src: eight new
resources, one MODELDEF include and two release diagnostics; all other bytes,
including the legacy ingot and every existing model, match the prior package.
All seven materials received native visual inspection; the final fixture records
21 detail rotations and seven overview views. Earlier compiler and pre-margin
captures remain in the evidence.

One sequential 700-tic pair with seven objects records 1019.78/1017.60 queue presents/s, p95 1.2371/1.2283 ms and p99 1.4418/1.4359 ms.
Environment: Windows 11 Pro 26200, Ryzen 9 5950X, 32 GB, RTX 3070 Ti,
GZDoom 4.14.2, Vulkan 1280x720, uncapped, vsync off, unpaused background and
5% audio. This bounded comparison is not GPU/display timing, repeatability or
a campaign/crowd budget. Evidence: assets/validation_v5_17_7/evidence/SUMMARY.json.
CA658-INGOTS-01 and the wider #647 inventory/character work remain pending.

## 5.17.6 - Document and small-supply world models (#656, parent #647)

Six existing native inventory classes receive five closed 3D meshes: the
processing manual and recipe book share the original blue/gold book design;
the sealed letter retains paper and red wax; the native silver-key class retains
its existing gold key and blue ribbon appearance; the cleaning cloth is folded
linen; the legacy iron ingot is a beveled metal block. MODELDEF binds each exact
class and original spawn pair. Native scale, collision, quantities, icons, keys,
recipe pages, contamination, provenance, Box and Limbo rules are unchanged.
Dynamic materials, locks, clothing and weapon catalogues remain separate work.

DESIGN.json and PROVENANCE.json in assets/source/art/inventory_models_647/documents
preserve the editable geometry and owned material sources. No new bitmap or image
generation is used. The five MD3 files reuse existing cloth, paper, metal, gold,
wax and linen pixels. Rebuild with
`python assets/generators/generate_inventory_document_models.py --output build/document-models --install`;
--check verifies deterministic outputs. The export also emits editable OBJ/MTL.
Width is normalized to each original opaque sprite extent, preserving Actor.Scale.
The cloth uses a vertical surface wave over closed subdivided prisms. Existing
ammunition defaults remain compatible: all eight prior runtime files are identical
after refreshing the shared generator's source hash.

Native tests use assets/validation_v5_17_6/run_document_drops.py and the shared
inventory observer. The manual's existing deferred sheet delivery must finish
before the independent recipe-book test, or that delivery creates another owned
book and correctly blocks the first book's pickup. The fixture now exercises and
checks that delivery explicitly. Initial compiler and ordering failures are kept
as failed evidence. The final complete package passes 472 assertions in five
phases: sprite baseline, old save with models, fresh models, model save/reload,
and rollback to the sprite package. Checks cover all six classes, native
pickup/toss and quantity, five Limbo quest guards, original collision/scale/icons,
floor contact, companion provenance, contamination, recipe pages, unit weight,
native key identity and the manual's deferred sheet delivery. No new save field
or schema is introduced. Ordinary menu and author review remain unconfirmed.

Static checks pass all six bindings, owned sources, MD3 surface/UV/quantized-bound
and triangle-index checks. The five designs total 48 closed components, 19,756
source vertices and 10,992 triangles. Fourteen repeated export files are
byte-identical. The package matches all 18,190 src entries: six new resources,
one MODELDEF include and two release diagnostics; all other runtime bytes match
the previous package. Native representative rotations and both book classes
were inspected; the final fixture records 18 detail views and seven overview views.

A single sequential 700-tic pair with six objects records sprite/model queue
presents at 1178.42/1144.28 per second, p95 1.0509/1.0821 ms and p99
1.2602/1.3074 ms. Environment: Windows 11 Pro 26200, Ryzen 9 5950X, 32 GB,
RTX 3070 Ti, GZDoom 4.14.2, Vulkan 1280x720, uncapped, vsync off, unpaused
background and 5% audio. This is a small isolated comparison, not GPU/display
timing, repeatability, a crowd budget or campaign acceptance. The measured model
run has slightly longer intervals; no performance improvement is claimed.
Evidence: assets/validation_v5_17_6/evidence/SUMMARY.json. CA656-DOCUMENTS-01
remains pending, as do the broader #647 inventory and character catalogues.

## 5.17.5 - Pombero inherited combat model (#461, first creature)

CaelumBestiary006 receives an explicit native 3D binding using the original
Pombero anatomy, UVs and unchanged owned textures from #455. The new editable
ANIMATION.json in assets/source/art/pombero_461 supplies 23 inherited frame pairs:
idle, run/walk, stun, shared melee/magic preparation/release, pain, six death
stages, racial breath and lying rest. The final two death frames share a settled
pose. The existing gameplay states, action calls, durations and serialization
remain byte-identical. No new saved fields, classes, encounter or population
are introduced. The original unintegrated 32-MU pilot and gallery stay intact.

The generator reads the current approved provisional Mandinga Height and Scale
from their existing source, normalizes the neutral model to that height and
divides out Actor.Scale in MODELDEF. It retains CorrectPixelStretch; neither
collision, mass nor the native actor scale changes. This is a provisional combat
presentation, not approval of final Pombero species dimensions. The fixed
reference outfit remains separate from the still-unfinished modular equipment
catalogue. Existing attacks keep their approved provisional Mandinga profile.

Rebuild with `python assets/generators/generate_pombero_combat_model.py --output build/pombero-combat --install`;
--check verifies deterministic exports. ANIMATION.json and the original design
remain editable; neutral OBJ/MTL, export hashes and original art provenance are
preserved. No new image generation or raster edits occur in this patch.

Native inspection uses assets/validation_v5_17_5/run_pombero.py. The native
signature is SetState(state, nofunction=false): frozen art inspection must pass
true, select a nonzero-duration state and run after the actor's Tick. Earlier
fixture calls executed Look/attack/death functions, moved out of view or changed
body flags. Those iterations are not successful visual evidence. The corrected
fixture verifies the actual state/sprite/frame and native flags after inspection.
Still captures disable model-frame interpolation locally; ordinary interpolation
is restored before saving and remains active in the continuity/presentation runs.
Otherwise tics=-1 can display an interpolated neighbor despite a correct state.

The final package passes 115 checks across baseline, old-save/model, fresh/model,
model reload and rollback to the baseline package. These include unchanged body
and state identity, finite inventory ownership, initialization, solid-body/wall
collision, free movement and native frame advancement. A separate exact-keyframe
visual run passes 51 checks, covers all 23 visible frame pairs and supplies front,
side and rear views. Representative poses and orientation captures were inspected.
Six actual attacks (Mandinga control and Pombero melee/projectile/breath) plus
death, finite-stock debiting, repeated-death guards and loot reload pass 80 checks.
Those actions run normally, without the frozen visual pose driver.

Static checks pass 301,645 binary coordinate/bounds checks, 13,115 vertices,
22,815 triangles and four material surfaces. Repeated exports are byte-identical;
the package matches all 18,184 src entries. The five new model/material/definition
resources and one MODELDEF include are the only art additions; two existing
diagnostic strings carry the release. All other runtime bytes are unchanged.

One sequential 700-tic pair compares the inherited sprite with the model in the
same isolated room, with one inspected subject and an offscreen Mandinga control:
1719.07/1738.87 queue presents/s, p95 0.7639/0.7640 ms, p99 0.9174/0.9117 ms.
Environment: Windows 11 Pro 26200, Ryzen 9 5950X, 32 GB, RTX 3070 Ti, GZDoom 4.14.2,
Vulkan 1280x720, uncapped, vsync off, unpaused background and 5% audio. These are
queue-present intervals, not GPU/display timing; one pair cannot establish
repeatability, crowd/campaign budgets or an improvement. Existing maps and armies
are unchanged and this creature remains unplaced. Evidence and failed iterations:
assets/validation_v5_17_5/evidence/SUMMARY.json. CA461-POMBERO-01 remains pending;
this first creature does not complete the #461 roster or author art acceptance.

## 5.17.4 - Regional materials and inspection gallery (#463)

The author requested needed regional textures and a small map alongside the
regional monsters. This first slice supplies three owned ground materials and
an isolated gallery for the three existing visual pilot identities. Pombero is
shown in Litoral and Selva; Cuero and Nahuelito are shown in Patagonia, following
the approved REGION_PROPOSAL.json. These four displays are original #455 preview
actors, not campaign populations, physical combat bodies or new encounter rules.
The remaining creatures and other regional environments are still unfinished.

INVENTORY.json in assets/source/art/regional_gallery_463 records the asset gaps
and existing city/port/beach, rock, bark and foliage resources retained. Built-in
image_gen generated three separate 1,254-square opaque PNGs: damp Litoral soil,
Selva leaf litter and Patagonian gravel. All original PNG bytes and exact prompts
remain beside PROVENANCE.json. Runtime copies are byte-identical; no raster was
edited. Native display tiles use 128, 32 and 64 MU respectively: the generated
leaf/gravel features need smaller tiling than the prompt's approximate 4m patch.
Those are art presentation scales, not body/collision or campaign dimensions.
The recorded scales must be judged in repeated native floor views.

`python assets/generators/generate_regional_materials.py --output build/regional-materials --install`
rebuilds the material definitions and unchanged image copies; --check compares
the deterministic export. New IDs CRLITGR/CRSELVG/CRPATGR do not replace old maps
or materials. The #652 ammunition manifest's TEXTURES input hash is refreshed
for the new include; its original icon aliases and model output remain intact.

GALLERY.json contains test coordinates for CA463G: four sectors, 15 linedefs,
three floor plots and a connecting walkway. assets/validation_v5_17_4/build_gallery.py
packages that map plus the preserved pilot resources from assets/bestiary/models;
no source model geometry, scale, animation or textures change. It is an isolated
development fixture, not a new campaign destination. The optional run_gallery.py
launcher provides F1 overview, F2/F3/F4 regional views, F5 player control, F6 Cuero,
F7 Nahuelito and F8-F10 repeated-floor views. The final package passes 36 native
fresh/reload checks, retaining references and idle advancement. Real native input
walks onto the plots and crosses both regional boundaries. The initial crossing
attempt was too short: 210 tics advanced about 605 of the required 768 MU. The
recorded 420-tic test reaches x631 from x-768 without changing game speed. The
runner waits for its last network event and requires exact per-phase counts;
an earlier clean exit with only the initial assertions is retained as partial
evidence. Separate gallery exports and their manifests are byte-identical.

Evidence: assets/validation_v5_17_4/evidence/SUMMARY.json. The package matches
18,179 source entries; existing runtime files change only at the new TEXTURES
include and two current-version diagnostics. One sequential 700-tic pair uses
the same four displays/geometry with old cobbles versus regional materials:
1849.27/1860.24 queue presents/s, p95 0.7010/0.7082 ms, p99 0.8260/0.8317 ms.
Environment: Windows 11 Pro 26200, Ryzen 9 5950X, 32 GB, RTX 3070 Ti, GZDoom 4.14.2,
Vulkan 1280x720, uncapped, vsync off, unpaused background, 5% audio. Queue presents
are not GPU/display timing. This single pair provides no repeatability estimate
or city/siege budget; existing campaign maps are byte-identical and were not
retested for this isolated slice. CA463-REGIONS-01 remains pending author review;
the broader #463 environment finish and remaining creatures are still open.

## 5.17.3 - Seven ammunition drop models (#652)

The #647 inventory conversion continues in this focused art patch, based on the
separate #650 native stack correction. Seven explicit models cover carbine rounds,
arrows, bolts, three javelin tiers and shotgun shells. Red arrow fletching, blue
bolt fletching, tiered metal fittings/red tassels, leather/brass cartridges and
red paper/metal-base shotgun shells retain the owned reference identities.
The implementation parent CaelumJavelinAmmo is not an eighth ammunition type.
Decorative bundle counts do not encode Amount. Icons, in-flight projectiles,
counts, provenance, weight, collision, actor scale and save fields are unchanged.

The new atlas request was rejected by the built-in image tool and produced no
image. Its exact original prompt and failure metadata remain in
assets/source/art/inventory_models_647/ammunition/PROMPT.txt and
GENERATION_STATUS.json. There was no retry. Geometry instead samples existing
owned training-dummy, consumable-atlas and shotgun-icon pixels without editing
those rasters. DESIGN.json identifies each material rectangle and source hash;
EXPORT.json records deterministic native meshes, components and authoring output.
The seven meshes contain 392-1,568 triangles. Every authored component is closed
and outward-facing. Visual size follows the reference opaque extent; shotgun
uses its world-sprite crop and scale, not the whole source sheet or icon scale.

`python assets/generators/generate_inventory_ammunition_models.py --output build/ammunition --install`
regenerates models and editable OBJ/MTL. Repeat with --check to compare bytes.
Editable MTL uses repository-relative src/ texture paths, resolved from the
repository root when importing; it never embeds a workstation path. The source
shader rasters remain authoritative, rather than duplicated into the export.
The production validator checks source hashes, seven explicit bindings, MD3
surface/shader counts and UV confinement to the specified source rectangles.

The final package passes 551 assertions in five native runs: original/fresh,
old-save load, new-save reload and rollback. Five incoming rounds split into three
held/two dropped, then recombine without changing type, provenance units/markers,
icons, weight, collision or native scale. All 21 front/oblique/rear detail images
match the inspected final overlay pixel for pixel. Evidence is preserved in
assets/validation_v5_17_3/evidence/SUMMARY.json; the package has 18,175 exact src
entries and changes only the new models/include plus two current-version labels.

One sequential 700-tic pair with seven visible drops measures sprites/models at
1126.81/1114.65 queue presents/s, p95 1.1122/1.1108 ms and p99 1.3244/1.3087 ms.
Environment: Windows 11 Pro 26200, Ryzen 9 5950X, 32 GB, RTX 3070 Ti, GZDoom 4.14.2,
Vulkan 1280x720, uncapped, vsync off, unpaused background and 5% audio. This is not
GPU/display timing, a repeatability estimate or an all-item/campaign budget.
No ordinary-menu, firing or multiplayer acceptance is claimed. Author review
remains pending as CA652-AMMUNITION-01. This slice does not complete all dropped
inventory or the campaign/regional art conversion.

## 5.17.1 - Inventory drops in 3D (#647, conversion in progress)

Five closed food meshes now cover ration/maze ration, bread, roast beef, roast
hake and puchero, with explicit bindings for six inventory classes and four
prepared dining displays. The accepted #410 paintings remain unchanged. Owned
built-in ImageGen atlas, exact prompt, reference hashes and editable controls
are in assets/source/art/inventory_models_647/food. New models contain 296-960
triangles and 3-9 closed components. Food footprint width follows the opaque
reference silhouette; its perspective image height is not treated as object
height. Plates/bowl remain presentation, not additional container inventory.

`python assets/generators/generate_inventory_food_models.py --output build/food --install`
uses the shared deterministic exporter; repeat with `--check --install`.
Nineteen prior consumable/water runtime outputs remain byte-identical after
adding width-based art scaling and explicit additional-class bindings. Native
table RefreshDisplays already copies item scale: table MODELDEF applies no
second .25 factor. No portions, recipes, food clocks, contamination or ownership
rules changed. Raised bread-cut tubes looked like spikes in the first native
view; the final model uses the painted crust scoring, with box UVs for slice sides.

The full 18,167-entry package passed 608 assertions in five native fresh/old-save/
reload/rollback runs. Six item classes split/recombine native quantities and
preserve lot units, chronology and contamination; four table displays retain
their real portions, native serving scale and table-surface position. Native
front/side/rear/close/table captures were inspected. Evidence:
assets/validation_v5_17_1/food-evidence/SUMMARY.json. No normal-menu, eating,
cooking, table placement-menu or author acceptance is inferred. For the author
room add `--kind food` below; F9 inspects the prepared meals on the table.

One sequential 700-tic pair for six visible food drops observed 1,166.08/1,149.78
presents/s (sprites/models), p95/p99 1.0599/1.2741ms and 1.0794/1.2929ms; mean
simulation spacing was 28.571ms. The recorded environment and queue-present
limits below apply; this is not a full dining-room or all-inventory budget.

Six bottle/canteen classes now have explicit production models. Small glass stays
green, normal glass amber with a leather sleeve, and the large demijohn green
inside a wicker basket with a solid handle. Small/normal canteens retain round/
oval leather bodies and straps. Five new MD3 meshes contain 640-1,112 triangles
and 5-6 closed outward components each. The large canteen reuses the existing
dining OBJ topology, UVs and owned texture in a separate normalized drop copy;
the dining source/binding remain unchanged. All six follow their original opaque
icon heights, with native scale, collision, capacity, contents and mass retained.

Sources are assets/source/art/inventory_models_647/water: DESIGN.json, EXPORT.json,
PROMPT.txt, PROVENANCE.json and materials-v1.png. The built-in ImageGen edit used
the selected consumable atlas and owned bottle references, requesting green/amber
glass and wicker cells; original output bytes are retained. No pixel-equality
claim is made for unrequested cells. No original icon/sprite was altered.
`python assets/generators/generate_inventory_water_models.py --output build/water --install`
exports native bindings, five MD3s, the normalized canteen OBJ, atlas and editable
new-mesh OBJ/MTL files. Repeat with `--check --install`. Read-only project checks
verify hashes, explicit class coverage, MD3 structure and reused topology/UVs.
Shared-exporter parameterization leaves all eleven previous consumable runtime
outputs byte-identical.

The final complete package passed 473 assertions in five native fresh/old-save/
reload/rollback runs, with all 18,160 source entries matching. Exact content,
quality, thermal and immersion fields are compared at native pickup/toss/repickup
boundaries. Saved contents/quality persist, with native cooling over elapsed time.
Front/side/rear/close captures were inspected. Evidence:
assets/validation_v5_17_1/water-evidence/SUMMARY.json. One sequential 700-tic pair
for six visible containers observed 1,141.79/1,130.29 presents/s (sprites/models),
p95/p99 1.0919/1.3261ms and 1.1038/1.3150ms; mean simulation spacing was 28.571ms.
The environment and queue-present qualifications below apply. No crowd budget,
normal-menu, drinking/boiling or author acceptance is inferred. Legacy water
rations, maze water and cooking vessels remain. For the six-container author
room, add `--kind water` to the inspection command below; F1-F4 and F6-F8 inspect
the objects, F5 restores player control/HUD.

The same issue now includes small/medium/large medikits, Anima flasks and energy
vials. The medikit remains the accepted leather bag identity, with handle, straps,
medical patch, fittings and bandage; it is not changed into a health bottle.
Anima keeps its blue rounded body, cork, ribbons and star/filigree; energy keeps
the yellow-green vial, leather sling and leaves. Small hardware is warm bronze,
medium silver, and large silver plus gold. Each real class is bound explicitly.
The nine meshes contain 1,324-3,888 triangles and 11-22 closed components each;
outward winding, paired oriented edges and reproducible exports are checked.

Owned editable controls, references and hashes live in
assets/source/art/inventory_models_647/consumables/DESIGN.json and EXPORT.json.
The built-in ImageGen tool generated materials-v1.png from the five owned
references and edited only the requested leather/cork materials into the selected
materials-v2.png. Exact prompts are PROMPT.txt and PROMPT-v2.txt; PROVENANCE.json
retains both original generated outputs and reference hashes. No raster pixels
are edited by the geometry exporter. Native bodies/caps/straps/ornaments are real
geometry, not object silhouettes on planes. Their height follows the existing
opaque reference silhouette; native scale, physics, item effects and icons stay.

`python assets/generators/generate_inventory_consumable_models.py --output build/consumables --install`
exports nine static MD3 files, one shared atlas, explicit bindings and editable
OBJ/MTL geometry with named components. The OBJ files remain in the export folder;
JSON controls and the deterministic generator are maintained sources. Repeat with
`--check --install` to verify installed bytes. Project validation also checks
native containers, nine-class coverage and source/dependency hashes without art tools.
The first native candidate passed 473 assertions in five fresh/old/reload/rollback
runs. Later visual revisions fix an amplified quadrant seam, handle-frame twisting,
floating Anima ornaments and stretched leather UVs. The final complete package
passed all 473 assertions without a model overlay, with 18,152 source entries
matching exactly. Native front/side/rear/close views were inspected. Evidence is
assets/validation_v5_17_1/consumables-evidence/SUMMARY.json; no manual acceptance
or ordinary-menu/healing-use test is inferred. CA-KP-227 records the art checks.

A single 700-tic presentation pair for nine visible consumables observed 1,135.71
presents/s with sprites versus 1,108.42 with models; p95/p99 were
1.0866/1.3089ms versus 1.1201/1.3445ms. Both averaged 28.571ms per simulation tic.
The recorded Win11/Ryzen5950X/RTX3070Ti Vulkan1280x720 environment and qualifications
below also apply: queue-present timing, no repeatability or campaign budget claim.

For the nine-item author room, add `--kind consumables` to run_coin_drops.py's
inspection command below. F1-F4 inspect the room/medikit; F5 restores player
control and the normal HUD; F6/F7 inspect Anima/energy; F8 shows the rear. The
fixture suppresses its HUD only during inspection, not in ordinary gameplay.

The inventory audit also found a pre-existing duplicate CAMDA0 registration for
medium armor and medium Anima in TEXTURES. This slice does not rename saved states
or change that shared sprite registration. New per-class 3D bindings use their
own intended resources; medium armor still needs explicit model coverage.

COINS.json and COINS_EXPORT.json in assets/source/art/inventory_models_647 record
owned source hashes, art geometry and deterministic outputs. Copper, silver and
gold each use a closed bevelled disk (290 vertices, 384 triangles), with outward
winding and 576 paired geometric edges. Both faces reuse the existing 64x64 sun
image unchanged; the edge samples its metal color. Original icons/sprites remain.
The 23-art-pixel radius comes from the opaque silhouette; the 3-pixel thickness
is display geometry. Actor Scale .25, Radius 12, Height 8 and unit mass do not change.

`python assets/generators/generate_inventory_coin_models.py --output build/coins --install`
exports OBJ/MTL/unchanged PNG and explicit MODELDEF bindings for all 15 classes.
Repeat with `--check --install` to verify byte-identical output. Ordinary project
validation checks sources, hashes and binding completeness without Pillow/Blender.
Runtime files live under src/models/caelum/inventory/coins and
src/caelum/data/inventory_coins.modeldef. Existing provenance is in
assets/manifests/sprites_v4.json; no new raster image or external resource is used.

The native read-only catalogue observation inspected 595 Inventory-derived types;
87 have visible spawn states and no native undroppable/untossable flag. That is a
candidate count, not a complete drop catalogue: custom policy and dynamic item
variants still matter. Furniture and camps can restore existing physical bodies.
Legacy rejected mate meshes and inactive support-implement bindings do not count
as current 3D coverage. The rest of #647 remains open.

The candidate-overlay fixture passed 785 assertions in five native runs: original
save, loading that save with the models, fresh candidate, candidate reload, and
rollback to the original runtime. Every denomination uses native pickup, splitting
37 into 30 held plus 7 dropped, then recombining. Captures show volume and retained
faces from above and near the floor. This is not ordinary menu or author acceptance.
The final complete package repeats all 785 assertions without an overlay.
Evidence: assets/validation_v5_17_1/evidence/SUMMARY.json.

One sequential 700-tic comparison at Vulkan 1280x720, uncapped/vsync off, on
Win11 Pro 26200 / Ryzen 9 5950X / 32GB / RTX 3070 Ti observed 950.75 presents/s
for 15 sprites versus 942.38 for 15 models. Presentation p95/p99 were
1.2991/1.5097ms versus 1.2992/1.5176ms; both averaged 28.571ms per simulation tic.
All 15 models are visible in the inspected capture. These queue-present intervals
are not GPU timing/display scanout; this single pair establishes no repeatability
or all-inventory/campaign budget. Tests ran unpaused in the background at 5% audio.
The severe existing siege rendering limitation remains unresolved.

For author inspection after building the current package:
`python assets/validation_v5_17_1/run_coin_drops.py --runtime build/caelum_argenteum_dev.pk3 --output build/coins-author-01 --interactive`.
F1/F2/F3/F4 select top/low/side/close views; F5 returns player control. Use a fresh
output directory, inspect actual drops, and save/reload. No automatic acceptance.

## 5.17.0 - Independent Domingo modules (#458, in progress)

MODULES.json in assets/source/art/character_modules_458 assigns all 73 existing
editable meshes exactly once to seven native slots: clothing, armor, cape, face,
hair, weapon and shield. The authoritative accepted domingo.blend, its skin,
MakeHuman CC0 provenance and original fixed MD3 remain unchanged. No new raster
image or external artwork is introduced. All 24 actions and 375 poses reuse the
existing rig and sampling; combinations are not baked into complete outfits.

`blender -b --python assets/generators/export_character_modules.py -- --output build/modules --install`
requires pinned Blender4.5.3. `--check --install` verifies export and installed
bytes. The exporter compares all 4,008,375 quantized vertex/normal samples, UVs
and 17,447 triangle indices against the accepted model. The seven surfaces total
10,689 vertices and 17,447 triangles. EXPORT.json records inputs/output hashes;
validate_character_modules.py checks source freshness, installed bindings and
native containers during ordinary project validation without requiring Blender.

src/caelum/data/domingo_modules.modeldef replaces only the opt-in pilot's fixed
binding. CaelumDomingoModules exposes named slots and native hide/restore calls.
The fixed source/runtime model remains for recovery and direct comparison.
Hiding armor exposes the old model's incomplete underbody; it is a diagnostic,
not a finished unequipped body. Other faces, hair, garments, equipment and species
still need authored geometry and their own native/visual checks.

The isolated preview compares fixed/modular frames, hides/restores equipment and
checks a saved hair/shield selection. GZDoom4.14.2 resets the tested A_ChangeModel
hide overrides on load: rebuild presentation once from saved authority using a transient
readiness flag. Checking a saved selection integer alone missed this defect;
the corrected fixture also compares rendered captures. Its state is not a new
production character schema. Native evidence, performance and remaining limits
are recorded under assets/validation_v5_17_0; author acceptance remains pending.

The complete-package fixture also runs without a model overlay. For author review:
`python assets/validation_v5_17_0/run_modular_preview.py --runtime build/caelum_argenteum_dev.pk3 --output build/modular-author-01 --interactive`.
Use a fresh output directory for each run. F1/F2 compare fixed/modular, F3 hides
sword/shield, F4 restores all, F5 hides hair/shield, F6 walks and F7 freezes.
This permits focused inspection without installing Blender or changing equipment.

Final package d4aa0aeb27ae9d37deb753f903a84e27937785f2fccb505fc30619283578b0e5
contains18,131 source-identical entries. Repeat Blender export/check and the
complete-runtime visual test pass. Reused native-player checks pass108 assertions
across12 runs: movement/attack, rest, fallback, guard, saved jump, death, hub travel,
old-save loading and rollback to the preceding package. These are fixture checks,
not author acceptance. See evidence/SUMMARY.json for raw hashes and failed attempts.

Recorded presentation requests on Windows11Pro26200, Ryzen95950X/32GB,
RTX3070Ti, GZDoom4.14.2 Vulkan1280x720, uncapped/vsync-off, background5%audio:

| Scene | Mean presents/s | p95 interval ms | p99 interval ms |
| --- | ---: | ---: | ---: |
| Studio,1 fixed figure | 1197.81 | 1.010 | 1.200 |
| Studio,1 modular figure | 1168.09 | 1.053 | 1.258 |
| Studio,64 fixed figures | 964.50 | 1.219 | 1.399 |
| Studio,64 modular figures | 887.89 | 1.311 | 1.478 |
| Mansion opening reference +1 modular figure | 62.51 | 18.342 | 20.132 |
| Sewer reference +1 modular figure | 160.35 | 8.287 | 10.253 |
| City ground view, added figure offscreen | 71.66 | 16.025 | 16.934 |
| Approved siege view +1 modular figure | 1.54 | 775.549 | 800.396 |

Each is one700-tic observation, not a repeatability estimate or GPU/display-scanout
measurement. Studio figures have no combat or collision. Campaign NPCs retain
their existing visuals; the extra figure is diagnostic only. Opening dialogue/HUD
overlays remain, and the ground view leaves the figure outside the camera. The siege retains988 living
attacker NPCs,601 defenders and the player; machines complete the approved attacker
side cap. Severe siege rendering remains unresolved; this is not an all-3D crowd
or completed production-budget acceptance. Native visual comparison captures use
the separately recorded1520x825 inspection window.

## 5.16.5 - Finale condition data (#457)

`python assets/generators/generate_campaign_finale_data.py` derives the eligibility
constants and existing faction identifiers from approved PROGRESSION.json.
`--check` and project validation reject stale generated data. No visual or map
asset is added, and the query is not attached to a narrative scene. Its isolated
two-peer fixture lives in assets/validation_v5_16_5; supplied character progress
must not be presented as normal campaign acquisition or scene acceptance.

## 5.16.4 - Essence coverage sources (#456)

assets/campaign/ESSENCE_POLICY.json retains the approved recovery decision.
ESSENCE_COVERAGE.json joins that contract with PROGRESSION.json and the existing
tarot_78_v4369 manifest, preserving original rank/suit labels as source metadata.
No art, map or gameplay behavior is changed; two diagnostic release labels advance
with the documentation version. Regenerate with
`python assets/generators/build_essence_coverage.py`; `--check` rejects stale
outputs, and `--require-complete` rejects outstanding exact acquisitions. Project
validation checks freshness and approved contracts without claiming completion.

## 5.16.3 - Animated folklore model pilots (#455, unintegrated)

Cuero / Cuero Uñudo (CA-FOLK-053) adds a third unintegrated technical pilot.
Its editable DESIGN.json in assets/source/art/cuero_455 describes a closed,
folded aquatic hide, pale underside, 24 curved marginal claws, dorsal relief and
paired raised eyes. The source's 3m lower diameter sets only the 96-MU preview
width; it does not authorize runtime body size or collision. The owned generator
reuses the Nahuelito MD3 writer and Pombero tube construction. OBJ/MTL and MD3
exports contain 9,536 native vertices, 16,032 triangles, three surfaces and
40 distinct frames (16 idle, 24 swim); motion is geometric deformation only.

Built-in image_gen produced the four-panel material atlas. Original PNG bytes,
the exact PROMPT.json and provenance hashes remain beside the editable design.
Rebuild with `python assets/generators/generate_cuero_model.py --output build/cuero`;
`--check` verifies generated files read-only. The shared binary validator and
native runner accept `--kind cuero`. Nine views include an inverted underside;
F1-F9 select views and F10 animates in optional interactive mode.

Binary bounds/material coverage, all 381,440 coordinate checks, byte-identical
independent generation and native fresh/reload/state advancement pass. Evidence
in assets/validation_v5_16_3/cuero/SUMMARY.json retains four visual iterations,
including early angular claws/rim seams and the subsequent curved claws, tighter
eyelids and underside strip. Studio captures establish technical presentation,
not ordinary lighting, encounter-scale performance or author acceptance. Membrane
folds and silhouette still require art review. No production appearance, actual
swimming/wrapping behavior, combat animation set, encounter or physical body is
activated. The catalogue and provisional Mandinga combat template stay distinct.

Pombero (CA-FOLK-006) adds a second technical visual pilot. Its editable DESIGN.json
in assets/source/art/pombero_455 describes 15 hierarchical parts, sculpted face,
pointed ears, straw hat, shirt/waistcoat, rope belt and bare hands/feet. The owned
generate_pombero_model.py reuses the Nahuelito MD3 writer and exports OBJ/MTL plus
40 native frames (16 idle, 24 walk), 13,115 native vertices, 22,815 triangles and
four surfaces. These are prototype costs, without encounter-scale performance
acceptance. The mesh's 32-MU neutral height uses the source's 1m lower bound only
for preview; no final collision or production actor binding is supplied.

Built-in image_gen produced the eight-panel atlas, its two material revisions,
and a separate reference-led facial diffuse plate. All original PNG outputs,
PROMPT.json/PROMPT-v2.json/PROMPT-v3.json, FACE-PROMPT.json and PROVENANCE.json
remain in the source directory. The face follows a continuous sculpted head
with separate front/rear material ownership; it is not a billboard. The refined
cloth/straw scale retains the original UV grid. Ear rims are curved and recessed;
side hair is moved behind them after native captures exposed intersections.
The existing owned dark material and source concept remain preserved. Rebuild using
`python assets/generators/generate_pombero_model.py --output build/pombero`.
The shared native runner accepts `--kind pombero`; its optional `--interactive`
mode remains a visual inspection fixture. Native fresh/reload, explicit state
advancement, binary bounds/material checks and deterministic regeneration pass;
assets/validation_v5_16_3/pombero-face/SUMMARY.json qualifies the follow-up evidence;
the earlier pombero/SUMMARY.json retains its original model hashes and iterations.
The camera uses explicit zero eye-height and this fixture adds two studio lights;
captures do not establish normal map lighting. The facial surface now better
matches the reference; hair/clothing geometry and seams still need production art
review. The new runner rejects a model-file argument before opening the engine.
This pilot is not final art or author acceptance, and supplies no combat animation
set, ordinary encounters, species physiology or campaign population.

CA-FOLK-055 now has a reference-led real 3D visual pilot: continuous neck/body/tail,
four swept flippers, jaw, eyes, nostrils and dorsal scutes. The editable anatomy
and motion controls are in assets/source/art/nahuelito_455/DESIGN.json;
generate_nahuelito_model.py exports a neutral OBJ/MTL and native MD3. The export
has 5,174 vertices, 9,272 triangles, three material surfaces and 40 frames
(16 idle, 24 swim). It uses procedural articulation; no skeletal armature is
claimed. The source's 12m lower bound sets only the preview's nose-to-tail length.
No collision radius, combat statistics, aquatic AI or encounters are inferred.

The skin is an unchanged built-in image_gen output. PROMPT.json retains the exact
prompt; PROVENANCE.json identifies the approved reference and original owned
brass/dark materials reused for iris and mouth detail. Original concept pixels
are untouched. Exported artifacts live in assets/bestiary/models/nahuelito;
AUTHORING/CATALOGUE identify this as an unintegrated visual pilot, with no engine
campaign identity and no author acceptance. No production actor/model is replaced.

Rebuild with `python assets/generators/generate_nahuelito_model.py --output build/nahuelito`;
`--check` compares all generated files read-only. The visual fixture and binary
validator live in assets/validation_v5_16_3. SUMMARY.json retains native captures,
failed fixture attempts and exact hashes. Native single-instance animation and
save/reload pass; binary/material/frame coverage and deterministic regeneration
pass. These checks do not establish ordinary aquatic gameplay, encounter-scale
performance, uniqueness across campaign maps, or final visual acceptance.
CA455-VIS-01 requests that separate Nahuelito author review. The other 55 references remain
without new models; #455 is unfinished.

The complete 5.16.3 project audit and package build pass. The final package's
isolated native run also confirms one subject before/after load and explicit
CurState advancement during swimming; evidence is in native-release. No gameplay
or encounter-scale performance acceptance is inferred from this visual test.

The author subsequently approved provisional Mandinga statistics and the current
Mandinga attacks, hostility and available-potion loot for new folklore creatures.
BEHAVIOR.json now generates 56 unplaced classes in CaelumBestiaryCombat.zs,
excluding the existing Mandinga and Zupay references. Repeatable Ucumar is distinct
from Rulo. Source names, taxonomy and population categories remain available;
LANGUAGE contains generated ES/EN names, preserving folklore proper names.
`python assets/generators/generate_bestiary_actors.py` rebuilds the classes/names;
then run `python build_dialogue_index.py build`. Both generators support checks,
and project validation rejects stale outputs. The source catalogue remains the
identity authority, with only translated descriptive names in BEHAVIOR.json.

The classes inherit Mandinga sprites, collision and armor/thermal/altitude adapter
as development placeholders. They do not integrate either pilot mesh, authorize
species-specific physiology or add playable races. No encounters or campaign
unique-instance ownership are supplied. Native evidence for profiles, actions and
finite inventory is kept separately from the visual pilot under
assets/validation_v5_16_3/combat; neither constitutes author visual acceptance.

## 5.16.2 - Approved map references and preserved sewer sources (#454)

The perception follow-up changes only CaelumVisualPerception.zs in the packaged
runtime; all geometry, models and other packaged entries match the preceding
integrated build. barracas-perception retains owned diagnostic overlays, raw
native logs, Vulkan queue-present traces and the isolated visibility fixtures.
Development packages, saves, engine binaries and the private IWAD stay local.

The existing Knight source reuses the quay's authored quarter-turn/translation:
CaelumArcanaPlacement resolves the original(0,640,14) to(-896,15488,14) only in
revision4 Barracas. It introduces no card art, new reward or new coordinate
authority. The original location remains the legacy source and migration input.
Native placement/capture evidence: barracas-arcana/SUMMARY.json.

The reviewed city is installed by `generate_barracas_map.py --output <build/path>`
followed by `install_barracas_map.py --compiled <build/path>`. The latter retains
the owned pre-Justice geometry in barracas_redesign/BASE_MAP03.wad, packages the
tested facade class/model/bindings, and delegates arena assembly to the existing
Justice generator. INSTALLATION.json records canonical-LF text-input hashes and
exact installed-asset hashes, preserving the tested model bytes across checkout.
Project
validation checks them and the three binding includes read-only. LAYOUT.json
owns activation. Installation also regenerates cartography and tactical-entry
catalogues, retaining identities and exact legacy geometry recognition. Repeated
full compilation and installation preserve identical
map/facade bytes; the final map matches the previously native-tested candidate.
All160 CAH maps retain their bytes. The source WAD and generated facade OBJ are
owned resources; engine binaries, IWADs, runtime packages and saves stay local.
Native installed/legacy checks are in barracas-integration/SUMMARY.json; separate
presentation traces retain severe siege stalls and do not imply author acceptance.

`generate_barracas_justice.py --candidate <preview.pk3> --output <build/path>
--register` appends the existing ARENA.json room without changing the input
TEXTMAP prefix or any production map. Optional registration writes candidate
geometry into the single assets/tarot_justice/MAPS.json manifest and regenerates
its runtime index. Two outputs repeat byte-identically. The candidate room is
sector391, centre(2560,20672,0), checksum f552012c9d4d7a2ba59d0809894ad272;
original MAP03 retains its checksum-qualified sector767. Source, native and
compatibility evidence: barracas-justice/SUMMARY.json.

MARCH.json derives six infantry approaches and12 southern gun-crew starts from
FRONTS/SOUTH/CITY and the retained operator offsets. RETREAT.json derives three
64-MU ground flow fields from assembled geometry to the southern exits:257109
connected cells per field;22 other ground cells require separate interpretation.
These fields are not a claim of complete multilayer connectivity. Elevated
withdrawal reverses the existing36 artillery routes. Both generators are
deterministic; generated string-return switches are split into64-row functions
to fit GZDoom registers. Navigation evidence is in barracas-navigation/SUMMARY.json.
Revision4 adds three-digit hexadecimal ground distances with an explicit
unreachable sentinel, retaining the original row-first direction fields. The
native helper decodes and caches costs by current/target cell. An independent
audit checks771327 reachable costs and257106 nearest-exit basin edges; native
save inspection also checks identity, original assault lane, selected exit and
decoded caches. Generated source/generator LF attributes keep byte checks stable.
See barracas-withdrawal/SUMMARY.json; no map/art asset changes accompany this fix.

FRONTS.json and CaelumBarracasFrontData derive six machine slots/three fronts
from the approved layout and original SOUTH/CITY/LAYOUT distances. The generator
records source hashes, gate materials, initial/reserve positions and complete
side approaches. No external art, machine profile or combat value is introduced.
Native deployment and physical-route evidence: barracas-fronts/SUMMARY.json.

The reference branch's ancestry and original PDF/PNGs are preserved under
assets/references/issue_454_maps_20261112. MAP01 owns their implementation
interpretation. Revision 6 reuses existing owned sewer/stone/water/bar textures;
it adds no third-party art or new creature models. LAYOUT.json is the editable
geometry source; BASE_MAP02.wad is its generated pre-Justice output. The normal
map generator reapplies the existing Justice arena from that explicit current
source without changing the immutable historical Justice archive.

assets/map02_maze/legacy_5161 preserves the exact previous WAD, layout, manifest,
helper and generator with source hashes. These are rollback evidence, not current
generation inputs except for the retained content identities and compatibility
helper. Do not regenerate or normalize those archived bytes.

assets/validation_v5_16_2 contains the reproducible isolated probes, static
audits, original/new chamber captures, full native logs and Vulkan presentation
traces. RESULTS.json separates agent evidence from CA454-MAP02-01 acceptance;
no engine, IWAD, disposable fixture package or save is distributed.

The intermediate Barracas source uses the same reference board and owned city
materials. generate_barracas_preview.py writes only an isolated build/ map/package;
generate_barracas_facades.py creates real geometric window frames, closed shutters
and cornices using existing CVCI01/CVCI05 textures. No raster is edited and no
bestiary model completion is implied. Preview evidence is under
validation_v5_16_2/barracas-preview. legacy_5162 preserves original MAP03 bytes and
a deterministic ZIP of relevant data/generator/helper sources before redesign.
RUNTIME.json/CaelumBarracasData are deterministic exterior-coordinate outputs of
generate_barracas_data.py. Private CAH coordinates retain their original source.
The city compatibility mode packages legacy_5162/MAP03.wad after verifying its
provenance checksum. barracas-legacy/ holds native continuation logs; all 160 CAH
map bytes match baseline. Loaded-map checksum selects the original Justice arena.
The isolated native service/rotated-leaf fixture and results live under
validation_v5_16_2/run_barracas_services.py and barracas-services/. Its subsequent
barracas-gates/ evidence adds full-perimeter closure and physical native gate
checks, preserving failed fixtures and final closed/open views. Existing gate
materials and dimensions are reused; no new raster, mass or resistance is added.
generate_barracas_map.py assembles a candidate only under build/, using the
reviewed shell, original transformed quay, existing workshops and low residential
sky policy. barracas-candidate/ preserves its native service/private-house proof
and qualified fixtures; no preview package or save is distributed.
generate_barracas_siege.py derives SIEGE.json from the approved layout and
retained city/siege profiles; it supplies 36 posts, existing tower geometry,
access flights and 528 guard positions. The candidate generator reuses owned
stone materials. Native geometry/crew evidence and failed iterations are in
validation_v5_16_2/barracas-forts; this does not activate the production siege.
generate_barracas_routes.py reuses the same in-memory candidate geometry to emit
DEPLOYMENT.json/CaelumBarracasDeployment: 600 routes and 9453 waypoints, with stable
resident identities and original private coordinates. Generated siege/route
helpers dispatch by loaded geometry. Native continuous traversal evidence is in
validation_v5_16_2/barracas-deployment; no fixture PK3 or save is distributed.
The candidate also opens exterior gate forecourts and fills missing ground for
the approved side fronts using existing walkway/artillery dimensions. Inner
gate throats/blockers retain their original dimensions. Physical ram-turn/contact
and gate evidence lives in validation_v5_16_2/barracas-rams; no new art is claimed.
generate_barracas_ram_crews.py derives RAM_CREWS.json and the shared runtime
post table from retained machine constants and accepted body bounds. It changes
positions, not combat profiles, counts or models. Native physical/live-crew
evidence and failed iterations are in validation_v5_16_2/barracas-ram-crews.
Qualified long-route, commander, capture, full-controller refill and shop evidence
now lives in validation_v5_16_2/barracas-continuation; house Used/rendered-ACK
round trips are in barracas-house-use. Native saves and PK3s remain local. The
read-only deployment-save auditor records600 retained identities and completion
flags without copying a binary save into the repository. Its early-checkpoint
replay now passes, alongside native Use at96 factory stations and four vehicles;
the access fixtures reuse the existing factory catalogue and live boarding parts.
No new art or production map bytes belong to this slice.

## 5.16.1 - Recovered folklore reference catalogue (#453, catalogue approved)

The author supplied six ZIP attachments in issue #453 on 2026-11-12. All 58 PNGs
are preserved byte-for-byte under [the original source directory](../assets/source/bestiary_453).
The original catalogue, CSV, visual index, notes and checksum list remain intact.
[PROVENANCE.json](../assets/bestiary/PROVENANCE.json) records attachment URLs,
archive hashes, original filenames and the reconstruction limits. The original
October 20 ZIP index/prompts and verified campaign-region assignments were not
recovered; the supplied catalogue was reconstructed by its author. No provenance
claim is upgraded to recovery of the missing original material.

The canonical authoring view is [CATALOGUE.json](../assets/bestiary/CATALOGUE.json),
generated from the immutable source plus [AUTHORING.json](../assets/bestiary/AUTHORING.json).
Stable CA-FOLK-001..058 keys are package identities, not new engine IDs. Categories:
2 Human, 3 Beast Man, 21 Duende/Demon, 16 Apparition and 16 Magical Beast references.
Caelith remains an existing category with no added reference in this set. There
are 33 unique identities, 24 repeatable references (four described as uncommon)
and the limited Shoort group. No numerical spawn cap is inferred for that group.
Lobizon/Uturunco/Ucumar remain Beast Men; Rulo remains the named Ucumar NPC.
Mandinga and Zupay keep the source's current-game-size qualification and existing
runtime behavior. A unique Zupay identity does not authorize deleting accepted
Chapter I encounters or moving his Chapter II death into the opening campaign.

Approximate size wording and explicit axes remain intact. A source range without
a recovered axis is not silently converted into height, collision dimensions or
runtime scaling. The author approved all 58 campaign-region assignments on 2026-11-12.
AUTHORING.json now owns those decisions; CATALOGUE.json includes every region.
[REGION_PROPOSAL.json](../assets/bestiary/REGION_PROPOSAL.json) preserves the reviewed
table. These are creative campaign placements, not recovered folklore geography
or an approved spawn/encounter table.

The author prefers actual 3D models where feasible. These PNGs define anatomy,
silhouette, materials and identity. The Teju Jagua reference has seven canine
heads, replacing the earlier reptilian-head proposal. Existing OBJ/MD3 support
provides an engine path, but this import contains no meshes, rigs, animations or
new runtime actors. Production must retain editable model/material sources,
appropriate animation, native bindings and separate visual/engine evidence;
a reference image on a plane is not a completed 3D creature. #455/#461 own the
functional creature/art handoff; races are not automatically made playable.

Rebuild with `python assets/generators/build_bestiary_catalogue.py`; `--check`
verifies freshness and all original checksums read-only. `--require-regions`
now passes for all 58 approved entries. Normal project validation checks
integrity; catalogue completion does not claim integrated creatures or models.
Static evidence is in assets/validation_v5_16_1; native gameplay and author model
acceptance do not apply to this source-only delivery.

### Approved regional allocation

The author approved the following rows on 2026-11-12. Unique entries crossing regions represent
one travelling identity, never one copy per region. Existing MAP01/MAP02/MAP03
roles remain protected. These regional assignments do not create new missions.

| Stable key | Reference | Approved campaign regions |
| --- | --- | --- |
| CA-FOLK-001 | Brujas y brujos | Buenos Aires, Pampa, Litoral, Cuyo, Northwest Argentina, Chaco, Selva, Patagonia |
| CA-FOLK-002 | Brujas y brujos de la Salamanca | Northwest Argentina, Supernatural domains |
| CA-FOLK-003 | Lobizón / Luisón | Pampa, Litoral |
| CA-FOLK-004 | Runa Uturunco / Uturunco | Litoral, Selva |
| CA-FOLK-005 | Ucumar / Ucumarí | Northwest Argentina |
| CA-FOLK-006 | Pombero | Litoral, Selva |
| CA-FOLK-007 | Yasí Yateré / Jasy Jaterê | Litoral |
| CA-FOLK-008 | Curupí / Kurupí | Selva |
| CA-FOLK-009 | Mikilo | Northwest Argentina |
| CA-FOLK-010 | Coquena | Northwest Argentina |
| CA-FOLK-011 | Yastay / Llastay | Cuyo, Northwest Argentina |
| CA-FOLK-012 | Sachayoj | Chaco |
| CA-FOLK-013 | Caá Porá | Selva |
| CA-FOLK-014 | Caá Yarí | Selva |
| CA-FOLK-015 | Zapam Zucum | Cuyo |
| CA-FOLK-016 | Pericana | Cuyo |
| CA-FOLK-017 | Solapa | Pampa |
| CA-FOLK-018 | Mandinga | Buenos Aires, Supernatural domains |
| CA-FOLK-019 | Zupay / Supay | Buenos Aires, Northwest Argentina, Supernatural domains |
| CA-FOLK-020 | Nóshtex / Nosjthej | Chaco |
| CA-FOLK-021 | Xalpen | Patagonia |
| CA-FOLK-022 | Shoort | Patagonia |
| CA-FOLK-023 | Tanu | Patagonia |
| CA-FOLK-024 | Halaháches / Kótaix | Patagonia |
| CA-FOLK-025 | Matan | Patagonia |
| CA-FOLK-026 | Ulen | Patagonia |
| CA-FOLK-027 | Luz Mala | Pampa, Cuyo, Patagonia |
| CA-FOLK-028 | Umita | Northwest Argentina |
| CA-FOLK-029 | Mulánima / Almamula | Northwest Argentina |
| CA-FOLK-030 | Chancho de Lata | Pampa, Litoral |
| CA-FOLK-031 | La Viuda | Buenos Aires, Pampa, Litoral, Cuyo |
| CA-FOLK-032 | La Llorona | Buenos Aires, Litoral |
| CA-FOLK-033 | Futre | Cuyo |
| CA-FOLK-034 | Anchimallén | Patagonia |
| CA-FOLK-035 | Chonchón / Tué Tué | Patagonia |
| CA-FOLK-036 | Gualicho | Patagonia |
| CA-FOLK-037 | Pampayoj | Pampa |
| CA-FOLK-038 | Mayu Maman | Northwest Argentina |
| CA-FOLK-039 | Orko Maman | Northwest Argentina |
| CA-FOLK-040 | Uritu Orko | Northwest Argentina |
| CA-FOLK-041 | Nowet | Chaco |
| CA-FOLK-042 | Máip | Patagonia |
| CA-FOLK-043 | Familiar | Northwest Argentina |
| CA-FOLK-044 | Basilisco criollo | Pampa, Litoral |
| CA-FOLK-045 | Cachirú / Cachurú | Northwest Argentina |
| CA-FOLK-046 | Kakuy / Cacuy | Northwest Argentina |
| CA-FOLK-047 | Tejú Jaguá / Teyú Yaguá | Selva |
| CA-FOLK-048 | Mbói Tu’ĩ | Litoral |
| CA-FOLK-049 | Moñái | Selva |
| CA-FOLK-050 | Ao Ao | Selva |
| CA-FOLK-051 | Mbói Tatá | Litoral, Selva |
| CA-FOLK-052 | Mbói Yaguá | Litoral, Selva |
| CA-FOLK-053 | Cuero / Cuero Uñudo | Patagonia |
| CA-FOLK-054 | Peuchén / Piuchén | Patagonia |
| CA-FOLK-055 | Nahuelito | Patagonia |
| CA-FOLK-056 | Huayrapuca | Northwest Argentina |
| CA-FOLK-057 | Kasogonaga | Chaco |
| CA-FOLK-058 | Kélenken | Patagonia |

## 5.15.4 / #451 - Consequence evidence and author launcher

No new art, audio or map asset is introduced. ES/EN occupation, recovery,
transport and Journal text use the existing owned presentation. Native evidence
and the shared author-scene launcher live in assets/validation_v5_15_4, with
issue-specific scene choices and results kept separate. Isolated profiles,
temporary fixture packages, saves, engine and development IWAD remain private
under build/ and are not distributable game assets. The five V5.15 author checks
passed by explicit confirmation on2026-11-10; HISTORY preserves their original
IDs/versions and TASKS records the remaining laboratory contamination limitation.


## 5.15.3 / #450 - Derived tactical route data

`generate_battle_routes.py` deterministically derives entry regions from the
existing `assets/map06_port/CITY.json`; it adds no map or visual asset. Route
markers reuse the owned action icon and known-only cartography presentation.
Guard dialogue source edits are in `src/dialogues/npc/guards.usdf`; runtime and
localization indexes are regenerated. ES/EN reporting text has no new voice asset.
Native fixtures, scripts and evidence are in assets/validation_v5_15_3. Private
packages/saves, engine and development IWAD are not distributed game assets.


## 5.15.2 / #449 - Owned barricade and machine data

assets/generators/machine_work.json records the approved catalogue and timings.
generate_machine_runtime.py deterministically emits CaelumMachineMaterials.zs,
the ca_barricade.obj model and its owned MODELDEF block. The panel reuses the
project's existing owned wood/iron station textures and Mesh/add_box generator;
no external art or Doom assets are introduced. Its dimensions and timber volume
derive from the approved recipe. Existing cannon/ram visuals remain unchanged.
Ram repair masses reuse component_volumes from the original ram physics generator;
the refactor preserves its original volume calculation and physical model values.
Source fixtures and validation records live in assets/validation_v5_15_2; generated
PK3s, private engine/IWAD, test maps and saves remain untracked under build.


## 5.15.1 / #448 - Command UI and validation sources

The ES/EN panel reuses the owned live-menu presentation, pointer and keyboard
controls. Existing guard sprites, military formations, city routes and cannon
crew routes retain provenance. No art, audio or map geometry is added.
assets/validation_v5_15_1 contains the separate command fixture and thin runner
over #447's native save/peer harness and #435 sync instrumentation. Private
engine/IWAD/fixture/save outputs remain under build/v515/issue448. The original
#447 package/save and intermediate schema1 save are retained for migration.

## 5.15.0 / #447 - Director validation sources

No new art, audio or campaign geometry is introduced. The existing Barracas
actors, machines, models and formation positions keep their provenance.
assets/validation_v5_15_0 contains deterministic private-room fixture sources
and focused native runners, reusing the #435 sync instrumentation and #431
campaign observer. Generated WAD/PK3 files, development IWADs, native executables
and local saves are not distributed; outputs stay in build/v515/issue447.
The original V5.14 package/save remain available for migration and rollback.

## V5.14 card services (#443–446)

The four patches reuse existing Tarot art, fonts and native menu presentation.
Validation generators create local-only fixtures under build/; no development
IWAD, executable or generated test map is distributed. No new asset attribution
or replacement is introduced.

## Human Palomo HUD evidence (#617 follow-up)

assets/validation_v5_13_11/air-status.png records the corrected native full-Air
label. The patch reuses all art and does not change the Palomo model or sprites.

## Final V5.13 manual scenes (#596)

The final author launcher reuses the packaged artwork without replacements.
Native captures in validation_v5_13_9/final document prepared scenes and model
visibility. The author still owns visual acceptance; automated preparation is
not recorded as physical-input approval.

## Distributed hunt opportunities (#616)

assets/hunt/ARCANA.json owns the 22 locations and reuse basis. The deterministic
hunt_arcana_geometry.py extension retains the original maze materials and adds
ordinary eight-metre chambers, with a twelve-metre Wheel footprint including its
outer bypass. Native water uses existing CAPOOL01. Props reuse the automaton,
espinillo, rocks, canopy bed, cannon, spirits, doorways and Tarot art; no new raster
art or third-party source is introduced. hunt_arcana.modeldef explicitly maps
the derived bed/fragile-rock classes to those unchanged owned meshes.
assets/hunt/legacy_51311 preserves the original map/navigation and provenance.
Native visual and functional evidence is in assets/validation_v5_13_12.

## Human Palomo presentation (#617)

Player Palomo reuses the original owned PAID/PAWK frames, scale and native body.
No new texture, sprite or model is generated. The same two-frame walk is driven
by actual player velocity. All six #614 power-up models remain unchanged.

## Labyrinth power-up models (#614)

The author explicitly requested translucent 3D spheres: silver common, gold rare,
with six distinct central emblems (table/cup, cartridges/crystal, sword/shield,
armor, bed/pillow, anvil/star). Original meshes are deterministically generated
by assets/generators/generate_powerups.py from assets/powerups/DATA.json.
The generator reuses owned mate metal swatches and the automaton's painted iron
ramp unchanged; it does not edit raster sources or distribute third-party art.
Placements, provenance and SHA-256 values are in assets/powerups/GENERATED.json.
Native screenshots and functional evidence are in validation_v5_13_10; final
visual approval belongs to the author's consolidated V5.13 check.

## Author-suite scene preparation (#596)

The isolated fixtures reuse existing owned assets and private native captures;
no new artwork is packaged. The prologue overlay seen in the first annex capture
was suppressed only in the test fixture before the final startup sweep.

## Cooperative hunt maze (#601)

assets/hunt/LAYOUT.json and generate_hunt.py deterministically create CAHUNT,
its navigation index and placement manifest. It reuses owned sewer textures,
Tarot card art, trap sprites and Palomo's sprites without raster modification.
The appended Justice room uses the existing approved geometry. No campaign map
or archived legacy geometry is changed. This map is an authored game labyrinth,
not a historical site. Generated output and repeatability are checked separately
from native appearance and author acceptance.

Standalone resident presets (#597) reuse the four existing residents' owned
sprite banks and scale for idle, walking, crouching, attacks, rest and death.
No new artwork, external resource or change to the campaign residents is added.
Visual verification remains separate from native profile/equipment assertions.

Star furniture volumes reuse the owned furniture envelopes and placed chair
layouts. `generate_star_geometry.py` deterministically derives the missing
basic-chair/cot/wardrobe/cupboard volume adapters from their existing DATA.json
dimensions; it does not alter art, masses or recipes. Other envelopes read the
existing runtime dimensions directly. No new exterior sizes are inferred.

Sun rocks reuse the unchanged owned `models/caelum/world/hazards/ca_hazard_boulder.obj`
through `CaelumHazardRockVisual`, at radius19.2MU (nominal diameter1.2m).
No raster/model source is added. The separate visual follows the persistent
body and hides during containment. Annex apparatus revision6 places hot and
contaminating examples clear of the display entrance. Native checks/screenshot are recorded
in sun-heat-results.json and sun-pollution-results.json; this is not author visual acceptance.
The inventory carrier reuses the existing Magic Box icon and the ordinary
inventory layout; no raster asset is generated. The native Spanish capture
was reviewed for row width and release-hint clearance.

The demonstration spirit reuses the unchanged V9G0 guard sprite and native
body scale. No new art or third-party resource is introduced. Its bilingual
native conversation capture is recorded in spirit-results.json.

## Moon clone appearance reuse (#440, 5.13.3)

Moon illusions reuse the existing owned player body/head appearance registry and
firearm poses. Each native body keeps a separate profile copy; no generated art,
new third-party material or rendering substitution is introduced. Native screenshots
and code checks are recorded in validation_v5_13_3/moon-results.json; final author
review remains part of the complete V5.13 suite.

## Tarot example annex geometry (#440, 5.13.3)

`assets/tarot_examples/ROOM.json` owns the implementation layout. The annex
reuses original mansion stone/pool textures (CMST01/CMST02/CAPOOL01), adding no
external assets or narrative. `tarot_example_geometry.py` appends it after
Justice through the existing deterministic map generator. The previous mansion
bytes remain in `pre_examples_MAP01.wad`, with SHA-256/provenance in BASELINE.json.
GEOMETRY.json records the appended indices/counts. APPARATUS.json and
generate_tarot_examples.py own the generated runtime placements. Portals reuse
the owned pressure-trap floor visual. The false-wall leaf now reuses CMST01
unchanged through a 64x128 TEXTURES alias at the existing door scale; no new
raster source or external attribution is introduced. All four annex leaves
face their doorways at90 degrees; native collision/sliding axes stay unchanged.
Front/rear native images and save migration are recorded in
assets/validation_v5_13_3/example-wall-art-results.json. Author review is pending.
The living-obstacle example reuses the existing CAVT O espinillo artwork and
physical profile unchanged; APPARATUS.json records its clear display-room location.

## Tarot automaton model (#440, 5.13.3)

The author explicitly requested a Zupay-sized 3D automaton with heavy armor,
tower shield and mace. `assets/source/art/tarot_automaton/DESIGN.json` and the
neutral modular OBJ are editable art sources. The deterministic generator
`assets/generators/generate_tarot_automaton.py` produces20 MD3 frames: inactive,
idle, eight walking, six attack, guard and three fallen poses. Its93.333333-MU
height follows the existing Zupay; visual geometry does not recalculate the
approved1,000kg body or96kg equipment. The model has3,232 triangles/7,816 vertices
in four material batches; individual joints do not become separate draw calls.
`CaelumAutomatonModelBody` is a noninteracting visual body. The persistent
`CaelumTarotAutomaton` now drives it from actual displacement and the shared
melee cycle, without editing the accepted source mesh or materials.

The iron uses a new opaque built-in image_gen painted value ramp, copied without
raster editing from the retained source. Neutral-pose face UVs select its values
so flat native sector lighting still shows the plates. `PROMPT.json` records the
complete prompt, tool mode and original output. Brass, wood and dark joints reuse
unchanged owned station/stash textures. No third-party or development-IWAD art is
introduced. `manifest.json` records source/material/output hashes. `--check` is
read-only; the binary validator also checks MD3 offsets, triangles and planted
legs during stationary attacks/guard. Native captures verify front/rear, walking,
attack, guard and fallen poses; common-save recovery preserves the visual body.
Evidence is in `assets/validation_v5_13_3/automaton-art-results.json`.
Author review and frame-presentation measurements remain pending.

## Justice arena geometry (#440, 5.13.3)

The24x24m room appended to every packaged map reuses owned CMST01 wall/ceiling
and CMST02 floor materials. No external or Doom texture is introduced. Its
160-unit headroom and light176 follow the existing arena envelope. Sources and
exact pre-arena map archive: assets/tarot_justice; deterministic generator:
assets/generators/generate_tarot_justice.py. The room is isolated from existing
campaign geometry; it adds no public entrance, narrative or reward. Its runtime
Tarot entry/return now has separate runtime evidence in HISTORY.

## Tarot Empress roots (#440, 5.13.3)

`assets/generators/generate_tarot_roots.py` builds five thorned stems around a
normalized target body, using the existing environment mesh helper and unchanged
owned plains-bark texture. The model starts at the victim's floor and scales to
its actual radius and height; geometry has no independent damage or collision.
It contains840 faces/3,210 vertices and no new raster or external artwork.
`assets/source/art/tarot_roots/manifest.json` records provenance and hashes;
the generator's `--check` verifies deterministic output. Native front/rear views
show the production effect around a player in two-client play. Evidence:
`assets/validation_v5_13_3/empress-art-results.json`. Author review remains pending.

## Tarot Chariot adaptation (#440, 5.13.3)

The author approved reuse of the original covered cart at2m width on2026-11-01.
`assets/generators/derive_tarot_chariot.py` uniformly scales that owned OBJ,
centers its horizontal bounds and aligns its lowest vertex with the ground.
Topology, normals, UVs and the original station/stash material references remain.
No raster image, third-party source or development-IWAD asset is added.
The source/output hashes, dimensions and provenance are recorded in
`assets/source/art/tarot_chariot/manifest.json`; `--check` verifies deterministic
outputs. The normal travel vehicle remains unchanged. Native front/rear captures
show the actual production actor with its model registration; see
`assets/validation_v5_13_3/chariot-art-results.json`. Final author review is pending.

## Equipment awakening panel (#442, 5.13.2)

The inventory association panel reuses the owned Tarot front references already
packaged for #441. Native menu controls and ES/EN text are code/UI changes; no
new image, model, third-party asset or attribution change is introduced.

## Tarot capture fronts (#441, 5.13.1)

The deterministic `assets/generators/tarot_world_fronts.py` registers the 75
additional world-front aliases and actor states from the owned #15 catalogue.
It does not alter any image pixels, palette, dimensions or provenance. Existing
Fool/Ace/Knight aliases and saved state offsets are retained. Generated outputs
are packaged under caelum/data and caelum/quests; all actual front PNGs remain
those recorded in assets/manifests/tarot_78_v4369.json.

## Native diagnostics and local presentation (#435, 5.12.7)

No new game artwork or audio. Multiplayer snapshots reuse the existing viewer
without creating local simulation actors. The optional diagnostic engine keeps
its official source provenance and the upstream ZWidget timer patch in
validation_v5_12_7/engine-timer-results.json; engine binaries, DLLs and development
IWADs remain local and are not distributed as project assets. The presentation
layer source and bounded evidence are tooling, not packaged runtime content.

## Profile graph tooling (#434, 5.12.6)

No artwork changes. The offline schema reader inspects the installed, version-
pinned engine PK3 and built project PK3; neither engine nor development IWAD is
redistributed. Disposable native saves/maps remain under build. Boundary data is
assets/profiles/personal-boundary.json; retained evidence is validation_v5_12_6.

## 5.12.5 - Card-table PvP reuses accepted artwork (#590)

No new graphics are generated. Both human card screens reuse the existing Tarot
fronts/back, fonts and table/chair assets with their existing provenance.
Native probe source/evidence: assets/validation_v5_12_5. Disposable generated
maps and test PK3s stay in build; no development IWAD or executable is distributed.
## Organized combat venues (#438, 5.12.4)

assets/arenas/VENUES.json is the geometry source; generate_arenas.py builds CARING
and CASEWER deterministically using the existing owned city/sewer materials.
The ring is 12 x 12 m. The connected maze occupies 64 x 64 m, including its outer
passage, with corridors at least 2 m wide. Both have eight native player starts.
Ceiling/light references reuse current city interiors. The Buenos Aires organizer
reuses the existing DOID Domingo sprite and the established civilian dimensions;
no newly generated face, equipment, voice or secret identity is introduced.
Original decorative corner posts and three rope courses reuse owned wood and
cloth textures. They introduce no collision, item, mass or balance rule. The
generator produces stable LF text and original WAD geometry. Native checks cover
all eight authored starts; author visual acceptance remains pending.

## 5.12.3 - Cooperative lifecycle guards (#437)

This implementation slice changes no artwork, audio or map geometry. Existing
native death presentation remains. The implemented spirit/journey behavior
reuses the accepted presentation; no new visual asset is claimed.


## 5.12.2 - Cooperative time interface (#436)

Reuse existing fonts, menu rendering and furniture art. Add bilingual consent,
duration and cancellation text; no new bitmap/model/audio assets. Diagnostic
map fixtures use the installed development IWAD only and are not packaged or
distributed as production content. Native evidence belongs to validation_v5_12_2.


## V5.12 native network fixture (#435, preparation)

The deterministic disposable square-map generator and network probe live in
assets/validation_v5_12_1; outputs stay under build. The probe uses only the
locally installed development IWAD for test textures and distributes no IWAD,
engine executable or generated fixture. No production art/audio changes.

## 5.11.8 - Species damage policy (#586)

Reuse accepted Mandinga, Zupay and rat artwork unchanged. The native diagnostic
room and test configuration remain under assets/build, outside runtime assets.
The author accepted the final scenarios on 2026-10-30; acceptance changes no
artwork, provenance or runtime resources. See HISTORY for per-issue records.

Companion speed verification reuses the accepted prisoner sprites and profiles;
no visual assets or production balance change (#430,2026-10-30).

## Arrival household placement (5.11.7, #581)

assets/map06_port/ARRIVAL_HOUSEHOLD.json supplies the four classes, original positions, house69 offsets and facing. assets/generators/generate_arrival_household.py deterministically writes CaelumArrivalHouseholdData.zs. Existing models are reused unchanged. The workbench/Chemistry/barrel use the north living-room wall, clear of the dining set; the cot uses the bedroom south of its existing bed. Native fit checks preserve paths and defer occupied placements.

The #430 movement correction reuses existing resident/prisoner walking
frames. Passive CompanionWalk/CompanionIdle labels are appended to preserve
existing state indices. No new artwork or changed asset provenance.

### Companion delivery (5.11.4, #430)

The subcaptain reuses the owned Domingo body/frames and the existing guard
equipment catalogue; the four residents and prisoner appearances are unchanged.
The party panel reuses the shared journal/menu presentation and bilingual text.
No new raster art, external assets or attribution changes are introduced.

## 5.11.0 / #431 - Profiling provenance

No art, audio or packaged runtime asset changes in this patch. Native campaign
comparisons reuse the immutable accepted 5.10.3 PK3 and owned campaign maps.
Diagnostic overlays and fixtures are generated by assets/validation_v5_11_0;
raw local captures remain in build/issue431. The standalone PresentMon 2.6.0
binary comes from GameTechDev/PresentMon's official GitHub release; its SHA256
and source URL are pinned in capture_presentation.ps1. It is a local diagnostic
dependency in build, not a distributed game asset or installed service.

## 5.9.7 / #423 - Port wardrobes

The approved scope is guards and the four rescued prisoners. Guards reuse four
human face/hair variants from the existing modular catalog. OpenAI native image
generation supplied headless navy jackets/gray trousers, caps, firearm, sword,
walking, pain/fall/death and crouch paintings from owned pose/equipment references.
Technical cutting and registration produce 160 shared body/cap modules and 544
native TEXTURES compositions (four faces, seventeen poses, eight views), without
extra head actors or a Cartesian collection of full character PNGs.

Prisoners use 632 finite cloth-palette variants of their existing pose files;
original files stay intact. Alpha, protected head envelopes, body silhouettes,
skin/fur and unselected pixels remain unchanged by the masks. Neutral umber,
slate, ochre and olive clothing choices add no insignia or faction knowledge.
Actual weapons/equipment and the twenty-five #387 inventory garments are
unchanged; worn player equipment/3D presentation remains deferred to V5.17.

Sources, exact prompts, rejected candidates, palettes, crops and output hashes:
assets/source/art/port_597. Deterministic processors:
assets/generators/generate_port_wardrobes.py and
generate_port_prisoner_wardrobes.py. The latter follows the legacy prisoner
processor if that catalog is regenerated. Native review/evidence is under
assets/validation_597. CA423-01 (origin 5.9.7 / #423) passed author visual and
city-traversal review on 2026-10-30. This does not assert measured monitor FPS.

## 5.8.56 / #416 - Original Ciudad theme for Buenos Aires

The author selected the original **Ciudad**, retained since the first music collection, for CABAIRES. The complete 188.8-second stereo master is encoded as `music/CA_MUS_CIUDAD.ogg` with Vorbis quality 6, no filters, trimming or normalization. Two encodes produced identical bytes and full decode preserved duration. Credits retain Damián Curti/Suno and the original embedded ID. `Campo de Buenos Aires` retains its countryside assignment. See `assets/validation_5856/PROVENANCE.json`; native playback and author listening are tracked separately.


## 5.8.54 furniture corrections (#410)

`furniture_bedding.py` adds deterministic bevelled mattresses/pillows using the owned cotton texture. Original bed models gain visible bedding and the luxury model receives a canopy over its existing posts. `basic_rest_furniture` and `luxury_furniture` DATA/GENERATED records retain construction calculations and explicit textile-filling approximation. The sleeping surface remains unchanged. No external pixels are introduced.

`generate_ornamental_decor.py` preserves the accepted small picture and statue, and adds a2.16x1.56m landscape using the same owned art: planar3x, depth1.5x; masses follow that construction. The former grouped review invoked only `view0`, so it spawned only the picture. The corrected gallery displays both paintings and the original statue together; this fixture issue is not missing production sculpture geometry.

Unreleased #416: `assets/buenos_aires/CITY.json` and
`assets/generators/generate_buenos_aires.py` generate the original schematic
six-block CABAIRES map from owned city profiles/textures. It is not a historical
street reconstruction. Native access/visual evidence: `assets/validation_5852`.
Destination music is unassigned; the author's field track is not reused as city music.

The new horse uses eight painted sprite directions, from an original OpenAI
imagegen atlas made on 2026-10-29 under the author's art direction. The unchanged
RGBA source, prompt, crop bounds and scale are retained in
`assets/art_source/transport/horse-eight-views.png` and
`assets/transport/vehicles.json`. No external horse photograph is incorporated.
`generate_transport_vehicles.py` deterministically crops/registers these sprites
and builds the owned wood/iron/brass steam locomotive, coach and service sign.
The train is a period-informed representation, not a named historical replica.
Existing carriage and ship art remains intact. Native captures in
`assets/validation_5852` establish rendering only; author visual acceptance is
reserved for the grouped V5.8 check.

## 5.8.50 - Contact adapter evidence (#502)

No art/audio/map source changes. Existing collision cylinders supply generic
physical-object approximations; dedicated approved geometries remain authoritative.
assets/validation_5850 contains private native fixtures, migration and performance
evidence. Do not distribute its generated engine/IWAD/save fixtures.

## 5.8.49 - Physical contact geometry references (#502)

No raster, model, audio or map assets change. The density reference manifest
assets/generators/contamination_physical.json records source URLs, units and
explicit proxies; generate_contamination_physical.py deterministically emits
the runtime table. It preserves existing inventory masses and physical vessel
geometry. Native fixtures, original-runtime migration and renderer-cadence
comparison are retained under assets/validation_5849. They are private QA,
not distributed IWAD/engine content or author visual acceptance.

## 5.8.48 - Vessel geometry and crash reproduction evidence (#502)

assets/validation_5848 records the existing thermal/physical geometry used for
vessel exterior exposure and isolated native fixtures. No sprite, model, map,
music or attribution changes. The author-provided CrashReport is retained in
ignored build/issue502-vessels/probe04-packedtravel-author-crash.zip; published
evidence records its hash and diagnosis, without distributing the minidump,
engine, development IWAD or private saves. The corrected fixture parks its real
table before travel; failed probes are retained and excluded from passing totals.

## 5.8.47 - Stack contamination evidence (#502)

No sprites, models, maps or audio change. The approved 1,000 kg/m^3 reference is
an abstract inventory geometry convention, not physical art scale. Native
fixtures, reproducible preparation and evidence are in assets/validation_5847;
test PK3s, engine/IWAD and saves remain private regenerable build outputs.

## 5.8.44 - Original landscapes and ornamental sculpture (#410)

The author approved River Plate landscapes and ornamental subjects, plus the
same three-item/ten-recipe furniture supply. Original built-in imagegen sources,
exact prompts and hashes are retained in assets/art_source/ornamental_decor.
The landscape texture and both transparent painted inventory sprites follow
SPRITE_ART_DIRECTION; no inventory sprite is rendered from a 3D model.

generate_ornamental_decor.py registers those sources and builds original world
meshes. The 72x52-cm wooden painting has a 60x40-cm canvas, stepped mouldings and
no glass/easel. The 85-cm botanical wood carving stands on a 35-cm square plinth.
DATA.json distinguishes delegated construction approximations from museum
references: The Met's early nineteenth-century carved-wood ornaments (189470)
and the Argentine museum's Pueyrredon River Plate landscape genre (308). No
external pixels, mesh, composition or historical person's likeness are copied.
Existing project-owned stash wood/iron textures are reused with provenance;
the statue's continuous carved surfaces use an original painted wood texture.

GENERATED.json records geometry-derived wood/iron/canvas masses, rounded recipe
grams and deterministic output hashes. Development fixtures and evidence live
in assets/validation_5844; private packages/IWADs/engine remain untracked.

## 5.8.43 - Household absence evidence (#502)

assets/validation_5843 contains deterministic private fixture sources, native
logs and environment/package hashes for chronological household cleaning,
resource shortages, Limbo clock separation, save/load and prior-runtime recovery.
No packaged art, music, maps, sprites or models change in this runtime patch.
Development PK3s, engine binaries and IWADs remain outside the tracked delivery.

## 5.8.40 - Dining set artwork (#410)

Three original deterministic wooden table meshes use documented nineteenth-century
envelopes: round 1.04 m diameter / 0.74 m high; ordinary 1.702 x 0.883 x 0.711 m;
long 3.105 x 0.845 x 0.699 m. The existing luxury table and all existing chair
models/textures are reused. DATA.json and GENERATED.json under
assets/art_source/dining_sets retain historical sources, member construction,
wood/iron volumes and complete-set bills. Reference photographs and meshes are
not copied. Fixed mansion tables are not replaced by these portable variants.

Four built-in imagegen painted inventory sprites show complete 2/6/12/6-chair
sets, using the owned ordinary/luxury chair palette and the current art direction.
Source PNGs, exact prompts/edit prompts and provenance are retained in that same
directory; CDS2A0/CDS6A0/CD12A0/CDLXA0 copy the selected pixels and alpha unchanged.
The twelve-chair image was corrected from an initial ten-chair draft before use.
Native inventory inspection confirms transparent silhouettes, localized labels
and mass displays. This is agent visual review; author acceptance stays pending.

assets/validation_5840 retains native world/inventory views,1,201 current PASS
and22 original-runtime checks, deterministic model/data hashes and exact source
packaging checks. No engine binaries, IWADs or compiled diagnostic packages are
included in the delivery. See report.json for boundaries and rollback evidence.

## 5.8.39 - Aim validation evidence (#415)

assets/validation_5839 retains deterministic private native fixtures, independent
numerical quadrature, exact prior/current shot samples, save/hub/rollback logs,
package/environment hashes and a reproducible report. Maps, models, sprites and
textures are unchanged; no game artwork or distributable engine/IWAD is added.
The fixture room reuses validation_588/580 and stays outside packaged src.

## 5.8.36 - Portable study artwork (#410)

Original deterministic desk and empty-bookcase meshes reuse owned wood/iron
textures. assets/art_source/study_furniture contains dimensional references,
explicit member construction and reproducible mass/material bills. No external
pixels/meshes are copied; museum pages provide dimensional context only. The
existing mansion desk and filled decorative library model are unchanged.
Two built-in imagegen painted pixel-oriented inventory sprites follow the owned
luxury-chair wood shading, with plain four-leg desk and three empty bookcase bays.
Exact source PNGs, prompts, reference roles and hashes remain under
assets/art_source/study_items; runtime CSDKA0/CSBKA0 preserve generated alpha.
Agent review confirms both painted icons in the Spanish native inventory and
both deployed models in an isolated native scene. Captures are retained in
assets/validation_5836; author acceptance remains separate and pending.

## 5.8.35 / #410 - Painted sofa item views

Built-in image generation supplies owned painted pixel-oriented two-/three-seat
inventory and dropped-item sprites. The native validation_5829 sofa view defines
physical identity; the owned luxury-chair item defines timber/cloth shading.
The three-seat drawing is corrected to one central front support, matching its
six-leg construction. Full prompts, intermediate source, reference roles and
hashes remain in assets/art_source/sofa_items. CSF2A0/CSF3A0 are exact copies of
the generated source PNGs with alpha preserved. No external images, Doom pixels
or model-render projections are used. Deployed world meshes remain unchanged.
The sofa generator now also exports its existing material bill to runtime data.
Agent native inventory review confirms both icons and their transparent
backgrounds; captures remain in assets/validation_5835. Author acceptance is
still pending. Repeated deterministic sofa exports are byte-identical.

## 5.8.34 / #410 - Painted ordinary chair and cot items

The built-in image generator supplies two painted transparent inventory/dropped
sprites. Owned validation_5833 captures provide chair/cot shape; the owned luxury
chair sprite supplies pixel-oriented wood shading only. Source PNGs, all prompts,
reference roles and hashes are retained in assets/art_source/basic_rest_items.
Runtime CBICA0/CBIBA0 PNGs are exact copies with generated alpha preserved.
The earlier cot generation is retained as provenance. No external/Doom pixels,
procedural model projection or replacement of world models is involved.
Native inventory review and author corroboration remain separate evidence levels.

## 5.8.33 / #410 - Human-scale chair and raised cot

The author requested this ordinary furniture correction on 2026-10-27.
`assets/art_source/basic_rest_furniture/DATA.json` owns dimension references and
all construction members; `GENERATED.json` records masses/material bills/hashes.
`assets/generators/generate_basic_rest_furniture.py` deterministically generates
the two owned models and runtime dimension constants. The older rest generator
now delegates these two meshes to that source; sleeping-bag outputs are unchanged.
Original chair/cot models are retained beside the source as `legacy-*.obj` and in Git.

Dimension-only references: [Heymann AH-263, circa1840](https://www.antik-heymann.de/en/antiquitaeten/stuehle/biedermeier-stuhl-kirschbaum-619.html)
and [Colonial Williamsburg folding cot1952-658,1780-1820](https://emuseum.colonialwilliamsburg.org/objects/23/cot-folding).
No external image, model or texture is copied. The chair keeps three horizontal
back rails; the cot keeps four straight legs, low wooden headboard and textile
support. Its sleeping surface is raised to the chair's seat, as requested.
The existing owned wood/iron/canvas textures remain byte-identical.
Native render/pose review belongs to validation_5833; author acceptance is pending.

## 5.8.32 / #410 - Painted luxury furniture inventory items

Two original transparent PNG sprites are generated with the built-in image tool,
following SPRITE_ART_DIRECTION: existing native chair/bed captures define physical
identity; the owned wardrobe icon defines painted pixel-oriented style. World
models are unchanged. Sources, prompt specification and SHA-256 provenance remain
in assets/art_source/rest_furniture_items. The packaged sprite is an exact copy
of its source; GZDoom scales it in inventory and as a dropped item. No rendered
model projection, external museum image or Doom pixels enter the output.
Author visual acceptance remains pending with the final grouped V5.8 handoff.

## 5.8.31 storage furniture acquisition

The movable wardrobe/cupboard reuse their accepted source geometry and painted
inventory icons, including the existing CWRD/CKCB sprite definitions. No image,
mesh, map or third-party resource was added or replaced. Acquisition artwork is
not a new rendering of a3D model; provenance remains under wardrobe and
kitchen_fixtures/kitchen_stations sources. Native inventory captures and author
corroboration are tracked in assets/validation_5831 and pending_test.txt.

## 5.8.30 - Original luxury furniture models (#410)

assets/art_source/luxury_furniture/DATA.json records envelopes from Metropolitan
Museum metadata: armchair1970.35.1(ca1870-1875),
https://www.metmuseum.org/art/collection/search/237 ; bedstead2021.109a-vv(1815-1825),
https://www.metmuseum.org/art/collection/search/19766 ; dining table11.60.157a-c
(1810-1820), https://www.metmuseum.org/art/collection/search/3184 . Metadata informs
dimensions and period context; none of their photographs or mesh is imported.
The generated designs are original interpretations, not replicas.

assets/generators/generate_luxury_furniture.py produces carved/turned wood members,
medallions, iron joinery and thin fitted cotton over solid boards/slats. It reuses
owned stash wood/metal/interior textures. Its explicit construction and solid
volumes provide reproducible material bills in GENERATED.json and runtime data.
No synthetic upholstery filling or copied image is added. This world-model stage
does not supply portable inventory sprites; that artwork remains with acquisition.
Native gallery/occupied captures and hashes: assets/validation_5830. Appearance
still needs author corroboration; no final V5.17 visual-polish claim is made.

## 5.8.29 - Original period sofa models (#410)

assets/art_source/sofas/DATA.json records the author's delegated calculations and
museum dimensional references: Metropolitan Museum59.197(1810-1820),
https://www.metmuseum.org/art/collection/search/7594 ; and39.148.1(circa1820),
https://www.metmuseum.org/art/collection/search/7578 . They inform envelopes only;
no photographs, pixels or museum mesh are imported. Seating counts are the game's
interpretation, not an asserted catalogue description.

assets/generators/generate_sofas.py deterministically creates two original wood
frame/solid seat/back meshes with thin cotton covers and iron trim. Existing owned
stash wood/metal/inside textures are reused without editing. DATA/GENERATED retain
member-volume mass calculations and output hashes; join overlap and thin-cover
construction are design approximations, not a museum replica. Mesh axes and
MODELDEF follow existing furniture conventions. No new raster sprite is generated
in this fixed-furniture stage; inventory acquisition/art remains separate.
Native frontal/occupied views are recorded in assets/validation_5829. Author visual
corroboration remains outstanding under CA410-SOFAS-01.

## 5.8.26 - Reused owned reading furniture (#410)

The reading desk reuses models/caelum/props/rest/ca_table_small.obj and its existing
owned texture/registration transform. The accepted reading shelf's model, sprites
and provenance remain unchanged. No image generation, replacement artwork or
third-party pixels were introduced. MODELDEF adds only the new desk class binding.
Native screenshots in assets/validation_5826 verify placement and bilingual menus;
visual author corroboration is still outstanding.

## 5.8.25 - Original garden water furniture (#410)

assets/art_source/water_furniture retains DATA.json, PROMPT.txt, the original
transparent imagegen sheet and deterministic output hashes. Its two painted128px
icons are crop/resize/alpha registrations, not rendered mesh projections.
assets/generators/generate_water_furniture.py creates original iron geometry,
physical quantities, MODELDEF and TEXTURES registrations. Existing owned painted
kitchen iron and stash hardware textures are reused; no historical image pixels
or Doom art enter the package.

The [Science Museum Group's1875 Handyside fountain](https://collection.sciencemuseumgroup.org.uk/objects/co8018571/cast-iron-drinking-fountain-midland-railway)
provides period material and basin/backplate construction context.
The [Preservation Resource Center's cistern history](https://prcno.org/rise-fall-new-orleans-cistern/)
records the rectangular1831 iron cistern at Hermann-Grima House. Our tank sizes,
panel thicknesses, motifs and fittings are delegated original game designs; the
sources are not evidence for their exact measurements. The native models use
physical tank capacities200/1000 L and calculated dry masses240.4476333/342.9765340kg.
Small decorative fitting overlaps count as stock allowance in the material bill.

Native visual and interaction review is recorded separately from pending author
acceptance CA410-WATER-FURNITURE-01. Future furnishing catalogue/manufacturing
integration remains open; final visual refinement also retains its roadmap scope.

## 5.8.24 - Wardrobe models and painted icon (#410)

Read SPRITE_ART_DIRECTION before creating the new asset. Original painted source
created with built-in OpenAI image_gen; exact prompt, reference roles and preserved
RGBA source are in assets/art_source/wardrobe/PROMPT.txt, BRIEF.json and
wardrobe-source-v1.png. No museum image pixels were copied. Source SHA256:
2a2ef38658c0a9e545a096bac3c3d5b60232ed6a37a8da82f9ce602dc428d9fa.
The [Parliament Pugin/Gillows record](https://heritagecollections.parliament.uk/collections/getrecord/HOP_POW_09440)
supplies nineteenth-century dimensions and six-panel construction context.

assets/generators/generate_wardrobe.py deterministically builds three original
OBJ states using the existing owned chest wood/iron/lock textures. It crops,
resizes and thresholds the preserved generated alpha for a painted128px
inventory/fallback icon; it does not replace the icon with a3D render. MODELDEF
and TEXTURES registrations use distinct CWRD frames. Physical fallback scale,
component volumes, masses and output hashes are in MANIFEST.json. Native
captures include the closed/open/locked states and inventory-size legibility;
agent review is separate from pending author visual acceptance.

5.8.23 / #502 changes exposure persistence only; no artwork, audio or map bytes change. Native evidence is in assets/validation_5823.

## 5.8.22 - Shared-water mansion bathroom fixtures (#410)

This patch reuses the accepted domestic bathroom models, painted sprites,
textures and provenance from assets/art_source/bathrooms. No bitmap, mesh or
map geometry is regenerated or edited. Only placement data is new; the twelve
first-floor mansion fixtures use the existing physical sizes. Their own artwork
and the other furnishing catalogue remain traceable to their earlier deliveries.
Current mansion placement captures and provenance/hash checks are recorded in
assets/validation_5822; author placement review remains pending.

## 5.8.20 - Mansion kitchen sink and wall cupboard (#410)

An original painted cupboard source was generated with built-in imagegen
under SPRITE_ART_DIRECTION; exact prompt, full source, museum references and
delegated construction assumptions are in assets/art_source/kitchen_fixtures.
The deterministic generator supplies closed/open/locked original OBJ meshes,
an alpha-cut painted 128px inventory/fallback sprite, physical fallback scale,
registrations and placement data. It reuses owned wood/hardware textures.
The sink reuses the accepted owned domestic sink model and painted fallback.

[Szczecin hanging food cupboard MNS/E/4432,1880-1910](https://inmuseums.pl/all-objects/5mQHgw43t52ec7lBBT0v_hanging-cupboard-)
supports period wall-hung wooden food storage; our two solid doors, geometry
and dimensions are an original interpretation, not a replica or a claimed
exact1889 museum object. The accepted sink retains the
[Burges washstand,1880](https://api.vam.ac.uk/v2/museumobject/O8362)
construction reference. No museum image pixels are copied.

Cupboard stock calculation: 20mm boards, 12mm back, 18mm shelf, algarrobo at
760 kg/m3, plus 0.3kg nominal hinge/knob/plate hardware. Sum of generated stock
box volumes gives 62.333kg wood plus hardware =62.633kg. Small trim overlaps
remain nominal stock allowances. An installed padlock keeps its own item mass;
the locked mesh's extra padlock is only its visible representation. Recipes
and portable acquisition are separate unfinished furniture scope.

Seven repeated generated outputs match byte-for-byte; all176 existing map and
bathroom files checked remain unchanged. Native captures and hashes are in
assets/validation_5820. Technical review is separate from pending author acceptance.

## 5.8.19 - Kitchen process artwork (#410, author review pending)

Original painted stove, oven, preparation counter and proofed-dough sources
were generated with built-in imagegen under SPRITE_ART_DIRECTION. Exact prompts,
retained variants and export hashes are in assets/art_source/kitchen_stations
and kitchen_dough. A separate painted matte-iron texture avoids the striped
appearance found in the first native review. No previously accepted art changes.

The deterministic kitchen generator supplies original simple meshes, painted
128px inventory/fallback sprites, registrations and the dimension/placement table.
It reuses owned wood, brass and trim textures; the iron source is retained at
full resolution and exported at 256px. Dough uses the existing packer's --dough
mode. Previous ingredient and meal exports are byte-identical; repeated new
exports also match. Evidence and native captures: assets/validation_5819.

DATA.json records the author's delegated geometry calculations and references:
[Temple and Reynolds range, 1848-1860](https://collection.sciencemuseumgroup.org.uk/objects/co48606/cast-iron-cooking-range)
for period iron construction and its 1390mm-wide/800mm-high body;
[Tatton Park kitchen table](https://www.nationaltrustcollections.org.uk/object/1297639)
for nineteenth-century wooden construction. No museum images are copied.
Our two 700mm modules, depths, 6mm iron shell, algarrobo boards and fixed trough
are original design approximations, not replicas or claimed museum dimensions.
The source table documents all assumptions; nominal masses are 175.997kg per
iron module and 89.295kg for the counter. These fixed actors do not yet establish
portable furniture recipes or prices. Native appearance remains subject to
CA410-COOKING-01; technical review is not author acceptance.

## 5.8.18 - Accepted painted prepared meals (#410)

Four new owned built-in imagegen sources show bread, roast beef, roast hake and
puchero in the project's painted inventory style. Original sources, exact
prompts and SHA256 provenance remain in assets/art_source/cooked_meals.
The existing deterministic kitchen exporter gains a --meals mode; authorized
alpha masking/cropping/resizing produces 128px sprites and FBRD/FRBF/FRFS/FPCH
aliases. Repeated exports match byte-for-byte; default ingredient outputs are
unchanged. Native quick-use, inventory and table presentation reuse those sprites.
The dishes' depicted plates/bowl are presentation, not additional container items.
Agent visual review is recorded in assets/validation_5818. Author visual
check CA410-MEALS-01 passed on 2026-10-26, without qualifications. No accepted
ration/ingredient artwork was replaced.

## 5.8.17 - Accepted painted kitchen ingredients (#410)

Five original built-in imagegen sources: flour, raw beef, raw hake fillet,
vegetable mix (potato, squash, carrot, sweetcorn), and culinary salt. Prompts,
source hashes, retained variants and technical export hashes are in
assets/art_source/cooking_ingredients. The accepted ration icon is the observed
style reference; none of its pixels or other existing art were replaced.
The exporter applies a 128/255 alpha mask to remove the generated matte fringe,
fits the silhouette within 116 x 116 pixels and packs 128px inventory/world
sprites. This is authorized technical processing under SPRITE_ART_DIRECTION.
The unselected fish edit remains as source evidence. Model art is not introduced.
The deterministic exporter produced identical bytes twice. Agent review of the
contact sheet and native Spanish/English inventory/quick-use captures passes;
author visual check CA410-INGREDIENTS-01 passed on 2026-10-26, without qualifications.


## 5.8.14 - Ration lot presentation (#410)

Existing ration world/inventory sprites are retained. Added bilingual numeric
lot/next-portion details only; no raster, model, provenance or map art changes.
Native UI capture and author terminal: assets/validation_5814.

## 5.8.13 - Campfire world artwork (#411)

Original deterministic OBJ log piles, flame variations and mounted iron pot:
assets/generators/generate_camp_fire.py with camp_fire_art.json. Dimensions
derive from CaelumCampData and CaelumPhysicsUnits. The author-accepted #137 flame atlas,
station iron and stash wood textures are reused with their existing provenance.
Flame UVs use the atlas measured row boundaries; its pixels remain unchanged.
No raster is edited and existing painted tent/pot inventory sprites are retained.
One model slot per actor frame avoids the earlier overlapping-model defect.
The mounted pot rests on its integral iron trivet, with the ring and three legs
using the approved physical dimensions from CaelumCampData. Original pot shape,
handles, textures and inventory artwork remain; no raster edit is introduced.
Manifest: assets/art_source/camp_equipment/FIRE_MODEL.json. Native captures and
determinism results: assets/validation_5813. Author visual acceptance is pending.

Solid-contact continuation (#502): no production art or map changes. The
unshipped contact laboratory reuses existing rat sprites and local development
IWAD texture references; its map/PK3 are generated under build, never distributed.

Surface-contamination continuation (#502): no production art/map changes. The
two-room diagnostic map is generated only in build; it references the local
development IWAD and is excluded from runtime packaging. No new sprite is needed.

Equipment-cleaning continuation (#502): reuse the existing inventory/live-menu
artwork. No sprite, model or map edits; inspected native captures are retained in
assets/validation_5812/cleaning/captures. CA502-CLEAN-01 passed author review on2026-10-25.

Soap-bathing continuation (#502): existing painted soap icon, bathroom artwork,
RestLying sprites and live-menu controls are reused. No art or map assets change.
Native UI captures: assets/validation_5812/bathing/captures.

## 5.8.12 - Toilet interaction (#502)

The posture continuation reuses existing RSDO seated/lying artwork, with no image,
model or map edits. Toilet support derives from the existing wooden seat's0.52m
height; tub support from its0.22m inner bottom (32MU/m). Center the seated sprite
on the toilet and align the lying sprite to the tub's long axis. The accepted
rest-camera distances/angles are reused. Native captures are in assets/validation_5812/postures.
CA502-POSE-01 passed author review on2026-10-25 without qualifications.

Reuse the accepted #410 domestic toilet model/sprite and household placement.
No artwork or map geometry changes. New interaction text and progress are EN/ES;
author review CA502-TOILET-01 covers behavior, not replacement art.

## 5.8.11 - Domestic bathroom artwork (#410)

Original image_gen sources and complete prompts: assets/art_source/bathrooms.
The selected bathtub is v2; v1 remains as provenance. Sink/toilet are v1.
The enamel source is a separate opaque tile. Transparent sprites are registered
as128x128 inventory/world images; alpha is preserved. World fallback scale fits
the declared physical envelope without modifying the original painted aspect.
The deterministic generator creates three original OBJ meshes and mechanically
registers the images; it does not synthesize their painted shapes in Python.

| Fixture | Width x depth x height (m) | Materials |
| --- | --- | --- |
| Washstand/sink |0.80 x0.57 x1.00|wood cabinet, ivory enamel basin, brass tap|
| Bathtub |1.80 x0.80 x0.75|iron body/feet, ivory enamel, brass taps|
| High-cistern toilet |0.55 x0.70 x1.90|ceramic bowl, wood seat, iron cistern/pipe, brass pull|

Dimensions are the author's delegated design calculations, not historical
universal sizes. The V&A1880 Burges washstand O8362 documents a wood/inset-basin
combination and79.5x56.7cm footprint; this simpler washstand reinterprets it.
The tub/toilet are original period-inspired designs, not museum replicas.
DATA.json records the reference, physical dimensions,32MU/m conversion and
positions inside the already-existing bathroom. No external museum bitmap is
copied. Model materials reuse owned stash wood/metal/brass and the new enamel.
The visible toilet cistern is not the abstract200-L household reserve.
Mass/recipes and portable versions remain the broader#410 catalogue work.

MANIFEST.json records input/output hashes, mesh bounds, sprite registration and
Pillow version. Retained prompts and src/licenses/DOMESTIC_BATHROOMS_410.txt
record provenance; no extra public redistribution license is inferred.
The world models and target panel were captured natively in validation_5811/captures. The basin cabinet is hollow around its inset bowl; owned station-paper shading separates inner walls from the enamel rim/floor. Inventory PNGs were inspected directly. The attempted runtime r_models toggle retained models in its capture, so it is not claimed as native sprite-fallback validation. Author visual acceptance passed as CA410-BATH-01 on 2026-10-25 without qualifications.

## 5.8.9 - Hygiene item artwork (#502, in progress)

Four original painted alpha sources were generated with built-in image_gen:
animal fat, a plain stoneware alkali jar, handmade soap and a reusable cotton
rag. The brief follows SPRITE_ART_DIRECTION's restrained nineteenth-century
materials and painted inventory style. Full prompts, generated provenance and
saved source paths are in assets/art_source/hygiene/PROMPTS.json. No external
art or existing accepted sprite was replaced.

export_hygiene_icons.py performs only alpha-bound cropping and proportional
128-pixel export. All four previews were inspected at actual inventory size;
repeated exports produced identical source/output hashes in EXPORT.json.
The four unchanged previews are now copied byte-for-byte into
src/graphics/caelum/icons/hygiene; RUNTIME.json records their source/runtime
hashes. Inventory/crafting use these painted icons; dropped supplies use sprite
billboards, with no replacement model. Native Spanish inventory and shop captures
are in assets/validation_589/supplies. The author accepted these sprites under CA502-SUPPLIES-01 on 2026-10-25.

## 5.8.8 - Deployed tent artwork (#411, in progress)

The deterministic `generate_camp_tent.py` builds an original A-frame OBJ from
the revised approved 4 x 3 m plan and 1.8 m ridge, using only existing owned canvas,
wood, iron and leather textures. The closed canvas area is approximately
35.34 square metres. The entrance remains open between inclined end frames.
The painted inventory sprite remains unchanged. Sources, material hashes and
provenance are in `assets/art_source/camp_equipment/TENT_MODEL.json`; native
four-view inspection and repeat-generation evidence are in
`assets/validation_588/tent`. Native registration/deployment is implemented; the author rejected the original narrow silhouette and approved the enlarged
dimensions/materials. The enlarged shape and corrected MODELDEF overlay are fully accepted (2026-10-25). Separate single-slot frame bindings prevent the
legacy and enlarged meshes rendering together; see validation_588/binding.
The original model is preserved as tent_legacy.obj for old deployed structures;
its hash remains bbfdef6195c44540d7223cac33ee4fae15747c10051fc8dac0c67c50a97fa9e8. No new bitmap or external artwork was introduced.

## 5.8.6 - Central property access (#411)

Reuses existing houses, furnishings, doors and menu artwork; no new art or map geometry. Four residents change home, with routing generated from the existing city geometry by `generate_property_routes.py`. `CaelumPropertyData.zs` owns the selected home IDs and placement coordinates; `assets/validation_586` contains private fixture sources and test evidence.

Camp acquisition artwork adds two painted 128-pixel RGBA icons: canvas tent and
open iron pot. Built-in image_gen sources and complete prompts are preserved in
`assets/art_source/camp_equipment`; `export_camp_icons.py` only crops alpha bounds,
scales and registers the sprites. No photographs, external images or Doom assets
were used. `EXPORT.json` and `VALIDATION.json` record provenance/hashes and the
byte-identical repeat export with Pillow 13.0.0. Both exports were visually
inspected; author acceptance is pending. These inventory images do not constitute
a completed deployed tent/fire model or camp runtime.

## 5.8.5 - Regional event discovery (#415)

No new visual/audio asset or map geometry. Reuse the current calendar and quest journal with ES/EN awaiting-news text. Private native validation rooms are generated locally; they are not campaign maps or packaged fixtures.

## 5.8.4 - Second map soundtrack (#496)

Damián Curti supplied nineteen WAV masters from Música CA - 2 on 2026-10-24 and confirmed he created them using Suno. `assets/source/audio/map_music_496/catalogue.json` is the authoritative destination/name mapping; `PROVENANCE.json` records original and encoded hashes, exact sample counts and the encoder fingerprint. Original WAVs are retained unchanged in `masters/`. Whole stereo 48-kHz Vorbis quality-6 recordings are packaged in `src/music/`; no normalization, cuts, fades or resampling. Credits ship in `src/licenses/MAP_MUSIC_496.txt`. No new public asset license is inferred.

The author explicitly approved preserving destinations from the supplied titles. Campo de Buenos Aires is countryside, not the city; Mar argentino is the sea, not the current coastal town. All nineteen destinations are reserved until their corresponding authored maps exist. Their presence in the PK3 is not a claim that these maps are implemented. Existing MAPINFO music remains unchanged. `assets/validation_584` contains deterministic preparation/playback evidence and a listening terminal; the author fully accepted CA496-MUSIC-01 on 2026-10-24. The inventory below includes these nineteen runtime OGG; their nineteen original WAV masters remain outside the PK3.

## 5.8.3 - Contamination HUD icon (#410, in progress)

Built-in image_gen generated a monochrome silver/grey skull with a withered
leaf on genuine alpha, following SPRITE_ART_DIRECTION and existing HUD icons.
Source: assets/art_source/food/contamination_icon_v1.png; runtime copy:
src/graphics/caelum/ui/hud/icons/ca_hud_icon_contamination.png.
Both are byte-identical; native scaling uses 18x18 virtual pixels, as the
accepted thermal icon. Prompt, SHA256, dimensions and provenance are retained
in assets/manifests/food_contamination_icon_583.json. No external or Doom artwork
was used. Native preview confirms layout; CA410-CORE-01 appearance acceptance
passed on 2026-10-24. Dish/ingredient/furniture artwork is not supplied by this icon.

## 5.8.2 - Connected mansion deposits (#414)

The deterministic standard-library generator `assets/generators/build_connected_water.py`
uses `assets/map01_mansion/CONNECTED_WATER.json` and the preserved `legacy_581`
WAD. It appends native basin, service-step, circular-opening and gate geometry;
existing records remain intact apart from sector-zero installation metadata.
Uses owned CMST01/02/03 masonry, CAPOOL01 water and the existing lever column/
face/sound. No new external artwork or runtime IWAD asset is introduced.
The 12-strip circle is a native visual approximation; hydraulic area uses the
approved circle. The manifest/report preserve layout, hashes and provenance.

## 5.7.14 - Mate vessels and inventory sprites (#472)

The author accepted functional tests on 2026-10-23 but rejected the original
hemispherical procedural vessels/icons. Corrected, originally painted sprites
show a complete porongo and ornamented silver/gold-clad wooden bodies with
narrower mouths and fixed bronze bombillas. They follow SPRITE_ART_DIRECTION
and the accepted owned inventory style. Silver has a central rosette and leafy
scrolls; gold has an elongated body, oval floral panel and decorated borders.

Sources, exact built-in image_gen prompts, museum references/roles and hashes:
`assets/art_source/mate_sprites`. San Antonio Museum of Art's Argentine
nineteenth-century mate (85.1.653.1-2) informed the closed silhouette; USC's
mate informed vegetal ornament. The Museo de Artes Decorativas documents
ovoid poros used in Argentina. These are original game interpretations, not
reproductions of specific artifacts. Museum photographs are not packaged.

`pack_mate_sprites.py` deterministically crops and downsamples generated alpha
to 128-pixel inventory icons. World TEXTURES registration compensates the 0.25
actor scale, keeping the former approximately 5.3-unit total height. The three
mate MODELDEF bindings are removed from the complete package. Legacy meshes,
generator function, manifest and captures remain recovery evidence; the old
generator entry point delegates to the painted exporter. Dry-gourd material
art and accepted #479 weapon art are unchanged. The open-hemisphere mass/thermal
approximation remains the accepted gameplay model. The author accepted the
corrected artwork and all CA472-01 checks on 2026-10-23. The contact sheet and
native correction evidence preserve the accepted presentation.

## 5.7.13 - Chemistry supply presentation (#471)

Previously accepted ingredient meshes/icons are now bound to appended native
material IDs. Production MODELDEF scale compensates the existing 0.25 material
actor scale, preserving the geometry used by the accepted gallery. All dynamic
sprite names are registered in VisualRegistry before model resolution.

Four new owned props cover sugar, prepared reagent packets and sealed carbine/
shotgun component cases. chemistry_supplies_art.json owns their bounded brief;
generate_chemistry_supplies_art.py reuses accepted procedural textures, shading
and the depth-tested icon renderer without regenerating accepted ingredient art.
Its manifest records source/model/icon hashes; the contact sheet lives in
assets/validation_5713. Models use contiguous material surfaces below the native
32-slot limit. Geometry represents the item identity, not an exposed chemical
process or real ammunition assembly. Final native presentation passes with five
inspected captures; two generator runs preserve all 13 data/art outputs. Author
review passed as part of CA471-BATCH-01 on 2026-10-23, without qualifications.

## 5.7.12 - Owned Fermentation Barrel (#487)

fermentation_station.json records the approved footprint, placements, physical
calibration and body profile. generate_fermentation_station.py emits the original
OBJ, CFERA0 fallback sprite and CaelumFermentationData; its manifest records hashes
and capacity. It reuses owned wood/iron/brass station textures and the accepted
#470 mesh projection, preserving that station and its provenance. No external
assets or portable inventory item are added. Native visual evidence belongs to
assets/validation_5712. The author accepted the visuals with CA487-01 in full on
2026-10-23, without qualifications; HISTORY records the confirmation.

## 5.7.11 - Station terminology (#486)

The accepted #470 station model, sprites, generator filenames and provenance
are unchanged. Its current displayed name is Chemistry / Química. No new art
is introduced; the Fermentation Barrel is a separate request under #487.

## 5.7.10 - Existing cartridge and station art reused (#471)

The cartridge station migration reuses the accepted kit icons/sprites and
Alchemy model. No art, provenance, world placement or firearm presentation
changes. Private test fixtures remain outside src; evidence: validation_5710.

## 5.7.9 - Existing water/Alchemy art reused (#409)

Boiling reuses the accepted six container icons, world items and fixed Alchemy
station. No new art, models or licensed resources are introduced. The private
water QA map and engine packages remain generated under build/issue409; tracked
validation sources/evidence do not package the development IWAD or executable.

## 5.7.8 - Painted support implement correction (#479)

The author rejected the procedural low-poly presentation after the first manual
handoff: accepted Book/Statuette designs must remain, and equipment must use
painted sprites consistent with SPRITE_ART_DIRECTION, including inventory icons.
This supersedes the initial #479 presentation without changing gameplay.

Support Book and Statuette reuse their original inventory/crafting icons,
world billboards, first-person A/B poses and character-hand variants unchanged.
Four new painted designs cover Scepter, Orb, Censer and Ritual Effigy, each at
T1/T2/T3. Built-in image_gen.imagegen used owned weapon icons as style references;
exact prompts, reference hashes and all four transparent source atlases are in
assets/art_source/support_sprites. No Doom or external artwork is incorporated.

pack_support_sprites.py performs deterministic cell extraction, alpha cleanup,
downscaling and grip registration. Twelve 128-square inventory/crafting icons
and twelve weapon-only 320x200 first-person layers live under
src/graphics/caelum/{icons,first_person}/support_sprites. World pickups are native
billboard sprites; MODELDEF no longer loads the rejected implement model bindings.
Three component bases use the corresponding painted icon. Existing character
hands remain authoritative. Sprite frames/state identities stay available to
saves; Book/Statuette resolve their original states under the new support IDs.
The Journal now draws the tier-resolved icon beside each of these six weapon
types, using the existing inventory row layout. Other weapon rows are unchanged.

The original procedural sources/outputs remain preserved for history/recovery,
including assets/generators/support_implements_manifest.json; they are not the
current visual contract. Current provenance is in
src/licenses/SUPPORT_SPRITES_578.md. The new inventory contact sheet and
MANIFEST.json record exact output/input hashes. Native presentation and inventory
checks are recorded separately from the initial runtime evidence in
assets/validation_578/RESULTS.md: 75 native checks on the full corrected package,
18 world/held views, 18 inventory rows and six T1 input/return sequences.
The author subsequently accepted the other five designs and requested a
baseless Orb held like the Book. orb-floating-source.png and ORB_EDIT.json
retain the targeted imagegen edit; orb-source.png preserves the earlier design.
The three updated Orb icons/first-person layers remove the pedestal. The held
Orb floats above the original FH02 Book palm, with all 38 original appearance/
glove variants referenced directly. Its pivot is the Book's existing pivot;
other weapon images remain byte-identical. World and material sprites reuse
the corrected icons. Native evidence: 23 checks, all three tiers in inventory,
world, primary/return, Book switch and male/female palms; floating_orb_report.json.
The author accepted the Orb retest on 2026-10-22, completing visual approval
for all six designs, including inventory sprites. CA479-01 retains its
outstanding gameplay, acquisition and save/load checks.

## 5.7.7 - Target-panel presentation (#481)

Reuses the existing CaelumMono font and the gallery's muted dark panel style,
centered above gameplay. Names and action hints reuse authoritative localized
catalogues and current bindings; additional labels are bilingual. No sprite,
model, texture or accepted #471 artwork changes. Layout constants are separate
from selection logic. Visual/native evidence: assets/validation_577/RESULTS.md.
Author check CA481-01 passed on 2026-10-22.

## 5.7.6 - Alchemy ingredient artwork (#471)

`assets/generators/alchemy_ingredients.json` records the bounded art brief and
owned palette. `generate_alchemy_ingredients.py` produces original textured
OBJ geometry and matching 128x128 transparent inventory sprites using a depth
buffer. Baked per-face texture shading preserves volume under native sector
lighting. Faces are grouped by material into 8?20 surfaces per new mesh to
stay within GZDoom 4.14.2's 32 surface-skin slots (CA-KP-152). Material inventory rows now draw their authoritative icons using the
existing clothing-row alignment. The existing #407 iodine mesh stays byte-identical; only its generic
opal icon/fallback is replaced by a view of that mesh. The marine data source
owns both inventory and fallback icon paths.

New models represent saltpeter, sulfur, charcoal, molasses, fermented
intermediate, alcohol, yeast, abstract gunpowder and two regional deposits.
Pale granular niter crust and yellow native sulfur remain visually distinct;
charcoal retains wood fractures. Closed or open vessels are visual conventions,
not approved masses, capacities, prices or container-reuse rules. The abstract
powder tin conveys no real formulation or manufacturing procedure. Existing
plant, hive, marine, medikit and potion art remains unchanged.

Runtime assets live under `src/models/caelum/world/alchemy_ingredients/` and
`src/graphics/caelum/icons/materials/`. The manifest records source, texture,
model and icon hashes; the review sheet stays outside src. Only iodine is
bound to an existing live material. The other models/icons are staged assets,
with private gallery bindings until the remaining #471 data is approved.
No new catalogue IDs or campaign sources are installed. This follows the
owned procedural model/icon workflow used for the accepted Alchemy station;
no external artwork, newly painted raster source or Doom assets are introduced.

Evidence: `assets/validation_576/RESULTS.md`. The author passed visual check
CA471-ART-01 in full on 2026-10-22, after the corrected gallery handoff.

## 5.7.5 - Owned marine material models (#407)

generate_marine_models.py builds two original volumetric OBJ meshes: a tied
bundle of dried cachiyuyo blades and an iodine container with a violet marker.
Only existing owned wood, paper, iron and gem textures are reused; inventory
thumbnails reuse owned plant-fiber and raw-opal art. marine_models.json records
provenance and mesh counts. No external art or development IWAD is distributed.
M087/M088 are registered in the material actor's visual registry and bind through
marine_resources.modeldef; model scale compensates the actor's 0.25 scale.
The artwork is representation only and introduces no vessel mass or benefits.
Byte determinism, visible front/side review and native evidence: validation_575.

## 5.7.4 - Owned Alchemy station (#470)

assets/generators/alchemy_station.json is the approved placement/dimension
source. generate_alchemy_data.py emits CaelumAlchemyData.zs;
generate_alchemy_station.py builds the original station OBJ and transparent
icon CALCA0 from the same mesh. The
manifest records deterministic hashes and provenance. Geometry reuses the
project's original wood, iron and brass station textures; no external art.
Mesh bounds at the combined 1.5 scale fit the approved 60 x 60 x 72 collision.
The static binding lives in MODELDEF; native collision/visual tests and save
migration evidence belong to assets/validation_574. CA470-01 passed on 2026-10-22.

## 5.7.3 - Recovery validation (#406)

validation_573 reuses the frozen #405 private-room geometry locally. Its native
fixtures, launch source and results cover source clocks and save compatibility.
No production art or geometry is added or changed by #406; generated test maps,
packages, engine/IWAD files and private saves are not distributed.

## 5.7.2 - Owned 3D land resources (#405)

generate_land_resource_models.py produces fourteen deterministic owned OBJ
meshes: seven source profiles, six dropped-material bundles and one fiber bush.
The latter also replaces the decorative mansion shrub, preserving both existing
classes' collision/mass/gameplay. Volumetric geometry reuses owned project
foliage, wood, wax, paper and gem textures; no external or Doom art is added.
land_resource_models.json records mesh counts and texture provenance. Outputs
are in src/models/caelum/world/land_resources; MODELDEF compensates actor scale.
M081-M086 must be registered before MODELDEF parsing. Existing owned inventory
thumbnails remain UI-only. The optional generator uses the existing Mesh utility
and Pillow; byte-for-byte regeneration is checked. Front/side/close-up native
captures belong to validation_572. The author passed visual check CA405-01 on 2026-10-22.

## 5.6.10 — library and clothing shop signs (#383)

CASG06/CASG07 extend the existing generated sign system with a book and period
coat emblem. Sources: assets/generators/generate_shop_signs.ps1 and
assets/map06_port/HOUSE_HUBS.json; runtime aliases: shop_signs.textures.
The six earlier sign PNGs remain byte-identical. The two additions use the same
code-native vector drawing style, palette and layout; no external art is added.
Catalogue placements derive from SHOP_CATALOGUE.json and original city door
data. Native/visual evidence: assets/validation_5610; CA383-01 passed on 2026-10-21.

## 5.6.9 - Prepared cartridge-kit sprites (#380)

The author requested sprites for cartridge components on 2026-10-21. Each of the
two approved prepared-kit inputs has a distinct 128x128 RGBA inventory icon and
world alias M079A0/M080A0. Bronze case/projectile and paper case/shot silhouettes
distinguish carbine and shotgun; sealed packets preserve the abstract kit design.
OpenAI's built-in imagegen generated the two original sources separately. Exact
prompts, generation identifiers and source paths are in
assets/art_source/cartridge_kits/manifest.json. exports.json records hashes,
alpha bounds and ground pivots; generate_cartridge_kit_sprites.py performs only
deterministic cropping/resizing/registration with Pillow 11.3.0. Sources remain
in assets, exported artwork in src. CA380-01 passed author review on 2026-10-21.

## 5.6.7 - Distinct garment object artwork (#387)

All 25 approved garments now have individual 128x128 RGBA icons and WC00-WC24
world sprites. Inventory, crafting and ground pickups share the same garment
art; the native item identity, size, mass and thermal rules are unchanged.
The world sprite's pivot is centered horizontally at its actual alpha bottom.
The existing pickup scale/collision remain unchanged.

OpenAI's built-in image_gen generated each source separately on 2026-10-21.
`assets/art_source/clothing/manifest.json` retains exact prompts, source names,
generation identifiers and the author-review outcome. `exports.json` records source
and output SHA-256, crop bounds, pivots and dimensions. The 25 original RGBA sources
and contact sheet remain in assets; only exported images and TEXTURES aliases
enter the PK3. No external/Doom art or generated reference fixture is distributed.
`assets/generators/generate_clothing_sprites.py` pins Pillow 11.3.0 and performs
only alpha cropping, premultiplied resampling, centering and packing. It neither
paints nor replaces sources. Repeating it produces byte-identical exports.

This stage covers inventory/crafting and dropped-item billboards. It does not
complete #387's approved worn-character, character-preview or first-person
coverage across supported bodies, sexes, species and sizes. Source and native
visual evidence: `assets/validation_567/RESULTS.md`. CA387-01 passed author visual
review on 2026-10-21 for these object views; no new NPC wardrobe assignment or
performance acceptance is implied. On 2026-10-21 the author deferred the remaining
clothing appearance until 3D character models are available and requested closure
of the current batch. Preserve this artwork and provenance for that later stage;
PROJECT/TASKS retain the deferred coverage and its visual/performance checks.

## 5.6.6 - Clothing gameplay representation (#386)

Native garments temporarily reuse the project-owned material-fabric inventory
icon and M018 world sprite from the existing material catalogue. No new model,
texture, source art or external asset is introduced. The approved #386 values do
not authorize the separate #387 cuts/colors/body coverage/rendering decisions.

## 5.6.3 - Original reading bookshelf (#378)

`assets/generators/generate_reading_shelf.py` deterministically builds
`src/models/caelum/props/reading/ca_reading_shelf.obj` and placement constants from
`assets/map01_mansion/READING.json`. The original procedural frame, shelves and
thirty books reuse project-owned stash wood and station paper/leather/cloth
textures; no external asset or license is introduced. Existing texture provenance
remains in their generator/license sources. MODELDEF binds the new actor without
changing existing furniture. Native placement and bilingual UI captures are
recorded under `assets/validation_563`; CA378-01 passed on 2026-10-20.

## 5.5.8 - Cleaned animated bull model (#369)

The author supplied the Copilot3D GLB linked in
`assets/source/art/bull_3d/DESIGN.json`. Its original 7,511,584 bytes are preserved
as `original.glb` (SHA-256
`21c6c3413a009d18512a6106ba52e5032c4423c33f8c67bccf3b01a71d9c0c97`).
The input contains 106,519 vertices, 148,524 triangles, one material and no rig
or animation. Embedded image 0 is base color; image 1 is metallic/roughness
(G roughness, B metallic). It is not a normal map. Both original PNGs and their
actual source roles are retained; MD3 samples the baked albedo only. Provenance
and modifications ship in `src/licenses/BULL_3D_MODEL.txt`; no new generator
license is inferred from the author's attachment.

On 2026-10-19 the author requested surface cleanup and explicitly approved
local reconstruction of the forehead and horns while preserving silhouette and
colors. Voxel cleanup removes the thin generated folds before the head repair;
the repaired transition is blended into the closed body. The stocky
body, tail and brown/ivory palette remain. Component-isolated baking prevents
horn colors from projecting onto the forehead. The new forehead's dark color
blends into the original albedo. The first candidate had 6,000 triangles and
4,983 UV-split MD3 vertices, compared with the source's 148,524 triangles.

The author's subsequent inspection requested a more symmetric head, eyes that
are more than black points, and a more bovine muzzle. The same #369 patch now
uses a centered facial contour with paired cheeks, ears and horns, contoured
eyelids, brown irises, horizontal pupils and restrained corneal highlights.
A broad muzzle has recessed lateral nostrils and defined lips. The old facial
volume is nested inside the replacement and the neck transition is smoothed;
the existing rig, 23 bones and action keyframes are retained. That facial candidate
has 9,108 triangles, 7,381 UV-split vertices and a single 2048-square albedo atlas
to keep the eyes legible. Render bounds accommodate the new face; gameplay
dimensions do not change. Native appearance/performance checks are repeated for
this geometry rather than treating the first candidate's captures as current.
`refine_head.py` records this edit from the frozen input in commit `885fe498`;
its input hash and editable parameters are in DESIGN.json. The source remains
editable art, with deterministic MD3 export. CA369-01 was accepted by the author on 2026-10-20.

The next author inspection requested the same body/head coat, more threatening
brows or hair, and a larger whole bull. On 2026-10-19 the author explicitly
approved a 50% uniform visual enlargement with existing physical collision and
combat retained. The current head, ears and modeled brow/forehead locks reuse a
continuous brown-fur patch from the retained body albedo, avoiding seams across
atlas islands. Rounded tapered locks provide volume above the eyes. The current
mesh has 10,580 triangles, 9,273 UV-split vertices and the same 136 poses/2048
atlas. DESIGN.json records the coat patch and author-approved visual factor.
The exporter scales all geometry and visual gait stride by 1.5; native action
timing and movement remain unchanged. Current evidence is report-coat.json.

The editable `bull.blend` contains a 23-bone quadruped rig, normalized painted
skin weights, IK feet and 12 actions: idle breathing, walk, run, ordinary and
tutorial charge preparation, charge, gore, pain, death, corpse, rest and stun.
There are 136 exported pose samples in one MD3 surface. Death reaches its final
pose at the original frame-N boundary (25 tics); the original corpse hold and
tutorial fade remain native. The initial art scale used the existing 51.8-unit
height; the author-approved revision multiplies that visual scale by 1.5. Actor
radius 15.6, height 51.8 and mass 900 remain unchanged. Floor correction belongs to resting/falling artwork, not physics.

`authoring.py`, `rigging.py` and `refine_head.py` retain construction history; the frozen `.blend`
is authoritative editable art input and is not promised to serialize identically
when rebuilt. Runtime export is deterministic with pinned Blender 4.5.3:
`blender -b --python assets/generators/export_bull_model.py -- --output <fresh-directory> --install`.
The generator samples only `Bull_surface`, excluding retained references and
bake proxies. It writes MD3, skin, native frame states, MODELDEF and owned
transparent sprite aliases. It reuses the accepted Domingo MD3 format pattern,
without changing the Domingo pilot. No external replacement mesh, executable,
IWAD or fixture is packaged. Original bull sprites are preserved.

The presentation helper follows the original bull locally. Distance-driven
gaits use discrete simulation samples to avoid native time interpolation moving
feet on a stopped body; other clips retain native model interpolation. Visual
frames never delay attacks. Native appearance, saves, hub rollback and a real
MAP01 encounter are checked separately from author acceptance. See
`assets/validation_558/RESULTS.md`; CA369-01 was accepted by the author on 2026-10-20.

## 5.5.6 - Thermal surface fixture (#314)

`assets/validation_556/scene.json` owns private fixture coordinates. Its generator
uses the project's existing granite image and explicit blue/orange TEXTURES
recolors for ice/lava, plus existing owned wall/sky textures. No external art,
IWAD asset or executable is added. Labels are bilingual; the existing thermal
HUD supplies exposure feedback. Generated test maps, packages and saves stay
under build/, outside campaign distribution. Original granite provenance is
unchanged. This is a contact test presentation, not final volcanic landscape art.

## 5.5.5 - Unarmed input evidence (#363)

No art or audio is changed. The native fixture, reproducible scripts and evidence
live in `assets/validation_555/`; private runtime packages and save copies remain
under `build/`. Runtime changes are the unarmed input source and diagnostic
release labels. The fixture is not campaign content or a distributable IWAD.

## 5.4.46 - House-transition evidence (#334)

validation_5446 contains private-test builders, trace sources and textual native
evidence. The player's own view supplies the runtime transition image; no new
art/audio asset is added. Saves, PK3s, engine/IWAD dependencies and diagnostic
captures remain local. Hashes identify inspected native screenshots without
distributing their contents. Inconclusive capture attempts are not visual proof.
The single-Melt follow-up has a separate textual evidence archive; original
draft evidence is retained, including the initially missed default-Melt case.

## 5.4.45 - Private breath regression evidence (#357)

validation_5445 contains deterministic diagnostic sources, native logs and
manifest hashes. The author's save, runtime packages, engine and development
IWAD remain local. No art/audio resources change. The normal gameplay change
only excludes technical navigation targets from demon breath.

## 5.4.42 - Distributed update evidence (#318)

validation_5442 owns the deterministic private-runtime builder, owner-local
worker, native probe/checks, sequential runner, strict ETW report and textual
evidence archive. The measured runtime is based on ae8408f5, not a shipped
gameplay replacement. Source members are transformed in memory; private PK3s,
saves, engine and IWAD remain local. No art or audio asset changes. Prototype
objects, CVars and handlers are absent from the verified normal package. The
archive includes 72 matched windows, three cache audits, 1,068 native assertions
and filtered ETW rows with coverage context; evidence.json hashes each member.

## 5.4.41 - Isolated workload evidence (#318)

validation_5441 owns the deterministic diagnostic builder, captured-cadence
replay harness, sequential runner, strict report, tables and evidence archive.
The matrix retains 66 native logs/configurations, benchmark slices, package,
engine and private-seed hashes. Its diagnostic runtime is based on 8eb04042;
no art or gameplay asset is replaced. Packages, private saves and engine/IWAD
remain local. Release 5.4.41 changes diagnostic release labels only in src.

## 5.4.40 - Rest and acceleration evidence (#325)

validation_5440 preserves the focused probe, scripts, native logs and hashes.
The patch adds three bilingual refusal messages and refreshes localization
indexes; no art changes. Runtime packages, engine/IWAD and private saves remain
local. Earlier isolated drafts are evidence, not earlier production delivery.

## 5.4.39 - Jump-wall diagnostic evidence (#339)

validation_5439 owns the isolated native probe, reproducible package preparation,
configs, source/runtime hashes and logs. Its inputs are QA controls, not game
balance data. No visual assets change; engine/IWAD/packages/private saves remain
local. Earlier failed probe attempts stay identifiable as diagnostic evidence.

## 5.4.38 - Map-legend presentation evidence (#321)

validation_5438 retains focused native UI scripts, screenshots, logs and hashes.
The existing fonts/art remain; only two bilingual hint texts change. Regenerate
the dialogue/localization index after LANGUAGE edits. No engine/IWAD distribution.

## 5.4.37 - Current MAP03 attribution evidence (#318)

validation_5437 contains source-only preparation/analysis tools, compressed raw
native logs, scene screenshots, benchmark byte ranges and immutable launch/hash
records. It reuses validation_issue318's diagnostic wrappers and observer, never
that retired fixture's MAP06/6,000-actor entry point. Engine, IWAD, generated
packages and private saves stay local. No art or audio changes.

## 5.4.36 - House-door presentation checks (#334)

validation_5436 owns native portal and vehicle-transition probes. No art/audio
assets change. Preserve source fixtures, hashes and compressed logs; generated
packages, engine, IWAD and private saved files remain local development inputs.

## 5.4.35 - Prisoner escort test sources (#322)

validation_5435 contains deterministic native follow/collision fixtures. Existing
prisoner sprites supply the new inert waiting poses; no new art or audio assets
are introduced. Test packages, engine, IWAD and private saves remain local;
Source fixtures, compressed logs, launch hashes and save identities preserve
23 final runs/375 assertions plus failed development evidence in validation_5435.

## 5.4.34 - Native autosave verification (#324)

assets/validation_5434 holds focused reproducible native fixtures and evidence;
only test sources, launch metadata and logs are deliverable. Engine/IWAD,
packages and private saved games remain local. No art/audio resource changes.
Final evidence records 36 runs/138 assertions and exact 16,373-member package
equivalence. Failed/intermediate fixtures retain their own sources and hashes.

## 5.4.33 - MAP02 crusher geometry provenance (#323)

The authoritative generate_map02_maze.py / LAYOUT.json now stamp isolated
crusher footprints after upper corridor construction. Original panel dimensions
are unchanged. Revision-4 WAD, manifest and layout remain in
assets/map02_maze/legacy_5432 for reversible recovery; no external assets were
added. Static evidence: assets/validation_5433; native checks remain pending.

## 5.4.29 - Map catalogue and exact geometry provenance (#327)

assets/map_catalogue/MAPS.json records the current campaign/test names and
assets/map_catalogue/legacy_5428/maps retains all seven renamed original WADs,
with SHA-256 provenance and source commit b9fd71ce. MAP01, MAP02 and the 160
CAH interiors remain unchanged. Renamed test TEXTMAP contents are unchanged.
MAP03 uses the exact #318 selected low-sky TEXTMAP (MD5
bfbf3d4ac39f36e7d61a450dbb47b1a2), generated by generate_city_ceilings.py from
CEILINGS.json and existing house/city dimensions. No new artwork or rights changes.

The playtest export allowlist now follows this catalogue, including private
interiors; this update does not publish an export. Current checks/sources live
in assets/validation_5429, separate from historical #318 captures. No executables,
IWADs, native saves or diagnostic packages are distributed as validation evidence.

## 5.4.28 - House signs and performance evidence (#318)

Subsequent author-approved house prototype: six original painted wood trade
signs are generated by assets/generators/generate_shop_signs.ps1 from the
category labels in assets/map06_port/HOUSE_HUBS.json. Bread/bottle, sword,
firearm/cartridge, jewelry, shield and staff identify the existing six vendor
categories. The procedural vector artwork uses muted paint, wood borders,
cream lettering and rasterized Windows Georgia; no external image or font file
is packaged. PNG sources are reproducible on the recorded Windows environment;
runtime sprites use one static wall-facing actor per shop (64 total).
The house doors reuse the existing owned mansion door model and materials.
The new house WADs are generated from the existing CITY/INTERIORS data; the
pre-hub MAP06 is preserved at assets/map06_port/legacy_5428/MAP06.wad.
These changes supersede the earlier no-production-art-change checkpoint below.

The earlier audit checkpoint retained owned diagnostic sources, sanitized native
logs, frame-presentation evidence and selected captures under validation_issue318.
At that checkpoint production textures, sprites, models and maps were unchanged.
Runtime packages, installed IWAD/engine, collector
executables and generated map fixtures remain local under build; they are not
redistributed. The collinear map control permits changed texture phase and thermal
shelter classification, so it is not accepted artwork or a production replacement.
See its [results and provenance](../assets/validation_issue318/RESULTS.md).

## 5.4.25 - Soldier representation benchmark (#304)

The isolated sprite/model comparison reuses the owned Domingo MD3 and texture
from #283 as an author-approved visual substitute for soldiers. It introduces
no new art or soldier balance. The diagnostic MODELDEF maps the actual soldier's
frames without adding proxy actors or AI. The prototype has 10,689 vertices and
17,447 triangles. In the frozen 600-soldier render control, median render callback
intervals are 2.93-3.08 ms for sprites and about 5.35 ms for MD3; both maintain
35 simulation tics/s. These callbacks are not displayed FPS. See validation_5425
for captures, native rendering counters, repeated measurements and limitations.
Production soldier presentation and the future modular migration remain unchanged.

## 5.4.24 - Zupay cosmetic rock projectile (#284)

The original deterministic OBJ boulder is generated by
`assets/generators/generate_zupay_rock.py`, with editable dimensions and a pinned
reference hash in `assets/source/art/zupay_rock_5424/DESIGN.json`. Its UVs reuse
unchanged rock pixels from the existing owned ZUPYN1 throw sprite; no bitmap is
edited and no external mesh is imported. The native TEXTURES fallback crops the
same source nondestructively. Attribution is retained in ZUPAY_ROCK_5424.txt.
The mesh has 128 vertex positions, 576 face UVs and 192 triangles. Dominant-face
projection avoids the stretching found during side review; its visual dimensions
follow the held rock, independent of the unchanged projectile collision.

Only Zupay-owned explosive shots adopt the new native MODELDEF frame. Elemental
lights/trails/impact effects and all flight/combat properties stay authoritative.
Native throw/flight and front/side model review pass, with an exact export repeat.
The earlier player-camera relocation fixture and stretched side UVs remain
recorded as superseded candidates. CA284-01 passed author visual review on 2026-10-15.

## 5.4.23 - Editable Domingo 3D prototype (#283, accepted)

The author accepted the corrected prototype and ended #283 on 2026-10-15.
CA283-02 is accepted. The V5.17 roadmap now owns modular sprite-to-model migration,
remaining timed animations and fine polish. Earlier review labels below retain
their historical stage; they do not reopen the accepted prototype.

The identity reference is the author-supplied original Domingo sheet from
2026-10-09 (`assets/source/art/death_repair_518/domingo-original.png`, SHA256
`4eb6162dc54d0117e23826ca8067b16851588c42948ad19cd05982c0e20f55f3`).
The pilot interprets its dark hair/beard, steel/gold armor, red scarf, blue/gold
cape, right sword and left shield as volumetric geometry. The later modular
human bodies are not the identity reference. The author now prefers polished human 3D
references for anatomy, rather than limiting the mesh to the sprite silhouette.

The initial author trial found sideways knee flexion and rigid walking elbows.
The corrective candidate sets the forward knee-pole plane and animates elbow
flexion during walk/run; 186 evaluated joint samples and rendered comparisons
check the change. Geometry/texture/frame counts are unchanged. See
validation_5423/anatomy-joints.json and anatomy-evidence.json; visual acceptance
was pending at that stage. The manual fixture starts from the front and follows its
selected review angle, with the native chase flag reserved for following mode.

Further author feedback requires less hand sway while walking and a distinct
running animation. The revised Walk arm curves keep a small elbow bend and a
short hand arc; Run uses more flexed elbows and a broader arm swing. Measured
walking hand excursion is 23-28% of the previous candidate, relative to the
shoulder. Native action periods, root/leg motion and all other model poses are
unchanged. DESIGN.json owns the art curves; arm-motion-joints.json and
arm-motion-evidence.json separate this revision from prior evidence. The manual
fixture explicitly starts walking with Shift held to run, rather than inheriting
the previous test configuration's enabled always-run setting. Review was pending
at that stage and is now covered by the final prototype acceptance.

The author found the walk/run revision better, then requested a perpendicular
running sword grip, more human head anatomy and better hair. The current head
and eye volumes adapt MakeHuman hm08 (CC0-1.0), with reduced topology, project
proportions/UVs and head-bone weights. The pinned upstream source and complete
license live in `assets/source/art/domingo_3d_pilot/makehuman/`; runtime attribution
is in DOMINGO_3D_PILOT.txt and MAKEHUMAN_CC0.txt. Snow (Blender Studio) and a male
head scan (petemc) supplied visual references only; DESIGN.json records URLs and
roles. The hair is project-authored fitted scalp/curved tapered locks. Run rotates
the sword around its held grip center; other native actions retain their geometry
outside the revised head/hair. The author provisionally accepted this candidate on 2026-10-15, deferring fine
visual polish. Its evidence
is separate in validation_5423/head-grip-evidence.json.

On return, the author required interchangeable weapons, shields, armor, hair
and faces, starting with Domingo and existing appearance/equipment choices.
The editable source has separate mesh objects, but this first runtime export
merges them into one fixed surface. It does not yet meet that modular contract.
The author subsequently moved this requirement to the future V5.17 roadmap,
closing #283 as an accepted fixed-surface prototype. The migration must use
reusable parts and native saved identity; it has not been implemented here.

`assets/source/art/domingo_3d_pilot/domingo.blend` contains editable mesh/UVs,
26 rig bones including foot IK/poles, packed source-derived texture and 24 named
actions. DESIGN.json records provenance, coverage, timing and pending decisions.
The .blend is authoritative art input; the retained initial authoring transcript
is construction history, not a byte-identical Blender-file regeneration tool.
The skin keeps original RGB and makes alpha opaque for UV sampling. It is
1254 x 1254, 1,863,217 PNG bytes. No Doom artwork is incorporated.

Blender 4.5.3 LTS exports deterministically with:
`blender -b --python assets/generators/export_domingo_pilot.py -- --output build/issue283-export --install`.
The exporter reads the committed source, bakes a native MD3 v15 with one surface,
10,689 UV-split vertices, 17,447 triangles and 375 frames (32,383,160 bytes), and
generates state/texture/model registrations. The exact GZDoom 4.14.2 loader was
checked before export. No Blender executable, IWAD or generated test PK3 ships.

The opt-in player subclass supports sword/shield idle, walk/run, native attack
poses, pain/death/raise and seated/lying breathing. New guard variants raise the
shield while retaining idle/walk/run and jump/landing leg motion. JumpPrepare
lowers the body and flexes the knees forward over 10 native tics; Landing reverses
that movement over 35 tics. The author's subsequent correction attaches the
shield to hand.L, with a visible rear grip centered in the closed gauntlet. In
relaxed poses its face points outward and its plane extends forward/back beside
the body; guard raises the shield forward while maintaining the same hand
contact. Unrelated geometry/poses are preserved. All 375 frame identities remain,
with DESIGN.json mapping existing jump poses onto the shorter playback timing.
Guard/jump visual acceptance is recorded as CA283-02; the
provisional CA283-01 acceptance applies to the preceding candidate. Other equipment and crouch
retain existing appearance. Native furniture offsets and the 47-unit seat
support are retained; the cape folds onto the chair. Original sprites remain
available for comparison. Standing geometry uses the existing 170-unit human
normalization and native sprite pixel stretch, without changing collision.

This is an accepted prototype, not a completed conversion of other actors. Sit/stand and lie/get-up
clips are editable candidates, not yet connected to gameplay. The author chose
2 seconds for sitting/standing from a chair, 3 seconds for lying/getting up,
and 4-second eating/drinking cycles. The future implementation must disable
movement, attacks and blocking during those animations, while keeping provision
speed and quantities unchanged. The
current tested intermediate still changes rest pose immediately. Small transient
floor intersections in death/raise and source-only crouch also need art polish;
the measured bounds and native evidence are in validation_5423. Additional
transition/weapon coverage, focused review of future changes and a broader
representative combat benchmark remain roadmap work. No large-battle performance
improvement is claimed.



## 5.4.22 - Quick-use HUD artwork (#282)

The bottom-center selector reads existing project-owned inventory icons. Its
selected preview is 40 HUD units, neighbors 30, using native HUD scale; labels
appear above the icons. No bitmap or model is generated or replaced. Individual
water-container icons and their contents retain their inventory identity.
Visual evidence: validation_5422; author acceptance remains pending.

## 5.4.21 - Channel Seal presentation (#252)

Channeling uses GZDoom's native chasecam and restores the owner's previous camera
mode afterward. A non-solid flat sprite follows the ground below the caster at twice the pressure
trap scale (0.75 versus 0.375, 96 versus 48 map units). Fire/Earth/Quintessence reuse
CMNF/CMNE/CMNQ; new CMNW/CMNA aliases reference the already-owned Water/Air jewelry
icons. No bitmap, model or audio source is replaced and no Doom asset is added to
the runtime. The Earth visual quake uses the native silent shake-only API; its
damage and force come solely from the authored gameplay calculation. The final
native chasecam capture was visually inspected; all five emblems and camera
restoration pass focused native checks in validation_5421. CA252-01 passed author
review on 2026-10-15. A 0.5-unit cosmetic WorldOffset along the camera depth axis
resolves transparent-sprite depth ties so the emblem draws behind the body; its
physical ground origin and artwork are unchanged. Fixture maps/IWADs remain local and are not distributed.

The author's visual correction registers Water/Air frames explicitly, removing
the invalid dynamic sprite lookup that displayed a face. A downward native trace
anchors the horizontal mark to real floors, including native 3D floors and solid
actor architecture, even when the caster is airborne. All five emblems remain
the existing jewelry art; no image source was repainted.

A separate cosmetic orb now floats directly above the caster's head. It uses
Arcane Sun's existing scale and the matching primary-element VFX animation;
texture dimensions determine its height so its lower edge clears the head.
It has no mass, collision, damage, heat or child projectiles. Stop, interruption
and departure remove both visuals. Older active channels recreate the missing
orb idempotently; climate state is unchanged. F7/F8 in the isolated review scene
provide wide-orb/close-ground views without changing production camera settings.


## 5.4.20 - Mounted Arcane Cloud presentation (#251)

The owned 5.4.5 mesh, palette, shader and original generator remain unchanged.
CaelumArcaneCloudModel binds them through MODELDEF with the covered cart's full
82-unit width (2.5625 m), scaled by Eloquence. The existing seated pose and pelvis
anchor place the rider above the cloud. The model has zero mass and no solid
body; player collision remains native. Deterministic cosmetic drops stop at
traced surfaces, with the established dense-combat VFX cadence. The surface
material still has the documented concave-band limitation (CA-KP-104); it is not
volumetric weather. Native gameplay/capture fixtures: validation_5420. CA251-01 author review
passed on 2026-10-15 for the offered gameplay/visual scene. Test geometry,
development IWAD, executables, saves and generated packages are not distributed.

## 5.4.19 - Redemption asset reuse (#250)

Reuse owned existing corpses, living actor art and shared class hands/HUD. Native
and gameplay fixture sources live in assets/validation_5419. Deterministic test
rooms reuse validation_5418 geometry. Native before/active/expired captures were
visually reviewed; CA250-01 passed author review on 2026-10-15. Development IWAD textures,
generated packages, saves and captures stay outside src. No new artwork or
distribution license is introduced.

## 5.4.18 - Summoning asset reuse (#249)

The temporary allied Zupay reuses the current owned sprites, animations, sounds,
projectile art and class hands/HUD. No new artwork or redistribution dependency is
introduced. Deterministic isolated fixture sources and runners are in
assets/validation_5418; generated native packages, logs, saves and captures remain
local in build/. Native visual review confirms reused Zupay art, Spanish test
overlay and shared HUD. Author CA249-01 passed on 2026-10-15. No development IWAD
resources are added to the product.

## 5.4.17 - Rally integration and isolated evidence (#248)

Reuse existing class hands, Cleric HUD icon, owned characters and localized UI.
No new art or distribution rights are introduced. assets/validation_5417 contains
the isolated room/occlusion fixture, native runner and evidence for Rally; generated
packages, saves, screenshots and logs remain in build/. These development maps
use the local IWAD and are not packaged with the product. The 16,166 normal
package members match src and the frozen runtime. Native/static checks pass;
agent visual review confirms the Spanish control/resource/last-hit overlay and
class HUD. CA248-01 passed author review on 2026-10-15; acceptance.json retains
the offered scenario and frozen-build identity.

## 5.4.16 - Formation Breaker residual appearance (#247)

Afterimages reuse the current owned player body sprite/frame, scale, facing,
translation and modular face/hair overlay. They add no raster/model source or
external attribution. Frozen actors are noninteractive, translucent at 50%,
emitted per 0.1 seconds of actual traversal and fade over 0.3 seconds (35-Hz tic
quantization). Development fixture sources live in assets/validation_5416; generated
packages, development IWADs and saves remain local under build/. Visual/native
validation passes; the agent inspected the final body/head alignment and fading
trail. Evidence/hashes are in validation_5416/evidence.json, separately from
CA247-01 author appearance acceptance, confirmed on 2026-10-15.

## 5.4.15 - Movement validation fixtures (#260)

assets/validation_5415 contains deterministic isolated maps, native command tests
and launchers for ordinary acceleration and directional impulses. No runtime art
is added. Packages, saves, private IWAD and engine files remain local build evidence.

## 5.4.7 - Telekinesis validation fixtures (#241)

assets/validation_547 contains isolated native test actors, packaging, launch and
rollback helpers. Runtime artwork is reused unchanged. Generated test PK3s,
captures, development IWADs and engine files remain outside src and distribution.

## 5.4.5 - Reusable dark rain cloud (#251, in progress)

`assets/rain_cloud/DESIGN.json` describes original density lobes, palette and
preview-only presentation settings. `generate_rain_cloud.py` uses Python's
standard library and marching tetrahedra to produce one closed, consistently
wound OBJ shell: 3,752 vertices, 7,500 triangles, one connected component and
Euler characteristic 2. OBJ axes are X width, Y up/base 0, Z depth; width is 2
art units. No world dimension, collision shape or rider anchor is approved here.
The generator also writes the palette PNG and soft-edge GLSL material; manifest
hashes and repeatability are checked by validation_545/verify_asset.py.

Runtime resources live in `src/models/caelum/weather/` and
`src/shaders/caelum/rain_cloud.fp`, with the material registered in GLDEFS.
The material uses GZDoom 4.14.2 SetupMaterial, world normals and view direction
to soften grazing contours and suppress back-facing fragments. It has no clock
or gameplay state. It remains a surface-based model, not a volumetric weather
simulation; overlapping concave contours can remain visible. Native Vulkan and
OpenGL previews show the checkerboard behind the volume from front, sides, back,
above and below. Shape, translucency and the seated-character composition still
require author review. The source has no external art/model dependencies or Doom
assets; provenance is in src/licenses/RAIN_CLOUD_545.txt.

The preview actor, model registration and original checkerboard room are isolated
fixtures, outside src. Production does not spawn the asset yet. No seating,
flight, rain, lightning or weather behavior is claimed. Earlier shape/material
iterations are retained as diagnostic evidence; assets/validation_545/RESULTS.md
records exact tested packages and the limits of this checkpoint.

## 5.4.4 - Class preparation hands (#238)

The same-version left class/racial HUD reuses ca_hud_combat_charge.png and
ca_hud_combat_affected_targets.png from the existing owned HUD icon set. No new
icon artwork is generated; generic labels identify their presentation roles.

The presentation reuses owned closed fists and palms with saved appearance/glove
selection. Inspection found the existing male equal-height atlas extraction clips
part of the previous row into the palm cells. The new cast-only pipeline extracts
the actual last row from the original human/wolf/bear/puma/jaguar atlases under
assets/source/art/appearance_5213. Source artwork is unchanged; existing accepted
weapon modules and their registration are unchanged. Female and gloved palms
continue to use their existing registrations.

`assets/generators/generate_class_cast_palms.py` (Pillow 11.3.0) reuses the existing
fit, tint and deterministic PNG helpers. Cropping coordinates are data in
class_cast_palms.json. Thirty-six cast-only PNGs and their native textures/states
regenerate byte-for-byte; hashes and original provenance are in
assets/validation_544/palms.json. Presentation timing, pivots and framing live in
CaelumClassCastLayout. Native captures exposed both the atlas-row defect and
stale interpolation origins when composed weapons recreate hand overlays; the
component now supplies its own origins. The author passed preparation and smaller
HUD icons in CA238-01 on 2026-10-14; this does not accept the new creature poses.

The built-in image_gen tool painted eight living sleep views per rat, Bull,
Mandinga and Zupay. Animals lie naturally; the two bipeds lie supine. Source
art, exact original/revised prompts, references, hashes and rejected candidates
are preserved under assets/source/art/sleep_544. The first animal atlases repeated
a rear direction; revised candidates correct it. The first Mandinga atlas was
rejected for face-down/overlapping views. No wounded death frame is reused.

register_sleep_creatures.py uses Pillow 11.3.0 for connected-silhouette crops,
alpha cleanup and resampling. Calibration is data in sleep_creatures.json: match
existing animal side-view length or biped standing height and reuse accepted
biped sleep foreshortening. Native actor and texture scales are retained. The
32 PNGs, registration and manifest regenerate byte-for-byte. Runtime art is
under src/graphics/caelum/sleep_creatures; provenance is packaged in
licenses/sleep_creatures_544.txt. Eight-angle engine captures verify the native
direction order, transparency and ground placement. The author passed CA238-02
on 2026-10-14; exact scope and frozen build: validation_544/sleep_acceptance.json.
The optional same-version rollback bridge retains these exact appended states
and owned graphics so saved pose pointers remain valid. It creates no new art.
Native schema round-trip evidence: validation_544/rollback_evidence.json.

## 5.4.3 - Original procedural rat audio (#254)

Four mono 22,050-Hz signed 16-bit PCM cues cover alert (0.38 s), bite (0.17 s),
pain (0.29 s) and death (0.58 s). No suitable rat source was found in the existing
audio inventory. These cues use original deterministic oscillator/noise synthesis,
with no external recordings or Doom audio. Rebuild with
`python assets/generators/generate_rat_audio.py`; editorial parameters and seed
live in `assets/generators/rat_audio.json`. All four outputs regenerate byte-for-byte.

Runtime files: `src/sounds/caelum/enemies/rat/`; rights/provenance:
`src/licenses/rat_audio_543.txt` and repository LICENSE.md. The manifest in
`assets/validation_543/rat_audio.json` records hashes, durations, RMS, peak and
zero endpoints. SNDINFO registers each cue with a local 3/512 instance limit.
The final native fixture verifies recognition, bite, pain and death triggers.
The author separately passed CA254-01 movement/listening review on 2026-10-14.

## 5.3.8 - Existing quest text and known-place links (#235)

The 2026-10-14 spatial-marker follow-up reuses the owned HUD target symbol
`src/graphics/caelum/ui/hud/icons/ca_hud_combat_affected_targets.png`. No new
bitmap or attribution is introduced. A tracked known destination temporarily
uses this symbol instead of its ordinary POI category icon.

`CaelumQuestTrackingData` associates existing LANGUAGE objective keys with #234
POI identities; no coordinate, map, bitmap, font or provenance is added. Shared
Journal/map adapters reuse existing bilingual mission and stage text. New labels
cover only tracking controls, known/unknown locations and overflow. Screenshots,
native fixtures and results live in assets/validation_538; engine/IWAD/save/PK3
inputs remain local. Existing paper-map and Journal assets remain authoritative.

## 5.3.7 - Authored cartographic data and symbols (#234)

`assets/map01_mansion/CARTOGRAPHY.json` lists the ten ordinary room interiors,
storeys and stable names against the existing WAD, REPAIR/PRACTICE data and
furniture/workshop placement, with native collision traces confirming the
ground-floor side-door strips. `generate_cartography_catalogue.py` derives room
data, CITY.json tower/east-arch geometry and native TEXTMAP checksums without
modifying a map. Its output is `CaelumCartographyCatalogueData.zs`; regeneration
must be byte-for-byte deterministic. Read-only project validation rejects stale
output, and a changed mansion checksum requires reviewing its room data before
regeneration. Service coordinates come from the actual
interacted actors, never a second coordinate table.
Rooms reuse the owned Journal reputation emblem, towers the shields-category
icon and closed/unknown grates the locked-action icon. Manual notes retain their
paper icon; other service symbols remain #232's. The initial access-state fix
used the existing Use hand for open grates. On 2026-10-14 the author confirmed
that it changed but clarified the expected symbol: an open padlock.
Built-in imagegen edited the project-owned closed padlock into the original
transparent counterpart at `graphics/caelum/ui/journal/icons/ca_ui_action_unlocked.png`.
The 1254x1254 RGBA output was copied byte-for-byte to runtime and
`assets/art_source/ca_ui_action_unlocked_537.png`; alpha and source are preserved,
without resampling or a generator. Existing native ICON_SIZE controls placement.
The prompt, reference/output hashes and method are recorded in
`assets/manifests/map_grate_unlocked_537.json`. No font, third-party asset, game
actor, closed-padlock replacement or change to the Use/exit hand is introduced.
Native closed/open/reloaded captures are in assets/validation_537. The author
accepted the new artwork and save/load on 2026-10-14. Bilingual names remain in LANGUAGE
and its localization index. Test packages/saves remain local.
The city follow-up reuses these padlocks for observed physical gate states and
the existing crafting emblem for factory stations. No additional artwork is
introduced. The catalogue generator derives 96 station identities from CITY.json
and INTERIORS.json, using the same building/profile/slot order as the existing
interior generator. It does not rebuild the WAD; regression preparation verifies
each slot and editor type against its actual MAP06 thing. Positions shown on the
map come from the interacted actor; its original SpawnPoint supplies identity.
The author accepted the focused city padlock/station presentation and save/load
on 2026-10-14; this does not certify every factory or ordinary city traversal.

## 5.3.6 - Manual note presentation (#233)

Manual markers reuse `graphics/caelum/ui/journal/icons/ca_ui_nav_quests.png`,
the owned Journal paper/quests icon. A consistent paper symbol distinguishes
written guesses from discovered service icons; category/text remain visible in
the list and nearest-center label. Existing Caelum fonts and Journal panels
frame the native list and TextEnterMenu. No bitmap, external asset, font source
or generator was added or modified. Provenance remains with the original owned
Journal assets. Bilingual text lives in LANGUAGE and its generated index.

## 5.3.5 - Known-service map icons (#232)

No new or edited bitmap, font, external asset or generator is introduced.
`CaelumPoiData.IconPath` reuses the owned sleep HUD icon, crafts navigation icon,
gold coin, use action icon and world navigation icon for the five categories.
Original provenance remains under the corresponding retained HUD/Journal/item
asset records. The map uses native icon projection at a fixed presentation
size; the name/category comes from the known fact and bilingual LANGUAGE keys.
Sources, native logs and captures are retained in assets/validation_535;
development packages, saves, executable and IWAD remain local.

## 5.3.4 - Local cartographic presentation (#231)

No new bitmap, font, engine or IWAD asset is distributed. Existing CaelumDisplay
and CaelumText fonts remain under their retained provenance. Owned paper/ink
colors live in `src/caelum/data/cartography.mapinfo`; layout measures and frame
colors live in `CaelumCartographyLayout.zs`. They are source data, not generated
images. GZDoom draws the existing map geometry, player arrow and numbered marks.
Native palette opt-out and texture preferences remain intact. Agent-generated
renderer captures and reproducible fixtures: assets/validation_534; author
visual acceptance passed CA231-01 on 2026-10-13.

## 5.3.1 - Survival and Character presentation (#256)

Reused all six retained HUD icons and Hunger/Thirst/Sleep/thermal icons without
editing pixels. Character uses existing fonts and native menu controls.
assets/validation_531 contains isolated fixture sources, logs and captures;
generated packages, saves, engine and development IWAD stay local in build.

## 5.3.0 - Power indicator presentation (#255)

Existing Seal and Tarot artwork/provenance are reused without pixel edits.
Reference rectangles become 88x88 and 64x96; viewport scaling can cap them.
assets/validation_530 holds source fixtures and evidence; generated packages,
saves and development dependencies remain local in build/issue255.

## 5.2.27 - Magic Box weight evidence (#229)

assets/validation_5227 retains the isolated native weight/save probe and result
record. No art, audio or model changes. Generated test packages, saves and engine
dependencies remain local under build/issue229.

## 5.2.26 - Rest feedback validation (#227)

No art, sounds or map assets change. assets/validation_5226 retains the isolated
native probe/runner and result record for rest key/click dispatch, real mansion
furniture, safety rejections and visible messages. Runtime/test packages, saves
and development dependencies stay local under build/issue227. CA227-01 passed
author acceptance on 2026-10-13 without qualifications.

## 5.2.23 - Sewer bag sleep (#219)

Reuse the existing sleeping bag, supine character pose and native rest/skip UI.
No generated art, models, sounds or provenance change. The generic T help no
longer claims a safe marker is always required; danger messages remain.
Native evidence: assets/validation_5223; author check CA219-01 accepted 2026-10-13.

## 5.2.22 - Menu control captions (#215)

No artwork, fonts, sounds or provenance change. Parenthesized bilingual text
uses existing fonts and native menu transforms. Custom button captions fit
complete hints within their bounds; creator previews and card images remain.
Native visual evidence and deterministic fixtures: assets/validation_5222.
CA215-01 passed author visual/input acceptance on 2026-10-13.

## 5.2.21 - Visible tutorial gold (#216)

Fresh MAP01 games spawned the finite 2 kg gold actor with collision but no
model registration for its subclass. Register the existing gold-rock OBJ for
CaelumTutorialGoldVein; keep placement, harvesting, quota and depletion intact.
Native before/after captures and extraction/save-load checks are recorded in
assets/validation_5221. Author visual acceptance CA216-01 passed author acceptance on 2026-10-13.

## 5.2.20 - Resource HUD layout (#213)

Reuse the existing HUD component PNGs, icons, laurels and CaelumMono font.
No artwork is generated or changed. Each resource group is anchored to its
lower screen edge, enlarged 95% over native HUD scaling within measured
viewport limits, and labelled above the bars. Validation sources and selected
native captures live in assets/validation_5220; generated PK3s and INIs stay
local under build/issue213.

## 5.2.19 - Horizontal impact diagnostics (#211)

No art, sound or world geometry changes. assets/validation_5219 records isolated
GZDoom fixtures, baseline regression, load/impairment and buckler cases,
bilateral bull contacts, charge motion, persistence, revised falls and unchanged
crushing. No new production test actor is packaged.
Diagnostic packages, user configs, saves, engine and IWAD remain local in build.

## 5.2.18 - Authored poses, female hands and dining model (#209)

Supersedes the shared-sex hand and rigged run/punch/sleep/death coverage in the
5.2.13 inventory below. Saved humanoid face/hair choices remain modular. New
source paintings cover male/female running, punch anticipation/drive/extension/
recovery, three actual death stages, and eight-direction supine sleep. The
death settle holds its final authored pose without changing native state timing.
Run uses two painted phases and their opposite mirrored half-cycle. The punch
uses complete body paintings, with no arm crop that can drag trouser pixels.
Sitting keeps the accepted crouched body and aligns its support to furniture.

Domingo's owned poses and anatomical forms are references except rear attack;
the Revenant supplies only the requested motion idea. Source art, retained
superseded candidates, exact built-in imagegen prompts/reference hashes and
portable reference boards are in assets/source/art/appearance_5218/PROVENANCE.json.
The author authorized deterministic Python cropping, masks and registration.
Technical projection foreshortens supine depth from the low world camera;
eight native directions retain world heading rather than tracking one camera.
Low-alpha source fringes are removed after resampling. Grounding moves the body
and neck together to avoid native default sprite-floor correction separating
them. This is not a guarantee for every engine sprite-clipping setting.

Current registration: 33 semantic poses, 22,176 body compositions, 2,288 world
modules; 1,728 humanoid looks, five anchor groups per sex, 69,120 head textures,
8,640 head frames and 3,072 face/hair modules. Only required transforms are
generated. Old tracked resources are retained; unused experimental new outputs
are outside src. New manifests preserve the original #148 registration records.

First-person hands have 37 variants: the original 18 bare male variants, 18
female skin/fur variants and one shared female glove variant. Male equipped
gloves retain the accepted original art. Six selected female atlases cover
human/Caelith/goblin skin, wolf, bear, puma, jaguar and gloves, with grip, fists,
shield, bolas and shotgun reload poses. Weapon patches and grip pivots remain
unchanged. The native registry has 1,850 labels and 1,443 banks; 770 shared PNG
modules avoid a weapon-by-identity painted product.

The original ca_large_canteen.obj mesh adds beveled depth, cap and strap to the
dining display, reusing the owned canteen_large.png icon as its texture. Its
generator triangulates polygon caps for the native OBJ reader. The existing
0.25 display scale and underlying inventory item are retained.

Rebuild with Pillow 11.3.0: generate_modular_appearance.py,
generate_appearance_details.py, generate_appearance_hands.py and
generate_dining_canteen.py under assets/generators. Registration/mask/pose data
are in appearance_catalog.json; appearance_pose_modules.py performs technical
source registration. Evidence and limits: assets/validation_5218/RESULTS.md.
CA209-01 and CA209-02 passed author visual acceptance on 2026-10-12 without
qualifications; this confirmation is separate from source generation.

## 5.2.17 - Preserve the living tutorial appearance (#207)

No new art/audio assets. The MAP01 1 HP floor retains the living player and
its modular appearance actors instead of entering the death/respawn path.
assets/validation_5217 retains isolated native fixtures, sanitized logs, hashes
and limits; local INIs, saves, engine packages and development IWADs are excluded.
This does not claim a general appearance-after-respawn repair on other maps.

## 5.2.16 - Fullscreen cursor evidence (#204)

The native 32x32 moon cursor, hotspot and all packaged artwork remain unchanged.
The author approved the existing native VSync setting after physical fullscreen
tests; no generated cursor, engine fork or dependency is distributed.
assets/validation_5216 retains console probes, logs, source hashes and explicit
author observations. INIs, saves, executables and development IWADs remain local.

## 5.2.15 - Presentation scaling and native feedback (#150)

No new art/audio assets. Existing HUD frames, thermal bands, outlines, icons,
card art and character previews are scaled through their shared presentation
adapter; first-person sprites retain their native bob and action poses.
The native crosshair uses engine-provided artwork without copying it into src.
Fonts and English/Spanish text retain their sources in LANGUAGE and the
localization index. The new notice history stores text, not rendered images.
Reproducible native fixtures, captures, source hashes and limits are retained in
assets/validation_5215. CA150-01 passed author visual/comfort acceptance on
2026-10-12 without qualifications.

## 5.2.14 - Native control presentation and test sources (#149)

No new art/audio assets. Bilingual labels and late-bound hint tokens remain in
LANGUAGE; the localization index is regenerated. The deterministic
assets/generators/controls_catalog.json and generate_controls.py produce native
DEFBINDS, explicit-reset KEYCONF aliases and the portable first-start preset.
Existing native fonts, menus and controller key names provide presentation.
assets/validation_5214 contains reproducible fixtures, retained engine evidence
and limits. CA149-01 passed on 2026-10-12; CA148-01 visual acceptance passed on
2026-10-12, with PR201 merged b21e0632 and #148 closed.

## 5.2.13 - Modular saved appearance and first-person hands (#148)

Read [SPRITE_ART_DIRECTION](SPRITE_ART_DIRECTION.md) before generating sprites.
The author requested this dedicated visual brief and an extension with four
faces/four hairstyles per humanoid race/sex and six hair colors, editable during
play. Both the initial body/hands integration and that extension are implemented;
CA148-01 passed author visual acceptance on 2026-10-12.

Author-approved plain shirt/trousers/boots replace the player's fixed armored
Domingo presentation. Heads, clothes and exposed hands are separate modules;
native TEXTURES composes them without storing a full identity/pose PNG product.
Original Domingo, Caella and equipment resources are preserved.

| Supported choice | World/preview | First-person | Voice |
| --- | --- | --- | --- |
| Human, male/female | Separate head/body; three natural skin tones; four faces/four hairstyles/six hair colors | Shared human hand geometry, matching tone | Saved sex |
| Goblin, male/female | Separate heads, scaled body; three natural skin tones; four faces/four hairstyles/six hair colors | Shared human hand geometry, matching tone | Saved sex |
| Caelith, male/female | Separate heads/bodies; RGB skin; four faces/four hairstyles/six hair colors | Shared hand geometry with RGB skin | Saved sex |
| Beast Man, male/female | Wolf/bear/puma/jaguar head modules, sex body modules; three natural fur tones each | Animal-specific hands, shared between sexes | Saved sex |
| Equipped gloves | Shared brown glove presentation | Existing accepted glove resources | Unchanged |

There are 14 body identities, 42 body/tone combinations, 29 visual poses and eight views,
with bare/gloved variants: 19,488 native compositions and 2,976 world module PNGs.
First-person resources use 18 bare variants, 375 modules and 702 registered
sprite banks. Shared hand/shield/bolas/shotgun/fallback compositions preserve
weapon patches and source pivots. World scale uses measured standing alpha
height and the existing physical capsule height. Native Blend modulation colors
exposed hand masks without recoloring clothing, hair or weapon patches.

The humanoid extension adds 1,728 head looks, with seven reusable anchor groups
and eight native views: 96,768 small head textures, 12,096 registered frames and
3,840 shared face/hair PNG modules. Hair uses catalog RGB Blend values, without
quantizing the face/body through actor palette translations. A complete
body/face/hair/color product would need 100,224 humanoid frames alone, exceeding
GZDoom 4.14.2's 16-bit frame index. Native view-specific offsets plus the pose's
common displacement preserve alignment without selecting a main camera.

A noninteractive head actor follows its body's position, interpolation, floor
clip, effective crouch scale and saved/death profile. Hub-restored duplicates
discard themselves unless they are the body's current module. MAPINFO's
AddDefaultMap forces compat_spritesort=0 for Caelum maps so the newer head draws
over the body at equal depth, without writing the user's global preference.
The preview draws the same body/head textures without creating actors. Hair
length does not alter physical height or the standing-height scale reference.

These resources cover existing state families, not a complete newly authored
animation catalogue. Walk cycles use a shared authored body; some attack, pain,
fall and rest poses reuse a deterministic rig. Sitting/kneeling share a crouched
body and firearm locomotion shares held poses. Material-specific gloves, clothing
color selectors, a full world weapon/armor wardrobe and independent voices are
not offered. Existing carbine/shotgun world presentations remain supported.

Sources and exact built-in imagegen prompts/references are retained in
assets/source/art/appearance_5213/PROVENANCE.json, including discarded drafts.
The original female goblin module derives from owned Caella art and is retained.
The new face/hair atlases, reference hashes and exact prompts are recorded in
FACE_HAIR_PROVENANCE.json. Technical cutting, masks,
anchors and packing with Python were explicitly authorized by the author.
Rebuild with Pillow 11.3.0 using assets/generators/generate_modular_appearance.py
and generate_appearance_hands.py, then generate_appearance_details.py;
appearance_catalog.json is the shared catalog. REGISTRATION.json,
HAND_REGISTRATION.json and DETAIL_REGISTRATION.json record output hashes.
The initial generators matched 3,355 outputs on repeat; the detail generator
separately matched all 3,843 outputs byte for byte. Alpha-component registration
handles imperfect atlas gutters and excludes detached source debris; original
atlases are preserved. The 24-face contact sheet and native captures document fit.

CaelumCharacterPreview adapts GZDoom g4.14.2 playerdisplay.zs state stepping and
GetSpriteTexture drawing. Christoph Oelckers' BSD notice is retained in the
packaged source. No Doom artwork or test IWAD is distributed. Before/after native
captures and scoped validation: assets/validation_5213/RESULTS.md. CA148-01
passed author acceptance on 2026-10-12; texture registration is not a GPU benchmark.

## 5.2.12 - Bull and resident diagnostics (#195)

Existing bull run and resident attack sprites are reused; new action poses are
appended to preserve existing state indices. No new artwork, sound, map geometry
or attribution changes. assets/validation_5212 keeps native fixture sources,
logs, package hashes and a live MAP01 capture. Generated PK3s, maps, saves,
the engine and development IWAD remain local build artifacts.

## 5.2.11 - Collision energy diagnostics (#194)

No art, sound, map geometry, cannon mesh or attribution changes. Runtime
diagnostics display received/cushioned joules and final HP. Native test sources
and text evidence live in assets/validation_5211; generated test maps/packages,
saves, the development IWAD and engine remain local build artifacts.

## 5.2.10 - Ranged descriptions and shotgun resource names (#192)

Bilingual creator ideology and weapon descriptions now state the approved
ranged exclusions and bow/crossbow bypass values. Sixteen retained preconversion
artwork paths now use `shotgun_legacy`; TEXTURES and the optional native-crop
generator reference those paths. Bytes, provenance and historical depictions
are unchanged; current shotgun art still uses its accepted modular renderer.
Development-only sources, native logs, hashes and bilingual captures are in
assets/validation_5210. Engine, IWAD, saves and generated packages remain local.

## 5.2.9 - Personality descriptions and creator layout (#192)

Existing native creator fonts, background and controls render four new bilingual
choice pages and the expanded summary. Bell descriptions now state twelve
projectiles. No new art/audio or third-party resource is introduced.
Development-only fixtures, normalized logs, source hashes, comparisons and
English/Spanish captures are in assets/validation_529. Engine, IWAD, generated
packages and saves stay local and are excluded from the delivery.

## 5.2.8 - Toughness evidence and existing status visuals (#188)

No new art/audio or external resource. Existing burn/poison effects retain
independent visual lifetimes when health resistance shortens or cancels the
harmful dose. Development-only test sources, logs, hashes and results are in
assets/validation_528. Runtime packages, saves, engine and IWAD remain local.

## 5.2.7 - Existing artwork inside native menus (#189)

All Journal panels, inventory icons, Tarot cards, dialogue portraits, native
cursor and existing fonts are retained. The migration changes input ownership
and adds controls using existing drawing helpers; no new art or external asset
is introduced. Development-only fixtures, logs, hashes and captures are under
assets/validation_527, outside the runtime package. Engine/IWAD/save/PK3 fixtures
are local dependencies and are not redistributed.
CA184-01 and CA189-01 passed author acceptance on 2026-10-11 without
qualifications. Original agent evidence remains distinct from that confirmation.

## 5.2.6 - Menu pointer evidence (#184)

Uses existing cursor, card, journal, crafting-item and action-icon artwork;
no external assets or provenance changes. Development-only native fixtures,
run hashes, logs and captures live in assets/validation_526. Only src is packaged.
The fixtures seed an isolated inventory and accelerate completion explicitly;
they do not establish author acceptance. No IWAD, engine, save or test PK3 is
redistributed. The existing UI assets are retained in the #189 migration.

## 5.2.5 - Dialogue source provenance and evidence (#185)

The complete pre-split CAPALOMO source is preserved at
archive/dialogues/5.2.4-CAPALOMO.usdf, including its original line endings and
comments. Authoritative NPC/shared files, their load manifest and generated
runtime/index live under src/dialogues. LANGUAGE text is unchanged apart from
LF normalization; src/localization indexes its source locations. The new paths
have explicit LF attributes for reproducible hashes across checkouts. No art,
audio, map geometry or distribution rights change. Native bilingual captures,
logs, parser/freshness checks and baseline comparison are in assets/validation_525.

## 5.2.4 - Reused onboarding assets and MAP02 generation (#183)

The single basement gold node, existing 2 kg sleeping bag, large canteen, Seals,
profession equipment and resident presentation reuse the current catalogue and
art. No new asset provenance or redistribution rights are introduced. MAP02
generation replaces allocated bullets/cartridges one-for-one with arrows/bolts
and adds an existing armor workshop to each refuge. LAYOUT and the generated
manifest record the campaign distribution; the historical equipment catalogue
remains provenance. Native fixtures/captures/logs and ammunition counts live in
assets/validation_524. Engine, development IWAD, PK3s and saves remain local.

## 5.2.3 - Mandinga targeting evidence (#180)

No sprites, sounds, maps or elemental presentation change. Native fire-breath,
high-density and old-save target checks are retained in assets/validation_523,
without distributing the engine, IWAD, packages or save fixtures.

## 5.2.2 - Time-skip performance evidence (#178)

No art, audio, map or recipe changes. assets/validation_522 contains native
fixtures, logs, timings and static/build evidence. It inherits the existing
development-engine/IWAD boundary; packages and saves remain local fixtures.

## 5.2.1 - Reused tutorial and provision presentation (#177)

The basement chest reuses the existing maze loot panel and chest models. Large
table canteens reuse the existing CW5X pickup sprite and its native scale;
food plates, table geometry and the sleeping bag keep their existing art.
MAP02 bed removal is runtime behavior with occupied-save deferral; no WAD,
source art, attribution or historical map snapshot is replaced or deleted.
Palomo's shotgun, supply and portable-rest explanations remain bilingual.
Native captures and evidence are in assets/validation_521.

## 5.2.0 - Saved identity presentation boundary (#147)

No new art, voices, color palettes or cosmetic catalogue. The existing Domingo
world body, accepted first-person layers, pain cues and breathing cues remain.
NOSKIN prevents a global Doom skin from replacing that body/sound bank. Native
setup no longer advertises unsupported skin/color options or its stock preview.
The shared character profile and saved voice-sex resolver are the interface for
#148; this patch does not claim race/sex-specific world art has been completed.
Bilingual native setting explanations and control labels use LANGUAGE; existing
creation descriptions remain unchanged. Native captures: assets/validation_520.

## 5.1.20 - Existing native door art in MAP06 (#173)

Interior door pairs reuse CaelumHingedDoorLeaf and its existing model, material,
physics and sounds. Existing INTERIORS.json doorway rectangles supply generated
coordinates; no art, WAD geometry or room distribution is replaced. Native
closed/open captures and save/time-boundary evidence: assets/validation_5120.

## 5.1.19 - Shared dialogue history (#172)

Uses existing fonts and native dialogue presentation. English/Spanish replay,
more-options and return labels are in LANGUAGE. No new art or sound. Reviewed
informational-topic data: assets/dialogue_history.json; deterministic generator
emits CaelumDialogueHistoryData.zs. Native evidence: assets/validation_5119.

## 5.1.18 - MAP01 gift presentation (#164)

MAP01 reuses the accepted Tarot deck, utility staff, Pickaxe, bolas, Box and
dummy assets. Bilingual dialogue and Journal text explain permanent ownership,
optional crafting/Channel and manual retries. No new artwork, sound, provenance
or geometry is introduced. Native presentation evidence: assets/validation_5118.

## 5.1.17 - Medikit labels (#169)

The existing small, silver-trimmed medium and silver/gold-trimmed large medikit
art is unchanged. LANGUAGE now labels this health family medikit/botiquín,
including size suffixes and pickup text; the author selected the Spanish term.
No raster asset, provenance, native sprite registration or icon path changes.
English/Spanish inventory and pickup captures: assets/validation_5117.

## 5.1.16 - Original bolas atlas (#163)

The built-in imagegen tool generated an original RGBA atlas of three
leather-covered bronze weights and cowhide thongs. Source, exact prompt,
provenance and measured clips: assets/source/art/bolas_5116. No museum image or
Doom art was copied. assets/generators/register_bolas.py copies the original
pixels unchanged and deterministically registers native TEXTURES for ready,
spin, release, pickup/icon and arm/leg overlays. Recovery uses the existing
dedicated extended hand layer with the released item absent. Native rotation spins around
the fixed grip; restraint overlays scale uniformly to preserve round weights
and remain below the mouth. The author's visual follow-up replaces only the
ready view with ready-hanging.png (READY_PROVENANCE.json records its exact
built-in imagegen edit prompt). All weights hang below the raised grip. Spin
uses 3 Hz while the hand stays fixed. Native TEXTURES clips split each wrap
at its lateral extrema into a lower/front fragment and upper/rear arc. Four
cosmetic actors use opposite camera-facing WorldOffset depths, so the body
occludes the back arcs from every ordinary viewing direction. Their physical
origins and collision remain unchanged; release removes all four layers.
A second author correction adds hand-extended.png, a built-in imagegen edit of
the original upright glove/atlas. HAND_PROVENANCE.json preserves the exact prompt
and references. Native registration uses an uninterrupted sleeve beyond the
screen edge in ready, spin, throw and recovery, without replacing other weapons.
Actual rope burning reuses the existing four-frame burn sprites, scale, opacity
and distance-limited light for the existing 12-tic impact lifetime. This finite
cosmetic actor survives cessation of the paid breath; it has no damage/status.
The original atlas and its superseded ready cell are retained. Runtime: src/graphics/caelum/bolas; validation
captures: assets/validation_5116. CA163-01 passed author acceptance on 2026-10-10.

## 5.1.15 - Bronze utility staff (#162)

Original RGBA artwork provides ready, fire, ice and equip poses of a walnut
shaft with bronze tip. The same ready artwork supplies pickup and inventory
views through native TEXTURES. Original generation, retained first draft,
prompt and measured registration are in assets/source/art/utility_staff_5115.
The atlas is copied byte-for-byte into src/graphics/caelum/utility_staff;
assets/generators/register_utility_staff.py deterministically registers clips,
scales and grip pivots without raster retouching. Existing shared hand layers
hold the tool; fire and ice streams reuse #137's original elemental atlases.
A native dynamic light follows the actual source and is removed on stop.
Provenance: src/licenses/UTILITY_STAFF_5115.txt. No Doom art was imported.

Native 1280x720 ready/fire/ice/release captures and test logs are recorded in
assets/validation_5115. Tool/cap readability, hand alignment and elemental effect
appearance were inspected in engine; CA162-01 passed author acceptance on 2026-10-10.
The unrelated pre-existing art-source deletion remains excluded from this patch.

Author correction, 2026-10-10: rotate the utility staff clockwise into the
existing right-leaning weapon rest pose, around the shared grip. Ready, fire,
ice and equip inherit that pose; the measured emission/light origin follows
the relocated bronze tip. The original atlas, pickup and icon are retained.
Updated native captures and checks: assets/validation_5115/RESULTS.md.

## 5.1.14 - Damage-flash travel validation (#165)

No art, sound, map, model or attribution changes. assets/validation_5114 contains
native fixture sources, before/after screen captures, raw logs, hashes and test
results. Original saves, engine, IWAD and generated packages stay local. The
unrelated author-owned art-source deletion is excluded.

## 5.1.13 - Silver-key validation (#160)

No artwork, audio, model, map or attribution change. assets/validation_5113 stores
isolated native fixture sources, logs, hashes and validation results. Protected
saves and test packages remain local; no engine or IWAD is distributed. The
unrelated author-owned art-source deletion remains outside this patch.

## 5.1.12 - Crafting-size validation (#158)

No art, sound, model, map or attribution changes. assets/validation_5112 holds
isolated deterministic fixture sources, native logs, run hashes and results.
Author saves, test packages, engine and IWAD stay local and are not distributed.
The unrelated author-owned art deletion remains outside this patch.

## 5.1.11 - Time-skip input validation (#156)

No visual/audio assets or attributions changed. assets/validation_5111 contains
isolated native fixture sources, logs and hashes. The original author save,
packaged fixtures, engine and IWAD remain local under build or their original
locations; none is distributed. The unrelated author-owned art deletion remains
excluded from the patch.

## 5.1.10 — Physics validation assets (#154)

No artwork, sprite, model, sound, geometry or attribution change is required.
Existing physical projectile models now follow gravitational flight; elemental
art retains its authored behavior. assets/validation_5110 contains deterministic
isolated fixture sources, native logs/configs, result summaries and package/source
hashes. Runtime fixtures, saves, development IWAD and engine stay out of src and
out of delivery. The author's unrelated deleted art source is excluded from this patch.

## 5.1.9 - Shotgun grip occlusion and cartridge world scale (#152)

Ready/opening poses draw the complete hand layer once below the weapon, keeping
the under-gun support hand the author selected. The earlier foreground copy caused
a visible duplicate and is no longer drawn. Loading hands/cartridges stay in front;
aim continues using canonical carbine hands. Recoil/lowering transform all layers.
Existing state indices and the now-unused foreground states remain for saved games.

The follow-up hands_domingo.png matches the existing FH05A0/FH06A0 references:
brown leather gloves, narrow red wrist bands and dark forearm bracers. Built-in
image_gen edited the separate hand atlas; both exact generated outputs, prompts
and source provenance are in assets/source/art/shotgun_517/HAND_STYLE_519.json.
The first draft's excessive red cloth was replaced in the selected iteration.
Original weapon/hand PNGs remain intact; runtime uses a byte-identical copy of
the selected 1087x1446 PNG and preserves its alpha. Generation did not preserve
the requested 1086x1448 canvas. Native 362-pixel virtual canvases and original
registration anchors are retained without resampling; missing bottom rows are
transparent outside the source. Used first-column silhouettes are checked natively.

assets/source/art/shotgun_517/PICKUP_LAYOUT.json stores the support-hand clipping
coordinate and author-approved 6 cm cartridge world-height reference. This corrects
the reported 37.5 cm pickup artwork without changing its inventory icon, count,
weight or collision. CA152-01 and revised hand appearance (CA152-02) were accepted
by the author on 2026-10-09. Registration and repeatable export,
fourteen native pose captures and existing-save load are in assets/validation_519.

## 5.1.8 - Original elemental atlases and projectile meshes (#137)

Original image_gen artwork, prompts, retained draft, editable visual data and
atlas registration are in assets/source/art/elemental_518. Runtime PNG copies
preserve the generated pixels byte-for-byte; TEXTURES clips cells and supplies
pivots/scales. No raster background removal or palette processing was used.
Cell boundaries follow measured gaps in DESIGN.json, rather than an assumed
uniform grid; native clips keep adjacent elements out of each animation frame.
Three atlases provide nine projectile families, four attached states and four
directional flame phases. The stronger art direction was chosen by the author;
the author accepted the final native appearance on 2026-10-09 (CA137-01/02).

Optional deterministic tools: register_elemental_vfx.py,
generate_projectile_models.py, generate_breath_models.py and
generate_lightning_models.py under assets/generators. Outputs are in
src/graphics/caelum/vfx, src/models/caelum/projectiles and the shared generated
VFX data. Physical meshes reuse the project's original training-dummy wood/iron
atlas; no external mesh was imported. OBJ +X is the native model pitch axis,
Y is up. MODELDEF binds only the flying frame and preserves existing physical
impact states. The existing Doom-dependent development impact puff is unchanged;
this patch does not claim to finish the broader independent-asset migration.

The lightning model is shared by staff, other existing implements and NPCs,
including the Federal prisoner; it is not a hitscan or new attack. Breath planes
use the same range and four visibility segments as the existing ability. Owned
impact/status effects use native alpha and bounded lifetimes. Runtime provenance:
src/licenses/ELEMENTAL_VFX_518.txt. Comparative native captures and measurement
records: assets/validation_518; no PK3, IWAD, save or executable is distributed.

The author supplied the complete original Domingo, rat and bull sheets after
the first death reconstructions. Current DOMI S-Z bindings use the original
Domingo sheet unchanged: measured native subtextures separate the overlapping
corpse silhouettes without repainting pixels. Standing height sets one common
scale. Sources, previous reconstructions and registration are retained in
assets/source/art/death_repair_518; generator register_death_frames.py.

The author explicitly approved code-based background removal for the opaque
animal sheets. assets/source/art/animal_recovery_518 records their provenance,
crop rectangles and masks. recover_rat_frames.py preserves source RGB and valid
legacy alpha, then separates missing regions with seeded, single-thread GrabCut
(Pillow 11.3.0, numpy 2.2.6, OpenCV 4.12.0.88). Seven original death poses occupy
RATG F-M, repeating the last corpse to preserve the eight existing state durations.
Nine movement/pain border cuts are restored; their source-relative grAb anchors
remain unchanged. All 118 bull images were audited; no recut was needed.
Legacy PNGs and prior reconstructions remain available; runtime provenance is
src/licenses/DEATH_REPAIR_518.txt. The author accepted CA137-03 on 2026-10-09.

## 5.1.7 - Modular shotgun artwork and evidence (#136)

Original transparent shotgun artwork was generated with the built-in image_gen
tool. Sources and the full prompt history are in assets/source/art/shotgun_517;
PROMPTS.json identifies selected runtime files and retained intermediate drafts.
The references are project-owned carbine/Domingo artwork. No new Doom art is
introduced. Runtime PNG copies remain byte-identical to the selected sources.

Following the author's hand-reuse request, weapon_layer.png contains complete
T1/T2/T3 guns without hands; the selected hands_muted.png contains foreground
gloves, forearms and held cartridges. The original hands_layer.png is retained.
HAND_STYLE_FOLLOWUP.json records the built-in image_gen color/style edit against
the existing Domingo glove reference. Only the first column is used across tiers.
Ready/reload use fixed 362-pixel canvases, common pivots and layers 50/51 at 0.68
view scale. Aimed hands reuse the carbine's DH05/DH06 poses on layers 48/49,
with the same 0.88 hand scale and placement below the stock. Twenty-one
weapon registrations and seven hand registrations cover ready, aim, empty/partial
opening and one/two-cartridge loading. Recoil and equip/holster transform both
layers together. New hand variants can replace the hand layer independently.
Earlier combined atlases remain source history and are not runtime resources.

Four inventory icons, two world pickups and 48 Domingo world frames supply six
poses in eight directions. register_shotgun.py measures alpha and emits native
TEXTURES clipping without rewriting image pixels. Shared fixed canvases prevent
independent trimming from misaligning hands and gun. REGISTRATION.json records
source hashes and rectangles; repeated exports must match byte-for-byte.
The follow-up native captures compare shotgun/carbine aim and empty, single and
partial loading. Do not clear and recreate the aimed hand overlays every frame:
their first-tic positioning differs from established overlays (fp-followup-a).
The corrected persistent overlays are verified in fp-final.

Native fixtures, selected clean logs/configurations/captures, source hashes and
reproduction commands are in assets/validation_517. They exercise both actual
inputs and deterministic mechanics. The author separately confirmed CA136-01
and CA143-01 passed on 2026-10-08; HISTORY records their original releases.
Development PK3s, IWADs, executables and
saved-game fixtures remain local under build/issue136 and are not distributed.

## 5.1.6 - Crouched Domingo carbine poses (#143)

Original transparent artwork was generated with the built-in image_gen tool
from the project's standing carbine atlas. The unchanged source is retained
at assets/source/art/carbine_crouch_516/atlas.png with prompt specification,
reference and attribution in PROVENANCE.json. Its runtime copy is byte-identical.
No Doom artwork or changed first-person assets are introduced.

Four rows contain eight directions each: crouched aim, fire, reload start and
reload completion. Native TEXTURES clips the original PNG at measured transparent
gaps and foot pivots. `register_carbine_crouch.py` measures alpha only; it does
not rewrite pixels. Explicit newline policy and two repeated exports verify
byte-for-byte deterministic output. CAGC A-D are appended to the existing
registration actor so native rendering never lazily initializes an unknown sprite.

The atlas matches half the standing Domingo artwork's height. The same service
selects these poses for stationary crouched players and soldiers; player moving
crouch retains the accepted walking art. Native captures and input checks live
in assets/validation_516. Agent visual review is separate from CA143-01,
which the author confirmed passed on 2026-10-08.

## 5.1.5 - Demon breath and potion tiers (#135)

Six dedicated transparent potion variants were created with the built-in
ImageGen tool from the project's existing icons. Medium fittings are silver;
large fittings combine silver and gold, including medikits. Small originals
are preserved. Source artwork, reference paths, prompt specifications and hashes:
`assets/art_source/potions_515/PROVENANCE.json`. The deterministic
`assets/generators/export_potion_tiers.ps1` exports 128x128 runtime icons;
TEXTURES registers matching world sprites. All nine identities have EN/ES names.

The author additionally requested dedicated exhalation gestures. Mandinga and
Zupay each receive an original 32-frame atlas: four sustained open-mouth phases
in eight directions, with braced shoulders and slight forward lean. Built-in
ImageGen reference edits, exact prompts and originals are preserved under
`assets/art_source/demon_breath_515`. `register_demon_breath.py` measures alpha
and registers native clipping/foot pivots; it never changes the PNG pixels.
The 64 frames loop with the engine's existing three-tic fire animation cadence.

The author's directional report identified reversed source order in Zupay's
ground-slam windup/impact, pain and six rock-cast poses (ZUPY D/E/F/M..R).
`register_zupay_directions.py` maps rotations 2/3/4/6/7/8 to source 8/7/6/4/3/2;
front/back, idle/walk/run and original PNG bytes remain intact. The mapping and
source hashes are recorded in `demon_breath_515/ZUPAY_DIRECTIONS.json`.

Breath reuses the original CEFB flame frames with additive light blending and
four owned visual samples following the same mouth/direction/wall checks as its
thermal source. No Doom
art is introduced. Native fixtures, logs, crash diagnosis and captures live in
`assets/validation_515`, outside the runtime package. Author visual acceptance
remains separate. The requested Domingo crouched carbine atlas belongs to the
separate follow-up #143 and is not part of this demon patch.

## 5.1.4 - Breathing recordings and native evidence (#140)

The author supplied the ZIP attached to issue #140. Unmodified originals, the
attachment, original SOURCES_AND_CREDITS.txt and derived PROVENANCE.json are in
`assets/source/audio/breathing_514`. Female: Joseph SARDIN, BigSoundBank sound
1345, CC0 (https://bigsoundbank.com/breathless-woman-s1345.html). Male: Teekee,
Creazilla/Freesound, CC0 according to the author's source metadata
(https://creazilla.com/media/audio/15493689/man-breathing-deep-breathe).
The packaged attribution is `src/licenses/breathing_514.txt`.

`assets/generators/prepare_breathing_audio.py` uses the recorded FFmpeg 7.1
binary to derive whole-recording mono 22050-Hz PCM16 clips, -23 LUFS / -2 dBTP,
and 20-ms endpoint fades. High-intensity variants use 4/3 tempo with pitch
preserved; the moderate source recordings are unchanged in pace. There is no
voice synthesis. Two runs produced byte-identical runtime files; hashes,
filters and source provenance are retained. Runtime SNDINFO aliases live under
caelum/breathing and use CHAN_BODY loops without replacing pain voice, weapons
or heartbeat. Male/female moderate/high cues pass native playing, switching,
stop and save/load checks. Subjective mix, source background noise and loop
quality were accepted under CA140-01 on 2026-10-08, before later thermal
calibration. No human recordings are assigned to bull/rat;
their physical sweat and ventilation are active without a new animal sound.

Small isolated fixtures and source-bound results live in assets/validation_514.
Generated test PK3s, development IWAD/engine and native saves remain local in
build; they are not distributed as game assets.

## 5.1.3 - City interiors and world carbine artwork (#133)

Original map generator inputs are in assets/map06_port/INTERIORS.json; existing
native hinged doors, dining furniture, beds and crafting station art are reused.
The two historical harbor shells are rebuilt west of their old footprint on the
free apron; docks, arrival, campaign actors and narrative access are preserved.
Exact previous geometry/source inputs are retained in assets/map06_port/legacy_512.

New original carbine artwork is generated with the built-in image_gen tool using
project Domingo/carbine references. Masters, both prompts and provenance live
in assets/source/art/carbine_world_513. The existing character and first-person
assets are preserved. The runtime PNG is byte-identical to the source atlas;
native TEXTURES registers 48 directional/action cells with measured transparent
gaps and foot pivots. `register_carbine_world.py` reads pixels to measure these
boundaries but never edits the bitmap. Verification covers native third-person
poses and actual player fire/reload; visual author acceptance remains separate.

The sweating extension reuses existing character/clothing visuals and thermal
HUD. Isolated fixtures, migration controls and native evidence remain under
assets/validation_513; local packages and saved games are not distributed.

## 5.1.2 - Siege reinforcement evidence (#132)

No new runtime art, audio, map geometry or external gameplay assets.
The optional controller reuses authored crew stations and formation positions.
Native fixtures, command scripts and measurement records live in
assets/validation_512. Local PK3s, executable tooling, IWADs and saves remain
in build/issue132 and are not distributed. Official PresentMon 2.6.0 is used
only as a local measurement tool; its URL/hash and scope accompany the evidence.

## 5.1.1 - Thermal HUD verification sources (#131)

The thermal bar reuses the existing resource frame, laurels and CaelumMono font;
its bands/marker are native draw primitives. The author also requests a grey
flame/snowflake icon, aligned to the left like the other resource icons. Built-in
image_gen generated the silver-relief PNG with genuine alpha. The author then
requests separation: snowflake upper left, flame lower right. Revision 2 uses
`assets/art_source/thermal_icon_511_v2.png`, copied unchanged to
`src/graphics/caelum/ui/hud/icons/ca_hud_icon_thermal.png`. The original
`assets/art_source/thermal_icon_511.png` and its manifest remain preserved.
Prompts, source, format and hashes: [original](../assets/manifests/thermal_icon_511.json)
and [revision 2](../assets/manifests/thermal_icon_511_v2.json).
The icon keeps its 18x18 virtual size and position, drawn over the frame laurel
so the displaced flame remains visible. No external image or Doom asset was
used in generation. No new audio.
`assets/validation_511/` contains deterministic isolated fixture sources, native
logs/configuration fingerprints, screenshots and a results manifest. Generated
packages, saves, test maps, engine and development IWAD stay outside distribution.

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
`v3/shotgun_legacy.png` and `v3/longbow.png`. The maintained generator is
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

The fully audited project contains 131 runtime files: 120 OGG, 2 MP3 and 9 WAV, including the
issue #31 pain cues, dialogue-opening cue and three new map-music tracks. `assets/audio_stock`
preserves 26 source/backup files outside `src`: 10 pack-05 backups and 16 issue-#31
music/sound masters. Issue #89 preserves four more audio originals under
assets/issue89_pickaxe/reference_package. The earlier scoped runtime/source tally was 137 files; it is not a current project-wide source count. The nineteen new #496 WAV masters live separately in `assets/source/audio/map_music_496/masters/`, and their nineteen runtime OGGs are included in the current 131-file runtime count above, together with the original Ciudad track assigned in #416.
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
| `sounds/caelum/enemies/rat/alert.wav` | Original procedural rat alert cue (#254). |
| `sounds/caelum/enemies/rat/bite.wav` | Original procedural rat bite cue (#254). |
| `sounds/caelum/enemies/rat/pain.wav` | Original procedural rat pain cue (#254). |
| `sounds/caelum/enemies/rat/death.wav` | Original procedural rat death cue (#254). |
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
