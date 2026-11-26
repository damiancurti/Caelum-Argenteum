"""Audit the final package against its parent and the exact working sources."""
from pathlib import Path
import argparse,hashlib,json,zipfile

ROOT=Path(__file__).resolve().parents[2]

def text(data):return data.decode('utf-8').replace('\r\n','\n')
def sha(data):return hashlib.sha256(data).hexdigest()

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--baseline',type=Path,required=True)
    parser.add_argument('--runtime',type=Path,required=True)
    parser.add_argument('--output',type=Path,required=True)
    args=parser.parse_args()
    visual='caelum/actors/CaelumVisualPerception.zs';data='caelum/data/CaelumPerceptionData.zs'
    diagnostics=['caelum/world/CaelumPhysicalHazards.zs','caelum/world/CaelumSewerMaze.zs']
    expected={visual,data,*diagnostics};changed=[]
    with zipfile.ZipFile(args.baseline) as before,zipfile.ZipFile(args.runtime) as after:
        names=sorted(after.namelist());assert names==sorted(before.namelist())
        assert names==sorted(p.relative_to(ROOT/'src').as_posix() for p in (ROOT/'src').rglob('*') if p.is_file())
        for name in names:
            previous=before.read(name);current=after.read(name)
            assert current==(ROOT/'src'/name).read_bytes(),name
            if previous!=current:changed.append(name)
        assert set(changed)==expected,changed
        for name in diagnostics:
            assert text(after.read(name)).replace('[Caelum 5.17.96]','[Caelum 5.17.95]')==text(before.read(name)),name
        current=text(after.read(visual)).replace('CaelumPerceptionData.CONTACT_MARGIN','0.01')
        start=current.index('    // #836: cota exterior conservadora;')
        end=current.index('    static Actor Candidate(',start)
        helper=current[start:end];assert 'static bool OutsideGroupReach' in helper
        current=current[:start]+current[end:]
        insertions=[
            '            double sightUpper=level.GetPortalGroupCount()==1\n                ? CaelumPhysicsUnits.MapUnits(CaelumPerceptionData.VISUAL_BASE_METERS)*InsightFactor(observer) : -1;\n',
            '                if(sightUpper>=0 && OutsideGroupReach(observer,candidate,sightUpper))continue;\n',
            '                if(sightUpper>=0 && OutsideGroupReach(observer,friend,sightUpper))continue;\n']
        for insertion in insertions:
            assert current.count(insertion)==1
            current=current.replace(insertion,'',1)
        assert current==text(before.read(visual)),'Unrelated visual behavior changed.'
        current=text(after.read(data))
        insertion='    // #836: margen de contacto preexistente, compartido con la cota exterior.\n    const CONTACT_MARGIN = 0.01;\n'
        assert current.count(insertion)==1
        assert current.replace(insertion,'',1)==text(before.read(data))
    report={'issue':836,'passed':True,'baseline_sha256':sha(args.baseline.read_bytes()),'runtime_sha256':sha(args.runtime.read_bytes()),'runtime_bytes':args.runtime.stat().st_size,'members':len(names),'changed_members':changed,'scope':'All package bytes equal current src. Only the query helper/guards, relocation of the existing contact margin and two diagnostic version strings differ semantically from the parent. Removing exactly those additions restores the original perception/data source; no saved-field or revision change. All other runtime members byte-identical.'}
    args.output.write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8');print(json.dumps(report))

if __name__=='__main__':main()
