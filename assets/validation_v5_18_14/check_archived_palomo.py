"""Load an already-dead Palomo from an actual earlier game and verify its displayed resting frame."""
import argparse
import io
from PIL import Image
import os
from pathlib import Path
import subprocess
import sys
import zipfile

HERE=Path(__file__).resolve().parent
sys.path.insert(0,str(HERE.parent/"validation_v5_18_13"))
from check_slam import stage_wad

CODE='''version "4.14.2"
class ArchiveVisitor : DoomPlayer {override void GiveDefaultInventory() {}}
class ArchivedPalomoTest : StaticEventHandler {
    override void NetworkProcess(ConsoleEvent e){
        if(e.Name=="arch_spawn"){
            let p=CaelumPalomo(Actor.Spawn('CaelumPalomo',(0,0,0),NO_REPLACE));
            p.ChangeTid(921);
        }
        if(e.Name=="arch_kill"){
            let p=CaelumPalomo(ActorIterator.Create(921).Next());p.health=0;p.Die(null,null,0,'None');
        }
        if(e.Name=="arch_probe"){
            let p=CaelumPalomo(ActorIterator.Create(921).Next());
            if(p==null)return;
            let rest=p.FindState("RestLying");
            Console.Printf("ARCHIVED dead=%d held=%d curled=%d",p.health<=0,p.tics<0,p.Sprite==rest.Sprite && p.Frame==rest.Frame);
        }
    }
}'''

def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument("--old",type=Path,required=True);p.add_argument("--game",type=Path,required=True)
    p.add_argument("--output",type=Path,required=True)
    args=p.parse_args()
    out=args.output.resolve();out.mkdir(parents=True,exist_ok=True)
    qa=out/"archive.pk3"
    with zipfile.ZipFile(qa,"w") as z:
        flat=io.BytesIO();Image.new("RGB",(32,32),(100,100,100)).save(flat,"PNG")
        for stem in ("FLAPISO","FLATECH","FLAPARED"):z.writestr("textures/"+stem+".png",flat.getvalue())
        z.writestr("ZSCRIPT",CODE);z.writestr("maps/ARCHIVE.wad",stage_wad())
        z.writestr("MAPINFO",'gameinfo { PlayerClasses="ArchiveVisitor" EventHandlers="ArchivedPalomoTest" } map ARCHIVE "Archive" {}')
    for old,game in ((True,args.old),(False,args.game)):
        name="before" if old else "after"
        cfg=out/(name+".cfg")
        actions="netevent arch_spawn; wait 10; netevent arch_kill; wait 82; netevent arch_probe; wait 4; save palomo_old; wait 30" if old else "netevent arch_probe; wait 6"
        cfg.write_bytes(("snd_mastervolume 0\ni_pauseinbackground false\nvid_activeinbackground true\nwait 100; "+actions+"; quit\n").encode())
        log=out/(name+".log")
        opts=["+map","ARCHIVE"] if old else ["-loadgame","palomo_old.zds"]
        with (out/(name+".stdout")).open("wb") as f:
            subprocess.run([os.environ.get("GZDOOM_EXE",r"C:\Program Files (x86)\GZDoom\gzdoom.exe"),"-nosound","-noautoload","-iwad",str(game.resolve()),"-file",str(qa),"-config",str(out/"engine.ini"),"-savedir",str(out),"-window","+logfile",str(log),*opts,"+exec",str(cfg)],cwd=out,stdout=f,stderr=f,timeout=70,check=True)
        assert f"ARCHIVED dead=1 held=1 curled={int(not old)}" in log.read_text("utf8",errors="replace"),name
if __name__=="__main__":main()
