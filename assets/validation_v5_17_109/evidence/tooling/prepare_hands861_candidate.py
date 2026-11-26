"""Build the focused source overlay and initial native selector checks."""
from pathlib import Path
import hashlib,json,zipfile
h=Path(__file__).resolve().parent;root=Path('C:/GZDooMProjects/CaelumArgenteum/build/v517/work-713');out=root/'build/issue861-prototype01';out.mkdir(exist_ok=False)
names=['caelum/player/CaelumPlayer.zs','caelum/character/CaelumAppearanceHands.zs','caelum/equipment/CaelumInventoryService.zs'];hashes={}
with zipfile.ZipFile(out/'prototype.pk3','w') as archive:
 for name in names:
  blob=(root/'src'/name).read_bytes();archive.writestr(zipfile.ZipInfo(name,(2026,11,20,0,0,0)),blob);hashes[name]=hashlib.sha256(blob).hexdigest()
(out/'SHA256.json').write_text(json.dumps(hashes,indent=2)+'\n',encoding='utf-8')
s=(h/'hands861_baseline.zs').read_text(encoding='utf-8')
s=s.replace('!CaelumAppearanceHands.HasGloves(User),"baseline retains documented armor-only selector"','CaelumAppearanceHands.HasGloves(User),"actual clothing glove selects shared glove presentation"')
s=s.replace('Variant(User)==0,"baseline clothing glove leaves male bare-hand variant"','Variant(User)==-1,"male clothing glove selects accepted shared glove variant"')
s=s.replace('Variant(User)==18,"baseline clothing glove leaves female bare-hand variant"','Variant(User)==36,"female clothing glove selects accepted distinct glove variant"')
(h/'hands861_candidate.zs').write_text(s,encoding='utf-8')
s=(h/'run_hands861_baseline.py').read_text(encoding='utf-8').replace('hands861_baseline.zs','hands861_candidate.zs').replace('Historical armor-only hand selector reproduction using actual native clothing and armor equipment; expected old behavior, not a claim that clothing presentation is implemented.','Actual native clothing/armor hand selector candidate; initial smoke only, not full ownership/save/performance or author qualification.')
(h/'run_hands861_candidate.py').write_text(s,encoding='utf-8');print('Created prototype01 and initial30 native selector checks.')
