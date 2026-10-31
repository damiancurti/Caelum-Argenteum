"""Open one isolated native arena view for a bounded live visual inspection."""
import argparse, datetime, subprocess, zipfile
from pathlib import Path
from run_arena_probe import ROOT, ENGINE, IWAD

p=argparse.ArgumentParser(description=__doc__)
p.add_argument('--runtime',type=Path,required=True)
p.add_argument('--map',choices=('CARING','CASEWER','CABAIRES'),default='CARING')
p.add_argument('--seconds',type=int,default=120)
p.add_argument('--organizer',action='store_true')
p.add_argument('--language',choices=('en','es'),default='en')
a=p.parse_args();folder=ROOT/'build/issue438'/datetime.datetime.now().strftime('visual-%Y%m%d-%H%M%S');folder.mkdir(parents=True)
(folder/'isolated.ini').write_text('[GlobalSettings]\nvid_preferbackend=1\nvid_vsync=false\nvid_maxfps=60\nvid_activeinbackground=true\ni_pauseinbackground=false\nvid_lowerinbackground=false\ni_soundinbackground=true\nsnd_mastervolume=0.05\nvid_fullscreen=false\nuse_mouse=false\nlanguage='+a.language+'\n')
extra=[]
if a.organizer:
    assert a.map=='CABAIRES'
    package=folder/'visual.pk3'
    with zipfile.ZipFile(package,'w') as z:
        z.writestr('MAPINFO','gameinfo { AddEventHandlers="CA438OrganizerView" }')
        z.writestr('ZSCRIPT','''version "4.14.2"
class CA438OrganizerView : StaticEventHandler
{
    bool Done;
    override void WorldTick()
    {
        if(Done || level.time<105)return;
        let user=CaelumPlayer(players[0].mo);if(!CaelumWorldClockTicker.Ready(user))return;
        let events=CaelumArenaEvents(StaticEventHandler.Find('CaelumArenaEvents'));
        if(events==null || events.Organizer==null)return;
        user.SetOrigin(CaelumArenaData.OrganizerPosition()-(48,0,0),false);user.Angle=0;
        if(user.player.ConversationNPC!=null)user.player.ConversationNPC.bInConversation=false;
        user.player.ConversationNPC=null;user.player.ConversationPC=null;
        bool opened=CaelumArena.Open(user,events.Organizer);
        Console.Printf("CA438 ORGANIZER open=%d class=%s map=%s",opened,events.Organizer.GetClassName(),level.MapName);
        Done=true;
    }
}''')
    extra=[str(package)]
startup=subprocess.STARTUPINFO();startup.dwFlags|=subprocess.STARTF_USESHOWWINDOW;startup.wShowWindow=0
command=[str(ENGINE),'-noautoload','-iwad',str(IWAD),'-file',str(a.runtime.resolve()),*extra,'-config',str(folder/'isolated.ini'),'-savedir',str(folder),'-window','-width','960','-height','640','+logfile',str(folder/'engine.log'),'+map',a.map]
child=subprocess.Popen(command,cwd=folder,startupinfo=startup);print(f'Visual PID {child.pid}: {folder}',flush=True)
try:child.wait(timeout=a.seconds)
except subprocess.TimeoutExpired:child.terminate();child.wait()
