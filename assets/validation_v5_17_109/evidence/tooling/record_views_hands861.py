"""Record only explicitly viewed native images."""
from pathlib import Path
import hashlib,json
root=Path('C:/GZDooMProjects/CaelumArgenteum/build/v517/work-713');p=root/'build/issue861-visual-review.json';d=json.loads(p.read_text());seen={r['path'] for r in d['directly_viewed']}
paths=['build/issue861-final03/motion-0-bare/idle.png','build/issue861-final03/motion-0-bare/guard.png','build/issue861-final05/motion-0-GP/attack.png','build/issue861-final05/motion-1-GP/guard.png','build/issue861-consumers-male01/preview-gloves.png','build/issue861-consumers-female01/preview-bare.png','build/issue861-final05/motion-1-bare/idle.png','build/issue861-final05/motion-1-GP/restored.png','build/issue861-save-baseline04/hands.png','build/issue861-final03/fresh/hands.png']
for name in paths:
 if name not in seen:d['directly_viewed'].append({'path':name,'sha256':hashlib.sha256((root/name).read_bytes()).hexdigest()})
note='Sword motion and guard retain the existing poses. Frontal shield block correctly hides sword layers and shows only shield/left hand. Actual menu shows male gloves and female bare hands. Existing shared art is not a specific textile/material depiction. Native captures are1520x825 despite requested1280x720 command-line size; record both rather than assuming requested resolution.'
if note not in d['notes']:d['notes'].append(note)
p.write_text(json.dumps(d,indent=2)+'\n',encoding='utf-8');print(len(d['directly_viewed']),'directly viewed images')
