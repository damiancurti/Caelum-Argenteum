"""Create a separate full-combat camera control; never include it in timings."""
from pathlib import Path
import zipfile

ROOT=Path(__file__).resolve().parents[2]
OUT=ROOT/'build/issue128'
with zipfile.ZipFile(OUT/'battle.pk3') as z:members={n:z.read(n) for n in z.namelist()}
members['ZSCRIPT']+=b'\n#include "view.zs"\n'
members['MAPINFO']=b'GameInfo { AddEventHandlers="CA121Profiler", "CA121Observer", "CA116InputProbe", "CA128Battle", "CA128View" }\n'
members['view.zs']=b'''class CA128View : EventHandler
{
    override void WorldTick()
    {
        if(level.time!=35 || players[0].mo==null)return;
        let user=players[0].mo;
        user.bNoGravity=true;user.bInvulnerable=true;
        user.SetOrigin((-16064,-15140,768.5),false);user.Angle=270;user.Pitch=20;
        Console.Printf("CA128 VIEW camera_only=1 npc_relocation=0 attacks_replaced=0");
    }
}
'''
with zipfile.ZipFile(OUT/'view.pk3','w',zipfile.ZIP_STORED) as z:
    for key,data in sorted(members.items()):z.writestr(zipfile.ZipInfo(key,(2000,1,1,0,0,0)),data)
(OUT/'view.cfg').write_text('vid_fps 1; wait 35; closemenu; wait 315; screenshot ca128-battle-early.png; wait 700; screenshot ca128-battle-later.png; wait 70; quit\n')
print('Prepared separate camera control; native NPC placement and combat retained')
