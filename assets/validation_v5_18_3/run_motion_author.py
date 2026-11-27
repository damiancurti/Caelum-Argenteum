"""Interactive rest/meal review using the already verified #460 fixture owners."""
from pathlib import Path
import argparse,importlib.util,json,subprocess,zipfile

ROOT=Path(__file__).resolve().parents[2]
ENGINE=Path('C:/Program Files (x86)/GZDoom/gzdoom.exe')
IWAD=Path('C:/Program Files (x86)/Steam/steamapps/common/ultimate doom/base/doom2/DOOM2.WAD')

def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--runtime',type=Path,required=True);p.add_argument('--output',type=Path,required=True)
    p.add_argument('--interactive',action='store_true');a=p.parse_args()
    out=a.output.resolve();out.relative_to(ROOT/'build');out.mkdir(parents=True,exist_ok=False)
    spec=importlib.util.spec_from_file_location('rest_room',ROOT/'assets/validation_5421/prepare.py')
    room=importlib.util.module_from_spec(spec);spec.loader.exec_module(room)
    manual='''
// La revisión manual rechaza comer fuera del descanso sin alterar el consumo.
class CA469MotionAuthor : CA460Probe
{
    // El observador automático heredado cierra menús al reiniciarse tras cargar.
    // Esta escena manual siempre conserva los menús nativos del autor.
    override void UiTick() {}
    override void WorldLoaded(WorldEvent e)
    {
        Manual=true;
        if(!e.IsSaveGame)return;
        Resolve();
        Camera=CA283Camera(players[0].camera);
        // Consulta tipada, una vez al restaurar esta sala con una sola cámara.
        if(Camera==null)
        {let cameras=ThinkerIterator.Create('CA283Camera');Camera=CA283Camera(cameras.Next());}
        Check(User!=null && Camera!=null,"restored manual reviewer owns native camera");
        if(Camera!=null){ManualCamera=Camera.ReviewSlot;players[0].camera=Camera;}
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name=='ca460_meal')
        {
            let user=CaelumPlayer(players[0].mo);
            if(user==null || !CaelumRestState.IsActive(user))
            {Console.Printf("Sit or lie down first (F1-F3).");return;}
        }
        Super.NetworkProcess(e);
    }
}
'''
    files={'ZSCRIPT':b'version "4.14.2"\n#include "equipment.zs"\n#include "previous.zs"\n#include "probe.zs"\n#include "manual.zs"\n',
        'equipment.zs':(ROOT/'assets/validation_541/session.zs').read_bytes(),
        'previous.zs':(ROOT/'assets/validation_5423/probe.zs').read_bytes(),
        'probe.zs':(ROOT/'assets/validation_v5_17_124/rest_motion_probe.zs').read_bytes(),
        'manual.zs':manual.encode('utf8'),'maps/MAP99.wad':room.wad(),
        'MAPINFO':b'gameinfo { PlayerClasses="CA283MotionPlayer" AddEventHandlers="CA469MotionAuthor" }\nmap MAP99 "Rest and meals author review" { sky1="CABASKY",0 }\n'}
    fixture=out/'motion.pk3'
    with zipfile.ZipFile(fixture,'x') as z:
        for name,blob in sorted(files.items()):z.writestr(zipfile.ZipInfo(name,(2000,1,1,0,0,0)),blob)
    ini=out/'session.ini';ini.write_text('[GlobalSettings]\nvid_fullscreen=false\nvid_activeinbackground=true\ni_pauseinbackground=false\ni_soundinbackground=true\nsnd_mastervolume=0.05\nvid_maxfps=60\n',encoding='utf8')
    setup='wait 100; netevent ca460_setup; netevent c283_manual; wait 10; '
    actions=['ca460_begin 0 0','ca460_begin 1 0','ca460_begin 1 1','ca460_cancel','ca460_meal 0','ca460_meal 1','c283_orbit']
    setup+='; '.join(f'bind F{i} "netevent {event}"' for i,event in enumerate(actions,1))+'; bind F8 "toggle ca_wardrobe_candidate";\n'
    cfg=out/'start.cfg';cfg.write_text(setup,encoding='utf8')
    command=[str(ENGINE),'-noautoload','-iwad',str(IWAD),'-file',str(a.runtime.resolve(strict=True)),str(fixture),
        '-config',str(ini),'-savedir',str(out),'-window','-width','1280','-height','720','+logfile',str(out/'engine.log'),'+map','MAP99','+exec',str(cfg)]
    print('F1 silla / F2 cama / F3 suelo / F4 levantarse / F5 comer / F6 beber / F7 cámara / F8 cuerpo base-candidato. Primero siéntate o acuéstate; usa Escape para guardar.',flush=True)
    if a.interactive:raise SystemExit(subprocess.call(command,cwd=out))
    (out/'prepared.json').write_text(json.dumps(dict(command=command,cwd=str(out)),indent=2)+'\n')

if __name__=='__main__':main()
