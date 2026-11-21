"""Instrument current actor tick stages, restoring every production byte inversely."""
from pathlib import Path
import hashlib,json,zipfile
ROOT=Path('C:/GZDooMProjects/CaelumArgenteum/build/v517/work-713')
runtime=ROOT/'build/issue868-diagnosis01.pk3';out=ROOT/'build/issue870-stages01';out.mkdir(exist_ok=False)
originals={};files={};edits=[]
with zipfile.ZipFile(runtime) as z:
    for p in ['caelum/actors/CaelumCombatActor.zs','caelum/actors/CaelumFolkloreCharacters.zs','caelum/world/CaelumPortDefender.zs']:
        originals[p]=z.read(p);files[p]=originals[p].decode('utf-8').replace('\r\n','\n')
setup="""        CA870ActorProbe ca870Probe=null;int ca870Family=0;double ca870Start=0;
        if(level.time>=3599 && level.time<4299 && (level.time-3599)%17==0)
        {
            ca870Probe=CA870ActorProbe(StaticEventHandler.Find('CA870ActorProbe'));
            if(ca870Probe!=null)
            {
                ca870Family=self is 'CaelumMandinga'?0:self is 'CaelumPortDefender'?1:2;
                ca870Start=MSTimeF();
            }
        }
"""
def replace(path,old,new):
    assert files[path].count(old)==1,(path,old[:100]);files[path]=files[path].replace(old,new,1);edits.append((path,old,new))
path='caelum/actors/CaelumCombatActor.zs';source=files[path]
start=source.index('    override void Tick()');end=source.index('\n    States',start);old=source[start:end]
assert old.rstrip().endswith('    }')
body=old.replace('    override void Tick()\n    {','    void CA870BodyTick(CA870ActorProbe ca870Probe,int ca870Family)\n    {\n        double ca870Part=ca870Probe!=null?MSTimeF():0;',1)
def mark(index):return f'        if(ca870Probe!=null){{ca870Probe.Record(ca870Family*7+{index},ca870Part);ca870Part=MSTimeF();}}\n'
for anchor,index in [('        CaelumCompanionMotion.Tick(self);\n',0),('        CaelumThermalRuntime.NPCStep(self);\n\n',3),('        UpdateImpactContactLatch();\n',4)]:
    assert body.count(anchor)==1;body=body.replace(anchor,anchor+mark(index),1)
anchor='        Super.Tick();\n        if(held';assert body.count(anchor)==1
body=body.replace(anchor,mark(1)+'        Super.Tick();\n'+mark(2)+'        if(held',1)
last=body.rfind('    }');body=body[:last]+mark(5)+body[last:]
wrapper='    override void Tick()\n    {\n'+setup+'''        CA870BodyTick(ca870Probe,ca870Family);
        if(ca870Probe!=null)ca870Probe.Record(ca870Family*7+6,ca870Start);
    }
'''
replace(path,old,wrapper+body)
for path,class_name,following,metric in [
    ('caelum/actors/CaelumFolkloreCharacters.zs','CaelumMandinga','    CaelumWeaponModel PossessedMachete;',21),
    ('caelum/world/CaelumPortDefender.zs','CaelumPortDefender','    void BeginCrewRoute(',22)]:
    source=files[path];begin=source.index('class '+class_name);start=source.index('    override void Tick()',begin);end=source.index(following,start)
    old=source[start:end];assert old.rstrip().endswith('    }')
    body=old.replace('    override void Tick()','    void CA870OuterBodyTick()',1)
    wrapper='    override void Tick()\n    {\n'+setup+f'''        CA870OuterBodyTick();
        if(ca870Probe!=null)ca870Probe.Record({metric},ca870Start);
    }}
'''
    replace(path,old,wrapper+body)
restored=dict(files)
for path,old,new in reversed(edits):assert restored[path].count(new)==1;restored[path]=restored[path].replace(new,old,1)
for path,s in restored.items():assert s.replace('\n','\r\n' if b'\r\n' in originals[path] else '\n').encode()==originals[path]
handler='''
class CA870ActorProbe : StaticEventHandler
{
    const METRICS=23;const WINDOW=700;
    Array<double> Total,Maximum;Array<int> Calls;
    bool Ready,Printed;
    override void WorldLoaded(WorldEvent e)
    {Total.Resize(METRICS*WINDOW);Maximum.Resize(METRICS*WINDOW);Calls.Resize(METRICS*WINDOW);Ready=true;}
    void Record(int metric,double start)
    {double elapsed=MSTimeF()-start;int cell=metric*WINDOW+level.time-3599;Total[cell]+=elapsed;Maximum[cell]=Max(Maximum[cell],elapsed);Calls[cell]++;}
    override void WorldTick()
    {
        if(!Ready || Printed || level.time!=4350)return;Printed=true;
        for(int tic=0;tic<WINDOW;tic++)for(int metric=0;metric<METRICS;metric++)
        {int cell=metric*WINDOW+tic;if(Calls[cell]>0)Console.Printf("CA870 STAGE tic=%d metric=%d total=%.6f maximum=%.6f calls=%d",tic+3599,metric,Total[cell],Maximum[cell],Calls[cell]);}
        Console.Printf("CA870 STAGES_COMPLETE");
    }
}
'''
files['caelum/actors/CaelumCombatActor.zs']+=handler
files['MAPINFO']='gameinfo { AddEventHandlers="CA870ActorProbe" }\n'
with zipfile.ZipFile(out/'stages.pk3','x') as z:
    for path,source in sorted(files.items()):
        data=source.replace('\n','\r\n' if b'\r\n' in originals.get(path,b'') else '\n').encode()
        z.writestr(zipfile.ZipInfo(path,(2026,11,21,0,0,0)),data)
        p=out/'source'/path;p.parent.mkdir(parents=True,exist_ok=True);p.write_bytes(data)
names=['services','motion-setup','native-state-physics','thermal-physics','potions-elemental-impacts','statistics-resources','common-tick-total']
metrics=[dict(id=family*7+i,family=name,stage=stage) for family,name in enumerate(['Mandinga','PortDefender','other']) for i,stage in enumerate(names)]+[dict(id=21,family='Mandinga',stage='outer-tick-total'),dict(id=22,family='PortDefender',stage='outer-tick-total')]
sha=lambda b:hashlib.sha256(b).hexdigest()
manifest=dict(issue=870,runtime_sha256=sha(runtime.read_bytes()),overlay_sha256=sha((out/'stages.pk3').read_bytes()),originals_restored_exactly={p:sha(b) for p,b in originals.items()},metrics=metrics,period=17,qualification='Private instrumented actor wrappers and stage timestamps. Seven common stages are split by actor family; common/outer totals include nested stages and instrumentation. Do not sum those totals with their children or treat them as uninstrumented CPU budgets. Early-return paths are covered by total wrappers but may omit later stage records. No production statements, individual rules, actor fields or saved schema are removed or changed.')
(out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf-8',newline='\n')
print(json.dumps(dict(output=str(out),metrics=len(metrics),overlay_sha256=manifest['overlay_sha256'])))
