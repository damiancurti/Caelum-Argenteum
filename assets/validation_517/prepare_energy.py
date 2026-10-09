"""Prepare isolated mechanical-work checks without replacing earlier evidence."""
from pathlib import Path
import importlib.util,subprocess

ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).resolve().parent
OUT=ROOT/'build/issue136'
spec=importlib.util.spec_from_file_location('energy_base',HERE/'prepare.py')
base=importlib.util.module_from_spec(spec);spec.loader.exec_module(base)

def main():
    if 'gzdoom.exe' in subprocess.check_output(['tasklist','/FI','IMAGENAME eq gzdoom.exe','/NH'],text=True).lower():
        raise SystemExit('Close native runs before replacing fixtures.')
    base.main()
    (OUT/'energy-current').mkdir(exist_ok=True)
    package=base.previous.package
    package('energy-current/caelum_argenteum_dev.pk3',{p.relative_to(ROOT/'src').as_posix():p.read_bytes() for p in (ROOT/'src').rglob('*') if p.is_file()})
    package('energy-checks.pk3',{
        'maps/CA136.wad':base.previous.room().replace(b'CA143',b'CA136'),
        'MAPINFO':b'map CA136 "Energy budgets" {}\nGameInfo { AddEventHandlers="CA136EnergyChecks" }\n',
        'ZSCRIPT':b'version "4.14"\n#include "checks.zs"\n#include "energy_checks.zs"\n',
        'checks.zs':(HERE/'checks.zs').read_bytes(),'energy_checks.zs':(HERE/'energy_checks.zs').read_bytes()})
    (OUT/'energy-checks.cfg').write_text('unbindall;wait 80;quit\n',encoding='utf-8')
    for mode in range(4):
        package(f'energy-live-{mode}.pk3',{
            'MAPINFO':b'GameInfo { AddEventHandlers="CA136EnergyLive" }\n',
            'ZSCRIPT':b'version "4.14"\n#include "checks.zs"\n#include "energy_live.zs"\n',
            'checks.zs':(HERE/'checks.zs').read_bytes(),
            'energy_live.zs':(HERE/'energy_live.zs').read_bytes().replace(b'const MODE=0;',f'const MODE={mode};'.encode())})
    (OUT/'energy-live.cfg').write_text('unbindall;wait 70;+jump;wait 1;-jump;wait 210;+attack;wait 210;-attack;wait 419;quit\n',encoding='utf-8')
    for high in range(2):
        package(f'energy-block-{high}.pk3',{
            'MAPINFO':b'GameInfo { AddEventHandlers="CA136EnergyBlock" }\n',
            'ZSCRIPT':b'version "4.14"\n#include "checks.zs"\n#include "energy_block.zs"\n',
            'checks.zs':(HERE/'checks.zs').read_bytes(),
            'energy_block.zs':(HERE/'energy_block.zs').read_bytes().replace(b'const HIGH=0;',f'const HIGH={high};'.encode())})
    (OUT/'energy-block.cfg').write_text('unbindall;wait 290;quit\n',encoding='utf-8')
    for mode in range(3):
        directory=OUT/f'energy-save-{mode}';directory.mkdir(exist_ok=True)
        package(f'energy-save-{mode}/energy-persist.pk3',{
            'maps/CA136.wad':base.previous.room().replace(b'CA143',b'CA136'),
            'MAPINFO':b'map CA136 "Energy persistence" {}\nGameInfo { AddEventHandlers="CA136EnergyPersist" }\n',
            'ZSCRIPT':b'version "4.14"\n#include "checks.zs"\n#include "energy_persist.zs"\n',
            'checks.zs':(HERE/'checks.zs').read_bytes(),
            'energy_persist.zs':(HERE/'energy_persist.zs').read_bytes().replace(b'const MODE=0;',f'const MODE={mode};'.encode())})
    for name,commands in {
        'energy-seed':'unbindall;wait 100;save ca136-energy-old;wait 5;quit',
        'energy-upgrade':'unbindall;wait 20;save ca136-energy-new;wait 220;quit',
        'energy-reload':'unbindall;wait 220;quit',
        'energy-rollback':'unbindall;wait 3;quit',
    }.items():(OUT/(name+'.cfg')).write_text(commands+'\n',encoding='utf-8')
    print('Prepared mechanical-work checks and current compatible package.')

if __name__=='__main__':main()
