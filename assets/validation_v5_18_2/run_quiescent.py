"""Copy a native anchor, cancel its conversation through Escape, then save.

Never edits native save objects or the original file. The static observer is
not serialized; the next production transfer runs without this fixture.
"""
from pathlib import Path
import argparse,hashlib,json,subprocess,sys,zipfile

ROOT=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(ROOT))
from caelum_sessions import resource_arguments

PROBE='''version "4.14.2"
class CA468Quiescent : StaticEventHandler
{
    int Age;
    bool Active;
    override void WorldTick()
    {
        let user=CaelumPlayer(players[0].mo);
        if(!CaelumWorldClockTicker.Ready(user))return;
        Active=user.HasActiveConversation();Age++;
        if(Age==70)Console.Printf("CA468ANCHOR %s conversation closed",Active?"FAIL":"PASS");
    }
    override void UiTick()
    {
        if(Active && consoleplayer==0)ConversationMenu.SendConversationReply(-1,0);
    }
}
'''

def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--runtime',type=Path,required=True)
    p.add_argument('--anchor',type=Path,required=True)
    p.add_argument('--output',type=Path,required=True)
    a=p.parse_args();runtime=a.runtime.resolve(strict=True);anchor=a.anchor.resolve(strict=True)
    out=a.output.resolve();out.mkdir(parents=True,exist_ok=False)
    original=anchor.read_bytes();(out/'input.zds').write_bytes(original)
    overlay=out/'observer.pk3'
    with zipfile.ZipFile(overlay,'x') as z:
        z.writestr('ZSCRIPT',PROBE)
        z.writestr('MAPINFO','gameinfo { AddEventHandlers="CA468Quiescent" }\n')
    (out/'session.ini').write_text('[GlobalSettings]\nvid_fullscreen=false\nvid_activeinbackground=true\ni_pauseinbackground=false\ni_soundinbackground=true\nsnd_mastervolume=0.05\nvid_maxfps=60\n')
    (out/'start.cfg').write_text('wait 105; save transfer_anchor; wait 35; quit\n')
    cmd=['C:/Program Files (x86)/GZDoom/gzdoom.exe','-noautoload','-nomouse',
         *resource_arguments(runtime,[runtime,overlay]),'-config',str(out/'session.ini'),
         '-savedir',str(out),'-loadgame','input.zds','+logfile',str(out/'engine.log'),'+exec',str(out/'start.cfg')]
    (out/'command.json').write_text(json.dumps(cmd,indent=2)+'\n')
    startup=subprocess.STARTUPINFO();startup.dwFlags|=subprocess.STARTF_USESHOWWINDOW;startup.wShowWindow=4
    with (out/'process.log').open('xb') as log:
        result=subprocess.run(cmd,cwd=out,startupinfo=startup,stdout=log,stderr=log,timeout=90)
    text=(out/'engine.log').read_text(errors='replace');target=out/'transfer_anchor.zds'
    passed=result.returncode==0 and 'CA468ANCHOR PASS' in text and 'CA468ANCHOR FAIL' not in text and target.exists()
    passed=passed and not any(v in text for v in ['Script error','Execution could not continue','VM execution aborted'])
    assert anchor.read_bytes()==original
    report=dict(issue=468,passed=passed,source=str(anchor),source_sha256=hashlib.sha256(original).hexdigest(),
                target=str(target),exit=result.returncode,author_acceptance=False)
    (out/'results.json').write_text(json.dumps(report,indent=2)+'\n');print(json.dumps(report))
    raise SystemExit(not passed)

if __name__=='__main__':main()
