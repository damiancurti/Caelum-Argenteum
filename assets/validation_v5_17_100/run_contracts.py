"""Run retained stack/vessel contracts, null dispatch parity and saved identities."""
from pathlib import Path
import argparse,hashlib,json,re,shutil,subprocess,time,zipfile
ROOT=Path(__file__).resolve().parents[2]
p=argparse.ArgumentParser(description=__doc__);p.add_argument('--runtime',type=Path,required=True);p.add_argument('--reference-runtime',type=Path,required=True);p.add_argument('--candidate',type=Path);p.add_argument('--load',type=Path);p.add_argument('--output',type=Path,required=True);a=p.parse_args()
out=a.output.resolve();out.relative_to(ROOT/'build');out.mkdir(exist_ok=False)
assert '"gzdoom.exe"' not in subprocess.check_output(['tasklist','/FI','IMAGENAME eq gzdoom.exe','/FO','CSV','/NH']).decode(errors='replace').lower()
with zipfile.ZipFile(a.reference_runtime) as z:reference=z.read('caelum/survival/CaelumContaminationStack.zs').decode('utf-8').replace('\r\n','\n')
start=reference.index('    static bool Eligible(Inventory item)');end=reference.index('    static CaelumContaminationState Record(',start)
reference='class CA844StackReference : Object play\n{\n'+reference[start:end].replace('Generic(item)','CaelumContaminationStack.Generic(item)')+'}\n'
source=reference+'''
class MAP01ullChecks : EventHandler
{
    int Revision;
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name!="ca844_null")return;
        int checks=0,errors=0;bool good=!CA844StackReference.Eligible(null) && !CaelumContaminationStack.Eligible(null);
        checks++;if(!good)errors++;
        let user=CaelumPlayer(players[e.Player].mo);
        for(Inventory item=user.Inv;item!=null;item=item.Inv)
        {checks++;if(CA844StackReference.Eligible(item)!=CaelumContaminationStack.Eligible(item))errors++;}
        checks++;if(Revision!=0 && Revision!=1)errors++;Revision=1;
        Console.Printf("CA844 NULL_CHECKS checks=%d errors=%d",checks,errors);
    }
}
'''
retained={name:(ROOT/path).read_bytes() for name,path in [('stacks.zs','assets/validation_5847/checks.zs'),('vessels.zs','assets/validation_5848/checks.zs')]}
files=dict(retained);files['checks.zs']=source.encode();files['ZSCRIPT']=b'version "4.14.2"\n#include "stacks.zs"\n#include "vessels.zs"\n#include "checks.zs"\n'
old=b'CaelumContaminationStack.Record(proof.Item).StackRevision==1'
assert files['stacks.zs'].count(old)==1
files['stacks.zs']=files['stacks.zs'].replace(old,b'CaelumContaminationStack.Record(proof.Item).StackRevision==CaelumStackSurfaceData.REVISION')
files['MAPINFO']=b'gameinfo { AddEventHandlers="CA502StackChecks","CA502VesselChecks","MAP01ullChecks" }\nmap MAP01 "Contamination dispatch checks" {}\n'
files['maps/MAP01.wad']=(ROOT/'assets/validation_5826/away.wad').read_bytes()
checks=out/'checks.pk3'
with zipfile.ZipFile(checks,'x') as z:
    for name,data in sorted(files.items()):z.writestr(zipfile.ZipInfo(name,(2026,11,19,0,0,0)),data)
for name,data in files.items():
    if name.endswith('.zs'):(out/name).write_bytes(data)
ini='[GlobalSettings]\nvid_preferbackend=1\nvid_fullscreen=false\nvid_activeinbackground=true\ni_pauseinbackground=false\nvid_lowerinbackground=false\nsnd_mastervolume=0.05\ni_soundinbackground=true\nvid_maxfps=60\nvid_vsync=false\nvid_defwidth=1280\nvid_defheight=720\nwin_w=1296\nwin_h=759\ncon_notifytime=0\nuse_mouse=false\nlanguage=enu\n'
(out/'session.ini').write_text(ini,encoding='utf-8')
events=['ca502s_resume','ca502v_resume'] if a.load else ['ca502s_'+s for s in ('core','native','exposure','contact','storage','catalogue','npc')]+['ca502v_'+s for s in ('catalogue','storage','immersion','camp','packed','contact','seed')]+['ca502s_seed']
events+=['ca844_null']
(out/'commands.cfg').write_text('wait 105; '+'; wait 1; '.join('netevent '+s for s in events)+'; wait 5; save contamination.zds; wait 5; quit\n',encoding='utf-8')
engine=Path('C:/Program Files (x86)/GZDoom/gzdoom.exe');iwad=Path('C:/Program Files (x86)/Steam/steamapps/common/ultimate doom/base/doom2/DOOM2.WAD')
packages=[a.runtime.resolve()]+([a.candidate.resolve()] if a.candidate else [])+[checks]
launch=['+map','MAP01']
if a.load:shutil.copyfile(a.load,out/'input.zds');launch=['-loadgame','input.zds']
command=[str(engine),'-noautoload','-nomouse','-iwad',str(iwad),'-file',*map(str,packages),'-config',str(out/'session.ini'),'-savedir',str(out),'-window','-width','1280','-height','720','+logfile',str(out/'engine.log'),*launch,'+exec',str(out/'commands.cfg')]
startup=subprocess.STARTUPINFO();startup.dwFlags|=subprocess.STARTF_USESHOWWINDOW;startup.wShowWindow=0
markers=('Script error','VM execution aborted','Execution could not continue','DIED WITH FATAL ERROR')
with (out/'process.log').open('wb') as log:
    proc=subprocess.Popen(command,cwd=out,stdout=log,stderr=log,startupinfo=startup);deadline=time.monotonic()+120
    while proc.poll() is None:
        f=out/'engine.log';sample=f.read_text(encoding='utf-8',errors='replace') if f.exists() else ''
        if any(s in sample for s in markers) or time.monotonic()>deadline:proc.terminate();break
        time.sleep(.25)
    code=proc.wait(timeout=15)
log=(out/'engine.log').read_text(encoding='utf-8',errors='replace')
results=[tuple(map(int,m)) for m in re.findall(r'CA502[SV] RESULT passed=(\d+) failed=(\d+)',log)]
null=re.search(r'CA844 NULL_CHECKS checks=(\d+) errors=(\d+)',log)
errors=[s for s in markers if s in log]+[line for line in log.splitlines() if re.match(r'CA502[SV] FAIL ',line)]
passed=code==0 and not errors and len(results)==len(events)-1 and all(f==0 for n,f in results) and null is not None and int(null[2])==0 and (out/'contamination.zds').is_file()
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
report=dict(issue=844,passed=passed,exit_code=code,command=command,errors=errors,events=events,results=results,null_result=list(null.groups()) if null else None,checks=sum(n for n,f in results)+(int(null[1]) if null else 0),sha256={str(p):sha(p) for p in packages},retained_sources={name:hashlib.sha256(data).hexdigest() for name,data in retained.items()},reference_runtime_sha256=sha(a.reference_runtime),loaded_save_sha256=sha(a.load) if a.load else None,saved_sha256=sha(out/'contamination.zds') if (out/'contamination.zds').exists() else None)
(out/'RESULTS.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8');print(json.dumps({k:report[k] for k in ('passed','checks','errors','null_result')}));raise SystemExit(not passed)
