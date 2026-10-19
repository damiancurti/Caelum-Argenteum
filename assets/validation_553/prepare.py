"""Freeze isolated #312 pressure tests and their accepted #194 dependencies."""
from pathlib import Path
import argparse
import hashlib
import importlib.util
import json
import subprocess
import struct
import zipfile

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).parent
OLD = HERE.parent / 'validation_5211'


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def package(path, members):
    with zipfile.ZipFile(path, 'w', zipfile.ZIP_STORED) as archive:
        for name, data in sorted(members.items()):
            archive.writestr(zipfile.ZipInfo(name, (2000, 1, 1, 0, 0, 0)), data)


def ceiling_map(legacy=False):
    text=['namespace="ZDoom";']
    for sector, (left,right,bottom,top,height,tag) in enumerate(((-1024,0,-512,512,256,0 if legacy else 44557),(256,384,-64,64,128,44556))):
        text.append(f'sector {{ heightfloor=0; heightceiling={height}; id={tag}; texturefloor="CASWRFLR"; textureceiling="CASWRWAL"; lightlevel=200; }}')
        for x,y in ((left,bottom),(left,top),(right,top),(right,bottom)):
            text.append(f'vertex {{ x={x}; y={y}; }}')
        for i in range(4):
            index=sector*4+i
            text.append(f'sidedef {{ sector={sector}; texturemiddle="CASWRWAL"; }}')
            text.append(f'linedef {{ v1={index}; v2={sector*4+(i+1)%4}; sidefront={index}; blocking=true; }}')
    text.append('thing { x=-512; y=0; type=1; skill1=true; skill2=true; skill3=true; skill4=true; skill5=true; single=true; }')
    data=b'';directory=b''
    for name,payload in [('MAPQA',b''),('TEXTMAP','\n'.join(text).encode()),('ENDMAP',b'')]:
        directory+=struct.pack('<II8s',12+len(data),len(payload),name.encode());data+=payload
    return struct.pack('<4sII',b'PWAD',3,12+len(data))+data+directory


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--directory', required=True)
    parser.add_argument('--runtime', type=Path)
    parser.add_argument('--legacy-ceiling', action='store_true',
                        help='Keep the original ceiling-save geometry and required package basename.')
    args = parser.parse_args()
    if not args.directory.replace('-', '').replace('_', '').isalnum():
        parser.error('Use a single directory name.')
    out = ROOT / 'build' / args.directory
    out.mkdir(exist_ok=False)
    spec = importlib.util.spec_from_file_location('map194', OLD / 'prepare.py')
    maps = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(maps)
    if args.runtime:
        (out / 'production.pk3').write_bytes(args.runtime.read_bytes())
    else:
        package(out / 'production.pk3', {p.relative_to(ROOT / 'src').as_posix(): p.read_bytes()
                for p in (ROOT / 'src').rglob('*') if p.is_file()})
    fixtures = {}
    for kind in ('probe', 'flow', 'persist', 'travel', 'ceiling', 'ceilingsave', 'ceilingsavelegacy', 'pressure', 'motion', 'combat', 'preview'):
        names = ['energy', 'combat']
        if kind in ('probe', 'flow', 'motion', 'preview'):
            names += ['motion']
        if kind in ('pressure', 'ceiling', 'ceilingsave', 'ceilingsavelegacy'):
            names += ['pressure']
        data = b'\n'.join((OLD / (name + '.zs')).read_bytes() for name in names)
        handler = 'CA194' + kind.title()
        if kind in ('probe', 'flow'):
            data += b'\n' + (HERE / 'probe.zs').read_bytes()
            handler = 'CA312' + kind.title()
        if kind in ('persist', 'travel'):
            data += b'\n' + (HERE / 'persistence.zs').read_bytes()
            handler = 'CA312' + kind.title()
        if kind in ('ceiling','ceilingsave','ceilingsavelegacy'):
            data += b'\n' + (HERE / 'ceiling.zs').read_bytes()
            handler = 'CA312' + kind.title()
            if kind=='ceilingsavelegacy':handler='CA312Ceilingsave'
        if kind=='preview':
            data += b'\n' + (HERE / 'preview.zs').read_bytes()
            handler='CA312Preview'
        mapinfo = f'GameInfo {{ AddEventHandlers="{handler}" }}\n'.encode()
        mapinfo += b'cluster 99 { hub }\nmap MAPQA "Pressure audit" { cluster=99 nointermission }\nmap MAPQB "Pressure travel" { cluster=99 nointermission }\n'
        package(out / (kind + '.pk3'), {
            'ZSCRIPT': b'version "4.14"\n#include "checks.zs"\n',
            'checks.zs': data, 'maps/MAPQA.wad': ceiling_map(kind=='ceilingsavelegacy' or (kind=='ceilingsave' and args.legacy_ceiling)) if kind in ('ceiling','ceilingsave','ceilingsavelegacy') else maps.test_map(),
            'maps/MAPQB.wad': maps.test_map(), 'MAPINFO': mapinfo})
        fixtures[kind + '.pk3'] = sha(out / (kind + '.pk3'))
    scripts = {'probe.cfg': 'wait 100; quit\n', 'flow.cfg': 'wait 110; quit\n',
               'pressure.cfg': 'wait 150; quit\n',
               'motion.cfg': 'wait 100; quit\n',
               'combat.cfg': 'wait 30; quit\n','ceiling.cfg':'wait 75; quit\n'}
    scripts.update({'save.cfg':'wait 20; storesavepic false; save ca312-ongoing; wait 4; quit\n',
                    'load.cfg':'wait 30; storesavepic false; save ca312-after; wait 4; quit\n',
                    'rollback.cfg':'wait 2; netevent c312_rollback; wait 25; quit\n',
                    'travel.cfg':'wait 100; netevent c312_travel_setup; wait 2; changemap MAPQB; wait 15; netevent c312_away; wait 2; changemap MAPQA; wait 15; netevent c312_back; wait 2; changemap MAPQB; wait 15; netevent c312_away; wait 2; changemap MAPQA; wait 15; netevent c312_back; wait 4; quit\n'})
    scripts.update({'ceiling-save.cfg':'wait 19; storesavepic false; save ca312-ceiling; wait 4; quit\n',
                    'ceiling-load.cfg':'wait 14; storesavepic false; save ca312-ceiling-upgraded; wait 4; quit\n'})
    scripts['old-load.cfg']=scripts['load.cfg'].replace('ca312-after','ca312-old-after')
    scripts['old-ceiling-load.cfg']=scripts['ceiling-load.cfg'].replace('ca312-ceiling-upgraded','ca312-legacy-converted')
    scripts['preview.cfg']='vid_maxfps 60; wait 180; use_mouse true; language es; netevent c312_preview_setup; bind f6 "netevent c312_preview 0"; bind f7 "netevent c312_preview 1"; bind f8 "netevent c312_preview 2"; bind f10 "map THAZARD; exec preview.cfg"; con_notifytime 0;\n'
    scripts['preview-smoke.cfg']=scripts['preview.cfg']+'wait 180; netevent c312_preview 1; wait 180; screenshot preview-weight.png; wait 5; netevent c312_preview 2; wait 180; screenshot preview-release.png; netevent c312_preview 0; wait 180; screenshot preview-ceiling.png; wait 5; quit\n'
    for name, data in scripts.items():
        (out / name).write_text(data, encoding='utf-8')
    manifest = {
        'source_commit': subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True).strip(),
        'runtime_sha256': sha(out / 'production.pk3'), 'fixtures': fixtures,
        'source_hashes': {str(p.relative_to(ROOT)): sha(p) for p in HERE.glob('*') if p.suffix in ('.py','.zs','.ps1')},
        'reused_sources': {name: sha(OLD / (name + '.zs')) for name in ('energy', 'combat', 'motion', 'pressure')},
        'script_hashes': {p.name: sha(p) for p in out.glob('*.cfg')}}
    (out / 'manifest.json').write_text(json.dumps(manifest, indent=2) + '\n', encoding='utf-8')
    print(json.dumps({'directory': str(out), 'runtime_sha256': manifest['runtime_sha256']}))


if __name__ == '__main__':
    main()
