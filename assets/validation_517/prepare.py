"""Build isolated #136 mechanical and migration fixtures; local PK3s only."""
from pathlib import Path
import importlib.util
import subprocess
ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).resolve().parent
OUT=ROOT/'build/issue136'
spec=importlib.util.spec_from_file_location('previous_room',ROOT/'assets/validation_516/prepare.py')
previous=importlib.util.module_from_spec(spec);spec.loader.exec_module(previous)
previous.OUT=OUT

def main():
    if 'gzdoom.exe' in subprocess.check_output(['tasklist','/FI','IMAGENAME eq gzdoom.exe','/NH'],text=True).lower():
        raise SystemExit('Finish native runs before replacing packages.')
    OUT.mkdir(exist_ok=True)
    previous.package('production.pk3',{p.relative_to(ROOT/'src').as_posix():p.read_bytes() for p in (ROOT/'src').rglob('*') if p.is_file()})
    for fixture in ('checks','visual','integration'):
        if not (HERE/(fixture+'.zs')).exists():continue
        previous.package(fixture+'.pk3',{
            'maps/CA136.wad':previous.room().replace(b'CA143',b'CA136'),
            'maps/CA136B.wad':previous.room().replace(b'CA143',b'C136B'),
            'MAPINFO':f'cluster 436 {{ hub }}\nmap CA136 "Shotgun test" {{ cluster=436 }}\nmap CA136B "Return test" {{ cluster=436 }}\nGameInfo {{ AddEventHandlers="CA136{fixture.title()}" }}\n'.encode(),
            'ZSCRIPT':('version "4.14"\n'+('#include "checks.zs"\n' if fixture!='checks' else '')+f'#include "{fixture}.zs"\n').encode(),
            'checks.zs':(HERE/'checks.zs').read_bytes(),fixture+'.zs':(HERE/(fixture+'.zs')).read_bytes(),
            'CVARINFO':b'server int ca136_view=0;\nserver int ca136_mode=0;\n'})
    (OUT/'checks.cfg').write_text('unbindall; wait 170; quit\n',encoding='utf-8')
    commands='unbindall; wait 90; screenshot fp-ready.png; +zoom; wait 20; -zoom; wait 15; screenshot fp-aim.png; +attack; wait 10; screenshot fp-fire.png; wait 55; -attack; +reload; wait 2; -reload; wait 12; screenshot fp-open.png; wait 90; screenshot fp-load.png; wait 110; screenshot fp-complete.png; ca136_mode 1; r_drawplayersprites false; '
    for stage in range(48):commands+=f'ca136_view {stage}; wait 15; screenshot world-{stage}.png; '
    commands+='ca136_mode 2; r_drawplayersprites true; wait 15; screenshot fp-t2.png; ca136_mode 3; wait 15; screenshot fp-t3.png; ca136_mode 5; wait 105; screenshot fp-single.png; wait 110; ca136_mode 6; wait 105; screenshot fp-partial.png; wait 110; ca136_mode 4; wait 10; quit\n'
    (OUT/'visual.cfg').write_text(commands,encoding='utf-8')
    (OUT/'manual.cfg').write_text('bind w +forward;bind s +back;bind a +moveleft;bind d +moveright;bind mouse1 +attack;bind mouse2 +altattack;bind r +reload;bind z +zoom;bind c +crouch;bind tab +showscores;wait 90\n',encoding='utf-8')
    print('Prepared current runtime and #136 isolated fixtures.')

if __name__=='__main__':main()
