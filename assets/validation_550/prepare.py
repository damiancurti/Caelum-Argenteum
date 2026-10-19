"""Freeze the #309 native-input audit in a fresh, private directory."""
from pathlib import Path
import argparse
import hashlib
import importlib.util
import json
import subprocess
import zipfile

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).parent
spec = importlib.util.spec_from_file_location('quick', HERE.parent/'validation_5422/prepare.py')
quick = importlib.util.module_from_spec(spec)
spec.loader.exec_module(quick)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--directory', required=True)
    parser.add_argument('--baseline', action='store_true')
    parser.add_argument('--runtime', type=Path, help='Reuse a frozen runtime for baseline controls.')
    args = parser.parse_args()
    if not args.directory or any(c not in 'abcdefghijklmnopqrstuvwxyz0123456789-_' for c in args.directory):
        parser.error('Use a plain lowercase directory name.')
    out = ROOT/'build'/args.directory
    out.mkdir(exist_ok=False)
    sources = {p.relative_to(ROOT/'src').as_posix(): p.read_bytes()
               for p in (ROOT/'src').rglob('*') if p.is_file()}
    if args.runtime:
        with zipfile.ZipFile(args.runtime) as archive:
            sources = {n: archive.read(n) for n in archive.namelist()}
    package = quick.seal.shared.package
    manifest = dict(source_commit=subprocess.check_output(['git','rev-parse','HEAD'],cwd=ROOT,text=True).strip(),
                    source_hashes={n: hashlib.sha256(v).hexdigest() for n,v in sources.items()},
                    runtime_sha256=package(out/'production.pk3',sources))
    manifest['fixture_sha256'] = package(out/'quick.pk3', {
        'ZSCRIPT': b'version "4.14"\n#include "probe.zs"\n',
        'probe.zs': (HERE/'probe.zs').read_bytes(),
        'maps/MAP99.wad': quick.seal.wad(), 'maps/MAP98.wad': quick.seal.wad(),
        'CVARINFO': b'server bool ca309_baseline = false;\n',
        'MAPINFO': b'GameInfo { AddEventHandlers="CA309Probe" }\ncluster 99 { hub }\nmap MAP99 "Combat input audit" { cluster=99 nointermission sky1="SKY1",0 }\nmap MAP98 "Combat hub audit" { cluster=99 nointermission sky1="SKY1",0 }\n'})
    start = f'wait 100; netevent c309_setup; wait 35; ca309_baseline {str(args.baseline).lower()}; '
    finish = 'netevent c309_done; wait 35; quit\n'
    # Held requests must reach completion without releasing the input. The
    # observer records transitions so expiration cannot masquerade as failure.
    cases = []
    for kind in (0, 1, 2, 14, 15, 16):
        cases.append(f'netevent c309_equip {kind} 1 0; wait 70; netevent c309_begin; +reload; wait 280; netevent c309_check 1; -reload; wait 5; ')
        cases.append(f'netevent c309_equip {kind} 1 0; wait 70; netevent c309_begin; +reload; wait 1; -reload; wait 280; netevent c309_check 0; ')
    (out/'reload.cfg').write_text(start+''.join(cases)+finish,encoding='utf-8')
    auto = ''.join(f'netevent c309_equip {kind} 1 0; wait 70; netevent c309_begin; +attack; wait 280; netevent c309_auto; -attack; wait 10; '
                   for kind in (2,14,15,16))
    (out/'auto.cfg').write_text(start+auto+finish,encoding='utf-8')
    (out/'catalogue.cfg').write_text(start+'netevent c309_catalogue; '+finish,encoding='utf-8')
    strikes = ''.join(f'netevent c309_gauntlet {side} {cold}; wait 70; +{button}; wait 1; -{button}; wait 70; netevent c309_gauntlet_check; '
                      for cold in (0,1) for side,button in ((0,'attack'),(1,'altattack')))
    (out/'gauntlet.cfg').write_text(start+strikes+finish,encoding='utf-8')
    for kind in (0,1,2):
        seed = start+f'netevent c309_equip {kind} 2 0; wait 70; +reload; wait 1; -reload; wait 10; netevent c309_snapshot; '
        (out/f'save-{kind}.cfg').write_text(seed+f'save action-{kind}.zds; '+finish,encoding='utf-8')
        (out/f'load-{kind}.cfg').write_text('wait 1; ca309_baseline false; netevent c309_restored; netevent c309_begin; wait 210; netevent c309_check 0; '+finish,encoding='utf-8')
        (out/f'hub-{kind}.cfg').write_text(seed+'changemap MAP98; wait 1; netevent c309_restored 1; changemap MAP99; wait 1; netevent c309_restored; netevent c309_begin; wait 210; netevent c309_check 0; '+finish,encoding='utf-8')
        (out/f'switch-{kind}.cfg').write_text(seed+'netevent c309_switched; wait 70; netevent c309_switch_back; wait 70; netevent c309_begin; +reload; wait 1; -reload; wait 210; netevent c309_check 0; '+finish,encoding='utf-8')
    (out/'held-load.cfg').write_text(start+'netevent c309_equip 0 2 0; wait 70; +reload; wait 10; netevent c309_snapshot; '
        'save held-action.zds; wait 2; load held-action.zds; wait 1; netevent c309_restored; netevent c309_begin; '
        'wait 280; netevent c309_check 1; -reload; '+finish,encoding='utf-8')
    magic=[f'netevent c309_equip {kind} 1 {essence}; wait 35; netevent c309_magic_begin; +{button}; wait 1; -{button}; wait 35; netevent c309_magic_check; '
        for kind in (1,17,18,19) for essence in range(5) for button in ('attack','altattack')]
    magic+=[f'netevent c309_equip {kind} 1 0; wait 35; +reload; wait 1; -reload; wait 70; netevent c309_magic_begin 1; +{button}; wait 1; -{button}; wait 35; netevent c309_magic_check; '
        for kind in (17,19) for button in ('attack','altattack')]
    # Each exec line schedules its own wait continuation. Chain bounded files
    # explicitly, instead of starting all lines concurrently or overflowing one.
    (out/'magic.cfg').write_text(start+'exec magic-00.cfg\n',encoding='utf-8')
    for i,case in enumerate(magic):
        tail=f'exec magic-{i+1:02d}.cfg\n' if i+1<len(magic) else finish
        (out/f'magic-{i:02d}.cfg').write_text(case+tail,encoding='utf-8')
    boundaries=''.join(f'netevent c309_equip {kind} 1 0; wait 70; +reload; wait 1; -reload; wait 10; netevent c309_stun; wait 2; netevent c309_cancelled; wait 80; ' for kind in (0,1,2))
    boundaries+=''.join(f'netevent c309_equip {kind} 1 0; wait 70; netevent c309_empty; +reload; wait 1; -reload; +attack; wait 70; -attack; netevent c309_empty_check; ' for kind in (2,14,15,16))
    (out/'boundaries.cfg').write_text(start+boundaries+finish,encoding='utf-8')
    (out/'manual.cfg').write_text('wait 100; language es; use_mouse true; netevent c309_manual; '
        'bind f6 "netevent c309_equip 0 1 0"; bind f7 "netevent c309_equip 1 1 0"; '
        'bind f8 "netevent c309_equip 14 1 0"; bind f9 "netevent c309_equip 13 1 0"; '
        'bind f10 "map MAP99; exec manual.cfg"; bind r +reload; bind mouse1 +attack; bind mouse2 +altattack; '
        'con_notifytime 0; wait 70; screenshot author-preview.png; netevent c309_done;\n',encoding='utf-8')
    manifest['script_hashes']={p.name:hashlib.sha256(p.read_bytes()).hexdigest() for p in sorted(out.glob('*.cfg'))}
    (out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf-8')
    print(json.dumps({k:v for k,v in manifest.items() if k not in ('source_hashes','script_hashes')}))


if __name__ == '__main__':
    main()
