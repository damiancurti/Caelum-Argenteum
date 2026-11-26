"""Add diagnostic-only cold lookup counters to an overlay, never to src."""
from pathlib import Path
import hashlib,json,zipfile
import argparse
root=Path(__file__).resolve().parents[2]
parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--output',type=Path,required=True)
args=parser.parse_args();out=args.output.resolve()
if not out.is_relative_to((root/'build').resolve()):parser.error('--output must be a new directory under this checkout/build')
out.mkdir(exist_ok=False)
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
