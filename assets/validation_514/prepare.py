"""Deterministic isolated #140 fixtures; production contains only src."""
from pathlib import Path
import hashlib
import importlib.util
import subprocess
import zipfile
import argparse

ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).resolve().parent
OUT=ROOT/'build/issue140'
BASE='dd8e18bdf12f91648b6d982991c9fda10b787627'

def package(name,members):
    with zipfile.ZipFile(OUT/name,'w',zipfile.ZIP_STORED) as z:
        for key,data in sorted(members.items()):
            z.writestr(zipfile.ZipInfo(key,(2000,1,1,0,0,0)),data)
    return hashlib.sha256((OUT/name).read_bytes()).hexdigest()

def source(name):
    return subprocess.check_output(['git','show',BASE+':src/caelum/survival/'+name+'.zs'],cwd=ROOT).decode('utf-8')

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--baseline',action='store_true',help='Also package the frozen 5.1.3 Git source for migration/rollback.')
    args=parser.parse_args()
    if 'gzdoom.exe' in subprocess.check_output(['tasklist','/FI','IMAGENAME eq gzdoom.exe','/NH'],text=True).lower():
        raise SystemExit('Finish the owned native run before replacing packages.')
    OUT.mkdir(exist_ok=True)
    package('production.pk3',{p.relative_to(ROOT/'src').as_posix():p.read_bytes() for p in (ROOT/'src').rglob('*') if p.is_file()})
    if args.baseline:
        spec=importlib.util.spec_from_file_location('export_source',ROOT/'build_playtest.py')
        export=importlib.util.module_from_spec(spec);spec.loader.exec_module(export)
        package('baseline.pk3',{k[4:]:v for k,v in export.committed_files(BASE).items() if k.startswith('src/')})
    spec=importlib.util.spec_from_file_location('old_prepare',ROOT/'assets/validation_513/prepare.py')
    old=importlib.util.module_from_spec(spec);spec.loader.exec_module(old)
    oracle=source('CaelumThermalService')+'\n'+source('CaelumThermalRules')+'\n'+source('CaelumThermalState').split('class CaelumThermalMoisture : Object',1)[1]
    oracle=oracle.replace('\n{\n    static clearscope double VaporKpa','\nclass CA140ReferenceMoisture : Object\n{\n    static clearscope double VaporKpa',1)
    oracle=oracle.replace('CaelumThermalService','CA140ReferenceService').replace('CaelumThermalRules','CA140ReferenceRules').replace('CaelumThermalMoisture','CA140ReferenceMoisture')
    members={'ZSCRIPT':b'version "4.14"\n#include "reference.zs"\n#include "checks.zs"\n',
        'reference.zs':oracle.encode(),'checks.zs':(HERE/'checks.zs').read_bytes(),
        'maps/CA140.wad':old.test_map().replace(b'CA133',b'CA140'),
        'MAPINFO':b'map CA140 "Thermal cache validation" { cluster=434 }\nGameInfo { AddEventHandlers="CA140Checks" }\n'}
    package('checks.pk3',members)
    package('audio.pk3',{'ZSCRIPT':b'version "4.14"\n#include "audio.zs"\n',
        'audio.zs':(HERE/'audio.zs').read_bytes(),'maps/CA140.wad':members['maps/CA140.wad'],
        'MAPINFO':b'map CA140 "Breathing audio validation" { cluster=434 }\nGameInfo { AddEventHandlers="CA140Audio" }\n'})
    package('manual.pk3',{'ZSCRIPT':b'version "4.14"\n#include "manual.zs"\n',
        'manual.zs':(HERE/'manual.zs').read_bytes(),'maps/CA140.wad':members['maps/CA140.wad'],
        'CVARINFO':b'server int ca140_case=0;\n',
        'MAPINFO':b'map CA140 "Thermal author inspection" { cluster=434 }\nGameInfo { AddEventHandlers="CA140Manual" }\n'})
    (OUT/'manual-smoke.cfg').write_text('wait 5; ca140_case 1; wait 10; ca140_case 2; wait 10; ca140_case 3; wait 10; ca140_case 4; wait 10; ca140_case 5; wait 10; ca140_case 6; wait 10; ca140_case 7; wait 10; ca140_case 8; wait 10; ca140_case 9; wait 10; quit\n',encoding='utf-8')
    (OUT/'audio.cfg').write_text('wait 250; save ca140-audio; wait 135; quit\n',encoding='utf-8')
    (OUT/'audio-reload.cfg').write_text('wait 135; quit\n',encoding='utf-8')
    (OUT/'checks.cfg').write_text('wait 130; save ca140-current; wait 10; quit\n',encoding='utf-8')
    package('heavy.pk3',{'ZSCRIPT':b'version "4.14"\n#include "heavy_effort.zs"\n',
        'CVARINFO':b'server bool ca140_endurance=false;\n',
        'heavy_effort.zs':(HERE/'heavy_effort.zs').read_bytes(),'maps/CA140.wad':members['maps/CA140.wad'],
        'MAPINFO':b'map CA140 "Heavy exertion" { cluster=434 }\nGameInfo { AddEventHandlers="CA140HeavyEffort" }\n'})
    commands='cl_run false; wait 35; +speed; +forward; '
    commands+=''.join('+jump; wait 1; -jump; wait 69; ' for _ in range(10))
    commands+='-forward; -speed; wait 1405; quit\n'
    (OUT/'heavy.cfg').write_text(commands,encoding='utf-8')
    endurance='alias ca140_repeat_jump "+jump; wait 1; -jump; wait 69; ca140_repeat_jump"\n'
    endurance+='cl_run false; ca140_endurance true; wait 35; +speed; +forward; ca140_repeat_jump\n'
    endurance+='wait 63035; quit\n'
    (OUT/'endurance.cfg').write_text(endurance,encoding='utf-8')
    package('carbine-heat.pk3',{'ZSCRIPT':b'version "4.14"\n#include "carbine_heat.zs"\n',
        'carbine_heat.zs':(HERE/'carbine_heat.zs').read_bytes(),'maps/CA140.wad':members['maps/CA140.wad'],
        'MAPINFO':b'map CA140 "Carbine thermal observation" { cluster=434 }\nGameInfo { AddEventHandlers="CA140CarbineHeat" }\n'})
    (OUT/'carbine-heat.cfg').write_text('wait 4210; save ca140-carbine; wait 140; quit\n',encoding='utf-8')
    package('greatsword-heat.pk3',{'ZSCRIPT':b'version "4.14"\n#include "greatsword_heat.zs"\n',
        'CVARINFO':b'server int ca140_pool=0;\nserver bool ca140_paced=false;\nserver int ca140_magic=0;\nserver int ca140_armor=3;\n',
        'greatsword_heat.zs':(HERE/'greatsword_heat.zs').read_bytes(),'maps/CA140.wad':members['maps/CA140.wad'],
        'MAPINFO':b'map CA140 "Greatsword thermal observation" { cluster=434 }\nGameInfo { AddEventHandlers="CA140GreatswordHeat" }\n'})
    (OUT/'greatsword-heat.cfg').write_text('unbindall; wait 6380; quit\n',encoding='utf-8')
    (OUT/'greatsword-paced.cfg').write_text('unbindall; ca140_paced true; wait 6380; quit\n',encoding='utf-8')
    # A temperate 22 C pool isolates retained water, not a cold-water challenge.
    from geometry_maps import geo
    import struct
    pool_text='\n'.join(geo).replace('user_ca_water_temperature_c=7;', 'user_ca_water_temperature_c=22;').replace('user_ca_water_temperature_c=15;', 'user_ca_water_temperature_c=22;')
    body=bytearray();directory=bytearray()
    for key,data in [('CA140',b''),('TEXTMAP',pool_text.encode()),('ENDMAP',b'')]:
        directory+=struct.pack('<ii8s',12+len(body),len(data),key.encode().ljust(8,b'\0'));body+=data
    pool_wad=struct.pack('<4sii',b'PWAD',3,12+len(body))+body+directory
    package('pool-heat.pk3',{'ZSCRIPT':b'version "4.14"\n#include "greatsword_heat.zs"\n',
        'CVARINFO':b'server int ca140_pool=0;\nserver bool ca140_paced=false;\nserver int ca140_magic=0;\nserver int ca140_armor=3;\n','greatsword_heat.zs':(HERE/'greatsword_heat.zs').read_bytes(),
        'maps/CA140.wad':pool_wad,'MAPINFO':b'map CA140 "Wet armor observation" { cluster=434 }\nGameInfo { AddEventHandlers="CA140GreatswordHeat" }\n'})
    (OUT/'pool-wet.cfg').write_text('unbindall; ca140_pool 1; wait 6380; quit\n',encoding='utf-8')
    (OUT/'pool-dry.cfg').write_text('unbindall; ca140_pool 2; wait 6380; quit\n',encoding='utf-8')
    for armor in range(5):
        for mode in (1,2):
            (OUT/f'mage-{mode}-{armor}.cfg').write_text(f'unbindall; ca140_magic {mode}; ca140_armor {armor}; wait 6380; quit\n',encoding='utf-8')
    print('Prepared production and independent baseline-reference probes.')

if __name__=='__main__':main()
