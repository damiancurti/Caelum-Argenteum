"""Document the retained author material candidate after its native comparisons."""
from pathlib import Path
import json
import re

root=Path('C:/GZDooMProjects/CaelumArgenteum/build/v517/work-713')
scope=json.loads((root/'build/issue866-preservation.json').read_text())
scenes=json.loads((root/'build/issue866-performance.json').read_text());assert len(scenes)==10
table='| Scene | Queue presents/s | Present p95 / p99 / max ms | Tic mean / p95 / p99 / max ms |\n| --- | ---: | --- | --- |\n'
for row in scenes:
    p=row['presentation'];t=row['simulation'];tail=p['present_intervals']
    table+=f"| {row['label']} | {p['mean_present_fps']:.3f} | {tail['p95_ms']:.3f} / {tail['p99_ms']:.3f} / {tail['max_ms']:.3f} | {t['mean_ms']:.3f} / {t['p95_ms']:.3f} / {t['p99_ms']:.3f} / {t['max_ms']:.3f} |\n"
title='## 5.17.111 - Recover the author-provided environment remasters for review (#866, #463)\n\n'
sections={
'ASSETS.md':'''The original Caelum_Texturas_Ciudad_Puerto_Playa_v1 ZIP was recovered locally.
Its SHA-256 exactly matches assets/coastal_textures/integration.json:
888b6c3b5cf54ffbaddad2a78e32fd61c5b6f9889faebb66654085d72c08681e.
The filename lacks the historical manifest's (1) suffix; the bytes match.
The eight optional remasters explicitly left uninstalled in 4.35.0m are now
preserved as an opt-in review candidate, not an approved production replacement.

CMEX01/04 depict worn lime plaster and handmade red brick; CMST01/02 irregular
cobbles and squared paving; CMWD01 dark planks; CMTB04 terracotta roof tiles;
CMGR01/02 dark grass and sparse grass/earth. Exact source preservation includes
eight 128x128 references, eight 1254x1254 masters, eight 512x512 RGB exports,
the original PROMPTS/EXPORT_CROPS JSON and TEXTURES_MEJORAS_V3 fragment:27 files.
No pixels were generated, cropped, resized, repainted or recompressed for #866.
The original crop metadata remains provenance; the supplied exports are used as-is.

The fragment defines 24 native wall/flat bindings for 12 names, including the
historical CMGR01A/B, CMRF01 and CMWV01 aliases. XScale/YScale 4 and WorldPanning
retain the author's 128x128-MU repeat (4m at 32 MU/m), with four pixels per MU.
Its aliases have 238 packaged UDMF map consumers, including test maps. This is
global scope while loaded, so use only dedicated comparison sessions. MAP02's
actual consumer is the existing Justice room; ordinary sewer passages use
different aliases and retain their previous appearance. #847 remains separate.

Three compositions still read the old raw PNGs: CMWIN36, CSUFA0 and CTFWA0.
The ca_mansion_door_gable.obj model also reads old CMEX01 directly. Those paths
remain unchanged. CMPLS36, CMPNL36, CMSHT36 and CMCL01 use other source images;
they are not silently transformed. The comparison is therefore deliberately
incomplete across derived surfaces, model skins and unrelated city materials.
Do not overwrite a 128-pixel source with 512-pixel art under existing crop layouts.

The eight exports total 4,292,384 encoded bytes; unique RGBA base levels would
occupy 8,388,608 bytes (8 MiB), or 11,184,800 bytes including full mip chains.
Separate allocations for all 24 bindings could cost three times that estimate.
These are explicit candidate image costs, not measured VRAM, driver overhead
or an approved permanent budget. Existing production images remain retained.

The source/capture gallery is assets/source/art/environment_remasters_866/review.html;
inventory, provenance and original prompts sit alongside it. Native source,
frame/tic traces, repeated assembly and runtime preservation evidence are in
assets/validation_v5_17_111. CA866-MATERIAL-01 joins the existing final-session
queue. Repeated wear/colour motifs remain visible at room scale; final artistic
judgment, derived-surface work, vaults, furnishing and broader #463 finish remain open.
''',
'SYSTEMS.md':'''#866 adds an isolated visual comparison package from retained author images.
Production maps, actor code, physics, material gameplay, interaction IDs, lighting,
resources and save fields/schema remain unchanged. The only runtime differences
from 5.17.110 are two release-diagnostic strings. The overlay retains the existing
texture names and 128-MU repeats; it contains no actors, map replacement or logic.

The diagnostic capture fixture uses camera teleports, menu dismissal, invulnerability
and notarget for its disposable pawn. Its short forward-input checks do not
establish ordinary locked-room access, full-map navigation or author acceptance.
MAP02 normal 96-MU passage clearance and its approved layout remain authoritative.
No global actor scan, population policy or offscreen gameplay change is introduced.
''',
'PROJECT.md':'''Prepared the eight retained author-supplied material remasters as an isolated
review candidate under #463/#866. Exact source provenance, native 128-MU repeats,
shared consumers, short movement, before/after views and peaceful/normal-siege
presentation windows are documented in ASSETS/HISTORY and validation_v5_17_111.

This does not activate the textures in production, approve shared mansion changes,
complete all scenery/characters/equipment or resolve siege fluency. Consolidated
author review remains deferred to the one final batch terminal. Continue the
remaining authorized work; retain explicit design gates and all pending tests.
''',
'TASKS.md':'''Completed #866 source recovery, shared-consumer inventory, deterministic opt-in
assembly, native material comparisons and scoped presentation checks. Preserve
the author's source bytes and original 128-MU world dimensions. Review the grass,
plaster, brick, stone, wood and roof candidates at the consolidated session.

Three raw-image compositions and one model skin remain on their original sources;
those require separately scoped transformations if the author selects the remasters.
Continue the remaining #463 scenery finish and other authorized batch work without
silently treating this material candidate, #736 boards or native tests as acceptance.
The appended CA866-MATERIAL-01 remains pending with every earlier author check.
''',
'HISTORY.md':f'''Recovered 27 source/provenance files from the author's retained ZIP, whose hash
matches the historical coastal-texture integration manifest. Three independent
overlay assemblies are byte-identical: {scope['overlay_sha256']}.
They contain only eight exact PNG exports and the exact supplied binding fragment.
All 18,767 runtime entries match source. Compared with 5.17.110, only the two release
diagnostic strings change; all maps, production art/models, gameplay and saved
fields remain byte-preserved. Final runtime SHA-256: {scope['runtime_sha256']}.

Five final control/candidate pairs cover an eight-material repeat room, mansion
garden/exterior/interior, MAP02 Justice stone room, port/factory threshold/interior
and a separate outward street view. Each run checks 24 native wall/flat sizes;
all 240 observations retain 128x128 MU. All 42 camera/walk placements report adequate
clearance. Ten 35-tic forward checks move 26.663 MU to identical paired positions.
The diagnostic pawn is 56 MU high; this is a short local check, not a full traversal,
largest-body clearance, combat, escort, locked-room progression or author test.
Unchanged map bytes preserve the existing approved geometry and earlier evidence.

Eight source exports and 32 named native before/after captures were directly
inspected. Captures are 1520x825 although 1280x720 was requested. All eight materials
render and repeat; surface detail increases without moving the cameras or changing
world dimensions. Repeated wear/colour patterns remain visible. The grass keeps
strong fine contrast. Mansion composites/gable, city brick, vehicles, props and
lighting remain visibly unchanged where outside the candidate aliases. Ten short
movement screenshots are retained but not separately visually reviewed.

First lab attempts retained two fixture-only compile failures: reserved identifier
state, then nonexistent sector floorpic/ceilingpic fields. The corrected fixture
uses record and Sector.GetTexture. Lab03/MAP01-01 completed but their run lifetimes
could overlap; lab04/MAP01-02 replaced them serially. Launchers now refuse an
already-running GZDoom. None of those attempts supplies performance evidence.

Ten later serial windows compare the same final runtime with/without the overlay,
native GZDoom 4.14.2, Vulkan 1280x720, Windows 11, Ryzen 9 5950X and RTX 3070 Ti,
unpaused background and 5% audio. MAP02 uses the actual stone room, not its
unaffected entry. Native QueuePresent is distinct from monitor scanout; tic
intervals include pacing/frame work and are not isolated simulation CPU cost.
These are single paired windows, not a stable causal speedup/cost estimate.

{table}
The normal siege retains the approved 1,000-attacker/600-defender diagnostic
design; actual census/observer states and full tails are recorded in the evidence.
No retired 6,000-attacker case ran. Overall siege rendering remains unresolved.
The mansion performance capture retains its opening dialogue; comparison captures
separately dismiss menus. Ten performance images are inspected and qualified in
the visual record. No asset is marked accepted. CA866-MATERIAL-01 is appended;
the consolidated terminal remains deferred until remaining authorized work is ready.
'''
}
for name,body in sections.items():
    p=root/'docs'/name;s=p.read_text(encoding='utf-8');assert title not in s
    i=s.index('\n## ');p.write_text(s[:i]+'\n'+title+body.strip()+'\n'+s[i:],encoding='utf-8',newline='\n')
