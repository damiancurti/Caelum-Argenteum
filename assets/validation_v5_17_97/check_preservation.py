"""Verify exact package scope and the inverse relationship-order transformation."""
from pathlib import Path
import argparse,hashlib,json,zipfile
ROOT=Path(__file__).resolve().parents[2]
def sha(data):return hashlib.sha256(data).hexdigest()
def text(data):return data.decode('utf-8').replace('\r\n','\n')
def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--baseline',type=Path,required=True)
    parser.add_argument('--runtime',type=Path,required=True)
    parser.add_argument('--output',type=Path,required=True)
    args=parser.parse_args()
    visual='caelum/actors/CaelumVisualPerception.zs'
    diagnostics=['caelum/world/CaelumPhysicalHazards.zs','caelum/world/CaelumSewerMaze.zs']
    changed=[]
    with zipfile.ZipFile(args.baseline) as before,zipfile.ZipFile(args.runtime) as after:
        names=sorted(after.namelist());assert names==sorted(before.namelist())
        assert names==sorted(p.relative_to(ROOT/'src').as_posix() for p in (ROOT/'src').rglob('*') if p.is_file())
        for name in names:
            previous=before.read(name);current=after.read(name)
            assert current==(ROOT/'src'/name).read_bytes(),name
            if previous!=current:changed.append(name)
        assert set(changed)=={visual,*diagnostics},changed
        for name in diagnostics:
            assert after.read(name).replace(b'[Caelum 5.17.97]',b'[Caelum 5.17.96]')==before.read(name)
        source=text(after.read(visual))
        insertion='''            // #838: estas rutas solo leen relaciones. Residentes y delegados
            // conservan el orden anterior, incluido el mantenimiento de esquemas.
            bool readOnlyRelation=!(observer is "CaelumAnchoredResident")
                && !(observer is "CaelumSummonedZupay")
                && !(observer is "CaelumTarotAutomaton") && !(observer is "CaelumTarotClone");
'''
        candidate='''                if(candidate==null)continue;
                if(readOnlyRelation && sightUpper>=0 && OutsideGroupReach(observer,candidate,sightUpper))continue;
                if(!Opponent(observer,candidate))continue;
                if(!readOnlyRelation && sightUpper>=0 && OutsideGroupReach(observer,candidate,sightUpper))continue;'''
        original='''                if(!Opponent(observer,candidate))continue;
                if(sightUpper>=0 && OutsideGroupReach(observer,candidate,sightUpper))continue;'''
        assert source.count(insertion)==1 and source.count(candidate)==1
        assert source.replace(insertion,'',1).replace(candidate,original,1)==text(before.read(visual))
    report={'issue':838,'passed':True,'baseline_sha256':sha(args.baseline.read_bytes()),'runtime_sha256':sha(args.runtime.read_bytes()),'runtime_bytes':args.runtime.stat().st_size,'members':len(names),'changed_members':changed,'scope':'Exact source/package equality. Only the read-only relationship guard/order and two diagnostic version strings differ from the parent. Inverse transformation restores original visual source. No data, clocks, scans, schema, saved fields or resource changes.'}
    args.output.write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8');print(json.dumps(report))
if __name__=='__main__':main()
