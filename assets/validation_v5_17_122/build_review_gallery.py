"""Present unchanged native waterline comparisons for the final author session."""
from pathlib import Path
import html, json

ROOT = Path(__file__).resolve().parent
style = 'body{max-width:1800px;margin:auto;padding:24px;background:#171c19;color:#eee;font:17px/1.5 system-ui}h1,h2{color:#d3b58b}a{color:#b4d5ff}.views{display:grid;grid-template-columns:repeat(2,1fr);gap:12px}figure{margin:0}img{display:block;width:100%;height:auto}figcaption{padding:8px 0}section{margin:36px 0}@media(max-width:950px){.views{grid-template-columns:1fr}}'
page = f'''<!doctype html><html lang="en"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Damp waterline masonry ? #887</title><style>{style}</style>
<h1>Damp waterline masonry ? #887</h1>
<p>This private proposal applies an owned damp-brick derivative only to the existing exposed 16-MU lower channel faces. The native 64-MU texture repeat, upper walls, geometry, lighting, water, hazards and services remain intact. Exact style awaits the single final author review.</p>
<p>The built-in imagegen tool edited the owned #847 brick. The original prompt, attribution and 1254?1254 output are preserved without pixel postprocessing. Brick bond and scale are visually comparable; pixel-identical relief is not claimed. The AySA reference supplies construction context, not exact archaeological reconstruction.</p>
<p>Two deterministic builds reproduce the package and manifest. Eighteen native gallery samples each verify all 4,638 affected faces. Same-option save/reload and a fresh default restoration pass. The final review helper retains native menus. Camera teleports and observer protection are explicit diagnostic aids; these are not ordinary campaign or all-route tests.</p>
<p>All 18 images below were inspected directly and remain unchanged. The candidate walk capture shows Aira 1084/1 versus control 1084/1084; its cause is unestablished, so those captures do not establish identical HUD/gameplay state. Measured performance pairs have equal recorded state/census samples. Normal AI remains active. Close waterline rendering costs more in this pair, and both options include isolated roughly quarter-second stalls. Queue presentation is not monitor scanout; no general speedup or author acceptance is claimed.</p>
<p><a href="../source/art/sewer_waterline_887/CONFIG.json">Selection sources</a> ? <a href="../source/art/sewer_waterline_887/PROVENANCE.json">Provenance</a> ? <a href="../source/art/sewer_waterline_887/wet-brick-v1.prompt.txt">Exact image prompt</a> ? <a href="../source/art/sewer_waterline_887/wet-brick-v1.png">Generated image</a> ? <a href="evidence/composition/MANIFEST.json">Exact geometry/material audit</a> ? <a href="evidence/persistence/RESULTS.json">Save checks</a> ? <a href="evidence/performance.json">Frame/tic tails</a></p>
'''
report = json.loads((ROOT / 'evidence/views/RESULTS.json').read_text(encoding='utf-8'))
assert report['passed']
count = 0
for name in [row['name'] for row in report['cameras']] + ['walk']:
    page += '<section><h2>' + html.escape(name.replace('_', ' ').title()) + '</h2><div class="views">'
    for variant, caption in [('control', 'Inherited brick at waterline'), ('candidate', 'Damp brick proposal')]:
        relative = f'evidence/views/{variant}/{name}.png'
        assert (ROOT / relative).is_file()
        page += f'<figure><figcaption>{caption}</figcaption><a href="{relative}"><img loading="lazy" src="{relative}" alt="{caption}: {html.escape(name)}"></a></figure>'
        count += 1
    page += '</div></section>\n'
assert count == 18
(ROOT / 'review.html').write_text(page + '</html>\n', encoding='utf-8', newline='\n')
print('Built waterline gallery: 18 unchanged native captures.')
