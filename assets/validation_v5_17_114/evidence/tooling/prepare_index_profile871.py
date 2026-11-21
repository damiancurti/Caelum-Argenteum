"""Measure the maintenance chain called by native NPC thermal updates."""
from pathlib import Path
import hashlib,json,re,zipfile
ROOT=Path('C:/GZDooMProjects/CaelumArgenteum/build/v517/work-713')
runtime=ROOT/'build/issue870-diagnosis01.pk3';out=ROOT/'build/issue871-index01';out.mkdir(exist_ok=False)
specs=[('CaelumContaminationSurface.zs', 'FloorTile', 'user,sheet,create', 'user'), ('CaelumContaminationSurface.zs', 'Find', 'kind,surface,side,x,y,create', None), ('CaelumContaminationSurface.zs', 'Index', '', None), ('CaelumContaminationSurface.zs', 'Hash', 'kind,surface,side,x,y', None)]

originals={};files={};edits=[]
with zipfile.ZipFile(runtime) as z:
    for short,*_ in specs:
        p='caelum/survival/'+short
        if p not in files:originals[p]=z.read(p);files[p]=originals[p].decode('utf-8').replace('\r\n','\n')
def replace(p,old,new):
    assert files[p].count(old)==1,(p,old[:80]);files[p]=files[p].replace(old,new,1);edits.append((p,old,new))
def end_body(source,begin):
    tokens=re.compile(r'//[^\n]*|/\*[\s\S]*?\*/|"(?:\\.|[^"\\])*"|\'(?:\\.|[^\'\\])*\'|[{}]');depth=0
    for m in tokens.finditer(source,begin):
        if m.group()=='{':depth+=1
        elif m.group()=='}':
            depth-=1
            if depth==0:return m.end()
    raise AssertionError('Unclosed body')
for metric,(short,name,args,actor) in enumerate(specs):
    p='caelum/survival/'+short;s=files[p]
    pattern=r'(?m)^    (?P<prefix>(?:(?:static|action|virtual|override) )*)(?P<type>\w+) '+name+r'\((?P<params>[^)]*)\)\s*\{'
    matches=list(re.finditer(pattern,s));assert len(matches)==1,(p,name,len(matches));m=matches[0]
    end=end_body(s,m.end()-1);old=s[m.start():end];renamed=old.replace(name+'(',f'CA871Original{metric}(',1)
    family=f'CA871IndexProbe.Family({actor})' if actor else 'ca871Probe.CurrentFamily'
    begin_context='int ca871Previous=0;if(ca871Probe!=null){ca871Previous=ca871Probe.CurrentFamily;ca871Probe.CurrentFamily=ca871Family;ca871Probe.ContactDepth++;}' if name=='FloorTile' else ''
    end_context='if(ca871Probe!=null){ca871Probe.CurrentFamily=ca871Previous;ca871Probe.ContactDepth--;}' if name=='FloorTile' else ''
    call=f'CA871Original{metric}({args});';is_void=m['type']=='void'
    wrapper=s[m.start():m.end()]+f'''
        let ca871Probe=CA871IndexProbe.FindContact({str(metric==0).lower()});
        int ca871Family=ca871Probe!=null?{family}:0;
        {begin_context}
        double ca871Start=ca871Probe!=null?MSTimeF():0;
        '''+('' if is_void else 'let ca871Result=')+call+f'''
        if(ca871Probe!=null)ca871Probe.Record(ca871Family*4+{metric},ca871Start);
        {end_context}
        '''+('' if is_void else 'return ca871Result;')+'''
    }
'''+renamed
    replace(p,old,wrapper)
