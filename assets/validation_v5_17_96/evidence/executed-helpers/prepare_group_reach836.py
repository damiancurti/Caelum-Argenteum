"""Build a conservative, portal-safe shared-candidate broadphase prototype."""
from pathlib import Path
import argparse, hashlib, json, zipfile

def sha(data):
    return hashlib.sha256(data).hexdigest()

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--runtime',type=Path,required=True)
    parser.add_argument('--output',type=Path,required=True)
    args=parser.parse_args()
    out=args.output.resolve();out.mkdir(exist_ok=False)
    path='caelum/actors/CaelumVisualPerception.zs'
    with zipfile.ZipFile(args.runtime) as z: original=z.read(path).decode('utf-8')
    changes=[]
    def change(before,after):
        nonlocal source
        newline='\r\n' if '\r\n' in original else '\n'
        before=before.replace('\n',newline);after=after.replace('\n',newline)
        assert source.count(before)==1,(before,source.count(before))
        source=source.replace(before,after,1);changes.append((before,after))
    source=original
    marker='    static Actor Candidate(CaelumCombatActor observer)'
    helper='''    // #836: cota exterior conservadora; no concede visibilidad ni identidad.
    // Solo se usa sin grupos de portales enlazados. Los radios y el margen
    // de contacto mantienen dentro de la cota todo contacto fisico posible.
    static bool OutsideGroupReach(CaelumCombatActor observer,Actor candidate,double sightUpper)
    {
        double reach=sightUpper*Max(0.0,candidate.Height)/CaelumPerceptionData.REFERENCE_VISIBLE_HEIGHT
            +Max(0.0,observer.Radius)+Max(0.0,candidate.Radius)+0.01;
        return Abs(observer.Pos.X-candidate.Pos.X)>reach || Abs(observer.Pos.Y-candidate.Pos.Y)>reach;
    }

'''
    change(marker,helper+marker)
    anchor='''            // La lista espacial se comparte; cada miembro conserva sus filtros'''
    change(anchor,'''            double sightUpper=level.GetPortalGroupCount()==1
                ? CaelumPhysicsUnits.MapUnits(CaelumPerceptionData.VISUAL_BASE_METERS)*InsightFactor(observer) : -1;
'''+anchor)
    anchor='''                if(!Opponent(observer,candidate))continue;
                double distance=observer.Distance3D(candidate);'''
    change(anchor,'''                if(!Opponent(observer,candidate))continue;
                if(sightUpper>=0 && OutsideGroupReach(observer,candidate,sightUpper))continue;
                double distance=observer.Distance3D(candidate);''')
    anchor='''                if(friend==observer || !Living(friend))continue;
                double distance=observer.Distance3D(friend);'''
    change(anchor,'''                if(friend==observer || !Living(friend))continue;
                if(sightUpper>=0 && OutsideGroupReach(observer,friend,sightUpper))continue;
                double distance=observer.Distance3D(friend);''')
    restored=source
    for before,after in reversed(changes):
        assert restored.count(after)==1
        restored=restored.replace(after,before,1)
    assert restored==original
    files={path:source.encode('utf-8')}
    with zipfile.ZipFile(out/'prototype.pk3','w') as z:
        for name,data in sorted(files.items()):
            z.writestr(zipfile.ZipInfo(name,(2026,11,19,0,0,0)),data)
            target=out/'source'/name;target.parent.mkdir(parents=True,exist_ok=True);target.write_bytes(data)
    report={'issue':836,'runtime_sha256':sha(args.runtime.read_bytes()),'overlay_sha256':sha((out/'prototype.pk3').read_bytes()),'original_source_sha256':sha(original.encode('utf-8')),'prototype_source_sha256':sha(source.encode('utf-8')),'exact_restoration':restored==original,'scope':'Diagnostic candidate only. Original predicates and ordered loops remain for every surviving candidate; linked-portal maps take the original path. No production adoption yet.'}
    (out/'manifest.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
    print(json.dumps(report))

if __name__=='__main__':main()
