"""Build a 5.1.6 seed and a current loader using identical saved fixture classes."""
from pathlib import Path
import io,zipfile,subprocess
import prepare
ROOT=prepare.ROOT;HERE=prepare.HERE;OUT=prepare.OUT
BASE='abd4f578a698cefc72e91d5176c79458276e6115'
def main():
    if not (OUT/'baseline-516.pk3').exists():
        archived=subprocess.check_output(['git','archive','--format=zip',BASE,'src'],cwd=ROOT)
        with zipfile.ZipFile(io.BytesIO(archived)) as z:
            prepare.previous.package('baseline-516.pk3',{n[4:]:z.read(n) for n in z.namelist() if n.startswith('src/') and not n.endswith('/')})
    for mode in ('seed','upgrade','rollback'):
        members={'maps/CA136.wad':prepare.previous.room().replace(b'CA143',b'CA136'),
            'maps/CA136B.wad':prepare.previous.room().replace(b'CA143',b'C136B'),
            'MAPINFO':('cluster 436 { hub }\nmap CA136 "Migration room" { cluster=436 }\nmap CA136B "Hub return" { cluster=436 }\nGameInfo { AddEventHandlers="CA136'+mode.title()+'" }\n').encode(),
            'ZSCRIPT':('version "4.14"\n#include "saved.zs"\n'+('#include "'+mode+'.zs"\n' if mode!='seed' else '')).encode(),
            'saved.zs':(HERE/'saved.zs').read_bytes(),'CVARINFO':b'server bool ca136_saved_shells=false;\n'}
        if mode!='seed':members[mode+'.zs']=(HERE/(mode+'.zs')).read_bytes()
        if mode!='seed':
            (OUT/mode).mkdir(exist_ok=True)
            prepare.previous.package(mode+'/seed.pk3',members)
        else:prepare.previous.package('seed.pk3',members)
    for name,commands in {
        'seed':'unbindall;wait 80;save ca136-old-shortbow;wait 10;quit',
        'upgrade':'wait 30;save ca136-migrated;wait 10;quit',
        'reload':'wait 30;quit',
        'hub':'wait 20;changemap CA136B;wait 15;changemap CA136;wait 25;quit',
    }.items():(OUT/(name+'.cfg')).write_text(commands+'\n',encoding='utf-8')
    print('Prepared old-runtime seed, upgrade, reload and hub fixtures.')
if __name__=='__main__':main()
