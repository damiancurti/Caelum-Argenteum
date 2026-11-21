"""Prepare or open one combined environment scene for the final author session.

All saves/configuration stay in a new build directory. F1 cycles native review
anchors; menus remain usable. House review enters through real portal travel.
The fixture uses invulnerability/notarget and suppresses narrative delivery;
this is an art review, not ordinary campaign or multiplayer acceptance.
"""
from pathlib import Path
import argparse, hashlib, json, subprocess, zipfile

ROOT = Path(__file__).resolve().parents[2]
ENGINE = Path('C:/Program Files (x86)/GZDoom/gzdoom.exe')
IWAD = Path('C:/Program Files (x86)/Steam/steamapps/common/ultimate doom/base/doom2/DOOM2.WAD')
SHA = lambda p: hashlib.sha256(p.read_bytes()).hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    for name in ['runtime', 'overlay-directory', 'output']:
        parser.add_argument('--' + name, type=Path, required=True)
    parser.add_argument('--scene', choices=['house', 'city', 'mansion', 'sewer'], required=True)
    parser.add_argument('--variant', choices=['control', 'appearance', 'vaults'], required=True)
    mode = parser.add_mutually_exclusive_group(required=True)
    mode.add_argument('--prepare-only', action='store_true')
    mode.add_argument('--interactive', action='store_true')
    args = parser.parse_args()
    runtime = args.runtime.resolve(strict=True)
    out = args.output.resolve()
    out.relative_to(ROOT / 'build')
    assert out != ROOT / 'build'
    manifest = json.loads((args.overlay_directory / 'MANIFEST.json').read_text(encoding='utf-8'))
    assert manifest['issue'] == 881
    assert SHA(runtime) == manifest['runtime_sha256'], 'Rebuild the composition for this runtime first'
    overlays = []
    if args.variant != 'control':
        row = next(r for r in manifest['variants'] if r['name'] == args.variant)
        overlay = (args.overlay_directory / (args.variant + '.pk3')).resolve(strict=True)
        assert SHA(overlay) == row['sha256']
        overlays.append(str(overlay))
    evidence = Path(__file__).parent / 'evidence/views' / args.scene
    report = json.loads((evidence / 'RESULTS.json').read_text(encoding='utf-8'))
    assert report['passed']
    source = (evidence / 'combined-probe.zs').read_text(encoding='utf-8')
    anchor = 'Place(View);View++;'
    assert source.count(anchor) == 1
    source = source.replace(anchor, f'Place(View);View=(View+1)%{len(report["cameras"])};')
    start = source.index('    override void UiTick()')
    end = source.index('    override void WorldTick()', start)
    source = source[:start] + source[end:]
    mapinfo = 'gameinfo { AddEventHandlers="CA866Views" }\n'
    commands = ['bind F1 "netevent ca866_next"', 'wait 140']
    map_name = report['map']
    if args.scene == 'house':
        map_name = 'MAP03'
        mapinfo = 'gameinfo { AddEventHandlers="CA866Views","CA454HouseUseProbe" }\ndoomednums {31050=CA454HouseUseCity}\n'
        commands += ['netevent ca454_house_in 0', 'wait 140']
    commands += ['netevent ca866_next']
    out.mkdir(parents=True, exist_ok=False)
    probe = out / 'review.pk3'
    members = {'ZSCRIPT': 'version "4.14.2"\n#include "probe.zs"\n', 'MAPINFO': mapinfo, 'probe.zs': source}
    with zipfile.ZipFile(probe, 'x') as archive:
        for name, value in sorted(members.items()):
            archive.writestr(zipfile.ZipInfo(name, (2026, 11, 21, 0, 0, 0)), value.encode('utf-8'))
    config = out / 'review.ini'
    config.write_text('[GlobalSettings]\nvid_fullscreen=false\nvid_preferbackend=1\nvid_activeinbackground=true\ni_pauseinbackground=false\nvid_lowerinbackground=false\ni_soundinbackground=true\nsnd_mastervolume=0.05\nvid_maxfps=60\nlanguage=enu\n', encoding='utf-8', newline='\n')
    cfg = out / 'start.cfg'
    cfg.write_text('; '.join(commands) + '\n', encoding='utf-8', newline='\n')
    command = [str(ENGINE), '-noautoload', '-iwad', str(IWAD), '-file', str(runtime), *overlays, str(probe), '-config', str(config), '-savedir', str(out), '-window', '-width', '1280', '-height', '720', '+logfile', str(out / 'engine.log'), '+map', map_name, '+exec', str(cfg)]
    record = dict(issue=881, author_acceptance=False, scene=args.scene, variant=args.variant,
                  runtime_sha256=manifest['runtime_sha256'], command=command, cameras=report['cameras'],
                  qualification=__doc__, geometry_save_scope='Fresh disposable sessions only. Never load campaign saves into the vaults variant.')
    (out / 'review-session.json').write_text(json.dumps(record, indent=2) + '\n', encoding='utf-8', newline='\n')
    if args.prepare_only:
        print('Prepared: ' + str(out))
        return
    active = subprocess.check_output(['tasklist', '/FI', 'IMAGENAME eq gzdoom.exe', '/FO', 'CSV', '/NH'], text=True, errors='replace')
    assert 'gzdoom.exe' not in active.lower(), 'Another native engine is running'
    print('F1 cycles ' + ', '.join(r['name'] for r in report['cameras']) + '.')
    print('Walk normally; native menus remain available. Disposable saves: ' + str(out))
    raise SystemExit(subprocess.call(command, cwd=out))


if __name__ == '__main__':
    main()
