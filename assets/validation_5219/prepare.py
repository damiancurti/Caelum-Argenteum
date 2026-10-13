"""Package focused #211 checks and explicitly adapted historical fixtures."""
from pathlib import Path
import hashlib
import importlib.util
import json
import subprocess

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent
OUT = ROOT / 'build/issue211'


def main():
    spec = importlib.util.spec_from_file_location('previous', ROOT/'assets/validation_5212/prepare.py')
    old = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(old)
    OUT.mkdir(exist_ok=True)
    if not (OUT/'baseline.pk3').exists():
        subprocess.run(['git','archive','--format=zip',f'--output={OUT / "baseline.pk3"}',
                        '4549991a:src'],cwd=ROOT,check=True)
    manifest = {'baseline': hashlib.sha256((OUT/'baseline.pk3').read_bytes()).hexdigest()}
    manifest['production'] = old.package(OUT/'production.pk3', {
        p.relative_to(ROOT/'src').as_posix():p.read_bytes()
        for p in (ROOT/'src').rglob('*') if p.is_file()})
    fixtures = {p.stem:p.read_text(encoding='utf-8') for p in HERE.glob('*.zs')}
    source = (ROOT/'assets/validation_5212/bull.zs').read_text(encoding='utf-8')
    start,end = source.index('    void Defense()'),source.index('    override void WorldTick()')
    source = source[:start]+source[end:]
    source = source.replace('Bull.target=TargetBody;Profiles();Defense();','Bull.target=TargetBody;')
    fixtures['bull'] = source.replace('CA195','CA211')
    source = (ROOT/'assets/validation_5212/contacts.zs').read_text(encoding='utf-8')
    source = source.replace('let a=bull.BuildImpactPhysicsBody()',
        'double absorption=bull.GetBiologicalLandingAbsorptionSpeed();\n        let a=bull.BuildImpactPhysicsBody()')
    source = source.replace('joules*0.598492890584',
        'joules*(Max(0.0,(result.Impulse/900)-absorption)/(result.Impulse/900))**2')
    fixtures['contacts'] = source.replace('CA195','CA211')
    previous = ROOT/'assets/validation_5211'
    common = (previous/'energy.zs').read_text(encoding='utf-8')+'\n'+(previous/'combat.zs').read_text(encoding='utf-8')
    for name in ['motion','pressure']:
        fixtures[name] = (common+'\n'+(previous/f'{name}.zs').read_text(encoding='utf-8')).replace('CA194','CA211')
    for name,source in fixtures.items():
        manifest[name] = old.package(OUT/f'{name}.pk3', {
            'ZSCRIPT':b'version "4.14"\n#include "checks.zs"\n', 'checks.zs':source.encode(),
            'maps/MAPQA.wad':old.test_map(),
            'MAPINFO':f'GameInfo {{ AddEventHandlers="CA211{name.title()}" }}\n'.encode()})
        (OUT/f'{name}.cfg').write_text('wait 220; quit\n',encoding='utf-8')
    for cfg in HERE.glob('*.cfg'):
        (OUT/cfg.name).write_bytes(cfg.read_bytes())
    (OUT/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf-8')
    print('Prepared:',', '.join(manifest))


if __name__ == '__main__':
    main()
