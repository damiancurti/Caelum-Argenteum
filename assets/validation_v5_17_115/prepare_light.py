"""Build a private current-light conservative reach prototype from release 114."""
from pathlib import Path
import hashlib,json,zipfile
ROOT=Path(__file__).resolve().parents[2]
import argparse
p=argparse.ArgumentParser(description=__doc__)
p.add_argument('--runtime',type=Path,required=True);p.add_argument('--output',type=Path,required=True)
p.add_argument('--fast',action='store_true');args=p.parse_args()
runtime=args.runtime.resolve(strict=True);out=args.output.resolve();out.relative_to(ROOT/'build');out.mkdir(exist_ok=False)
path='caelum/actors/CaelumVisualPerception.zs'
with zipfile.ZipFile(runtime) as z:original=z.read(path)
source=original.decode('utf-8').replace('\r\n','\n');edits=[]
def change(old,new):
    global source
    assert source.count(old)==1,old
    source=source.replace(old,new,1);edits.append((old,new))
old='''    static double Range(CaelumCombatActor observer,Actor candidate)
    {
        if(candidate==null)return 0;
        double light=candidate.CurSector==null ? 0.0 : Clamp(double(candidate.CurSector.lightlevel),0.0,CaelumPerceptionData.NATIVE_FULL_LIGHT);
        double illumination=CaelumPerceptionData.DARK_RANGE_FACTOR
            +(1.0-CaelumPerceptionData.DARK_RANGE_FACTOR)*light/CaelumPerceptionData.NATIVE_FULL_LIGHT;
'''
new='''    static double LightFactor(Sector sector)
    {
        double light=sector==null ? 0.0 : Clamp(double(sector.lightlevel),0.0,CaelumPerceptionData.NATIVE_FULL_LIGHT);
        return CaelumPerceptionData.DARK_RANGE_FACTOR
            +(1.0-CaelumPerceptionData.DARK_RANGE_FACTOR)*light/CaelumPerceptionData.NATIVE_FULL_LIGHT;
    }

    static double Range(CaelumCombatActor observer,Actor candidate)
    {
        if(candidate==null)return 0;
        double illumination=LightFactor(candidate.CurSector);
'''
change(old,new)
change('double reach=sightUpper*Max(0.0,candidate.Height)/CaelumPerceptionData.REFERENCE_VISIBLE_HEIGHT',
       'double reach=sightUpper*LightFactor(candidate.CurSector)*Max(0.0,candidate.Height)/CaelumPerceptionData.REFERENCE_VISIBLE_HEIGHT')
if args.fast:change('        double reach=sightUpper*LightFactor(candidate.CurSector)*Max(0.0,candidate.Height)/CaelumPerceptionData.REFERENCE_VISIBLE_HEIGHT\n            +Max(0.0,observer.Radius)+Max(0.0,candidate.Radius)+CaelumPerceptionData.CONTACT_MARGIN;\n        return Abs(observer.Pos.X-candidate.Pos.X)>reach || Abs(observer.Pos.Y-candidate.Pos.Y)>reach;','        double height=Max(0.0,candidate.Height);\n        double observerRadius=Max(0.0,observer.Radius),candidateRadius=Max(0.0,candidate.Radius);\n        double dx=Abs(observer.Pos.X-candidate.Pos.X),dy=Abs(observer.Pos.Y-candidate.Pos.Y);\n        double reach=sightUpper*height/CaelumPerceptionData.REFERENCE_VISIBLE_HEIGHT\n            +observerRadius+candidateRadius+CaelumPerceptionData.CONTACT_MARGIN;\n        if(dx>reach || dy>reach)return true;\n        // #873: solo los vecinos restantes necesitan la luz actual; sin cache.\n        reach=sightUpper*LightFactor(candidate.CurSector)*height/CaelumPerceptionData.REFERENCE_VISIBLE_HEIGHT\n            +observerRadius+candidateRadius+CaelumPerceptionData.CONTACT_MARGIN;\n        return dx>reach || dy>reach;')
restored=source
for old,new in reversed(edits):assert restored.count(new)==1;restored=restored.replace(new,old,1)
encode=lambda s:s.replace('\n','\r\n' if b'\r\n' in original else '\n').encode('utf-8')
assert encode(restored)==original
data=encode(source)
with zipfile.ZipFile(out/'light.pk3','x') as z:z.writestr(zipfile.ZipInfo(path,(2026,11,21,0,0,0)),data)
target=out/'source'/path;target.parent.mkdir(parents=True,exist_ok=True);target.write_bytes(data)
sha=lambda b:hashlib.sha256(b).hexdigest()
manifest=dict(issue=873,runtime_sha256=sha(runtime.read_bytes()),overlay_sha256=sha((out/'light.pk3').read_bytes()),original_sha256=sha(original),candidate_sha256=sha(data),original_restored_exactly=True,fast_path=args.fast,production_accepted=False,scope='Rejected experimental bound. Extract the existing sector-light arithmetic without changing Range, then use its current value in the conservative reach bound. Contact radii, portal guards, relation order and all other statements remain unchanged. No new fields or caches. Private prototype, not production acceptance.')
(out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf-8',newline='\n')
print(json.dumps(manifest))
