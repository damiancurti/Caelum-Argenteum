"""Prototype a read-only relationship guard after the existing geometric bound."""
from pathlib import Path
import argparse,hashlib,json,zipfile
root=Path(__file__).resolve().parents[2]
parser=argparse.ArgumentParser(description=__doc__)
parser.add_argument('--runtime',type=Path,required=True)
parser.add_argument('--output',type=Path,required=True)
args=parser.parse_args();out=args.output.resolve();out.relative_to(root/'build');out.mkdir(exist_ok=False)
path='caelum/actors/CaelumVisualPerception.zs'
with zipfile.ZipFile(args.runtime) as package:original=package.read(path)
source=original.decode('utf-8');newline='\r\n' if '\r\n' in source else '\n'
source=source.replace('\r\n','\n')
first='''            // La lista espacial se comparte; cada miembro conserva sus filtros'''
insert='''            // #838: estas rutas solo leen relaciones. Residentes y delegados
            // conservan el orden anterior, incluido el mantenimiento de esquemas.
            bool readOnlyRelation=!(observer is "CaelumAnchoredResident")
                && !(observer is "CaelumSummonedZupay")
                && !(observer is "CaelumTarotAutomaton") && !(observer is "CaelumTarotClone");
'''
assert source.count(first)==1
source=source.replace(first,insert+first,1)
before='''                if(!Opponent(observer,candidate))continue;
                if(sightUpper>=0 && OutsideGroupReach(observer,candidate,sightUpper))continue;'''
after='''                if(candidate==null)continue;
                if(readOnlyRelation && sightUpper>=0 && OutsideGroupReach(observer,candidate,sightUpper))continue;
                if(!Opponent(observer,candidate))continue;
                if(!readOnlyRelation && sightUpper>=0 && OutsideGroupReach(observer,candidate,sightUpper))continue;'''
assert source.count(before)==1
source=source.replace(before,after,1)
assert source.replace(after,before,1).replace(insert,'',1).replace('\n',newline).encode()==original
data=source.replace('\n',newline).encode()
with zipfile.ZipFile(out/'prototype.pk3','w') as z:z.writestr(zipfile.ZipInfo(path,(2026,11,19,0,0,0)),data)
p=out/'source'/path;p.parent.mkdir(parents=True);p.write_bytes(data)
sha=lambda b:hashlib.sha256(b).hexdigest()
report={'issue':838,'source_path':path,'baseline_source_sha256':sha(original),'candidate_source_sha256':sha(data),'overlay_sha256':sha((out/'prototype.pk3').read_bytes()),'inverse_source_exact':True,'qualification':'Diagnostic prototype; same reach bound and fallback ordering for residents, summoned bodies, automatons and clones. No production edit.'}
(out/'manifest.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
print(json.dumps(report))
