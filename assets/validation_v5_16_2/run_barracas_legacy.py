"""Create old-city saves and test exact-geometry continuation with current code.

Native changemap exercises stored hub persistence; it does not represent ordinary
door use, existing author saves, siege performance or author acceptance.
"""
from pathlib import Path
import argparse
import hashlib
import json
import shutil
import subprocess
import time
import zipfile

ROOT = Path(__file__).resolve().parents[2]
ENGINE = Path('C:/Program Files (x86)/GZDoom/gzdoom.exe')
IWAD = Path('C:/Program Files (x86)/Steam/steamapps/common/ultimate doom/base/doom2/DOOM2.WAD')
FATAL = ('Script error', 'Execution could not continue', 'VM execution aborted', 'DIED WITH FATAL ERROR', 'CA454 LEGACY FAIL', 'This savegame needs these files')
SOURCE = '''
class CA454CityStamp : Actor
{
    int Value;
    Default { +NOINTERACTION +NOGRAVITY }
    States { Spawn: TNT1 A -1; Stop; }
}
class CA454CityLegacyProbe : EventHandler
{
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name!="ca454_seed" && e.Name!="ca454_check")return;
        let user=CaelumPlayerAuthority.FromNetworkPlayer(e.Player);
        bool city=level.MapName=="MAP03";
        bool ok=user!=null && user.health>0 && user.CharacterCreationComplete;
        if(user!=null)user.bInvulnerable=true;
        let stamp=CA454CityStamp(ActorIterator.Create(454904,"CA454CityStamp").Next());
        if(e.Name=="ca454_seed" && stamp==null)
        {
            stamp=CA454CityStamp(Actor.Spawn("CA454CityStamp",user.Pos,NO_REPLACE));
            stamp.ChangeTid(454904);stamp.Value=city?3:69;
        }
        ok=ok && stamp!=null && stamp.Value==(city?3:69) && CaelumJusticeGeometry.Get()!=null;
        if(city)
        {
            let port=CaelumPortSiege.Get();
            ok=ok && port!=null && port.args[0]==3 && port.SetupRevision>0 && port.Gates.Size()==8;
            for(int i=0;i<160;i++)
            {
                vector3 origin=CaelumCityData.HouseOrigin(i);
                ok=ok && (CaelumCityData.DoorOutside(i)-origin-(1056,384,0)).Length()<0.01;
                ok=ok && (CaelumCityData.ChestPosition(i)-origin-(864,832,0)).Length()<0.01;
            }
            Console.Printf("CA454 LEGACY CITY checksum=%s justice=%d gates=%d",level.GetChecksum(),CaelumJusticeGeometry.SectorIndex(level.MapName),port!=null?port.Gates.Size():-1);
        }
        else
        {
            int house=CaelumHouseHubData.HouseForMap(level.MapName);
            ok=ok && house==69 && (CaelumCityData.ChestPosition(house)-CaelumCityData.HouseOrigin(house)-(864,832,0)).Length()<0.01;
        }
        Console.Printf("CA454 LEGACY %s map=%s stamp=%d",ok?"PASS":"FAIL",level.MapName,stamp!=null?stamp.Value:-1);
    }
}
'''


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def run(runtime, folder, fixture, commands, save=None):
    folder.mkdir()
    # GZDoom save metadata requires the same package basename across releases.
    package = folder / 'caelum_argenteum_dev.pk3'
    shutil.copyfile(runtime, package)
    (folder / 'isolated.ini').write_text('[GlobalSettings]\nvid_fullscreen=false\nvid_preferbackend=1\nvid_activeinbackground=true\ni_pauseinbackground=false\nvid_lowerinbackground=false\ni_soundinbackground=true\nsnd_mastervolume=0.05\nvid_maxfps=60\nlanguage=en\n', encoding='utf-8')
    (folder / 'commands.cfg').write_text(commands + '; wait 10; quit\n', encoding='utf-8')
    entry = ['+map', 'MAP03']
    if save:
        (folder / 'input.zds').write_bytes(save.read_bytes())
        entry = ['-loadgame', 'input.zds']
    command = [str(ENGINE), '-noautoload', '-iwad', str(IWAD), '-file', str(package), str(fixture),
               '-config', str(folder / 'isolated.ini'), '-savedir', str(folder), '-window', '-width', '960', '-height', '720',
               '+logfile', str(folder / 'engine.log'), *entry, '+exec', str(folder / 'commands.cfg')]
    startup = subprocess.STARTUPINFO();startup.dwFlags |= subprocess.STARTF_USESHOWWINDOW;startup.wShowWindow = 0
    timed_out = False
    with (folder / 'process.log').open('wb') as stream:
        process = subprocess.Popen(command, cwd=folder, stdout=stream, stderr=stream, startupinfo=startup)
        try:
            deadline = time.monotonic() + 120
            while process.poll() is None:
                log = folder / 'engine.log'
                if log.exists() and any(s in log.read_text(errors='replace') for s in FATAL): break
                if time.monotonic() >= deadline: timed_out = True;break
                time.sleep(.25)
        finally:
            if process.poll() is None: process.terminate();process.wait(timeout=10)
    log = (folder / 'engine.log').read_text(errors='replace')
    passed = not timed_out and process.returncode == 0 and not any(s in log for s in FATAL)
    checks = [line for line in log.splitlines() if line.startswith('CA454 LEGACY')]
    passed = passed and sum(' PASS ' in line for line in checks) == commands.count('netevent')
    return {'phase': folder.name, 'passed': passed, 'exit_code': process.returncode, 'timed_out': timed_out, 'checks': checks}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--baseline', type=Path, required=True)
    parser.add_argument('--runtime', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--seed-directory', type=Path, help='Reuse already verified old_seed saves from a preceding run directory')
    args = parser.parse_args()
    baseline, runtime, out = args.baseline.resolve(), args.runtime.resolve(), args.output.resolve()
    out.relative_to(ROOT / 'build');out.mkdir(exist_ok=False)
    fixture = out / 'city-legacy.pk3'
    with zipfile.ZipFile(fixture, 'w') as archive:
        for name, content in {'ZSCRIPT': 'version "4.14.2"\n' + SOURCE,
                              'MAPINFO': 'gameinfo { AddEventHandlers="CA454CityLegacyProbe" }'}.items():
            archive.writestr(zipfile.ZipInfo(name, (2026, 11, 12, 0, 0, 0)), content)
    report = {'issue': 454, 'scope': __doc__.strip(), 'baseline_sha256': digest(baseline), 'runtime_sha256': digest(runtime),
              'engine_sha256': digest(ENGINE), 'fixture_sha256': digest(fixture), 'runs': []}
    phases = [('old_seed', baseline, None, 'wait 140; netevent ca454_seed; wait 5; save active; wait 10; changemap CAH069; wait 140; netevent ca454_seed; wait 5; save hub'),
              ('active_continue', runtime, out / 'old_seed/active.zds', 'wait 140; netevent ca454_check; wait 5; save continued; wait 10; changemap CAH069; wait 140; netevent ca454_seed; wait 5; changemap MAP03; wait 140; netevent ca454_check'),
              ('hub_continue', runtime, out / 'old_seed/hub.zds', 'wait 140; netevent ca454_check; wait 5; changemap MAP03; wait 140; netevent ca454_check; wait 5; save continued')]
    if args.seed_directory:
        seed = args.seed_directory.resolve()
        previous = json.loads((seed / 'results.json').read_text(encoding='utf-8'))
        assert previous['baseline_sha256'] == report['baseline_sha256'] and previous['fixture_sha256'] == report['fixture_sha256']
        assert previous['runs'][0]['phase'] == 'old_seed' and previous['runs'][0]['passed']
        report['seed_directory'] = str(seed)
        phases = [(name, package, seed / 'old_seed' / save.name, commands) for name, package, save, commands in phases[1:]]
    for phase, package, save, commands in phases:
        print('Native city continuation: ' + phase, flush=True)
        result = run(package, out / phase, fixture, commands, save)
        report['runs'].append(result)
        (out / 'results.json').write_text(json.dumps(report, indent=2) + '\n', encoding='utf-8')
        print(json.dumps(result), flush=True)
        if not result['passed']: raise SystemExit(1)


if __name__ == '__main__':
    main()
