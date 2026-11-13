"""Native exterior-coordinate and rotated-door regression fixture for #454."""
from pathlib import Path
import argparse
import hashlib
import json
import subprocess
import sys
import zipfile

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'assets/generators'))
import generate_barracas_preview as preview


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--runtime', type=Path, required=True)
    args = parser.parse_args()
    out, runtime = args.output.resolve(), args.runtime.resolve()
    out.relative_to(ROOT / 'build')
    data = json.loads((ROOT / 'assets/barracas_redesign/RUNTIME.json').read_text(encoding='utf-8'))
    hubs = json.loads((ROOT / 'assets/map06_port/HOUSE_HUBS.json').read_text(encoding='utf-8'))

    def portals(port, layout, city, interior):
        for row in data['houses']:
            port.prop(hubs['portal_editor'], *row['portal'][:2],
                      angle=row['angle'], args=(row['identity'], 0))

    preview.generate(out, configure=portals)
    source = '''
class CA454ServiceFit : Actor
{
    Default { +NOINTERACTION +NOGRAVITY }
    States { Spawn: TNT1 A -1; Stop; }
}
class CA454ServiceProbe : EventHandler
{
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name!="ca454_services")return;
        int failed=0, portals=0, leaves=0;
        let fit=Actor.Spawn("CA454ServiceFit",(0,0,0),NO_REPLACE);
        fit.A_SetSize(RADIUS,HEIGHT);
        for(int i=0;i<224;i++)
        {
            vector3 p=i<160?CaelumBarracasData.DoorOutside(i):CaelumBarracasData.ShopPosition(i-160);
            fit.SetOrigin(p,false);fit.FindFloorCeiling();FCheckPosition check;
            bool ok=fit.CheckPosition(p.XY,false,check) && check.floorz==0 && check.ceilingz-check.floorz>=fit.Height;
            if(!ok){failed++;Console.Printf("CA454 SERVICES FIT FAIL %d floor=%.1f ceiling=%.1f",i,check.floorz,check.ceilingz);}
        }
        fit.Destroy();
        // Censos tipados acotados a esta prueba, ejecutados una sola vez.
        let it=ThinkerIterator.Create("CaelumHousePortal");CaelumHousePortal door;
        Array<CaelumHouseDoorVisual> visuals;
        let vi=ThinkerIterator.Create("CaelumHouseDoorVisual");CaelumHouseDoorVisual visual;
        while((visual=CaelumHouseDoorVisual(vi.Next()))!=null){visuals.Push(visual);leaves++;}
        while((door=CaelumHousePortal(it.Next()))!=null)
        {
            portals++;int found=0;
            for(uint j=0;j<visuals.Size();j++)
            {
                vector3 delta=visuals[j].Pos-door.Pos;
                if(delta.Length()>CaelumMansionDoorData.HALF_WIDTH+0.01)continue;
                double forward=delta.X*cos(door.Angle)+delta.Y*sin(door.Angle);
                double sideways=-delta.X*sin(door.Angle)+delta.Y*cos(door.Angle);
                bool ok=Abs(forward)<0.01 && Abs(Abs(sideways)-CaelumMansionDoorData.HALF_WIDTH)<0.01
                    && Abs(delta.Z)<0.01 && Abs(cos(visuals[j].Angle-door.Angle))<0.01;
                if(!ok){failed++;Console.Printf("CA454 SERVICES LEAF FAIL house=%d angle=%.1f",door.args[0],door.Angle);}
                found++;
            }
            if(found!=2){failed++;Console.Printf("CA454 SERVICES LEAF COUNT FAIL house=%d count=%d",door.args[0],found);}
        }
        if(portals!=160 || leaves!=320)failed++;
        // El interior privado y su cofre siguen usando las coordenadas anteriores.
        vector3 origin=CaelumCityData.HouseOrigin(69);
        if((CaelumCityData.ChestPosition(69)-origin-(864,832,0)).Length()>0.01 || CaelumBarracasData.IsCurrent())failed++;
        Console.Printf("CA454 SERVICES total=224 portals=%d leaves=%d failures=%d",portals,leaves,failed);
    }
}
'''
    body = json.loads((ROOT / 'assets/map02_maze/LAYOUT.json').read_text(encoding='utf-8'))
    source = source.replace('RADIUS', str(body['largest_player_radius'])).replace('HEIGHT', str(body['largest_supported_height']))
    fixture = out / 'services.pk3'
    with zipfile.ZipFile(fixture, 'w') as archive:
        for name, value in {'ZSCRIPT': 'version "4.14.2"\n' + source,
                            'MAPINFO': 'gameinfo { AddEventHandlers="CA454ServiceProbe" }'}.items():
            archive.writestr(zipfile.ZipInfo(name, (2026, 11, 12, 0, 0, 0)), value)
    (out / 'isolated.ini').write_text('[GlobalSettings]\nvid_fullscreen=false\nvid_preferbackend=1\nvid_activeinbackground=true\ni_pauseinbackground=false\nvid_lowerinbackground=false\ni_soundinbackground=true\nsnd_mastervolume=0.05\nvid_maxfps=60\nlanguage=en\n')
    (out / 'commands.cfg').write_text('wait 140; netevent ca454_services; wait 10; quit\n')
    engine = Path('C:/Program Files (x86)/GZDoom/gzdoom.exe')
    iwad = Path('C:/Program Files (x86)/Steam/steamapps/common/ultimate doom/base/doom2/DOOM2.WAD')
    command = [str(engine), '-noautoload', '-iwad', str(iwad), '-file', str(runtime), str(out / 'preview.pk3'), str(fixture),
               '-config', str(out / 'isolated.ini'), '-savedir', str(out), '-window', '-width', '1280', '-height', '720',
               '+logfile', str(out / 'engine.log'), '+map', 'CABAPRV', '+exec', str(out / 'commands.cfg')]
    startup = subprocess.STARTUPINFO();startup.dwFlags |= subprocess.STARTF_USESHOWWINDOW;startup.wShowWindow = 0
    with (out / 'process.log').open('wb') as log:
        process = subprocess.Popen(command, cwd=out, stdout=log, stderr=log, startupinfo=startup)
        try: code = process.wait(timeout=120)
        except subprocess.TimeoutExpired:
            process.terminate();process.wait(timeout=10);raise
    log = (out / 'engine.log').read_text(errors='replace')
    errors = [line for line in log.splitlines() if any(t in line for t in ('Script error', 'Execution could not continue', 'VM execution aborted', 'Unknown type', 'CA454 SERVICES'))]
    passed = code == 0 and 'CA454 SERVICES total=224 portals=160 leaves=320 failures=0' in log
    report = {'issue': 454, 'scope': 'Isolated native endpoint clearance, map-spawned rotated leaves and private-interior coordinate retention. No ordinary travel/siege/author acceptance.',
              'runtime_sha256': hashlib.sha256(runtime.read_bytes()).hexdigest(), 'exit_code': code, 'passed': passed, 'diagnostics': errors}
    (out / 'native-results.json').write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps(report))
    if not passed: raise SystemExit(1)


if __name__ == '__main__':
    main()
