from pathlib import Path
import zipfile,hashlib,json
root=Path(__file__).resolve().parents[2];runtime=root/'build/v516/issue454-integrated02.pk3';out=root/'build/v516/barracas-distance-reuse01';out.mkdir(exist_ok=False)
path='caelum/actors/CaelumVisualPerception.zs'
with zipfile.ZipFile(runtime) as package:original=package.read(path)
source=original.decode('utf-8')
signature='static bool CanSee(CaelumCombatActor observer,Actor candidate)'
assert source.count(signature)==1
source=source.replace(signature,'static bool CanSee(CaelumCombatActor observer,Actor candidate,double knownDistance=-1)')
distance='if(observer.Distance3D(candidate)>Range(observer,candidate))return false;'
assert source.count(distance)==1
source=source.replace(distance,'if((knownDistance>=0 ? knownDistance : observer.Distance3D(candidate))>Range(observer,candidate))return false;')
start=source.index('    static Actor Candidate(');end=source.index('    static bool Identify(',start)
body=source[start:end]
assert body.count('CanSee(observer,candidate)')==3 and body.count('CanSee(observer,friend)')==2
body=body.replace('CanSee(observer,candidate)','CanSee(observer,candidate,distance)').replace('CanSee(observer,friend)','CanSee(observer,friend,distance)')
source=source[:start]+body+source[end:]
with zipfile.ZipFile(out/'preview.pk3','w',zipfile.ZIP_STORED) as package:package.writestr(zipfile.ZipInfo(path,(2026,11,13,0,0,0)),source.encode())
(out/'manifest.json').write_bytes((json.dumps({'issue':454,'scope':'Diagnostic reuse of the identical Distance3D already computed within each Candidate loop. Original predicate order/contact exception retained. No production change yet.','runtime_sha256':hashlib.sha256(runtime.read_bytes()).hexdigest(),'original_source_sha256':hashlib.sha256(original).hexdigest(),'candidate_source_sha256':hashlib.sha256(source.encode()).hexdigest()},indent=2)+'\n').encode())
print(out/'preview.pk3')
