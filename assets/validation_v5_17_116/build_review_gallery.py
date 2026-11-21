"""Build the deterministic #875 gallery from unchanged native capture files."""
from pathlib import Path
import html,json
ROOT=Path(__file__).resolve().parents[2]
EVIDENCE=ROOT/'assets/validation_v5_17_116/evidence'
report=json.loads((EVIDENCE/'views/RESULTS.json').read_text())
assert report['passed']
notes={
    'entrance':'The entry buffer stays at96 MU; the raised main-passage roof begins beyond it.',
    'junction':'Flat inspection chamber retained, looking toward the shallow vaulted exits.',
    'channel':'Existing dry shelf, channel and NPCs; this camera is inside a flat chamber looking down passages.',
    'refuge':'Original flat chamber, workshop objects and overhead conduit retained.',
    'boss_access':'Existing locked/barred access and its96-MU clearance retained.',
    'main_horizontal':'Inside the160-MU main passage. The96-MU dry shelf and64-MU channel keep their widths.',
    'main_vertical':'Same main-passage profile on the other horizontal axis, approaching a flat chamber.',
    'service':'Inside the existing128-MU service route; crown128 MU, spring96 MU.',
    'maintenance':'Inside the64-MU maintenance route. The existing door height and closure are unchanged.',
    'walk':'The same26.663-MU forward movement in each run. This is a bounded inspection, not a full campaign walkthrough.'}
style='body{max-width:1600px;margin:auto;padding:24px;background:#151311;color:#eee6dc;font:17px/1.5 system-ui}h1,h2{color:#e6b28c}a{color:#b4d5ff}.pair{display:grid;grid-template-columns:1fr 1fr;gap:12px}figure{margin:0}img{display:block;width:100%;height:auto}figcaption{padding:8px 0}section{margin:36px 0}table{border-collapse:collapse}td,th{padding:8px 20px;border-bottom:1px solid #78695e;text-align:left}@media(max-width:850px){.pair{grid-template-columns:1fr}}'
content=f'''<!doctype html><html lang="en"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Sewer vault review · #875</title><style>{style}</style>
<h1>Sewer vault review · #875</h1>
<p>Private structure proposal for the final consolidated author review. Production revision6 stays unchanged. The roof rises from the current96-MU minimum toward128 MU; its form, physical clearance and cost are unapproved.</p>
<p>The exact owned #847 brick image is reused with map-local aliases. No other map receives these material names. Lighting, floor geometry, routes, objects, gate dimensions and source populations remain. Raised roof space can change jump/projectile clearance.</p>
<p><a href="CONFIG.json">Profile and provenance</a> · <a href="../../../validation_v5_17_116/evidence/builds/issue875-vault02/MANIFEST.json">Exact inventory/hashes</a> · <a href="../../../validation_v5_17_116/evidence/performance.json">Presentation and tic measurements</a></p>
<table><tr><th>Base map before existing arena</th><th>Current</th><th>Proposal</th></tr><tr><td>Sectors</td><td>104</td><td>539</td></tr><tr><td>Lines</td><td>32,524</td><td>67,120</td></tr><tr><td>Vertices</td><td>32,001</td><td>65,578</td></tr><tr><td>Original things</td><td>445</td><td>445</td></tr></table>
<p>Twenty sampled native images at1520×825, all inspected by the agent. Teleports, invulnerability and notarget are diagnostic setup. Separate maximum-body geometry runs temporarily suppress one blocking rat's solidity and restore it; they do not prove escort AI. No author acceptance is inferred.</p>
'''
for name,note in notes.items():
    content+=f'<section><h2>{html.escape(name.replace("_"," ").title())}</h2><p>{html.escape(note)}</p><div class="pair">'
    for label,caption in [('control','Current production'),('candidate','Vault and brick proposal')]:
        relative=f'../../../validation_v5_17_116/evidence/views/{label}/{name}.png'
        assert (EVIDENCE/f'views/{label}/{name}.png').is_file()
        content+=f'<figure><figcaption>{caption}</figcaption><img loading="lazy" src="{relative}" alt="{caption}: {name}"></figure>'
    content+='</div></section>\n'
content+='</html>\n'
target=ROOT/'assets/source/art/sewer_structure_875/review.html'
target.write_text(content,encoding='utf-8',newline='\n')
print(target.relative_to(ROOT))
