"""Build separate lot checks without replacing the accepted core fixture."""
from pathlib import Path
import importlib.util
import zipfile

HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[1]
WORK=ROOT/'build/issue410'

def main():
    spec=importlib.util.spec_from_file_location('room580',ROOT/'assets/validation_580/prepare.py')
    module=importlib.util.module_from_spec(spec);spec.loader.exec_module(module)
    members={'ZSCRIPT':b'version "4.14"\n#include "lot_checks.zs"\n',
        'lot_checks.zs':(HERE/'lot_checks.zs').read_bytes(),
        'MAPINFO':b'GameInfo { AddEventHandlers="CA410LotChecks" }\ncluster 8410 { hub }\nmap CAF410 "Food lot checks" { cluster=8410 }\nmap CAF410B "Food return" { cluster=8410 }\n',
        'maps/CAF410.wad':module.wad(module.room(),'CAF410'),
        'maps/CAF410B.wad':module.wad(module.room(),'CAF410B')}
    WORK.mkdir(parents=True,exist_ok=True)
    with zipfile.ZipFile(WORK/'lot-checks.pk3','w',zipfile.ZIP_STORED) as archive:
        for name,blob in sorted(members.items()):
            archive.writestr(zipfile.ZipInfo(name,(2000,1,1,0,0,0)),blob)
    scripts={'lots':'wait 35; netevent ca410_lots; wait 5; quit',
        'lot-save':'wait 35; netevent ca410_lotseed; save ca410-lots; wait 5; quit',
        'lot-load':'wait 35; netevent ca410_lotload; wait 5; quit',
        'lot-hub':'wait 35; netevent ca410_lotload; changemap CAF410B; wait 35; netevent ca410_lotload; changemap CAF410; wait 35; netevent ca410_lotload; wait 5; quit'}
    for name,script in scripts.items():(WORK/(name+'.cfg')).write_text(script+'\n',encoding='utf-8')

if __name__=='__main__':main()
