from pathlib import Path
import hashlib,json
from PIL import Image
root=Path('C:/GZDooMProjects/CaelumArgenteum/build/v517/work-713');p=root/'build/issue861-visual-review.json';d=json.loads(p.read_text());seen={r['path'] for r in d['directly_viewed']}
paths=['build/issue861-actions-0-bare01/carbine-reload.png','build/issue861-actions-0-GP01/carbine-reload.png','build/issue861-actions-1-bare01/staff-charge.png','build/issue861-actions-1-GP01/staff-charge.png']
rows=json.loads((root/'build/issue861-presentation-final.json').read_text());assert len(rows)==8
paths+=[r['directory']+'/scene.png' for r in rows]
for name in paths:
 if name not in seen:d['directly_viewed'].append({'path':name,'sha256':hashlib.sha256((root/name).read_bytes()).hexdigest()})
for row in d['directly_viewed']:
 with Image.open(root/row['path']) as im:row['pixels']=list(im.size)
d['notes'].append('Four representative native reload/charge captures directly viewed: male carbine bare/GP and female staff bare/GP. Native action timers and layers pass. Carbine reload hands are partly below frame, so complete grip contact is not claimed. All8 final performance images viewed: matched first-person studio, opening mansion dialogue, sewer entrance and city gate. Sewer contamination differs slightly between independent native runs; these are not deterministic whole-world state replays or proof that the selector caused the presentation difference.')
p.write_text(json.dumps(d,indent=2)+'\n',encoding='utf-8');print(len(d['directly_viewed']),'directly viewed images; sizes',sorted({tuple(r['pixels']) for r in d['directly_viewed']}))
