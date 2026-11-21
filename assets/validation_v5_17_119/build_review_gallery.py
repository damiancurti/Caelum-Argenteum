"""Present unchanged native images alongside the source-backed finish inventory."""
from pathlib import Path
import html, json

ROOT = Path(__file__).resolve().parent
review = json.loads((ROOT.parent / 'source/art/environment_review_881/REVIEW.json').read_text(encoding='utf-8'))
style = 'body{max-width:1800px;margin:auto;padding:24px;background:#171c19;color:#eee;font:17px/1.5 system-ui}h1,h2{color:#d3b58b}a{color:#b4d5ff}.views{display:grid;grid-template-columns:repeat(2,1fr);gap:12px}figure{margin:0}img{display:block;width:100%;height:auto}figcaption{padding:8px 0}section{margin:36px 0}td,th{padding:12px;text-align:left;vertical-align:top;border-bottom:1px solid #58605b}table{border-collapse:collapse}@media(max-width:950px){.views{grid-template-columns:1fr}}'
page = f'''<!doctype html><html lang="en"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Combined environment review · #881</title><style>{style}</style>
<h1>Combined environment review · #881</h1>
<p>Compare retained production art with the combined owned remasters, house joinery and optional sewer vaults. This is a proposal for the final author session. The production maps and art remain unchanged; the corrected production facade visibility is active in both variants.</p>
<p>Existing household and workshop furniture is reused. The source inventory distinguishes available models, actual map setup, measured costs and unfinished detail. Roof tiles used on interior ceilings and the municipal office/archive finish remain visible gaps.</p>
<p>Eight native phases passed sampled camera clearance and a26.663-MU walk each. House review uses real entrance/return travel. The capture fixture supplies camera teleports, invulnerability/notarget and menu dismissal; it does not establish ordinary campaign progression, all-map traversal or author acceptance. Gate animation timing can differ between captures.</p>
<p><a href="../source/art/environment_review_881/INVENTORY.json">Source inventory and model costs</a> · <a href="../source/art/environment_review_881/REVIEW.json">Coverage and remaining gaps</a> · <a href="evidence/visual-inspection.json">Image review record</a> · <a href="evidence/composition/MANIFEST.json">Verified composition</a> · <a href="evidence/performance.json">Presentation and tic tails</a></p>
<h2>Current coverage</h2><table><thead><tr><th>Area</th><th>Available / verified</th><th>Remaining</th></tr></thead><tbody>
'''
for row in review['coverage']:
    page += '<tr>' + ''.join('<td>' + html.escape(row[k]) + '</td>' for k in ['area', 'existing', 'remaining']) + '</tr>\n'
page += '</tbody></table>\n'
for scene in ['house', 'city', 'mansion', 'sewer']:
    report = json.loads((ROOT / 'evidence/views' / scene / 'RESULTS.json').read_text(encoding='utf-8'))
    assert report['passed']
    page += '<h2>' + html.escape(scene.title()) + '</h2>\n'
    for name in [r['name'] for r in report['cameras']] + ['walk']:
        page += '<section><h3>' + html.escape(name.replace('_', ' ').title()) + '</h3><div class="views">'
        for label, caption in [('control', 'Retained production art'), ('candidate', 'Combined unapproved proposal')]:
            relative = f'evidence/views/{scene}/{label}/{name}.png'
            assert (ROOT / relative).is_file()
            page += f'<figure><figcaption>{caption}</figcaption><a href="{relative}"><img loading="lazy" src="{relative}" alt="{caption}: {html.escape(name)}"></a></figure>'
        page += '</div></section>\n'
(ROOT / 'review.html').write_text(page + '</html>\n', encoding='utf-8', newline='\n')
print('Built combined environment gallery:50 unchanged native captures.')
