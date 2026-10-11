"""Build deterministic local-only packages for the #195 bull and resident checks."""
from pathlib import Path
import hashlib
import importlib.util
import json
import subprocess
import struct
import zipfile

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent
OUT = ROOT / 'build/issue195'


def test_map():
    text = ['namespace="ZDoom";', 'sector { heightfloor=0; heightceiling=1024; texturefloor="CASWRFLR"; textureceiling="CASWRWAL"; lightlevel=200; }']
    for x, y in ((-2048,-2048),(-2048,2048),(2048,2048),(2048,-2048)):
        text.append(f'vertex {{ x={x}; y={y}; }}')
    for i in range(4):
        text.append('sidedef { sector=0; texturemiddle="CASWRWAL"; }')
        text.append(f'linedef {{ v1={i}; v2={(i+1)%4}; sidefront={i}; blocking=true; }}')
    text.append('thing { x=-1800; y=-1800; type=1; skill1=true; skill2=true; skill3=true; skill4=true; skill5=true; single=true; }')
    data=b''; directory=b''
    for name, payload in [('MAPQA',b''),('TEXTMAP','\n'.join(text).encode()),('ENDMAP',b'')]:
        directory+=struct.pack('<II8s',12+len(data),len(payload),name.encode())
        data+=payload
    return struct.pack('<4sII',b'PWAD',3,12+len(data))+data+directory


def package(path, members):
    with zipfile.ZipFile(path, 'w', zipfile.ZIP_STORED) as archive:
        for name, data in sorted(members.items()):
            archive.writestr(zipfile.ZipInfo(name, (2000, 1, 1, 0, 0, 0)), data)
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    running = subprocess.check_output(['powershell', '-NoProfile', '-Command',
        "Get-CimInstance Win32_Process -Filter \"Name='gzdoom.exe'\" | Select-Object -ExpandProperty ProcessId"], text=True)
    if running.strip():
        raise SystemExit('Finish the native run before replacing packages.')
    OUT.mkdir(exist_ok=True)
    if not (OUT / 'baseline.pk3').exists():
        subprocess.run(['git', 'archive', '--format=zip', f'--output={OUT / "baseline.pk3"}',
                        'dbf449cd:src'], cwd=ROOT, check=True)
    manifest = {'baseline': hashlib.sha256((OUT / 'baseline.pk3').read_bytes()).hexdigest()}
    manifest['production'] = package(OUT / 'production.pk3', {
        p.relative_to(ROOT / 'src').as_posix(): p.read_bytes()
        for p in (ROOT / 'src').rglob('*') if p.is_file()})
    for source in sorted(HERE.glob('*.zs')):
        data = source.read_bytes()
        manifest[source.stem] = package(OUT / (source.stem + '.pk3'), {
            'ZSCRIPT': b'version "4.14"\n#include "checks.zs"\n', 'checks.zs': data, 'maps/MAPQA.wad': test_map(),
            'MAPINFO': f'GameInfo {{ AddEventHandlers="CA195{source.stem.title()}" }}\n'.encode()})
    for cfg in HERE.glob('*.cfg'):
        (OUT / cfg.name).write_bytes(cfg.read_bytes())
    # Reuse accepted player-tool mechanics checks against the new shared service.
    spec=importlib.util.spec_from_file_location('staff_fixture',ROOT/'assets/validation_5115/prepare.py')
    module=importlib.util.module_from_spec(spec);spec.loader.exec_module(module)
    for name,version,old in [('staffregress','5115','162'),('bolasregress','5116','163')]:
        source=(ROOT/f'assets/validation_{version}/checks.zs').read_text(encoding='utf-8')
        source=source.replace(f'CA{old}Checks',f'CA195{name.title()}').replace(f'CA{old} ', 'CA195 ')
        source=source.replace('RESULT passed=%d failed=%d",Passed,Failed','DONE failures=%d passes=%d",Failed,Passed')
        if name=='staffregress':
            source=source.replace('recipe revision 6 preserves','recipe revision at least 6 preserves').replace('record.RecipeBookVersion==6','record.RecipeBookVersion>=6')
        manifest[name]=package(OUT/(name+'.pk3'),{
            'ZSCRIPT':b'version "4.14"\n#include "checks.zs"\n','checks.zs':source.encode(),
            'maps/CA162.wad':module.test_map(),'CVARINFO':b'server int ca162_stage=0;\n',
            'MAPINFO':f'GameInfo {{ AddEventHandlers="CA195{name.title()}" }}\n'.encode()})
        (OUT/(name+'.cfg')).write_text('wait 120; quit\n',encoding='utf-8')
    (OUT / 'manifest.json').write_text(json.dumps(manifest, indent=2) + '\n', encoding='utf-8', newline='\n')
    print('Prepared:', ', '.join(manifest))


if __name__ == '__main__':
    main()
