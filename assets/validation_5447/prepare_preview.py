"""Create a private author preview with explicit controls and an open terminal."""
from pathlib import Path
import argparse
import hashlib
import importlib.util
import json
import shutil

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).parent
spec = importlib.util.spec_from_file_location('focus', HERE/'prepare.py')
focus = importlib.util.module_from_spec(spec)
spec.loader.exec_module(focus)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--directory', default='issue361-preview01')
    args = parser.parse_args()
    assert args.directory.startswith('issue361-preview') and Path(args.directory).name == args.directory
    out = ROOT/'build'/args.directory
    out.mkdir(exist_ok=False)
    shutil.copy2(ROOT/'build/caelum_argenteum_dev.pk3', out/'baseline.pk3')
    seed = ROOT/'build/issue354-preview01/auto00.zds'
    shutil.copy2(seed, out/'author.zds')
    shutil.copy2(ROOT/'build/gzdoom.ini', out/'preview.ini')
    compatibility = (ROOT/'assets/validation_5446/trace.zs').read_text(encoding='utf-8').split('class CA334NativeTrace')[0]
    probe = compatibility+'''
class CA361Preview : StaticEventHandler
{
    override void NetworkProcess(ConsoleEvent e)
    {
        let user=CaelumPlayer(players[e.Player].mo);if(user==null)return;
        if(e.Name=="ca361_visit")
        {
            int house=CaelumHouseHubData.HouseForMap(level.MapName);
            Level.ChangeLevel(house>=0?"MAP03":CaelumHouseHubData.MapName(7),
                house>=0?house+1:0,CHANGELEVEL_NOINTERMISSION);
        }
        if(e.Name=="ca361_status")
        {
            int total,full;let port=CaelumPortSiege.Get();
            if(port!=null)
            {
                for(int i=0;i<port.Attackers.Size();i++)
                {
                    let entry=port.Attackers[i];let body=entry.Body;
                    if(body==null || body.health<=0 || entry.Exited)continue;
                    total++;if(body.CurrentCombatAdrenaline==body.MaximumCombatAdrenaline)full++;
                }
                for(int i=0;i<port.Defenders.Size();i++)
                {
                    let body=port.Defenders[i];if(body==null || body.health<=0 || body.Port!=port)continue;
                    total++;if(body.CurrentCombatAdrenaline==body.MaximumCombatAdrenaline)full++;
                }
            }
            Console.Printf("ADRENALINA jugador %.3f / %.3f | NPC al maximo %d/%d | %s",
                user.CurrentAdrenaline,user.DerivedStats.MaximumAdrenaline,full,total,level.MapName);
        }
    }
}
'''
    fixture = {'ZSCRIPT': b'version "4.14"\n#include "preview.zs"\n',
               'preview.zs': probe.encode('utf-8'),
               'MAPINFO': b'GameInfo { AddEventHandlers="CA353Performance", "CA361Preview" }\n'}
    fixture_hash = focus.prior.prior.base.package(out/'city.pk3', fixture)
    (out/'preview.cfg').write_text('bind F8 "netevent ca361_visit"\nbind F9 "netevent ca361_status"\nbind F10 "load author.zds"\nsnd_mastervolume 0.05\ni_pauseinbackground false\nvid_activeinbackground true\ni_soundinbackground true\nuse_mouse true\n', encoding='utf-8')
    launcher = r'''$ErrorActionPreference='Stop'
Set-Location -LiteralPath $PSScriptRoot
$Host.UI.RawUI.WindowTitle='Caelum #361 - Solo NPC (actualizado)'
if(Get-CimInstance Win32_Process -Filter "Name='gzdoom.exe'"){throw 'Ya hay una ventana de GZDoom abierta.'}
Write-Host 'PRUEBA ACTUALIZADA #361 - ADRENALINA SOLO PARA NPC Y MONSTRUOS' -ForegroundColor Cyan
Write-Host 'Estas en tu asedio real de MAP03, en una copia privada del guardado.'
Write-Host 'F9: muestra tu reserva normal y cuantos NPC del asedio estan al maximo.'
Write-Host 'F8: entra a una casa / vuelve a la ciudad para comprobar la regla.'
Write-Host 'Tu adrenalina NO se fuerza al maximo, ni en ciudad ni en casas.'
Write-Host 'Prueba un sello equipado: debe consumir y poder agotar su reserva normal.'
Write-Host 'Volver a la ciudad NO repone tu adrenalina. Solo NPC y monstruos tienen el beneficio.'
Write-Host 'F10: recarga el punto inicial si el combate avanzo o moriste.'
Write-Host 'No se miden FPS. El resto de las pruebas antiguas ya esta aprobado.'
Write-Host 'Al terminar, cierra GZDoom y confirma solamente este nuevo comportamiento.'
$engine361='C:\Program Files (x86)\GZDoom\gzdoom.exe'
$iwad361='C:\Program Files (x86)\Steam\steamapps\common\ultimate doom\base\doom2\DOOM2.WAD'
$arguments361=@('-noautoload','-iwad',('"'+$iwad361+'"'),'-file','baseline.pk3','city.pk3','-config','preview.ini','-savedir',('"'+$PSScriptRoot+'"'),'-window','-width','1280','-height','720','-loadgame','author.zds','+logfile','preview.txt','+exec','preview.cfg','+snd_mastervolume','0.05','+i_pauseinbackground','false','+vid_activeinbackground','true','+i_soundinbackground','true')
$process361=Start-Process -FilePath $engine361 -ArgumentList $arguments361 -WorkingDirectory $PSScriptRoot -WindowStyle Normal -PassThru
[IO.File]::WriteAllText((Join-Path $PSScriptRoot 'preview-pid.txt'),[string]$process361.Id)
$process361.WaitForExit()
Write-Host 'Prueba cerrada. Esta terminal queda disponible.' -ForegroundColor Cyan
'''
    (out/'open_preview.ps1').write_text(launcher, encoding='utf-8-sig')
    manifest = dict(issue=361, release='5.4.47',
                    runtime_sha256=hashlib.sha256((out/'baseline.pk3').read_bytes()).hexdigest(),
                    fixture_sha256=fixture_hash, seed_sha256=hashlib.sha256(seed.read_bytes()).hexdigest(),
                    controls={'F8': 'private house / city', 'F9': 'adrenaline values', 'F10': 'reload private seed'})
    (out/'manifest.json').write_text(json.dumps(manifest, indent=2)+'\n', encoding='utf-8')
    print(json.dumps(manifest))


if __name__ == '__main__':
    main()
