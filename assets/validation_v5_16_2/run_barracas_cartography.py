"""Verify installed/legacy known-only discovery on native maps and saved records.

The fixture calls native binding/use-record/update APIs and supplies positions;
it does not establish normal walking, service UI, siege fluency or acceptance.
"""
from pathlib import Path
import argparse
import json
import shutil
import subprocess
import zipfile
from run_barracas_legacy import ROOT, ENGINE, IWAD, digest
from run_barracas_candidate import local_point


def expected(revised):
    city = json.loads((ROOT / 'assets/map06_port/CITY.json').read_text())
    interior = json.loads((ROOT / 'assets/map06_port/INTERIORS.json').read_text())
    layout = json.loads((ROOT / 'assets/barracas_redesign/LAYOUT.json').read_text())
    siege = json.loads((ROOT / 'assets/barracas_redesign/SIEGE.json').read_text())
    buildings = {b['id']: b for b in layout['buildings']}
    points = []; ids = []
    for i, building in enumerate(b for b in city['buildings'] if b['kind'] == 'factory'):
        profile = interior['factory_profiles'][i % len(interior['factory_profiles'])]
        for j, kind in enumerate(profile['stations']):
            dx, dy = interior['station_positions'][j]
            xy = local_point(buildings[building['id']], dx, dy) if revised else (building['bounds'][0]+dx, building['bounds'][1]+dy)
            points.append((*xy, 0)); ids.append(f'city-factory-{building["id"]}-{kind}')
    stairs = [g['stairs'][0] for g in siege['defending_guns']] if revised else [s['steps'][0] for s in city['access_stairs']]
    steps = [((a+c)/2, (b+d)/2, z) for a, b, c, d, z in stairs]
    towers = siege['towers'] if revised else city['towers']
    tower_points = [(t['origin'][0]+city['tower_size']/2, t['origin'][1]+city['tower_size']/2, city['tower_deck_height']) for t in towers]
    if revised:
        east = next(g['position'] for g in layout['gates'] if g['id'] == 'east')
    else:
        a, b, c, d = next(g['bounds'] for g in city['gates'] if g['name'] == 'east'); east = ((a+c)/2, (b+d)/2, 0)
    source = f'class CA454DiscoveryExpected : Object {{ const REVISED={int(revised)};const STATIONS={len(points)};const STAIRS={len(steps)};'
    for name, rows in [('Station', points), ('Stair', steps), ('Tower', tower_points)]:
        source += f'static vector3 {name}(int i){{switch(i){{'
        source += ''.join(f'case {i}:return ({",".join(f"{v:g}" for v in p)});' for i, p in enumerate(rows))
        source += '}return (0,0,0);}'
    source += 'static String StationId(int i){switch(i){' + ''.join(f'case {i}:return "{name}";' for i, name in enumerate(ids)) + '}return "";}'
    return source + 'static vector3 East(){return (' + ','.join(f'{v:g}' for v in east) + ');}}\n'


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    for name in ('runtime', 'legacy', 'output'):
        parser.add_argument('--' + name, type=Path, required=True)
    args = parser.parse_args(); out = args.output.resolve(); out.relative_to(ROOT / 'build'); out.mkdir(exist_ok=False)
    report = {'issue': 454, 'scope': __doc__.strip(), 'engine_sha256': digest(ENGINE), 'runs': []}
    for revised, runtime in [(True, args.runtime.resolve()), (False, args.legacy.resolve())]:
        label = 'installed' if revised else 'legacy'
        fixture = out / (label + '.pk3')
        with zipfile.ZipFile(fixture, 'w') as archive:
            for name, text in {'ZSCRIPT': 'version "4.14.2"\n' + expected(revised) + Path(__file__).with_name('barracas_cartography_probe.zs').read_text(encoding='utf-8'),
                               'MAPINFO': 'gameinfo { AddEventHandlers="CA454CartographyProbe" }\n'}.items():
                archive.writestr(zipfile.ZipInfo(name, (2026, 11, 13, 0, 0, 0)), text)
        for phase in ('fresh', 'reload'):
            folder = out / (label + '-' + phase); folder.mkdir()
            (folder / 'session.ini').write_text('[GlobalSettings]\nvid_preferbackend=1\nvid_activeinbackground=true\ni_pauseinbackground=false\nvid_lowerinbackground=false\nsnd_mastervolume=0.05\ni_soundinbackground=true\nvid_fullscreen=false\nvid_maxfps=60\n')
            event = 'start' if phase == 'fresh' else 'resume'
            (folder / 'commands.cfg').write_text(f'wait 210; netevent ca454_discovery_{event}; wait 5; save knowledge; wait 10; quit\n')
            entry = ['+map', 'MAP03']
            if phase == 'reload':
                shutil.copyfile(out / (label + '-fresh') / 'knowledge.zds', folder / 'input.zds'); entry = ['-loadgame', 'input.zds']
            command = [str(ENGINE), '-noautoload', '-iwad', str(IWAD), '-file', str(runtime), str(fixture), '-config', str(folder / 'session.ini'), '-savedir', str(folder), '-window', '-width', '960', '-height', '720', '+logfile', str(folder / 'engine.log'), *entry, '+exec', str(folder / 'commands.cfg')]
            startup = subprocess.STARTUPINFO(); startup.dwFlags |= subprocess.STARTF_USESHOWWINDOW; startup.wShowWindow = 0
            with (folder / 'process.log').open('wb') as stream:
                process = subprocess.Popen(command, cwd=folder, stdout=stream, stderr=stream, startupinfo=startup)
                try: code = process.wait(timeout=180)
                except subprocess.TimeoutExpired: process.terminate(); process.wait(timeout=10); raise
            log = (folder / 'engine.log').read_text(errors='replace')
            errors = [line for line in log.splitlines() if any(s in line for s in ['Script error', 'Execution could not continue', 'VM execution aborted', 'CA454 CARTOGRAPHY FAIL'])]
            result = {'layout': label, 'phase': phase, 'runtime_sha256': digest(runtime), 'fixture_sha256': digest(fixture), 'command': command, 'exit_code': code,
                      'passed': code == 0 and not errors and 'CA454 CARTOGRAPHY PASS' in log and (folder / 'knowledge.zds').exists(), 'errors': errors,
                      'checks': [line for line in log.splitlines() if 'CA454 CARTOGRAPHY' in line]}
            report['runs'].append(result); (out / 'results.json').write_text(json.dumps(report, indent=2) + '\n'); print(json.dumps(result), flush=True)
            if not result['passed']: raise SystemExit(1)


if __name__ == '__main__':
    main()
