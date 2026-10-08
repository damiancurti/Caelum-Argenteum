"""Build isolated #135 native fixtures; no engine/IWAD/test package is distributed."""
from pathlib import Path
import hashlib
import importlib.util
import subprocess
import zipfile

ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).resolve().parent
OUT=ROOT/'build/issue135'
BASE='5f9202ad42f3dd0750f5368e2e15b28d98fac4a5'

def package(name,members):
    with zipfile.ZipFile(OUT/name,'w',zipfile.ZIP_STORED) as z:
        for key,data in sorted(members.items()):
            z.writestr(zipfile.ZipInfo(key,(2000,1,1,0,0,0)),data)
    return hashlib.sha256((OUT/name).read_bytes()).hexdigest()

def main():
    if 'gzdoom.exe' in subprocess.check_output(['tasklist','/FI','IMAGENAME eq gzdoom.exe','/NH'],text=True).lower():
        raise SystemExit('Finish native runs before replacing packages.')
    OUT.mkdir(exist_ok=True)
    package('production.pk3',{p.relative_to(ROOT/'src').as_posix():p.read_bytes() for p in (ROOT/'src').rglob('*') if p.is_file()})
    spec=importlib.util.spec_from_file_location('city_fixture',ROOT/'assets/validation_513/prepare.py')
    old=importlib.util.module_from_spec(spec);spec.loader.exec_module(old)
    room=old.test_map().replace(b'CA133',b'CA135')
    for fixture in ('checks','breath','integration','consumption','visual','cost','orientation'):
        extra=',"CA135AbilityProbe"' if fixture=='integration' else ''
        package(fixture+'.pk3',{'maps/CA135.wad':room,'maps/CA135B.wad':room.replace(b'CA135',b'C135B'),
            'MAPINFO':f'cluster 435 {{ hub }}\nmap CA135 "Demon mechanics" {{ cluster=435 }}\nmap CA135B "Hub probe" {{ cluster=435 }}\nGameInfo {{ AddEventHandlers="CA135{fixture.title()}"{extra} }}\n'.encode(),
            'ZSCRIPT':f'version "4.14"\n#include "{fixture}.zs"\n'.encode(),
            'CVARINFO':b'server bool ca135_verify_load=false;\nserver int ca135_gallery_stage=0;\nserver int ca135_cost_sources=0;\n',
            fixture+'.zs':(HERE/(fixture+'.zs')).read_bytes()})
    (OUT/'checks.cfg').write_text('unbindall; wait 230; save ca135-mid; wait 250; save ca135-checks; wait 5; quit\n',encoding='utf-8')
    (OUT/'reload.cfg').write_text('wait 5; ca135_verify_load true; wait 245; quit\n',encoding='utf-8')
    (OUT/'integration.cfg').write_text('unbindall; wait 100; save ca135-breath; wait 350; quit\n',encoding='utf-8')
    (OUT/'integration-reload.cfg').write_text('wait 350; quit\n',encoding='utf-8')
    (OUT/'consumption.cfg').write_text('unbindall; wait 2260; quit\n',encoding='utf-8')
    commands='unbindall; wait 100; screenshot potion-tiers.png; wait 10; '
    for stage in range(1,11):
        commands+=f'ca135_gallery_stage {stage}; wait 60; screenshot pose-{stage}.png; wait 5; '
    (OUT/'visual.cfg').write_text(commands+'quit\n',encoding='utf-8')
    commands='unbindall; wait 80; '
    for stage in range(1,25):
        commands+=f'ca135_gallery_stage {stage}; wait 10; screenshot orientation-{stage}.png; wait 2; '
    (OUT/'orientation.cfg').write_text(commands+'quit\n',encoding='utf-8')
    for sources in (0,4,16):
        (OUT/f'cost-{sources}.cfg').write_text(f'unbindall; ca135_cost_sources {sources}; wait 1230; quit\n',encoding='utf-8')
    print('Prepared isolated demon mechanics package.')

if __name__=='__main__':main()
