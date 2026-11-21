"""Retain the inexpensive full-light rejection before reading current light."""
from pathlib import Path
import hashlib,json,zipfile
ROOT=Path('C:/GZDooMProjects/CaelumArgenteum/build/v517/work-713')
previous=ROOT/'build/issue873-light01/light.pk3';out=ROOT/'build/issue873-light02';out.mkdir(exist_ok=False)
path='caelum/actors/CaelumVisualPerception.zs'
with zipfile.ZipFile(previous) as z:original=z.read(path)
source=original.decode('utf-8').replace('\r\n','\n')
old='''        double reach=sightUpper*LightFactor(candidate.CurSector)*Max(0.0,candidate.Height)/CaelumPerceptionData.REFERENCE_VISIBLE_HEIGHT
            +Max(0.0,observer.Radius)+Max(0.0,candidate.Radius)+CaelumPerceptionData.CONTACT_MARGIN;
        return Abs(observer.Pos.X-candidate.Pos.X)>reach || Abs(observer.Pos.Y-candidate.Pos.Y)>reach;'''
new='''        double height=Max(0.0,candidate.Height);
        double observerRadius=Max(0.0,observer.Radius),candidateRadius=Max(0.0,candidate.Radius);
        double dx=Abs(observer.Pos.X-candidate.Pos.X),dy=Abs(observer.Pos.Y-candidate.Pos.Y);
        double reach=sightUpper*height/CaelumPerceptionData.REFERENCE_VISIBLE_HEIGHT
            +observerRadius+candidateRadius+CaelumPerceptionData.CONTACT_MARGIN;
        if(dx>reach || dy>reach)return true;
        // #873: solo los vecinos restantes necesitan la luz actual; sin cache.
        reach=sightUpper*LightFactor(candidate.CurSector)*height/CaelumPerceptionData.REFERENCE_VISIBLE_HEIGHT
            +observerRadius+candidateRadius+CaelumPerceptionData.CONTACT_MARGIN;
        return dx>reach || dy>reach;'''
assert source.count(old)==1;source=source.replace(old,new,1)
nl='\r\n' if b'\r\n' in original else '\n';assert source.replace(new,old,1).replace('\n',nl).encode()==original
data=source.replace('\n',nl).encode()
with zipfile.ZipFile(out/'light.pk3','x') as z:z.writestr(zipfile.ZipInfo(path,(2026,11,21,0,0,0)),data)
target=out/'source'/path;target.parent.mkdir(parents=True,exist_ok=True);target.write_bytes(data)
sha=lambda b:hashlib.sha256(b).hexdigest()
manifest=json.loads((ROOT/'build/issue873-light01/manifest.json').read_text());manifest.update(previous_overlay_sha256=sha(previous.read_bytes()),overlay_sha256=sha((out/'light.pk3').read_bytes()),candidate_sha256=sha(data),previous_restored_exactly=True,scope='Retain the original full-light bound first and only calculate current illumination for surviving bodies. Both reach expressions preserve the original addition/multiplication order. Same conservative contact padding and portal guards; no new fields or caches.')
(out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf-8',newline='\n');print(json.dumps(manifest))
