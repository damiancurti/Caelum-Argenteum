"""Extend retained native save checks with actual candidate ceiling-plane bounds."""
from pathlib import Path
import hashlib,json,struct,subprocess,sys,zipfile
ROOT=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(ROOT/'assets/generators'))
from generate_tarot_justice import lumps,parse
index=sys.argv.index('--overlay');overlay=Path(sys.argv[index+1]).resolve(strict=True);del sys.argv[index:index+2]
assert 'gzdoom.exe' not in subprocess.check_output(['tasklist','/FI','IMAGENAME eq gzdoom.exe','/FO','CSV','/NH'],text=True,errors='replace').lower()
with zipfile.ZipFile(overlay) as z:wad=z.read('maps/MAP02.wad')
textmap=dict(lumps(wad))['TEXTMAP'];checksum=hashlib.md5(textmap).hexdigest()
groups=parse(textmap.decode('utf-8'));indices=[i for i,s in enumerate(groups['sector']) if 'ceilingplane_a' in s]
assert indices
layout=json.loads((ROOT/'assets/map02_maze/LAYOUT.json').read_text(encoding='utf-8'))
cases=''.join(f'case {i}:return true;\n' for i in indices)
geometry='''
class CA875GeometryCheck : EventHandler
{
    static bool Expected(int index)
    {switch(index){CASES default:return false;}}
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name!="ca454_probe")return;
        int count=0,endpoints=0;double minimum=1e30,maximum=-1e30;bool okay=true;
        if(level.MapName!="MAP02" || level.GetChecksum()!="CHECKSUM")
        {Console.Printf("CA875 GEOMETRY FAIL checksum/map");return;}
        for(int i=0;i<level.Sectors.Size();i++)
        {
            if(!Expected(i))continue;count++;
            let sector=level.Sectors[i];
            for(int edge=0;edge<sector.lines.Size();edge++)for(int end=0;end<2;end++)
            {
                let line=sector.lines[edge];vector2 point=end==0?line.v1.p:line.v2.p;
                double height=sector.ceilingplane.ZatPoint(point);endpoints++;
                minimum=Min(minimum,height);maximum=Max(maximum,height);
                if(height<SPRING-0.000001 || height>CROWN+0.000001)okay=false;
                if(height-sector.floorplane.ZatPoint(point)<BODYHEIGHT)okay=false;
            }
        }
        okay=okay && count==COUNT && endpoints>0;
        Console.Printf("CA875 GEOMETRY %s sectors=%d endpoints=%d minimum=%.9f maximum=%.9f checksum=%s",okay?"PASS":"FAIL",count,endpoints,minimum,maximum,level.GetChecksum());
    }
}
'''.replace('CASES',cases).replace('CHECKSUM',checksum).replace('SPRING',str(layout['ceiling'])).replace('CROWN',str(layout['chamber_height'])).replace('BODYHEIGHT',str(layout['largest_supported_height'])).replace('COUNT',str(len(indices)))
original=ROOT/'assets/validation_v5_16_2/run_native.py';source=original.read_text(encoding='utf-8')
changes=[
    ('str(runtime),str(fixture)','str(runtime),str(CA875_OVERLAY),str(fixture)'),
    ("'probe.zs':(HERE/'native_probe.zs').read_bytes()","'probe.zs':(HERE/'native_probe.zs').read_bytes()+CA875_GEOMETRY.encode('utf-8')"),
    ('AddEventHandlers="CA454Probe"','AddEventHandlers="CA454Probe", "CA875GeometryCheck"'),
    ("'CA454 NATIVE PASS map=MAP02' in log and", "'CA454 NATIVE PASS map=MAP02' in log and 'CA875 GEOMETRY PASS' in log and"),
    ("'CA454 NATIVE FAIL')", "'CA454 NATIVE FAIL','CA875 GEOMETRY FAIL')"),
    ('report=dict(issue=454,','report=dict(issue=875,overlay_sha256=digest(CA875_OVERLAY),'),
    ("    fixture=out/'probe.pk3'", "    (out/'geometry.zs').write_text(CA875_GEOMETRY,encoding='utf-8',newline='\\n')\n    fixture=out/'probe.pk3'")]
for old,new in changes:assert source.count(old)==1,old;source=source.replace(old,new,1)
exec(compile(source,str(original),'exec'),{'__file__':str(original),'__name__':'__main__','CA875_OVERLAY':overlay,'CA875_GEOMETRY':geometry})
