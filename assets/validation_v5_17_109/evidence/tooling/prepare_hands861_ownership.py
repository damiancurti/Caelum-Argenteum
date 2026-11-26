"""Prepare the final read-only-state lookup prototype and native ownership checks."""
from pathlib import Path
import hashlib,json,zipfile
h=Path(__file__).resolve().parent;root=Path('C:/GZDooMProjects/CaelumArgenteum/build/v517/work-713');out=root/'build/issue861-prototype02';out.mkdir(exist_ok=False)
names=['caelum/player/CaelumPlayer.zs','caelum/character/CaelumAppearanceHands.zs','caelum/equipment/CaelumInventoryService.zs'];hashes={}
with zipfile.ZipFile(out/'prototype.pk3','w') as archive:
 for name in names:
  data=(root/'src'/name).read_bytes();archive.writestr(zipfile.ZipInfo(name,(2026,11,20,0,0,0)),data);hashes[name]=hashlib.sha256(data).hexdigest()
(out/'SHA256.json').write_text(json.dumps(hashes,indent=2)+'\n',encoding='utf-8')
s=(h/'hands861_candidate.zs').read_text(encoding='utf-8');i=s.rindex('    override void NetworkProcess');s=s[:i]+(h/'hands861_ownership.zs').read_text(encoding='utf-8')+'\n'+s[i:];s=s.replace("if(e.Name!='ca857check')return;Probe();","if(e.Name!='ca857check')return;Probe();Ownership();")
(h/'hands861_ownership_full.zs').write_text(s,encoding='utf-8')
s=(h/'run_hands861_candidate.py').read_text(encoding='utf-8').replace('hands861_candidate.zs','hands861_ownership_full.zs').replace('initial smoke only, not full ownership/save/performance or author qualification.','native ownership, direct stale-object guards and42 profile choices; save/performance/visual acceptance remains separate.')
(h/'run_hands861_ownership.py').write_text(s,encoding='utf-8');print('Prepared prototype02 and extended native ownership suite.')
