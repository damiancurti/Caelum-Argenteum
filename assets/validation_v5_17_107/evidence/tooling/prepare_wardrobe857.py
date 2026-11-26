"""Assemble an isolated equipment-driven wardrobe prototype on the tested runtime."""
from pathlib import Path
import argparse,hashlib,json,zipfile
from prepare_wardrobe_data857 import generate,ROOT
p=argparse.ArgumentParser(description=__doc__);p.add_argument('--runtime',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args()
out=a.output.resolve();out.relative_to(ROOT/'build');out.mkdir(exist_ok=False);helper=Path(__file__).resolve().parent
paths=['ZSCRIPT','MODELDEF','CVARINFO','caelum/character/CaelumDomingoPilot.zs','caelum/equipment/CaelumInventoryService.zs']
with zipfile.ZipFile(a.runtime) as z:original={n:z.read(n) for n in paths}
files={n:b.decode('utf-8').replace('\r\n','\n') for n,b in original.items()};edits=[]
def change(name,old,new):
    assert files[name].count(old)==1,(name,old,files[name].count(old));files[name]=files[name].replace(old,new);edits.append((name,old,new))
pilot='caelum/character/CaelumDomingoPilot.zs';inventory='caelum/equipment/CaelumInventoryService.zs'
change(pilot,'''    bool UpdatePilotVisual()
    {
        if(CurState==null || CharacterProfile==null)return false;''','''    bool UpdatePilotVisual()
    {
        bool wardrobeEnabled=CaelumWardrobeVisual.Enabled();
        // Desactivar permite guardar sin referencias al tipo visual candidato.
        if(!wardrobeEnabled && PilotBody is 'CaelumWardrobePilotBody')
        {PilotBody.Destroy();PilotBody=null;}
        if(CurState==null || CharacterProfile==null)return false;''')
old="        supported=supported && !(CurState.sprite==GetSpriteIndex('RSDO') && CurState.Frame>=2);"
change(pilot,old,old+'\n        bool useWardrobe=wardrobeEnabled && CaelumWardrobeVisual.Supported(self,supported);')
change(pilot,'''        if(PilotBody==null)
        {
            PilotBody=CaelumDomingoPilotBody(Actor.Spawn('CaelumDomingoPilotBody',Pos,NO_REPLACE));''','''        if(PilotBody!=null && useWardrobe!=(PilotBody is 'CaelumWardrobePilotBody'))
        {PilotBody.Destroy();PilotBody=null;}
        if(PilotBody==null)
        {
            Name bodyClass=useWardrobe?'CaelumWardrobePilotBody':'CaelumDomingoPilotBody';
            PilotBody=CaelumDomingoPilotBody(Actor.Spawn(bodyClass,Pos,NO_REPLACE));''')
change(pilot,'''            PilotBody.bInvisible=bInvisible;
            PilotBody.UpdateVisual();''','''            PilotBody.bInvisible=bInvisible;
            let wardrobe=CaelumWardrobePilotBody(PilotBody);
            if(wardrobe!=null)wardrobe.Sync(self);
            PilotBody.UpdateVisual();''')
change(inventory,'''    static void OnNativeInventoryChanged(CaelumPlayer user)
    {
        if (!CaelumPlayerAuthority.CanMutate(user)) return;
        CaelumTarotStar.Changed(user);''','''    static void OnNativeInventoryChanged(CaelumPlayer user)
    {
        if (!CaelumPlayerAuthority.CanMutate(user)) return;
        CaelumWardrobeVisual.Invalidate(user);
        CaelumTarotStar.Changed(user);''')
restored=files.copy()
for name,old,new in reversed(edits):assert restored[name].count(new)==1;restored[name]=restored[name].replace(new,old)
assert all(restored[n]==b.decode('utf-8').replace('\r\n','\n') for n,b in original.items())
data,definition,metadata=generate()
files.pop('ZSCRIPT')
# A later PK3 ZSCRIPT unit cannot satisfy forward references in the base unit.
# Inject the includes through the overridden pilot source used by that unit.
files[pilot]+='\n#include "caelum/data/CaelumWornClothingModelData.zs"\n#include "caelum/character/CaelumWardrobePilot.zs"\n'
files['MODELDEF']='#include "caelum/data/wardrobe_candidate.modeldef"\n'
files['CVARINFO']='// #857: candidato visual de sesion; no modifica el equipo ni el guardado.\nnosave noarchive server bool ca_wardrobe_candidate = false;\n'
files['caelum/data/CaelumWornClothingModelData.zs']=data
files['caelum/data/wardrobe_candidate.modeldef']=definition
files['caelum/character/CaelumWardrobePilot.zs']=(helper/'wardrobe_candidate857.zs').read_text(encoding='utf-8')
sha=lambda b:hashlib.sha256(b).hexdigest();hashes={}
with zipfile.ZipFile(out/'prototype.pk3','w') as z:
    for name,source in sorted(files.items()):
        nl='\r\n' if name in original and b'\r\n' in original[name] else '\n';blob=source.replace('\n',nl).encode('utf-8')
        z.writestr(zipfile.ZipInfo(name,(2026,11,19,0,0,0)),blob)
        path=out/'source'/name;path.parent.mkdir(parents=True,exist_ok=True);path.write_bytes(blob);hashes[name]=sha(blob)
metadata.update(dict(runtime_sha256=sha(a.runtime.read_bytes()),overlay_sha256=sha((out/'prototype.pk3').read_bytes()),sources=hashes,inverse_existing_logic_exact=True,source_version='prototype_unverified',new_presentation_class='CaelumWardrobePilotBody',new_player_class=False,presentation_revision=1,activation='Default-off nosave/noarchive server CVAR; existing opt-in Domingo player only. Ordinary player/default presentation remains unchanged.',save_qualification='Forward migration, dead-outfit snapshot, transient cache reconstruction and disabled legacy-save rollback require native verification before production integration.'))
(out/'manifest.json').write_text(json.dumps(metadata,indent=2)+'\n',encoding='utf-8');print(json.dumps(dict(output=str(out),sha256=metadata['overlay_sha256'],members=len(files))))
