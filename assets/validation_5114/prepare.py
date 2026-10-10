"""Build isolated #165 damage-feedback and native travel fixtures."""
from pathlib import Path
import zipfile
ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).resolve().parent
OUT=ROOT/'build/issue165'
def package(path,source,handler):
    path.parent.mkdir(exist_ok=True,parents=True)
    members={'MAPINFO':f'GameInfo {{ AddEventHandlers="{handler}" }}\n'.encode(),
             'ZSCRIPT':b'version "4.14"\n#include "checks.zs"\n',
             'checks.zs':(HERE/source).read_bytes()}
    with zipfile.ZipFile(path,'w',zipfile.ZIP_STORED) as z:
        for name,data in sorted(members.items()):z.writestr(zipfile.ZipInfo(name,(2000,1,1,0,0,0)),data)
def main():
    for folder,source,handler in [('baseline','baseline.zs','CA165Baseline'),('','checks.zs','CA165Checks'),('reload','reload.zs','CA165Reload'),('travel','travel.zs','CA165Travel')]:
        package(OUT/folder/'checks.pk3',source,handler)
    for name,commands in {'baseline':'wait 55; screenshot view.png; wait 15; quit',
                          'checks':'wait 55; screenshot view.png; save ca165-repaired; wait 35; quit',
                          'reload':'wait 70; quit','travel':'wait 230; quit'}.items():
        (OUT/f'{name}.cfg').write_text('unbindall; '+commands+'\n',encoding='utf-8',newline='\n')
    print('Prepared #165 damage and travel fixtures.')
if __name__=='__main__':main()
