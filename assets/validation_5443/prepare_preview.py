"""Prepare an interactive city siege, reusing the measured save without input capture."""
from pathlib import Path
import argparse
import hashlib
import importlib.util
import json

ROOT=Path(__file__).resolve().parents[2]
spec=importlib.util.spec_from_file_location('cache_preparation',Path(__file__).with_name('prepare.py'))
base=importlib.util.module_from_spec(spec);spec.loader.exec_module(base)

def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--directory',required=True)
    p.add_argument('--runtime',type=Path,required=True)
    p.add_argument('--seed',type=Path,required=True)
    p.add_argument('--release',default='5.4.43')
    a=p.parse_args();out=ROOT/'build'/a.directory;out.mkdir(exist_ok=False)
    (out/'baseline.pk3').write_bytes(a.runtime.read_bytes())
    (out/'cache-battle.zds').write_bytes(a.seed.read_bytes())
    source='''class CA353Performance : EventHandler
{
    int Age,StartTic;
    bool SeedReady,Started,Finished;
    transient bool PreviewReady;
    CaelumPortSiege Port;
    Array<CaelumCombatActor> Bodies;
    Array<double> Stamps;
    ui double LastFrame;
    ui Array<double> FrameMS,FrameTimes;
    ui Array<int> FrameTics;
    ui bool Flushed;
    override void WorldTick()
    {
        if(PreviewReady)return;
        let user=players[0].mo;if(user==null)return;
        PreviewReady=true;
        // La partida de medicion se abre en una calle real, sin bloquear los controles.
        // Started se guarda: recargar o entrar en una casa no vuelve a colocar al jugador.
        if(level.MapName~=="MAP03" && !Started)
        {
            Port=CaelumPortSiege.Get();
            if(!SeedReady || Port==null || !Port.SiegeStarted)
            {Console.Printf("CA282 FAIL preview did not restore the saved siege");return;}
            Started=true;user.SetOrigin((0,320,0),false);user.FindFloorCeiling();
            user.SetOrigin((0,320,user.FloorZ),false);user.Angle=180;user.Pitch=0;user.Vel=(0,0,0);
            Console.Printf("CA282 DONE passes=1 failures=0");
        }
        Console.Printf("PREVIEW READY map=%s x=%.3f y=%.3f z=%.3f",level.MapName,user.Pos.X,user.Pos.Y,user.Pos.Z);
        Console.Printf("CA353-01: ciudad con asedio activo. Movimiento y raton libres; instrucciones en la terminal.");
    }
}
'''
    fixture=base.prior.base.package(out/'city.pk3',{'ZSCRIPT':b'version "4.14"\n#include "preview.zs"\n',
        'preview.zs':source.encode(),'MAPINFO':b'GameInfo { AddEventHandlers="CA353Performance" }\n'})
    manifest=dict(issue=353,release=a.release,runtime_sha256=hashlib.sha256(a.runtime.read_bytes()).hexdigest(),
        fixture_sha256=fixture,seed_sha256=hashlib.sha256(a.seed.read_bytes()).hexdigest(),
        purpose='Interactive acceptance preview, not a performance measurement. Saved player invulnerability retained.')
    (out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
    (out/'preview.cfg').write_text('wait 35; use_mouse true; vid_vsync false; cl_capfps false; vid_maxfps 0; vid_fps true; con_notifylines 0\n')
    (out/'smoke.cfg').write_text('wait 35; vid_vsync false; vid_maxfps 0; wait 70; screenshot quick-city.png; wait 70; quit\n')
    launcher=f'''$ErrorActionPreference='Stop'
Set-Location -LiteralPath '{ROOT}'
Write-Host 'CA353-01 - PRUEBA DE LA CIUDAD Y SU ASEDIO' -ForegroundColor Cyan
Write-Host 'La ciudad ya tiene el asedio activo: 600 soldados y hasta 1000 mandingas.'
Write-Host '1. Camina varias calles y mira al frente y al suelo. Los FPS aparecen arriba.'
Write-Host '2. Acercate al combate: comprueba movimiento, ataques y cambio de blanco.'
Write-Host '3. Recoge/usa un objeto; entra y sal de una casa; guarda y vuelve a cargar.'
Write-Host '4. Confirma que no desaparecen ni se duplican soldados, objetos o recursos.'
Write-Host 'El jugador de esta prueba es invulnerable. No es una partida de campana.'
Write-Host 'Cuando termines, cierra GZDoom y cuenta el resultado. La terminal queda abierta.'
& '{ROOT / 'assets/validation_5422/run_native.ps1'}' -Directory '{a.directory}' -Label 'author01' -Runtime 'baseline.pk3' -Fixture 'city.pk3' -Script 'preview.cfg' -LoadGame 'cache-battle.zds' -Map MAP03 -Language esp -Interactive
'''
    (out/'open_preview.ps1').write_text(launcher,encoding='utf-8-sig')
    print(json.dumps(manifest))

if __name__=='__main__':main()
