"""Present the unchanged native ceiling comparisons for the final author session."""
from pathlib import Path
import html,json

ROOT=Path(__file__).resolve().parent
style='body{max-width:1800px;margin:auto;padding:24px;background:#171c19;color:#eee;font:17px/1.5 system-ui}h1,h2{color:#d3b58b}a{color:#b4d5ff}.views{display:grid;grid-template-columns:repeat(2,1fr);gap:12px}figure{margin:0}img{display:block;width:100%;height:auto}figcaption{padding:8px 0}section{margin:36px 0}@media(max-width:950px){.views{grid-template-columns:1fr}}'
page=f'''<!doctype html><html lang="en"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Interior ceiling review · #883</title><style>{style}</style>
<h1>Interior ceiling review · #883</h1>
<p>Compare the existing roof-tile underside with the owned timber ceiling proposal. Both sides use the same combined #881 art. Only321 surface names across160 private houses and the municipal underside differ. Exterior roofing, room geometry and existing furniture stay intact.</p>
<p>This proposal awaits the final author session. It does not establish historical authenticity or approval of timber for every room. The municipal office/archive finish and the broader batch remain open.</p>
<p>Four native view phases passed sampled clearance and short walks. House entry and return used the real portal/capture/render acknowledgement. Camera teleports, invulnerability and menu dismissal support these captures; they do not establish ordinary campaign progression or all-map traversal.</p>
<p>All options require fresh disposable sessions: texture-name changes alter map checksums even when geometry is identical. Same-option save/reload and a fresh original-material session passed. Do not import campaign saves into these review options.</p>
<p><a href="../source/art/interior_ceilings_883/CONFIG.json">Source and proposal</a> · <a href="evidence/composition/MANIFEST.json">Surface audit</a> · <a href="evidence/persistence/RESULTS.json">Save/reload</a> · <a href="evidence/performance.json">Presentation and tic tails</a> · <a href="evidence/visual-inspection.json">Image review record</a></p>
'''
count=0
for scene in ['house','city']:
    report=json.loads((ROOT/'evidence/views'/scene/'RESULTS.json').read_text(encoding='utf-8'))
    assert report['passed']
    page+='<h2>'+html.escape(scene.title())+'</h2>\n'
    for name in [row['name'] for row in report['cameras']]+['walk']:
        page+='<section><h3>'+html.escape(name.replace('_',' ').title())+'</h3><div class="views">'
        for variant,caption in [('control','Existing roof-tile underside'),('candidate','Owned timber ceiling proposal')]:
            relative=f'evidence/views/{scene}/{variant}/{name}.png';assert (ROOT/relative).is_file()
            page+=f'<figure><figcaption>{caption}</figcaption><a href="{relative}"><img loading="lazy" src="{relative}" alt="{caption}: {html.escape(name)}"></a></figure>'
            count+=1
        page+='</div></section>\n'
assert count==16
(ROOT/'review.html').write_text(page+'</html>\n',encoding='utf-8',newline='\n')
print('Built ceiling gallery:16 unchanged native captures.')