p=root/'README.md';s=p.read_text(encoding='utf-8');marker='#864 shortens';i=s.index(marker)
s=s[:i]+'''#866 recovers eight author-provided environment remasters for isolated review.
The exact-source gallery is assets/source/art/environment_remasters_866/review.html;
native material, movement and presentation evidence is in assets/validation_v5_17_111.
Production art/geometry remain unchanged. Shared-surface limits and candidate
image costs are explicit in docs/ASSETS.md; author review stays at the final session.

'''+s[i:];p.write_text(s,encoding='utf-8',newline='\n')
p=root/'docs/CONTEXT.md';s=p.read_text(encoding='utf-8').replace('#847:sewer.','#847:sewer;#866:remasters.',1);assert len(s.split())<2500;p.write_text(s,encoding='utf-8',newline='\n')
p=root/'pending_test.txt';s=p.read_text(encoding='utf-8');assert 'CA866-MATERIAL-01' not in s
s+='''
CA866-MATERIAL-01 | Origin 5.17.111 / #866 (parent #463) | Pending
Prerequisites: final consolidated batch terminal; preserve original campaign saves. Gallery: assets/source/art/environment_remasters_866/review.html. The opt-in overlay has global aliases while loaded; normal production art remains unchanged.
Steps: compare all eight source materials and paired native repeats, then the mansion garden/exterior/interior, port, city street/factory and actual MAP02 Justice stone consumer. In the dedicated final review session inspect scale, tiling motifs, grass contrast, plank/stone joins, route/object readability and movement. Review the explicit image cost and unchanged composites/gable before selecting materials.
Expected: the authored 128-MU repeat and existing layout remain coherent. Confirm selected materials or name corrections; this does not authorize every shared consumer, derived-image transformation, ordinary locked-room access or the complete #463 scenery finish. No intermediate acceptance is assumed.
''';p.write_text(s,encoding='utf-8',newline='\n')
p=root/'docs/KNOWN_PITFALLS.md';s=p.read_text(encoding='utf-8');i=s.index('\n## ')
lesson='''
## CA-KP-267 - Audit aliases and raw-image consumers before remaster binding

Status/evidence: CODE-VERIFIED and ENGINE-VERIFIED, #866 /5.17.111,
2026-11-21, GZDoom 4.14.2. Artistic acceptance remains pending.

A logical wall/flat alias, a cropped TEXTURES composition and an OBJ usemtl
raw-image path are separate consumers. Replacing an alias does not update the
other two; replacing their shared 128-pixel PNG with 512-pixel art can instead
change crop coverage or UV scale. Inventory all paths, aliases and packaged
maps first. Preserve source pixels and world dimensions explicitly; inspect
native wall and flat lookups as well as the actual map locations that use them.

For #866, the retained fragment supplies 24 bindings/12 aliases at 128 MU, while
CMWIN36/CSUFA0/CTFWA0 and one mansion model retain old raw images. MAP02 uses
these stones in its Justice room, so an entry-only capture would miss the change.
Use exact archive/per-file hashes and deterministic ZIP metadata; decoded-image
estimates are not measured VRAM. Keep global-alias candidates isolated until
their shared scope is accepted. Evidence: assets/validation_v5_17_111 and
assets/source/art/environment_remasters_866/INVENTORY.json.

'''
assert 'CA-KP-267' not in s;p.write_text(s[:i]+lesson+s[i:],encoding='utf-8',newline='\n')
print('Documented 5.17.111; validation status will be recorded after its full check.')
