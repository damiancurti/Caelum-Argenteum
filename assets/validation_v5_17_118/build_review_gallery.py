"""Build an unchanged-capture gallery for the production facade correction."""
from pathlib import Path
import html,json
ROOT=Path(__file__).resolve().parent
report=json.loads((ROOT/'evidence/views/RESULTS.json').read_text())
assert report['passed'] and report['production_classes'] and not report['diagnostic_class_override']
style='body{max-width:1800px;margin:auto;padding:24px;background:#171c19;color:#eee;font:17px/1.5 system-ui}h1,h2{color:#d3b58b}a{color:#b4d5ff}.views{display:grid;grid-template-columns:repeat(3,1fr);gap:12px}figure{margin:0}img{display:block;width:100%;height:auto}figcaption{padding:8px 0}section{margin:36px 0}@media(max-width:950px){.views{grid-template-columns:1fr}}'
content=f'''<!doctype html><html lang="en"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Facade visibility correction · #879</title><style>{style}</style>
<h1>Facade visibility correction · #879</h1>
<p>The original large facade could disappear from nearby streets. The corrected production class uses a render radius derived from the unchanged mesh. Collision, house placement, original model, maps and usable portals remain unchanged.</p>
<p>Left: release117. Middle: corrected release118 with original art. Right: corrected release118 with the separate, unapproved #878 joinery option. These captures use the actual production facade classes, without a diagnostic radius subclass.</p>
<p>Inspect especially Window270 and Door90. Teleports, invulnerability/notarget and menu dismissal are diagnostic. The short walk is 26.663MU; this gallery does not establish full-city traversal, siege fluency or author acceptance.</p>
<p><a href="evidence/visual-inspection.json">Image review record</a> · <a href="evidence/persistence/RESULTS.json">Native persistence and house travel</a> · <a href="evidence/performance.json">Presentation and tic tails</a> · <a href="../source/art/house_joinery_878/review.html">Separate joinery proposal</a></p>
'''
for name in [r['name'] for r in report['cameras']]+['walk']:
    content+=f'<section><h2>{html.escape(name.replace("_"," ").title())}</h2><div class="views">'
    for label,caption in [('control','Original production class'),('fixed','Corrected production class'),('joinery','Corrected class + unapproved joinery')]:
        relative=f'evidence/views/{label}/{name}.png';assert (ROOT/relative).is_file()
        content+=f'<figure><figcaption>{caption}</figcaption><a href="{relative}"><img loading="lazy" src="{relative}" alt="{caption}: {name}"></a></figure>'
    content+='</div></section>\n'
(ROOT/'review.html').write_text(content+'</html>\n',encoding='utf-8',newline='\n')
print('Built facade visibility gallery:30 unchanged native captures.')
