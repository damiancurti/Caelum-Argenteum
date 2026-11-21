"""Present unchanged native municipal comparisons for the final author session."""
from pathlib import Path
import html, json

ROOT = Path(__file__).resolve().parent
style = 'body{max-width:1800px;margin:auto;padding:24px;background:#171c19;color:#eee;font:17px/1.5 system-ui}h1,h2{color:#d3b58b}a{color:#b4d5ff}.views{display:grid;grid-template-columns:repeat(2,1fr);gap:12px}figure{margin:0}img{display:block;width:100%;height:auto}figcaption{padding:8px 0}section{margin:36px 0}@media(max-width:950px){.views{grid-template-columns:1fr}}'
page = f'''<!doctype html><html lang="en"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Municipal furnishing review · #886</title><style>{style}</style>
<h1>Municipal furnishing review · #886</h1>
<p>The proposal uses owned desks, chairs and book-filled shelves at their existing native scale: eight workstations in four open northern bays, plus a western archive row. The original entrance, courtyard, southern vendor wing and all map geometry remain intact.</p>
<p>The 42 fixed scene props have collision and bilingual labels. Their visible books are part of the existing mesh. They provide no new reading, resting, storage, item, ownership or trading function. The existing merchant remains the same service. These are open workspace bays, not newly enclosed rooms.</p>
<p>Both sides use the inherited remasters, joinery, sewer vaults and timber ceilings. The candidate adds only this municipal arrangement. Production defaults remain available in a separate fresh session. Exact style, historical appearance and placement await the final author review.</p>
<p>The three unchanged model sources total 3,672 vertices, 1,836 triangles, seven OBJ material sections and 236,392 bytes. The 42 instances total 42,120 source triangles. These counts are not a permanent art budget, visible triangle count, draw-call count or GPU memory measurement.</p>
<p>Two view phases passed 18 scene samples. Four route/save phases each passed 451 native movement steps, 42 collision probes and the existing merchant's Use interaction after preparing its persistent Box prerequisite. Same-option reload and a fresh default restoration passed. These diagnostic sessions do not establish ordinary campaign progression, all-body clearance or multiplayer acceptance.</p>
<p>Camera teleports, invulnerability and automatic menu dismissal support the gallery. Some control captures show a different Aira HUD value; its cause was not established and the images are not claimed to have identical gameplay state. The final review helper leaves native menus available.</p>
<p><a href="../source/art/municipal_review_886/CONFIG.json">Sources and placement rules</a> · <a href="evidence/composition/MANIFEST.json">Geometry and cost audit</a> · <a href="evidence/routes/RESULTS.json">Routes and reload</a> · <a href="evidence/performance.json">Frame and tic tails</a> · <a href="evidence/visual-inspection.json">Image review</a></p>
'''
report = json.loads((ROOT / 'evidence/views/RESULTS.json').read_text(encoding='utf-8'))
assert report['passed']
count = 0
for name in [row['name'] for row in report['cameras']] + ['walk']:
    page += '<section><h2>' + html.escape(name.replace('_', ' ').title()) + '</h2><div class="views">'
    for variant, caption in [('control', 'Inherited art, empty perimeter'), ('candidate', 'Municipal furniture proposal')]:
        relative = f'evidence/views/{variant}/{name}.png'
        assert (ROOT / relative).is_file()
        page += f'<figure><figcaption>{caption}</figcaption><a href="{relative}"><img loading="lazy" src="{relative}" alt="{caption}: {html.escape(name)}"></a></figure>'
        count += 1
    page += '</div></section>\n'
assert count == 18
(ROOT / 'review.html').write_text(page + '</html>\n', encoding='utf-8', newline='\n')
print('Built municipal gallery: 18 unchanged native captures.')
