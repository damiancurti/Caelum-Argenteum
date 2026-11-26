from pathlib import Path
import zipfile,hashlib,json
root=Path(__file__).resolve().parents[2];runtime=root/'build/v516/issue454-integrated02.pk3';out=root/'build/v516/barracas-range-first02';out.mkdir(exist_ok=False)
path='caelum/actors/CaelumVisualPerception.zs'
with zipfile.ZipFile(runtime) as package:original=package.read(path)
source=original.decode('utf-8')
field='        if(Abs(observer.DeltaAngle(observer.Angle,observer.AngleTo(candidate)))>CaelumPerceptionData.VISUAL_FIELD_DEGREES/2)return false;'
distance='        if(observer.Distance3D(candidate)>Range(observer,candidate))return false;'
newline='\r\n' if '\r\n' in source else '\n'
assert source.count(field+newline+distance)==1
source=source.replace(field+newline+distance,distance+newline+field)
with zipfile.ZipFile(out/'preview.pk3','w',zipfile.ZIP_STORED) as package:package.writestr(zipfile.ZipInfo(path,(2026,11,13,0,0,0)),source.encode())
(out/'manifest.json').write_bytes((json.dumps({'issue':454,'scope':'Diagnostic reordering of identical range/angle predicates after unchanged touching exception. No production change yet.','runtime_sha256':hashlib.sha256(runtime.read_bytes()).hexdigest(),'original_source_sha256':hashlib.sha256(original).hexdigest(),'candidate_source_sha256':hashlib.sha256(source.encode()).hexdigest()},indent=2)+'\n').encode())
print(out/'preview.pk3')
