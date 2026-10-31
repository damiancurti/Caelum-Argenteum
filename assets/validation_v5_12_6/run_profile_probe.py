"""Two native processes inspect an isolated personal-graph transfer (#434)."""
from pathlib import Path
import argparse
import datetime
import importlib.util
import json
import subprocess
import sys
import time
import zipfile

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT))
from caelum_profile_graph import NativeSchema, PersonalGraph, native_archive


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--runtime', type=Path, required=True)
    parser.add_argument('--source', type=Path)
    parser.add_argument('--reload', type=Path, help='Reload a previously imported native checkpoint without importing it again')
    parser.add_argument('--port', type=int, default=30434)
    args = parser.parse_args()
    spec = importlib.util.spec_from_file_location('card_fixture', ROOT/'assets/validation_v5_12_5/run_card_probe.py')
    fixture = importlib.util.module_from_spec(spec); spec.loader.exec_module(fixture)
    runtime = args.runtime.resolve(strict=True)
    out = ROOT/'build/issue434'/datetime.datetime.now().strftime('native-%Y%m%d-%H%M%S-%f')
    out.mkdir(parents=True)
    # Reuse the accepted disposable two-start UDMF geometry, not its card probe.
    geometry = out/'geometry.pk3'; fixture.fixture(geometry, 2)
    with zipfile.ZipFile(geometry) as old, zipfile.ZipFile(out/'checks.pk3','w') as archive:
        archive.writestr('maps/MAP03.wad', old.read('maps/MAP03.wad'))
        archive.writestr('MAPINFO', 'gameinfo { AddEventHandlers="CA434ProfileProbe" }')
        archive.writestr('ZSCRIPT', 'version "4.14.2"\n#include "probe.zs"\n')
        archive.writestr('probe.zs', (Path(__file__).parent/'profile_probe.zs').read_bytes())
    if args.source:
        source = args.source.resolve(strict=True)
        members, info, level = native_archive(source)
        schema = NativeSchema(fixture.ENGINE.parent/'gzdoom.pk3', runtime)
        adapter = PersonalGraph(schema); graph = adapter.capture(level, 0)
        # Only this disposable fixture is made an empty destination. Production
        # install refuses to overwrite a committed unrelated character.
        target_record = next(o for o in level['objects'] if o['classtype']=='CaelumPersistentCharacterState'
                             and o['class:Inventory']['Owner']==level['players'][1]['mo'])
        target_record['class:CaelumPersistentCharacterState']['ProfileCommitted']=False
        installed = adapter.install(level, graph, 1, 'profile-native-fixture', 0)
        members[info['Current Map'].lower()+'.map.json']=json.dumps(installed,separators=(',',':')).encode()
        with zipfile.ZipFile(out/'imported.zds','w',compression=zipfile.ZIP_DEFLATED) as archive:
            for name,data in members.items(): archive.writestr(name,data)
        (out/'graph.json').write_text(json.dumps(graph,indent=2),encoding='utf-8')
    if args.reload:
        with (out/'imported.zds').open('xb') as target:target.write(args.reload.resolve(strict=True).read_bytes())
    startup=subprocess.STARTUPINFO();startup.dwFlags|=subprocess.STARTF_USESHOWWINDOW;startup.wShowWindow=0
    processes=[];streams=[];commands=[]
    try:
        for index in range(2):
            peer=out/f'peer{index}';peer.mkdir()
            (peer/'test.cfg').write_text(f'wait {420+(2-index)*35}; quit\n')
            (peer/'isolated.ini').write_text('[GlobalSettings]\nvid_preferbackend=1\nvid_maxfps=60\nvid_vsync=false\nvid_activeinbackground=true\ni_pauseinbackground=false\nvid_lowerinbackground=false\nsnd_mastervolume=0.05\n')
            network=['-host','2','-port',str(args.port),'-netmode','0'] if index==0 else ['-join',f'127.0.0.1:{args.port}','-port',str(args.port+1)]
            if args.source or args.reload:
                with (peer/'recovery.zds').open('xb') as copied:copied.write((out/'imported.zds').read_bytes())
            entry=['-loadgame','recovery.zds'] if args.source or args.reload else ['+map','MAP03']
            cmd=[str(fixture.ENGINE),'-noautoload','-iwad',str(fixture.IWAD),'-file',str(runtime),str(out/'checks.pk3'),
                 '-config',str(peer/'isolated.ini'),'-savedir',str(peer),'-window','-width','640','-height','480','-rngseed','434',
                 *network,'+logfile',str(peer/'engine.log'),*entry,'+exec',str(peer/'test.cfg')]
            commands.append(cmd);stream=(peer/'process.log').open('wb');streams.append(stream)
            processes.append(subprocess.Popen(cmd,cwd=peer,startupinfo=startup,stdout=stream,stderr=stream));time.sleep(.3)
        print('Started two native peers:',out,flush=True)
        deadline=time.monotonic()+70
        while any(p.poll() is None for p in processes) and time.monotonic()<deadline:
            if any(any(t in p.read_text(errors='replace') for t in ('Execution could not continue','Script error','VM execution aborted','Cannot find savegame','DIED WITH FATAL ERROR','EADDRINUSE')) for p in out.glob('peer*/engine.log')):break
            time.sleep(.2)
    finally:
        for process in processes:
            if process.poll() is None:process.terminate();process.wait(timeout=10)
        for stream in streams:stream.close()
    reports=[]
    for index,process in enumerate(processes):
        log=out/f'peer{index}/engine.log';text=log.read_text(errors='replace') if log.exists() else ''
        errors=[l for l in text.splitlines() if any(t in l for t in (' FAIL ','Execution could not continue','Script error','VM execution aborted','out of sync','desync','Unknown type','Unknown sprite','Cannot find savegame','DIED WITH FATAL ERROR','EADDRINUSE'))]
        checks=[l for l in text.splitlines() if l.startswith('CA434 ')]
        passed=process.returncode==0 and not errors and text.count('CA434 PASS')==(15 if args.source or args.reload else 3) and text.count('CA434 RESULT')==1
        reports.append(dict(peer=index,exit=process.returncode,passed=passed,checks=checks,errors=errors))
    result=dict(issue=434,stage='typed graph prototype; not durable custody acceptance',runtime_sha256=fixture.digest(runtime),
                commands=commands,source=str(args.source),reload=str(args.reload),peers=reports,passed=all(r['passed'] for r in reports))
    (out/'results.json').write_text(json.dumps(result,indent=2),encoding='utf-8')
    print(json.dumps({'directory':str(out),'passed':result['passed'],'peers':reports},indent=2))
    if not result['passed']:raise SystemExit(1)


if __name__=='__main__':main()
