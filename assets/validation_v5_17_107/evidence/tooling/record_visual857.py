"""Record images actually inspected, including rejected frame-order evidence."""
from pathlib import Path
import hashlib,json
root=Path('C:/GZDooMProjects/CaelumArgenteum/build/v517/work-713')
rows=[]
def add(path,observation):
    file=root/path;rows.append(dict(path=path,sha256=hashlib.sha256(file.read_bytes()).hexdigest(),viewed=True,observation=observation))
for scene,description in [('studio','Private tiled room; diagnostic figure, no campaign population.'),('mansion','Opening Unknown Voice dialogue in front of the mansion doors; not an interior walkthrough.'),('sewers','Dark flat-ceiling masonry entrance; one equipped figure, not a traversal or crowd.'),('city','Paved open area with the gate/mechanism background; peaceful fixed entrance view, no siege.')]:
    for mode,suffix in [('candidate','02'),('control','01')]:
        add(f'build/issue857-bench-{scene}-{mode}{suffix}/scene.png',description+(' Equipped clothing candidate; hands remain relaxed.' if mode=='candidate' else 'Retained seven-module default comparison.'))
for name in ['idle','attack','guard','jump-air','run','back']:
    add(f'build/issue857-motion01/{name}.png','Rejected: body slots retained last frame374 while weapons animated; native pose assertions alone missed this binding-generation defect.')
for name in ['idle','attack','guard','jump-air','run','back']:
    add(f'build/issue857-motion02/{name}.png','Corrected contiguous frame groups restore body/accessory pose agreement. Relaxed fingers and item-specific glove/grip fit remain #859; close framing does not establish all-footwear or all-garment coverage.')
report=dict(issue=857,reviewed_utc='2026-11-19T22:43:00Z',method='Direct view_image inspection of each listed native capture; no synthetic image edits.',images=rows,limitations=['The walk-labelled capture was sampled at pose0 and is not a still-image proof of walking; native WorldTick records the actual walk pose separately.','Jump-preparation capture and complete feet were not used as visual acceptance evidence.','No author acceptance, other body/species conversion, all-equipment fitting or first-person acceptance.','The four control captures are reused because the frame-order correction only changes the candidate model definition.'],corrected_runtime='build/issue857-wardrobe02.pk3',corrected_runtime_sha256='f4b41b9417deb39020fb884357027784bbfc3bafd419af028b34a101cea8a748')
(root/'build/issue857-visual-review.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8');print(len(rows),'directly viewed images recorded')