restored=dict(files)
for p,old,new in reversed(edits):assert restored[p].count(new)==1;restored[p]=restored[p].replace(new,old,1)
for p,s in restored.items():assert s.replace('\n','\r\n' if b'\r\n' in originals[p] else '\n').encode()==originals[p]
handler='''
class CA871IndexProbe : StaticEventHandler
{
    const METRICS=12;const WINDOW=700;
    Array<double> Total,Maximum;Array<int> Calls;
    bool Ready,Printed;int CurrentFamily,ContactDepth;
    static CA871IndexProbe FindSample()
    {
        if(level.time<3599 || level.time>=4299 || (level.time-3599)%17!=0)return null;
        return CA871IndexProbe(StaticEventHandler.Find('CA871IndexProbe'));
    }
    static CA871IndexProbe FindContact(bool entry)
    {let probe=FindSample();return probe!=null && (entry || probe.ContactDepth>0)?probe:null;}
    static int Family(Actor body){return body is 'CaelumMandinga'?0:body is 'CaelumPortDefender'?1:2;}
    override void WorldLoaded(WorldEvent e)
    {Total.Resize(METRICS*WINDOW);Maximum.Resize(METRICS*WINDOW);Calls.Resize(METRICS*WINDOW);CurrentFamily=2;Ready=true;}
    void Record(int metric,double start)
    {double elapsed=MSTimeF()-start;int cell=metric*WINDOW+level.time-3599;Total[cell]+=elapsed;Maximum[cell]=Max(Maximum[cell],elapsed);Calls[cell]++;}
    override void WorldTick()
    {
        if(!Ready || Printed || level.time!=4350)return;Printed=true;
        for(int tic=0;tic<WINDOW;tic++)for(int metric=0;metric<METRICS;metric++)
        {int cell=metric*WINDOW+tic;if(Calls[cell]>0)Console.Printf("CA871 INDEX tic=%d metric=%d total=%.6f maximum=%.6f calls=%d",tic+3599,metric,Total[cell],Maximum[cell],Calls[cell]);}
        let sheet=CaelumContaminationSurfaces.CurrentMap(CaelumPlayer(players[0].mo));
        if(sheet!=null)
        {
            Console.Printf("CA871 TILE_INDEX tiles=%d buckets=%d",sheet.Tiles.Size(),sheet.Buckets.Size());
            for(int i=0;i<sheet.Tiles.Size();i++)
            {
                let tile=sheet.Tiles[i];
                Console.Printf("CA871 TILE i=%d kind=%d surface=%d side=%d x=%d y=%d",i,tile.Kind,tile.Surface,tile.Side,tile.X,tile.Y);
            }
        }
        Console.Printf("CA871 INDEX_COMPLETE");
    }
}
'''
files['caelum/survival/CaelumContaminationSurface.zs']+=handler;files['MAPINFO']='gameinfo { AddEventHandlers="CA871IndexProbe" }\n'
with zipfile.ZipFile(out/'index.pk3','x') as z:
    for p,s in sorted(files.items()):
        data=s.replace('\n','\r\n' if b'\r\n' in originals.get(p,b'') else '\n').encode();z.writestr(zipfile.ZipInfo(p,(2026,11,21,0,0,0)),data)
        target=out/'source'/p;target.parent.mkdir(parents=True,exist_ok=True);target.write_bytes(data)
sha=lambda b:hashlib.sha256(b).hexdigest()
stages=[short+':'+name for short,name,*_ in specs]
metrics=[dict(id=family*4+i,family=family_name,stage=stage) for family,family_name in enumerate(['Mandinga','PortDefender','other']) for i,stage in enumerate(stages)]
manifest=dict(issue=871,runtime_sha256=sha(runtime.read_bytes()),overlay_sha256=sha((out/'index.pk3').read_bytes()),originals_restored_exactly={p:sha(b) for p,b in originals.items()},metrics=metrics,period=17,qualification='Private inclusive maintenance timers; no production statements changed. FloorTile tags nested calls by actor family and restores the prior tag; subordinate metrics record only inside that call stack. Nested timers include wrapper overhead and must not be added as independent CPU costs.')
(out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf-8',newline='\n');print(json.dumps(dict(output=str(out),overlay_sha256=manifest['overlay_sha256'])))
