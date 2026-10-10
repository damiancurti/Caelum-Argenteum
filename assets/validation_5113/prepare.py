"""Package deterministic #160 native actions; original saves stay untouched."""
from pathlib import Path
import zipfile

ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).resolve().parent
OUT=ROOT/'build/issue160'

def package(path,source,handler):
    path.parent.mkdir(exist_ok=True,parents=True)
    members={'MAPINFO':f'GameInfo {{ AddEventHandlers="{handler}" }}\n'.encode(),
             'ZSCRIPT':b'version "4.14"\n#include "checks.zs"\n',
             'checks.zs':(HERE/source).read_bytes()}
    with zipfile.ZipFile(path,'w',zipfile.ZIP_STORED) as z:
        for name,data in sorted(members.items()):
            z.writestr(zipfile.ZipInfo(name,(2000,1,1,0,0,0)),data)

def main():
    package(OUT/'checks.pk3','checks.zs','CA160Checks')
    package(OUT/'reload/checks.pk3','reload.zs','CA160Reload')
    for name,commands in {'baseline':'wait 70; quit',
                          'checks':'wait 70; save ca160-key; wait 35; quit',
                          'reload':'wait 70; quit'}.items():
        (OUT/f'{name}.cfg').write_text('unbindall; '+commands+'\n',encoding='utf-8',newline='\n')
    print('Prepared #160 native action fixtures.')

if __name__=='__main__':main()
