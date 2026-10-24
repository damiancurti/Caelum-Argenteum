"""Create the private native playback fixture and listening controls."""
from pathlib import Path
import importlib.util
import json
import zipfile

ROOT=Path(__file__).resolve().parents[2]
WORK=ROOT/'build/issue496'


def main():
    tracks=json.loads((ROOT/'assets/source/audio/map_music_496/catalogue.json').read_text(encoding='utf-8'))['tracks']
    cases='\n'.join(f'case {i}: return "{t["music_name"]}";' for i,t in enumerate(tracks))
    script='''class CA496MusicChecks : EventHandler
{
    int Selected, NextTic, Completed, Failures;
    bool Running;
    String Track(int index)
    { switch(index) { CASES } return ""; }
    void StartTrack(int index)
    {
        Selected=(index+19)%19;
        bool ok=S_ChangeMusic(Track(Selected),0,true);
        Console.Printf("CA496 %s music %d %s",ok ? "PASS" : "FAIL",Selected+1,Track(Selected));
        if(!ok)Failures++;
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name=="ca496_all"){Running=true;Completed=0;Failures=0;NextTic=level.maptime;}
        if(e.Name=="ca496_next"){Running=false;StartTrack(Selected+1);}
        if(e.Name=="ca496_previous"){Running=false;StartTrack(Selected-1);}
        if(e.Name=="ca496_start"){Running=false;StartTrack(0);}
        if(e.Name=="ca496_restart"){S_ChangeMusic("");StartTrack(Selected);}
    }
    override void WorldTick()
    {
        if(!Running || level.maptime<NextTic)return;
        if(Completed==19)
        {Running=false;Console.Printf("CA496 RESULT played=%d failures=%d",Completed,Failures);return;}
        StartTrack(Completed);Completed++;NextTic=level.maptime+TICRATE;
    }
}
'''.replace('CASES',cases)
    spec=importlib.util.spec_from_file_location('room',ROOT/'assets/validation_580/prepare.py')
    room=importlib.util.module_from_spec(spec);spec.loader.exec_module(room)
    members={'ZSCRIPT':b'version "4.14"\n#include "checks.zs"\n',
        'checks.zs':script.encode(), 'MAPINFO':b'GameInfo { AddEventHandlers="CA496MusicChecks" }\nmap CAM496 "Map soundtrack listening room" { music="" }\n',
        'maps/CAM496.wad':room.wad(room.room(),'CAM496')}
    WORK.mkdir(parents=True,exist_ok=True)
    with zipfile.ZipFile(WORK/'checks.pk3','w',zipfile.ZIP_STORED) as out:
        for name,data in sorted(members.items()):out.writestr(zipfile.ZipInfo(name,(2000,1,1,0,0,0)),data)
    (WORK/'all.cfg').write_text('wait 35; netevent ca496_all; wait 735; quit\n',encoding='utf-8')
    (WORK/'interactive.cfg').write_text('bind F1 "netevent ca496_next"\nbind F2 "netevent ca496_previous"\nbind F3 "netevent ca496_restart"\nwait 35; netevent ca496_start\n',encoding='utf-8')


if __name__=='__main__':main()
