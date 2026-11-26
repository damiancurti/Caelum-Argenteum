"""Build the deterministic joinery gallery from unchanged native captures."""
from pathlib import Path
import html,json
ROOT=Path(__file__).resolve().parents[2]
EVIDENCE=ROOT/'assets/validation_v5_17_117/evidence'
report=json.loads((EVIDENCE/'views/RESULTS.json').read_text())
assert report['passed'] and report['render_radius_preview']['render_radius']==781
style='body{max-width:1600px;margin:auto;padding:24px;background:#151b18;color:#eeeae0;font:17px/1.5 system-ui}h1,h2{color:#d3b58b}a{color:#b4d5ff}.pair{display:grid;grid-template-columns:1fr 1fr;gap:12px}figure{margin:0}img{display:block;width:100%;height:auto}figcaption{padding:8px 0}section{margin:36px 0}td,th{padding:8px 20px;border-bottom:1px solid #78695e;text-align:left}@media(max-width:850px){.pair{grid-template-columns:1fr}}'
content=f'''<!doctype html><html lang="en"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>House joinery review · #878</title><style>{style}</style>
<h1>House joinery review · #878</h1>
<p>Opt-in proposal for the final consolidated author review: paired closed timber leaves, modeled rails/stiles and iron hinge plates on the existing opaque house windows. Original plaster frames, cornices, operational doors, passages and private interiors remain.</p>
<p>Existing owned green wood and painted-iron pixels are reused unchanged. Review the texture clarity at close range as well as the street silhouette. The 1876 Casa Ezeiza reference informs timber/iron construction vocabulary; this is an original artistic proposal, not a reconstruction of every 1889 house.</p>
<p><a href="CONFIG.json">Proposal and provenance</a> · <a href="../../../validation_v5_17_117/evidence/builds/issue878-joinery02/MANIFEST.json">Inventory and hashes</a> · <a href="../../../validation_v5_17_117/evidence/performance.json">Presentation and tic tails</a></p>
<table><tr><th>Shared model</th><th>Original</th><th>Proposal</th></tr><tr><td>Vertices</td><td>1,896</td><td>4,548</td></tr><tr><td>Triangles</td><td>948</td><td>2,274</td></tr><tr><td>Native material sections</td><td>36</td><td>3</td></tr><tr><td>House instances</td><td>160</td><td>160</td></tr><tr><td>New pixel bytes</td><td>—</td><td>0</td></tr></table>
<p>The proposed mesh is 311,432 bytes and stays inside the original envelope. This inventory is not an approved permanent budget or a performance gain.</p>
<p>These paired views use the same private visibility adjustment on both models. The existing large facade can disappear near some houses; issue #879 owns the production fix. Teleports, invulnerability/notarget and menu dismissal are diagnostic. Images and a short walk do not establish ordinary full-city traversal or author acceptance.</p>
'''
names=[r['name'] for r in report['cameras']]+['walk']
for name in names:
    content+=f'<section><h2>{html.escape(name.replace("_"," ").title())}</h2><div class="pair">'
    for label,caption in [('control','Original model · visibility preview'),('candidate','Joinery proposal · same visibility preview')]:
        relative=f'../../../validation_v5_17_117/evidence/views/{label}/{name}.png'
        assert (EVIDENCE/f'views/{label}/{name}.png').is_file()
        content+=f'<figure><figcaption>{caption}</figcaption><img loading="lazy" src="{relative}" alt="{caption}: {name}"></figure>'
    content+='</div></section>\n'
content+='<section><h2>Retained visibility defect</h2><p>The default class loses the house 19 facade at this camera. This existed before the proposed joinery. The separate operational door remains usable. The visibility correction is tracked under #879.</p><div class="pair">'
for label,caption in [('control','Original model, default class'),('candidate','Intermediate joinery01, default class')]:
    relative=f'../../../validation_v5_17_117/evidence/visibility-baseline/{label}/window_270.png'
    content+=f'<figure><figcaption>{caption}</figcaption><img loading="lazy" src="{relative}" alt="{caption}: missing facade"></figure>'
content+='</div></section></html>\n'
target=ROOT/'assets/source/art/house_joinery_878/review.html'
target.write_text(content,encoding='utf-8',newline='\n')
print(target.relative_to(ROOT))
