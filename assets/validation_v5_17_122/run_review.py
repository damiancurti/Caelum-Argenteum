"""Prepare or open the waterline masonry proposal in a fresh disposable review session.

F1 cycles eight sampled anchors; native menus remain available. The fixture
suppresses narrative delivery and enables invulnerability/notarget. It does
not grant services or inventory. This is art review, not campaign acceptance.
"""
from pathlib import Path
import argparse, hashlib, json, subprocess, zipfile

ROOT = Path(__file__).resolve().parents[2]
ENGINE = Path('C:/Program Files (x86)/GZDoom/gzdoom.exe')
IWAD = Path('C:/Program Files (x86)/Steam/steamapps/common/ultimate doom/base/doom2/DOOM2.WAD')
SHA = lambda p: hashlib.sha256(p.read_bytes()).hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    for name in ['runtime', 'control-overlay', 'overlay', 'manifest', 'output']:
        parser.add_argument('--' + name, type=Path, required=True)
    parser.add_argument('--variant', choices=['default', 'control', 'candidate'], required=True)
    mode = parser.add_mutually_exclusive_group(required=True)
    mode.add_argument('--prepare-only', action='store_true')
    mode.add_argument('--interactive', action='store_true')
    args = parser.parse_args()
    runtime = args.runtime.resolve(strict=True)
    out = args.output.resolve()
    out.relative_to(ROOT / 'build')
    assert out != ROOT / 'build'
    manifest = json.loads(args.manifest.read_text(encoding='utf-8'))
    assert manifest['issue'] == 887
    assert SHA(runtime) == manifest['runtime_sha256'], 'Rebuild the proposal for this runtime first'
    overlays = []
    if args.variant != 'default':
        overlay = (args.control_overlay if args.variant == 'control' else args.overlay).resolve(strict=True)
        expected = manifest['inherited_sha256'] if args.variant == 'control' else manifest['package_sha256']
        assert SHA(overlay) == expected
        overlays.append(str(overlay))
    evidence = Path(__file__).parent / 'evidence/views'
    report = json.loads((evidence / 'RESULTS.json').read_text(encoding='utf-8'))
    assert report['passed'] and report['candidate_sha256'] == manifest['package_sha256']
    source = (evidence / 'probe.zs').read_text(encoding='utf-8')
    anchor = 'Place(View);View++;'
    assert source.count(anchor) == 1
    source = source.replace(anchor, f'Place(View);View=(View+1)%{len(report["cameras"])};')
    from run_views import surface_probe
    start = source.index('    void CheckSurfaces()')
    end = source.index('    void Place(int index)', start)
    source = source[:start] + surface_probe(manifest, allow_default=True) + source[end:]
    start = source.index('    void Sizes()')
    end = source.index('    void CheckSurfaces()', start)
    source = source[:start] + source[end:]
    assert source.count('if(View==0)Sizes();') == 1
    source = source.replace('if(View==0)Sizes();', '')
    start = source.index('    override void UiTick()')
    end = source.index('    override void WorldTick()', start)
    source = source[:start] + source[end:]
    out.mkdir(parents=True, exist_ok=False)
    probe = out / 'review.pk3'
    members = {'ZSCRIPT': 'version "4.14.2"\n#include "probe.zs"\n',
               'MAPINFO': 'gameinfo { AddEventHandlers="CA866Views" }\n', 'probe.zs': source}
    with zipfile.ZipFile(probe, 'x') as archive:
        for name, value in sorted(members.items()):
            archive.writestr(zipfile.ZipInfo(name, (2026, 11, 21, 0, 0, 0)), value.encode('utf-8'))
    config = out / 'review.ini'
    config.write_text('[GlobalSettings]\nvid_fullscreen=false\nvid_preferbackend=1\nvid_activeinbackground=true\ni_pauseinbackground=false\nvid_lowerinbackground=false\ni_soundinbackground=true\nsnd_mastervolume=0.05\nvid_maxfps=60\nlanguage=es\n', encoding='utf-8', newline='\n')
    cfg = out / 'start.cfg'
    cfg.write_text('bind F1 "netevent ca866_next"; wait 140; netevent ca866_next\n', encoding='utf-8', newline='\n')
    command = [str(ENGINE), '-noautoload', '-iwad', str(IWAD), '-file', str(runtime), *overlays, str(probe),
               '-config', str(config), '-savedir', str(out), '-window', '-width', '1280', '-height', '720',
               '+logfile', str(out / 'engine.log'), '+map', 'MAP02', '+exec', str(cfg)]
    record = dict(issue=887, author_acceptance=False, variant=args.variant, command=command,
                  runtime_sha256=manifest['runtime_sha256'], cameras=report['cameras'], qualification=__doc__,
                  save_scope='Fresh disposable sessions only. Same-option saves only; never import campaign saves or saves from another map variant.')
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
