"""Add diagnostic-only cold lookup counters to an overlay, never to src."""
from pathlib import Path
import hashlib,json,zipfile
h=Path(__file__).resolve().parent;root=Path('C:/GZDooMProjects/CaelumArgenteum/build/v517/work-713');out=root/'build/issue861-cache-overlay01';out.mkdir(exist_ok=False)
player=(root/'src/caelum/player/CaelumPlayer.zs').read_text(encoding='utf-8');needle='    transient bool AppearanceHandStateReady;';assert player.count(needle)==1
player=player.replace(needle,needle+'\n    transient int CA861StateReads,CA861ItemReads;')
hands=(root/'src/caelum/character/CaelumAppearanceHands.zs').read_text(encoding='utf-8');needle='                user.AppearanceHandState=CaelumPersistentCharacterState';assert hands.count(needle)==1
hands=hands.replace(needle,'                user.CA861StateReads++;\n'+needle)
needle='            user.AppearanceHandLayers[layer]=wanted>0?';assert hands.count(needle)==1;hands=hands.replace(needle,'            if(wanted>0)user.CA861ItemReads++;\n'+needle)
files={'caelum/player/CaelumPlayer.zs':player,'caelum/character/CaelumAppearanceHands.zs':hands}
with zipfile.ZipFile(out/'prototype.pk3','w') as archive:
 for name,text in files.items():
  target=out/name;target.parent.mkdir(parents=True,exist_ok=True);target.write_bytes(text.encode());archive.writestr(zipfile.ZipInfo(name,(2026,11,20,0,0,0)),text.encode())
(out/'SHA256.json').write_text(json.dumps({n:hashlib.sha256(s.encode()).hexdigest() for n,s in files.items()},indent=2)+'\n',encoding='utf-8')
s=(h/'hands861_candidate.zs').read_text(encoding='utf-8');i=s.rindex('    override void NetworkProcess');s=s[:i]+(h/'hands861_cache.zs').read_text(encoding='utf-8')+'\n'+s[i:];s=s.replace("if(e.Name!='ca857check')return;Probe();","if(e.Name!='ca857check')return;Probe();Warm();")
(h/'hands861_cache_full.zs').write_text(s,encoding='utf-8')
s=(h/'run_hands861_candidate.py').read_text(encoding='utf-8').replace('hands861_candidate.zs','hands861_cache_full.zs').replace('initial smoke only, not full ownership/save/performance or author qualification.','diagnostic-only lookup counters, five1000-call warm batches; elapsed time includes instrumentation and does not establish production frame performance.')
(h/'run_hands861_cache.py').write_text(s,encoding='utf-8');print('Prepared private lookup counters; production runtime/source unchanged.')
