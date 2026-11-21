"""Measure tic grouping and native full-frame cost using the unchanged campaign."""
from pathlib import Path
import argparse,hashlib,json,re,subprocess,sys
ROOT=Path('C:/GZDooMProjects/CaelumArgenteum/build/v517/work-713')
p=argparse.ArgumentParser(description=__doc__,add_help=False)
p.add_argument('--mode',choices=['grouping','native','native-phases'],required=True)
p.add_argument('--label',required=True)
a,remainder=p.parse_known_args();assert re.fullmatch(r'[a-z0-9_-]+',a.label)
assert 'gzdoom.exe' not in subprocess.check_output(['tasklist','/FI','IMAGENAME eq gzdoom.exe','/FO','CSV','/NH'],text=True,errors='replace').lower()
out=ROOT/f'build/issue873-{a.label}';out.mkdir(exist_ok=False)
adapter=ROOT/'assets/validation_v5_16_2/run_barracas_presentation.py'
adapter_text=adapter.read_text(encoding='utf-8')
end="    exec(compile(source, str(previous), 'exec'), {'__file__': str(previous), '__name__': '__main__'})"
assert adapter_text.count(end)==1
namespace={'__file__':str(adapter),'__name__':'__main__'}
exec(compile(adapter_text.replace(end,''),str(adapter),'exec'),namespace)
source=namespace['source'];previous=namespace['previous']
anchor="    source=(ROOT/'assets/validation_5103/performance.zs').read_text(encoding='utf-8')\n"
assert source.count(anchor)==1
changes=[
    ('    ui bool FrameWindow;','    ui bool FrameWindow;\n    ui Array<int> FrameTics;\n    ui Array<double> FrameStamps;\n    Array<double> TicStamps;'),
    ('        double now=MSTimeF();if(PreviousTic>0)', '        double now=MSTimeF();TicStamps.Push(now);if(PreviousTic>0)'),
    ('            for(int i=0;i<TicMS.Size();i++)Console.Printf("CA510 TIC %.6f",TicMS[i]);', '            for(int i=0;i<TicMS.Size();i++)Console.Printf("CA510 TIC %.6f",TicMS[i]);\n            for(int i=0;i<TicStamps.Size();i++)Console.Printf("CA873 TICK_TIME i=%d ms=%.6f",i,TicStamps[i]);'),
    ('        PreviousFrame=now;FrameWindow=true;', '        FrameTics.Push(level.time);FrameStamps.Push(now);\n        PreviousFrame=now;FrameWindow=true;'),
    ('        Console.Printf("CA510 FRAMES_END count=%d",FrameMS.Size());','        Console.Printf("CA510 FRAMES_END count=%d",FrameMS.Size());\n        for(int i=0;i<FrameTics.Size();i++)Console.Printf("CA873 FRAME_TIME i=%d tic=%d ms=%.6f",i,FrameTics[i],FrameStamps[i]);'),
    ('        if(e.Name!="ca510_frames")return;','        if(e.Name=="ca873_mark"){Console.Printf("CA873 NATIVE_MARK tic=%d ms=%.6f",level.time,MSTimeF());return;}\n        if(e.Name!="ca510_frames")return;')]
inject=anchor
for old,new in changes:
    inject+=f'    assert source.count({old!r})==1\n    source=source.replace({old!r},{new!r},1)\n'
source=source.replace(anchor,inject)
config="            (peer/'start.cfg').write_text(f'wait {duration}; event ca510_frames; screenshot scene.png; wait 3; quit\\n')"
assert source.count(config)==1
if a.mode in ('native','native-phases'):
    events=[(0,'stat think; stat rendertimes; stat VM'),(3605,'echo CA873_THINK_0; profilethinkers -t'),(3610,'bench'),(3745,'echo CA873_THINK_1; profilethinkers -t'),(3855,'bench'),(3885,'echo CA873_THINK_2; profilethinkers -t'),(4025,'echo CA873_THINK_3; profilethinkers -t'),(4100,'bench'),(4165,'echo CA873_THINK_4; profilethinkers -t')]
    if a.mode=='native-phases':
        events=[(0,'stat think; stat rendertimes; stat VM'),(3610,'bench'),(3855,'bench'),(4100,'bench')]
        events += [(3605+i*19,f'echo CA873_THINK_{i}; event ca873_mark; profilethinkers -t') for i in range(35)]
        events.sort()
    prefix='';last=0
    for tic,command in events:
        if tic>last:prefix+=f'wait {tic-last}; '
        prefix+=command+'; ';last=tic
    replacement=f"            (peer/'start.cfg').write_text({prefix!r}+f'wait {{duration-{last}}}; event ca510_frames; screenshot scene.png; wait 3; quit\\n')"
    source=source.replace(config,replacement)
    command="command=[str(engine),'-noautoload','-nomouse'"
    assert source.count(command)==1;source=source.replace(command,"command=[str(engine),'-debugfile','-noautoload','-nomouse'")
source=source.replace("issue=454,",'issue=873,')
(out/'driver.py').write_text(source,encoding='utf-8',newline='\n')
manifest=dict(issue=873,mode=a.mode,adapter_sha256=hashlib.sha256(adapter.read_bytes()).hexdigest(),shared_driver_sha256=hashlib.sha256(previous.read_bytes()).hexdigest(),generated_driver_sha256=hashlib.sha256(source.encode()).hexdigest(),scope='Only private observer arrays and console diagnostics change. Production runtime, camera, census, combatants, schedules and resources are unchanged. Native mode adds one-tic profilethinkers snapshots, later bench CPU snapshots and debugfile IO; this is diagnostic overhead, not uninstrumented throughput.')
(out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf-8',newline='\n')
sys.argv=[str(previous),*remainder]
exec(compile(source,str(previous),'exec'),{'__file__':str(previous),'__name__':'__main__'})
